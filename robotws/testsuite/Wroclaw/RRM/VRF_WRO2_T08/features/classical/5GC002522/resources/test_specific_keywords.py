import datetime
import os.path
import re

from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from taf.gnb.oam.coam.admin import admin
from taf.transport.ssh import ssh

import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output

api = admin()
scf = scf()
current_lua = True


def get_attach_sctp_msgs(pcap, lua=current_lua):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap, lua=lua, shark_filter='',
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
        msgs = finder.find_all([
            PM('SgNBAdditionRequest', name_line_pattern='empty'),
            PM('SgNBAdditionRequestAcknowledge', name_line_pattern='empty'),
            PM('SgNBReconfigurationComplete', name_line_pattern='empty'),
            PM('SNStatusTransfer', name_line_pattern='empty'),
        ], forget_matcher_on_hit=True)
        blog('found messages:')
        if msgs:
            for k in msgs:
                blog(k)
        return msgs


def check_attach_sctp_msgs(in_pcap, lua=current_lua):
    o = get_attach_sctp_msgs(in_pcap, lua)
    assert o.get('SgNBAdditionRequest', False)
    assert o.get('SgNBAdditionRequestAcknowledge', False)
    assert o.get('SgNBReconfigurationComplete', False)
    assert o.get('SNStatusTransfer', False)


def change_to_lower_nrarfcn():
    change_carrierFreqNrCell_on_lte(carrier_fq='629280')
    change_nrarfcn(nrarfcn='629366')


def change_to_middle_nrarfcn():
    change_carrierFreqNrCell_on_lte(carrier_fq='636576')
    change_nrarfcn(nrarfcn='636666')


def change_to_higher_nrarfcn():
    change_carrierFreqNrCell_on_lte(carrier_fq='643968')
    change_nrarfcn(nrarfcn='644000')


def change_to_256QAM_enable():
    change_256QAM('true')


def change_to_256QAM_disable():
    change_256QAM('false')


def change_nrarfcn(nrarfcn):
    dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-552'.format(
        mrbts_id=fixture.get_bts_id(),
        nrbts_id=fixture.get_robot_variable('${tl.gnbs[0].global_bts_id}'))
    parameters_dict = [{'p_name': 'nrarfcn', 'value': nrarfcn, 'dist_name': dist_name}]
    fixture.webUI.change_parameters_values_using_scf(parameters_dict)


def _get_distname(sw_release):
    enb_id = fixture.get_robot_variable('${tl.enbs[0].global_bts_id}')
    if sw_release == 'SBTS20C':
        return 'MRBTS-{id}/LNBTS-{id}/NRDCDPR-0'.format(id=enb_id)
    return 'MRBTS-{id}/LNBTS-{id}/NRDCDPR-0/ENDCDMEASCONF-0'.format(id=enb_id)


def change_carrierFreqNrCell_on_lte(carrier_fq):
    mplane = fixture.get_robot_variable('${tl.enbs[0].x2_link_addr.v4}')
    connection = api.connect_to(bts_host=mplane)
    sw_release = api.get_sw_release_name(connection=connection)
    distname = _get_distname(sw_release)
    api.perform_parameter_recommissioning(dist_name=distname,
                                          parameter='carrierFreqNrCell',
                                          operation='update',
                                          value=carrier_fq,
                                          connection=connection)
    connection.disconnect()
    api.teardown(connection)


def change_256QAM(value):
    dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-552'.format(
        mrbts_id=fixture.get_bts_id(),
        nrbts_id=fixture.get_robot_variable('${tl.gnbs[0].global_bts_id}'))
    if fixture.get_oam_type() == 'megazone_client':
        with fixture.webUI.WebUISeleniumOperations() as selenium:
            selenium.change_list_value(dist_name, 'actDl256Qam', value)
            selenium.validate_changes()
            selenium.activate_changes()
    else:
        with fixture.webUI.WebUIOperations() as coam:
            coam.perform_parameter_recommissioning(dist_name=dist_name,
                                                   parameter='actDl256Qam',
                                                   operation='update',
                                                   value=value,
                                                   skip_parameter_relation_errors=False,
                                                   timeout=900)


