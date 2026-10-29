*** Settings ***

Documentation
...    author: VRF ULM T01
...    Team: 'MN RAN RD VRF ULM VT1'
...    Email: 'I_MN_RAN_RD_VRF_ULM_VT1@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB012656-C NR UL CA aware Idle mode steering with UL Tx Switching.
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

*** Test Cases ***

[1]CB012656-C_B01_Main_ET_NR_UL_CA_aware_IMM_steering_wo_mob_prof_with_DL_CA_IMM_steering_disabled_and_UL_Tx_Switching_enabled
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering without mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA IMM steering is disabled and UL Tx Switching is enabled. This test
    ...  instance covers CB012656-C#B01 Main Scenario.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56177  C_B1  C_B1_1
    #UE-30: GNB initiated RRC release from Cell-1 is triggered.
    Apply Configuration for Sub-Feature C User Scenario  algo=UL CA aware  mob_prof=false  test_instance=C_B1_1
    UE Register  ue_id=30  nwslice=1
    UE PDU Session Setup  ue_id=30  pdu=1  gw=30  nwslice=1
    Verify whether gNB includes Release 16 UL Tx Switching Request in UE Capability Enquiry
    Verify Measurement ID Is Configured  event_type=A3  ue_id=30  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=30  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=30  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=518910
    ...    steer_freq_3=127450  steer_freq_4=636576  dl_freq_1=531870  dl_freq_2=516990  sib-1_freq=655968  prio1=4  sub_prio1=4  prio2=1  prio4=0
    ...    sub_prio4=6
    UE Deregister  ue_id=30  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=GNB_Initiated_RRC_Conn_to_Idle

[1]CB012656-C_B01_Alt2_ET_NR_UL_CA_aware_IMM_steering_wo_mob_prof_with_DL_CA_IMM_steering_enabled_and_UL_Tx_Switching_enabled
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering without mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA IMM steering and UL Tx Switching are enabled. This test instance covers
    ...  CB012656-C#B01 Alterante Scenario#2.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56178  C_B1  C_B1_2
    #UE-31: GNB initiated RRC release from Cell-1 is triggered.
    Apply Configuration for Sub-Feature C User Scenario  algo=UL and DL CA aware  mob_prof=false  test_instance=C_B1_2
    UE Register  ue_id=31  nwslice=2
    UE PDU Session Setup  ue_id=31  pdu=1  gw=31  nwslice=2
    Verify whether gNB includes Release 16 UL Tx Switching Request in UE Capability Enquiry
    Verify Measurement ID Is Configured  event_type=A3  ue_id=31  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=31  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=31  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=518910
    ...    steer_freq_3=127450  steer_freq_4=636576  dl_freq_1=531870  dl_freq_2=516990  sib-1_freq=655968  prio1=6  sub_prio1=2  prio2=6  prio4=0
    ...    sub_prio4=6
    UE Deregister  ue_id=31  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=GNB_Initiated_RRC_Conn_to_Idle

[1]CB012656-C_B01_ET_Robustness_NR_UL_CA_aware_IMM_steering_wo_mob_prof_with_UL_Tx_Switching_enabled_no_overlap_with_ULCA
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering without mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA IMM steering is disabled and UL Tx Switching is enabled. This test
    ...  instance covers robustness case.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56173  C_B1  C_B1_3
    #UE-32 with Non overlaping band combination (n41A_n71A & n77A_n71A BC supports only UL Tx Switching, does not support DL/UL CA):
    #GNB initiated RRC release from Cell-1 is triggered.
    Apply Configuration for Sub-Feature C User Scenario  algo=UL CA aware  mob_prof=false  test_instance=C_B1_2
    UE Register  ue_id=32  nwslice=1
    UE PDU Session Setup  ue_id=32  pdu=1  gw=32  nwslice=1
    Verify whether gNB includes Release 16 UL Tx Switching Request in UE Capability Enquiry
    Verify Measurement ID Is Configured  event_type=A3  ue_id=32  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=32  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=32  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=392410  steer_freq_2=518910
    ...    steer_freq_3=127450  steer_freq_4=636576  dl_freq_1=531870  dl_freq_2=516990  sib-1_freq=655968  prio1=4  sub_prio1=4  prio2=1  prio4=0
    ...    sub_prio4=6
    UE Deregister  ue_id=32  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=GNB_Initiated_RRC_Conn_to_Idle

