*** Settings ***
Resource     ../../resources/common_keywords.robot
Resource     ../../resources/common_configuration.robot
Library      5GC000782_A.py
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_file_system
Library      ta5g_tshark
Library      ta5g_throughput
Library      ta5g_enb
Library      ta5g_iphy
Variables    ta5g_global_var
Documentation
...    author: Marek Niescioruk
...    maintainer: Marek Niescioruk (marek.niescioruk@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN
...    release: 22R3

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...    AND        Reach Onair    lua_cfg=${CURDIR}/config/egate_1c_sansa_abin.lua
...    AND        Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=true
...    AND        Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Send Configuration ID To Scout

Suite Teardown    Run Keywords    Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=false
...    AND                        Check For An Unexpected Alarm
...    AND                        Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SgNBAdditionRequestReject}=    x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 2 and x2ap.Cause == 0 and x2ap.radioNetwork == 15

*** Test Cases ***
5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Tags]   CRT
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as NULL and AES(nea2-128) but gNB support only
    ...        SNOW3G(nea1-128) and ZUC(nea3-128)
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc1_nea0_0_nea1_1_nea2_0_nea3_2.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    Detach Ue    ue_id=11
    [Teardown]    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Prepare Test Envioronment
    [Arguments]    ${perform_full_commissioning}=${FALSE}    ${perform_reset_tl}=${FALSE}
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/prepare_test_env
    Run Keyword If    ${perform_full_commissioning}
    ...       Update Enb And Iphy Configuration And Perform Full Commissioning
    ...         scfc_filename=full_1cell_nsa.xml
    ...         iphy_xml_filepath=${CURDIR}/config/iphy_1AEQA_1c.xml
    Run Keyword If    ${perform_reset_tl}
    ...        Reset Testline And Wait For Rmods
    Start Vm Ethernet Interface
    ...               if_name=eth3:ng
    ...               ip_with_mask=10.0.1.21/24
    Reach Onair    lua_cfg=${CURDIR}/config/egate_1c_1g_endc.lua
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/prepare_test_env

Reset Testline And Wait For Rmods
    Reset Testline
    Check Radios Availability

Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg

Perform SgNBAddition With Start Data Traffic And Capture Pcap
    [Arguments]    ${direction}    ${throughput}    ${filename}    ${ue_id}
    Perform SgNBAddition And Capture Pcap    filename=${filename}    ue_id=${ue_id}
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=${direction}    throughput=${throughput}
    Sleep    10s    Waiting For Traffic To Start

Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${filename}    ${ue_id}
    Perform SgNBAddition And Capture Pcap    filename=${filename}    ue_id=${ue_id}
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=dl    throughput=${dl_throughput}
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=ul    throughput=${ul_throughput}
    Sleep    10s    Waiting For Traffic To Start

Perform SgNBAddition And Capture Pcap
    [Arguments]    ${filename}    ${ue_id}
    Start Capturing Pcap On E1 And F1 Interfaces    filename=${filename}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Sleep    5s    Waiting For All Packets To Be Captured
    Stop Capturing Pcap On E1 And F1 Interfaces    filename=${filename}

Stop Capturing Pcap On E1 And F1 Interfaces
    [Arguments]    ${filename}
    ${output}=    Execute Enb Command    cmd=ps -ef | grep ${filename} | awk '{print $2}' | awk 'NR==1'
    Execute Enb Command    cmd=kill -TERM ${output}
    Get File From Enb    source=/tmp/${filename}    destination=${OUTPUT_DIR}/${filename}
