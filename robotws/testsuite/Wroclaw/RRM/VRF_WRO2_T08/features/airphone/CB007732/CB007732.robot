*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CRT    SBTS23R2    PY310
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Michal Durajczyk, Ilona Kondel, Piotr Pondel, Anna Roskosz, Anna Szymandera-Bialek
...              :contact: michal.durajczyk@nokia.com, ilona.kondel@nokia.com, piotr.pondel@nokia.com, anna.roskosz@nokia.com,
...              anna.szymandera-bialek@nokia.com

Resource    CB007732_Keywords_And_Variables.robot
Library     CB007732.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Update Number Of Sa Ue In Lua   lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Add Preferences To Wireshark Config
...            AND             Start Xn And Ng Interfaces
...            AND             Start Server Interface
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Clear Changes In Number Of Sa Ue In Lua
...                               lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB007732_A_B1201_Failed_Activation_Of_The_Subscribe_Trace_Content_When_No_Valid_IP_Address_And_No_Default_TCE_Defined
    [Documentation]     Test purpose: check correct behavior when Subscriber Trace Recording Session reporting
    ...                 is not started when there is no valid IP address (neither default nor UE)
    ...                 Test case checks if: Trace Recording Session of UE call for Subscriber Trace content
    ...                 is not started and no messages are sent to TCE
    ...                 Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4211
    ...
    ...                 author: Ilona Kondel
    ...                 contact: ilona.kondel@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_non_default.json
    ...        AND             Start Tcp Pcap

    Trigger ICS With Trace Start    ue_id=1    tce_ip=10.0.1.1
    Attach Ue    ue_id=1
    Create Tce And Establish Pdu Session With Traffic     ue_id=1    pdu_id=1    gw_id=1
    Trigger ICS With Trace Start    ue_id=2    tce_ip=0.0.0.0
    Attach Ue    ue_id=2
    Establish Pdu Session With Traffic    ue_id=2    pdu_id=2    gw_id=2

    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION} && ${UE1_NGAP_ID}
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION} && ${UE2_NGAP_ID}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_1_ICS_RESP}
    Verify Tcp Messages    packet_filter=${UE_2_ICS_RESP}   number_of_messages=0

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=1
    ...           AND             Stop Subscriber Trace    ue_id=2
    ...           AND             Stop Tce
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_non_default.json
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0110_Release_Of_The_UE_With_Activated_Trace_Recording_Session
    [Documentation]    Test purpose: check correct behavior of the Trace Recording Session for selected UE in case of UE released
    ...                Test case checks if:
    ...                - Trace Recording Session (TRS) for selected UE is stopped in gNB,
    ...                - no further messages are sent to the TCE with Subscriber Trace content
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4168; 5G_TC_213; 5G_TC_214;
    ...                5G_TC_220; 5G_TC_221; 5G_TC_222; 5G_TC_243; 5G_TC_142; OM_GEN_SFS_TRACEMGMNT.4168; 5G_TC_1425
    ...
    ...                author: Anna Roskosz
    ...                contact: anna.roskosz@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Attach Ue    ue_id=3
    Establish Pdu Session With Traffic    ue_id=3    pdu_id=3    gw_id=3
    Start Subscriber Trace   ue_id=3
    Deregister Ue    ue_id=3
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RELEASE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RELEASE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=3
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=3
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0901_Start_Trace_Recording_Session_With_Default_DefaultNrTceIdentifier
    [Documentation]    Test purpose: check correct behavior of the Trace Recording Session with default TCE applied for UE
    ...                Test case checks if:
    ...                gNB establishes connection to default TCE configured in MNL/TCEADM/TCE
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4207; CB_FIM_2758
    ...
    ...                author: Anna Roskosz
    ...                contact: anna.roskosz@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_false.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Trigger ICS With Trace Start    ue_id=4
    Attach Ue    ue_id=4
    Establish Pdu Session With Traffic    ue_id=4    pdu_id=4    gw_id=4
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=4
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=4
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_false.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B1401_Attempted_Activation_Of_The_Subscriber_Trace_Content_For_Already_Active_Trace_Recording_Session_The_Same_Session_For_The_Same_UE
    [Documentation]    Test purpose: correct behavior when operator start new Trace Recording Session for the same UE which has already active TRS
    ...                Test case checks if:
    ...                - Trace Recording Session (TRS) for selected UE started on gNB
    ...                - After second activation of subscriber trace the new Trace Recording Session is not activated
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4219
    ...
    ...                author: Anna Szymandera-Bialek
    ...                contact: anna.szymandera-bialek@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Trigger ICS With Trace Start    ue_id=5    tce_ip=10.0.1.1
    Attach Ue    ue_id=5
    Establish Pdu Session With Traffic    ue_id=5    pdu_id=5    gw_id=5
    Start Subscriber Trace    ue_id=5
    Deregister Ue    ue_id=5
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=5
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0102_Handling_Of_TraceActivation_In_Case_Of_Active_Ue_When_Feature_Flag_Is_Disabled
    [Documentation]    Test purpose: check of correct behavior of the Subscriber Trace handling of TraceActivation
    ...                via NGAP: TRACE START message when feature flag is disabled
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4168
    ...
    ...                author: Piotr Pondel
    ...                contact: piotr.pondel@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD
    ...        AND             Perform Parameter Commissioning    parameter=actSubscriberTraceReport    value=false

    Wait Until Keyword Succeeds    2x  100ms   Attach Ue    ue_id=6
    Establish Pdu Session With Traffic    ue_id=6    pdu_id=6    gw_id=6    direction=dl    throughput='168mbps'
    Start Subscriber Trace    ue_id=6
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Deregister Ue    ue_id=6
    Verify Tcp Messages    packet_filter=${NSETAPX_SBA}    number_of_messages=0

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=6
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0125_Activation_Of_Subscriber_Trace_Content_During_Initial_Context_Setup_NgHO_XnHO_When_Cell_Trace_Is_Active
    [Documentation]    Test purpose: check correct behavior of the Subscriber Tracing works together with cell trace for new UEs
    ...                Activation of subscriber trace during Initial Context Setup
    ...                Test case checks if:
    ...                - gNB reports SBA Trace Recording Session of SA UE call containing all selected to be traced messages to default TCE
    ...                - gNB reports MBA Trace Recording Session of the same SA UE call containing all messages to TCE
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4168
    ...
    ...                author: Anna Roskosz
    ...                contact: anna.roskosz@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_subscriber_trace_with_cell_trace.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Trigger ICS With Trace Start    ue_id=7
    Attach Ue    ue_id=7
    Establish Pdu Session With Traffic    ue_id=7    pdu_id=7    gw_id=7
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_SETUP} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${DOWNLINK_INFORMATION_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_DOWNLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${RRC_SETUP} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${RRC_SETUP_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${DOWNLINK_INFORMATION_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_DOWNLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=7
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=7
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_subscriber_trace_with_cell_trace.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0126_Activation_Of_Subscriber_Trace_Content_NGAP_TRACE_START_When_Cell_Trace_Is_Active
    [Documentation]    Test purpose: check correct behavior of the Subscriber Tracing works together with cell trace for new UEs
    ...                TraceActivation via NGAP: TRACE START
    ...                Test case checks if:
    ...                - gNB reports SBA Trace Recording Session of SA UE call containing all selected to be traced messages to default TCE
    ...                - gNB reports MBA Trace Recording Session of the same SA UE call containing all messages to TCE
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4289; CB_FIM_2757, 5G_TC_1425
    ...
    ...                author: Anna Roskosz
    ...                contact: anna.roskosz@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_subscriber_trace_with_cell_trace.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Attach Ue    ue_id=8
    Establish Pdu Session With Traffic    ue_id=8    pdu_id=8    gw_id=8
    Start Subscriber Trace    ue_id=8
    Deregister Ue Without Confirmation   ue_id=8
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_SETUP} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${DOWNLINK_INFORMATION_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_DOWNLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${RRC_SETUP} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${RRC_SETUP_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${DOWNLINK_INFORMATION_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_DOWNLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_RELEASE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RELEASE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=8
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_subscriber_trace_with_cell_trace.json
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0501_Intra_GNB_Intra_DU_HO_Of_The_UE_With_Activated_Trace_Recording_Session
    [Documentation]    Test purpose: correct behavior of the Trace Recording Session when Intra-gNB INTRA-DU HO happened
    ...                Test case checks if:
    ...                A Subscriber Trace Recording Session for selected UE call is continued after
    ...                Intra-gNB INTRA-DU HO
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4220;5G_TC_1425; 5G_TC_142
    ...
    ...                author: Ilona Kondel
    ...                contact: ilona.kondel@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_0501.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Wait Until Keyword Succeeds    2x  100ms    Attach Ue    ue_id=9
    Establish Pdu Session With Traffic    ue_id=9    pdu_id=9    gw_id=9
    Start Subscriber Trace    ue_id=9
    Send Custom UE Measurement NR    event=A3  id=9  meas_id=1  phycell_id=51  nrsrp_nr=40  srsrp_nr=30
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...                              timeout=7
    Deregister Ue Without Confirmation    ue_id=9
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${NRRRC_SRB_TOADDMODLIST}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_MEASUREMENT_REPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=9
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_0501.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0902_Start_Trace_Recording_Session_With_UE_IP_Address
    [Documentation]    Test purpose: check correct behavior of the Trace Recording Session with UE IP adresses
    ...                Test case checks if:
    ...                gNB establishes connection to TCE using NRSTRACECU/nrTcePortNumber and UE IP adress
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4207;CB_FIM_2758
    ...
    ...                author: Anna Roskosz
    ...                contact: anna.roskosz@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_non_default.json
    ...        AND             Start Tcp Pcap

    Trigger ICS With Trace Start    ue_id=10    tce_ip=10.0.1.1
    Attach Ue    ue_id=10
    Create Tce And Establish Pdu Session With Traffic     ue_id=10    pdu_id=10    gw_id=10
    Deregister Ue    ue_id=10
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=10
    ...           AND             Stop Tce
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_non_default.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_B_B0201_Deactivation_Of_The_Subscriber_Trace_Content_Via_Feature_Flag
    [Documentation]    Test purpose: Check correct behavior of the terminate Trace Recording Session
    ...                for selected UE when feature flag is disabled
    ...                Test case checks if:
    ...                - Trace Recording Session for selected UE is terminated.
    ...                - Any new SBA Trace Record Session is not reported for any UE call in this CU cell.
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4184
    ...
    ...                author: Michal Durajczyk
    ...                contact: michal.durajczyk@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...        AND             Setup PCMD

    ${tshark_tcp_before_flag_set_to_disabled}=     Start Tshark For Nsetapx
    Attach Ue    ue_id=11
    Establish Pdu Session With Traffic    ue_id=11    pdu_id=11    gw_id=11
    Start Subscriber Trace    ue_id=11
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Stop Capturing     alias=${tshark_tcp_before_flag_set_to_disabled}

    ${tshark_tcp_after_flag_set_to_disabled}=     Start Tshark For Nsetapx
    Perform Parameter Commissioning    parameter=actSubscriberTraceReport    value=false
    Deregister Ue    ue_id=11
    Sleep    5    reason=Waiting for logs to be collected
    Stop Capturing     alias=${tshark_tcp_after_flag_set_to_disabled}

    ${tshark_tcp_recheck_logs_after_test}=     Start Tshark For Nsetapx
    Sleep    5    reason=Waiting for logs to be collected and to recheck lack of IsAlive message
    Stop Capturing     alias=${tshark_tcp_recheck_logs_after_test}

    Verify Tshark For Given Number Of Messages
    ...     alias=${tshark_tcp_after_flag_set_to_disabled}
    ...     packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}
    ...     number_of_messages=1

    Verify Tshark For Given Number Of Messages
    ...     alias=${tshark_tcp_before_flag_set_to_disabled}
    ...     packet_filter=${NSETAPX_SBA}
    ...     number_of_messages=1

    Verify Tshark For Given Number Of Messages
    ...     alias=${tshark_tcp_recheck_logs_after_test}
    ...     packet_filter=${NSETAPX_IS_ALIVE}
    ...     number_of_messages=0

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=11
    ...           AND             Teardown PCMD
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
