import sys
import csv
import re
import os
from datetime import datetime


# Get input and output file names from command-line arguments
input_file = sys.argv[1]
output_file = sys.argv[2]

# Create a log file name based on current timestamp and input file
base_name = os.path.splitext(os.path.basename(input_file))[0]
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
log_file = f"analysis_log_{base_name}_{timestamp}.txt"

# Dictionary to hold the scheduling data
scheduling_data = []


def log_print(message, file):
    print(message)
    file.write(message + "\n")


# Read the input CSV file
with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    reader = csv.reader(f)
    for row in reader:
        line = row[0]

        # Look for load control events
        is_load_control_event = False
        direction = ""

        if 'dlLoadControlData' in line:
            is_load_control_event = True
            direction = "DL"
        elif 'ulLoadControlData' in line:
            is_load_control_event = True
            direction = "UL"

        if is_load_control_event:
            # Extract physCellId, SFN, slot
            physCellId_match = re.search(r'physCellId;(\d+)', line)
            sfn_match = re.search(r'sfn;(\d+)', line)
            slot_match = re.search(r'slot;(\d+)', line)

            # Extract scheduling metrics
            scheduled_ues_match = re.search(r'scheduledUes;(\d+)', line)

            if (physCellId_match and sfn_match and slot_match and
                    scheduled_ues_match):
                physCellId = int(physCellId_match.group(1))
                sfn = int(sfn_match.group(1))
                slot = int(slot_match.group(1))
                scheduled_ues = int(scheduled_ues_match.group(1))

                # Store the data
                scheduling_data.append({
                    'Direction': direction,
                    'PhysCellId': physCellId,
                    'SFN': sfn,
                    'Slot': slot,
                    'ScheduledUes': scheduled_ues
                })

# Write the results to output CSV
with open(output_file, 'w', newline='') as f_csv:
    writer = csv.writer(f_csv)
    # Write header
    writer.writerow(['Direction', 'PhysCellId', 'SFN', 'Slot', 'ScheduledUes'])

    # Sort data by SFN and Slot
    sorted_data = sorted(scheduling_data,
                         key=lambda x: (x['PhysCellId'], x['SFN'], x['Slot']))

    # Write data rows
    for entry in sorted_data:
        writer.writerow([
            entry['Direction'],
            entry['PhysCellId'],
            entry['SFN'],
            entry['Slot'],
            entry['ScheduledUes']
        ])

# Write statistics to both console and log file
with open(log_file, 'w') as log_f:
    # Write header to log file
    log_print(f"===== ANALYSIS LOG =====", log_f)
    log_print(f"Input file: {input_file}", log_f)
    log_print(f"Output file: {output_file}", log_f)
    log_print(f"Log file: {log_file}", log_f)
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_print(f"Analysis timestamp: {timestamp}", log_f)
    log_print(f"========================\n", log_f)

    # Print summary statistics
    if scheduling_data:
        max_scheduled = max(entry['ScheduledUes']
                            for entry in scheduling_data)
        total_ues = sum(entry['ScheduledUes'] for entry in scheduling_data)
        avg_scheduled = total_ues / len(scheduling_data)

        log_print(f"\nAnalysis complete. Results written to {output_file}",
                  log_f)
        events_count = len(scheduling_data)
        log_print(f"Total scheduling events found: {events_count}", log_f)
        log_print(f"Maximum scheduled UEs in any slot: {max_scheduled}",
                  log_f)
        log_print(f"Average scheduled UEs per slot: {avg_scheduled:.2f}",
                  log_f)

        # Analyze UL scheduling specifically
        ul_data = [entry for entry in scheduling_data
                   if entry['Direction'] == "UL"]
        if ul_data:
            max_ul = max(entry['ScheduledUes'] for entry in ul_data)
            log_print(f"\nMaximum scheduled UEs in UL: {max_ul}", log_f)

            # Show distribution
            distribution = {}
            for i in range(max_ul + 1):
                count = sum(1 for entry in ul_data
                            if entry['ScheduledUes'] == i)
                if count > 0:
                    distribution[i] = count

            log_print("\nUL Scheduled UEs distribution:", log_f)
            for num, count in sorted(distribution.items()):
                percentage = count/len(ul_data)*100
                log_print(f"{num} UE(s): {count} slots ({percentage:.1f}%)",
                          log_f)

        # Analyze DL scheduling specifically
        dl_data = [entry for entry in scheduling_data
                   if entry['Direction'] == "DL"]
        if dl_data:
            max_dl = max(entry['ScheduledUes'] for entry in dl_data)
            log_print(f"\nMaximum scheduled UEs in DL: {max_dl}", log_f)

            # Show distribution
            distribution = {}
            for i in range(max_dl + 1):
                count = sum(1 for entry in dl_data
                            if entry['ScheduledUes'] == i)
                if count > 0:
                    distribution[i] = count

            log_print("\nDL Scheduled UEs distribution:", log_f)
            for num, count in sorted(distribution.items()):
                percentage = count/len(dl_data)*100
                log_print(f"{num} UE(s): {count} slots ({percentage:.1f}%)",
                          log_f)
    else:
        log_print(f"\nNo scheduling data found in {input_file}.", log_f)
        log_print("Check if the file contains dlLoadControlData or "
                  "ulLoadControlData events.", log_f)
        log_print("Try these troubleshooting steps:", log_f)
        log_print("1. Verify the input file contains 'dlLoadControlData' or "
                  "'ulLoadControlData' events", log_f)
        log_print("2. Check if 'physCellId', 'sfn' and 'slot' fields are "
                  "present in the events", log_f)
        log_print("3. Ensure the file encoding is correct "
                  "(try removing 'errors='ignore')", log_f)

# Also print the log file location to console
print(f"\nAnalysis complete. Console output saved to: {log_file}")
