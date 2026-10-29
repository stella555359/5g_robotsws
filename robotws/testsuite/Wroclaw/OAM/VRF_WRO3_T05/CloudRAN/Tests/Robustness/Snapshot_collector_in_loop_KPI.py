import datetime
import glob
import logging
import os
import shutil
import threading
import time
import json
import subprocess
from pprint import pprint

import taf.gnb.oam.coam.cu
import taf.gnb.oam.coam.vdu
import taf.selenium.gnb.oam.coam.cu
import taf.selenium.gnb.oam.coam.vdu
from taf.selenium.gnb.oam.core.exceptions import TimeoutException, TooManyFilesFoundException
from taf.selenium.gnb.oam.coam.cu.common.exceptions import ButtonCanNotClick

selenium_lib = None
oam_lib = None
logger = None
logs_dir = ""
passed_loops = 0
failed_loops = {}
download_dir = ""
loop = 0

running_flag = True


def get_current_env():
    while True:
        global selenium_lib, oam_lib
        oam_ip = input(f"Enter OAM IP: ")
        hw_type = input("Enter test module vDU/vCU: ").lower()
        password = input("Enter OAM password: ")
        if (
                input(
                    f"\n{50 * '='}\nOAM IP: "
                    f"{oam_ip}\ntest module: {hw_type}\npassword: {password}.\nIs this correct? (y/n): "
                ).lower()
                == "y"
        ):
            if hw_type == "vdu":
                selenium_lib = taf.selenium.gnb.oam.coam.vdu.interface.vdu()
                oam_lib = taf.gnb.oam.coam.vdu.interface.vdu()
            elif hw_type == "vcu":
                selenium_lib = taf.selenium.gnb.oam.coam.cu.interface.cu()
                oam_lib = taf.gnb.oam.coam.cu.interface.cu()
            else:
                print(2 * "\n", "Invalid hardware type. Please enter 'vDU' or 'vCU'.")
                continue
            return oam_ip, password
        else:
            print(20 * "\n")
        logger.info(f"Current config:\noam_ip: {oam_ip}, hw_type: {hw_type}, password: {password}")


def login_on_webem(ip, password):
    logger.info("Login on webem")
    try:
        output = oam_lib.connect_to(host=ip, port=443, username="Nemuadmin", password=password, timeout=10, secure=True)
    except Exception as e:
        logger.error(f"Failed to connect to OAM: {e}")
        print(f"Failed to connect to OAM: \n{e}")
        quit(10)
    logger.debug(output)
    download_dir = selenium_lib.get_download_dir()
    logger.debug(f"Download dir: {download_dir}")
    logger.info("Open webem")
    try:
        output = selenium_lib.login(url=f"https://{ip}/", password=password, timeout=60)
    except Exception as e:
        logger.error(f"Failed to login on webem: {e}")
        print(f"Failed to login on webem: \n{e}")
        quit(11)
    return download_dir


def logout_from_webem():
    logger.info("Logout from webem")
    try:
        output = selenium_lib.logout()
    except Exception as e:
        logger.error(f"Failed to logout from webem: {e}")
        print(f"Failed to logout from webem: \n{e}")
    try:
        output = oam_lib.disconnect()
    except Exception as e:
        logger.error(f"Failed to disconnect from OAM: {e}")
        print(f"Failed to disconnect from OAM: \n{e}")


def get_operations_history():
    if ".cu." in str(oam_lib):
        operations = oam_lib.get_cu_operation_history()
    else:
        operations = oam_lib.get_vdu_operation_history()
    return operations['created']


def check_disk_space():
    logger.info("Check free disk space - at least 3GB needed")
    total_dl, used_dl, free_dl = shutil.disk_usage(download_dir)
    total_log, used_log, free_log = shutil.disk_usage("/home/ute/MN/UTE/robotws/testsuite")
    logger.debug(
        f"{download_dir}"
        f"\n\t\t\t\t  | free: {free_dl / (1024 ** 3):.1f} GB | used: {used_dl / (1024 ** 3):.1f} GB |"
        f" total: {total_dl / (1024 ** 3):.1f} GB |"
    )
    logger.debug(
        f"/home/ute/MN/UTE/robotws/testsuite"
        f"\n\t\t\t\t  | free: {free_log / (1024 ** 3):.1f} GB | used: {used_log / (1024 ** 3):.1f} GB |"
        f" total: {total_log / (1024 ** 3):.1f} GB |"
    )
    if free_dl > 3 * 1024 ** 3 and free_log > 3 * 1024 ** 3:
        logger.info("Disk space check passed")
        return True
    else:
        logger.info("Fail! Not enough disk space!")
        return False


def wait_for_quit():
    global running_flag
    while True:
        if input() == "q":
            print("Terminating execution, please wait...")
            logger.info("Execution interrupted on demand")
            running_flag = False
            break


