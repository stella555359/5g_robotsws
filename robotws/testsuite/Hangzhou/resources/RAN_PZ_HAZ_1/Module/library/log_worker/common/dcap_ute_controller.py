# -*- coding: utf-8 -*-
"""
Author: Xiang, Liang
"""


import re
import subprocess
import time


def check_utf_controller_status():
    health_check_status = subprocess.run(["utf_lab-controller", "status"], stdout=subprocess.PIPE,
                                         stderr=subprocess.PIPE)
    if health_check_status.returncode == 0:
        return True


def check_update_utf_lab_common():
    check_version = subprocess.run(['utf_lab-updates'], capture_output=True, text=True)

    matches = re.findall(r'FB\d{4}\.\d', check_version.stdout)

    if matches:
        installed_version = matches[0]
        if len(matches) > 1:
            latest_version = matches[1]

    if installed_version == latest_version:
        print("The installed version is latest:" + latest_version)
    else:
        print(
            "Installed version:" + installed_version + ", and Latest version:" + latest_version + ". Start to upgrade.")
        command = ["sudo", "UTE_CLOUD=1", "bash", "/home/ute/Downloads/utf_lab_installer." + latest_version + ".sh",
                   "127.0.0.1"]
        try:
            upgradeutf = subprocess.run(command, timeout=1200, stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE, check=True, text=True)
            print(upgradeutf.stdout)
        except subprocess.CalledProcessError as e:
            print(f"CalledProcessError: {e}")
            print(e.stdout)
            print(e.stderr)
            print(upgradeutf.stdout)
            print(upgradeutf.stderr)
            return
        except subprocess.TimeoutExpired as e:
            print(f"Command timed out after {e.timeout} seconds")
            print(e.stdout)
            print(e.stderr)
            print(upgradeutf.stdout)
            print(upgradeutf.stderr)
            return
        except Exception as e:
            print(f"One unknown error：{e}")
            print(e.stdout)
            print(e.stderr)
            print(upgradeutf.stdout)
            print(upgradeutf.stderr)
            return

        if upgradeutf.returncode == 0:
            print("utf_lab-updates succeed")
        else:
            print("utf_lab-updates failed!")
            print(upgradeutf.stdout)


def start_dcap_controller_common():
    # Check whether utf_lab is latest, if not, upgrade automatically
    check_update_utf_lab_common()
    # Start to start dcap controller
    if check_utf_controller_status():
        print("Utf lab controller was started")
        restart_dcap_controller_common()
        return
    else:
        print("Utf lab controller is not started and Will start utf lab controller")

        start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE)
        if start_status.returncode == 0:
            print("All DCAP containers started successfully. ")
            dcap_checks_attempts = 3
            for _ in range(dcap_checks_attempts):
                if check_utf_controller_status():
                    print("DCAP health check passed.")
                    return
                time.sleep(10)
            print("DCAP containers failed.")
            raise Exception("Starting Dcap Failed!")


def restart_dcap_controller_common():
    # Check whether utf_lab is latest, if not, upgrade automatically
    start_status = subprocess.run(["utf_lab-controller", "restart"], stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
    if start_status.returncode == 0:
        print("All DCAP containers re-started successfully. ")
        dcap_checks_attempts = 3
        for _ in range(dcap_checks_attempts):
            if check_utf_controller_status():
                print("DCAP health check passed.")
                return
            time.sleep(10)
        print("DCAP containers failed.")
        raise Exception("re-starting Dcap Failed!")


if __name__ == "__main__":
    start_dcap_controller_common()
