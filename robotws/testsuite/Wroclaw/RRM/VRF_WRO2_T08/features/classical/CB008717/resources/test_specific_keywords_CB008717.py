import os
import re
import shutil
import tarfile
import time

from robot.libraries.BuiltIn import BuiltIn
from ta_attenuator import ta_attenuator
from taf.analyzer.pdml import PdmlReader
from taf.collectors.btslog import btslog
from taf.collectors.core import core
from taf.collectors.tcpdump import tcpdump
from taf.converters.pcaptopdml import pcaptopdml
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.ue import *
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners import clear_admin_api_logs
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import wait_until_function_succeeds

_attenuator = ta_attenuator()
_builtin = BuiltIn()
_ute_tshark = ute_tshark()
_ute_ue = ue()
_ssh = ssh()
core = core()
btslog = btslog()
admin = admin()
tl = _builtin.get_variable_value("${tl}")
ue1 = tl.ues[0]
ssh_details = ue1.ssh_connection_details
pcaptopdml = pcaptopdml()
pcap_file = "PsCellAddition"
pdml_file = "PsCellAddition.pdml"

UES_INFO = {
    "UE_1": {"name": "QUALCOMM", "adb_id": "QUALCOMM"},
}


def create_syslog_collector(filename):
    executor = {"host": "10.42.71.23",
                "user": "ute",
                "password": "Ut3pa5s#1be1"}
    btslog.create_btslog_collector(name="btslog", target_file_name=filename,
                                   executor=executor)
    btslog.setup_collectors("btslog")


def turn_on_apn(alias, apn_type):
    _ute_ue.disconnect_additional_pdn(alias, apn_type)
    _ute_ue.connect_additional_pdn(alias, apn_type)


def turn_off_apn(alias, apn_type):
    _ute_ue.disconnect_additional_pdn(alias, apn_type)


def start_syslog():
    btslog.start_collectors("btslog")
    btslog.set_global_alias("btslog")


def stop_and_collect_syslog(file_dir):
    btslog.stop_collectors("btslog")
    btslog.collect_collectors("btslog", target_dir=file_dir)
    btslog.teardown_collectors("btslog")
    extract_file()
    file_path = get_path()
    path = file_path + "/btslog/btslogs_merged"
    LOG_files = [f for f in os.listdir(file_path + "/btslog/") if f.endswith('.LOG')]
    log_files_iter = iter(LOG_files)
    if len(LOG_files) == 0:
        raise ValueError('Should be minimum one LOG file in the current directory.')
    if not os.path.exists(path):
        os.mkdir(path)
    with open(os.path.join(path, "btslog.LOG"), 'w') as f:
        while True:
            try:
                iterator = next(log_files_iter)
                for line in file_reader(file_path + "/btslog/" + iterator):
                    f.write(line)
            except StopIteration:
                break


def clear_admin_logs():
    clear_admin_api_logs()


def extract_file():
    file_path = get_path()
    with tarfile.open("{}/btslog/{}".format(file_path, "BtsLog.tgz", 'r')) as tar:
        tar.extractall(file_path + "/btslog/")


def supervision_timer_retry_timer(number_of_rt_st):
    file_path = get_path()
    patrn1 = "SupervisionTimer started"
    patrn2 = "RetryTimer started"
    number_of_st = 0
    number_of_rt = 0
    supervision = []
    retry = []
    for line in file_reader("{}{}".format(file_path, "/btslog/btslogs_merged/btslog.LOG")):
        if re.search(patrn1, line):
            supervision.append(line.split(' ')[2][:-4])
        elif re.search(patrn2, line):
            retry.append(line.split(' ')[2][:-4])
        elif number_of_rt_st == 64:
            number_of_st = len(supervision)
            number_of_rt = len(retry)
    if number_of_rt < number_of_rt_st and number_of_st < number_of_rt_st:
        raise Exception("Failure due to wrong number of measIDs. Value should be bigger then 64")
    if retry and supervision:
        return True
    else:
        raise Exception("Supervision or Retry timer - ", " NOT FOUND")


def check_tput_on_pcell_and_pscell_btslog():
    file_path = get_path()
    tput_pattern = re.compile(r'INF/L2HiCu.*?STATS-DL-PDCP.*?inB:(\d[1-9]+)')
    log = file_path + "/btslog/btslogs_merged/" + "btslog.LOG"
    with open(log, 'r') as f:
        matches = tput_pattern.findall(f.read())
        assert matches, f"No tput matching prints in log {log}"


