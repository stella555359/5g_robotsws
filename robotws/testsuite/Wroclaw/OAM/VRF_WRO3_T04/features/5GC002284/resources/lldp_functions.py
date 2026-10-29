from taf.sbts.oam.coam.admin import admin
from ute_common_admin.exception import AdminApiProcedureFailureException
from taf.transport.ssh import ssh
import os
import time
import pexpect
import testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.admin.admin_utils as bts
from robot.libraries.BuiltIn import BuiltIn

ssh = ssh()
bts_id = BuiltIn().get_variable_value("${tl.gnbs[0].global_bts_id}")


def create_lldp_ethapp_object(connection):
    params_to_ethapp = [{
        "parameterName": "optionalTlvReplyEnabled",
        "operation": "update",
        "value": "false"
    },
        {
            "parameterName": "remoteMepMacAutoLearningEnabled",
            "operation": "update",
            "value": "false"
        },
        {
            "parameterName": "serviceOamEnabled",
            "operation": "update",
            "value": "false"
        }]
    try:
        bts.manage_object_on_bts(dist_name='MRBTS-{}/TNLSVC-1/TNL-1/ETHAPP-1'.format(bts_id),
                                 param_name=params_to_ethapp, operation='create', connection=connection)
    except AdminApiProcedureFailureException as e:
        if 'object already exists' in str(e.message):
            pass


def create_lldp_object(connection):
    params_to_lldp = [{
        "parameterName": "ethlkDN",
        "operation": "update",
        "value": 'MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1'.format(bts_id)
    }]
    try:
        bts.manage_object_on_bts(dist_name='MRBTS-{}/TNLSVC-1/TNL-1/ETHAPP-1/LLDP-1'.format(bts_id),
                                 param_name=params_to_lldp, operation='create', connection=connection)
    except AdminApiProcedureFailureException as e:
        if 'object already exists' in str(e.message):
            pass


def get_portid_webem(connection):
    api = admin()
    lldp_object = api.get_managed_objects(class_name='LLDP_R', connection=connection)
    return lldp_object[0]['parameters']['remoteDiscoveryTable']['portId']


def get_chassisid_webem(connection):
    api = admin()
    lldp_object = api.get_managed_objects(class_name='LLDP_R', connection=connection)
    return lldp_object[0]['parameters']['remoteDiscoveryTable']['chassisId']


def check_if_mac_portid_match(mac_adress, port_id, topology, connection):
    if "ASIL" in topology:
        ssh.execute(command="tcpdump -i etheif1 -c 2 -w lldp.pcap", connection=connection)
    elif "ASIK" in topology:
        ssh.execute(command="tcpdump -i tapeif1 -c 2 -w lldp.pcap", connection=connection)
    elif "ASOE" in topology:
        ssh.execute(command="tcpdump -i etheif1 -c 2 -w lldp.pcap", connection=connection)
    elif "ASIM" in topology:
        ssh.execute(command="tcpdump -i etheif1 -c 2 -w lldp.pcap", connection=connection)
    time.sleep(30)
    ssh.download_file(remote_path="/user/toor4nsn/lldp.pcap", local_path="./lldp.pcap", connection=connection)
    tshark_on_lldp_obj_outcome = str(os.popen("sudo tshark -r lldp.pcap").readlines())
    assert "MA/" + mac_adress in tshark_on_lldp_obj_outcome
    assert "IN/" + port_id in tshark_on_lldp_obj_outcome


def send_pcap_via_tcpreplay(speed, path_to_file):
    ssh.connect_to(hostname='10.42.63.239', username='r00t', password='YT_xk39b', alias='testpc_connection')
    ssh.execute(command='tcpreplay -i enp2s0f0 -p {} -K --duration=1200 --loop 95000000 {}'
                .format(speed, path_to_file), connection='testpc_connection')
    ssh.disconnect(connection='testpc_connection')


def check_lldp_processes():
    processes = ssh.execute(command="ps aux | grep 'lldp' | egrep -v grep | awk -F' ' '{print $11}'",
                            connection="cOAM_toor4nsn")
    assert '/opt/trs/bin/trs-lldp-d\r' in str(processes).split('\n')
    assert '/opt/trs/bin/lldpad\r' in str(processes).split('\n')


def check_gnb_uptime():
    uptime_value = str(ssh.execute(command="uptime | awk -F' ' '{print $3}'", connection='cOAM_toor4nsn'))[:4]
    if int(uptime_value[0]) == 0:
        assert int(uptime_value[2]) >= 2


def activity_lldp_object(connection, operation):
    params = [{"parameterName": "ethlkDN", "operation": "update",
               "value": 'MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1'.format(bts_id)},
              {"parameterName": "lldpId", "operation": "update", "value": '1'}]
    bts.manage_object_on_bts(
        dist_name="MRBTS-{}/TNLSVC-1/TNL-1/ETHAPP-1/LLDP-1".format(bts_id), connection=connection,
        operation=operation, param_name=params)


def sniffing_lldp_disable_packet(topology='ASIK'):
    ssh.send_command(command='rm lldp_testing.pcap', connection="cOAM_toor4nsn")
    if "ASIL" in topology:
        ssh.send_command(command="tcpdump -i etheif1 -c 10 -w lldp_testing.pcap", connection="cOAM_toor4nsn")
    elif "ASIK" in topology:
        ssh.send_command(command="tcpdump -i tapeif1 -c 10 -w lldp_testing.pcap", connection="cOAM_toor4nsn")


def stop_sniffing_and_search_disable_packets(interface):
    while str(ssh.execute(command="ps aux | grep 'tcpdump' | egrep -v grep | awk -F' ' '{print $11}'",
                          connection="cOAM_toor4nsn")) == 'tcpdump\r\n':
        time.sleep(20)
    ssh.download_file(remote_path="/user/toor4nsn/lldp_testing.pcap", local_path="./lldp_testing.pcap",
                      connection="cOAM_toor4nsn")
    tshark_on_lldp_obj_outcome = str(os.popen("sudo tshark -r lldp_testing.pcap").readlines())
    assert interface in tshark_on_lldp_obj_outcome, "Packets not found"


def switch_lldp_operation(parameter, topology):
    child = pexpect.spawn('ssh u1146637@10.42.186.108')
    child.expect("u1146637@10.42.186.108's password:")
    child.sendline('FHOSNcUyWg0Sfqz')
    child.expect('#')
    child.sendline('configure terminal')
    child.expect('#')
    if topology == 'ASIK':
        child.sendline('interface Tengigabitethernet 1/1')
    elif topology == 'ASIL':
        child.sendline('interface Tengigabitethernet 1/17')
    elif topology == 'ASOE':
        child.sendline('interface Tengigabitethernet 1/24')
    child.expect('#')
    child.sendline('protocol lldp')
    child.expect('#')
    child.sendline(parameter)
    child.expect('#')
    child.kill(0)


def get_lldp_r_neighbour(connection, value_state):
    api = admin()
    lldp_object = api.get_managed_objects(class_name='LLDP_R', connection=connection)
    values_structure = lldp_object[0]['parameters']['remoteDiscoveryTable'].values()
    if value_state == 'disable':
        assert values_structure.count(None) == len(values_structure), 'LLDP structure is not deleted from WebEM'
    if value_state == 'no disable':
        assert values_structure.count(None) != len(values_structure), 'LLDP structure is not created in WebEM'
