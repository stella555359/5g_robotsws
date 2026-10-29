# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import six
import logging
import time
import os

from .common import IpaMmlItem, device_config
from .pet_tma import c_pet_tma


class c_pet_tm500(IpaMmlItem, object):

    def __init__(self, id, logfile, logger=None):
        self.id = id
        self.logfile = logfile
        self.logger = logger or logging.getLogger('PET_TA')
        self.level = 'P'
        self._name = 'TM500-{}'.format(id)
        self.shenick = None
        self.p_mode = False
        self.ascid = ''
        self.config = device_config('tm500', id)
        for key in self.config:
            setattr(self, key.lower(), self.config[key])

    def setup(self):
        self.logger.info('Setup for {}'.format(self._name))
        self.tma = c_pet_tma(host=self.tm500_control_pc_lab, port=22,
                             username=self.tm500_control_pc_username, password=self.tm500_control_pc_password,
                             logfile=self.logfile, logger=self.logger)
        self.tma.setup()
        self.logger.info('Setup TMA of {} done.'.format(self._name))

    def poweroff(self):
        if self.ascid:
            pass
        else:
            host, port = self.tm500_powerbreak_port.split(':')
            from pet_pb import pb_factory
            pb = pb_factory(host=host, factory='APC', logger=self.logger)
            pb.power_off(port)

    def reboot_tm500(self):
        pass
        # if self.ascid.strip():
        #     self.logger.info('It is a asc {}'.format(self.ascid))
        #     from .pet_asc import c_pet_asc
        #     asc = c_pet_asc(self.ascid, self.logger)
        #     case = gv.case.curr_case
        #     if self.ascid in gv.asc_locks:
        #         self.logger.info(f'start to use asc lock: {self.ascid}')
        #         with gv.asc_locks[self.ascid]:
        #             if hasattr(case, 'use_asc') and case.use_asc:
        #                 self.logger.info('lock {} change_to_state_l2 all'.format(self.ascid))
        #                 asc.change_to_state_l2('all')
        #             else:
        #                 self.logger.info('lock {} change_to_state_l2 {}'.format(self.ascid, self.id))
        #                 asc.change_to_state_l2(self.id)
        #                 # asc.simple_restart(str(self.id))
        #         self.logger.info(f'quit to use asc lock: {self.ascid}')
        #     else:
        #         if hasattr(case, 'use_asc') and case.use_asc:
        #             self.logger.info('change_to_state_l2 all')
        #             asc.change_to_state_l2('all')
        #         else:
        #             self.logger.info('change_to_state_l2 {}'.format(self.id))
        #             asc.change_to_state_l2(self.id)
        # else:
        #     self.logger.info('Restart {} with powerbreak'.format(self._name))
        #     from lib_device import c_pet_pb_apc_c
        #     apc_host, outlet = self.tm500_powerbreak_port.split(':')
        #     apc = c_pet_pb_apc_c(host=apc_host, logger=self.logger)
        #     apc.power_reboot(outlet, 30)
        #     self.logger.info('Restart {} with powerbreak done'.format(self._name))

    def start_tma(self, force=False):
        pass
        # self.logger.info('Try to start TMA for {}'.format(self._name))
        # if self.cpc.tma_is_running():
        #     if self.cpc.get_running_tma_count() > 1:
        #         self.logger.warning('Multiple TMA is running, should be killed all.')
        #         self._reboot_tma()
        #         return 0

        #     running_version = self.cpc.get_running_tma_version()
        #     config_version = self._parse_tma_version(self.tm500_version_dir)
        #     self.logger.info('Running TMA: [{}] vs Needed TMA [{}]'.format(
        #         running_version, config_version))
        #     if running_version != config_version or force:
        #         self._reboot_tma()
        #         return 0
        #     else:
        #         self.logger.info('TMA is Running and version is matched.')

        #     if not self.p_mode:
        #         if self.cpc.tma_is_listening():
        #             self.logger.info('TMA is listening.')
        #             output = self.tma.execute_tm500_command_without_check('HELP')
        #             if 'TMA NO RESPONSE' not in output:
        #                 self.logger.info('TMA is Alive, everything is OK.')
        #             else:
        #                 self.logger.warning('TMA is not Alive')
        #                 self._reboot_tma()
        #                 return 0
        #         else:
        #             self.logger.warning('TMA is not listening.')
        #             self._reboot_tma()
        # else:
        #     self.logger.info('TMA is not running, TA will start it')
        #     self.cpc.start_tma(self.tm500_version_dir)

    def run_script_file(self, filename):
        if os.path.exists(filename):
            script = open(filename).readlines()
            script = [x.strip() for x in script if x.strip()]
            script = [x.splitlines()[0] for x in script if 'CONNECT' in x.upper() or
                      'PORT' in x.upper() or not x.startswith('#')]

            output = ''
            for line in script:
                self.logger.info('--> [{}]'.format(line))
                output += self.tma.execute_tm500_command_without_check(line)
                if 'Assert'.upper() in output.upper():
                    raise Exception('Found Assert in TM500 output')
            return output
        else:
            raise Exception('Could not find specific TM500 Connect file {}'.format(filename))


if __name__ == '__main__':
    tm500 = c_pet_tm500(27)
