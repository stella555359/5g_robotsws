import logging

from moler.device import DeviceFactory
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class JournalObserver(GenericBts):
    commands = None

    @load_moler_configuration_from_tl()
    def start_journal_observer(self, gnb_id=0, du_id=0):
        """
        Start journal logs observer on gNB.
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        device_name = self.ssh_alias.format(gnb_id, du_id)
        gnb = DeviceFactory.get_device(name=device_name)
        gnb.goto_state("FSP")
        self.commands = gnb.get_cmd(
            cmd_name="cat",
            cmd_params={'path': '/dev/null;journalctl -f | grep is_alarm_active'})
        self.commands.start(timeout=1200)
        logging.info("Start journal events observer on device {}".format(device_name))

    def stop_journal_observer(self, gnb_id=0):
        """
        Stop journal logs observer on gNB.
        :param gnb_id: gNB id - related to Test Line configuration.
        :return: results: output of journalctl command. type: list
        """
        try:
            self.commands.cancel()
            results = self.commands.current_ret['LINES']
            logging.info("journalctl command output: {}".format(results))
            return results
        except KeyError:
            raise Exception("Please first run 'start_journal_observer' for gnb_id={}".format(gnb_id))