[1]CB012656-C_B02_Alt1_ET_NR_UL_CA_aware_IMM_steering_with_mob_prof_with_DL_CA_IMM_steering_disabled_and_UL_Tx_Switching_enabled
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering with mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA IMM steering is disabled and UL Tx Switching is enabled. This test
    ...  instance covers CB012656-C#B02 Alternate Scenario#1.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56176  C_B2  C_B2_1
    #UE-34: Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-6
    #AMF initiated RRC release from Cell-1 is triggered.
    Apply Configuration for Sub-Feature C User Scenario  algo=UL CA aware  mob_prof=true  test_instance=C_B2_1
    Update RFSP parameter in Initial Context Setup  ue_id=34  indexToRFSP=49
    UE Register  ue_id=34  nwslice=3
    UE PDU Session Setup  ue_id=34  pdu=1  gw=34  nwslice=3
    Verify whether gNB includes Release 16 UL Tx Switching Request in UE Capability Enquiry
    Verify Measurement ID Is Configured  event_type=A3  ue_id=34  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=34  carrier_freq=${SSBFREQUENCY}
    Trigger AMF Initiated RRC Release  ue_id=34
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=127450  steer_freq_2=392410
    ...    steer_freq_3=531870  dl_freq_1=518910  dl_freq_2=636576  dl_freq_3=516990  sib-1_freq=655968  prio1=5  sub_prio1=6  prio2=3  sub_prio2=8
    ...    prio3=1  prio4=0  sub_prio4=6
    Collect and Verify PM Counters  test_instance=C_B2_1

[1]CB012656-C_B02_Alt2_ET_NR_UL_CA_aware_IMM_steering_with_mob_prof_with_DL_CA_IMM_steering_enabled_and_UL_Tx_Switching_enabled
    [Documentation]
    ...  This user scenario describes the gNB behaviour for NR UL CA aware Idle mode mobility steering with mobility profile during RRC Connection
    ...  release with transition from RRC Connected to RRC Idle when DL CA IMM steering and UL Tx Switching are enabled. This test instance covers
    ...  CB012656-C#B02 Alternate Scenario#2.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_56175  C_B2  C_B2_2
    #UE-33: Expected Mobility Profile ID as per Configuration is MRBTS-1/NRBTS-1/NRMOPR_SA-6. dl_freq_3 below is also a SIB-1 Target as per the
    #configuration in this scenario. GNB initiated RRC release from Cell-1 is triggered.
    Apply Configuration for Sub-Feature C User Scenario  algo=UL and DL CA aware  mob_prof=true  test_instance=C_B2_2
    Update RFSP parameter in Initial Context Setup  ue_id=33  indexToRFSP=48
    UE Register  ue_id=33  nwslice=3
    UE PDU Session Setup  ue_id=33  pdu=1  gw=33  nwslice=3
    Verify whether gNB includes Release 16 UL Tx Switching Request in UE Capability Enquiry
    Verify Measurement ID Is Configured  event_type=A3  ue_id=33  carrier_freq=${SSBFREQUENCY}
    Verify Measurement ID Is Configured  event_type=A5  ue_id=33  carrier_freq=${SSBFREQUENCY}
    Verify whether gNB Triggers RRC Release  ue_id=33  timeout=21
    Verify RRC Release Contains cellReselectionPriorities IE with Expected Target Frequencies  steer_freq_1=127450  steer_freq_2=392410
    ...    steer_freq_3=531870  dl_freq_1=516990  dl_freq_2=655968  dl_freq_3=518910  sib-1_freq=636576  prio1=6  sub_prio1=4  prio2=6  sub_prio2=2
    ...    prio3=5  sub_prio3=6  prio4=3  sub_prio4=8
    UE Deregister  ue_id=33  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=GNB_Initiated_RRC_Conn_to_Idle
