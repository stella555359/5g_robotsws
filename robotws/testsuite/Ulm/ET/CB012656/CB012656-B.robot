*** Settings ***

Documentation
...    author: VRF ULM T01
...    Team: 'MN RAN RD VRF ULM VT1'
...    Email: 'I_MN_RAN_RD_VRF_ULM_VT1@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB012656-B NR UL CA aware Idle mode steering with mobility profile.
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

[1]CB012656-B_B02_Main_ET_NR_UL_CA_aware_IMM_steering_with_mob_profile_with_DL_CA_IMM_steering_is_enabled
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering with mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA IMM steering is also enabled (CB007516). This test instance covers
    ...  CB012656-B#B02 Main Scenario (gNB initiated RRC connection release procedure).
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56172  B_B2
    #UE-7: Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-6
    Apply Configuration for Sub-Feature B_B2  algo=UL and DL CA aware  mob_prof=true  test_instance=B_B2
    Update RFSP parameter in Initial Context Setup  ue_id=7  indexToRFSP=49
    UE Register  ue_id=7  nwslice=3
    UE PDU Session Setup  ue_id=7  pdu=1  gw=7  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=7  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=7  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=7  timeout=31
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=531870  steer_freq_2=127450
    ...    steer_freq_3=392410  dl_freq_1=516990  dl_freq_2=655968  dl_freq_3=518910  sib-1_freq=636576  prio3=5  sub_prio3=6  prio4=3  sub_prio4=8
    UE Deregister  ue_id=7  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=GNB_Initiated_RRC_Conn_to_Idle

[1]CB012656-B_B03_Alt1_ET_NR_UL_CA_aware_IMM_steering_with_mob_prof_during_RRC_Conn_to_RRC_Inact_Transition
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering with mobility profile during RRC Connected
    ...  to RRC Inactive transition. This test instance covers CB012656-B#B03 Alternate Scenario#1.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56171  B_B3
    #UE-8: Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-5
    Activate Mobility Profile and RRC Inactive State Transition  test_instance=B_B3
    Update AMF Parameter to Enable Core Network Assistance Info for RRC Inactive State  ue_id=8
    Update RFSP parameter in Initial Context Setup  ue_id=8  indexToRFSP=10
    UE Register  ue_id=8  nwslice=2
    Set traffic type  ue_id=8  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=8  pdu=1  gw=8  nwslice=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=8  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=8  carrier_freq=${SSBFREQUENCY}
    Start data traffic in egate  ue_id=8  direction=dl  mbps=50  pdu=1  qfi=1
    Sleep  10s  Reason=wait for data traffic to stabilize
    Trigger UE Assistance Info based RRC Connected to RRC Inactive Transition  ue_id=8
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=531850  steer_freq_2=518910
    ...    steer_freq_3=127450  dl_freq_1=531870  dl_freq_2=636576  dl_freq_3=392410  sib-1_freq=655968  prio1=4  sub_prio1=4  prio2=3  sub_prio2=8
    ...    prio3=3  prio4=0  sub_prio4=6
    Collect and Verify PM Counters  test_instance=RRC_Conn_to_Inactive

