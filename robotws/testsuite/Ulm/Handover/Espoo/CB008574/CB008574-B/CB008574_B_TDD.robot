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
...      Case 6: CB008574-B-B3_002_XnHOTarget-RRE_to_prepared_cell_with_cause_reconfFailure-TDD
...      TEST CASE NAME - CB008574-B-B3_002_XnHOTarget-RRE_to_prepared_cell_with_cause_reconfFailure-TDD
...      Purpose: This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
...               in a prepared TDD cell with cause reconfiguration failure
...      Case 8: CB008574-B-B3_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-TDD
...      TEST CASE NAME - CB008574-B-B3_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-TDD
...      Purpose: This test verifies that online modification of parameter actInterGnbRREPreparedCell is correctly
...               taken into account in scenario where RRC Reestablishment request is received by Target with
...               cause reconfiguration failure
...      Case 9: CB008574-B-B5_001_XnHOTarget-RRE_to_target_cell_with_invalid_shortMAC-I_or_unknown_C-RNTI_received-TDD
...      TEST CASE NAME - CB008574-B-B5_001_XnHOTarget-RRE_to_target_cell_with_invalid_shortMAC-I_or_unknown_C-RNTI_received-TDD
...      Purpose: This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
...               in handover target TDD with either invalid shortMAC-I or unknown C-RNTI
...      Case 11: CB008574-B-B5_003_XnHOTarget-RRE_to_unpreparedCell-TDD
...      TEST CASE NAME - CB008574-B-B5_003_XnHOTarget-RRE_to_unpreparedCell-TDD
...      Purpose: This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
...               in an unprepared TDD cell after HandoverRequestAcknowledge has been sent
...      Case 14: CB008574-B-B9_001_XnHOTarget-Security_algorithm_validation_failure-TDD
...      TEST CASE NAME - CB008574-B-B9_001_XnHOTarget-Security_algorithm_validation_failure-TDD
...      Purpose: This test verifies that target gNB shall do fallback to RRC Setup RRC in Reestablishment handling
...               during Inter gNB handover via Xn interface in case Security algorithm validation fails
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
${EPCSIM_CFG_PATH}           ${CURDIR}/config/basic_setup_TDD.cfg
${IPHY_XML}                  ${CURDIR}/config/iphy_TDD.xml
${SWCONFIG}                  ${CURDIR}/config/sm_swconfig_TDD.txt
${SWCONFIG_AP}               ${CURDIR}/config/sim_swconfig_TDD.txt
${SCFC_FILE}                 scfc_TDD.xml
${ROBOT_SUITE_DIR}           ${CURDIR}
${timerHOGuard}              6000
${tWaitingRlRecoverSA}       10000

*** Test Cases ***
CB008574-B-B3_002_XnHOTarget-RRE_to_prepared_cell_with_cause_reconfFailure-TDD
    [Tags]    TC06

    [Documentation]
    ...  DESCRIPTION:  This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
    ...                in a prepared TDD cell with cause reconfiguration failure
    ...
    ...  PRECONDITION: USCB008574-B#B3: RRC Reestablishment request with cause reconfiguration failure during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-2 included in ReestabNCellInfo IE in HandoverRequest
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
    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50
    Wait For Next Full Pm Interval
    CB008574-B Start PCMD Capture

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=2    cause=reconfigurationFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}

    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    Verify Any Counters In File
    ...  M55124C00501  0  RRC_REESTAB_DISCARD
    ...  M55124C00502  0  RRC_REESTAB_FALLBACK
    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
    ...  M55124C00515  0  REESTAB_ACC_FALLBACK
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

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
    ...  M55127C00513  1  RRC_REESTAB_DISCARD_DU
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
    ...  M55113C01009  0  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  0  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55145C00222  0  SUCC_NGBR_DRB_INTERGHO_SA_PLMN
    ...  M55145C00361  1  SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...  M55145C00362  0  SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/MCC-311/MNC-489
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55145C00222  0  SUCC_NGBR_DRB_INTERGHO_SA_PLMN
    ...  M55145C00361  0  SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...  M55145C00362  0  SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2/MCC-311/MNC-489
    ...    file_path=${pm_counter_file}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    interrupt=${True}

    UE Deregister    ue_id=1
    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
    ...    AND    Run keyword and ignore error   UE Deregister    ue_id=1
    ...    AND    Testcase Teardown

