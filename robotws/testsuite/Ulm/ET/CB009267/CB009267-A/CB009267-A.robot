*** Settings ***

Documentation
...    author: VRF ULM T01 01 and VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 1' and 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB009267-A
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource   ../CB009267_Keywords.robot

Suite Setup       Prepare TL for CB009267
Suite Teardown    Sqd65 Common Teardown

Test Setup        Perform Preconditions of Test Scenario
Test Teardown     Perform Postconditions of Test Case

*** Variables ***

${TEST_MODE}                    auto
${NRCELL-1.arfcnSsbPbch}        518910
${NRCELL-2.arfcnSsbPbch}        531870
${NRCELL-3.arfcnSsbPbch}        655968
${NRCELL-4.arfcnSsbPbch}        127450
${NRCELL-5.arfcnSsbPbch}        431090
${NRCELL-6.arfcnSsbPbch}        392410
@{pdu_qos_list_A_EI_B201-2_1}   4
@{pdu_qos_list_A_EI_B201-3}     3,5

@{MSG_SEQ_DLUL}                 @{EMPTY}

@{MSG_SEQ_DLUL_1}               sCellToAddModList
...                             sCellIndex 1
...                             physCellId 55
...                             downlinkConfigCommon
...                             uplinkConfigCommon

@{MSG_SEQ_DLUL_2}               sCellToAddModList
...                             sCellIndex 2
...                             physCellId 52
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellToReleaseList

@{MSG_SEQ_DLUL_3}               sCellToAddModList
...                             sCellIndex 1
...                             physCellId 50
...                             downlinkConfigCommon
...                             uplinkConfigCommon

@{MSG_SEQ_DLUL_4}               sCellToAddModList
...                             sCellIndex 2
...                             physCellId 51
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellToReleaseList

@{MSG_SEQ_DLUL_5}               sCellToAddModList
...                             sCellIndex 1
...                             physCellId 50
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellToReleaseList

@{MSG_SEQ_DLUL_6}               sCellToAddModList
...                             sCellIndex 1
...                             physCellId 53
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellIndex 2
...                             physCellId 54
...                             downlinkConfigCommon

@{MSG_SEQ_DLUL_RELEASE}         sCellToReleaseList

*** Test Cases ***

[1]CB009267-A_SA_CA_Counters_for_successfull_SCell_configuration_swap_change_and_release
    [Documentation]
    ...   These two SA CA user scenarios are covered by this TI: "SA CA Counters for SCell configuration attempts and success (5G_PM_1631)" and
    ...   "SA CA Counters for SCell change and SCell swap configuration attempts and success (5G_PM_1666)". This TI is based on SCell Addition by A1,
    ...   SCell Change by A1 and SCell Release by A2.
    ...   UE4: configured for DL: 2CC and UL: 2CC is configured with SA CA with A1-based MR, followerd by SCell Change by A1-based MR and SCell
    ...   Release by A2-based MR. PCell = FDD (Cell_4 in gNB), SCell-1 = FDD (Cell_6 in gNB), SCell-2 = TDD (Cell_3 in gNB).
    ...   SCell configuration attempts and success counters are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B101 counters update for scell addition/swap/change attempts and success for Intra gNB CA SA-FR1.
    [Tags]    A_EI_B101  A_EI_B101_1
    Apply Configs for D_EI_B2_2    test_instance=A_EI_B101_1
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=4
    Verify A1 Measurement Event Configured and Confirm that UE is Configured with CA after Sending A1 MR  ue_id=4
    Verify A1 Measurement Event Configured and Confirm that SCell Change was Successul at UE after Sending A1 MR  ue_id=4
    Verify A2 Measurement Event Configured and Confirm that SCell Release was Successul at UE after Sending A2 MR  ue_id=4
    Collect and Verify PM Counters for SA  test_instance=A_EI_B101_1   pcell=4
    Stop Data transfer and Deregister UE  ue_id=4

