*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Documentation    :copyright: Nokia
...              :authors: Przemysław Sas, Tomasz Niedzwiedzki, Marcin Pławny
...              :contact: przemyslaw.sas@nokia.com, tomasz.niedzwiedzki@nokia.com, marcin.plawny@nokia.com
...              :maintainer: marcin.plawny@nokia.com

Resource    CB008225_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8225_cell2_no_ranac.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_ran_sharing.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Wait For Next Full PM Interval
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_8225_cell2_no_ranac.json

Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...           AND             Wait For Next Full PM Interval
Test Teardown    Run Keywords    Deregister UE Without Confirmation    ue_id=all
...              AND             Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Run Keyword And Ignore Error    Stop Downlink Traffic
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB008225_B_B2_Success_Trans_RRC_CONNECTED_UE_To_RRC_INACTIVE_UE_Assistance_Information_Based
    [Documentation]    This test case describes the gNB behaviour for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state. To configure UE for RRC_INACTIVE state gNB adds suspendConfig IE
    ...                into RRC: RRCRelease message. Before sending UE to RRC_INACTIVE state, gNB-CU-CP checks feature activation,
    ...                RRC_INACTIVE state UE capability, CoreNetworkAssistanceInformationForInactive IE,
    ...                UE shall not have 5QI1 DRB established, UE shall not be identified as RedCap UE.
    ...                5G_RAN_USR_RRM_18113, 5G_PM_961

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=6    amf_id=2
    ...                                                                                      plmn_id=311:492    tac_id=200
    Set UE To Ignore Paging    ue_id=6
    Set Internal Traffic Type For Ue    ue=9    pdu=1
    Attach UE    ue_id=6
    Establish PDU Session    ue_id=6    pdu_id=1    gw_id=1
    Modify PDU Session    ue_id=6    pdu_id=1    qos_to_add=2
    Send ReleasePreference
    Verify Traces For Successful Transition To RRC INACTIVE
    Attach UE    ue_id=9
    Establish PDU Session    ue_id=9    pdu_id=1    gw_id=2
    Modify PDU Session    ue_id=9    pdu_id=1    qos_to_add=2
    Sleep    1
    Start Data Traffic    ues=9    direction=dl    optional_parameters=pdu=1 qfi=1 mbps=1
    Start Data Traffic    ues=9    direction=dl    optional_parameters=pdu=1 qfi=2 mbps=1
    Start Downlink Traffic    ue_ip=1.2.4.7    duration=30    check_if_tput_started=False
    Sleep    1
    AMF NG Context Release    ue_id=6
    AMF NG Context Release    ue_id=9
    Wait For Next Full PM Interval
    Stop Data Traffic    ues=9    pdu=1    direction=dl
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55133C01004  7  NE1US_CTXT_MOD_REQ_RECD
    ...    M55133C01005  7  NE1US_CTXT_MOD_RSP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55135C00505  7  NE1CS_CTXT_MOD_REQ_SENT
    ...    M55135C00506  7  NE1CS_CTXT_MOD_RSP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55124C00001  1  NRRCC_RRC_RELEASE_SENT
    ...    M55124C00006  1  NRRCC_RRC_REL_WITH_SUSP_NRNAU
    ...    M55125C00021  2  NG_FLOW_SUSP_RRC_CONN_INACTIVE
    ...    M55163C00010  1  NG_FLOW_SUS_RRC_CON_INCT_PMQAP
    ...    M55125C09018  0  NG_FLOW_REL_AMF_UE_LOST
    ...    M55163C00518  0  NG_FLOW_REL_AMF_UE_LOST_PMQAP
    ...    M55125C09026  0  NG_FLOW_REL_ABNORMAL_INSESSION
    ...    M55163C00014  0  NG_FLOW_REL_ABNRM_INSESN_PMQAP
    ...    M55125C09027  0  NG_FLOW_REL_AMF_UE_LOST_INSESN
    ...    M55163C00015  0  NG_FLOW_REL_AMF_UELSTISN_PMQAP
    ...    M55124C00016  1  UAI_RRC_REL_INACT_PREF_INACT
    ...    M55125C08503  2  NG_FLOW_REL
    ...    M55125C08504  2  NG_FLOW_REL_NORMAL
    ...    M55163C00004  1  NG_FLOW_REL_NORMAL_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55125C09018  2  NG_FLOW_REL_AMF_UE_LOST
    ...    M55163C00518  1  NG_FLOW_REL_AMF_UE_LOST_PMQAP
    ...    M55125C09026  2  NG_FLOW_REL_ABNORMAL_INSESSION
    ...    M55163C00014  1  NG_FLOW_REL_ABNRM_INSESN_PMQAP
    ...    M55125C09027  2  NG_FLOW_REL_AMF_UE_LOST_INSESN
    ...    M55163C00015  1  NG_FLOW_REL_AMF_UELSTISN_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB008225_C_B7_NGAP_NGReset_For_UE_RRC_INACTIVE
    [Documentation]    This user scenario describes reception of NGAP:NGReset (partial) for the UEs in RRC_INACTIVE state
    ...                5G_RAN_USR_RRM_18728, 5G_PM_980

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1
    Set Internal Traffic Type For Ue    ue=10    pdu=1
    Set UE To Ignore Paging    ue_id=1
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    gw_id=1
    Modify PDU Session    ue_id=1    pdu_id=1    qos_to_add=2
    Attach UE    ue_id=10
    Establish PDU Session    ue_id=10    gw_id=2
    Modify PDU Session    ue_id=10    pdu_id=1    qos_to_add=2
    Start Data Traffic    ues=10    direction=dl    optional_parameters=pdu=1 qfi=1 mbps=1
    Start Data Traffic    ues=10    direction=dl    optional_parameters=pdu=1 qfi=2 mbps=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition to RRC INACTIVE
    Set Parameters For NG Link Reset    id=1    gnb_id=2    action=logical_error    error_type=empty_ie    cause=MISC_unspecified    msg=resp
    Start Downlink Traffic    ue_ip=1.2.4.2    duration=30    check_if_tput_started=False
    Sleep    1
    Reset NG Link For UE    amf_id=1    ue_id=1
    Reset NG Link For UE    amf_id=1    ue_id=10
    Verify Traces For NG Resets

    Wait For Next Full PM Interval
    Stop Data Traffic    ues=10    pdu=1    direction=dl
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55125C09017  0  NG_FLOW_REL_NG_RESET_AMF
    ...    M55163C00517  0  NG_FLOW_REL_AMF_NG_RESET_PMQAP
    ...    M55125C09028  0  NG_FLOW_REL_ABNORMAL
    ...    M55163C03009  0  NG_FLOW_REL_ABNORMAL_PMQAP
    ...    M55125C00020  2  NG_FLOW_REL_RRC_INACTIVE_IDLE
    ...    M55125C08503  2  NG_FLOW_REL
    ...    M55125C08504  2  NG_FLOW_REL_NORMAL
