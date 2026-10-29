*** Settings ***

Documentation
...    author: VRF ULM T01
...    Team: 'MN RAN RD VRF ULM VT1'
...    Email: 'I_MN_RAN_RD_VRF_ULM_VT1@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB012656-D Weighted round robin for secondary target frequency priority assignment in
...    NR CA aware IDLE mode steering (CB007516).
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

[1]CB012656-D_B01_Alt4_ET_DL_CA_aware_IMM_steering_with_WRR_CA_aware_algo_based_prio_assignment_for_sec_target_freq_wo_mob_prof
    [Documentation]
    ...  This user scenario describes the gNB behaviour during WRR based priority assignment for secondary target frequency in DL CA aware Idle mode
    ...  mobility steering during RRC Connection release(RRC Connected to RRC Idle) without mobility profile enabled.. This test instance covers
    ...  CB012656-D#B01 Alternate Scenario#4. Configuration for DB01 is: actUlCaAwareIMMSteering=true(CB012656), idleMMSteeringAlgo=CA aware &
    ...  idleMMSteeringWRREnabledSec=UL and DL CA aware. CB008696 is also enabled, however UE does not send A4 MR, hence CB07516 will be triggered
    ...  and secondary DL targets (which are eligible for primary, but not selected by idleMMSteeringAlgo) will also be based on WRR algorithm.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_13711  D_B1
    #UE-8: GNB initiated RRC release from Cell-1 is triggered.
    #There are 3 eligible candidates for primary as per the SCF configuration, in that and one of them get priority 7, remaining 2 frequencies get
    #priority 6.8, and 6.6 based on WRR algorithm. Here dl_fre_xx (in line number 54) are also SIB-1 targets.
    Apply Configuration for Sub-Feature D_B01 CB007516 User Scenario  algo=CA aware  WRR_Sec=UL and DL CA aware  EnDcSteer=true  test_instance=D_B1
    UE Register  ue_id=8  nwslice=3
    UE PDU Session Setup  ue_id=8  pdu=1  gw=8  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=8  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=8  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=8  carrier_freq=${FR2_SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=8
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=531870
    ...    steer_freq_3=127450  dl_freq_1=518910  dl_freq_2=636576  dl_freq_3=516990  sib-1_freq=655968  prio1=5  sub_prio1=6  prio2=3  sub_prio2=8
    ...    prio3=1  prio4=0  sub_prio4=6
    UE Deregister  ue_id=8  ue_deregister_type=switch_off
    #UE-9: GNB initiated RRC release from Cell-1 is triggered. idleMMNrCelResWeight is not configured in any of the NR targets in NRIRFIM and
    #idleMMEutraCelResWeight is configured only for EUTRA Traget 300 in NRLIM, hence gNB steers the UE to LTE ARFCN 300 with high priority 7 and
    #NRRCC_RRC_RELEASE_IMM_LTE gets pegged.
    Apply Configuration for Sub-Feature D_B01 to get UE Steered to LTE Frequency
    UE Register  ue_id=9  nwslice=2
    UE PDU Session Setup  ue_id=9  pdu=1  gw=9  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=9  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=9  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=9  carrier_freq=${FR2_SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=9
    Verify RRC Release Contains cellReselectionPriorities IE with High Priority for LTE Target
    UE Deregister  ue_id=9  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=D_B1

[1]CB012656-D_B02_Main_ET_DL_CA_aware_IMM_steering_with_WRR_CA_aware_algo_based_prio_assignment_for_sec_target_freq_with_mob_prof
    [Documentation]
    ...  This user scenario describes the gNB behaviour during WRR based priority assignment for secondary target frequency in DL CA aware Idle mode
    ...  mobility steering during RRC Connection release(RRC Connected to RRC Idle) with mobility profile enabled. This test instance covers
    ...  CB012656-D#B02 Main Scenario.  Configuration for DB01 is: actUlCaAwareIMMSteering=false(CB012656), idleMMSteeringAlgo=CA aware &
    ...  idleMMSteeringWRREnabledSec=DL CA aware. CB07516 will be triggered and secondary DL targets (which are eligible for primary, but not
    ...  selected by idleMMSteeringAlgo) will also be based on WRR algorithm.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_13712  D_B2
    #UE-7: Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-6
    #There are 4 eligible candidates for primary as per the SCF configuration, in that and one of them get priority 7, remaining 3 frequencies get
    #priority 6.8, 6.6, and 6.4 based on WRR algorithm. Here dl_fre_xx (in line number 92) are also SIB-1 targets.
    Apply Configuration for Sub-Feature D_B02 CB007516 User Scenario  UlCaAware=false  algo=CA aware  WRR_Sec=DL CA aware  mob_prof=true
    ...    test_instance=D_B2
    Update RFSP parameter in Initial Context Setup  ue_id=7  indexToRFSP=49
    UE Register  ue_id=7  nwslice=3
    UE PDU Session Setup  ue_id=7  pdu=1  gw=7  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=7  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=7  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=7  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=127450  steer_freq_2=516990
    ...    steer_freq_3=392410  steer_freq_4=655968  dl_freq_1=518910  dl_freq_2=531870  sib-1_freq=636576  prio1=5  sub_prio1=6  prio2=4  prio4=3
    ...    sub_prio4=8
    UE Deregister  ue_id=7  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=D_B2
