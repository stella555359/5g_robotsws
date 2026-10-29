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
...                [17.07.2024] - Initial version
...                [31.07.2024] - Created Test Plan
...                [13.08.2024] - Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
...                [10.10.2024] - Test Script finished
...                [23.07.2025] - Migration to TMO


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
${relative_json_path}             ../../CB013392/CB013392-A/CB013392_A_B5.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_A_B5_TC01_IntragNB_A2_UL_SCell_release_power_class
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This user scenario describes the successful UE mobility measurements reconfiguration during
    ...               Intra-gNB UL SCell release. This scenario updates the scenario originally covered by
    ...               USCB008127-HS#B4 by adding private IE in communication between gNB-CU-CP and gNB-DU.
    ...
    ...               USCB008127-HS#B4: The existing user scenario “USCB006137-AB#8 (5G_RAN_USR_RRM_15096): Single UE
    ...               connection setup with UL CA, TDD FR1 cell as PCell and FDD cell as SCell (A1 MR based SCell
    ...               addition and A2 MR based SCell release) (SA)” describes the successful configuration of UE
    ...               with the Inter-band TDD+FDD UL+DL CA with 2 aggregated carriers. An A1 MR received from the
    ...               UE triggers SCell addition and an A2 MR received later on triggers the SCell release.
    ...               PCell is TDD carrier and the SCell is FDD carrier.
    ...  PRECONDITION:
    ...    - UE is connected to PCell (NRCELL-1, band nY) and SCell (NRCELL-2, band nX)
    ...    - Intra-gNB UL Carrier Aggregation is supported (for example CB006137 is enabled)
    ...    - Intra-freq (for example 5GC000704) and inter-freq (for example 5GC000706) measurements are supported
    ...    - NRCELL/pMaxNROwnCell parameter must be set to a value equal to or higher than the higher used power class (e.g. 26dBm = pc2)
    ...
    ...    CB013392 related configuration:
    ...      • CB008127 feature is enabled for SA and CB013392-A is activated to support the effective power class
    ...        criterion determination based on power control output
    ...      • There are two measurement profile mappings defined
    ...          • NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher priority defined in NRCELL-1
    ...          • NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower priority defined in NRCELL-1
    ...          • Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...    CB006137-AB#3 related configuration(5G_RAN_USR_RRM_15047):
    ...        - gNB configured with TDD FR1 and FDD cells on different ABILs.
    ...        - Inter-band TDD FR1 - FDD CA feature (5GC002329) is activated:
    ...        - NRBTS/NRDU/carrierAggregationSupportList enumeration parameter is set to 500 (ca_Fr1Tdd_Fdd_Sa).
    ...        - NRBTS/NRDU/flexibleCAMode = 2 (ConfigurationIndependent).
    ...        - sCellActivationMethod parameter is set to blind while NIDD parameter
    ...          NRBTS/NRCELL/sCellDeactivationTimergNB is configured with 0(infinity).
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
    ...    5GC000706-A#B1 related configuration:
    ...      - Inter-frequency Handover is enabled using MRBTS/NRBTS/actInterFreqHoSa
    ...      - Handover related parameters for A2 measurements have been configured through O&M parameters.
    ...      - 5GUE supports UE capability for handover to the target frequency (FR1/FR2)/deployment mode (TDD/FDD).
    ...
    ...    CB008127-HS-B4 related configuration:
    ...      - The preconditions specified in “USCB006137-AB#8” which are relevant to this user scenario are as below
    ...        (Note: The reader does not need to look into preconditions of “USCB006137-AB#8”,
    ...         whatever is needed for this user scenario is described below):
    ...           - NRCELL-1 is configured as a TDD cell on band 'n41' as follows:
    ...               - NRCELL-1. cellTechnology is set to '1' (meaning NRCELL-1 is a TDD cell)
    ...               - NRCELL-1. freqBandIndicatorNR is set to 'n41' (n41 is a TDD band)
    ...               - NRCELL-1 .a1MeashoEnabledSA, NRCELL-1.a2MeashoEnabledSA, NRCELL-1.a3MeasEnabled and
    ...                 NRCELL-1.a5MeasEnabled are set to 'Rsrp' or 'RsrpCombined'.
    ...               - At least one inter-freq target is configured for inter-freq A3/A5 measurements for
    ...                 mobility in NRCELL-1/NRHOIF
    ...               - At least one inter-RAT target is configured for inter-RAT B2 measurement for mobility in
    ...                 NRCELL-1.nrhoirDNList
    ...           - NRCELL-2 is configured as a FDD cell on band 'n25':
    ...               - NRCELL-2.cellTechnology is set to '0' (meaning NRCELL-2 is a FDD cell)
    ...               - NRCELL-2.freqBandIndicatorNR is set to 'n25' (n25 is a FDD band)
    ...               - NRCELL-2.a1MeashoEnabledSA and NRCELL-2.a2MeashoEnabledSA is set to 'Rsrp' or 'RsrpCombined'.
    ...           - CA relation is configured between PCell (NRCELL-1) and SCell (NRCELL-2)
    ...               - NRCELL-1/NRREL-1 points to NRCELL-2
    ...               - NRCELL-1/NRREL-1.sCellAdditionMethod is set to 'covBasedA1'
    ...           -	Activate measurement based SCell addition
    ...               - NRBTS/actMeasBasedSCellAdditionSA is set to 'A1-based'
    ...               - SCell Addition related parameters for A1 measurement are configured:
    ...                   - NRCELL-1/a1MeasSCellAddEnabled
    ...                   - NRCELL-1/a1MeasSCellAddSsbRsrp and/or NRCELL-1/a1MeasSCellAddSsbRsrq based on
    ...                     a1MeasSCellAddEnabled.
    ...           - SCell release related parameters for A2 measurements are configured.
    ...                   - NRCELL-2.a2MeasSCellRelEnabled is set to a not 'none' value.
    ...                   - NRCELL-2.a2MeasSCellRelSsbRsrp or NRCELL-2.a2MeasSCellRelSsbRsrq are configured
    ...                     appropriately.
    ...           - Inter-band FR1 TDD - FDD CA feature (5GC002329) is activated
    ...                   - NRBTS/NRDU/carrierAggregationSupportList enumeration parameter contains ca_Fr1Tdd_Fdd_Sa
    ...           -	Inter-band TDD - FDD FR1 UL CA (CB006137) is activated:
    ...               - NRBTS/NRDU/carrierAggregationSupportList enumeration parameter contains
    ...                 ca_Fr1Tdd_Fdd_Sa_WithUl.
    ...               - NRCELL-1/NRREL-1.sCellOperationalMode is set as 'dlAndUl'
    ...           - Contribution percentage of DL data rate to the overall data rate during band combination and
    ...             feature set selection in FR1 is set
    ...               - NRBTS/NRDU/dlToUlContributionRatio is set as 50
    ...     - CB008127 related configuration:
    ...           - CB008127 feature is enabled for SA. ('NRBTS.actMeasurementProfile' is 'SA' or 'SA+NSA')
    ...           - The mapping MO, 'NRMEASPR_MA_SA-1', is configured as follows:
    ...               - nrMeasPrIafDn points to 'NRBTS/ NRMEASPR/NRMEASPR_IAF-1'
    ...               - nrMeasPrIefDefaultDn points to 'NRBTS/ NRMEASPR/NRMEASPR_IEF-1'
    ...               - nrMeasPrIrfDN points to 'NRBTS/ NRMEASPR/NRMEASPR_IRF-1'
    ...           - The mapping MO, 'NRMEASPR_MA_SA-2', is configured as follows:
    ...               - nrMeasPrIafDn points to 'NRBTS/ NRMEASPR/NRMEASPR_IAF-2'
    ...               - nrMeasPrIefDefaultDn points to 'NRBTS/ NRMEASPR/NRMEASPR_IEF-2'
    ...               - nrMeasPrIrfDN points to 'NRBTS/ NRMEASPR/NRMEASPR_IRF-2'
    ...
    ...          - Two instances of 'NRMEASPR_IEF' are configured. (NRBTS/ NRMEASPR/NRMEASPR_IEF-1 and
    ...            NRBTS/ NRMEASPR/NRMEASPR_IEF-2)
    ...               - a3MeasSsbRsrp/a3MeasSsbRsrq and a5MeasSsbRsrp/a5MeasSsbRsrq are configured with values
    ...                 different than at NRHOIF level.
    ...                 Values in NRMEASPR_IEF-1 and NRMEASPR_IEF-2 are different
    ...          - Two instances of 'NRMEASPR_IRF' are configured. (NRBTS/ NRMEASPR/NRMEASPR_IRF-1 and
    ...            NRBTS/NRMEASPR/NRMEASPR_IRF-2)
    ...               - eutraB2MeashoRsrp/ eutraB2MeashoRsrq and b2Threshold1hoRsrp/ b2Threshold1hoRsrq are
    ...                 configured with values different than at NRHOIR level. Values in NRMEASPR_IRF-1 and
    ...                 NRMEASPR_IRF-2 are different
    ...          - Two instances of ' NRMEASPR_IAF' are configured. (NRBTS/ NRMEASPR/NRMEASPR_IAF-1 and
    ...            NRBTS/NRMEASPR/NRMEASPR_IAF-2)
    ...               - a1MeashoSsbRsrp and a1MeashoSsbRsrq are configured with values different than at NRCELL level.
    ...                 Values in NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are different.
    ...               - a2MeashoSsbRsrp and a2MeashoSsbRsrq are configured with values different than at NRCELL level.
    ...                 Values in NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are different.
    ...               - a2MeasRedirectSsbRsrp and a2MeasRedirectSsbRsrq are configured with values different than at
    ...                 NRCELL level. Values in NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are different.
    ...          - Serving NRCELL (NRCELL-1) points to two mapping MOs (NRMEASPR_MA_SA-1 and NRMEASPR_MA_SA-2).
    ...            Configurations in NRCELL-1 are as follows:
    ...               - 'measPrMaSAList[0].nrMeasPrMaSADN' points to 'NRBTS/NRMEASPR/NRMEASPR_MA_SA-1'
    ...               - 'measPrMaSAList[0]. measPrPriority' is set to 10
    ...               - 'measPrMaSAList[1].nrMeasPrMaSADN' points to 'NRBTS/NRMEASPR/NRMEASPR_MA_SA-2'
    ...               - 'measPrMaSAList[1]. measPrPriority' is set to 11
    ...
    ...    UE Capabilities:
    ...    - UE capabilities as received from UE in the message “RRC:UE Capability Information” (IE “UE-NR-Capability->RF-Parameters) has following:
    ...          - supportedBandListNR contains two bands (n25 and n41) having power classes as follows:
    ...             - (band n25, power class 3)
    ...             - (band n41, power class 2)
    ...          - supportedBandCombinationList contains {band n25, band n41}
    ...             - (bandCombination n25 & n41, power class 3)
    ...
    ...    Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: Register UE to 5G cell and trigger A1 measurement (on PCell) for SCell addition.
    ...                    (PCell -> TDD FR1, band n41 and SCell -> FDD, band n25)
    ...       Expected:    - UE attached successfully to 5G cell and is configured with TDD-FR1 cell as PCell
    ...                      and FDD cell as SCell.
    ...                    - NRMEASPR_IAF-2 is chosen for measurement event values as the band combination (n41 and n25)
    ...                      has pc3 which corresponds to NRMEASPR_IAF-2
    ...
    ...    Step 2:
    ...        Description: Trigger A2 measurement (on SCell) using the values from NRMEASPR_IAF-2 in "ue_measurement_send_nr" EGATE command
    ...        Expected:    - UE is successfully released from SCell.
    ...                     - The A2, A3 and A5 values in the UE are changed to NRMEASPR_IAF-1 values as UE is now
    ...                       attached to PCell(n41) whose power class is pc2. PC2 corresponds to NRMEASPR_IAF-1.
    ...
    ...    Step 3:
    ...        Description: Start DL and UL user data traffic on UE#1
    ...        Expected:    - Data transfer is realized for the UE via PCell only
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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26865
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Daniel Lammers
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_A_B5_TC01_IntragNB_A2_UL_SCell_release_power_class
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable
    ...    /home/ute/logs/CB013392_A_B5/2025-07-23T07-33-48-F/CB013392_A_B5/SBTS00_ENB_9999_250722_000007/20250723_073435
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_A_B5_TC01_IntragNB_A2_UL_SCell_release_power_class
