*** Settings ***

Documentation   CB008127-AB-B6

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB008127_B6_keywords.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var

Resource   ../Common/test_keywords.robot
Resource   ../Common/test_variables.robot
Library    ../Common/test_keywords.py
Variables  ../Common/test_variables.py

Suite Setup      Testsuite Setup
Suite Teardown   Testsuite TearDown

Test Setup       Testcase Setup
Test Teardown    Testcase Teardown

*** Variables ***
${IPHY_DIR_PATH}             /opt/iphy
${EPCSIM_DIR_PATH}           ${IPHY_DIR_PATH}/latest
${EPCSIM_CFG_PATH}           ${CURDIR}/config/basic_setup.cfg
${IPHY_XML}                  ${CURDIR}/config/iphy.xml
${SWCONFIG}                  ${CURDIR}/config/sm_swconfig.txt
${SWCONFIG_AP}               ${CURDIR}/config/sim_swconfig.txt
${ROBOT_SUITE_DIR}           ${CURDIR}

${A4_WS_PCAP}=     ${OUTPUT_DIR}/Analyse/UE1.pcap
${A4_PDML_XML}=    ${OUTPUT_DIR}/Analyse/UE1_A4.pdml

${A4_MEASPR_NSA_WS_PCAP}=                 ${OUTPUT_DIR}/Analyse/UE1_MeasPR_NSA.pcap
${A4_MEASPR_NSA_PDML_XML}=                ${OUTPUT_DIR}/Analyse/UE1_MeasPR_NSA_A4.pdml
${A4_NO_MATCH_MEASPR_PC_WS_PCAP}=         ${OUTPUT_DIR}/Analyse/UE1_No_match_MeasPR_PC.pcap
${A4_NO_MATCH_MEASPR_PC_PDML_XML}=        ${OUTPUT_DIR}/Analyse/UE1_No_match_MeasPR_PC.pdml
${A4_NO_MATCH_SSBFREQ_MEASPR_WS_PCAP}=    ${OUTPUT_DIR}/Analyse/UE1_No_Match_SsbFreq_MeasPR.pcap
${A4_NO_MATCH_SSBFREQ_MEASPR_PDML_XML}=   ${OUTPUT_DIR}/Analyse/UE1_No_Match_SsbFreq_MeasPR.pdml
${A4_NO_A4MEAS_MEASPR_WS_PCAP}=           ${OUTPUT_DIR}/Analyse/UE1_No_A4Meas_MeasPR.pcap
${A4_NO_A4MEAS_MEASPR_PDML_XML}=          ${OUTPUT_DIR}/Analyse/UE1_No_A4Meas_MeasPR.pdml

${RRC_Reconf_EventA4}=
...  (f1ap && nr-rrc.c1 == 0)&&
...  (nr-rrc.eventId == 1||nr-rrc.eventId == 2||nr-rrc.eventId == 3||nr-rrc.eventId == 4)

${RRC Reconfiguration}=
...    (nr-rrc.measId == 1)&&
...    (nr-rrc.c1 == 0)&&
...    (nr-rrc.reportConfigToAddModList == 1)&&
...    (nr-rrc.a4_Threshold == 0)&&
...    (nr-rrc.measTriggerQuantity.rsrp == 2)&&
...    (nr-rrc.eventId == 3)&&
...    (nr-rrc.freqBandIndicatorNR == 257)&&
...    (nr-rrc.ssbFrequency == 2079166)
${UE Meauserement Report}=
...    (nr-rrc.criticalExtensions == 0)&&
...    (nr-rrc.measId == 1)&&
...    (nr-rrc.measResultNeighCells == 0)
${AMF UE Context Release Request}=
...    (ngap.radioNetwork == 20)&&
...    (ngap.procedureCode == 42)
${AMF UE Context Release Command}=
...    (ngap.procedureCode == 41)&&
...    (ngap.radioNetwork == 20)
${NGAP: UE Context Release Complete appears}=    (ngap.id == 60)

