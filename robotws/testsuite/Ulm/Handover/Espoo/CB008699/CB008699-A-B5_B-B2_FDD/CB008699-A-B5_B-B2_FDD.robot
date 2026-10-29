*** Settings ***

# robot --dryrun -L TRACE:DEBUG -b debug.log -V $(find ~/testline_configuration/ -type d -name $(hostname | tr - _))
# -d /home/ute/logs/ /home/ute/CB008699-A-B5_B-B2_FDD/CB008699-A-B5_B-B2_FDD.robot

Documentation
...
...  INTRODUCTION:
...      This feature was initially introduced with ID=5GC002047. Due to system release change, a new feature ID has been assigned.
...      *    This feature introduces Full RRC Configuration support during handover in SA option 2 deployment for Intra-gNB Inter-DU or
...           Inter-gNB cases.
...      *    In case of multi-vendor situation, for the support of open Interfaces (NG, Xn, F1): since Nokia gNB does not have any control
...           of what is supported by other vendor gNB or other vendor gNB-DU under nokia gNB-CU, full configuration is needed during mobility
...           scenarios. Handling of unsupported IEs is covered in this feature only for RRC related IEs. Other interfaces IEs (Xn, NG, E1, F1)
...           is not a scope of this feature.
...      *    In case of SW upgrade when RAN nodes of a customer network are from different 3GPP releases or from different versions of same
...           3GPP release: full configuration shall solve the issue of Interoperability between heterogeneous gNBs during mobility scenarios when
...           gNBs are of different 3GPP release version or when gNBs are of different 3GPP releases.
...      *    Full configuration option includes an initialization of the radio configuration at the target node, which makes the procedure
...           independent of the configuration used in the source node. When UE receives RRC Reconfiguration with the fullconfig IE set,
...           the UE shall release/clear all current dedicated radio configurations with some exceptions.
...      *    Without this feature, only radio delta UE configuration is supported by the gNB in RRC message during mobility scenarios in
...           SA option 2 deployment. This feature allows the gNB to configure UE using full Configuration to erase the previous UE configuration.

...      * This feature shall be enabled/disabled per gNB by OAM settings.
...      * This feature shall introduce the setting of the fullconfig IE to TRUE in the RRC: RRCReconfiguration message to UE. This IE is sent to
...        UE in RRC: RRCReconfiguration message in SA Option 2 deployment.
...      * This feature shall have impact on E1 signalling as full configuration leads to PDCP reset and gNB-CU-UP needs to be aware of this to
...        inform 5G-L2-Hi.
...
...      NG handover part using TDD/FDD band radios is verified in this test plan
...
...      AirPhone simulator EFS and egate commands for the feature:
...      https://confluence.ext.net.nokia.com/display/AirPhoneWTS/CB008699-SR++Full+RRC+Configuration+for+SA+Handover
...
...  TEST SET NAME:  CB008699-A-B5_B-B2
...
...  TESTING SCOPE:  CB008699-A-B5; CB008699-B-B2
...
...  PRECONDITIONS:  USCB008699-A#B5: Source DRB to QoS flow mapping is missing or is not supported at target gNB during NG based handover
...                  USCB008699-B#B2: Unknown extension detected by the target gNB in the source configuration due to usage of older 3GPP
...                                   version at the target node of inter-gNB NG based handover
...
...  DEPENDENCIES:   5GC002175: Spillover from SA Mobility (5GC000704, 5GC000708)
...                  * Full RRC Configuration for SA Handover feature requires SA mobility support
...                  CB008699 Depends on CB005792
...                  * CB005792: Cloud RAN BTS FR1-TDD RRM feature parity for SA mode
...                  * Full RRC Configuration for SA Handover feature needs to be adjusted to vRAN support
...                  CB008699 Depends on CB009086
...                  * CB009086: 3GPP specification baseline for gNB 23R2 release
...                  * Full RRC Configuration for SA Handover feature requires to be adjusted to 3GPP baseline
...                  CB008699 Depends on CB009219
...                  * CB009219: O-RAN Open Interfaces (X2/Xn/F1) baseline for gNB 23R2 release
...                  * Full RRC Configuration for SA Handover feature requires to be adjusted to O-RAN baseline
...                  CB008699 Interacts with 5GC000704
...                  * 5GC000704: Intra-frequency handover via Xn (SA option 2)
...                  * Full RRC Configuration for SA Handover feature requires Xn handover support
...                  CB008699 Interacts with 5GC000706
...                  * 5GC000706: Inter-frequency handover via Xn (SA option 2)
...                  * Full RRC Configuration for SA Handover feature requires Xn handover support
...                  CB008699 Interacts with 5GC000876
...                  * 5GC000876: Radio Admission Control - SA mode
...                  * In Intra-NR Inter-gNB handover, if Full Configuration is applied and DRBs to QoS flows at source is unavailable or
...                    inconsistent then QoS Flow Setup List IE instead of DRBs to QoS Flows Mapping List IE shall be taken as an input
...                    for DRBs to QoS mapping procedure at target side.
...                  CB008699 Interacts with CB008700
...                  * CB008700: ARP-based admission control in case of multiple DRBs (SA mode)
...                  * There is no functional dependency, however since both features impact the admission control algorithms,
...                    the admission response shall not cause inconsistency in other feature.
...                  CB008699 Interacts with CB008731
...                  * CB008731: IRAT handover from LTE (SA option 2)
...                  * If CB008731 Handover from LTE to 5G Option 2 feature is configured and NRBTS/nonContentRachAcIrat parameter is set to
...                    force CBRA, then this will affect Intra-NR handover with full config by using CBRA as well.
...                  CB008699 Interacts with CB008806
...                  * CB008806: Intra and Inter-frequency handover via NG
...                  * Full RRC Configuration for SA Handover requires NG based HO support
...
...  TEST INSTANCES:
...    CB008699-A_B5_001_NG_handover-intraFreq_FDD_with_full_or_delta_rrc_reconfig_due_to_DRB_to_QoS_flow_mapping_usage
...    CB008699-A_B5_002_NG_handover-interFreq_FDD_with_full_rrc_reconfig_due_to_DRB_to_QoS_flow_mapping_usage
...    CB008699-A_B5_003_NG_handover-interFreq_TDD_with_full_rrc_reconfig_due_to_DRB_to_QoS_flow_mapping_usage
...    CB008699-A_B5_004_NG_handover-interFreq_FDD_DRB_to_QoS_flow_mapping_usage_with_CB008699_disabled
...
...    CB008699-B_B2_001_NG_handover-intraFreq_FDD_with_full_or_delta_rrc_reconfig_due_to_unknown_extension_IE_usage
...    CB008699-B_B2_002_NG_handover-interFreq_FDD_with_full_rrc_reconfig_due_to_unknown_extension_IE_usage
...    CB008699-B_B2_003_NG_handover-interFreq_TDD_with_full_rrc_reconfig_due_to_unknown_extension_IE_usage
...    CB008699-B_B2_004_NG_handover-interFreq_FDD_unknown_extension_IE_usage_with_CB008699_disabled
...
...  MAIN CONTACTS:
...    Role:									              Name:
...    ===================================  ====================================
...    Product Manager:                     Palli, Aspasia (Nokia - FR/Paris-Saclay)
...    FOT leader:                          Narayanan, Iyer (Nokia - DE/Ulm)
...    CFAM leader:                         Wesolowski, Marek (Nokia - PL/Wroclaw)
...    Feature Test Lead:                   Paszkowski, Grzegorz 1. (Nokia - PL/Wroclaw)
...    LESE:                                Lung, Petra (Nokia - DE/Ulm)
...    Other EFS  contributors:             Pingel, Ulf Torsten (Nokia - DE/Ulm)
...                                         El-Henawy, Tamer (Nokia - FI/Espoo)
...                                         Takala, Tero (Nokia - FI/Espoo)
...    L3 ET:                               Viitanen, Sami (Nokia - FI/Espoo)   (This NG part ET test plan)
...                                         Kivineva, Topi (Nokia - FI/Espoo)
...                                         Greiner, Wolfgang (Nokia - DE/Ulm)  (Xn part ET)
...    ST Classical:                        Paszkowski, Grzegorz 1. (Nokia - PL/Wroclaw)
...    ST Cloud:                            Guo, Qianqian (NSB - CN/Hangzhou)
...    AirPhone:                            Kumar, Ajay B. (Nokia - IN/Bangalore)
...                                         Bandhu, Niranjan (Nokia - IN/Bangalore)
...                                         Pradhan, Binaya (Nokia - IN/Bangalore)
...                                         Shenoy, Pradeep (Nokia - IN/Bangalore)
...
...    Full list of FOT members can be found from:
...    https://nokia-my.sharepoint.com/personal/iyer_narayanan_nokia_com/_layouts/15/Doc.aspx?sourcedoc={66fc87aa-3748-45f1-989f-1b5684d2755a}
...    &action=view&wd=target%28Dashboard.one%7C9dd6b59e-5bde-4c85-9a80-2b882d76bc88%2FFOT%20members%7C205cdf6d-7dcd-4fca-8103-cc251edab354%2F%29&wd
...    origin=NavigationUrl
...
...  REFERENCES:  CFAM CB008699
...
...  TERMS AND ABBREVIATIONS:  -
...
...  HISTORY:  History, current status and TC description is available in repository:
...            https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008699
...
...            [01.11.2022] - Test plan documentation created
...            [01.11.2022] - Test plan documentation, proposed (ready for review)
...            [24.11.2022] - Test plan documentation, approved - https://collab.ext.net.nokia.com/ui#review:id=870792
...            [24.12.2022] - Code review for test suite and cases completed
...                           https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/51459


