*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB009059-A which consists of Feature activation and blind SCell Addition with 3CC CA
...    Tested on: CLOUD_5G_I_MP_AP_LO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_CPRI_FDD_CB009059

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ./CB009059_Keywords.robot

Suite Setup                     Prepare TL for CB009059
Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions of Test Scenario
Test Teardown                   Perform Postconditions of Test Case

*** Variables ***

${TEST_MODE}                    auto

@{pdu1_qos_list_A_B6_ue_1}      2
@{pdu1_qos_list_A_B6_ue_2}      5
@{pdu1_qos_list_A_B10_1}        5
@{pdu1_qos_list_A_B10_2}        3
@{pdu1_qos_list_A_B10_3}        4,5

@{MSG_SEQ_DL}                   sCellToAddModList
...                             sCellIndex 1
...                             physCellId 51
...                             downlinkConfigCommon
...                             sCellIndex 2
...                             physCellId 52
...                             downlinkConfigCommon

*** Test Cases ***

CB009059_A_B1_Feature_activation_of_DRB_profile_based_Carrier_Aggregation_interaction
    [Documentation]
    ...   In this user scenario, Operator activates CB009059 via NIDD parameter change. After feature activation, the gNB considers the
    ...   NRBTS/NRDRB.CellAggrLevel parameter when a PDU session is set-up, modified, or released to determine whether CA can be configured
    ...   on this UE.
    ...   CB009059-ET-A001: Feature activation ICS with one FR1 CA eligible DRB and one Not FR1 CA eligible DRB blind 2T1F CA
    [Tags]    A_B1
    Apply Config for A_B1  test_instance=A_B1
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=2
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1,5
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=3  start_qfi=1  end_qfi=3
    Collect and Verify PM Counters  test_instance=A_B1
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=3
    UE Deregister  ue_id=1  ue_deregister_type=switch_off

CB009059_A_B2_Feature_deactivation_of_DRB_profile_based_Carrier_Aggregation_interaction
    [Documentation]
    ...   In this user scenario, Operator deactivates CB009059 via NIDD parameter change. After feature deactivation, the gNB considers any
    ...   RLC AM mode non-GBR DRB as CA eligible regardless of the NRBTS/NRDRB.cellAggrLevel parameter setting.
    ...   CB009059-ET-A002: Feature deactivation ICS with FR1 CA eligible DRB and Not FR1 CA eligible DRB and FR1 CA incompatible DRB blind 1T2F CA
    [Tags]    A_B2   robot:skip
    Apply Config for A_B2   test_instance=A_B2
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=2
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=3,5
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=3  start_qfi=1  end_qfi=3
    Collect and Verify PM Counters  test_instance=A_B2
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=3
    UE Deregister  ue_id=1  ue_deregister_type=switch_off

CB009059_A_B6_PDU_session_modification_with_DRB_setup_when_UE_is_not_in_CA
    [Documentation]
    ...   In this user scenario, the UE is attached to a cell and the DRB configuration does not allow SCell Addition. After a PDU session
    ...   modification procedure adds an FR1 CA eligible DRB, SCell Addition is triggered only if there is no established FR1 CA
    ...   incompatible DRB.
    ...   CB009059-ET-A014: Non CA PDU with Not FR1 CA eligible DRB and then PDU modify add at least one FR1 CA eligible DRB blind CA
    ...   Case 1 execute with UE-1 and case 2 execute with UE-2
    [Tags]    A_B6   robot:skip
    Apply Config for A_B6   test_instance=A_B6
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=3
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_A_B6_ue_1}  by=amf
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Save Current Section of Egate Console Log and Restart Egate log  name=section_${SECTION}
    UE Register  ue_id=2
    Modifying default QOS flow   ue_id=2  qos_flow=1
    Set traffic type  ue_id=2  pdu_id=1  trf_type=internal
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=4
    UE PDU Session Setup  ue_id=2  pdu=1  gw=2
    Verify the UE is not Configured with Carrier Aggregation  ue_id=2
    UE PDU Session Modify   ue_id=2  pdu=1  qos_flow_list=@{pdu1_qos_list_A_B6_ue_2}  by=amf
    Verify the UE is not Configured with Carrier Aggregation  ue_id=2
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  start_qfi=1  end_qfi=2
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=2  trf_id_range_min=1  trf_id_range_max=4  start_qfi=1  end_qfi=3
    Collect and Verify PM Counters  test_instance=A_B6
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4
    Stop Data transfer for all Traffic IDs  ue_id=2  trf_id_start=1  trf_id_end=4
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    UE Deregister  ue_id=2  ue_deregister_type=switch_off

