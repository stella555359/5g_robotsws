import os
import sys
if sys.version_info < (3, 3):
    import urllib
else:
    import urllib.request
import urllib
import errno
import logging
from taf.sbts.oam.coam.admin import admin
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from robot.api import logger


def check_alarm_occurs(alarm_list, expected_fault_id):
    if expected_fault_id in [str(alarm['faultId']) for alarm in alarm_list]:
        return True
    else:
        return False


def return_fault_ids(alarm_list):
    return [str(alarm['faultId']) for alarm in alarm_list]


def get_type(bts_info, module):
    modules = {'SMOD': 'systemModules', 'BBMOD': 'basebandModules'}
    product_name = bts_info[str(modules[module])][0]['productName']
    return product_name.split()[0]


def prepare_sw_name_to_dl(enb_build):
    if '5G' in enb_build:
        return 'AirScale-{}.zip'.format(enb_build.split('_')[1])
    elif ("SBTS00_" in enb_build) \
            or ("SBTS22R1_" in enb_build) \
            or ("SBTS22R2_" in enb_build) \
            or ("SBTS22R3_" in enb_build):
        return '{}_release_BTSSM_downloadable_A54.zip'.format(enb_build)


def download_file_from_artifactory(enb_build, sw_to_download, download_dir):
    if not os.path.isdir(download_dir):
        os.mkdir(download_dir)
    elif 'SBTS00_' in enb_build:
        artifactory = \
            'http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/'
        url = artifactory + sw_to_download
    elif 'SBTS22R1_' in enb_build:
        artifactory = \
            'http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS22R1/'
        url = artifactory + sw_to_download
    elif 'SBTS22R2_' in enb_build:
        artifactory = \
            'http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS21B/'
        url = artifactory + sw_to_download
    elif 'SBTS22R3_' in enb_build:
        artifactory = \
            'http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS21B/'
        url = artifactory + sw_to_download

    logger.info('URL for build download: {}'.format(url))
    _file = os.path.join(download_dir, sw_to_download)

    if sys.version_info < (3, 3):
        urllib.urlretrieve(url, _file)
    else:
        urllib.request.urlretrieve(url, _file)

    if os.path.isfile(_file):
        return _file
    else:
        raise IOError(errno.ENOENT, 'File not found', _file)


class Bts(object):
    def __init__(self, m_plane_ip):
        self.m_plane_ip = m_plane_ip
        self.output = None

    def open_coam_session(self):
        api = admin()
        self.connection = api.connect_to(bts_host='{}'.format(self.m_plane_ip), release=Env.ADMIN_CONNECT_STREAM)

    def teardown_coam_session(self):
        self.connection.disconnect()

    def update_gnb_sharing_ratio(self, dist_name, param_name, max_sr, min_sr, enb_build):
        if param_name == "lteNrDssDlRatio" and (("SBTS00_" in enb_build) or ("SBTS21B_" in enb_build)):
            parameters = [
                {
                    "parameterName": param_name,
                    "operation": "update",
                    "value": [
                        {
                            "dlResourceSharingAlgo": "DL PRB load based",
                            "maxNrDssRatio": max_sr,
                            "minNrDssRatio": min_sr,
                        }
                    ]
                }
            ]
        else:
            parameters = [
                {
                    "parameterName": param_name,
                    "operation": "update",
                    "value": [
                        {
                            "maxNrDssRatio": max_sr,
                            "minNrDssRatio": min_sr,
                        }
                    ]
                }
            ]
        self.connection.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameters,
            operation="update"
        )

    def update_nsaDrbParam_list_parameter(self, dist_name, ulDataPath, nsa3xBearerAllowed):
        parameters = [
                        {
                            "parameterName": "nsaDrbParam",
                            "operation": "update",
                            "value": [
                                {
                                    "actPrioritizeX2AfterInactivity": "true",
                                    "dlDataSplitBufferBuildUpThreshold": 5,
                                    "dlDataSplitBufferBuildUpThresholdPrioritizeX2": 5,
                                    "dlDataSplitGainThreshold": 5,
                                    "dlDataSplitMode": "dlOverF1UX2U",
                                    "inactivityThresholdForPrioritizeX2": 300,
                                    "inactivityThresholdForRestartPrioritizeX2": 100,
                                    "initialDLTrafficRouting": "initDLoverX2U",
                                    "nsa3xBearerAllowed": nsa3xBearerAllowed,
                                    "prioritizeX2Period": 500,
                                    "ulDataPath": ulDataPath,
                                    "ulDataSplitThreshold": "infinity"
                                }
                            ]
                        }
        ]
        self.connection.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameters,
            operation="update"
        )

    def update_list_of_parameters(self, dist_name, parameter, values):
        parameters = [
            {
                "parameterName": parameter,
                "operation": "update",
                "value": [
                    values
                ]
            }
        ]
        self.connection.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameters,
            operation="update"
        )

    def update_parameter(self, param_name, dist, value, activate=True):
        self.connection.perform_parameter_recommissioning(dist_name=dist,
                                                          parameter=param_name,
                                                          value=value,
                                                          operation="update",
                                                          should_activate=activate)

    def update_parameter_number(self, param_name, dist, value, activate=True):
        self.connection.perform_parameter_recommissioning(dist_name=dist,
                                                          parameter=param_name,
                                                          value=int(value),
                                                          operation="update",
                                                          should_activate=activate)

    def update_gnb_channel_bw(self, dist_name, dl, ul):
        parameters = [
                        {
                            "parameterName": "chBwDl",
                            "operation": "update",
                            "value": dl
                        },
                        {
                            "parameterName": "chBwUl",
                            "operation": "update",
                            "value": ul
                        }
                     ]
        self.connection.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameters,
            operation="update"
        )

    def update_enb_channel_bw(self, dist_name, dl, ul):
        parameters = [
            {
                "parameterName": "dlChBw",
                "operation": "update",
                "value": dl
            },
            {
                "parameterName": "ulChBw",
                "operation": "update",
                "value": ul
            }
        ]
        self.connection.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameters,
            operation="update"
        )

    def log_current_sw_version(self):
        logging.info(self.connection.get_sw_version())

    def get_current_sw_version(self):
        return self.connection.get_sw_version()


