*** Settings ***

Documentation
...
...     INTRODUCTION:  CB013392-A Measurement Profiles Power Class criterion for CA UEs
...                    The CB013392 introduces the possibility to assign different values
...                    of mobility measurement parameters and Power Class determination
...                    to different UE groups for UL CA
...
...     TEST SET NAME: CB013392_A_SA_Power_Class_determination_UL_CA
...
...     TESTING SCOPE: covers CB013392-A subfeature
...
...     CONTACTS:      MN RAN RD VRF ULM 6 <I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com>
...                    Lavanya Schmid, Daniel Lammers, Nikolay Shkulepov
...
...     REFERENCES:
...                [1] CB013392 CFAM: https://gates.nsn-net.net/view/00025ee1#o=0
...                [2] CB013392 FTS: https://nokia.sharepoint.com/:w:/r/sites/mn-ran-productization
...                                  /RAN%20Productization%20WoW/_layouts/15/Doc.aspx?
...                                  sourcedoc=%7BBAAAD487-C383-43D5-A997-72C86F89DD95%7D&file
...                                  =CB013392_Feature_Test_Strategy.docx&action=default&mobileredirect=true&wdsle=0
...                [3] Review Session in Collaborator: https://collab.ext.net.nokia.com/ui#review:id=913592
...
...      HISTORY:
...                [03.07.2024] - Initial version
...                [31.07.2024] - Created Test Plan
...                [13.08.2024] - Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
...                [08.10.2024] - Test Script finished
...                [22.07.2025] - Migration to TMO of TC1


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ../../L2/resources/robot/test_setup.robot
Resource   ../../L2/resources/common_keywords.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB013392_scenario_modifications.robot
Resource   resources/CB013392_scenario_verification.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB013392/CB013392-A/CB013392_A_B1.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_A_B1_TC01_IntragNB_blind_UL_SCell_addition_power_class
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the successful UE configuration of the UL Carrier Aggregation for
    ...               single UE with 2 aggregated carriers. This user scenario modifies the behavior described in
    ...               USCB008127-HS#B1 (5G_RAN_USR_RRM_23751) and introduces usage of power class criterion in UL CA.
    ...
    ...               USCB008127-HS#B1: This user scenario describes the successful UE configuration of the
    ...               Inter-band TDD FR1 - FDD UL CA feature for single UE with 2 aggregated carriers. PCell is
    ...               TDD FR1 carrier and single SCell is FDD carrier. It is assumed that FDD cell and TDD FR1 cell
    ...               have overlaid coverage.  This describes how measurements are reconfigured at the UE using the
    ...               selected measurement profile during the SCell addition.
    ...
    ...  PRECONDITION:
    ...    - CA relation is configured between PCell (NRCELL-1, band nY) and SCell (NRCELL-2, band nX)
    ...        - NRCELL-1/NRREL-1 points to NRCELL-2
    ...        - NRCELL-1/NRREL-1.sCellAdditionMethod is set to "blind"
    ...    - Deactivate measurement based SCell addition
    ...        - NRBTS/actMeasBasedSCellAdditionSA is set to 'disabled'
    ...    - UL CA is supported (for example CB006137 is enabled)
    ...    - A2/A3/A5 intra-freq measurements are supported (for example 5GC000704, 5GC000708 are enabled)
    ...    - In case the scenario is tested after incoming handover, then the respective handover feature
    ...      must be enabled (5GC000704/706 for Xn HO, CB008806 for NG HO, CB008731 for Inter-RAT HO)
    ...    - CB013392-A is activated ("NRBTS.actMeasurementProfReselForCA" = 'pcInSaUlCaSupported')
    ...    - NRCELL/pMaxNROwnCell parameter must be set to a value equal to or higher than the higher used power class (e.g. 26dBm = pc2)
    ...
    ...    CB013392 related configuration:
    ...        - CB008127 feature is enabled for SA and CB013392-A is activated to support power class criterion in
    ...          UL CA
    ...        - There are two measurement profile mappings defined
    ...            - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and
    ...              higher priority defined in NRCELL
    ...            - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and
    ...              lower priority defined in NRCELL
    ...        - Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...    CB006137-AB#3 related configuration (5G_RAN_USR_RRM_15047):
    ...        - Inter-band TDD FR1 - FDD CA feature (5GC002329) is activated:
    ...            - NRBTS/NRDU/carrierAggregationSupportList enumeration parameter is set to 500 (ca_Fr1Tdd_Fdd_Sa).
    ...            - NRBTS/NRDU/flexibleCAMode = 2 (ConfigurationIndependent).
    ...            - TDD FR1 cell contains NRREL object referring to the FDD cell with optional sCellAdditionMethod
    ...              parameter set to 0 (blind).
    ...            - sCellActivationMethod parameter is set to blind while NIDD parameter
    ...              NRBTS/NRCELL/sCellDeactivationTimergNB is configured with 0(infinity).
    ...        - Inter-band TDD FR1 - FDD UL CA is activated:
    ...            - NRBTS/NRDU/ULcarrierAggregationSupportList enumeration parameter is set to 500 (ca_Fr1Tdd_Fdd_Sa).
    ...        - Support of long PUCCH is selected for all the TDD FR1 and FDD cells of the gNB-DU
    ...            - NRBTS/NRCELL/pucchModeSelect = 1 (longPucch).
    ...        - Cell deployment type NIDD parameter allows SA access to the TDD FR1 cell and FDD cell:
    ...            - NRBTS/NRCELL/cellDepType is set to 1 (SA) or 10 (SA+NSA).
    ...        - DSS is disabled in FDD cell:
    ...            - NRBTS/actLteNrDss = FALSE
    ...        - DRX is disabled in TDD FR1 cell and FDD cell:
    ...            - NRBTS/NRCELL/actCDrx = FALSE
    ...        - FDM Scheduling is enabled:
    ...            - NRBTS/actFdmScheduling = TRUE
    ...        - Beamforming is disabled on TDD FR1 cell:
    ...            - NRBTS/NRCELL.actBeamforming = FALSE
    ...        - Closed loop power control is deactivated:
    ...            - actUlClosedLoopPwrCtrl = 0 (disabled)
    ...        - Simultaneous Harq Ack Nack and CSI is supported (See 5G_L3_4319).
    ...          rdSupportSimultaneousHarqAckCsi  = TRUE
    ...        - TDD FR1 cell is configured with subframe configuration according to
    ...          5GC001116-B (tdLte aligned Frame structure with 0ms shift). (5G_RAN_USR_RRM_14799)
    ...            - frameStructureType = tdLte
    ...            - guardPeriodLength = 6 symbols (SSF6)
    ...            - lteToNrFrameShift = 0ms
    ...            - prachConfiguration = 97 (format A2 in subframe 7)
    ...            - ssBurstSetPeriod = 20ms
    ...        - Both TDD FR1 and FDD Cells are configured and on-air.
    ...
    ...    5GC000704 IFHO-B#B8 related configuration:
    ...      - gNB up and running
    ...      - 5GUE/Airphone up and running
    ...      - Initial context is setup successfully and UE has been configured for measurement event A5.
    ...      - Criteria for the configured measurement event A5 is met.
    ...
    ...    CB008127 related configuration:
    ...        - CB008127 feature is enabled for SA. ("NRBTS.actMeasurementProfile" is "SA" or "SA+NSA")
    ...        - Two instances of " NRMEASPR_IAF" are configured with not the same values.
    ...          (NRBTS/NRMEASPR/NRMEASPR_IAF-1 and NRBTS/NRMEASPR/NRMEASPR_IAF-2)
    ...            - a1MeashoSsbRsrp and a1MeashoSsbRsrq are configured with values different than at NRCELL level.
    ...            - a2MeashoSsbRsrp and a2MeashoSsbRsrq are configured with values different than at NRCELL level.
    ...            - a2MeasRedirectSsbRsrp and a2MeasRedirectSsbRsrq are configured with values different than at NRCELL level
    ...
    ...        - Serving NRCELL (NRCELL-1) points to two mapping MOs (NRMEASPR_MA_SA-1 and NRMEASPR_MA_SA-2).
    ...          Configurations in NRCELL-1 are as follows:
    ...            - "measPrMaSAList[0].nrMeasPrMaSADN" points to "NRBTS/NRMEASPR/NRMEASPR_MA_SA-1"
    ...            - "measPrMaSAList[0].measPrPriority" is set to 10
    ...            - "measPrMaSAList[1].nrMeasPrMaSADN" points to "NRBTS/NRMEASPR/NRMEASPR_MA_SA-2"
    ...            - "measPrMaSAList[1].measPrPriority" is set to 20
    ...        - On both FDD Pcell and TDD FR1 SCell, set MRBTS/NRBTS/NRCELL.pMaxNROwnCell to 26dBm.
    ...
    ...    UE Capabilities:
    ...      - UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE
    ...        “UE-NR-Capability->RF-Parameters) has following:
    ...      - supportedBandListNR contains two bands (nX and nY) having power classes as follows:
    ...            - (band n25, power class 3)
    ...            - (band n41, power class 2)
    ...      - supportedBandCombinationList contains {band nX, band nY}
    ...            - supportedBandCombinationList contains {band n25, band n41, power class 3}
    ...
    ...    Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...    Note 2: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test.
    ...            The only goal is to capture that power class for a single band and power class for the band
    ...            combination are different.
    ...
    ...    Trigger:
    ...      - Initial Context Setup and blind SCell addition procedure starts
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: Register UE to 5G n41 TDD (pc2) cell (PCell).Scell Addition is triggered (n25 FDD).
    ...                    UE supports power class 3 for the band combination n41 and n25
    ...       Expected: - Measurement profile NRMEASPR_IAF-2 is selected as the Intra frequency A3/A5 and A2
    ...                   measurement profile for this UE.
    ...                 - RRC reconfiguration message is verified if the measurement
    ...                   configuration for the events are set as per the measurement profile
    ...                 - reportConfigNr in “measConfig. reportConfigToAddModList" for intra-Freq A3/A5 and A2
    ...                   (mobility and redirection) in RRCReconfiguration message are set according to the selected
    ...                    measurement profile (NRMEASPR_IAF-2) as follows.
    ...                       - The IE "ReportConfigNr.EventTriggerConfig.eventA2" for the MeasObject corresponding to
    ...                         serving cell frequency is filled using "NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp".
    ...                         The IE "ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to
    ...                         serving cell frequency is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2
    ...                         .a2MeasRedirectSsbRsrp"
    ...                       - "ReportConfigNr.EventTriggerConfig.eventA3" for the MeasObject corresponding to PCell
    ...                         is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp"
    ...                       - "ReportConfigNr.EventTriggerConfig.eventA5" for the MeasObject corresponding to PCell
    ...                         is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp"
    ...    Step 3:
    ...       Description: Start DL/UL user data traffic on UE#1
    ...       Expected:    DL and UL data transfer is realized for the UE via both cells.
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology:  CLOUD_5G_I_LOO_AP_LOOO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26742
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Lavanya Schmid
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_A_B1_TC01_IntragNB_blind_UL_SCell_addition_power_class
    tracing.Check For Errors In Syslog


