*** Settings ***

Documentation
...
...  INTRODUCTION:
...      When deployed in 3GPP Standalone Architecture Option 2, the gNB supports the RRC Connection Re-establishment procedure during
...      Inter-gNB Handover to a prepared target gNB. A prepared gNB is a gNB that has received a Handover Request (via Xn or NG interface)
...      including ReestablishmentInfo IE and optionally including ReestabNCellInfo IE. Target gNB uses ReestablishmentInfo IE to identify
...      already allocated resources during the HO when the RRE is received. This is referred to as UE context retrieval.
...
...      There are various situations, where Re-establishment procedure cannot be perfomed by responding with RRCReestablishment message,
...      but rather RRCSetup message is sent. This is also referred to as Fallback to RRCSetup.
...
...			 The RRC Connection Re-establishment is done via RRCSetup procedure in case:
...
...       - RRC Reestablishment request is received before sending out XnAP: HandoverRequestAcknowledge
...       - RRC Reestablishment request is received with cause reconfiguration failure
...       - UE context retrieval fails due to invalid shortMAC-I, unknown C-RNTI or cell being unprepared
...       - CB008699 triggered Full RRC Configuration is applied during the handover
...       - Target gNB cannot apply the Security algorithm used on the source side
...
...      Note! Xn handover part using TDD/FDD band radios is verified in this test plan. NG handover part will be tested by Ulm ET
...
...      AirPhone simulator EFS and egate commands for the feature:
...      https://confluence.ext.net.nokia.com/display/AirPhoneWTS/CB008574+RRC+connection+re-establishment+under+a+prepared+gNB+SA
...
...  TEST SET NAME:  CB008574-B-B1, CB008574-B-B3, CB008574-B-B5, CB008574-B-B8, CB008574-B-B9
...
...  TESTING SCOPE:  CB008574-B - RRC Connection Re-establishment under a prepared gNB via RRCSetup
...
...  PRECONDITIONS:
...
...  TEST ENVIRONMENT #1 - #TESTLINE_FDD:
...       HARDWARE ID:           ASIL, ABIO, AHLOA (FDD band 71), AHFIB (FDD band 66)
...
...                              Real gNB-2:
...                              NRCELL-1 band 71 FDD
...                              NRCELL-2 band 66 FDD
...
...                              Simulated gNB-3:
...                              NRCELL-1 band 71 FDD
...                              NRCELL-2 band 66 FDD
...
...       ENVIRONMENT ELEMENTS:  Simulated 5GC, real gNB-2, simulated gNB-3
...       TESTLINE:              CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...
...  TEST ENVIRONMENT #2 - #TESTLINE_TDD:
...       HARDWARE ID:           ASIL, ABIO, AQHA (TDD band 41), AEQE (TDD band 78)
...
...                              Real gNB-2:
...                              NRCELL-1 band 41 TDD
...                              NRCELL-2 band 78 TDD
...
...                              Simulated gNB-3:
...                              NRCELL-1 band 41 TDD
...                              NRCELL-2 band 78 TDD
...
...       ENVIRONMENT ELEMENTS:  Simulated 5GC, real gNB-2, simulated gNB-3
...       TESTLINE:              CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...
...
...                5GC000732 is enabled (MRBTS/NRBTS/rrcReestabTypeSA set to 1 (sameGNB)) on real gNB
...                CB008574-SR is enabled (MRBTS/NRBTS/actInterGnbRREPreparedCell=true) on real gNB
...                5GC000704 Intra-frequency HO activated (actIntraFreqHoSA=true)
...                5GC000706 Inter-frequency HO activated (actInterFreqHoSA=true)
...                5GC000786 Voice over NR enabled (actVoNR=true)
...                Simulated and real gNB cells defined as neighbour cells for intra and inter-freq handovers, Measurement events A2 and A3 enabled
...
...                Measurements:    55147 - NR Mobility CU (miNrMobilityReportCu=5min)
...                                 55124 - NR RRC Interface Report per CELL (miNrRRCC=5min)
...
...                Trace Session with PCMD content is configured on real gNB (on CU and DU):
...                  -TCE is configured under MNL/TCEADM MOC and connected with TCE "sim" running on UTE
...                  -The feature flag NRBTS-actPCMDReport for activating PCMD functionality is set to true
...                  -NRBTS/NRCTRLTS/NRMTRACECU MOC is configured with nrTceIdentifier set to TCE-tceIdentifier,
...                    scope set to allResources, actPCMDReporting set to true, jobType set to TraceOnly or ImmediateMDTAndTrace
...                  -Max number of traced UEs is not reached (NRBTS/NRCTRLTS/NRMTRACECU-cellMaxActiveUEsTraced)
...                  -NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU MOC is configured with nrTceIdentifier set to TCE-tceIdentifier,
...                    scope set to allResources, actPCMDReporting set to true, jobType set to TraceOnly
...                  -Max number of traced UEs is not reached (NRBTS/NRDU/NRCTRLTSDU/NRMTRACEDU-cellMaxActiveUEsTraced)
...
...                Wireshark with latest available NSETAP-X plugin supporting CB008574 content
...                  (for capturing interface traces and decoding PCMD records)
...
...                For FDD setup: Carrier aggregation CA FDD+FDD (5GC001167) configured
...                               UEs that support 5G SA with FDD bands 66 and 71 and CA, A2/A3 events with mgaps, VoNR
...                               UEs without CA support
...                For TDD setup: Carrier aggregation CA TDD+TDD (CB007922) configured
...                               UEs that support 5G SA with TDD bands 41 and 78 and CA, A2/A3 events with mgaps, VoNR
...                               UEs without CA support
...
...  DEPENDENCIES:  CB008574 CFAM chapter 1.3.4 Feature Dependencies
...
...  TEST INSTANCE SPECIFIC NOTES:
...      Case 1: CB008574-B-B1_001_XnHOTarget-RRE_to_target_cell_before_HO_Req_Ack-FDD
...      TEST CASE NAME - CB008574-B-B1_001_XnHOTarget-RRE_to_target_cell_before_HO_Req_Ack-FDD
...      Purpose: This test verifies RRC Reestablishment handling when received by Target gNB before sending out
...               XnAP: HandoverRequestAcknowledge
...      Case 5: CB008574-B-B3_001_XnHOTarget-RRE_to_target_cell_with_cause_reconfFailure-FDD
...      TEST CASE NAME - CB008574-B-B3_001_XnHOTarget-RRE_to_target_cell_with_cause_reconfFailure-FDD
...      Purpose: This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
...               in handover target FDD cell with cause reconfiguration failure
...      Case 7: CB008574-B-B3_003_Robustness_XnHOTarget-RRE_to_unprepared_cell_with_cause_reconfFailure-FDD
...      TEST CASE NAME - CB008574-B-B3_003_Robustness_XnHOTarget-RRE_to_unprepared_cell_with_cause_reconfFailure-FDD
...      Purpose: This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
...               in an unprepared FDD cell with cause reconfiguration failure
...      Case 10: CB008574-B-B5_002_XnHOTarget-RRE_to_prepared_cell_with_invalid_shortMAC-I_or_unknown_C-RNTI_received-FDD
...      TEST CASE NAME - CB008574-B-B5_002_XnHOTarget-RRE_to_prepared_cell_with_invalid_shortMAC-I_or_unknown_C-RNTI_received-FDD
...      Purpose: This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
...               in a prepared FDD cell with either invalid shortMAC-I or unknown C-RNTI
...      Case 12: CB008574-B-B5_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-FDD
...      TEST CASE NAME - CB008574-B-B5_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-FDD
...      Purpose: This test verifies that fallback to RRCSetup is done with parameter actInterGnbRREPreparedCell
...               both values True/False in case RRC Reestablishment request is received with either invalid
...               shortMAC-I or unknown C-RNTI
...      Case 13: CB008574-B-B8_001_XnHOTarget-Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover-FDD
...      TEST CASE NAME - CB008574-B-B8_001_XnHOTarget-Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover-FDD
...      Purpose: This test case verifies interaction with CB008699 Full RRC Configuration for SA Handover,
...               where fallback to RRC Setup procedure is performed
...      Case 14: CB008574-B-B9_001_XnHOTarget-Security_algorithm_validation_failure-TDD
...
...  CONTACTS:
...  Author:		      Huhta, Johan (Nokia - FI/Espoo) <johan.huhta@nokia.com>
...  FOT leader:          Narayanan, Iyer (Nokia - DE/Ulm)
...  CFAM leader:         Li, Gong (NSB - CN/Hangzhou)
...  EFS author:          -
...  Feature Test Lead:   Haberer, Manfred (Nokia - DE/Ulm)
...
...    Full list of FOT members can be found from FOT pages:
...    https://nokia-my.sharepoint.com/personal/iyer_narayanan_nokia_com/_layouts/15/Doc.aspx?sourcedoc={2867c41f-5a2c-45f7-b67d-c8d5b1a78bef}
...    &action=edit&wd=target%28Dashboard.one%7Cc8e398e6-18bc-49e9-ad7b-86392913a1ef%2FFOT%20members%7Cdc61c0e5-5f87-4ed5-96b4-4a23c077bad4%2F%29
...    &wdorigin=NavigationUrl
...
...  REFERENCES:  CFAM CB008574
...
...  HISTORY:  History, current status and TC description is available in repository:
...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
...
...            [02.05.2023] - Test plan and test case documentation created
...            [03.05.2023] - Test plan and test case documentation, proposed (ready for review)
...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572


