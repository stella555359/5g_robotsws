*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Kornel Dluniewski
...             :contact: kornel.dluzniewski@nokia.com

Resource     ../CB008490_Keywords_And_Variables.robot

Suite Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_SN}
...                                remote_host=${REMOTE_HOST_1_IP}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_MN}
...                AND             Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown     Run Keywords    Update And Put Iphy Xml         input_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Send Full Commissioning
...                                input_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml   remote_host=${REMOTE_HOST_1_IP}
...                AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Wait For Testline Icmp Echo Replies And Ssh Services
...                AND             Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${SCFC_GNB_MN}=             MN_LAB8.xml
${SCFC_GNB_SN}=             SN_LAB8.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${cfg}=                     ${CURDIR}/config/cfg_n77A_n257M_8CC_LA_B8.cfg
${ue_id}=                   1
${pdu_id}=                  1
@{bandCombinationIndex}=    1
@{requestedFeatureSets}=    1
@{physCellIds_UE1}=         52    53    54    55
@{sCellIndexes_UE1}=        2    3    4
${NosCellToAddModList}=     xnap.procedureCode == 7 && xnap.id == 72 && !nr-rrc.sCellToAddModList
${ServcellIndex} =      (_ws.col.info == "SNodeAdditionRequestAcknowledge, RRC Reconfiguration" || nr-rrc.servCellIndex == 4)
${phyCellidsetto52} =      (nr-rrc.physCellId == 52) && (_ws.col.info == "SNodeAdditionRequestAcknowledge, RRC Reconfiguration")
${forUE1phycellid} =      (nr-rrc.physCellId == 55) &&(nr-rrc.physCellId == 54) &&(nr-rrc.physCellId == 53) && (nr-rrc.physCellId == 52)
...    && (_ws.col.info == "SNodeAdditionRequestAcknowledge, RRC Reconfiguration")
${forUE1sCellidnex} =      (nr-rrc.sCellIndex == 2) &&(nr-rrc.sCellIndex == 3) &&(nr-rrc.sCellIndex == 3)
...    && (_ws.col.info == "SNodeAdditionRequestAcknowledge, RRC Reconfiguration")
${uplinkConfigPresent} =      (_ws.col.info == "SNodeAdditionRequestAcknowledge, RRC Reconfiguration") && (nr-rrc.uplinkConfig_element)
${tci_stateNotPresent} =      (nr-rrc.tci_StatesPDCCH_ToAddList ) && (_ws.col.info == "SNodeAdditionRequestAcknowledge, RRC Reconfiguration")
@{FAULT_IDS_LIST}=          6450    4383
${pcap_file}=               tshark/gnb_F1_E1_RRC.pcap


*** Test Cases ***
CB008490-LA#B8_UE_Capability_Maximum number of TRS resource sets_Impacts_On_FR2_SCell_Addition
    [Setup]    Run Keywords     Start Default Logging And Mark New Test

    Attach UE1 And Establish PDU Session On GNB2 With 2 Qos Flow/s
    Send Command To Not Send SNodeModificationConfirm Message
    UE1 sends A4 measurement ID eq 1 for inter-gNB NR-DC PSCell ID eq 52 addition
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}    number_of_messages=5    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    number_of_messages=5     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE}
    Verify Tcpdump Log    packet_filter=${XNAP_XNU_ADDRESS_INDICATION}
    Send Data Traffic_QF1_DL
    Send Data Traffic_QF1_UL
    Send Data Traffic_QF2_DL
    Send Data Traffic_QF2_UL
    Verify Tcpdump Log    packet_filter=${ServcellIndex}
    Verify Tcpdump Log    packet_filter=${phyCellidsetto52}
    Verify Tcpdump Log    packet_filter=${forUE1phycellid}
    Verify Tcpdump Log    packet_filter=${forUE1sCellidnex}
    Verify Tcpdump Log    packet_filter=${uplinkConfigPresent}
    Verify Tcpdump Log    packet_filter=${tci_stateNotPresent}          number_of_messages=0
    Verify DL thoughput For UE1 On SCells



    [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
#     ...    AND    Add scout external execution id to the reporting portal
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}

*** Keywords ***
Attach UE${ue_id:\d+} And Establish PDU Session On GNB${gnb_id:\d+} With 2 Qos Flow/s
    ta5g_ue_mobility.attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type For UE    ue_id=${ue_id}    pdu_id=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} and QoS Flow ID eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

UE${ue_id:\d+} sends A4 measurement ID eq ${meas_id:\d+} for inter-gNB NR-DC PSCell ID eq ${phycell_id:\d+} addition
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} nrsrp_nr=60 report_type=event_triggered event=A4
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone

Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=170
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=67
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=107
    Send Data Traffic In Direction      uefist_UE_id=${ue_id}    qfi=2    dir=ul    mbps=67

Send Data Traffic For UE${ue_id:\d+} With Only One QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=140
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=50

Send Data Traffic_QF1_DL
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=1    dir=dl    mbps=170
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=1    dir=dl    mbps=170
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=2    dir=dl    mbps=170
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=3    dir=dl    mbps=170

Send Data Traffic_QF1_UL
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=1    dir=ul    mbps=67
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=1    dir=ul    mbps=67
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=2    dir=ul    mbps=67
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=1    trf_id=3    dir=ul    mbps=67

Send Data Traffic_QF2_DL
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=1    dir=dl    mbps=170
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=1    dir=dl    mbps=170
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=2    dir=dl    mbps=170
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=3    dir=dl    mbps=170

Send Data Traffic_QF2_UL
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=1    dir=ul    mbps=67
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=1    dir=ul    mbps=67
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=2    dir=ul    mbps=67
    Execute Egate Command    cmd=trf_data_start ue=${ue_id}    qfi=2    trf_id=3    dir=ul    mbps=67

Verify DL thoughput For UE1 On SCells
    Wait Until Keyword Succeeds    2x    5sec    get throughput for ue    ue_id=1
    ...    direction=ul    selection_type=current    scells=all
