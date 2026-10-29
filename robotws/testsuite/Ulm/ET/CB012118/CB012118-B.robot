*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'I_MN_RAN_RD_VRF_ULM_SQD_65@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB012118-B: Voice fallback to LTE - B1 measurement based redirection using Measurment
...    and mobility profiles.
...    Tested on: CLOUD_5G_I_LO_AP_LO   STATE_CONFIGURED
...    Variant Tag: VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ./CB012118_Keywords.robot

Suite Setup                     Prepare TL for CB012118-B and -G
Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions of Test Scenario
Test Teardown                   Perform Postconditions of Test Case

*** Variables ***

${TEST_MODE}                    auto

${NRCELL-1.nrarfcn_gscn}        636576

*** Test Cases ***

[1]CB012118-B_B1a_Successful_config_of_B1_meas_using_meas_profile_on_reception_of_NGAP-PDUSessionSetupRequest_for_PDU_Session_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using measurement profile on reception of subsequent PDU session
    ...  for 5QI-1, here measurement profile selection is based on UE power class and the test procedure is based on User Scenario CB012118-A#B3 main
    ...  scenario. UE-1 that supports power class 2 for NR frequency band 78 is used for this test instance and it register to network slice 1.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26733  B_B1  B_B1a  B_B1a_1
    UE Register  ue_id=1
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=3000  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=12  hyst_1=2  time_to_trig_1=ms128
    ...     earfcn_2=2000  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=28  hyst_2=0  time_to_trig_2=ms100
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=1350
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=B_A_B3

[2]CB012118-B_B1a_Successful_config_of_B1_meas_using_meas_profile_on_reception_of_NGAP-PDUSessionSetupRequest_for_PDU_Session_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using measurement profile on reception of subsequent PDU session
    ...  for 5QI-1, here measurement profile selection is based on PLMN, NSSAI (slice), RFSP and the test procedure is based on User Scenario
    ...  CB012118-A#B3 main scenario. UE-2 that supports power class 3 for NR frequency band 78 is used for this test instance and it register to
    ...  network slice 2.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26734  B_B1  B_B1a  B_B1a_2
    Update AMF Initial Context Setup RFSP parameter  ue_id=2  indexToRFSP=5
    UE Register  ue_id=2  nwslice=2
    Modifying default QOS flow  ue_id=2  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=2  pdu=1  gw=1  nwslice=2
    Verify Measurement ID Is Configured  event_type=A2  ue_id=2  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=2  qos_flow=3
    UE PDU Session Setup  ue_id=2  pdu=2  gw=2  nwslice=2  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=2  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=3000  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=17  hyst_1=6  time_to_trig_1=ms256
    ...     earfcn_2=2000  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=33  hyst_2=4  time_to_trig_2=ms160
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=1350
    UE Deregister  ue_id=2  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=2  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B3

[1]CB012118-B_B1b_Successful_config_of_B1_meas_using_meas_profile_on_reception_of_NGAP-PDUSessionSetupRequest_for_PDU_Session_having_5QI-1
    [Documentation]
    ...  This user scenario describes if no measurement profile mapping is available for the UE (no criterion matching) or no measurement profile
    ...  (NRBTS/NRMEASPR_MA_SA.nrMeasPrIrfDN is not set) exists in the measurement profile mapping selected for the UE, then legacy configuration
    ...  from NRHOIR is used for Inter-RAT measurements B1 values. The test procedure is based on User Scenario CB012118-A#B3 main scenario. UE-2
    ...  that supports power class 3 for NR frequency band 78 is used for this test instance and it register to network slice 1.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26735  B_B1  B_B1b  B_B1b_1
    UE Register  ue_id=2
    Modifying default QOS flow  ue_id=2  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=2  pdu=1  gw=1
    Verify Measurement ID Is Configured  event_type=A2  ue_id=2  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=2  qos_flow=3
    UE PDU Session Setup  ue_id=2  pdu=2  gw=2  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=2  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=3000  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=27  hyst_1=14  time_to_trig_1=ms640
    ...     earfcn_2=2000  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=38  hyst_2=8  time_to_trig_2=ms320
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=1350
    UE Deregister  ue_id=2  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=B_A_B3

[1]CB012118-B_B1f_Successful_config_of_B1_meas_using_meas_profile_on_reception_of_NGAP-PDUSessionSetupRequest_for_PDU_Session_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement on reception of NGAP: UEContextModificationRequest for Emergency
    ...  Fallback. The test procedure is based on User Scenario CB012118-A#B6, and the measurement profile selection is based on UE power class. UE-1
    ...  that supports power class 2 for NR frequency band 78 is used for this test instance and it register to network slice 1.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26736  B_B1  B_B1f  B_B1f_1
    UE Register  ue_id=1
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Sleep  30s  Reason=wait for rrcReconfigurationComplete from the UE before verifying A2 meas config
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Trigger UE Context Modification procedure with Emergency Fallback Indicator IE  ue_id=1  emergency_fb=on
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=3000  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=12  hyst_1=2  time_to_trig_1=ms128
    ...     earfcn_2=2000  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=28  hyst_2=0  time_to_trig_2=ms100
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=1350
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=B_A_B6

