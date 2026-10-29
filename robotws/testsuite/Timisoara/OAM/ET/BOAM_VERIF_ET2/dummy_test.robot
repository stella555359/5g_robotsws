*** Settings ***

Documentation
...    Sample execution: robot --variable number_of_resets:4 -L TRACE -b debug.log -d results/
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/dummy_test.robot

Library    taf.sbts.oam.coam.admin

Test Setup        ADMIN Setup Admin
Test Teardown     ADMIN Teardown Admin

*** Variables ***
${ADMIN_BTS_HOST}=            192.168.255.1
${ADMIN_BTS_PORT}=            443
${ADMIN_USERNAME}=            Nemuadmin
${ADMIN_PASSWORD}=            nemuuser
${ADMIN_USE_SSL}=             True
${ADMIN_UPDATE_INTERVAL}=     5000
${ADMIN_API_LOG_DIR}=         ${OUTPUT_DIR}
${ADMIN_TIMEOUT}=             30
${ADMIN_ALIAS}=               default

*** Test Cases ***
Periodic Site Reset
    FOR    ${i}    IN RANGE  1  ${number_of_resets}+1
        log to console  Reset No ${i}
        ADMIN Reset Site
        Sleep  60
    END

*** Keywords ***
ADMIN Setup Admin
    [Arguments]    ${bts_host}=${ADMIN_BTS_HOST}
    ...            ${bts_port}=${ADMIN_BTS_PORT}
    ...            ${username}=${ADMIN_USERNAME}
    ...            ${password}=${ADMIN_PASSWORD}
    ...            ${use_ssl}=${ADMIN_USE_SSL}
    ...            ${update_interval}=${ADMIN_UPDATE_INTERVAL}
    ...            ${admin_api_log_dir}=${ADMIN_API_LOG_DIR}
    ...            ${timeout}=${ADMIN_TIMEOUT}
    ...            ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${use_ssl}
    ...    update_interval=${update_interval}
    ...    admin_api_log_dir=${admin_api_log_dir}
    ...    alias=${alias}
    ...    timeout=${timeout}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    alias=${alias}

ADMIN Reset Site
    [Arguments]    ${timeout}=360
    ...            ${wait_for_reconnection}=${True}
    ...            ${connection}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Reset Site
    ...    timeout=${timeout}
    ...    wait_for_reconnection=${wait_for_reconnection}
    ...    connection=${connection}
