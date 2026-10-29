*** Settings ***
Documentation
...   author:  Jakub Siluch
...   maintainer: Jakub Siluch
...   contact: jakub.siluch@nokia.com

Resource        taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot
Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Library         taf.rfrl.utilities.logger.custom_logger
Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library         testsuite.Krakow.resources.UUF_ASIR.uuf_asir_common
Library         taf.ul.sc.tl_config.TestLineConfiguration
Library         taf.rfrl.bts.commissioning
Library         taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py  WITH NAME  update
Library         testsuite.Krakow.resources.UUF_ASIR.uuf_asir_factory_load     WITH NAME      factory_load
Library         testsuite.Krakow.resources.UUF.upgrade_and_commission_bts     WITH NAME      prepare_gnb
Library         ../UUF/get_uuf_builds.py


*** Variables ***

${REMOTE_VM_IP}=           ${None}
${REMOTE_MPLANE}=          ${None}
${REMOTE_NODE_UPDATE}=     ${False}
${REMOTE}=                 ${False}

*** Keywords ***

Factory Load Test Setup
    [Arguments]    ${builds_dict}     ${hub_builds_path}    ${5g_target_sw}    ${proxy}
    ${hub_number}=    Get HUB number from HW info
    prepare_hub_builds      ${builds_dict}    ${proxy}      ${hub_builds_path}
    taf.rfrl.utilities.logger.custom_logger.Log Info To Console    Copying HUB builds to SMODs
    factory_load.scp_builds_to_smods     ${builds_dict}     ${hub_builds_path}
    taf.rfrl.utilities.logger.custom_logger.Log Info To Console    Attempt to download target build
    ${5g_target_sw_path}=   update.Download Package     ${5g_target_sw}   use_builds_storage=${False}
    ${case_type}=           Convert To String           Factory Load
    Set Test Variable       ${STOP_FIX}                 ${False}
    Set Test Variable       ${CASE_TYPE}                ${case_type}
    Set Test Variable       ${5G_TARGET_SW_PATH}        ${5g_target_sw_path}
    Set Test Variable       ${5G_TARGET_SW}             ${5g_target_sw}
    Set Test Variable       ${HUB_BUILDS_PATH}          ${hub_builds_path}
    Set Test Variable       ${BUILDS_DICT}              ${builds_dict}
    Set Test Variable       ${HUBS_NUMBER}              ${hub_number}
    [Teardown]    admin.Teardown All Aliases For Admin

Factory Load Test
    [Arguments]   ${test_phase}=${EMPTY}  ${remote}=${False}
    Run Keyword And Ignore Error   uuf_rfrl_common_keywords.Setup Admin Connection
    ${bts}=  uuf_rfrl_common.Get Bts For Operation  ${remote}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test  ${test_phase}/update/${bts}  ${remote}
    uuf_rfrl_common_keywords.Watch Alarms  remote=${remote}
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/update/${bts}
    factory_load.run_factory_load      ${BUILDS_DICT}    ${HUBS_NUMBER}
    Wait Until Keyword Succeeds    5m    10sec    Verify if faults 23 exist on HUBs    ${HUBS_NUMBER}
    uuf_rfrl_common.Update Sw    ${5G_TARGET_SW}    ${5G_TARGET_SW_PATH}    ${remote}
    uuf_rfrl_common.Verify SW change    ${5G_TARGET_SW}    ${remote}
    taf.rfrl.utilities.logger.custom_logger.Log Info To Console    Waiting for HUBs availity after bts update
    factory_load.wait_until_all_hubs_available
    Run Keyword And Ignore Error   uuf_rfrl_common_keywords.Setup Admin Connection
    factory_load.verify_build_hub_change_after_bts_upgrade    ${5G_TARGET_SW}
    Wait Until Keyword Succeeds    5m    10sec    Verify if faults 23 exist on HUBs     0
    Verify if fault 23 exist in alarm history
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify BTS State  120  ${test_phase} after update  ${remote}
    uuf_rfrl_common_keywords.Get Blackbox File After Test  ${test_phase}/update/${bts}  ${remote}
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error
    ...  uuf_rfrl_common_keywords.Verify Logs   ${test_phase} after update  ${False}  ${remote}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}
    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/update/${bts}
    Run Keyword If  "${result}" == "False"  Fail
    [Teardown]  Run Keywords  Run Keyword If  "${CRITICAL_FAULT_STATUS_LOCAL}" == "False"  Fatal Error  Critical Fault Visible  AND
    ...         Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Stop Watching Alarms  ${remote}  AND
    ...         Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin  AND
    ...         Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Collect Syslog

Verify if faults 23 exist on HUBs
     [Arguments]    ${expected_alarm_number}
     ${alarms}=    admin.get_active_alarms   connection=${LOCAL_ADMIN}
     check_number_of_fault_23_on_hubs    ${alarms}     ${expected_alarm_number}

Verify if fault 23 exist in alarm history
     ${alarms}=    admin.get_historic_alarms    connection=${LOCAL_ADMIN}     load_history=${True}  timeout=60
     check_if_alarm_exists_in_alarm_history    ${alarms}

