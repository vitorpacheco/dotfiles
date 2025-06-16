-- Disable automatic profile switching for Bluetooth headsets

local rule = {
	matches = {
		{
			{ "node.name", "matches", "bluez_card.*" },
			{ "device.api", "matches", "bluez" },
		},
	},
	actions = {
		-- Set preferred profile to A2DP sink.
		-- This will make A2DP the default if available.
		-- "auto_switch=false" in PulseAudio is effectively
		-- achieved by making A2DP the higher priority.
		{ "updateProperty", "bluez5.auto-profile", "a2dp-sink" },
		-- You might also try:
		-- { "updateProperty", "bluez5.enable-sbc-hd", "true" },
		-- { "updateProperty", "bluez5.enable-ldac", "true" }, -- if your device supports LDAC
	},
}

--table.insert(alsa_monitor.rules, rule)
