import os
import sys
import time
import telnetlib
import subprocess
from datetime import datetime
import threading


def read_initial_commands(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        commands = []
        for line in lines:  # Read all lines
            line = line.strip()
            if line and not line.startswith('#'):  # Skip empty lines and comments
                try:
                    command, wait_time = line.split(';')
                    commands.append((command.strip(), float(wait_time)))
                except ValueError:
                    print(f"Warning: Skipping malformed line: {line}")
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


def execute_commands_batch(commands_batch, t0, log_file, waitResponse=0.1, verbose=False,
                           prompt_timeout=60, stop_event=None, last_exec_time=None,
                           enforce_ue_gap=False):
    """
    Execute a batch of commands in a single telnet connection.
    Each command is sent at its scheduled time (t0 + delta), and respects
    a minimum gap between consecutive commands for the same UE.

    Args:
        commands_batch: List of tuples (command, delta, ue_id, ue_cmd_gap) to execute
        t0: Reference time for the scenario
        log_file: Path to log file
        waitResponse: Time to wait after sending command
        verbose: Display timing information
        prompt_timeout: Timeout for waiting EGATE> prompt
        stop_event: Threading event to signal stop
        last_exec_time: Dict tracking last execution time per UE (ue_id → timestamp)
        enforce_ue_gap: If False, ignore per-UE minimum gap (compat mode)
    """
    if not commands_batch:
        return

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

            # Execute each command in the batch at its scheduled time
            for cmd_entry in commands_batch:
                command, delta = cmd_entry[0], cmd_entry[1]
                ue_id = cmd_entry[2] if len(cmd_entry) > 2 else None
                ue_cmd_gap = float(cmd_entry[3]) if len(cmd_entry) > 3 else 0.0

                # Check for stop event before each command
                if stop_event and stop_event.is_set():
                    break

                # Gap semantics:
                #   ue_cmd_gap: configured UE-specific spacing between two commands
                #   schedule_gap: time until the absolute scenario slot (t0 + delta)
                #   required_ue_cmd_gap: remaining time to honor the UE-specific spacing between two commands
                #   enforced_ue_cmd_gap: delay we actually impose (0 if enforcement disabled)
                #   available_wait_without_enforcement: actual wait we will get if we only follow the schedule

                # Wait condition 1: respect absolute schedule (t0 + delta)
                schedule_gap = t0 + delta - time.time()
                # Without enforcement we can only wait up to the absolute schedule
                available_wait_without_enforcement = max(schedule_gap, 0.0)

                # Wait condition 2: respect per-UE minimum gap (optional)
                enforced_ue_cmd_gap = 0
                required_ue_cmd_gap = 0
                if last_exec_time is not None and ue_id and ue_id in last_exec_time:
                    required_ue_cmd_gap = last_exec_time[ue_id] + ue_cmd_gap - time.time()
                    if enforce_ue_gap:
                        enforced_ue_cmd_gap = required_ue_cmd_gap

                # Debug: show computed waits and last execution for this UE
                last_exec = None
                if last_exec_time is not None and ue_id and ue_id in last_exec_time:
                    last_exec = last_exec_time[ue_id]
                last_exec_str = (
                    datetime.fromtimestamp(last_exec).strftime('%y%m%d-%H%M%S.%f')[:-3]
                    if last_exec else 'None'
                )
                dbg_ts = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                ue_label = ue_id or 'N/A'
                print_to_screen_and_log(
                    f"{dbg_ts} [UE {ue_label}] [DBG] : last_exec={last_exec_str}; "
                    f"schedule_gap={schedule_gap:.3f}; "
                    f"required_ue_cmd_gap={required_ue_cmd_gap:.3f}; "
                    f"enforced_ue_cmd_gap={enforced_ue_cmd_gap:.3f}; "
                    f"enforce_ue_gap={enforce_ue_gap}",
                    log_file, out='file')

                if enforce_ue_gap and required_ue_cmd_gap > schedule_gap:
                    print_to_screen_and_log(
                        f"{dbg_ts} [UE {ue_label}] [WRN] : schedule inside gap; "
                        f"enforced_ue_cmd_gap={enforced_ue_cmd_gap:.3f}s "
                        f"(required_ue_cmd_gap={required_ue_cmd_gap:.3f}s, ue_cmd_gap={ue_cmd_gap:.3f}s); "
                        f"schedule_gap={schedule_gap:.3f}s; delta_sched={delta}; cmd='{command}'",
                        log_file, out='file')

                # Take the strictest constraint
                effective_wait = max(schedule_gap, enforced_ue_cmd_gap)
                if effective_wait > 0:
                    time.sleep(effective_wait)

                cmd_start_time = time.time()

                # Send the command and record exact send time
                tn.write(command.encode('ascii') + b"\r\n")
                send_time = time.time()
                send_ts_str = datetime.fromtimestamp(send_time).strftime('%H:%M:%S.%f')[:-3]
                elapsed_time = round(send_time - t0, 6)

                # Compute actual gap between this command and previous for this UE
                # Warning if actual gap < ue_cmd_gap (command executed too soon after previous)
                # Only warn if missing gap > 1ms (precision threshold)
                if last_exec_time is not None and ue_id and ue_id in last_exec_time:
                    actual_gap = send_time - last_exec_time[ue_id]
                    missing_gap = ue_cmd_gap - actual_gap
                    if not enforce_ue_gap and missing_gap > 0.001:
                        print_to_screen_and_log(
                            f"{send_ts_str} [UE {ue_label}] [WRN] : would need extra "
                            f"{missing_gap:.3f}s to fullfil "
                            f"ue_cmd_gap={ue_cmd_gap:.3f}s with previous command; "
                            f"actual_gap={actual_gap:.3f}s; delta_sched={delta}; "
                            f"cmd='{command}'",
                            log_file, out='file')

                # Track last execution time for this UE and log it (use send_time)
                if last_exec_time is not None and ue_id:
                    last_exec_time[ue_id] = send_time
                    new_last_str = datetime.fromtimestamp(send_time).strftime('%y%m%d-%H%M%S.%f')[:-3]
                    print_to_screen_and_log(
                        f"{send_ts_str} [UE {ue_id}] [DBG] : last_exec_updated={new_last_str}",
                        log_file, out='file')

                # Wait for command response
                time.sleep(waitResponse)

                ue_info = f" [UE {ue_id}]" if ue_id else ""
                print_to_screen_and_log(
                    f"{send_ts_str}{ue_info} {command} sent at {elapsed_time} instead of {delta}",
                    log_file, out='file')

                # Wait for EGATE> prompt before next command
                try:
                    result = read_with_timeout(tn, log_file, timeout=prompt_timeout)
                    if result:
                        formatted_time = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                        ue_label_resp = ue_id or 'N/A'
                        msg = f"{formatted_time} [egate response after command]: {result}"
                        print_to_screen_and_log(msg, log_file, out='file')
                except TimeoutError as e:
                    msg = f"ERR: EGATE prompt timeout after command '{command}': {e}"
                    print_to_screen_and_log(msg, log_file, out='all')
                    sys.exit(1)

                cmd_duration = round(time.time() - cmd_start_time, 6)
                if verbose:
                    drift = round(elapsed_time - delta, 3)
                    ue_gap_info = f" | UE_GAP= {ue_cmd_gap:.1f}s" if ue_id else ""
                    delay_info = (
                        f"TELNET_EXEC_TIME= {cmd_duration:7.3f}s | "
                        f"DRIFT= {drift:+7.3f}s | "
                        f"Scheduled: {delta:8.3f}s | "
                        f"Actual: {elapsed_time:8.3f}s | "
                        f"UE: {ue_id or 'N/A':>3s}{ue_gap_info} | "
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
    execute_commands_batch([(command, delta, None, 0.0)], t0, log_file, waitResponse, verbose, prompt_timeout)


def write_telnet(path="./", output_path="./", run_init_cmd=True,
                 stop_event=None, thread_log_file=None, isX2LinkUp=True,
                 verbose=False, cmds_per_connection=1, enforce_ue_gap=False):
    path = os.path.join(path, 'UeScenario')
    filename = os.path.join(path, 'master_scenario.txt')
    current_date = datetime.now().strftime('%y%m%d%H%M%S')
    log_file = os.path.join(output_path, f"egateSendTelnet_{current_date}.log")
    # Log thread start
    if thread_log_file:
        with open(thread_log_file, 'a') as f:
            f.write(f"[{current_date}] [write_telnet] Thread started.\n")
    t0 = time.time()
    print_to_screen_and_log(f"background scenario log - run_init_cmd = {run_init_cmd}", log_file)
    print_to_screen_and_log(f"background scenario log - verbose mode = {verbose}", log_file)
    print_to_screen_and_log(f"background scenario log - commands per connection = {cmds_per_connection}", log_file)
    print_to_screen_and_log(f"background scenario log - enforce_ue_gap = {enforce_ue_gap}", log_file)

    # Read initial commands from the specified file
    if isX2LinkUp:
        path_init_cmd = (
            '/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/transversal_robustness/'
            'config/background_scenario/cellAndX2LinkUp.txt'
        )
    else:
        path_init_cmd = (
            '/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/transversal_robustness/'
            'config/background_scenario/cellUp.txt'
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

    # Parse all commands (format: delta;type;command;ue_id;ue_cmd_gap)
    all_commands = []
    for line in lines:
        parts = line.strip().split(';')
        if len(parts) >= 3:
            delta = float(parts[0])
            type_cmd = parts[1]
            command = parts[2]
            ue_id = parts[3] if len(parts) > 3 else None
            ue_cmd_gap = float(parts[4]) if len(parts) > 4 else 0.0
            if type_cmd == 'wts':  # Only include wts commands
                all_commands.append((delta, command, ue_id, ue_cmd_gap))

    # Track last execution time per UE for minimum gap enforcement
    last_exec_time = {}

    # Process commands in batches
    reason = "end of scenario"
    i = 0
    while i < len(all_commands):
        # Check for stop event
        if stop_event and stop_event.is_set():
            print_to_screen_and_log("Thread stop requested, exiting.", log_file)
            if thread_log_file:
                with open(thread_log_file, 'a') as f:
                    f.write(
                        f"[{datetime.now().strftime('%y%m%d%H%M%S')}] [write_telnet] Thread stop requested, "
                        f"exiting due to stop_event.\n"
                    )
            reason = "stop_event triggered"
            break

        # Prepare batch of commands
        batch = []

        # Collect up to cmds_per_connection commands for this batch
        for j in range(cmds_per_connection):
            if i + j < len(all_commands):
                delta, command, ue_id, ue_cmd_gap = all_commands[i + j]
                batch.append((command, delta, ue_id, ue_cmd_gap))

        if not batch:
            break

        # Execute the batch (connection stays open, timing per command inside)
        execute_commands_batch(
            batch, t0, log_file, waitResponse=0.1, verbose=verbose,
            stop_event=stop_event, last_exec_time=last_exec_time,
            enforce_ue_gap=enforce_ue_gap
            )

        if stop_event and stop_event.is_set():
            reason = "stop_event triggered"
            break

        # Move to next batch
        i += len(batch)

    if thread_log_file:
        with open(thread_log_file, 'a') as f:
            f.write(
                f"[{datetime.now().strftime('%y%m%d%H%M%S')}] [write_telnet] Thread finished. "
                f"Reason: {reason}.\n"
            )


def start_sce_background_sub_task(path_scenario, path_output, isX2LinkUp, verbose=False,
                                  cmds_per_connection=10, enforce_ue_gap=False):
    stop_event = threading.Event()
    current_date = datetime.now().strftime('%y%m%d%H%M%S')
    thread_log_file = os.path.join(path_output, f"thread_sce_{current_date}.log")
    thread_context = (
        f"Thread creation context:\n"
        f"  - start time: {current_date}\n"
        f"  - scenario path: {path_scenario}\n"
        f"  - output path: {path_output}\n"
        f"  - verbose: {verbose}\n"
        f"  - cmds per connection: {cmds_per_connection}\n"
        f"  - thread ident: None (not started yet)\n"
    )
    with open(thread_log_file, 'a') as f:
        f.write(thread_context)
        f.write(f"[{current_date}] [start_sce_background_sub_task] Thread starting.\n")
        sce_thread = threading.Thread(
            target=write_telnet,
            args=(
                path_scenario, path_output, True, stop_event, thread_log_file,
                isX2LinkUp, verbose, cmds_per_connection, enforce_ue_gap
                )
            )
    sce_thread.start()
    # Now thread ident is available
    with open(thread_log_file, 'a') as f:
        f.write(f"  - thread ident after start: {sce_thread.ident}\n")
    return sce_thread, stop_event, thread_log_file


def stop_sce_background_sub_task(stop_event, thread, thread_log_file=None):
    stop_event.set()
    if thread_log_file:
        with open(thread_log_file, 'a') as f:
            f.write(
                f"[{datetime.now().strftime('%y%m%d%H%M%S')}] [stop_sce_background_sub_task] "
                f"Stop event set. Waiting for thread to join.\n"
            )
    thread.join()
    if thread_log_file:
        with open(thread_log_file, 'a') as f:
            f.write(f"[{datetime.now().strftime('%y%m%d%H%M%S')}] [stop_sce_background_sub_task] Thread joined.\n")
