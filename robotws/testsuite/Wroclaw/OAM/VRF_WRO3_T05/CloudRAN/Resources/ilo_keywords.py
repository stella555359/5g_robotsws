# ilo_keywords.py
"""
Robot Framework library for parallel iLO server operations.
Supports connecting to multiple iLOs, forcing a restart,
waiting, and then collecting iLO event logs.
"""

from threading import Thread
from taf.hw.hp import redfish
import time


def reset_servers_parallel(ip_list, username, password):
    """
    Resets multiple iLO servers in parallel and then retrieves logs after a wait.

    Args:
        ip_list (list): IP addresses of iLO servers
        username (str): iLO username
        password (str): iLO password

    Returns:
        dict: mapping IP -> list of iLO event logs
    """
    threads = []

    # Phase 1: Reset all servers in parallel
    def reset_worker(ip):
        rf = redfish.redfish()
        rf.connect_to(host=ip, username=username, password=password)
        rf.set_host_power_status("ForceRestart")
        rf.disconnect()  # Disconnect after sending restart

    for ip in ip_list:
        t = Thread(target=reset_worker, args=(ip,))
        threads.append(t)
        t.start()

    for t in threads:
        t.join()  # Wait for all resets to finish

    # Phase 2: Wait 30 seconds before collecting logs
    time.sleep(30)

    # Collect logs sequentially after all resets are done
    ilo_logs = {}
    for ip in ip_list:
        rf = redfish.redfish()
        rf.connect_to(host=ip, username=username, password=password)
        logs = rf.get_ilo_event_logs()
        ilo_logs[ip] = logs
        rf.disconnect()

    return ilo_logs
