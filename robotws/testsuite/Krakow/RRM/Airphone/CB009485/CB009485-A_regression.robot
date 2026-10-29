*** Settings ***
Documentation
...   Test suite for feature CB009485: PCMD 5G SA NSA - UE DU Bearer and RRC status reporting
...   author: Paulina Karpf Matoga
...   maintainer: Paulina Karpf Matoga

Resource     ./resources/common.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup    Run keywords
...    Testline Setup    config=${SUITE_CONFIG}
...    AND    Add Simulated GNB to WTS Config    wts_in=${WTS_DRB}    wts_delta=${WTS_DELTA_A3_Xn}    wts_out=${WTS_final}
...    AND    Start WTS and Reach Onair    wts_cfg=${WTS_final}    skip_confirmation=yes
...    AND    Wait for All Cells to be Enabled
Suite Teardown    Testline Teardown
Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Run Keywords
...               Test Case Teardown
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
@{DCAP_GNB}              condor5gSyslog
@{DCAP_BTS}              ipCapture
&{DCAP_OPTIONS}          gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}        dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes

&{SUITE_CONFIG}          delta=${DELTA_FILES}    ip_addr=${IP_ADDR_SIM_GNB}
@{IP_ADDR_SIM_GNB}       eth3:10.0.1.3/24    eth3:10.0.1.4/24
@{DELTA_FILES}           ${DELTA_PCMD_DCAP}    ${DELTA_HO}
${DELTA_PCMD_DCAP}       ${CURDIR}/resources/configs/Delta_PCMD_DCAP_A.json
${DELTA_HO}              ${CURDIR}/resources/configs/Delta_HO_Xn_A3_FR2.json
${WTS_DRB}               ${CURDIR}/resources/configs/basic_setup_A.cfg
${WTS_DELTA_A3_Xn}       ${CURDIR}/resources/configs/wts_sim_gnb_A3_XnHO_FR2.cfg
${WTS_final}             ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg

*** Test Cases ***
CB009485_A_04_Monitoring_Xn_based_Inter-gNB_HO_for_SA_call
    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_HO
    Prepare Ue For Inter gNB HO    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1
    PDU Session Setup    ue_id=1    pdu_id=2
    Add QoS Flow to PDU Session    ue_id=1    pdu_id=2    qosflow_id=2    expected_5qi=5
    Add QoS Flow to PDU Session    ue_id=1    pdu_id=2    qosflow_id=4    expected_5qi=7
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=xnap.HandoverRequest_element    count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.UEContextSetupRequest_element && nr-rrc.drb_ToAddModList == 4    count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.UEContextSetupResponse_element && f1ap.DRBs_Setup_List == 4    count=1
    SA UE Deregister    ue_id=1
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.DuBearerDataSetupItem_element   save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    Verify PCMD Record In Collection    ${records}    bearerRecord    no
    ...    data_r2_element.*trigger=1    setupBearers=4
    ...    setupBearers_tree.*Item 0.*DuBearerDataSetupItem_element.*drb_Id=4    setupBearers_tree.*Item 0.*fiveQi=6
    ...    setupBearers_tree.*Item 0.*pduSessionId=1
    ...    setupBearers_tree.*Item 1.*DuBearerDataSetupItem_element.*drb_Id=5    setupBearers_tree.*Item 1.*fiveQi=6
    ...    setupBearers_tree.*Item 1.*pduSessionId=2
    ...    setupBearers_tree.*Item 2.*DuBearerDataSetupItem_element.*drb_Id=6    setupBearers_tree.*Item 2.*fiveQi=5
    ...    setupBearers_tree.*Item 2.*pduSessionId=2
    ...    setupBearers_tree.*Item 3.*DuBearerDataSetupItem_element.*drb_Id=7    setupBearers_tree.*Item 3.*fiveQi=7
    ...    setupBearers_tree.*Item 3.*pduSessionId=2

CB009485_A_07_Robustness_in_new_PCMD_records
    [Setup]    Run keywords
    ...    Test Case Setup
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1   param=rrcReestabTypeSA   value=sameGNB
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-1   param=t301    value=2000ms
    ...    AND    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-2   param=t301    value=2000ms
    ...    AND    Setup DCAP Trace    gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=no
    ...    AND    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES

    Monitoring of bearerRecord for UE    id=1
    Monitoring of bearerRecord for UE    id=2
    Monitoring of bearerRecord for UE    id=3
    Monitoring of bearerRecord for UE    id=4
    Monitoring of bearerRecord for UE    id=5
    Monitoring of bearerRecord for UE    id=6
    Monitoring of bearerRecord for UE    id=7
    Monitoring of bearerRecord for UE    id=8
    Monitoring of bearerRecord for UE    id=9
    Monitoring of bearerRecord for UE    id=10