Resource    ../../resources/keywordbook-resourceUsage.robot
Resource    CB008574-B_keywords.robot
Resource    ../Common/test_keywords.robot
Resource    ../Common/test_variables.robot
Library     ../Common/test_keywords.py
Variables   ../Common/test_variables.py

Suite Setup      CB008574-B Testsuite Setup
Suite Teardown   Testsuite TearDown

Test Setup       Testcase Setup
Test Teardown    Testcase Teardown


*** Variables ***
${IPHY_DIR_PATH}             /opt/iphy
${EPCSIM_DIR_PATH}           ${IPHY_DIR_PATH}/latest
${EPCSIM_CFG_PATH}           ${CURDIR}/config/basic_setup_FDD.cfg
${IPHY_XML}                  ${CURDIR}/config/iphy_FDD.xml
${SWCONFIG}                  ${CURDIR}/config/sm_swconfig_FDD.txt
${SWCONFIG_AP}               ${CURDIR}/config/sim_swconfig_FDD.txt
${SCFC_FILE}                 scfc_FDD.xml
${ROBOT_SUITE_DIR}           ${CURDIR}
${timerHOGuard}              2500
${tWaitingRlRecoverSA}       5000


*** Test Cases ***
CB008574-B-B1_001_XnHOTarget-RRE_to_target_cell_before_HO_Req_Ack-FDD
    [Tags]    TC01

    [Documentation]
    ...  DESCRIPTION:  This test verifies that when RRC Reestablishment request is received by Target gNB before sending out
    ...                XnAP: HandoverRequestAcknowledge, the inter-gNB Xn Handover is correctly aborted (XNAP: Handover Preparation Failure)
    ...                and UE connection is established with fallback to RRCSetup
    ...                The RRC Reestablishment request is received in the handover target FDD cell
    ...
    ...  PRECONDITION: USCB008574-B#B1: RRC Reestablishment request received by Target gNB before sending out XnAP: HandoverRequestAcknowledge
    ...                message to Source gNB during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has received
    ...        HandoverRequest but before it has responded with HandoverRequestAcknowledge
    ...    4.  Verify handover for UE-1 is aborted and UE-1 connection is successfully established to gNB-2 cell-1 with
    ...        RRCSetup procedure
    ...    5.  Verify relevant PM counters
    ...    6.  Verify relevant PCMD records
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends XNAP: Handover Preparation Failure with Radio Network Layer Cause set to Unspecified
    ...        gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...    5.  PM counter values:
    ...        gNB-2 cell-1
    ...         - M55124C00502 RRC_REESTAB_FALLBACK = 1
    ...         - M55124C00504 RRC_REESTAB_HO_FAILURE = 1
    ...         - M55124C00505 RRC_REESTAB_OTHER_FAILURE = 0
    ...         - M55124C00511 REESTAB_ACC_HO_FAIL = 0
    ...         - M55124C00512 REESTAB_ACC_OTHER_FAIL = 0
    ...         - M55124C00515 REESTAB_ACC_FALLBACK = 1
    ...         - M55143C00009 HO_PREP_FAIL_SENT_OTH = 1
    ...    6.  PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4547
    ...
    ...  POSTCONDITION:  -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19155
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-134751
    ...
    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS: Refer to test plan section
    ...
    ...  REFERENCES: Refer to test plan section
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
    ...
    ...            [02.05.2023] - Test plan and test case documentation created
    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
    ...            [xx.xx.2023] - Testcase GIT review completed : <add link when done>

    Wait Until Keyword Succeeds     60min     30sec     CB008574-B-B1_001_scenario

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Execute Egate Command    cmd=gnb_param id=3 delay_proc_measurement_report=none
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Testcase Teardown