Resource   test_keywords.robot
Resource   test_variables.robot
Library    pdml_handling.py
Library    test_keywords.py

Resource        ../../../../resources/Common/reporting.robot

Variables  test_variables.py

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


*** Test Cases ***
CB008699-A_B5_001_NG_handover-intraFreq_FDD_with_full_or_delta_rrc_reconfig_due_to_DRB_to_QoS_flow_mapping_usage
    [Tags]    TC01

    [Documentation]
    ...  DESCRIPTION:  This test verifies that real gNB applies full or delta RRCReconfiguration during Inter gNB intra-frequency
    ...                handover on band 71 via NG interface based on DRB to QoS Flow mapping content received in NGAP: HandoverRequest
    ...
    ...                When full configuration is applied it will erase the old UE configuration and UE shall be configured
    ...                with target node supported IEs values
    ...
    ...                For Data forwarding from source gNB to target gNB it is checked that:
    ...                - DRB specific tunnel(s) for all DRBs with the same DRB to QoS flow mapping at target and source
    ...                  (DRBtoQoSFlowMapping 1:1)
    ...                - PDU session level forwarding tunnel (common tunnel) for DRBs with DRBtoQoSFlowMapping missing or
    ...                  if DRB is mapped by source gNB to several QFIs
    ...
    ...                Testcase will also verify new default DRB selection and Full Config related IE usage and relevant
    ...                PM and PMI ticket counters for:
    ...                55147 - NR Mobility CU
    ...                55125 - NR NGAP Interface Report per CELL
    ...                55337 - NR PDU Session or DRB DL Forwarding
    ...
    ...                Note! Call is started on real gNB in order to get data transfer working properly. UE is then moved to simulated gNB
    ...                and back to real gNB via NG handover (latter handover from RANSIM to real gNB will be verified)
    ...
    ...                Note! 02812899 PR correction changes functionality to have only DRB or PDU level forwarding for all PDU sessions!
    ...
    ...  PRECONDITION: USCB008699-A#B5: Source DRB to QoS flow mapping is missing or is not supported at target gNB
    ...                                 during NG based handover preconditions
    ...                CB008699:        Full RRC Configuration for SA Handover active (actFullRRCConfigurationSaHo=enabled)
    ...                                 Allowed values: {disabled, enabled, DrbToQosMappingOnly}
    ...                5GC000876:       Radio Admission Control - SA mode activated
    ...                CB008700:        ARP-based admission control in case of multiple DRBs (actARPBasedAC=on)
    ...                CB008731:        IRAT handover from LTE (SA option 2) deactivated (actInterRatHoSA=false, CBRA not used)
    ...                5GC000704:       Intra-frequency HO activated (actIntraFreqHoSA=true)
    ...                5GC000706:       Inter-frequency HO activated (actInterFreqHoSA=true)
    ...                5GC000705:       NG HO activated (handoverAllowedSA=XnHoNotAllowed)
    ...                CB008806:        Intra and Inter-frequency handover via NG activated (actIntraNrNgHo=sourceAndTarget)
    ...                5GC000786:       Voice over NR activated (actVoNR=true)
    ...                CB008379:        GBR Services for SA activated (actNonVoNRGbrService=true)
    ...                Measurements:    55147 - NR Mobility CU (miNrMobilityReportCu=5min)
    ...                                 55125 - NR NGAP Interface Report per CELL active (miNrNGCC=5min)
    ...                                 55337 - NR PDU Session or DRB DL Forwarding (miNrNRPFW=5min)
    ...                UEs that support 5G SA with FDD bands 66 and 71, A2/A3 events with mgaps, VoNR and Access Stratum r16
    ...                Airphone:        Always includes DefaultDRB information for the PDU sessions 1st DRB when it's source gNB in handover
    ...
    ...  TEST EXECUTION:
    ...  1.  Register UE in gNB-2 cell-1 and establish PDU session 1 with 2 QoS flows (QFI 1, 2, 3 - 5qi-9, 4) and start data transfer
    ...  2.  Establish PDU session 2 for UE with 3 QoS flows (QFI 1, 2, 3 - 5qi-8, 5, 1) and start data transfer
    ...  3.  Establish PDU session 3 for UE with 3 QoS flows (QFI 1, 2, 3 - 5qi-6, 7, 2) and start data transfer
    ...  4.  Trigger Inter gNB intra-freq handover via NG interface to simulated gNB-3
    ...  5.  Set simulated gNB to send DRB to QoS flow mapping IE for PDU sessions in HandoverRequest as following:
    ...        PDU1: All DRBs 1:1                                                                         > DRB level tunnel used
    ...        PDU2: Mapping IE missing                                                                   > PDU level tunnel used
    ...        PDU3: DRB9 not 1:1 mapped (to QFIs 1, 2), DRB10 not included in mapping, DRB11 1:1 mapped  > DRB and PDU level tunnels used
    ...  6.  Trigger Inter gNB intra-freq handover via NG interface back to real gNB-2 and check feature relevant E1, F1, NG IF message contents
    ...  7.  Check that following PM counter values (also CP-UE PMI ticket counters) are correct (exact values in test case):
    ...        Counter ID:   PMI counter ID:  Name:
    ...        ============  ===============  ============================
    ...        M55125C07506  3612679506       NG_HO_RES_ALC_F_OTH_TRG  (only incremented in failed handover)
    ...        M55147C00036  3614113828       HO_PREP_SUCC_FULLCONF_TRG
    ...        M55147C00037  3614113829       RRC_RECONF_COMP_FULLCONF_TRG
    ...        For QoS classes 1-9 (where xx is 01 to 09):
    ...        ===========================================
    ...        M55337C040xx                   VOL_DL_FWDT_RCV_PDUSES_QOS_xx
    ...        M55337C050xx                   NUM_DL_FWDT_RCV_PDUSES_QOS_xx
    ...
    ...  8.  Detach UE
    ...  9.  Repeat steps 1-8 but set simulated gNB to send 1:1 mapping for all PDU sessions in step 5
    ...
    ...  EXPECTED RESULTS:
    ...  1.  5G SA UE registration and PDU session establishment is successful and data is started for all QFIs
    ...  2.  Second PDU session establishment is successful and data is started for all QFIs
    ...  3.  Third PDU session establishment is successful and data is started for all QFIs
    ...  4.  Handover is triggered to simulated gNB and UE is in target gNB in RRC Connected state
    ...  6a. Handover is triggered to real gNB and UE is in target gNB in RRC Connected state
    ...  6b. Source gNB (sim) will set every DRBs 'DRB to QoS Flow Mapping' contents according to configured values in step 5
    ...
    ...      NGAP: 'Handover Request > SourceToTarget-TransparentContainer > pDUSessionResourceInformationList > PDUSessionResourceInformationItem >
    ...      dRBsToQosFlowsMappingList > DRBsToQosFlowsMappingItem' is shown as either 1:1 mapping, missing or not 1:1 mapping
    ...
    ...  6c. Target gNB assigns new default DRB as per 5G_CP_ARC_ALG_8767 (DRB to QoS Flow Mapping and Default DRB determination) for
    ...      PDU sessions 1 and 3 (PDU session 2 default DRB information is intact)
    ...
    ...      E1AP: 'BearerContextSetupRequest > System-BearerContextSetupRequest > PDU-Session-Resource-To-Setup-List >
    ...             PDU-Session-Resource-To-Setup-Item > dRB-To-Setup-List-NG-RAN >  DRB-To-Setup-Item-NG-RAN > sDAP-Header-UL: present (0)'
    ...             is shown for the default DRB of every PDU session
    ...
    ...      NGAP: 'Handover Request Acknowledge > TargetToSource-TransparentContainer > handoverCommand > RRCReconfiguration > drb-ToAddModList >
    ...             DRB-ToAddMod > sdap-Config > sdap-HeaderUL: present (0)' AND 'defaultDRB: True' are set for the default DRB of every PDU session
    ...             'sdap-HeaderUL: absent (1)' AND 'defaultDRB: False' for the rest of DRBs
    ...
    ...  6d. Target gNB will send full RRCReconfiguration and PDU session level or DRB level data forwarding information
    ...
    ...      Note! 02812899 PR correction changes functionality to have only DRB or PDU level forwarding for all PDU sessions!
    ...
    ...      F1AP: 'UeContextSetupRequest > CUtoDURRC Information > HandoverPreparationInformation > sourceConfig' IE is NOT present!
    ...      F1AP: 'UEContextSetupResponse > FullConfiguration' IE is present (FullConfiguration: full (0))
    ...      NGAP: 'Handover Request Acknowledge > TargetToSource-TransparentContainer > HandoverCommand > RRCReconfiguration >
    ...      nonCriticalExtension > fullConfig: true (0)'
    ...
    ...      For DRBs with DRBtoQoSFlowMapping missing or not 1:1 (if no DRB index reallocation done)
    ...      ========================================================
    ...      E1AP: 'BearerContextSetupRequest > System-BearerContextSetupRequest > PDU-Session-Resource-To-Setup-List >
    ...             PDU-Session-Resource-To-Setup-Item > pDU-Session-Data-Forwarding-Information-Request > Data Forwarding Request' IE
    ...             is set to the value "dL"
    ...      E1AP: 'BearerContextSetupResponse > System-BearerContextSetupResponse > PDU-Session-Resource-To-Setup-List >
    ...             PDU-Session-Resource-To-Setup-Item > pDU-Session-Data-Forwarding-Information-Response > DL Data Forwarding' IE is set
    ...      NGAP: 'Handover Request Acknowledge > PDUSessionResourceAdmittedItem > HandoverRequestAcknowledgeTransfer >
    ...             dLForwardingUP-TNLInformation' IE is set
    ...             Note! This IE is set only once per PDU session and all DRBs not having dataForwardingResponseDRBList IE will use PDU level
    ...             session data-forwarding instead
    ...
    ...      For DRBs with DRBtoQoSFlowMapping 1:1
    ...      ========================================================
    ...      E1AP: 'BearerContextSetupRequest > System-BearerContextSetupRequest > PDU-Session-Resource-To-Setup-List >
    ...             PDU-Session-Resource-To-Setup-Item > dRB-To-Setup-List-NG-RAN >  DRB-To-Setup-Item-NG-RAN >
    ...             dRB-Data-Forwarding-Information-Request > data-Forwarding-Request' IE set value "dL"
    ...      E1AP: 'BearerContextSetupResponse > System-BearerContextSetupResponse > PDU-Session-Resource-To-Setup-List >
    ...             PDU-Session-Resource-To-Setup-Item > dRB-To-Setup-List-NG-RAN >  DRB-To-Setup-Item-NG-RAN >
    ...             dRB-data-Forwarding-Information-Response > dL-Data-Forwarding' IE is set
    ...      NGAP: 'Handover Request Acknowledge > PDUSessionResourceAdmittedItem > HandoverRequestAcknowledgeTransfer >
    ...             dataForwardingResponseDRBList > DataForwardingResponseDRBItem > dLForwardingUP-TNLInformation' IE is set
    ...
    ...  7.  PM counters of measurements 55147, 55125 and 55337 have appropriate values. PMI ticket counters have also appropriate values
    ...  8.  UE is detached properly and data transfer is stopped
    ...  9.  Same expected results than 1-8 except counters HO_PREP_SUCC_FULLCONF_TRG and RRC_RECONF_COMP_FULLCONF_TRG will not be pegged and
    ...
    ...      F1AP: 'UeContextSetupRequest > CUtoDU RRC Information > HandoverPreparationInformation > sourceConfig' IE is present
    ...      F1AP: 'UEContextSetupResponse > FullConfiguration' IE is NOT present
    ...      NGAP: 'Handover Request Acknowledge > TargetToSource-TransparentContainer > HandoverCommand > RRCReconfiguration >
    ...             nonCriticalExtension > fullConfig' is NOT set
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIO, AHLOA (FDD band 71), AHFIB (FDD band 66)
    ...
    ...                              Real gNB-2:
    ...                              NRCELL-1 band 71 FDD
    ...                              NRCELL-2 band 66 FDD
    ...
    ...                              Simulated gNB-3:
    ...                              NRCELL-1 band 71 FDD
    ...
    ...       ENVIRONMENT ELEMENTS:  Simulated 5GC, real gNB-2, simulated gNB-3
    ...       TESTLINE:              CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_16119
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55125C07506, M55147C00036, M55147C00037
    ...       BACKLOG ID:                    FCA_5G_L2L3-105171
    ...
    ...  FEATURE SUB-ITEMS:  CB008699-A#B5: Source DRB to QoS flow mapping is missing or is not supported at target gNB during NG based handover
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS:  See Test plan in beginning of this file (Documentation part)
    ...
    ...  REFERENCES:  CFAM CB008699
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008699
    ...
    ...               [27.10.2022] - Test plan documentation created
    ...               [01.11.2022] - Test plan documentation, proposed (ready for review)
    ...               [24.11.2022] - Test plan documentation, approved - https://collab.ext.net.nokia.com/ui#review:id=870792
    ...               [24.12.2022] - Code review for test suite and cases completed
    ...                              https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/51459

    Set Sim Automatic Neighbour Relation  pci=50
    Delta Commissioning Single Parameter Value  actInterRatHoSA  false  MRBTS-1/NRBTS-1

    Set Default Bearer And Additional QoS Flows  def_qosflow=9  add_qosflows=4  integrity_prot=${False}
    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2
    UE Register And Establish PDU Session  ue_id=2  pdu_id=4  cell_id=1  gnb_id=2  gw_id=4

    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=5  integrity_prot=${False}
    Establish Pdu Session For UE  ue_id=1  pdu_id=2  nwslice=2  gw_id=2
    Establish Pdu Session For UE  ue_id=2  pdu_id=5  nwslice=2  gw_id=5
    UE VoNR Call  ue_id=1  pdu_id=2
    UE VoNR Call  ue_id=2  pdu_id=5

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=5,7  integrity_prot=${False}
    Establish Pdu Session For UE  ue_id=1  pdu_id=3  nwslice=3  gw_id=3
    Establish Pdu Session For UE  ue_id=2  pdu_id=6  nwslice=3  gw_id=6

    ${VAR1}=  Set variable  drb_id_to_qos_flows_mapping=9:1|2 missing_qfi_per_pdu_in_drbtoqosflowsmapping=2:1|2|3,3:2
    Execute Egate Command  cmd=ue_gnb_ho_param id=1 gnb=3 ${VAR1}

    @{QFIs}=  Set variable    1  2
    Start Or Stop Data On All QFIs  ue_id=1  pdu=1  qfis=${QFIs}  throughput=500
    @{QFIs}=  Set variable    1  2  3
    Start Or Stop Data On All QFIs  ue_id=1  pdu=2  qfis=${QFIs}  throughput=500
    Start Or Stop Data On All QFIs  ue_id=1  pdu=3  qfis=${QFIs}  throughput=500

    Perform NG Handover  ue_id=1  phycell_id=381  direction=outgoing  carrier_freq2=126530  intrafreq=${True}

    Check Need Of Fresh PM Counter Interval
    Clear And Start Collecting PMI Tickets

    # Handover back to real gNB band 66 cell, intrafreq
    ${ret1}=  Perform NG Handover  ue_id=1  phycell_id=50  direction=incoming  carrier_freq=126530
    Verify Data Forwarding  ret1=${ret1}  pdu1=${True}  pdu2=${True}  pdu3=${True}

    ################################################
    # Verify FullConfig
    ################################################
    Verify FullConfig  fullConfigSet=${True}

    ################################################
    # Default DRB checking for all DRBs:
    ################################################
    @{drbList}=  Set variable  4  6  9
    Verify DefaultDRB In E1 And NG  drbList=${drbList}  times=3
    @{drbList}=  Set variable  5  7  8  10  11
    Verify DefaultDRB In E1 And NG  drbList=${drbList}  times=0

    ################################################
    # DRB ID usage checking:
    ################################################
    @{drbList}=  Set variable  4  5  6  7  8  9  10  11
    Verify DRB IDs In E1 And NG  drbList=${drbList}  times=8

    ##########################################################
    # DRB tunnel verification:
    ##########################################################
    @{drbList}=  Set variable  4  5  11
    #Verify DRB Tunnels In E1 And NG   drbList=${drbList}  times=3
    Verify DRB Tunnels In E1 And NG   drbList=${drbList}  times=0
    @{drbList}=  Set variable  6  7  8  9  10
    Verify DRB Tunnels In E1 And NG   drbList=${drbList}  times=0

    ################################################
    # PDU session level tunnel verification
    ################################################
    @{pduList}=  Set variable  1  2  3
    #Verify PDU Tunnels In E1 And NG  pduList=${pduList}  times=2
    Verify PDU Tunnels In E1 And NG  pduList=${pduList}  times=3
    @{pduList}=  Set variable  4  5
    Verify PDU Tunnels In E1 And NG  pduList=${pduList}  times=0

    #Stop Tshark  ${TSHARKALIAS_NG}
    stop_tcpdump_on_remote_interface

    Stop Collecting PMI Tickets And Verify Full Config Counters
    ${pm_counter_file}  Wait For Next Meas File And Verify Full Config Counters
    Verify Received Data Forwarding Packets For 5QIs  pm_counter_file=${pm_counter_file}

    # Start data for UE-2 (delta variant)
    @{QFIs}=  Set variable    1  2
    Start Or Stop Data On All QFIs  ue_id=2  pdu=4  qfis=${QFIs}  throughput=500
    @{QFIs}=  Set variable    1  2  3
    Start Or Stop Data On All QFIs  ue_id=2  pdu=5  qfis=${QFIs}  throughput=500
    Start Or Stop Data On All QFIs  ue_id=2  pdu=6  qfis=${QFIs}  throughput=500

    Perform NG Handover  ue_id=2  phycell_id=381  direction=outgoing  carrier_freq2=126530  intrafreq=${True}

    # Handover back to real gNB band 66 cell, intrafreq, UE2 delta config
    ${ret1}=  Perform NG Handover  ue_id=2  phycell_id=50  direction=incoming  carrier_freq=126530
    Verify Data Forwarding  ret1=${ret1}  pdu1=${True}  pdu2=${True}  pdu3=${True}

    ################################################
    # Verify FullConfig
    ################################################
    Verify FullConfig  fullConfigSet=${False}

    ################################################
    # Default DRB checking for all DRBs:
    ################################################
    @{drbList}=  Set variable  4  6  9
    Verify DefaultDRB In E1 And NG  drbList=${drbList}  times=3
    @{drbList}=  Set variable  5  7  8  10  11
    Verify DefaultDRB In E1 And NG  drbList=${drbList}  times=0

    ################################################
    # DRB ID usage checking:
    ################################################
    @{drbList}=  Set variable  4  5  6  7  8  9  10  11
    Verify DRB IDs In E1 And NG  drbList=${drbList}  times=8

    ##########################################################
    # DRB tunnel verification:
    ##########################################################
    #Verify DRB Tunnels In E1 And NG   drbList=${drbList}  times=8
    # 5G_CP_IF_RRC_4375:
    Verify DRB Tunnels In E1 And NG   drbList=${drbList}  times=0

    ################################################
    # PDU session level tunnel verification
    ################################################
    @{pduList}=  Set variable  4  5  6
    #Verify PDU Tunnels In E1 And NG  pduList=${pduList}  times=0
    Verify PDU Tunnels In E1 And NG  pduList=${pduList}  times=3

    stop_tcpdump_on_remote_interface

    ${pm_counter_file}  Wait For Next Meas File And Verify Full Config Counters  HO_PREP_SUCC_FULLCONF_TRG=0  RRC_RECONF_COMP_FULLCONF_TRG=0
    Verify Received Data Forwarding Packets For 5QIs  pm_counter_file=${pm_counter_file}

    [Teardown]  Run Keywords    Set SCOUT TC ID for Reporting
    ...  AND  Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=1
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=2
    ...  AND  Testcase Teardown


