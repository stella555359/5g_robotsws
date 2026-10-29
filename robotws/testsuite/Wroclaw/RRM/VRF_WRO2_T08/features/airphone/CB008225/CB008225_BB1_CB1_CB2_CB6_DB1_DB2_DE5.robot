*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny, Bartosz Grzegorczyk, Sebastian Maslak
...              :contact: marcin.plawny@nokia.com
...              :maintainer: marcin.plawny@nokia.com

Resource    CB008225_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8225_no_ran_sharing.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Wait For Next Full PM Interval
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_8225_no_ran_sharing.json

Test Setup    Run Keywords    Wait For Next Full PM Interval
...           AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Deregister UE Without Confirmation    ue_id=all
...              AND             Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB008225_B_B1_Success_Trans_RRC_CONNECTED_UE_To_RRC_INACTIVE_Inactivity_Based_5GC000723_5GC000752
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure.
    ...                5G_RAN_USR_RRM_18017, 5G_PM_960, 5G_PM_977, 5G_PM_983

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1
    Set Internal Traffic Type For Ue    ue=12    pdu=1
    Set UE To Ignore Paging    ue_id=1
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    gw_id=1
    Modify PDU Session    ue_id=1    pdu_id=1    qos_to_add=5
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Attach UE    ue_id=12
    Establish PDU Session    ue_id=12    gw_id=2
    Modify PDU Session    ue_id=12    pdu_id=1    qos_to_add=5
    Sleep    1
    Start Data Traffic    ues=12    direction=dl    optional_parameters=pdu=1 qfi=1 mbps=1
    Start Data Traffic    ues=12    direction=dl    optional_parameters=pdu=1 qfi=2 mbps=1
    Start Downlink Traffic    ue_ip=1.2.4.2    duration=30    check_if_tput_started=False
    Sleep    1
    AMF NG Context Release    ue_id=1    cause=RN_user_inactivity
    Sleep    1
    AMF NG Context Release    ue_id=12    cause=RN_user_inactivity
    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55133C01004  7  NE1US_CTXT_MOD_REQ_RECD
    ...    M55133C01005  7  NE1US_CTXT_MOD_RSP_SENT
    ...    M55133C00001  2  NE1US_CTXT_REL_CMD_RECD
    ...    M55133C00002  2  NE1US_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55135C00505  7  NE1CS_CTXT_MOD_REQ_SENT
    ...    M55135C00506  7  NE1CS_CTXT_MOD_RSP_RECD
    ...    M55140C00001  1  PEAK_NUMBER_OF_SA_RRC_USERS_CU
    ...    M55140C00002  1  PEAK_NBR_OF_SA_NGBR_USERS_CU
    ...    M55140C00501  0  PEAK_NBR_OF_SA_GBR_USERS_CU
    ...    M55135C00002  2  NE1CS_CTXT_REL_CMP_RECD
    ...    M55135C00001  2  NE1CS_CTXT_REL_CMD_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55124C00001  1  NRRCC_RRC_RELEASE_SENT
    ...    M55124C00006  1  NRRCC_RRC_REL_WITH_SUSP_NRNAU
    ...    M55125C00021  2  NG_FLOW_SUSP_RRC_CONN_INACTIVE
    ...    M55163C00010  1  NG_FLOW_SUS_RRC_CON_INCT_PMQAP
    ...    M55138C00017  >1  AVE_SA_RRC_HOLDING_TIME
    ...    M55138C00018  1  AVE_SA_RRC_HOLDING_TIME_DEN
    ...    M55138C00019  >1  PEAK_SA_RRC_HOLDING_TIME
    ...    M55138C00020  >1  AVE_SA_NGBR_HOLDING_TIME
    ...    M55138C00021  2  AVE_SA_NGBR_HOLDING_TIME_DEN
    ...    M55138C00022  >1  PEAK_SA_NGBR_HOLDING_TIME
    ...    M55138C01008  0  AVE_SA_GBR_HOLDING_TIME
    ...    M55138C01009  0  AVE_SA_GBR_HOLDING_TIME_DEN
    ...    M55138C01010  0  PEAK_SA_GBR_HOLDING_TIME
    ...    M55138C00008  >1  AVE_NUMBER_OF_SA_RRC
    ...    M55138C00009  300  AVE_NUMBER_OF_SA_RRC_DENOM
    ...    M55138C00014  1  PEAK_NUMBER_OF_SA_RRC_USERS
    ...    M55138C00033  1  PEAK_NUMBER_OF_SA_RRC_GR
    ...    M55161C00002  300  AVE_NUMB_OF_SA_RRC_DENOM_PMQAP
    ...    M55161C00003  1  PEAK_NUMB_OF_SA_RRC_USER_PMQAP
    ...    M55138C00016  1  PEAK_NUMBER_OF_SA_NGBR_USERS
    ...    M55138C00034  1  PEAK_NBR_OF_SA_NGBR_USERS_GR
    ...    M55138C00012  >1  AVE_NUMBER_OF_SA_NGBR_USERS
    ...    M55138C00013  300  AVE_NUM_OF_SA_NGBR_USERS_DENOM
    ...    M55138C00050  >1  AVE_NUMBER_OF_RRC_INACT_NOM
    ...    M55181C00003  300  AVG_NUM_UE_DENOM
    ...    M55125C08504  2  NG_FLOW_REL_NORMAL
    ...    M55163C00004  1  NG_FLOW_REL_NORMAL_PMQAP
    ...    M55125C09019  2  NG_FLOW_REL_AMF_NORMAL
    ...    M55163C00519  1  NG_FLOW_REL_AMF_NORMAL_PMQAP
    ...    M55125C09025  1  NG_FLOW_REL_NORMAL_INSESSION
    ...    M55163C00013  1  NG_FLOW_REL_NORM_INSESSN_PMQAP
    ...    M55125C00019  >1  NG_FLOW_SES_TIME_EXCL_SUSP
    ...    M55163C00008  >1  NG_FLOW_SES_TIME_EXC_SUS_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55125C08504  2  NG_FLOW_REL_NORMAL
    ...    M55163C00004  1  NG_FLOW_REL_NORMAL_PMQAP
    ...    M55125C09019  2  NG_FLOW_REL_AMF_NORMAL
    ...    M55163C00519  1  NG_FLOW_REL_AMF_NORMAL_PMQAP
    ...    M55125C09025  2  NG_FLOW_REL_NORMAL_INSESSION
    ...    M55163C00013  1  NG_FLOW_REL_NORM_INSESSN_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=1
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Run Keyword And Ignore Error    Stop Downlink Traffic
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

