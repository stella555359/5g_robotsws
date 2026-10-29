*** Settings ***


Documentation
...            CB010790      DU overload handling
...
...            author:        Mateusz Michalik, mateusz.michalik@nokia.com
...            maintainer:    Mateusz Michalik, mateusz.michalik@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...               Add Second ENB Cell to WTS Config    wts_delta=${DELTA_WTS_ENB}    wts_out=${WTS_CFG}
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra NSA Bearer    wts_delta=${DELTA_WTS_DRB}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Add Extra UE Caps    wts_delta=${DELTA_WTS_CAPS}    wts_in=${WTS_CFG}    wts_out=${WTS_CFG}
...    AND        Testline Setup    reach_on_air=yes    wts=${WTS_CFG}    config=${SUITE_CONFIG}    reboot_after_config=yes
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Run Keywords
...           Airphone And Gnb Bip Traces Stop 1
...    AND    Airphone And Gnb Bip Traces Stop 2
...    AND    Airphone And Gnb Bip Traces Stop 3
...    AND    Airphone And Gnb Bip Traces Stop 4
...    AND    Stop GNB tcpdump Collection
...    AND    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
...    AND    Test Case Teardown    oam_logs=yes    sosreport=yes

*** Variables ***
@{IP_ADDR_SIM_GNB}     eth3:10.0.1.3/24    eth3:10.0.1.4/24
${DELTA_CNT}           ${CURDIR}/configs/delta_pm_counters_5min.json
${DELTA_HO}            ${CURDIR}/configs/delta_HO_SA_NSA.json
${DELTA_A4}            ${CURDIR}/configs/delta_A4meas.json
${DELTA_BEAM}          ${CURDIR}/configs/delta_beam_rrc.json
@{DELTAS}              ${DELTA_CNT}    ${DELTA_HO}    ${DELTA_A4}    ${DELTA_BEAM}
&{SUITE_CONFIG}        delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
${DELTA_WTS_A3_Xn}     ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${DELTA_WTS_ENB}       ${CURDIR}/configs/wts_sim_enb_cell_2.cfg
${DELTA_WTS_DRB}       ${CURDIR}/configs/wts_nsa_bearer.cfg
${DELTA_WTS_CAPS}      ${CURDIR}/configs/wts_ue_caps.cfg
${WTS_CFG}             ${OUTPUT DIR}/Logs/wts_modified.cfg

@{DCAP_GNB}             condor5gSyslog    cp_5g
@{DCAP_BTS}             scf
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       tcpdump_gnb=yes    dcap=${DCAP_OPTIONS}

${DELTA_du_ovlSaRrcRej}                  ${CURDIR}/configs/delta_du_ovlSaRrcRej_enabled.json
${DELTA_ovl_disabled}                    ${CURDIR}/configs/delta_ovl_disabled.json
${DELTA_emergency_call}                  ${CURDIR}/configs/delta_emergency.json
${DELTA_emergency_call_disabled}         ${CURDIR}/configs/delta_emergency_disabled.json
${DELTA_ovl_enabled}                     ${CURDIR}/configs/delta_ovl_enabled.json
&{CONFIG_ovl_enabled}                    delta=${DELTA_ovl_enabled}

${MO_CELL1}              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${MO_CELL2}              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${MO_NRBTS}              PLMN-PLMN/MRBTS-1/NRBTS-1

