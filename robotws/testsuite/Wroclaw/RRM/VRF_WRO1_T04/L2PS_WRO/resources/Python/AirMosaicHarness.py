__author__ = 'Mateusz Lesniak'
__owner_email__ = 'mateusz.lesniak@nokia.com'
__maintainer__ = 'Mateusz Lesniak'

import json
import os
import signal
import time
import psutil
import taf.ue.prisma_airmosaic.pymosaic_restapi as mosaic

from robot.api import logger
from robot.errors import ExecutionFailed
from zipfile import ZipFile
from os.path import basename
from testsuite.Wroclaw.RRM.L2PS_WRO.CB008141.resources.variables import *

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

    The following robot-variables MUST be defined for class to run:
        -  MOSAIC_PATH: Path to the directory with the Air Mosaic Harness executable
             e.g. MOSAIC_PATH = '/home/ute/Keysight/airmosaic/airmosaic_lteuu/bin/'

        -  CONFIG_ZIP_FILE: Path to the  configuration .zip file that will be created
             e.g. CONFIG_ZIP_FILE = 'testsuite/Wroclaw.RRM.L2PS_WRO/CB008141/resources/AirMosaicConfig' \
                  '/AirMosaic_configuration.zip'

        - SCENARIO_LOG: Path to the scenario logs file that will be created
             e.g. SCENARIO_LOG = '/home/ute/logs/scenario_log.json'

    :attrib string ROBOT_LIBRARY_SCOPE: Scope for creating object when robot framework import class as library.
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        logger.info('Run AirMosaic', also_console=True)
        self.process = mosaic.pymosaic.initLocalAirMosaic(MOSAIC_PATH)
        time.sleep(10)  # Waiting for program to initialize
        self.session_id = None

    @staticmethod
    def make_zip_configuration(config_zip_dir):
        """
        Creates a .zip archive from configuration files needed by the AirMosaic.
        .zip format is required by AirMosaicHarness API.
        """
        zip_obj = ZipFile(CONFIG_ZIP_FILE, 'w')
        for folderName, subfolders, filenames in os.walk(config_zip_dir):
            for filename in filenames:
                if 'zip' not in filename:
                    file_path = os.path.join(folderName, filename)
                    zip_obj.write(file_path, basename(file_path))
        zip_obj.close()

    @staticmethod
    def delete_zip_configuration():
        """
        Delete a .zip archive witch configuration files needed by the AirMosaic.
        """
        os.remove(CONFIG_ZIP_FILE)

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
        result = mosaic.pymosaic.storeZipArchive(self.session_id,
                                                 inzip=CONFIG_ZIP_FILE,
                                                 outzip="AirMosaic_configuration.zip")
        logger.info('Load configuration zip file  ' + str(result), also_console=True)

    def load_sid(self, sid_filename):
        """
        Load .sid configuration file contains simulation data.
        """
        result = mosaic.pymosaic.loadSid(self.session_id, sid_filename)
        logger.info('Load sid file  ' + str(result), also_console=True)

    def load_scenario(self, scenario_name):
        """
        Load .sce configuration file contains simulating-connection data.
        """
        result = mosaic.pymosaic.loadScenario(self.session_id, scenario_name)
        logger.info('Load scenario  ' + str(result), also_console=True)

    def connect_to_tstm(self):
        """
        Connects to the TSTM which results in setup should be OnAir.
        """
        result = mosaic.pymosaic.initializeTestManager(self.session_id)
        time.sleep(60)  # Waiting for TSTM to initialize
        logger.info('Connect to TSTM  ' + str(result), also_console=True)

    def start_scenario(self):
        """
        Run scenario specified in .sce file.
        """
        result = mosaic.pymosaic.startScenario(self.session_id)
        time.sleep(120)  # Waiting for scenario perform
        logger.info('Start scenario  ' + str(result), also_console=True)

    def collect_scenario_log_and_check_if_successful(self):
        """
        Collecting logs from scenario and check if attach and UDG was successful.
        """
        result = mosaic.pymosaic.getScenarioLogger(self.session_id)
        with open(SCENARIO_LOG, 'w') as outfile:
            json.dump(result, outfile)

    def stop_session(self):
        """
        Close active AirMosaic session.
        """
        result = mosaic.pymosaic.stopTestManager(self.session_id)
        logger.info('Stop session  ' + str(result), also_console=True)

    def start_session(self):
        """
        Start AirMosaic session.
        """
        result = mosaic.pymosaic.openTestSession()
        self.session_id = result['sessionId']
        logger.info('Run session  ' + str(result), also_console=True)
