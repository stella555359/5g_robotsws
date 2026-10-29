"""
createMasterScenario.py - Step 3: Master Scenario Merger

DESCRIPTION:
    This script merges all individual UE scenario files into a single master scenario file.
    It combines commands from all UEs and sorts them chronologically by timestamp.
    This is the FINAL script to run in the scenario generation workflow.

WORKFLOW POSITION:
    Step 3/3: createUeScenario.py → createFullScenario.py → createMasterScenario.py

WHAT IT DOES:
    1. Reads all UE<ID>.allIterations files from UeScenario/ directory
    2. Collects all commands from all UEs with their timestamps
    3. Sorts all commands chronologically
    4. Generates master_scenario.txt with the complete timeline

USAGE:
    python createMasterScenario.py [path] [output_file]

ARGUMENTS:
    path        : Directory containing UeScenario/ folder (default: ./)
                 Must contain UE<ID>.allIterations files created by createFullScenario.py

    output_file : Name of the master scenario file (default: master_scenario.txt)
                 Will be created in the UeScenario/ directory

INPUT:
    Reads from UeScenario/ directory:
        - UE001.allIterations
        - UE002.allIterations
        - UE003.allIterations
        - ...

OUTPUT:
    Creates in UeScenario/ directory:
        - master_scenario.txt (or custom name)

    Format: <timestamp>;<command_type>;<command>
    Example:
        0.0;wait;initial offset
        5.0;wts;egate ue_create 1
        5.5;wts;egate ue_create 2
        10.0;wts;egate ue_start 1
        10.5;wts;egate ue_start 2

EXAMPLES:
    # Run with default output filename
    python createMasterScenario.py ./

    # Specify custom output filename
    python createMasterScenario.py ./ my_scenario.txt

    # Full workflow example
    python createUeScenario.py scenario.txt ./output/
    python createFullScenario.py ./output/ 7200
    python createMasterScenario.py ./output/ master_scenario.txt

NEXT STEP:
    Use the generated master_scenario.txt with writeTelnet.py:
    python writeTelnet.py ./output/ /tmp/logs --verbose
"""

import os
import sys
import time
import argparse


def create_master_scenario(path="./", result_file="master_scenario.txt"):
    commands = []
    path = os.path.join(path, 'UeScenario')
    print(f"background scenario log - path = {path} - result_file = {result_file}")
    file_list = [os.path.join(path, f) for f in os.listdir(path) if f.endswith('.allIterations')]
    print(f"background scenario log - File {file_list}")
    # read the commands from the files and save them with their delay
    for file_name in file_list:
        with open(file_name, 'r') as file:
            lines = file.readlines()
            for line in lines:
                parts = line.strip().split(';')
                if len(parts) >= 3:
                    print(f"background scenario log - current line {line}")
                    delay = float(parts[0])
                    type_cmd = parts[1]
                    command = parts[2]
                    ue_id = parts[3] if len(parts) > 3 else "unknown"
                    min_ue_gap = float(parts[4]) if len(parts) > 4 else 0.0
                    commands.append((delay, type_cmd, command, ue_id, min_ue_gap))

    # order the commands per delay
    commands.sort(key=lambda x: x[0])

    # print the command and save the result
    with open(os.path.join(path, result_file), 'w') as result:
        # start_time = time.time()
        for delay, type_cmd, command, ue_id, min_ue_gap in commands:
            result.write(f"{delay};{type_cmd};{command};{ue_id};{min_ue_gap}\n")
            print(f"background scenario log - {delay};{type_cmd};{command};{ue_id};{min_ue_gap}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Step 3/3: Merge all UE scenarios into master scenario file',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Workflow:
  1. createUeScenario.py   → Generate UE<ID>.oneIteration files
  2. createFullScenario.py → Expand iterations for total duration
  3. createMasterScenario.py → Merge all UEs into master_scenario.txt

Complete Example:
  # Step 1: Generate individual UE scenarios
  python createUeScenario.py scenario.txt ./output/

  # Step 2: Expand to 2 hours duration
  python createFullScenario.py ./output/ 7200

  # Step 3: Create master scenario
  python createMasterScenario.py ./output/ master_scenario.txt

  # Step 4: Execute the scenario
  python writeTelnet.py ./output/ /tmp/logs --verbose
        '''
    )

    parser.add_argument(
        'path',
        nargs='?',
        default='./',
        help='Directory containing UeScenario/ folder (default: ./)'
    )

    parser.add_argument(
        'output_file',
        nargs='?',
        default='master_scenario.txt',
        help='Name of the master scenario file (default: master_scenario.txt)'
    )

    if '--help' in sys.argv or '-h' in sys.argv:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    print(f"Step 3/3: Creating master scenario")
    print(f"  Path: {args.path}")
    print(f"  Output file: {args.output_file}")
    print("-" * 60)

    create_master_scenario(args.path, args.output_file)
    print(f"\n✓ Master scenario created successfully: {args.path}UeScenario/{args.output_file}")
    print(f"Ready to execute: python writeTelnet.py {args.path} /tmp/logs --verbose")
