"""
:copyright: Nokia Networks
:author: Aleksander Kleczek
:contact: aleksander.kleczek@nokia.com
:maintainer: None
:contact: None
"""
import time
import datetime
import re
import os
import logging
from contextlib import contextmanager
from pprint import pprint

from robot.api.deco import keyword

from moler.config import load_config, loaded_config
from moler.device import DeviceFactory
from taf.ul.sc.uesim.cus.executor import Executor


class CusExecutor():
    def __init__(self):
        self.dev_name = 'cus'

    def _get_moler_config(self):
        moler_configuration = {
            'LOGGER': {
                'PATH': '/home/ute/moler_logs',
                'RAW_LOG': True,
                'DEBUG_LEVEL': 'DEBUG'},
            'DEVICES': {
                'CUS': {
                    'DEVICE_CLASS': 'ta_moler.device.cus.CUS',
                    'CONNECTION_HOPS': {
                        'UNIX_LOCAL': {
                            'WS': {
                                'execute_command': 'ssh',
                                'command_params': {
                                    'expected_prompt': 'ute@.*',
                                    'host': 'localhost',
                                    'login': 'ute',
                                    'password': 'ute'}
                            }
                        },
                        'WS': {
                            'CUS': {
                                'execute_command': 'telnet',
                                'command_params': {
                                    'expected_prompt': r'.*CUS>'
                                }
                            },
                            'UNIX_LOCAL': {
                                'execute_command': 'exit',
                                'command_params': {
                                    'expected_prompt': 'moler_bash',
                                    'timeout': 2
                                }
                            }
                        },
                        'CUS': {
                            'WS': {
                                'execute_command': 'exit_telnet',
                                'command_params': {
                                    'expected_prompt': "ute@.*",
                                }
                            }
                        },
                        'WS_ROOT': {
                            'WS': {
                                'execute_command': 'exit',
                                'command_params': {
                                    'expected_prompt': 'ute@.*'
                                }
                            }
                        }
                    }
                }
            }
        }
        return moler_configuration

    @contextmanager
    def _get_cus_executor(self):
        try:
            if "NOT_LOADED_YET" in loaded_config:
                config = self._get_moler_config()
                load_config(config=config)
            executor = DeviceFactory.get_device('CUS')
            yield executor
            executor.remove()
        except Exception as err:
            logging.error(err)
            raise

    def start_cus_scenario(self, scenario_name):
        """
        Example Robot usage:
        Start CUS scenario    CB008609_A_1.scn

        :param scenario_name:
        :return:
        """
        with self._get_cus_executor() as executor:
            start_cmd = executor.get_cmd('start', cmd_params={'scenario': scenario_name})
            start_cmd(timeout=30)

    def stop_cus_scenario(self):
        """
        Example Robot usage:
        Stop CUS scenario

        :return:
        """
        with self._get_cus_executor() as executor:
            stop_cmd = executor.get_cmd('stop', cmd_params={})
            stop_cmd()

    def start_ue_mobile_session(self, session_name, timeout=60, **kwargs):
        """
        Example Robot usage:
        Start UE mobile session  attach_ue  number=50  rate=5.0  cells=3,4
        ueCapabilities="release=12 category=8 category_dl=14 category_ul=8
        supported_bands=2 ca_supported_bands=2:a:a ul_64QAM_supported=on"

        First argument is mobileSession name defined in CUS scenario, which is currently started.
        Rest parameters are testScenario params.

        :param session_name:
        :param timeout:
        :param kwargs:
        :return:
        """
        with self._get_cus_executor() as executor:
            start_ue_session = executor.get_cmd('scenario_ue_start', cmd_params={'mobile_session': session_name,
                                                                                 'parameters': kwargs})
            result = start_ue_session(timeout=timeout)

    def get_ue_stats(self):
        ue_stats = {}
        with self._get_cus_executor() as executor:
            stats_cmd = executor.get_cmd('stats', cmd_params={'options': 'ue'})
            try:
                result = stats_cmd()
                if result:
                    ue_stats = {self._parse_sector_name(sector): value for (sector, value) in result['LTE'].items()}
            except Exception as err:
                logging.error(err)

        return ue_stats

    def _parse_sector_name(self, sector):
        return str(re.findall(r'\d+', sector)[0]) if re.findall(r'\d+', sector) else str(sector)

    def _convert_ues_per_cell_str_to_dict(self, cell_ue_str):
        ue_per_cell_amount = {}
        for data in cell_ue_str.split(','):
            cell, expected_ues = data.strip().split(':')
            ue_per_cell_amount[cell] = int(expected_ues)
        return ue_per_cell_amount

    @keyword('Verify attached UEs amount per cell [${ue_per_cell_amount}]')
    def check_ues_per_cell(self, ue_per_cell_amount):
        """
        Example Robot usage:
        Verify attached UEs amount per cell [1:1500, 2:1000, 3:150]

        :param ue_per_cell_amount:
        :return:
        """
        expected_ues_per_cell = self._convert_ues_per_cell_str_to_dict(ue_per_cell_amount)
        timeout = 30
        step = 10
        status = ['nok']

        start_time = datetime.datetime.now()
        while 'nok' in status and timeout:
            current_ue_per_cell = self.get_ue_stats()
            status = []

            for cell, expected_ues in expected_ues_per_cell.items():
                current_ues = int(current_ue_per_cell[cell]['RRC_CONNECTED_UES'])
                if current_ues == expected_ues:
                    status.append('ok')
                else:
                    logging.info('CELL-{} active UEs: current - {}, expected - {}.'.format(cell, current_ues,
                                                                                           expected_ues))
                    status.append('nok')
            logging.info(50 * '-')
            if 'nok' in status:
                logging.info('Waiting {}s for next check\n'.format(step))
                timeout -= step
                time.sleep(step)
        stop_time = datetime.datetime.now()
        logging.info('Start time: {}'.format(start_time))
        logging.info('Stop time: {}'.format(stop_time))
        time_diff = stop_time - start_time
        logging.info('Duration: {}s'.format(time_diff.total_seconds()))
        assert 'nok' not in status, 'Number of attached UEs is not as expected'

    @keyword('Verify active bearers amount per cell [${bearers_per_cell_amount}]')
    def check_bearers_per_cell(self, bearers_per_cell_amount):
        """
        Example usage:
        Verify active bearers amount per cell [1:1500, 2:1000, 3:150]
        """
        expected_bearers_per_cell = self._convert_ues_per_cell_str_to_dict(bearers_per_cell_amount)
        timeout = 30
        step = 10
        status = ['nok']

        start_time = datetime.datetime.now()
        while 'nok' in status and timeout:
            current_ue_per_cell = self.get_ue_stats()
            status = []

            for cell, expected_bearers in expected_bearers_per_cell.items():
                current_bearers = int(current_ue_per_cell[cell]['ACTIVE_BEARERS'])
                if current_bearers == expected_bearers:
                    status.append('ok')
                else:
                    logging.info('CELL-{} active bearers: current - {}, expected - {}.'.format(cell, current_bearers,
                                                                                               expected_bearers))
                    status.append('nok')
            logging.info(50 * '-')
            if 'nok' in status:
                logging.info('Waiting {}s for next check\n'.format(step))
                timeout -= step
                time.sleep(step)
        stop_time = datetime.datetime.now()
        logging.info('Start time: {}'.format(start_time))
        logging.info('Stop time: {}'.format(stop_time))
        time_diff = stop_time - start_time
        logging.info('Duration: {}s'.format(time_diff.total_seconds()))
        assert 'nok' not in status, 'Number of active bearers is not as expected'


if __name__ == '__main__':
    test = CusExecutor()

    test.start_ue_mobile_session(session_name='testSession',
                                 number='50',
                                 rate='5.0',
                                 cells='"3, 4"',
                                 ueCapabilities='"release=12 category=8 category_dl=14 category_ul=8 supported_bands=2'
                                                ' ca_supported_bands=2:a:a ul_64QAM_supported=on"')
