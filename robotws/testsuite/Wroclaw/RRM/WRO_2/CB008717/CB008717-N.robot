*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :author: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    ../resources/testing_env.robot
Resource    ../keywords/keywords.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/traffic.robot
Resource    feature_keywords.robot

Library     KeywordsCB008717.py
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     ta5g_pm_counters
Library     ../../resources/scout_report.py

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
...    AND     Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND     Start Vm Ethernet Interfaces For Simulated gNB
...    AND     Wait For Environment To Be Ready

Test Teardown      Run Keywords
...                Add Scout Scf Id To Test Data
...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg_N_B1b}=               ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1b.cfg
${IPHY_N_B1b}=              ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B1b}=              scfc_NB1b_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${cfg_N_B2b1}=              ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${IPHY_N_B2b1}=             ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B2b1}=             scfc_NB2b1_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${cfg_N_B2c}=               ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${IPHY_N_B2c}=              ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B2c}=              scfc_NB2c_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${cfg_N_B41a}=              ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${IPHY_N_B41a}=             ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B41a}=             scfc_NB41a_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${cfg_N_B41d}=              ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${IPHY_N_B41d}=             ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B41d}=             scfc_N_B41d.xml
${cfg_N_B42c}=              ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B42c.cfg
${IPHY_N_B42c}=             ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO_N_B42c.xml
${SCFC_N_B42c}=             scfc_N_B42c.xml
${cfg_N_B42f}=              ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B1a.cfg
${IPHY_N_B42f}=             ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B42f}=             scfc_N_B4.2f.xml
${cfg_N_B5c}=               ${CURDIR}/config/CB008717_N/n66A_n71A_n41_2A_n260I_N_B5a.cfg
${IPHY_N_B5c}=              ${CURDIR}/config/CB008717_N/iphy_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${SCFC_N_B5c}=              scfc_N_B5c_n66A_n71A_n41_2A_n260I_BOO_LOO.xml
${delta}=                   delta_CB008717_N_B1b2.json
${amf_id}=                  1
${gnb_id}=                  2
${HANDOVER_REQUEST}=        nr-rrc.c1 == 0 && nr-rrc.candidateCellInfoList == 1 && nr-rrc.physCellId == 51 && xnap.procedureCode == 0
${HANDOVER_REQUEST_ACK}=    xnap.procedureCode == 0 && nr-rrc.c1 == 0 && nr-rrc.measObjectToAddModList == 1 && nr-rrc.freqBandIndicatorNR == 66 &&
                     ...    nr-rrc.reportConfigToAddModList == 1 && nr-rrc.eventId == 0 && nr-rrc.measId == 49 && nr-rrc.measIdToAddModList == 1 &&
                     ...    nr-rrc.physCellId == 51
@{COUNTERS_FOR_NRDC_REL_SCELL_DL}=    M55118C00083    M55118C00084
@{COUNTERS_FOR_NRDC_REL_SCELL_UL}=    M55118C00085    M55118C00086
@{COUNTERS_FOR_UE_CTXT_MOD}=     M55113C00001    M55113C00002
@{COUNTERS_NOT_TO_INCREMENT}=    M55112C00003    M55124C03006    M55118C10503    M55118C10504    M55118C10505    M55118C10506
@{COUNTERS_TO_INCREMENT}=      M55118C10503    M55118C10504    M55118C10505    M55118C10506
@{FAULT_IDS}=               6450    4383

