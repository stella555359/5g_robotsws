*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com
...             :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...             :variant: custom configs

Resource     CB009103_Keywords_And_Variables.robot



Suite Setup        Run Keywords
...                                Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_SN}    remote_host=${REMOTE_HOST_1_IP}
...                                skip_relation_errors=True
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_MN}
...                                skip_relation_errors=True
...                AND             Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}

Suite Teardown   Run Keyword       Stop Default Processes And Gather Logs And Compress Logs



*** Variables ***
${SCFC_MN}=                        Prime_CB009103_H_IWK13.xml
${SCFC_SN}=                        External_CB009103_H_IWK13.xml
${cfg}=                            ${CURDIR}/config/egate_config_CB009103_H_IWK13.cfg
${iphy}=                           ${CURDIR}/config/iphy_CB009103_H_IWK13.xml
${Verify_ScellAddition_for_UE1} =      nr-rrc.physCellId == 50 && nr-rrc.physCellId == 53 && nr-rrc.physCellId == 57
${Verify_bufferMonitoring} =      itf_l2_ps_user_BufferMonitoringInd_t.bufferMonitoring == 0
${Verify_ScellAddition_for_UE2} =    nr-rrc.physCellId == 50 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 56
${DELTA_MN_UE1} =                  ${CURDIR}/config/default/deltas/prepare_MN_UE1.json
${DELTA_SN_UE1} =                  ${CURDIR}/config/default/deltas/prepare_SN_UE1.json
${DELTA_MN_UE2} =                  ${CURDIR}/config/default/deltas/prepare_MN_UE2.json
${DELTA_SN_UE2} =                  ${CURDIR}/config/default/deltas/prepare_SN_UE2.json

*** Test Cases ***
CB009103_H_IWK13_Interworking_With_Multiple_Dedicated_BWP
    [Documentation]
    ...    PCell = pci 50
    ...    internal sCells = pci 52, 56
    ...    external sCells = pci 53, 57
    ...    The test case checks interworking with multiple dedicated BWPs.
    ...    PCell and all retained SCells BWP can't be changed during step-wise Scell addition.
    ...    New SCell and retained SCell are in different gNBs.

    [Setup]    Run Keywords     Start Default Logging And Mark New Test

    Lock Cells UE1
    Setup X2 Links
    Attach Ue    ue_id=1
    Establish PDU Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Start Traffic To Trigger SCells Addition    ue_id=1
    Sleep    10s    reason=Wait for traffic to stabilize
    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=3 phycell_id=50 srsrp_nr=40 event=A1
    Sleep    4s
    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=5 phycell_id=50 srsrp_nr=45 event=A1
    Verify Messages 1
    Unlock Cells UE2
    Lock Cells UE2
    Setup X2 Links
    Attach Ue    ue_id=2
    Establish PDU Session With Traffic    ue_id=2    pdu_id=1    gw_id=1
    Start Traffic To Trigger SCells Addition    ue_id=2
    Sleep    20s    reason=Wait for traffic to stabilize
    Execute egate command  cmd=ue_measurement_send_nr id=2 meas_id=3 phycell_id=50 srsrp_nr=40 event=A1
    Verify Messages 2

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
        ...       AND             Deregister Ue Without Confirmation   ue_id=2
        ...       AND             Add Scout Scf Id To Test Data
        ...       AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Keywords ***
Setup X2 Links
    Execute egate command  cmd=enb_x2_link_up enb=1 target=2
    Sleep    4s
    Execute egate command  cmd=enb_x2_link_up enb=1 target=3
    Sleep    10s

Prepare Cells for UE2

    Execute egate command  cmd=enb_x2_link_up enb=1 target=2
    Sleep    3s
    Execute egate command  cmd=enb_x2_link_up enb=1 target=3
    Sleep    10s


Verify Messages 1
    Verify Tcpdump Log    packet_filter=${Verify_bufferMonitoring}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=2    timeout=60

Verify Messages 2
    Verify Tcpdump Log    packet_filter=${Verify_ScellAddition_for_UE1}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1    timeout=60
    Verify Tcpdump Log    packet_filter=${Verify_ScellAddition_for_UE2}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1    timeout=60
    Verify Tcpdump Log    packet_filter=${Verify_bufferMonitoring}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=4    timeout=60


Lock Cells UE1
    Lock Single Cell    cell_id=2
    Lock Single Cell    cell_id=3
    Lock Single Cell    cell_id=5    remote_host=${REMOTE_HOST_1_IP}
    Lock Single Cell    cell_id=6    remote_host=${REMOTE_HOST_1_IP}
    Lock Single Cell    cell_id=7    remote_host=${REMOTE_HOST_1_IP}

Lock Cells UE2
    Lock Single Cell    cell_id=4
    Lock Single Cell    cell_id=8    remote_host=${REMOTE_HOST_1_IP}

Unlock Cells UE2
    Unlock Single Cell    cell_id=7    remote_host=${REMOTE_HOST_1_IP}
    Unlock Single Cell    cell_id=3