*** Test Cases ***
[1]CB010790-B_17_Multiple_countermeasure_application_and_emergency_call_during_ovl_detected_by_gNB-DU
    [Setup]    Run Keywords    Update UE Parameters    ue_id=1    ue_nr_capabilities=$SA_UE_CAPABILITIES_TDD_FDD_A4
    ...    AND    Enable gNB Overload Protection Feature
    ...    AND    Upload Delta    delta=${DELTA_emergency_call}
    ...    AND    Test Case Setup    logs=${LOGS_WITH_DCAP}    config=${CONFIG_ovl_enabled}
    ...    AND    Wait for Next PM Counters Interval

    Airphone And Gnb Bip Traces Start 1

    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=eventId eventA4
    ...    should_contain=eventId eventA4

    Airphone And Gnb Bip Traces Stop 1

    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=52    event=A4
    SA UE Deregister    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Enter Overload State on gNB-DU
    Set and Attach Beamcontrol Test Mode    ue_id=1

    Airphone And Gnb Bip Traces Start 2

    SA UE Register    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1
    ...    pass_regexp=rrc-TransactionIdentifier [0-9].*rrcReconfigurationComplete

    Airphone And Gnb Bip Traces Stop 2

    Perform Beam Change with RRC    ue_id=1    profile_id=2    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    Perform Beam Change with RRC    ue_id=1    profile_id=1    pass_regexp=${None}
    Sleep    5s    Wait for potential unexpected beam change
    SA UE Deregister    ue_id=1
    Remove Beamcontrol Test Mode
    Start SA L3 Call    ue_id=1
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1
    ...    pass_regexp=PDU Session Resource Setup.*unsuccessful due to misc control processing overload
    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=measResultNeighCells measResultListNR
    Sleep    5s    Wait for potential unexpected HO to complete
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Prepare UE History Information    ue_id=1
    Start SA L3 Call    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    ...    should_contain=@{Empty}    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation
    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=2    cell_id=1
    Start NSA L3 Call    ue_id=101
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    ...    should_contain=@{Empty}    pass_regexp=value NRUeReport
    Sleep    5s    Wait for potential unexpected HO to complete
    Perform NSA LTE Bearer Addition    ue_id=101    bearer_id=3
    Perform NSA DC Bearer Addition    ue_id=101    bearer_id=3
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    ...    should_contain=SgNBModificationRequestReject
    Stop NSA L3 Call    ue_id=101
    Stop GNB tcpdump Collection
    ${pm_filepath}    Get Next XML PM Counters File

    Log To Console    verify counters ${MO_CELL1}
    Verify Last Counters In File
    ...  M55113C02502  >1  NSA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55125C06001  1  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  M55112C05501  0  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  M55124C00023  0  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55113C02501  >3  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55305C03009  1  BEAM_CHANGE_0_1
    ...  M55305C03002  1  BEAM_CHANGE_1_0
    ...  M55124C04502  1  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  M55143C00501  1  XN_SA_HO_PREP_FAIL_OVLCP
    ...  M55124C04503  1  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  M55112C05502  1  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    Log To Console    verify counters ${MO_NRBTS}
    Verify Last Counters In File
    ...  M55128C01501  0  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=(f1ap.procedureCode == 24) && (f1ap.GNBDUOverloadInformation == 0)    count=>1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=0
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.UEContextModificationRefuse_element && f1ap.misc == control-processing-overload    count=>5
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=xnap.HandoverPreparationFailure_element && xnap.misc == control-processing-overload    count=1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUOverloadInformation == overloaded    count=>1
    Upload Delta    delta=${DELTA_du_ovlSaRrcRej}
    Start GNB tcpdump Collection    log_dir=${TEST_log_dir}/Wireshark2/
    Prepare UE To Emergency Call    ue_id=1

    Airphone And Gnb Bip Traces Start 3

    SA UE Register    ue_id=1    registration_type=EmergencyRegistration    should_contain=establishmentCause emergency
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1    request_type=initial-emergency-request
    Sleep    3s    Wait for potential unexpected A4 configuration
    Verify UE Has No Configuration For A4 Measurement    ue_id=1
    PDU Session Setup    ue_id=1    pdu_id=15    nwslice=1    request_type=initial-emergency-request
    SA UE Deregister    ue_id=1
    SA UE Register    ue_id=1    registration_type=EmergencyRegistration    should_contain=establishmentCause emergency
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1    request_type=initial-emergency-request

    Airphone And Gnb Bip Traces Stop 3

    Start Internal SA Downlink Traffic    ue_id=1
    Start Internal SA Uplink Traffic    ue_id=1

    Airphone And Gnb Bip Traces Start 4

    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=51    event=A3
    Verify UE Location    ue_id=1    node_id=2    cell_id=2

    Perform Intra-GNB Inter-Cell Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Verify UE Location    ue_id=1    node_id=2    cell_id=1

    Airphone And Gnb Bip Traces Stop 4

    Stop SA L3 Call    ue_id=1
    Change UE Location    ue_id=1    node_id=3    cell_id=1
    Prepare UE History Information    ue_id=1
    SA UE Register    ue_id=1    registration_type=EmergencyRegistration    should_contain=establishmentCause emergency
    PDU Session Setup    ue_id=1    pdu_id=1    nwslice=1    request_type=initial-emergency-request
    Start Internal SA Downlink Traffic    ue_id=1
    Start Internal SA Uplink Traffic    ue_id=1
    Perform Inter-GNB Xn Handover To Target PCI    ue_id=1    target_pci=50    event=A3
    Verify UE Location    ue_id=1    node_id=2    cell_id=1
    Stop SA L3 Call    ue_id=1
    Stop GNB tcpdump Collection

    ${pm_filepath}    Get Next XML PM Counters File
    Log To Console    verify counters ${MO_CELL1}
    Verify Last Counters In File
    ...  M55113C02502  0  NSA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55125C06001  0  SA_PDU_SES_NEME_STP_FAIL_OVLCP
    ...  M55112C05501  0  X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...  M55124C00023  0  SA_RRC_ESTAB_NEME_FAIL_OVLDU
    ...  M55113C02501  0  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  M55124C04502  0  NRRCC_NSA_MEAS_DISCARD_OVLCP
    ...  M55143C00501  0  XN_SA_HO_PREP_FAIL_OVLCP
    ...  M55124C04503  0  NRRCC_SA_MEAS_DISCARD_OVLCP
    ...  M55112C05502  0  NX2CC_BEARER_FAIL_OVLCP
    ...  local_moid=${MO_CELL1}
    ...  file_path=${pm_filepath}
    Log To Console    verify counters ${MO_CELL2}
    Verify Last Counters In File
    ...  M55113C02501  0  SA_UE_CTXT_MOD_FAIL_OVLCP
    ...  local_moid=${MO_CELL2}
    ...  file_path=${pm_filepath}
    Log To Console    verify counters ${MO_NRBTS}
    Verify Last Counters In File
    ...  M55128C01501  0  X2_HO_FAIL_OVLCP
    ...  local_moid=${MO_NRBTS}
    ...  file_path=${pm_filepath}
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=(f1ap.procedureCode == 24) && (f1ap.GNBDUOverloadInformation == 0)    count=>1
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBAdditionRequestReject_element && x2ap.misc==control-processing-overload   count=0
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=x2ap.SgNBModificationRequestReject_element && x2ap.misc == control-processing-overload   count=0
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.UEContextModificationRefuse_element && f1ap.misc == control-processing-overload    count=0
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=xnap.HandoverPreparationFailure_element && xnap.misc == control-processing-overload    count=0
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUOverloadInformation == overloaded    count=>1

