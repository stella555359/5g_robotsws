*** Settings ***
Documentation
...    Author:  gang.1.xue
...    Contact: gang.1.xue@nokia-sbell.com
...    Feature: testability_eCPRI_72a
...    Release: 25R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown

Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    8101
${scfc_file}    Testability_ABIO_1xAZQP_NRTDD_1xNRCEL_72a_${btsid}.xml
${SSB_Event}    event detected:40
${CSI_Event}    event detected:45

*** Test Cases ***
Testability_TC14_CNI96135_NR_FR1_TDD_eCPRI_ABIO_72a_SSB_CSI-RS_event_IQ_trigger_IQ_capture
    [Tags]    ABIO    SMAwave    Trunk    Testability    iq    CNI_96135    QL3
    Swconfig File Flag Added
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scfc_file}

    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 100]${72a_flag}NRCELL-1: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}

    ADMIN Set RAD debug parameters    CommonPhy    nbOfEventsToTrigAutoBTSSnapshot    100
    ${NrDlPhy_list}    Set Variable    [{'name':'dlPhyCaptureTriggerSpecificBuffer', 'value':'true'}, {'name':'dlPhyEventEnableExt', 'value':'8448'}]
    ADMIN Set Multiple RAD debug parameters    NrDlPhy    ${NrDlPhy_list}
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    Syslog Check Event Trigger And Snapshot IQ Capture
    [Teardown]    Check IqSnapshotBuffer And Test Teardown

*** Keywords ***
Syslog Check Event Trigger And Snapshot IQ Capture
    TRY
        ${file_content}=    ute_syslog.Message Should Exist In Syslog File    regexp=event detected:4*    alias=enb_testSetup
        ${ssb_event_count}=    Get Count    ${file_content}    ${SSB_Event}
        ${csi_event_count}=    Get Count    ${file_content}    ${CSI_Event}
        Should Be True    ${ssb_event_count} > 0 and ${csi_event_count} > 0
        ...    [ ERROR ] Event 40 :: ${ssb_event_count} and Event 45 :: ${csi_event_count} are not found
    EXCEPT
        Log    Error Read 'event detected:4*' in ute syslog with alias=enb_testSetup
    END


Check IqSnapshotBuffer And Test Teardown
    ${L1_ERR_rt_message_num}=     Count Syslog messages    regexp=ERR/l1_application_rt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application_nrt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application    alias=enb_testSetup
    ${L1_WRN_rt_message_num}=     Count Syslog messages    regexp=WRN/l1_application_rt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application_nrt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application    alias=enb_testSetup
    Check L1 ERR and WRN in syslog
    Run Keyword And Ignore Error    Stop Collect GNB Syslog    ${TEST_LOG_DIR}
    Run Keyword And Ignore Error    ute_syslog.Teardown All Aliases For Syslog
    Get Alarms State    alarm_management=Active
    Get Alarms State    alarm_management=Historic
    Run Keyword And Ignore Error    sbts_admin.teardown    connection=${connection}
    Run Keyword And Ignore Error    WebUI disconnection    suite
    Run Keyword And Ignore Error    WebUI connection    iq_disable
    Run Keyword And Ignore Error    Disable IQ capture via webUI    sbts=iq_disable
    Run Keyword And Ignore Error    WebUI disconnection    iq_disable

    ${snapshot}    Save Snapshot Via WebUI
    ${node_id}    Get Node Id    ABIO    loki_1
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${node_id.strip('0x')}D_l1a_iqSnapshotBuffer.bin.xz
    ${second_zip}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}
    ...    ${node_id.strip('0x')}D_l1a_iqSnapshotBuffer.bin.xz

    ${target_file_path}    Set Variable    ${path2}/${third_zip}
    ${target_file_name}=    Set Variable    ${target_file_path.rstrip('.xz')}
    ${uncompress_command}=    Set Variable    xz -d ${target_file_path}
    Run And Return Rc And Output    ${uncompress_command}
    ${file_exists}=    File Should Exist    ${target_file_name}
    ${file_size}=    Get File Size    ${target_file_name}
    Should Be True    ${file_size} > 1024    [ERROR] The size of ${target_file_name} is ${file_size} <= 1024.
    Remove files    ${path1}/${second_zip}    ${target_file_name}

    Filter And Check DU L1 Journal Log    ${snapshot}
    Filter And Check RU L1 Runtime Log    ${snapshot}

Swconfig File Flag Added
    ${config_items}=    Create Dictionary    0x10041=5    0x10040=1    0x1003F=1    0x10028=1    0x1002A=1    0x1005A=1    0x1002F=1
    ...    0x1002B=0x097E
    modify swconfig file    ${config_items}
