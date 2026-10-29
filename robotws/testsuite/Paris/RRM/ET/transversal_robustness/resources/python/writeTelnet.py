"""
writeTelnet.py - Telnet Command Scheduler for UE Scenario Testing

DESCRIPTION:
    This script executes telnet commands to an EGATE server (0.0.0.0:9880) following a
    time-scheduled scenario defined in a master scenario file. It is designed to automate
    UE (User Equipment) testing scenarios with precise timing control.

WORKFLOW:
    1. Optionally executes initial setup commands (cell/X2 link activation)
    2. Reads a master scenario file containing timestamped commands
    3. Executes each command at its scheduled time via telnet
    4. Logs all operations with precise timestamps

USAGE:
    python writeTelnet.py [path_scenario] [output_path] [run_init_cmd]

ARGUMENTS:
    path_scenario   : Path to the scenario directory (default: './')
                     The script will look for 'UeScenario/master_scenario.txt' in this path

    output_path     : Path where log files will be created (default: './')
                     Log file format: egateSendTelnet_<timestamp>.log

    run_init_cmd    : Execute initial commands (default: True)
                     Loads commands from cellAndX2LinkUp.txt before running scenario

EXAMPLES:
    # Run with default parameters (current directory)
    python writeTelnet.py

    # Specify scenario path and output path
    python writeTelnet.py /path/to/scenario /path/to/logs

    # Specify all parameters including disabling init commands
    python writeTelnet.py /path/to/scenario /path/to/logs False

    # Full example with absolute paths
    python writeTelnet.py \\
        /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/transversal_robustness/config/background_scenario \\
        /tmp/logs \\
        True

SCENARIO FILE FORMAT:
    master_scenario.txt should contain lines in the format:
        <timestamp>;<command_type>;<command>

    Example:
        0.0;wts;ue_create 1
        5.5;wts;ue_start 1
        10.0;wts;ue_handover 1 2

    Only lines with command_type='wts' are executed.

INITIAL COMMANDS FILE:
    cellAndX2LinkUp.txt contains initial setup commands executed before the scenario.
    Format: <command>;<wait_time_seconds>
    Only the first 2 lines are read by this script.

REQUIREMENTS:
    - EGATE server running on 0.0.0.0:9880
    - Valid scenario files in the expected format
    - Python 3.x with telnetlib module

NOTES:
    - Current implementation reads only first 2 lines of initial commands file
    - Commands are executed with precise timing based on scenario timestamps
    - Telnet timeout is set to 900 seconds (15 minutes)
    - Each command opens a new telnet connection (not persistent)

AUTHOR:
    Original implementation for RRM/ET transversal robustness testing
"""

import os
import sys
import time
import telnetlib
import subprocess
from datetime import datetime
import argparse