def verify_syslog(parameters):
    file_path = get_path()
    for key, value in parameters.items():
        matches = False
        for line in file_reader("{}{}".format(file_path, "/btslog/btslogs_merged/btslog.LOG")):
            if re.search(value, line):
                matches = True
        if matches is False:
            raise Exception(f'{key} not found in Syslog')


def create_tcpdump_collector():
    executor = {"host": "192.168.255.129",
                "user": "toor4nsn",
                "password": "oZPS0POrRieRtu"}
    tcpdump().create_tcpdump_collector(name="tcpdump", target_file_name=pcap_file, options="sctp -i any -p",
                                       executor=executor)
    core.setup_collectors("tcpdump")


def start_tcp_dump():
    core.start_collectors("tcpdump")
    tcpdump().set_global_alias("tcpdump")


def stop_and_collect_tcp_dump(file_dir):
    core.stop_collectors("tcpdump")
    core.collect_collectors("tcpdump", target_dir=file_dir)
    core.teardown_collectors("tcpdump")


def attach(ue):
    blog("Call is ongoing...")
    _ute_ue.attach_ue(ue)
    blog("{} attached!".format(ue))


def start_dl(ue, duration, dt_name):
    dl_value = "1000mbits/sec"
    _ute_ue.start_data_transfer(dt_name=dt_name, ue_alias=ue, duration=duration,
                                direction="dl", throughput=dl_value, protocol="udp", packet_size="1400")
    blog("Verifying DL tput for {}".format(ue))


def stop_traffic(dt_name):
    _ute_ue.stop_data_transfer(dt_name)


def start_ul(ue):
    ul_value = "1000 MBytes/sec"
    _ute_ue.start_data_transfer(dt_name="DT_UL", ue_alias=ue, duration="10s",
                                direction="ul", throughput=ul_value, protocol="udp", packet_size="1400")
    _ute_ue.await_data_transfer_finish(dt_name="DT_UL")
    blog("Verifying UL tput for {}".format(ue))
    _ute_ue.stop_data_transfer("DT_UL")


def perform_handover(cell1, cell2, ue, att):
    time.sleep(5)
    blog("Change attenuation for HO")
    set_attenuation_for_cell(cell_alias=cell1, attenuation=att)
    set_attenuation_for_cell(cell_alias=cell2, attenuation="0db")
    time.sleep(10)


def collect_scf_before_test():
    blog("Collecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(get_path(), 'backup_scf.xml')


def perform_recommissioning(srbinactivity, reportamount, a4threshold):
    blog("Setting parameters for test...")
    with Admin5G() as admin_api:
        admin_api.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859", parameter="srbInactivityTimerSA",
                                                    operation="update", value=srbinactivity,
                                                    skip_parameter_relation_errors=True,
                                                    should_activate=True, timeout=300)
        admin_api.perform_parameter_recommissioning("MRBTS-50859/NRBTS-50859/NRCELL-592",
                                                    parameter="reportAmountNrDc", operation="update",
                                                    value=reportamount,
                                                    skip_parameter_relation_errors=True,
                                                    should_activate=True, timeout=300)
        perform_delta(a4threshold)


def perform_delta(a4threshold, *args):
    if len(args) == 0:
        path = "NRHOIF-1"
        execute_delta(a4threshold, path)
    else:
        for path in args:
            execute_delta(a4threshold, path)


def execute_delta(a4threshold, path):
    try:
        admin.setup_admin()
        admin.create_delta("path")
        admin.append_complex_item_to_delta(f"MRBTS-50859/NRBTS-50859/NRCELL-592/{path}", "a4MeasNrDcSsbRsrp",
                                           a4HysteresisNrDcSsbRsrp="0",
                                           a4TimeToTriggerNrDcSsbRsrp="ms100",
                                           a4ThresholdNrDcSsbRsrp=a4threshold,
                                           delta_id="path")
        admin.save_delta('delta.json', "path")
        admin.perform_delta_recommissioning(delta_file=admin.get_delta("path"), skip_parameter_relation_errors=True)
    finally:
        admin.teardown_admin()


