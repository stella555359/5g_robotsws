import os
import shutil
import glob
from lxml import etree
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru
from itertools import zip_longest
import io
import subprocess
import time


class ORANOperations:
    def __init__(self, ap_ip="192.168.200.1"):
        self.AP_IP = ap_ip

    def set_iphy_file_to_be_updated(self, input_folder=None, backup_folder='/home/ute/iphy_backup'):
        self.backup_folder = backup_folder
        self.input_folder = input_folder
        os.system("mkdir -p " + backup_folder)
        os.system("scp {0}:/ffs/run/simmode/iphy.xml {1} >/dev/null 2>&1".format(self.AP_IP, backup_folder))
        if input_folder is None:
            self.iphy_xml_path = os.path.join(self.backup_folder, 'iphy.xml')
        else:
            self.iphy_xml_path = os.path.join(self.input_folder, 'iphy.xml')
        return self.iphy_xml_path

    def execute_command_in_shell(self, command, console_output=True, timeout=0.5, filename="shell_output.log"):
        with io.open(filename, "w") as writer:
            process = subprocess.Popen(command, shell=True, executable="/bin/bash",
                                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            for line in process.stdout:
                try:
                    if isinstance(line, bytes):
                        line = line.decode("utf-8")
                    line = line.replace("�", "")
                    if console_output:
                        loguru.logger.opt(raw=True).info(f"> {line.lstrip()}")
                    else:
                        loguru.logger.debug(f"> {line.lstrip()}")
                    writer.write(line)
                except UnicodeDecodeError:
                    pass
            return_code = process.wait()
        return return_code

    def read_snapshot_filename_version(self):
        parser = etree.XMLParser(remove_blank_text=True)
        root = etree.parse(self.iphy_xml_path, parser).getroot()
        self.snapshot_file_names = [path.text for path in root.findall(".//NCSnapshotPath")]
        self.snapshot_list = list(map(lambda x: x.split('/ffs/run/simmode/')[1], self.snapshot_file_names))
        loguru.logger.info(f"snapshot file names in iphy.xml are {self.snapshot_list}")
        versions = [f"v{path.text}" for path in root.findall(".//OranVersion")]
        loguru.logger.info(f"oran version in iphy.xml are {versions}")
        for grp in zip_longest(self.snapshot_list, versions):
            if None in grp:
                raise Exception("Version or Snapshot Name not available for all entries")
        else:
            return self.snapshot_list, versions

    def download_snapshot(self, input_folder):
        self.snapshot_list, versions = self.read_snapshot_filename_version()
        if 'testsuite' in input_folder:
            loguru.logger.info("Snapshot files already downloaded in testsuite folder")
            return self.snapshot_list
        oran_clone_dir = self.clone_oran_repository(input_folder)
        for snapshot, version in zip(self.snapshot_list, versions):
            self.execute_command_in_shell(f"cp {oran_clone_dir}/{version}/{snapshot} {input_folder}")
            if not glob.glob(input_folder + "/" + snapshot):
                loguru.logger.error(f"Oran snapshot file {snapshot} is not downloaded")
                raise Exception(f"Snapshot file not found {snapshot}")
        return self.snapshot_list

    def clone_oran_repository(self, input_folder):
        gerrit_url = "ssh://gerrit-hzsl2.int.net.nokia.com:29418/MN/UTE/O-RAN"
        oran_clone_dir = os.path.join(input_folder, 'O-RAN')
        self.execute_command_in_shell(f'rm -rf {oran_clone_dir}')
        return_code = self.execute_command_in_shell('git -P clone ' + gerrit_url + ' ' + oran_clone_dir)
        if return_code != 0:
            loguru.logger.exception("Failed to clone O-RAN snapshots repository")
        return oran_clone_dir

    def snapshot_upload(self, snapshots):
        if any('simmode' in snapshot for snapshot in self.snapshot_file_names):
            loguru.logger.info("snapshot path in iphy.xml is as expected.")
        else:
            self.snapshot_path_change()
        for snapshot_file_name in snapshots:
            src_path = os.path.join(self.input_folder, snapshot_file_name)
            loguru.logger.info(f"uploading snapshot {snapshot_file_name} to AP")
            ret_code = self.execute_command_in_shell(f"scp {src_path} {self.AP_IP}:/ffs/run/simmode/ >/dev/null 2>&1")
            time.sleep(30)
            if ret_code != 0:
                loguru.logger.error("Failed to upload the snapshot data from host machine")
                raise Exception(f"Failed to upload {snapshot_file_name}")
        loguru.logger.info(f"Completed Snapshot Upload")

    def download_and_upload_snapshot(self, input_folder):
        loguru.logger.info("Downloading and uploading snapshot files")
        snapshot_list = self.download_snapshot(self.input_folder)
        self.snapshot_upload(snapshot_list)
        loguru.logger.info("Snapshot files downloaded and uploaded successfully")
        return self.snapshot_list

    def snapshot_path_change(self):
        parser = etree.XMLParser(remove_blank_text=True)
        root = etree.parse(self.iphy_xml_path, parser).getroot()
        ru_elements = root.findall(".//RE")
        if not ru_elements:
            loguru.logger.info("ERROR!! No RMODS found in iphy.xml"
                               "\nCheck if <resourceBuildKey> element is present for the Rmods in iphy.xml"
                               "\nERROR!! Iphy.xml will not be updated as part of AP install")
        sector = 1
        for ru_element, snapshot_file_name in zip_longest(ru_elements, self.snapshot_list):
            if None in (ru_element, snapshot_file_name):
                raise Exception("No of RUs in iphy.xml and Snapshot Data does not match")
            snapshot_path = f"/ffs/run/simmode/{snapshot_file_name}"
            nc_snapshot_path = ru_element.find(".//NCSnapshotPath")
            nc_snapshot_path.text = snapshot_path
            loguru.logger.info(f"iphy.xml file updated with NCSnapshotPath: {snapshot_path}")
            sector += 1
        iphy_str = etree.tostring(root, pretty_print=True, xml_declaration=True, encoding="UTF-8")
        try:
            with open(self.iphy_xml_path, "wb") as file:
                file.write(iphy_str)
        except Exception:
            loguru.logger.exception(f"Could not open file in path: {self.iphy_xml_path,}")
            return
        loguru.logger.info(f"Updated snapshot path in iphy.xml")
        return

    def download_rfm_plugin(self, filename):
        workspace = os.getenv('WORKSPACE', '/tmp')
        wft_rfm_download = ["https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN/",
                            "https://lterel.es-si-s3-z4.eecloud.nsn-net.net/RFM_PLUGIN/"]
        dest_path = f"{workspace}/rfm_plugin/"
        os.makedirs(dest_path, exist_ok=True)
        if os.path.exists(f"{dest_path}{filename}"):
            loguru.logger.info(f"{filename} RFM Plugin present in cache")
            return f"{dest_path}{filename}"
        else:
            self.execute_command_in_shell(f"mkdir -p {dest_path}", console_output=False)
            for link in wft_rfm_download:
                url = link + filename
                cmd = f"wget {url} -P {dest_path}"
                loguru.logger.info(f"cmd to download RFM file: {cmd}")
                self.execute_command_in_shell(cmd)
                if os.path.exists(f"{dest_path}{filename}"):
                    loguru.logger.info(f"Downloaded RFM file: {filename}")
                    return f"{dest_path}{filename}"
            loguru.logger.error(f"Failed to download RFM file: {filename}")
            raise Exception(f"RFM file {filename} not found in any of the provided links")


if __name__ == '__main__':
    print("Just a placeholder")
    oranObj = ORANOperations()
    # oranObj.set_iphy_file_to_be_updated('/home/ute/tl_custom_config/sim/')
    # oranObj.download_and_upload_snapshot('/home/ute/tl_custom_config/sim/')
    # oranObj.download_rfm_plugin('RFMPlugin_O-RU_FJ_TA08029-B311-01_0006.zip')