CB008574-B-B3_001_XnHOTarget-RRE_to_target_cell_with_cause_reconfFailure-FDD
    [Tags]    TC05    AP_REG

    [Documentation]
    ...  DESCRIPTION:  This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
    ...                in handover target FDD cell with cause reconfiguration failure
    ...                Scell addition (after RRC setup and initial context establishment) for UE is also verified
    ...
    ...  PRECONDITION: USCB008574-B#B3: RRC Reestablishment request with cause reconfiguration failure during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause reconfFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed. Verify that Scell is added
    ...    5.  Verify relevant PM counters
    ...    6.  Verify relevant PCMD records
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...        Scell is successfully added
    ...    5.  Related handover failure counters are updated
    ...    6.  PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4565
    ...
    ...  POSTCONDITION:  -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19156
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-139597
    ...
    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS: Refer to test plan section
    ...
    ...  REFERENCES: Refer to test plan section
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
    ...
    ...            [02.05.2023] - Test plan and test case documentation created
    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
    ...            [28.06.2023] - Testcase GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/74192

    Get Resources Taken Before_test
    Wait For Next Full Pm Interval
    CB008574-B Start PCMD Capture

    Execute Egate Command  cmd=ue_enb_param id=3 drx_config=sl20:1 measurement_gap=off
    Delta Commissioning Single Parameter Value  actBufferBasedSCellAddition  oneShot_Dl_Fr1  MRBTS-1/NRBTS-1
    Delta Commissioning Single Parameter Value  sCellAdditionMethod  covBasedA1  MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=7
    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=9
    Establish Pdu Session For UE  ue_id=3  pdu_id=2  nwslice=1  gw_id=2
    Execute Egate Command  cmd=ue_gnb_param id=3 drx_config=on

    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=1    cause=reconfigurationFailure    crnti=source
    Set Sim Automatic Neighbour Relation    pci=50
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid
    ${tcpdump_process}    Perform Xn Handover  ue_id=3  phycell_id=50  direction=incoming  carrier_freq2=126530  fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}

    @{QFIs}=  Set variable    1  2
    Start And Stop Data On All QFIs  ue_id=3  pdu=1  qfis=${QFIs}  throughput=70000  CA=${True}  phys_pcell=50  a1CovBasedCA=${True}
    ...  carrier_freq=126530

    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...  M55124C00501  0  RRC_REESTAB_DISCARD
    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
    ...  M55124C00503  1  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00504  0  RRC_REESTAB_HO_FAILURE
    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
    ...  M55124C00518  0  REESTAB_ACC_VONR
    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55127C00501  1  RRC_REESTAB_RECONF_FAILURE_DU
    ...  M55127C00502  0  RRC_REESTAB_HO_FAILURE_DU
    ...  M55127C00503  0  RRC_REESTAB_OTHER_FAILURE_DU
    ...  M55127C00510  0  REESTAB_ACC_RECONF_FAIL_DU
    ...  M55127C00511  0  REESTAB_ACC_HO_FAIL_DU
    ...  M55127C00512  0  REESTAB_ACC_OTHER_FAIL_DU
    ...  M55127C00513  0  RRC_REESTAB_DISCARD_DU
    ...  M55117C01009  1  NF1CD_UE_CTXT_REL_COMMAND_RECD
    ...  M55117C01010  1  NF1CD_UE_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  1  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  1  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55145C00222  0  SUCC_NGBR_DRB_INTERGHO_SA_PLMN
    ...  M55145C00361  1  SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...  M55145C00362  0  SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489
    ...    file_path=${pm_counter_file}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    interrupt=${True}

    UE Deregister  ue_id=3
    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Execute Egate Command  cmd=ue_enb_param id=3 reset
    ...  AND  Execute Egate Command  cmd=ue_gnb_param id=3 reset
    ...  AND  Delta Commissioning Single Parameter Value  actBufferBasedSCellAddition  disabled  MRBTS-1/NRBTS-1
    ...  AND  Delta Commissioning Single Parameter Value  sCellAdditionMethod  blind  MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...  AND  Testcase Teardown

