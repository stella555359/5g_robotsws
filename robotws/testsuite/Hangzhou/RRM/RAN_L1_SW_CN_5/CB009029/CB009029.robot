*** Settings ***
Documentation
...    Author:  Qian, Zhang
...    Contact: qian.3.zhang@nokia-sbell.com
...    Feature: CB005914
...    Release: 23R4

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
Library    OperatingSystem

*** Variables ***
@{ALLOWED_FAULT}    2922    Antenna calibration error caused by transmission path (Tx) failure
...    2923    Antenna calibration error caused by reception path (Rx) failure
...    8101    L1 IQ Data Suspicious Event
...    49      Cell blocked
${scfc_file}         CB009029_ABIP_AKQJ_NRTDD_1xNRCELL.xml
${DL_TP}    250M
${UL_TP}    60M   #CPE621-b,UL 1 layer
${EVENT_TARGET_FILE_NAME}    *124D_l1a_iqSnapshotBuffer.bin
${TARGET_ZIP_FILE_NAME}    124D_l1a_iqSnapshotBuffer.bin.xz
${MIN_SIZE}     ${1024}
*** Test Cases ***
CB009029_TC05_NR_FR1_TDD_eCPRI_ABIP_file_upload_to_system_modules_IQ_capture_cell_deletion
    [Tags]    CRT    Trunk    CB009029    CB009029_TC05
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009029${/}CB009029_US05_ASIM_ABIP_AKQJ_AHFII_AHEH_Full_Commission.xml

    Online change SCFC parameter    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-11    parameter=pMax    value=350
    Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir

    Append To List    ${L1_WRN_whitelist}    EnableFileWriting failed

    SMAwave UE attach    rat=5G    cell_id=191545355    band=78    specific_UE_index=UE_3
    SMAwave Start Data Traffic    ${DL_TP}    ${UL_TP}
    IQ Event capture configuration with RRU
    SMAwave Verify throughput for DL and UL    ${DL_TP}    ${UL_TP}    15%    5G
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    SMAwave Stop Data And Detach
    Sleep    60s
    Perform NR Cell block 11 via AdminCLI
    Wait Until Keyword Succeeds    300s    60s    Check If Alarm Disappeared    8101
    Perform NR Cell unblock 11 via AdminCLI
    Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
    SMAwave UE attach    rat=5G    cell_id=191545355    band=78    specific_UE_index=UE_3
    SMAwave Start Data Traffic    ${DL_TP}    ${UL_TP}
    IQ Event capture configuration with RRU
    SMAwave Verify throughput for DL and UL    ${DL_TP}    ${UL_TP}    15%    5G
    ${snapshot}    Save Snapshot Via WebUI
    Check NrFine slot    ${snapshot}
    Extract trbl log and check iq log    ${snapshot}    ${TARGET_ZIP_FILE_NAME}    ${EVENT_TARGET_FILE_NAME}
    Check ru iq    ${snapshot}
    Disable IQ capture via webUI
    SMAwave Stop Data And Detach


*** Keywords ***
IQ Event capture configuration with RRU
    [Arguments]    ${capture_frame_offset}=8    ${buffer_cycle}=16_FRAMES

    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 11][7-2a]NRCELL-11: Subcell 1

    ${polar_list_minus}    Create List    ANT1
    ${polar_list_plus}     Create List    ANT5
    ${antenna_list_group}=    Create Dictionary    Antenna list    Set1(-45 polarization, +45 polarization)    -45 Polarization    ${polar_list_minus}
    ...    +45 Polarization    ${polar_list_plus}

    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU and RU    profile_prefix=ul_profile_3
    ...    buffer_cycle=${buffer_cycle}    capture_frame_offset=${capture_frame_offset}    antenna_list_group=${antenna_list_group}
    ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    2147483648

Extract trbl log and check ru iq log
    [Arguments]    ${snapshot}    ${zip_file_name}    ${TARGET_FILE_NAMES}
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${zip_file_name}
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}[0]
    ${find_target_file_in_first_zip}    run keyword and return status    Should Contain    ${second_zip}    ${zip_file_name}
    ${third_zip}    Set Variable    ${None}
    ${path2}    Set Variable    ${None}
    ${third_zip}     ${path2}    Run Keyword If    not ${find_target_file_in_first_zip}
    ...    Extract Target file From Compressed File     ${path1}/${second_zip}    ${zip_file_name}
    ${TGZ_PATH}    Set Variable If    ${find_target_file_in_first_zip}    ${path1}/${second_zip}    ${path2}/${third_zip}
    Log To Console    \n[INFO]captured file path is ${TGZ_PATH}
    ${compress_format}    Set Variable    ${TGZ_PATH.rsplit('.',1)[-1]}
    ${list_cmd}    Run Keyword If    '${compress_format}'=='.gz'    Set Variable    cd ${path}; gizp -d ${TGZ_PATH}
    ${uncompress}    Run    ${list_cmd}
    FOR    ${TARGET_FILE_NAME}    IN    @{TARGET_FILE_NAMES}
        ${TARGET_FILE}    Set Variable    ${path}/${TARGET_FILE_NAME}
        ${output}    Run    ls -l ${TARGET_FILE}
        Log To Console   \n${output}
        ${file_size}=    Get File Size From String    ${output}
        Log    [INFO]File size is: ${file_size}
        Run    rm -rf ${TARGET_FILE}
        Should Be True    ${file_size} > ${MIN_SIZE}    The file ${TARGET_FILE} size ${file_size} should be greater than 1 MB
    END

Get File Size From String
    [Arguments]    ${string}
    @{str_list}=    Split String    ${string}    ${SPACE}
    ${size}    Set Variable    ${str_list}[4]
    [Return]    ${size}

Check NrFine slot
    [Arguments]     ${snapshot}
    ${node_id}    Get Node Id    ABIP    thor_1
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${second_zip}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${forth_zip}     ${path3}    Extract Target file From Compressed File     ${path2}/${third_zip}    NrFine_slot
    File Should Exist    ${path3}/${forth_zip}    [ ERROR ] filename NOT EXIST
    Remove files    ${path2}/${third_zip}    ${path3}/${forth_zip}

Check ru iq
    [Arguments]     ${snapshot}
    ${first_zip_list}     ${path}     Get Target Logs From Snapshot    ${snapshot}    fcpTriggeredCapture
    FOR    ${first_zip}    IN    @{first_zip_list}
        ${second_zip}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}
        ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    fcpTriggeredCapture_.*_rxArray
        ${fcp_size}=    Get File Size    ${path2}/${third_zip}
        Log    ${fcp_size} :: ${third_zip}
        Run Keyword And Continue On Failure    Should Be True    ${fcp_size} > 1024
        ...    [ ERROR ] ${fcp_size} size should be greater than 0\n${fcp_size} :: ${third_zip}

        Run Keyword And Continue On Failure    Remove files    ${path1}/${second_zip}    ${path2}/${third_zip}
    END

Extract trbl log and check iq log
    [Arguments]    ${snapshot}    ${zip_file_name}    ${TARGET_FILE_NAMES}
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${zip_file_name}
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${zip_file_name}
    Log To Console    \ncaptured file path is ${path2}/${third_zip}
    ${TGZ_PATH}    Set Variable    ${path2}/${third_zip}
    ${compress_format}    Set Variable    ${TGZ_PATH.rsplit('.',1)[-1]}
    ${list_cmd}    Run Keyword If    '${compress_format}'=='xz'    Set Variable    xz -d ${TGZ_PATH}
    ${uncompress}    Run    ${list_cmd}
    ${TARGET_FILE}    Set Variable    ${path2}/${TARGET_FILE_NAMES}
    ${output}    Run    ls -l ${TARGET_FILE}
    Log To Console   \n${output}
    ${file_size}=    Get File Size From String    ${output}
    Log    File size is: ${file_size}
    Should Be True    ${file_size} > ${MIN_SIZE}    [ ERROR ] ${TARGET_FILE_NAMES} size should be greater than 1 MB :: ${file_size}
    Run    rm -rf ${TARGET_FILE}

Collect IQ Snapshot
    Save Snapshot Via WebUI
    Disable IQ capture via webUI
