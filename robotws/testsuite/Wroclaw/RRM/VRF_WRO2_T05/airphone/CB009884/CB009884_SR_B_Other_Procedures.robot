*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY311
...           CONFIGURED    NoResUsage    TOOLS_PROFILE_TTI_LEGACY    OPTION_RELATED_ARTIFACTS_5G

Documentation    :copyright: Nokia
...              :authors: Dominik Borkowski
...              :contact: dominik.borkowski@nokia.com

Resource    CB009884_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_pmqap_profiles.json
...            AND             Backup And Modify Swconfig File    parameters_list=@{Radio_Connection}
...            AND             Trigger Site Reset
...            AND             Check Radios Availability
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_vonr.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords
...                            Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB009884_SR_B_User_Scenario_SA_QOSFlow_Release_Failure_In_Radio_Interface_Procedure_Scenario_1
    [Documentation]   This test case checks if counters:
    ...               NG_UE_CTXT_REL_GNB_INTRCT_PROC,
    ...               NG_FLOW_GNB_REL_RDPRCDFL_PMQAP
    ...               are properly incremented during not successful RRC Reconfiguration.
    ...               Lua file with VoNR UE capabilities supported.
    ...               Delta scf with NRPMQAP objects.
    ...               For UE-ID 1 rrcReestabTypeSA=sameGNB
    ...               Initial PDU Session is triggered with traffic,
    ...               Prepare simulator to reestablish cause RRC reconfigurationFailure,
    ...               Trigger RRC Reestablish,
    ...               UE should be released with cause interaction-with-other-procedure.
    ...               QOSFlows associated with PDU Session should be released.
    ...               Counter NG_UE_CTXT_REL_GNB_INTRCT_PROC is updated.
    ...               For UE-ID 51 rrcReestabTypeSA=deactivated
    ...               Initial PDU Session is triggered with traffic,
    ...               Add additional QoS Flow, trigger RRC Reestablish,
    ...               UE should be release with cause failure-in-radio-interface-procedure.
    ...               Counter NG_FLOW_GNB_REL_RDPRCDFL_PMQAP is updated.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Activate Additional 5QI
    Attach Ue    ue_id=51
    Establish PDU Session With Traffic    ue_id=51    pdu_id=1    gw_id=1
    Ue NR RRC Reconf Param     ue_id=51    if_contains=any    action=reestablish    cause=reconfigurationFailure
    Initiate UE RRC Reestablishment    ue_id=51
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_Interaction_Other_Procedure}  number_of_messages=1
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE_1} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55163C03009   +0    NG_FLOW_REL_ABNORMAL_PMQAP
    ...    M55125C13059   +1    NG_UE_CTXT_REL_GNB_INTRCT_PROC
    ...    M55125C13050   +1    NG_FLOW_REL_5QI1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE_1}
    ...    report_pm_counter=True
    Perform Parameter Commissioning    parameter=rrcReestabTypeSA    value=deactivated
    Perform Parameter Commissioning    parameter=actInterGnbRREPreparedCell    value=false
    Reset SMF
    Attach Ue    ue_id=52
    Establish PDU Session With Traffic    ue_id=52    pdu_id=2    gw_id=2
    Initiate UE RRC Reestablishment    ue_id=52    pass_regexp=T301
    Verify Ngap Messages    packet_filter=${NGAP_UE_Release_Failure_In_Radio_Interface}  number_of_messages=2
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE_2} =    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55163C03009   +1    NG_FLOW_REL_ABNORMAL_PMQAP
    ...    M55163C00016   +1    NG_FLOW_GNB_REL_RDPRCDFL_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${PM_COUNTER_FILE_2}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=51-52
        ...       AND             Add Scout External Execution ID To Reporting Portal
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
