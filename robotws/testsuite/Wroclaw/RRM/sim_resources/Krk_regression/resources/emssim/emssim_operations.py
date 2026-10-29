import time
import logging
import os
from datetime import datetime
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from ta_emss import ta_emss


class emssim_operations(object):
    alias = 'emssim{}'

    def __init__(self):
        self.ems = ta_emss()
        self._tcpdump_cmd = None

    # TODO check if discover possible for RCF devices
    def setup_emssim(self, host, oam_ip, bts_ip, manager_id, bts_id=1):
        """
        Setup EMS simulator - and don't wait for connection - because RFC NE it doesn't work
        :param host: EMSsim server IP address (default: taken from ta_emss library constructor)
        :param manager_id: Use custom manager_id for NE3S registration.
        :param oam_ip: Additional OAM IP to be added to the existing Primary OAM IP already specified as
                       data_server in /etc/emssim.conf
        :param bts_ip: Together with provided 'user' option will add the new BTS user with given BTS IP
        :param bts_id:
        :return:
        """
        self.ems.setup_emss(bts_id=bts_id,
                            alias=self.alias.format(bts_id),
                            host=host,
                            oam_ip=oam_ip,
                            manager_id=manager_id,
                            bts_ip=bts_ip,
                            wait_connected=False
                            )

    def teardown_emssim(self, bts_id=1):
        self.ems.teardown_emss(bts_id=bts_id, alias=self.alias.format(bts_id))

    def connect_to_rfc(self, rfc_ip, auth, priv, user='admin', bts_id=1):
        """
        Connect to RFC via snmp and set authentication credentials.
        If commends succeed it means that RFC is integrated to EMSsim
        :return:
        """
        self.ems.run_emssim_command(command='snmp_set_ip', params=rfc_ip,
                                    bts_id=bts_id, alias=self.alias.format(bts_id))
        self.ems.run_emssim_command(command='snmp_set_user',
                                    params='-name {} -auth {} -priv {}'.format(user, auth, priv),
                                    bts_id=bts_id, alias=self.alias.format(bts_id))

    def clear_emssim_alarm_history(self, bts_id=1):
        self.ems.clear_alarm_history(bts_id=bts_id, alias=self.alias.format(bts_id))

    def refresh_and_get_alarms(self, bts_id=1):
        self._refresh_alarm_list(bts_id)
        alarms = self._get_alarm_history(bts_id)
        logging.debug("ALARMS_HIST: {}".format(alarms))
        return alarms

    def _refresh_alarm_list(self, bts_id=1):
        alarms = self.ems.run_emssim_command(command='alarm_status', can_fail=True, get_full_data=False,
                                             bts_id=bts_id, alias=self.alias.format(bts_id))
        logging.debug("ALARM STATUS: {}".format(alarms))

    def _get_alarm_history(self, bts_id=1):
        return self.ems.get_alarm_history(alias=self.alias.format(bts_id))

    @load_moler_configuration_from_tl()
    def start_wireshark_on_emssim_interface(self, interface, host_ip_address, logs_dir_path, timeout=30 * 60):
        """
        Start collecting pcap logs
        :param interface:       interface on which logs will be collected
        :param host_ip_address: host ip address
        :param logs_dir_path:   path to the directory where the logs will be collected
        :param timeout:         maximum time for collecting wireshark logs
        :return: path to file log
        """
        start_time = datetime.now().strftime("%Y%m%d_%H%M%S")
        wireshark_logs_path = "{0}/wireshark_logs_{1}.pcapng".format(logs_dir_path, start_time)
        device = DeviceFactory.get_device(name='TEST_PC')
        cmd_tcpdump = device.get_cmd(cmd_name='tcpdump', cmd_params={'options': '-w {0} -i {1} host {2} > /dev/null '
                                                                                '2>&1'.format(wireshark_logs_path,
                                                                                              interface,
                                                                                              host_ip_address)})
        self._tcpdump_cmd = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_tcpdump})
        self._tcpdump_cmd.start(timeout=timeout)

        return wireshark_logs_path

    @load_moler_configuration_from_tl()
    def stop_wireshark_on_emssim_interface(self):
        """
        Stop collecting pcap logs
        """
        if self._tcpdump_cmd:
            self._tcpdump_cmd.break_cmd()
