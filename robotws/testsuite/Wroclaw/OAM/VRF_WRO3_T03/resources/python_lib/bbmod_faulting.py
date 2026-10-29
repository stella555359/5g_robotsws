import paramiko
import subprocess
import time

"""
Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_1
...  *****************
...  Basic information
...  *****************
...  Internal CB012611 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  22.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-598 - resource creation
...  02.07.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22401 - Implement inject_i2c_command_abion
...  function for I2C fault triggering and recovery
"""

BTS_HOST = "192.168.255.129"
PORT = 22
BTS_USERNAME = "toor4nsn"
BTS_PASSWORD = "oZPS0POrRieRtu"
KNOWN_HOST = "rm /user/toor4nsn/.ssh/known_hosts"


def is_host_pingable(host):
    """
    Checks if the host is reachable via ping.

    Parameters:
    host (str): The hostname or IP address to ping.

    Returns:
    bool: True if the host is reachable, False otherwise.
    """
    try:
        result = subprocess.run(['ping', '-c', '1', '-W', '2', host], stdout=subprocess.DEVNULL)
        return result.returncode == 0
    except Exception as e:
        print(f"An error occurred: {e}")
        return False


def generate_fault_abion_lokiab(bbmod_name, slot_id, soc):
    """
    Generates a fault command based on the provided parameters:
    "bmutool -S <slot id> -r 0x10 0xA0" for Loki_A
    "bmutool -S <slot id> -r 0x11 0xA0" for Loki_B

    Parameters:
    slot_id (str): Slot id is for all the rack (1-3 5-7).
    bbmod_name (str): The name of the BBMOD, must be either 'ABIO' or 'ABIN'.
    soc (str): SoC, must be 'LokiA' or 'LokiB' if bbmod_name is 'ABIO', or 'LokiA' if bbmod_name is 'ABIN'.

    Notes:
    +=======================+=======================+
    |       SLOT #3         |       SLOT #7         |
    +=======================+=======================+
    |       SLOT #2         |       SLOT #6         |
    +=======================+=======================+
    |       SLOT #1         |       SLOT #5         |
    +=======================+=======================+
    |       SMOD            |       SMOD            |
    +=======================+=======================+
    """
    if not is_host_pingable(BTS_HOST):
        raise ConnectionError(f"Host {BTS_HOST} is not reachable.")
    amia_slot = int(slot_id.split('-')[-1])
    if bbmod_name not in ["ABIO", "ABIN"]:
        print("Warning: bbmod_name must be ABIO or ABIN.")
    elif amia_slot not in [1, 2, 3, 5, 6, 7]:
        print("Warning: slot_id must be one of (1-3, 5-7).")
    elif (bbmod_name == "ABIO" and soc not in ["LokiA", "LokiB"]) or (bbmod_name == "ABIN" and soc != "LokiA"):
        print("Warning: soc value is incorrect for the given bbmod_name.")
    else:
        if soc == "LokiA":
            command = rf"bmutool -S {amia_slot} -r 0x10 0xA0"
        elif soc == "LokiB":
            command = rf"bmutool -S {amia_slot} -r 0x11 0xA0"
    try:
        print(command)
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(BTS_HOST, PORT, BTS_USERNAME, BTS_PASSWORD)
        (stdin, stdout, stderr) = ssh.exec_command(command)
        output = stdout.readlines()
        errors = stderr.readlines()
        print(output)
        print(errors)
        if errors:
            print(f"Command '{command}' execution failed with errors: {errors}")
        else:
            print(f"Command '{command}' executed successfully.")
    except Exception as e:
        return f"Error during SSH connection: {str(e)}"