[2]CB009267-A_SA_CA_Counters_for_successfull_SCell_configuration_swap_change_and_release
    [Documentation]
    ...   These two SA CA user scenarios are covered by this TI: "SA CA Counters for SCell configuration attempts and success (5G_PM_1631)" and
    ...   "SA CA Counters for SCell change and SCell swap configuration attempts and success (5G_PM_1666)". This TI is based on SCell Addition by A1,
    ...   SCell Swap by A6 and SCell Release by A2.
    ...   UE4: configured for DL: 2CC and UL: 2CC is configured with SA CA with A1-based MR, followed by SCell Swap by A6-based MR and SCell
    ...   Release by A2-based MR. PCell = FDD (Cell_4 in gNB), SCell-1 = TDD (Cell_1 in gNB), SCell-2 = TDD (Cell_2 in gNB).
    ...   SCell configuration attempts and success counters are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B101 counters update for scell addition/swap/change attempts and success for Intra gNB CA SA-FR1.
    [Tags]    A_EI_B101  A_EI_B101_2
    [Setup]   Reconfigure TL for CB009267-A_EI_B101_2
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=4
    Verify A1 Measurement Event Configured and Confirm that UE is Configured with CA & A6 Meas Event after Sending A1 MR  ue_id=4
    Send A6 MR and Verify that SCell Swap was Successful at UE  ue_id=4  scell_index=1  phycell_id=51  Cell_Id=Cell-2
    Send A6 MR and Verify that SCell Swap was Successful at UE  ue_id=4  scell_index=2  phycell_id=50  Cell_Id=Cell-1
    Verify A2 Measurement Event Configured and Confirm that SCell Release was Successul at UE after Sending A2 MR  ue_id=4
    ...   carrier_freq=${NRCELL-1.arfcnSsbPbch}  scell_index=1
    Collect and Verify PM Counters for SA  test_instance=A_EI_B101_2   pcell=4
    Stop Data transfer and Deregister UE  ue_id=4
    [Teardown]   Reconfigure TL back to Default Config for CB009267-A_EI_B101_2

CB009267-A_SA_CA_Counters_for_SCell_release_for_UE_overheating
    [Documentation]
    ...   This SA CA user scenario is covered by this TI: "SA CA counters for SCell release attempts and release success (5G_PM_1634)". This TI is
    ...   based on SCell Release triggered due to UE overheating.
    ...   UE1: configured for DL: 3CC and UL: 2CC is configured with SA CA with buffer-based SCell addition and SCell activation, followerd by
    ...   UE overheating triggered with egate command resulting in SCell release in RRC Reconfiguration meassage. PCell = TDD (Cell_1 in gNB),
    ...   SCell-1 = FDD (Cell_4 in gNB), SCell-2 = FDD (Cell_5 in gNB).
    ...   SCell release attempts and success counters due to UE overheating are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B201 counters update for scell release attempts and success for Intra gnb CA SA-FR1.
    [Tags]    A_EI_B201  A_EI_B201-1
    Apply Configs for A_EI_B201-1    test_instance=A_EI_B201-1
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=1
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_6}
    Verify SCELL Addition for UE in RRC Reconfiguration
    ...   DLUL_CA_cell_configuration=3CC DL CA with Cell-4 and Cell-5 as SCell and 2CC UL CA with Cell-4 as SCell
    Send UE Assistance for overheating Egate command and verify SCells release in seperate RRC Reconfiguration message  ue_id=1
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_6}
    Verify SCELL Addition for UE in RRC Reconfiguration after the expiry of CA backoff timer for UE overheating
    ...   DLUL_CA_cell_configuration=3CC DL CA with Cell-4 and Cell-5 as SCell and 2CC UL CA with Cell-4 as SCell
    Collect and Verify PM Counters for SA  test_instance=A_EI_B201-1
    Stop Data transfer and Deregister UE  ue_id=1

[1]CB009267-A_SA_CA_Counters_for_SCell_release_for_Incompatible_DRB_and_Non_Eligible_DRB
    [Documentation]
    ...   This SA CA user scenario is covered by this TI: "SA CA counters for SCell release attempts and release success (5G_PM_1634)". This TI is
    ...   based on SCell Release triggered due to Incompatible DRB.
    ...   UE1: configured for DL: 3CC and UL: 2CC is configured with SA CA with blind SCell addition, buffer-based SCell activation, followerd by
    ...   UE PDU Session modification to add Incompatible DRB resulting in SCell release in RRC Reconfiguration meassage.
    ...   PCell = TDD (Cell_1 in gNB), SCell-1 = FDD (Cell_4 in gNB), SCell-2 = FDD (Cell_5 in gNB).
    ...   SCell release attempts and success counters due to Incompatible DRB are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B201 counters update for scell release attempts and success for Intra gnb CA SA-FR1.
    [Tags]    A_EI_B201  A_EI_B201-2  A_EI_B201-2_1
    Apply Configs for A_EI_B201-2    test_instance=A_EI_B201-2_1
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=1
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_6}
    Verify SCELL Addition for UE in RRC Reconfiguration
    ...   DLUL_CA_cell_configuration=3CC DL CA with Cell-4 and Cell-5 as SCell and 2CC UL CA with Cell-4 as SCell
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Modify UE PDU Session to add Incompatible DRB and verify SCells release in one RRC Reconfiguration message  ue_id=1
    Collect and Verify PM Counters for SA  test_instance=A_EI_B201-2_1
    Stop Data transfer and Deregister UE  ue_id=1