def read_initial_commands(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        commands = []
        for line in lines[:2]:  # Read only the first two lines
            command, wait_time = line.strip().split(';')
            commands.append((command, float(wait_time)))
        return commands


def read_with_timeout(telnet_connection, log_file, timeout=60):
    start_time = time.time()
    message_displayed = False
    i = 1

    while True:
        if telnet_connection.sock_avail() > 0:  # check if buffer is not empty
            return telnet_connection.read_until(b"EGATE> ")

        if not message_displayed:
            formatted_time = datetime.now().strftime("%y%m%d-%H%M%S.%f")[:-3]
            print_to_screen_and_log(f"{formatted_time}: {i} waiting egate... ", log_file, out='file')
            # message_displayed = True

        if time.time() - start_time > timeout:
            error_msg = f"ERR: EGATE prompt timeout ({timeout}s) has been reached - Aborting script"
            print_to_screen_and_log(error_msg, log_file, out='all')
            raise TimeoutError(error_msg)

        time.sleep(0.1)  # wait 0.1s
        i += 1


# print to screen and log
def print_to_screen_and_log(message, log_file, out='all'):
    if out == 'all':
        print(message)
    with open(log_file, 'a') as f:
        f.write(message + '\n')


def execute_commands_batch(commands_batch, t0, log_file, waitResponse=0.1, verbose=False, prompt_timeout=60):
    """
    Execute a batch of commands in a single telnet connection.

    Args:
        commands_batch: List of tuples (command, delta) to execute
        t0: Reference time for the scenario
        log_file: Path to log file
        waitResponse: Time to wait after sending command
        verbose: Display timing information
        prompt_timeout: Timeout for waiting EGATE> prompt
    """
    if not commands_batch:
        return

    batch_start_time = time.time()

    try:
        with telnetlib.Telnet('0.0.0.0', 9880) as tn:
            # Wait for initial prompt
            try:
                result = read_with_timeout(tn, log_file, timeout=prompt_timeout)
                if result:
                    formatted_time = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                    print_to_screen_and_log(f"{formatted_time}: egate initial response: {result}", log_file, out='file')
            except TimeoutError as e:
                print_to_screen_and_log(f"ERR: Failed to get initial EGATE prompt: {e}", log_file, out='all')
                sys.exit(1)

            # Execute each command in the batch
            for command, delta in commands_batch:
                cmd_start_time = time.time()

                # Send the command
                tn.write(command.encode('ascii') + b"\r\n")
                elapsed_time = round(time.time() - t0, 6)

                # Wait for command response
                time.sleep(waitResponse)

                timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                print_to_screen_and_log(f"{timestamp} {command} sent at {elapsed_time} instead of {delta}",
                                        log_file, out='file')

                # Wait for EGATE> prompt before next command
                try:
                    result = read_with_timeout(tn, log_file, timeout=prompt_timeout)
                    if result:
                        formatted_time = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                        msg = f"{formatted_time}: egate response after command: {result}"
                        print_to_screen_and_log(msg, log_file, out='file')
                except TimeoutError as e:
                    msg = f"ERR: EGATE prompt timeout after command '{command}': {e}"
                    print_to_screen_and_log(msg, log_file, out='all')
                    sys.exit(1)

                cmd_duration = round(time.time() - cmd_start_time, 6)
                if verbose:
                    drift = round(elapsed_time - delta, 3)
                    delay_info = (
                        f"TELNET_EXEC_TIME= {cmd_duration:7.3f}s | "
                        f"DRIFT= {drift:+7.3f}s | "
                        f"Scheduled: {delta:8.3f}s | "
                        f"Actual: {elapsed_time:8.3f}s | "
                        f"Command: '{command}'"
                    )
                    print(delay_info)

            # Close connection properly
            tn.write(b"exit\r\n")
            timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]
            print_to_screen_and_log(f"{timestamp} exit sent", log_file, out='file')
            time.sleep(0.05)
            tn.close()

    except Exception as e:
        print_to_screen_and_log(f"Error during batch execution: {e}", log_file, out='all')
        sys.exit(1)


def execute_command(command, t0, log_file, delta, waitResponse=0.1, verbose=False, prompt_timeout=60):
    """Wrapper for single command execution (backward compatibility)"""
    execute_commands_batch([(command, delta)], t0, log_file, waitResponse, verbose, prompt_timeout)


