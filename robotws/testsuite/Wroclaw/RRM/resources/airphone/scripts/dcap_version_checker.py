import os
import subprocess
import re
import socket
import threading
import time
from robot.api import logger

DCAP_VER_CHECK_SCRIPT = "/sharedvolume/check_updates.sh"


def start_process_with_command(command):
    """Start the subprocess with the specified command."""
    return subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def start_watchdog(proc, timeout_seconds, terminate_event):
    """Start a thread to terminate the process if it exceeds the timeout."""
    def monitor_process():
        start_time = time.time()
        while time.time() - start_time < timeout_seconds:
            if terminate_event.is_set():  # Check if the process has finished
                return
            time.sleep(5)  # Poll every 5 seconds to reduce CPU usage
        if proc.poll() is None:  # Process still running after timeout
            print(f"Timeout reached ({timeout_seconds}s). Terminating process...")
            proc.terminate()
            proc.kill()
    terminate_event = threading.Event()
    watchdog = threading.Thread(target=monitor_process)
    watchdog.start()
    return watchdog, terminate_event


def execute_command(proc):
    """Communicate with the process and fetch its output."""
    try:
        stdout, stderr = proc.communicate()
        return proc.returncode, stdout, stderr
    except subprocess.TimeoutExpired:
        proc.terminate()
        return 1, "", "Timeout expired. Process killed."


def log_result(return_code, stdout, stderr):
    """Log the result of the command execution."""
    if return_code != 0:
        logger.error(f"DCAP installation failed or timed out. Stdout: {stdout}, Stderr: {stderr}")
    else:
        logger.info(f"DCAP installation executed successfully! Output: {stdout}")


def install_newer_version_of_dcap(installer_script, timeout_seconds=3600):
    """
    Run a subprocess command to install a newer version of DCAP.
    Terminates the process if it exceeds the specified timeout.
    """
    hostname_ip = get_vm_ip()
    command = ['sudo', 'UTE_CLOUD=1', 'bash', installer_script, hostname_ip]
    proc = start_process_with_command(command)
    watchdog, terminate_event = start_watchdog(proc, timeout_seconds, None)
    try:
        return_code, stdout, stderr = execute_command(proc)
        terminate_event.set()  # Notify the watchdog that the process finished
    except Exception as e:
        return_code, stdout, stderr = 1, "", f"An error occurred: {e}"
    watchdog.join()
    log_result(return_code, stdout, stderr)
    return return_code, stdout, stderr


def get_vm_ip():
    """
        Gets the IP address of the current VM.
    """
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    return ip_address


def check_version_of_dcap_and_install_if_needed():
    """
        Checks DCAP version and installs the latest if needed.
    """
    cur_version_pattern = r'Currently\s+installed\s+version\s+:\s+(FB\d+.\d+)'
    lat_released_version_pattern = r'Latest\s+released\s+version\s+:\s+(FB\d+.\d+)'
    installer_script_pattern = r'downloaded\s+to\S+\s+(.*?\.sh)'
    if os.path.exists(DCAP_VER_CHECK_SCRIPT):
        result = subprocess.run(['bash', DCAP_VER_CHECK_SCRIPT], capture_output=True, text=True)
        dcap_current_version = re.search(cur_version_pattern, result.stdout).group(1)
        dcap_latest_released_version = re.search(lat_released_version_pattern, result.stdout).group(1)
        installer_script = re.search(installer_script_pattern, result.stdout).group(1)
        logger.info(f"Installed version of DCAP: {dcap_current_version}", also_console=True)
        if dcap_current_version != dcap_latest_released_version:
            logger.info(f"Installing DCAP newer version: {dcap_latest_released_version}...", also_console=True)
            install_newer_version_of_dcap(installer_script)
    else:
        logger.error(f"Provided path: {DCAP_VER_CHECK_SCRIPT} does not exists.")
