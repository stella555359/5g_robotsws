*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     feature_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.logging
Library      ta5g_pm_counters
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/f1ap.py

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${5GC001167_A_b_CONFIG_DIRECTION_1}=    ${CURDIR}/config/5GC001167-A/5GC001167_A_b_Successfull_2CC_CA_PCell_2L_MIMO_and_SCell_4L_MIMO/PCell_5MHz
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=                 f1ap.SCell_ToBeSetupMod_List == 1
${F1AP_SCELL_TO_ADD_MOD_LIST}=                      nr-rrc.sCellToAddModList == 1 && nr-rrc.physCellId == 51
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=        ngap.pDUSessionResourceModifyResponseTransfer && ngap.qosFlowIdentifier == 1
${F1AP_SCELL_MAXMIMOLAYER_CONFIGURATION}=           nr-rrc.sCellToAddModList && nr-rrc.physCellId == 51 && nr-rrc.maxMIMO_Layers == 4
    ...                                             && !nr-rrc.maxMIMO_Layers == 2
${5GC001167_A_b_CONFIG_DIRECTION_2}=    ${CURDIR}/config/5GC001167-A/5GC001167_A_b_SCell_addition_to_2CC_and_HO_nonCAUE
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE_UE1}=    ngap.qosFlowIdentifier == 1 && ngap.fiveQI == 5 && ngap.pDUSessionID == 1
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE_UE2}=    ngap.qosFlowIdentifier == 1 && ngap.fiveQI == 5 && ngap.pDUSessionID == 2
${NGAP_PDU_SESSION_MODIFY_RESPONSE_UE1}=            ngap.qosFlowIdentifier == 2 && ngap.fiveQI == 1 && ngap.pDUSessionID == 1
${NGAP_PDU_SESSION_MODIFY_RESPONSE_UE2}=            ngap.qosFlowIdentifier == 2 && ngap.fiveQI == 1 && ngap.pDUSessionID == 2

*** Test Cases ***
5GC001167_A_b_and_C_a_Successfull_2CC_CA_PCell_2L_MIMO_and_SCell_4L_MIMO_with_PM_counters_check
    [Setup]    Run Keywords    Custom Prepare Test Environement And Reach Onair
    ...           iphy_xml=${5GC001167_A_b_CONFIG_DIRECTION_1}/ap/iphy_A_b_and_C_a.xml
    ...           scfc=scfc_A_b_and_c.xml
    ...           egate_cfg=${5GC001167_A_b_CONFIG_DIRECTION_1}/fdd_sa_2CC_PCell_2DLMIMO_SCell_4DLMIMO.cfg
    ...           disablel1bypass=False
    ...    AND    Find Scfc and Send Delta Commissioning    scfc_filename=delta_C_a_pm_counter.json
    ...    AND    Wait For Next Full Pm Interval

    Attach UE With Scell Configuration    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Verify_Successful_2CC_On_NGAP_And_F1AP_Messages
    Verify_MaxMIMO_Layer_Configuration
    Wait For Next Full Pm Interval
    Verify PM Counters After SCell Addition
    Detach Ue And Verify Detach Procedure
    Wait For Next Full Pm Interval
    Verify PM Counters After Release UE

5GC001167_A_b_SCell_addition_to_2CC_and_HO_nonCAUE
    [Setup]    Custom Prepare Test Environement And Reach Onair
    ...            iphy_xml=${5GC001167_A_b_CONFIG_DIRECTION_2}/ap/iphy_A_b_and_C_a.xml
    ...            scfc=scfc_A_b.xml
    ...            egate_cfg=${5GC001167_A_b_CONFIG_DIRECTION_2}/fdd_sa_2CC_n5n66_2UE_CA_nonCA.cfg
    ...            disablel1bypass=False

    Attach_UE_With_PDU_Session_Setup          ue_id=1    pdu_id=1        gw_id=1
    Attach_UE_With_PDU_Session_Setup          ue_id=2    pdu_id=2        gw_id=2
    Modify_PDU_Session_By_Adding_QoS_Flow     ue_id=1    qosflows=2
    Modify_PDU_Session_By_Adding_QoS_Flow     ue_id=2    qosflows=2
    Send_Data_Traffic_For_Ue                  ue_id=1    qfi_id=1        mbps_dl=1       mbps_ul=1
    Display_Qfi_Statistic_In_Egate_Console    ue_id=1    qfi_id=1
    Perform_UE_HO_With_Stabilization_Time     ue_id=2    a2_meas_id=1    a3_meas_id=3    phycell_id=50    target_cell=1
    Perform_UE_HO_With_Stabilization_Time     ue_id=2    a2_meas_id=4    a3_meas_id=6    phycell_id=51    target_cell=2
    Stop_Data_Traffic                         ue_id=1    dir=bi          qfi_id=1
    Verify_Successful_2CC_SCell_Addition
    Verify_Successful_PDU_Session_Setup
    Verify_Successful_PDU_Session_Modification