CB008225_C_B1_RAN_Paging_For_UE_RRC_INACTIVE_DL_From_UPF
    [Documentation]    RAN Paging for the UEs in RRC_INACTIVE state for DL user plane data arrival from UPF.
    ...                Successful scenario.
    ...                5G_RAN_USR_RRM_18015, 5G_PM_969

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    gw_id=2
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Start Downlink Traffic    ue_ip=1.2.4.2    duration=15
    Sleep    5s    reason=Wait for data traffic transfer to start
    Verify Traces For Successful Transition to RRC CONNECTED By MT Access
    Verify UE Stays Connected
    Stop Downlink Traffic

    ${RD_COUNTER_FILE}=    Get Next Unpacked Raw RD Counters File
    Verify Any Counters In File
    ...    PDCP_SDU_BUFFER_RRC_INACT_UE  >1  M55320CRD50005
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${RD_COUNTER_FILE}

    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55117C00004  1  NF1CD_RAN_PAGING_SUCC_SENT
    ...    M55117C03001  1  NF1CD_F1AP_PAGING_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55133C01004  4  NE1US_CTXT_MOD_REQ_RECD
    ...    M55133C01005  4  NE1US_CTXT_MOD_RSP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55124C00007  1  NRRCC_RRC_RESUME_REQUEST1
    ...    M55124C00010  1  NRRCC_RRC_RESUME_SUCC
    ...    M55331C00004  1  NRPAG_RAN_PAGING_SUCC_SENT
    ...    M55125C00022  1  NG_FLOW_RESUME_RRC_INACT_CONN
    ...    M55163C00011  1  NG_FLOW_RES_RRC_INCT_CON_PMQAP
    ...    M55125C00023  >1  NG_FLOW_TIME_SUSP
    ...    M55163C00012  >1  NG_FLOW_TIME_SUSP_PMQAP
    ...    M55138C00052  >1  AVE_SA_RRC_INACTIVE_TIME_NOM
    ...    M55138C00053  1  AVE_SA_RRC_INACTIVE_TIME_DEN
    ...    M55138C00054  >1  PEAK_SA_RRC_INACTIVE_TIME
    ...    M55138C00059  >1  DL_DELAY_PAGING_RRC_INCT_CON
    ...    M55166C00506  1  NRD_RRC_RESUME_REQUEST1
    ...    M55166C00508  1  NRD_RRC_RESUME_SUCC
    ...    M55113C03003  2  NRDU_F1AP_UECTX_STPREQ_REC_CEL
    ...    M55113C03004  2  NRDU_F1AP_UECTX_STPRESP_CELL
    ...    M55113C01001  2  NF1CC_UECTXT_STP_REQSENT
    ...    M55113C01002  2  NF1CC_UECTXT_STP_RESPRECD
    ...    M55331C00001  1  NRPAG_PAGING_SUCC_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Run Keyword If Test Failed    Stop Downlink Traffic
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

