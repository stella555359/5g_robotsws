*** Settings ***
Documentation     Test-Specific Keywords for CB015769-A Test Cases
...
...               This library provides keywords for TTI trace analysis specific to
...               CB015769-A Cell CSI-RS Overhead Reduction testing.
...
...               Author: Automation Team
...               Creation Date: 2026-02-03

Resource          ../../../../../resources/SWENG/robot/TtiAnalysisInterface.robot
Resource          ./CB015769_common_keywords.robot

Library           Collections
Library           String
Library           OperatingSystem

*** Keywords ***
#=======================================================================================================================
# CSI-RS Scheduling Analysis Keywords
#=======================================================================================================================
Verify ZAB Privilege Status
    [Documentation]    Verify ZAB (Zero-overhead Adaptive Beamforming) privilege status
    ...
    ...                Checks dlAllocatedPooledResourcesData event for hasZAB field
    ...
    ...                Arguments:
    ...                - cell_name: Name of the cell
    ...                - tti_file: Path to TTI trace file
    [Arguments]    ${tti_csv_file}    ${physCellId}

    Log    === Verifying ZAB Privilege for ${physCellId} ===    INFO

    # Get ZAB privilege status from TTI trace
    ${has_zab}=    csi_rs_analyzer.Get ZAB Privilege Status    ${tti_csv_file}    ${physCellId}

    Log    ${physCellId} ZAB privilege (hasZAB): ${has_zab}    INFO

    # Log explanation of ZAB privilege impact
    Run Keyword If    '${has_zab}' == 'True'
    ...    Log    ZAB privilege granted: PDSCH can use last symbol on CSI-RS slots    INFO
    ...    ELSE
    ...    Log    ZAB privilege not granted: Last symbol blocked on CSI-RS slots    INFO

    Log    === ZAB Privilege Verification Completed ===    INFO

#=======================================================================================================================
# Optional: PDCCH Sharing After Muting Verification
#=======================================================================================================================
STEP01_Verify_Cell_CSI_RS_Overhead_Reduction_RS4_Muted_Only
    [Documentation]    Step 1: Verify CSI-RS overhead reduction with RS4 muted only
    ...
    ...                Preconditions:
    ...                - Frame Structure 1208 applied (Semi-Static 1/4)
    ...                - CB012269 enabled (actTddCsiRsOpt = true)
    ...                - CB015769 enabled on Cell-1 (actCellCsirsTddOnSsbBf = false)
    ...                - NRCELL-1.cellSpecCsiRsMuteList = 001 (RS4 muted)
    ...                - CB015769 disabled on Cell-2 and Cell-3
    ...
    ...                Test Steps:
    ...                1. Activate TTI traces for 3 cells
    ...                2. Attach UE on Cell-1
    ...                3. Run full buffer DL traffic
    ...                4. Collect and analyze TTI traces
    ...
    ...                Expected Results:
    ...                - Cell-1: PDSCH allowed on RS1/RS2 slots, blocked on RS4 slots
    ...                - Cell-2/3: PDSCH blocked on all CSI-RS slots (RS1, RS2, RS4)
    [Tags]    Step1    RS4_Muted    TTI_Analysis

    # Step 1: Configure CSI-RS muting for Cell-1 (RS4 only)
    Log    === Step 1: RS4 Muted Only (cellSpecCsiRsMuteList = ${MUTE_LIST_STEP1}) ===    WARN
    # Start traces capture during
    ${log_dir}=    Set Variable    ${LOG_PATH}/STEP01
    ${syslog_file_name}=    Set Variable    STEP01_Cell_CSI_RS_Overhead_Reduction_RS4_Muted_Only
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}

    FOR   ${cell_name}    IN    @{CELLS_NAMES}
        Set Cell Specific CSI RS Mute List    ${cell_name}    ${MUTE_LIST_STEP1}
    END
    Sleep    5s    Wait for configuration to apply
    ${SYSLOG_RS4}=                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path:  ${SYSLOG_RS4}
    ${bip_rs4_csv_report_file}=    Run Traffic Scenario And Traces Collection    STEP01_RS4_Muted_Only    ${SA_UE_ID_List}

    # Verify ZAB (Zero-overhead Adaptive Beamforming) privilege status
    FOR    ${PCI}   IN    @{PCIs}
        Verify ZAB Privilege Status   ${TTIcsv}    ${PCI}
    END
    # Analyze syslog and BIP traces for RS4 muting verification
    ${csi_rs4_slots}=    csi_rs_analyzer.get_RS_muted_symbole_setup_info    ${SYSLOG_RS4}
    Log    RS4 muted symbols info extracted from syslog: ${csi_rs4_slots}    INFO
    IF     ${csi_rs4_slots} == []
        Fail    RS4 muted symbols info is empty. Exception raised.
    END

    csi_rs_analyzer.verify_slots_in_range
    ...    ${csi_rs4_slots}
    ...    psc_csi_gp=${PCI_PER_CSI_GROUP}
    ...    muting_symbol=${RS4_MUTED_SLOTS}

    Log   RS4 muted symbols are within expected periodicity and aligned with PCI per CSI group.    INFO

    ${symbol4_slots_checked}     ${symbol2_slots_checked}    csi_rs_analyzer.analyze_csi_rs_periodicity
    ...    ${bip_rs4_csv_report_file}
    ...    csiReportPeriodicity=${320}
    ...    nbSlotsPerSFN=${20}
    ...    psc_csi_gp=${PCI_PER_CSI_GROUP}
    ...    muting_symbol=${RS4_MUTED_SLOTS}

    Log  CSI-RS muting periodicity and alignment with PCI per CSI group verified successfully.    INFO
    Log  CSI-RS muting Symbol4 Checked: ${symbol4_slots_checked}    INFO
    Log  CSI-RS muting Symbol2 Checked: ${symbol2_slots_checked}    INFO

