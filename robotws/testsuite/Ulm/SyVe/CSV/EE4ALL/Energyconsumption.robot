*** Settings ***
Documentation
...
...     INTRODUCTION:  Energy Efficiency
...     CONTACTS:      VRF_ULM_T01_02
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     OperatingSystem

Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations               WITH NAME    gnbbbu
Resource    taf/rfrl/procedures/SISO/ESM/resources/ESM.robot

Resource    ../../../../Ulm/resources/Common/testline.robot
Resource    ../../../../Ulm/resources/Common/snapshot.robot
Resource    ../../../../Ulm/resources/Common/pmcounters.robot
Resource    ../../../../Ulm/resources/Common/gnb.robot
Resource    ../../../../Ulm/resources/Common/reporting.robot
Library     ../../../../Ulm/SyVe/CSV/libraries/common_tools.py    WITH NAME    common_tools
Resource    ../../../../Ulm/SyVe/CSV/resources/commonKeywords.robot
Resource    ../../../../Ulm/SyVe/resources/syve_testline.robot


Suite Setup     Do Suite Setup
Suite Teardown  Do Suite Teardown



*** Variables ***

${WITH_PM_COUNTERS}               ${TRUE}    # [INFO] ${TRUE} or ${FALSE}



*** Test Cases ***

EE4ALL_KPI_MEASUREMENT_TEST
    [Tags]     EE4ALL_KPI_MEASUREMENT_TEST    QC_318334    QCD_MN_RAN    QCP_RAN_VRF
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	gnbbbu.Connect
    # Remember to connect to ADMIN CLI and then pass the connection to the keyword

    ${suite_path}    ${suite_file}    OperatingSystem.Split Path    ${SUITE SOURCE}
    Run ESM Measurement Procedure
    ...    connection=REST_GNB0_DU0
    ...    configuration_yaml_file=${suite_path}/esm_configuration_${tl_name}.yaml
    ...    report_kpi=True
    Run Keyword And Ignore Error    reporting.Set SCOUT TC ID For Reporting    scout_tl_name=${tl_name}



*** Keywords ***

Do Suite Setup
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${robot_report_target_dir}    testline.Get test suite result base directory
    Set Suite Variable    ${robot_report_target_dir}
    ${ts_log_dir}    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}
    ${tl_name}    testline.Get Testline Name
    Set Suite Variable    ${tl_name}
    ${ts_config_dir}    testline.Get Test Suite Config Directory
    Set Suite Variable    ${ts_config_dir}
    gnb.Get SCF From gNB    target_dir=${ts_config_dir}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Keyword And Continue On Failure
    ...    commonKeywords.Identify The List Of Unique SMODs And Associated Primary SBTS Nodes Of The Testline   log_to_console=${True}
    Set Suite Variable    ${PRIMARY_TL_NODES_LIST}
    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        IF   ('syslog' in ${ENABLED_LOGS})
        ...   syve_testline.Start Syslog Collection For CCRTS    node_id=${node_id}    node_type=${node_type}
    END


Do Suite Teardown
    Log To Console    "Overall Suite Status: ${SUITE_STATUS}"
    IF    '${SUITE_STATUS}' == 'FAIL'    OperatingSystem.Create File    ${robot_report_target_dir}/offline_reporting.txt    false
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        IF    ('syslog' in ${ENABLED_LOGS})   Run Keyword And Warn On Failure
        ...    syve_testline.Stop syslog collection for CCRTS   node_type=${node_type}    node_id=${node_id}
        IF    ('snapshot' in ${ENABLED_LOGS})   Run Keyword And Warn On Failure
        ...    snapshot.Get snapshot for node   node_type=${node_type}    node_id=${node_id}    target_dir=${ts_log_dir}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${WITH_PM_COUNTERS}
        ${pm_counters_dir}    Run Keyword And Continue On Failure    pmcounters.Collect PM Counter    target_dir=${ts_log_dir}/pmc
        Set Suite Variable    ${pm_counters_dir}
        Run Keyword And Continue On Failure    common_tools.Zip Older PM Files To Save Conversion Time    directory=${pm_counters_dir}
        ...                                                                                               keep_recent=12
        ...                                                                                               zip_name=archived_PM_files.zip
        ...                                                                                               file_name_filter=PM.BTS
        Run Keyword And Continue On Failure    pmcounters.Convert PM Files To CSV    file_path=${pm_counters_dir}
    END
