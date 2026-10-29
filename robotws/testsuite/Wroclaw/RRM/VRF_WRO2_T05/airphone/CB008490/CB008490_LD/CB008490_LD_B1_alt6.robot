*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...           NoResUsage

Documentation   :copyright: Nokia
...             :authors: Magdalena Rakiej, Dawid Rusek, Katarzyna Wisniewska
...             :contact: magdalena.rakiej@nokia.com, dawid.rusek@nokia.com, katarzyna.wisniewska@nokia.com
...             :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...             :variant: custom configs

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
${SCFC_GNB_MN}=             scfc_MN_n77A_n257M_AEQE_LD.xml
${SCFC_GNB_SN}=             scfc_SN_n77A_n257M_AWEUB_LD_alt6_alt7.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${cfg}=                     ${CURDIR}/config/cfg_n78_n257M_8CC_9UEs_LD_alt6.cfg
${ue_id}=                   1
${pdu_id}=                  1

*** Test Cases ***
CB008490-LD#B1_ALT6_SNodeAddition_Interaction_With_PUCCH_Multiplexing_In_The_SCG_Leg
    [Setup]    Start Default Logging And Mark New Test    remote_host=${REMOTE_HOST_1_IP}    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        test_name=${TEST_NAME}
    Attach UE1 And Establish PDU Session On GNB2 With 2 Qos Flow/s
    UE1 sends A4 measurement ID eq 1 for inter-gNB NR-DC PSCell ID eq 52 addition
    Send Data Traffic For UE1 With Two QFI
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST}
    Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE}
    Verify Tcpdump Log    packet_filter=${XNAP_XNU_ADDRESS_INDICATION}
	Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}    number_of_messages=5    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    number_of_messages=5    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_RESPONSE}
	Verify Tcpdump Log    packet_filter=${XNAP_SNODE_RECONFIGURATION_COMPLETE}
    Verify SNodeAdditionRequestAcknowledge Message Content
    Verify Throughput For UE1 With Cell Index Max In DL Is Eq 8
    Verify PUCCH Multiplexing in SCG - Two CSI Process, Four CSI Report Group

   [Teardown]    Run Keywords       Deregister UE    ue_id=${ue_id}
    ...          AND                Add Scout Scf Id To Test Data
    ...          AND                Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Verify Throughput For UE${ue_id:\d+} With Cell Index Max In DL Is Eq ${cell_index:\d+}
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=${ue_id}    cell_group=SCG    cell_index_min=1    cell_index_max=${cell_index}

Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=170
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=67
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=107
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=ul    mbps=67

Send Data Traffic In Direction
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${dir}=dl    ${mbps}=160    ${wait}=30s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=1 dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=2 dir=${dir} mbps=${mbps}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=3 dir=${dir} mbps=${mbps}
    Sleep    ${wait}

Verify That Traffic Is Scheduled On All SCells In Group
    [Arguments]    ${ue_id}=1    ${cell_index_min}=0    ${cell_index_max}=3    ${cell_group}=MCG    ${type}=pdsch
    ${num_of_cells_on_MN_and_SN}=    Evaluate        int(${cell_index_max}) + int(1)
    ${num_of_cells_if_only_SN}=      Set variable    ${cell_index_max}
    ${num_of_cells}=                 Set variable if
    ...     '${cell_index_min}' == '0'    ${num_of_cells_on_MN_and_SN}    ${num_of_cells_if_only_SN}
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} cell_group=${cell_group} type=${type} scell=${cell_index_min}-${cell_index_max}
        ...          pass_regexp=(CellIndex-[${cell_index_min}-${cell_index_max}][\\s][\\s][1-9].*\\n){${num_of_cells}}

Verify PUCCH Multiplexing in SCG - Two CSI Process, Four CSI Report Group
    [Documentation]    KW verifies PUCCH Multiplexing in SCG - Two CSI Process, Four CSI Report Groups

    sskpy.verify_pucch_mux_two_process_four_report_groups  pcap_file=${OUTPUT_DIR}/${TEST_NAME}/tshark/gnb_F1_E1_RRC.pcap