*** Test Cases ***
CB008717_N_B1b2_NR-DC_A4_measurements_activation_after_incoming_inter_gNB_inter_frequency_handover_with_CA_HO_optimization_enabled_AFTER_CNI_102699
    [Documentation]    This Test Case covers N_B1b1 and N_B1b2 User Scenarios. The first UE is for N_B1b1 case and after sending delta commissioning,
    ...                the second UE is attached and procedure for N_B1b2 begins.
    ...                :copyright: Nokia
    ...                :authors: Marta Klukas
    ...                :contact: marta.klukas@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B1b
    ...    AND         Setup devices aliases

    Reach SIBs on simulated gNB
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=3    gw_id=1
    Get UE1 history information list

    Set expected message flow for A4 measurements activation after incoming inter gNB intra frequency handover with CA HO optimization disabled
    UE1 sends A3 measurement id=3 for inter gNB intra frequency handover with CA HO optimization disabled
    Verify expected message flow for A4 measurements activation after incoming inter gNB intra frequency handover with CA HO optimization disabled

    Verify Successfull HO with configured measurements for A1 SCell Addition
    Verify Successfull A4 Measurement Activation for UE1

    Verify that UE was not released for 60 seconds    ue_id=1
    Find Scfc and Send Delta Commissioning   scfc_filename=${delta}

    Attach UE And Establish PDU Session    ue_id=2    cell_id=2    enb_id=3    gw_id=2
    Get UE2 history information list

    Set expected message flow for A4 measurements activation after incoming inter gNB inter frequency handover with CA HO optimization enabled
    UE2 sends A3 measurement id=3 for inter gNB inter frequency handover with CA HO optimization enabled
    Verify expected message flow for A4 measurements activation after incoming inter gNB inter frequency handover with CA HO optimization enabled

    Verify Successfull HO with configured measurements for A1 SCell Addition    number_of_messages=2
    Verify Successfull SCell Addition
    Verify Successfull A4 Measurement Activation for UE2

    Verify that UE was not released for 60 seconds    ue_id=2

CB008717_N_B2b1_Rejecting_buffered_A1_measurement_report_after_successful_completion_of_NR_DC_Setup_procedure
    [Documentation]    :copyright: Nokia
    ...                :authors: Marta Klukas
    ...                :contact: marta.klukas@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B2b1
    ...    AND         Setup devices aliases

   Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1
    Delay RRC Reconfiguration Complete
    UE1 sends A4 measurement id=2 for NR-DC PSCell addition
    UE1 sends A1 measurement id=1 for SCell Addition
    UE1 sends A1 measurement id=1 for SCell Addition

    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod
    Verify Successfull NRDC setup with removed A1 and all A4 measurements

    Verify that UE was not released for 60 seconds    ue_id=1

CB008717_N_B2c_EXC1_Keeping_A1_measurement_active_after_unsuccessful_completion_of_NR-DC_Setup_procedure
    [Documentation]    :copyright: Nokia
    ...                :authors: Magdalena Mlynarska
    ...                :contact: magdalena.mlynarska@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B2c

    Setup devices aliases
    Set expexted messages flow for NR-DC rollback when A4&A1meas were configured on UE1, gNB2, AMF1 & 5*UECtxMod

    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1
    UE1 sends A4 measurement id=2 for NR-DC PSCell addition

    Verify expexted messages flow for NR-DC rollback when A4&A1meas were configured on UE1, gNB2, AMF1 & 5*UECtxMod
    Verify that BearerCtxModReq_2 out of 3 for PDUSesID1 with 1DRB was success for gNB2 for rollback
    Verify that BearerCtxModReq_3 out of 3 for PDUSesID1 was send to remove SCG with CellGrID1, 1DRB, gNB2
    Verify that NR-DC A4 meas and SCell Addition A1 meas are kept active for UE    ue_id=1

    Verify that UE was not released for 60 seconds    ue_id=1

CB008717_N_B41a1_Successful_Intra-gNB_FR1_SCell_Release_With_Counters_Verification
    [Documentation]    :copyright: Nokia
    ...                :contact: dominik.chalupczynski@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B41a
    ...    AND         Setup devices aliases

    Wait For Next Full Pm Interval
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Waiting For PDU session establishment
    Set expexted messages flow for NR-DC setup after FR1 SCell Release on UE1, gNB2
    Waiting For Message Flow To Set Up
    UE1 sends A4 measurement id=1 for PSCell Addition
    Verify expexted messages flow for NR-DC setup after FR1 SCell Release on UE1, gNB2
    Verify Successfull NR-DC setup after FR1 SCell Release
    Verify PM Counters After SCell Release Due to NRDC Setup

CB008717_N_B41d_ALT3_Releasing_FR1_SCells_during_unsuccessful_NR-DC_Setup
    [Documentation]    :copyright: Nokia
    ...                :authors: Maciej Grzeszczak, Miłosz Komarczewski
    ...                :contact: maciej.grzeszczak@nokia.com, milosz.komarczewsk@nokia.com

    [Setup]            Run Keywords
    ...                Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B41d
    ...    AND         Setup devices aliases
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}

    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Waiting For PDU session establishment

    Set expexted messages flow for NR-DC rollback after FR1 SCell Release on UE1, gNB2, AMF1
    Waiting For Message Flow To Set Up

    UE1 sends A4 measurement id=1 for PSCell Addition

    Verify expexted messages flow for NR-DC rollback after FR1 SCell Release on UE1, gNB2, AMF1

    Verify Successfull NR-DC rollback after FR1 SCell Release

    Deregister UE    1

