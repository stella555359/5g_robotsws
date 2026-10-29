*** Settings ***

Documentation
...
...  INTRODUCTION:
...
...      CB008127-SR feature introduces 48 additional Measurement Profiles for Intra-frequency, 48 for Inter-frequency
...      and 24 for Inter-RAT mobility. With Measurement Profiles Operator can group UEs depending on several criteria
...      and apply different measurement configurations for each UE group. Each time when A1, A2, A3, A4, A5 or B2 measurement
...      configuration needs to be sent to UE, a Measurement Profile mapping shall be selected. This selection defines a set of
...      used measurement configurations for the UE. When no match of Measurement Profile is found then mobility configuration
...      according Legacy Mobility features shall be used. In CB008127-E sub-feature PLMN, NSSAI and RFSP are added
...      in matching criteria among already existing UE PowerClass capability criteria.
...
...  TEST SET NAME:  CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
...
...  TESTING SCOPE:  USCB008127-E#B1, USCB008127-E#B2, USCB008127-E#B5,
...                  USCB008127-E#B6, USCB008127-E#B7
...
...  DEPENDENCIES:
...                  CB008127-E depends on activation of 5GC000704
...                    - 5GC000704: Intra-frequency handover via Xn (SA option 2)
...
...                  CB008127-E depends on activation of 5GC000706
...                    - 5GC000706: Inter-frequency handover via Xn (SA option 2)
...
...                  CB008127-E depends on activation of CB008127-AB
...                    - CB008127-AB: SA measurement profiles selection and allocation to UE and HPUE measurement profiles support
...
...                  CB008127-E depends on activation of 5GC001630
...                    - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing)
...
...                  CB008127-E interacts with 5GC001008
...                    - 5GC001008: Signaling-based NG RAN Slicing with 5GC
...
...  TEST INSTANCE SPECIFIC NOTES:
...  Case 1: CB008127-E-B1-T01-Measurement-Profile-Based-On-PLMN-And-NSSAI
...  TEST CASE: CB008127-E-B1-T01-Measurement-Profile-Based-On-PLMN-And-NSSAI
...  Purpose : This test case verifies Measurement Profile selection based on UE's PLMN, NSSAI and
...  Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
...  with rsrp criteria during Initial Context Setup or after incoming HO. Incrementing of feature PM counters are verified.
...
...  Case 2: CB008127-E-B1-ALT1-T02-PLMN-And-NSSAI-Fallback-To-Legacy-Parameters
...  TEST CASE: CB008127-E-B1-ALT1-T02-PLMN-And-NSSAI-Fallback-To-Legacy-Parameters
...  Purpose : This test case verifies Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
...  using Legacy configuration during Initial Context Setup when no PLMN and NSSAI match
...  found from Measurement Profiles. Usage of Legacy configuration according NRCELL MO is verified.
...
...  Case 3: CB008127-E-B2-T01-Measurement-Profile-Based-On-PLMN-And-NSSAI-And-RFSP
...  TEST CASE: CB008127-E-B2-T01-Measurement-Profile-Based-On-PLMN-And-NSSAI-And-RFSP
...  Purpose : This test case verifies Measurement Profile selection based on UE's PLMN, NSSAI, RFSP
...  and Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
...  with rsrp criteria during Initial Context Setup or after incoming HO. Incrementing of feature PM counters
...  are verified.
...
...  Case 4: CB008127-E-B2-ALT3-T03-PLMN-NSSAI-RFSP-Partial-UE-Match-Criteria
...  TEST CASE: CB008127-E-B2-ALT3-T03-PLMN-NSSAI-RFSP-Partial-UE-Match-Criteria
...  Purpose : This test case verifies Measurement Profile selection based on UE's PLMN, NSSAI, RFSP
...  and Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
...  with rsrp criteria when only PLMN or only NSSAI or only RFSP selection criteria is defined in mapping table.
...  Verification is done during Initial Context Setup.
...
...  Case 5: CB008127-E-B5-T01-Measurement-Profile-Reselection-With-PDU-Session-Resource-Setup-For-New-NSSAI
...  TEST CASE: CB008127-E-B5-T01-Measurement-Profile-Reselection-With-PDU-Session-Resource-Setup-For-New-NSSAI
...  Purpose : This test case verifies Measurement Profile reselection based on UE's PLMN, NSSAI, RFSP
...  and Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
...  with rsrp criteria when a second PDU session is associated to a different S-NSSAI than previously established
...  PDU session. Due to a new NSSAI (slice), Measurement Profile shall be reselected.
...
...  Case 6: CB008127-E-B7-T01-A1-Measurement-Report-Handling-With-PLMN-NSSAI-RFSP-PowerClass
...  TEST CASE: CB008127-E-B7-T01-A1-Measurement-Report-Handling-With-PLMN-NSSAI-RFSP-PowerClass
...  Purpose : This test case verifies Intra-Frequency EventA2 measurement configuration after receiving A1 Measurement Report.
...  UE is in RRC connected state with Inter-Frequency EventA3 measurement active with rsrp and sends A1 MR to gNB.
...  Measurement profile is selected based on multiple criteria: PLMN, NSSAI, RFSP, PowerClass and 5QI.
...
...  CONTACTS:
...     Role:                                   Name:
...     ===================================     ====================================
...     Product Manager:                        @Arkadiusz Zieba (Nokia)
...     FS1TA Author:                           @Roland Baron  (Nokia)
...     APO:                                    @Karolina Bidzinska (Nokia)
...     FOT leader:                             @Wolfgang Mennerich (Nokia)
...     CFAM leader:                            @Marek Wesolowski (Nokia)
...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
...                                             --------------------------------------------------
...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
...                                             --------------------------------------------------
...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
...
...     AirPhone:                               @Pradeep Shenoy (Nokia)
...
...  REFERENCES:  CFAM CB008127-EG
...
...  HISTORY:
...         [25.08.2023] - Created TC
...         [08.09.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=893138
...         [06.10.2023] - Test finished at SVN revision https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318
...         [06.10.2023] - Review closed






Resource   ../Common/test_keywords.robot
Resource   ../Common/test_variables.robot
Library    ../Common/test_keywords.py
Variables  ../Common/test_variables.py
Resource   ./CB008127-E_CRT_Keywords.robot

Resource        ../../../../../resources/Common/reporting.robot


Suite Setup    Run Keywords    Testsuite Setup

Suite Teardown    Run Keywords    Testsuite TearDown
...    AND    Collect Additional Logs

Test Setup    Testcase Setup
Test Teardown    Testcase Teardown

*** Variables ***
${IPHY_DIR_PATH}      /opt/iphy
${EPCSIM_DIR_PATH}    ${IPHY_DIR_PATH}/latest
${EPCSIM_CFG_PATH}    ${CURDIR}/config/basic_setup.cfg
${IPHY_XML}           ${CURDIR}/config/iphy.xml
${SWCONFIG}           ${CURDIR}/config/sm_swconfig.txt
${SWCONFIG_AP}        ${CURDIR}/config/sim_swconfig.txt
${ROBOT_SUITE_DIR}    ${CURDIR}

${RRC_Reconf_EventA2}=
...  (f1ap && nr-rrc.c1 == 0)&&
...  (nr-rrc.eventId == 1)

*** Test Cases ***
CB008127-E-B1-T01-Measurement-Profile-Based-On-PLMN-And-NSSAI

    [Tags]    TC01
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Measurement Profile selection based on UE's PLMN, NSSAI and
    ...  Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
    ...  with rsrp criteria during Initial Context Setup or after incoming HO. Incrementing of feature PM counters are verified.
    ...  test execution
    ...    1. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    2. Based on UE's PLMN and NSSAI a match is found from mapping-MO table during Initial Context Setup
    ...    3. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrp criteria.
    ...    4. Verify increment of PM counters 55190 - NR Measurement Profile mapping SA
    ...                                                                  55187 - NR Measurement Profile Intra-Frequency
    ...    5. Register UE-2 in simulated gNB-3 cell-1 and establish a PDU session
    ...    6. Trigger Inter-gNB Intra-Frequency HO via Xn interface to real gNB-2
    ...    7. Verify from UEContextSetupRequest.CUtoDURRCInformation.MeasConfig.reportConfigToAddModList.ReportConfigToAddMod
    ...       that Intra-Frequency EventA3, EventA5 and EventA2 measurement IE is filled with selected Measurement
    ...       Profile using rsrp criteria.
    ...    8. Verify increment of PM counter 55190 - NR Measurement Profile mapping SA
    ...                                                                 55187 - NR Measurement Profile Intra-Frequency
    ...  expected results
    ...    1. PDU session is established for UE and based on Initial Context Setup EventA3, EventA5 and EventA2
    ...       measurements are active in UE
    ...    2-3. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrp criteria
    ...    4. PM counters M55190C00001 SA_MEAS_PROFILE_SELECTED and M55187C00001 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...    5. PDU session is established for UE.
    ...    6. Inter-gNB Intra-Frequency HO is successful
    ...    7. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile with rsrp criteria
    ...    8. PM counters M55190C00001 SA_MEAS_PROFILE_SELECTED and M55187C00001 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...
    ...
    ...  PRECONDITION: - 5GC000704: Intra-frequency handover via Xn (SA option 2) activated (actIntraFreqHoSA=true, NRCELL/a2MeashoSsbRsrp)
    ...                - Simulated and real gNB cells defined as neighbour cells for Intra-Frequency handovers
    ...                - CB008127-AB Measurement Profile activated, (actMeasurementProfile= SA or SA+NSA)
    ...                - Parameters a1MeashoEnabledSA, a2MeashoEnabledSA, a3MeasEnabled and a5MeasEnabled are having value rsrp
    ...                - A2, A3, A5 and A1 Intra-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IAF)
    ...                - PLMN and NSSAI based matching rules filled in Measurement Profiles mapping table (NRMEASPR_MA_SA)
    ...                - Mapping-MO Intra-Frequency Distinguished Name value filled (nrMeasPrIafDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - PM counters for CB008127 are enabled
    ...                - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing=true)
    ...                - 5GC001008: Signaling-based NG RAN Slicing with 5GC
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
    ...
    ...                                        Real gNB-2:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...                                        Simulated gNB-3:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...         ENVIRONMENT ELEMENTS:  Simulated 5G Core, real gNB-2, simulated gNB-3, simulated LTE
    ...         TEST CONFIGURATIONS:   CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20917
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   M55187C00001, M55190C00001
    ...       BACKLOG ID:                    FCA_5G_L2L3-179791
    ...
    ...  FEATURE SUB-ITEMS: CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
    ...
    ...  REQUIRED LOGS:  Wireshark logs, PM counter files
    ...
    ...  CONTACTS:
    ...     Role:                                   Name:
    ...     ===================================     ====================================
    ...     Product Manager:                        @Arkadiusz Zieba (Nokia)
    ...     FS1TA Author:                           @Roland Baron  (Nokia)
    ...     APO:                                    @Karolina Bidzinska (Nokia)
    ...     FOT leader:                             @Wolfgang Mennerich (Nokia)
    ...     CFAM leader:                            @Marek Wesolowski (Nokia)
    ...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
    ...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
    ...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
    ...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
    ...                                             --------------------------------------------------
    ...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
    ...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
    ...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
    ...                                             --------------------------------------------------
    ...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
    ...
    ...     AirPhone:                               @Pradeep Shenoy (Nokia)
    ...
    ...  REFERENCES:  CFAM CB008127-EG
    ...
    ...  HISTORY:
    ...         [25.08.2023] - Created TC
    ...         [08.09.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=893138
    ...         [06.10.2023] - Test finished at SVN revision https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318
    ...         [06.10.2023] - Review closed

    Get Next Unpacked Full Pm Counters File

    Set Ciphering And Integrity Protection Algorithms On Sim gNB  nia=nia3  nea=nea0
    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    # Step-1
    ${CapFile}=  Set Variable  TC01_Step1
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_1
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s
    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    # Step-3
    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=20
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=1
    ...  hysteresis=2
    ...  trigger=ms512

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=20
    ...  threshold2=10
    ...  hysteresis=2
    ...  trigger=ms512

    # Step-4
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # Step-5
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File

    # Incoming Inter-freq HO
    sleep    10s    Give some extra time
    Log To Console With Timestamp  log=## ## Attach UE-2 to gNB-3 Cell-1, n41, pci-381
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1  CA=${False}
    #Set Sim Automatic Neighbour Relation  pci=51
    ${CapFile}=  Set Variable  TC01_Step5
    Log To Console With Timestamp  log=## Incoming Intra-freq HO from gNB-3 pci=381 n41 to gNB-2 pci=50 n41
    ${tcpdump_process}=    Perform Xn Handover  ue_id=2  phycell_id=50  direction=incoming
    ...  carrier_freq2=527790  RRE=${False}  copy_pcap=${CapFile}

    # Step-7
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    Log To Console With Timestamp  log=## UE-2 Measurements after HO:
    Print Measurements  ue_id=2
    Run Keyword And Ignore Error  UE Deregister  ue_id=2
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    # Step-8
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Set SCOUT TC ID for Reporting


CB008127-E-B1-ALT1-T02-PLMN-And-NSSAI-Fallback-To-Legacy-Parameters

    [Tags]    TC02
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Measurement Profile selection for Intra-Frequency EventA2, EventA3 and EventA5
    ...    measurement configuration using Legacy feature configuration (NRCELL) during Initial Context Setup.
    ...    In this test is verified situations:
    ...      a) Feature is disabled for SA
    ...      b) Matching UE's PLMN and NSSAI is not found from Measurement Profile mapping table (NRMEASPR_MA_SA)
    ...      c) Matching rule for UE found from Measurement Profile mapping table (NRMEASPR_MA_SA) and DN to configuration
    ...         table NRMEASPR_IAF exists, but data is only partly filled. Some parameter a2MeasSsbRsrp, a3MeasSsbRsrp
    ...         or a5MeasSsbRsrp are missing.
    ...
    ...  test execution
    ...    a) actMeasurementProfile=NSA
    ...    1. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    2. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according NRCELL MO using rsrp criteria.
    ...    3. Deregister UE-2
    ...
    ...    b) No match Measurement Profile mapping table
    ...    4. Activate feature actMeasurementProfile=SA
    ...    5. Remove matching record from Measurement Profile mapping table (NRMEASPR_MA_SA)
    ...    6. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    7. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according NRCELL MO using rsrp criteria.
    ...    8. Deregister UE-2
    ...
    ...    c) Partial Measurement profile configuration in NRMEASPR_IAF
    ...    9. Remove a3MeasSsbRsrp structure from matching record of NRMEASPR_IAF.
    ...    10. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    11. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that EventA2 and EventA5 threshold, hysteresis
    ...        and time_to_trigger are filled according selected Measurement Profile using rsrp criteria and
    ...        EventA3 threshold, hysteresis and time_to_trigger are filled according Legacy feature NRCELL.
    ...
    ...  expected results
    ...    1. PDU session is established for UE
    ...    2. Based on Initial Context Setup EventA2, EventA3 and EventA5 measurement configuration values are according Legacy feature
    ...       NRCELL with rsrp criteria
    ...    6. PDU session is established for UE.
    ...    7. Based on Initial Context Setup EventA2, EventA3 and EventA5 measurement configuration values are according Legacy feature
    ...       NRCELL with rsrp criteria
    ...    10. PDU session is established for UE
    ...    11. Based on Initial Context Setup EventA2 and eventA5 measurement configuration values are according selected Measurement
    ...        Profile with rsrp criteria. EventA3 measurement configuration values are according Legacy feature
    ...        NRCELL with rsrp criteria
    ...
    ...  PRECONDITION: - 5GC000704: Intra-frequency handover via Xn (SA option 2) activated (actIntraFreqHoSA=true, NRCELL/a2MeashoSsbRsrp)
    ...                - Simulated and real gNB cells defined as neighbour cells for Intra-Frequency handovers
    ...                - CB008127-AB Measurement Profile activated, (actMeasurementProfile= SA or SA+NSA)
    ...                - Parameters a1MeashoEnabledSA, a2MeashoEnabledSA, a3MeasEnabled and a5MeasEnabled are having value rsrp
    ...                - PLMN and NSSAI based matching rules filled in Measurement Profiles mapping table (NRMEASPR_MA_SA)
    ...                - A2, A3, A5 and A1 Intra-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IAF)
    ...                - Mapping-MO Intra-Frequency Distinguished Name value filled (nrMeasPrIafDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing=true)
    ...                - 5GC001008: Signaling-based NG RAN Slicing with 5GC
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
    ...
    ...                                        Real gNB-2:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...                                        Simulated gNB-3:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...         ENVIRONMENT ELEMENTS:  Simulated 5G Core, real gNB-2, simulated gNB-3, simulated LTE
    ...         TEST CONFIGURATIONS:   CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20917
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-179791
    ...
    ...  FEATURE SUB-ITEMS:  CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
    ...
    ...  REQUIRED LOGS:  Wireshark logs
    ...
    ...  CONTACTS:
    ...     Role:                                   Name:
    ...     ===================================     ====================================
    ...     Product Manager:                        @Arkadiusz Zieba (Nokia)
    ...     FS1TA Author:                           @Roland Baron  (Nokia)
    ...     APO:                                    @Karolina Bidzinska (Nokia)
    ...     FOT leader:                             @Wolfgang Mennerich (Nokia)
    ...     CFAM leader:                            @Marek Wesolowski (Nokia)
    ...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
    ...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
    ...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
    ...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
    ...                                             --------------------------------------------------
    ...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
    ...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
    ...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
    ...                                             --------------------------------------------------
    ...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
    ...
    ...     AirPhone:                               @Pradeep Shenoy (Nokia)
    ...
    ...  REFERENCES:  CFAM CB008127-EG
    ...
    ...  HISTORY:
    ...         [25.08.2023] - Created TC
    ...         [08.09.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=893138
    ...         [06.10.2023] - Test finished at SVN revision https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318
    ...         [06.10.2023] - Review closed


    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc02_step1.json

    Set Ciphering And Integrity Protection Algorithms On Sim gNB  nia=nia3  nea=nea0
    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    # a) actMeasurementProfile=NSA
    # Step-1
    ${CapFile}=  Set Variable  TC02_Step1
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_2
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s
    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    # Step-2
    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=30
    ...  hysteresis=0
    ...  trigger=ms320

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=20
    ...  hysteresis=0
    ...  trigger=ms320

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=40
    ...  threshold2=30
    ...  hysteresis=0
    ...  trigger=ms320

    # Step-3
    Run Keyword And Ignore Error  UE Deregister  ue_id=2
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc02_step5.json
    Sleep  5s
    # Step-6
    ${CapFile}=  Set Variable  TC02_Step6
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_3
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s
    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    # Step-7
    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=30
    ...  hysteresis=0
    ...  trigger=ms320

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=20
    ...  hysteresis=0
    ...  trigger=ms320

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=40
    ...  threshold2=30
    ...  hysteresis=0
    ...  trigger=ms320

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # c )Partial Measurement profile configuration in NRMEASPR_IAF
    # Remove  a3MeasSsbRsrp from "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-1",
    # Step-9

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc02_step9.json
    Sleep  5s

    ${CapFile}=  Set Variable  TC02_Step9
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_4
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Step-10
    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    # Step-11
    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=20
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=20
    ...  hysteresis=0
    ...  trigger=ms320

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=20
    ...  threshold2=10
    ...  hysteresis=2
    ...  trigger=ms512

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    Set SCOUT TC ID for Reporting

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc02_step11.json
    Sleep  5s


CB008127-E-B2-T01-Measurement-Profile-Based-On-PLMN-And-NSSAI-And-RFSP
    [Tags]    TC03
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Measurement Profile selection based on UE's PLMN, NSSAI, RFSP and
    ...  Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
    ...  with rsrp criteria during Initial Context Setup or after incoming HO.
    ...  Incrementing of feature PM counters are verified.
    ...
    ...  test execution
    ...    1. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    2. Based on UE's PLMN, NSSAI and RFSP a match is found from mapping-MO table during Initial Context Setup
    ...    3. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrp criteria.
    ...    4. Verify increment of PM counters 55190 - NR Measurement Profile mapping SA
    ...                                       55187 - NR Measurement Profile Intra-Frequency
    ...    5. Register UE-2 in simulated gNB-3 cell-1 and establish a PDU session
    ...    6. Trigger Inter-gNB Intra-Frequency HO via Xn interface to real gNB-2
    ...    7. Verify from UEContextSetupRequest.CUtoDURRCInformation.MeasConfig.reportConfigToAddModList.ReportConfigToAddMod
    ...       that Intra-Frequency EventA3, EventA5 and EventA2 measurement IE is filled with selected Measurement
    ...       Profile using rsrp criteria.
    ...    8. Verify increment of PM counter 55190 - NR Measurement Profile mapping SA
    ...                                      55187 - NR Measurement Profile Intra-Frequency
    ...
    ...  expected results
    ...    1. PDU session is established for UE and based on Initial Context Setup EventA3, EventA5 and EventA2
    ...       measurements are active in UE
    ...    2-3. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrp criteria
    ...    4. PM counters M55190C00000 SA_MEAS_PROFILE_SELECTED and M55187C00000 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...    5. PDU session is established for UE.
    ...    6. Inter-gNB Intra-Frequency HO is successful
    ...    7. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile with rsrp criteria
    ...    8. PM counters M55190C00000 SA_MEAS_PROFILE_SELECTED and M55187C00000 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...
    ...  PRECONDITION: - 5GC000704: Intra-frequency handover via Xn (SA option 2) activated (actIntraFreqHoSA=true, NRCELL/a2MeashoSsbRsrp)
    ...                - Simulated and real gNB cells defined as neighbour cells for Intra-Frequency handovers
    ...                - CB008127-AB Measurement Profile activated, (actMeasurementProfile= SA or SA+NSA)
    ...                - Parameters a1MeashoEnabledSA, a2MeashoEnabledSA, a3MeasEnabled and a5MeasEnabled are having value rsrp
    ...                - A2, A3, A5 and A1 Intra-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IAF)
    ...                - PLMN, NSSAI and RFSP based matching rules filled in Measurement Profiles mapping table (NRMEASPR_MA_SA)
    ...                - Mapping-MO Intra-Frequency Distinguished Name value filled (nrMeasPrIafDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - PM counters for CB008127 are enabled
    ...                - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing=true)
    ...                - 5GC001008: Signaling-based NG RAN Slicing with 5GC
    ...                - RFSP retrieve/send and store in SA option 2 (actRfspIndex = true)
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
    ...
    ...                                        Real gNB-2:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...                                        Simulated gNB-3:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...         ENVIRONMENT ELEMENTS:  Simulated 5G Core, real gNB-2, simulated gNB-3, simulated LTE
    ...         TEST CONFIGURATIONS:   CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20918
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   M55187C00000, M55190C00000
    ...       BACKLOG ID:                    FCA_5G_L2L3-179792
    ...
    ...  FEATURE SUB-ITEMS:  CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
    ...
    ...  REQUIRED LOGS:  Wireshark logs, PM counter files
    ...
    ...  CONTACTS:
    ...     Role:                                   Name:
    ...     ===================================     ====================================
    ...     Product Manager:                        @Arkadiusz Zieba (Nokia)
    ...     FS1TA Author:                           @Roland Baron  (Nokia)
    ...     APO:                                    @Karolina Bidzinska (Nokia)
    ...     FOT leader:                             @Wolfgang Mennerich (Nokia)
    ...     CFAM leader:                            @Marek Wesolowski (Nokia)
    ...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
    ...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
    ...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
    ...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
    ...                                             --------------------------------------------------
    ...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
    ...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
    ...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
    ...                                             --------------------------------------------------
    ...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
    ...
    ...     AirPhone:                               @Pradeep Shenoy (Nokia)
    ...
    ...  REFERENCES:  CFAM CB008127-EG
    ...
    ...  HISTORY:
    ...         [25.08.2023] - Created TC
    ...         [08.09.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=893138
    ...         [06.10.2023] - Test finished at SVN revision https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318
    ...         [06.10.2023] - Review closed


    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc03_step1.json
    Sleep  5s

    Get Next Unpacked Full Pm Counters File

    Set Ciphering And Integrity Protection Algorithms On Sim gNB  nia=nia3  nea=nea0
    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    # Step-1
    ${CapFile}=  Set Variable  TC01_Step1
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_5
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Include Index to RFSP in NG:Initial Context Setup Request
    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16

    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    # Step-3
    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=20
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=1
    ...  hysteresis=2
    ...  trigger=ms512

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=20
    ...  threshold2=10
    ...  hysteresis=2
    ...  trigger=ms512

    # Step-4
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # Step-5
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File

    # Incoming Inter-freq HO
    sleep    10s    Give some extra time

    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16
    Log To Console With Timestamp  log=## ## Attach UE-2 to gNB-3 Cell-1, n41, pci-381
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1  CA=${False}
    #Set Sim Automatic Neighbour Relation  pci=51

    Execute Egate Command  cmd=amf_dl_nas_transport_param id=1 indexToRFSP=16 alias=ap_egate
    Execute Egate Command  cmd=ue_send_dl_nas_transport id=2 alias=ap_egate

    ${CapFile}=  Set Variable  TC01_Step5
    Log To Console With Timestamp  log=## Incoming Intra-freq HO from gNB-3 pci=381 n41 to gNB-2 pci=50 n41
    ${tcpdump_process}=    Perform Xn Handover  ue_id=2  phycell_id=50  direction=incoming
    ...  carrier_freq2=527790  RRE=${False}  copy_pcap=${CapFile}

    sleep    10s    Give some extra time
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    # Step-7
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    Log To Console With Timestamp  log=## UE-2 Measurements after HO:
    Print Measurements  ue_id=2
    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # Step-8
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Set SCOUT TC ID for Reporting

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc03_step8.json


CB008127-E-B2-ALT3-T03-PLMN-NSSAI-RFSP-Partial-UE-Match-Criteria

    [Tags]    TC04
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Measurement Profile selection for Intra-Frequency EventA2, EventA3 and EventA5
    ...    measurement configuration during Initial Context Setup when only PLMN or NSSAI or RFSP match criteria is defined in
    ...    Measurement Profile mapping table (NRMEASPR_MA_SA).
    ...
    ...  test execution
    ...    a) Only-PLMN filled in Measurement Profiles mapping table
    ...    1. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    2. Based on UE's PLMN a match is found from mapping-MO table during Initial Context Setup
    ...    3. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrq criteria.
    ...    b) Only-NSSAI filled in Measurement Profiles mapping table
    ...    4. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    5. Based on UE's NSSAI a match is found from mapping-MO table during Initial Context Setup
    ...    6. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrq criteria.
    ...    c) Only-RFSP filled in Measurement Profiles mapping table
    ...    7. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    8. Based on UE's RFSP a match is found from mapping-MO table during Initial Context Setup
    ...    9. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrq criteria.
    ...
    ...  expected results
    ...    1. PDU session is established for UE
    ...    3. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrq criteria
    ...    4. PDU session is established for UE.
    ...    6. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrq criteria
    ...    7. PDU session is established for UE.
    ...    9. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrq criteria
    ...
    ...  PRECONDITION: - 5GC000704: Intra-frequency handover via Xn (SA option 2) activated (actIntraFreqHoSA=true, NRCELL/a2MeashoSsbRsrp)
    ...                - Simulated and real gNB cells defined as neighbour cells for Intra-Frequency handovers
    ...                - CB008127-AB Measurement Profile activated, (actMeasurementProfile= SA or SA+NSA)
    ...                - Parameters a1MeashoEnabledSA, a2MeashoEnabledSA, a3MeasEnabled and a5MeasEnabled are having value rsrq
    ...                - A2, A3, A5 and A1 Intra-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IAF)
    ...                  using rsrp and rsrq criteria
    ...                - Only-PLMN or only-NSSAI or only-RFSP based matching rules filled in Measurement Profiles mapping table (NRMEASPR_MA_SA)
    ...                - Mapping-MO Intra-Frequency Distinguished Name value filled (nrMeasPrIafDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing=true)
    ...                - 5GC001008: Signaling-based NG RAN Slicing with 5GC
    ...                - RFSP retrieve/send and store in SA option 2 (actRfspIndex = true)
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
    ...
    ...                                        Real gNB-2:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...                                        Simulated gNB-3:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...         ENVIRONMENT ELEMENTS:  Simulated 5G Core, real gNB-2, simulated gNB-3, simulated LTE
    ...         TEST CONFIGURATIONS:   CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20918
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-179792
    ...
    ...  FEATURE SUB-ITEMS:  CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
    ...
    ...  REQUIRED LOGS:  Wireshark logs
    ...
    ...  CONTACTS:
    ...     Role:                                   Name:
    ...     ===================================     ====================================
    ...     Product Manager:                        @Arkadiusz Zieba (Nokia)
    ...     FS1TA Author:                           @Roland Baron  (Nokia)
    ...     APO:                                    @Karolina Bidzinska (Nokia)
    ...     FOT leader:                             @Wolfgang Mennerich (Nokia)
    ...     CFAM leader:                            @Marek Wesolowski (Nokia)
    ...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
    ...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
    ...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
    ...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
    ...                                             --------------------------------------------------
    ...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
    ...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
    ...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
    ...                                             --------------------------------------------------
    ...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
    ...
    ...     AirPhone:                               @Pradeep Shenoy (Nokia)
    ...
    ...  REFERENCES:  CFAM CB008127-EG
    ...
    ...  HISTORY:
    ...         [25.08.2023] - Created TC
    ...         [08.09.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=893138
    ...         [06.10.2023] - Test finished at SVN revision https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318
    ...         [06.10.2023] - Review closed

    Set Ciphering And Integrity Protection Algorithms On Sim gNB  nia=nia3  nea=nea0
    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc04_step1.json
    Sleep  5s

    # a) Only-PLMN
    # Step-1
    ${CapFile}=  Set Variable  TC03_Step1
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_6
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Include Index to RFSP in NG:Initial Context Setup Request
    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16

    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    # Step-3
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=40
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=5
    ...  hysteresis=2
    ...  trigger=ms512

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=40
    ...  threshold2=30
    ...  hysteresis=2
    ...  trigger=ms512

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # b) Only-NSSAI
    # Step-4

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc04_step4.json
    Sleep  5s

    ${CapFile}=  Set Variable  TC03_Step4
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_7
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Include Index to RFSP in NG:Initial Context Setup Request
    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16

    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    # Step-6
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=40
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=5
    ...  hysteresis=2
    ...  trigger=ms512

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=40
    ...  threshold2=30
    ...  hysteresis=2
    ...  trigger=ms512

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # c) Only-RFSP
    # Step-7

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc04_step7.json
    Sleep  5s

    ${CapFile}=  Set Variable  TC03_Step7
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_8
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Include Index to RFSP in NG:Initial Context Setup Request
    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16

    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    # Step-9
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=40
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=5
    ...  hysteresis=2
    ...  trigger=ms512

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRQ From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=40
    ...  threshold2=30
    ...  hysteresis=2
    ...  trigger=ms512

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    Set SCOUT TC ID for Reporting

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc04_step9.json
    Sleep  5s


CB008127-E-B5-T01-Measurement-Profile-Reselection-With-PDU-Session-Resource-Setup-For-New-NSSAI

    [Tags]    TC05
    [Documentation]

    ...  DESCRIPTION: This test case verifies Measurement Profile re-selection based on UE's PLMN, NSSAI, RFSP
    ...  and Measurement Profile priority for Intra-Frequency EventA3, EventA5 and EventA2 measurement configuration
    ...  with rsrp criteria when a second PDU session is associated to a different S-NSSAI than previously established
    ...  PDU session. Due to a new NSSAI (slice), Measurement Profile shall be reselected.
    ...
    ...  test execution
    ...    1. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    2. Based on UE's PLMN, NSSAI and RFSP a match is found from mapping-MO table during Initial Context Setup
    ...    3. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrp criteria.
    ...    4. Verify increment of PM counters 55190 - NR Measurement Profile mapping SA
    ...                                       55187 - NR Measurement Profile Intra-Frequency
    ...    5. Start New Data call on UE using a new slice. Due to a new NSSAI, Measurement Profile shall be reselected.
    ...    6. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Event threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrp criteria.
    ...    7. Verify increment of PM counters 55190 - NR Measurement Profile mapping SA
    ...                                       55187 - NR Measurement Profile Intra-Frequency
    ...
    ...  expected results
    ...    1. PDU session is established for UE and based on Initial Context Setup EventA3, EventA5 and EventA2
    ...       measurements are active in UE
    ...    3. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrp criteria
    ...    4. PM counters M55190C00001 SA_MEAS_PROFILE_SELECTED and M55187C00001 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...    5. PDU session is established for UE using new NSSAI.
    ...    6. EventA2, EventA3 and EventA5 measurement configuration values are according selected Measurement Profile
    ...       with rsrp criteria
    ...    7. PM counters M55190C00001 SA_MEAS_PROFILE_SELECTED and M55187C00001 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...
    ...  PRECONDITION: - 5GC000704: Intra-frequency handover via Xn (SA option 2) activated (actIntraFreqHoSA=true, NRCELL/a2MeashoSsbRsrp)
    ...                - Simulated and real gNB cells defined as neighbour cells for Intra-Frequency handovers
    ...                - CB008127-AB Measurement Profile activated, (actMeasurementProfile= SA or SA+NSA)
    ...                - Parameters a1MeashoEnabledSA, a2MeashoEnabledSA, a3MeasEnabled and a5MeasEnabled are having value rsrp
    ...                - A2, A3, A5 and A1 Intra-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IAF)
    ...                - PLMN, NSSAI and RFSP based matching rules filled in Measurement Profiles mapping table (NRMEASPR_MA_SA)
    ...                - Mapping-MO Intra-Frequency Distinguished Name value filled (nrMeasPrIafDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - PM counters for CB008127 are enabled
    ...                - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing=true)
    ...                - 5GC001008: Signaling-based NG RAN Slicing with 5GC
    ...                - RFSP retrieve/send and store in SA option 2 (actRfspIndex = true)
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
    ...
    ...                                        Real gNB-2:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...                                        Simulated gNB-3:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...         ENVIRONMENT ELEMENTS:  Simulated 5G Core, real gNB-2, simulated gNB-3, simulated LTE
    ...         TEST CONFIGURATIONS:   CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_21244, CB_FIM_39561
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   M55187C00001, M55190C00001
    ...       BACKLOG ID:                    FCA_5G_L2L3-179793
    ...
    ...  FEATURE SUB-ITEMS: CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
    ...
    ...  REQUIRED LOGS:  Wireshark logs, PM counter files
    ...
    ...  CONTACTS:
    ...     Role:                                   Name:
    ...     ===================================     ====================================
    ...     Product Manager:                        @Arkadiusz Zieba (Nokia)
    ...     FS1TA Author:                           @Roland Baron  (Nokia)
    ...     APO:                                    @Karolina Bidzinska (Nokia)
    ...     FOT leader:                             @Wolfgang Mennerich (Nokia)
    ...     CFAM leader:                            @Marek Wesolowski (Nokia)
    ...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
    ...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
    ...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
    ...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
    ...                                             --------------------------------------------------
    ...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
    ...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
    ...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
    ...                                             --------------------------------------------------
    ...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
    ...
    ...     AirPhone:                               @Pradeep Shenoy (Nokia)
    ...
    ...  REFERENCES:  CFAM CB008127-EG
    ...
    ...  HISTORY:
    ...         [25.08.2023] - Created TC
    ...         [08.09.2023] - Approved by https://collab.ext.net.nokia.com/ui#review:id=893138
    ...         [06.10.2023] - Test finished at SVN revision https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318
    ...         [06.10.2023] - Review closed


    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc05_step1.json
    Sleep  5s

    Get Next Unpacked Full Pm Counters File

    Set Ciphering And Integrity Protection Algorithms On Sim gNB  nia=nia3  nea=nea0
    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    # Step-1
    ${CapFile}=  Set Variable  TC01_Step1
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_9
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Include Index to RFSP in NG:Initial Context Setup Request
    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16

    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach UE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Start Internal Data Transfer  ue_id=2  pdu_id=1  tp_mbps=1

    # Step-3
    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=20
    ...  hysteresis=2
    ...  trigger=ms512

    ${A3_result}=  Run Keyword And Continue On Failure  SA Verify A3 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  offset=1
    ...  hysteresis=2
    ...  trigger=ms512

    ${A5_result}=  Run Keyword And Continue On Failure  SA Verify A5 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold1=20
    ...  threshold2=10
    ...  hysteresis=2
    ...  trigger=ms512

    Sleep  10s
    Print Data Throughput  ue_id=2  pdu_id=1

    Log To Console With Timestamp  log=## UE-2 Measurements after PDU-1
    Print Measurements  ue_id=2

    # Step-4
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    # Change hysteresis from 2dB to 3dB
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc05_step4.json
    Sleep  5s

    Get Next Unpacked Full Pm Counters File

    ${CapFile}=  Set Variable  TC01_Step2
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_10
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s

    # Step-5
    # UE-2 create 2nd PDU on NSSAI=2
    Establish Pdu Session  ue_id=2  pdu_id=2  nwslice=2  gw_id=1    pass_regexp=Established PDU session
    Sleep  5s
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    # Step-6
    Log To Console With Timestamp  log=## UE-2 Measurements after adding 2nd PDU
    Print Measurements  ue_id=2

    # Step-7
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Stop Internal Data Transfer  ue_id=2
    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    Set SCOUT TC ID for Reporting

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc05_step7.json
    Sleep  5s