CB008574-B-B3_003_Robustness_XnHOTarget-RRE_to_unprepared_cell_with_cause_reconfFailure-FDD
    [Tags]    TC07

    [Documentation]
    ...  DESCRIPTION:  This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
    ...                in an unprepared FDD cell with cause reconfiguration failure
    ...
    ...  PRECONDITION: USCB008574-B#B3: RRC Reestablishment request with cause reconfiguration failure during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session including 5QI-1 (VoNR) bearer for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-2 not included in ReestabNCellInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause reconfFailure in gNB-2 cell-2 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-2 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Verify relevant PM counters
    ...    6.  Verify relevant PCMD records
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    5.  Related handover failure counters are updated
    ...    6.  PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4565
    ...
    ...  POSTCONDITION:  -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19156
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-139597
    ...
    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS: Refer to test plan section
    ...
    ...  REFERENCES: Refer to test plan section
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
    ...
    ...            [02.05.2023] - Test plan and test case documentation created
    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
    ...            [28.06.2023] - Testcase GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/74192

    Get Resources Taken Before_test
    Wait For Next Full Pm Interval
    CB008574-B Start PCMD Capture

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=7
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=2    cause=reconfigurationFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid
    ${tcpdump_process}    Perform Xn Handover  ue_id=3  phycell_id=50  direction=incoming  carrier_freq2=126530  fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Kill Latest Tshark Process  ${tcpdump_process}

    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...  M55124C00501  1  RRC_REESTAB_DISCARD
    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
    ...  M55124C00503  1  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00504  0  RRC_REESTAB_HO_FAILURE
    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
    ...  M55124C00518  0  REESTAB_ACC_VONR
    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55127C00501  1  RRC_REESTAB_RECONF_FAILURE_DU
    ...  M55127C00502  0  RRC_REESTAB_HO_FAILURE_DU
    ...  M55127C00503  0  RRC_REESTAB_OTHER_FAILURE_DU
    ...  M55127C00510  0  REESTAB_ACC_RECONF_FAIL_DU
    ...  M55127C00511  0  REESTAB_ACC_HO_FAIL_DU
    ...  M55127C00512  0  REESTAB_ACC_OTHER_FAIL_DU
    ...  M55127C00513  0  RRC_REESTAB_DISCARD_DU
    ...  M55117C01009  1  NF1CD_UE_CTXT_REL_COMMAND_RECD
    ...  M55117C01010  1  NF1CD_UE_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  1  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  1  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55145C00222  0  SUCC_NGBR_DRB_INTERGHO_SA_PLMN
    ...  M55145C00361  1  SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...  M55145C00362  0  SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489
    ...    file_path=${pm_counter_file}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup

    UE Deregister  ue_id=3
    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Testcase Teardown