[1]CB009059_A_B7_PDU_session_modification_with_DRB_setup_and_release
    [Documentation]
    ...   In this user scenario, during ICS the UE is attached to the PCell. None of the established DRBs are FR1 CA eligible.  After a PDU
    ...   session modification procedure adds an FR1 CA eligible DRB and releases the last DRB which disallows CA, SCell Addition is triggered.
    ...   [1]CB009059-ET-A017: Non CA PDU with Not FR1 CA eligible DRB and then PDU modify add at least one FR1 CA eligible DRB and del old Not
    ...   FR1 CA eligible DRB blind CA
    [Tags]    A_B7  A_B7_1   robot:skip
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=3
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Adding and deleting QOS Flows to PDU Session   ue_id=1  pdu=1  qosflows_to_add=2  qosflows_to_del=3  by=amf
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  start_qfi=2  end_qfi=2
    Collect and Verify PM Counters  test_instance=A_B7_1
    Wait until the next Measurement Period starts
    Adding and deleting QOS Flows to PDU Session   ue_id=1  pdu=1  qosflows_to_add=5  qosflows_to_del=2  by=amf
    Verify Carrier Aggregation is still activated at the UE  ue_id=1
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  start_qfi=1  end_qfi=1
    Collect and Verify PM Counters  test_instance=A_B7  dual_delta_commissioning=_after_pdu_mod
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4
    UE Deregister  ue_id=1  ue_deregister_type=switch_off

[2]CB009059_A_B7_PDU_session_modification_with_DRB_setup_and_release
    [Documentation]
    ...   In this user scenario, during ICS the UE is attached to the PCell. None of the established DRBs are FR1 CA eligible.  After a PDU
    ...   session modification procedure adds an FR1 CA eligible DRB and releases the last DRB which disallows CA, SCell Addition is triggered.
    ...   CB009059-ET-A018: Non CA PDU with multiple PDUs with FR1 CA incompatible DRB and then PDU modify add FR1 CA eligible DRB and del all
    ...   FR1 CA incompatible DRB blind CA
    [Tags]    A_B7  A_B7_2   robot:skip
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=4
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Set traffic type  ue_id=1  pdu_id=2  trf_type=internal
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  pass_regexp=Pdu Session Resource Setup.*successfully
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Adding and deleting QOS Flows to PDU Session   ue_id=1  pdu=1  qosflows_to_add=2  qosflows_to_del=4  by=amf
    Adding and deleting QOS Flows to PDU Session   ue_id=1  pdu=2  qosflows_to_add=5  qosflows_to_del=4  by=amf
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Start downlink Data Traffic in Egate on multiple Traffic IDs and PDUs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  pdu_count=2  qfi=2
    Collect and Verify PM Counters  test_instance=A_B7_2
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4  pdu=1
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4  pdu=2
    UE Deregister  ue_id=1  ue_deregister_type=switch_off

[3]CB009059_A_B7_PDU_session_modification_with_DRB_setup_and_release
    [Documentation]
    ...   In this user scenario, during ICS the UE is attached to the PCell. None of the established DRBs are FR1 CA eligible.  After a PDU
    ...   session modification procedure adds an FR1 CA eligible DRB and releases the last DRB which disallows CA, SCell Addition is triggered.
    ...   [Alt] Non CA PDU with FR1 CA eligible and FR1 CA incompatible DRB and then PDU modify delete FR1 CA incompatible DRB blind CA
    [Tags]    A_B7  A_B7_3   robot:skip
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=2
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=7
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Deleting QOS Flow in PDU Session   ue_id=1  pdu=1  qosflows_to_del=7  by=amf  pass_regexp=Pdu Session Resource Modify.*successfully
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  start_qfi=1  end_qfi=1
    Collect and Verify PM Counters  test_instance=A_B7_3
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4
    UE Deregister  ue_id=1  ue_deregister_type=switch_off

[1]CB009059_A_B10_PDU_session_modification_after_eligible_DRB_and_no_incompatible_DRB_established
    [Documentation]
    ...   In this user scenario, the UE attaches and an FR1 CA eligible DRB is established. The blind SCell Addition fails however due to
    ...   admission control and later a PDU modification results in the addition of one or two DRBs. The gNB may then trigger SCell Addition
    ...   as long as no FR1 CA incompatible DRBs are setup or remain.
    ...   CB009059-ET-A020: CA Failure by AC PDU with at least one FR1 CA eligible DRB and then PDU modify add one FR1 CA eligible DRB blind CA
    [Tags]    A_B10  A_B10_1   robot:skip
    ${DELTA_COMMISSIONING}=  Set Variable  _SCell_Allocations_disabled
    Apply Config for A_B10  test_instance=A_B10_1  action=${DELTA_COMMISSIONING}
    UE Register  ue_id=1
    Modifying default QOS flow   ue_id=1  qos_flow=2
    Set traffic type  ue_id=1  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  pdu=1
    Collect and Verify PM Counters  test_instance=A_B10_1  dual_delta_commissioning=${DELTA_COMMISSIONING}
    ${DELTA_COMMISSIONING}=  Set Variable  _SCell_Allocations_enabled
    Apply Config for A_B10  test_instance=A_B10_1  action=${DELTA_COMMISSIONING}
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list_A_B10_1}  by=amf
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Wait until the next Measurement Period starts
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=1  trf_id_range_min=1  trf_id_range_max=4  start_qfi=2  end_qfi=2
    Collect and Verify PM Counters  test_instance=A_B10_1  dual_delta_commissioning=${DELTA_COMMISSIONING}
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4
    UE Deregister  ue_id=1  ue_deregister_type=switch_off

