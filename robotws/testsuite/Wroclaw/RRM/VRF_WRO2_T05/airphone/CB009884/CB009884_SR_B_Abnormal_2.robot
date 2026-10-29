*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY311
...           CONFIGURED    NoResUsage    TOOLS_PROFILE_TTI_LEGACY    OPTION_RELATED_ARTIFACTS_5G

Documentation    :copyright: Nokia
...              :authors: Dominik Borkowski
...              :contact: dominik.borkowski@nokia.com

Resource    CB009884_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_xn_and_a5_activation_pmqap.json
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../5GC000770/config/egate_2gNB_2c_tdd_2c_fdd_sansa.lua
...            AND             Wait For Xn Link Status Value Change    xn_link_id=10    value=available    timeout=60
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords  Roll Delta Back
...                             initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                             delta_scf_filename=delta_xn_and_a5_activation_pmqap.json
...               AND           Stop Default Processes And Gather Logs And Compress Logs


*** Test Cases ***
CB009884_SR_B_User_Scenario_SA_QosFlow_Release_Abnormal_PROCEDURE_1_2
    [Documentation]   This test case checks if counter NG_FLOW_REL_ABNORMAL_PMQAP
    ...               is properly incremented during not successful XN Inter gNB HO.
    ...               Lua file with simulated gNB-3 and XN link.
    ...               Delta scf with XN link and NRPMQAP objects.
    ...               For UE-ID 1:
    ...               Initial PDU Session is triggered with traffic,
    ...               Prepare simulator to drop UE during RRC Reconfiguration,
    ...               Trigger XN Inter gNB HO, UE should be released.
    ...               QOSFlows associated with PDU Session should be released.
    ...               Counters updated.
    ...               Abnormal cause is a cause that is not considered as Normal cause.
    ...               A cause that might result from an error or not expected scenario.
    ...               In this scenario release is triggered by GNB.


    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Attach Ue    ue_id=1
    Establish PDU Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Ue NR RRC Reconf Param    ue_id=1    if_contains=any    action=drop
    Send Custom UE Measurement NR  id=1 meas_id=1 index=0 nrs_result=50:56:0 event=A5 phycell_id=52 nrsrp_nr=50 srsrp_nr=56
    ...                            pass_regexp=UE CONTEXT RELEASE COMPLETE
    ...                            timeout=10
    Verify Ngap Messages    packet_filter=${NGAP_UECONTEXT_RELEASE_ABNORMAL_XN}  number_of_messages=1
    Verify Ngap Messages    packet_filter=${NGAP_PDU_SESSION_RELEASE}  number_of_messages=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55125C09028   +1    NG_FLOW_REL_ABNORMAL
    ...    M55163C03009   +1    NG_FLOW_REL_ABNORMAL_PMQAP
    ...    M55125C01001   +1    NNGCC_UE_CTXT_REL_REQ_SENT
    ...    M55145C04034   +1    NG_UE_CTXT_REL_GNB_ABNRML_PLMN
    ...    M55145C04037   +1    NG_UE_CTXT_REL_GNB_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