CB008717_N_B42c_Missing_RRCReconfigurationComplete_during_FR1_SCell_Release
    [Documentation]    :copyright: Nokia
    ...                :authors: Emilia Godlewska-Lipka, Magdalena Mlynarska
    ...                :contact: emilia.godlewska-lipka@nokia.com, magdalena.mlynarska@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B42c
    ...    AND         Setup devices aliases

    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1
    Waiting For PDU Session Establishment
    Set Expexted Messages Flows For Unsuccesfull FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE1, gNB2, AMF1

    UE1 sends A1 measurement report id=1 for SCellAddition with RSRP value lower than FDD threshold
    Ignore RRCReconfiguration Message
    UE1 sends A4 measurement id=2 for PSCell Addition

    Verify Expexted Messages Flows For Unsuccesfull FR1 SCellRele due to RRCGuardTimer Exp After A4 Meas On UE1, gNB2, AMF1
    Verify Successfull A1 Measurement Based SCell Addition And CA Related Measurement Configuration
    Verify Unsuccesfull FR1 SCell Release Procedure Due To RRCGuardTimer Expiried

CB008717_N_B4.2f_SCell_Addition_after_NR-DC_Setup_failure
    [Documentation]    :copyright: Nokia
    ...                :authors: Katarzyna Bandrowska
    ...                :contact: joanna.kutrowska-girzycka@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B42f
    ...    AND         Setup devices aliases

    Set expected messages for A1 SCell Addition after NR-DC rollback and FR1 SCell Release for UE1, gNB2 and AMF1

    Attach Ue    ue_id=1
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1
    Waiting For PDU session enstablishment
    UE1 sends A1 measurement id=1 for SCell Addition
    UE1 sends A4 measurement id=2 for NR-DC Setup
    UE1 sends A1 measurement id=10 for SCell Addition

    Verify expected messages for A1 SCell Addition after NR-DC rollback and FR1 SCell Release for UE1, gNB2 and AMF1

    Verify Successfull FR1 SCell Release
    Verify Successfull NR-DC rollback
    Verify Successfull A1 Measurement Based SCell Addition

    Verify that UE was not released for 60 seconds    ue_id=1

CB008717_N_B5c_ALT1_UL_CA_PCell_FDD+SCell_TDD_operation_after_NR-DC_release_with_Beamforming_enabled_in_TDD_SCell_Trigger_with_MN_Context
    [Documentation]    :copyright: Nokia
    ...                :authors: Maciej Grzeszczak
    ...                :contact: milosz.komarczewsk@nokia.com

    [Setup]            Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    N_B5c
    ...    AND         Setup devices aliases

    Attach Ue    ue_id=2
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic   ue_id=2    pdu_id=1    gw_id=1
    Waiting For PDU Session Establishment
    Setup NR-DC PSCell Addition For UE2

    Set expexted messages flow for Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback, gNB2
    Verify expexted messages flow for Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback, gNB2
    Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback

    Send Data Traffic In Direction    ue_id=2    pdu_id=1    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=2    pdu_id=1    dir=ul    mbps=100    wait=10s

    Set expexted messages flow for NR-DC setup after FR1 SCell Release for UE2, gNB2 and AMF1
    Waiting For Message Flow To Set Up

    Successfull Expiry Random Access Problem   ue_id=2    gnb_id=2    amf_id=1    SN_gnb_id=${SN_gnb_id}    MN_gnb_id=${MN_gnb_id}
    Wait For Next Full Pm Interval
    Verify expexted messages flow for NR-DC setup after FR1 SCell Release for UE2, gNB2 and AMF1

    Verify Successfull CA FR1 establishment after NR-DC takeback due to RLF detected on UE side

    Verify That UL/DL Throughput Is Reached On PCell And SCell
    Verify PM Counters After SCell Addition Due to NRDC Release

    Verify that UE was not released for 60 seconds    ue_id=2

*** Keywords ***
#NB1
Start Vm Ethernet Interfaces For Simulated gNB
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24

