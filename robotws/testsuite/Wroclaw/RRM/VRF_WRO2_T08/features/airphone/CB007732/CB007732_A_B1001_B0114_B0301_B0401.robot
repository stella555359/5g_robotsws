*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CRT    SBTS23R2    PY310
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Piotr Gudas, Ilona Kondel, Anna Roskosz, Anna Szymandera-Bialek
...              :contact: piotr.gudas@nokia.com, ilona.kondel@nokia.com, anna.roskosz@nokia.com, anna.szymandera-bialek@nokia.com

Resource    CB007732_Keywords_And_Variables.robot
Library     CB007732.py

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Start Server Interface
    ...        AND             Add Preferences To Wireshark Config
    ...        AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7732_on_and_xn_handover.json
    ...        AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2cc_2gNB_TDD.lua
    ...        AND             Wait For Xn Link Status Value Change    xn_link_id=10    value=available    timeout=60
    ...        AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_7732_on_and_xn_handover.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB007732_A_B1001_Activation_Of_The_Subscriber_Trace_Content_With_Default_TCE_Applied_For_All_Subscriber_TRS
    [Documentation]    Test purpose: check of correct behavior of the Trace Recording Session start
    ...                with default TCE applied for all Subscriber TRS
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4208
    ...
    ...                Acceptance criteria
    ...                Trace Recording Session of SA UE1 and UE 2 call reported to default TCE contains following messages:
    ...                    NSETAP-X StartRecordingSession
    ...                    NSETAP-X Report
    ...
    ...                author:    Piotr Gudas
    ...                contact:   piotr.gudas@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    gw_id=1    direction=dl    throughput='168mbps'

    Start Subscriber Trace    ue_id=1    tce_ip=10.0.1.2

    Send A5 Event To Trigger Ho    ue_id=1    phycell_id=52
    ...                            pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

    Add Item To UE History Information List    gnb_id=3

    Sleep    3s    reason=Give AirPhone some time to process handover and add item to ue history information list

    Send A5 Event To Trigger Ho    ue_id=1    phycell_id=50
    ...                            pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed

    Deregister Ue Without Confirmation   ue_id=1

    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${NSETAPX_REPORT} && ${NSETAPX_SBA}    relation_symbol= >=    number_of_messages=4

    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=2
    Establish Pdu Session With Traffic    ue_id=2    pdu_id=2    gw_id=2    direction=dl    throughput='168mbps'

    Start Subscriber Trace    ue_id=2    tce_ip=0.0.0.0

    Deregister Ue Without Confirmation    ue_id=2

    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}    number_of_messages=3
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}    number_of_messages=3
    Verify Tcp Messages    packet_filter=${NSETAPX_REPORT} && ${NSETAPX_SBA}    relation_symbol= >=    number_of_messages=6

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=1
    ...           AND             Stop Subscriber Trace    ue_id=2
    ...           AND             Deregister Ue Without Confirmation    ue_id=1
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0114_Intra_DU_Reestablishment_Of_The_UE_With_Activated_Trace_Recording_Session
    [Documentation]    Test purpose: check correct behavior of the Subscriber Tracing for UEs after
    ...                Re-establishment to the selected serving cell in the same DU
    ...                Test case checks if:
    ...                Trace Recording Session for selected UE call is continued.
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4168; 5G_TC_211; 5G_TC_212; 5G_TC_306; G_TC_307;
    ...                5G_TC_215; 5G_TC_216; 5G_TC_223; 5G_TC_224; 5G_TC_141; 5G_TC_150; 5G_TC_153; 5G_TC_155; 5G_TC_143
    ...
    ...                author: Ilona Kondel
    ...                contact: ilona.kondel@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Attach Ue    ue_id=3
    Establish Pdu Session With Traffic    ue_id=3    pdu_id=3    gw_id=3
    Start Subscriber Trace    ue_id=3
    Initiate Ue Rrc Reestablishment    ue_id=3    gnb=2    cell=1    cause=otherFailure    retries=1
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=3    carrier_freq=636576    index=0    nrs_result=50:56:0    phycell_id=52
    ...                                                     nrsrp_nr=50    srsrp_nr=56
    ...                                                     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...                                                     timeout=10
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${RRC_REESTABLISHMENT} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${XNAP_HANDOVER_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_MEASUREMENT_REPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${XNAP_SN_STATUS_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${XNAP_UE_CONTEXT_RELEASE} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=2

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=3
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=3
    ...           AND             Stop Tcp Pcap
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_B_B0301_Deactivation_Of_The_Subscriber_Trace_Recording_Session_Via_NG_C_Interface
    [Documentation]    Test purpose: correct behavior of of the terminate Trace Recording Session for selected UE
    ...                when deactivation is triggered
    ...                Test case checks if: after stoping subscriber trace there is no nsetapx message with handover
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4188; 5G_TC_1427
    ...
    ...                author: Anna Szymandera-Bialek
    ...                contact: anna.szymandera-bialek@nokia.com

    [Setup]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Trigger ICS With Trace Start    ue_id=4
    Attach Ue    ue_id=4
    Establish Pdu Session With Traffic    ue_id=4    pdu_id=4    gw_id=4
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Stop Subscriber Trace    ue_id=4
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=4    carrier_freq=636576    index=0    nrs_result=50:56:0    phycell_id=52
    ...                                                     nrsrp_nr=50    srsrp_nr=56
    ...                                                     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...                                                     timeout=10

    Verify Ngap Messages    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}

    Verify Tcp Messages    packet_filter=${XNAP_HANDOVER_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=0
    Verify Ngap Messages    packet_filter=${XN_HANDOVER_REQUEST_WITH_TRACE_ACTIVATION}    number_of_messages=0

    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Stop Subscriber Trace    ue_id=4
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=4
    ...           AND             Stop Tcp Pcap
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB007732_A_B0401_Activation_Of_The_Subscriber_Trace_Content_Via_Inter_gNB_Handover_XnHO_With_Active_Feature_Flag
    [Documentation]    Test purpose: correct behavior of the Subscriber Tracing, activated via XnAP:HANDOVER REQUEST
    ...                Test case checks if:
    ...                TRS for selected UE call for gNB is recording after Inter gNB Handover via Xn
    ...                Test case covers requirement: OM_GEN_SFS_TRACEMGMNT.4168; OM_GEN_SFS_TRACEMGMNT.4189; CB_FIM_2996; CB_FIM_2993
    ...
    ...                author: Anna Roskosz
    ...                contact: anna.roskosz@nokia.com

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    Trigger ICS With Trace Start    ue_id=5
    Attach Ue    ue_id=5
    Establish Pdu Session With Traffic    ue_id=5    pdu_id=5    gw_id=5
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=5    carrier_freq=636576    index=0    nrs_result=50:56:0
    ...                                                     phycell_id=52    nrsrp_nr=50    srsrp_nr=56
    ...                                                     pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ...                                                     timeout=10
    Add Item To UE History Information List    gnb_id=3
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=5    carrier_freq=636576    srsrp_nr=19    srsrq_nr=10    phycell_id=50
    ...                                                     nrsrp_nr=85    nrsrq_nr=50
    ...                                                     pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...                                                     timeout=20
    Deregister Ue    ue_id=5
    Verify Ngap Messages    packet_filter=${XN_HANDOVER_REQUEST_WITH_TRACE_ACTIVATION}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}    number_of_messages=2

    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_ENQUIRY} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${SECURITY_MODE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${UE_CAPABILITY_INFORMATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}

    Verify Tcp Messages    packet_filter=${XNAP_HANDOVER_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${XNAP_HANDOVER_REQUEST_ACK} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${RRC_MEASUREMENT_REPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${XNAP_SN_STATUS_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${XNAP_UE_CONTEXT_RELEASE} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}    number_of_messages=2
    Verify Tcp Messages    packet_filter=${NGAP_PATH_SWITCH_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_PATH_SWITCH_REQUEST_ACK} && ${NSETAPX_SBA}

    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_RELEASE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}        number_of_messages=2

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Subscriber Trace    ue_id=5
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
