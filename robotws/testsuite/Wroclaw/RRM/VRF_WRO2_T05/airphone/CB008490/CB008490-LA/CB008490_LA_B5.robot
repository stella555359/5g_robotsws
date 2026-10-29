*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com


Resource     ../CB008490_Keywords_And_Variables.robot
Resource     ../../keywords/traffic.robot


Suite Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_SN}
...                                remote_host=${REMOTE_HOST_1_IP}
...                                skip_relation_errors=True
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_MN}
...                AND             Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs


*** Variables ***
${SCFC_GNB_MN}=             scfc_MN_n77A_n257M_AEQE_8CC_LA_B5.xml
${SCFC_GNB_SN}=             scfc_SN_n77A_n257M_AEQE_8CC_LA_B5.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC_LA_B5.xml
${cfg}=                     ${CURDIR}/config/cfg_n77A_n257M_8CC_LA_B5_main_A1.cfg
${ue_id}=                   1
${pdu_id}=                  1
${amf_id}=                  1
@{physCellIds_UE1}=         52    53    54    55    56    57
@{sCellIndexes_UE1}=        2    3    4    5    6
@{FAULT_IDS_LIST}=          6450    4383
${pcap_file}=               ${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
${pcap_file_remote}=        ${OUTPUT_DIR}/tshark/remote_host_F1_E1_RRC.pcap

${SCELLS_ADDITTION}        nr-rrc.servCellIndex == 1 && nr-rrc.cellGroupId == 1 && nr-rrc.sCellToAddModList == 5
...                        && nr-rrc.sCellIndex == 2 && nr-rrc.sCellIndex == 3 && nr-rrc.sCellIndex == 4 &&
...                        nr-rrc.sCellIndex == 5 && nr-rrc.sCellIndex == 6
${SCELLS_FAILED}=          f1ap.SCell_FailedtoSetup_List == 2
${SCELLS_UL_CONFIGURED}=   f1ap.sCellULConfigured == 0

*** Test Cases ***
CB008490-LA_B5_MN-SN_Resource_Coordination
    [Setup]    Run Keyword     Start Default Logging And Mark New Test     remote_host=${REMOTE_HOST_1_IP}

    Attach UE1 And Establish PDU Session On GNB2 With 2 Qos Flow/s
    Wait 2s For Measurement To Configure
    UE1 sends A4 measurement ID eq 1 for inter-gNB NR-DC PSCell ID eq 52 addition
    Wait 2s For NRDC To Establish
    Verify Secondary Node Addition Flow
    Start traffic
    Wait 30s for traffic to stabilize
    Verify that only 6 out of 8 SCell candidates were successfully setup for UE1
    Verify That Traffic Is Scheduled On All SCells In Group
    ...                              ue_id=1    cell_group=SCG    cell_index_min=1    cell_index_max=6

    [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
     ...    AND    Add Scout Scf Id To Test Data
     ...    AND    Stop Default Processes And Gather Logs And Compress Logs


*** Keywords ***
Attach UE${ue_id:\d+} And Establish PDU Session On GNB${gnb_id:\d+} With 2 Qos Flow/s
    ta5g_ue_mobility.attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type For UE    ue=${ue_id}    pdu=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} and QoS Flow ID eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

UE${ue_id:\d+} sends A4 measurement ID eq ${meas_id:\d+} for inter-gNB NR-DC PSCell ID eq ${phycell_id:\d+} addition
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} nrsrp_nr=60 report_type=event_triggered event=A4
    ...    timeout=30s
    Sleep    30s

Verify that only 6 out of 8 SCell candidates were successfully setup for UE1
     Verify Tcpdump Log    packet_filter=${SCELLS_ADDITTION}        number_of_messages=1    relation_symbol= >=
     Verify Tcpdump Log    packet_filter=${SCELLS_FAILED}           number_of_messages=1    relation_symbol= >=     pcap_file_path=${pcap_file_remote}
     Verify Tcpdump Log    packet_filter=${SCELLS_UL_CONFIGURED}    number_of_messages=1    pcap_file_path=${pcap_file_remote}

Start traffic
    Start traffic for number of traffic ids  ue_id=1  pdu_id=1  qfi=1  mbps=160  size=1350  inactive_timer=30  dir=dl  starting_index=1
    ...                                      num_of_traffic_ids=4
    Start traffic for number of traffic ids  ue_id=1  pdu_id=1  qfi=2  mbps=160  size=1350  inactive_timer=30  dir=dl  starting_index=5
    ...                                      num_of_traffic_ids=3
    Start traffic for number of traffic ids  ue_id=1  pdu_id=1  qfi=1  mbps=100  size=1350  inactive_timer=30  dir=ul  starting_index=1
    ...                                      num_of_traffic_ids=4
