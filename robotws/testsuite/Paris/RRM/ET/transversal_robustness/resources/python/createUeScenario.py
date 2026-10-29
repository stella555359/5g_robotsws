"""
createUeScenario.py - Step 1: UE Scenario Generator

DESCRIPTION:
    This script generates individual UE scenario files from a main scenario configuration file.
    It creates one .oneIteration file per UE, containing the commands for one iteration of the UE's behavior.
    This is the FIRST script to run in the scenario generation workflow.

WORKFLOW POSITION:
    Step 1/3: createUeScenario.py → createFullScenario.py → createMasterScenario.py

WHAT IT DOES:
    1. Reads a scenario configuration file listing all UEs and their templates
    2. For each UE, loads its command template
    3. Calculates timing and loop duration
    4. Generates UE<ID>.oneIteration files in the UeScenario/ directory
    5. Replaces <UEID> placeholders with actual UE IDs

USAGE:
    python createUeScenario.py [scenario_file] [output_path]

ARGUMENTS:
    scenario_file : Configuration file listing UEs and their templates (default: scenario.txt)
                   Format: <UE_ID>, <template_file>, offset=<value>, duration=<value>

    output_path   : Directory where UeScenario/ will be created (default: ./)

SCENARIO FILE FORMAT:
    Each line describes one UE:
        UE1, templates/voice.txt, offset=0, duration=300
        UE2, templates/data.txt, offset=5, duration=600

    Fields:
        - UE_ID: Unique UE identifier (will be padded to 3 digits: UE001, UE002...)
        - template_file: Path to the command template for this UE
        - offset: Initial delay before starting the UE scenario (seconds)
        - duration: Total duration of one loop iteration (seconds)

TEMPLATE FILE FORMAT:
    Each line in template contains:
        <delay>;<command>

    Example:
        0;start scenario
        5;egate ue_create <UEID>
        10;egate ue_start <UEID>
        50;wait before next loop

OUTPUT:
    Creates UeScenario/ directory containing:
        - UE001.oneIteration
        - UE002.oneIteration
        - UE003.oneIteration
        - ...

EXAMPLES:
    # Run with default parameters
    python createUeScenario.py

    # Specify scenario file and output path
    python createUeScenario.py config/ues.txt /tmp/scenario_output

    # Full workflow example
    python createUeScenario.py scenario.txt ./output/
    python createFullScenario.py ./output/ 7200
    python createMasterScenario.py ./output/ master_scenario.txt

NEXT STEP:
    After running this script, run createFullScenario.py to expand iterations.
"""

import os
import re
import sys
import shutil
import argparse


def create_ue_scenario(scenario_file="scenario.txt", path="./"):
    directoryUeScenario = os.path.join(path, "UeScenario")

    # delete directory UeScenario if present
    if os.path.exists(directoryUeScenario):
        shutil.rmtree(directoryUeScenario)

    # create directory UeScenario if necessary
    os.makedirs(directoryUeScenario, exist_ok=True)

    with open(scenario_file, 'r') as file:
        lines = file.readlines()

    for line in lines:
        parts = line.strip().split(', ')
        ue_id = parts[0]
        numeric_part = ue_id[2:]
        padded_numeric_part = numeric_part.zfill(3)
        ue_id = f"UE{padded_numeric_part}"
        template_file = path + parts[1]
        offset = parts[2].split('=')[1]
        duration = int(parts[3].split('=')[1])
        print(f"\nbackground scenario log - {ue_id}: initial offset = {offset} / duration = {duration}")

        # read the template
        with open(template_file, 'r') as template:
            template_lines = template.readlines()

        # compute the sum of the value for each line of template.txt
        total_duration = sum(int(line.split(';')[0]) for line in template_lines)
        print(f"background scenario log - {ue_id}: total duration of the scenario {template_file} is {total_duration}")

        # Calculer la valeur de waitBeforeNextLoop
        wait_before_next_loop = duration - total_duration
        if wait_before_next_loop < 0:
            print(f"background scenario log - {ue_id}: Warning: Negative waitBeforeNextLoop value for {ue_id}.\
                   Setting it to 0.")
            wait_before_next_loop = 0
        print(
              f"background scenario log - {ue_id}: computed value for \"wait before next loop\" "
              f"is {wait_before_next_loop}"
              )

        # create new file UExx.oneIteration in UeScenario directory
        print(f"background scenario log - ue_id={ue_id}")
        ue_file_name = f"{ue_id}.oneIteration"
        # /!\ current limitation with UE id between 000 and 999
        ue_id = re.search(r'UE(\d{3})\.oneIteration', ue_file_name).group(1) if\
            re.search(r'UE(\d{3})\.oneIteration', ue_file_name) else None
        ue_id_stripped = ue_id.lstrip('0') or '0'
        print(f"background scenario log - ue_id={ue_id} - ue_id_stripped={ue_id_stripped}")
        with open(os.path.join(directoryUeScenario, ue_file_name), 'w') as ue_file:
            # write the first line with the initial offset
            first_line_parts = template_lines[0].strip().split(';')
            ue_file.write(f"{offset};{build_egate_command(first_line_parts[1].strip(), ue_id)};{ue_id_stripped}\n")

            # write the file
            for template_line in template_lines[1:-1]:
                command = template_line.strip().split(';')[1].strip()
                ue_file.write(f"{template_line.split(';')[0]};{build_egate_command(command, ue_id)};{ue_id_stripped}\n")

            # write the last line with the wait before next loop
            last_line_parts = template_lines[-1].strip().split(';')
            ue_file.write(
                f"{wait_before_next_loop};{build_egate_command(last_line_parts[1].strip(), ue_id)};{ue_id_stripped}\n"
                )


def build_egate_command(command, ue_id):
    ue_id = ue_id.lstrip('0')
    if "<UEID>" in command:
        command = command.replace("<UEID>", ue_id)
        return f"wts;{command}"
    elif "smf_param" in command:
        return f"wts;{command}"
    elif command == "start scenario":
        return "wait;start scenario"
    elif command == "initial offset":
        return "wait;initial offset"
    elif command == "wait before next loop":
        return "wait;wait before next loop"
    else:
        print(f"ERR: background scenario log - the command : {command} is not managed by the script")
        sys.exit(f"ERR: the command : {command} is not managed by the script")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Step 1/3: Generate individual UE scenario files from configuration',
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
        'scenario_file',
        nargs='?',
        default='scenario.txt',
        help='Configuration file listing UEs and templates (default: scenario.txt)'
    )

    parser.add_argument(
        'output_path',
        nargs='?',
        default='./',
        help='Directory where UeScenario/ will be created (default: ./)'
    )

    if '--help' in sys.argv or '-h' in sys.argv:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    print(f"Step 1/3: Creating UE scenarios")
    print(f"  Scenario file: {args.scenario_file}")
    print(f"  Output path: {args.output_path}")
    print("-" * 60)

    create_ue_scenario(args.scenario_file, args.output_path)
    print(f"\n✓ UE scenarios created successfully")
    print(f"Next step: python createFullScenario.py {args.output_path} <duration>")
