#!/usr/bin/env python
"""
Convert Bitwarden JSON export to KeePassXC KDBX format using pykeepass.
Supports upsert: updates existing entries or creates new ones.
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
    value = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]", "", str(value))
    return value


def get_unique_name(kp, group, base_name, counter=0):
    """Generate unique entry name to avoid duplicates."""
    name = base_name if counter == 0 else f"{base_name} ({counter})"
    existing = kp.find_entries(title=name, group=group, first=True)
    if existing:
        return get_unique_name(kp, group, base_name, counter + 1)
    return name


def find_entry_in_group(kp, group, base_name, counter=0):
    """Find existing entry by name in group. Returns (entry, name) if found, (None, unique_name) if not."""
    name = base_name if counter == 0 else f"{base_name} ({counter})"
    existing = kp.find_entries(title=name, group=group, first=True)
    if existing:
        return existing, name
    if counter > 0:
        return None, name
    next_name = f"{base_name} ({counter + 1})"
    next_entry = kp.find_entries(title=next_name, group=group, first=True)
    if next_entry:
        return find_entry_in_group(kp, group, base_name, counter + 1)
    return None, name


def upsert_login_entry(kp, entry_data, group):
    """Update existing or create new login entry. Returns (updated, created)."""
    raw_name = entry_data.get("name") or "Unnamed"
    base_name = sanitize_string(raw_name)

    existing_entry, unique_name = find_entry_in_group(kp, group, base_name)
    login = entry_data.get("login") or {}

    username = sanitize_string(login.get("username") or "")
    password = sanitize_string(login.get("password") or "")
    urls = login.get("uris", [])
    url = sanitize_string(urls[0].get("uri", "")) if urls else ""
    notes = sanitize_string(entry_data.get("notes") or "")

    if existing_entry:
        existing_entry.username = username
        existing_entry.password = password
        existing_entry.url = url
        existing_entry.notes = notes
        existing_entry.set_custom_property("TOTP Seed", "")
        for key in list(existing_entry.custom_properties.keys()):
            if key != "TOTP Seed":
                try:
                    existing_entry.delete_custom_property(key)
                except Exception:
                    pass
        totp = login.get("totp")
        if totp:
            existing_entry.set_custom_property("TOTP Seed", sanitize_string(totp))
        for field in entry_data.get("fields", []) or []:
            field_name = sanitize_string(field.get("name") or "Custom Field")
            field_value = sanitize_string(field.get("value") or "")
            if field_name and field_value:
                existing_entry.set_custom_property(field_name, field_value)
        return True, False

    entry = kp.add_entry(group, unique_name, username, password, url=url, notes=notes)
    totp = login.get("totp")
    if totp:
        entry.set_custom_property("TOTP Seed", sanitize_string(totp))
    for field in entry_data.get("fields", []) or []:
        field_name = sanitize_string(field.get("name") or "Custom Field")
        field_value = sanitize_string(field.get("value") or "")
        if field_name and field_value:
            entry.set_custom_property(field_name, field_value)
    return False, True


def upsert_note_entry(kp, entry_data, group):
    """Update existing or create new secure note entry."""
    raw_name = entry_data.get("name") or "Unnamed Note"
    base_name = sanitize_string(raw_name)

    existing_entry, unique_name = find_entry_in_group(kp, group, base_name)
    notes = sanitize_string(entry_data.get("notes") or "")

    if existing_entry:
        existing_entry.notes = notes
        return True, False

    kp.add_entry(group, unique_name, "", "", notes=notes)
    return False, True


def upsert_card_entry(kp, entry_data, group):
    """Update existing or create new card entry."""
    raw_name = entry_data.get("name") or "Unnamed Card"
    base_name = sanitize_string(raw_name)

    existing_entry, unique_name = find_entry_in_group(kp, group, base_name)
    card = entry_data.get("card") or {}
    notes = sanitize_string(entry_data.get("notes") or "")
    cardholder = sanitize_string(card.get("cardholderName") or "")
    number = sanitize_string(card.get("number") or "")
    exp_month = sanitize_string(str(card.get("expMonth") or ""))
    exp_year = sanitize_string(str(card.get("expYear") or ""))
    code = sanitize_string(card.get("code") or "")

    card_info = f"""Cardholder: {cardholder}