Reach SIBs on simulated gNB
    Execute egate command    cmd=gnb_param id=3 sib1_period=40
    Execute egate command    cmd=gnb_param id=3 sib2_period=40
    Execute egate command    cmd=gnb_param id=3 sib5_period=40

Get UE${ue_id:\d+} history information list
    Execute egate command
    ...    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command    cmd=ue_history_information_list id=${ue_id} action=commit
    Execute egate command    cmd=ue_enb_param id=${ue_id} ue_history_list=1

Verify Successfull HO with configured measurements for A1 SCell Addition
    [Arguments]    ${number_of_messages}=1
    Verify Tcpdump Log      packet_filter=${HANDOVER_REQUEST}        continue_on_failure=False    number_of_messages=${number_of_messages}
    Verify Tcpdump Log      packet_filter=${HANDOVER_REQUEST_ACK}    continue_on_failure=False    number_of_messages=${number_of_messages}

Set expected message flow for A4 measurements activation after incoming inter gNB intra frequency handover with CA HO optimization disabled
    Set expected message flow    bearerCtxSet=1    bearerCtxMod=2    uECtxSet=1    uECtxMod=3    rrcReconf=1    rrcReconfCompl=2
    ...    handoverPreparation=1     pathSwitchReq=1    sNStatusTransfer=1    XNAPuECtxRelease=1

Verify expected message flow for A4 measurements activation after incoming inter gNB intra frequency handover with CA HO optimization disabled
    Verify expected message flow    bearerCtxSet=1    bearerCtxMod=2    uECtxSet=1    uECtxMod=3    rrcReconf=1    rrcReconfCompl=2
    ...    handoverPreparation=1     pathSwitchReq=1    sNStatusTransfer=1    XNAPuECtxRelease=1

Verify Successfull A4 Measurement Activation for UE1
    Verify in UECtxModResp_2 out of 3 that measGapConfigIE is present for gNB2
    Verify in RRCReconfig_1 out of 1 if A4 for UE1 report id 8 with measObj 9 and measId 50
    Verify in RRCReconfig_1 out of 1 if A4 for UE1 report id 8 with measObj 10 and measId 51
    Verify in RRCReconfig_1 out of 1 if A4 for UE1 report id 8 with measObj 11 and measId 52
    Verify in RRCReconfig_1 out of 1 if A4 for UE1 report id 8 with measObj 12 and measId 53
    Verify in UECtxModReq_3 out of 3 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 3 that GNB-DUConfigurationQuery is set to true for gNB2

Set expected message flow for A4 measurements activation after incoming inter gNB inter frequency handover with CA HO optimization enabled
    Set expected message flow    ue_id=2    bearerCtxSet=1    bearerCtxMod=2    uECtxSet=1    uECtxMod=6    rrcReconf=2    rrcReconfCompl=3
    ...    handoverPreparation=1     pathSwitchReq=1    sNStatusTransfer=1    XNAPuECtxRelease=1

Verify expected message flow for A4 measurements activation after incoming inter gNB inter frequency handover with CA HO optimization enabled
    Verify expected message flow    ue_id=2    bearerCtxSet=1    bearerCtxMod=2    uECtxSet=1    uECtxMod=6    rrcReconf=2    rrcReconfCompl=3
    ...    handoverPreparation=1     pathSwitchReq=1    sNStatusTransfer=1    XNAPuECtxRelease=1

Verify Successfull SCell Addition
    Verify that UECtxModReq_2 out of 6 SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 2 for UE2 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify in RRCReconfig_1 out of 2 for UE2 that A1 for CA related report id 7 and 1 measids are removed
    Verify in RRCReconfig_1 out of 2 if A2 for UE2 report id 8 with measObj 9 and measId 50
    Verify in RRCReconfig_1 out of 2 if A2 for UE2 report id 8 with measObj 10 and measId 51
    Verify in RRCReconfig_1 out of 2 if A2 for UE2 report id 8 with measObj 11 and measId 52
    Verify in UECtxModReq_3 out of 6 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_4 out of 6 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull A4 Measurement Activation for UE2
    Verify in UECtxModResp_5 out of 6 that measGapConfigIE is present for gNB2
    Verify in RRCReconfig_2 out of 2 if A4 for UE2 report id 9 with measObj 12 and measId 53
    Verify in RRCReconfig_2 out of 2 if A4 for UE2 report id 9 with measObj 13 and measId 54
    Verify in RRCReconfig_2 out of 2 if A4 for UE2 report id 9 with measObj 14 and measId 55
    Verify in RRCReconfig_2 out of 2 if A4 for UE2 report id 9 with measObj 15 and measId 56
    Verify in UECtxModReq_6 out of 6 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_6 out of 6 that GNB-DUConfigurationQuery is set to true for gNB2