CB008127-E-B7-T01-A1-Measurement-Report-Handling-With-PLMN-NSSAI-RFSP-PowerClass

    [Tags]    TC06
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Intra-Freq EventA2 measurement activation to RRC_CONNECTED UE with
    ...  selected Measurement Profile using rsrp criteria after receiving A1 Measurement Report. In this test Measurement
    ...  Profile is reselected based on multiple criterions: PLMN, NSSAI, RFSP and PowerClass.
    ...  Incrementing of feature PM counters are verified.
    ...
    ...  test execution
    ...    1. Register UE-2 in gNB-2 cell-1 and establish a PDU session
    ...    2. UE sends A2 Measurement Report to activate Inter-Frequency EventA3 and Intra-Frequency EventA1 Measurements
    ...    3. UE sends A1 Measurement Report to gNB
    ...    4. Based on UE's PLMN, NSSAI, RFSP and power class a match is found from mapping-MO table during A1 Measurement Report handling.
    ...    5. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that Intra-Frequency EventA2 threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrp criteria.
    ...    6. Verify increment of PM counters 55190 - NR Measurement Profile mapping SA
    ...                                       55187 - NR Measurement Profile Intra-Frequency
    ...
    ...  expected results
    ...    1. PDU session is established for UE
    ...    2. Inter-Frequency EventA1 Measurement is active on UE
    ...    3-5. Intra-Frequency EventA2 measurement configuration values are according selected Measurement Profile with rsrp criteria
    ...    6. PM counters M55190C00001 SA_MEAS_PROFILE_SELECTED and M55187C00001 IAF_MEAS_PROFILE_CONF_ATT have been incremented
    ...
    ...  PRECONDITION: - 5GC000704: Intra-frequency handover via Xn (SA option 2) activated (actIntraFreqHoSA=true, NRCELL/a2MeashoSsbRsrp)
    ...                - 5GC000706: Inter-frequency handover via Xn (SA option 2) activated (actInterFreqHoSA=true,
    ...                    NRCELL/NRHOIF/ssbFrequency = 633408
    ...                    Inter-Frequency A3/A5 activated with rsrp criteria (NRCELL/NRHOIF/a3MeasSsbRsrp & a5MeasSsbRsrp)
    ...                - Simulated and real gNB cells defined as neighbour cells for Intra- and Inter-Frequency handovers
    ...                - CB008127-AB Measurement Profile activated, (actMeasurementProfile= SA or SA+NSA)
    ...                - Parameters a1MeashoEnabledSA, a2MeashoEnabledSA, a3MeasEnabled and a5MeasEnabled are having value rsrp
    ...                - A2, A3, A5 and A1 Intra-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IAF)
    ...                - PLMN, NSSAI, RFSP, PowerClass and 5QI based matching rules filled in Measurement Profiles mapping table
    ...                  (NRMEASPR_MA_SA)
    ...                - Mapping-MO Intra-Frequency Distinguished Name value filled (nrMeasPrIafDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - PM counters for CB008127 are enabled
    ...                - 5GC001630 RAN Sharing in SA and additional configuration for NSA 3x (actRanSharing=true)
    ...                - 5GC001008: Signaling-based NG RAN Slicing with 5GC
    ...                - RFSP retrieve/send and store in SA option 2 (actRfspIndex = true)
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
    ...
    ...                                        Real gNB-2:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...                                        Simulated gNB-3:
    ...                                        NRCELL-1 band 41 TDD
    ...                                        NRCELL-2 band 78 TDD
    ...
    ...         ENVIRONMENT ELEMENTS:  Simulated 5G Core, real gNB-2, simulated gNB-3, simulated LTE
    ...         TEST CONFIGURATIONS:   CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_21945
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   M55187C00001, M55190C00001
    ...       BACKLOG ID:                    FCA_5G_L2L3-179795
    ...
    ...  FEATURE SUB-ITEMS: CB008127-E SA measurement profile selection based on PLMN, slice and RFSP
    ...
    ...  REQUIRED LOGS:  Wireshark logs, PM counter files
    ...
    ...  CONTACTS:
    ...     Role:                                   Name:
    ...     ===================================     ====================================
    ...     Product Manager:                        @Arkadiusz Zieba (Nokia)
    ...     FS1TA Author:                           @Roland Baron  (Nokia)
    ...     APO:                                    @Karolina Bidzinska (Nokia)
    ...     FOT leader:                             @Wolfgang Mennerich (Nokia)
    ...     CFAM leader:                            @Marek Wesolowski (Nokia)
    ...     Feature Test Lead:                      @Michal Kowalczyk (Nokia)
    ...     Lead Entity Specification Engineer:     @Tero Takala (Nokia)
    ...     5G L3 EFS Technical:                    @Ulf-Torsten Pingel (Nokia), @Frank Prietzel (Nokia),
    ...                                             @Jauaries Loyala (Nokia), @Felipe Rodriguez Yaguache (Nokia)
    ...                                             --------------------------------------------------
    ...     L3 ET:                                  @Bernhard Kukla (Nokia), @Wolfgang Greiner (Nokia), @Ronald Danke (Nokia)
    ...                                             @Roohi Bolar (Nokia), @Timo Leinonen (Nokia), @Topi Kivineva (Nokia),
    ...                                             Mithun Raj (Nokia), Md M. Alam (Nokia)
    ...                                             --------------------------------------------------
    ...     ST RRM:                                 @Mateusz Ochenduszko (Nokia), @Krzysztof Mirecki (Nokia)
    ...
    ...     AirPhone:                               @Pradeep Shenoy (Nokia)
    ...
    ...  REFERENCES:  CFAM CB008127-EG
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008127-AB
    ...
    ...            [25.08.2023] - Test plan and test case documentation created
    ...            [28.08.2023] - Test plan and test case review, proposed (ready for review)
    ...            [08.09.2023] - Test plan and test case review, approved - https://collab.ext.net.nokia.com/ui#review:id=893138
    ...            [06.10.2023] - Code review for test suite and cases completed:
    ...                         - https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/88318


    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc06_step1.json
    Sleep  5s

    Get Next Unpacked Full Pm Counters File

    Set Ciphering And Integrity Protection Algorithms On Sim gNB  nia=nia3  nea=nea0
    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    # Step-1
    # Include Index to RFSP in NG:Initial Context Setup Request
    Execute Egate Command  cmd=amf_ue_ics_param id=1 indexToRFSP=16

    #UE Id=2 SA, no CA, pc1dot5 for band41 and band78
    Log To Console With Timestamp  log=## Attach HPUE-2 to gNB-2 Cell-1, n41
    UE Register And Establish PDU Session  ue_id=2  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Log To Console With Timestamp  log=## UE-2 Measurements after Initial Context Setup:
    Print Measurements  ue_id=2
    Sleep  5s

    # Step-2
    Log To Console With Timestamp  log=## HPUE-2 sends A2 Measurement Report:
    Get And Send A2 Meas Id  ue_id=2  phycell_id=382  carrier_freq=527790
    Sleep  2s
    Log To Console With Timestamp  log=## HPUE-2 Measurements after sending A2 MR
    Print Measurements  ue_id=2
    Sleep  5s

    # Step-3
    ${CapFile}=  Set Variable  TC01_Step3
    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface
    ...  alias=WS_UE2_11
    ...  log_filename_prefix=${CapFile}
    ...  log_dirpath=${OUTPUT_DIR}
    Sleep  5s
    Log To Console With Timestamp  log=## HPUE-2 sends A1 Measurement Report:
    Run Keyword And Continue On Failure  Get And Send A1 Meas Id  ue_id=2  phycell_id=50  carrier_freq=527790

    sleep    5s    Give some extra time
    Run Keyword And Ignore Error  Kill Latest Tshark Process  ${tcpdump_process}

    Log To Console With Timestamp  log=## HPUE-2 Measurements after sending A1 MR
    Print Measurements  ue_id=2

    # Step-5
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...  filename=${OUTPUT_DIR}/${CapFile}.pdml
    ...  packet_filter=${RRC_Reconf_EventA2}
    ...  output_type=pdml
    ...  pcap_file_path=${OUTPUT_DIR}/${CapFile}.pcap
    Teardown Tshark

    ${A2_result}=  Run Keyword And Continue On Failure  SA Verify A2 Measurement RSRP From PDML
    ...  file=${OUTPUT_DIR}/${CapFile}.pdml
    ...  threshold=20
    ...  hysteresis=2
    ...  trigger=ms512

    Run Keyword And Ignore Error  UE Deregister  ue_id=2

    # Step-6
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure  Verify Any Counters In File
    ...  M55190C00001  >0  SA_MEAS_PROFILE_SELECTED
    ...  M55187C00001  >0  IAF_MEAS_PROFILE_CONF_ATT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Set SCOUT TC ID for Reporting

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_tc06_step6.json
    Sleep  5s