[2]CB009267-A_SA_CA_Counters_for_SCell_release_for_Incompatible_DRB_and_Non_Eligible_DRB
    [Documentation]
    ...   This SA CA user scenario is covered by this TI: "SA CA counters for SCell release attempts and release success (5G_PM_1634)". This TI is
    ...   based on SCell Release triggered due to Non Eligible DRB.
    ...   UE1: configured for DL: 3CC and UL: 2CC is configured with SA CA with blind SCell addition with PDU session setup with two DRBs: default
    ...   FR1 CA eligible DRB and Not FR1 CA eligible DRB, then buffer-based SCell activation, followerd by UE PDU Session modification to delete
    ...   default FR1 CA eligible DRB, resulting in SCell release in RRC Reconfiguration meassage due to one Non Eligible DRB remaining.
    ...   PCell = TDD (Cell_1 in gNB), SCell-1 = FDD (Cell_4 in gNB), SCell-2 = FDD (Cell_5 in gNB).
    ...   SCell release attempts and success counters due to releasing the last CA-eligible DRB are checked for SA for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B201 counters update for scell release attempts and success for Intra gnb CA SA-FR1.
    [Tags]    A_EI_B201  A_EI_B201-2  A_EI_B201-2_2
    Apply Configs for A_EI_B201-2    test_instance=A_EI_B201-2_2
    Wait until the next Measurement Period starts
    UE Register  ue_id=1
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=3
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_6}
    Verify SCELL Addition for UE in RRC Reconfiguration
    ...   DLUL_CA_cell_configuration=3CC DL CA with Cell-4 and Cell-5 as SCell and 2CC UL CA with Cell-4 as SCell
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Modify UE PDU Session to delete default FR1 CA eligible DRB and verify SCells release in one RRC Reconfiguration message  ue_id=1
    Collect and Verify PM Counters for SA  test_instance=A_EI_B201-2_2
    Stop Data transfer and Deregister UE  ue_id=1

CB009267-A_SA_CA_Counters_for_SCell_release_for_HRDRB
    [Documentation]
    ...   This SA CA user scenario is covered by this TI: "SA CA counters for SCell release attempts and release success (5G_PM_1634)". This TI is
    ...   based on SCell Release triggered due to HR DRB.
    ...   High-Reliability functionality isn't active in one or more SCells (MRBTS-1/NRBTS-1/NRCELL-5.actLAForHiReliab=false).
    ...   UE1: configured for DL: 3CC and UL: 2CC is configured with SA CA with blind SCell addition with PDU session setup with default best
    ...   reliability (BR) FR1 CA eligible DRB, then buffer-based SCell activation, followerd by UE PDU Session modification to add two high
    ...   reliability DRBs (HRDRBs), resulting in SCell release in RRC Reconfiguration meassage since High-Reliability functionality isn't active
    ...   in one SCell (Cell-5).
    ...   PCell = TDD (Cell_1 in gNB), SCell-1 = FDD (Cell_4 in gNB), SCell-2 = FDD (Cell_5 in gNB).
    ...   SCell release attempts and success counters due to HR DRB are checked for SA for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B201 counters update for scell release attempts and success for Intra gnb CA SA-FR1.
    [Tags]    A_EI_B201  A_EI_B201-3
    Apply Configs for A_EI_B201-3    test_instance=A_EI_B201-3
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=1
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_6}
    Verify SCELL Addition for UE in RRC Reconfiguration
    ...   DLUL_CA_cell_configuration=3CC DL CA with Cell-4 and Cell-5 as SCell and 2CC UL CA with Cell-4 as SCell
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Modify UE PDU Session to add two HR DRBs and verify SCells release in one RRC Reconfiguration message  ue_id=1
    Collect and Verify PM Counters for SA  test_instance=A_EI_B201-3
    Stop Data transfer and Deregister UE  ue_id=1