CB008225_C_B2_RAN_Paging_For_UE_RRC_INACTIVE_DL_From_AMF
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup
    ...                and there is DL AMF signalling arrival - PDU session modification. Successful scenario.
    ...                5G_RAN_USR_RRM_18718, 5G_PM_969

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Set PDU Param Internal Traffic    ue_id=3
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    gw_id=3
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Modify PDU Session    ue_id=3    pdu_id=1    qos_to_add=3    pass_regexp=Added QosFlow with QFI:2 5QI:6
    Verify Traces For Successful Transition to RRC CONNECTED By MT Access
    Start And Check Data Traffic    ues=3    pdu=1    direction=both    throughput=1mbps    qfi=1

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55124C00007  1  NRRCC_RRC_RESUME_REQUEST1
    ...    M55124C00010  1  NRRCC_RRC_RESUME_SUCC
    ...    M55125C00023  >1  NG_FLOW_TIME_SUSP
    ...    M55163C00012  >1  NG_FLOW_TIME_SUSP_PMQAP
    ...    M55331C00004  1  NRPAG_RAN_PAGING_SUCC_SENT
    ...    M55138C00052  >1  AVE_SA_RRC_INACTIVE_TIME_NOM
    ...    M55138C00053  1  AVE_SA_RRC_INACTIVE_TIME_DEN
    ...    M55125C00022  1  NG_FLOW_RESUME_RRC_INACT_CONN
    ...    M55163C00011  1  NG_FLOW_RES_RRC_INCT_CON_PMQAP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    Verify Any Counters In File
    ...    M55117C00004  1  NF1CD_RAN_PAGING_SUCC_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB008225_C_B6_NGAP_UEContextRelease_For_UE_RRC_INACTIVE
    [Documentation]    This user scenario describes reception of NGAP:UeContextRelease for the UEs in RRC_INACTIVE state
    ...                5G_RAN_USR_RRM_18727

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=4
    Set PDU Param Internal Traffic    ue_id=4
    Attach UE    ue_id=4
    Establish PDU Session    ue_id=4    gw_id=4
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Deregister UE    ue_id=4    by=amf    ue_deregister_type=normal
    Verify Traces For UE Release

CB008225_D_B1_Transition_Of_UE_In_RRC_INACTIVE_To_RRC_CONNECTED_Triggered_By_UL_NAS_PDU_2_Or_More_PDUs
    [Documentation]    This test case checking the gNB behaviour for UE in RRC_INACTIVE state that is successfully
    ...                transitioned to RRC_CONNECTED state. Successful Resume procedure.
    ...                5G_RAN_USR_RRM_18085, 5G_PM_982

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=5
    Set Parameters For UE RRC Resume Request    ue_id=5    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Set PDU Param Internal Traffic    ue_id=5
    Set PDU Param Internal Traffic    ue_id=5    pdu_id=2
    Set PDU Param Internal Traffic    ue_id=5    pdu_id=3
    Attach UE    ue_id=5
    Establish PDU Session    ue_id=5    gw_id=5    pdu_id=1
    Establish PDU Session    ue_id=5    gw_id=5    pdu_id=2
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Modify PDU Session    ue_id=5    pdu_id=1    qos_to_add=3,4    pass_regexp=Added QosFlow with QFI:3 fiveQI:8 TEID:.{10} SEID:.{1}
    Modify PDU Session    ue_id=5    pdu_id=2    qos_to_add=3,4    pass_regexp=Added QosFlow with QFI:3 fiveQI:8 TEID:.{10} SEID:.{1}
    Establish Pdu Session    ue_id=5    pdu_id=3    nwslice=1    gw_id=5
    Start And Check Data Traffic    ues=5    pdu=1    direction=both    throughput=1mbps    qfi=1
    Start And Check Data Traffic    ues=5    pdu=2    direction=both    throughput=1mbps    qfi=1
    Start And Check Data Traffic    ues=5    pdu=3    direction=both    throughput=2mbps    qfi=1
    Verify Traces For Successful Transition To RRC CONNECTED By MO Signaling

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55124C00007  1  NRRCC_RRC_RESUME_REQUEST1
    ...    M55124C00010  1  NRRCC_RRC_RESUME_SUCC
    ...    M55166C00506  1  NRD_RRC_RESUME_REQUEST1
    ...    M55166C00508  1  NRD_RRC_RESUME_SUCC
    ...    M55113C03003  2  NRDU_F1AP_UECTX_STPREQ_REC_CEL
    ...    M55113C03004  2  NRDU_F1AP_UECTX_STPRESP_CELL
    ...    M55113C01001  2  NF1CC_UECTXT_STP_REQSENT
    ...    M55113C01002  2  NF1CC_UECTXT_STP_RESPRECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

	Verify Any Counters In File
    ...    M55133C01004  >2  NE1US_CTXT_MOD_REQ_RECD
    ...    M55133C01005  >2  NE1US_CTXT_MOD_RSP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCUUP-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB008225_D_B2_Successful_RNA_Update_Inactive_UE_Context_Found
    [Documentation]    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE that performs RNA Update caused by
    ...                periodical t380 expiration or by update due to RANAC change in gNB . UE stays in RRC_INACTIVE state.
    ...                Successful RNA Update procedure.
    ...                5G_RAN_USR_RRM_18093, 5G_PM_970, 5G_PM_977

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=6
    Attach UE    ue_id=6
    Establish PDU Session    ue_id=6    gw_id=6
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Wait For Timer T380 To Expire
    Verify Traces For Successful RNA Update

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55124C00001  1  NRRCC_RRC_RELEASE_SENT
    ...    M55124C00011  1  NRRCC_RRC_RESUME_REQUEST1_RNAU
    ...    M55124C00012  1  NRRCC_RRC_REL_WITH_SUSP_RNAU
    ...    M55113C00502  0  NF1CC_UL_RRC_MSG_TRANSFER
    ...    M55113C01009  1  NF1CC_UECTXT_REL_CMDSENT
    ...    M55113C01010  1  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

