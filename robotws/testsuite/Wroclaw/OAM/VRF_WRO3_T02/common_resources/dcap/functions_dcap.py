import subprocess
import os
from robot.api import logger
from taf.sw.dcap.rd import rd
import zipfile
import glob
from datetime import datetime
import shutil
import paramiko
import requests


class DCAPInstaller(object):

    def __init__(self, version=None):
        self.RELEASES_URL = (
            "https://artifactory-espoo2.int.net.nokia.com/artifactory/"
            "dcap-lite-binaries-local/dcap-basic/releases"
        )
        self.API_URL = (
            "https://artifactory-espoo2.int.net.nokia.com/artifactory/api/storage/"
            "dcap-lite-binaries-local/dcap-basic/releases"
        )
        self.version = self._latest_version() if not version else version

    def _latest_version(self):
        response = requests.get(self.API_URL)
        directories = response.json()['children']
        latest = max(release['uri'] for release in directories)
        logger.info("No version provided. Taking the latest one: {}".format(latest), also_console=True)
        # URI has a leading slash, hence the lstrip.
        return latest.lstrip("/")

    @staticmethod
    def _update_symbolic_links():
        process = subprocess.Popen("sudo rm -rf /var/lib/docker && sudo ln -s /home/docker/ /var/lib/docker",
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   shell=True)
        process.wait()
        logger.info("Resetting symlinks...", also_console=True)

    def _download_dcap(self):
        logger.info("Downloading dcap {ver}...".format(ver=self.version), also_console=True)
        filename = "dcap_basic_installer.{ver}.sh".format(ver=self.version)
        path = os.path.join(os.path.expanduser("~"), filename)
        cmd = "wget {rel_url}/{ver}/{filename} -O {path}".format(rel_url=self.RELEASES_URL, ver=self.version,
                                                                 filename=filename, path=path)
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
        output, _ = process.communicate()
        process.wait()
        assert "saved" in str(output), "Downloading failed."
        logger.info("Downloading finished.", also_console=True)
        return path

    def run(self, vm_ip):
        self._update_symbolic_links()
        path = self._download_dcap()
        logger.info("Installing dcap...", also_console=True)
        cmd = "sudo UTE_CLOUD=1 bash {path} {vm_ip}".format(path=path, vm_ip=vm_ip)
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
        output, error = process.communicate()
        process.wait()
        if "SUCCESS: DCAP Basic {ver} installed".format(ver=self.version) in str(output):
            logger.info("DCAP {} Installed.".format(self.version), also_console=True)
        else:
            logger.info("DCAP Installation Failed.", also_console=True)
            logger.warn("DCAP Installation Failed.", html=True)
            logger.info(output, also_console=True)


def install_dcap(vm_ip, version=None):
    di = DCAPInstaller(version=version)
    di.run(vm_ip=vm_ip)


def dcap_extract_logs(log_name, path):
    with zipfile.ZipFile("{}.zip".format(path), 'r') as zf:
        zf.extractall(path)
    collect_dcap_logs(path)
    new_filepath = extract_log(log_name, path)
    shutil.rmtree(path)
    return new_filepath


def collect_dcap_logs(path):
    new_name = os.path.basename(path)
    logs_path = "{}/logs".format(path)
    zip_path = os.path.join(os.path.dirname(path), "dcap_logs_{}".format(new_name))
    with zipfile.ZipFile("{}.zip".format(zip_path), "w") as zf:
        for _, _, filenames in os.walk(logs_path):
            for filename in filenames:
                filepath = os.path.join(logs_path, filename)
                zf.write(filepath, os.path.basename(filepath))


def extract_log(log_name, path):
    path = os.path.normpath(path)
    # now = datetime.now().strftime("%Y%m%d")
    filepath = None
    # for f in glob.glob(glob.escape(path) + '/**/{}*{}*.*'.format(now, log_name), recursive=True):
    #     filepath = f
    for f in glob.glob(glob.escape(path) + '/**/*{}*.*'.format(log_name), recursive=True):
        filepath = f
    try:
        new_path = os.path.join(os.path.split(path)[:-1][0], os.path.basename(filepath))
    except TypeError as e:
        raise Exception("Unable to find logfile in the archive. Error: {}".format(e))
    new_filepath = os.path.join(os.path.dirname(new_path), os.path.basename(path)) + os.path.splitext(new_path)[1]
    os.rename(filepath, new_path)
    os.remove("{}.zip".format(path))
    logger.info(new_filepath, also_console=True)
    os.rename(new_path, new_filepath)
    return new_filepath


def extract_ims2(snapshot_path):
    path = os.path.splitext(snapshot_path)[0]
    with zipfile.ZipFile(snapshot_path, 'r') as zf:
        zf.extractall(path)
    for f in glob.glob("{}/*".format(path)):
        if f.endswith("ims2"):
            os.rename(f, os.path.join(os.path.dirname(path), os.path.basename(f)))
    shutil.rmtree(path)


def check_log(f_path):
    prefix = ""
    with open(f_path, "r") as f:
        content = "".join(f.readlines())
        if "SUCCESS: DCAP Basic" in content:
            prefix = "S"
        elif "ERROR: DCAP Basic installation failed" in content:
            prefix = "F"

    return prefix


def send_dcap_logs(host="10.42.158.24", user="ute", password="Ut3pa5s#1be1"):
    vm_name = os.uname()[1]
    files = []
    for f in glob.glob("{}/*-install-*.log".format(os.getcwd())):
        files.append(f)

    if len(files) == 0:
        raise Exception("No DCAP logs found.")

    with paramiko.SSHClient() as ssh:
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        log_dir = datetime.now().strftime("%m-%d-%Y-%H:%M:%S")
        dir = ["dcap_logs", vm_name, log_dir]
        for f in files:
            status = ""
            if "DCAP-Basic" in f:
                status = check_log(f)
            f_name = os.path.basename(f)
            if status:
                f_name = "{}_{}".format(status, f_name)
            for i, _ in enumerate(dir):
                d = "/home/ute/{}".format("/".join(dir[:i+1]))
                try:
                    sftp.stat(d)
                except IOError:
                    sftp.mkdir(d)
            remote_f = "{}/{}".format(d, f_name)
            logger.warn("Sending DCAP Log {} to {} on {}".format(f, remote_f, host))
            sftp.put(f, remote_f)


def find_bts_id_by_host_address(all_bts_info, host_ip="192.168.255.129"):
    bts = list(filter(lambda _bts: _bts.get("host") == host_ip, all_bts_info))[0]
    return bts.get("id")