CB008574-B-B5_002_XnHOTarget-RRE_to_prepared_cell_with_invalid_shortMAC-I_or_unknown_C-RNTI_received-FDD
    [Tags]    TC10    AP_REG

    [Documentation]
    ...  DESCRIPTION:  This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
    ...                in a prepared FDD cell with either invalid shortMAC-I or unknown C-RNTI
    ...
    ...  PRECONDITION: USCB008574-B#B5: RRC Reestablishment request with invalid shortMAC-I or unknown C-RNTI or to unprepared
    ...                cell during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-2 included in ReestabNCellInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-2 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...        - shortMAC-I does not match with value stored in step-2
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-2 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    6.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
    ...        - gNB-2 cell-2 included in ReestabNCellInfo IE in HandoverRequest
    ...        - C-RNTI received in handoverPreparationInformation -> newUE-Identity
    ...    7.  UE-2 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-2 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...        - C-RNTI value does not match with value stored in step-6
    ...    8.  Verify UE-2 connection is successfully established to gNB-2 cell-2 with RRCSetup procedure and handover
    ...        procedure started in step-6 is completed
    ...    9.  Verify relevant PM counters
    ...    10. Verify relevant PCMD records
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    8.  Refer to step-4
    ...    9.  Related handover failure counters are updated
    ...    10. PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4565
    ...
    ...  POSTCONDITION:  -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19395
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-139601
    ...
    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS: Refer to test plan section
    ...
    ...  REFERENCES: Refer to test plan section
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
    ...
    ...            [02.05.2023] - Test plan and test case documentation created
    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
    ...            [28.06.2023] - Testcase GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/74192

    CB008574-B Start PCMD Capture
    Wait For Next Full Pm Interval
    Get Resources Taken Before_test

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session    ue_id=3    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=2    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:invalid
    ${tcpdump_process}  Perform Xn Handover    ue_id=3    phycell_id=50    direction=incoming    carrier_freq2=126530    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=3

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    CB008574-B Start PCMD Capture

    UE Register And Establish PDU Session    ue_id=3    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    # configure ue_rrc_reestablish with invalid_crnti
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop
    ${cmd}    Catenate    ue_rrc_reestablish id=3 gnb=2 cell=2 cause=handoverFailure action=invalid_crnti
    ...                   send_after=measurement_report time_to_wait=10
    Execute Egate Command    cmd=${cmd}
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=3    phycell_id=50    direction=incoming    carrier_freq2=126530    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=3

    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...  M55124C00501  2  RRC_REESTAB_DISCARD
    ...  M55124C00502  2  RRC_REESTAB_FALLBACK
    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00504  2  RRC_REESTAB_HO_FAILURE
    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
    ...  M55124C00515  2  REESTAB_ACC_FALLBACK
    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
    ...  M55124C00518  0  REESTAB_ACC_VONR
    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55127C00501  0  RRC_REESTAB_RECONF_FAILURE_DU
    ...  M55127C00502  2  RRC_REESTAB_HO_FAILURE_DU
    ...  M55127C00503  0  RRC_REESTAB_OTHER_FAILURE_DU
    ...  M55127C00510  0  REESTAB_ACC_RECONF_FAIL_DU
    ...  M55127C00511  0  REESTAB_ACC_HO_FAIL_DU
    ...  M55127C00512  0  REESTAB_ACC_OTHER_FAIL_DU
    ...  M55127C00513  2  RRC_REESTAB_DISCARD_DU
    ...  M55117C01009  4  NF1CD_UE_CTXT_REL_COMMAND_RECD
    ...  M55117C01010  4  NF1CD_UE_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  2  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  2  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  2  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  2  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Testcase Teardown

