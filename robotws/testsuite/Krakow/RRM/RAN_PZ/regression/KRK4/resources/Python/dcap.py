"""
:copyright: Nokia Networks
:author: Beata Kapusta, Mateusz Pajor
:maintainer: Beata Kapusta, Mateusz Pajor
:contact: beata.kapusta@nokia.com, mateusz.pajor@nokia.com
:team:.RAN_PZ.regression.KRK4.SW_2_KRK_CntDlv_SG
"""

import os
import time

import netifaces as ni
import requests
from robot.libraries.OperatingSystem import OperatingSystem
from taf.sw.dcap.rd import rd

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console


class Dcap(object):
    """
    DCAP (UTF Lab) class

    Class uses taf library taf.sw.dcap.rd
    Link to the documentation: https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/stable/interfaces/interface.html
    """

    def __init__(self, host=None, port='9443', username=None, password=None,
                 rd_version='dcapv3', secure=True, alias=None):
        """
        :param host (str): IP of a VM where UTF Lab will be used
        :param port (str): port used to run UTF Lab
        :param username (str): username used to connect to UTF Lab
        :param password (str): password used to connect to UTF Lab
        :param rd_version (str):  RD version used in taf.sw.dcap.rd library
        :param secure (bool): If set to True, the connection will be realized with use https prefix, else with http,
        default value is False.
        :param alias (str): alias
        """
        self.host = self._get_vm_ip() if not host else host
        self.port = port
        self.username = username
        self.password = password
        self.repository_url = (
            "https://artifactory-espoo2.int.net.nokia.com/artifactory/"
            "dcap-lite-binaries-local/dcap-basic/releases"
        )
        self.api_url = (
            "https://artifactory-espoo2.int.net.nokia.com/artifactory/api/storage/"
            "dcap-lite-binaries-local/dcap-basic/releases"
        )
        self.rd_version = rd_version
        self.secure = secure
        self.alias = alias
        self.rd = rd()

    @staticmethod
    def _get_vm_ip():
        """
        Get VM IP from eth0
        :return: VM IP address
        """
        addresses = ni.ifaddresses('eth0')[ni.AF_INET]
        vm_ip = addresses[0]['addr']
        return vm_ip

    def _latest_version(self):
        """
        Get the latest version of UTF Lab installation file from Artifactory
        :return: latest version of UTF Lab
        """
        response = requests.get(self.api_url)
        directories = response.json()['children']
        latest = max(release['uri'] for release in directories)
        logger_console("No version provided. Taking the latest one: {}".format(latest))
        # URI has a leading slash, hence the lstrip.
        return latest.lstrip("/")

    @staticmethod
    def _update_symbolic_links():
        """
        Update symbolic links on VM
        """
        OperatingSystem().run("sudo rm -rf /var/lib/docker && sudo ln -s /home/docker/ /var/lib/docker")

    @staticmethod
    def _check_if_dcap_script_on_vm(path):
        """
        Check if UTF Lab is downloaded to home directory on VM
        :return: result if path exists or not
        """
        return os.path.exists(path)

    def _download_dcap(self, version, filename, path):
        """
        Download UTF Lab installation file to home directory of VM
        :param version (str): UTF Lab version that should be downloaded
        :param filename (str): name of the UTF Lab script file
        :param path (str): path where script will be downloaded
        """
        logger_console("Downloading UTF lab")
        cmd = "wget {rel_url}/{ver}/{filename} -O {path}".format(rel_url=self.repository_url, ver=version,
                                                                 filename=filename, path=path)
        OperatingSystem().run(cmd)
        logger_console("Downloading UTF lab finished.")

    def install_dcap(self):
        """
        Install UTF Lab on the VM and downloads UTF Lab installation file if its not already in home directory of VM
        """
        self._update_symbolic_links()
        version = self._latest_version()
        filename = "dcap_basic_installer.{ver}.sh".format(ver=version)
        path = os.path.join(os.path.expanduser("~"), filename)
        file_exists = self._check_if_dcap_script_on_vm(path)
        if file_exists:
            logger_console("UTF lab installation file is already downloaded on VM. Skipping download.")
        else:
            self._download_dcap(version, filename, path)
        logger_console("Installing UTF lab...")
        cmd = "sudo UTE_CLOUD=1 bash {path} {vm_ip}".format(path=path, vm_ip=self.host)
        rc, output = OperatingSystem().run_and_return_rc_and_output(cmd)
        assert "SUCCESS: UTF Lab {ver} installed".format(ver=version) in str(output), "UTF Lab Installation Failed."
        logger_console("UTF lab {} Installed.".format(version))

    @staticmethod
    def start_dcap_basic_controller():
        """
        Starting UTF Lab using DCAP_Basic_controller command which is installed by default on UTE Cloud VMs
        Link to the documentation: https://confluence.ext.net.nokia.com/display/DCAPBASIC/DCAP+Basic+in+UTE
        """
        logger_console("Starting UTF Lab...")
        cmd = "utf_lab-controller start"
        rc, output = OperatingSystem().run_and_return_rc_and_output(cmd)
        failed_output = "UTF Lab starting Failed. Print 'All UTF Lab containers started successfully.' is missing " \
                        "in output of DCAP_Basic_controller command"
        assert "All UTF Lab containers started successfully." in str(output), failed_output
        logger_console("UTF_Basic_controller started successfully, wait 60s for containers up...")
        time.sleep(60)

    @staticmethod
    def stop_dcap_basic_controller():
        """
        Stopping UTF Lab using DCAP_Basic_controller command which is installed by default on UTE Cloud VMs
        Link to the documentation: https://confluence.ext.net.nokia.com/display/DCAPBASIC/DCAP+Basic+in+UTE
        """
        logger_console("Stopping UTF Lab...")
        cmd = "utf_lab-controller stop"
        rc, output = OperatingSystem().run_and_return_rc_and_output(cmd)
        failed_output = "UTF Lab stopping Failed. Print 'All UTF Lab containers stopped successfully.' " \
                        "is missing in output of DCAP_Basic_controller command"
        assert "All UTF Lab containers stopped successfully." in str(output), failed_output
        logger_console("UTF_Basic_controller stopped successfully")

    @staticmethod
    def restart_dcap_basic_controller():
        """
        Restarting UTF Lab using utf_Basic_controller command which is installed by default on UTE Cloud VMs
        """
        logger_console("Restarting UTF Lab...")
        cmd = "utf_lab-controller restart"
        rc, output = OperatingSystem().run_and_return_rc_and_output(cmd)
        failed_output = "UTF Lab restarting Failed. Print 'All UTF Lab containers restarted successfully.' " \
                        "is missing in output of DCAP_Basic_controller command"
        time.sleep(120)  # After run command utf_lab-controller restart there is need to wait additional time
        assert "All UTF Lab containers restarted successfully." in str(output), failed_output
        logger_console("UTF_Basic_controller restarted successfully")

    def create_dcap_session(self):
        """
        Create UTF Lab session that is necessary for basic actions
        """
        self.rd.connect_to(host=self.host, port=self.port, username=self.username, password=self.password,
                           rd_version=self.rd_version, secure=self.secure, alias=self.alias)

    def create_bts_in_dcap(self, ip='10.0.1.2', port='443', username='Nemuadmin', password='nemuuser',
                           bts_alias='target_bts', timeout=30):
        """
        :param ip: (str) IP of BTS that should be added
        :param port: (str) port for connection to UTF Lab
        :param username: (str) username to authenticate the BTS
        :param password: (str) password to authenticate the BTS
        :param bts_alias: (str) alias for bts
        :param timeout: (int) timeout for adding bts
        """
        self.rd.create_bts(host=ip, port=port, username=username, password=password, bts_alias=bts_alias,
                           connection=self.alias, timeout=timeout)

    def edit_bts_in_dcap(self, bts_id='1', ip='10.0.1.2', port='443', username='Nemuadmin', password='nemuuser',
                         bts_alias='target_bts', lte_cells=None, nr_cells=None):
        """
        :param bts_id: (str) id of BTS to edit
        :param ip: (str) IP of BTS that should be added
        :param port: (str) port for connection to UTF Lab
        :param username: (str) username to authenticate the BTS
        :param password: (str) password to authenticate the BTS
        :param bts_alias: (str) alias for bts
        :param lte_cells: (str) sets lte_cells
        :param nr_cells: (str) sets nr_cells
        """
        self.rd.edit_bts(bts_id, host=ip, port=port, username=username, password=password,
                         bts_alias=bts_alias, lte_cells=lte_cells, nr_cells=nr_cells, connection=self.alias)

    def delete_bts_from_dcap(self, bts_id='1'):
        """
        Delete BTS under UTF Lab
        :param bts_id: (str) id of BTS to delete
        """
        self.rd.delete_bts(bts_id=bts_id, connection=self.alias)

    def check_if_bts_is_configured_in_dcap(self, ip='10.0.1.2', **kwargs):
        """
        Check if BTS is configured and if not it creates BTS under UTF Lab
        """
        bts = self.get_dcap_bts_id(ip=ip)
        if bts:
            logger_console("BTS is created in UTF Lab. Skipping BTS configuration.")
        else:
            logger_console("Creating BTS in UTF Lab")
            self.create_bts_in_dcap(ip=ip, **kwargs)

    def get_all_bts_info(self):
        """
        Get all information about BTS configured under UTF Lab
        :return: dict with BTS information like id, alias name
        """
        return self.rd.get_all_bts_info(connection=self.alias)

    def get_dcap_bts_id(self, ip='10.0.1.2'):
        """
        Get added under UTF Lab BTS id
        :param ip: (str) IP of BTS
        :return: added under UTF Lab BTS id
        """
        dcap_bts_info = self.get_all_bts_info()
        for bts in dcap_bts_info:
            if ip in bts.values():
                return bts['id']

    def get_5g_profiles(self):
        """
        Get all 5G profiles info under UTF Lab
        :return: dict with 5G profiles info
        """
        return self.rd.get_5g_profiles()

    def start_new_trace(self, bts_details, wait_for_start=True, **kwargs):
        """
        Start new trace under UTF Lab. To start new trace trace profile is needed.
        More information about profiles:
        https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/stable/interfaces/interface.html#taf.sw.dcap.rd. \
        interface.rd.start_trace
        :param bts_details: (list) list of bts details containing host, username, password and port number, required
        to start the trace
        :param wait_for_start: (bool) parameter used to confirm that traces are started and it is in "running" state
        :return: started trace id
        """
        logger_console("Starting collecting UTF Lab logs")
        trace_id = self.rd.start_trace(bts=bts_details, wait_for_activation=wait_for_start, **kwargs)
        return trace_id

    def stop_trace(self, ip='10.0.1.2', trace_id=None):
        """
        Stop running trace
        :param ip: (str) IP of BTS
        :param trace_id: (dict) dictionary with id of trace
        :return: dict with operation information
        """
        logger_console("Stopping collecting UTF Lab logs")
        if trace_id is None:
            last_trace_id = self.get_last_trace_id(ip=ip)
        else:
            last_trace_id = trace_id['tracer_id']
        result = self.rd.stop_trace(trace_id=last_trace_id, connection=self.alias)
        return result

    def get_last_trace_id(self, ip='10.0.1.2'):
        """
        Get last trace id. Raises exception where there is no trace id.
        :param ip: (str) IP of BTS
        :return: last trace id
        """
        last_trace_id = None
        trace_infos = self.rd.get_all_trace_info(connection=self.alias)
        for trace_info in trace_infos:
            if "targets" in trace_info.keys():
                for target in trace_info["targets"]:
                    if ip == target["host"]:
                        last_trace_id = trace_info['id']
                        break
        if last_trace_id:
            return last_trace_id
        else:
            raise ValueError("No trace id for IP in target. Check if logs collection has started.")

    def get_trace_status(self, trace_id):
        """
        :param trace_id: (str) last trace id
        :return: UTF Lab trace status
        """
        return self.rd.get_trace_info_by_id(trace_id=trace_id, connection=self.alias)

    def get_result_file(self, target_dir, ip='10.0.1.2', trace_id=None):
        """
        Download UTF Lab log result file to target directory
        :param target_dir: (str) target directory where file will be downloaded
        :param ip: (str) IP of BTS
        :param trace_id: (dict) dictionary with id of trace
        :return: path where logs were downloaded
        """
        if trace_id is None:
            self.wait_for_state(ip=ip)
            last_trace_id = self.get_last_trace_id(ip=ip)
        else:
            self.wait_for_state(trace_id=trace_id)
            last_trace_id = trace_id['tracer_id']
        file_path = self.rd.get_results(result_id=last_trace_id, target_dir=target_dir)
        return logger_console("UTF Lab logs downloaded to {}".format(file_path))

    def wait_for_state(self, retry=20, retry_interval=15, ip='10.0.1.2', trace_id=None):
        """
        Wait for ready state of log collecting to start downloading log file.
        Raises exception if UTF Lab logs aren't in ready state.
        :param retry: (int) number of retries
        :param retry_interval: (int) retry interval
        :param ip: (str) IP of BTS
        :param trace_id: (dict) dictionary with id of trace
        """
        logger_console("Waiting for UTF Lab logs to be ready")
        if trace_id is None:
            last_trace_id = self.get_last_trace_id(ip=ip)
        else:
            last_trace_id = trace_id['tracer_id']
        while retry > 0:
            retry -= 1
            trace_info = self.get_trace_status(trace_id=last_trace_id)
            if trace_info['status'] in ["ready", "readyWithWarnings"]:
                break
            time.sleep(retry_interval)
        else:
            raise Exception("UTF Lab logs are not in ready state!")
