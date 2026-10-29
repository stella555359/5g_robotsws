*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Library    9260.py
Library    XML    use_lxml=True    WITH NAME    Myxml


Documentation

*** Variables ***
${host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${user}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${password}   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
BTS_startup_SFP_power_level_compatibility_validation_AWHQN
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify when BTS has detected SFP power level incompatibility
    ...    and the operator is informed about SFP power level incompatibility by an alarm in BTS Element Manager or NMS.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.09.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${stream}    get stream from version    ${Active_SW_version}
    ${sfp_info_list}    get sfp info list
    ${sfp_list}    get sfp type list    sfp_info_list=${sfp_info_list}
    ${check_bit}    set variable if    '${sfp_list}[0]'=='AOSK'    02
    ...    '${sfp_list}[0]'=='AOSD'    0E,18,1C
    ...    '${sfp_list}[0]'=='AOXC'    3E
    ...    '${sfp_list}[0]'=='AOXD'    3E
    ...    Undefined
    Connect to Common Unit Master    alias=ASIK Master
    ${power_txt}    csn.execute     timeout 5 /opt/trs/bin/trs-eth-d monitor    connection=ASIK Master    timeout=30
    ${result}    Run Keyword If    '${stream}' == 'SBTS22R4'
    ...    Select_power_information_smod_22r4    str1=${power_txt}
    ...    ELSE    Select_power_information_smod_AWHQN    str1=${power_txt}
    should be true    ${result} == 1
    #Connect to fsp_1b    abil_alias=fsp_1b
    #csn.execute    sfp_tester mem_dump /tmp/my_dump_file_1.txt    connection=fsp_1b
    ${dump_file}    Collect dump_file And check power class
    ${check_result}    get_dump_file_result    dump_file=${log_path}/my_dump_file_1.txt
    Should Contain    ${check_bit}    ${check_result}
    #run keywords    Run Keyword And Ignore Error    csn.disconnect    connection=fsp_1b    AND
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master


SISO Coam 9260Suite Setup
    [Arguments]    ${gnb_index}=0    ${gNBMode}=Singlecore
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    #run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    Run Keyword If    '${gNBMode}'=='Dualcore'    KW.gNB.ConfigurationReset
    gNB.Commission    ${CFGFILE_PATH}/SCF_CB009260.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    get eNB active version
    set suite variable    ${suite_setup_fail_flag}    ${False}

Collect dump_file And check power class
    [Arguments]  ${log_command}=bsh 1:1     ${bget}=bget 1:1
    ...  ${hostname}=${host}    ${username}=${user}      ${password}=${password}     ${alias}=gnb
    csn.Connect to    hostname=${host}   username=${user}   password=${password}    alias=${alias}
    csn.send_command    command=${log_command} sfp_tester mem_dump /tmp/dump_file.txt      connection=${alias}
    sleep    5s
    csn.send_command    command=${bget} /tmp/dump_file.txt /tmp/
    ...   connection=${alias}
    sleep   5s
    csn.download_file   remote_path=/tmp/dump_file.txt     local_path=${log_path}/my_dump_file_1.txt
    ...   connection=${alias}
    ${dump_file}    Set Variable       ${log_path}/my_dump_file_1.txt
    #sleep    10
    #Wait until keyword succeeds    2min    30 sec    csn.download file    remote_path=${log_path}/my_dump_file_1.txt${dump_file}
    #...    local_path=${dump_file}    connection=${alias}
    [Teardown]    csn.Disconnect     connection=${alias}
    [Return]    ${dump_file}

KW.gNB.ConfigurationReset
    [Documentation]  Description: perform configuration reset from WebEM
    log to console    gNB configuration reset
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    selenium_sbts.configuration_reset
    sleep   20s
    Run Keyword And Ignore Error     COAM_WebEM.Logout


KW.gnb.LoginWithCoreMode
    [Documentation]  Description: input is Dualcore or Singlecore
    [Arguments]    ${mode}=Singlecore
    Run keyword if     '${mode}'=='Dualcore'       KW.SWM.COAM_WebEM.LoginWithSync    button=Start sync  url=${ASIK_LMP_IP_URL}
    ...      ELSE IF   '${mode}'=='Singlecore'    COAM_WebEM.Login