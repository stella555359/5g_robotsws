*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    CONFIGURED    RAN_5G    CRT    SBTS00    PY39    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Ilona Kondel, Anna Roskosz
...              :maintainer: Piotr Pondel
...              :contact: piotr.pondel@nokia.com

Resource    ../../../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_admin_operations
Library     ta5g_pm_counters

Suite Setup    Run Keywords    Enable Cloud
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Reach Onair    lua_cfg=${CURDIR}/../config/egate_cloud.cfg
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${ERROR_INDICATION_NOT_INCLUDED_ID}=    ${NGAP_ERROR_INDICATION} and ngap.protocol == 0 and ngap.id == 10 and not ngap.id == 85

*** Test Cases ***
5GC002333_K_PM_Counters
    [Documentation]    This test case covers rejection of ue attach in case of different establishment causes for each ue
    ...                when parameter MaxNumOfRrcSa is set to 1 and check that each counter connected to specific
    ...                establishment cause has been incremented. Covered:
    ...                5GC000723_B_1_Check_U-Plane_Counters_RA
    ...                5GC000723_D_6_Check_SRB_1_Counters
    ...                5GC002333_K_1_Check_Incrementation_Of_Nrrc_Rrc_Stpsucc_Tot_Pm_Counter_Upon_Successful_Rrc
    ...                5GC000723_G_1_Sukcess_RRC_Idle_to_Connected_Transition
    ...                5GC000723_G_4_Test_4_Checking_receiving_of_NGAP_INITIAL_UE_MESSAGE
    ...                Requirement ID: 5G_RAN_USR_12769, 5G_RAN_USR_4523, 5G_RAN_USR_12798

    [Setup]            Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                AND             Perform Parameter Commissioning Aic    parameter=maxNumOfRrcSA    value=1
    ...                                dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...                AND             Perform Parameter Commissioning Vdu Aic    parameter=maxNumOfRrcSA    value=1
    ...                                dist_name=MRBTS-1/NRBTS-1/NRCELL-1

    Wait For Next Full Pm Interval
    Attach UE    ue_id=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE}
    Verify Tcpdump Log    packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
    Verify Tcpdump Log    packet_filter=${RRC_SETUP}
    Verify Tcpdump Log    packet_filter=${RRC_SETUP_COMPLETE}
    Attach UE With Cause    ue_id=2    cause=emergency
    Attach UE With Cause    ue_id=3    cause=highPriorityAccess
    Attach UE With Cause    ue_id=4    cause=mcs-PriorityAccess
    Attach UE With Cause    ue_id=5    cause=mo-Data
    Attach UE With Cause    ue_id=6    cause=spare1
    Attach UE With Cause    ue_id=7    cause=mo-Signalling
    Attach UE With Cause    ue_id=8    cause=mo-SMS
    Attach UE With Cause    ue_id=9    cause=mo-VideoCall
    Attach UE With Cause    ue_id=10    cause=mo-VoiceCall
    Attach UE With Cause    ue_id=11    cause=mps-PriorityAccess
    Attach UE With Cause    ue_id=12    cause=mt-Access

    Wait For Next Full Pm Interval
    ${pm_counter_file_vcu}=    Get Latest Unpacked Full Pm Counters File
    ${pm_counter_file_vdu}=    Get Latest Unpacked Full Pm Counters File    vdu=1
    Verify Any Counters In File
    ...    M55124C01024  +1  NRRCC_RRC_STPREJ_EMERGENCY
    ...    M55124C01025  +1  NRRCC_RRC_STPREJ_HIPRIO_ACCESS
    ...    M55124C01030  +1  NRRCC_RRC_STPREJ_MCS
    ...    M55124C01022  +2  NRRCC_RRC_STPREJ_MO_DATA
    ...    M55124C01021  +1  NRRCC_RRC_STPREJ_MO_SIGNALLING
    ...    M55124C01028  +1  NRRCC_RRC_STPREJ_MO_SMS
    ...    M55124C01027  +1  NRRCC_RRC_STPREJ_MO_VIDEOCALL
    ...    M55124C01026  +1  NRRCC_RRC_STPREJ_MO_VOICECALL
    ...    M55124C01029  +1  NRRCC_RRC_STPREJ_MPS
    ...    M55124C01023  +1  NRRCC_RRC_STPREJ_MT_ACCESS
    ...    M55124C01031   1  NRRCC_RRC_STPSUCC_TOT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file_vcu}
    Verify Any Counters In File
    ...    M55317C04001    +4    UL_PDCP_SDU_RX_SRB1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file_vcu}
    Verify Any Counters In File
    ...    M55311C25001  +4  UL_RLC_SDU_RX_H_SRB1
    ...    M55311C29001  +0  UL_RLC_PDU_RETX_H_SRB1
    ...    M55311C31001  >1  UL_RLC_DELAY_H_SRB1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file_vdu}
    Verify Any Counters In File
    ...    M55309C05001  +72  UL_MAC_SDU_VOL_CCCH_SRB0
    ...    M55309C10001  >0   UL_MAC_SDU_DCCH_SRB1
    ...    M55306C00001  +12  RA_ATT_CONT_A_PRMBL_SSB_00
    ...    M55306C03001  +12  RA_COMP_CONT_A_PRMBL
    ...    M55310C12001  >0   UL_RLC_PDU_RX_L_SRB1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file_vdu}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Perform Parameter Commissioning Aic    parameter=maxNumOfRrcSA    value=250    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...           AND             Perform Parameter Commissioning Vdu Aic    parameter=maxNumOfRrcSA    value=250
    ...                              dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC002333_RA_Ngap_Error_Indication_Received_Not_Included_Ran_Ue_Ngap_Id
    [Documentation]    This test case covers Ngap Error Indication received, when Ran Ue Ngap Id is not included
    ...                Requirement ID: 5G_RAN_USR_6472

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Trigger Error Indication Without RAN UE NGAP ID
    Attach Ue Without Confirmation    ue_id=13
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_TCPDUMP_ALIAS}
    ...    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Ngap Messages    packet_filter=${ERROR_INDICATION__NOT_INCLUDED_ID}

    [Teardown]    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Trigger Error Indication Without RAN UE NGAP ID
    Execute Egate Command    cmd=amf_init_ue_msg_param id=1 action=error_indication_without_ran_ueid cause=PROTOCOL_transfer_syntax_error

Attach UE With Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}
    Attach Ue Without Confirmation    ue_id=${ue_id}
    Sleep    5s    reason=Waiting for procedure end