__author__ = 'Mateusz Lesniak'
__owner_email__ = 'mateusz.lesniak@nokia.com'
__maintainer__ = 'Mateusz Lesniak'

import os
import time
import json
import signal
import subprocess
from zipfile import ZipFile

import psutil
from robot.api import logger
from robot.errors import ExecutionFailed
import taf.ue.prisma_airmosaic.pymosaic as mosaic
try:
    # For Python 3.0 and later
    from urllib.error import URLError
    from urllib.request import urlopen, Request
    from http.client import BadStatusLine
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen, Request, URLError
    from httplib import BadStatusLine


class AirMosaicHarness:
    """
    A class used to AirMosaicHarness API integration using taf.ue.prisma_airmosaic library.
    More info: https://docs.taf.nsn-rdnet.net/taf.ue.prisma_airmosaic/0.1.3/1/pymosaic_restapi/

    :attrib string ROBOT_LIBRARY_SCOPE: Scope for creating object when robot framework import class as library.
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, mosaic_path, config_zip_file, scenario_logs):
        logger.info('Run AirMosaic', also_console=True)
        self.mosaic_path = mosaic_path
        self.config_zip_file = config_zip_file
        self.scenario_logs = scenario_logs
        try:
            self.process = subprocess.Popen(
                self.mosaic_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                shell=False)
            logger.info(f"Air Mosaic pid: {self.process.pid}", also_console=True)
            time.sleep(10)  # Waiting for program to initialize
        except FileNotFoundError:
            logger.info(f'Incorrect path to airmosaic.\n {mosaic_path}', also_console=True)
        except NotADirectoryError:
            logger.info(f'Incorrect path to airmosaic.\n {mosaic_path}', also_console=True)

    def make_zip_configuration(self, config_zip_dir):
        """
        Creates a .zip archive from configuration files needed by the AirMosaic.
        .zip format is required by AirMosaicHarness API.
        """
        zip_obj = ZipFile(self.config_zip_file, 'w')
        for folderName, subfolders, filenames in os.walk(config_zip_dir):
            for filename in filenames:
                if 'zip' not in filename:
                    file_path = os.path.join(folderName, filename)
                    zip_obj.write(file_path, os.path.basename(file_path))
        zip_obj.close()

    def delete_zip_configuration(self):
        """
        Delete a .zip archive witch configuration files needed by the AirMosaic.
        """
        os.remove(self.config_zip_file)

    def close_air_mosaic(self, sig=signal.SIGTERM, include_parent=True, timeout=None, on_terminate=None):
        """
        Kill AirMosaic program and all its processes.

        :param signal sig: Type of signal send to process.
        :param bool include_parent: Also kills processes parent to that given.
        :param int timeout: The number of seconds the function waits for the process to die.
        :param function on_terminate: if specified, is a callback function which is
        called as soon as a child terminates.
        :return: tuple: Return (gone, still_alive) processes tuple.
        """
        assert self.process.pid != os.getpid(), "won't kill myself"
        parent = psutil.Process(self.process.pid)
        children = parent.children(recursive=True)
        if include_parent:
            children.append(parent)
        for p in children:
            try:
                p.send_signal(sig)
            except psutil.NoSuchProcess:
                pass
        gone, alive = psutil.wait_procs(children, timeout=timeout,
                                        callback=on_terminate)
        return gone, alive

    def disable_cell_control(self):
        """
        Disable cell control in AirMosaic.
        """
        headers = {
            'Content-Type': 'application/json'
        }
        socket_address = 'localhost'
        socket_port = '8090'
        airmosaic_cmd = json.dumps({"cellcontrol": "false", "ppucontrol": "false"})
        req = Request('http://%s:%s/harness/testerMode/%s' % (socket_address, socket_port, self.session_id),
                      airmosaic_cmd.encode('utf-8'), headers)
        try:
            res = urlopen(req, timeout=30).read().decode('utf-8')
            logger.info('Disable cell control' + str(json.loads(res)), also_console=True)
            return json.loads(res)
        except URLError as pe_err:
            return {'result': 'failed', 'error': str(pe_err.reason)}
        except Exception as pe_err:
            return {'result': 'failed', 'error': str(pe_err)}

    def load_configuration_files(self):
        """
        Load archived configuration files into current AirMosaic Session.
        """
        result = mosaic.storeZipArchive(self.session_id,
                                        inzip=self.config_zip_file,
                                        outzip="AirMosaic_configuration.zip")
        logger.info('Load configuration zip file  ' + str(result), also_console=True)

    def load_sid(self, sid_filename):
        """
        Load .sid configuration file contains simulation data.
        """
        result = mosaic.loadSid(self.session_id, sid_filename)
        logger.info('Load sid file  ' + str(result), also_console=True)

    def load_scenario(self, scenario_name):
        """
        Load .sce configuration file contains simulating-connection data.
        """
        result = mosaic.loadScenario(self.session_id, scenario_name)
        logger.info('Load scenario  ' + str(result), also_console=True)

    def connect_to_tstm(self):
        """
        Connects to the TSTM which results in setup should be OnAir.
        """
        result = mosaic.initializeTestManager(self.session_id)
        time.sleep(60)  # Waiting for TSTM to initialize
        logger.info('Connect to TSTM  ' + str(result), also_console=True)

    def start_scenario(self):
        """
        Run scenario specified in .sce file.
        """
        result = mosaic.startScenario(self.session_id)
        time.sleep(120)  # Waiting for scenario perform
        logger.info('Start scenario  ' + str(result), also_console=True)

    def collect_scenario_log_and_check_if_successful(self):
        """
        Collecting logs from scenario and check if attach and UDG was successful.
        """
        result = mosaic.getScenarioLogger(self.session_id)
        with open(self.scenario_logs, 'w') as outfile:
            json.dump(result, outfile)
        if result['result'] == 'success':
            logs = result['logRecords']
            attach = False
            udg = False
            nsa = False
            for elem in logs:
                if elem['message'] == 'UE Attached':
                    attach = True
                if elem['message'] == 'ProfileName=SGNBAddition:UEMNG-5gnsa_sgnb_addition_cmpl ' \
                                      'PRC-ID=1_1_0_3_sgnb_addition':
                    nsa = True
                if elem['message'] == 'UDG successful':
                    udg = True
            if not attach or not udg or not nsa:
                logger.info('UE Attached  ' + str(attach), also_console=True)
                logger.info('ProfileName=SGNBAddition  ' + str(nsa), also_console=True)
                logger.info('UDG successful  ' + str(udg), also_console=True)
                raise ExecutionFailed("Scenario error - Missing message (UE, UDG or 5gnsa) in scenario log file.")
        else:
            raise ExecutionFailed("Scenario failed to run.")

    def stop_session(self):
        """
        Close active AirMosaic session.
        """
        result = mosaic.stopTestManager(self.session_id)
        logger.info('Stop session  ' + str(result), also_console=True)

    def start_session(self):
        """
        Start AirMosaic session.
        """
        result = mosaic.openTestSession()
        logger.info(str(result), also_console=True)
        self.session_id = result['sessionId']
        logger.info('Run session  ' + str(result), also_console=True)
