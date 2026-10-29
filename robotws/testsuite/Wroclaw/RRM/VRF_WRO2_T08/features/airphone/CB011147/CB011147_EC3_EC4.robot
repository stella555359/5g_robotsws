*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65    SBTS00

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :maintainer: marcin.plawny@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_ue_measurements
Library    ta5g_testline_management
Library    ta5g_tshark
Library    testsuite/Wroclaw/RRM/resources/syslog_checker.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Backup And Modify Swconfig File    parameters_list=@{swconfig_flag}
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_11147.json    skip_relation_errors=False
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../scf_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_11147.cfg    mplane_cells=${mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Teardown

*** Variables ***
@{mplane_cells}=    5    6    9    12
@{swconfig_flag}=    0x5B024B=0

*** Test Cases ***
CB011147_A_EC3_A4_MR_for_mobility_to_higher_prio_NR_freq_during_SCell_addition_and_a4SupervisionTimer_running
    [Documentation]    The tests describes interaction between A4 Measurement Report for "mobility to higher priority NR frequency"
    ...                received while SCell addition is ongoing.
    Attach UE And Add 2 Scells
    Send Custom Ue Measurement Nr    id=1    meas_id=10    event=A4    phycell_id=63    nrsrp_nr=100
    ...    pass_regexp=XN Handover Successfully completed

    Verify Tshark For ScellAddition And HO

CB011147_A_EC4_Handover_preparation_failure_and_BufferCriterionNotification_received_during_the_handover_preparation
    [Documentation]    The tests describes interaction between A4 MR for mobility to higher priority NR frequency received
    ...                and ongoing SCell addition.
    Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=3 action=force_failure_with_delay time_to_wait=v1s cause=handover_target_not_allowed
    Attach UE And Add 2 Scells    ue_id=2
    Send Custom Ue Measurement Nr    id=2    meas_id=10    event=A4    phycell_id=63    nrsrp_nr=100
    ...    pass_regexp=HandoverPreparationFailure sent to GNB-2
    Sleep    2
    Send Custom Ue Measurement Nr    id=2    meas_id=11    event=A2    srsrp_nr=100    scell=1    scell_rsrp=20
    Send Custom Ue Measurement Nr    id=2    meas_id=12    event=A2    srsrp_nr=100    scell=2    scell_rsrp=20

    Verify Tshark For ScellAddition And HO Failure

    [Teardown]    Run Keywords    Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 reset    AND    Teardown

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB3_XN    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_NG    ip_with_mask=10.0.1.6/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB3_XN    ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB3_NG    ip_with_mask=10.0.1.6/24

Verify Tshark Message
    [Arguments]    ${packet_filter}    ${pass_criteria}= ==1
    Verify Tshark
    ...    alias=default_tcpdump_alias
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${pass_criteria}
    ...    pcap_file_path=default

Verify Tshark For ScellAddition And HO
    Verify Tshark Message   packet_filter=f1ap.UEContextModificationResponse_element && nr-rrc.gapUE == 1
    Verify Tshark Message   packet_filter=f1ap.UEContextModificationRequest_element && f1ap.SCell_ToBeSetupMod_List == 2
    Verify Tshark Message   packet_filter=xnap.HandoverRequest_element && xnap.radioNetwork == "resource-optimisation-handover"

Verify Tshark For ScellAddition And HO Failure
    Verify Tshark Message   packet_filter=f1ap.UEContextModificationResponse_element && nr-rrc.gapUE == 1
    Verify Tshark Message   packet_filter=f1ap.UEContextModificationRequest_element && f1ap.SCell_ToBeSetupMod_List == 2
    Verify Tshark Message   packet_filter=xnap.HandoverPreparationFailure_element && xnap.radioNetwork == "handover-target-not-allowed"
    Verify Tshark Message   packet_filter=f1ap.UEContextModificationRequest_element && f1ap.SCell_ToBeRemoved_List == 1    pass_criteria= ==2

Attach UE And Add 2 Scells
    [Arguments]    ${ue_id}=1
    Set Internal Traffic Type For UE    ue=${ue_id}    pdu=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 Mbps=160 dir=dl trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 Mbps=160 dir=dl trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 Mbps=160 dir=dl trf_id=3
    Get UE Measurement Configuration    ue_id=${ue_id}
    Execute Egate Command    cmd=script file=${CURDIR}/script_ue${ue_id}.txt
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone    timeout=35
    Sleep    2

Teardown
    Deregister UE Without Confirmation    ue_id=1,2
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Add Scout Scf Id To Test Data
    Run Keyword If Test Passed    Find Suspicious Logs