${RRC Release}=    nr-rrc.rrcRelease_element
${RRC Release EUTRA}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.cellReselectionPriority == 7)&&
...    (nr-rrc.carrierFreq == 300)&&
...    (nr-rrc.t320 == 1)
${RRC Release NR}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.carrierFreq == 147500)&&
...    (nr-rrc.cellReselectionPriority == 6)&&
...    (nr-rrc.carrierFreq == 636576)&&
...    (nr-rrc.cellReselectionPriority == 4)&&
...    (nr-rrc.t320 == 1)


*** Test Cases ***
CB008127-AB-B6-T01-Activate-Inter-Freq-A4-measurement-For-EN-DC-Aware-Traffic-Steering-rsrp

    [Tags]    TC01
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Inter-Freq EventA4 measurement for Idle mode mobility EN-DC aware traffic steering
    ...    is activated with rsrp criteria using the selected Measurement Profile after UE Inactivity timer (drbInactivityTimerSA)
    ...    expires. Incrementing of feature PM counters are verified.
    ...
    ...  test execution
    ...    1. Register UE-1 in gNB-2 cell-1 and establish a PDU session
    ...    2. Wait until UE Inactivity timer expires (drbInactivityTimerSA)
    ...    3. Based on UE's PowerClass and target cell NFHOIF/ssbFrequency a match is found from mapping-MO table
    ...    4. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that EventA4 threshold, hysteresis
    ...       and time_to_trigger are filled according selected Measurement Profile using rsrp criteria.
    ...    5. Verify increment of PM counters 55190 - NR Measurement Profile mapping SA
    ...                                       55188	- NR Measurement Profile Inter-Frequency
    ...  expected results
    ...    1. PDU session is established for UE
    ...    3-4. EventA4 measurement configuration values are according selected Measurement Profile
    ...       with rsrp criteria (a4MeasEnDcSteeringSsbRsrp)
    ...    5. PM counters M55190C00001 SA_MEAS_PROFILE_SELECTED and M55188C00001 IEF_MEAS_PROFILE_CONF_ATT have been incremented
    ...
    ...  PRECONDITION: - 5GC000706: Inter-frequency handover via Xn (SA option 2) activated (actInterFreqHoSA=true,
    ...                    NRCELL/NRHOIF/ssbFrequency = 2079166
    ...                - CB008696: 5G Idle mode Traffic from NR SA to LTE EN-DC carrier activated:
    ...                    NRBTS/actIdlMMEnDcSteering = true
    ...                    NRCELL/dleMMEnDcSteeringPercentageOfUes = 100
    ...                    NRCELL/idleMMEnDcSteeringSsbFrequency = 2079166
    ...                    NRCELL/NRHOIF/a4MeasEnDcSteeringEnabled = rsrp
    ...                    NRCELL/NRHOIF/a4MeasEnDcSteeringSsbRsrp
    ...                - Simulated and real gNB cells defined as neighbour cells for Inter-Freq handovers
    ...                - CB008127-AB MeasurementProfile activated,(actMeasurementProfile= SA or SA+NSA)
    ...                - A4 Inter-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IEF)
    ...                - PowerClass and target cell ssbFrequency based matching rules filled in Measurement Profiles
    ...                  mapping table (NRMEASPR_MA_SA)
    ...                - Mapping-MO Default Distinguished Name values filled (nrMeasPrIefDefaultDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - UE fills PowerClass IE into ueCapabilityInformation message sent to gNB.
    ...                - PM counters for CB008127 are enabled
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              AEQE
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20746, CB_FIM_39611
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   M55188C00001, M55190C00001
    ...       BACKLOG ID:                    FCA_5G_L2L3-165981
    ...
    ...  FEATURE SUB-ITEMS: CB008127-AB  SA measurement profile selection based on UE power class
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
    ...  REFERENCES:  CFAM CB008127-AB
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008127-AB
    ...
    ...            [01.02.2023] - Test plan and test case documentation created
    ...            [03.07.2023] - Test plan and test case review, proposed (ready for review)
    ...            [14.07.2023] - Test plan and test case review, approved - https://collab.ext.net.nokia.com/ui#review:id=878763
    ...            [23.10.2023] - Code review for test suite and cases completed https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/90993

    Get Next Unpacked Full Pm Counters File
    #Start PCMD Capture

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface

    Set Test Variable    ${TSHARKALIAS_XN}       ${alias}
    Set Test Variable    ${TSHARKALIAS_XN_PATH}  ${log_filepath}

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=1
    ...    meas_id=1

    Log To Console With Timestamp    Measurements after drbInactivityTimerSA expires
    Print Measurements  ue_id=1
    Verify A4event Activation

    Sleep    5s
    Stop Tcpdump On Remote Interface
    Kill Latest Tshark Process  ${tcpdump_process}
    Copy Capture File To Analyse Folder  file=UE1  source_file=${TSHARKALIAS_XN_PATH}

    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}

    Setup Tshark    eth1
    Log To Console With Timestamp  log=## Create A4 pdml file with filter "${RRC_Reconf_EventA4}"
    read_pcap_and_save_to_file
    ...   filename=${A4_PDML_XML}
    ...   packet_filter=${RRC_Reconf_EventA4}
    ...   output_type=pdml
    ...   pcap_file_path=${A4_WS_PCAP}
    Teardown Tshark

    ${A4_result}=  Run Keyword And Continue On Failure  SA Verify A4 Measurement RSRP From PDML  file=${A4_PDML_XML}
    ...     threshold=25
    ...     hysteresis=0
    ...     trigger=ms40

    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C07502    >0       NRRCC_A4_MEAS_IMM_REC
    ...    M55124C07501    >0       NRRCC_RRC_RELEASE_IMM_ENDC_LTE
    ...    M55124C00001    >0       NRRCC_RRC_RELEASE_SENT
    ...    M55190C00001    >0       SA_MEAS_PROFILE_SELECTED
    ...    M55188C00001    >0       IEF_MEAS_PROFILE_CONF_ATT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  UE Deregister  ue_id=1
    ...  AND  Testcase Teardown