def turn_off_fwa_ue():
    try:
        admin.setup_admin()
        admin.create_delta("path")
        admin.append_parameter_delete_to_delta("MRBTS-50859/NRBTS-50859", "identifiedFwaUeList", delta_id="path")
        admin.save_delta('delta.json', "path")
        admin.perform_delta_recommissioning(delta_file=admin.get_delta("path"), skip_parameter_relation_errors=True)
    finally:
        admin.teardown_admin()


def turn_on_fwa_ue():
    try:
        admin.setup_admin()
        parameter = [
            {
                "parameterName": "identifiedFwaUeList",
                "operation": "update",
                "value": [99]
            }]
        admin.perform_object_recommissioning(
            dist_name="MRBTS-50859/NRBTS-50859", parameter=parameter, operation="update",
            skip_parameter_relation_errors=True
        )
    finally:
        admin.teardown_admin()


def verify_administrative_state(value, *args):
    blog("Verifying administrative state...")
    for cell in args:
        with Admin5G() as admin_api:
            admin_api.perform_parameter_recommissioning(f"MRBTS-50859/NRBTS-50859/{cell}",
                                                        parameter="administrativeState",
                                                        operation="update", value=value,
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True, timeout=300)


def change_one_parameter(parameters):
    blog("Setting parameters")
    for key, value in parameters.items():
        with Admin5G() as admin_api:
            admin_api.perform_parameter_recommissioning(f"MRBTS-50859/{value[0]}", parameter=key,
                                                        operation="update", value=value[1],
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True, timeout=300)


def change_parameters_with_relation_error(parameters):
    try:
        admin.setup_admin()
        admin.create_delta("path")
        for key, value in parameters.items():
            admin.append_parameter_update_to_delta(f"MRBTS-50859/{value[0]}", key, value[1], delta_id="path")
        admin.save_delta('delta.json', "path")
        admin.perform_delta_recommissioning(delta_file=admin.get_delta("path"), skip_parameter_relation_errors=True)
    finally:
        admin.teardown_admin()


def check_remote_cells_on_air():
    try:
        admin.setup_admin(bts_host="10.42.47.8")
        fr2 = admin.get_cell_specific_info("/MRBTS-50858/NRBTS-50858/NRCELL-582")
        fr1 = admin.get_cell_specific_info("/MRBTS-50858/NRBTS-50858/NRCELL-581")
        assert fr1['status'].get('operationalState').lower() == 'enabled', 'Not all cells are on air'
        assert fr2['status'].get('operationalState').lower() == 'enabled', 'Not all cells are on air'
    finally:
        admin.teardown_admin()


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def disable_ecolab():
    cmd = 'sudo touch /etc/ute/disable_ecolab'
    os.system(cmd)


def convert_pdml():
    file_path = get_path()
    pcaptopdml.create_pcap_to_pdml_converter(name="pcap",
                                             file_path_pattern="{}/tcpdump/{}".format(file_path, pcap_file))
    pcaptopdml.convert("pcap")


def pcap_flow(test_flow_variable):
    file_path = get_path()
    call_flow_messages = test_flow_variable
    read_lines(file_path, pdml_file, call_flow_messages)


def read_lines(file_path, file_name, call_flow_messages):
    for line in file_reader("{}/tcpdump/{}".format(file_path, file_name)):
        counter = 0
        if len(call_flow_messages) == 0:
            return True
        if re.search(call_flow_messages[counter], line):
            call_flow_messages.pop(counter)
    if len(call_flow_messages) > 0:
        raise Exception("Incorrect_call_flow - ", call_flow_messages, " NOT FOUND")
    else:
        return True


def check_fr1_fr2_and_meas_objects(morethan=None):
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/tcpdump/{}".format(file_path, pdml_file))
    result = {"lower_than_70": 0,
              "higher_than_250": 0}
    meas_check = {"how_many_meas": 0}
    for entry in pdml_entries:
        if "nr-rrc.measObjectToAddModList" in entry.packet:
            freq = entry.packet.findall("nr-rrc.freqBandIndicatorNR")
            if freq:
                for _ in freq:
                    if int(_.show) < 70:
                        result["lower_than_70"] += 1
                    if int(_.show) > 250:
                        result["higher_than_250"] += 1
        if "nr-rrc.measIdToAddModList" in entry.packet:
            meas = entry.packet.findall("nr-rrc.measObjectId")
            if meas:
                for _ in meas:
                    meas_check["how_many_meas"] += 1
    blog(meas_check["how_many_meas"])
    if morethan is not None:
        if result["lower_than_70"] > 0 and result["higher_than_250"] > 1:
            return True
        raise Exception("There_are_no_second_FR2!")
    else:
        if result["lower_than_70"] > 0 and result["higher_than_250"] > 0:
            return True
        raise Exception("There_are_no_FR2!")


