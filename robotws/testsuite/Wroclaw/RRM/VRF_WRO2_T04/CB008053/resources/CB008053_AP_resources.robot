*** Settings ***
Documentation
...      == COPYRIGHT ==
...          Nokia Networks
...      == AUTHORS U-PLANE ==
...        - Michal Obszarny    <michal.obszarny@nokia.com>
...        - Marcin Gorczyca    <marcin.gorczyca@nokia.com>
...        - Lukasz Gdowski     <lukasz.gdowski@nokia.com>
...        - Szymon Guza        <szymon.guza@nokia.com>
...        - Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
...        - Jakub Grela        <jakub.grela@nokia.com>
...      == MAINTAINER ==
...        - Michal Obszarny    <michal.obszarny@nokia.com>
...        - Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
...        - Lukasz Klimowicz   <lukasz.klimowicz@nokia.com>
...        - Blanka Gozdek      <blanka.gozdek@nokia.com>


Variables   ta_messaging_filters_TTTF.py
Resource    ../../CB006733/CB006733_AP/resources/collectors.robot

*** Keywords ***
# ------------ UEs registration , PDU session setup and A1 report sending ------------
Register 4CC DL CA capable NR-UE${UE_ID} to gNB-2 Cell-${CELL_ID}
    Log to console  \nRegister NR-UE${UE_ID} to Cell-${CELL_ID}
    Set Internal Traffic Type To UE    ue_id=${UE_ID}    pdu_id=${UE_ID}
    Attach UE    ue_id=${UE_ID}    cell=${CELL_ID}    enb=2
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE

Establish PDU session for NR-UE${UE_ID}
    Execute egate command
    ...    cmd=ue_pdu_session_setup pdu=${UE_ID} ue=${UE_ID} nwslice=1 gw=${UE_ID}
    ...    pass_regexp=UE${UE_ID}: Established PDU session

Establish PDU session to trigger blind SCell addition for NR-UE${UE_ID}
    Log to console  ESTABLISH NR-UE${UE_ID}
    Expect message flow
    ...    UE_${UE_ID}:NR-RRC_UECapabilityInformation as UECapabilityInformation
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration as RRCReconfiguration_2nd
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete_2nd
    ...    alias=SCell_addition_NR_RRC_UE${UE_ID}   overall_timeout=20
    Expect message flow
    ...    gNB2:F1AP_UEContextSetupRequest (CUtoDURRCInformation is present) as UEContextSetupRequest
    ...    gNB2:F1AP_UEContextSetupResponse (DUtoCURRCInformation is present) as UEContextSetupResponse
    ...    gNB2:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest_1st
    ...    gNB2:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_1st
    ...    gNB2:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB2:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_2nd
    ...    alias=SCell_addition_F1AP_UE${UE_ID}   overall_timeout=20
    Execute egate command
    ...    cmd=ue_pdu_session_setup pdu=${UE_ID} ue=${UE_ID} nwslice=1 gw=${UE_ID}
    ...    pass_regexp=UE${UE_ID}: Established PDU session
    Flow occurred as expected  alias=SCell_addition_NR_RRC_UE${UE_ID}
    Flow occurred as expected  alias=SCell_addition_F1AP_UE${UE_ID}

Send A1 measurement report with srsrp value eq ${srsrp} and meas_id eq ${meas_id} to trigger SCells addition for NR-UE${UE_ID}
    Expect message flow
    ...    gNB2:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest_1st
    ...    gNB2:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_1st
    ...    gNB2:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB2:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_2nd
    ...    alias=SCell_addition_F1AP_UE${UE_ID}   overall_timeout=20
    Expect message flow
    ...    UE_${UE_ID}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SCell_addition_NR_RRC_UE${UE_ID}   overall_timeout=20
    Execute egate command  cmd=ue_measurement_send_nr event=A1 meas_id=${meas_id} id=${UE_ID} srsrp_nr=${srsrp}
    Flow occurred as expected  alias=SCell_addition_F1AP_UE${UE_ID}
    Flow occurred as expected  alias=SCell_addition_NR_RRC_UE${UE_ID}

# ------------ TTI Traces collection ------------
Collect TTI Traces during ${duration} seconds and save to directory ${directory_name}
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Start TTI trace
    Stop TTI trace    target_dir=${OUTPUTDIR}/${TESTNAME}/${parent_directory}    delay=${duration}

Convert TTI Traces
    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/${TESTNAME}/pCSI_BM_reported_in_a_bundle/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/${TESTNAME}/pCSI_BM_reported_in_a_bundle/output
    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/${TESTNAME}/beam_switch/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/${TESTNAME}/beam_switch/output
    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/${TESTNAME}/Bler_MCS/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/${TESTNAME}/Bler_MCS/output