[1]CB012656-B_B04_Main_ET_NR_UL_CA_aware_IMM_steering_from_NR_SA_to_LTE_EN-DC_carrier_with_mob_prof-_Fallback_to_CB012656
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering from NR SA to LTE EN-DC carrier with
    ...  mobility profile and fallback to CB012656. This test instance covers CB012656-B#B04 Main Scenario. CB007516 is not activated.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56169  B_B4  B_B4_1
    #UE-3: Send A4 MR when UE gets configured with A4 measurement event
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-4
    Activate Mobility Profile and ENDC Steering  test_instance=B_B4_1
    Update RFSP parameter in Initial Context Setup  ue_id=3  indexToRFSP=56
    UE Register  ue_id=3  nwslice=3
    UE PDU Session Setup  ue_id=3  pdu=1  gw=3  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=3  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=3  carrier_freq=${FR2_SSBFREQUENCY}
    Send A4 Measurement Report and Verify whether gNB Triggers RRC Release with High Prio LTE Frequency  ue_id=3  meas_id=4
    UE Deregister  ue_id=3  ue_deregister_type=switch_off
    #UE-11: GNB initiated RRC Release will be triggered when a4ReportTimerEnDc is expired
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-4
    Update RFSP parameter in Initial Context Setup  ue_id=11  indexToRFSP=85
    UE Register  ue_id=11  nwslice=3
    UE PDU Session Setup  ue_id=11  pdu=1  gw=11  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=11  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=11  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=11  carrier_freq=${FR2_SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=11
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=127450  steer_freq_2=655968
    ...    steer_freq_3=392410  dl_freq_1=518910  dl_freq_2=531870  dl_freq_3=431090  sib-1_freq=516990  prio1=5  sub_prio1=6  prio2=4  sub_prio2=4
    ...    prio3=3  sub_prio3=8  prio4=1  sub_prio4=2  freq_5=636576  prio5=0
    UE Deregister  ue_id=11  ue_deregister_type=switch_off
    #UE-9: AMF initiated RRC Release will be triggered when UE is configured with A4 meas event (a4ReportTimerEnDc is running)
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-7
    Update RFSP parameter in Initial Context Setup  ue_id=9  indexToRFSP=100
    UE Register  ue_id=9  nwslice=2
    UE PDU Session Setup  ue_id=9  pdu=1  gw=9  nwslice=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=9  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=9  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=9  carrier_freq=${FR2_SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=9  timeout=6
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=655968
    ...    steer_freq_3=431090  dl_freq_1=518910  dl_freq_2=127450  dl_freq_3=531870  sib-1_freq=516990  prio1=5  sub_prio1=6  prio2=5  sub_prio2=2
    ...    prio3=4  sub_prio3=4  prio4=1  sub_prio4=2  freq_5=636576  prio5=0
    #UE-95: GNB initiated RRC Release will be triggered (GNB doesn't configure A4 meas to this UE since UE does not support configured MRDC capa)
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-2 (Mob Prof Config: PLMN-1, Slice-1)
    UE Register  ue_id=95
    UE PDU Session Setup  ue_id=95  pdu=1  gw=95
    Verify Measurement ID Is Configured  event_type=A3  ue_id=95  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=95  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=95  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=516990  steer_freq_2=518910
    ...    steer_freq_3=392410  dl_freq_1=127450  dl_freq_2=531870  dl_freq_3=431090  sib-1_freq=655968  prio1=5  sub_prio1=2  prio2=4  sub_prio2=4
    ...    prio3=3  sub_prio3=8  prio4=0  sub_prio4=6  freq_5=636576  prio5=0
    UE Deregister  ue_id=95  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=NR_SA_to_LTE_ENDC

[1]CB012656-B_B04_Alt1_ET_NR_UL_CA_aware_IMM_steering_from_NR_SA_to_LTE_EN-DC_carrier_with_mob_prof-_Fallback_to_CB012656
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering from NR SA to LTE EN-DC carrier with
    ...  mobility profile and fallback to CB012656. This test instance covers CB012656-B#B04 Alternate Scenario#1. CB007516 is activated and
    ...  configured as per user scenario CB007516-B#B1
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56170  B_B4  B_B4_2
    #UE-12: Send A4 MR when UE gets configured with A4 measurement event
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-4
    Activate Mobility Profile and ENDC Steering  test_instance=B_B4_2
    Update RFSP parameter in Initial Context Setup  ue_id=12  indexToRFSP=71
    UE Register  ue_id=12  nwslice=3
    UE PDU Session Setup  ue_id=12  pdu=1  gw=12  nwslice=3
    Verify Measurement ID Is Configured  event_type=A3  ue_id=12  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=12  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=12  carrier_freq=${FR2_SSBFREQUENCY}
    Send A4 Measurement Report and Verify whether gNB Triggers RRC Release with High Prio LTE Frequency  ue_id=12  meas_id=4
    UE Deregister  ue_id=12  ue_deregister_type=switch_off
    #UE-13: GNB initiated RRC Release will be triggered when a4ReportTimerEnDc is expired
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-3
    Update RFSP parameter in Initial Context Setup  ue_id=13  indexToRFSP=25
    UE Register  ue_id=13  nwslice=2
    UE PDU Session Setup  ue_id=13  pdu=1  gw=13  nwslice=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=13  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=13  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=13  carrier_freq=${FR2_SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=13
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=431090  steer_freq_2=518910
    ...    steer_freq_3=392410  dl_freq_1=531870  dl_freq_2=127450  dl_freq_3=516990  sib-1_freq=655968  prio4=0  sub_prio4=6  freq_5=636576  prio5=0
    UE Deregister  ue_id=13  ue_deregister_type=switch_off
    #UE-14: AMF initiated RRC Release will be triggered when UE is configured with A4 meas event (a4ReportTimerEnDc is running)
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-3
    Update RFSP parameter in Initial Context Setup  ue_id=14  indexToRFSP=30
    UE Register  ue_id=14  nwslice=2
    UE PDU Session Setup  ue_id=14  pdu=1  gw=14  nwslice=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=14  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=14  carrier_freq=${SSBFREQUENCY}
    Sleep  21s  Reason=wait for UE Inactivity Timer to get expired
    Verify Measurement ID Is Configured  event_type=A4  ue_id=14  carrier_freq=${FR2_SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=14  timeout=6
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=518910  steer_freq_2=392410
    ...    steer_freq_3=431090  dl_freq_1=531870  dl_freq_2=127450  dl_freq_3=516990  sib-1_freq=655968  prio4=0  sub_prio4=6  freq_5=636576  prio5=0
    #UE-96: GNB initiated RRC Release will be triggered (GNB doesn't configure A4 meas to this UE since UE does not support configured MRDC capa)
    #Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-8 (This default Mobility Profile is taken since the criteria
    #RFSP/Slice/PLMN does not match for the configured profiles for this UE)
    Update RFSP parameter in Initial Context Setup  ue_id=96  indexToRFSP=100
    UE Register  ue_id=96  nwslice=2
    UE PDU Session Setup  ue_id=96  pdu=1  gw=96  nwslice=2
    Verify Measurement ID Is Configured  event_type=A3  ue_id=96  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=96  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=96  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=127450  steer_freq_2=431090
    ...    steer_freq_3=655968  dl_freq_1=531870  dl_freq_2=516990  dl_freq_3=392410  sib-1_freq=518910  prio4=5  sub_prio4=6  freq_5=636576  prio5=0
    UE Deregister  ue_id=96  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=NR_SA_to_LTE_ENDC