STEP02_Verify_Cell_CSI_RS_Overhead_Reduction_RS2_RS4_Muted
    [Documentation]    Step 2: Verify CSI-RS overhead reduction with RS2 and RS4 muted
    ...
    ...                Preconditions:
    ...                - Continuation from Step 1
    ...                - Online parameter change: NRCELL-1.cellSpecCsiRsMuteList = 011
    ...
    ...                Test Steps:
    ...                1. Change cellSpecCsiRsMuteList online to 011 (RS2+RS4 muted)
    ...                2. Continue TTI trace collection
    ...                3. Continue DL traffic on Cell-1
    ...                4. Collect and analyze TTI traces
    ...
    ...                Expected Results:
    ...                - Cell-1: PDSCH allowed on RS1 slots only, blocked on RS2 and RS4 slots
    ...                - Cell-2/3: PDSCH blocked on all CSI-RS slots (RS1, RS2, RS4)
    [Tags]    Step2    RS2_RS4_Muted    TTI_Analysis
     # Step 2: Configure CSI-RS muting for Cell-1 (RS2 and RS4)
    Log    === Step 2: RS2 and RS4 Muted (cellSpecCsiRsMuteList = ${MUTE_LIST_STEP2}) ===    WARN
    # Start traces capture during
    ${log_dir}=    Set Variable    ${LOG_PATH}/STEP02
    ${syslog_file_name}=    Set Variable    STEP02_Cell_CSI_RS_Overhead_Reduction_RS2_RS4_Muted
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}

    FOR   ${cell_name}    IN    @{CELLS_NAMES}
        Set Cell Specific CSI RS Mute List    ${cell_name}    ${MUTE_LIST_STEP2}
    END
    Sleep    5s    Wait for configuration to apply
    ${SYSLOG_RS2_RS4}                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path:  ${SYSLOG_RS2_RS4}
    ${bip_rs2_rs4_csv_report_file}=    Run Traffic Scenario And Traces Collection    STEP02_RS2_RS4_Muted    ${SA_UE_ID_List}

    # Analyze syslog and BIP traces for RS2-RS4 muting verification
    ${csi_rs2_rs4_slots}=    csi_rs_analyzer.get_RS_muted_symbole_setup_info    ${SYSLOG_RS2_RS4}
    Log    RS2-RS4 muted symbols info extracted from syslog: ${csi_rs2_rs4_slots}    INFO
    IF     ${csi_rs2_rs4_slots} == []
        Fail    RS2-RS4 muted symbols info is empty. Exception raised.
    END

    csi_rs_analyzer.verify_slots_in_range
    ...    ${csi_rs2_rs4_slots}
    ...    psc_csi_gp=${PCI_PER_CSI_GROUP}
    ...    muting_symbol=${RS2_RS4_MUTED_SLOTS}

    Log   RS2-RS4 muted symbols are within expected periodicity and aligned with PCI per CSI group.    INFO

    ${symbol4_slots_checked}     ${symbol2_slots_checked}    csi_rs_analyzer.analyze_csi_rs_periodicity
    ...    ${bip_rs2_rs4_csv_report_file}
    ...    csiReportPeriodicity=${320}
    ...    nbSlotsPerSFN=${20}
    ...    psc_csi_gp=${PCI_PER_CSI_GROUP}
    ...    muting_symbol=${RS2_RS4_MUTED_SLOTS}

    Log  CSI-RS muting periodicity and alignment with PCI per CSI group verified successfully.    INFO
    Log  CSI-RS muting Symbol4 Checked: ${symbol4_slots_checked}    INFO
    Log  CSI-RS muting Symbol2 Checked: ${symbol2_slots_checked}    INFO