def check_alarms_and_raise_exception(alarm_list):
    for alarm in alarm_list:
        if alarm['faultId'] not in [61524, 61649, 6450, 4654, 4655, 4038, 61652]:
            logging.error(alarm)
            raise Exception('Unexpected alarm encountered')


def check_alarm_in_list(alarm_list, alarm_id):
    if alarm_id not in [str(alarm['faultId']) for alarm in alarm_list]:
        raise Exception('Alarm {} was not raised'.format(alarm_id))


def check_cells_onair(cell_list):
    for cell in cell_list:
        if cell["parameters"]["stateInfo"]["availabilityStatus"] != 'Online':
            raise Exception('Cell {} is not online!'.format(cell["distName"]))


def check_cells_offline(cell_list):
    for cell in cell_list:
        if cell["parameters"]["stateInfo"]["availabilityStatus"] != 'Offline':
            raise Exception('Cell {} is not offline!'.format(cell["distName"]))


def check_that_every_cells_on_air_state(cells_info,  cell_type):
    """
    Function checks in cells_info that avery single cell is on air depends on type 5G or LTE
    :param cells_info: info about all cells took from BTS (string)
    :param cell_type: BTS cell type lte or nr (5G)
    :return: True if all cells have values like in on_air_state_dict, False if not
    """
    if cell_type == 'nr':
        bts = Bts('192.168.255.129')
        bts.open_coam_session()
        sw_ver = bts.connection.get_sw_version()
        bts.teardown_coam_session()
        if 'SBTS' in sw_ver:
            on_air_state_dict = {
                'usageState': 'Active',
                'proceduralStatus': 'configured',
                'barringStatus': 'unbarred',
                'availabilityStatus': 'Online',
                'administrativeState': 'Unlocked',
                'operationalState': 'Enabled',
                'blockingState': 'Unblocked'}
        else:
            on_air_state_dict = {
                'administrativeState': 'Unlocked',
                'usageState': 'Active',
                'proceduralStatus': 'configured',
                'availabilityStatus': 'Online',
                'operationalState': 'Enabled',
                'blockingState': 'Unblocked'}
    elif cell_type == 'lte':
        on_air_state_dict = {
            'blockingState': 'Unblocked',
            'usageState': 'Idle',
            'operationalState': 'Enabled',
            'administrativeState': 'Unlocked',
            'availabilityStatus': 'Online'}
    for cell_info in cells_info:
        if cell_info['status'] == on_air_state_dict:
            are_cells_on_air = \
                [True if cell_info['status'] == on_air_state_dict else False for cell_info in cells_info]
    if len(set(are_cells_on_air)) == 1:
        return True
    else:
        return False


def _get_new_lines(log1, log2):
    s1 = set(line.strip() for line in open(log1, 'rt'))
    s2 = set(line.strip() for line in open(log2, 'rt'))
    return s2.difference(s1)


def parse_logs_for_attach(log1, log2, interval):
    log = _get_new_lines(log1, log2)
    for i in sorted(list(log), key=lambda k: k.split()[2]):
        logging.info(i)

    logging.info('total number of lines: {}'.format(len(log)))
    if len(log) < int(interval) - 3:
        raise Exception('No 5G attach!')
    else:
        logger.console('5G attach OK!!! :)')
