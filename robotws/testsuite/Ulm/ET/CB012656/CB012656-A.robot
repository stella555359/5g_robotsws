*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM VT1'
...    Email: 'I_MN_RAN_RD_VRF_ULM_VT1@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB012656-A NR UL CA aware Idle mode steering without mobility profile.
...    Tested on: CLOUD_5G_I_MP_AP_LO   STATE_CONFIGURED
...    Variant: SANSA_FS_ECPRI_CMWV_TDD

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        CB012656_Keywords.robot
Resource                        CB012656_Commissioning.robot
Resource                        CB012656_PM.robot

Suite Setup                     Prepare TL for CB012656
Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions of Test Scenario
Test Teardown                   Perform Postconditions of Test Scenario

*** Variables ***

${TEST_MODE}                    auto
${SSBFREQUENCY}                 636576
${FR2_SSBFREQUENCY}             2079167

*** Test Cases ***

[1]CB012656-A_B02_Main_ET_NR_UL_CA_aware_IMM_steering_wo_mob_prof_with_DL_CA_aware_IMM_steering_is_enabled
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering without mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA aware IMM steering is also enabled (CB007516). This test instance covers
    ...  CB012656-A#B02 Main Scenario (gNB initiated RRC connection release procedure). UE-3 performs Intra frequency HO from Cell-2 to Cell-1 and
    ...  then AMF initiated RRC release from Cell-1 is triggered.
    ...  UE-99 is newly added to include the PR789735 in CDRT scope.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_50730  A_B2  A_B2_1
    Modify Idle mode mobility steering algorithm and Inactivity Timer Value  algo=UL and DL CA aware  test_instance=A_B2_1
    pmcounters.Wait Until The Next Measurement Period Starts
    UE Register  ue_id=3
    UE PDU Session Setup  ue_id=3  pdu=1  gw=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Send NR Measurement Report  ue_id=3  event=A3  meas_values=srsrp_nr=60 srsrq_nr=55 phycell_id=50 nrsrp_nr=75 nrsrq_nr=70
    ...   carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A3  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=3  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=655968  steer_freq_2=392410
    ...    steer_freq_3=636576  dl_freq_1=531870  dl_freq_2=516990  dl_freq_3=127450  sib-1_freq=518910
    UE Deregister  ue_id=3  ue_deregister_type=switch_off
    Move idle or detached UE to another cell  ue_id=3  gnb=2  cell=2
    Apply Delta Configuration for PR789735 Verification  test_instance=PR789735
    UE Register  ue_id=99
    UE PDU Session Setup  ue_id=99  pdu=1  gw=99
    Verify Measurement ID Is Configured  event_type=A3  ue_id=99  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=99  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=99  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=655968  steer_freq_2=392410
    ...    steer_freq_3=636576  dl_freq_1=531870  dl_freq_2=516990  sib-1_freq=518910
    UE Deregister  ue_id=99  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=A_B2_1