CB008574-B-B5_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-FDD
    [Tags]    TC12

    [Documentation]
    ...  DESCRIPTION:  This test verifies that fallback to RRCSetup is done with parameter actInterGnbRREPreparedCell
    ...                both values True/False in case RRC Reestablishment request is received with either invalid
    ...                shortMAC-I or unknown C-RNTI
    ...                RRC Reestablishment request is received in FDD cell
    ...
    ...  PRECONDITION: USCB008574-B#B5: RRC Reestablishment request with invalid shortMAC-I or unknown C-RNTI or to unprepared
    ...                cell during Inter-gNB Handover via Xn
    ...                 - NRBTS.actInterGnbRREPreparedCell = True
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...        - shortMAC-I does not match with value stored in step-2
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    6.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...        - C-RNTI received in handoverPreparationInformation -> newUE-Identity
    ...    7.  UE-2 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...        - C-RNTI value does not match with value stored in step-6
    ...    8.  Verify UE-2 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-6 is completed
    ...    9.  Perform delta commissioning to modify gNB-2 parameter:
    ...        - NRBTS.actInterGnbRREPreparedCell = False
    ...    10. Repeat steps step-1..step-8
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    8.  Refer to step-4
    ...    10. Refer to step-4 and step-8
    ...
    ...  POSTCONDITION:  -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19395
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-139601
    ...
    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS: Refer to test plan section
    ...
    ...  REFERENCES: Refer to test plan section
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
    ...
    ...            [02.05.2023] - Test plan and test case documentation created
    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
    ...            [28.06.2023] - Testcase GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/74192

    Get Resources Taken Before_test

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session    ue_id=3    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=1    cause=otherFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:invalid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=3    phycell_id=50    direction=incoming    carrier_freq2=126530    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=3

    UE Register And Establish PDU Session    ue_id=3    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    # configure ue_rrc_reestablish with invalid_crnti
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop
    ${cmd}    Catenate    ue_rrc_reestablish id=3 gnb=2 cell=1 cause=otherFailure action=invalid_crnti
    ...                   send_after=measurement_report time_to_wait=10
    Execute Egate Command    cmd=${cmd}
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=3    phycell_id=50    direction=incoming    carrier_freq2=126530    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=3

    Delta Commissioning Single Parameter Value  actInterGnbRREPreparedCell  false  MRBTS-1/NRBTS-1

    UE Register And Establish PDU Session    ue_id=3    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=1    cause=otherFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:invalid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=3    phycell_id=50    direction=incoming    carrier_freq2=126530    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=3

    UE Register And Establish PDU Session    ue_id=3    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    # configure ue_rrc_reestablish with invalid_crnti
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop
    ${cmd}    Catenate    ue_rrc_reestablish id=3 gnb=2 cell=1 cause=otherFailure action=invalid_crnti
    ...                   send_after=measurement_report time_to_wait=10
    Execute Egate Command    cmd=${cmd}
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=3    phycell_id=50    direction=incoming    carrier_freq2=126530    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=3

    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Delta Commissioning Single Parameter Value  actInterGnbRREPreparedCell  true  MRBTS-1/NRBTS-1
    ...  AND  Testcase Teardown