CB008127-AB-B6-ALT3-4-T03-Activate-Inter-Freq-A4-measurement-For-EN-DC-Aware-Traffic-Steering-With-Legacy-Parameters

    [Tags]    TC03
    [Documentation]
    ...  DESCRIPTION:  This test case verifies Measurement Profile selection for Inter-Freq EventA4 measurement for
    ...    Idle mode mobility EN-DC aware traffic steering using Legacy feature configuration (NRCELL/NRHOIF)
    ...    after UE Inactivity timer (drbInactivityTimerSA) expires.
    ...    In this test is verified situations:
    ...      a) Feature is disabled for SA
    ...      b) Matching UE PowerClass and freqBandIndicatorNR is not found from Measurement Profile mapping table
    ...      c) UE PowerClass is found from Measurement Profile mapping table, but there is no match for target cell ssbFrequency
    ...         and nrMeasPrIefDefaultDN is not set.
    ...      d) Matching rule for UE found from Measurement Profile mapping table (NRMEASPR_MA_SA) and DN to configuration
    ...         table NRMEASPR_IEF exists, but data is only partly filled. Parameter a4MeasEnDcSteeringSsbRsrp or
    ...         or a4MeasEnDcSteeringSsbRsrq is missing.
    ...
    ...  test execution
    ...    a) actMeasurementProfile=NSA
    ...    1. Register UE-1 in gNB-2 cell-1 and establish a PDU session
    ...    2. Wait until UE Inactivity timer expires (drbInactivityTimerSA)
    ...    3. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that EventA4 threshold, hysteresis
    ...       and time_to_trigger are filled according NRCELL/NRHOIF MO using rsrp criteria.
    ...    4. Deregister UE-1
    ...
    ...    b) No match Measurement Profile mapping table
    ...    5. Activate feature actMeasurementProfile=SA
    ...    6. Remove matching record from Measurement Profile mapping table (NRMEASPR_MA_SA)
    ...    7. Register UE-1 in gNB-2 cell-1 and establish a PDU session
    ...    8. Wait until UE Inactivity timer expires (drbInactivityTimerSA)
    ...    9. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that EventA4 threshold, hysteresis
    ...       and time_to_trigger are filled according NRCELL/NRHOIF MO using rsrp criteria.
    ...    10. Deregister UE-1
    ...
    ...    c)  NRMEASPR_MA_SA no match for target cell ssbFrequency and nrMeasPrIefDefaultDN not set.
    ...    11. Change matching target cell ssbFrequency in Measurement Profile mapping table (NRMEASPR_MA_SA) old frequency + 1
    ...    12. Register UE-1 in gNB-2 cell-1 and establish a PDU session
    ...    13. Wait until UE Inactivity timer expires (drbInactivityTimerSA). Based on UE's PowerClass and target cell
    ...        ssbFrequency a match is not found from mapping-MO table
    ...    14. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that EventA4 threshold, hysteresis
    ...       and time_to_trigger are filled according NRCELL/NRHOIF MO using rsrp criteria.
    ...    15. Deregister UE-1
    ...
    ...    d) Partial Measurement profile configuration in NRMEASPR_IEF
    ...    16. Change ssbFrequency in Measurement Profile mapping table to match target cell
    ...    17. Remove a4MeasEnDcSteeringSsbRsrp from matching record of NRMEASPR_IEF.
    ...    18. Register UE-1 in gNB-2 cell-1 and establish a PDU session
    ...    19. Wait until UE Inactivity timer expires (drbInactivityTimerSA). Based on UE's PowerClass and target cell
    ...        ssbFrequency a match is found from mapping-MO table
    ...    20. Verify from rrcReconfiguration.measConfig.reportConfigToAddModList that EventA4 threshold, hysteresis
    ...        and time_to_trigger are filled according Legacy feature NRCELL/NRHOIF/ssbFrequency using rsrp criteria
    ...
    ...  expected results
    ...    1. PDU session is established for UE
    ...    2-3. EventA4 measurement configuration values are according Legacy feature
    ...         NRCELL/NRHOIF/ssbFrequency with rsrp criteria (a4MeasEnDcSteeringSsbRsrp)
    ...    7. PDU session is established for UE
    ...    8-9. EventA4 measurement configuration values are according Legacy feature
    ...         NRCELL/NRHOIF/ssbFrequency with rsrp criteria (a4MeasEnDcSteeringSsbRsrp)
    ...    18. PDU session is established for UE
    ...    19-20. EventA4 measurement configuration values are according Legacy feature
    ...         NRCELL/NRHOIF/ssbFrequency with rsrp criteria (a4MeasEnDcSteeringSsbRsrp)
    ...
    ...  PRECONDITION: - 5GC000706: Inter-frequency handover via Xn (SA option 2) activated (actInterFreqHoSA=true,
    ...                    NRCELL/NRHOIF/ssbFrequency = 2079166
    ...                - CB008696: 5G Idle mode Traffic from NR SA to LTE EN-DC carrier activated:
    ...                    NRBTS/actIdlMMEnDcSteering = true
    ...                    NRCELL/dleMMEnDcSteeringPercentageOfUes = 100
    ...                    NRCELL/idleMMEnDcSteeringSsbFrequency = 2079166
    ...                    NRCELL/NRHOIF/a4MeasEnDcSteeringEnabled = rsrp
    ...                    NRCELL/NRHOIF/a4MeasEnDcSteeringSsbRsrp
    ...                    NRCELL/NRHOIF/a4MeasEnDcSteeringSsbRsrq
    ...                - Simulated and real gNB cells defined as neighbour cells for Inter-Freq handovers
    ...                - CB008127-AB MeasurementProfile activated,(actMeasurementProfile= SA or SA+NSA)
    ...                - A4 Inter-Frequency HO parameter values filled in Measurement profiles (NRMEASPR_IEF)
    ...                - PowerClass and target cell ssbFrequency based matching rules filled in Measurement Profiles
    ...                  mapping table (NRMEASPR_MA_SA)
    ...                - Mapping-MO Default Distinguished Name values filled (nrMeasPrIefDefaultDN)
    ...                - Mapping-MO DN list filled in NRBTS.NRCELL (nrMeasPrMaSAList)
    ...                - UE fills PowerClass IE into ueCapabilityInformation message sent to gNB.
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:              AEQE
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_20746, CB_FIM_39611
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-165981
    ...
    ...  FEATURE SUB-ITEMS: CB008127-AB  SA measurement profile selection based on UE power class
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
    ...  REFERENCES:  CFAM CB008127-AB
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008127-AB
    ...
    ...            [03.07.2023] - Test plan and test case documentation created
    ...            [03.07.2023] - Test plan and test case review, proposed (ready for review)
    ...            [14.07.2023] - Test plan and test case review, approved - https://collab.ext.net.nokia.com/ui#review:id=878763
    ...            [dd.mm.2023] - Code review for test suite and cases completed:
    ...                         - https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/nnnnn

    Find Scfc And Fix And Send Full Commissioning    scfc3.xml
    Wait For Testline Icmp Echo Replies And Ssh Services
    Wait for gNB Configured state
    Check Radios Availability
    Links up

    #a) actMeasurementProfile=NSA

    Delta Commissioning Single Parameter Value
    ...    parameter=actMeasurementProfile
    ...    value=NSA
    ...    dist_name=MRBTS-1/NRBTS-1

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface

    Set Test Variable    ${TSHARKALIAS_XN}       ${alias}
    Set Test Variable    ${TSHARKALIAS_XN_PATH}  ${log_filepath}

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=1
    ...    meas_id=1
    ...    a4MeasEnDcSteeringEnabled=rsrp

    Log To Console With Timestamp    Measurements after drbInactivityTimerSA expires
    Print Measurements  ue_id=1
    Verify A4event Activation

    Sleep    5s
    Stop Tcpdump On Remote Interface
    Kill Latest Tshark Process  ${tcpdump_process}
    Copy Capture File To Analyse Folder  file=UE1_MeasPR_NSA  source_file=${TSHARKALIAS_XN_PATH}

    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}

    Setup Tshark    eth1
    Log To Console With Timestamp  log=## Create A4 pdml file with filter "${RRC_Reconf_EventA4}"
    read_pcap_and_save_to_file
    ...   filename=${A4_MeasPR_NSA_PDML_XML}
    ...   packet_filter=${RRC_Reconf_EventA4}
    ...   output_type=pdml
    ...   pcap_file_path=${A4_MeasPR_NSA_WS_PCAP}
    Teardown Tshark

    ${A4_result}=  Run Keyword And Continue On Failure  SA Verify A4 Measurement RSRP From PDML  file=${A4_MeasPR_NSA_PDML_XML}
    ...     threshold=2
    ...     hysteresis=6
    ...     trigger=ms40

    UE Deregister  ue_id=1

    #no mapping MO (NRMEASPR_MA_SA-X) configured with 'pcCapabilityList' which matches the UE's power class
    #for the band NRHOIF-X.freqBandIndicatorNR

    Find SCFC and Send Delta Commissioning    scfc_filename=Delta_Step6.json

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface

    Set Test Variable    ${TSHARKALIAS_XN}       ${alias}
    Set Test Variable    ${TSHARKALIAS_XN_PATH}  ${log_filepath}

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=1
    ...    meas_id=1
    ...    a4MeasEnDcSteeringEnabled=rsrp

    Log To Console With Timestamp    Measurements after drbInactivityTimerSA expires
    Print Measurements  ue_id=1
    Verify A4event Activation

    Sleep    5s
    Stop Tcpdump On Remote Interface
    Kill Latest Tshark Process  ${tcpdump_process}
    Copy Capture File To Analyse Folder  file=UE1_No_match_MeasPR_PC  source_file=${TSHARKALIAS_XN_PATH}

    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}

    Setup Tshark    eth1
    Log To Console With Timestamp  log=## Create A4 pdml file with filter "${RRC_Reconf_EventA4}"
    read_pcap_and_save_to_file
    ...   filename=${A4_NO_MATCH_MEASPR_PC_PDML_XML}
    ...   packet_filter=${RRC_Reconf_EventA4}
    ...   output_type=pdml
    ...   pcap_file_path=${A4_NO_MATCH_MEASPR_PC_WS_PCAP}
    Teardown Tshark

    ${A4_result}=  Run Keyword And Continue On Failure  SA Verify A4 Measurement RSRP From PDML  file=${A4_NO_MATCH_MEASPR_PC_PDML_XML}
    ...     threshold=2
    ...     hysteresis=6
    ...     trigger=ms40

    UE Deregister  ue_id=1

    #mapping MO (NRMEASPR_MA_SA-X) configured which matches the UE's power class for the band NRHOIF-X.freqBandIndicatorNR
    #but the corresponding NRMEASPR_MA_SA-X. nrMeasPrIefList does not contain the ssbFrequency of NRHOIF-X (NRHOIF-X.ssbFrequency)
    #and NRMEASPR_MA_SA-X. nrMeasPrIefDefaultDN has not been set

    Find SCFC and Send Delta Commissioning    scfc_filename=Delta_Step11.json

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface

    Set Test Variable    ${TSHARKALIAS_XN}       ${alias}
    Set Test Variable    ${TSHARKALIAS_XN_PATH}  ${log_filepath}

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=1
    ...    meas_id=1
    ...    a4MeasEnDcSteeringEnabled=rsrp

    Log To Console With Timestamp    Measurements after drbInactivityTimerSA expires
    Print Measurements  ue_id=1
    Verify A4event Activation

    Sleep    5s
    Stop Tcpdump On Remote Interface
    Kill Latest Tshark Process  ${tcpdump_process}
    Copy Capture File To Analyse Folder  file=UE1_No_Match_SsbFreq_MeasPR  source_file=${TSHARKALIAS_XN_PATH}

    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}

    Setup Tshark    eth1
    Log To Console With Timestamp  log=## Create A4 pdml file with filter "${RRC_Reconf_EventA4}"
    read_pcap_and_save_to_file
    ...   filename=${A4_NO_MATCH_SSBFREQ_MEASPR_PDML_XML}
    ...   packet_filter=${RRC_Reconf_EventA4}
    ...   output_type=pdml
    ...   pcap_file_path=${A4_NO_MATCH_SSBFREQ_MEASPR_WS_PCAP}
    Teardown Tshark

    ${A4_result}=  Run Keyword And Continue On Failure  SA Verify A4 Measurement RSRP From PDML  file=${A4_NO_MATCH_SSBFREQ_MEASPR_PDML_XML}
    ...     threshold=2
    ...     hysteresis=6
    ...     trigger=ms40

    UE Deregister  ue_id=1

    #mapping MO (NRMEASPR_MA_SA-X) configured which matches the UE's power class for the band NRHOIF-X.freqBandIndicatorNR
    #and there is an Inter-Freq measurement profile configured for NRHOIF-X's ssbFrequency ('NRHOIF-X.ssbFrequency')
    #but the corresponding NRMEASPR_IEF-X. a4MeasEnDcSteeringSsbRsrp or NRMEASPR_IEF-X. a4MeasEnDcSteeringSsbRsrq has not been configured

    Find SCFC and Send Delta Commissioning    scfc_filename=Delta_Step17.json

    ${tcpdump_process}  ${log_filepath}  ${alias}  Start Tcpdump On Remote Interface

    Set Test Variable    ${TSHARKALIAS_XN}       ${alias}
    Set Test Variable    ${TSHARKALIAS_XN_PATH}  ${log_filepath}

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5

    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2  pdu_id=1  gw_id=1  nwslice=1  CA=${False}

    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=1
    ...    meas_id=1
    ...    a4MeasEnDcSteeringEnabled=rsrp

    Log To Console With Timestamp    Measurements after drbInactivityTimerSA expires
    Print Measurements  ue_id=1
    Verify A4event Activation

    Sleep    5s
    Stop Tcpdump On Remote Interface
    Kill Latest Tshark Process  ${tcpdump_process}
    Copy Capture File To Analyse Folder  file=UE1_No_A4Meas_MeasPR  source_file=${TSHARKALIAS_XN_PATH}

    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}

    Setup Tshark    eth1
    Log To Console With Timestamp  log=## Create A4 pdml file with filter "${RRC_Reconf_EventA4}"
    read_pcap_and_save_to_file
    ...   filename=${A4_NO_A4MEAS_MEASPR_PDML_XML}
    ...   packet_filter=${RRC_Reconf_EventA4}
    ...   output_type=pdml
    ...   pcap_file_path=${A4_NO_A4MEAS_MEASPR_WS_PCAP}
    Teardown Tshark

    ${A4_result}=  Run Keyword And Continue On Failure  SA Verify A4 Measurement RSRP From PDML  file=${A4_NO_A4MEAS_MEASPR_PDML_XML}
    ...     threshold=2
    ...     hysteresis=6
    ...     trigger=ms40

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  UE Deregister  ue_id=1
    ...  AND  Testcase Teardown