[1]CB009267-A_SA_CA_Counters_for_SCell_configuration_failure_for_Cell_Not_Available_and_No_UE_Capability
    [Documentation]
    ...   This SA CA user scenario is covered by this TI: "SA CA Counters for SCell configuration failures (5G_PM_1636)". This TI checks counters
    ...   for SCell configuration failure for cases of Cell not available (NRBTS/NRCELL.longPucchConfigType=nonCaPucchConfig for PCell).
    ...   UE4: configured for DL: 3CC and UL: 2CC. longPucchConfigType is set to nonCaPucchConfig for PCell. Initially default nonGBR DRB (NRDRB-11)
    ...   is established in PDU session in a PCell and no CA SCell added in RRC Reconfiguration message, due to longPucchConfigType=1 in PCell
    ...   (SCell configuration failure). PCell = FDD (Cell_4 in gNB), SCell-1 = FDD (Cell_6 in gNB), SCell-2 = TDD (Cell_3 in gNB).
    ...   SCell configuration failure counters are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B3 Counters update for SCell addition/swap/change failures for SA - FR1.
    [Tags]    A_EI_B3  A_EI_B3_1
    Apply Configs for A_EI_B3_1    test_instance=A_EI_B3_1
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=4
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=4  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=4  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Collect and Verify PM Counters for SA  test_instance=A_EI_B3_1   pcell=4
    Stop Data transfer and Deregister UE  ue_id=4

[2]CB009267-A_SA_CA_Counters_for_SCell_configuration_failure_for_Cell_Not_Available_and_No_UE_Capability
    [Documentation]
    ...   This SA CA user scenario is covered by this TI: "SA CA Counters for SCell configuration failures (5G_PM_1636)". This TI checks counters
    ...   for SCell configuration failure for cases of UE NR Capability of UE not supporting CA in DL or UL.
    ...   UE1: configured for DL: 3CC and UL: 2CC. UE NR Capability of UE1 does not support CA in DL or UL. Initially default nonGBR DRB (NRDRB-11)
    ...   is established in PDU session in a PCell and no CA SCell added in RRC Reconfiguration message, due to UE NR Capability of UE1 not
    ...   supporting CA (SCell configuration failure). PCell = TDD (Cell_1 in gNB), SCell-1 = FDD (Cell_4 in gNB), SCell-2 = FDD (Cell_5 in gNB).
    ...   SCell configuration failure counters are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-A-B3 Counters update for SCell addition/swap/change failures for SA - FR1.
    [Tags]    A_EI_B3  A_EI_B3_2
    Apply Configs for A_EI_B3_2    test_instance=A_EI_B3_2
    Wait until the next Measurement Period starts
    Register and Establish PDU Session with modified UE Capability  ue_id=1  ue_nr_capabilities=${UE_CAPAB_1CC_1CC_NO_CA}
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Collect and Verify PM Counters for SA  test_instance=A_EI_B3_2
    Stop Data transfer and Deregister UE  ue_id=1

[1]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_release
    [Documentation]
    ...  The User scenario describes the CA configuration release attempts and release success counters for all CA type Inter gNB for SA
    ...  privateCause::Xg-U-GTP-U-error  (scell addition: meas based)
    [Tags]    A_B202  A_B202_1
    Perform Preconditions for Inter gNB CA       scenario=scell_release
    Inter gNB CA Addition Params
    Set Counter Value                            ref_table=${A_EI_B202_PM_PCELL}  counter=M55118C11099  value=1  # DL_LNKFEXT_REL_SCELL_ATT_SA
    Set Counter Value                            ref_table=${A_EI_B202_PM_PCELL}  counter=M55118C11100  value=1  # DL_LNKFEXT_REL_SCELL_SUC_SA
    Register UE and trigger inter gNB CA
    Inter gNB CA Release                         cause=xgu_gtpu_error
    Inter gNB CA Counter Verification

[2]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_release
    [Documentation]
    ...  The User scenario describes the CA configuration release attempts and release success counters for all CA type Inter gNB for SA
    ...  radioNetwork::Unspecified   (scell addition: meas based)
    [Tags]    A_B202  A_B202_2
    Perform Preconditions for Inter gNB CA       scenario=scell_release
    Inter gNB CA Addition Params
    Set Counter Value                            ref_table=${A_EI_B202_PM_PCELL}  counter=M55118C11101  value=1  # DL_RNUSPC_EXT_REL_SCELL_ATT_SA
    Set Counter Value                            ref_table=${A_EI_B202_PM_PCELL}  counter=M55118C11102  value=1  # DL_RNUSPC_EXT_REL_SCELL_SUC_SA
    Register UE and trigger inter gNB CA
    Inter gNB CA Release                         cause=unspecified
    Inter gNB CA Counter Verification