CB008574-B-B3_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-TDD
    [Tags]    TC08

    [Documentation]
    ...  DESCRIPTION:  This test verifies that online modification of parameter actInterGnbRREPreparedCell is correctly
    ...                taken into account in scenario where RRC Reestablishment request is received by Target with
    ...                cause reconfiguration failure
    ...
    ...  PRECONDITION: USCB008574-B#B3: RRC Reestablishment request with cause reconfiguration failure during Inter-gNB Handover via Xn
    ...                gNB-2
    ...                 - NRBTS.actInterGnbRREPreparedCell = True
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause reconfFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Perform delta commissioning to modify gNB-2 parameter:
    ...        - NRBTS.actInterGnbRREPreparedCell = False
    ...    6.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    7.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    8.  UE-2 sends RRC Reestablishment request with cause reconfFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    9.  Verify UE-2 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    9.  Refer to step-4
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
    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=reconfigurationFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    Delta Commissioning Single Parameter Value  actInterGnbRREPreparedCell  false  MRBTS-1/NRBTS-1

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=reconfigurationFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
    ...    AND    Run keyword and ignore error   UE Deregister    ue_id=1
    ...    AND    Delta Commissioning Single Parameter Value  actInterGnbRREPreparedCell  true  MRBTS-1/NRBTS-1
    ...    AND    Testcase Teardown

CB008574-B-B5_001_XnHOTarget-RRE_to_target_cell_with_invalid_shortMAC-I_or_unknown_C-RNTI_received-TDD
    [Tags]    TC09

    [Documentation]
    ...  DESCRIPTION:  This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
    ...                in handover target TDD cell with either invalid shortMAC-I or unknown C-RNTI
    ...
    ...  PRECONDITION: USCB008574-B#B5: RRC Reestablishment request with invalid shortMAC-I or unknown C-RNTI or to unprepared
    ...                cell during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...        - shortMAC-I does not match with value stored in step-2
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    6.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...        - C-RNTI received in handoverPreparationInformation -> newUE-Identity
    ...    7.  UE-2 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...        - C-RNTI value does not match with value stored in step-6
    ...    8.  Verify UE-2 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-6 is completed
    ...    9.  Verify relevant PM counters
    ...    10. Verify relevant PCMD records
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    8.  Refer to step-4
    ...    9.  Related handover failure counters are updated
    ...    10. PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4567
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

    Wait For Next Full Pm Interval
    Get Resources Taken Before_test
    CB008574-B Start PCMD Capture

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:invalid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    CB008574-B Start PCMD Capture

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    # configure ue_rrc_reestablish with invalid_crnti
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
    ${cmd}    Catenate    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=handoverFailure action=invalid_crnti
    ...                   send_after=measurement_report time_to_wait=10
    Execute Egate Command    cmd=${cmd}
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

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
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
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
    ...  M55113C01009  4  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  4  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
    ...    AND    Run keyword and ignore error    UE Deregister    ue_id=1
    ...    AND    Testcase Teardown

CB008574-B-B5_003_XnHOTarget-RRE_to_unpreparedCell-TDD
    [Tags]    TC11    AP_REG

    [Documentation]
    ...  DESCRIPTION:  This test verifies successful fallback to RRCSetup in case RRC Reestablishment request is received
    ...                in an unprepared TDD cell after HandoverRequestAcknowledge has been sent:
    ...                - RRC Reestablishment request in handover target but non-matching shortMAC-I in ReestablishmentInfo
    ...                - RRC Reestablishment request in cell not included in ReestabNCellInfoList
    ...                - RRC Reestablishment request in handover target cell but ReestablishmentInfo missing
    ...
    ...  PRECONDITION: USCB008574-B#B5: RRC Reestablishment request with invalid shortMAC-I or unknown C-RNTI or to unprepared
    ...                cell during Inter-gNB Handover via Xn
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - shortMAC-I not matching gNB-2 cell-2 included in ReestabNCellInfo IE in HandoverRequest
    ...    3.  UE-1 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-2 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-2 with RRCSetup procedure and handover
    ...        procedure started in step-2 is completed
    ...    5.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    6.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
    ...        - gNB-2 cell-2 not included in ReestabNCellInfoList IE in HandoverRequest
    ...    7.  UE-2 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-2 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    8.  Verify UE-2 connection is successfully established to gNB-2 cell-2 with RRCSetup procedure and handover
    ...        procedure started in step-6 is completed
    ...    9.  Register and establish PDU session for UE-3 in gNB-3 cell-1
    ...    10. Trigger Inter gNB handover via Xn interface for UE-3 to gNB-2 cell-1
    ...        - ReestablishmentInfo IE not included in HandoverRequest
    ...    11. UE-3 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    12. Verify UE-3 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-10 is completed
    ...    13. Verify relevant PM counters
    ...    14. Verify relevant PCMD records
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure is completed (as failed handover where UE is lost)
    ...    8.  Refer to step-4
    ...    12. Refer to step-4
    ...    13. Related handover failure counters are updated
    ...    14. PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4567
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

    CB008574-B Start PCMD Capture
    Wait For Next Full Pm Interval

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:invalid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    CB008574-B Start PCMD Capture

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=2    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    CB008574-B Start PCMD Capture

    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3

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
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55127C00501  0  RRC_REESTAB_RECONF_FAILURE_DU
    ...  M55127C00502  3  RRC_REESTAB_HO_FAILURE_DU
    ...  M55127C00503  0  RRC_REESTAB_OTHER_FAILURE_DU
    ...  M55127C00510  0  REESTAB_ACC_RECONF_FAIL_DU
    ...  M55127C00511  0  REESTAB_ACC_HO_FAIL_DU
    ...  M55127C00512  0  REESTAB_ACC_OTHER_FAIL_DU
    ...  M55127C00513  3  RRC_REESTAB_DISCARD_DU
    ...  M55117C01009  6  NF1CD_UE_CTXT_REL_COMMAND_RECD
    ...  M55117C01010  6  NF1CD_UE_CTXT_REL_CMP_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}

    Verify Any Counters In File
    ...  M55113C01009  5  NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010  5  NF1CC_UE_CTXT_REL_CMP_RECD
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
    ...    AND    Run keyword and ignore error    UE Deregister    ue_id=1
    ...    AND    Testcase Teardown

