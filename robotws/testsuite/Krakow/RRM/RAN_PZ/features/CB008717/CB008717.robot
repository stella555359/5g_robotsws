*** Settings ***
Documentation
...    author: Jakub Kupiec
...    contact: jakub.kupiec@nokia.com
...    Description: Test Case CB008717-5G-C_03#B1_UE_Release_due_to_AMF_Context_Release

*** Settings ***
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Library     taf.rfrl.ue.iperf.tput_runner.ThroughputRunner    WITH NAME  tput_runner
Library     testsuite.Krakow.RRM.RAN_PZ.features.CB008717.resources.amf_release_keywords.AmfReleaseKeywords
Library     testsuite/Krakow/RRM/RAN_PZ/features/CB008717/resources/mediatek_keywords.py

*** Test Cases ***
CB008717-5G-C_03#B1_UE_Release_due_to_AMF_Context_Release
    Start Collecting gNB Syslog
    detach_ue_with_adb_cmd
    attach_ue_with_adb_cmd
    tput_runner.set_data_transfer_parameters
    ...  parallel_streams_dl=3
    ...  data_size_dl=900M
    ...  protocol=tcp
    start_sniffer
    tput_runner.run_dl_traffic_with_ues_simultaneously    duration=120
    detach_ue_with_adb_cmd
    stop_sniffer_and_collect_pcap
    tput_runner.validate_current_throughput_values    transfers_to_validate=1    dl_tput=800M
    Stop Collecting gNB Syslog
    validate_ue_context_release_in_syslog
    validate_ngap_ue_context_release_procedure
    validate_f1ap_ue_context_release_procedure
    validate_e1ap_ue_context_release_procedure