Number: {number}
Expiry: {exp_month}/{exp_year}
Security Code: {code}

{notes}"""

    if existing_entry:
        existing_entry.username = cardholder
        existing_entry.password = code
        existing_entry.notes = card_info
        return True, False

    kp.add_entry(group, unique_name, cardholder, code, notes=card_info)
    return False, True


def upsert_identity_entry(kp, entry_data, group):
    """Update existing or create new identity entry."""
    raw_name = entry_data.get("name") or "Unnamed Identity"
    base_name = sanitize_string(raw_name)

    existing_entry, unique_name = find_entry_in_group(kp, group, base_name)
    identity = entry_data.get("identity") or {}
    notes = sanitize_string(entry_data.get("notes") or "")

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

    if existing_entry:
        existing_entry.username = sanitize_string(identity.get("email") or "")
        existing_entry.notes = identity_info
        return True, False

    kp.add_entry(
        group,
        unique_name,
        sanitize_string(identity.get("email") or ""),
        "",
        notes=identity_info,
    )
    return False, True


def get_or_create_group(kp, folder_name):
    """Get existing group or create new one."""
    if not folder_name or folder_name == "No Folder":
        return kp.root_group

    folder_name = sanitize_string(folder_name)

    for group in kp.groups:
        if group.name == folder_name:
            return group

    return kp.add_group(kp.root_group, folder_name)


def convert_bitwarden_to_keepass(
    json_path, kdbx_path, password, existing_kdbx_path=None
):
    """Convert Bitwarden JSON export to KDBX database with upsert behavior."""

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if existing_kdbx_path and os.path.exists(existing_kdbx_path):
        kp = PyKeePass(existing_kdbx_path, password=password)
    else:
        kp = create_database(kdbx_path, password=password)

    folders = data.get("folders") or []
    folder_map = {"": kp.root_group, None: kp.root_group}

    for folder in folders:
        folder_name = folder.get("name") or ""
        folder_id = folder.get("id") or ""
        if folder_name and folder_id:
            group = get_or_create_group(kp, folder_name)
            folder_map[folder_id] = group

    items = data.get("items") or []

    updated_count = 0
    created_count = 0
    for item in items:
        item_type = item.get("type") or 1
        folder_id = item.get("folderId")
        group = folder_map.get(folder_id, kp.root_group)

        try:
            if item_type == 1:
                updated, created = upsert_login_entry(kp, item, group)
            elif item_type == 2:
                updated, created = upsert_note_entry(kp, item, group)
            elif item_type == 3:
                updated, created = upsert_card_entry(kp, item, group)
            elif item_type == 4:
                updated, created = upsert_identity_entry(kp, item, group)
            else:
                updated, created = upsert_note_entry(kp, item, group)

            if updated:
                updated_count += 1
            if created:
                created_count += 1
        except Exception as e:
            item_name = item.get("name") or "unnamed"
            print(f"Warning: Failed to import item '{item_name}': {e}", file=sys.stderr)
            continue

    kp.save()
    print(
        f"Upserted {updated_count} entries, created {created_count} new entries into {kdbx_path}"
    )
    if updated_count > 0:
        print(f"Updated {updated_count} existing entries")
    if created_count > 0:
        print(f"Created {created_count} new entries")


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(
            "Usage: bw-to-keepass.py <bitwarden.json> <output.kdbx> <password> [existing_kdbx_path]",
            file=sys.stderr,
        )
        sys.exit(1)

    json_path = sys.argv[1]
    kdbx_path = sys.argv[2]
    password = sys.argv[3]
    existing_kdbx_path = sys.argv[4] if len(sys.argv) > 4 else None

    if not os.path.exists(json_path):
        print(f"Error: JSON file not found: {json_path}", file=sys.stderr)
        sys.exit(1)

    try:
        convert_bitwarden_to_keepass(json_path, kdbx_path, password, existing_kdbx_path)
    except CredentialsError:
        print("Error: Invalid password for existing KeePass database", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