#NB2b1
Delay RRC Reconfiguration Complete
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=mrdc_scg_setup delay=4000

Verify Successfull NRDC setup with removed A1 and all A4 measurements
    Verify that UECtxSetupReq_2 out of 2 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_2 out of 2 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE1 and 0-SCells and 1 DRB
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A1 measurement related to measid-1 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-4 is removed
    Verify in RRCReconfiguration_3 out of 3 for UE1 that A4 measurement related to measid-5 is removed

Verify that UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} is with expected content for PSCELL for gNB${gnb_id:\d+} with ${drb:\d+} DRB
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that SCell-ToBeSetup-Item is not present for gNB${gnb_id}
    Verify in UEContextSetupRequest_${msg_num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${gnb_id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} for 1 PDU session has ${drb:\d+} DRB for gNB${id:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} that CellGroupID eq 1 for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB${id}
    Verify in UEContextSetupResponse_${num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${id}

#NB2c
Verify that NR-DC A4 meas and SCell Addition A1 meas are kept active for UE
    [Arguments]    ${ue_id}=1  ${EventType}=EventA1.*EventA4
        Execute Egate Command And Wait For Data
        ...          cmd=ue_meas_cfg_disp id=${ue_id}
        ...          pass_regexp=${EventType}

#NB41a
Waiting For PDU session establishment
    Sleep    2s
Waiting For Message Flow To Set Up
    Sleep    2s

Verify Successfull NR-DC setup after FR1 SCell Release
    Verify that UECtxModReq_1 out of 5 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 2 for UE1 that sCellToReleaseList contains 3 sCells & A4 does not deconfigure
    Verify in UECtxModReq_2 out of 5 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify that UECtxSetupResp_1 out of 1 for 1 PDU session has 1 DRB for gNB2
    Verify that BearerCtxModResp_2 out of 2 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurements are removed
    Verify that RRCReconfigurationComplete_2 out of 2 for UE1 that message contains nr-SCG response

Verify that UECtxSetupReq_1 out of 1 is with expected content for PSCELL for gNB2 with 1 DRB
    Verify in UECtxSetupReq_1 out of 1 that ServCellIndex eq 1 for gNB2
    Verify in UECtxSetupReq_1 out of 1 that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB2
    Verify in UECtxSetupReq_1 out of 1 that SCell-ToBeSetup-Item is not present for gNB2
    Verify in UEContextSetupRequest_1 out of 1 that 1 DRB is set according to E1AP for gNB2

Verify that UECtxSetupResp_1 out of 1 for 1 PDU session has 1 DRB for gNB2
    Verify in UECtxSetupResp_1 out of 1 that CellGroupID eq 1 for gNB2
    Verify in UEContextSetupResponse_1 out of 1 that 1 DRB is set according to E1AP for gNB2

Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurements are removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-1 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-2 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-3 is removed
    Verify in RRCReconfiguration_2 out of 2 for UE1 that A4 measurement related to measid-4 is removed

Verify PM Counters After SCell Release Due to NRDC Setup
    ${pm_counter_file}=    Get Next Unpacked Raw Pm Counters File
    Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=${COUNTERS_FOR_NRDC_REL_SCELL_DL}
        ...    value=3
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=${COUNTERS_FOR_NRDC_REL_SCELL_UL}
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=${COUNTERS_FOR_UE_CTXT_MOD}
        ...    value=12
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55124C03002
        ...    value=5
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=${COUNTERS_NOT_TO_INCREMENT}
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
        ...    counter_id=M55118C09501
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest Pm Counter Is Bigger Than The Given Value
        ...    counter_id=M55118C11009
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
        ...    filepath=${pm_counter_file}
    Verify If Latest Pm Counter Is Bigger Than The Given Value
        ...    counter_id=M55118C11009
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
        ...    filepath=${pm_counter_file}
    Verify If Latest Pm Counter Is Bigger Than The Given Value
        ...    counter_id=M55118C11009
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-8
        ...    filepath=${pm_counter_file}

#NB41d
Verify Successfull NR-DC rollback after FR1 SCell Release
    Verify that UECtxModReq_1 out of 3 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_1 out of 1 for UE1 that sCellToReleaseList contains 3 sCells & A4 does not deconfigure
    Verify in UECtxModReq_2 out of 3 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 3 that GNB-DUConfigurationQuery is set to true for gNB2
    Verify that BearerCtxModReq_1 out of 2 for PDUSesID1 with 1DRB was success for gNB2 for rollback
    Verify that BearerCtxModReq_2 out of 2 for PDUSesID1 was send to remove SCG with CellGrID1, 1DRB, gNB2

#NB42c
Verify Successfull A1 Measurement Based SCell Addition And CA Related Measurement Configuration
    Verify that UECtxModReq_1 out of 4 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16391
    Verify in RRCReconfig_1 out of 2 for UE1 that sCellToAddModList contains 1 sCells with starting phys_id 57
    Verify in RRCReconfiguration_1 out of 2 for UE1 that A1 for CA related to measid-1 is removed
    Verify in RRCReconfig_1 out of 2 for UE1 that SCell Change A1 and SCell Release A2 and SCell Switch A6 are configured
    Verify in UECtxModReq_2 out of 4 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_3 out of 4 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Unsuccesfull FR1 SCell Release Procedure Due To RRCGuardTimer Expiried
    Verify that UECtxModReq_4 out of 4 SCellToBeRemovedList Contains 1 SCells With PLMN "0x134198" and starting_id 16391
    Verify in RRCReconfig_2 out of 2 for UE1 that sCellToReleaseList contains 1 sCells
    Verify in RRCReconfig_2 out of 2 for UE1 that SCell Addition A1 measurement is configured
    Verify in RRCReconfig_2 out of 2 for UE1 that SCell Change A1 and SCell Release A2 and SCell Switch A6 are deconfigured
    Verify that in UECtxReleaseCommand_1 out of 1 was send cause:radioNetwork:radio-connection-with-ue-lost for gNB2
    Verify that in UECtxReleaseCmd_F1AP_1 out of 1 was send cause:radioNetwork:normal-release for gNB2
    Verify that in BearerCtxReleaseCmd_1 out of 1 was send cause:radioNetwork:normal-release for gNB2

Send Data Traffic In Direction UL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=ul    ${mbps}=40
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=${dir} mbps=${mbps}

Send Data Traffic In Direction DL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=dl    ${mbps}=175
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=2 dir=${dir} mbps=${mbps}

#NB42f
Waiting For PDU session enstablishment
    Sleep    1s

Verify Successfull FR1 SCell Release
    Verify that UECtxModReq_8 out of 13 SCellToBeRemovedList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_4 out of 5 for UE1 that sCellToReleaseList contains 3 sCells
    Verify in RRCReconfig_4 out of 5 for UE1 that SCell Addition A1 measurement is configured
    Verify in RRCReconfig_4 out of 5 for UE1 that A2 for CA related report id 3 and 3 measids are removed
    Verify in UECtxModReq_9 out of 13 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_10 out of 13 that GNB-DUConfigurationQuery is set to true for gNB2

Verify Successfull NR-DC rollback
    Verify that BearerCtxModReq_2 out of 3 for PDUSesID1 with 1DRB was success for gNB2 for rollback
    Verify that BearerCtxModReq_3 out of 3 for PDUSesID1 was send to remove SCG with CellGrID1, 1DRB, gNB2

Verify Successfull A1 Measurement Based SCell Addition
    Verify that UECtxModReq_11 out of 13 SCellToBeSetupList Contains 3 SCells With PLMN "0x134198" and starting_id 16390
    Verify in RRCReconfig_5 out of 5 for UE1 that sCellToAddModList contains 3 sCells with starting phys_id 56
    Verify in RRCReconfiguration_5 out of 5 for UE1 that A1 measurement related to measid-10 is removed
    Verify in RRCReconf_5 out of 5 for UE1 that A2 meas was configured with reportConfigId 6
    Verify in UECtxModReq_12 out of 13 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_13 out of 13 that GNB-DUConfigurationQuery is set to true for gNB2

#NB5c
Triggered RRC By Random Access Problem
     Execute Egate Command     cmd=ue_dc_rlf ue=2 failure_type=T310_expiry at=gnb

Setup NR-DC PSCell Addition For UE2
    Execute Egate Command
    ...        cmd=ue_measurement_send_nr id=2 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4

Verify Successfull CA FR1 establishment after NR-DC takeback due to RLF detected on UE side
    Verify Suspends Data Transmission Over SCG And Confirms Modification
    Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify MCG and UE reconfiguration and release SCG and confirms modification
    Verify confirms SCG context deletion by sending Radio Network cause

    Verify that UECtxModReq_3 out of 7 SCellToBeSetupList Contains 1 SCells With PLMN "0x134198" and starting_id 16391
    Verify in UECtxtModRes_3 out of 7 that after takeback with blind FR1 CA csi-ReportConfigIDs Related To SCells And BF Cfg Are Present
    Verify in RRCReconfig_2 out of 3 for UE2 that sCellToAddModList contains 1 sCells with starting phys_id 57
    Verify in RRCReconfig_2 out of 3 that after takeback with blindCA for UE2 csi-ReportCfgIDs Related To SCells And BF Are Present
    Verify in UECtxModReq_5 out of 7 that GNB-DUConfigurationQuery is set to true for gNB2
    Verify A4 measurement report configuration in UECtxtModReq_6 out of 7 for gNB2
    Verify in UECtxtModReq_6 out of 7 that measObjectID 5 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 1 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 2 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 3 is present
    Verify in UECtxtModReq_6 out of 7 that measObjectID 4 is present
    Verify in UECtxModResp_6 out of 7 that measGapConfigIE is present for gNB2
    Verify in RRCReconfig_3 out of 3 for UE2 that MeasConfig contains 4-items in measIdToAddModList
    Verify in UECtxModReq_4 out of 7 that RRCReconfigurationCompleteIndicator is set to true for gNB2
    Verify in UECtxModReq_7 out of 7 that GNB-DUConfigurationQuery is set to true for gNB2

Collect GND-IDs From Flow To Use In Parallel Execution Of Bearer Takeback
    ${SN_gnb_id}=    Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_1 out of 1 for gNB2
    ${MN_gnb_id}=    Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_1 out of 1 for gNB2
    Set Suite Variable    ${SN_gnb_id}
    Set Suite Variable    ${MN_gnb_id}

Verify Suspends Data Transmission Over SCG And Confirms Modification
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 2 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 2 for pDUSessionID=1 with 1 DRBs were send for gNB2 for MN

Verify requests to reconfigure MCG and to release SCG and confirms modification
    Verify that UECtxModReq_1 out of 6 was send with adjustment of MCG configuration upon SCG release for the UE2 for MN
    Verify that UECtxModResp_1 out of 6 was send with confirming modification of MCG for the UE2 for MN
    Verify that RRCReconfiguration_1 out of 3 was send for UE2 to release SCG and reconfigure MCG for 1-DRBs
    Verify that SCGFailureInformation_1 out of 1 was completed RLF in SCG
    Verify that RRCReconfigurationComplete_1 out of 3 was send for UE2

Verify MCG and UE reconfiguration and release SCG and confirms modification
    Verify that UECtxModReq_2 out of 6 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 6 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 2 was send to release SCG leg with CellGroupID=1 for 1-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 2 was send with SCG leg deletion for 1-DRBs for gNB2 for MN

Verify confirms SCG context deletion by sending Radio Network cause
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:action-desirable-for-radio-reasons for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2

Verify That UL/DL Throughput Is Reached On PCell And SCell
    Verify That Throughput Is Reached On Cell Group    ue_id=2    expected_throughput=30Mbps     cell_index_min=0
        ...    cell_index_max=1    direction=dl    selection_type=Average    margin=50%
    Verify That Throughput Is Reached On Cell Group   ue_id=2    expected_throughput=30Mbps     cell_index_min=0
        ...       direction=ul       selection_type=Average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=2    expected_throughput=30Mbps     cell_index_min=1
        ...       direction=ul       selection_type=Average    margin=50%

Verify PM Counters After SCell Addition Due to NRDC Release
    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=${COUNTERS_TO_INCREMENT}
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