CB008574-B-B9_001_XnHOTarget-Security_algorithm_validation_failure-TDD
    [Tags]    TC14    AP_REG

    [Documentation]
    ...  DESCRIPTION:  This test verifies that target gNB shall do fallback to RRC Setup RRC in Reestablishment handling
    ...                during Inter gNB handover via Xn interface in case Security algorithm validation fails
    ...                Security algorithm validation failure happens in case cipheringAlgorithm and integrityProtAlgorithm
    ...                received in HandoverPreparationInformation are not supported/configured at target gNB
    ...
    ...  PRECONDITION: USCB008574-B#B9: Security algorithm validation failure
    ...                 - NRBTS.integrityProtPrefL
    ...                     - nia0 = 0, nia1_128 = 2, nia2_128 = 0, nia3_128 = 8
    ...                 - NRBTS.cipherPrefL
    ...                     - nea0 = 9, nea1_128 = 0, nea2_128 = 0, nea3_128 = 0
    ...
    ...  TEST EXECUTION:
    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...        - HandoverPreparationInformation/SecurityAlgorithmConfig
    ...          - cipheringAlgorithm = nea0
    ...          - integrityProtAlgorithm = nia1
    ...    3.  UE-1 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    4.  Verify UE-1 successful RRC Reestablishment and handover completion
    ...    5.  Register and establish PDU session for UE-2 in gNB-3 cell-1
    ...    6.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...        - HandoverPreparationInformation/SecurityAlgorithmConfig
    ...          - cipheringAlgorithm = nea0
    ...          - integrityProtAlgorithm = nia2
    ...    7.  UE-2 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    8.  Verify UE-2 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-6 is completed (as a failed handover where UE is lost)
    ...    9.  Register and establish PDU session for UE-3 in gNB-3 cell-1
    ...    10. Trigger Inter gNB handover via Xn interface for UE-3 to gNB-2 cell-1
    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
    ...        - HandoverPreparationInformation/SecurityAlgorithmConfig
    ...          - cipheringAlgorithm = nea1
    ...          - integrityProtAlgorithm = nia1
    ...    11. UE-3 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has sent
    ...        HandoverRequestAcknowledge
    ...    12. Verify UE-3 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
    ...        procedure started in step-10 is completed (as a failed handover where UE is lost)
    ...
    ...  EXPECTED RESULTS:
    ...    4.  gNB-2 sends rrcReestablishment to UE-1 and successfully completes the incoming Xn handover
    ...    8.  gNB-2 sends RRCSetup to UE-2 and follows the steps from idle to connected state transition procedure
    ...        Handover procedure fails due to rrcReconfigurationComplete not being received from UE-2
    ...        (HandoverRequestAcknowledge is sent and SNStatusTransfer is received)
    ...    12. Refer to step-8
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
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_21037
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
    ...            [28.06.2023] - Testcase GIT review completed : https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/74192

    Delta Commissioning NIA And NEA List    nia0=0  nia1=2  nia2=0  nia3=8  nea0=9  nea1=0  nea2=0  nea3=0

    Get Resources Taken Before_test
    Wait For Next Full Pm Interval

    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
    Set Sim Automatic Neighbour Relation    pci=50

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia1    nea=nea0
    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${False}
    Verify RRE Msg Flow    fallbackRRCSetup=${False}
    Sleep    ${timerHOGuard}ms
    Sleep    ${tWaitingRlRecoverSA}ms
    Verify F1AP UeContextReleaseCommand    isPresent=${False}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    CB008574-B Start PCMD Capture

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    CB008574-B Start PCMD Capture

    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia1    nea=nea1
    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
    Set UE RRC Reestablishment During RRCReconfiguration
    ...    ue_id=1    gnb_id=2    cell_id=1    cause=handoverFailure    crnti=source
    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
    ${tcpdump_process}  Perform Xn Handover    ue_id=1    phycell_id=50    direction=incoming    carrier_freq2=527790    fallbackRRCSetup=${True}
    Verify RRE Msg Flow    fallbackRRCSetup=${True}
    Verify F1AP UeContextReleaseCommand    isPresent=${True}
    Kill Latest Tshark Process  ${tcpdump_process}
    UE Deregister    ue_id=1

    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File

    CB008574-B Stop PCMD Capture and Convert To TXT
    Verify PCMD Records for Fallback to RRCSetup    RRCSetupCause=3
    Get Resources Taken After_test
    Verify Resource Usage

    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
    ...    AND    Run keyword and ignore error    UE Deregister    ue_id=1
    ...    AND    Testcase Teardown


