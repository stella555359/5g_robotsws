*** Settings ***

Suite Setup       Convert TL Mode And Suite Setup Tdd_5
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          ./CB007859_Resource.robot
Library           ./resources/python/lib.py
Library           ./resources/python/read_csv.py

Documentation
...
...             author           Akhil K P (Nokia) <akhil.k_p@nokia.com>
...             maintainer       Akhil K P (Nokia) <akhil.k_p@nokia.com>
...
...             INTRODUCTION     CNI-119314_TC1_Increased_FDM_UE_per_TTI_for_ASOE_10MHZ_FDD_SA
...             TEST SET NAME    CNI-119314_TC1_Increased_FDM_UE_per_TTI_for_ASOE_10MHZ_FDD_SA
...             Description        This case is to verify the DL&UL data transmission with an increased number of allocations on PDSCH and
...                                PUSCH per slot for FDD FR1 10MHz( 12 in dl and 10 in ul) on ASOE hw

...             TESTING SPLIT    NA
...             CONTACTS         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES       https://jiradc.ext.net.nokia.com/browse/CNI-119314
...             Requirement ID   FDD_10105_#1

*** Variables ***
${iphy_file}               ${CURDIR}/resources/config/new_3cell_iphy.xml
${scf_file_path}           new_3cell_pet_config.xml
${DELTA_FILE}              119314_delta.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 cni119314_basic_setup_new.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_tdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7881</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=10M    ul_traffic=3M
${UE_NUM}                  50
${UE_NUM_DL}               30
${UE_NUM_CHANGE}            2
&{UE_INFO_DL}              profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=10M    ul_traffic=0
&{UE_INFO_UL}              profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=0      ul_traffic=3M
*** Test Cases ***
CNI-119314_TC1_Increased_FDM_UE_per_TTI_for_ASOE_10MHZ_FDD_SA
    Backup Scf    ${OUTPUT_DIR}    before_suite
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}
    wait for previous action to stabilise ${650}s
    Verify fdm max ul Counters   10
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    sleep    60s
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM_DL}
    wait for previous action to stabilise ${650}s
    Verify fdm max dl Counters   12
    Detach multiple SA UEs      max_ue_num=${UE_NUM_DL}
    sleep     10s
    SA MultiUE Attach And Do Traffic on SANSA     max_ue_num=${UE_NUM}
    wait for previous action to stabilise ${350}s
    Verify fdm max dl Counters   12
     Verify fdm max ul Counters   10
*** Keywords ***
Start And Stop Tti Trace Streaming new
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}
Detach NSA UEs
    [Arguments]    ${start_ue}      ${end_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${end_ue}+1
    NSA LTE Detach      ${ue_id}
    END

wait for counter update ${sleep}s
    sleep       ${sleep}s

NSA MultiUE Attach And send Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ue_info}
    [Documentation]    This keyword is to do NSA multi UE attach and do DL/UL traffic
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${max_ue_num} | Yes | the number of multi UE |
    ...    | ${ue_info} | Yes | the directory for setting UE info. |
    ...
    ...    Examples:
    ...    1. both UL and DL --- kbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100M | ul_traffic=10m |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    2. both UL and DL --- mbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | \ Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100k | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    3. only UL or DL
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=0 | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...    or
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | \ profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=10m | ul_traffic=0 |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ${ul_traffic_type}    Run Keyword If    '${ue_info.ul_traffic}'!='0'    Evaluate    '${ue_info.ul_traffic}'[-1]
    ${dl_traffic_type}    Run Keyword If    '${ue_info.dl_traffic}'!='0'    Evaluate    '${ue_info.dl_traffic}'[-1]
    ${dl_type}    Run Keyword If    '${dl_traffic_type}'!='None'    String.Convert To Lowercase    ${dl_traffic_type}
    ${ul_type}    Run Keyword If    '${ul_traffic_type}'!='None'    String.Convert To Lowercase    ${ul_traffic_type}
    ${ul_traffic_value}    Run Keyword If    '${ul_type}'!='None'    Evaluate    '${ue_info.ul_traffic}'[0:-1]
    ${dl_traffic_value}    Run Keyword If    '${dl_type}'!='None'    Evaluate    '${ue_info.dl_traffic}'[0:-1]
    FOR    ${ue_id}    IN RANGE    21    ${max_ue_num}+21
    NSA LTE Attach    ${ue_id}    ${ue_info.profile_id}
    NSA 5G Attach    ${ue_id}    ${ue_info.gnb_id}    ${ue_info.cell_id}    ${ue_info.bearer_id}
#    NSA Verify If Attach Passed
    Run Keyword If    '${ul_type}'=='m'    NSA Start UL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    ...    ELSE IF    '${ul_type}'=='k'    NSA Start UL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    Run Keyword If    '${dl_type}'=='m'    NSA Start DL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    ...    ELSE IF    '${dl_type}'=='k'    NSA Start DL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    END

Verify fdm max dl Counters
     [Arguments]    ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl counter
     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     Should Be True      ${counter_dl}==${dl_expected}

Verify fdm max ul Counters
     [Arguments]    ${ul_expected}
     [Documentation]    This keyword is to verify the FDM ul counter
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
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
#    Start DL Traffic        ${ue_id}   ${dl_tput}
    Start UL Traffic        ${ue_id}
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do DL Traffic on SANSA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}
#    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}
    Start UL Traffic        ${ue_id}
    Display average DL and UL data        ${ue_id}
    END

Start DL Traffic
    [Arguments]    ${ue_id}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl period_ms\=4 burst\=8 size\=50
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Start UL Traffic
    [Arguments]    ${ue_id}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=ul period_ms\=4 burst\=8 size\=50
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