Factory Load Test Case
    [Arguments]  ${test_iteration}=1
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${hub_builds_dict}=${None}
    ...          ${factory_load_files_path}=/home/ute/UUF_SW/
    ...          ${target_sw_enb}=${None}
    ...          ${proxy_svne}=http://proxy-lab.krk-lab.nsn-rdnet.net:8080
    ${allowed_alarms}=    Create List       23    4478    10
    ${custom_alarms}=     Combine Lists     ${allowed_alarms}     ${custom_alarms}
    uuf_rfrl_common_keywords.Common Test Setup   custom_alarms=${custom_alarms}   critical_faults=${critical_faults}
    ...  label=${None}   hostname=${None}    should_be_reported=${False}    remote_vm_ip=${None}
    ...  customers_list=${None}  remote_mplane=${None}   use_remote_node=${False}
    Factory Load Test Setup     ${hub_builds_dict}     ${factory_load_files_path}    ${target_sw_enb}  ${proxy_svne}
    uuf_rfrl_common_keywords.Verify Test In Loop    ${test_iteration}    ${False}
    ...                      uuf_asir_common_keywords.Factory Load Test
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  factory_load.delete_hub_builds_files      ${hub_builds_dict}
    ...  AND    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin

Single Software Update No Rollback
    [Arguments]    ${5g_target_sw}    ${custom_alarms}=@{EMPTY}     ${critical_faults}=@{EMPTY}
    Set Test Variable       ${i}    0
    &{kpis}=    Create Dictionary
    Set Test Variable  ${KPIS}  ${kpis}
    Set Test Variable  ${PASS_ITERATION}  ${0}
    uuf_rfrl_common_keywords.Common Test Setup    custom_alarms=${custom_alarms}   critical_faults=${critical_faults}
    ...  label=${None}   hostname=${None}    should_be_reported=${False}    remote_vm_ip=${None}
    ...  customers_list=${None}  remote_mplane=${None}   use_remote_node=${False}
    Prepare 5G SW    5g_target_sw=${5g_target_sw}    5g_source_sw=${None}  5g_target_sw_path=${None}
    ...              use_builds_storage=${False}     download_path=${None}    use_test_packages=${False}
    ${update_test_variables}=     uuf_rfrl_common.Get Update Variables
    Set Test Variable  ${UPDATE_TEST_VARIABLES}  ${update_test_variables}
    &{update_results}=    Create Dictionary
    Set Test Variable  ${UPDATE_RESULTS}  ${update_results}
    admin.Teardown All Aliases For Admin
    Software Update    ${5G_TARGET_SW}         ${5G_TARGET_SW_PATH}    test_phase=${EMPTY}       remote=${False}
    [Teardown]     admin.Teardown All Aliases For Admin

Check SW And Update If Needed
    [Arguments]      ${5g_target_sw}     ${CUSTOM_ALARMS}    ${critical_faults}=@{EMPTY}
    Run Keyword And Ignore Error   uuf_rfrl_common_keywords.Setup Admin Connection
    ${result}=       Run Keyword And Ignore Error  uuf_rfrl_common.Verify Sw Change     ${5g_target_sw}
    Run Keyword If   '${result}[0]' != 'PASS'      Single Software Update No Rollback   ${5g_target_sw}
    ...              custom_alarms=${CUSTOM_ALARMS}    critical_faults=${CRITICAL_FAULTS}
    admin.Teardown All Aliases For Admin

Suite Setup
    [Arguments]    ${disk_path}           ${disk_passowrd}   ${source_builds}    ${target_build}
    ...            ${hub_builds_dict}     ${bts_scf}         ${asir_scf}         ${prefix_tag}     ${https_proxy}
    ...            ${UTE_run}=${False}
    taf.rfrl.utilities.logger.custom_logger.Log Info To Console    Starting suite setup
    Run Keyword If    ${UTE_run} == ${True}     Set Source List and Target Build Variables
    Run Keyword If    ${UTE_run} == ${True}     Set HUB Factory Loads Variable
    Run Keyword And Ignore Error    prepare_build_disk                 ${disk_passowrd}    ${disk_path}
    download_all_needed_builds      ${source_builds}  ${target_build}  ${hub_builds_dict}  ${https_proxy}  ${disk_path}
    admin.Setup Admin
    ${active_sw}=     Run Keyword And Ignore Error    uuf_rfrl_common.Get Active Sw Version     default
    Run Keyword If    '${active_sw[1].split(":")[0]}' != '@{SOURCE_ENB_BUILDS}[0]'
    ...               Prepare TL  @{SOURCE_ENB_BUILDS}[0]    ${bts_scf}    ${asir_scf}    ${prefix_tag}    ${disk_path}
    ...    ELSE       Wait Until Keyword Succeeds   10m   20    gnbbbu.Verify Bts Is Onair
    [Teardown]        Run Keyword And Ignore Error              admin.Teardown All Aliases For Admin

Prepare TL
    [Arguments]    ${5g_target_sw}    ${bts_scf}     ${asir_scf}    ${prefix_tag}   ${builds_dir}=/home/ute/UUF_SW/
    Run Keyword And Ignore Error     admin.Setup Admin
    prepare_gnb.upgrade_and_commission_gnb    ${5g_target_sw}    ${bts_scf}    ${asir_scf}    ${builds_dir}
    [Teardown]   Run Keyword And Ignore Error       admin.Teardown All Aliases For Admin

Wait For Update Possibility
    admin.Setup Admin
    admin.wait_sw_update_possible
    [Teardown]     admin.Teardown All Aliases For Admin

Get HUB number from HW info
    ${bts_info}=      admin.Get Bts Info  connection=${LOCAL_ADMIN}
    ${ru_type}=       get_rmods_and_hubs    ${bts_info}
    ${ru_amount}=     Run Keyword If     "+" in "${ru_type}"    get_number_of_hubs_from_hw_conf    ${ru_type}
    ...               ELSE    Set Variable    ${ru_type[0]}
    [Return]          ${ru_amount}
