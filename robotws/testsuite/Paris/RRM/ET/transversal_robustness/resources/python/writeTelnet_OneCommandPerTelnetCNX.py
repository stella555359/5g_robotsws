import os
import sys
import time
import telnetlib
import subprocess
import telnetlib
from datetime import datetime


def read_with_timeout(telnet_connection, log_file, timeout=900):
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


def execute_command(command, t0, log_file, delta):
    try:
        with telnetlib.Telnet('0.0.0.0', 9880) as tn:
            # tn.set_debuglevel(1)  # enable debug mode
            elapsed_time = round(time.time() - t0, 6)
            # wait for the prompt
            # tn.read_until(b"EGATE> ")
            result = read_with_timeout(tn, log_file)
            if result:
                formatted_time = datetime.now().strftime('%H:%M:%S.%f')[:-3]
                print_to_screen_and_log(f"{formatted_time}: egate response: {result}", log_file, out='file')
                # print("response:", result)
            elapsed_time = round(time.time() - t0, 6)

            # send the command
            tn.write(command.encode('ascii') + b"\r\n")
            elapsed_time = round(time.time() - t0, 6)

            # read the response from the server
            time.sleep(0.2)  # wait response from server
            # response = tn.read_very_eager() # COMMENTED SUSPICION OF INSTABILITY WITH AP
            timestamp = datetime.now().strftime('%H:%M:%S.%f')[:-3]
            elapsed_time = round(time.time() - t0, 6)
            print_to_screen_and_log(f"{timestamp} {command} sent at {elapsed_time} instead of {delta}",
                                    log_file, out='file')
            # print_to_screen_and_log(response.decode('ascii'), log_file, out='file') # COMMENTED FOR DEBUG DTN250123

            tn.write(b"exit\r\n")
            print_to_screen_and_log(f"{timestamp} exit sent",
                                    log_file, out='file')
            time.sleep(0.1)  # wait for the exit command to be processed
            tn.close()
    except Exception as e:
        print_to_screen_and_log(f"Error during execution of the command '{command}': {e}", log_file)


def write_telnet(path="./", output_path="./"):
    path = os.path.join(path, 'UeScenario')
    filename = os.path.join(path, 'master_scenario.sce')
    # define the origin of time
    t0 = time.time()
    human_readable_time = datetime.fromtimestamp(t0).strftime('%A %d %B %Y, %H:%M:%S')
    current_date = datetime.now().strftime('%y%m%d%H%M%S')
    log_file = os.path.join(output_path, f"egateSendTelnet_{current_date}.log")
    print_to_screen_and_log(f"background scenario log - path = {path} - filename = {filename}", log_file)
    print_to_screen_and_log(f"background scenario log - t0 = {t0:.6f} = {human_readable_time}", log_file)

    # open file masterScenario.sce
    input_filename = os.path.join(path, filename)
    with open(input_filename, 'r') as file:
        lines = file.readlines()

    for line in lines:
        delta, type_cmd, command = line.strip().split(';')
        delta = float(delta)

        # compute waiting time
        wait_time = t0 + delta - time.time()

        if wait_time > 0:
            time.sleep(wait_time)

        # run only command tagged with wts
        if type_cmd != 'wts':
            continue

        execute_command(command, t0, log_file, delta)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        write_telnet(sys.argv[1], sys.argv[2])
    else:
        write_telnet()