CB008574-B-B8_001_XnHOTarget-Interaction_with_CB008699_Full_RRC_Configuration_for_SA_Handover-FDD
    [Tags]    TC13

    [Documentation]
    ...  DESCRIPTION:  This test case verifies interaction with CB008699 Full RRC Configuration for SA Handover,
    ...                where fallback to RRC Setup procedure is performed
    ...
    ...                Target gNB has triggered full configuration in inter-gNB Xn Handover, and RRC Reestablishment
    ...                request is received during the handover in:
    ...                 - handover target FDD cell
    ...                 - prepared FDD cell
    ...                The CB008699 based Full RRC configuration is triggered with:
    ...                 - DRB to QoS flow mapping based trigger
    ...                 - actForceFullRRCConfigurationSaHo = OnlyXnHo
    ...
    ...  PRECONDITION: USCB008574-B#B8: Interaction with CB008699 Full RRC Configuration for SA Handover
    ...                NRBTS.actForceFullRRCConfigurationSaHo = disabled
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish two PDU sessions with 2 QFI's each for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...        - DRB to QoS flow mapping IE for PDU sessions in HandoverRequest
    ...          - PDU1: All DRBs 1:1
    ...          - PDU2: Mapping IE missing
    ...    3.  UE-1 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Perform delta commissioning to modify gNB-2 parameter:
    ...        - NRBTS.actForceFullRRCConfigurationSaHo = OnlyXnHo
    ...    5.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    6.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    7.  UE-2 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    8.  Verify UE-2 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-6 is completed
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    8.  Refer to step-4
    ...
    ...  POSTCONDITION:  -
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID: ASIL, ABIO
    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_20175
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       PM COUNTERS:                   -
    ...       BACKLOG ID:                    FCA_5G_L2L3-149079
    ...
    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS: Refer to test plan section
    ...
    ...  REFERENCES: Refer to test plan section
    ...
    ...  HISTORY:  History, current status and TC description is available in repository:
    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
    ...
    ...            [02.05.2023] - Test plan and test case documentation created
    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
    ...            [28.06.2023] - Testcase GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/74192

    Get Resources Taken Before_test
    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=7
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=9
    Establish Pdu Session For UE  ue_id=3  pdu_id=2  nwslice=1  gw_id=2
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid

    Wait For Next Full Pm Interval

    ${tcpdump_process}    Perform Xn Handover  ue_id=3  phycell_id=50  direction=incoming  carrier_freq2=126530  fallbackRRCSetup=${False}
    Verify FullConfig CB008574-B    fullConfigSet=${False}
    Verify RRE Msg Flow    fallbackRRCSetup=${False}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister  ue_id=3

    CB008574-B Start PCMD Capture

    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=9
    Establish Pdu Session For UE  ue_id=3  pdu_id=2  nwslice=1  gw_id=2
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid
    # set drb qos mapping for full config
    ${VAR1}    Catenate    action=modify_drb_qos_mapping drb_qos_map_modification=incompatible_mapping pdu_sessions=1
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 ${VAR1}
    ${tcpdump_process}    Perform Xn Handover  ue_id=3  phycell_id=50  direction=incoming  carrier_freq2=126530  fallbackRRCSetup=${True}
    Verify FullConfig CB008574-B    fullConfigSet=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    UE Deregister  ue_id=3
    CB008574-B Start PCMD Capture

    Delta Commissioning Single Parameter Value  actForceFullRRCConfigurationSaHo  onlyXnHo  MRBTS-1/NRBTS-1
    Execute Egate Command  cmd=gnb_xn_handover_preparation_param id=3 reset

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=7
    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=9
    Establish Pdu Session For UE  ue_id=3  pdu_id=2  nwslice=1  gw_id=2
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Set Sim Automatic Neighbour Relation    pci=50
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid
    ${tcpdump_process}    Perform Xn Handover  ue_id=3  phycell_id=50  direction=incoming  carrier_freq2=126530  fallbackRRCSetup=${True}
    Verify FullConfig CB008574-B    fullConfigSet=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    UE Deregister  ue_id=3
    CB008574-B Start PCMD Capture

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=7
    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=9
    Establish Pdu Session For UE  ue_id=3  pdu_id=2  nwslice=1  gw_id=2
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=3    gnb_id=2    cell_id=2    cause=handoverFailure    crnti=source
    Set Sim Automatic Neighbour Relation    pci=50
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}    Perform Xn Handover  ue_id=3  phycell_id=50  direction=incoming  carrier_freq2=126530  fallbackRRCSetup=${True}
    Verify FullConfig CB008574-B    fullConfigSet=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    UE Deregister  ue_id=3

    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...  M55124C00501  2  RRC_REESTAB_DISCARD
    ...  M55124C00502  2  RRC_REESTAB_FALLBACK
    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00504  3  RRC_REESTAB_HO_FAILURE
    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
    ...  M55124C00511  1  REESTAB_ACC_HO_FAIL
    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
    ...  M55124C00515  2  REESTAB_ACC_FALLBACK
    ...  M55124C00516  1  REESTAB_RRCRECONFIG_SUCC
    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
    ...  M55124C00518  0  REESTAB_ACC_VONR
    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55124C00501  1  RRC_REESTAB_DISCARD
    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00504  1  RRC_REESTAB_HO_FAILURE
    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
    ...  M55124C00518  0  REESTAB_ACC_VONR
    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55127C00501  0  RRC_REESTAB_RECONF_FAILURE_DU
    ...  M55127C00502  4  RRC_REESTAB_HO_FAILURE_DU
    ...  M55127C00503  0  RRC_REESTAB_OTHER_FAILURE_DU
    ...  M55127C00510  0  REESTAB_ACC_RECONF_FAIL_DU
    ...  M55127C00511  1  REESTAB_ACC_HO_FAIL_DU
    ...  M55127C00512  0  REESTAB_ACC_OTHER_FAIL_DU
    ...  M55127C00513  3  RRC_REESTAB_DISCARD_DU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55145C00361  4  SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...  M55145C00362  1  SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  6  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  6  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  1  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  1  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]  Run Keywords    Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Delta Commissioning Single Parameter Value  actForceFullRRCConfigurationSaHo  disabled  MRBTS-1/NRBTS-1
    ...  AND  Testcase Teardown