[3]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_release
    [Documentation]
    ...  The User scenario describes the CA configuration release attempts and release success counters for all CA type Inter gNB for SA
    ...  by A2 measurement         (scell addition: meas based)
    [Tags]    A_B204  A_B202_3
    Perform Preconditions for Inter gNB CA       scenario=scell_release
    Inter gNB CA Addition Params
    Set Counter Value                            ref_table=${A_EI_B202_PM_PCELL}  counter=M55118C06501  value=1  # A2MEAS_REL1DLSCELL_ATT_SA
    Set Counter Value                            ref_table=${A_EI_B202_PM_PCELL}  counter=M55118C06502  value=1  # A2MEAS_REL1DLSCELL_SUCC_SA
    Register UE and trigger inter gNB CA
    Inter gNB CA Release                         cause=A2
    Inter gNB CA Counter Verification

[1]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   standardCause::radioNetwork: target_not_allowed  (scell addition: blind)
    [Tags]    A_B3  A_B3_1
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=target_not_allowed
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00141    # DL_XDU_1SCELL_STP_F_TRGNALD_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}          pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification

[2]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   cause: maxNumOfCaUsersExceeded    (scell addition: blind)
    ...   (no addmission check)
    [Tags]    A_B3  A_B3_2
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Init CA Counters                             ${SCELL_2_SA}
    Set MaxNumOfCaUsersNRCell                    0
    Set Counter Value                            ref_table=${A_EI_B3_PM_PCELL}       counter=M55118C11104  value=1  # GNB_SCELL_F_MAXCAUSR_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}
    Inter gNB CA Counter Verification

[3]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures al CA type (Inter gNB) for SA.
    ...   cause: unknown (Number of SCell configuration fails due to no SCell candidte found for SCell)
    ...   (scell addition: blind, no admission check)
    [Tags]    A_B3  A_B3_3
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Set FreqBandIndicatorNR
    Set Counter Value                            ref_table=${A_EI_B3_PM_PCELL}       counter=M55118C11105  value=1  # GNB_SCELL_F_NOCAND_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}
    Inter gNB CA Counter Verification

[5]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   privateCause::Incompatible configuration   (scell addition: blind)
    [Tags]    A_B3  A_B3_5
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=incompatible_configuration
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00155   # DL_XDU_1SCELL_STP_F_ICMCNF_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification

[6]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   privateCause::C-RNTI-collision    (scell addition: blind)
    [Tags]    A_B3  A_B3_6
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=c_rnti_collision
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00148   # DL_XDU_1SCELL_STP_F_CRNTICL_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification

[7]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   standardCause: radioNetwork: cell-not-available  (scell addition: blind)
    [Tags]    A_B3  A_B3_7
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=cell_not_available
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00169   # DL_XDU_1SCELL_STP_F_CEL_NA_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification

[8]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   standardCause: misc: not-enough-user-plane-processing-resources  (scell addition: blind)
    [Tags]    A_B3  A_B3_8
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=not_enough_user_plane_processing_resources
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00176   # DL_XDU_1SCELL_STP_F_UP_RES_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification

[9]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   standardCause: radioNetwork: insufficient-ue-capabilities  (scell addition: blind)
    [Tags]    A_B3  A_B3_9
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=insufficient_ue_capabilities
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00183   # DL_XDU_1SCELL_STP_F_UE_CAP_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification

[10]CB009267-A_CA_counters_for_inter-gNB_CA_SCell_configuration failures
    [Documentation]
    ...   The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for SA.
    ...   standardCause: radioNetwork: no-radio-resources-available / transport: transport-resource-unavailable
    ...   (scell addition: blind)
    [Tags]    A_B3  A_B3_10
    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=transport_resource_unavailable
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00162   # DL_XDU_1SCELL_STP_F_NO_RES_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification
    Stop Data transfer and Deregister UE         ue_id=${UE_ID_IGNB_CA}

    Perform Preconditions for Inter gNB CA       scenario=scell_config_failure
    Inter gNB CA Addition Params                 cause=no_radio_resource_available
    Set Counter Values for cfg failures on XDU   failure_counter=M55167C00162   # DL_XDU_1SCELL_STP_F_NO_RES_SA
    Register and Establish PDU Session           ue_id=${UE_ID_IGNB_CA}         pass_regexp=CELL-4\\.11 \\[ACTIVE\\]
    Inter gNB CA Counter Verification
