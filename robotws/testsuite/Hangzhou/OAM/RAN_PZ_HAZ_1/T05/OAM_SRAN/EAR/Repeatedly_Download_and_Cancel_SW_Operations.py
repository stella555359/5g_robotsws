import random
import time
from datetime import datetime, timedelta
import os
import taf.ul.alarms_watchdog
from taf.ul.alarms_watchdog import Alarm
from taf.nms.netact.facade import Netact
from taf.sbts.oam.coam.admin import admin


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


if __name__ == "__main__":
    # Allowed Allarms for CRT Tests used with taf.ul.alarms.watchdog library
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
        Alarm(fault_name="No Xn link available", fault_id="7311"),
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
    # Parse command-line arguments

    # logging.basicConfig(level=logging.INFO)
    # logging.getLogger('paramiko').setLevel(level=logging.ERROR)
    NETACT_SERVER_INFO = {"IP": "10.56.3.18",
                          "URL": "jiang7lbwas.jiang7.srnhz.nsn-rdnet.net",
                          "USERNAME": "omc",
                          "PASSWORD": "Nokia123!",
                          "PORT": "22",
                          "EXTEND_IP": ""}
    dist_names = 'PLMN-PLMN/MRBTS-5345'
    # sw_version = 'SBTS20A_ENB_0000_000861_000003'
    # sw_package_path = '/tmp/{}_release_BTSSM_downloadable.zip'

    print(CRT_ALLOWED_ALARMS)
    watchlog = taf.ul.alarms_watchdog.alarms_watchdog()
    watchlog.watch_alarms(CRT_ALLOWED_ALARMS)
    netact = Netact()
    netact.add_node('cmwas', NETACT_SERVER_INFO['IP'], NETACT_SERVER_INFO['USERNAME'], NETACT_SERVER_INFO['PASSWORD'])
    # try:
    #     netact.integrate_mrbts_with_netact(mo_release='SBTS25R3',
    #                                    mr='MRC-COMMON/MR-COMMON',
    #                                    mrbts_address='10.106.205.17',
    #                                    dist_name=dist_names,
    #                                    security_mode='no TLS')
    # except Exception as e:
    #     print(e)
    current_date = datetime.now()
    print(current_date)
    threshold_date = current_date - timedelta(days=4)
    print(threshold_date)
    imported_build = netact.get_list_of_imported_builds()
    print(imported_build)
    # filtered_builds = [build for build in imported_build if '9999' in build and '0000' in build]
    filtered_builds = []
    for build in imported_build:
        # Check if the build contains '9999' or '0000'
        if '9999' in build and '0000' in build:
            # Extract the date part (assume it's the 3rd underscore-separated field)
            try:
                date_str = build.split('_')[3]
                build_date = datetime.strptime(date_str, '%y%m%d')
                # Check if the build date is within the threshold
                if build_date >= threshold_date:
                    filtered_builds.append(build)
            except ValueError:
                # Skip builds with invalid date formats
                print(f"Skipping invalid date format in build: {build}")

    print("Filtered builds:", filtered_builds)
    # Ensure there are filtered builds to proceed
    if not filtered_builds:
        print("No valid builds found after filtering. Exiting.")
    else:
        # selected_build = filtered_builds.remove('SBTS25R3_ENB_9999_250423_0000')

        # selected_build = filtered_builds[-1]

        # Loop 100 times or until get_detected_alarms returns results
        for i in range(200):
            print(f"Starting SWM operation iteration {i + 1}...")
            selected_build_1 = random.choice(filtered_builds)
            print("Selected build:", selected_build_1)
            # Start the SWM operation
            # Retry logic for start_swm_operation
            operation_id = None
            while operation_id is None:
                try:
                    # Start the SWM operation
                    operation_id = netact.start_swm_operation(
                        operation_type='download',
                        dist_names=dist_names,
                        package=selected_build_1
                    )
                    print(f"Operation ID: {operation_id}")
                except Exception as e:
                    print(f"Failed to start SWM operation for build {selected_build_1}. Retrying... Error: {e}")
                    time.sleep(5)  # Wait before retrying
            print(selected_build_1)
            print(f"Operation ID: {operation_id}")

            # Wait for a random time before checking progress
            random_point = random.randint(30, 180)
            print(random_point)
            time.sleep(random_point)

            # Check the progress of the operation
            progress = netact.get_progress_of_swm_operation(operation_id)
            print(f"Progress: {progress}")

            # Cancel the operation if it is ongoing
            if progress['Status'] == 'ONGOING':
                cancel_result = netact.cancel_swm_operation(operation_id)
                print(f"Cancel operation result: {cancel_result}")

            # Check detected alarms
            detected_alarms = watchlog.get_detected_alarms()
            print(f"Detected alarms: {detected_alarms}")

            # Exit the loop if detected alarms are found
            if detected_alarms:
                print("Detected alarms found. Exiting loop.")
                break
                # Clean up log files in each iteration
            clean_watchdog_logs(directory="./", keyword="admin_api_alarms_watchdog")
            time.sleep(15)
        # Stop watching alarms
        watchlog.stop_watching_alarms()
        api_admin = admin()
        api_admin.setup_admin('192.168.255.129', connection='primary')
        alarms = api_admin.collect_snapshot('/home/ute/Downloads/', connection='primary')
        api_admin.teardown_admin(connection='primary')
        netact.delete_node('cmwas')
        # api_admin= admin()
        # api_admin.setup_admin('10.106.205.17',connection='primary')
        # alarms= api_admin.get_alarms(connection='primary')
        # print(alarms)
        # api_admin.teardown_admin(connection='primary')
        # netact.get_alarms(dist_name=dist_names)
    # print(f"Progress: {progress}, Random cancel point: {random_point}")
    # if progress >= random_point:
    # netact.cancel_swm_operation(operation_id)

    # Clean up
    # netact.deintegrate_mrbts_from_netact(dist_name=dist_names)

    # if progress==random:
    #     netact.cancel_swm_operation(operation_id)
    # netact.deintegrate_mrbts_from_netact(dist_name=mrbts_mo_dist_name)
