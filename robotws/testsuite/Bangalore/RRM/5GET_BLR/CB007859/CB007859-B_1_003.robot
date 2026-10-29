*** Settings ***
Force Tags       CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...    CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

Suite Setup       Convert TL Mode And Suite Setup 7859_dss
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          ./resources/common/common_dss_command.robot
Resource          ./CB007859_Resource.robot
Library           ./resources/python/lib.py
Library           ./resources/python/read_csv.py


Documentation
...
...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-B_1_003_DL_UL_Data_transmission_for_enhanced_FDM_users_6cells_per_Loki_FDD_DSS_SA_20MHz.
...                                This case is to verify  the DL&UL data transmission with an increased number of allocations
...                                on PDSCH and PUSCH per slot for FDD FR1 DSS deployments and when 6 Cells per Loki is used
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)


...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:     5G_RAN_USR_20536

*** Variables ***
${DELTA_SCF_FILE}              scf_7859_dss_sa_20MHZ.xml
${delta_json_file}             Delta_Conf_CB007859_B_1_003.json
${iphy_file}               ${CURDIR}/resources/config/iphy_7859_dss_sa_20mhz.xml
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setting_dss_7859_sa_20M.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>1.1</cell>    <cell>1.2</cell>    <GSCN>1588</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=1    cell_id=1    bearer_id=2    dl_traffic=20M    ul_traffic=20M
${UE_NUM}                  8
${UE_PER_SLOT_UL}          ${5}
${UE_PER_SLOT_DL}          ${6}

*** Test Cases ***
[1][1.0] CB007859-B_2_003_DL_UL_Data_transmission_for_enhanced_FDM_users_6cells_per_Loki_FDD_DSS_SA_20MHz
#    Enable 7859 With DSS    prb_list=${PRB_LIST_20M_50_50}    ALLOC_SUBFRAME=${ALLOC_SUBFRAME_20M}    min_dss_ratio=50    max_dss_ratio=70
#    ...    min_prb_ratio=50    max_prb_ratio=70
#    SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}    dl_tput=20000    ul_tput=20000
#    Start And Stop Tti Trace Streaming     ${test_log_directory}/ttitrace_streaming/
#    Convert Tti To Csv Mode          ${test_log_directory}/ttitrace_streaming/
#    Check UL and DL rnti per slot    ${test_log_directory}/ttitrace_streaming    ${UE_PER_SLOT_UL}    ${UE_PER_SLOT_DL}
#    sleep    600s
#    Verify fdm max ul and dl Counters	${UE_PER_SLOT_UL}    ${UE_PER_SLOT_DL}
#    Detach multiple SA UEs      max_ue_num=${UE_NUM}


# New Version
    Backup Scf    ${OUTPUT_DIR}    before_suite

    Enable 7859 With DSS    prb_list=${PRB_LIST_20M_50_50}    ALLOC_SUBFRAME=${ALLOC_SUBFRAME_20M}    min_dss_ratio=30    max_dss_ratio=70
#    ...    min_prb_ratio=30    max_prb_ratio=70
    log to console     UL CHECK STARTED
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}    ul_tput=20000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_ul/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
    Check UL rnti per slot    ${test_log_directory}/ttitrace_streaming_ul/    ${UE_PER_SLOT_UL}
    Verify fdm max ul Counters   ${UE_PER_SLOT_UL}
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    log to console     UL CHECK COMPLETED

    sleep    60s

    log to console     DL CHECK STARTED
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM}    dl_tput=20000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_dl/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
    Check DL rnti per slot    ${test_log_directory}/ttitrace_streaming_dl/    ${UE_PER_SLOT_DL}
    Verify fdm max dl Counters   ${UE_PER_SLOT_DL}
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
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

