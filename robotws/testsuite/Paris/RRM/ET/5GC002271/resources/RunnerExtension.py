from taf.wts.runner import runner
from robot.api import logger
from robot.libraries.String import String
from robot.libraries.BuiltIn import BuiltIn
from math import ceil
import time


class RunnerExtension(runner):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def initialize_egate(self, edaemon_egate_ssh_alias="Wts",
                         dir_path="/opt/wts/latest",
                         edaemon_port="22222",
                         egate_port="20000",
                         egate_console_ip="127.0.0.1",
                         sudo_pass="ute",
                         wts_file=None):
        """
        Initialize runner library with configuration parameters to set up wts egate

        :param wts_file:            WTS config file to configure egate
        :param edaemon_egate_ssh_alias: Connection alias for WTS egate
        :param dir_path:        edaemon/egate application path
        :param edaemon_port:    Edaemon port  (22222)
        :param egate_port:      Egate port   (20000)
        :param egate_console_ip:      Ip of egate console
        :param sudo_pass:       Sudo command password.
        """

        self.configure_wtsemu_edaemon(edaemon_ssh_alias=edaemon_egate_ssh_alias,
                                      directory_path=dir_path,
                                      port=edaemon_port,
                                      sudo_password=sudo_pass)
        self.configure_wtsemu_egate(egate_ssh_alias=edaemon_egate_ssh_alias,
                                    directory_path=dir_path,
                                    port=egate_port)
        self.start_wtsemu(egate_console_ip=egate_console_ip, egate_port=egate_port)
        self.configure(file=wts_file)
        self.read_wtsemu_output_until_re(expected="SimMode is ready now", timeout="240")
        self.sim_state_disp()
        self.read_wtsemu_output_until_re(expected="The state is ACTIVE", timeout="120")

    def initialize_egate_with_sa_2_cell_on_air_regex_validation(self, edaemon_egate_ssh_alias="Wts",
                                                                dir_path="/opt/wts/latest",
                                                                edaemon_port="22222",
                                                                egate_port="20000",
                                                                egate_console_ip="127.0.0.1",
                                                                sudo_pass="ute",
                                                                wts_file=None):
        self.initialize_egate(edaemon_egate_ssh_alias=edaemon_egate_ssh_alias,
                              dir_path=dir_path,
                              edaemon_port=edaemon_port,
                              egate_port=egate_port,
                              egate_console_ip=egate_console_ip,
                              sudo_pass=sudo_pass,
                              wts_file=wts_file)
        self.read_wtsemu_output_until_re(expected="eNB 2 cell \\d: SystemInformationBlockType4-NR updated",
                                         timeout="120")
        self.read_wtsemu_output_until_re(expected="eNB 2 cell \\d: SystemInformationBlockType4-NR updated",
                                         timeout="120")

    def establish_connection_with_x2_link(self, enb_id, target_id):
        """
        Establish X2 Connection between eNB and target gNB, and verifies
        if the connection was established.

        :param enb_id:  eNB's ID
        :param target_id:  gNB's ID
        """
        pattern = "ENB-1: X2AP Link with GNB-2 .* is up"
        self.enb_x2_link_up(enb=enb_id, target=target_id)
        out = self.read_wtsemu_output_until_re(expected=pattern, timeout=300)
        output = String().get_lines_matching_regexp(string=out, pattern=pattern, partial_match=True)
        BuiltIn().log_to_console(message=" \n {}".format(output))

    def attach_single_ue_to_enodeb(self, ue_id, profile):
        """
        Attach UE to eNB and validates.

        :param ue_id:  ID of UE
        :param profile:  ID of profile
        """
        logger.info("\n Attaching UE-{} with profile {} to LTE".format(ue_id, profile))
        self.ue_attach(id=ue_id, profile=profile)
        out = self.read_wtsemu_output_until_re(expected="UE IS ACTIVE", timeout=300)
        output = String().get_lines_matching_regexp(string=out, pattern="UE IS ACTIVE", partial_match=True)
        BuiltIn().log_to_console(message=" \n {}".format(output))
        BuiltIn().log(message="\n lte_attach_is_ok")

    def start_eutran_new_radio_dual_connectivity(self, ue_id, pattern="reported successful RA"):
        """
        Start EUTRAN NR Dual Connectivity procedure for UE

        :param ue_id:    ID of UE
        :param pattern:  Pattern to evaluate
        """
        logger.info("\n Starts EN_DC for {}".format(ue_id))
        self.enb_ue_dc_start(target_gnb=2, target_cells=1, ue=ue_id, bearer=2, type="split_scg")
        output = self.read_wtsemu_output_until_re(expected=pattern, timeout=300)
        output = String().get_lines_matching_regexp(string=output, pattern=pattern, partial_match=True)
        BuiltIn().log_to_console(message="\n {}".format(output))

    def detach_ue_from_lte_and_release_endc(self, ue_id, bearer_id, time_between_operations):
        """
        Detach UE from eNB, then release DC

        :param ue_id: UE ID
        :param bearer_id: Bearer's ID
        :param time_between_operations:  Time between detachment and release
        """
        logger.info("\n Release EN_DC for {}".format(ue_id))
        self.enb_ue_dc_release(ue=ue_id, bearer=bearer_id, by="enb", cause="off")
        BuiltIn().sleep(time_=time_between_operations, reason="Wait for successful response from admin")
        self.ue_detach(id=ue_id)

    def reset_wts(self):
        self.reset_wtsemu_cfg()

    def register_ue_from_5gcn(self, ue_id):
        """
        Register UE to 5GCN

        :param ue_id: UE ID
        """
        self.ue_register_with_internal_trf_type(ue_id)
        time.sleep(2)
        self.define_profile_id_for_ue(ue_id=ue_id)
        self.associate_profile_to_ue(ue_id=ue_id)

    def register_ue_and_validate(self, ue_id):
        self.ue_register_with_internal_trf_type(ue_id)
        time.sleep(2)

    def ue_register_with_internal_trf_type(self, ue_id):
        self.set_pdu_param(ue=ue_id, pdu="1", trf_type="internal")
        self.ue_register(id=ue_id)
        out = self.read_wtsemu_output_until_re(expected=".*REGISTRATION COMPLETE.*",
                                               timeout="180")
        String().get_lines_matching_regexp(string=out, pattern="REGISTRATION COMPLETE",
                                           partial_match=True)
        String().get_lines_matching_regexp(string=out, pattern=".*Initial UE Message Success.*",
                                           partial_match=True)

    def define_profile_id_for_ue(self, ue_id):
        self.csi_override_testmode_nr(profile_id=ue_id, cqi=13, pmi=2, ri=0, cqi_mode="fixed",
                                      pmi_mode="fixed", ri_mode="fixed")

    def associate_profile_to_ue(self, ue_id):
        self.ue_testmode_set_nr(id=ue_id, profile_id=ue_id, action="activate", testmode="csi_override",
                                scell="0")

    def establish_pdu_session_for_user_equipment(self, ue_id):
        """
        Establish PDU session for User
        :param ue_id:
        :return:
        """
        self.ue_pdu_session_setup(pdu=1, ue=ue_id, nwslice=1, gw=ue_id)
        output = self.read_wtsemu_output_until_re(expected="Initial Context Setup Successful",
                                                  timeout="180")
        String().get_lines_matching_regexp(string=output, pattern="Initial Context Setup Successful",
                                           partial_match=True)
        time.sleep(2)

    def register_multiple_ues_and_establish_pdu_session(self, first_ue_id, last_ue_id):
        """
        Register multiple ues
        :param first_ue_id:
        :param last_ue_id:
        """
        list_of_ids = [str(i) for i in range(int(first_ue_id), int(last_ue_id) + 1)]
        for ue in list_of_ids:
            self.register_ue_from_5gcn(ue_id=ue)
            self.establish_pdu_session_for_user_equipment(ue_id=ue)
            time.sleep(1)

    def deregister_ue_from_5gcn(self, ue_id):
        """
        Deregister UE from 5GCN
        :param ue_id:  UE ID
        """
        self.ue_deregister(id=ue_id, ue_deregister_type="switch_off")
        out = self.read_wtsemu_output_until_re(expected="UE Context Release Complete", timeout="180")
        String().get_lines_matching_regexp(string=out, pattern="UE Context Release Complete", partial_match=True)
        time.sleep(2)

    def deregister_multiple_ues(self, first_ue_id, last_ue_id, **kwargs):
        """
        Deregister multiple ues
        :param first_ue_id:
        :param last_ue_id:
        """
        list_of_ids = [str(i) for i in range(int(first_ue_id), int(last_ue_id) + 1)]
        timeout = kwargs.get('timeout') if kwargs.get('timeout') else None
        for ue in list_of_ids:
            if timeout:
                self.deregister_ue_from_5gcn(ue_id=ue)
                time.sleep(int(timeout))
            else:
                self.deregister_ue_from_5gcn(ue_id=ue)

    def start_data_ping_for_ue_in_sa_nsa_configuration(self, ue_id, direction, mode, burst, size,
                                                       packets, period_ms, bearer_id="2"):
        """
         Start DL or UL traffic for a specific user in SA or NSA configuration

        :param ue_id: UE ID
        :param direction: Data transmission direction
        :param mode: SA or NSA UE
        :param burst:  Number of packets to be sent in burst
        :param size: (Optional) Size of the packet
        :param packets: (Optional) Maximum packets to generate
        :param period_ms: (Optional) Period (4,6,8,...,20,30,40,...) between bursts (also applicable for RTP)
        :param bearer_id: Specified Bearer ID
        """
        trf_id = 1
        if mode == "SA":
            self.trf_data_start(ue=ue_id, pdu="1", qfi="1", dir=direction.lower(), trf_id=trf_id,
                                burst=burst, size=size, packets=packets, period_ms=period_ms)
            time.sleep(1)
        if mode == "NSA":
            self.trf_data_start(ue=ue_id, id=bearer_id, dir=direction.lower(), trf_id=trf_id,
                                burst=burst, size=size, packets=packets, period_ms=period_ms)
            time.sleep(1)

    def start_data_traffic_for_ue_in_sa_nsa_configuration(self, mode, **kwargs):
        """
         Start DL or UL traffic for a specific user in SA or NSA configuration
        """
        max_throughput_per_stream = 150
        rate = int(kwargs.get('mbps'))
        trf_id = 1
        if kwargs.get('period_ms'):
            kwargs.pop('mbps')
        if rate <= max_throughput_per_stream and mode == "SA":
            self.trf_data_start(**kwargs)
        elif rate <= max_throughput_per_stream and mode == "NSA":
            self.trf_data_start(**kwargs)
        else:
            kwargs.pop('mbps')
            while rate > 0:
                rate_to_send = max_throughput_per_stream if rate > max_throughput_per_stream else rate
                if mode == "SA":
                    self.trf_data_start(trf_id=trf_id, mbps=rate_to_send, **kwargs)
                else:
                    self.trf_data_start(trf_id=trf_id, mbps=rate_to_send, **kwargs)
                trf_id += 1
                rate -= rate_to_send
                time.sleep(1)

    def start_data_traffic_for_multiple_ues(self, first_ue_id, last_ue_id, mode, order, **kwargs):
        """
        Start traffic for multiple ues
        :param first_ue_id:
        :param last_ue_id:
        :param mode: Cell deployment type [ SA|NSA ]
        :param order: Mbps or Kbps
        """
        rate = int(kwargs.get('mbps')) if order == "Kbps" else None
        list_of_ids = [str(i) for i in range(int(first_ue_id), int(last_ue_id)+1)]
        for ue in list_of_ids:
            if order == "Mbps":
                self.start_data_traffic_for_ue_in_sa_nsa_configuration(mode=mode,
                                                                       ue=ue,
                                                                       **kwargs)
            elif order == "Kbps":
                self.trf_data_start(ue=ue, kbps=rate, **kwargs)
            else:
                raise Exception("Traffic not started Select properly the order of traffic")

    def stop_data_traffic(self, ue_id, pdu):
        """
        Stop all traffic started

        :param ue_id:   UE ID
        :param pdu:   pdu's ID
        """
        self.trf_data_stop(ue=ue_id, pdu=pdu)
        out = self.read_wtsemu_output_until_re(expected="Traffic was stopped", timeout="10")
        out = String().get_lines_matching_regexp(string=out, pattern="Traffic was stopped", partial_match=True)
        BuiltIn().log_to_console(message="\n {}".format(out))

    def stop_data_traffic_nsa(self, ue_id, bearer_id):
        """
        Stop all traffic started

        :param ue_id:   UE ID
        :param bearer_id:   bearer ID

        """
        self.trf_data_stop(ue=ue_id, id=bearer_id)
        out = self.read_wtsemu_output_until_re(expected="Traffic was stopped", timeout="10")
        out = String().get_lines_matching_regexp(string=out, pattern="Traffic was stopped", partial_match=True)
        BuiltIn().log_to_console(message="\n {}".format(out))

    def stop_dl_data_traffic_sa(self, ue_id):
        """
        Stop Internal traffic
        :param ue_id:  UE ID
        """
        self.trf_data_stop(ue=ue_id, pdu=1, qfi=1, dir="dl")
        self.read_wtsemu_output_until_re(expected="Stopp.* Downlink", timeout="10")

    def stop_ul_data_traffic_sa(self, ue_id):
        """
        Stop Internal traffic
        :param ue_id:  UE ID
        """
        self.trf_data_stop(ue=ue_id, pdu=1, qfi=1, dir="ul")
        self.read_wtsemu_output_until_re(expected="Stopp.* Uplink", timeout="10")

    def report_cqi(self, ue_id, cqi_nr):
        """
         Updates UE Channel State Information for single UE in fixed mode
        :param ue_id: UE ID
        :param cqi_nr:
        """
        self.csi_override_testmode_nr(profile_id=ue_id, cqi=cqi_nr)
        time.sleep(1)

    def kill_wts_processes(self, wts_connection):
        """
        Kill WTS Process
        """
        self.kill_wtsemu_edaemon(edaemon_port="22222", connection=wts_connection, sudo_password="ute")
        self.kill_wtsemu_egate(egate_port="20000", connection=wts_connection, sudo_password="ute")

    def start_amf_paging(self, ue_id):
        """
        Starts amf paging
        """
        self.amf_paging_start(id=1, ueid=ue_id)

    def stop_amf_paging(self):
        """
        Stops amf paging for specified UE
        """
        self.amf_paging_stop(id="1")

    def switch_ue_to_idle(self, ue_id):
        """
        Switches UE to idle
        :param ue_id: UE ID
        """
        self.ue_ng_ctx_release(id=ue_id, cause="NAS_normal_release")
        self.read_wtsemu_output_until_re(expected="IS IDLE", timeout="10")

    def report_cqi_for_multiple_ues(self, string_of_ids, nr_cqi_index):
        """
        Updates UE Channel State Information

        :param string_of_ids:    String of UE IDs
        :param nr_cqi_index:    CQI index to be reported for each UE

        """
        list_ids = string_of_ids.split(",") if "," in string_of_ids else string_of_ids
        list_ids = [ue_id.strip(" ") for ue_id in list_ids[1:]]
        list_ids.append("1")
        list_ids.sort()
        for ue_id in list_ids:
            self.ue_cqi_param(id=ue_id, on="nr", nr_cqi=nr_cqi_index, nr_cqi_mode="fixed", scell="0")
            time.sleep(1)

    def start_dtx_detection(self, profile_id, force_dtx_pusch):
        """
        Force dtx detection
        :param profile_id: profile ID
        :param force_dtx_pusch: (Optional) forced dtx pusch total:interval
        """
        self.forced_dtx_testmode_nr(profile_id=profile_id, force_dtx_pusch=force_dtx_pusch)

    def set_ue_testmode(self, id_testmode, testmode, profile_id, action):
        """
        :param id_testmode: Specified UE ID
        :param testmode: Testmode to be used
        :param profile_id: Test profile id
        :param action: (Optional) Triggers the activation or the deactivation of the test mode
        """
        self.ue_testmode_set_nr(id=id_testmode, testmode=testmode, profile_id=profile_id, action=action)

    def send_ping_message_from_ue(self, size, ue_id, rate):
        self.trf_data_start(ue=ue_id, pdu="1", qfi="1", dir="ul", trf_id=1, mbps=rate, size=size)

    def configure_ue_testmode(self, ue_velocity):
        self.ue_ta_nr(profile_id=1, ue_fo_velocity=ue_velocity)

    def configure_speed_profile_for_ue(self, ue_id):
        self.ue_testmode_set_nr(id=ue_id, testmode="ta", action="activate", profile_id=1)

    def configure_ul_sinr_testmode(self, ue_id):
        self.ul_sinr_testmode_nr(noise_pusch=-900, profile_id=1)
        self.ue_testmode_set_nr(id=ue_id, testmode="ul_sinr", action="activate", profile_id=1)
        self.ul_sinr_testmode_nr(profile_id=1, sinr_target_pusch=0)
        self.ul_sinr_testmode_nr(profile_id=1)
        self.read_wtsemu_output_until_re(expected="phr_value_offset.*", timeout="60")

    def degraded_rf_condition_below_ultransprecodeonsinrthresh(self):
        self.ul_sinr_testmode_nr(noise_pusch=-500, profile_id=1)
        time.sleep(5)
        self.ul_sinr_testmode_nr(profile_id=1, sinr_target_pusch=-5)
        time.sleep(5)
        self.ul_sinr_testmode_nr(profile_id=1, sinr_target_pusch=-10)
        time.sleep(5)
        self.ul_sinr_testmode_nr(profile_id=1, sinr_target_pusch=-10)
        self.read_wtsemu_output_until_re(expected="transformPrecoder enabled", timeout="60")

    def start_sa_uplink_traffic_with_degraded_rf_condition_below_ultransprecodeonsinrthresh(self,
                                                                                            ue_id,
                                                                                            rate,
                                                                                            duration):
        self.start_data_traffic_for_ue_in_sa_nsa_configuration(mode="SA",
                                                               ue=ue_id,
                                                               dir="ul",
                                                               mbps=rate)
        time.sleep(5)
        self.degraded_rf_condition_below_ultransprecodeonsinrthresh()
        time.sleep(float(duration))

    def measure_average_ul_data_rate(self, ue_id, mode="SA", direction="ul"):
        if mode == "SA":
            self.qfi_stats(ue=ue_id, pdu="1", qfi="1", dir=direction)
        else:
            self.bearer_stats(id=2, ue=ue_id, dir=direction)
        cmd_result = self.read_wtsemu_output_until_re(expected="Last data rate", timeout="10")
        BuiltIn().log_to_console(message=" \n {}".format(cmd_result))
        average_rate = String().get_regexp_matches(cmd_result, "Average data rate\\s+(\\d+)", 1)
        return int(average_rate[0])

    def set_ue_param_to_break_ue_capability_into_segments(self, ue_id, var_cap, cap_path, **kwargs):
        """
        :param ue_id: Specified UE ID
        :param var_cap: name from the variable in cfg capability file
        :param cap_path: File's path containing Hex strings with higher Hex strings size
        :param kwargs:  kwargs dictionary can contain key:value for the egate arguments
        ueCapInfomsg_Segment_Threshold - threshold value for the size of ULDedicatedMessageSegment [20...8985 (bytes)]
        and ueCapInfomsg_Errortype - Error type that can be triggered [delay_between_segments, missing_segment,
        Send_ueCapInfoMsg_between_segments]
        """
        hex_string_from_cap_file = read_cfg_capability_variable_from_file(var=var_cap, path=cap_path)
        if kwargs.get("number_of_segments"):
            num_of_segments = kwargs.get("number_of_segments")
            ue_cap_size_bytes = len(hex_string_from_cap_file)/2
            threshold = ceil(ue_cap_size_bytes/float(num_of_segments))
            self.ue_param(id=ue_id, ueCapInfomsg_Segment_Threshold=threshold)
        elif kwargs.get("last_ue_id"):
            last_ue_id = kwargs.get("last_ue_id")
            list_of_ids = [str(i) for i in range(int(ue_id), int(last_ue_id) + 1)]
            for ue in list_of_ids:
                self.ue_param(ue_id=ue, **kwargs)
        else:
            self.ue_param(id=ue_id, **kwargs)

    def prepare_ue_for_ho(self, ue_id, source_gnb_id="2", target_gnb_id="3"):
        self.ue_history_information_list_add_ngran(id=ue_id, gnb_id=source_gnb_id, cell_type="large",
                                                   nrcgi="311:489|0x01",
                                                   time_ue_stayed_in_cell=97)
        self.ue_history_information_list_add_ngran(id=ue_id, gnb_id=target_gnb_id, cell_type="large",
                                                   nrcgi="311:489|0x01",
                                                   time_ue_stayed_in_cell=98)
        self.ue_history_information_list(id=ue_id, action="commit")
        self.ue_enb_param(id=ue_id, ue_history_list=ue_id)

    def trigger_ho(self, cell_id, ue_id, handover_type="INTRA_NR_HO", event_type="A3"):
        self.ue_meas_cfg_disp(id=ue_id)
        cmd_result = self.read_wtsemu_output_until_re(expected="DETAILED INFO ABOUT NR REPORT CONFIGURATIONS",
                                                      timeout="10")
        measurement = String().get_lines_containing_string(cmd_result, "Event{}".format(event_type))
        measurement_id = String().fetch_from_left(measurement, "   ")
        assert int(measurement_id) > 0

        if handover_type == "INTRA_NR_HO":
            self.ue_measurement_send_nr(id=ue_id, meas_id=measurement_id, event=event_type, srsrp_nr=19, srsrq_nr=10,
                                        phycell_id=cell_id, nrsrp_nr=85, nrsrq_nr=31)
            self.read_wtsemu_output_until_re(expected="Inter-eNB handover", timeout="60")
        elif handover_type == "INTER_RAT_HO":
            self.ue_measurement_send_nr(id=ue_id, meas_id=measurement_id, event="A2", srsrp_nr=11, srsrq_nr=10,
                                        phycell_id=cell_id, nrsrp_nr=85, nrsrq_nr=31)
            time.sleep(3)
            self.ue_meas_cfg_disp(id=ue_id)
            cmd_result = self.read_wtsemu_output_until_re(expected="DETAILED INFO ABOUT NR REPORT CONFIGURATIONS",
                                                          timeout="10")
            measurement_b2 = String().get_lines_containing_string(cmd_result, "EventB2")
            measurement_b2_id = String().fetch_from_left(measurement_b2, "   ")
            self.ue_measurement_send_nr(id=ue_id, meas_id=measurement_b2_id, event="B2", srsrp_nr=19, srsrq_nr=10,
                                        phycell_id=cell_id, nrsrp_nr=85, nrsrq_nr=31)
        else:
            logger.info("\n None of possible HO types was selected")

    def ue_reauthentication(self, ue_id):
        self.ue_reauth(id=ue_id, nr_sec_cap="null|zuc")
        self.read_wtsemu_output_until_re("Reauthentication procedure is complete", timeout="10")

    def change_ue_location(self, ue_id, enb_id, cell_id):
        self.ue_change_location(id=ue_id, enb=enb_id, cell=cell_id)

    def trigger_ue_to_enter_or_exit_idle_state(self, ue_id, entity_triggering, trigger_type):
        """
        Trigger enter/exit to/from idle state

        :param ue_id - UE ID
        :param entity_triggering - ue or enb
        :param trigger_type -
        """
        return self.ue_im_entry(id=ue_id, by=entity_triggering) if trigger_type == "enter" else self.ue_im_exit(
            id=ue_id, by=entity_triggering)

    def measure_average_data_rate_for_multiple_sa_ues(self, first_ue_id, last_ue_id):
        avg_ul_tput_list = []
        avg_dl_tput_list = []
        for ue_id in range(int(first_ue_id), int(last_ue_id), 1):
            avg_ul_tput_list.append(self.measure_average_ul_data_rate(ue_id=ue_id, mode="SA", direction="ul"))
            avg_dl_tput_list.append(self.measure_average_ul_data_rate(ue_id=ue_id, mode="SA", direction="dl"))
        return avg_ul_tput_list, avg_dl_tput_list

    def verify_tput_deviation_is_within_margin_for_multiple_ues(self, first_ue_id, last_ue_id, expected_tput, margin,
                                                                direction):
        avg_ul_tput_list = []
        avg_dl_tput_list = []
        percent_deviation = 0
        if direction == "ul":
            self.measure_average_data_rate_for_multiple_sa_ues(first_ue_id, last_ue_id)
            for tput_val in avg_ul_tput_list:
                difference = abs(int(margin) - int(tput_val))
                BuiltIn().log_to_console(message=" \n {}".format(difference))
                percent_deviation = float((difference / int(expected_tput))) * 100
                BuiltIn().log_to_console(message=" \n {}".format(percent_deviation))
        if direction == "dl":
            self.measure_average_data_rate_for_multiple_sa_ues(first_ue_id, last_ue_id)
            for tput_val in avg_dl_tput_list:
                difference = abs(int(margin) - int(tput_val))
                BuiltIn().log_to_console(message=" \n {}".format(difference))
                percent_deviation = float((difference / int(expected_tput))) * 100
                BuiltIn().log_to_console(message=" \n {}".format(percent_deviation))
        assert percent_deviation < int(margin)

    def trigger_inter_rat_ho_from_lte_to_nr(self, ue_id, target_gnb, target_cell, plmn):
        self.gnb_trigger_inter_rat_handover_to_5g(ue=ue_id, target_gnb=target_gnb, target_cell=target_cell, plmn=plmn)


def read_cfg_capability_variable_from_file(var, path):
    with open(path) as cfg_file:
        for line in cfg_file.readlines():
            key, value, *other = line.split("=")
            if key == var:
                return value
