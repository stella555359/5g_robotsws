*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-BA
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ../CB013142_Keywords.robot
Resource                        ../CB013142_Commissioning.robot
Resource                        ../CB013142_PM.robot

Suite Setup                     Prepare TL for CB013142
Suite Teardown                  Sqd65 Common Teardown

Test Setup                      Perform Preconditions of Test Scenario
Test Teardown                   Perform Postconditions of Test Case

*** Variables ***
@{CA_MSG_SEQ}                   sCellToAddModList
...                             sCellIndex 1
...                             physCellId 50
...                             downlinkConfigCommon
...                             uplinkConfigCommon
...                             sCellIndex 2
...                             physCellId 51


@{A1_BASED_PCELL_SWITCH_MSG_SEQ}                spCellConfig
...                                             spCellConfigCommon
...                                             physCellId 50
...                                             frequencyInfoDL
...                                             absoluteFrequencySSB 518910
...                                             frequencyInfoUL

*** Test Cases ***

CB013142_BA_ET_TC01_B1_SA_A1_meas_Config_on_SCell_for_PCell_change_using_criteria_except_UE_PC_based_meas_prof_during_SCell_addition
    [Documentation]
    ...   Main scenario: This user scenario intends to verify configuration of A1 measurement on SCell(s) for ‘PCell change’ using the selected
    ...   measurement profile based on one or more criteria (except UE power class) during SCell addition procedure for a SA UE. The mapping criteria
    ...   can be PLMN and/or S-NSSAI (slice) and/or RFSP and/or 5QI (VoNR) and/or UE supported band combination.
    ...   7 UEs are used for this test automation.
    ...   UE-1 selects measurement profile (NRMEASPR_MA_SA-67 points to NRMEASPR_SCELL-12 & default NRMEASPR_SCELL-29) based on PLMN criteria.
    ...   UE-2 and UE-5 select measurement profile (NRMEASPR_MA_SA-4 points to NRMEASPR_SCELL-67 & default NRMEASPR_SCELL-1) based on RFSP criteria.
    ...   UE-3 and UE-6 select measurement profile (NRMEASPR_MA_SA-9 points to NRMEASPR_SCELL-1 & default NRMEASPR_SCELL-67) based on slice criteria.
    ...   UE-4 selects measurement profile (NRMEASPR_MA_SA-78 points to NRMEASPR_SCELL-2 & default NRMEASPR_SCELL-12) based on 5qi criteria.
    ...   UE-7 selects measurement profile (NRMEASPR_MA_SA-99 points to NRMEASPR_SCELL-29 & default NRMEASPR_SCELL-2) based on NRCACLASS criteria.
    [Tags]    BA_B1
    Register and Establish PDU Session for Multiple UEs
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_4}
    Verify whether UEs are configured with A1 Measurement event for the PCell Change
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=BA_B1


CB013142_BA_ET_TC02_B2_SA_A1_meas_Config_on_SCell_for_PCell_change_using_NRCELL_configuration_when_matching_profile_mapping_is_not_found
    [Documentation]
    ...   Main scenario: Configuration of A1 measurement on SCell for ‘PCell change’ using configuration parameters from NRCELL and selected
    ...   measurement profile based on one or more criteria (except UE power class criteria) during SCell addition for SA when matching profile
    ...   mapping is not found.This user scenario intends to verify that if no measurement profile mapping is matching with the UE, then legacy
    ...   measurement configuration from NRCELL is used for configuring A1 measurement for PCell change.
    ...   This automation is based on single UE
    [Tags]    BA_B2
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    3=2
    Register and Establish PDU Session    ue_id=3
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_4}
    Verify UE is configured with A1 Measurement on SCell for the PCell Change
        ...    ue_id=3
        ...    thresh_1=${SCELL_1_a1_thresh}
        ...    hyst_1=${SCELL_1_a1_hyst}
        ...    time_to_trig_1=ms${SCELL_1_a1_time}
        ...    thresh_2=${SCELL_2_a1_thresh}
        ...    hyst_2=${SCELL_2_a1_hyst}
        ...    time_to_trig_2=ms${SCELL_2_a1_time}
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=BA_B2


