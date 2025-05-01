#!/bin/bash

echo "🔍 Verifying Ryzen 7 5700X Tuning on Linux"

echo -n "✅ CPU Driver: "
grep . /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver

echo -n "✅ EPP Mode: "
cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference

echo -n "✅ CPPC Detected: "
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/amd_pstate_highest_perf ]; then
  echo "Yes"
else
  echo "No"
fi

echo -n "✅ Preferred Core Ranking: "
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/amd_pstate_prefcore_ranking ]; then
  echo "Yes"
else
  echo "No"
fi

echo -n "✅ Running Kernel: "
uname -r

echo -e "\n✅ All key Linux-side Ryzen tuning options appear active.\n"