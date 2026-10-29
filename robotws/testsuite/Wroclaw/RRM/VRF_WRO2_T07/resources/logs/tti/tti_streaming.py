from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.converters.eventdecoder import eventdecoder
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.core import CollectorKeywords
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti.tcpdump_collector import start_tcpdump_on_test_pc
from taf.transport.ssh import ssh
import os

default_cell_dist_id = ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1']
src_ip = tl.gnbs[0].cu.m.v4  # mplane
dest_ip = tl.test_pc.default_ssh_connection_details.addr  # UTE VM


@logged_keyword
def start_tti_traces_in_streaming_mode(tcpdump_filename='tti_tcpdump', collector_type="sbts"):
    blog('TTI Traces are forwarded to IP: ' + str(dest_ip))
    tcpdump_collector = start_tcpdump_on_tti_interface(tcpdump_filename=tcpdump_filename)
    if collector_type == 'coam':
        blog('Using start_tti_traces_in_streaming_mode with collector_type="coam" has been deprecated.')
        blog('Script will run with collector_type="sbts". Please use that instead.')
        start_generation_of_tti_trace_using_taf(tcpdump_collector)
    else:
        start_generation_of_tti_trace_using_taf_sbts(tcpdump_collector)


def start_tcpdump_on_tti_interface(tcpdump_filename='tti_tcpdump'):
    connection = connections.connect_to_test_pc()
    interface_name = identify_interface_with_ip(dest_ip, connection)
    blog('Identifed interface for tcpdump on Test PC is : ' + str(interface_name))
    collector = start_tcpdump_on_test_pc(interface=interface_name, option='port 5678', collector=tcpdump_filename)
    return collector


def start_generation_of_tti_trace_using_taf(tcpdump_collector, tti_collector_name='TTI'):
    start_generation_of_tti_trace_using_taf_sbts(tcpdump_collector, tti_collector_name)


def start_generation_of_tti_trace_using_taf_sbts(tcpdump_collector, tti_collector_name='TTI'):
    executor = {'host': tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr,
                'user': tl.gnbs[0].cu.oam_http_connection_details.username,
                'password': tl.gnbs[0].cu.oam_http_connection_details.password,
                'port': 443,
                'release': assign_release_version()}
    l2_stream_config_1 = {'trace_type': 'Component'}
    l2_stream_configuration = [l2_stream_config_1]
    tti_collector = l2stream3()
    tti_collector.create_sbts_l2stream_collector(name=tti_collector_name, webservice=executor,
                                                 source_ip_addr=src_ip,
                                                 destination_ip_addr=dest_ip,
                                                 collector=tcpdump_collector,
                                                 l2_stream_configuration=l2_stream_configuration)
    core = CollectorKeywords()
    core.setup_collectors(names=tti_collector_name)
    core.start_collectors(names=tti_collector_name)
    core.set_suite_alias(tti_collector_name)
    blog('TTI streaming started!')


@logged_keyword
def stop_tti_traces_in_streaming_mode(tti_collector_name='TTI', tti_output_dir=None, decoded_output_file=None,
                                      tcpdump_filename='tti_tcpdump', with_decode=True,
                                      output_file_format='legacyCsv'):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = \
        os.path.join(tti_collector_name, testname) if decoded_output_file is None else decoded_output_file
    tti_output_dir = outputdir if tti_output_dir is None else tti_output_dir

    stop_generation_of_tti_trace_using_taf(tti_output_dir=tti_output_dir)
    tti_pcap_path = os.path.join(tti_output_dir, tti_collector_name, tcpdump_filename, tcpdump_filename + '.pcap')
    if with_decode:
        convert_tti_to_csv(
            input_file_path=tti_pcap_path, output_file=decoded_output_file, output_file_format=output_file_format)
    blog('TTI streaming stopped!')
    return os.path.join(robot_globals.outputdir(), decoded_output_file + '.dlAndUl.csv')


def teardown_tti_traces_in_streaming_mode(tti_collector_name='TTI', tti_output_dir=None, decoded_output_file=None,
                                          tcpdump_filename='tti_tcpdump', with_decode=True,
                                          output_file_format='legacyCsv'):
    try:
        stop_tti_traces_in_streaming_mode(tti_collector_name=tti_collector_name, tti_output_dir=tti_output_dir,
                                          decoded_output_file=decoded_output_file, tcpdump_filename=tcpdump_filename,
                                          with_decode=with_decode, output_file_format=output_file_format)
    except Exception:
        blog('TTI traces have already been collected. Teardown will not download TTI traces.')


def stop_generation_of_tti_trace_using_taf(tti_output_dir, tti_collector_name='TTI'):
    core = CollectorKeywords()
    core.stop_collectors(names=tti_collector_name)
    core.collect_collectors(names=tti_collector_name, target_dir=tti_output_dir)
    core.teardown_collectors(names=tti_collector_name)


def convert_tti_to_csv(input_file_path=None, output_file='decoded_tti', output_file_format='legacyCsv'):
    ed = eventdecoder()
    ed.create_eventdecoder_converter(name='converter', input_file_path=input_file_path,
                                     output_file_format=output_file_format,
                                     output_file_path=os.path.join(robot_globals.outputdir(), output_file))
    ed.convert(name='converter')
    return os.path.join(robot_globals.outputdir(), output_file)


def identify_interface_with_ip(ip, connection):
    _ssh = ssh()
    cl_output = _ssh.execute("ip -o -4 addr show | awk '{print $2\" \"$4}'" + " | grep {ip}".format(ip=ip),
                             connection=connection)
    words = cl_output.split()
    interface_name = words[0] if words else None
    return interface_name


def assign_release_version():
    smod_conn = connections.connect_to_smod()
    _ssh = ssh()
    version_file = _ssh.execute(command='ls /ffs/run/TargetBD*.xml', connection=smod_conn)
    return version_file.split()[-1].split('TargetBD_')[-1].split('_')[0]
