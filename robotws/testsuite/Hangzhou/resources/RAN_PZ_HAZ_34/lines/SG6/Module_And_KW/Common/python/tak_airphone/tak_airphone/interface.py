# -*- coding: utf-8 -*-
"""
:created on: 18-02-2024

:copyright: Nokia
:author: winnie he
:contact: winnie.he@nokia-sbell.com
"""

import logging
from ute_common_store import Store
from ute_common_store.exception import AliasError
from .airphone import Airphone


class Nsa(object):
    def __init__(self):
        self._log = logging.getLogger(__name__)
        self.store = Store()

    def airphone_get_enb_id(self, alias='default'):
        """Get enb id from egate

        :param alias: Name of execution context
        :return: Enb id
        """
        try:
            return self.store.get(alias).get_enb_id()
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_get_cell_id_by_ue_id_from_cfg_file(self, ue_id, alias='default'):
        """Get cell id by ue id from wts config file

        :param ue_id: Ue id
        :param alias: Name of execution context
        :return: Cell id
        """
        try:
            return self.store.get(alias).get_cell_id_by_ue_id_from_cfg_file(ue_id)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_get_bearer_id_by_ue_id_from_cfg_file(self, ue_id, alias='default'):
        """Get bearer id by ue id from wts config file

        :param ue_id: Ue id
        :param alias: Name of execution context
        :return: Bearer id
        """
        try:
            return self.store.get(alias).get_bearer_id_by_ue_id_from_cfg_file(ue_id)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_get_sim_state(self, alias='default'):
        """Get sim state

        :param alias: Name of execution context
        :return: The state of simulator, include INIT, CONFIGURING, CONFIGURED, ACTIVATING, ACTIVE
        """
        try:
            return self.store.get(alias).get_sim_state()
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_nsa_attach(self, ue_id, profile_id=1, cell_id=1, bearer_id=2, timeout=10, interval=0.5,
                            ue_nr_capabilities=None, ue_eutra_nr_capabilities=None, alias='default'):
        """Attach specified ue id for NSA

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param profile_id: Profile id, default is 1
        :param cell_id: Cell id, default is 1
        :param bearer_id: Bearer id, default is 2
        :param interval: Interval, default is 0.5
        :param timeout: UE attach timeout, default is 10 seconds
        :param ue_nr_capabilities: UE capability, default is None
        :param ue_eutra_nr_capabilities: UE capability, default is None
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).nsa_attach(ue_id, profile_id, cell_id, bearer_id, interval, timeout,
                                             ue_nr_capabilities, ue_eutra_nr_capabilities)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_nsa_detach(self, ue_id, timeout=10, interval=0.5, alias='default'):
        """Detach specified ue id for NSA

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param timeout: UE detach timeout, default is 10 seconds
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).nsa_detach(ue_id, timeout, interval)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_nsa_detach_all(self, interval=0.5, timeout=30, alias='default'):
        """Detach all ue for NSA

        :param interval: interval, default is 0.5
        :param timeout: UE detach timeout, default is 30 seconds
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).nsa_detach_all(interval, timeout)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_setup_x2_connection(self, timeout=10, enb_id=None, gnb_id=None, alias='default'):
        """Setup X2 connection for NSA bts onair

        :param timeout: setup x2 connection timeout, default is 10 seconds
        :param enb_id: default is None, then active enb id(1) will got automatically, simulated gnb id(5)
        should be input
        :param gnb_id: gnb id, default is None, then active gnb id(2) will got automatically, simulated gnb id(3)
        should be input
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).setup_x2_connection(timeout, enb_id, gnb_id)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_nsa_start_data_traffic(self, ue_id, direction, throughput, trf_id=1, bearer_id=2, duration=600,
                                        interval=0.5, protocol='udp', alias='default', **kwargs):
        """NSA start data traffic.

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param direction: downlink or uplink, value can be "dl" or "ul"
        :param throughput: throughput value, desired data transfer throughput, value can be such as "10M"
        :param trf_id: trf id, default is 1
        :param bearer_id: bearer id, default is 2
        :param duration: duration value, default is 600s
        :param interval: interval between multi ues, default is 0.5s
        :param protocol: udp or tcp, default is udp
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        try:
            throughput = str(throughput) + "bps"
            self.store.get(alias).nsa_start_data_traffic(ue_id, direction.lower(), throughput, trf_id,
                                                         bearer_id, duration, interval, protocol.lower(), **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_nsa_stop_data_traffic(self, ue_id, direction, bearer_id=2, interval=0.5, alias='default', **kwargs):
        """NSA stop data traffic.

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param direction: downlink or uplink, value can be "dl" or "ul"
        :param bearer_id: bearer id, default is 2
        :param interval: interval between multi ues, default is 0.5s
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        try:
            self.store.get(alias).nsa_stop_data_traffic(ue_id, direction.lower(), bearer_id, interval, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_nsa_get_throughput(self, ue_id, direction, rate_type='ave', bearer_id=2, alias='default', **kwargs):
        """NSA get throughput

        :param ue_id: UE ID
        :param direction: downlink or uplink, value can be "dl" or "ul"
        :param rate_type: max or average or min throghput, value can be "max" or "ave" or "min", default is ave
        :param alias: Name of execution context
        :param kwargs:
        :return: throughput value, unit is kbps
        """
        try:
            return self.store.get(alias).nsa_get_throughput(ue_id, direction.lower(), rate_type, bearer_id, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")


class Sa(object):
    def __init__(self):
        self._log = logging.getLogger(__name__)
        self.store = Store()

    def airphone_set_traffic_type(self, ue_id, pdu_id=1, type='internal', timeout=30, interval=0.5, alias='default'):
        """Airphone set traffic type

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param pdu_id: pdu id, default is 1
        :param type: trf type, default is internal
        :param timeout: time out, default is 30 seconds
        :param interval: interval, default is 0.5 second
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).set_traffic_type(ue_id, pdu_id, type, timeout, interval)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_get_cell_id_list(self, type='gnb', alias='default'):
        """Get all cell id list from egate

        :param type: enb cell id list or gnb cell id list, default is gnb
        :param alias: Name of execution context
        :return: Cell id list
        """
        try:
            return self.store.get(alias).get_cell_id_list(type)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_wait_until_sib1_received(self, cell_id=1, timeout=600, alias='default'):
        """Wait unitl sib1 received

        :param cell_id: Cell ID, default is 1
        :param timeout: Timeout, default is 600 seconds
        :param alias: Name of execution context
        :return: Indicate whether sib1 and sib2 is received. If yes, return True, else return False
        :rtype: bool
        """
        try:
            cell_id = int(str(cell_id))
            timeout = int(str(timeout))
            return self.store.get(alias).wait_until_sib1_received(cell_id, timeout)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_sa_attach(self, ue_id, timeout=300, ue_capability=None, interval=0.5, alias='default'):
        """Attach specified ue id for SA

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param timeout: UE attach timeout, default is 10 seconds
        :param ue_capability: UE capability, default value is none
        :param interval: interval between multi ues, default is 0.5s
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).sa_attach(ue_id, timeout, ue_capability, interval)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_sa_detach(self, ue_id, timeout=300, interval=0.5, alias='default'):
        """Detach specified ue id for SA

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param timeout: UE detach timeout, default is 10 seconds
        :param interval: interval between multi ues, default is 0.5s
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).sa_detach(ue_id, timeout, interval)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_pdu_session_setup(self, ue_id, pdu_id=1, nwslice_id=1, gw_id=1, timeout=180,
                                   pass_regexp="Initial Context Setup Successful", interval=0.5, alias='default'):
        """Simulate PDU session setup on 5GNR side

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param pdu_id: default is 1
        :param nwslice_id: default is 1
        :param gw_id: default is 1
        :param timeout: simulate PDU session, default is 180
        :param pass_regexp: pass regex
        :param interval: default is 0.5
        :param alias: Name of execution context
        :return:
        """
        try:
            return self.store.get(alias).pdu_session_setup(ue_id, pdu_id, nwslice_id, gw_id, timeout, pass_regexp,
                                                           interval)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_pdu_session_modify(self, ue_id=1, pdu_id=1, pass_regexp=None, alias='default', **kwargs):
        """Modify pdu session

        :param ue_id: UE id
        :param pdu_id: PDU id, default is 1
        :param pass_regexp: Pass regexp
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        self.store.get(alias).pdu_session_modify(ue_id, pdu_id, pass_regexp, **kwargs)

    def airphone_sa_start_data_traffic(self, ue_id, direction, throughput, trf_id=1, pdu_id=1, duration=600,
                                       interval=0.5, protocol='udp', alias='default', **kwargs):
        """SA start data traffic.

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param direction: downlink or uplink, value can be "dl" or "ul"
        :param throughput: throughput value, desired data transfer throughput, value can be such as "10M"
        :param trf_id: trf id, default is 1
        :param pdu_id: pdu id, default is 1
        :param duration: duration value, default is 600s
        :param interval: interval between multi ues, default is 0.5s
        :param protocol: protocol, udp or tcp, default is udp
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        try:
            throughput = str(throughput) + "bps"
            self.store.get(alias).sa_start_data_traffic(ue_id, direction.lower(), throughput, trf_id, pdu_id,
                                                        duration, interval, protocol.lower(), **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_sa_stop_data_traffic(self, ue_id, direction, pdu_id=1, qfi_id=1, interval=0.5,
                                      alias='default', **kwargs):
        """SA stop data traffic.

        :param ue_id: UE ID, support multi ue id like '1...3,6'
        :param direction: downlink or uplink, value can be "dl" or "ul"
        :param pdu_id: pdu id, default is 1
        :param qfi_id: qfi id, default is 1
        :param interval: interval between multi ues, default is 0.5s
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        try:
            self.store.get(alias).sa_stop_data_traffic(ue_id, direction.lower(), pdu_id, qfi_id, interval, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_sa_get_throughput(self, ue_id, direction, pdu_id=1, qfi_id=1, rate_type='ave',
                                   alias='default', **kwargs):
        """SA get throughput

        :param ue_id: UE ID
        :param direction: downlink or uplink, value can be "dl" or "ul"
        :param pdu_id: pdu id, default is 1
        :param qfi_id: qfi id, default is 1
        :param rate_type: max or average or min throghput, value can be "max" or "ave" or "min", default is ave
        :param alias: Name of execution context
        :param kwargs:
        :return: throughput value, unit is kbps
        """
        try:
            return self.store.get(alias).sa_get_throughput(ue_id, direction.lower(), pdu_id,
                                                           qfi_id, rate_type, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")


class tak_airphone(Nsa, Sa):

    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self.store = Store()
        self.ROBOT_LIBRARY_LISTENER = self
        Nsa.__init__(self)
        Sa.__init__(self)

    def airphone_setup(self, edaemon_port=22222, egate_port=20000, tool_dir="/opt/wts/latest",
                       host_ip='127.0.0.1', alias='default', save_egate=True):
        """Setup airphone, this keyword must be called before others keyword in this library

        :param edaemon_port: Edamon port. default 22222
        :param egate_port: Egate port. default 20000
        :param alias: Name of execution context
        :return:
        """
        airphone_control = Airphone(edaemon_port, egate_port, tool_dir, host_ip, save_egate)
        self.store.add(airphone_control, alias)
        self.store.get(alias).setup(alias=alias)

    def airphone_start_wtssim_with_cfg_file(self, cfg_file, reload=True, timeout=120, alias='default'):
        """Start wtssim and load cfg files

        :param cfg_file: Path to the lua file where egate configuration is stored.
                         e.g.  '/opt/wts/latest/basic_l1bypass_sa_call_tdd_cmwv.cfg'
        :param reload: load cfg file or not
        :param timeout: Timeout, default is 120 seconds
        :param alias: Name of execution context
        :return:
        """
        try:
            self.store.get(alias).start_wtssim_with_cfg_file(cfg_file, reload, timeout)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_execute_egate_command(
            self, cmd, pass_regexp=None, fail_regexp=None, timeout=10, alias='default', **kwargs):
        """To execute a single command passed to airphone for the specific objective.

        :param cmd: cmd to execute.
        :param pass_regexp: Regexp indIcating that the command passed.
        :param fail_regexp: Regexp indicating that the command failed.
        :param timeout: Timeout for waiting this operation print pass_regexp. Default is 10 seconds.
        :param alias: Name of execution context
        :return: Data received during the execution. Valid only if pass_regexp is set.
        :rtype: string
        :note: Command could be anything supported by the Telnet interface of egate.
               pass_regexp need assign value by yourself, otherwise the keyword will pass any condition
               you must have already call keyword 'airphone_start_wtssim_with_cfg_file' before call this keyword
        :Supported parameter is available via kwargs:
            return_output (boolean) - Flag indicating whether egate log should be printed out. Default is True.
            padding_buffer (int) - Parameter setting the size of the padding buffer to be used in the output
            If RRC protocol is enabled, set value >40000
        """
        try:
            return self.store.get(alias).execute_command(cmd, pass_regexp, fail_regexp, timeout, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_get_gnb_id(self, alias='default'):
        """Get gnb id from egate

        :param alias: Name of execution context
        :return: Gnb id
        """
        try:
            return self.store.get(alias).get_gnb_id()
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_get_throughput_on_specific_scell(
            self, ue_id, scell_id=0, type='pdsch', tput_type='ave', alias='default'):
        """Get airphne throughput on specific scell(ue level).

        :param String  ue_id: the identification of ue
        :param Integer  scell_id:  the identification of cell. Default is 0
        :param String  type: the direction , pdsch or pusch
        :param String  tput_type: the type of throughput. Default is 'ave'.
               Support below string: ave, max, min, current.
        :param alias: Name of execution context

        :return: the value of throughput, unit is Kbps.
        :rtype: float
        """
        return self.store.get(alias).get_throughput_on_specific_scell(
            ue_id=ue_id, scell_id=scell_id, type=type, tput_type=tput_type)

    def airphone_collect_edaemon_log_files(self, subdirectory=None, unzip=None, alias='default', **kwargs):
        """Download created log files to the test result directory.

        :param subdirectory: (string) – Name of folder to create in addition to the normal test result structure.
        :param unzip: (boolean) – Flag indicating whether collected logs should be extracted.
        :param alias: Name of execution context
        :param kwargs:
        :return:
        Supported SSH parameters are available via kwargs:
            ssh_user (string) - Username for SSH authentication. Default is ‘ute’.
            ssh_pass (string) - Password for SSH authentication. Default is ‘ute’.
            ssh_port (integer) - SSH service port on specified machine. Default is 22.
            ssh_prompt (string) - SSH prompt received after logging in. Default is ‘$ ‘.
        This method will download the following files:
            edaemon.log
            mme_*.log
            pgw_*.log
            sgw_*.log
            uec_*.log

        Note: Format of the result directory structure is: TestSuite1/TestSuite2/TestCase/SubFolder.
        """
        try:
            self.store.get(alias).collect_edaemon_log_files(unzip, subdirectory, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_collect_egate_log_files(self, subdirectory=None, unzip=None, alias='default', **kwargs):
        """Download created files to the test result directory.

        :param subdirectory: (string) – Name of folder to create in addition to the normal test result structure.
        :param unzip: (boolean) – Flag indicating whether collected logs should be extracted.
        :param alias: Name of execution context
        :param kwargs:
        :return:
        Supported SSH parameters are available via kwargs:
            ssh_user (string) - Username for SSH authentication. Default is 'ute'.
            ssh_pass (string) - Password for SSH authentication. Default is 'ute'.
            ssh_port (integer) - SSH service port on specified machine. Default is 22.
            ssh_prompt (string) - SSH prompt received after logging in. Default is ‘$'.
        This method will download the following files:
            egate.log
            egate_console.log

        Note: Format of result directory structure is: TestSuite1/TestSuite2/TestCase/SubFolder.
        """
        try:
            self.store.get(alias).collect_egate_log_files(unzip, subdirectory, **kwargs)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_cleanup_egate_console_log(self, log_path='/opt/wts/latest', alias='default'):
        """Clean up the eagate log.

        :param log_path: set the egate console log path to cleanup
        :param alias: Name of execution context
        :return:
        :rtype:
        """
        try:
            self.store.get(alias).cleanup_egate_console_log(log_path=log_path)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def airphone_set_log_flush(self, alias='default'):
        """Set log flush

        :param alias: Name of execution context
        :return:
        """
        self.store.get(alias).set_log_flush()

    def airphone_bler_testmode_nr(self, profile_id=1, alias='default', **kwargs):
        """Config bler testmode

        :param profile_id: profile id, default is 1
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        self.store.get(alias).bler_testmode_nr(profile_id, **kwargs)

    def airphone_measurement_send_nr(self, id, meas_id, event, pass_regexp=None, alias='default', **kwargs):
        """Send measurement

        :param id:
        :param meas_id:
        :param event:
        :param pass_regexp:
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        self.store.get(alias).measurement_send_nr(id, meas_id, event, pass_regexp, **kwargs)

    def airphone_cqi_param(self, id=1, on='nr', nr_cqi_mode='fixed', scell_id=1, nr_ri=0, nr_cqi=1, alias='default',
                           **kwargs):
        """Config cqi param

        :param id:
        :param on:
        :param nr_cqi_mode:
        :param scell_id:
        :param nr_ri:
        :param nr_cqi:
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        self.store.get(alias).cqi_param(id, on, nr_cqi_mode, scell_id, nr_ri, nr_cqi, **kwargs)

    def airphone_csi_override_testmode_nr(self, profile_id, cqi, ri, cri, li, pmi, cqi_mode='fixed', ri_mode='fixed',
                                          pmi_mode='fixed', cri_mode='fixed', li_mode='fixed',
                                          alias='default', **kwargs):
        """Config csi override testmode

        :param profile_id:
        :param cqi:
        :param ri:
        :param cri:
        :param li:
        :param pmi:
        :param cqi_mode:
        :param ri_mode:
        :param pmi_mode:
        :param cri_mode:
        :param li_mode:
        :param alias: Name of execution context
        :param kwargs:
        :return:
        """
        self.store.get(alias).csi_override_testmode_nr(profile_id, cqi, ri, cri, li, pmi, cqi_mode, ri_mode, pmi_mode,
                                                       cri_mode, li_mode, **kwargs)

    def airphone_location_change(self, id, cell_id, alias='default', **kwargs):
        """Change location

        :param id:
        :param cell_id:
        :param alias:
        :param kwargs:
        :return:
        """
        self.store.get(alias).location_change(id, cell_id, **kwargs)

    def airphone_teardown(self, alias='default'):
        """Teardown airphone

        :param alias: Name of execution context
        """
        try:
            self.store.get(alias).teardown()
            self.store.remove(alias)
        except AliasError:
            raise AliasError("Please use Airphone Setup or Common Suite Setup before any other operation.")

    def get_nr_meas_id_for_specific_type_and_frequency(self,
                                                       ue_id,
                                                       carrierfreq,
                                                       event_type,
                                                       carrierfreq_rat="NR",
                                                       measho_type='',
                                                       threshold='',
                                                       timetotrigger='',
                                                       timeout='2',
                                                       alias='default'
                                                       ):
        """
        the keyword is to get meas id from ue_meas_cfg_disp according to carrierfrequency, carrierfrequency rat
        and event_type.\n
        :param ue_id  string: Specified UE ID(s). for SA type or NSA type.mandatory
        :param carrierfreq  string:condition to look up meas id, absoluteFrequencySSB calculated by
        nr arfcn and gscn. mandatory
        :param carrierfreq_rat  string: condition to look up meas id , such as NR,EUTRAN , default is NR. optional
        :param event_type  string: condition to look up meas id , such as A1,A2,A3,A4,A5,A6,B1,B2,periodical.
        :param mesho_type  string: condition to look up RSRP or RSRQ.
        :param threshold   string: condition to look up specific threhold value. such as threshold=RSRP 60
        :param timetotrigger    string:condition to look up TimeToTrigger value. such as timetotrigger=480 ms
        :param timeout     string: the wait time after inputting ue_meas_cfg_disp command.
        Example:
        | Get Nr Meas Id For Specific Type And Frequency | ue_id=91  |  carrierfreq=633216 | carrierfreq_rat=NR |
        | event_type=A3 |
        """
        return self.store.get(alias).get_nr_meas_id_for_specific_type_and_frequency(ue_id,
                                                                                    carrierfreq,
                                                                                    event_type,
                                                                                    carrierfreq_rat,
                                                                                    measho_type,
                                                                                    threshold,
                                                                                    timetotrigger,
                                                                                    timeout)