*** Keywords ***
Verify_Successful_2CC_On_NGAP_And_F1AP_Messages
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}        continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}             number_of_messages=3   continue_on_failure=False

Verify_MaxMIMO_Layer_Configuration
    Verify Tcpdump Log    packet_filter=${F1AP_SCELL_MAXMIMOLAYER_CONFIGURATION}    continue_on_failure=False

Attach_UE_With_PDU_Session_Setup
    [Arguments]     ${ue_id}    ${pdu_id}    ${gw_id}
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue                           ue_id=${ue_id}
    Establish Pdu Session               ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Modify_PDU_Session_By_Adding_QoS_Flow
    [Arguments]     ${ue_id}    ${qosflows}
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qosflows} by=amf

Send_Data_Traffic_For_Ue
    [Arguments]     ${ue_id}    ${qfi_id}    ${mbps_dl}    ${mbps_ul}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi_id} mbps=${mbps_dl} dir=dl seconds=1000
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi_id} mbps=${mbps_ul} dir=ul seconds=1000

Display_Qfi_Statistic_In_Egate_Console
    [Arguments]    ${ue_id}    ${qfi_id}
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${ue_id} qfi=${qfi_id} dir=bi
    Sleep                    2s
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${ue_id} qfi=${qfi_id} dir=bi

Verify_Successful_2CC_SCell_Addition
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}    number_of_messages=4

Verify_Successful_PDU_Session_Setup
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE_UE1}
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE_UE2}

Verify_Successful_PDU_Session_Modification
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_MODIFY_RESPONSE_UE1}
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_MODIFY_RESPONSE_UE2}

Perform_UE_HO_With_Stabilization_Time
    [Arguments]     ${ue_id}    ${a2_meas_id}    ${a3_meas_id}    ${phycell_id}    ${target_cell}
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${a2_meas_id} srsrp_nr=40 event=A2
    Sleep    5s
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${a3_meas_id} phycell_id=${phycell_id} srsrp_nr=40 event=A3
    Sleep    5s
    Execute Egate Command
    ...    cmd=ue_disp id=${ue_id}
    ...    pass_regexp=cell*.*${target_cell}

Stop_Data_Traffic
    [Arguments]    ${ue_id}    ${dir}    ${qfi_id}
    Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} dir=${dir} pdu=${ue_id} qfi=${qfi_id}
    ...    pass_regexp=(Stopped Downlink)*(Stopping Uplink)

Verify PM Counters After SCell Addition
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55138C01501    +1    GNB_SCELL_1_ADMI_REQ_SA
        ...    M55138C01502    +1    GNB_SCELL_1_ADMI_SUCC_SA
        ...    M55118C05505    +1    RRC_RECONF_ADD1DLSCELL_ATT_SA
        ...    M55118C05506    +1    RRC_RECONF_ADD1DLSCELL_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

Verify PM Counters After Release UE
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55138C01501    0    GNB_SCELL_1_ADMI_REQ_SA
        ...    M55138C01502    0    GNB_SCELL_1_ADMI_SUCC_SA
        ...    M55118C05505    0    RRC_RECONF_ADD1DLSCELL_ATT_SA
        ...    M55118C05506    0    RRC_RECONF_ADD1DLSCELL_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