# ------------ Radio conditions setting ------------
Trigger Beam change on the TDD FR1 SCells based on SSB beam measurements received from UE for NR-UE${UE_ID}
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-140
    Sleep  1s
    Execute egate command  cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=activate profile_id=1 scell=2
    Sleep  1s
    Execute egate command  cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=activate profile_id=1 scell=0
    Sleep  1s
    Execute egate command  cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=activate profile_id=1 scell=3
    Sleep  1s

Deactivate and remove UE beam control testmodes for NR-UE${UE_ID}
    Execute egate command  cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=deactivate profile_id=1 scell=2
    Sleep  2s
    Execute egate command  cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=deactivate profile_id=1 scell=0
    Sleep  2s
    Execute egate command  cmd=ue_testmode_set_nr id=${UE_ID} testmode=beam_control action=deactivate profile_id=1 scell=3
    Sleep  2s
    Execute egate command  cmd=beam_control_testmode_nr profile_id=1 delete=on
    Sleep  2s

Trigger DL BLER Test Mode to achieve Target MCS for NR-UE${UE_ID}
    Execute egate command  cmd=bler_testmode_nr profile_id=2 target_mcs=5 num_dl_pkts=1000
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=activate profile_id=2 scell=0
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=activate profile_id=2 scell=1
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=activate profile_id=2 scell=2
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=activate profile_id=2 scell=3
    Sleep  2s

Deactivate and remove UE bler testmodes for NR-UE${UE_ID}
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=deactivate profile_id=2 scell=0
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=deactivate profile_id=2 scell=1
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=deactivate profile_id=2 scell=2
    Sleep  2s
    Execute egate command  cmd=ue_testmode_nr_set id=${UE_ID} testmode=bler action=deactivate profile_id=2 scell=3
    Sleep  2s
    Execute egate command  cmd=bler_testmode_nr profile_id=2 delete=on
    Sleep  2s

Release PDU session for NR-UE${UE_ID}
    Release PDU session    ${UE_ID}

Deregister NR-UE${UE_ID}
    Deregister UE    ${UE_ID}