def wait_for_snapshot_collection(files_before):
    logger.info("Wait for any snapshot collection to finish...")
    ongoing_operations = True

    while (ongoing_operations):
        operations = get_operations_history()
        snapshot_operations = [op['status'] for op in operations if op['name'] == "Trigger local snapshot"]
        current_ongoing_operations = len([op for op in snapshot_operations if op == "ongoing"])

        if current_ongoing_operations != 0:
            if current_ongoing_operations != ongoing_operations:
                logger.debug(f"Snapshot collections ongoing: {current_ongoing_operations}")
                ongoing_operations = current_ongoing_operations
        else:
            if current_ongoing_operations == 0 and ongoing_operations is True:
                logger.debug(f"No ongoing snapshot collections")
                ongoing_operations = 0
                break
            else:
                for timer in range(60):
                    downloaded_files = get_new_files_in_folder(download_dir, files_before)
                    no_crdownload = all('.crdownload' not in os.path.basename(f) for f in downloaded_files)
                    logger.debug(f"Downloaded files: {downloaded_files}, no .crdownload: {no_crdownload}")
                    if len(downloaded_files) > 0 and no_crdownload:
                        logger.info("Snapshot collection finished")
                        break
                    time.sleep(1)
                else:
                    logger.error("Snapshot file download did not finish in 60s after operation end!")
        time.sleep(0.5)


def collect_logs(files_before):
    loop_logs_dir = f"{logs_dir}/{loop}_loop/"
    os.makedirs(loop_logs_dir)
    logger.info(f"Collect logs - {loop_logs_dir}")
    try:
        logger.info("Check if something was downloaded from WebEm")
        downloaded_files = get_new_files_in_folder(download_dir, files_before)
        logger.debug(f"Downloaded files: {downloaded_files}")
        logger.debug(f"Before files: {files_before}")
    except Exception as e:
        logger.error(f"Failed to check downloaded files: {e}")
    finally:
        if len(downloaded_files) > 0:
            logger.info(f"Moving downloaded files to logs dir")
            for file in downloaded_files:
                try:
                    shutil.move(file, loop_logs_dir)
                except Exception as e:
                    logger.error(f"Failed to move downloaded file {file} to logs dir: {e}")
        else:
            logger.info("No files downloaded from WebEm or error occurred")
    try:
        logger.info(f"Collecting additional snapshot")
        oam_lib.get_local_snapshot(directory=loop_logs_dir, operation_timeout=900)
        wait_for_snapshot_collection(files_before)
    except Exception as e:
        logger.error(f"Failed to collect additional snapshot: {e}")
        wait_for_snapshot_collection(files_before)
    try:
        logger.info(f"Collecting snapshot history")
        snap_history_path = oam_lib.get_snapshot_history_file()
        logger.info(f"Moving snapshot history files to logs dir")
        snap_history_log_path = os.path.join(loop_logs_dir, "snapshot_history.txt")
        shutil.move(snap_history_path, snap_history_log_path)
        os.path.exists(snap_history_log_path)
    except Exception as e:
        logger.error(f"Failed to collect snapshot history: {e}")


def get_new_files_in_folder(folder_path, files_before):
    current_files = set(glob.glob(os.path.join(folder_path, "*")))
    new_files = list(current_files - set(files_before))
    return new_files


def find_record_in_snapshot_history(file_path, start_time, end_time):
    logger.info(f"Find record in snapshot history between {start_time} and {end_time}")
    with open(file_path, 'r') as f:
        for line in f:
            entry = json.loads(line)
            if start_time <= entry['start_time'] <= end_time:
                logger.debug(f"Found entry: {entry}")
                return entry
    logger.error("No matching entry found in snapshot history")
    return None