*** Keywords ***
Monitoring of bearerRecord for UE
    [Arguments]    ${id}
    Start DCAP Trace
    Start GNB tcpdump Collection    log_dir=${TEST_log_dir}/Wireshark_ue${id}/

    SA UE Register    ue_id=${id}
    PDU Session Setup    ue_id=${id}    pdu_id=1
    Add QoS Flow to PDU Session    ue_id=${id}    pdu_id=1    qosflow_id=2    expected_5qi=5
    PDU Session Setup    ue_id=${id}    pdu_id=2
    PDU Session Release    ue_id=${id}    pdu_id=2
    PDU Session Setup    ue_id=${id}    pdu_id=2
    Add QoS Flow to PDU Session    ue_id=${id}    pdu_id=2    qosflow_id=2    expected_5qi=5
    Add QoS Flow to PDU Session    ue_id=${id}    pdu_id=2    qosflow_id=4    expected_5qi=7
    PDU Session Modify    ue_id=${id}    pdu_id=2    qos_to_add=5    qos_to_del=2,4
    UE RRC Reestablish    ue_id=${id}   cell_id=2    gnb_id=2  pass_regexp=pcid:51   should_contain=Reestablishment sucessfully completed
    ${rnti_2}    Get CRNTI of UE    ue_id=${id}
    SA UE Deregister    ue_id=${id}

    Stop GNB tcpdump Collection
    ${dcap_files}    Stop and Collect DCAP Trace  log_dir=${TEST_log_dir}/DCAP_ue${id}/
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.DuBearerDataSetupItem_element || nsetapx.DuVendorExtensionRecordDataType == bearerRecord
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records_ue${id}.json

    ${record_add_1}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=1    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=4    fiveQi=6    pduSessionId=1
    ${record_add_2}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=5    fiveQi=5    pduSessionId=1
    ${record_rel_1}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=6    fiveQi=6    pduSessionId=2
    ${record_rel_2}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    releasedBearers=1    DuBearerReleaseItem_element.*drb_Id=6
    ${record_mod_1}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=7    fiveQi=6    pduSessionId=2
    ${record_mod_2}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=8    fiveQi=5    pduSessionId=2
    ${record_mod_3}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=9    fiveQi=7    pduSessionId=2
    ${record_mod_4}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=1    DuBearerDataSetupItem_element.*drb_Id=10    fiveQi=8    pduSessionId=2
    ...    releasedBearers=2
    ...    releasedBearers_tree.*Item 0.*DuBearerReleaseItem_element.*drb_Id=9    releasedBearers_tree.*Item 1.*DuBearerReleaseItem_element.*drb_Id=8
    ${record_reestab_1}      Create dictionary
    ...    record_name=bearerRecord
    ...    data_r2_element.*trigger=2    setupBearers=4
    ...    setupBearers_tree.*Item 0.*DuBearerDataSetupItem_element.*drb_Id=4    setupBearers_tree.*Item 0.*fiveQi=6
    ...    setupBearers_tree.*Item 0.*pduSessionId=1
    ...    setupBearers_tree.*Item 1.*DuBearerDataSetupItem_element.*drb_Id=5    setupBearers_tree.*Item 1.*fiveQi=5
    ...    setupBearers_tree.*Item 1.*pduSessionId=1
    ...    setupBearers_tree.*Item 2.*DuBearerDataSetupItem_element.*drb_Id=7    setupBearers_tree.*Item 2.*fiveQi=6
    ...    setupBearers_tree.*Item 2.*pduSessionId=2
    ...    setupBearers_tree.*Item 3.*DuBearerDataSetupItem_element.*drb_Id=10    setupBearers_tree.*Item 3.*fiveQi=8
    ...    setupBearers_tree.*Item 3.*pduSessionId=2

    ${bearerRecord_seq}    Create List    ${record_add_1}    ${record_add_2}    ${record_rel_1}    ${record_rel_2}
    ...    ${record_mod_1}    ${record_mod_2}    ${record_mod_3}    ${record_mod_4}    ${record_reestab_1}
    Verify PCMD Records Sequence In Collection    ${records}    ${bearerRecord_seq}