CB013392_A_B1_TC02_IntragNB_blind_UL_SCell_addition_power_class_incoming_HO
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: Alternate Scenario with incoming handover
    ...  PRECONDITION:
    ...    Same as CB013392_HS_B1_TC01_IntragNB_blind_UL_SCell_addition_power_class
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description:  Register UE to any 5G cell and trigger handover to PCell (TDD-FR1 cell)
    ...       Expected: - UE is handed over to PCell
    ...                 - UE is configured with TDD-FR1 cell as PCell and FDD cell as SCell.
    ...                 - Measurement profile NRMEASPR_IAF-2 is selected as the Intra frequency A3/A5 and A2
    ...                   measurement profile for this UE.
    ...                 - RRC reconfiguration message is verified if the measurement
    ...                   configuration for the events are set as per the measurement profile
    ...                 - reportConfigNr in “measConfig. reportConfigToAddModList" for intra-Freq A3/A5 and A2
    ...                   (mobility and redirection) in RRCReconfiguration message are set according to the selected
    ...                    measurement profile (NRMEASPR_IAF-2) as follows.
    ...                       - The IE "ReportConfigNr.EventTriggerConfig.eventA2" for the MeasObject corresponding to
    ...                         serving cell frequency is filled using "NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp".
    ...                         The IE "ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to
    ...                         serving cell frequency is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2
    ...                         .a2MeasRedirectSsbRsrp"
    ...                       - "ReportConfigNr.EventTriggerConfig.eventA3" for the MeasObject corresponding to PCell
    ...                         is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp"
    ...                       - "ReportConfigNr.EventTriggerConfig.eventA5" for the MeasObject corresponding to PCell
    ...                         is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp"
    ...    Step 2:
    ...       Description: Start DL/UL user data traffic on UE#1
    ...       Expected:    DL and UL data transfer is realized for the UE via both cells.
    ...
    ...  TESTING TOOLS:
    ...    - No specific tools needed
    ...
    ...  TEST ENVIRONMENT:
    ...      HARDWARE ID:
    ...             1x gNB: ASIL / ABIO
    ...             Airphone: ASIL / ABIO
    ...             WTS 5G Core Simulator
    ...             UTE Cloud Topology:  CLOUD_5G_I_LOO_AP_LOOO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26742
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Lavanya Schmid
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_A_B1_TC02_IntragNB_blind_UL_SCell_addition_power_class_incoming_HO


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable
    ...    /home/ute/logs/CB013392_A_B2/2025-07-08T08-50-53-F/CB013392_A_B2/SBTS00_ENB_9999_250707_000008/20250708_085128
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_A_B1_TC01_IntragNB_blind_UL_SCell_addition_power_class
