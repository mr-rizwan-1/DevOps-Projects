#!/usr/bin/env python3

import psutil
from datetime import datetime

THRESHOLD = 80
alert_count = 0

print("=" * 60)
print(f"Disk Space Monitor - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("=" * 60)

print(f"{'Drive':<20}{'Total':<10}{'Used':<10}{'Free':<10}{'Usage'}")

for partition in psutil.disk_partitions():

    try:
        usage = psutil.disk_usage(partition.mountpoint)

        total = usage.total / (1024 ** 3)
        used = usage.used / (1024 ** 3)
        free = usage.free / (1024 ** 3)

        print(
            f"{partition.device:<20}"
            f"{total:>6.1f}GB  "
            f"{used:>6.1f}GB  "
            f"{free:>6.1f}GB  "
            f"{usage.percent:.0f}%"
        )

        if usage.percent >= THRESHOLD:
            print(f"ALERT: {partition.device} is at {usage.percent:.0f}% usage!\n")
            alert_count += 1

    except PermissionError:
        pass

if alert_count == 0:
    print("\nAll drives are healthy.")
else:
    print(f"\nTotal Alerts: {alert_count}")