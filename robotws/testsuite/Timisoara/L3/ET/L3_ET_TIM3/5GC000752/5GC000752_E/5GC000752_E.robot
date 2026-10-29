*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamil Wos
...              :contact: kamil.wos@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Suite Setup     Run Keywords    Start Default Logging And Reach Onair
    ...                         output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...                         lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Test Cases ***
5GC000752-E_3_USBasicCall-E_EC8_Unsuccessful_PDU_Session_Release_last_PDU_session_two_PDU_Sessions_lack_of_RRC_Reconfiguration_Complete
    [Documentation]   Correct handling of failing PDU session release after sucsecssful setup of 2 sessions
    ...    caused by no response from 5G UE which in turn ends with DRB PDU Session release and lack of RRC Reconfiguration Complete

    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Establish PDU Session    ue_id=1    pdu_id=2    gw_id=2
    Release PDU Session    ue_id=1    pdu_id=2    initiator=ue
    Set Ue NR RRC Reconf Param    ue_id=1    value=drop
    Release PDU Session Without Confirmation    ue_id=1    pdu_id=1    initiator=ue
    Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    Deregister Ue Without Confirmation   ue_id=1

5GC000752-E_2_USBasicCall-E_EC8_Unsuccessful_PDU_Session_Release_last_PDU_session_one_PDU_Session_lack_of_RRC_Reconfiguration_Complete
    [Documentation]   Correct handling of failing PDU session release after sucsecssful setup caused by no response from 5G UE which in turn
    ...    ends with DRB PDU Session release and lack of RRC Reconfiguration Complete

    Attach Ue    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=1    gw_id=3
    Set Ue NR RRC Reconf Param    ue_id=2    value=drop
    Release PDU Session Without Confirmation    ue_id=2    pdu_id=1    initiator=ue
    Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    Deregister Ue Without Confirmation   ue_id=2

5GC000752-E_1_USBasicCall-E_EC3_Unsuccessful_PDU_Session_Release_not_last_PDU_session_5G_UE_no_response_lack_of_RRC_Reconfiguration_Complete
    [Documentation]   Correct handling of failing PDU session release after sucsecssful setup of 2 sessions
    ...    caused by no response from 5G UE which in turn ends with DRB PDU Session release and lack of RRC Reconfiguration Complete

    Attach Ue    ue_id=3
    Establish Pdu Session    ue_id=3    pdu_id=1     gw_id=4
    Establish Pdu Session    ue_id=3    pdu_id=2     gw_id=5
    Set Ue NR RRC Reconf Param    ue_id=3   value=drop
    Release Pdu Session     ue_id=3    pdu_id=2    initiator=ue
    Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    Deregister Ue Without Confirmation    ue_id=3

*** Keywords ***
Set Ue NR RRC Reconf Param
    [Arguments]    ${ue_id}    ${value}
	Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${value}

Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    @{id}=    Get AMF And Ran Id    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    output_filepath=${OUTPUT_DIR}/${TEST_NAME}/id.pdml
    Verify Tshark For Ngap Ue Context Release    ran_id=@{id}[1]    amf_id=@{id}[0]    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