def recovery_action_abion(slot_id):
    """
    Generates a recovery command based on the provided parameter:
    "bmutool -S <slot id> -r 0x1F 1"

    Parameter:
    slot_id (str): Slot id is for all the rack (1-3 5-7).

    """
    amia_slot = int(slot_id.split('-')[-1])
    if amia_slot not in [1, 2, 3, 5, 6, 7]:
        print("Warning: slot_id must be one of (1-3, 5-7).")
    recovery_command = f"bmutool -S {amia_slot} -r 0x1F 1"
    try:
        print(recovery_command)
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(BTS_HOST, PORT, BTS_USERNAME, BTS_PASSWORD)
        (stdin, stdout, stderr) = ssh.exec_command(recovery_command)
        output = stdout.readlines()
        errors = stderr.readlines()
        print(output)
        print(errors)
        if errors:
            print(f"Command '{recovery_command}' execution failed with errors: {errors}")
        else:
            print(f"Command '{recovery_command}' executed successfully.")
    except Exception as e:
        return f"Error during SSH connection: {str(e)}"


def inject_i2c_command_abion(slot_id, action="fault"):
    """
    Logs into BTS, then FSP, triggers I2C fault or recovery on the FSP.

    Parameters:
    slot (int or str): The slot number (1, 2, or 3) or slot identifier in format "SLOT-ID"
                       where N is 1, 2, or 3
    action (str): Either "fault" or "recovery"

    Returns:
    None
    """
    # Map slot numbers to FSP hosts
    FSP_MAP = {1: "fsp1s0icom", 2: "fsp2s0icom", 3: "fsp3s0icom"}

    slot = int(slot_id.split('-')[-1])

    if slot not in FSP_MAP:
        print(f"Invalid slot {slot}. Must be 1, 2, or 3.")
        return

    fsp_host = FSP_MAP[slot]
    print(f"Selected FSP host: {fsp_host}")

    if not is_host_pingable(BTS_HOST):
        print(f"Host {BTS_HOST} is not reachable. Exiting.")
        return

    try:
        # print(f"Connecting to BTS ({BTS_HOST})...")
        ssh_bts = paramiko.SSHClient()
        ssh_bts.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_bts.connect(BTS_HOST, PORT, BTS_USERNAME, BTS_PASSWORD)
        (stdin, stdout, stderr) = ssh_bts.exec_command(KNOWN_HOST)
        error = stderr.read().decode()
        exit_status = stdout.channel.recv_exit_status()

        if error:
            print(f"Stderr from cmd: {error}")
        if exit_status == 0:
            print("Known_hosts file removed correctly!")
        else:
            print(f"Cannot remove known_hosts due to: {error}")
        # print("Connected to BTS.")

        channel = ssh_bts.invoke_shell()
        channel.settimeout(10)

        if channel.recv_ready():
            channel.recv(4096)

        # print(f"Opening SSH connection to FSP ({fsp_host})...")
        channel.send(f"ssh {BTS_USERNAME}@{fsp_host}\n")

        buffer = ""
        while True:
            if channel.recv_ready():
                resp = channel.recv(4096).decode("utf-8")
                buffer += resp

                if "Are you sure you want to continue connecting" in buffer:
                    channel.send("yes\n")
                    buffer = ""

                elif "password:" in buffer.lower():
                    channel.send(f"{BTS_PASSWORD}\n")
                    buffer = ""

                elif any(prompt in buffer for prompt in ["#", "$", ">"]):
                    print(f"Logged into FSP {fsp_host}.")
                    break
            else:
                time.sleep(0.5)

        if action == "fault":
            print("Triggering I2C fault...")
            cmd = "echo 0x17 > /sys/kernel/debug/oip-3-0054/addr ; echo 1 > /sys/kernel/debug/oip-3-0054/data"
        elif action == "recovery":
            print("Performing I2C recovery...")
            cmd = "echo 0 > /sys/kernel/debug/oip-3-0054/data"
        else:
            print("Invalid action. Use 'fault' or 'recovery'.")
            channel.send("exit\n")
            channel.close()
            ssh_bts.close()
            return

        channel.send(cmd + "\n")
        time.sleep(2)

        while channel.recv_ready():
            channel.recv(4096)

        print(f"{action.capitalize()} operation completed successfully.")

        channel.send("exit\n")
        time.sleep(1)
        channel.close()
        ssh_bts.close()
        # print("Session closed.")

    except Exception as e:
        print(f"Error: {e}")