[1]CB012118-B_B2_Successful_config_of_B1_meas_using_mobProfile_on_reception_of_NGAP_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using mobility profile on reception of subsequent PDU session
    ...  (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1. This test instance covers
    ...  CB012118-B#B2 main Scenario. The test procedure is based on User Scenario CB012118-A#B3 main scenario, and mobility profile for the UE
    ...  based on selected PLMN, the slice (S-NSSAI) and IndexToRFSP IE.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26727  B_B2  B_B2_1
    Activate Mobility Profile  test_instance=B_B2_1
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=100
    UE Register  ue_id=1
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Sleep  30s  Reason=wait for rrcReconfigurationComplete from the UE before verifying A2 meas config
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=900  wideband_meas_1=TRUE  b1MeasRedir_1=rsrp  b1Threshold_1=53  hyst_1=20  time_to_trig_1=ms2560
    ...     earfcn_2=300  wideband_meas_2=FALSE  b1MeasRedir_2=rsrq  b1Threshold_2=32  hyst_2=18  time_to_trig_2=ms1280
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=6300
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B3

[2]CB012118-B_B2_Successful_config_of_B1_meas_using_mobProfile_on_reception_of_NGAP_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using mobility profile on reception of subsequent PDU session
    ...  (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1. This test instance covers
    ...  CB012118-B#B2 Alternate Scenraio #1. The test procedure is based on User Scenario CB012118-A#B3 main scenario, and default mobility profile
    ...  is used since none of the configured Mobility profiles matching the PLMN and/or Slice allocated to the UE and/or RFSP.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26728  B_B2  B_B2_2
    Activate Mobility Profile  test_instance=B_B2
    UE Register  ue_id=1  nwslice=2
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1  nwslice=2
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  nwslice=2  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=900  wideband_meas_1=TRUE  b1MeasRedir_1=rsrp  b1Threshold_1=53  hyst_1=20  time_to_trig_1=ms2560
    ...     earfcn_2=3000  wideband_meas_2=FALSE  b1MeasRedir_2=rsrp  b1Threshold_2=43  hyst_2=12  time_to_trig_2=ms512
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=3625
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Collect and Verify PM Counters  test_instance=B_A_B3

[3]CB012118-B_B2_Successful_config_of_B1_meas_using_mobProfile_on_reception_of_NGAP_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using mobility profile on reception of subsequent PDU session
    ...  (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1. This test instance covers
    ...  CB012118-B#B2 Alternate Scenraio #2. The test procedure is based on User Scenario CB012118-A#B3 main scenario, and voiceFBMode is disabled
    ...  in the mobility profile. Hence, UE is not configured with B1 measurements for redirection and redirection release is not triggered
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26729  B_B2  B_B2_3
    Activate Mobility Profile  test_instance=B_B2
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=100
    UE Register  ue_id=1  nwslice=2
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1  nwslice=2
    Sleep  30s  Reason=wait for rrcReconfigurationComplete from the UE before verifying A2 meas config
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=2 gw=2   fail_regexp=rrcReconfigurationComplete
    Verify gNB neither Configures B1 Event nor Triggers RRC Release with Redirected Eutra Carrier Info for UE
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_B2_3

[4]CB012118-B_B2_Successful_config_of_B1_meas_using_mobProfile_on_reception_of_NGAP_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using mobility profile on reception of subsequent PDU session
    ...  (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1. This test instance covers
    ...  CB012118-B#B2 Alternate Scenraio #3. The test procedure is based on User Scenario CB012118-A#B3 main scenario. Here, Redirection is not
    ...  based on mobility profile but based on NRHOIR, since voiceFBMode is not configured in the selected mobility profile.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26730  B_B2  B_B2_4
    Activate Mobility Profile  test_instance=B_B2_4
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=100
    UE Register  ue_id=1  nwslice=3
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1  nwslice=3
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  nwslice=3  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=3000  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=27  hyst_1=14  time_to_trig_1=ms640
    ...     earfcn_2=2000  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=38  hyst_2=8  time_to_trig_2=ms320  test_instance=B_B2_4
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=1350
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B3

[5]CB012118-B_B2_Successful_config_of_B1_meas_using_mobProfile_on_reception_of_NGAP_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using mobility profile on reception of subsequent PDU session
    ...  (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1. This test instance covers
    ...  CB012118-B#B2 Alternate Scenraio #5. The test procedure is based on User Scenario CB012118-A#B3 main scenario. Here, Redirection is not
    ...  based on mobility profile but based on NRHOIR, since b1RedirectList is not configured in mobility profile, but configured in NRCELL.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26731  B_B2  B_B2_5
    Activate Mobility Profile  test_instance=B_B2
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=5
    UE Register  ue_id=1  nwslice=3
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1  nwslice=3
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  nwslice=3  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=3000  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=27  hyst_1=14  time_to_trig_1=ms640
    ...     earfcn_2=2000  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=38  hyst_2=8  time_to_trig_2=ms320  test_instance=B_B2_5
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=3625
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B3

[6]CB012118-B_B2_Successful_config_of_B1_meas_using_mobProfile_on_reception_of_NGAP_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using mobility profile on reception of subsequent PDU session
    ...  (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1. This test instance covers
    ...  CB012118-B#B2 Alternate Scenraio #4. The test procedure is based on User Scenario CB012118-A#B6, and mobility profile for the UE based on
    ...  selected PLMN, the slice (S-NSSAI) and IndexToRFSP IE.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26732  B_B2  B_B2_6
    Activate Mobility Profile  test_instance=B_B2
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=100
    UE Register  ue_id=1
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Trigger UE Context Modification procedure with Emergency Fallback Indicator IE  ue_id=1  emergency_fb=on
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=300  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=32  hyst_1=18  time_to_trig_1=ms1280
    ...     earfcn_2=900  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=53  hyst_2=20  time_to_trig_2=ms2560
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=3625
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B6

[1]CB012118-B_B3_Successful_config_of_B1_meas_using_meas_and_mob_profile_on_reception_of_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using measurement and mobility profile on reception of
    ...  subsequent PDU session (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1
    ...  This test instance covers CB012118-B#B3 Main Scenraio. The test procedure is based on User Scenario CB012118-A#B3 main scenario.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_299016  B_B3  B_B3_1
    Activate Mobility Profile  test_instance=B_B3
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=100
    UE Register  ue_id=1
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Sleep  30s  Reason=wait for rrcReconfigurationComplete from the UE before verifying A2 meas config
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Modifying default QOS flow  ue_id=1  qos_flow=3
    UE PDU Session Setup  ue_id=1  pdu=2  gw=2  pass_regexp=rrcReconfigurationComplete
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=300  wideband_meas_1=FALSE  b1MeasRedir_1=rsrq  b1Threshold_1=12  hyst_1=2  time_to_trig_1=ms128
    ...     earfcn_2=900  wideband_meas_2=TRUE  b1MeasRedir_2=rsrp  b1Threshold_2=28  hyst_2=0  time_to_trig_2=ms100
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=3625
    UE Deregister  ue_id=1  ue_deregister_type=switch_off
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B3

[2]CB012118-B_B3_Successful_config_of_B1_meas_using_meas_and_mob_profile_on_reception_of_PDUSessionSetupReq_for_subsequent_PDUSession_having_5QI-1
    [Documentation]
    ...  This user scenario describes the successful configuration of B1 measurement using measurement and mobility profile on reception of
    ...  subsequent PDU session (at least one PDU Session has been already established for the UE) via NGAP:PDUSessionSetupRequest for 5QI-1
    ...  This test instance covers CB012118-B#B3 Alternate Scenraio#1. The test procedure is based on User Scenario CB012118-A#B6.
    [Tags]    QCD_MN_RAN  QCP_RAN_VRF  QC_26726  B_B3  B_B3_2
    Activate Mobility Profile  test_instance=B_B3_1
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=100
    UE Register  ue_id=1
    Modifying default QOS flow  ue_id=1  qos_flow=2
    Add Additional QOS Flows to Activate  id=1  additional_qosflows=1
    UE PDU Session Setup  ue_id=1  pdu=1  gw=1
    Sleep  30s  Reason=wait for rrcReconfigurationComplete from the UE before verifying A2 meas config
    Verify Measurement ID Is Configured  event_type=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Smf Param Reset
    Trigger UE Context Modification procedure with Emergency Fallback Indicator IE  ue_id=1  emergency_fb=on
    Verify Measurement ID is absent  event=A2  ue_id=1  carrier_freq=${NRCELL-1.nrarfcn_gscn}
    Verify UE is configured with B1 Measurement event based on B1 Measurement Priority
    ...     earfcn_1=900  wideband_meas_1=TRUE  b1MeasRedir_1=rsrp  b1Threshold_1=28  hyst_1=0  time_to_trig_1=ms100
    ...     earfcn_2=300  wideband_meas_2=FALSE  b1MeasRedir_2=rsrq  b1Threshold_2=12  hyst_2=2  time_to_trig_2=ms128
    Sleep  5s  Reason=wait for gNB to release the UE with redirected EUTRA carrier info after b1RedirSupervisionTimer expires
    Verify gNB Triggers RRC Release with Redirected Eutra Carrier Info  redir_carrier=6300
    Update AMF Initial Context Setup RFSP parameter  ue_id=1  indexToRFSP=none
    Collect and Verify PM Counters  test_instance=B_A_B6


