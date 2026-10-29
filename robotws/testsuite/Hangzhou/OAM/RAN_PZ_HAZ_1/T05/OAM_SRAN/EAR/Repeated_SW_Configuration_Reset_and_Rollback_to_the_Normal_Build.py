import subprocess
import time
import os
from taf.sbts.oam.coam.admin import admin
from taf.fdsw.rc import RescueConsoleConnection
import argparse
import taf.ul.alarms_watchdog
from taf.ul.alarms_watchdog import Alarm
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.testline import TestLine


def collect_snapshot(bts_host='192.168.255.129', suffix_name='s.zip'):
    print('Function: get_snapshot for ' + bts_host)

    prefix_timestamp = time.strftime("%Y%m%d_%H%M%S", time.localtime())
    prefix_snapshot = 'Snapshot_'
    snapshot_admin = admin()
    snapshot_admin.setup_admin(bts_host, connection='snapshot')
    active_sw_version = snapshot_admin.get_sw_version(connection='snapshot')
    if len(suffix_name) > 0:
        snapshot_name = prefix_snapshot + bts_host + '_' + active_sw_version + '_' + prefix_timestamp + '_' \
                        + suffix_name
    else:
        snapshot_name = prefix_snapshot + bts_host + '_' + active_sw_version + '_' + prefix_timestamp + '.zip'

    operation_status = snapshot_admin.get_snapshot(snapshot_name, connection='snapshot')
    snapshot_admin.teardown_admin(connection='snapshot')
    print('collect snapshot finished with status: ' + operation_status)
    return operation_status


def clean_watchdog_logs(directory, keyword="admin_api_alarms_watchdog"):
    """
    Clean up log files in the specified directory that contain the given keyword.

    :param directory: The directory to search for log files.
    :param keyword: The keyword to match in the filenames.
    """
    try:
        # List all files in the directory
        for filename in os.listdir(directory):
            # Check if the file contains the keyword
            if keyword in filename:
                file_path = os.path.join(directory, filename)
                # Delete the file
                os.remove(file_path)
                print(f"Deleted log file: {file_path}")
    except Exception as e:
        print(f"Error while cleaning logs: {e}")


