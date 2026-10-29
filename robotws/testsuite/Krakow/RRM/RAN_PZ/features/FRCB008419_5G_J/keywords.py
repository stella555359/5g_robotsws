from moler.exceptions import CommandFailure
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.resources.enb.enb_keywords import EnbKeywords
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.cu.commissioning import CuCommissioning
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest

tl = BuiltIn().get_variable_value("${tl}")
output_dir = BuiltIn().get_variable_value("${OUTPUT DIR}")

enb_keywords = EnbKeywords()
enbs_global_id_list = [tl.enbs[0].instance_id, tl.enbs[1].instance_id]
enb_proxy_pcs_list = [tl.enbs[0].airscale.common_units[0].lmp_connection.proxy.addr,
                      tl.enbs[1].airscale.common_units[0].lmp_connection.proxy.addr]
enb_addr = tl.enbs[0].airscale.common_units[0].lmp_connection.addr
enb_username = tl.enbs[0].airscale.common_units[0].lmp_connection.username
enb_password = tl.enbs[0].airscale.common_units[0].lmp_connection.password
enb_pcap_path = "/tmp/enb.pcap"
enb_pcap_id = 0
tcpdump_cmds = [None, None]

gnbCommissioning = GnbCommissioning()
cuCommissioning = CuCommissioning()
gnb_global_id = tl.gnbs[0].global_bts_id
x2c_address = tl.gnbs[0].cu.x2c.v4


def change_actEndcAutoX2Setup_parameter_on_both_enbs(value):
    """
    Change value of actEndcAutoX2Setup parameter
    :param value: new value of parameter, true or false
    :return: None
    """
    lnbts_object = "MRBTS-{0}/LNBTS-{0}"
    parameter = "actEndcAutoX2Setup"
    for enb_id, enb_global_id in enumerate(enbs_global_id_list):
        dist_name = lnbts_object.format(enb_global_id)
        enb_keywords.change_enb_parameter(dist_name, parameter, value, enb_id=enb_id)


def configure_LNDAJGNB_on_enb(enb_id=0):
    """
    Change values of LNDAJGNB object parameters
    :param enb_id: Id of eNB
    :return: None
    """
    dist_name = "MRBTS-{0}/LNBTS-{0}/LNADJGNB-1".format(enbs_global_id_list[enb_id])
    enb_keywords.change_enb_parameter(dist_name, "cPlaneIpAddrCtrl", "enbControlled", enb_id=enb_id)
    enb_keywords.change_enb_parameter(dist_name, "administrativeState", "locked", enb_id=enb_id)
    enb_keywords.delete_enb_parameter(dist_name, "cPlaneIpAddr", enb_id=enb_id)
    adjgnbid = enb_keywords.get_enb_parameter(dist_name, "adjGnbId", enb_id=enb_id)
    gnb_id = str(gnb_global_id)[-2:]
    if adjgnbid != gnb_id:
        MolerTest.error(
            "Wrong adjGnbId value (eNB {}):\n expected: {}, current: {}".format(enbs_global_id_list[enb_id], gnb_id,
                                                                                adjgnbid))


def change_actX2ConfigTransfer_parameter(value):
    """
    Change value of actX2ConfigTransfer parameter
    :param value: new value of parameter, true or false
    :return: None
    """
    cuCommissioning.update_one_or_more_parameters_of_delta_plan(
        parameters=[{'name': "actX2ConfigTransfer", 'value': value}])
    cuCommissioning.validate_and_activate_delta_plan(skip_if_no_changes=True)
    cuCommissioning.delete_delta_plan_from_cu()


def change_administrativeState_of_LNADJGNB(value, enb_id=0):
    """
    Change administrativeState of LNADJGNB
    :param value: new value of parameter, true or false
    :param enb_id: Id of eNB
    :return: None
    """
    dist_name = "MRBTS-{0}/LNBTS-{0}/LNADJGNB-1".format(enbs_global_id_list[enb_id])
    parameter = "administrativeState"
    enb_keywords.change_enb_parameter(dist_name, parameter, value, enb_id=enb_id)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def start_collecting_pcap_on_enb(enb_id=0):
    """
    Start collecting pcap on enb
    :param enb_id: Id of eNB
    :return: None
    """
    enb_device = DeviceFactory.get_device("ENB{}_DU0".format(enb_id))
    enb_device.goto_state("FCT")
    tcpdump_cmds[int(enb_id)] = enb_device.get_cmd(cmd_name="tcpdump", cmd_params={
        "options": "-i br1 -n sctp -s0 -w {}".format(enb_pcap_path)})
    tcpdump_cmds[int(enb_id)].start(timeout=999)


def start_collecting_pcap_on_enbs():
    """
    Start collecting pcap on all enbs
    :return: None
    """
    for enb_id in range(len(enbs_global_id_list)):
        start_collecting_pcap_on_enb(enb_id)


