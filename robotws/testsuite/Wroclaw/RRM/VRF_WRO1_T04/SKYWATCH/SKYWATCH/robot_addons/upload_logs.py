import subprocess
import os
# import shutil


def create_log_html(src):
    log_html_path = os.path.join(src, "log.html")
    report_html_path = os.path.join(src, "report.html")
    output_xml = os.path.join(src, "output.xml")
    cmd = "rebot --log " + log_html_path + " --report " + report_html_path + " --output NONE " + output_xml
    try:
        subprocess.Popen(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Error during creating log.html file: {e}")


def copy_directory_with_sudo(src, dest):
    try:
        subprocess.run(["sudo", "mkdir", "-p", dest], check=True)
        subprocess.run(["sudo", "cp", "-r", src, dest], check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Error during copying logs to rotta: {e}")


def software_cleanup(dest):
    try:
        subprocess.run(["rm", "-rf", dest], check=True)
        subprocess.run(["mkdir", "-p", dest], check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Error during removing softwares: {e}")