#    ...    M55163C00004  1  NG_FLOW_REL_NORMAL_PMQAP    under investigation
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55125C09017  2  NG_FLOW_REL_NG_RESET_AMF
    ...    M55163C00517  1  NG_FLOW_REL_AMF_NG_RESET_PMQAP
    ...    M55125C09028  2  NG_FLOW_REL_ABNORMAL
    ...    M55163C03009  1  NG_FLOW_REL_ABNORMAL_PMQAP
    ...    M55125C08503  2  NG_FLOW_REL
    ...    M55125C08504  0  NG_FLOW_REL_NORMAL
    ...    M55163C00004  0  NG_FLOW_REL_NORMAL_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55119C00012  2  NG_CU_RESET_REQ_RCV
    ...    M55119C00013  2  NG_CU_RESET_ACK_SENT
    ...    M55121C00501  2  E1_RESET_SENT_CUCP
    ...    M55121C00502  2  E1_RESET_ACK_RECD_CUCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB008225_D_B5_UE_In_RRC_INACTIVE_Reselection_From_NR_Cell_1_With_Configured_Ranac_To_NR_Cell_2_Without_Configured_Ranac
    [Documentation]    This user scenario describes reselection of UE in RRC_INACTIVE state from NR Cell#1
    ...                with configured ranac (RRC_INACTIVE supported) to NR Cell#2 without configured ranac
    ...                (RRC_INACTIVE NOT supported). Counter NG_FLOW_REL is increamented only for NRCELL-2.
    ...                5G_RAN_USR_RRM_18673, 5G_PM_979

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    gw_id=2
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=2    msg=resume_request    cause=rna_Update
    Send UE RRC Resume Request    ue_id=2
    Verify Traces For Successful Reselection Of UE In RRC INACTIVE

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55125C00020  0  NG_FLOW_REL_RRC_INACTIVE_IDLE
    ...    M55163C00009  0  NG_FLOW_REL_RRC_INCT_IDL_PMQAP
    ...    M55125C08503  0  NG_FLOW_REL
    ...    M55124C00014  0  NRRCC_RRC_RESUME_FALLBACK_SUCC
    ...    M55124C00013  0  NRRCC_RRC_RESUME_FALLBACK_ATT
    ...    M55124C00008  0  NRRCC_RRC_RESUME_REQUEST
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55125C00020  0  NG_FLOW_REL_RRC_INACTIVE_IDLE
    ...    M55163C00009  0  NG_FLOW_REL_RRC_INCT_IDL_PMQAP
    ...    M55125C08503  1  NG_FLOW_REL
    ...    M55124C00014  1  NRRCC_RRC_RESUME_FALLBACK_SUCC
    ...    M55124C00013  1  NRRCC_RRC_RESUME_FALLBACK_ATT
    ...    M55124C00008  1  NRRCC_RRC_RESUME_REQUEST
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB008225_D_E6_Internal_Parameter_maxUeRrcInactTime_Timer_Expires
    [Documentation]    This user scenario test  the gNB behaviour for UE in RRC_INACTIVE state that internal timer
    ...                NRBTS.maxUeRrcInactTime is expired. Inactive UE Context is "silently" released
    ...                (UE is not notified).
    ...                5G_RAN_USR_RRM_18100, 5G_PM_974

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1    parameter=maxUeRrcInactTime    value=1
    ...        AND             Wait For Next Full PM Interval

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    gw_id=3
    Wait For Release RRC Inactive Conditions Met
    Wait For MaxUeRrcInactTime Timer To Expire
    Verify Traces For Successful Transition to RRC INACTIVE
    Verify Traces For Inactive UE Release After MaxUeRrcInactTime Timer Expired

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55133C00002  1  NE1US_CTXT_REL_CMP_SENT
    ...    M55133C00001  1  NE1US_CTXT_REL_CMD_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55135C00001  1  NE1CS_CTXT_REL_CMD_SENT
    ...    M55135C00002  1  NE1CS_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55163C00006  1  NG_FLOW_SUS_REL_INACTVTY_PMQAP
    ...    M55163C00009  1  NG_FLOW_REL_RRC_INCT_IDL_PMQAP
    ...    M55125C00502  1  NNGCC_UE_CTXT_REL_CMP_SENT
    ...    M55125C09004  1  NG_FLOW_REL_GNB_UE_INACTIVITY
    ...    M55125C08504  1  NG_FLOW_REL_NORMAL
    ...    M55125C00015  1  NG_FLOW_SUSP_REL_INACTIVITY
    ...    M55125C01001  1  NNGCC_UE_CTXT_REL_REQ_SENT
    ...    M55125C00016  1  INACT_UE_CTXT_REL_INACTIVITY
    ...    M55125C08503  1  NG_FLOW_REL
    ...    M55125C00503  1  NNGCC_UE_CTXT_REL_REQ_INACTIVE
    ...    M55125C00020  1  NG_FLOW_REL_RRC_INACTIVE_IDLE
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

*** Keywords ***
Send ReleasePreference
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=6 PreferredRRCState=inactive    pass_regexp=UE.: Is INACTIVE

Set Parameters For NG Link Reset
    [Arguments]    ${id}    ${gnb_id}    ${action}    ${error_type}    ${cause}    &{msg}
    Execute Egate Command    cmd=ng_link_reset_param id=${id} gnb=${gnb_id} action=${action} error_type=${error_type}
    ...                      ntimes=2 nth=1 cause=${cause} msg=&{msg}

Reset NG Link For UE
    [Arguments]    ${amf_id}    ${ue_id}
    Execute Egate Command    cmd=link_ng_reset by=amf:${amf_id} ue=${ue_id} ue_ngap_id_type=both

Wait For MaxUeRrcInactTime Timer To Expire
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST_DUE_TO_USER_INACTIVITY}    timeout=80