def write_telnet(path="./", output_path="./", run_init_cmd=True, verbose=False, cmds_per_connection=1):
    path = os.path.join(path, 'UeScenario')
    filename = os.path.join(path, 'master_scenario.txt')
    current_date = datetime.now().strftime('%y%m%d%H%M%S')
    log_file = os.path.join(output_path, f"egateSendTelnet_{current_date}.log")
    t0 = time.time()
    print_to_screen_and_log(f"background scenario log - run_init_cmd = {run_init_cmd}", log_file)
    print_to_screen_and_log(f"background scenario log - verbose mode = {verbose}", log_file)
    print_to_screen_and_log(f"background scenario log - commands per connection = {cmds_per_connection}", log_file)

    # Read initial commands from the specified file
    # path_init_cmd =
    #     '/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/config/background_scenario/cellAndX2LinkUp.txt'
    path_init_cmd = (
        '/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/transversal_robustness/'
        'config/background_scenario/cellAndX2LinkUp.txt'
    )
    if run_init_cmd is True:
        print_to_screen_and_log(f"background scenario log - path_init_cmd : {path_init_cmd} ", log_file)
        initial_commands = read_initial_commands(path_init_cmd)
        for command, wait_time in initial_commands:
            print_to_screen_and_log(f"command : {command} - wait_time : {wait_time}", log_file)
            execute_command(command, t0, log_file, 0, wait_time, verbose)
    else:
        print_to_screen_and_log(f"background scenario log - run_init_cmd in false condition", log_file)

    # define the origin of time
    t0 = time.time()
    human_readable_time = datetime.fromtimestamp(t0).strftime('%A %d %B %Y, %H:%M:%S')
    print_to_screen_and_log(f"background scenario log - path = {path} - filename = {filename}", log_file)
    print_to_screen_and_log(f"background scenario log - t0 = {t0:.6f} = {human_readable_time}", log_file)

    # open file master_scenario.txt
    with open(filename, 'r') as file:
        lines = file.readlines()

    # Parse all commands
    all_commands = []
    for line in lines:
        parts = line.strip().split(';')
        if len(parts) == 3:
            delta, type_cmd, command = parts
            delta = float(delta)
            if type_cmd == 'wts':  # Only include wts commands
                all_commands.append((delta, command))

    # Process commands in batches
    i = 0
    while i < len(all_commands):
        # Prepare batch of commands
        batch = []

        # Collect up to cmds_per_connection commands for this batch
        for j in range(cmds_per_connection):
            if i + j < len(all_commands):
                delta, command = all_commands[i + j]
                batch.append((command, delta))

        if not batch:
            break

        # Wait and execute each command in the batch, respecting individual timestamps
        batch_commands = []
        for command, delta in batch:
            # Wait until this specific command should be executed
            wait_time = t0 + delta - time.time()
            if wait_time > 0:
                time.sleep(wait_time)
            batch_commands.append((command, delta))

        # Execute the batch (connection stays open for all commands)
        execute_commands_batch(batch_commands, t0, log_file, waitResponse=0.05, verbose=verbose)

        # Move to next batch
        i += len(batch)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Telnet Command Scheduler for UE Scenario Testing',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Run with default parameters (current directory)
  python writeTelnet.py

  # Specify scenario path and output path
  python writeTelnet.py /path/to/scenario /path/to/logs

  # Specify all parameters including disabling init commands
  python writeTelnet.py /path/to/scenario /path/to/logs False

  # Full example with absolute paths
  python writeTelnet.py \\
      /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/transversal_robustness/config/background_scenario \\
      /tmp/logs \\
      True

Scenario File Format:
  master_scenario.txt should contain lines: <timestamp>;<command_type>;<command>
  Example:
    0.0;wts;ue_create 1
    5.5;wts;ue_start 1
    10.0;wts;ue_handover 1 2

Initial Commands File:
  cellAndX2LinkUp.txt contains initial setup commands (format: <command>;<wait_time_seconds>)
  Only the first 2 lines are read.
        '''
    )

    parser.add_argument(
        'path_scenario',
        nargs='?',
        default='./',
        help='Path to the scenario directory (default: ./). Script looks for UeScenario/master_scenario.txt'
    )

    parser.add_argument(
        'output_path',
        nargs='?',
        default='./',
        help='Path where log files will be created (default: ./). Log file: egateSendTelnet_<timestamp>.log'
    )

    parser.add_argument(
        'run_init_cmd',
        nargs='?',
        default='True',
        help='Execute initial commands from cellAndX2LinkUp.txt (default: True). Use True/False'
    )

    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Display detailed timing information for each telnet command execution in console'
    )

    parser.add_argument(
        '--cmds-per-connection', '-n',
        type=int,
        default=10,
        metavar='N',
        help='Number of commands to execute per telnet connection (default: 10). Higher values reduce connection time.'
    )

    # Show help if --help or -h is provided
    if '--help' in sys.argv or '-h' in sys.argv:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    # Convert run_init_cmd string to boolean
    run_init = args.run_init_cmd.lower() in ('true', '1', 'yes', 'y')

    print(f"Starting writeTelnet with:")
    print(f"  Scenario path: {args.path_scenario}")
    print(f"  Output path: {args.output_path}")
    print(f"  Run init commands: {run_init}")
    print(f"  Verbose mode: {args.verbose}")
    print(f"  Commands per connection: {args.cmds_per_connection}")
    print(f"  EGATE server: 0.0.0.0:9880")
    print("-" * 60)

    write_telnet(args.path_scenario, args.output_path, run_init, args.verbose, args.cmds_per_connection)
