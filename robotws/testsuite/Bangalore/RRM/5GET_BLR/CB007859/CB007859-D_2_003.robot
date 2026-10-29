*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    VARIANT_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Suite Setup       Convert TL Mode And Suite Setup Tdd_3
Suite Teardown    Common Suite Teardown
Test Setup        Common New Test Setup
Test Teardown     Run keywords      Common New Test Teardown
...               AND    Link SCOUT SCF to Configuration ID for Reporting

Resource          ./resources/common/common_setup_teardown.robot
Resource          CB007859_Resource.robot
Library          ./resources/python/lib.py
Library          ./resources/python/read_csv.py

Documentation
...
...             author:            Santhosh G N, g.n_santhosh@nokia.com
...             maintainer:        Santhosh G N, g.n_santhosh@nokia.com
...
...             INTRODUCTION:      CB007859 Spillover of CB006667 Increased number of FDM scheduled UEs per slot for ABIO
...             TEST SET NAME:     CB007859-D_2_003_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_BF_eCPRI_SA_100MHz.
...                                This case is to verify the DL&UL data transmission with an increased number of allocations on PDSCH and
...                                PUSCH per slot for TDD FR1 BF deployments and when 3 Cells per Loki is used
...                                (Due to Airphone limitation and HW availability, test scenario is executed with 1 cell configuraiton
...                                and in L1B mode)

...             TESTING SPLIT:     See CB007859 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007859 CFAM
...             Requirement ID:    5G_RAN_USR_20894
*** Variables ***
${iphy_file}               ${CURDIR}/resources/config/CB007859_D_2_003_iphy.xml
${scf_file_path}           CB007859_D_2_003_SCF.xml
${DELTA_FILE}              Delta_Conf_CB007859_D_2_003_SANSA_TDD.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_SANSA_twocell_Beamforming.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_tdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7881</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=10M    ul_traffic=10M
${UE_NUM}                  15
${UE_PER_SLOT}              8
${UE_NUM_CHANGE}            2

*** Test Cases ***
[1][1.0] CB007859-D_2_003_DL_UL_Data_transmission_for_enhanced_FDM_users_3cells_per_Loki_TDD_FR1_BF_eCPRI_SA_100MHz
    [Tags]     QC_201749     QC_117928     QCD_MN_RAN    QCP_RAN_ET
    #UE Beamforming Profile And Association For 2 Beams SA    ${UE_NUM}
    #SA MultiUE Attach And Do Traffic on SANSA    max_ue_num=${UE_NUM}   dl_tput=15000    ul_tput=15000
    #wait for previous action to stabilise ${120}s
    #Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming/
    #Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming/
    #Verify fdm max ul and dl Counters   8   8
    #Check UL and DL rnti per slot    ${test_log_directory}/ttitrace_streaming/    ${8}    ${8}
    #Verify fdm max ul and dl Counters   7   7
    #Verify max ue per slot after online modification    ${2}     ${2}    after_change/    ${2}     ${2}
    #Detach multiple SA UEs      max_ue_num=${UE_NUM}
    Backup Scf    ${OUTPUT_DIR}    before_suite
    UE Beamforming Profile And Association For 2 Beams SA    ${UE_NUM}
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}    ul_tput=20000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_ul/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_ul/
    Check UL rnti per slot    ${test_log_directory}/ttitrace_streaming_ul/    ${8}
    Verify fdm max ul Counters   8
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    sleep    60s
    UE Beamforming Profile And Association For 2 Beams SA    ${UE_NUM}
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM}    dl_tput=20000
    wait for previous action to stabilise ${120}s
    Start And Stop Tti Trace Streaming    ${test_log_directory}/ttitrace_streaming_dl/
    Convert Tti To Csv Mode     ${test_log_directory}/ttitrace_streaming_dl/
    Check DL rnti per slot    ${test_log_directory}/ttitrace_streaming_dl/    ${8}
    Verify fdm max dl Counters   8
    Detach multiple SA UEs      max_ue_num=${UE_NUM}

*** Keywords ***

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
#    Start DL Traffic        ${ue_id}   ${dl_tput}
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
#    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END
