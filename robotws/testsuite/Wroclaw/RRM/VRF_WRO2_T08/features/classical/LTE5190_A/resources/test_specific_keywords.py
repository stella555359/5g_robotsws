from collections import defaultdict
from random import choice
from time import sleep

from robot.libraries.BuiltIn import BuiltIn
from ta_attenuator import ta_attenuator
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from ute_tshark import ute_tshark
from ute_ue import ute_ue

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners import clear_admin_api_logs
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.resources.log.log import blog

_builtin = BuiltIn()
_ssh = ssh()
_attenuator = ta_attenuator()
_api = admin()
_ute_ue = ute_ue()
_ute_tshark = ute_tshark()
_tl_conf = TestlineConfiguration()
current_lua = True

sgnb_filters_pci = ['x2ap.procedureCode == 27 and nr-rrc.physCellId == {} and ip.src == 10.44.225.195 '
                    'and ip.dst == 10.44.224.67',
                    'x2ap.procedureCode == 27 and  nr-rrc.physCellId == {} and ip.src == 10.44.224.67 '
                    'and ip.dst == 10.44.225.195',
                    ]
sgnb_filters_non_pci = ['x2ap.procedureCode == 28 and ip.src == 10.44.225.195 and ip.dst == 10.44.224.67',
                        'x2ap.procedureCode == 4 and ip.src == 10.44.225.195 and ip.dst == 10.44.224.67',
                        ]
endc_filters = ['x2ap.procedureCode == 40 and ip.src == 10.44.224.67 and ip.dst == 10.44.225.195',
                'x2ap.procedureCode == 37 and ip.src == 10.44.224.67 and ip.dst == 10.44.225.195',
                'x2ap.procedureCode == 37 and ip.src == 10.44.225.195 and ip.dst == 10.44.224.67',
                ]


def initialize_attenuator():
    blog("initializing attenuator")
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = _attenuator.cells_pool.cells_registry.keys()
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')
    sleep(2)


def release_attenuator():
    blog("releasing attenuator...")
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(_attenuator.cells_pool.cells_registry.keys())


def attach(ue, cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)
    _ute_ue.attach_ue(ue)
    blog("UE attached")
    sleep(5)


def set_attenuation_for_cell(cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)


def pick_random_cell():
    with Admin5G() as api:
        all_cells_info = api.get_parameters_for_all(class_name="NRCEL")
    cell_dict = defaultdict()
    for cell in all_cells_info:
        cell_dict[cell['id']] = cell['physCellId']
    random_cell_id = choice(list(cell_dict))
    random_pci = cell_dict[random_cell_id]
    return random_cell_id, random_pci


def block_cell_and_check_state(dist_name, alarm_to_check):
    with Admin5G() as api:
        api.block_cell(dist_name=dist_name)
        sleep(10)
        cell = api.get_cell_specific_info(cell_id=dist_name)
        assert cell['status'].get('blockingState').lower() == 'blocked', 'Cell {} is not blocked'.format(cell)
        alarms = api.get_alarms()
    assert _look_for_specific_fault_in_cell(dist_name, alarms, alarm_to_check), \
        "{} not visible after blocking".format(alarm_to_check)
    blog("Cell blocked")


def _look_for_specific_fault_in_cell(dist_name, alarms, fault):
    specific_fault_present = False
    for alarm in alarms:
        if str(alarm['alarmId']) == fault and alarm['alarmingObjectIds'][0]['internal'] == dist_name:
            specific_fault_present = True
            break
    return specific_fault_present


def unblock_cell_and_check_state(dist_name):
    with Admin5G() as api:
        cell = api.get_cell_specific_info(cell_id=dist_name)
        if cell['status'].get('blockingState').lower() == 'blocked':
            api.unblock_cell(dist_name=dist_name)
            sleep(10)
        cell = api.get_cell_specific_info(cell_id=dist_name)
        assert cell['status'].get('blockingState').lower() == 'unblocked', 'Cell {} is not unblocked'.format(cell)
    blog("Cell unblocked")


def verify_scenario_in_pcaps(pci, attach_pcap, reattach_pcap):
    blog("verifying attach messages in pcap files...")
    alias = 'tshark'
    _ute_tshark.setup_tshark(interface='any', alias=alias)
    _verify_messages_in_pcap(attach_pcap, sgnb_filters_pci, pci=pci, tshark_alias=alias)
    _verify_messages_in_pcap(attach_pcap, sgnb_filters_non_pci, tshark_alias=alias)
    _verify_messages_in_pcap(attach_pcap, endc_filters, tshark_alias=alias)
    _verify_messages_in_pcap(reattach_pcap, endc_filters[1:], tshark_alias=alias)
    _ute_tshark.teardown_tshark(alias=alias)


def _verify_messages_in_pcap(pcap_filename, filters, pci=None, tshark_alias=None):
    for entry in filters:
        value = _ute_tshark.get_packets_count(packet_filter=entry.format(pci) if pci is not None else entry,
                                              pcap_file_path=pcap_filename,
                                              alias=tshark_alias)
        assert value == 1, "Wrong number of packets for filter: {}\nNumber of packets found: {}".format(entry, value)


def remove_files_from_vms():
    clear_admin_api_logs()
    ssh_details = _tl_conf.get_lte_test_pc_connection_details()
    _ssh.connect_to(hostname=ssh_details['hostname'],
                    username=ssh_details['username'],
                    password=ssh_details['password'])
    _ssh.send_command(command='rm [1]5GC002177*')
    _ssh.read_output()


def adb_reboot_ue():
    uepc_ssh_details = _tl_conf.get_uepc_connection_details()
    _ssh.connect_to(hostname=uepc_ssh_details['hostname'],
                    username=uepc_ssh_details['username'],
                    password=uepc_ssh_details['password'])
    _ssh.send_command(command='adb reboot')
    sleep(90)
