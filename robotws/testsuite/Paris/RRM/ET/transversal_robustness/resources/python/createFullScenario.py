"""
createFullScenario.py - Step 2: Scenario Duration Expander

DESCRIPTION:
    This script expands individual UE iteration files into full-duration scenarios.
    It repeats the commands from .oneIteration files to cover the specified total duration.
    This is the SECOND script to run in the scenario generation workflow.

WORKFLOW POSITION:
    Step 2/3: createUeScenario.py → createFullScenario.py → createMasterScenario.py

WHAT IT DOES:
    1. Reads all UE<ID>.oneIteration files from UeScenario/ directory
    2. For each UE, repeats the iteration commands until reaching total duration T
    3. Adjusts timestamps to maintain correct timing across iterations
    4. Generates UE<ID>.allIterations files with full scenario timeline

USAGE:
    python createFullScenario.py [path] [duration]

ARGUMENTS:
    path     : Directory containing UeScenario/ folder (default: ./)
               Must contain UE<ID>.oneIteration files created by createUeScenario.py

    duration : Total scenario duration in seconds (default: 1800)
               Commands will be repeated until this duration is reached

INPUT:
    Reads from UeScenario/ directory:
        - UE001.oneIteration
        - UE002.oneIteration
        - UE003.oneIteration
        - ...

OUTPUT:
    Creates in UeScenario/ directory:
        - UE001.allIterations
        - UE002.allIterations
        - UE003.allIterations
        - ...

EXAMPLES:
    # Run with default duration (1800s = 30min)
    python createFullScenario.py ./

    # Specify custom duration (7200s = 2 hours)
    python createFullScenario.py ./ 7200

    # Full workflow example
    python createUeScenario.py scenario.txt ./output/
    python createFullScenario.py ./output/ 7200
    python createMasterScenario.py ./output/ master_scenario.txt

NEXT STEP:
    After running this script, run createMasterScenario.py to merge all UE scenarios.
"""

import os
import sys
import argparse


def create_full_scenario(path="./", T=1800):
    input_directory = path + "UeScenario"
    output_directory = path + "UeScenario"

    # list files in directory matchig pattern UExx.oneIteration
    for filename in os.listdir(input_directory):
        if filename.startswith("UE") and filename.endswith(".oneIteration"):
            input_filename = os.path.join(input_directory, filename)
            output_filename = os.path.join(output_directory, filename.replace(".oneIteration", ".allIterations"))

            if not os.path.exists(input_filename):
                print(f"background scenario log - File {input_filename} does not exist.")
                continue

            with open(input_filename, 'r') as infile:
                lines = infile.readlines()

            total_duration = 0
            output_lines = []

            # process the first line
            if lines:
                first_line = lines[0].strip().split(';')
                first_delay = float(first_line[0])
                first_type = first_line[1]
                first_command = first_line[2]
                first_ue_id = first_line[3] if len(first_line) > 3 else "unknown"
                first_min_ue_gap = first_delay  # original relative delay = min gap for this UE
                output_lines.append(f"{first_delay};{first_type};{first_command};{first_ue_id};{first_min_ue_gap}\n")
                total_duration = first_delay

            # process the remaining lines
            while total_duration <= T:
                for line in lines[1:]:
                    parts = line.strip().split(';')
                    relative_delay = float(parts[0])
                    type_cmd = parts[1]
                    command = parts[2]
                    ue_id = parts[3] if len(parts) > 3 else "unknown"
                    min_ue_gap = relative_delay  # original relative delay = min gap for this UE
                    absolute_delay = round(relative_delay + total_duration, 3)
                    output_lines.append(f"{absolute_delay};{type_cmd};{command};{ue_id};{min_ue_gap}\n")
                    total_duration = absolute_delay

            with open(output_filename, 'w') as outfile:
                outfile.writelines(output_lines)

            print(f"background scenario log - processed {input_filename} and created {output_filename} \
                  with total duration {total_duration}.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Step 2/3: Expand UE iterations to cover full scenario duration',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Workflow:
  1. createUeScenario.py   → Generate UE<ID>.oneIteration files
  2. createFullScenario.py → Expand iterations for total duration
  3. createMasterScenario.py → Merge all UEs into master_scenario.txt

Example:
  python createUeScenario.py scenario.txt ./output/
  python createFullScenario.py ./output/ 7200
  python createMasterScenario.py ./output/ master_scenario.txt
        '''
    )

    parser.add_argument(
        'path',
        nargs='?',
        default='./',
        help='Directory containing UeScenario/ folder (default: ./)'
    )

    parser.add_argument(
        'duration',
        nargs='?',
        type=float,
        default=1800,
        help='Total scenario duration in seconds (default: 1800)'
    )

    if '--help' in sys.argv or '-h' in sys.argv:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    print(f"Step 2/3: Expanding UE scenarios to full duration")
    print(f"  Path: {args.path}")
    print(f"  Duration: {args.duration}s ({args.duration/60:.1f} minutes)")
    print("-" * 60)

    create_full_scenario(args.path, args.duration)
    print(f"\n✓ Full scenarios created successfully")
    print(f"Next step: python createMasterScenario.py {args.path} master_scenario.txt")