STEP03_Verify_Cell_CSI_RS_Overhead_Reduction_All_Muted
    [Documentation]    Step 3: Verify CSI-RS overhead reduction with RS1, RS2, and RS4 muted
    ...
    ...                Preconditions:
    ...                - Continuation from Step 2
    ...                - Online parameter change: NRCELL-1.cellSpecCsiRsMuteList = 111
    ...
    ...                Test Steps:
    ...                1. Change cellSpecCsiRsMuteList online to 111 (All muted)
    ...                2. Continue TTI trace collection
    ...                3. Continue DL traffic on Cell-1
    ...                4. Collect and analyze TTI traces
    ...
    ...                Expected Results:
    ...                - Cell-1: PDSCH allowed on all slots (all CSI-RS muted)
    ...                - Cell-2/3: PDSCH blocked on all CSI-RS slots (RS1, RS2, RS4)
    ...                - CSI-RS muting applied identically on all cells according to CB012269
    [Tags]    ${FEATURE_ID}    Step3    All_Muted    TTI_Analysis
    # Step 3: Configure CSI-RS muting for Cell-1 (All muted)
    Log    === Step 3: All Muted (cellSpecCsiRsMuteList = ${MUTE_LIST_STEP3}) ===    WARN
    # Start traces capture during
    ${log_dir}=    Set Variable    ${LOG_PATH}/STEP03
    ${syslog_file_name}=    Set Variable    STEP03_Cell_CSI_RS_Overhead_Reduction_All_Muted
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}

    FOR   ${cell_name}    IN    @{CELLS_NAMES}
        Set Cell Specific CSI RS Mute List    ${cell_name}    ${MUTE_LIST_STEP3}
    END
    Sleep    5s    Wait for configuration to apply
    ${SYSLOG_MUTE_ALL}=                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path:  ${SYSLOG_MUTE_ALL}
    ${bip_mute_all_csv_report_file}=    Run Traffic Scenario And Traces Collection    STEP03_All_Muted    ${SA_UE_ID_List}

    # Analyze syslog and BIP traces for RS2-RS4 muting verification
    ${csi_muted_all_slots}=    csi_rs_analyzer.get_RS_muted_symbole_setup_info    ${SYSLOG_MUTE_ALL}
    Log    RS2-RS4 muted symbols info extracted from syslog: ${csi_muted_all_slots}    INFO
    IF     ${csi_muted_all_slots} == []
        Fail    RS2-RS4 muted symbols info is empty. Exception raised.
    END

    csi_rs_analyzer.verify_slots_in_range
    ...    ${csi_muted_all_slots}
    ...    psc_csi_gp=${PCI_PER_CSI_GROUP}
    ...    muting_symbol=${RS1_RS2_RS4_MUTED_SLOTS}

    Log   RS2-RS4 muted symbols are within expected periodicity and aligned with PCI per CSI group.    INFO

    ${symbol4_slots_checked}     ${symbol2_slots_checked}    csi_rs_analyzer.analyze_csi_rs_periodicity
    ...    ${bip_mute_all_csv_report_file}
    ...    csiReportPeriodicity=${320}
    ...    nbSlotsPerSFN=${20}
    ...    psc_csi_gp=${PCI_PER_CSI_GROUP}
    ...    muting_symbol=${RS1_RS2_RS4_MUTED_SLOTS}

    Log  CSI-RS muting periodicity and alignment with PCI per CSI group verified successfully.    INFO
    Log  CSI-RS muting Symbol4 Checked: ${symbol4_slots_checked}    INFO
    Log  CSI-RS muting Symbol2 Checked: ${symbol2_slots_checked}    INFO