CB013142_BA_ET_TC03_B4_SA_Second_meas_quant_eval_on_SCell_using_meas_profile_using_criteria_except_UE_PC_during_A1_MR_reception_for_PCell_change
    [Documentation]
    ...   Main scenario: This user scenario intends to verify that when A1 measurement for PCell change (NRBTS/NRCELL/a1MeasPCellSwitchEnabled)
    ...   is configured as ‘rsrpCombined’, upon receiving the A1 measurement report for PCell change gNB evaluates the secondary measurement
    ...   quantity included in the A1 measurement report using A1 measurement configuration from the measurement profile. gNB ignores the
    ...   measurement report, if the A1 event criteria is not fulfilled for the RSRQ quantity.


    [Tags]    BA_B4
    [Setup]   Setup for CB013142-BA-B4
    Register and Establish PDU Session for Multiple UEs
    Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    Initiate Both Uplink and Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    Send A1 MR For SCell Addition And Verify Whether gNB Configures CA And Deconfigures A1 Measurement At The UE   carrier_freq=${CARRIER_FREQ_4}
    Verify whether UEs are configured with A1 Measurement event for the PCell Change
    Send A1 MR and Verify PCELL switch did not happen
    Send A1 MR and Verify PCELL switch happened
    Stop Data transfer and Deregister All UEs
    Collect and Verify PM Counters   test_instance=BA_B1


