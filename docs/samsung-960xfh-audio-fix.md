# Samsung Galaxy Book3 Pro (960XFH) — Audio Fix on Arch Linux

**Hardware:** Samsung 960XFH-P07ALQ (NP960XFH_XA1BR)  
**CPU:** Intel Raptor Lake-P (i7-13xxx)  
**Audio:** Intel SOF / Raptor Lake-P cAVS — `snd_soc_skl_hda_dsp`, Realtek ALC298 (I2C-connected)  
**OS:** Arch Linux, kernel 7.0.3-arch1-2  
**Audio stack:** PipeWire 1.6.4, WirePlumber 0.5

---

## Symptoms

1. System freezes for ~2 minutes when opening Zen Browser (or any browser with audio).
2. After freeze, no audio output — PipeWire shows only "Dummy Output".
3. After reboots, audio eventually comes back as "Raptor Lake-P/U/H cAVS Pro N" (pro-audio
   profile sinks) instead of named "Speaker" / "Headphone" ports.
4. `pactl list cards` shows only `off` and `pro-audio` profiles — no HiFi UCM profile.

---

## Root Cause Chain

```
NHLT table reports 2 DMICs
  → kernel auto-selects sof-hda-generic-idisp-2ch.tplg
    → topology only creates HDMI PCM devices (no HDA Analog device 0)
      → Speaker/Headphone physically exist but no PCM for them
        → PipeWire cannot open HDA Analog → only HDMI sinks
```

Separately, the SOF DSP runtime power management was enabled:

```
wireplumber opens ALSA capture device
  → kernel triggers rpm_resume on SOF DSP
    → rpm_resume hangs for 122 s (kernel bug / driver race)
      → PipeWire-Pulse times out
        → all audio streams blocked → browser/app freeze
```

And the UCM HiFi profile never loaded because:

```
UCM sof-hda-dsp detects cfg-dmics:2 in card components
  → adds Mic1 device with CapturePCM hw:sofhdadsp,6
    → PipeWire ACP probes device 6 → ENOENT (topology has no DMIC PCM)
      → all HiFi profiles fail probe → fallback to pro-audio
        → no Speaker / Headphone sinks, only raw pro-audio outputs
```

Additionally, PipeWire's `api.alsa.split-enable = true` created internal split PCM paths
(`<<<SplitPCM=1>>>hw:0`) that UCM couldn't match, producing earlier "No UCM verb is valid"
errors when the above wasn't yet the dominant failure mode.

---

## Things That Were Tried (Chronologically)

### 1. Force HDA driver instead of SOF

```
# /etc/modprobe.d/audio-hda.conf
options snd-intel-dspcfg dsp_driver=1
```

**Result: Failed.** The Realtek ALC298 on this laptop is connected via I2C, not the HDA bus.
Only SOF can drive it. The HDA bus has no codec — pure silence.

**Reverted.**

### 2. Force SOF topology `sof-hda-generic-2ch.tplg`

```
# /etc/modprobe.d/sof-audio.conf
options snd-intel-dspcfg dsp_driver=3
options snd_sof tplg_filename=sof-hda-generic-2ch.tplg
```

**Result: Failed.** Kernel rejected the topology:
```
sof-audio-pci-intel-tgl: could not load header (ABI mismatch, EINVAL -22)
```
The `sof-hda-generic-2ch.tplg` (44 KB) is incompatible with the IPC3 firmware
(`sof-rpl.ri`, ABI 3:22:1) loaded on this machine. The larger 2ch/4ch topology files
appear to target a different firmware ABI.

**Reverted.**

### 3. udev rule (ACTION=="add") to disable SOF PM

```
# /etc/udev/rules.d/99-sof-audio-pm.rules
ACTION=="add", KERNEL=="0000:00:1f.3", SUBSYSTEM=="pci", ATTR{power/control}="on"
```

**Result: Ineffective.** The `ACTION=="add"` rule fires only once at device detection.
`udevadm trigger` sends a `change` event, not `add`, so manual re-trigger did nothing.
The power/control kept reverting to `auto` after PipeWire opened the device.

### 4. systemd oneshot service (ran too early)

