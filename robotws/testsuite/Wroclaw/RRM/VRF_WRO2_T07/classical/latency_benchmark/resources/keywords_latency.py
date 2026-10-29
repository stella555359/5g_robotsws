import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod as tcp_dump
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.latency_benchmark.resources.test_specific_keywords \
    import make_setup, make_handover_latency, make_interuption_time, analyze_latency, process_tti
from robot.libraries.BuiltIn import BuiltIn


setup_params = {'nea0': '1', 'nea1_128': '0', 'nea2_128': '0', 'nea3_128': '0', 'cbraPreamblesPerSsb': 'n40',
                'srPeriodicity': 'slots20', 'srPeriodicityMin': 'slots5', 'ulDataPath': 'ulOverNr'}

default_params = {'nea0': '5', 'nea1_128': '3', 'nea2_128': '4', 'nea3_128': '2', 'cbraPreamblesPerSsb': 'n64',
                  'srPeriodicity': 'slots80', 'srPeriodicityMin': 'none', 'ulDataPath': 'ulOverLteNr_PrimaryPathOverNr'}

TCPDUMP = tcp_dump.TcpdumpSmod()
l1l2 = L1L2()
TESTS = 3

output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
time_path = output_dir + '/logs_times.txt'


@logged_keyword
def Analyze_NSA_Call_Setup_and_Release_Latency():
    with open(time_path, 'w') as f:
        f.write('Analyze_NSA_Call_Setup_and_Release_Latency\n')

    TCPDUMP.start_tcpdump_on_smod()
    make_setup(TESTS)
    sctp = TCPDUMP.stop_tcpdump_and_download_logs_from_smod()
    analyze_latency(sctp, 'x2ap', 'SgNBAdditionRequest', 'SNStatusTransfer', 'NSA Call Setup and Release')


@logged_keyword
def Analyze_NSA_Handover_Latency():
    with open(time_path, 'a') as f:
        f.write('Analyze_NSA_Handover_Latency\n')

    TCPDUMP.start_tcpdump_on_smod()
    make_handover_latency(TESTS)
    sctp = TCPDUMP.stop_tcpdump_and_download_logs_from_smod()
    analyze_latency(sctp, 'x2ap', 'RRCTransfer', 'SgNBModificationConfirm', 'NSA Handover')


@logged_keyword
def Analyze_NSA_Handover_Interruption_Time():
    with open(time_path, 'a') as f:
        f.write('Analyze_NSA_Handover_Interruption_Time\n')

    l1l2.start_gnbmirroring(filename="Analyze_NSA_Handover_Interruption_Time.pcap")
    TCPDUMP.start_tcpdump_on_smod()
    tti = make_interuption_time(TESTS)
    TCPDUMP.stop_tcpdump_and_download_logs_from_smod()
    l1l2.stop_gnbmirroring_and_download_logs()
    process_tti(tti)
