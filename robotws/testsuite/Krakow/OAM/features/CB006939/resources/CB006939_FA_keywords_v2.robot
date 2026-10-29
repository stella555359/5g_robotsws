*** Settings ***
Documentation    Keywords for feature 5GC002536

Library    testsuite.Krakow.OAM.features.CB006939.resources.CB006939_FA_keywords.LoginGuiMeasurements   WITH NAME   gui
Library    testsuite.Krakow.OAM.features.CB006939.resources.CB006939_FA_keywords.AdminSessionsMeasurements   WITH NAME   adm
Library    testsuite.Krakow.OAM.features.CB006939.resources.CB006939_FA_keywords.AdminCliConnection    WITH NAME   cli
Resource   taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${MPLANE_GNB_IP}=  ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${DU_GNB_LMP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${MRBTS_ID}=   ${tl.gnbs[0].instance_id}
${DU_ALIAS}=   du
${MAX_WEBEM_MEMORY_USAGE}   2048
${MAX_WEBEM_LOAD_DURATION}   5.0
${MAX_WEBEM_LOGIN_DURATION}    25.0
${MAX_WEBEM_RUNTIME_DURATION}    30.0

*** Keywords ***
Check WEBEM DU load time
    [Arguments]   ${du_web_address}
    gui.open_browser
    ${webem_load_duration}=   gui.open_login_page   ip_address=${MPLANE_GNB_IP}
    ...                         page_timeout=${MAX_WEBEM_LOAD_DURATION}
    Should be true  ${webem_load_duration} < ${MAX_WEBEM_LOAD_DURATION}  msg=Page loading took more than expected
    gui.login
    ...     modal_timeout=${MAX_WEBEM_LOGIN_DURATION}
    ...     runtime_timeout=${MAX_WEBEM_RUNTIME_DURATION}
    gui.collect_snapshot
    ${mem}=  gui.get_webdriver_memory_consumption
    log to console  Webdriver memory consumption ${mem}MB
    Should be true  ${mem} < ${MAX_WEBEM_MEMORY_USAGE}   msg=Memory consumption exceeds ${MAX_WEBEM_MEMORY_USAGE}MB
    [Teardown]  gui.close_browser

Create 10 concurrent DU WebEM sessions and expect error on 11th
    [Arguments]   ${du_webem_address}
    adm.establish_max_number_of_sessions   bts_ip_address=${du_webem_address}   expected_max=9
    [Teardown]  adm.teardown_all_admin_sessions

Download and unzip ADMIN CLI package
    cli.download_admin_package

Check admin cli standalone mode connection request latency
    ${time_measurements}=    cli.open_cli_connection_standalone_mode  mplane_ip=${MPLANE_GNB_IP}
    cli.check_if_time_within_range     ${time_measurements}  30.0

Check admin cli server mode connection latency
    ${time_measurements}=    cli.open_cli_connection_server_mode   mplane_ip=${MPLANE_GNB_IP}   port=9007
    cli.check_if_time_within_range  ${time_measurements}  30.0

Kill ADMIN CLI connection
    cli.kill_current_admin_cli

Check admin cli server mode request latency
    ${time_measurements}=    cli.open_cli_connection_server_mode   mplane_ip=${MPLANE_GNB_IP}    port=9008
    cli.check_if_time_within_range  ${time_measurements}  30.0
    ${time_measurements}=    cli.request_latency_server_mode
    cli.check_if_time_within_range    ${time_measurements}   5.0

Enable actCli parameter
    Perform Configuration Parameter Recommissioning On gNB
        ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    param_name=actCli
        ...    operation=update
        ...    param_value=true
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True

Check if it is impossible to create more than 5 admin cli connections
    cli.open_5_concurrent_admin_server_connections_expect_error_at_6th    mplane_ip=${MPLANE_GNB_IP}


