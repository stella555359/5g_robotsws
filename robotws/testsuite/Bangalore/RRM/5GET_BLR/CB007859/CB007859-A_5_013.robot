*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...    CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Suite Setup       Convert TL Mode And Suite Setup Fdd
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          ./CB007859_Resource.robot
Library          ./resources/python/lib.py
Library          ./resources/python/read_csv.py

Documentation
...
...             author:            Jayagovinda K S, jayagovinda.1.ks@nokia.com
...             maintainer:        Jayagovinda K S, jayagovinda.1.ks@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-A_5_013_Verification_of_FDM_limit_for_fddNrCellConfigTradeoff==0_with_6cells _configured_FDD_SA_5MHz.
...                                This case is to verify the fact, gNB shall limit the FDM capacity properly
...			                       when BBMOD.fddNrCellConfigTradeoff == 0,and 6 FDD cells is configured for half Loki based hardware
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)

...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:     5G_RAN_USR_21029
*** Variables ***
${DELTA_FILE}              Delta_Conf_CB007859_A_5_013.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_multiuefdd_5mhz.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>1585</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=5M    ul_traffic=5M
${UE_NUM}                  8
${UE_PER_SLOT}              8
${UE_NUM_CHANGE}            2

*** Test Cases ***
[1][1.0] CB007859-A_5_013_Verification_of_FDM_limit_for_fddNrCellConfigTradeoff==0_with_6cells _configured_FDD_SA_5MHz
#    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}  dl_tput=5000    ul_tput=5000
#    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming/
#    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming/
#    Check UL and DL rnti per slot    ${test_log_directory}/ttitrace_streaming/    ${5}    ${8}
#    wait for counter update ${300}s
#    Verify fdm max ul and dl Counters   5   8
#    Verify max ue per slot after online modification    ${2}     ${2}    after_change/    ${2}     ${2}
#    Detach multiple SA UEs      max_ue_num=${UE_NUM}

    log to console     UL CHECK STARTED
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}    ul_tput=2100
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_ul/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
    Check UL rnti per slot    ${test_log_directory}/ttitrace_streaming_ul/    ${5}
    Verify fdm max ul Counters   5
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    log to console     UL CHECK COMPLETED

    sleep    60s

    log to console     DL CHECK STARTED
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM}    dl_tput=6000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_dl/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
    Check DL rnti per slot    ${test_log_directory}/ttitrace_streaming_dl/    ${8}
    Verify fdm max dl Counters   8
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    log to console     DL CHECK COMPLETED
    sleep    60s
    log to console     online modification
    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}  dl_tput=5000    ul_tput=2000
    Verify max ue per slot after online modification    ${2}     ${2}    after_change/    ${2}     ${2}

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

Check DL rnti per slot
    [Arguments]    ${path}  ${expected_dl}
    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
    Should Contain    ${y}    Pass

SA MultiUE Attach And Do UL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ul_tput}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do DL Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${dl_tput}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}   ${dl_tput}
    Display average DL and UL data        ${ue_id}
    END
