"""
Keywords for Feature CB008969 Check UL counters from BBMOD journal

:author: Arkadiusz Kowalczyk
:contact: arkadiusz.kowalczyk@nokia.com

"""

from moler.exceptions import CommandFailure, DeviceChangeStateFailure
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu


class UlCounters(GnbBbu):

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def enable_debug_logs_in_journal(self, gnb_id=0, du_id=0):
        """
        Enable debug logs printing in journal on FPGA module, eg. Loki.
        :param gnb_id:      BTS id - related to Test Line configuration. Default: 0
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        try:
            gnb = DeviceFactory.get_device(name=self.ssh_alias.format(gnb_id, du_id))
            gnb.goto_state("FSP")
            write_cmd = gnb.get_cmd(cmd_name="run_script",
                                    cmd_params={'script_command': 'loggerctl --name ip_mgmt --set_level debug'})
            write_cmd()
            MolerTest.steps_end()
        except DeviceChangeStateFailure as err:
            MolerTest.error("Couldn't correctly establish connection to FST BTS\n{}".format(repr(err)))
            MolerTest.steps_end()
