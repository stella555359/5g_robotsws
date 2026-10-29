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
...                [04.07.2024] - Initial version
...                [31.07.2024] - Created Test Plan
...                [13.08.2024] - Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
...                [29.10.2024] - Test Script finished
...                [15.07.2025] - Migration to TMO

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
${relative_json_path}             ../../CB013392/CB013392-A/CB013392_A_B3.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB013392_A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    [Documentation]
    ...  DESCRIPTION: This user scenario extends the user scenario “USCB008127-HS#B3” (5G_RAN_USR_RRM_23772)
    ...               and describes how measurements are reconfigured at the UE using the selected measurement profile
    ...               during the SCell change.
    ...
    ...               USCB008127-HS#B3: This test case verifies the A1 based SCell addition and is applied only
    ...               when one TDD PCell has both FDD SCells and FR1 TDD SCells.
    ...
    ...  PRECONDITION:
    ...   · CA relation is configured between PCell (NRCELL-3, band nY) and SCell-1 (NRCELL-4, band nX) and SCell-2 (NRCELL-8, band nZ)
    ...       · NRCELL-3/NRREL-1 points to NRCELL-4
    ...       · NRCELL-3/NRREL-2 points to NRCELL-8
    ...   · UE is connected to NRCELL-3 (PCell) and NRCELL-4 (DL only SCell-1)
    ...       · Measurement based SCell addition is setup (5GC001765 and related features)
    ...   · UL CA is supported (for example CB006137 is enabled)
    ...   · Intra-freq measurements are supported (for example 5GC000704/5GC000708 are enabled)
    ...   · CB013392-A is activated ("NRBTS.actMeasurementProfReselForCA" = pcInSaUlCaSupported)
    ...   · NRCELL/pMaxNROwnCell parameter must be set to a value equal to or higher than the higher used power class (e.g. 26dBm = pc2)
    ...
    ...   · CB013392 related configuration:
    ...       · CB008127 feature is enabled for SA and CB013392-A is activated to support power class criterion in UL CA
    ...       · There are two measurement profile mappings defined
    ...           - NRMEASPR_MA_SA-1 with ue-PowerClass2 criterion and NRMEASPR_IAF-1 profile pointed and higher
    ...             priority defined in NRCELL
    ...           - NRMEASPR_MA_SA-2 with ue-PowerClass3 criterion and NRMEASPR_IAF-2 profile pointed and lower
    ...             priority defined in NRCELL
    ...       · Measurement profiles NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are configured with different values
    ...
    ...   · Updated preconditions as indicated in original US CB008015-B#B3 and for CB009169. Some of the important
    ...     configurations described in are elaborated as below (refer below for CB013392_A_B3 cell config):
    ...            - One SCell is configured as a FDD cell on band "n25":
    ...                - NRCELL.cellTechnology is set to "0" (meaning NRCELL-3 is a FDD cell)
    ...                - NRCELL.freqBandIndicatorNR is set to "n25" (n25 is a FDD band)
    ...            - PCell is configured as a TDD cell on band "n41" follows:
    ...                - NRCELL.cellTechnology is set to "1" (meaning NRCELL-3 is a TDD cell)
    ...                - NRCELL.freqBandIndicatorNR is set to "n41" (n41 is a TDD band)
    ...                - NRCELL. a2MeasRedirectEnabled is set to "rsrp"
    ...                - NRCELL.a1MeashoEnabledSA and NRCELL-4.a2MeashoEnabledSA is set to "rsrp".
    ...                - NRCELL.a3MeasEnabled is set to "rsrp"
    ...                - NRCELL.a5MeasEnabled is set to "rsrp"
    ...                - At least one inter-freq target is configured for inter-freq A3/A5 measurements for mobility
    ...                  in NRCELL/NRHOIF
    ...                - SCell Addition related parameters for A1 measurement are configured:
    ...                    - NRCELL/a1MeasSCellAddEnabled is set to "rsrp"
    ...                    - NRCELL/a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD is configured with a lower
    ...                      threshold than NRCELL-4.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD
    ...            - Another SCell is configured as a TDD cell on band "n41" follows:
    ...                - NRCELL.cellTechnology is set to "1" (meaning NRCELL is a TDD cell)
    ...                - NRCELL.freqBandIndicatorNR is set to "n41" (n41 is a TDD band)
    ...            - CA relation is configured between TDD PCell and FDD SCell
    ...                - NRCELL/NRREL-1 of TDD points to NRCELL of FDD SCell
    ...                - NRCELL/NRREL-1.sCellAdditionMethod is set to "covBasedA1"
    ...            - CA relation is configured between TDD PCell and TDD SCell
    ...                - NRCELL/NRREL-2 of TDD points to TDD SCell
    ...                - NRCELL/NRREL-2.sCellAdditionMethod is set to "covBasedA1"
    ...            - Activate measurement based SCell addition
    ...                - NRBTS/actMeasBasedSCellAdditionSA is set to 'A1-based'
    ...            - Inter-band FDD - TDD FR1 CA feature (5GC002329) is activated
    ...                - NRBTS/NRDU/carrierAggregationSupportList enumeration parameter contains ca_Fr1Tdd_Fdd_Sa.
    ...            - Inter-band FDD - TDD FR1 UL CA (CB006137) is activated:
    ...                - NRBTS/NRDU/carrierAggregationSupportList enumeration parameter contains
    ...                  ca_Fr1Tdd_Fdd_Sa_WithUl
    ...                - NRREL.sCellOperationalMode is set as dlAndUl under FDD cell (NRCELL-3)
    ...            - Contribution percentage of DL data rate to the overall data rate during band combination and
    ...              feature set selection in FR1 is set
    ...                - NRBTS/NRDU/dlToUlContributionRatio is set as 50
    ...
    ...    CB008127 related configuration:
    ...    - CB008127 feature is enabled for SA. ("NRBTS.actMeasurementProfile" is "SA" or "SA+NSA")
    ...        - The mapping MO, "NRMEASPR_MA_SA-1", is configured as follows:
    ...            - pcCapabilityList is set to "(ue-PowerClass2 and without freqBandIndicatorNR)"
    ...            - nrMeasPrIafDn points to "NRBTS/ NRMEASPR/NRMEASPR_IAF-1
    ...            - nrMeasPrIefDefaultDn points to "NRBTS/ NRMEASPR/NRMEASPR_IEF-1"
    ...        - Two instances of "NRMEASPR_IEF" are configured:
    ...            - NRBTS/ NRMEASPR/NRMEASPR_IEF-1
    ...                - a3MeasSsbRsrp/a3MeasSsbRsrq and a5MeasSsbRsrp/a5MeasSsbRsrq are configured with values
    ...                  different than at NRHOIF level.
    ...            - NRBTS/ NRMEASPR/NRMEASPR_IEF-2
    ...                - a3MeasSsbRsrp/a3MeasSsbRsrq and a5MeasSsbRsrp/a5MeasSsbRsrq are configured with values
    ...                  different than at NRHOIF level.
    ...        - Two instances of " NRMEASPR_IAF" are configured. (NRBTS/NRMEASPR/NRMEASPR_IAF-1 and NRBTS/
    ...          NRMEASPR/NRMEASPR_IAF-2)
    ...            - a1MeashoSsbRsrp and a1MeashoSsbRsrq are configured with values different than at NRCELL level.
    ...              Values in NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are different.
    ...            - a2MeashoSsbRsrp and a2MeashoSsbRsrq are configured with values different than at NRCELL level.
    ...              Values in NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are different.
    ...            - a2MeasRedirectSsbRsrp and a2MeasRedirectSsbRsrq are configured with values different than at
    ...              NRCELL level. Values in NRMEASPR_IAF-1 and NRMEASPR_IAF-2 are different.
    ...        - Serving NRCELL (TDD PCell) points to two mapping MOs (NRMEASPR_MA_SA-1 and NRMEASPR_MA_SA-2).
    ...          Configurations in TDD PCell are as follows:
    ...            - "measPrMaSAList[0].nrMeasPrMaSADN" points to "NRBTS/NRMEASPR/NRMEASPR_MA_SA-1"
    ...            - "measPrMaSAList[0].measPrPriority" is set to 10
    ...            - "measPrMaSAList[1].nrMeasPrMaSADN" points to "NRBTS/NRMEASPR/NRMEASPR_MA_SA-2"
    ...            - "measPrMaSAList[1].measPrPriority" is set to 20
    ...        - NRCELL frequency bands configuration is:
    ...            - TDD PCell is n41
    ...            - FDD SCell is n25
    ...            - TDD SCell is n41
    ...
    ...  CB008015-B#B3 related configuration:
    ...      gNB Preconditions:
    ...      - Preconditions for gNB is same with CB008015-B#B1.
    ...      - And the weighted cell bandwidth is configured as below:
    ...          - If TDD is P(S) cell:
    ...              - FDD SCell > TDD SCell
    ...      - Loading (number of served UEs) in each SCell is the same.
    ...      Preconditions for UE:
    ...          SA UE-1 supports
    ...              - TDD-TDD 2CC with band combination for n41 and n41.
    ...              - TDD-FDD 2CC with band combination for n41 and n25.
    ...
    ...  CB008015-B#B1 related configuration:
    ...      - Feature flag for connected mode mobility of mixed CA is activated
    ...        (NRBTS/NRDU.actConnectedModeMobilityCA = true).
    ...      - FlexibleCAMode is set as 2(correseponding to ConfigurationIndependent).
    ...      - Inter L2-RT scheduling feature flag is active (NRBTS/NRDU.actInterNumerologyCa = true).
    ...      - Six items are configured for NRBTS/NRDU.carrierAggregationSupportList enumeration parameter
    ...          - NRBTS/NRDU.carrierAggregationSupportList[0] is set to 200 (ca_Fdd_Fr1Tdd_Sa)
    ...          - NRBTS/NRDU.carrierAggregationSupportList[1] is set to 201 (ca_Fdd_Fr1Tdd_Nsa)
    ...          - NRBTS/NRDU.carrierAggregationSupportList[2] is set to 3 (ca_Fdd_Fdd)
    ...          - NRBTS/NRDU.carrierAggregationSupportList[3] is set to 400 (ca_FR1Tdd_Sa)
    ...          - NRBTS/NRDU.carrierAggregationSupportList[4] is set to 401 (ca_FR1Tdd_Nsa)
    ...          - NRBTS/NRDU.carrierAggregationSupportList[5] is set to 500 (ca_FR1Tdd_Fdd_Sa)
    ...
    ...      - Set NRBTS/NRCELL.pucchModeSelect as longPucch for all cells.
    ...      - DSS features is enabled: NRBTS/actLteNrDss = true.
    ...      - DRX is enabled. NRBTS/NRCELL/actCDrx = true for all cells.
    ...      - NRBTS/actFdmScheduling is set as true.
    ...      - NRBTS/NRCELL/actPrachMultiplexing = true for all cells.
    ...      - Set NRBTS/NRCELL.maxNumOfSCellAlloc as 250 for all cells.
    ...
    ...    All cells are configured as SA and NSA mode. NRBTS/NRCELL/cellDepType = 10 (SA+NSA).
    ...    Based on the cell configuration proposed in CB008015-B#B1, there shall be 3 test instances with the
    ...    following configurations:
    ...        - FR1 TDD - FDD CA relationship with:
    ...              - Scell: lteNrDSSMode=0
    ...              - PCell: SCellAdditionMethod=covBasedA1
    ...                       a1MeasSCellAddEnabled=rsrp
    ...        - FR1-TDD - FDD CA relationship with:
    ...              - Scell: lteNrDSSMode=3
    ...              - PCell: SCellAdditionMethod=covBasedA1
    ...                       a1MeasSCellAddEnabled=rsrp
    ...        - FR1 TDD - TDD CA relationship with:
    ...              - PCell: SCellAdditionMethod=covBasedA1
    ...                       a1MeasSCellAddEnabled=rsrp
    ...
    ...    NRREL objects configured under different P(S)Cell can configure different value for
    ...      - NRBTS.actMeasBasedSCellAddition and NRBTS.actMeasBasedSCellAdditionNSA must be set as TRUE.
    ...      - NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD and
    ...            NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD need be configured.
    ...      - Other parameters under NRBTS/NRCELL.a1MeasSCellAddSsbRsrp are configured properly based on 5GC001765,
    ...        5GC002329, CB007726, CB007877 and CB007893.
    ...      - NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpFDD has higher value than
    ...        NRBTS/NRCELL.a1MeasSCellAddSsbRsrp.a1ThresholdSCellAddSsbRsrpTDD.
    ...
    ...    Note: gNB restart might be needed after the configuration is done if values of the following parameters
    ...        are changed.
    ...      - NRBTS/NRDU.actInterNumerologyCa
    ...      - NRBTS/actFdmScheduling
    ...      - NRBTS/NRCELL/actPrachMultiplexing
    ...
    ...    Note: See 3GPP 38.101 Table 6.2.1-1: UE Power Class for the possible UE capabilities according to the band.
    ...    Note 2: Power class 2 and 3 are just examples. Other power classes might be used on purpose of the test.
    ...            The only goal is to capture that power class for a single band and power class for the band
    ...            combination are different.
    ...    Note:  In this CB013392_A_B3, the following frequency band configuration is used:
    ...               - TDD PCell is n41
    ...               - FDD SCell is n25
    ...               - TDD SCell is n41
    ...   ##########################################################################################
    ...    • UE Capabilities: Same as in US CB013392-A#B1
    ...        • 5G-UE is capable of CA
    ...            - UE capabilities as received from UE in the message “RRC:UE Capability Information”
    ...              (IE “UE-NR-Capability->RF-Parameters) has following:
    ...            - supportedBandListNR contains two bands (n25 and n41) having power classes as follows:
    ...            - (band n25, power class 3)
    ...            - (band n41, power class 2)
    ...        - supportedBandCombinationList contains following:
    ...            - band combination {band n41, band n25, power class 3},
    ...            - band combination {band n41, band n41, power class 3}
    ...
    ...  TEST STEPS:
    ...    Step 1:
    ...       Description: Register UE to 5G cell (PCell).
    ...       Expected: UE is configured with TDD cell as PCell (n41).
    ...    Step 2:
    ...       Description: A1 measurement report is triggered from UE that has a threshold value higher than
    ...                   a1ThresholdSCellAddSsbRsrpTDD leading to TDD SCELL addition.
    ...       Expected: - TDD Scell (n41) gets added
    ...
    ...    Step 3:
    ...       Description: A1 measurement report is triggered from UE that has a threshold value higher than
    ...                    a1ThresholdSCellAddSsbRsrpFDD leading to FDD SCELL addition.
    ...       Expected: - UE is now served by FDD SCell (n25).  TDD SCell (n41) is removed.
    ...                 - Mapping MO "NRMEASPR_MA_SA-2" is selected and "NRBTS/NRMEASPR/NRMEASPR_IAF-2" is selected
    ...                   as the Intra-Freq measurement profile for the UE as the UE power class for the band
    ...                   combination of n41(PCell) + n25(SCell-2) is pc3
    ...                 - ReportconfigNr of Intra-Freq A3/A5 and A2 are present in the
    ...                   measConfig.reportConfigToAddModList with the same ReportConfigId as the one used in the
    ...                   UE for these reportConfigNrs
    ...                       - The IE "ReportConfigNr.EventTriggerConfig.eventA2" for the MeasObject corresponding to
    ...                         serving cell frequency is filled using "NRBTS/NRMEASPR/NRMEASPR_IAF-2.a2MeashoSsbRsrp".
    ...                         The IE "ReportConfigNr.EventTriggerConfig.eventA2' for the MeasObject corresponding to
    ...                         serving cell frequency is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2
    ...                         .a2MeasRedirectSsbRsrp"
    ...                       - "ReportConfigNr.EventTriggerConfig.eventA3" for the MeasObject corresponding to PCell
    ...                         is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a3MeasSsbRsrp"
    ...                       - "ReportConfigNr.EventTriggerConfig.eventA5" for the MeasObject corresponding to PCell
    ...                         is filled using "NRBTS/ NRMEASPR/NRMEASPR_IAF-2. a5MeasSsbRsrp"
    ...    Step 4:
    ...       Description: Start DL/UL user data traffic on UE#1
    ...       Expected: - DL and UL data transfer is realized for the UE via both cells
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
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_26744
    ...
    ...  REQUIRED LOGS:  EGATE Console logs, PM Counters
    ...
    ...  CONTACTS:       Lavanya Schmid
    ...  REFERENCES:     see "Documentation" part above
    ...  HISTORY:        Review Closed https://collab.ext.net.nokia.com/ui#review:id=917117
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    common_keywords.Run Test Scenario
    CB013392_scenario_verification.Verify CB013392_A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/DEVELOPMENT/robotws/CB013392_A_B3/SBTS00_ENB_9999_240505_000003/20240506_151505
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB013392_scenario_verification.Verify CB013392_A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class