def change_mcs_in_config(mcs_value):
    if fixture.get_oam_type() == 'megazone_client':
        timeout_for_selenium = 30
        with fixture.webUI.WebUISeleniumOperations() as selenium:
            selenium.change_text_value('MRBTS-50039/NRBTS-50039/NRCELL-552', 'dllaIniMcs',
                                       mcs_value, timeout=timeout_for_selenium)
            selenium.change_text_value('MRBTS-50039/NRBTS-50039/NRCELL-552', 'ullaIniMcs',
                                       mcs_value, timeout=timeout_for_selenium)
            selenium.validate_changes(timeout=timeout_for_selenium)
            validation_errors = selenium.get_validation_error(timeout=timeout_for_selenium)
            assert not validation_errors, "Following validation errors appears: {}".format(validation_errors)
            selenium.activate_changes()
    else:
        with fixture.webUI.WebUIOperations() as coam:
            coam.perform_parameter_recommissioning(dist_name='MRBTS-50039/NRBTS-50039/NRCELL-552',
                                                   parameter='dllaIniMcs',
                                                   operation='update',
                                                   value=mcs_value,
                                                   timeout=900)
            coam.perform_parameter_recommissioning(dist_name='MRBTS-50039/NRBTS-50039/NRCELL-552',
                                                   parameter='ullaIniMcs',
                                                   operation='update',
                                                   value=mcs_value,
                                                   timeout=900)


@fixture.logged_keyword
def get_mcs_average(pcap_file, field_name='DlData_PdschSendReq.PdschSendReq.mcs'):
    output = TSharkCommandAssembler() \
        .with_pcap_file(pcap_file) \
        .with_attached_lua_scripts() \
        .with_filter(field_name) \
        .inject_additional_parameters('-T fields -e {}'.format(field_name)) \
        .build()
    output = remove_luashark_loading_from_output(output)
    if len(output) == 0:
        fixture.log_message(level='WARN', message="{} logs not found in {}.".format(field_name, pcap_file))
        return 0
    mcs_sum = 0
    mcs_decimals = []
    for mcs in output:
        val = int(mcs, 0)
        mcs_sum += val
        mcs_decimals.append(val)
    fixture.log_message(message="mcs sum = {}".format(mcs_sum))
    fixture.log_message(message="len = {}, output = {}".format(len(output), mcs_decimals))
    return mcs_sum / float(len(output))


@fixture.logged_keyword
def get_ul_dl_mcs_average(pcap_file,
                          ul_field_name='UlData_PuschReceiveReq.grants_item_7.mcs',
                          dl_field_name='DlData_PdschSendReq.PdschSendReq.mcs'):
    ul_avg = get_mcs_average(pcap_file, ul_field_name)
    dl_avg = get_mcs_average(pcap_file, dl_field_name)
    fixture.log_message(message="UL mcs average = {}".format(ul_avg))
    fixture.log_message(message="DL mcs average = {}".format(dl_avg))
    return ul_avg, dl_avg


def check_logcat_attach(logcatdump_path):
    """
    Checks for last 5G connection status from logcat dump from UE, raises exception,
    if file does not contain neccessary prints - probably not collected properly
    or QC-UE 5G modem is not responding from boottime to log collection
    :param str logcatdump_path: path to local(testPC) logcat dump file from UE
    :return: bool:  last is5GConnected from UE
    """
    logcontent = str(fixture.file_to_string(logcatdump_path))
    fiveGstatuses = re.findall("(is5GConnected) (true|false)", logcontent)
    fixture.log_message(message="fiveGstatus_statement: {}, type: {}".format(fiveGstatuses, type(fiveGstatuses)))
    try:
        last5Gstatus = fiveGstatuses[-1][-1]
    except LookupError:
        last5Gstatus = None

    fixture.log_message(message="Is 5G connected: {}".format(last5Gstatus))

    assert last5Gstatus in ['true', 'false'], "There's no 'is5GConnected' statement inside logcat dump"
    assert last5Gstatus == 'true', "Last 5G Connection status is: FALSE - UE not connected to 5G network"
    return True


@fixture.logged_keyword
def get_mcs_from_qcat_file(qcat_file_path):
    mcs_ul_lst = []
    mcs_dl_lst = []
    avg_mcs = []
    fixture.log_message(message="Calculating avgMcs for file: {}".format(qcat_file_path))
    with open(qcat_file_path) as f:
        txt = f.read()
        mcs_ul_line = re.findall(r".*NR5GMAC.*UL since last.*MCS: \d*", txt)
        mcs_dl_line = re.findall(r".*NR5GMAC.*DL since last.*MCS: \d*", txt)
        for line in mcs_ul_line:
            mcs = re.search(r"MCS: (\d*)", line)
            mcs_ul_lst.append(int(mcs.group(1)))
        for line in mcs_dl_line:
            mcs = re.search(r"MCS: (\d*)", line)
            mcs_dl_lst.append(int(mcs.group(1)))
    avg_mcs.append(sum(mcs_ul_lst) / len(mcs_ul_lst))
    avg_mcs.append(sum(mcs_dl_lst) / len(mcs_dl_lst))
    fixture.log_message(message="avgMCS for UL : {0} \navgMCS for DL: {1}".format(avg_mcs[0], avg_mcs[1]))
    return avg_mcs


