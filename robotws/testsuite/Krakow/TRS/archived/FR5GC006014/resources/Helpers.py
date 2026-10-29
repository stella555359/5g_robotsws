"""
:author: Bartlomiej Trybuch
:contact: bartlomiej.trybuch@nokia.com
"""

from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as GnbRu
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
import time
import os
import sys


class BbuHelpers(GnbBbu):

    @load_moler_configuration_from_tl()
    def set_dhcp(self, container_name, bts_id=0, du_id=0):
        """
        Sets correct DHCP mask and performs DHCP service reset and RU reset to apply changes
        :param container_name:  0x2018 or 0x1018
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        bts_name = self.ssh_alias.format(bts_id, du_id)
        bts = DeviceFactory.get_device(bts_name)
        bts.goto_state('FCT')
        sed_cmd = bts.get_cmd(cmd_name='sed',
                              cmd_params={
                                  'options': '-i',
                                  'scripts': ['s/subnet-mask 255.255.255.252/subnet-mask 255.255.255.248/g'],
                                  'input_files': ['/tmp/node_{}/tmp/dhcpd.cfg'.format(container_name)]
                              })
        sed_cmd()
        lxc_attach_cmd_1 = bts.get_cmd(cmd_name='lxc_attach',
                                       cmd_params={
                                           'name': container_name,
                                           'options': '--set-var COLUMNS=250  -- killall -HUP dhcpd'
                                       })
        lxc_attach_cmd_2 = bts.get_cmd(cmd_name='lxc_attach',
                                       cmd_params={
                                           'name': container_name,
                                           'options': '--set-var COLUMNS=250 -- /usr/sbin/dhcpd -cf /tmp/dhcpd.cfg -lf'
                                                      ' /var/tmp/radio-dhcpd/dhcp.leases -user root -group root -pf'
                                                      ' /tmp/dhcpPidFile rlan0.cpri rlan0.ecpri'
                                       })
        lxc_attach_cmd_1()
        time.sleep(10)
        lxc_attach_cmd_2()
        time.sleep(10)


class RuHelpers(GnbRu):

    @load_moler_configuration_from_tl()
    def spam_ls(self, gnb_id=0, du_id=0, radio_unit_id=0):
        """
        Sends 100 ls commands to ru
        :param gnb_id:    BTS id - related to Test Line configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param radio_unit_id: RU id - related to Test line configuration - gnbs.dus.rus[]
        """
        ru = DeviceFactory.get_device(self.ssh_ru_alias.format(gnb_id, du_id, radio_unit_id))
        ru.goto_state("RU")
        for i in range(100):
            ls_cmd = ru.get_cmd(cmd_name='ls',
                                cmd_params={'options': '-al'})
            ls_cmd()


def build_script_command():
    """
    Build script command to launch sendpackets.py
    """
    current_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(current_dir, 'sendpackets.py')
    cmd = 'sudo PYTHONPATH={} {} {}'.format(os.environ['PYTHONPATH'], sys.executable, script_path)
    return cmd
