*** Settings ***
Documentation    Logs collector
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py    WITH NAME    TTI
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/C/resources/test_specific_keywords.py
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2

*** Keywords ***
ROHC_C MANUAL HELPER
    [Arguments]   ${folder}=run_0   ${l1l2_filename}=L1L2.pcap    ${time}=5s
    ${new_folder}=    check_and_assign_filename    ${folder}
    Create Directory    ${new_folder}

    L1L2.start_gnbmirroring   filename=${l1l2_filename}
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts

    BuiltIn.Sleep   ${time}

    ${l1l2_logs}=        L1L2.stop_gnbmirroring_and_download_logs
    ${tti_file_path}=    TTI.stop_tti_traces_in_streaming_mode

    Run keyword and Ignore error     Move Files    ${OUTPUT_DIR}/TTI/*.csv   ${new_folder}
    Run keyword and Ignore error     Move Files    ${OUTPUT_DIR}/TTI/l2stream3/tti_streaming/*.pcap   ${new_folder}
    Remove Directory    ${OUTPUT_DIR}/TTI   ${new_folder}
    Move File         ${OUTPUT_DIR}/${l1l2_filename}     ${new_folder}

    Log to console    Current logging folder is: ${new_folder}