def wait_for_ping_loss(ip_address, timeout=360, interval=5):
    """
    Wait until the specified IP address stops responding to ping.

    :param ip_address: The IP address to ping.
    :param timeout: Maximum time to wait in seconds.
    :param interval: Time interval between pings in seconds.
    :return: True if the IP stops responding within the timeout, False otherwise.
    """
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            # Use subprocess to send a ping command
            result = subprocess.run(["ping", "-c", "1", ip_address], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if result.returncode != 0:
                print(f"Ping to {ip_address} lost.")
                return True
            else:
                print(f"Ping to {ip_address} still responding.")
        except Exception as e:
            print(f"Error while pinging {ip_address}: {e}")
        time.sleep(interval)
    print(f"Timeout reached. {ip_address} did not stop responding.")
    return False


def wait_for_ping(ip_address, timeout=600, interval=5):
    """
    Wait until the specified IP address responds to ping.

    :param ip_address: The IP address to ping.
    :param timeout: Maximum time to wait in seconds.
    :param interval: Time interval between pings in seconds.
    :return: True if the IP responds within the timeout, False otherwise.
    """
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            # Use subprocess to send a ping command (Linux uses -c for count)
            result = subprocess.run(["ping", "-c", "1", ip_address], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if result.returncode == 0:
                print(f"Ping to {ip_address} successful.")
                return True
        except Exception as e:
            print(f"Error while pinging {ip_address}: {e}")
        print(f"Waiting for {ip_address} to respond...")
        time.sleep(interval)
    print(f"Timeout reached. {ip_address} did not respond.")
    return False


def retry_with_timeout(func, *args, timeout=600, interval=10, **kwargs):
    """
    Retry a function until it succeeds or the timeout is reached.

    :param func: The function to execute.
    :param args: Positional arguments for the function.
    :param timeout: Maximum time to retry in seconds.
    :param interval: Time interval between retries in seconds.
    :param kwargs: Keyword arguments for the function.
    :return: The result of the function if it succeeds, or raises the last exception.
    """
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            # Attempt to execute the function
            return func(*args, **kwargs)
        except Exception as e:
            print(f"Function {func.__name__} failed with error: {e}. Retrying in {interval} seconds...")
            time.sleep(interval)
    raise TimeoutError(f"Function {func.__name__} failed to succeed within {timeout} seconds.")


def wait_for_ping_recovery(ip_address, timeout=600, interval=5):
    """
    Wait until the specified IP address responds to ping again.

    :param ip_address: The IP address to ping.
    :param timeout: Maximum time to wait in seconds.
    :param interval: Time interval between pings in seconds.
    :return: True if the IP responds within the timeout, False otherwise.
    """
    return wait_for_ping(ip_address, timeout, interval)


if __name__ == "__main__":
    # Parse command-line arguments
    CRT_ALLOWED_ALARMS = [
        Alarm(fault_name="LMP access via port"),
        Alarm(fault_name="SSH enabled"),
        Alarm(fault_name="User Account has Default Password"),
        Alarm(fault_name="R&D Service Port enabled"),
        Alarm(fault_name="Temp Fault1"),
        Alarm(fault_name="LMP access via port 443"),
        Alarm(fault_name="LMP access via port 3600"),
        Alarm(fault_name="BTS Reset Cause"),
        Alarm(fault_name="Service account root access is enabled"),
        Alarm(fault_name="Ethernet port security is disabled"),
        Alarm(fault_name="Setup of X2 connectivity to gNB failed", fault_id="6327"),
        Alarm(fault_name="No X2 link available", fault_id="7300"),
        Alarm(fault_name="Problem sending VES event to SMO/ONAP VES Endpoint", fault_id="4639"),
        Alarm(fault_name="No X2 link available for a specific LTEENB", fault_id="7319"),
        Alarm(fault_name="Failure in connection to Real-time PM Collection Entity", fault_id="4203"),
        Alarm(fault_name="Serial console activated", fault_id="4334"),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Minor",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Minor",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Minor",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b, 2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b, 2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Minor",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Minor",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Minor",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b, 2}",
        ),

        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Major",
            reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                   "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b, 2}",
        ),
        Alarm(
            fault_name="Sanity Check Error",
            severity="Warning",
            fault_id="4681"),
        Alarm(
            fault_name="Diagnostic Check Error",
            fault_id="4681"),
        Alarm(
            fault_name="ToP reference missing",
            fault_id="4298"),
        Alarm(
            fault_name="Reference clock missing in startup",
            fault_id="4153"),

    ]
    parser = argparse.ArgumentParser(description="Script to execute admin operations.")
    parser.add_argument("--ip_address", type=str,
                        help="IP address to connect to. Defaults to 192.168.255.129 if not provided.")
    args = parser.parse_args()
    _enb_sbts_1 = RealEnb(
        oam_ip=NetworkAddress("10.56.197.136"),
        instance_id=5339,
    )

    # Use the provided IP address or default to 192.168.255.129
    ip_address = args.ip_address if args.ip_address else "192.168.255.129"
    watchlog = taf.ul.alarms_watchdog.alarms_watchdog()
    watchlog.watch_alarms(allowed_alarms=CRT_ALLOWED_ALARMS, bts_config=_enb_sbts_1)
    print("watch dog started.....")
    # # Initialize the admin API
    api = admin()

    api.setup_admin(bts_host=ip_address, name="configuration")
    NRCEL_status = api.get_ids_for_all("NRCEL", connection="configuration")
    LNCEL_status = api.get_ids_for_all("LNCEL", connection="configuration")
    WNCEL_status = api.get_ids_for_all("WNCEL", connection="configuration")
    GNCEL_status = api.get_ids_for_all("GNCEL", connection="configuration")

    has_nrcel_status = bool(NRCEL_status)
    has_lncel_status = bool(LNCEL_status)
    has_wncel_status = bool(WNCEL_status)
    has_gncel_status = bool(GNCEL_status)
    print(f"Has NRCEL status: {has_nrcel_status}")
    print(f"Has LNCEL status: {has_lncel_status}")
    print(f"Has WNCEL status: {has_wncel_status}")
    print(f"Has GNCEL status: {has_gncel_status}")

    active_build = api.get_software_info(connection="configuration")
    print(active_build['Active SW version'])

    # Reset configuration
    print("Resetting configuration...")
    for i in range(20):
        print(f"Starting configuration reset and rollback operation iteration {i + 1}...")
        api.reset_configuration(connection="configuration")
        # Wait for the IP to respond to ping
        # Wait for the IP to stop responding to ping
        print(f"Waiting for {ip_address} to stop responding to ping...")
        if wait_for_ping_loss(ip_address):
            print(f"{ip_address} has stopped responding to ping. Waiting for it to come back online...")
        else:
            print(f"{ip_address} did not stop responding within the timeout. Exiting.")
            exit(1)

        # Wait for the IP to respond to ping again
        if wait_for_ping_recovery(ip_address):
            print(f"{ip_address} is back online. Proceeding with the next steps.")
        else:
            print(f"Failed to reach {ip_address}. Exiting.")
            exit(1)
        time.sleep(180)
        # Initialize RescueConsoleConnection
        print("start connect to fdsw resceue console")
        rc_connection = RescueConsoleConnection(ip_address="192.168.255.129", port=443, username="Nemuadmin",
                                                password="nemuuser",
                                                secure=False, name='primary')
        slot1_sw = rc_connection.get_sw_version_name(sw_slot_id=1)
        slot2_sw = rc_connection.get_sw_version_name(sw_slot_id=2)
        if active_build['Active SW version'] in slot1_sw:
            rc_connection.software_rollback(1, connection="primary")
        else:
            rc_connection.software_rollback(2, connection="primary")
        print("start connect to fdsw resceue console on ESM")

        remote_connection = RescueConsoleConnection.setup_remote(ssh_host="10.97.92.251", ssh_port=22,
                                                                 ssh_username='ute',
                                                                 ssh_password='UTE.debian12')

        time.sleep(90)
        rc_remote_connection = retry_with_timeout(
            RescueConsoleConnection,
            ip_address="127.0.0.1",
            port=8888,
            username="Nemuadmin",
            password="nemuuser",
            secure=False,
            name="second"
        )

        slot1_sw_second = rc_remote_connection.get_sw_version_name(sw_slot_id=1)
        print(slot1_sw_second)
        if active_build['Active SW version'] in slot1_sw_second:
            rc_remote_connection.software_rollback(1, connection="second")
        else:
            rc_remote_connection.software_rollback(2, connection="second")
            # Wait for the IP to respond to ping again
        if wait_for_ping_recovery(ip_address):
            time.sleep(180)
            print(f"{ip_address} is back online. Proceeding with the next steps.")
        else:
            print(f"Failed to reach {ip_address}. Exiting.")
            exit(1)

        # rc_remote_connection.disconnect()
        # RescueConsoleConnection.disconnect_remote(remote_connection)
        print("kill remote connection")
        time.sleep(60)
        api.reset_admin(connection="configuration")
        print("resetting admin cli connection")
        time.sleep(300)
        print("start verify BTS state")
        # check alarm
        result = api.assert_every("SMOD", 'operationalState=regex"(?i)enabled"', timeout=120,
                                  connection="configuration")
        print(result)
        result = api.assert_every("RMOD", 'operationalState=regex"(?i)enabled"', timeout=120,
                                  connection="configuration")
        print(result)
        if has_nrcel_status:
            result = api.assert_every("NRCEL", 'operationalState=regex"(?i)enabled"', timeout=120,
                                      connection="configuration")
        print(result)
        if has_wncel_status:
            result = api.assert_every("WNCEL", 'operationalState=regex"(?i)enabled"', timeout=120,
                                      connection="configuration")
            print(result)
        if has_lncel_status:
            result = api.assert_every("LNCEL", 'operationalState=regex"(?i)enabled"', timeout=120,
                                      connection="configuration")
            print(result)
        if has_gncel_status:
            result = api.assert_every("GNCEL", 'operationalState=regex"(?i)enabled"', timeout=120,
                                      connection="configuration")
            print(result)
        # Check detected alarms
        detected_alarms = watchlog.get_detected_alarms()
        print("11111111111111111111111111111111111111111111111111111111111111")
        print(f"Detected alarms: {detected_alarms}")
        print("11111111111111111111111111111111111111111111111111111111111111")
        # Exit the loop if detected alarms are found
        if detected_alarms:
            print("Detected alarms found. Exiting loop.")
            prefix_timestamp = time.strftime("%Y%m%d_%H%M%S", time.localtime())
            snapshot_name = '/home/ute/Downloads/' + ip_address + '_' + prefix_timestamp + '.zip'
            api.collect_snapshot(snapshot_name, connection="configuration")
            break
            # Clean up log files in each iteration
        clean_watchdog_logs(directory="./", keyword="admin_api_alarms_watchdog")
    watchlog.stop_watching_alarms()
    api.teardown_all_aliases_for_admin()
    # print("clean up admin cli connection")