CB013142_BA_ET_TC05_B6_SA_Online_modification
    [Documentation]
    ...   This user scenario intends to verify the gNB behaviour when feature is activated/deactivated online, or parameters introduced by this
    ...   feature are online modified. As per CFAM, there is a main scenario and two alternate scenarios to be tested to have 100% test coverage.
    ...   This test case covers all these scenarios. Also, here the measurement profile selection is based on RFSP criteria.
    ...   Main Scenario: Two new NRMEASPR_SCELLs are created and mapped to the matching measurement profile NRMEASPR_MA_SA:
    ...       UE-16 (Connected UE) remains configured with A1 measurement configuration based on old mapping and measurement profile parameters.
    ...       UE-17 (New UE) is configured with A1 measurement configuration based on new NRMEASPR_SCELLs profile parameters.
    ...   Alternate#1 Scenario: CB013142 is deactivated (NRBTS.actCAMeasInMeasProf set to 'deactivated'):
    ...       UE-17 (Connected UE) remains configured with A1 measurement configuration based on measurement profile
    ...       UE-18 (New UE) is configured with A1 measurement configuration based on legacy NRCELL parameters
    ...   Alternate#2 Scenario: CB013142 is activated (NRBTS.actCAMeasInMeasProf set to 'SA' or 'SA+NSA'):
    ...       UE-18 (Connected UE) remains configured with A1 measurement configuration based on legacy NRCELL parameters
    ...       UE-19 (New UE) is configured with A1 measurement configuration based on measurement profile
    [Tags]    BA_B6
    #Main Scenario starts here:
    CB013142_Commissioning.Activate A2 Measurement Based Scell Release
    CB013142_Keywords.Register And Establish Pdu Session   ue_id=16  rfsp=15
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=16  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Initiate Uplink And Downlink Data Traffic In Egate For Single Sa Ue   ue_id=16  dl_data=20  ul_data=10
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca And Removes A1 Meas Event At The Ue   ue_id=16
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify Ue Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=16  thresh_1=54  hyst_1=4
    ...   time_to_trig_1=ms256  thresh_2=60  hyst_2=10  time_to_trig_2=ms512
    CB013142_Commissioning.Apply Online Modification By Creating New Nrmeaspr Scell Mocs And Mapping It To Nrmeaspr Ma Sa
    CB013142_Keywords.Verify Whether Ues Are Configured With A2 Meas For Scell Release And Then Send A2 Mr And Verify Whether Gnb Releases Scell
    ...   ue_id=16
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=16  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca And Removes A1 Meas Event At The Ue   ue_id=16
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify Ue Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=16  thresh_1=80  hyst_1=30
    ...   time_to_trig_1=ms5120  thresh_2=62  hyst_2=12  time_to_trig_2=ms640  report_id_1=7  report_id_2=8  meas_obj_id_1=4  meas_obj_id_2=5
    ...   measid_1=8  measid_2=9
    #Alternate#1 Scenario starts here:
    CB013142_Keywords.Register And Establish PDU Session   ue_id=17  rfsp=18
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=17  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Initiate Uplink And Downlink Data Traffic In Egate For Single Sa Ue   ue_id=17  dl_data=20  ul_data=10
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca And Removes A1 Meas Event At The Ue   ue_id=17
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify UE Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=17  thresh_1=80  hyst_1=30
    ...   time_to_trig_1=ms5120  thresh_2=62  hyst_2=12  time_to_trig_2=ms640
    CB013142_Keywords.Stop Data Traffic And Deregister The Ue   ue_id=16
    CB013142_Keywords.Collect And Verify Pm Counters   test_instance=BA_B6_Part1  counter_extension=_Part_1    #Main Scenario ends here:
    CB013142_Commissioning.Apply Online Modification To Activate Or Deactivate Cb013142  faf=deactivated
    pmcounters.Wait Until The Next Measurement Period Starts
    CB013142_Keywords.Verify Whether Ues Are Configured With A2 Meas For Scell Release And Then Send A2 Mr And Verify Whether Gnb Releases Scell
    ...   ue_id=17
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=17  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca and Removes A1 Meas Event At The Ue   ue_id=17
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify Ue Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=17  thresh_1=50  hyst_1=0
    ...   time_to_trig_1=ms128  thresh_2=52  hyst_2=2  time_to_trig_2=ms160  report_id_1=7  report_id_2=8  meas_obj_id_1=4  meas_obj_id_2=5
    ...   measid_1=8  measid_2=9
    #Alternate#2 Scenario starts here:
    CB013142_Keywords.Register And Establish Pdu Session   ue_id=18  rfsp=19
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=18  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Initiate Uplink And Downlink Data Traffic In Egate For Single Sa Ue   ue_id=18  dl_data=20  ul_data=10
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca And Removes A1 Meas Event At The Ue   ue_id=18
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify Ue Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=18  thresh_1=50  hyst_1=0
    ...   time_to_trig_1=ms128  thresh_2=52  hyst_2=2  time_to_trig_2=ms160
    CB013142_Keywords.Stop Data Traffic And Deregister The Ue   ue_id=17    #Alternate#1 Scenario ends here:
    CB013142_Commissioning.Apply Online Modification To Activate Or Deactivate Cb013142  faf=SA+NSA
    CB013142_Keywords.Verify Whether Ues Are Configured With A2 Meas For Scell Release And Then Send A2 MR And Verify Whether Gnb Releases Scell
    ...   ue_id=18
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=18  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca And Removes A1 Meas Event At The Ue   ue_id=18
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify Ue Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=18  thresh_1=80  hyst_1=30
    ...   time_to_trig_1=ms5120  thresh_2=62  hyst_2=12  time_to_trig_2=ms640  report_id_1=7  report_id_2=8  meas_obj_id_1=4  meas_obj_id_2=5
    ...   measid_1=8  measid_2=9
    CB013142_Keywords.Register And Establish Pdu Session   ue_id=19  rfsp=20
    CB013142_Keywords.Verify Whether Ues Are Configured With A1 Measurement Event For Scell Addition   ue_id=19  carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Initiate Uplink And Downlink Data Traffic In Egate For Single Sa Ue   ue_id=19  dl_data=20  ul_data=10
    CB013142_Keywords.Send A1 Measurement Report And Verify Whether Gnb Configures Ca And Removes A1 Meas Event At The Ue   ue_id=19
    ...   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Verify Ue Is Configured With A1 Measurement On Scell For The Pcell Change   ue_id=19  thresh_1=80  hyst_1=30
    ...   time_to_trig_1=ms5120  thresh_2=62  hyst_2=12  time_to_trig_2=ms640
    CB013142_Keywords.Stop Data Traffic And Deregister The Ue   ue_id=18
    CB013142_Keywords.Stop Data Traffic And Deregister The Ue   ue_id=19
    CB013142_Keywords.Collect And Verify Pm Counters   test_instance=BA_B6_Part2  counter_extension=_Part_2    #Alternate#2 Scenario ends here:
