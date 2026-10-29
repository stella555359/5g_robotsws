*** Settings ***
Documentation     Common Keywords for CB015769 Test Suite
...
...               This library provides common keywords for CB015769 feature testing,
...               including configuration management, TTI trace handling, and utility functions.
...
...               Author: Automation Team
...               Creation Date: 2026-02-03

Library           OperatingSystem
Library           String
Library           BuiltIn
Library           Collections
Library           DateTime
Library           ute_wtssim                    WITH NAME    wts
Library           taf.config.wts                WITH NAME    wts_cfg
Library           taf.sbts.oam.coam.admin       WITH NAME    coam
Library           taf.sbts.oam.coam.admin       WITH NAME   sbts_coam


Resource          taf/rfrl/common_resources/robot/preconditions.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Hardening.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot

Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../resources/vrf_nps2/robot/common_utilities_resources.robot
Resource          ../../../resources/vrf_nps2/robot/common_managements_resources.robot



*** Keywords ***
#=======================================================================================================================
# Suite Setup and Teardown Keywords
#=======================================================================================================================

CB015769 Suite Setup
    [Documentation]    Suite-level setup for CB015769 tests
    ...                - Performs backup of configuration files
    ...                - Applies initial SCF delta configuration
    ...                - Verifies preconditions
    ...                - Sets up test environment

    Log    === CB015769 Suite Setup Started ===    WARN

    # Standard suite setup with backup
    Setup.Suite Setup from scratch        automaticTeardown=${True}    keepAllUeDataInCfgFile=${True}

    Set suite variable    ${tl.core.dir_path}    /opt/iphy/latest
    Suite Dir Preparation


CB015769 Suite Teardown
    [Documentation]    Suite-level teardown for CB015769 tests
    ...                - Collects final logs and snapshots
    ...                - Restores original configuration
    ...                - Performs cleanup

    Log    === CB015769 Suite Teardown Started ===    WARN
    # Standard suite teardown
    Suite Teardown

    Log    === CB015769 Suite Teardown Completed ===    WARN


CB015769 Test Setup
    [Documentation]    Test-level setup for CB015769 tests
    ...                - Prepares test environment
    ...                - Initializes test variables

    Log    === Test Setup: ${TEST_NAME} ===    INFO
    Test Setup
    # Setup Config Initializations
    Init Sequence   "Setup Config Initializations"
    Dated Log New Line                                  ---> Configuring gNB

    # Initialize log collection paths
    Test Case Dir Preparation

    ## To do
    Critical Step    Download BSR File Using Git and Update BTS SW
    ...    ${bsr_file}    /home/ute/BSR

    Dated Log New Line                                  ---> WTS setup SA
    Critical Step    WTS Setup                           shouldUseLua=${False}

    # Apply initial SCF delta configuration
    # Start traces capture during
    ${syslog_file_name}=    Set Variable    Setup_Cell_1208_SF
    ${syslog}=              SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}
    ${scf_delta_file}=    Catenate    SEPARATOR=
    ...    ${CURDIR}/../config/${ENB_BRANCH}/
    ...    delta_scf_CB15769_activation.json
    Log    Applying SCF delta configuration: ${scf_delta_file}    INFO
    Critical Step    Apply SCF Delta Configuration    ${scf_delta_file}
    ${syslog_path}          SYSLOG Stop    syslog=${syslog}


    Critical Step    Verify Frame Structure Configuration and CB015769 Feature Flags

    ${cells_info}=    csi_rs_analyzer.csi_report_info    ${syslog_path}
    Log    Cells info extracted from syslog: ${cells_info}    INFO


    ${pcis}=    csi_rs_analyzer.get_all_pci_4_csi_group    ${cells_info}
    Log    PCI per CSI group: ${pcis}    INFO
    Set Suite Variable    ${PCIs}    ${pcis}

    ${pci_per_csi_group}=    csi_rs_analyzer.get_pci_per_group    ${cells_info}
    Log    PCI per CSI group: ${pci_per_csi_group}    INFO
    Set Suite Variable    ${PCI_PER_CSI_GROUP}    ${pci_per_csi_group}

    csi_rs_analyzer.check_csi_group_info    ${cells_info}

    Log     Both CSI groups 0 and 1 are present in the syslog.    INFO
    Dated Log New Line                                  ---> Test setup completed successfully
    Log    === CB015769 Suite Setup Completed ===    WARN

CB015769 Test Teardown
    [Documentation]                 Generic Test teardown:
    ...                             - Call the SCOUT services to produce data for the Reporting Portal.
    ...                             - Save the current egate_console.log file in LOG_PATH and then delete it.
    ...                             - Get SOS report and snapshot only if test is fail.
    Dated Log                       Start Test Teardown
    Produce Scout Data
    Save and Clear Egate Console Log          pattern=TestTeardown
    Run keyword if                  '${TEST_STATUS}'=='FAIL'
    ...                             Test Teardown if Fail
#=======================================================================================================================
# Configuration Management Keywords
#=======================================================================================================================

Verify Frame Structure Configuration and CB015769 Feature Flags
    [Documentation]     Verify that all required feature flags are correctly configured
    ...                for CB015769 testing and frame structure 1208 (Semi-Static 1/4) is correctly configured
    [Teardown]         Run Keyword And Ignore Error     sbts_coam.teardown            connection=coamCnx

    sbts_coam.connect_to          name=coamCnx
    @{obj_list}=    Create List    NRCELL-1    NRCELL-2    NRCELL-3
    ...                            NRCELL-4    NRCELL-5    NRCELL-6
    #  Verify CB015769 Feature Flags
    Log    Verifying CB015769 Feature Flags configuration    INFO
    Run Keyword And Ignore Error   Validate Parameters Configuration    NRBTS    ${NRBTS_FEATURE_FALGS}
    ...    obj_list=${None}    sub_param_name=${None}
    ...    connection=coamCnx

    # NRCELL Feature Flags
    Run Keyword And Ignore Error   Validate Parameters Configuration    NRCELL    ${NRCELL_FEATURE_FALGS}
    ...    obj_list=${obj_list}    sub_param_name=${None}
    ...    connection=coamCnx
    Log    CB015769 Feature Flags configuration verified successfully    INFO

    # Verify Frame 1208 Structure Configuration
    Log    Verifying Frame Structure 1208 configuration    INFO
    Run Keyword And Ignore Error   Validate Parameters Configuration    NRCELL    ${FRAME_STRUCTURE}
    ...    obj_list=${obj_list}    sub_param_name=tddFrameStructure
    ...    connection=coamCnx
    Log    Frame Structure 1208 verified successfully    INFO


Set Cell Specific CSI RS Mute List
    [Documentation]    Set the cellSpecCsiRsMuteList parameter for a specific cell
    ...
    ...                Arguments:
    ...                - cell_name: Name of the cell (e.g., NRCELL-1)
    ...                - mute_list: Muting bitmap (e.g., 001, 011, 111)
    ...
    ...                Example:
    ...                Set Cell Specific CSI RS Mute List    NRCELL-1    011
    [Teardown]         Run Keyword And Ignore Error     sbts_coam.teardown            connection=${connection}
    [Arguments]    ${CELL_NAME}    ${mute_list}   ${connection}=${GNB_ALIAS}

    sbts_coam.connect_to          name=${connection}

    Log    Setting ${CELL_NAME}.cellSpecCsiRsMuteList to ${mute_list}    INFO

    ${dist_name}=    Catenate   SEPARATOR=   MRBTS-1/NRBTS-1/    ${CELL_NAME}

    # Set parameter online (no restart required)
    sbts_coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...                                            parameter=cellSpecCsiRsMuteList
    ...                                            operation=update
    ...                                            value=${mute_list}
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

    # Verify parameter was set
    Sleep    2s    Wait for parameter update
    ${parameter_list}=    Create List    cellSpecCsiRsMuteList
    ${dst_name_values}=     sbts_coam.get_parameter_by_distname
    ...                                           ${dist_name}
    ...                                           parameter_list=${parameter_list}
    ...                                           include_children=${None}
    ...                                           timeout=60
    ...                                           detailed_output=${False}
    ...                                           connection=${connection}
    FOR  ${dst_name_value}  IN  @{dst_name_values}
        ${param_value}=    Get From Dictionary    ${dst_name_value}    parameters
        ${value}=    Get From Dictionary    ${param_value}    cellSpecCsiRsMuteList
        Should Be Equal As Strings    ${value}    ${mute_list}
        ...    msg=${CELL_NAME}.cellSpecCsiRsMuteList should be ${mute_list}
    END


    Log    ${CELL_NAME}.cellSpecCsiRsMuteList set to ${mute_list} successfully    INFO





#=======================================================================================================================
# Traffic and UE Management Keywords
#=======================================================================================================================

CB015769_Register_and_Attach_All_UEs
    [Arguments]            ${SA_UE_List}    ${SA_UeId_List}
    # Dated Log New Line       ---> Attaching all needed UEs
    FOR        ${ue_id}      IN        @{SA_UeId_List}
        &{current_UE}=                  Copy dictionary     ${BASIC_UE_SA}
        Set To Dictionary               ${current_UE}       ue          ${ue_id}
        Set To Dictionary               ${current_UE}       pdu         1
        Append To List                  ${SA_UE_List}       ${current_UE}
        CallSetup.UE Register                     ue=${current_UE.ue}
        Launch PDU Session              ue=${current_UE.ue}    pdu=${current_UE.pdu}    gw=${current_UE.ue}
    END
    Dated Log                ---> All needed UEs are now attached

CB015769 Start Traffic Scenario
    [Arguments]    ${SA_UE_List}   ${id_cell_gp0}=${0}    ${id_cell_gp1}=${3}
    [Documentation]    Start the downlink traffic for the given list of UEs
    ...                Arguments:
    ...                - SA_UE_List: List of UEs to start traffic for

    ${Sub_UE_List}=    Create List    ${SA_UE_List[${id_cell_gp0}]}    ${SA_UE_List[${id_cell_gp1}]}

    Traffic.Traffic UEs DL                   ueSettingList=${SA_UE_List}
    ...                                 duration=10s        shouldBeStop=False      shouldBeCheck=False    protocol=udp
    ...                                 throughput=175
    ${Sub_UE_List}=    Update Trf ID In UE List          ${Sub_UE_List}    2
    Traffic.Traffic UEs DL                   ueSettingList=${Sub_UE_List}
    ...                                 duration=10s        shouldBeStop=False      shouldBeCheck=False    protocol=udp
    ...                                 throughput=175
    ${Sub_UE_List}=    Update Trf ID In UE List          ${Sub_UE_List}    3
    Traffic.Traffic UEs DL                   ueSettingList=${Sub_UE_List}
    ...                                 duration=10s        shouldBeStop=False      shouldBeCheck=False    protocol=udp
    ...                                 throughput=175

CB015769 Stop Traffic
    [Arguments]    ${SA_UE_List}   ${id_cell_gp0}=${0}    ${id_cell_gp1}=${3}
    [Documentation]    Stop the downlink traffic for the given list of UEs
    ...                Arguments:
    ...                - SA_UE_List: List of UEs to stop traffic for

    ${Sub_UE_List}=    Create List    ${SA_UE_List[${id_cell_gp0}]}    ${SA_UE_List[${id_cell_gp1}]}
    Traffic.Traffic Stop UEs                    ueSettingList=${SA_UE_List}      dir=dl
    ${Sub_UE_List}=    Update Trf ID In UE List          ${Sub_UE_List}    2
    Traffic.Traffic Stop UEs                   ueSettingList=${Sub_UE_List}      dir=dl
    ${Sub_UE_List}=    Update Trf ID In UE List          ${Sub_UE_List}    3
    Traffic.Traffic Stop UEs                   ueSettingList=${Sub_UE_List}      dir=dl

CB015769_Detach_all_UEs
    [Arguments]            ${SA_UE_List}
    FOR        ${current_ue}            IN         @{SA_UE_List}
        UE Deregister                   id=${current_ue.ue}
    END

Run Traffic Scenario And Traces Collection
    [Arguments]     ${step}    ${SA_UE_ID_List}
    [Documentation]  Increase the traffic load UL/DL, an collect the syslog and check the k2 mode status
    ...              Arguments:
    ...              -  SA_UE_List: the list of the mobile
    ...              -  syslog_file_name: Syslog file name


    ${SA_UE_List}=        Create List
    CB015769_Register_and_Attach_All_UEs    ${SA_UE_List}    ${SA_UE_ID_List}
    # Start traces capture during
    ${syslog_file_name}=    Set Variable    ${step}_Traffic_Scenario
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}

    CB015769 Start Traffic Scenario     ${SA_UE_List}
    Start L1L2 Logs    ${step}
    ${TTIcsv}=        TTI Trace Collection                dir_suffix=tti_traces
    ...                                 tti_trace_filename=${step}_tti_traces
    ...                                 tti_capture_duration=10s
    BuiltIn.Sleep   5s
    Stop L1L2 Logs
    ${syslog}=                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path:  ${syslog}
    CB015769 Stop Traffic      ${SA_UE_List}
    CB015769_Detach_all_UEs    ${SA_UE_List}
    Dated Log                ---> Traffic scenario ${step} executed and logs collected successfully
    ${report_file}=    Generate L1L2 Traces Report for CB015769    ${CaptureBIP.path}
    Set Suite Variable     ${TTIcsv}
    Log    L1L2 trace report generated at: ${report_file}    INFO
    [Return]    ${report_file}
#=======================================================================================================================
# Utility Keywords
#=======================================================================================================================

Get Log Directory
    [Documentation]    Get the log directory path for current test suite
    ...
    ...                Returns:
    ...                - Log directory path

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${log_dir}=    Set Variable    ${OUTPUT_DIR}/logs_${timestamp}
    Create Directory    ${log_dir}

    [Return]    ${log_dir}



Generate L1L2 Traces Report for CB015769
    [Arguments]    ${l1l2_trace_file}
    [Documentation]    Analyze the collected L1L2 trace files for CB015769 tests and generate analysis reports
    ...                Arguments:
    ...                - l1l2_trace_file: Path to the L1L2 trace file to be analyzed
    Log    Analyzing L1L2 trace file: ${l1l2_trace_file}    INFO

    # get file name without extension to create report file

    ${path}           ${file_name}=      Split Path        ${l1l2_trace_file}
    ${name_no_ext}    ${ext}=            Split Extension    ${file_name}
    ${report_file}=        Catenate    SEPARATOR=/    ${path}    ${name_no_ext}_report.csv

    ${cmd}    catenate     tshark
    ...            -r ${l1l2_trace_file}
    # ...            -c 50000
    ...            -E header=y
    ...            -E separator="/t"
    ...            -T fields
    ...            -Y dldata_pdschsendreql1sw
    ...            -e _ws.col.Time
    ...            -e frame.number
    ...            -e 3gpp.sfn
    ...            -e 3gpp.slot
    ...            -e 3gpp.rnti
    ...            -e 3gpp.subcellid
    ...            -e DlData_PdschGrantL1sw.pdschScramblingSeqInit
    ...            -e DlData_PdschGrantL1sw.rateMatchingOption
    ...            -e DlData_PdschGrantL1sw.startSymbol
    ...            -e DlData_PdschGrantL1sw.numOfPdschSymbols
    ...            -e _ws.col.Info  > ${report_file}

    Run    ${cmd}
    Log    L1L2 trace analysis completed. Report generated at: ${report_file}    INFO
    Return From Keyword    ${report_file}