```ini
# /etc/systemd/system/sof-audio-pm-fix.service
[Unit]
After=sysinit.target
DefaultDependencies=no
[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo on > /sys/bus/pci/devices/0000:00:1f.3/power/control'
RemainAfterExit=yes
[Install]
WantedBy=sysinit.target
```

**Result: Partially worked** — fixed the freeze on first boot, but `power/control` reverted to
`auto` when PipeWire initialized the audio device later. After suspend/resume cycles the freeze
came back.

### 5. Force topology `sof-hda-generic.tplg` (fixed HDA Analog)

```
# /etc/modprobe.d/sof-audio.conf
options snd-intel-dspcfg dsp_driver=3
options snd_sof tplg_filename=sof-hda-generic.tplg
```

**Result: Partial success.** HDA Analog (device 0) appeared in `aplay -l`:
```
card 0: sofhdadsp [sof-hda-dsp], device 0: HDA Analog (*) []
card 0: sofhdadsp [sof-hda-dsp], device 3: HDMI1 (*) []
...
```
`speaker-test -D hw:0,0` played audio. But PipeWire still only showed pro-audio sinks
(no Speaker/Headphone labels) because the UCM HiFi profile still failed to probe.

The reason: `sof-hda-generic.tplg` has no DMIC PCM (device 6), but the UCM config adds
a Mic1 device requiring `hw:sofhdadsp,6` because NHLT reports `cfg-dmics:2`. All HiFi
profiles include Mic1 → all fail probe → pro-audio fallback.

### 6. PipeWire `api.alsa.split-enable = false` (fixed split PCM errors)

```conf
# ~/.config/wireplumber/wireplumber.conf.d/50-sof-hda-fix.conf
monitor.alsa.rules = [{
  matches = [{ device.name = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic" }]
  actions = { update-props = { api.alsa.split-enable = false } }
}]
```

**Result: Cleared earlier UCM errors** ("No UCM verb is valid for `<<<SplitPCM=1>>>hw:0`")
but HiFi profiles still didn't load because the Mic1/device-6 failure was now the sole
blocking issue.

### 7. UCM override attempt via `/etc/alsa/ucm2/`

Attempted to create a local UCM override in `/etc/alsa/ucm2/conf.d/sof-hda-dsp/` that
would re-define the card config without DMIC devices.

**Result: Failed.** alsa-lib does not search `/etc/alsa/ucm2/` in its compiled-in UCM
search path on Arch Linux. The override was never loaded.

---

## The Real Fix

### Problem Summary

Three independent issues needed to be fixed:

| Issue | Root Cause | Fix |
|---|---|---|
| Freeze | SOF DSP runtime PM hang in wireplumber | udev `RUN+=` rule to force `power/control=on` |
| No HDA Analog speaker | Wrong topology auto-selected (idisp-2ch) | Force `sof-hda-generic.tplg` via modprobe |
| No Speaker/Headphone UCM ports | UCM adds Mic1 (DMIC device 6) which doesn't exist in forced topology | Patch UCM config to not add DMIC device |

---

### Fix 1 — Force correct SOF topology

```bash
sudo tee /etc/modprobe.d/sof-audio.conf > /dev/null << 'EOF'
options snd-intel-dspcfg dsp_driver=3
options snd_sof tplg_filename=sof-hda-generic.tplg
EOF
sudo mkinitcpio -P
```

**Why:** The kernel auto-selects `sof-hda-generic-idisp-2ch.tplg` when it detects 2 DMICs
in the NHLT table (`cfg-dmics:2`). That topology has no HDA Analog PCM — only HDMI outputs.
`sof-hda-generic.tplg` includes HDA Analog (device 0) and all three HDMI outputs. DMIC
support is sacrificed but the ALC298 speakers and headphone jack work correctly.

---

### Fix 2 — Disable DMIC device in UCM config

The `sof-hda-generic.tplg` topology has no DMIC PCM (device 6). The UCM config for
`sof-hda-dsp` automatically adds a `Mic1` device (DMIC on hw:sofhdadsp,6) whenever
`cfg-dmics:` appears in card components. Since the card always reports `cfg-dmics:2` from
the NHLT table (regardless of which topology is loaded), all HiFi UCM profiles include
Mic1, and all fail probe because device 6 doesn't exist.

Fix: force `DeviceDmic` to empty in the UCM config so Mic1 is never added:

```bash
sudo sed -i 's/Define\.DeviceDmic "Mic1"/Define.DeviceDmic ""/' \
  /usr/share/alsa/ucm2/Intel/sof-hda-dsp/sof-hda-dsp.conf
```

Verify the result (should show no Mic1):
```bash
alsaucm -c sof-hda-dsp set _verb HiFi list _devices
# Expected: Headphones, Speaker, Mic2, HDMI1, HDMI2, HDMI3
```

**Note:** This file is owned by the `alsa-ucm-conf` package and will be overwritten on
package upgrades. Re-apply after upgrading `alsa-ucm-conf`.

---

### Fix 3 — Disable PipeWire split-enable for the SOF card

PipeWire's default ALSA monitor enables `api.alsa.split-enable = true` for all devices.
This creates internal split PCM paths that UCM cannot match, producing errors during UCM
verb setup. Disable it for this specific card:

```bash
mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
cat > ~/.config/wireplumber/wireplumber.conf.d/50-sof-hda-fix.conf << 'EOF'
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
      }
    ]
    actions = {
      update-props = {
        api.alsa.split-enable = false
      }
    }
  }
]
EOF
```

This file is already tracked in the dotfiles repo at
`config-files/wireplumber/wireplumber.conf.d/50-sof-hda-fix.conf`.

---

### Fix 4 — Prevent SOF DSP runtime PM from causing freeze

The SOF DSP runtime power management causes wireplumber to hang for ~2 minutes when it
tries to open the ALSA capture device while the DSP is in a low-power state. The DSP
stalls in `rpm_resume` indefinitely.

Fix with a udev `RUN+=` rule that forces `power/control=on` on every udev event for this
PCI device (fires on add, change, and bind — persists across suspend/resume):

```bash
sudo tee /etc/udev/rules.d/99-sof-audio-pm.rules > /dev/null << 'EOF'
# Keep SOF audio DSP runtime PM disabled to prevent wireplumber hang/freeze
SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x51ca", RUN+="/bin/sh -c 'echo on > /sys%p/power/control'"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=pci --attr-match=vendor=0x8086 --attr-match=device=0x51ca
```

Verify:
```bash
cat /sys/bus/pci/devices/0000:00:1f.3/power/control
# Expected: on
```

**Why `RUN+=` instead of `ATTR{power/control}="on"`:** The direct attribute assignment only
works at the moment the udev rule is evaluated on the first "add" event. Using `RUN+=` with
a shell command re-applies the setting on every subsequent event, including "change" events
triggered when PipeWire opens/closes the device.

---

### Fix 5 — Clear WirePlumber stored profile state

After the UCM fix, WirePlumber may have a stale state file remembering `pro-audio` from
before the fix was applied. Remove it so WirePlumber selects the now-working HiFi profile:

```bash
sed -i '/alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic/d' \
  ~/.local/state/wireplumber/default-profile
systemctl --user restart wireplumber
```

---

### Verification

After applying all fixes and rebooting:

```bash
# Should show HiFi profile active
pactl list cards | grep "Active Profile"
# Expected: Active Profile: HiFi (HDMI1, HDMI2, HDMI3, Mic2, Speaker)

# Should show Speaker and HDMI sinks (no pro-audio)
wpctl status | grep -A 8 "Sinks:"

# SOF PM must stay on
cat /sys/bus/pci/devices/0000:00:1f.3/power/control
# Expected: on

# Playback test
speaker-test -c 2 -t wav -l 1
```

---

### Files Modified

| File | Change |
|---|---|
| `/etc/modprobe.d/sof-audio.conf` | Force `dsp_driver=3` (SOF) and `tplg_filename=sof-hda-generic.tplg` |
| `/usr/share/alsa/ucm2/Intel/sof-hda-dsp/sof-hda-dsp.conf` | Set `DeviceDmic ""` to disable DMIC device |
| `~/.config/wireplumber/wireplumber.conf.d/50-sof-hda-fix.conf` | Disable `api.alsa.split-enable` for SOF card |
| `/etc/udev/rules.d/99-sof-audio-pm.rules` | `RUN+=` rule to keep SOF DSP PM at `on` |
| `/etc/systemd/system/sof-audio-pm-fix.service` | Oneshot service (belt-and-suspenders, runs at boot) |
