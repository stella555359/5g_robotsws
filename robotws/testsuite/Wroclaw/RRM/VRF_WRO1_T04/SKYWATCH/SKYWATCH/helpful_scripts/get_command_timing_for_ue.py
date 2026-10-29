import re
import sys
from datetime import datetime
import csv


if len(sys.argv) < 2:
    print("Użycie: python get_command_timing_for_ue.py <sciezka_do_pliku_log> <ue_id>")
    sys.exit(1)

log_path = sys.argv[1]
ue = str(sys.argv[2])

with open(log_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

regex = rf"(\d{{4}}-\d{{2}}-\d{{2}} \d{{2}}:\d{{2}}:\d{{2}},\d+).*Successfully sent command to telnet:(.*={ue}.*)"
lines_dict = {}  # mapa: timestamp -> komenda, w której występuje


for line in lines:
    match = re.search(regex, line)
    if match:
        lines_dict[f"{match.group(1)}"] = f"{match.group(2)}"
for key, value in lines_dict.items():
    print(f"{key} : {value}")

items = sorted(lines_dict.items(), key=lambda x: x[0])
rows = []
prev_time = None
fmt = "%Y-%m-%d %H:%M:%S,%f"

for ts_str, cmd in items:
    ts = datetime.strptime(ts_str, fmt)

    if prev_time is None:
        diff = 0
    else:
        diff = (ts - prev_time).total_seconds()
    rows.append([ts_str, cmd, diff])
    prev_time = ts

with open("output.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["timestamp", "command", "diff_seconds"])
    writer.writerows(rows)
