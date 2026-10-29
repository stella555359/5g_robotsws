*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB009267-B
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ../CB009267_Keywords.robot

Suite Setup       Prepare TL for CB009267
Suite Teardown    Sqd65 Common Teardown

Test Setup        Perform Preconditions of Test Scenario
Test Teardown     Perform Postconditions of Test Case

*** Variables ***
${TEST_MODE}              auto

*** Test Cases ***

CB009267-B_NSA_CA_Counters_for_Scell_Release_Attempt_Release_Success_HRDRB
    [Documentation]
    ...   This NSA CA user scenario is covered by this TI: "NSA CA counters for SCell release attempts and release success". This TI is
    ...   based on SCell Release triggered due to HR DRB.
    ...   High-Reliability functionality isn't active in one or more SCells (actLAForHiReliab=false).
    ...   UE12: configured for DL: 2CC and UL: 1CC with NSA CA and blind SCell addition, then buffer-based SCell activation,
    ...   followerd by one high reliability DRB(HRDRB), resulting in SCell release in RRC Reconfiguration meassage.
    ...   PCell = FDD (Cell_4 in gNB), SCell-1 = TDD (Cell_1 in gNB).
    ...   SCell release attempts and success counters due to HR DRB are checked for NSA for DL.
    ...   Entity item mapping: CB009267-SR-B-B201 counters update for scell release attempts and success for Intra gnb CA NSA-FR1.

    [Tags]    B_EI_B201
    Apply Configs for B_B201   test_instance=B_EI_B201
    Wait until the next Measurement Period starts
    Attach UE to LTE  ue_id=12
    Trigger LTE-NR dual connectivity for bearers    ue_id=12  target_cells=4
    Send Egate Command and verify output     cmd=trf_data_start ue=12 id=2 dir=dl kbps=500
    Send Egate Command and verify output     cmd=trf_data_start ue=12 id=2 dir=ul kbps=500
    Sleep  30s    reason=Wait for data traffic to stabilize
    Send Egate Command and verify output     cmd=bearer_add ue=12 id=3 filter=3 precedence=3    pass_regexp=rrcConnectionReconfigurationComplete
    Send Egate Command and verify output    cmd=enb_ue_dc_modify ue=12 bearer_to_add=3 by=enb cause=RN_reduce_load_in_serving_cell type=split_scg
    ...       pass_regexp=sCellToReleaseList
    Collect and Verify PM Counters for SA  test_instance=B_EI_B201    pcell=4
    Detach UE from LTE    ue_id=12

CB009267-B_NSA_CA_Counters_for_Scell_Configuration_Attempt_Failure
    [Documentation]     A1-based scell addition, Buffer-based scell activatin.
    ...    The User scenario describes the CA SCell configuration attempts and configuration failure counters Intra gNB NSA.
    ...    Here we consider UE12 with 2CC DL and 1CC UL CA support, Pcell=4
    ...   Entity item mapping: CB009267-SR-B-B301
    [Tags]    B_EI_B301
    Apply Configs for B_B301    test_instance=B_EI_B301
    Wait until the next Measurement Period starts
    Attach UE to LTE  ue_id=12
    Trigger LTE-NR dual connectivity for bearers    ue_id=12  target_cells=4
    Send Egate Command and verify output      cmd=ue_measurement_send_nr id=12 meas_id=1 event=A1 rs_type=ssb srsrp_nr=70
    Send Egate Command and verify output      cmd=trf_data_start ue=12 id=2 dir=dl mbps=150
    Send Egate Command and verify output     cmd=trf_data_start ue=12 id=2 dir=ul mbps=50
    Sleep  30s    reason=Wait for data traffic to stabilize
    Collect and Verify PM Counters for SA  test_instance=B_EI_B301    pcell=4
    Detach UE from LTE    ue_id=12

CB009267-B-UPD001_NSA_CA_config_failure_SgNB_Triggered_HO
    [Documentation]     The User scenario describes the CA SCell configuration attempt failures all CA type (Intra gNB) for NSA mobility scenario
    ...                 From Procedure 2: NSA Intra SgNB Intra DU PSCell Change Mobility (inter MeNB HO/intra MeNB HO/SgNB Triggered HO)
    ...                 SCell configuration attempts are attempted for various HOs: SgNB Triggered HO
    [Tags]    B-UPD001  B-UPD001_1
    Wait until the next Measurement Period starts
    Preconditions for NSA CA Config Failure (NSA Mobility)
    Attach UE to LTE  ue_id=${UE_ID_NSA_MOBILITY_CA}
    Trigger LTE-NR dual connectivity for bearers    ue_id=${UE_ID_NSA_MOBILITY_CA}  target_cells=5
    Intra SgNB Triggered HO
    NSA CA Config Failure (NSA Mobility) Counter Verification

CB009267-B-UPD001_NSA_CA_config_failure_Inter_SgNB_PSCell_change_HO
    [Documentation]     The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for NSA mobility scenario
    ...                 Procedure 3: NSA Inter SgNB PSCell Change Mobility:
    [Tags]    B-UPD001  B-UPD001_2
    Wait until the next Measurement Period starts
    Preconditions for NSA CA Config Failure (NSA Mobility)
    Attach UE to LTE  ue_id=${UE_ID_NSA_MOBILITY_CA}
    Trigger LTE-NR dual connectivity for bearers    ue_id=${UE_ID_NSA_MOBILITY_CA}  target_gnb=3  target_cells=1
    Inter SgNB Mobility
    NSA CA Config Failure (NSA Mobility) Counter Verification

CB009267-B-UPD001_NSA_CA_config_failure_PSCell_Change_by_SecurityKey_Change
    [Documentation]     The User scenario describes the CA SCell configuration attempt failures all CA type (Inter gNB) for NSA mobility scenario
    ...                 Procedure 2:
    [Tags]    B-UPD001  B-UPD001_3
    Attach UE to LTE  ue_id=${UE_ID_NSA_MOBILITY_CA}
    Trigger LTE-NR dual connectivity for bearers    ue_id=${UE_ID_NSA_MOBILITY_CA}  target_cells=4
    Wait until the next Measurement Period starts
    Preconditions for NSA CA Config Failure (NSA Mobility)
    Intra MeNB Handover
    NSA CA Config Failure (NSA Mobility) Counter Verification