###################################################################################################################
## CB008584-B1 cases which are not added to CRT
###################################################################################################################

#CB008574-B-B1_002_XnHOTarget-RRE_to_prepared_cell_before_HO_Req_Ack-TDD
#    [Tags]    TC02
#
#    [Documentation]
#    ...  DESCRIPTION:  This test verifies that when RRC Reestablishment request is received by Target gNB before sending out
#    ...                XnAP: HandoverRequestAcknowledge, the inter-gNB Xn Handover is correctly aborted (XNAP: Handover Preparation Failure)
#    ...                and UE connection is established with fallback to RRCSetup
#    ...                The RRC Reestablishment request is received in a prepared TDD cell
#    ...
#    ...  PRECONDITION: USCB008574-B#B1: RRC Reestablishment request received by Target gNB before sending out XnAP: HandoverRequestAcknowledge
#    ...                message to Source gNB during Inter-gNB Handover via Xn
#    ...
#    ...  TEST EXECUTION:
#    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
#    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
#    ...        - gNB-2 cell-2 included in ReestabNCellInfo IE in HandoverRequest
#    ...    3.  UE-1 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-2 after gNB-2 has received
#    ...        HandoverRequest but before it has responded with HandoverRequestAcknowledge
#    ...    4.  Verify handover for UE-1 is aborted and UE-1 connection is successfully established to gNB-2 cell-2 with
#    ...        RRCSetup procedure
#    ...    5.  Verify relevant PM counters
#    ...    6.  Verify relevant PCMD records
#    ...
#    ...  EXPECTED RESULTS:
#    ...    4.  gNB-2 sends XNAP: Handover Preparation Failure with Radio Network Layer Cause set to Unspecified
#    ...        gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
#    ...    5.  PM counter values:
#    ...        gNB-2 cell-1
#    ...         - M55124C00502 RRC_REESTAB_FALLBACK = 0
#    ...         - M55124C00504 RRC_REESTAB_HO_FAILURE = 0
#    ...         - M55124C00505 RRC_REESTAB_OTHER_FAILURE = 0
#    ...         - M55124C00511 REESTAB_ACC_HO_FAIL = 0
#    ...         - M55124C00512 REESTAB_ACC_OTHER_FAIL = 0
#    ...         - M55124C00515 REESTAB_ACC_FALLBACK = 0
#    ...         - M55143C00009 HO_PREP_FAIL_SENT_OTH = 1
#    ...        gNB-2 cell-2
#    ...         - M55124C00502 RRC_REESTAB_FALLBACK = 1
#    ...         - M55124C00504 RRC_REESTAB_HO_FAILURE = 1
#    ...         - M55124C00505 RRC_REESTAB_OTHER_FAILURE = 0
#    ...         - M55124C00511 REESTAB_ACC_HO_FAIL = 0
#    ...         - M55124C00512 REESTAB_ACC_OTHER_FAIL = 0
#    ...         - M55124C00515 REESTAB_ACC_FALLBACK = 1
#    ...         - M55143C00009 HO_PREP_FAIL_SENT_OTH = 0
#    ...    6.   PCMD records filled according to OM_GEN_SFS_TRACEMGMNT.4547
#    ...
#    ...  POSTCONDITION:  -
#    ...
#    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
#    ...
#    ...  TEST ENVIRONMENT:
#    ...       HARDWARE ID: ASIL, ABIO
#    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
#    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    ...
#    ...  REQUIREMENTS COVERAGE:
#    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19155
#    ...       REQUIREMENTS OUT OF SCOPE:     -
#    ...       PM COUNTERS:                   -
#    ...       BACKLOG ID:                    FCA_5G_L2L3-134751
#    ...
#    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
#    ...
#    ...  REQUIRED LOGS:  Wireshark logs, Syslog
#    ...
#    ...  HISTORY:  History, current status and TC description is available in repository:
#    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
#    ...
#    ...            [02.05.2023] - Test plan and test case documentation created
#    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
#
#    Get Resources Taken Before_test
#    Wait For Next Full Pm Interval
#    CB008574-B Start PCMD Capture
#    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
#    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
#    Set Sim Automatic Neighbour Relation    pci=50
#
#    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
#    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
#    Execute Egate Command    cmd=gnb_param id=3 delay_proc_measurement_report=v1s
#    Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=2 cause=handoverFailure send_after=measurement_report time_to_wait=983ms
#    ${tcpdump_process}  Perform Xn Handover
#    ...                 ue_id=1    phycell_id=50    direction=incoming    ho_failure=${True}    carrier_freq2=527790    fallbackRRCSetup=${True}
#    Verify F1AP UeContextReleaseCommand    isPresent=${True}
#    Verify RRE Msg Flow    fallbackRRCSetup=${True}
#    Kill Latest Tshark Process  ${tcpdump_process}
#    Sleep    5
#    CB008574-B Stop PCMD Capture and Convert To TXT
#    Verify PCMD Records for Fallback to RRCSetup    interrupt=${True}    RRCSetupCause=3
#
#    Wait For Next Full Pm Interval
#    Sleep    10
#    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
#
#    Verify Any Counters In File
#    ...  M55124C00501  0  RRC_REESTAB_DISCARD
#    ...  M55124C00502  0  RRC_REESTAB_FALLBACK
#    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
#    ...  M55124C00504  0  RRC_REESTAB_HO_FAILURE
#    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
#    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
#    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
#    ...  M55124C00515  0  REESTAB_ACC_FALLBACK
#    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
#    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
#    ...  M55124C00518  0  REESTAB_ACC_VONR
#    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
#    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
#    ...  M55143C00009  1  HO_PREP_FAIL_SENT_OTH
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${pm_counter_file}
#
#    Verify Any Counters In File
#    ...  M55124C00501  1  RRC_REESTAB_DISCARD
#    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
#    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
#    ...  M55124C00504  1  RRC_REESTAB_HO_FAILURE
#    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
#    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
#    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
#    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
#    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
#    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
#    ...  M55124C00518  0  REESTAB_ACC_VONR
#    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
#    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
#    ...  M55143C00009  0  HO_PREP_FAIL_SENT_OTH
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
#    ...    file_path=${pm_counter_file}
#
#    UE Deregister    ue_id=1
#    Get Resources Taken After_test
#    Verify Resource Usage
#
#    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
#    ...    AND    Run keyword and ignore error    UE Deregister    ue_id=1
#    ...    AND    Testcase Teardown
#
#CB008574-B-B1_003_Robustness_XnHOTarget-RRE_to_unprepared_cell_before_HO_Req_Ack-TDD
#    [Tags]    TC03
#
#    [Documentation]
#    ...  DESCRIPTION:  This test verifies that when RRC Reestablishment request is received in an unprepared cell
#    ...                by Target gNB before sending out XnAP: HandoverRequestAcknowledge, the inter-gNB Xn Handover is
#    ...                correctly completed (as a failed handover due to RLF) and UE connection is established with fallback to RRCSetup
#    ...                The RRC Reestablishment request is received in a unprepared TDD cell:
#    ...                - RRC Reestablishment request in handover target but non-matching shortMAC-I in ReestablishmentInfo
#    ...                - RRC Reestablishment request in cell not included in ReestabNCellInfoList
#    ...                - RRC Reestablishment request in handover target cell but ReestablishmentInfo missing
#    ...
#    ...  PRECONDITION: USCB008574-B#B1: RRC Reestablishment request received by Target gNB before sending out XnAP: HandoverRequestAcknowledge
#    ...                message to Source gNB during Inter-gNB Handover via Xn
#    ...
#    ...  TEST EXECUTION:
#    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
#    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
#    ...        - shortMAC-I not matching gNB-2 cell-1 included in ReestabNCellInfo IE in HandoverRequest
#    ...    3.  UE-1 sends RRC Reestablishment request with cause handoverFailure in gNB-2 cell-1 after gNB-2 has received
#    ...        HandoverRequest but before it has responded with HandoverRequestAcknowledge
#    ...    4.  Verify UE-1 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
#    ...        procedure started in step-2 is completed (as a failed handover where UE is lost)
#    ...    5.  Verify relevant PM counters
#    ...
#    ...  EXPECTED RESULTS:
#    ...    4.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
#    ...        Handover procedure fails due to rrcReconfigurationComplete not being received from UE-1
#    ...        (HandoverRequestAcknowledge is sent and SNStatusTransfer is received)
#    ...    5.  Related handover failure counters are updated
#    ...
#    ...  POSTCONDITION:  -
#    ...
#    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
#    ...
#    ...  TEST ENVIRONMENT:
#    ...       HARDWARE ID: ASIL, ABIO
#    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
#    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    ...
#    ...  REQUIREMENTS COVERAGE:
#    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_19151, 5G_RAN_USR_RRM_19155
#    ...       REQUIREMENTS OUT OF SCOPE:     -
#    ...       PM COUNTERS:                   -
#    ...       BACKLOG ID:                    FCA_5G_L2L3-134751
#    ...
#    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
#    ...
#    ...  REQUIRED LOGS:  Wireshark logs, Syslog
#    ...
#    ...  HISTORY:  History, current status and TC description is available in repository:
#    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
#    ...
#    ...            [02.05.2023] - Test plan and test case documentation created
#    ...            [16.05.2023] - Collaborator review completed : https://collab.ext.net.nokia.com/ui#review:id=884572
#
#    Get Resources Taken Before_test
#    Wait For Next Full Pm Interval
#    CB008574-B Start PCMD Capture
#    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
#    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
#    Set Sim Automatic Neighbour Relation    pci=50
#
#    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
#    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:invalid  prep_cell_list=2:valid
#    Execute Egate Command    cmd=gnb_param id=3 delay_proc_measurement_report=v1s
#    Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=handoverFailure send_after=measurement_report time_to_wait=981ms
#    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
#    ${tcpdump_process}  Perform Xn Handover
#    ...                 ue_id=1    phycell_id=50    direction=incoming    ho_failure=${False}    carrier_freq2=527790    fallbackRRCSetup=${True}
#    Verify F1AP UeContextReleaseCommand    isPresent=${False}
#    Sleep    ${timerHOGuard}ms
#    Sleep    ${tWaitingRlRecoverSA}ms
#    Verify RRE Msg Flow    fallbackRRCSetup=${True}
#    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
#    Kill Latest Tshark Process  ${tcpdump_process}
#    Sleep    5
#    CB008574-B Stop PCMD Capture and Convert To TXT
#    Verify PCMD Records for Fallback to RRCSetup    interrupt=${False}    RRCSetupCause=3
#
#    Wait For Next Full Pm Interval
#    Sleep    10
#    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
#
#    Verify Any Counters In File
#    ...  M55124C00501  1  RRC_REESTAB_DISCARD
#    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
#    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
#    ...  M55124C00504  1  RRC_REESTAB_HO_FAILURE
#    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
#    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
#    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
#    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
#    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
#    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
#    ...  M55124C00518  0  REESTAB_ACC_VONR
#    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
#    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${pm_counter_file}
#
#    Verify Any Counters In File
#    ...  M55127C00501  0  RRC_REESTAB_RECONF_FAILURE_DU
#    ...  M55127C00502  1  RRC_REESTAB_HO_FAILURE_DU
#    ...  M55127C00503  0  RRC_REESTAB_OTHER_FAILURE_DU
#    ...  M55127C00510  0  REESTAB_ACC_RECONF_FAIL_DU
#    ...  M55127C00511  0  REESTAB_ACC_HO_FAIL_DU
#    ...  M55127C00512  0  REESTAB_ACC_OTHER_FAIL_DU
#    ...  M55127C00513  1  RRC_REESTAB_DISCARD_DU
#    ...  M55117C01009  1  NF1CD_UE_CTXT_REL_COMMAND_RECD
#    ...  M55117C01010  1  NF1CD_UE_CTXT_REL_CMP_SENT
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
#    ...    file_path=${pm_counter_file}
#
#    Verify Any Counters In File
#    ...  M55113C01009  1  NF1CC_UECTXT_REL_CMDSENT
#    ...  M55113C01010  1  NF1CC_UE_CTXT_REL_CMP_RECD
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${pm_counter_file}
#
#    UE Deregister    ue_id=1
#    Get Resources Taken After_test
#    Verify Resource Usage
#
#    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
#    ...    AND    Run keyword and ignore error    UE Deregister    ue_id=1
#    ...    AND    Testcase Teardown
#
#CB008574-B-B1_004_XnHOTarget-Online_modification_of_parameter_actInterGnbRREPreparedCell-TDD
#    [Tags]    TC04
#
#    [Documentation]
#    ...  DESCRIPTION:  This test verifies that online modification of parameter actInterGnbRREPreparedCell is correctly taken
#    ...                into account in scenario where RRC Reestablishment request is received by Target gNB before sending out
#    ...                XnAP: HandoverRequestAcknowledge
#    ...
#    ...  PRECONDITION: USCB008574-B#B1: RRC Reestablishment request received by Target gNB before sending out XnAP: HandoverRequestAcknowledge
#    ...                message to Source gNB during Inter-gNB Handover via Xn
#    ...                gNB-2
#    ...                 - NRBTS.actInterGnbRREPreparedCell = True
#    ...
#    ...
#    ...  TEST EXECUTION:
#    ...    1.  Register and establish PDU session for UE-1 in gNB-3 cell-1
#    ...    2.  Trigger Inter gNB handover via Xn interface for UE-1 to gNB-2 cell-1
#    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
#    ...    3.  UE-1 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-1 after gNB-2 has received
#    ...        HandoverRequest but before it has responded with HandoverRequestAcknowledge
#    ...    4.  Verify handover for UE-1 is aborted and UE-1 connection is successfully established to gNB-2 cell-1 with
#    ...        RRCSetup procedure
#    ...    5.  Perform delta commissioning to modify gNB-2 parameter:
#    ...        - NRBTS.actInterGnbRREPreparedCell = False
#    ...    6.  Register and establish PDU session for UE-2 in gNB-3 cell-1
#    ...    7.  Trigger Inter gNB handover via Xn interface for UE-2 to gNB-2 cell-1
#    ...        - gNB-2 cell-1 included in ReestablishmentInfo IE in HandoverRequest
#    ...    8.  UE-2 sends RRC Reestablishment request with cause otherFailure in gNB-2 cell-1 after gNB-2 has received
#    ...        HandoverRequest but before it has responded with HandoverRequestAcknowledge
#    ...    9.  Verify UE-2 connection is successfully established to gNB-2 cell-1 with RRCSetup procedure and handover
#    ...        procedure started in step-7 is completed (as a failed handover where UE is lost)
#    ...    10. Verify relevant PM counters
#    ...
#    ...  EXPECTED RESULTS:
#    ...    4.  gNB-2 sends XNAP: Handover Preparation Failure with Radio Network Layer Cause set to Unspecified
#    ...        gNB-2 sends RRCSetup to UE-2 and follows the steps from idle to connected state transition procedure
#    ...    9.  gNB-2 sends RRCSetup to UE-1 and follows the steps from idle to connected state transition procedure
#    ...        Handover procedure fails due to rrcReconfigurationComplete not being received from UE-1
#    ...        (HandoverRequestAcknowledge is sent and SNStatusTransfer is received)
#    ...    10. PM counter values:
#    ...        gNB-2 cell-1
#    ...         - M55124C00502 RRC_REESTAB_FALLBACK = 2
#    ...         - M55124C00504 RRC_REESTAB_HO_FAILURE = 0
#    ...         - M55124C00505 RRC_REESTAB_OTHER_FAILURE = 2
#    ...         - M55124C00511 REESTAB_ACC_HO_FAIL = 0
#    ...         - M55124C00512 REESTAB_ACC_OTHER_FAIL = 0
#    ...         - M55124C00515 REESTAB_ACC_FALLBACK = 2
#    ...         - M55143C00009 HO_PREP_FAIL_SENT_OTH = 1
#    ...         Additionally, step-9 related handover failure counters
#    ...
#    ...  POSTCONDITION:  -
#    ...
#    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
#    ...
#    ...  TEST ENVIRONMENT:
#    ...       HARDWARE ID: ASIL, ABIO
#    ...       ENVIRONMENT ELEMENTS: real gNB (SUT), simulated core, simulated RH and UE's
#    ...       TEST CONFIGURATIONS:  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#    ...
#    ...  REQUIREMENTS COVERAGE:
#    ...       REQUIREMENTS IN SCOPE:         -
#    ...       REQUIREMENTS OUT OF SCOPE:     -
#    ...       PM COUNTERS:                   -
#    ...       BACKLOG ID:                    FCA_5G_L2L3-134751
#    ...
#    ...  FEATURE SUB-ITEMS:  CB008574-B RRC Connection Re-establishment under a prepared gNB via RRCSetup
#    ...
#    ...  REQUIRED LOGS:  Wireshark logs, Syslog
#    ...
#    ...  HISTORY:  History, current status and TC description is available in repository:
#    ...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008574
#    ...
#    ...            [XX.XX.2023] - Test plan and test case documentation created
#
#    Get Resources Taken Before_test
#    Wait For Next Full Pm Interval
#    CB008574-B Start PCMD Capture
#    Set Ciphering And Integrity Protection Algorithms On Sim gNB    nia=nia2    nea=nea0
#    Set Default Bearer And Additional QoS Flows    def_qosflow=6    add_qosflows=5
#    Set Sim Automatic Neighbour Relation    pci=50
#
#    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
#    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:valid  prep_cell_list=2:valid
#    Execute Egate Command    cmd=gnb_param id=3 delay_proc_measurement_report=v1s
#    Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=handoverFailure send_after=measurement_report time_to_wait=981ms
#    ${tcpdump_process}  Perform Xn Handover
#    ...                 ue_id=1    phycell_id=50    direction=incoming    ho_failure=${True}    carrier_freq2=527790    fallbackRRCSetup=${True}
#    Verify F1AP UeContextReleaseCommand    isPresent=${True}
#    Verify RRE Msg Flow    fallbackRRCSetup=${True}
#    Kill Latest Tshark Process  ${tcpdump_process}
#    Sleep    5
#    CB008574-B Stop PCMD Capture and Convert To TXT
#    Verify PCMD Records for Fallback to RRCSetup    interrupt=${True}    RRCSetupCause=3
#    UE Deregister    ue_id=1
#
#    Delta Commissioning Single Parameter Value  actInterGnbRREPreparedCell  false  MRBTS-1/NRBTS-1
#    CB008574-B Start PCMD Capture
#
#    UE Register And Establish PDU Session    ue_id=1    cell_id=1    gnb_id=3    pdu_id=1    gw_id=1    nwslice=1
#    Configure ReestablishmentInfo For Xn Handover  tgt_cell_info=1:invalid  prep_cell_list=2:valid
#    Execute Egate Command    cmd=gnb_param id=3 delay_proc_measurement_report=v1s
#    Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=handoverFailure send_after=measurement_report time_to_wait=981ms
#    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
#    ${tcpdump_process}  Perform Xn Handover
#    ...                 ue_id=1    phycell_id=50    direction=incoming    ho_failure=${False}    carrier_freq2=527790    fallbackRRCSetup=${True}
#    Verify F1AP UeContextReleaseCommand    isPresent=${False}
#    Sleep    ${timerHOGuard}ms
#    Sleep    ${tWaitingRlRecoverSA}ms
#    Verify RRE Msg Flow    fallbackRRCSetup=${True}
#    Verify F1AP UeContextReleaseCommand    isPresent=${True}    RRCRelease=${True}    cause=0
#    Kill Latest Tshark Process  ${tcpdump_process}
#    Sleep    5
#    CB008574-B Stop PCMD Capture and Convert To TXT
#    Verify PCMD Records for Fallback to RRCSetup    interrupt=${False}    RRCSetupCause=3
#
#    Wait For Next Full Pm Interval
#    Sleep    10
#    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
#
#    Verify Any Counters In File
#    ...  M55124C00501  2  RRC_REESTAB_DISCARD
#    ...  M55124C00502  2  RRC_REESTAB_FALLBACK
#    ...  M55124C00503  0  RRC_REESTAB_RECONF_FAILURE
#    ...  M55124C00504  2  RRC_REESTAB_HO_FAILURE
#    ...  M55124C00505  0  RRC_REESTAB_OTHER_FAILURE
#    ...  M55124C00511  0  REESTAB_ACC_HO_FAIL
#    ...  M55124C00512  0  REESTAB_ACC_OTHER_FAIL
#    ...  M55124C00515  2  REESTAB_ACC_FALLBACK
#    ...  M55124C00516  0  REESTAB_RRCRECONFIG_SUCC
#    ...  M55124C00517  0  REESTAB_RRCRECONFIG_UNSUCC
#    ...  M55124C00518  0  REESTAB_ACC_VONR
#    ...  M55124C00519  0  REESTAB_ADMISSION_CTRL
#    ...  M55124C00520  0  RRC_REESTAB_ATT_VONR
#    ...  M55143C00009  1  HO_PREP_FAIL_SENT_OTH
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    file_path=${pm_counter_file}
#
#    UE Deregister    ue_id=1
#    Get Resources Taken After_test
#    Verify Resource Usage
#
#    [Teardown]    Run Keywords    Log to console    Teardown started for TC: ${TEST_NAME} ..
#    ...    AND    Run keyword and ignore error    UE Deregister    ue_id=1
#    ...    AND    Delta Commissioning Single Parameter Value  actInterGnbRREPreparedCell  true  MRBTS-1/NRBTS-1
#    ...    AND    Testcase Teardown
