#!/usr/bin/env python
"""
Convert Bitwarden JSON export to KeePassXC KDBX format using pykeepass.
"""

import sys
import json
import os
from pykeepass import PyKeePass, create_database
from pykeepass.exceptions import CredentialsError
import re


def sanitize_string(value):
    """Sanitize string for XML compatibility - remove control characters."""
    if value is None:
        return ""
    # Remove control characters except tabs, newlines, and carriage returns
    value = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]", "", str(value))
    return value


def get_unique_entry_name(kp, group, base_name, counter=0):
    """Generate unique entry name to avoid duplicates."""
    name = base_name if counter == 0 else f"{base_name} ({counter})"
    # Check if entry exists in group
    existing = kp.find_entries(title=name, group=group, first=True)
    if existing:
        return get_unique_entry_name(kp, group, base_name, counter + 1)
    return name


def create_entry_from_login(kp, entry_data, group):
    """Create a KeePass entry from Bitwarden login item."""
    raw_name = entry_data.get("name") or "Unnamed"
    name = get_unique_entry_name(kp, group, sanitize_string(raw_name))
    login = entry_data.get("login") or {}

    username = sanitize_string(login.get("username") or "")
    password = sanitize_string(login.get("password") or "")

    # Get URL
    urls = login.get("uris", [])
    url = sanitize_string(urls[0].get("uri", "")) if urls else ""

    # Get notes
    notes = sanitize_string(entry_data.get("notes") or "")

    # Create entry
    entry = kp.add_entry(group, name, username, password, url=url, notes=notes)

    # Add custom fields (TOTP, etc.)
    totp = login.get("totp")
    if totp:
        entry.set_custom_property("TOTP Seed", sanitize_string(totp))

    # Add other fields
    for field in entry_data.get("fields", []) or []:
        field_name = sanitize_string(field.get("name") or "Custom Field")
        field_value = sanitize_string(field.get("value") or "")
        if field_name and field_value:
            entry.set_custom_property(field_name, field_value)

    return entry


def create_entry_from_note(kp, entry_data, group):
    """Create a KeePass entry from Bitwarden secure note."""
    raw_name = entry_data.get("name") or "Unnamed Note"
    name = get_unique_entry_name(kp, group, sanitize_string(raw_name))
    notes = sanitize_string(entry_data.get("notes") or "")

    # Create entry with no password
    entry = kp.add_entry(group, name, "", "", notes=notes)

    return entry


def create_entry_from_card(kp, entry_data, group):
    """Create a KeePass entry from Bitwarden card item."""
    raw_name = entry_data.get("name") or "Unnamed Card"
    name = get_unique_entry_name(kp, group, sanitize_string(raw_name))
    card = entry_data.get("card") or {}

    notes = sanitize_string(entry_data.get("notes") or "")
    cardholder = sanitize_string(card.get("cardholderName") or "")
    number = sanitize_string(card.get("number") or "")
    exp_month = sanitize_string(str(card.get("expMonth") or ""))
    exp_year = sanitize_string(str(card.get("expYear") or ""))
    code = sanitize_string(card.get("code") or "")

    # Build notes with card info
    card_info = f"""Cardholder: {cardholder}
Number: {number}
Expiry: {exp_month}/{exp_year}
Security Code: {code}

{notes}"""

    entry = kp.add_entry(group, name, cardholder, code, notes=card_info)

    return entry


def create_entry_from_identity(kp, entry_data, group):
    """Create a KeePass entry from Bitwarden identity item."""
    raw_name = entry_data.get("name") or "Unnamed Identity"
    name = get_unique_entry_name(kp, group, sanitize_string(raw_name))
    identity = entry_data.get("identity") or {}
    notes = sanitize_string(entry_data.get("notes") or "")

    # Build identity info
    identity_info = f"""Title: {sanitize_string(identity.get("title") or "")}
First Name: {sanitize_string(identity.get("firstName") or "")}
Middle Name: {sanitize_string(identity.get("middleName") or "")}
Last Name: {sanitize_string(identity.get("lastName") or "")}
Email: {sanitize_string(identity.get("email") or "")}
Phone: {sanitize_string(identity.get("phone") or "")}

Address:
{sanitize_string(identity.get("address1") or "")}
{sanitize_string(identity.get("address2") or "")}
{sanitize_string(identity.get("city") or "")}, {sanitize_string(identity.get("state") or "")} {sanitize_string(identity.get("postalCode") or "")}
{sanitize_string(identity.get("country") or "")}

SSN: {sanitize_string(identity.get("ssn") or "")}
Passport: {sanitize_string(identity.get("passportNumber") or "")}
License: {sanitize_string(identity.get("licenseNumber") or "")}

{notes}"""

    entry = kp.add_entry(
        group,
        name,
        sanitize_string(identity.get("email") or ""),
        "",
        notes=identity_info,
    )

    return entry


def get_or_create_group(kp, folder_name):
    """Get existing group or create new one."""
    if not folder_name or folder_name == "No Folder":
        return kp.root_group

    # Sanitize folder name
    folder_name = sanitize_string(folder_name)

    # Try to find existing group
    for group in kp.groups:
        if group.name == folder_name:
            return group

    # Create new group
    return kp.add_group(kp.root_group, folder_name)


def convert_bitwarden_to_keepass(json_path, kdbx_path, password):
    """Convert Bitwarden JSON export to KDBX database."""

    # Load Bitwarden JSON
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Create new KDBX database
    kp = create_database(kdbx_path, password=password)

    # Process folders first to create groups
    folders = data.get("folders") or []
    folder_map = {"": kp.root_group, None: kp.root_group}  # Map folder ID to group

    for folder in folders:
        folder_name = folder.get("name") or ""
        folder_id = folder.get("id") or ""
        if folder_name and folder_id:
            group = get_or_create_group(kp, folder_name)
            folder_map[folder_id] = group

    # Process items
    items = data.get("items") or []

    imported_count = 0
    for item in items:
        item_type = item.get("type") or 1  # 1 = login by default
        folder_id = item.get("folderId")

        # Get the appropriate group
        group = folder_map.get(folder_id, kp.root_group)

        # Create entry based on type
        # Bitwarden types: 1=login, 2=secure note, 3=card, 4=identity
        try:
            if item_type == 1:
                create_entry_from_login(kp, item, group)
            elif item_type == 2:
                create_entry_from_note(kp, item, group)
            elif item_type == 3:
                create_entry_from_card(kp, item, group)
            elif item_type == 4:
                create_entry_from_identity(kp, item, group)
            else:
                # Unknown type, treat as note
                create_entry_from_note(kp, item, group)
            imported_count += 1
        except Exception as e:
            item_name = item.get("name") or "unnamed"
            print(
                f"Warning: Failed to import item '{item_name}': {e}",
                file=sys.stderr,
            )
            continue

    # Save database
    kp.save()
    print(f"Successfully imported {imported_count}/{len(items)} items into {kdbx_path}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(
            "Usage: bw-to-keepass.py <bitwarden.json> <output.kdbx> <password>",
            file=sys.stderr,
        )
        sys.exit(1)

    json_path = sys.argv[1]
    kdbx_path = sys.argv[2]
    password = sys.argv[3]

    if not os.path.exists(json_path):
        print(f"Error: JSON file not found: {json_path}", file=sys.stderr)
        sys.exit(1)

    try:
        convert_bitwarden_to_keepass(json_path, kdbx_path, password)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