*** Keywords ***
CB008574-B-B1_001_scenario
    Run Keyword And Continue On Failure    Get Resources Taken Before_test
    Run Keyword And Continue On Failure    Wait For Next Full Pm Interval
    Run Keyword And Continue On Failure    CB008574-B Start PCMD Capture
    Run Keyword And Continue On Failure    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Run Keyword And Continue On Failure    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Run Keyword And Continue On Failure    Set Sim Automatic Neighbour Relation    pci=50

    Run Keyword And Continue On Failure    UE Register And Establish PDU Session  ue_id=3  cell_id=1  gnb_id=3  pdu_id=1  gw_id=1  nwslice=1
    Run Keyword And Continue On Failure    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid
    Run Keyword And Continue On Failure    Execute Egate Command    cmd=gnb_param id=3 delay_proc_measurement_report=v1s
    Run Keyword And Continue On Failure    Do RRC Re-establish
    Run Keyword And Continue On Failure    CB008574-B-B1_001 Do Handover
    Run Keyword And Continue On Failure    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Run Keyword And Continue On Failure    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Run Keyword And Continue On Failure    Sleep    5
    Run Keyword And Continue On Failure    CB008574-B Stop PCMD Capture and Convert To TXT
    Run Keyword And Continue On Failure    Verify PCMD Records for Fallback to RRCSetup    interrupt=${True}    RRCSetupCause=3

    Run Keyword And Continue On Failure    Wait For Next Full Pm Interval
    Run Keyword And Continue On Failure    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...  M55124C00501  1  RRC_REESTAB_DISCARD
    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00504  1  RRC_REESTAB_HO_FAILURE
    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
    ...  M55124C00518  0  REESTAB_ACC_VONR
    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
    ...  M55143C00009  1  HO_PREP_FAIL_SENT_OTH
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Run Keyword And Continue On Failure    UE Deregister  ue_id=3
    Run Keyword And Continue On Failure    Get Resources Taken After_test
    Run Keyword And Continue On Failure    Verify Resource Usage

Do RRC Re-establish
    Execute Egate Command    cmd=ue_rrc_reestablish id=3 gnb=2 cell=1 cause=handoverFailure send_after=measurement_report time_to_wait=972ms

CB008574-B-B1_001 Do Handover
    ${tcpdump_process}    Perform Xn Handover
    ...                   ue_id=3  phycell_id=50  direction=incoming  ho_failure=${True}  carrier_freq2=126530  fallbackRRCSetup=${True}