[2]CB009059_A_B10_PDU_session_modification_after_eligible_DRB_and_no_incompatible_DRB_established
    [Documentation]
    ...   In this user scenario, the UE attaches and an FR1 CA eligible DRB is established. The blind SCell Addition fails however due to
    ...   admission control and later a PDU modification results in the addition of one or two DRBs. The gNB may then trigger SCell Addition
    ...   as long as no FR1 CA incompatible DRBs are setup or remain.
    ...   CB009059-ET-A021: CA Failure by AC PDU with at least one FR1 CA eligible DRB and then PDU modify add one Not FR1 CA eligible DRB blind CA
    [Tags]    A_B10  A_B10_2   robot:skip
    ${DELTA_COMMISSIONING}=  Set Variable  _SCell_Allocations_disabled
    Apply Config for A_B10  test_instance=A_B10_2  action=${DELTA_COMMISSIONING}
    UE Register  ue_id=2
    Modifying default QOS flow   ue_id=2  qos_flow=2
    Set traffic type  ue_id=2  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=2  pdu=1  gw=2
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=2  trf_id_range_min=1  trf_id_range_max=4  pdu=1
    Collect and Verify PM Counters  test_instance=A_B10_2  dual_delta_commissioning=${DELTA_COMMISSIONING}
    ${DELTA_COMMISSIONING}=  Set Variable  _SCell_Allocations_enabled
    Apply Config for A_B10  test_instance=A_B10_2  action=${DELTA_COMMISSIONING}
    UE PDU Session Modify   ue_id=2  pdu=1  qos_flow_list=@{pdu1_qos_list_A_B10_2}  by=amf
    Verify SCELL Addition for UE in RRC Reconfiguration  sCellOperationalMode=dlonly
    Wait until the next Measurement Period starts
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=2  trf_id_range_min=1  trf_id_range_max=4  start_qfi=2  end_qfi=2
    Collect and Verify PM Counters  test_instance=A_B10_2  dual_delta_commissioning=${DELTA_COMMISSIONING}
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4
    UE Deregister  ue_id=2  ue_deregister_type=switch_off

[3]CB009059_A_B10_PDU_session_modification_after_eligible_DRB_and_no_incompatible_DRB_established
    [Documentation]
    ...   In this user scenario, the UE attaches and an FR1 CA eligible DRB is established. The blind SCell Addition fails however due to
    ...   admission control and later a PDU modification results in the addition of one or two DRBs. The gNB may then trigger SCell Addition
    ...   as long as no FR1 CA incompatible DRBs are setup or remain.
    ...   CB009059-ET-A022: CA Failure by AC PDU with at least one FR1 CA eligible DRB and then PDU modify add one FR1 CA eligible DRB and one
    ...   FR1 CA incompatible DRB blind No CA
    [Tags]    A_B10  A_B10_3   robot:skip
    ${DELTA_COMMISSIONING}=  Set Variable  _SCell_Allocations_disabled
    Apply Config for A_B10  test_instance=A_B10_3  action=${DELTA_COMMISSIONING}
    UE Register  ue_id=3
    Modifying default QOS flow   ue_id=3  qos_flow=2
    Set traffic type  ue_id=3  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=3  pdu=1  gw=3
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=3  trf_id_range_min=1  trf_id_range_max=4  pdu=1
    Collect and Verify PM Counters  test_instance=A_B10_3  dual_delta_commissioning=${DELTA_COMMISSIONING}
    ${DELTA_COMMISSIONING}=  Set Variable  _SCell_Allocations_enabled
    Apply Config for A_B10  test_instance=A_B10_3  action=${DELTA_COMMISSIONING}
    Wait until the next Measurement Period starts
    UE PDU Session Modify   ue_id=3  pdu=1  qos_flow_list=@{pdu1_qos_list_A_B10_3}  by=amf
    Verify the UE is not Configured with Carrier Aggregation  ue_id=1
    Start downlink Data Traffic in Egate on multiple Traffic IDs and QFIs   ue_id=3  trf_id_range_min=1  trf_id_range_max=4  start_qfi=2  end_qfi=3
    Collect and Verify PM Counters  test_instance=A_B10_3  dual_delta_commissioning=${DELTA_COMMISSIONING}
    Stop Data transfer for all Traffic IDs  ue_id=1  trf_id_start=1  trf_id_end=4
    UE Deregister  ue_id=3  ue_deregister_type=switch_off
