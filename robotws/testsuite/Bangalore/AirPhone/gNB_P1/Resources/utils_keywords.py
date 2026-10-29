import os
import sys
import subprocess


def get_base_hostname():
    hostname = subprocess.check_output("hostname", shell=True)
    hostname = hostname.decode('UTF-8')
    hostname = hostname.strip()
    hostname = hostname.replace("-", "_")
    if hostname[-2] == "_":
        hostname = "_".join(hostname.split("_")[:-1])
    return hostname