@MolerTest.raise_background_exceptions()
def stop_collecting_pcap_on_enb(enb_id=0):
    """
    Stop collecting pcap on enb
    :param enb_id: Id of eNB
    :return: None
    """
    tcpdump_cmds[int(enb_id)].cancel()


def stop_collecting_pcap_on_enbs_and_download():
    """
    Stop collecting pcap on all enbs and copy to test pc
    :return: None
    """
    global enb_pcap_id
    enb_pcap_id += 1
    for enb_id in range(len(enbs_global_id_list)):
        stop_collecting_pcap_on_enb(enb_id)
        copy_pcap(enb_id)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def copy_pcap(enb_id):
    """
    Copy pcap files to test pc
    :param enb_id: Id of eNB
    :return: None
    """
    pcap_file_path = output_dir + "/pcap/enb{}_{}.pcap".format(enb_id, str(enb_pcap_id))
    enb_device = DeviceFactory.get_device("ENB{}_DU0".format(enb_id), initial_state="PROXY_PC")
    enb_device.get_cmd(cmd_name="scp",
                       cmd_params={"source": "{}@{}:{}".format(enb_username, enb_addr, enb_pcap_path),
                                   "dest": enb_pcap_path, "password": enb_password})()
    gnb_device = DeviceFactory.get_device("GNB0_DU0", initial_state="PROXY_PC")
    try:
        gnb_device.get_cmd(cmd_name="mkdir", cmd_params={"path": output_dir + "/pcap"})()
    except CommandFailure:
        pass
    gnb_device.get_cmd(cmd_name="scp",
                       cmd_params={"source": "ute@{}:{}".format(enb_proxy_pcs_list[enb_id], enb_pcap_path),
                                   "dest": pcap_file_path})()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def run_tshark(options, message, enb_id):
    """
    Run tshark command
    :param options: tshark options
    :param message: expected message
    :param enb_id: Id of eNB
    :return: dict with tshark cmd result
    """
    result_file_path = output_dir + "/pcap/{}_enb{}_{}".format(message, enb_id, enb_pcap_id)
    gnb_device = DeviceFactory.get_device("GNB0_DU0", initial_state="PROXY_PC")
    gnb_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": options + " > {}".format(result_file_path)})()
    cat_cmd = gnb_device.get_cmd(cmd_name="cat", cmd_params={"path": result_file_path})
    return cat_cmd()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def check_configuration_transfer_message(tshark_options, message, field, expected, enb_id):
    pcap_file_path = output_dir + "/pcap/enb{}_{}.pcap".format(enb_id, str(enb_pcap_id))
    tshark_options = tshark_options.format(pcap_file_path)
    tshark_result = run_tshark(tshark_options, message, enb_id)
    if not tshark_result['LINES']:
        MolerTest.error("ENBConfigurationTransfer was not sent. Check {} file".format(pcap_file_path))
    else:
        for line in tshark_result['LINES']:
            if line == expected:
                return
    MolerTest.error("{} in {} != {}. Check {} file".format(field, message, expected, pcap_file_path))


def check_ENBConfigurationTransfer(enb_id):
    """
    Verify eNB sends ENBConfigurationTransfer with EN-DCSONConfigurationTransfer request to MME with targetenbNB
    with en-gNB-ID set to gNB ID
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENBConfigurationTransfer"
    field = "en-gNB-ID"
    tshark_options = "-r {} -Y \"s1ap.ENBConfigurationTransfer_element\" -T fields -e s1ap.en_gNB_ID"
    check_configuration_transfer_message(tshark_options, message, field, "0000b0", enb_id)


def check_ENBConfigurationTransfer_reply(enb_id):
    """
    Verify eNB sends ENBConfigurationTransfer with EN-DCSONConfigurationTransfer reply to MME
    with sONInformationReply containing x2-c address
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENBConfigurationTransfer_reply"
    field = "transportLayerAddressIPv4"
    tshark_options = "-r {} -Y \"s1ap.ENBConfigurationTransfer_element\" -T fields -e s1ap.transportLayerAddressIPv4"
    check_configuration_transfer_message(tshark_options, message, field, x2c_address, enb_id)


def check_MMEConfigurationTransfer(enb_id):
    """
    Verify MME sends MMEConfigurationTransfer with EN-DCSONConfigurationTransfer request to eNB with targetenbNB
    with en-gNB-ID set to gNB ID
    :param enb_id: Id of eNB
    :return: None
    """
    message = "MMEConfigurationTransfer"
    field = "en-gNB-ID"
    tshark_options = "-r {} -Y \"s1ap.MMEConfigurationTransfer_element\" -T fields -e s1ap.en_gNB_ID"
    check_configuration_transfer_message(tshark_options, message, field, "0000b0", enb_id)


