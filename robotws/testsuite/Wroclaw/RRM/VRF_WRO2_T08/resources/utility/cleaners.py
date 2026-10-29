import subprocess


def clear_admin_api_logs(rootdir="/tmp"):
    cmd = r"find {} -maxdepth 1 -type f \( -name 'admin_api*' -o -name '*.ims2' \) -delete"
    subprocess.call(cmd.format(rootdir), shell=True)


def clear_tmp_if_needed():
    cmd = [element.encode() for element in ["sudo", "du", "-hs", "/tmp"]]
    tmp_disk_usage = subprocess.check_output(cmd).decode().split("\t")[0]
    if "G" in tmp_disk_usage and float(tmp_disk_usage[:-1]) > 8.0:
        subprocess.call(r"find /tmp -maxdepth 1 -type f -name 'SYSLOG*' -delete", shell=True)
