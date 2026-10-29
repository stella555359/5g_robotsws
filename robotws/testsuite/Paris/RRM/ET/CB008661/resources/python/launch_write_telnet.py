import subprocess


def launch_write_telnet(path_scenario, path_output):
    subprocess.Popen(["sudo", "python",
                      "/home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/CB008661/resources/python/writeTelnet.py",
                      path_scenario,
                      path_output])
