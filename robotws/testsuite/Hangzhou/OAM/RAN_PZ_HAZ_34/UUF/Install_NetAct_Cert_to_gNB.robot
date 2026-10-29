*** Settings ***
Force Tags    PY36
Documentation     Install NetAct Cert to gNB
Library           OperatingSystem
Library           String
Library           taf.selenium.sbts    WITH NAME    selenium_sbts
Resource          Resource${/}common.robot
Resource          Resource${/}netact_swm.robot

*** Variables ***
${NetAct_cert_link}    git@gitlabe1.ext.net.nokia.com:SG8/golden_scf.git
${password}       123456
${cert_format}    VNF
${origin_version}    ${EMPTY}
${file_name}   old_commission.xml

*** Test Cases ***
Install NetAct Cert to gNB
    [Setup]    Install NetAct Cert Case Setup

    Set Test Variable    ${NetAct_info}   ${netact_global_configuration}[${netact_nodeip}]
    Set Test Variable    ${NetAct_cert}   ${NetAct_info['name']}.p12
    Set Test Variable    ${cert_file}   /home/ute/cert/cert/${NetAct_cert}
    Set Test Variable    ${oam_tls_status}    off
    ${build_version}    set variable    ${origin_version.split(',')[0]}
    ${NE_TYPE}    Get OAM Type From gNB    version=${build_version}
    Get TLS Status of WebUI on COAM
    @{CMP NetAct}    Create List    LIANG    KUNGFU    QIN
    @{No CMP NetAct}    Create List
    run keyword if    '${NetAct_info['name']}' in @{CMP NetAct} and '${oam_tls_status}'=='forced'
    ...    Install BTS CMP Certificate on COAM    ${NetAct_info['reference_number']}    ${NetAct_info['pre_shared_key']}
    ...    ELSE IF   '${NetAct_info['name']}' in @{No CMP NetAct} and '${oam_tls_status}'=='forced'
    ...    Install NetAct Certificate    file_path=${cert_file}    password=${password}    cert_format=${cert_format}
    ...    ELSE    log    no need to install certificate
    [Teardown]    Install NetAct Cert Case Teardown

*** Keywords ***
Install NetAct Cert Case Setup
    run keyword and ignore error    selenium_sbts.enable_virtual_display

Install NetAct Cert Case Teardown
    run keyword and ignore error    selenium_sbts.disable_virtual_display

Install NetAct Certificate
    [Arguments]    ${file_path}=${cert_file}    ${password}=123456    ${cert_format}=VNF
    Get NetAct Certificate from Git
    log to console    Install NetAct Certificate on gNB
    Install NetAct Certificate on COAM    cert_file=${file_path}    password=${password}

Install NetAct Certificate on COAM
    [Arguments]    ${cert_file}    ${password}=123456
    log to console    Install NetAct Certificate on COAM
    wait until keyword succeeds    5mins    1min    selenium_sbts.login    https://${WEBUI_ADDR}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    ...    screenshot_dir=${OUTPUT_DIR}
    run keyword and ignore error    selenium_sbts.disable_message_box
    run keyword and ignore error    selenium_sbts.disable_screen_lock
    selenium_sbts.install_bts_certificates_from_local    bts_file_path=${cert_file}    password=${password}    timeout=60
    [Teardown]    run keyword and ignore error    selenium_sbts.logout

Get TLS Status of WebUI on COAM
    [Arguments]   ${file_name}=old_commission.xml
    ${connection}   wait until keyword succeeds  5min   1min   coam.connect_to   bts_host=${WEBUI_ADDR}   name=COAM
    COAM Backup SCF   local_dir=${OUTPUT_DIR}   file_name=${file_name}   connection=COAM
    ${XML}   xml.parse xml   ${OUTPUT_DIR}/${file_name}
    ${tls_status}   xml.get element text   ${XML}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"]
    Set Test Variable    ${oam_tls_status}    ${tls_status}
    [Teardown]   run keyword and ignore error  coam.teardown   connection=${connection}

Install BTS CMP Certificate on COAM
    [Arguments]    ${reference_number}    ${this_is_very_secret}
    wait until keyword succeeds    5mins    1min    selenium_sbts.login    https://${WEBUI_ADDR}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    ...    screenshot_dir=${OUTPUT_DIR}
    run keyword and ignore error    selenium_sbts.disable_message_box
    run keyword and ignore error    selenium_sbts.disable_screen_lock
    selenium_sbts.update_cmp_server_settings    ${reference_number}    ${this_is_very_secret}
    selenium_sbts.initialize_certificates
    [Teardown]    run keyword and ignore error    selenium_sbts.logout

Get NetAct Certificate from Git
    log to console    Get NetAct Certificate from Git
    Run    rm -rf /home/ute/cert/
    Create Directory    /home/ute/cert
    Log    \nStart to NetAct Certificate From GIT!    WARN
    ${output}    Run    git clone ${NetAct_cert_link} /home/ute/cert --progress --verbose
    Sleep    10s
    Should Contain    ${output}    Receiving objects: 100%
    Should Contain    ${output}    Resolving deltas: 100%
    Log To Console    Download NetAct Certificate Finished!
    ${output}    Run    ls /home/ute/cert/cert/
    #    ${cert_name}    set variable    ${NetAct_cert}.p12
    run keyword if  not ${output.count('${NetAct_cert}')}>0    FAIL    [ERROR] NetAct cert doesn't exist in gitlab!