def check_a4(file_name):
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/tcpdump/{}".format(file_path, file_name))
    for entry in pdml_entries:
        if "nr-rrc.eventTriggered_element" in entry.packet:
            meas = str(entry.packet.findall("nr-rrc.reportInterval"))
            assert "ms1024" in meas
            meas = str(entry.packet.findall("nr-rrc.reportAmount"))
            assert "r4" in meas
            event = entry.packet["nr-rrc.eventId"].showname
            assert event.split()[1] == "eventA4"
            event = entry.packet["nr-rrc.hysteresis"].showname
            event = event.split(" ")
            assert event[1] == "0dB"
            event = entry.packet["nr-rrc.timeToTrigger"].showname
            event = event.split(" ")
            assert event[1] == "ms100"
            return True
    raise Exception("Where is A4?!")


def verify_reconfiguration_from_bts50858(pci):
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/tcpdump/{}".format(file_path, pdml_file))
    pciList = []
    for entry in pdml_entries:
        if "UEContextSetupRequest" in entry.packet:
            if "spCellConfig" in entry.packet:
                if "spCellConfigCommon" in entry.packet:
                    physCellId = entry.packet.findall("nr-rrc.physCellId")
                    if physCellId:
                        for _ in physCellId:
                            pciList.append(_.show)
    assert pciList.__eq__(pci)


def verify_proper_pci_attach(pci):
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/tcpdump/{}".format(file_path, pdml_file))
    for entry in pdml_entries:
        if "SgNBAdditionRequest" in entry.packet:
            attach_pci = entry.packet["nr-rrc.physCellId"].show
            assert attach_pci == pci
        elif "UEContextModificationResponse" in entry.packet:
            if "nr-rrc.physCellId" in entry.packet:
                attach_pci = entry.packet["nr-rrc.physCellId"].show
                if attach_pci == pci:
                    blog(pci)
                    return True
        elif "UEContextSetupResponse" in entry.packet:
            if "nr-rrc.physCellId" in entry.packet:
                attach_pci = entry.packet["nr-rrc.physCellId"].show
                if attach_pci == pci:
                    blog(pci)
                    return True
    raise Exception("No PCell or PSCell!/Different_PCI?")


def verify_worse_reported_cell(first_cell, second_cell):
    file_path = get_path()
    pdml_entries = PdmlReader.from_file("{}/tcpdump/{}".format(file_path, pdml_file))
    attach_pci = []
    for entry in pdml_entries:
        if "GNBDUConfigurationUpdate" in entry.packet:
            pci = entry.packet.findall("nr-rrc.physCellId")
            if pci:
                for _ in pci:
                    attach_pci.append(_.show)
    assert attach_pci.__eq__(first_cell) and attach_pci.__eq__(second_cell)


def zip_results():
    file_path = get_path()
    shutil.make_archive(file_path, 'zip', file_path)
    shutil.rmtree(file_path)


def setup_attenuator():
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')


def set_default_attenuation():
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


def set_attenuation_for_cell(cell_alias, attenuation):
    blog("attenuation change for: ", cell_alias)
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)
    time.sleep(25)


@wait_until_function_succeeds(timeout=420, interval=10)
def verify_cells_on_air_state():
    with Admin5G() as admin_api:
        cells = admin_api.get_cells_info(cell_type='nr')
        assert len(cells), 'Cells not detected'
        for cell in cells:
            assert cell['status'].get('operationalState') == 'enabled', \
                blog('Not all cells are online\n', cell, console=False)


def workaround_commissioning(scf):
    """This is temporary workaround.
    Feature is not commercial and is in development. """
    with Admin5G() as admin_api:
        admin_api.perform_commissioning(scf_file=scf, skip_parameter_relation_errors=True)
    verify_cells_on_air_state()
