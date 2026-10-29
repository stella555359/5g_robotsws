*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36    CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamil Wos, Julia Szymczak
...              :contact: kamil.wos@nokia.com, julia.szymczak@nokia.com

Library      ta5g_enb
Library      ta5g_delta
Resource     ../../resources/5G_SW_WRO_Keywords.robot

Suite Setup     Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...         AND              Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...         AND              Find Scfc And Send Delta Commissioning    scfc_filename=delta_638_V.json
    ...         AND              Reach OnAir    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging  output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Wait For NGlink Reestablishment
    ...          AND             Deregister Ue Without Confirmation    ue_id=1
    ...          AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords   Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_638_V.json
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${CONNECTIVITY_PROBLEM_ALARM}  7107
${BROKEN_SCTP_FAULT}  7304
${SCTP_ABORT}    sctp.abort_t_bit


*** Test Cases ***
5GC000638_V_2_Failure_Of_The_Already_Established_SCTP_Association_On_NG_Interface
    [Documentation]   Checks whether SCTP reestablishment in NG interface is done properly.
    ...               UE shall estabish PDU session and after Ng link failure UE should be released
    ...               and Ng link should be inactive.
    ...               Covers: 5GC000638_V_1_SCTP_Failure_On_NG_Interface_EFaultId_NgSctpEndpointBrokenAl

    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Wait For NGlink Failure
    Check Admin Object Parameter Value    moc=SERVEDAMF_R    parameter_name=ngLinkStatus    value=Inactive
    Verify Tcpdump Log       packet_filter=${F1AP_RESET}
    Verify Tcpdump Log       packet_filter=${E1AP_RESET}

*** Keywords ***
Restore Sctp On Ng Interface
    Execute Enb Command    cmd=ifconfig br0 up

Wait For NGlink Reestablishment
       Perform Action And Wait For Given Tshark Message Number
        ...    packet_filter=${SCTP_INIT_CREDIT}
        ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
        ...    action=Restore Sctp On Ng Interface
        ...    waiting_timeout=300

Wait For NGlink Failure
        Perform Action And Wait For Given Tshark Message Number
        ...    packet_filter=${SCTP_ABORT}
        ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
        ...    action=Invoke Sctp Failure On Ng Interface   by=amf:1    to=gnb:2
        ...    waiting_timeout=300