CB008225_D_E5_Unsuccessful_UE_State_Change_From_RRC_INACTIVE_To_RRC_CONNECTED_UE_Context_Not_Found_Or_ResumeMAC_I_Is_Not_Authenticated
    [Documentation]    This test case checking the gNB behaviour for handling RRCResumeRequest1 from UE in RRC_INACTIVE state,
    ...                for which the UE Context was not found, or resumeMAC-I not verified, and this leads to fallback to RRCSetup.
    ...                5G_RAN_USR_RRM_18098, 5G_PM_973

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=7
    Set PDU Param Internal Traffic    ue_id=7
    Attach UE    ue_id=7
    Establish PDU Session    ue_id=7    gw_id=7
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Set Parameters For UE RRC Resume Request With Action    ue_id=7    gnb_id=2    cell_nr=1    msg=resume_request_1
    ...                                                     cause=mt_Access    action=invalid_short_mac_i
    Wait For Next Full PM Interval
    Start Data Traffic    ues=7    direction=dl    pdu=1    throughput=10kbps
    Verify Traces For RRC Setup After Resuming UE

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55127C03001  0  NRRCD_RRC_STPSUCC_HPA
    ...    M55127C03002  0  NRRCD_RRC_STPSUCC_MCS
    ...    M55127C03003  0  NRRCD_RRC_STPSUCC_MPS
    ...    M55127C03005  0  NRRCD_RRC_STPSUCC_PAG_PRIO
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True
    Verify Any Counters In File
    ...    M55124C00013  1  NRRCC_RRC_RESUME_FALLBACK_ATT
    ...    M55124C00014  1  NRRCC_RRC_RESUME_FALLBACK_SUCC
    ...    M55124C00007  1  NRRCC_RRC_RESUME_REQUEST1
    ...    M55113C00502  8  NF1CC_UL_RRC_MSG_TRANSFER
    ...    M55113C00501  7  NF1CC_DL_RRC_MSG_TRANSFER
    ...    M55125C00001  1  NNGCC_INIT_UE_MSG_SENT
    ...    M55124C01031  0  NRRCC_RRC_STPSUCC_TOT
    ...    M55124C04001  0  NRRCC_RRC_STPSUCC_EMERGENCY
    ...    M55124C09001  0  NRRCC_RRC_STPSUCC_HPA
    ...    M55124C09002  0  NRRCC_RRC_STPSUCC_MCS
    ...    M55124C09006  0  NRRCC_RRC_STPSUCC_PAG_PRIO
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

*** Keywords ***
Check Bearer Stats
    [Arguments]              ${ue_id}=2    ${pdu_id}=1    ${qfi_id}=1    ${dir}=dl    ${pass_regexp}=1
    Execute Egate Command    cmd=bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir}    pass_regexp=\(${pass_regexp}\.\\d M\)

Wait For Timer T380 To Expire
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1} && nr-rrc.resumeCause == 8    timeout=305

Set PDU Param Internal Traffic
    [Arguments]              ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Set Parameters For UE RRC Resume Request With Action
    [Arguments]              ${ue_id}    ${gnb_id}    ${cell_nr}    ${msg}    ${cause}    ${action}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_nr} msg=${msg} cause=${cause} action=${action}

Verify UE Stays Connected
       Verify Tcpdump Log    packet_filter=${RRC_RELEASE}    timeout=20    number_of_messages=1
