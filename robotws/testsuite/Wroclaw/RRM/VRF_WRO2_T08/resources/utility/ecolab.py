import os


def disable_ecolab():
    cmd = 'sudo touch /etc/ute/disable_ecolab'
    os.system(cmd)