def check_MMEConfigurationTransfer_reply(enb_id):
    """
    Verify MME sends MMEConfigurationTransfer with EN-DCSONConfigurationTransfer request to eNB with targetenbNB
    with en-gNB-ID set to gNB ID
    :param enb_id: Id of eNB
    :return: None
    """
    message = "MMEConfigurationTransfer_reply"
    field = "transportLayerAddressIPv4"
    tshark_options = "-r {} -Y \"s1ap.MMEConfigurationTransfer_element\" -T fields -e s1ap.transportLayerAddressIPv4"
    check_configuration_transfer_message(tshark_options, message, field, x2c_address, enb_id)


def check_ENDCConfigurationTransfer(enb_id):
    """
    Verify eNB sends ENDCConfigurationTransfer with EN-DCSONConfigurationTransfer request to gNB with targetenbNB
    with en-gNB-ID set to gNB ID
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENDCConfigurationTransfer"
    field = "en-gNB-ID"
    tshark_options = "-r {} -Y \"x2ap.ENDCConfigurationTransfer_element\" -T fields -e s1ap.en_gNB_ID"
    check_configuration_transfer_message(tshark_options, message, field, "0000b0", enb_id)


def check_ENDCConfigurationTransfer_reply(enb_id):
    """
    Verify gNB sends ENDCConfigurationTransfer with EN-DCSONConfigurationTransfer reply to eNB
    with sONInformationReply containing x2-c address
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENDCConfigurationTransfer_reply"
    field = "transportLayerAddressIPv4"
    tshark_options = "-r {} -Y \"x2ap.ENDCConfigurationTransfer_element\" -T fields -e s1ap.transportLayerAddressIPv4"
    check_configuration_transfer_message(tshark_options, message, field, x2c_address, enb_id)


@MolerTest.raise_background_exceptions()
def check_ENDCConfigurationTransfer_reply_not_sent(enb_id):
    """
    Verify ENDCConfigurationTransfer with EN-DCSONConfigurationTransfer reply is not sent to eNB
    with sONInformationReply containing x2-c address
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENDCConfigurationTransfer_reply"
    tshark_options = "-r {} -Y \"x2ap.ENDCConfigurationTransfer_element\" -T fields -e s1ap.transportLayerAddressIPv4"
    pcap_file_path = output_dir + "/pcap/enb{}_{}.pcap".format(enb_id, str(enb_pcap_id))
    tshark_options = tshark_options.format(pcap_file_path)
    tshark_result = run_tshark(tshark_options, message, enb_id)
    for line in tshark_result['LINES']:
        if x2c_address in line:
            MolerTest.error("ENDCConfigurationTransfer_reply was sent. Check {} file".format(pcap_file_path))


def check_ENDCX2SetupRequest(enb_id):
    """
    Verify eNB sends ENDCX2SetupRequest to gNB
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENDCX2SetupRequest"
    field = "macro_eNB_ID"
    tshark_options = "-r {} -Y \"x2ap.ENDCX2SetupRequest_element\" -T fields -e x2ap.macro_eNB_ID"
    check_configuration_transfer_message(tshark_options, message, field, "0272b0", enb_id)


def check_ENDCX2SetupResponse(enb_id):
    """
    Verify gNB sends ENDCX2SetupResponse to eNB
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENDCX2SetupResponse"
    field = "x2ap.gNB_ID"
    tshark_options = "-r {} -Y \"x2ap.ENDCX2SetupResponse_element\" -T fields -e x2ap.gNB_ID"
    check_configuration_transfer_message(tshark_options, message, field, "0,0000b0", enb_id)


def check_ENBConfigurationUpdate(enb_id):
    """
    Verify ENBConfigurationUpdate was sent from eNB to MME with en-gNB-ID set to gNB ID
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENBConfigurationUpdate"
    field = "s1ap.en_gNB_ID"
    tshark_options = "-r {} -Y \"s1ap.ENBConfigurationUpdate_element\" -T fields -e s1ap.en_gNB_ID"
    check_configuration_transfer_message(tshark_options, message, field, "0000b0", enb_id)


def check_ENBConfigurationUpdateAcknowledge(enb_id):
    """
    Verify ENBConfigurationUpdateAcknowledge was sent from MME to eNB
    :param enb_id: Id of eNB
    :return: None
    """
    message = "ENBConfigurationUpdateAcknowledge"
    field = "s1ap.protocolIEs"
    tshark_options = "-r {} -Y \"s1ap.ENBConfigurationUpdateAcknowledge_element\" -T fields -e s1ap.protocolIEs"
    check_configuration_transfer_message(tshark_options, message, field, "0", enb_id)
