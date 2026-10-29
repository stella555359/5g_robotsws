import subprocess
import taf.sbts.oam.coam.admin.interface as cOAM
import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.common import get_interface_name
from robot.libraries.BuiltIn import BuiltIn


def get_vlan():
    INTERFACE_NAME = get_interface_name()
    os.system('chmod a+x testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/get_interface_ip.sh')
    output = subprocess.check_output(
        'testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/get_interface_ip.sh {}'.format(INTERFACE_NAME),
        shell=True)
    vlan = output.split(INTERFACE_NAME)[1].lstrip('.')[:3]

    return vlan


def get_source_ip():
    mplane_ip_addr = BuiltIn().get_variable_value("${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}")
    return mplane_ip_addr


def get_sw_name():
    admin = cOAM.admin()
    conn = admin.connect_to()
    sw_version = conn.get_sw_release_name()
    admin.teardown()
    return sw_version


def start_l2_trace(interface_ip, vm_ip, cell_dns, dscp_num=15, port=5678, type='Component',
                   data_flow='L2Ps'):
    admin = cOAM.admin()
    conn = admin.connect_to(release=get_sw_name())
    admin.start_uplane_l2_trace(source_ip=interface_ip, dscp=dscp_num,
                                destination_ip=vm_ip, destination_port=port,
                                nr_cell_dns=cell_dns, trace_type=type, up_sw=data_flow, connection=conn)
    admin.teardown(connection=conn)


def stop_l2_trace(type='Component', data_flow='L2Ps'):
    admin = cOAM.admin()
    conn = admin.connect_to(release=get_sw_name())
    admin.stop_uplane_l2_trace(trace_type=type, up_sw=data_flow, connection=conn)
    admin.teardown(connection=conn)


def remove_file(filepath, recursive=False):
    if not recursive:
        command = 'sudo rm {}'.format(filepath)
    else:
        command = 'sudo rm -r {}'.format(filepath)
    os.system(command)


def remove_files(files):
    for f in files:
        remove_file(f)


def decode_pcap_file(feature, out_format="legacyCsv"):
    access_command = "sudo chmod 777 {}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/{}/resources/vm_tti_trace" \
                     "/vm_tti_trace.pcap ".format(os.getcwd(), feature)
    os.system(access_command)
    access_command = "sudo chmod 777 {}/tti-dec-bin/bin" \
                     "/eventDecoder ".format(os.getcwd())
    os.system(access_command)
    decode_command = (
        "python3 "
        "{}/tti-dec-bin/TtiTraceDecoder.py --ul "
        "{}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/{}/resources/vm_tti_trace/vm_tti_trace.pcap "
        "{} -o "
        "testsuite/Wroclaw/RRM/VRF_WRO2_T01/{}/resources/tti_trace".format(
            os.getcwd(), os.getcwd(), feature, out_format, feature
        )
    )
    os.system(decode_command)
