import os
import signal
import psutil


def send_sigterm_to_agent_robot():
    for proc in psutil.process_iter(['pid', 'name']):
        if 'agent_robot' in proc.info['name']:
            os.kill(proc.info['pid'], signal.SIGTERM)
            return f"SIGTERM sent to process {proc.info['name']} with PID {proc.info['pid']}"
    return "No process with 'agent_robot' in its name found"


def print_all_processes():
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        print(proc.info)
