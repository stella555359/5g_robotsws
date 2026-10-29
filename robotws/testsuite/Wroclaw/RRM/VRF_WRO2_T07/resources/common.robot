*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   Set of common keywords to be used in tests

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.py
Library    OperatingSystem
Library    ute_syslog
Library    taf.sw.reporting_portal
Library    taf.collectors.btslog    WITH NAME  btslog
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.collectors.tcpdump   WITH NAME  tcpdump
Library    taf.collectors.core      WITH NAME  core
Variables  testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/vars/testline_mapping.py


*** Variables ***
${default_syslog_alias}   test_syslog


*** Keywords ***
Remove tmp btslog dir
    [Arguments]     ${path}=/tmp/btslog2
    Remove directory    ${path}    recursive=${True}


Start syslog capture
    [Arguments]   ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  ${log_name}=SYSLOG.LOG
    ...           ${alias}=${default_syslog_alias}
    ute_syslog.start_syslog  log_dir=${log_dir}  log_name=${log_name}  alias=${alias}


Stop syslog capture
    [Arguments]   ${alias}=${default_syslog_alias}
    ute_syslog.collect_syslog_results  alias=${alias}
    ute_syslog.teardown_all_aliases_for_syslog


Set Scout Configuration ID
    ${scout_config_id}  fetch_scout_id  testline_name=${TL_NAME_SCOUT}
    run keyword if  '${scout_config_id}'!='None'  add to test data  data={"tc_execution_id": "${scout_config_id}"}


Get Software release name
    [Arguments]   ${alias}
    ${release}       coam.Get sw release name  connection=${alias}
    Should not be empty   ${release}
    [Return]   ${release}


Connect with runtime release
    [Arguments]      ${alias}=admin_api
    coam.connect to  name=${alias}
    ${release}=   Wait Until Keyword Succeeds   5 min   1 min   Get Software release name   ${alias}
    coam.teardown    connection=${alias}
    coam.connect_to  name=${alias}             release=${release}


Setup cplane tcpdump collector
    [Arguments]
    ...    ${name}=cplane_collector
    ...    ${host}=192.168.255.129

    Set suite variable    ${cplane_collector}    ${name}
    ${sysmod_executor}    Create Dictionary
    ...     host=${host}
    ...     user=toor4nsn
    ...     password=oZPS0POrRieRtu

    tcpdump.create_tcpdump_collector
    ...     name=${cplane_collector}
    ...     options=-p -i any sctp
    ...     executor=${sysmod_executor}
    core.Setup collectors    ${cplane_collector}
    core.Set Suite Alias     ${cplane_collector}


Start cplane logs
    log to console    starting cplane logs
    core.Start collectors    ${cplane_collector}


Stop cplane logs
    [Arguments]   ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/
    log to console            Stopping cplane logs
    core.Stop collectors      ${cplane_collector}
    core.Collect collectors   ${cplane_collector}  target_dir=${log_dir}
    core.Teardown collectors  ${cplane_collector}