def main_loop(loops):
    global passed_loops, failed_loops, loop, download_dir, oam_ip, oam_password

    files_before = glob.glob(os.path.join(download_dir, "*"))

    while running_flag:
        loop += 1
        print(f"\rIteration {loop}/{loops} - currently: {len(failed_loops)} failed..", end='', flush=True)
        logger.info(f"{25*'#'} Start loop: {loop} {25*'#'}")
        if not check_disk_space():
            break
        try:
            logger.info("Collecting snapshot...")
            start_time = datetime.datetime.utcnow().isoformat(timespec='milliseconds') + 'Z'
            output = selenium_lib.collect_snapshot(snapshot_waiting_timeout=600)
        except TooManyFilesFoundException:
            output = 'Failed, more than one snapshot file found in download dir'
            logger.error("More than one snapshot file found in download dir, cannot continue.")
            logger.debug("Cleaning download dir...")
            current_files = glob.glob(os.path.join(download_dir, "*"))
            for file in current_files:
                os.remove(file)
            logger.info("Download dir cleaned, continue...")
            continue
        except ButtonCanNotClick:
            logger.error(f"Snapshot button can not be clicked.")
            logout_from_webem()
            download_dir = login_on_webem(oam_ip, oam_password)
            continue
        except RuntimeError as e:
            logger.error(f"Runtime fault - {e}")
            wait_for_snapshot_collection(files_before)
            continue
        except TimeoutException:
            output = 'Failed, snapshot collection timed out'
            logger.error(f"Snapshot collection timed out.")
        except Exception as e:
            logger.error(f"Unexpected fault - {e}")
            output = 'Failed, unexpected fault'
        else:
            logger.info("Collecting snapshot finished, checking status...")
        finally:
            wait_for_snapshot_collection(files_before)
            end_time = datetime.datetime.utcnow().isoformat(timespec='milliseconds') + 'Z'
            logger.info(f"Operation start time: {start_time}, end time: {end_time}")
            if 'Failed' in output:
                logger.error(f"Snapshot collection failed, possible timeout occured: \n\t\t\t\t  {output}")
                collect_logs(files_before)
                snapshot_results = find_record_in_snapshot_history(
                    f"{logs_dir}/{loop}_loop/snapshot_history.txt", start_time, end_time)
                logger.debug(f"Snap history: {snapshot_results}")
                failed_loops[f"Loop_{loop}"] = snapshot_results
            else:
                logger.debug(f"Collection status: {output}")
                if os.path.exists(output):
                    logger.info("Snap collected!")
                    no_partial = not ("partial" in os.path.basename(output).lower())
                    if no_partial:
                        logger.info("Snapshot file checked, OK!")
                        passed_loops += 1
                        os.remove(output)
                    else:
                        logger.error("Partial snapshot downloaded!")
                        collect_logs(files_before)
                        snapshot_results = find_record_in_snapshot_history(
                            f"{logs_dir}/{loop}_loop/snapshot_history.txt", start_time, end_time)
                        logger.debug(f"Snap history: {snapshot_results}")
                        failed_loops[f"Loop_{loop}"] = snapshot_results
                else:
                    logger.error("Snapshot file not found after collection!")
                    collect_logs(files_before)
                    snapshot_results = find_record_in_snapshot_history(
                        f"{logs_dir}/{loop}_loop/snapshot_history.txt", start_time, end_time)
                    logger.debug(f"Snap history: {snapshot_results}")
                    failed_loops[f"Loop_{loop}"] = snapshot_results
        if loop >= loops:
            break


def main():
    global logs_dir, logger, download_dir, oam_ip, oam_password

    # Create log dir
    curr_date = datetime.datetime.now()
    curr_date_str = curr_date.strftime("%Y-%m-%d_%H-%M-%S")
    curr_dir = os.getcwd()
    logs_dir = f"{curr_dir}/{curr_date_str}_snapshot_in_loop"
    os.makedirs(logs_dir)
    print(f"{curr_date} Execution started!")
    print(f"Logs dir: {logs_dir}")

    # Start logger
    logger = logging.getLogger("snap_logs")
    logger.setLevel(logging.DEBUG)
    fh = logging.FileHandler(f"{logs_dir}/snapshot_in_loop.log", mode="a")
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    fh.setFormatter(formatter)
    logger.addHandler(fh)
    logger.propagate = False
    logger.info("Execution started")

    # Sync VM time with NTP
    logger.info(f"Synchronize VM time with NTP server")
    response = subprocess.run("sudo service ntp stop; sudo ntpdate 10.42.248.70; sudo service ntp start",
                              capture_output=True, text=True, shell=True)
    logger.debug(f"NTP synchronized! - {response.stdout.strip()}")

    # DBG mode
    # global selenium_lib, oam_lib
    # selenium_lib = taf.selenium.gnb.oam.coam.cu.interface.cu()
    # oam_lib = taf.gnb.oam.coam.cu.interface.cu()
    # oam_ip = "10.42.140.5"
    # oam_password = "Nokia@123"
    oam_ip, oam_password = get_current_env()
    loops = ""
    while not loops.isdigit():
        loops = input("Enter number of loops to execute (or press Enter for default 100): ")
        if loops == "":
            loops = 100
        elif not loops.isdigit():
            print("Invalid input, please enter a number or press Enter for default 100.")
        else:
            loops = int(loops)
            break
    logger.info(
        f"Test config:"
        f"\n\t\t\t\t oam_ip: {oam_ip},"
        f"\n\t\t\t\t oam_password: {oam_password},"
        f"\n\t\t\t\t selenium_lib: {type(selenium_lib)},"
        f"\n\t\t\t\t oam_lib: {type(oam_lib)}."
    )
    logger.info(f"Number of loops to execute: {loops}")

    # Enable 2nd thread for execution interruption
    threading.Thread(target=wait_for_quit, daemon=True).start()
    print("\nEnter q anytime to end current execution..\n")
    time.sleep(3)

    # Main execution
    download_dir = login_on_webem(oam_ip, oam_password)
    main_loop(loops)

    # End of execution
    logout_from_webem()
    logger.info(f"\n\nExecution finished, total loops: {passed_loops + len(failed_loops)}")
    if len(failed_loops) > 0:
        logger.info(f"Passed loops: {passed_loops}")
        failed_loops_text = '\n\t\t\t\t - ' + '\n\t\t\t\t - '.join(f"{k}" for k, v in failed_loops.items())
        logger.info(f"Failed loops: {failed_loops_text}")
    else:
        logger.info(f"All loops passed!")
    print(
        f"\nExecution finished!"
        f"\nTotal loops performed: {passed_loops + len(failed_loops)}"
        f"\nPassed: {passed_loops}"
        f"\nFailed: {len(failed_loops)}"
    )


if __name__ == "__main__":
    main()