CB008699-A_B5_004_NG_handover-interFreq_FDD_DRB_to_QoS_flow_mapping_usage_with_CB008699_disabled
    [Tags]    TC03

    [Documentation]
    ...  DESCRIPTION:  This test verifies that if target gNB does not receive or does not support the DRB to QoS flow mapping provided by source gNB
    ...                in NGAP: HandoverRequest and CB008699 feature is not active, then legacy behavior of NG based HO feature shall be applied,
    ...                which means NGAP: HandoverFailure will be sent to target AMF from target gNB-CU-CP with "Radio Network Layer Cause
    ...                (Handover target not allowed)"
    ...
    ...                In this test Inter gNB inter-frequency handover is performed between bands 41 and 78 via NG interface
    ...
    ...                Note! Call is started on real gNB in order to get data transfer working properly. UE is then moved to simulated gNB
    ...                and back to real gNB via NG handover (latter handover from RANSIM to real gNB will be verified)
    ...
    ...  PRECONDITION: USCB008699-A#B5: Source DRB to QoS flow mapping is missing or is not supported at target gNB
    ...                                 during NG based handover preconditions
    ...                CB008699:        Full RRC Configuration for SA Handover active (actFullRRCConfigurationSaHo=enabled)
    ...                                 Allowed values: {disabled, enabled, DrbToQosMappingOnly}
    ...                                 Note! This parameter will be set to disabled in test case execution via delta commissioning
    ...                5GC000876:       Radio Admission Control - SA mode activated
    ...                CB008700:        ARP-based admission control in case of multiple DRBs (actARPBasedAC=on)
    ...                CB008731:        IRAT handover from LTE (SA option 2) deactivated (actInterRatHoSA=false, CBRA not used)
    ...                5GC000704:       Intra-frequency HO activated (actIntraFreqHoSA=true)
    ...                5GC000706:       Inter-frequency HO activated (actInterFreqHoSA=true)
    ...                5GC000705:       NG HO activated (handoverAllowedSA=XnHoNotAllowed)
    ...                CB008806:        Intra and Inter-frequency handover via NG activated (actIntraNrNgHo=sourceAndTarget)
    ...                5GC000786:       Voice over NR activated (actVoNR=true)
    ...                CB008379:        GBR Services for SA activated (actNonVoNRGbrService=true)
    ...                Measurements:    55147 - NR Mobility CU (miNrMobilityReportCu=5min)
    ...                                 55125 - NR NGAP Interface Report per CELL active (miNrNGCC=5min)
    ...                                 55337 - NR PDU Session or DRB DL Forwarding (miNrNRPFW=5min)
    ...                UEs that support 5G SA with FDD bands 66 and 71, A2/A3 events with mgaps, VoNR and Access Stratum r16
    ...                Airphone:        Always includes DefaultDRB information for the PDU sessions 1st DRB when it's source gNB in handover
    ...
    ...  TEST EXECUTION:
    ...  1.  Delta commission actFullRRCConfigurationSaHo with value disabled
    ...  2.  Register UE in gNB-2 cell-2 and establish PDU session 1 with 2 QoS flows (QFI 1, 2 - 5qi-6, 2) and start data transfer
    ...  3.  Establish PDU session 2 for UE with 2 QoS flows (QFI 1, 2 - 5qi-5, 1) and start data transfer
    ...  4.  Establish PDU session 3 for UE with 2 QoS flows (QFI 1, 2 - 5qi-9, 4) and start data transfer
    ...  5.  Establish PDU session 4 for UE with 2 QoS flows (QFI 1, 2 - 5qi-7, 8) and start data transfer
    ...  6.  Trigger Inter gNB inter-freq handover via NG interface to simulated gNB-3
    ...  7.  Set simulated gNB to send DRB to QoS flow mapping IE for PDU sessions in HandoverRequest as following:
    ...        PDU1: Both DRBs 1:1 mapped
    ...        PDU2: Mapping IE missing
    ...        PDU3: DRB8: not 1:1 mapped (mapped to QFIs 1, 2), DRB9: missing mapping
    ...        PDU4: Both DRBs 1:1 mapped
    ...  8.  Trigger Inter gNB inter-freq handover via NG interface back to real gNB-2 and check relevant NG IF message contents
    ...  9.  Check that following PM counter values (also CP-UE PMI ticket counters) are correct (exact values in test case):
    ...        Counter ID:   PMI counter ID:  Name:
    ...        ============  ===============  ============================
    ...        M55125C07506  3612679506       NG_HO_RES_ALC_F_OTH_TRG  (only incremented in failed handover)
    ...        M55147C00036  3614113828       HO_PREP_SUCC_FULLCONF_TRG
    ...        M55147C00037  3614113829       RRC_RECONF_COMP_FULLCONF_TRG
    ...        For QoS classes 1-9 (where xx is 01 to 09):
    ...        ===========================================
    ...        M55337C040xx                   VOL_DL_FWDT_RCV_PDUSES_QOS_xx
    ...        M55337C050xx                   NUM_DL_FWDT_RCV_PDUSES_QOS_xx
    ...
    ...  10. Detach UE
    ...
    ...  EXPECTED RESULTS:
    ...  1.  Online delta commissioning is done and gNB is not restarted
    ...  2.  5G SA UE registration and PDU session establishment is successful and data is started for all QFIs
    ...  3.  Second PDU session establishment is successful and data is started for all QFIs
    ...  4.  Third PDU session establishment is successful and data is started for all QFIs
    ...  5.  Fourth PDU session establishment is successful and data is started for all QFIs
    ...  6.  Handover is triggered to simulated gNB and UE is in target gNB in RRC Connected state
    ...  8a. Source gNB (sim) will set every DRBs 'DRB to QoS Flow Mapping' contents according to configured values in step 6
    ...
    ...  8b. Handover is triggered to real gNB and real gNB sends NGAP: HandoverFailure to target AMF
    ...      NGAP: 'Handover Request > SourceToTarget-TransparentContainer > pDUSessionResourceInformationList > PDUSessionResourceInformationItem >
    ...      dRBsToQosFlowsMappingList > DRBsToQosFlowsMappingItem' is shown as either 1:1 mapping, missing or not 1:1 mapping
    ...
    ...  9.  PM counters of measurements 55147, 55125 and 55337 have appropriate values. PMI ticket counters have also appropriate values
    ...      Note! Since handover is rejected only M55125C07506 should be pegged
    ...  10. UE is detached properly and data transfer is stopped
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIO, AHLOA (FDD band 71), AHFIB (FDD band 66)
    ...
    ...                              Real gNB-2:
    ...                              NRCELL-1 band 71 FDD
    ...                              NRCELL-2 band 66 FDD
    ...
    ...                              Simulated gNB-3:
    ...                              NRCELL-1 band 71 FDD
    ...
    ...       ENVIRONMENT ELEMENTS:  Simulated 5GC, real gNB-2, simulated gNB-3
    ...       TESTLINE:              CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_16119 (USCB008699-A#B5: ALT#1)
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55125C07506, M55147C00036, M55147C00037
    ...       BACKLOG ID:                    FCA_5G_L2L3-105171
    ...
    ...  FEATURE SUB-ITEMS:  CB008699-A#B5: Source DRB to QoS flow mapping is missing or is not supported at target gNB during NG based handover
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS:  See Test plan in beginning of this file (Documentation part)
    ...
    ...  REFERENCES:  CFAM CB008699
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008699
    ...
    ...               [27.10.2022] - Test plan documentation created
    ...               [01.11.2022] - Test plan documentation, proposed (ready for review)
    ...               [24.11.2022] - Test plan documentation, approved - https://collab.ext.net.nokia.com/ui#review:id=870792
    ...               [24.12.2022] - Code review for test suite and cases completed
    ...                              https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/51459


    Set Sim Automatic Neighbour Relation  pci=51
    Delta Commissioning Single Parameter Value  actARPBasedAC  off  MRBTS-1/NRBTS-1/NRCELL-1
    Delta Commissioning Single Parameter Value  actInterRatHoSA  false  MRBTS-1/NRBTS-1

    # Enumerated {disabled, enabled, DrbToQosMappingOnly}
    Delta Commissioning Single Parameter Value  actFullRRCConfigurationSaHo  disabled  MRBTS-1/NRBTS-1

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=7
    UE Register And Establish PDU Session  ue_id=5  cell_id=2  gnb_id=2

    Set Default Bearer And Additional QoS Flows  def_qosflow=5  add_qosflows=None
    Establish Pdu Session For UE  ue_id=5  pdu_id=2  nwslice=2  gw_id=2
    UE VoNR Call  ue_id=5  pdu_id=2

    Set Default Bearer And Additional QoS Flows  def_qosflow=9  add_qosflows=4
    Establish Pdu Session For UE  ue_id=5  pdu_id=3  nwslice=3  gw_id=3

    Set Default Bearer And Additional QoS Flows  def_qosflow=7  add_qosflows=8
    Establish Pdu Session For UE  ue_id=5  pdu_id=4  nwslice=1  gw_id=4

    ${VAR1}=  Set variable  drb_id_to_qos_flows_mapping=8:1|2
    ${VAR2}=  Set variable  missing_qfi_per_pdu_in_drbtoqosflowsmapping=2:1|2,3:2
    Execute Egate Command   cmd=ue_gnb_ho_param id=5 gnb=3 ${VAR1} ${VAR2}

    @{QFIs}=  Set variable    1  2
    Start Or Stop Data On All QFIs  ue_id=5  pdu=1  qfis=${QFIs}  throughput=500
    Start Or Stop Data On All QFIs  ue_id=5  pdu=2  qfis=${QFIs}  throughput=500
    Start Or Stop Data On All QFIs  ue_id=5  pdu=3  qfis=${QFIs}  throughput=500
    Start Or Stop Data On All QFIs  ue_id=5  pdu=4  qfis=${QFIs}  throughput=500

    Perform NG Handover  ue_id=5  phycell_id=381  direction=outgoing  carrier_freq=431090  carrier_freq2=126530

    Clear And Start Collecting PMI Tickets
    Check Need Of Fresh PM Counter Interval

    # Handover back to real gNB band 66 cell, intrafreq
    Perform NG Handover  ue_id=5  phycell_id=51  direction=incoming  carrier_freq=431090  ho_failure=${True}

    # radioNetwork: ho-target-not-allowed (8)
    Verify Handover Failure  cause=8

    stop_tcpdump_on_remote_interface

    Stop Collecting PMI Tickets And Verify Full Config Counters  ho_fail=${True}  NG_HO_RES_ALC_F_OTH_TRG=1
    ${pm_counter_file}  Wait For Next Meas File And Verify Full Config Counters
    ...                 NG_HO_RES_ALC_F_OTH_TRG=1  HO_PREP_SUCC_FULLCONF_TRG=0  RRC_RECONF_COMP_FULLCONF_TRG=0  nrcell=2

    [Teardown]  Run Keywords        Set SCOUT TC ID for Reporting
    ...  AND  Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Delta Commissioning Single Parameter Value  actFullRRCConfigurationSaHo  enabled  MRBTS-1/NRBTS-1
    ...  AND  Delta Commissioning Single Parameter Value  actARPBasedAC  on  MRBTS-1/NRBTS-1/NRCELL-1
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=5
    ...  AND  Testcase Teardown


CB008699-B_B2_001_NG_handover-intraFreq_FDD_with_full_or_delta_rrc_reconfig_due_to_unknown_extension_IE_usage
    [Tags]    TC04

    [Documentation]
    ...  DESCRIPTION:  This test verifies that real gNB applies full or delta RRCReconfiguration during Inter gNB intra-frequency
    ...                handover on band 71 via NG interface based on Unknown Extension IE usage received in NGAP: HandoverRequest
    ...
    ...                When full configuration is applied it will erase the old UE configuration and UE shall be configured
    ...                with target node supported IEs values
    ...
    ...                Testcase will also verify Full Config related IE usage and relevant PM and PMI ticket counters for:
    ...                55147 - NR Mobility CU
    ...                55125 - NR NGAP Interface Report per CELL
    ...
    ...                Note! Call is started on real gNB in order to get data transfer working properly. UE is then moved to simulated gNB
    ...                and back to real gNB via NG handover (latter handover from RANSIM to real gNB will be verified)
    ...
    ...  PRECONDITION: USCB008699-B#B2: Unknown extension detected by the target gNB in the source configuration due to usage of older 3GPP
    ...                                 version at the target node of inter-gNB NG based handover
    ...                CB008699:        Full RRC Configuration for SA Handover active (actFullRRCConfigurationSaHo=enabled)
    ...                                 Allowed values: {disabled, enabled, DrbToQosMappingOnly}
    ...                5GC000876:       Radio Admission Control - SA mode activated
    ...                CB008700:        ARP-based admission control in case of multiple DRBs (actARPBasedAC=on)
    ...                CB008731:        IRAT handover from LTE (SA option 2) deactivated (actInterRatHoSA=false, CBRA not used)
    ...                5GC000704:       Intra-frequency HO activated (actIntraFreqHoSA=true)
    ...                5GC000706:       Inter-frequency HO activated (actInterFreqHoSA=true)
    ...                5GC000705:       NG HO activated (handoverAllowedSA=XnHoNotAllowed)
    ...                CB008806:        Intra and Inter-frequency handover via NG activated (actIntraNrNgHo=sourceAndTarget)
    ...                5GC000786:       Voice over NR activated (actVoNR=true)
    ...                CB008379:        GBR Services for SA activated (actNonVoNRGbrService=true)
    ...                Measurements:    55147 - NR Mobility CU (miNrMobilityReportCu=5min)
    ...                                 55125 - NR NGAP Interface Report per CELL active (miNrNGCC=5min)
    ...                UEs that support 5G SA with FDD bands 66 and 71, A2/A3 events with mgaps, VoNR and Access Stratum r16
    ...
    ...  TEST EXECUTION:
    ...  1.  Register UE in gNB-2 cell-1 and establish PDU session 1 with 3 QoS flows (QFI 1, 2, 3 - 5qi-6, 7, 2) and start data transfer
    ...  2.  Establish PDU session 2 for UE with 3 QoS flows (QFI 1, 2, 3 - 5qi-8, 5, 1) and start data transfer
    ...  3.  Establish PDU session 3 for UE with 2 QoS flows (QFI 1, 2 - 5qi-9, 4) and start data transfer
    ...  4.  Trigger Inter gNB intra-freq handover via NG interface to simulated gNB-3
    ...  5.  Set simulated gNB to send late non critical extension in RRCReconfiguration IE:
    ...      -Introduce Introduce 'late non critical extension' in RRC context's RRCReconfiguration-IE information element
    ...  6.  Trigger Inter gNB intra-freq handover via NG interface back to real gNB-2 and check feature relevant E1, F1, NG IF message contents
    ...  7.  Check that following PM counter values (also CP-UE PMI ticket counters) are correct (exact values in test case):
    ...        Counter ID:   PMI counter ID:  Name:
    ...        ============  ===============  ============================
    ...        M55125C07506  3612679506       NG_HO_RES_ALC_F_OTH_TRG  (only incremented in failed handover)
    ...        M55147C00036  3614113828       HO_PREP_SUCC_FULLCONF_TRG
    ...        M55147C00037  3614113829       RRC_RECONF_COMP_FULLCONF_TRG
    ...
    ...  8.  Detach UE
    ...  9.  Repeat steps 1-8 but set simulated gNB to not send Unknown Extension in Master Key update IE
    ...
    ...  EXPECTED RESULTS:
    ...  1.  5G SA UE registration and PDU session establishment is successful and data is started for all QFIs
    ...  2.  Second PDU session establishment is successful and data is started for all QFIs
    ...  3.  Third PDU session establishment is successful and data is started for all QFIs
    ...  4.  Handover is triggered to simulated gNB and UE is in target gNB in RRC Connected state
    ...  6a. Handover is triggered to real gNB and UE is in target gNB in RRC Connected state
    ...  6b. Target gNB will send full RRCReconfiguration and PDU session level or DRB level data forwarding information
    ...
    ...      F1AP: 'UeContextSetupRequest > CUtoDURRC Information > HandoverPreparationInformation > sourceConfig' IE is NOT present!
    ...      F1AP: 'UEContextSetupResponse > FullConfiguration' IE is present (FullConfiguration: full (0))
    ...      NGAP: 'Handover Request Acknowledge > TargetToSource-TransparentContainer > HandoverCommand > RRCReconfiguration >
    ...      nonCriticalExtension > fullConfig: true (0)'
    ...
    ...  7.  PM counters of measurements 55147, 55125 have appropriate values. PMI ticket counters have also appropriate values
    ...  8.  UE is detached properly and data transfer is stopped
    ...  9.  Same expected results than 1-8 except counters HO_PREP_SUCC_FULLCONF_TRG and RRC_RECONF_COMP_FULLCONF_TRG will not be pegged and
    ...
    ...      F1AP: 'UeContextSetupRequest > CUtoDU RRC Information > HandoverPreparationInformation > sourceConfig' IE is present
    ...      F1AP: 'UEContextSetupResponse > FullConfiguration' IE is NOT present
    ...      NGAP: 'Handover Request Acknowledge > TargetToSource-TransparentContainer > HandoverCommand > RRCReconfiguration >
    ...             nonCriticalExtension > fullConfig' is NOT set
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIO, AHLOA (FDD band 71), AHFIB (FDD band 66)
    ...
    ...                              Real gNB-2:
    ...                              NRCELL-1 band 71 FDD
    ...                              NRCELL-2 band 66 FDD
    ...
    ...                              Simulated gNB-3:
    ...                              NRCELL-1 band 71 FDD
    ...
    ...       ENVIRONMENT ELEMENTS:  Simulated 5GC, real gNB-2, simulated gNB-3
    ...       TESTLINE:              CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_16010
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55125C07506, M55147C00036, M55147C00037
    ...       BACKLOG ID:                    FCA_5G_L2L3-105174
    ...
    ...  FEATURE SUB-ITEMS:    CB008699-B#B2: Unknown extension detected by the target gNB in the source configuration due to usage of older 3GPP
    ...                        version at the target node of inter-gNB NG based handover
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS:  See Test plan in beginning of this file (Documentation part)
    ...
    ...  REFERENCES:  CFAM CB008699
    ...
    ...  HISTORY:     History, current status and TC description is available in repository:
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET/CB008699
    ...
    ...               [27.10.2022] - Test plan documentation created
    ...               [01.11.2022] - Test plan documentation, proposed (ready for review)
    ...               [24.11.2022] - Test plan documentation, approved - https://collab.ext.net.nokia.com/ui#review:id=870792
    ...               [24.12.2022] - Code review for test suite and cases completed
    ...                              https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/51459

    Set Sim Automatic Neighbour Relation  pci=50

    Delta Commissioning Single Parameter Value  actInterRatHoSA  false  MRBTS-1/NRBTS-1

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=8,7

    ta5g_pm_counters.Wait For Next Full Pm Interval

    UE Register And Establish PDU Session  ue_id=1  cell_id=1  gnb_id=2

    Set Default Bearer And Additional QoS Flows  def_qosflow=8  add_qosflows=5
    Establish Pdu Session For UE  ue_id=1  pdu_id=2  nwslice=2  gw_id=2
    UE VoNR Call  ue_id=1  pdu_id=2

    Set Default Bearer And Additional QoS Flows  def_qosflow=9  add_qosflows=4
    Establish Pdu Session For UE  ue_id=1  pdu_id=3  nwslice=3  gw_id=3

    Perform NG Handover  ue_id=1  phycell_id=381  direction=outgoing  carrier_freq2=126530  intrafreq=${True}

    # Introduce 'late non critical extension' in RRC context's RRCReconfiguration-IE information element
    ${VAR1}=  Set variable  unsupported_extension_type=late_non_crit_extn_rrcreconfig
    Execute Egate Command  cmd=ue_gnb_ho_param id=1 gnb=3 ${VAR1}

    Clear And Start Collecting PMI Tickets
    Check Need Of Fresh PM Counter Interval

    Perform NG Handover  ue_id=1  phycell_id=50  direction=incoming  carrier_freq=126530

    ################################################
    # Verify FullConfig
    ################################################
    Verify FullConfig  fullConfigSet=${True}

    ################################################
    # Default DRB checking for all DRBs:
    ################################################
    @{drbList}=  Set variable  4  7  10
    Verify DefaultDRB In E1 And NG  drbList=${drbList}  times=3
    @{drbList}=  Set variable  5  6  8  9  11
    Verify DefaultDRB In E1 And NG  drbList=${drbList}  times=0

    ################################################
    # DRB ID usage checking:
    ################################################
    @{drbList}=  Set variable  4  5  6  7  8  9  10  11
    Verify DRB IDs In E1 And NG  drbList=${drbList}  times=8

    stop_tcpdump_on_remote_interface

    Stop Collecting PMI Tickets And Verify Full Config Counters
    ${pm_counter_file}  Wait For Next Meas File And Verify Full Config Counters

    [Teardown]  Run Keywords    Set SCOUT TC ID for Reporting
    ...  AND  Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=1
    ...  AND  Testcase Teardown


CB008699-B_B2_004_NG_handover-interFreq_FDD_unknown_extension_IE_usage_with_CB008699_disabled
    [Tags]    TC06

    [Documentation]
    ...  DESCRIPTION:  This test will verify alternate scenarios ALT#2 where lateNonCriticalExtension is detected but feature is deactivated
    ...                and ALT#1 where feature is active but criticalExtensionFuture is detected during Inter gNB inter-frequency
    ...                handover between bands 71 and 66 via NG interface
    ...
    ...                In ALT#2 delta RRC Reconfiguration should be applied. In ALT#1 handover should be rejected
    ...
    ...                Test case also verifies relevant PM and PMI ticket counters for:
    ...                55147 - NR Mobility CU
    ...                55125 - NR NGAP Interface Report per CELL
    ...
    ...                Note! Call is started on real gNB in order to get data transfer working properly. UE is then moved to simulated gNB
    ...                and back to real gNB via NG handover (latter handover from RANSIM to real gNB will be verified)
    ...
    ...  PRECONDITION: USCB008699-B#B2: Unknown extension detected by the target gNB in the source configuration due to usage of older 3GPP
    ...                                 version at the target node of inter-gNB NG based handover
    ...                CB008699:        Full RRC Configuration for SA Handover active (actFullRRCConfigurationSaHo=enabled)
    ...                                 Allowed values: {disabled, enabled, DrbToQosMappingOnly}
    ...                                 Note! This parameter will be set to value 'DrbToQosMappingOnly' and to value 'disabled'
    ...                                 during test case execution via delta commissioning
    ...                5GC000876:       Radio Admission Control - SA mode activated
    ...                CB008700:        ARP-based admission control in case of multiple DRBs (actARPBasedAC=on)
    ...                CB008731:        IRAT handover from LTE (SA option 2) deactivated (actInterRatHoSA=true, CBRA used)
    ...                5GC000704:       Intra-frequency HO activated (actIntraFreqHoSA=true)
    ...                5GC000706:       Inter-frequency HO activated (actInterFreqHoSA=true)
    ...                5GC000705:       NG HO activated (handoverAllowedSA=XnHoNotAllowed)
    ...                CB008806:        Intra and Inter-frequency handover via NG activated (actIntraNrNgHo=sourceAndTarget)
    ...                5GC000786:       Voice over NR activated (actVoNR=true)
    ...                CB008379:        GBR Services for SA activated (actNonVoNRGbrService=true)
    ...                Measurements:    55147 - NR Mobility CU (miNrMobilityReportCu=5min)
    ...                                 55125 - NR NGAP Interface Report per CELL active (miNrNGCC=5min)
    ...                UEs that support 5G SA with FDD bands 66 and 71, A2/A3 events with mgaps, VoNR and Access Stratum r16
    ...
    ...  TEST EXECUTION:
    ...  1.  Register UE in gNB-2 cell-2 and establish PDU session 1 with 2 QoS flows (QFI 1, 2 - 5qi-6, 2) and start data transfer
    ...  2.  Establish PDU session 2 for UE with 2 QoS flows (QFI 1, 2 - 5qi-5, 1) and start data transfer
    ...  3.  Establish PDU session 3 for UE with 2 QoS flows (QFI 1, 2 - 5qi-9, 4) and start data transfer
    ...  4.  Establish PDU session 4 for UE with 2 QoS flows (QFI 1, 2 - 5qi-7, 8) and start data transfer
    ...  5.  Trigger Inter gNB intra-freq handover via NG interface to simulated gNB-3
    ...  6.  Set simulated gNB to send late non critical extension in RRCReconfiguration IE:
    ...      -Introduce 'late non critical extension' in RRC context's RRCReconfiguration-IE information element
    ...  7.  Delta commission actFullRRCConfigurationSaHo to value disabled
    ...  8.  Trigger Inter gNB intra-freq handover via NG interface back to real gNB-2 and check feature relevant E1, F1, NG IF message contents
    ...  9.  Check that following PM counter values (also CP-UE PMI ticket counters) are correct (exact values in test case):
    ...        Counter ID:   PMI counter ID:  Name:
    ...        ============  ===============  ============================
    ...        M55125C07506  3612679506       NG_HO_RES_ALC_F_OTH_TRG  (only incremented in failed handover)
    ...        M55147C00036  3614113828       HO_PREP_SUCC_FULLCONF_TRG
    ...        M55147C00037  3614113829       RRC_RECONF_COMP_FULLCONF_TRG
    ...
    ...  10. Detach UE
    ...  11. Repeat steps 1-10 but Delta commission actFullRRCConfigurationSaHo to value DrbToQosMappingOnly
    ...  12. Repeat steps 1-10 but Delta commission actFullRRCConfigurationSaHo to value enabled and set simulated gNB to send
    ...      critical extension future in RRC context's RRCReconfiguration information element in step 6
    ...  13. Repeat steps 1-10 but Delta commission actFullRRCConfigurationSaHo to value disabled and set simulated gNB to send
    ...      critical extension future in RRC context's RRCReconfiguration information element in step 6
    ...
    ...  EXPECTED RESULTS:
    ...  1.  5G SA UE registration and PDU session establishment is successful and data is started for all QFIs
    ...  2.  Second PDU session establishment is successful and data is started for all QFIs
    ...  3.  Third PDU session establishment is successful and data is started for all QFIs
    ...  4.  Fourth PDU session establishment is successful and data is started for all QFIs
    ...  5.  Handover is triggered to simulated gNB and UE is in target gNB in RRC Connected state
    ...  7.  Online delta commissioning is done and gNB is not restarted
    ...  8a. Handover is triggered to real gNB and UE is in target gNB in RRC Connected state
    ...  8b. Target gNB applies delta configuration to UE
    ...
    ...      F1AP: 'UeContextSetupRequest > CUtoDU RRC Information > HandoverPreparationInformation > sourceConfig' IE is present
    ...      F1AP: 'UEContextSetupResponse > FullConfiguration' IE is NOT present
    ...      NGAP: 'Handover Request Acknowledge > TargetToSource-TransparentContainer > HandoverCommand > RRCReconfiguration >
    ...             nonCriticalExtension > fullConfig' is NOT set
    ...
    ...  9.  PM counters of measurements 55147, 55125 have appropriate values. PMI ticket counters have also appropriate values
    ...      Note! Since delta RRC configuration will be used, counters should not be pegged
    ...  10. UE is detached properly and data transfer is stopped
    ...  11. Same expected results than 1-10
    ...  12. Same expected results than 1-10 except target gNB shall reject the handover and send NGAP: HandoverFailure and
    ...      M55125C07506 will be pegged
    ...  13. Same expected results than 1-10 except target gNB shall reject the handover and send NGAP: HandoverFailure and
    ...      M55125C07506 will be pegged
    ...
    ...  POSTCONDITION:  Teardown test suite and simulator and collect logs
    ...
    ...  TESTING TOOLS:  UTE, Robot, AirPhone, WTS, Wireshark
    ...
    ...  TEST ENVIRONMENT:
    ...       HARDWARE ID:           ASIB, ABIO, AHLOA (FDD band 71), AHFIB (FDD band 66)
    ...
    ...                              Real gNB-2:
    ...                              NRCELL-1 band 71 FDD
    ...                              NRCELL-2 band 66 FDD
    ...
    ...                              Simulated gNB-3:
    ...                              NRCELL-1 band 71 FDD
    ...
    ...       ENVIRONMENT ELEMENTS:  Simulated 5GC, real gNB-2, simulated gNB-3
    ...       TESTLINE:              CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...
    ...  REQUIREMENTS COVERAGE:
    ...       REQUIREMENTS IN SCOPE:         5G_RAN_USR_RRM_16010 (USCB008699-B#B2: ALT#1 & ALT#2)
    ...       REQUIREMENTS OUT OF SCOPE:     -
    ...       NON-REQUIREMENTS-BASED TESTS:  -
    ...       PM COUNTERS:                   M55125C07506, M55147C00036, M55147C00037
    ...       BACKLOG ID:                    FCA_5G_L2L3-105174
    ...
    ...  FEATURE SUB-ITEMS:    CB008699-B#B2: Unknown extension detected by the target gNB in the source configuration due to usage of older 3GPP
    ...                        version at the target node of inter-gNB NG based handover
    ...
    ...  REQUIRED LOGS:  Wireshark logs, Syslog
    ...
    ...  CONTACTS:  See Test plan in beginning of this file (Documentation part)
    ...
    ...  REFERENCES:  CFAM CB008699
    ...
    ...  HISTORY:     History, current status and TC description is available in repository (To be completed when TCs reviewed):
    ...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Espoo/ET
    ...
    ...               [31.10.2022] - Test plan documentation created
    ...               [01.11.2022] - Test plan documentation, proposed (ready for review)
    ...               [24.11.2022] - Test plan documentation, approved - https://collab.ext.net.nokia.com/ui#review:id=870792
    ...               [24.12.2022] - Code review for test suite and cases completed
    ...                              https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/51459

    Set Sim Automatic Neighbour Relation  pci=51

    # Enumerated {disabled, enabled, DrbToQosMappingOnly}
    Delta Commissioning Single Parameter Value  actFullRRCConfigurationSaHo  disabled  MRBTS-1/NRBTS-1

    Set Default Bearer And Additional QoS Flows  def_qosflow=6  add_qosflows=7
    UE Register And Establish PDU Session  ue_id=1  cell_id=2  gnb_id=2

    Set Default Bearer And Additional QoS Flows  def_qosflow=5  add_qosflows=None
    Establish Pdu Session For UE  ue_id=1  pdu_id=2  nwslice=2  gw_id=2
    UE VoNR Call  ue_id=1  pdu_id=2

    Set Default Bearer And Additional QoS Flows  def_qosflow=9  add_qosflows=4
    Establish Pdu Session For UE  ue_id=1  pdu_id=3  nwslice=3  gw_id=3

    Set Default Bearer And Additional QoS Flows  def_qosflow=7  add_qosflows=8
    Establish Pdu Session For UE  ue_id=1  pdu_id=4  nwslice=1  gw_id=4

    UE Register And Establish PDU Session  ue_id=2  pdu_id=5  cell_id=2  gnb_id=2  gw_id=5
    UE Register And Establish PDU Session  ue_id=3  pdu_id=6  cell_id=2  gnb_id=2  gw_id=6
    UE Register And Establish PDU Session  ue_id=4  pdu_id=7  cell_id=2  gnb_id=2  gw_id=7

    # Introduce 'late non critical extension' in RRC context's RRCReconfiguration-IE information element
    ${VAR1}=  Set variable  unsupported_extension_type=late_non_crit_extn_rrcreconfig
    Execute Egate Command  cmd=ue_gnb_ho_param id=1 gnb=3 ${VAR1}
    Execute Egate Command  cmd=ue_gnb_ho_param id=2 gnb=3 ${VAR1}

    # Introduce 'critical extension future' in RRC context's RRCReconfiguration information element > Handover failure !!!
    ${VAR1}=  Set variable  unsupported_extension_type=critical_extn_futr_rrcreconfig
    Execute Egate Command  cmd=ue_gnb_ho_param id=3 gnb=3 ${VAR1}
    Execute Egate Command  cmd=ue_gnb_ho_param id=4 gnb=3 ${VAR1}

    Perform NG Handover  ue_id=1  phycell_id=381  direction=outgoing  carrier_freq=431090  carrier_freq2=126530
    Perform NG Handover  ue_id=2  phycell_id=381  direction=outgoing  carrier_freq=431090  carrier_freq2=126530
    Perform NG Handover  ue_id=3  phycell_id=381  direction=outgoing  carrier_freq=431090  carrier_freq2=126530
    Perform NG Handover  ue_id=4  phycell_id=381  direction=outgoing  carrier_freq=431090  carrier_freq2=126530

    # Need to wait for meas interval since rest of TC takes minutes to execute..
    Get Next Unpacked Full Pm Counters File

    Perform NG Handover  ue_id=1  phycell_id=51  direction=incoming  carrier_freq=431090

    ################################################
    # Verify FullConfig not used - UE1 delta RRC
    ################################################
    Verify FullConfig  fullConfigSet=${False}

    Delta Commissioning Single Parameter Value  actFullRRCConfigurationSaHo  DrbToQosMappingOnly  MRBTS-1/NRBTS-1
    Perform NG Handover  ue_id=2  phycell_id=51  direction=incoming  carrier_freq=431090

    ################################################
    # Verify FullConfig not used - UE2 delta RRC
    ################################################
    Verify FullConfig  fullConfigSet=${False}

    # Critical future extension usage will always cause HO reject
    Perform NG Handover  ue_id=3  phycell_id=51  direction=incoming  carrier_freq=431090  ho_failure=${True}

    Delta Commissioning Single Parameter Value  actFullRRCConfigurationSaHo  disabled  MRBTS-1/NRBTS-1
    # Critical future extension usage will always cause HO reject
    Perform NG Handover  ue_id=4  phycell_id=51  direction=incoming  carrier_freq=431090  ho_failure=${True}

    stop_tcpdump_on_remote_interface
    ${pm_counter_file}  Wait For Next Meas File And Verify Full Config Counters
    ...                 NG_HO_RES_ALC_F_OTH_TRG=2  HO_PREP_SUCC_FULLCONF_TRG=0  RRC_RECONF_COMP_FULLCONF_TRG=0  nrcell=2

    [Teardown]  Run Keywords    Set SCOUT TC ID for Reporting
    ...  AND  Log to console  Teardown started for TC: ${TEST_NAME} ..
    ...  AND  Delta Commissioning Single Parameter Value  actFullRRCConfigurationSaHo  enabled  MRBTS-1/NRBTS-1
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=1
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=2
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=3
    ...  AND  Run keyword and ignore error   UE Deregister  ue_id=4
    ...  AND  Testcase Teardown
