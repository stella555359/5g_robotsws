*** Settings ***
Documentation    Suite documentation
...    author:  damon.lei@nokia-sbell.com
...    contact: damon.lei@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv_tmo_65    ue_count=1
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_LOO_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${EMIL_FLAG}    ${False}
${AUTO_ANALYSIS_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:True,fail:True
${SOS_REPORT_FLAG}    pass:False,fail:False
${GNB_BIP_FLAG}    ${False}
${AP_BIP_FLAG}    ${False}
${RECREATE_WIRESHARK_FLAG}    ${False}
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${pdu_id}    1
${gw_id}    1
${PDU_ADD_VIA_MODIFY_SUCCESS}    QoS Routing Table
${PDU_ADD_VIA_MODIFY_FAILED}    PDU Session Resource Modify Unsuccessful Transfer
@{intraGNB_ho_succ}
...    Intra-eNB handover from EXT_ENB-2.8 to EXT_ENB-2.2 performed

*** Test Cases ***
CB008195_SR_K17_Verify_online_Enabling_Disabling_RG_level_GBR_checks_with_SA_GBR_DRBs_established_maxGBRTrafficLimit
    [Documentation]
    ...    The test scenario is intended to verify This user scenario: This user scenario describes the gNB behavior
    ...    while RG level GBR checks in Slice-Aware Admission Control is online enabled or disabled and then
    ...    established PDU session with GBR bearers.
    ...    1. [Configuration]:
    ...       maxGBRTrafficLimit=40, Cell2/3/6 belongs to same L2 pool
    ...       Cell2/3/6 RG1: minQuota=0, maxQuota=26
    ...       Cell2/3/6 RG2: minQuota=24, maxQuota=74
    ...    2. Test Case Steps:
    ...       Step1: Lock cell2/cell6
    ...       Step2: unLock cell2
    ...       Step3: online change GBR RG level check to NonBypass
    ...       Step4: UE1 attach to Cell2 with 5QI6 setup
    ...       Step5: 5QI4 setup via pdu session modify
    ...       Step6: start traffic on GBR qosflow
    ...       Step7: UE2 attach to Cell2 with 5QI6
    ...       Step8: start traffic on 5QI6 qosflow
    ...       Step10: setup 5QI4 qosflow via pdu session modify
    ...       Step11: check counters
    ...       Step12: Lock cell2/cell6
    ...       Step13: unLock cell2
    ...       Step14: online change GBR RG level check to Bypass
    ...       Step15: UE1 attach to Cell2 with 5QI6 setup
    ...       Step16: 5QI4 setup via pdu session modify
    ...       Step17: start traffic on GBR qosflow
    ...       Step18: UE2 attach to Cell2 with 5QI6
    ...       Step19: start traffic on 5QI6 qosflow
    ...       Step20: setup 5QI4 qosflow via pdu session modify
    ...       Step21: check counters
    ...       Step22: UEs release.
    ...    3. Expected Results:
    ...       Step1: cell2/cell6 locked successfully
    ...       Step2: cell2 unlocked successfully
    ...       Step3: online change successfully performed
    ...       Step4: UE1 attach successfully
    ...       Step5: 5QI4 setup successfully
    ...       Step6: traffic started
    ...       Step7: UE2 attached successfully
    ...       Step8: start traffic on 5QI6 qosflow
    ...       Step10: 5QI4 setup failed due to GbrDl RG max check fails
    ...       Step11: counters updated correctly
    ...       Step12: cell2/cell6 lock
    ...       Step13: cell2 unlocked
    ...       Step14: online change successfully performed
    ...       Step15: UE1 attached successfully
    ...       Step16: 5QI4 setup successfully
    ...       Step17: start traffic on GBR qosflow
    ...       Step18: UE2 attached successfully
    ...       Step19: start traffic on 5QI6 qosflow
    ...       Step20: 5QI4 setup successfully since no RG level GBRDL check
    ...       Step21: counters updated correctly
    ...       Step22: UEs sucessflly released
    [Tags]    K02 K17
    Delta Commission Parameters    ${DELTA_PARAS_Lock_Cell}
    Delta Commission Parameters    ${DELTA_PARAS_UnLock_Cell}
    Delta Commission Parameters    ${DELTA_PARAS_NonBypass}
    Clear Counter files
    Set qosflow GFBR    qosflow_id=7    gfbr_dl=2800    gfbr_ul=28000
    UE SA Attach To Target Cell    ue_id=1    nwslice=1    cell_id=2
    Add Qosflow With PDU Session Modify    ue_id=1    pdu_id=1    qosflows_to_add=7
    ...    expect_result=${PDU_ADD_VIA_MODIFY_SUCCESS}
    Send Throuput    ue_id=1    qfi_id=2
    UE SA Attach To Target Cell    ue_id=2    nwslice=1    cell_id=2
    Send Throuput    ue_id=2    qfi_id=1
    Add Qosflow With PDU Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=7
    ...    expect_result=${PDU_ADD_VIA_MODIFY_FAILED}
    Release Ues    ue_type=sa    ue_id=2
    UE SA Attach To Target Cell    ue_id=2    nwslice=1    cell_id=8
    Send Throuput    ue_id=2    qfi_id=1
    Add Qosflow With PDU Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=7
    ...    expect_result=${PDU_ADD_VIA_MODIFY_SUCCESS}
    Trigger Interfreq Handover
    Check Counters    pm_counters_expression=${PM_Counters_Check_K17_1}
    Delta Commission Parameters    ${DELTA_PARAS_Lock_Cell}
    Delta Commission Parameters    ${DELTA_PARAS_UnLock_Cell}
    Delta Commission Parameters    ${DELTA_PARAS_Bypass}
    Release Ues    ue_type=all
    Clear Counter files
    UE SA Attach To Target Cell    ue_id=1    nwslice=1    cell_id=2
    Add Qosflow With PDU Session Modify    ue_id=1    pdu_id=1    qosflows_to_add=7
    ...    expect_result=${PDU_ADD_VIA_MODIFY_SUCCESS}
    Send Throuput    ue_id=1    qfi_id=2
    UE SA Attach To Target Cell    ue_id=2    nwslice=1    cell_id=2
    Send Throuput    ue_id=2    qfi_id=1
    Add Qosflow With PDU Session Modify    ue_id=2    pdu_id=1    qosflows_to_add=7
    ...    expect_result=${PDU_ADD_VIA_MODIFY_SUCCESS}
    Check Counters    pm_counters_expression=${PM_Counters_Check_K17_2}
    Release Ues    ue_type=all

*** Keywords ***
Trigger Interfreq Handover
    [Arguments]    ${expect_ho_regexp}=${intraGNB_ho_succ}
    Report A2 Event
    Report A5 Event    fail_regexp=${expect_ho_regexp}

Report A2 Event
    [Arguments]    ${ue_id}=2    ${ssbfreq}=396970
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    eventA5
    Sleep    2s    #wait

Report A5 Event
    [Arguments]    ${fail_regexp}    ${ue_id}=2    ${carrierfreq}=502110    ${target_phycell_id}=52
    ${meas_id_scell}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${event_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_scell} event=A5
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=${target_phycell_id} nrsrp_nr=110 nrsrq_nr=110
    Execute Egate Command    ${event_cmd}
    ...    fail_regexp=${fail_regexp}
    Sleep    2s    #wait

Send Throuput
    [Arguments]    ${ue_id}=1    ${qfi_id}=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=100 trf_id=1
    ...    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=40 trf_id=1
    ...    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

UE SA Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}
    ...    QoS Routing Table

Add Qosflow With PDU Session Modify
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qosflows_to_add}=2    ${expect_result}={EMPTY}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add}
    ...    pass_regexp=${expect_result}

Set qosflow GFBR
    [Arguments]    ${qosflow_id}=2    ${gfbr_dl}=28000    ${gfbr_ul}=28000
    Execute Egate Command    qosflow_modify qos_flow=${qosflow_id} gfbr_dl=${gfbr_dl} gfbr_ul=${gfbr_ul}

Add Aditional qosflow
    [Arguments]    ${qosflow_id}=2    ${smf_id}=1
    Execute Egate Command    smf_param additional_qosflows_to_activate=${qosflow_id} id=${smf_id}
