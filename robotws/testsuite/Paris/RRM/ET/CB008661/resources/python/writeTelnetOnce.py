import os
import sys
import time
import telnetlib
import subprocess
from datetime import datetime


def read_initial_commands(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        commands = []
        for line in lines[:2]:  # Read only the first two lines
            command, wait_time = line.strip().split(';')
            commands.append((command, float(wait_time)))
        return commands


def read_egate_very_eager(telnet_connection, log_file, search_string=b"EGATE> ", timeout_while=3600):
    start_time = time.time()
    buffer = b""
    # search_string = b":INF: SP: Script completed"
    egate_errors = [b"connection timed out", b"Failed to execute"]
    # check and convert search_string if necessary
    if isinstance(search_string, str):
        search_string = search_string.encode('ascii')
    elif not isinstance(search_string, bytes):
        print_to_screen_and_log(f"...unsupported search_string type for {search_string}", log_file, 'all')
        return "ERR: unsupported search_string type detected during read_egate_very_eager"
    search_strings = [search_string] + egate_errors

    print_to_screen_and_log(f"in read_egate_very_eager - log_file = {log_file}", log_file, 'all')
    print_to_screen_and_log(f"in read_egate_very_eager - timeout_while = {timeout_while}", log_file, 'all')
    # print_to_screen_and_log(f"in read_egate_very_eager - search_string = {search_string}", log_file, 'all')
    for msg in search_strings:
        print_to_screen_and_log(f"in read_egate_very_eager - search_string = {msg}", log_file, 'all')
        # print_to_screen_and_log(f"in read_egate_very_eager - search_string bytes = {msg_bytes}", log_file, 'all')

    stop_while = False
    with open(log_file, 'a') as file:
        while not stop_while:
            if time.time() - start_time > timeout_while:
                print("Timeout reached while in read_egate_very_eager !")
                break
            if telnet_connection.sock_avail() > 0:
                response = telnet_connection.read_very_eager()
                # print_to_screen_and_log(f"Le type de response est: {type(response)}", log_file, 'all')
                file.write(response.decode('utf-8'))
                buffer += response
#                if search_string in response:
            for msg in search_strings:
                if msg in buffer:
                    # print_to_screen_and_log(f"Search string '{msg}' stop condition", log_file, 'all')
                    file.write(f"Search string '{msg}' stop condition" + '\n')
                    stop_while = True
                    break
            else:
                continue
            time.sleep(0.1)  # small delay before next check
    return "end of read_egate_very_eager"


def read_egate_until(telnet_connection, log_file, timeout=900, msg="EGATE>"):
    start_time = time.time()
    message_displayed = False
    i = 1
    print_to_screen_and_log(f"in read_egate_until - log_file = {log_file}", log_file, 'all')
    print_to_screen_and_log(f"in read_egate_until - timeout = {timeout}", log_file, 'all')
    msg_bytes = msg.encode('ascii')
    print_to_screen_and_log(f"in read_egate_until - msg = {msg}", log_file, 'all')
    print_to_screen_and_log(f"in read_egate_until - msg_bytes = {msg_bytes}", log_file, 'all')

    while True:
        if telnet_connection.sock_avail() > 0:  # check if buffer is not empty
            return telnet_connection.read_until(msg_bytes)

        if not message_displayed:
            formatted_time = datetime.now().strftime("%y%m%d-%H%M%S.%f")[:-3]
            print_to_screen_and_log(f"{formatted_time}: {i} in read_egate_until... ", log_file, out='file')
            # message_displayed = True

        if time.time() - start_time > timeout:
            print_to_screen_and_log("ERR: egate timeout of 15 minutes has been reached", log_file, out='all')
            sys.exit()  # stop the script

        time.sleep(1)  # wait 1s
        i += 1


# print to screen and log
def print_to_screen_and_log(message, log_file, out='all'):
    if out == 'all':
        print(message)
    with open(log_file, 'a') as f:
        f.write(message + '\n')


def execute_command(command, t0, log_file, waitResponse=0.2, tag_end=b"EGATE> "):
    print_to_screen_and_log(f"in execute_command - command = {command}", log_file, out='all')
    try:
        with telnetlib.Telnet('0.0.0.0', 9880) as tn:
            # tn.set_debuglevel(1)  # enable debug mode
            elapsed_time = round(time.time() - t0, 6)
            # wait for the prompt
            # tn.read_until(b"EGATE> ")
            result = read_egate_until(tn, log_file)
            # print_to_screen_and_log(f"in execute_command 001 - result = {result}", log_file, out='all')
            if result:
                formatted_time = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                print_to_screen_and_log(f"{formatted_time}: egate response: {result}", log_file, out='file')
                # print("response:", result)
            elapsed_time = round(time.time() - t0, 6)
            # print_to_screen_and_log(f"in execute_command 002 - elapsed_time = {elapsed_time}", log_file, out='all')

            # send the command
            tn.write(command.encode('ascii') + b"\r\n")
            # print_to_screen_and_log(f"in execute_command 002bis - result = {result}", log_file, out='all')

            # result = read_egate_until(tn, log_file, 600, tag_end)
            # if result:
            #     formatted_time = datetime.now().strftime('%H:%M:%S.%f')[:-3]
            #     print_to_screen_and_log(f"{formatted_time}: egate response: {result}", log_file, out='file')

            # wait the end of the script
            time.sleep(waitResponse)  # wait response from server
            result = read_egate_very_eager(tn, log_file, search_string=tag_end, timeout_while=3600)
            # print_to_screen_and_log(f"in execute_command 003 - result = {result}", log_file, out='all')
            print_to_screen_and_log(f"result = {result}", log_file, out='file')
            timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]

            tn.write(b"exit\r\n")
            print_to_screen_and_log(f"{timestamp} exit sent", log_file, out='file')
            time.sleep(0.1)  # wait for the exit command to be processed
            tn.close()
    except Exception as e:
        print_to_screen_and_log(f"Error during execution of the command '{command}': {e}", log_file)


def writeTelnetOnce(path_to_cmd="./commands.csv", output_path="./"):
    current_date = datetime.now().strftime('%y%m%d%H%M%S')
    log_file = os.path.join(output_path, f"egateSendTelnetOnce_{current_date}.log")
    t0 = time.time()
    waitResponse = 1

    # define the origin of time
    t0 = time.time()
    human_readable_time = datetime.fromtimestamp(t0).strftime('%A %d %B %Y, %H:%M:%S')
    print_to_screen_and_log(f"writeTelnetOnce - path_to_cmd = {path_to_cmd}", log_file, 'all')
    print_to_screen_and_log(f"writeTelnetOnce - t0 = {t0:.6f} = {human_readable_time}", log_file, 'all')

    # Check file extension
    file_extension = os.path.splitext(path_to_cmd)[1]

    if file_extension == '.csv':
        # send command to egate via telnet
        with open(path_to_cmd, 'r') as file:
            lines = file.readlines()
        for line in lines:
            command, tag_end = line.strip().split(';')
        # first element of the list
            if len(command) == 1:
                command = command[0]
            execute_command(command, t0, log_file, waitResponse, tag_end)
    elif file_extension == '.sce':
        # Read the .sce file and execute the single command
        command = os.path.join("/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/script", path_to_cmd)
        command = "script file=" + command
        tag_end = "Script completed"
        execute_command(command, t0, log_file, waitResponse, tag_end)
    else:
        print_to_screen_and_log(f"Unsupported file type: {file_extension}", log_file, all)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        writeTelnetOnce(sys.argv[1], sys.argv[2])
    else:
        writeTelnetOnce()