def start_qxdm_logging(duration, filename, ue_id):
    tl = BuiltIn().get_variable_value("${tl}")
    local_path = BuiltIn().get_variable_value("${OUTPUT_DIR}") + "/"
    ue = tl.ues[int(ue_id)]
    ssh_details = ue.ssh_connection_details
    logs_path = "C:/Users/wro5grrm/auto/logs/"
    file_path = "".join((logs_path, filename, ".hdf"))
    qxdm_location = "C:/Users/wro5grrm/auto/QxdmCommand.py"
    qxdm_cmd = "{} -t {} -p {} -c {} -s {}".format(qxdm_location,
                                                   int(duration),
                                                   ue.diag_com,
                                                   ue.dmc_path,
                                                   file_path)
    qcat_cmd = "\"{}\" -txt {}".format(ue.qcat_path, file_path)
    _ssh = ssh()
    _ssh.connect_to(hostname=ssh_details.addr,
                    username=ssh_details.username,
                    password=ssh_details.password, )
    print(datetime.datetime.now().time())
    _ssh.send_command(command="{} {}".format(ue.python_path, qxdm_cmd))
    _ssh.read_output()
    _ssh.assert_file_exists(file_path)
    _ssh.send_command(command=qcat_cmd)
    _ssh.read_output()
    txt_path = "".join((logs_path, filename, ".txt"))
    _ssh.assert_file_exists(txt_path)
    _ssh.download_file(remote_path=txt_path, local_path="".join((local_path, filename, ".txt")))
    _ssh.read_output()
    assert os.path.exists("".join((local_path, filename, ".txt")))
    return "".join((local_path, filename, ".txt"))


def verify_avg_tput_from_qcat_file(qcat_file_path, ul_tput, dl_tput, deviation):
    ul_tput = int(re.findall(r"^\d*", ul_tput)[0])
    dl_tput = int(re.findall(r"^\d*", dl_tput)[0])
    ul_tput_lst = []
    dl_tput_lst = []
    avg_ul_tput = []
    avg_dl_tput = []
    fixture.log_message(message="Calculating avg Tput for file: {}".format(qcat_file_path))
    with open(qcat_file_path) as f:
        txt = f.read()
        ul_tput_line = re.findall(r".*NR5GMAC.*UL since last.*Avg\s*PHY.{0,7}: \s*\d*", txt)
        dl_tput_line = re.findall(r".*NR5GMAC.*DL since last.*Avg\s*PHY.{0,7}: \s*\d*", txt)
        for line in ul_tput_line:
            print("UL LINE", line)
            tput = re.search(r"Avg\s*PHY.{0,7}: (\s*\d*)", line)
            print("AVG LLLL", tput.group(1))
            ul_tput_lst.append(int(tput.group(1)))
        for line in dl_tput_line:
            print(line)
            tput = re.search(r"Avg\s*PHY.{0,7}: (\s*\d*)", line)
            print("DL TPUT LINNE", tput.group(1))
            dl_tput_lst.append(int(tput.group(1)))

    avg_ul_tput.append(sum(ul_tput_lst) / len(ul_tput_lst))
    avg_dl_tput.append(sum(dl_tput_lst) / len(dl_tput_lst))
    fixture.log_message(message="avg tput for UL : {0} \navg tput for DL: {1}".format(avg_ul_tput[0], avg_dl_tput[0]))
    deviation = float(deviation.rstrip("%")) / 100
    min_ul_tput = int(float(ul_tput) * 1024 - float(ul_tput) * 1024 * deviation)
    max_ul_tput = int(float(ul_tput) * 1024 + float(ul_tput) * 1024 * deviation)
    min_dl_tput = int(float(dl_tput) * 1024 - float(dl_tput) * 1024 * deviation)
    max_dl_tput = int(float(dl_tput) * 1024 + float(dl_tput) * 1024 * deviation)
    if avg_ul_tput[0] in range(min_ul_tput, max_ul_tput) and avg_dl_tput[0] in range(min_dl_tput, max_dl_tput):
        return True

    raise ValueError()
