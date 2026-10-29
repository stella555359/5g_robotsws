*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED
Suite Setup       Convert TL Mode And Suite Setup fdd_acsi
Suite Teardown      Run Keywords
...                 Fetch AMF and Nglink Status
...                 AND   Dump RMOD BBMOD And Cell Status
...                 AND      Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown       Run Keywords
...                 Fetch AMF and Nglink Status
...                 AND   Dump RMOD BBMOD And Cell Status
...                 AND   Common New Test Teardown
...                 AND    Run Keyword if test failed      CPRT Monitoring Stop Collect ASIB    ${test_log_directory}
...                 AND    Run Keyword if test failed      Bip Mon Stop AP ASIK ABIL       ${test_log_directory}
...                 AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          ./CB007859_Resource.robot
Library          ./resources/python/lib.py
Library          ./resources/python/read_csv.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/BIP_Capture.py

Documentation
...
...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-A_4_011_Enhanced_FDM_of_UCI_on_PUSCH_FDD_SANSA_20MHz.
...                                This case is to verify  the operator configurable number of PDSCH/PUSCH allocation per slot
...                                controls the maximum allocation per slot and Up to 10 CSI on PUSCH allocation per slot  can
...				                   be achieved based on UE attached in tota
...                                maxNumPdschAllocationPerSlot
...                                maxNumPuschAllocationPerSlot
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)


...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:     5G_RAN_USR_20536

*** Variables ***
${DELTA_FILE}              Delta_tmo_apercsi.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_tmo_7859_a4.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>1582</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=20M    ul_traffic=20M
${UE_NUM}                  20
${UE_PER_SLOT_UL}          ${10}
${UE_PER_SLOT_DL}          ${12}
${ACSI_ON_PUSCH}           ${10}


*** Test Cases ***
[1][1.0] CB007859-A_4_011_Enhanced_FDM_of_UCI_on_PUSCH_FDD_SANSA_20MHz
#    CPRT Monitoring Start ASIB
#    Bip Mon Start AP ASIK ABIL
#    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}    dl_tput=20000    ul_tput=20000
#    CPRT Monitoring Stop Collect ASIB    ${test_log_directory}
#    Bip Mon Stop AP ASIK ABIL       ${test_log_directory}
#    Start And Stop Tti Trace Streaming     ${test_log_directory}/ttitrace_streaming/
##    Convert Tti To Csv Mode          ${test_log_directory}/ttitrace_streaming/
#    Wait Until Keyword Succeeds    2x    5sec     Convert Tti To Csv Mode          ${test_log_directory}/ttitrace_streaming/
#    Check UL and DL rnti per slot    ${test_log_directory}/ttitrace_streaming    ${UE_PER_SLOT_UL}    ${UE_PER_SLOT_DL}
#    Verify fdm max ul and dl Counters	10	12
#    ${ret}    Check ACSI per on PUSCH slot    ${test_log_directory}/ttitrace_streaming    ${ACSI_ON_PUSCH}    output_ul_formated.csv
#    log to console     ACSI on PUSCH per slot is ${ret[1]}
#    Verify fdm max ul and dl Counters	10	12
##    Run keyword if    ${ret[1]} < 10    Check ACSI per on PUSCH slot for longer duration    ${test_log_directory}/ttitrace_streaming
##    ...    ${ACSI_ON_PUSCH}    output_ul_formated.csv
#    Detach multiple SA UEs      max_ue_num=${UE_NUM}
#    Run Keyword and Ignore Error    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    Set test variable      ${LOG_PATH}      /home/ute/
    log to console     UL CHECK STARTED
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}    ul_tput=20000
    wait for previous action to stabilise ${600}s
    Verify fdm max ul Counters   10
##    Start And Stop Tti Trace Streaming Mod    ${test_log_directory}/ttitrace_streaming_ul/      duration=${2}
##    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
    Start TTI_TRACE custom     ${57}
    sleep     2s
    ${tti1_ul}     Stop Log     ttitrace         test_scenario=ttiul
    Decode TTI Trace    ttiul
    Check UL rnti per slot    ${tti1_ul}[ttitrace]/    ${10}
#    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    ${ret}    Check ACSI per on PUSCH slot    ${tti1_ul}[ttitrace]/    ${ACSI_ON_PUSCH}    output_ul_formated.csv
    ${ue_der}    SET VARIABLE    ue_deregister id=51-70 ue_deregister_type=switch_off
    ute_wtssim.Execute Egate Command    ${ue_der}    timeout=30s
    log to console     ACSI on PUSCH per slot is ${ret}
    log to console     UL CHECK COMPLETED

    sleep    60s

    log to console     DL CHECK STARTED
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM}    dl_tput=20000
    wait for previous action to stabilise ${600}s
    Verify fdm max dl Counters   12
#   Start And Stop Tti Trace Streaming Mod    ${test_log_directory}/ttitrace_streaming_dl/      duration=${2}
#   Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
    Start TTI_TRACE custom     ${57}
    sleep     2s
    ${tti1_dl}     Stop Log     ttitrace         test_scenario=ttidl
    Decode TTI Trace    ttidl
    Check DL rnti per slot    ${tti1_dl}[ttitrace]/    ${12}
#    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    ${ue_der}    SET VARIABLE    ue_deregister id=51-70 ue_deregister_type=switch_off
    ute_wtssim.Execute Egate Command    ${ue_der}    timeout=30s
    log to console     DL CHECK COMPLETED

*** Keywords ***
Verify fdm max dl Counters
     [Arguments]    ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter

     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     Should Be True      ${counter_dl}==${dl_expected}

Verify fdm max ul Counters
     [Arguments]    ${ul_expected}
     [Documentation]    This keyword is to verify the FDM dl&ul counter
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_ul}==${ul_expected}
Check UL rnti per slot
    [Arguments]    ${path}  ${expected_ul}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}/output_ul_formated.csv
    Should Contain    ${x}    Pass
#    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
#    Should Contain    ${y}    Pass

Check DL rnti per slot
    [Arguments]    ${path}  ${expected_dl}

    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
    Should Contain    ${y}    Pass

SA MultiUE Attach And Do UL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ul_tput}
    Builtin.Log to console      ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    51    71
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
#    \    Start DL Traffic        ${ue_id}   ${dl_tput}
    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END
SA MultiUE Attach And Do DL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${dl_tput}
    Builtin.Log to console      ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    51       71
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}   ${dl_tput}
#    \    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

Start And Stop Tti Trace Streaming Mod
    [Arguments]         ${path}     ${duration}=${3}
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}
