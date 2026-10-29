from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory
from moler.exceptions import MolerException
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value, get_builtin_instance
from taf.rfrl.bts.devices.du.pm_counters import GenericPmCounter
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.rfrl.bts.devices.du.logs_collecting.bip_collector import BipCollectorSsh
from ast import literal_eval
from testsuite.Krakow.RRM.RAN_PZ.features.FRCB008072.resources.LicenseKeeper import LicenseKeeper
import time
import os
import re


class SmallCellsKeywords(object):
    """Small Cells pcap validation KWs"""

    def __init__(self):
        self.moler_devices_created = False
        self.dl_prb_validator = None
        self.ul_prb_validator = None
        self.pdschsendreqs_validator = None
        self.csirssendreq_validator = None
        self.bwp_validator = None
        self.cell_info_validator = None
        self.sniff_xn_interface_cmd = None
        self.sniff_x2_interface_cmd = None
        self.gnb_ho_sniffer = None
        self.gnb_ho_sniffer_cmd = None
        self.ax_report_validator = None
        self.enb_mplane_ip = None
        self.global_bts_id = None
        self.fct_username = None
        self.fct_password = None
        self.ssh_bip_collector = None
        self.ue_pc_device = None
        self.ue_serial_number = None
        self.incorrect_packets_limit = 0
        self.incorrect_packets_counter = 0

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _create_moler_devices(self):
        """
        Create all necessary moler devices for SC TL operations.

        :return: None
        """
        if not self.moler_devices_created:
            tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
            ue = BuiltIn().get_variable_value('${tl.ues[0]}')
            ue_conf = ue['UE_POOLS']['TafUeAndroidPool']['inline_config']['ANDROID_UE']['CONSTRUCTOR_PARAMETERS']
            m_plane_with_mask = tl.enbs[0].oam_ip.v4
            self.enb_mplane_ip = m_plane_with_mask.split("/")[0]
            self.global_bts_id = tl.enbs[0].global_bts_id
            self.ue_serial_number = ue_conf['serial_number']
            self.fct_username = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
            self.fct_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
            self.dl_prb_validator = DeviceFactory.get_cloned_device("GNB0", "DL_PRBs_validation",
                                                                    initial_state="PROXY_PC")
            self.ul_prb_validator = DeviceFactory.get_cloned_device("GNB0", "UL_PRBs_validation",
                                                                    initial_state="PROXY_PC")
            self.pdschsendreqs_validator = DeviceFactory.get_cloned_device("GNB0", "pdschsendreqs_validation",
                                                                           initial_state="PROXY_PC")
            self.csirssendreq_validator = DeviceFactory.get_cloned_device("GNB0", "csirssendreq_validation",
                                                                          initial_state="PROXY_PC")
            self.bwp_validator = DeviceFactory.get_cloned_device("GNB0", "BWP_validation", initial_state="FCT")
            self.cell_info_validator = DeviceFactory.get_cloned_device("GNB0", "Cell_info_validation",
                                                                       initial_state="PROXY_PC")
            self.ax_report_validator = DeviceFactory.get_cloned_device("GNB0", "ax_report_validation",
                                                                       initial_state="PROXY_PC")
            self.ue_pc_device = DeviceFactory.get_cloned_device("UE0_PC", "UE_PC_ssh",
                                                                initial_state="UNIX_REMOTE")
            self.moler_devices_created = True

    @MolerTest.raise_background_exceptions()
    def start_blind_scell_addition_observer(self):
        """
        Start blind scell addition observer which collect packets in '/tmp/xn.pcap' file on gNB.

        :return: None
        """
        self._create_moler_devices()
        self.cell_info_validator.goto_state("FCT")
        self.sniff_xn_interface_cmd = self.cell_info_validator.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i any -w {} sctp -v".format("/tmp/xn.pcap")})
        self.sniff_xn_interface_cmd.start(timeout=100)

    @MolerTest.raise_background_exceptions()
    def stop_blind_scell_addition_observer(self):
        """
        Stop blind scell addition observer and download file to '/tmp/xn.pcap' location on PROXY_PC.

        :return: None
        """
        self._create_moler_devices()
        self.sniff_xn_interface_cmd.break_cmd()
        download_files(local_dir="/tmp/", remote_file="xn.pcap", device_name="BWP_validation", remote_dir="/tmp/",
                       from_state="FCT", timeout=100, remove_source_file=True)
        self.cell_info_validator.goto_state("PROXY_PC")

    @MolerTest.raise_background_exceptions()
    def verify_blind_scell_addition_in_ue_context_modification_request(self, nr_cell_identity):
        """
        Verify UeContextModificationRequest packet with blind scell addition procedure request.

        :param nr_cell_identity: target NR scell for blind scell addition procedure
        :return: None
        """
        self.bwp_validator.goto_state("PROXY_PC")
        self.bwp_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "f1ap.UEContextModificationRequest_element&&f1ap.nRCellIdentity" \
            -T fields -e f1ap.nRCellIdentity > result""".format("/tmp/xn.pcap")})(timeout=100)
        self._validate_blind_scell_addition_nr_cell_identity(nr_cell_identity)
        self.bwp_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    @MolerTest.raise_background_exceptions()
    def verify_blind_scell_addition_in_ue_context_modification_response(
            self, phy_cell_id, carrier_bandwidth, subcarrier_spacing, location_and_bandwidth):
        """
        Verify UeContextModificationResponse packet with blind scell addition procedure response.

        :param phy_cell_id: PHY cell id in UeContextModificationResponse
        :param carrier_bandwidth: carrier bandwidth in UeContextModificationResponse
        :param subcarrier_spacing: subcarrier spacing in UeContextModificationResponse
        :param location_and_bandwidth: location and bandwidth in UeContextModificationResponse
        :return: None
        """
        self.bwp_validator.goto_state("PROXY_PC")
        self.bwp_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "f1ap.UEContextModificationResponse_element&&nr-rrc.physCellId=={}\
            &&nr-rrc.sCellConfigDedicated_element" -T fields -e nr-rrc.locationAndBandwidth \
            -e nr-rrc.subcarrierSpacing -e nr-rrc.carrierBandwidth > result""".
                                   format("/tmp/xn.pcap", str(phy_cell_id))})(timeout=100)
        self._validate_blind_scell_addition_bwp(location_and_bandwidth, carrier_bandwidth, subcarrier_spacing)
        self.bwp_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    @MolerTest.raise_background_exceptions()
    def validate_dl_prb_number(self, expected_number_of_prb, tolerance="10%", sub_cell_id=None):
        """
        Verify if average number of PRB in all 'dldata_pdschsendreq' packets is in defined tolerance.

        :param int expected_number_of_prb: excepted average of PRB
        :param string tolerance: percent tolerance value (e.g. 15%)
        :param int sub_cell_id: id of sub cell for which prbs are validated
        :return: None
        """
        self._create_moler_devices()
        filter_sub_cell = "3gpp.subcellid=={}&&".format(sub_cell_id) if sub_cell_id else ""
        tshark_cmd = self.dl_prb_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "{}!(3gpp.rnti==65535)&&dldata_pdschsendreq" -T fields -e \
            DlData_PdschGrant.numOfPrb > result""".format(self._get_bip_pcap_path(), filter_sub_cell)})
        tshark_cmd(timeout=300)
        self._validate_prb_number(expected_number_of_prb=int(expected_number_of_prb), direction="DL",
                                  tolerance=int(tolerance.replace("%", "")))
        self.dl_prb_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    @MolerTest.raise_background_exceptions()
    def validate_ul_prb_number(self, expected_number_of_prb, tolerance="10%"):
        """
        Verify if average number of PRB in all 'uldata_puschreceivereq' packets is in defined tolerance.

        :param int expected_number_of_prb: excepted average of PRB
        :param string tolerance: percent tolerance value (e.g. 15%)
        :return: None
        """
        self._create_moler_devices()
        tshark_cmd = self.ul_prb_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y "uldata_puschreceivereq" -T fields -e UlData_puschReceiveReqGrant_t.numOfPrb \
              > result""".format(self._get_bip_pcap_path())})
        tshark_cmd(timeout=300)
        self._validate_prb_number(expected_number_of_prb=int(expected_number_of_prb), direction="UL",
                                  tolerance=int(tolerance.replace("%", "")))
        self.ul_prb_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    @MolerTest.raise_background_exceptions()
    def check_if_string_exist_in_syslog(self, pattern_string):
        """
        Check if pattern found in syslog file.

        :param string pattern_string: expected pattern (regex) in syslog file
        :return: None
        """
        self._create_moler_devices()
        syslog_directory = os.path.join(get_builtin_value('OUTPUT_DIR'), "moler",
                                        get_builtin_value("TEST NAME")).replace(" ", "_")
        syslog_path = os.path.join(syslog_directory, "moler.GNB0_DU0_SYSLOG.raw.log")
        with open(syslog_path) as f:
            syslog_content = f.readlines()
        for line_id, line_content in enumerate(syslog_content):
            if re.match(pattern_string, line_content):
                MolerTest.info("Pattern -> {} found in syslog (line -> {})".format(pattern_string, line_id))
                break
        else:
            MolerTest.error("Pattern -> {} NOT found in syslog".format(pattern_string), raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def verify_rrc_reconfiguration_counters(self):
        """
        Verify if RRC reconfiguration counters values have non 0 value in lase pm interval.

        :return: None
        """
        self._create_moler_devices()
        gnb_pm_counters = GenericPmCounter()
        counter_ids = ["M55166C00001", "M55166C00003"]
        counter_ids_string = "{},{}".format(counter_ids[0], counter_ids[1])
        counters_values = gnb_pm_counters.get_counter(counter_ids_string)["BTS"]["CELLS"]["NRCELL-1"]["NRCCD"]
        for counter_id in counter_ids:
            time_stamps = list(counters_values[counter_id].keys())
            time_stamps.sort()
            recent_value = counters_values[counter_id][time_stamps[-1]]
            if recent_value > 0:
                MolerTest.info("Counter {} value is above 0 ({} != 0)".format(counter_id, recent_value))
            else:
                MolerTest.error("Counter {} value is equal 0 ({} == 0). RRC reconfiguration not occurred".
                                format(counter_id, recent_value), raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def change_enb_default_ln_rel_gnb_cell_id(self, value):
        """
        Change 'defaultLnRelGnbCellId' parameter value in enb configuration.

        :param string value: value of 'defaultLnRelGnbCellId' parameter.
        :return: None
        """
        self._create_moler_devices()
        dist_name = "MRBTS-{}/LNBTS-{}/LNCEL-1".format(self.global_bts_id, self.global_bts_id)
        enb_bts = admin()
        enb_bts.connect_to(bts_host=self.enb_mplane_ip)
        enb_bts.perform_parameter_recommissioning(dist_name=dist_name, parameter="defaultLnRelGnbCellId",
                                                  operation="update", value=value, skip_parameter_relation_errors=True)
        enb_bts.teardown()

    @MolerTest.raise_background_exceptions()
    def perform_anchor_enb_commissioning(self):
        """
        Perform anchor ENB commissioning with default configuration.

        :return: None
        """
        self._create_moler_devices()
        enb_scf_path = os.path.join(DefaultFileLocation().get_commissioning_dir(), "anchor_ENB_SCF.xml")
        enb_bts = admin()
        enb_bts.connect_to(bts_host=self.enb_mplane_ip)
        enb_bts.perform_commissioning(scf_file=enb_scf_path, skip_parameter_relation_errors=True, should_activate=True)
        enb_bts.teardown()

    @MolerTest.raise_background_exceptions()
    def start_bip_logs_collection(self, bts_id=0):
        """
        Start BIP logs collection with gnb mirroring scripts via ssh connection.

        :param bts_id: BTS id - related to Test Line configuration.
        :return: None
        """
        self._create_moler_devices()
        self.ssh_bip_collector = BipCollectorSsh(bts_device_name="GNB{}_DU0".format(bts_id))
        self.ssh_bip_collector.upload_mirroring_scripts()
        self.ssh_bip_collector.start_log_capturing(
            mirroring_script_params={"number_of_files": 1, "file_size_mbytes": 100})

    @MolerTest.raise_background_exceptions()
    def stop_bip_logs_collection(self):
        """
        Stop BIP logs collection.

        :return: None
        """
        self._create_moler_devices()
        self.ssh_bip_collector.stop_log_capturing()

    @MolerTest.raise_background_exceptions()
    def download_collected_bip_logs(self):
        """
        Download BIP logs pcap file to output directory.

        :return: None
        """
        self._create_moler_devices()
        self.ssh_bip_collector.download_bip_logs(download_dir=get_builtin_value('OUTPUT_DIR'))

    @MolerTest.raise_background_exceptions()
    def validate_guard_band_in_pdschsendreqs(self, sub_cell_id, even_sfn_rat_bitmap, even_sfn_rgb_size,
                                             odd_sfn_rat_bitmap, odd_sfn_rgb_size):
        """
        Validate guard band interval parameters in pdschsendreqs packets.

        :param sub_cell_id: ID of sub cell
        :param even_sfn_rat_bitmap: rat0bitmap parameter value for even sfn and slot=0
        :param even_sfn_rgb_size: rgbsize parameter value for even sfn and slot=0
        :param odd_sfn_rat_bitmap: rat0bitmap parameter value for odd sfn and slot!=0
        :param odd_sfn_rgb_size: rgbsize parameter value for odd sfn and slot!=0
        :return: None
        """
        self._create_moler_devices()
        tshark_cmd_string = """ -r {} -Y "(3gpp.subcellid=={}) && dldata_pdschsendreq && \
        !(3gpp.rnti==65535)&&DlData_PdschGrant.mcs==27" -T fields -e 3gpp.slot  -e 3gpp.sfn \
        -e DlData_PdschGrant.rat0Bitmap -e DlData_PdschGrant.rbgSize -e DlData_PdschGrant.rbgSizeFirst > result"""
        tshark_cmd = self.pdschsendreqs_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": tshark_cmd_string.format(self._get_bip_pcap_path(), sub_cell_id)})
        tshark_cmd(timeout=300)
        self._validate_guard_band_in_pdschsendreqs_tshark_result(even_sfn_rat_bitmap, even_sfn_rgb_size,
                                                                 odd_sfn_rat_bitmap, odd_sfn_rgb_size)
        self.pdschsendreqs_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    @MolerTest.raise_background_exceptions()
    def validate_guard_band_in_csirssendreq(self, sub_cell_id):
        """
        Validate guard band interval parameters in csirssendreq packets.

        :param sub_cell_id: ID of sub cell
        :return: None
        """
        self._create_moler_devices()
        tshark_cmd_string = """-r {} -Y "3gpp.subcellid=={} && dldata_csirssendreq" -T fields \
        -e DlData_CsiRsResource_t.startSymbol -e  DlData_CsiRsResource_t.startPrb -e DlData_CsiRsResource_t.numOfPrb \
        > result"""
        tshark_cmd = self.csirssendreq_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": tshark_cmd_string.format(self._get_bip_pcap_path(), sub_cell_id)})
        tshark_cmd(timeout=300)
        self._validate_guard_band_in_csirssendreq_tshark_result()
        self.csirssendreq_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    @MolerTest.raise_background_exceptions()
    def set_asym_bandwidth_capabilities_on_ue(self, ue_capabilities_file_path,
                                              pcat_path="/cygdrive/c/Program Files (x86)/Qualcomm/PCAT/bin/"):
        """
        Set asymmetric bandwidth UE capabilities with PCAT tool.

        :param ue_capabilities_file_path: path to UE capabilities file
        :param pcat_path: destination folder of PCAT.exe file
        :return: None
        """
        pcat_cmd = "PCAT.exe -PLUGIN EE -DEVICE {} -FS PRI -MODE COPY -TYPE FILE -FROM '{}'" \
                   " -TO /nv/item_files/modem/nr5g/RRC/cap_control_asym_bw"
        license_keeper = LicenseKeeper()
        license_keeper.get_pcat_licence()
        try:
            self.ue_pc_device.get_cmd(cmd_name="run_script",
                                      cmd_params={"script_command": "cd '{}'".format(pcat_path)})()
            self.ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={
                "script_command": pcat_cmd.format(self.ue_serial_number, ue_capabilities_file_path)})()
        except Exception as e:
            MolerTest.warning("Following exception occurred during UE capabilities change: {}".format(e))
        finally:
            license_keeper.release_pcat_licence()
            license_keeper.logout()

    @MolerTest.raise_background_exceptions()
    def unset_asym_bandwidth_capabilities_on_ue(self, pcat_path="/cygdrive/c/Program Files (x86)/Qualcomm/PCAT/bin/"):
        """
        Set basic bandwidth UE capabilities with PCAT tool.

        :param pcat_path: destination folder of PCAT.exe file
        :return: None
        """
        pcat_cmd = "PCAT.exe -PLUGIN EE -DEVICE {} -FS PRI -MODE DELETE -TYPE FILE" \
                   " -VALUE /nv/item_files/modem/nr5g/RRC/cap_control_asym_bw"
        license_keeper = LicenseKeeper()
        license_keeper.get_pcat_licence()
        try:
            self.ue_pc_device.get_cmd(cmd_name="run_script",
                                      cmd_params={"script_command": "cd '{}'".format(pcat_path)})()
            self.ue_pc_device.get_cmd(cmd_name="run_script",
                                      cmd_params={"script_command": pcat_cmd.format(self.ue_serial_number)})()
            self.ue_pc_device.get_cmd(cmd_name="run_script",
                                      cmd_params={"script_command": "adb -s {} reboot".format(self.ue_serial_number)})()
            time.sleep(60)
        except Exception as e:
            MolerTest.warning("Following exception occurred during UE capabilities change: {}".format(e))
        finally:
            license_keeper.release_pcat_licence()
            license_keeper.logout()

    @staticmethod
    def verify_cell_id(cell_type, cell_id):
        """
        Verify UE cell ID and cell type.

        :param cell_type: expected cell type (LTE/NR/NR-LTE)
        :param cell_id: expected cell ID
        :return: None
        """
        ue = get_builtin_instance("ue")
        cell_info = ue.get_ue_info("UE", "CELL_INFO")
        if cell_info["cellType"] == "NR":
            actual_cell_id = cell_info["nci"]
        else:
            actual_cell_id = cell_info["ci"]
        if cell_type == cell_info["cellType"] and int(cell_id) == actual_cell_id:
            MolerTest.info("Cell type and cell ID as expected")
        else:
            MolerTest.error("Cell type -> expected: {} | actual: {}".format(cell_type, cell_info["cellType"]))
            MolerTest.error("Cell id -> expected: {} | actual: {}".format(cell_id, actual_cell_id))
            MolerTest.error("Incorrect cell type or cell ID. Check UE settings", raise_exception=True)

    def start_ho_sniffer(self, bts_id=0):
        """
        Start sniffer on gNB to monitor handover procedure events.

        :param bts_id: BTS id - related to Test Line configuration.
        :return: None
        """
        self.gnb_ho_sniffer = DeviceFactory.get_device("GNB{}".format(bts_id))
        self.gnb_ho_sniffer.goto_state("FCT")
        self.gnb_ho_sniffer_cmd = self.gnb_ho_sniffer.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i any -w {} sctp -v".format("/tmp/ax_report.pcap")})
        self.gnb_ho_sniffer_cmd.start(timeout=100)

    def stop_ho_sniffer_and_download_pcap(self, bts_id=0):
        """
        Stop handover sniffer on gNB and download result file.

        :param bts_id: BTS id - related to Test Line configuration.
        :return: None
        """
        self.gnb_ho_sniffer_cmd.break_cmd()
        download_files(local_dir="/tmp/", remote_file="ax_report.pcap", device_name="GNB{}".format(bts_id),
                       remote_dir="/tmp/", from_state="FCT", timeout=100, remove_source_file=True)

    def verify_a2_measurement_report(self, serving_phy_cell_id):
        """
        Verify if A2 measurement report contains valid physical cell ID.

        :param serving_phy_cell_id: expected cell ID
        :return: None
        """
        self._create_moler_devices()
        self.ax_report_validator.goto_state("PROXY_PC")
        tshark_cmd_string = """-r {} -Y "f1ap&&nr-rrc.measResultServingMOList" \
        -T fields -e nr-rrc.physCellId > result"""
        tshark_cmd = self.ax_report_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": tshark_cmd_string.format("/tmp/ax_report.pcap")})
        tshark_cmd(timeout=300)
        self._validate_a2_measurement_report(serving_phy_cell_id)
        self.csirssendreq_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    def verify_a3_measurement_report(self, serving_phy_cell_id, neigh_phy_cell_id):
        """
        Verify if A3 measurement report contains valid physical serving cell ID and neighbour cell ID.

        :param serving_phy_cell_id: expected cell ID
        :param neigh_phy_cell_id: expected neighbour cell ID
        :return: None
        """
        self._create_moler_devices()
        self.ax_report_validator.goto_state("PROXY_PC")
        tshark_cmd_string = """-r {} -Y "f1ap&&nr-rrc.measResultServingMOList&&nr-rrc.measResultNeighCells" \
        -T fields -e nr-rrc.physCellId > result"""
        tshark_cmd = self.ax_report_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": tshark_cmd_string.format("/tmp/ax_report.pcap")})
        tshark_cmd(timeout=300)
        self._validate_a3_measurement_report(serving_phy_cell_id, neigh_phy_cell_id)
        self.csirssendreq_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    def verify_handover_request(self, nr_ci):
        """
        Verify if handover request contains valid NR-CI value.

        :param nr_ci: expected NR-CI value
        :return: None
        """
        self._create_moler_devices()
        self.ax_report_validator.goto_state("PROXY_PC")
        tshark_cmd_string = """-r {} -Y "xnap&&xnap.NR_Cell_Identity" -T fields -e xnap.NR_Cell_Identity > result"""
        tshark_cmd = self.ax_report_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": tshark_cmd_string.format("/tmp/ax_report.pcap")})
        tshark_cmd(timeout=300)
        self._validate_handover_request(nr_ci)
        self.csirssendreq_validator.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})()

    def _check_expected_param_value(self, param_name, param_value, expected_value, packet_id):
        if param_value == expected_value:
            MolerTest.info("Packet {} has correct {} value. Actual = {} Expected = {}".
                           format(packet_id, param_name, param_value, expected_value))
        elif self.incorrect_packets_counter < self.incorrect_packets_limit:
            self.incorrect_packets_counter += 1
            MolerTest.warning("Packet {} has incorrect {} value. Actual = {} Expected = {}".
                              format(packet_id, param_name, param_value, expected_value))
        else:
            MolerTest.error("Packet {} has incorrect {} value. Actual = {} Expected = {}".
                            format(packet_id, param_name, param_value, expected_value), raise_exception=True)

    @staticmethod
    def _get_bip_pcap_path():
        bip_log_path = get_builtin_value('OUTPUT_DIR')
        for file_name in os.listdir(bip_log_path):
            if "L2L1_bip" in file_name:
                return os.path.join(bip_log_path, file_name)
        else:
            MolerTest.error("BIP pcap not found in {}".format(bip_log_path), raise_exception=True)

    @staticmethod
    def _validate_result_file(file_lines):
        if len(file_lines) >= 1:
            MolerTest.info("Packets details extracted with success.")
        else:
            MolerTest.error("Cannot extract packets details from pcap file. Requested fields don't exist or "
                            "pcap file is damaged", raise_exception=True)

    @staticmethod
    def _show_prb_values_distribution(user_prb_values):
        prb_values_distribution = {}
        for value in user_prb_values:
            if value in prb_values_distribution.keys():
                prb_values_distribution[value] = prb_values_distribution[value] + 1
            else:
                prb_values_distribution.update({value: 1})
        for unique_prb in prb_values_distribution.keys():
            unique_prb_count = prb_values_distribution[unique_prb]
            MolerTest.info("PRB [{}] occurrences -> {} | ({:.2f}) %".format(unique_prb, unique_prb_count,
                                                                            unique_prb_count * 100 / len(
                                                                                user_prb_values)))

    def _validate_prb_number(self, expected_number_of_prb, direction, tolerance):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        used_prb_values = []
        for line in result_file_content:
            try:
                used_prb_values.append(int(line))
            except ValueError:
                continue
        self._show_prb_values_distribution(used_prb_values)
        lower_limit = expected_number_of_prb * ((100 - tolerance) / 100)
        upper_limit = expected_number_of_prb * ((100 + tolerance) / 100)
        average_prb_value = sum(used_prb_values) / len(used_prb_values)
        if lower_limit < average_prb_value < upper_limit:
            MolerTest.info("Average number of prb = {:.2f} in {} direction in range [{} - {}]".
                           format(average_prb_value, direction, lower_limit, upper_limit))
        else:
            MolerTest.error("Average number of prb = {:.2f} in {} direction NOT in range [{} - {}]".
                            format(average_prb_value, direction, lower_limit, upper_limit), raise_exception=True)

    def _validate_guard_band_in_pdschsendreqs_tshark_result(self, even_sfn_rat_bitmap, even_sfn_rgb_size,
                                                            odd_sfn_rat_bitmap, odd_sfn_rgb_size):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        self.incorrect_packets_limit = 10
        for packet_id, line in enumerate(result_file_content):
            param_values = re.split(r"\s+", line)
            slot = int(param_values[0])
            sfn = int(param_values[1])
            rat0bitmap = int(param_values[2])
            rgbsize = int(param_values[3])
            rgbsizefirst = int(param_values[4])
            if slot == 0 and sfn % 2 == 0:
                self._check_expected_param_value("rat0Bitmap", rat0bitmap, int(even_sfn_rat_bitmap), packet_id)
                self._check_expected_param_value("rbgSize", rgbsize, int(even_sfn_rgb_size), packet_id)
                self._check_expected_param_value("rbgSizeFirst ", rgbsizefirst, int(even_sfn_rgb_size), packet_id)
            else:
                self._check_expected_param_value("rat0Bitmap", rat0bitmap, int(odd_sfn_rat_bitmap), packet_id)
                self._check_expected_param_value("rbgSize", rgbsize, int(odd_sfn_rgb_size), packet_id)
                self._check_expected_param_value("rbgSizeFirst ", rgbsizefirst, int(odd_sfn_rgb_size), packet_id)
        self.incorrect_packets_limit = 0
        self.incorrect_packets_counter = 0

    def _validate_guard_band_in_csirssendreq_tshark_result(self):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        for packet_id, line in enumerate(result_file_content):
            start_symbol, start_prb, num_of_prb = re.split(r"\s+", line)[:-1]
            start_symbol = start_symbol.split(",")
            start_prb = start_prb.split(",")
            num_of_prb = num_of_prb.split(",")
            if len(start_symbol) % 2 != 0:
                MolerTest.error("Incorrect number of csirssendreq items. {}%2 != 0".format(len(start_symbol)),
                                raise_exception=True)
            for k in range(0, len(start_symbol), 2):
                if int(start_symbol[k]) == 13:
                    self._check_expected_param_value("startPrb", int(start_prb[k]), 0, packet_id)
                    self._check_expected_param_value("numOfPrb", int(num_of_prb[k]), 48, packet_id)
                    self._check_expected_param_value("startPrb", int(start_prb[k + 1]), 64, packet_id)
                    try:
                        self._check_expected_param_value("numOfPrb", int(num_of_prb[k + 1]), 96, packet_id)
                    except MolerException:
                        # 2 values of numOfPrb parameter in last packet element are allowed
                        self._check_expected_param_value("numOfPrb", int(num_of_prb[k + 1]), 40, packet_id)
                else:
                    self._check_expected_param_value("startPrb", int(start_prb[k]), 0, packet_id)
                    self._check_expected_param_value("numOfPrb", int(num_of_prb[k]), 50, packet_id)
                    self._check_expected_param_value("startPrb", int(start_prb[k + 1]), 55, packet_id)
                    self._check_expected_param_value("numOfPrb", int(num_of_prb[k + 1]), 105, packet_id)

    def _validate_blind_scell_addition_bwp(self, location_and_bandwidth, carrier_bandwidth, sub_carrier_spacing):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        for packet_id, line in enumerate(result_file_content):
            param_values = re.split(r"\s+", line)[:-1]
            self._check_expected_param_value("location_and_bandwidth", param_values[0].split(",")[-1],
                                             location_and_bandwidth, packet_id)
            self._check_expected_param_value("carrier_bandwidth", param_values[-1].split(",")[-1], carrier_bandwidth,
                                             packet_id)
            self._check_expected_param_value("phy_cell_id", param_values[1].split(",")[-1], sub_carrier_spacing,
                                             packet_id)

    def _validate_blind_scell_addition_nr_cell_identity(self, nr_cell_identity):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        for packet_id, line in enumerate(result_file_content):
            self._check_expected_param_value("nr_cell_identity", int(line), int(nr_cell_identity), packet_id)

    def _validate_a2_measurement_report(self, serving_phy_cell_id):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
            for packet_id, line in enumerate(result_file_content):
                self._check_expected_param_value("serving_phy_cell_id", int(line), int(serving_phy_cell_id), packet_id)

    def _validate_a3_measurement_report(self, serving_phy_cell_id, neigh_phy_cell_id):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
            for packet_id, line in enumerate(result_file_content):
                phy_cell_ids = line.split(",")
                self._check_expected_param_value("serving_phy_cell_id", int(phy_cell_ids[0]), int(serving_phy_cell_id),
                                                 packet_id)
                self._check_expected_param_value("neigh_phy_cell_id", int(phy_cell_ids[1]), int(neigh_phy_cell_id),
                                                 packet_id)

    def _validate_handover_request(self, nr_ci):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
            for packet_id, line in enumerate(result_file_content):
                self._check_expected_param_value("nr-CI", literal_eval(line), literal_eval(nr_ci), packet_id)
