*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_FDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamil Wos
...              :contact: kamil.wos@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000752_F_Variables.robot

Suite Setup     Run Keywords    Start Default Logging And Reach Onair
    ...                         output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...                         lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
5GC000752-F_1_USBasicCall-F_EC1_Unsuccessful_Initial_Context_Setup_with_PDU_Session_without_UE_Radio_Capabilities_gNBCUCP_rejection_NGAP_ICS_Req
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    without UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=1    pdu_id=1    gw_id=1
    Set Emergency Fallback Indicator    ue_id=1    value=on include_ue_capabilities=off
    Exit Idle Mode Without Confirmation    ue_id=1
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=0
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}

    [Teardown]    Run Keywords    Set Emergency Fallback Indicator    ue_id=1    value=off
    ...           AND             Deregister Ue Without Confirmation  ue_id=1
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000752-F_2_USBasicCall-F_EC2_Unsuccessful_Initial_Context_Setup_with_PDU_Session_without_UE_Radio_Capabilities_RRC_Security_Mode_Failure
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    without UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to RRC Security Mode Failure

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=2    pdu_id=2    gw_id=2
    Configure Rule For Securitymodecommand Messages    ue_id=2    rule=failure
    Exit Idle Mode Without Confirmation    ue_id=2
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=0
    Verify ICS And Ue Context Release Failure Cause

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation  ue_id=2
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000752-F_3_USBasicCall-F_EC3_Unsuccessful_Initial_Context_Setup_with_PDU_Session_without_UE_Radio_Capabilities_lack_of_RRC_Sec_Mode_Complete
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    without UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to lack of RRC: Security Mode Complete - 5G UE no response

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=3    pdu_id=3    gw_id=3
    Configure Rule For Securitymodecommand Messages    ue_id=3    rule=drop
    Exit Idle Mode Without Confirmation    ue_id=3
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=0
    Verify ICS And Ue Context Release Failure Cause

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation  ue_id=3
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000752-F_4_USBasicCall-F_EC4_Unsuccessful_Initial_Context_Setup_with_PDU_Session_without_UE_Radio_Capabilities_lack_of_RRC_Ue_Capa_Info
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    without UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to lack of RRC: UE Capability Information - 5G UE no response

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=4    pdu_id=4    gw_id=4
    Change Action Of RRC UE Capability Enquiry    ue_id=4    action=drop
    Exit Idle Mode Without Confirmation    ue_id=4
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=0
    Verify ICS And Ue Context Release Failure Cause

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation  ue_id=4
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000752-F_5_USBasicCall-F_EC11_Unsuccessful_Initial_Context_Setup_with_PDU_Session_without_UE_Radio_Capabilities_lack_of_RRC_Reconf_Complete
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    without UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to lack of RRC: RRC Reconfiguration Complete - 5G UE no response

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=5    pdu_id=5    gw_id=5
    Ignore NR RRC Connection Reconfiguration Messages    ue_id=5
    Exit Idle Mode Without Confirmation    ue_id=5
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=0
    Verify ICS And Ue Context Release Failure Cause

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation  ue_id=5
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000752-F_6_USBasicCall-F_EC12_Unsuccessful_Initial_Context_Setup_with_PDU_Session_with_UE_Radio_Capabilities_gNBCUCP_rejection_NGAP_ICS_Req
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    with UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to incorect content of NGAP: Initial Context Setup Request

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=6    pdu_id=6    gw_id=6
    Turn On Off Inclusion Of Ue Capabilities    ue_id=6    turn_on_off=on
    Set Emergency Fallback Indicator    ue_id=6    value=on
    Exit Idle Mode Without Confirmation   ue_id=6
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=1

    [Teardown]    Run Keywords    Set Emergency Fallback Indicator    ue_id=6    value=off
    ...           AND             Deregister Ue Without Confirmation  ue_id=6
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000752-F_7_USBasicCall-F_EC17_1A_Unsuccessful_Initial_Context_Setup_with_PDU_Session_with_UE_Radio_Capabilities_RRC_Security_Mode_Failure
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    with UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to RRC Security Mode Failure

    Attach UE And Establish PDU Session And Release UE Ctx    ue_id=7    pdu_id=7    gw_id=7
    Turn On Off Inclusion Of Ue Capabilities    ue_id=7    turn_on_off=on
    Configure Rule For Securitymodecommand Messages    ue_id=7    rule=failure
    Exit Idle Mode Without Confirmation    ue_id=7
    Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release    number_of_ue_radio_capability=1
    Verify ICS And Ue Context Release Failure Cause

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation  ue_id=7
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Set Emergency Fallback Indicator
    [Arguments]    ${ue_id}    ${value}
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=${ue_id} emergency_fb=${value}

Attach UE And Establish PDU Session And Release UE Ctx
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID \\d+ and AMF UE NGAP ID \\d+
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Verify Ngap Messages    packet_filter=ngap.PDUSessionResourceSetupListCxtRes == 1 && ngap.pDUSessionID == ${pdu_id}
    Release Ue Ctx    ue_id=${ue_id}

Change Action Of RRC UE Capability Enquiry
    [Arguments]    ${action}    ${ue_id}
    Execute Egate Command    cmd=ue_capability_enquiry_param id=${ue_id} if_contains=nr action=${action}

Ignore NR RRC Connection Reconfiguration Messages
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop

Verify Ngap Initial Context Setup Request And UE Radio Capability And Ue Context Release
    [Arguments]    ${number_of_ue_radio_capability}
    @{id}=    Get AMF And Ran Id    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    output_filepath=${OUTPUT_DIR}/${TEST_NAME}/id.pdml
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.UERadioCapability
    ...                     number_of_messages=${number_of_ue_radio_capability}
    Verify Ngap Messages    packet_filter=ngap.PDUSessionResourceFailedToSetupListCxtFail == 1
    Verify Tshark For Ngap Ue Context Release    ran_id=@{id}[1]    amf_id=@{id}[0]    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}

Verify ICS And Ue Context Release Failure Cause
    Verify Ngap Messages    packet_filter=${ICS_RADIO_NETWORK_FAILURE_IN_RADIO_INTERFACE_PROCEDURE}
    Verify Ngap Messages    packet_filter=${UECONTEXTRELEASE_RADIO_NETWORK_FAILURE_IN_RADIO_INTERFACE_PROCEDURE}