# ------------ SCells selection and addition: ------------
# ***** 2CC DL CA *****
Verify sCellToAddModList IE whether only 1FDD Cell was added as SCell in A1 SCells addition for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${added_SCell_for_TF_2CC_CA_SCells_addition_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_UE${UE_ID}

Verify sCellToAddModList IE whether only 1TDD Cell was added as SCell in A1 SCells addition for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${added_SCell_for_TT_2CC_CA_SCells_addition_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_UE${UE_ID}

# ***** 3CC DL CA *****
Verify SCell-ToBeSetupMod-List IE whether 2TDD Cells were selected to 3CC DL CA in A1 SCells addition for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_TTT_3CC_CA_SCells_addition_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest_1st
    ...  flow_alias=SCell_addition_UE${UE_ID}

Verify sCellToAddModList IE whether 2TDD Cells were added as SCells in A1 SCells addition for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${added_SCells_for_TTT_3CC_CA_SCells_addition_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_UE${UE_ID}

Verify SCell-ToBeSetupMod-List IE whether 1TDD Cells and 1FDD Cell were selected to 3CC DL CA for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_TTTF_3CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest_1st
    ...  flow_alias=SCell_addition_UE${UE_ID}

# ***** 4CC DL CA *****
Verify SCell-ToBeSetupMod-List IE whether 2TDD Cells and 1FDD Cell were selected to 4CC DL CA for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest_1st
    ...  flow_alias=SCell_addition_F1AP_UE${UE_ID}

Verify sCellToAddModList IE whether 2TDD and 1FDD Cells were added as SCells for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${added_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_UE${UE_ID}

Verify SCell-ToBeSetupMod-List IE whether 3FDD Cells were selected to 4CC DL CA in A1 SCells addition for NR-UE${UE ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_TFFF_4CC_CA_SCells_addition_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest_1st
    ...  flow_alias=SCell_addition_UE${UE_ID}

Verify sCellToAddModList IE whether 3FDD Cells were added as SCells in A1 SCells addition for NR-UE${UE ID}
    Verify That Message Fulfills Query
    ...      ${added_SCells_for_TFFF_4CC_CA_SCells_addition_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_UE${UE_ID}

# ------------ UE capabilities verification: ------------
Verify NR-UE${UE_ID} successfully attached to the PCell and gNB obtained UE capabilities and contains simultaneousCSI-ReportsAllCC eq 20
    Verify That Message Fulfills Query
    ...      ${UE_NR_Capability_contains_simultaneousCSI_ReportsPerCC_4_and_simultaneousCSI_ReportsAllCC_20}
    ...  message_alias=UECapabilityInformation
    ...  flow_alias=SCell_addition_NR_RRC_UE${UE_ID}

Verify NR-UE${UE_ID} successfully attached to the PCell and gNB obtained UE capabilities and contains simultaneousCSI-ReportsAllCC eq 12
    Verify That Message Fulfills Query
    ...      ${UE_NR_Capability_contains_simultaneousCSI_ReportsPerCC_4_and_simultaneousCSI_ReportsAllCC_12}
    ...  message_alias=UECapabilityInformation
    ...  flow_alias=SCell_addition_NR_RRC_UE${UE_ID}

# ------------ PUCCH resourceSetId verification: ------------
Verify resourceSetToAddModList IE whether PUCCH resources were allocated correctly for BF enabled for TTTF 4CC CA NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${resourceSetToAddModList_for_BF_enabled_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_F1AP_UE${UE_ID}

# ------------ Periodic CSI, HARQ AN, SSB Beam and CRI of the best CSI-RS (Beamforming and Beam Refinement) reporting configuration ------------
# ***** TTTF Measurements reporting configuration - Beamforming enabled *****
Verify whether pCSI and HARQ AN and SSB Beam reporting configuration was sent for all Cells for TTTF 4CC CA for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSIReportConfigToAddModList_for_BF_enabled_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_UE${UE_ID}

Verify HARQ-AN for PDSCH transmission can be decoded correctly when multiplexed with pCSI (bundled or separate) for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSIReportConfigToAddModList_for_BF_enabled_with_CSI_BM_bundling_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_F1AP_UE${UE_ID}

Verify SCellToAddModList IE whether each SCell has CSI-RS configuration for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${CSIRS_configuration_for_each_SCell}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=SCell_addition_F1AP_UE${UE_ID}

# ------------ SCells change ------------
Verify SCell-ToBeSetupMod-List IE whether 2TDD Cells were selected as SCells in SCells Change from TFFF to TTT CA for NR-UE${UE ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_SCells_change_from_TFFF_to_TTT_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest_1st
    ...  flow_alias=Successful_SCell_change_UE${UE_ID}

Verify sCellToAddModList IE whether 2TDD Cells were added as SCells in SCells Change from TFFF to TTT CA for NR-UE${UE ID}
    Verify That Message Fulfills Query
    ...      ${added_SCells_in_SCells_change_from_TFFF_to_TTT_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=Successful_SCell_change_UE${UE_ID}

Verify SCell-ToBeSetupMod-List IE whether 3FDD Cells were selected as SCells in SCells Change from TTT to TFFF CA for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${selected_SCells_for_SCells_change_from_TTT_to_TFFF_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest_1st
    ...  flow_alias=Successful_SCell_change_UE${UE_ID}

Verify sCellToAddModList IE whether 3FDD Cells were added as SCells in SCells Change from TTT to TFFF CA for NR-UE${UE_ID}
    Verify That Message Fulfills Query
    ...      ${added_SCells_in_SCells_change_from_TTT_to_TFFF_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse_2nd
    ...  flow_alias=Successful_SCell_change_UE${UE_ID}

# ------------ Throughput ------------
Start ${tput_mbps}Mbps DL data traffic for NR-UE${UE_ID}
    Start SA traffic  ue=${UE_ID}  dir=dl  traffic_rate=${tput_mbps}Mbps

Start ${tput_mbps}Mbps UL data traffic for NR-UE${UE_ID}
    Start SA traffic  ue=${UE_ID}  dir=ul  traffic_rate=${tput_mbps}Mbps

Verify that average ${direction} throughput in SA mode on SCell-${SCell} is about ${traffic_rate}MBps for NR-UE${UE_ID}
    Verify SA traffic  ue=${UE_ID}  dir=${direction}  expected_traffic=${traffic_rate}Mbps  scells=${SCell}  tolerance=30  data_rate_type=average

Verify that maximum ${direction} throughput in SA mode on SCell-${SCell} is about ${traffic_rate}MBps for NR-UE${UE_ID}
    Verify SA traffic  ue=${UE_ID}  dir=${direction}  expected_traffic=${traffic_rate}Mbps  scells=${SCell}  tolerance=20  data_rate_type=maximum

Stop DL and UL traffic on PDU for NR-UE${UE_ID}
    Stop SA traffic  ue=${UE_ID}

Wait ${seconds}s for throughput stable
    Sleep  ${seconds}s

# ------------ gNB reconfiguration ------------
Change infTddFrameStructure configuration to tdLte on Cell4
    Configure and wait    ${CURDIR}/../CB008053_AP/config/CB008053-C-B3a_inftdLte.yaml
