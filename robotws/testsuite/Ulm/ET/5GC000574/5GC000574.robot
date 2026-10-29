*** Settings ***

Documentation
...    Description: Test Suite for 5GC000574 Inter-MeNB LTE handover without en-gNB change (NSA Option 3x)
...    Rework: Ulm SQD 65
...    author: G. Sankaran, L. Medico, Ulm SQD 66
...    contact: ganesh.sankaran@nokia.com   luca.medico@nokia.com
...    maintainer: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Precondition: one Classical gNB with Airphone and WTS, pre-configured with QT released configuration
...    UTE Testline Type: CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...    notes: 5GC000634-K adapted

Resource         5GC000574_Keywords.robot

Suite Setup      Suite Setup for 5GC000574
Suite Teardown   Sqd65 Common Teardown

Test Setup       Perform Precondition for 5GC000574 testcase
Test Teardown    Perform Postconditions for 5GC000574 testcase

*** Test Cases ***
5GC000574_A_TC02_Verify_SgNB_addition_support_for_inter_MeNB_HO_without_change_in_SCG_configuration
    [Documentation]
    ...    Perform Ue HO between two eNB without changing gNB
    ...    Following counters must be checked:
    ...    M55112C03501: X2_SGNB_ADD_REQ_INTR_MENB_HO = 1
    ...    M55112C03502: X2_SGNB_ADD_REQ_ACK_INTRENB_HO = 1
    ...    M55128C00503: INTER_MENB_HO_RRC_RECONF = 1
    ...    M55128C00504: INTER_MENB_HO_RRC_RECONF_SUCC = 1
    ...    M55128C00502: INTER_MENB_HO_WO_PSCELL_CHNGE = 1
    ...    M55110C00034: X2_SGNB_ADD_REQ_REC = 1
    ...    M55112C00002: X2_SGNB_ADD_REQ_ACK_SENT = 1
    ...    M55112C00003: X2_SGNB_RECONF_RECEIVED = 1
    ...    M55112C00004: X2_SGNB_RECONF_ACK_RECEIVED = 1
    [Tags]    TC02  CIT
    ${number_handover}=    Set Variable    1
    Attach UE to LTE    ue_id=101
    Trigger LTE-NR dual connectivity for bearers    ue_id=101  bearer_id=${DEFAULT_BEARER}
    Start data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl
    ...  trf_id=2  mbps=${AP_DL_RATE}
    Perform eNB Handover    ue_id=101  target_enb_id=9  target_cell_id=9
    Stop data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl  trf_id=2
    Wait until the current Measurement Period stops
    Verify 5GC000574    ${number_handover}

5GC000574_A_TC10_Verify_SgNB_addition_support_for_ping-pong_inter_MeNB_HO_without_change_in_SCG_configuration
    [Documentation]
    ...    Perform several Ue HO between two eNB without changing gNB
    ...    Following counters must be checked:
    ...    M55112C03501: X2_SGNB_ADD_REQ_INTR_MENB_HO
    ...    M55112C03502: X2_SGNB_ADD_REQ_ACK_INTRENB_HO
    ...    M55128C00503: INTER_MENB_HO_RRC_RECONF
    ...    M55128C00504: INTER_MENB_HO_RRC_RECONF_SUCC
    ...    M55128C00502: INTER_MENB_HO_WO_PSCELL_CHNGE
    ...    M55110C00034: X2_SGNB_ADD_REQ_REC = 1
    ...    M55112C00002: X2_SGNB_ADD_REQ_ACK_SENT = 1
    ...    M55112C00003: X2_SGNB_RECONF_RECEIVED = 1
    ...    M55112C00004: X2_SGNB_RECONF_ACK_RECEIVED = 1
    [Tags]    TC10
    ${number_handover}=    Set Variable    5
    Attach UE to LTE    ue_id=101
    Trigger LTE-NR dual connectivity for bearers    ue_id=101  bearer_id=${DEFAULT_BEARER}
    Start data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl
    ...  trf_id=2  mbps=${AP_DL_RATE}
    Perform multiple eNB Handovers    ${number_handover}
    Stop data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl  trf_id=2
    Wait until the current Measurement Period stops
    Verify 5GC000574    ${number_handover}

5GC000574_C_TC05_Verify_SgNB_addition_support_for_inter_MeNB_HO_with_SGW_relocation_and_without_change_in_SCG_configuration
    [Documentation]
    ...    Perform Ue HO between two eNB without changing gNB
    ...    Following counters must be checked:
    ...    M55112C03501: X2_SGNB_ADD_REQ_INTR_MENB_HO = 1
    ...    M55112C03502: X2_SGNB_ADD_REQ_ACK_INTRENB_HO = 1
    ...    M55128C00503: INTER_MENB_HO_RRC_RECONF = 1
    ...    M55128C00504: INTER_MENB_HO_RRC_RECONF_SUCC = 1
    ...    M55128C00502: INTER_MENB_HO_WO_PSCELL_CHNGE = 1
    ...    M55112C04001 : X2_SGNB_MOD_REQ_RECEIVED = 1
    ...    M55112C04002 : X2_SGNB_MOD_REQ_ACK_SENT = 1
    [Tags]    TC05  CRT
    ${number_handover}=    Set Variable    1
    Attach UE to LTE    ue_id=101
    Trigger LTE-NR dual connectivity for bearers    ue_id=101  bearer_id=${DEFAULT_BEARER}
    Start data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl
    ...  trf_id=2  mbps=${AP_DL_RATE}
    Start data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=ul
    ...  trf_id=1  mbps=${AP_UL_RATE}
    Trigger SGW relocation
    Perform eNB Handover    ue_id=101  target_enb_id=9  target_cell_id=9  sgw_relocation=True
    Stop data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl  trf_id=2
    Wait until the current Measurement Period stops
    Verify 5GC000574    ${number_handover}  extended_dict_sgw=True

5GC000574_A_TC03_Verify_SgNB_addition_support_for_inter_MeNB_HO_with_change_in_SCG_configuration_with_PS_cell_in_same_DU
    [Documentation]
    ...   This scenario covers the handling of SgNB Addition procedure by 5GNB to support Inter-MeNB handover without SgNB change,
    ...   with change in the SCG configuration(PSCell) at SgNB with PScell in same DU.
    ...   candidate_cells_mn_hex_for_menb_ho (hex-string) from SgNBAddReq: candidateCellInfoListMN for Cell-2 (target cell)
    [Tags]    TC03  CRT
    Attach UE to LTE    ue_id=101
    Trigger LTE-NR dual connectivity for bearers    ue_id=101  bearer_id=${DEFAULT_BEARER}
    Start data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=dl  trf_id=2  mbps=1
    Start data traffic in egate    ue_id=101  id=${DEFAULT_BEARER}  direction=ul  trf_id=1  mbps=1
    Send Egate Command and verify output   ue_enb_endc_param id=101 candidate_cells_mn_hex_for_menb_ho=092659802198
    Perform eNB Handover    ue_id=101  target_enb_id=9  target_cell_id=9
    Stop data traffic in egate    ue_id=101 id=${DEFAULT_BEARER}  direction=dl  trf_id=2
    Wait until the current Measurement Period stops
    Verify 5GC000574-A_TC03