[1]CB012656-A_B02_ET_Expl_NR_UL_CA_aware_IMM_steering_wo_mob_prof_with_Different_spCellPlacement_IE
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering without mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA aware IMM steering is also enabled (CB007516). This test instance covers
    ...  Robustaness scenario based on CB012656-A#B02. UE-4 performs Inter gNB HO from simulated gNB to real gNB Cell-1 and then AMF initiated RRC
    ...  release from Real gNB Cell-1 is triggered. UE-5 performs intra freq HO from real gNB Cell-2 to real gNB Cell-1 and then AMF initiated RRC
    ...  release is triggered. UE-6 is registered on real gNB Cell-1 and AMF initiated RRC release is triggered.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_52322  A_B2  A_B2_2
    Apply Configuration for Sub-Feature A_B2  algo=UL and DL CA aware  test_instance=A_B2_2
    #UE-4: spCellPlacement is included AND spCellPlacement.fr1fdd-FR1TDD-CA-SpCellOnFR1FDD is present (supported)
    UE Register  ue_id=4
    UE PDU Session Setup  ue_id=4  pdu=1  gw=4  pass_regexp=Pdu Session Resource Setup Response Message with RAN UE NGAP ID 2 handled successfully
    Verify Measurement ID Is Configured  event_type=A5  ue_id=4  carrier_freq=${SSBFREQUENCY}
    Send NR Measurement Report  ue_id=4  event=A5  meas_values=srsrp_nr=19 phycell_id=50 nrsrp_nr=100  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A3  ue_id=4  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=4  carrier_freq=${SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=4
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=636576  steer_freq_2=392410
    ...    steer_freq_3=127450  dl_freq_1=531870  dl_freq_2=516990  dl_freq_3=655968  sib-1_freq=518910
    Move idle or detached UE to another cell  ue_id=4  gnb=3  cell=1
    #UE-5: spCellPlacement is included AND spCellPlacement.fr1fdd-FR1TDD-CA-SpCellOnFR1TDD is present (supported)
    UE Register  ue_id=5
    UE PDU Session Setup  ue_id=5  pdu=1  gw=6
    Verify Measurement ID Is Configured  event_type=A3  ue_id=5  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=5  carrier_freq=${SSBFREQUENCY}
    Send NR Measurement Report  ue_id=5  event=A3  meas_values=srsrp_nr=60 srsrq_nr=55 phycell_id=50 nrsrp_nr=75 nrsrq_nr=70
    ...   carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A3  ue_id=5  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=5  carrier_freq=${SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=5
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=655968  steer_freq_2=127450
    ...    steer_freq_3=636576  dl_freq_1=392410  dl_freq_2=531870  dl_freq_3=516990  sib-1_freq=518910
    Move idle or detached UE to another cell  ue_id=5  gnb=2  cell=2
    #UE-6: spCellPlacement is included AND spCellPlacement.fr1fdd-FR1TDD-CA-SpCellOnFR1FDD & fr1fdd-FR1TDD-CA-SpCellOnFR1TDD are present (supported)
    UE Register  ue_id=6
    UE PDU Session Setup  ue_id=6  pdu=1  gw=6
    Verify Measurement ID Is Configured  event_type=A3  ue_id=6  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=6  carrier_freq=${SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=6
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=655968
    ...    steer_freq_3=636576  steer_freq_4=127450  dl_freq_1=531870  dl_freq_2=516990  sib-1_freq=518910  sub_prio1=2
    Collect and Verify PM Counters  test_instance=A_B2_2

[1]CB012656-A_B03_Alt1_ET_NR_UL_CA_aware_IMM_steering_wo_mob_prof_during_RRC_Conn_to_RRC_Inact_Transition
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering without mobility profile during RRC Connected
    ...  to RRC Inactive transition. This test instance covers CB012656-A#B03 Alternat Scenario#1: UE Assistance information based successful
    ...  transition from RRC_Connected state to RRC_Inactive state. DL CA aware IMM steering is disabled (CB007516).
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_52323  A_B3
    Apply Delta Config to Enable RRC Inactive State Transition and Modify NRIRFIM Params  test_instance=A_B3
    Update AMF Parameter to Enable Core Network Assistance Info for RRC Inactive State  ue_id=2
    UE Register  ue_id=2
    Set traffic type  ue_id=2  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=2  pdu=1  gw=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=2  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=2  carrier_freq=${SSBFREQUENCY}
    Start data traffic in egate  ue_id=2  direction=dl  mbps=20  pdu=1  qfi=1
    Sleep  10s  Reason=wait for data traffic to stabilize
    Trigger UE Assistance Info based RRC Connected to RRC Inactive Transition  ue_id=2
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=655968  steer_freq_2=392410
    ...    steer_freq_3=431090  dl_freq_1=518910  dl_freq_2=127450  dl_freq_3=531870  sib-1_freq=516990  prio1=5  sub_prio1=6  prio2=5  sub_prio2=2
    ...    prio3=4  sub_prio3=4  prio4=1  sub_prio4=2
    Collect and Verify PM Counters  test_instance=RRC_Conn_to_Inactive

[1]CB012656-A_B04_Alt1_ET_NR_UL_CA_aware_IMM_steering_from_NR_SA_to_LTE_EN-DC_carrier_wo_mob_prof-_Fallback_to_CB012656
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering from NR SA to LTE EN-DC carrier without
    ...  mobility profile and fallback to CB012656. This test instance covers CB012656-A#B04 Alternat Scenario#1.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_52324  A_B4
    Apply Delta Config to Enable Steering from NR SA to ENDC  test_instance=A_B4
    #UE-3: Intra-gNB intra frequency HO from Cell-2 to Cell-1 and then send A4 MR when UE gets configured with A4 measurement event
    UE Register  ue_id=3
    UE PDU Session Setup  ue_id=3  pdu=1  gw=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Send NR Measurement Report  ue_id=3  event=A3  meas_values=srsrp_nr=60 srsrq_nr=55 phycell_id=50 nrsrp_nr=75 nrsrq_nr=70
    ...   carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A3  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=3  carrier_freq=${FR2_SSBFREQUENCY}
    Send A4 Measurement Report and Verify whether gNB Triggers RRC Release with High Prio LTE Frequency  ue_id=3
    UE Deregister  ue_id=3  ue_deregister_type=switch_off
    Move idle or detached UE to another cell  ue_id=3  gnb=2  cell=2
    #UE-8: GNB initiated RRC Release will be triggered when a4ReportTimerEnDc is expired
    UE Register  ue_id=8  nwslice=3
    UE PDU Session Setup  ue_id=8  pdu=1  gw=8  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=8  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=8  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=8  carrier_freq=${FR2_SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=8
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=655968  steer_freq_2=392410
    ...    steer_freq_3=431090  dl_freq_1=518910  dl_freq_2=127450  dl_freq_3=531870  sib-1_freq=516990  prio1=5  sub_prio1=6  prio2=5  sub_prio2=2
    ...    prio3=4  sub_prio3=4  prio4=1  sub_prio4=2
    UE Deregister  ue_id=8  ue_deregister_type=switch_off
    #UE-9: AMF initiated RRC Release will be triggered when UE is configured with A4 meas event (a4ReportTimerEnDc is running)
    UE Register  ue_id=9  nwslice=2
    UE PDU Session Setup  ue_id=9  pdu=1  gw=9  nwslice=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=9  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=9  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=9  carrier_freq=${FR2_SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=9  timeout=6
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=655968
    ...    steer_freq_3=431090  dl_freq_1=518910  dl_freq_2=127450  dl_freq_3=531870  sib-1_freq=516990  prio1=5  sub_prio1=6  prio2=5  sub_prio2=2
    ...    prio3=4  sub_prio3=4  prio4=1  sub_prio4=2
    #UE-10: GNB initiated RRC Release will be triggered (GNB doesn't configure A4 meas to this UE since UE does not support configured MRDC capa)
    UE Register  ue_id=10
    UE PDU Session Setup  ue_id=10  pdu=1  gw=10
    Verify Measurement ID Is Configured  event_type=A3  ue_id=10  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=10  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=10  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=431090  steer_freq_2=392410
    ...    steer_freq_3=655968  dl_freq_1=518910  dl_freq_2=127450  dl_freq_3=531870  sib-1_freq=516990  prio1=5  sub_prio1=6  prio2=5  sub_prio2=2
    ...    prio3=4  sub_prio3=4  prio4=1  sub_prio4=2
    UE Deregister  ue_id=10  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=NR_SA_to_LTE_ENDC
