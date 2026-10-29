*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library    CB007841.py
Library    XML    use_lxml=True    WITH NAME    Myxml


Documentation
...    author: Ren Zhenzhen
...    contact: zhenzhen.ren@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
@{default_sfp_list}    FOTB    AOSD
@{default_link_list}    'connected'    'notConnected'

*** Keywords ***
CB007841-5G-E_AQQK_01_The BTS shall support NIDD parameter (EQM APEQM-SFPOperatorMode)
    [Arguments]    ${sfp_num}=3    ${sfp_list}=${default_sfp_list}
    [Documentation]    check fault4657
    Download SFPWhiteList from BTS
    Modify sfp module in sfpwhitelist    sfp_list=${sfp_list}
    Upload sfpwhitelist to BTS    log_name=new_${SFPWhiteList_name}
    Perform BTS Site Reset
    sleep    15min
    Check fault 4657 should present    sfp_num=${sfp_num}
    Modify parameter sfpOperatorMode    new_value=true
    Wait Until Keyword Succeeds    2min   30s    Expect Fault Should Absent    faultId=4657
    [Teardown]    Case Tear down


Download SFPWhiteList from BTS
    [Arguments]    ${asik_alias}=ASIK Master    ${log_path}=${TS_CASE_LOG_PATH}
    [Documentation]    Download SFPWhiteList from BTS
    Connect to Common Unit Master  alias=${asik_alias}
    ${output}    csn.execute     find /ffs/run/swpool/OAM/ -type f -name sfpWhitelist*.xml    connection=${asik_alias}    timeout=30
    log to console    ${output}
    ${SFPWhiteList_name}     Fetch From Right    ${output}    /
    ${SFPWhiteList_name}     Set Variable    ${SFPWhiteList_name.replace("\n", "").replace("\r", "")}
    Set Test Variable    ${SFPWhiteList_name}
    Wait until keyword succeeds    5 min    20 sec    csn.download file    remote_path=/ffs/run/swpool/OAM/${SFPWhiteList_name}
    ...    local_path=${log_path}/${SFPWhiteList_name}    connection=${asik_alias}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}


Modify sfp module in sfpwhitelist
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${sfp_list}=sfp_list
    [Documentation]    Delete sfp module in sfpwhitelist
    ${xml_root}    Myxml.parse xml    ${log_path}/${SFPWhiteList_name}
    FOR  ${sfp_model}  IN  @{sfp_list}
        ${xpath}=    set variable    ./record/ModuleName[.='${sfp_model}']/..
        ${value}=    Myxml.Get Element Count     ${xml_root}    xpath=${xpath}
        run keyword if    ${value} > 0     run keywords
        ...    Myxml.Remove Elements    ${xml_root}    xpath=${xpath}    AND
        ...    Myxml.Save Xml    ${xml_root}    ${log_path}/new_${SFPWhiteList_name}
        ${xml_root}    Myxml.parse xml    ${log_path}/new_${SFPWhiteList_name}
    END


Upload sfpwhitelist to BTS
    [Arguments]    ${log_name}=log_name    ${log_path}=${TS_CASE_LOG_PATH}    ${asik_alias}=ASIK Master
    [Documentation]    Upload sfpwhitelist to BTS
    Connect to Common Unit Master  alias=${asik_alias}
#    csn.execute     cd /ffs/run/swpool/OAM/;rm -rf sfpWhitelist*    connection=${asik_alias}    timeout=30
    csn.upload_file    remote_path=/ffs/run/swpool/OAM/${SFPWhiteList_name}    local_path=${log_path}/${log_name}
    ...    connection=${asik_alias}
    sleep    10
    csn.execute     crasign /ffs/run/swpool/OAM/${SFPWhiteList_name}    connection=${asik_alias}
    sleep    5
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}


Check fault 4657 should present
    [Arguments]    ${sfp_num}    ${connection}=GNB_OAM
    ${sfp_num}    Convert To Integer    ${sfp_num}
    ${notifier}    Create List
    Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    FOR  ${alarm}  IN  @{alarms}
        ${check_noti}    Fetch from right    ${alarm['notifier']}    APEQM_R-1/
        run keyword if    '${alarm['faultId']}'=='4657'    append to list    ${notifier}    ${check_noti}
    END
    ${fault_num}    get length    ${notifier}
    Should Be Equal    ${sfp_num}    ${fault_num}


Case Tear down
    Upload sfpwhitelist to BTS    log_name=${SFPWhiteList_name}
    Perform BTS Site Reset
    Sleep    2min
    COAM Wait gnb And Cells ready    timeout=15min
    Modify parameter sfpOperatorMode    new_value=false
    sleep    10s


Modify parameter sfpOperatorMode
    [Arguments]    ${dist_name}=MRBTS-${mrbtsID}/EQM-1/APEQM-1     ${new_value}=false
    COAM Navigate to login page via webUI
    Close Start Up View    timeout=60
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=SFP Operator Mode
    ...    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    Selenium Logout And Close Browser


BTS startup Cooled SFP+ or SFP28 transceivers support for FH interface
    Perform BTS Site Reset
    Sleep    2min
    COAM Wait gnb And Cells ready    timeout=15min
    ${status}     Check sfp cooled status
    Run Keyword If    '${status}' == 'True'    Check time stamp in rf log


Check sfp cooled status
    [Arguments]    ${connection}=GNB_OAM
    [Documentation]    check sfp cooled status should be consistent with the sfp
    ${sfp_info_list}    get sfp info list    connection=${connection}
    ${status}    set variable    ${False}
    FOR    ${sfp_info}    IN    @{sfp_info_list}
        ${status}    run keyword and return status  Should Be Equal As Strings   ${sfp_info['cooled']}    True
        exit for loop if    ${status}
    END
    [Return]   ${status}


Check sfp transmission rate info
    [Documentation]    check sfp transmission rate info
    ${rate_list}    create list
    ${ref_list}    create list
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    ${links_connected_list}    set variable    ${links['connected']}
    FOR  ${link_connected}  IN  @{links_connected_list}
        ${rate_source}    set variable    ${link_connected['details']['staticParameters']['transmissionRate']['source']}
        ${rate_destination}    set variable    ${link_connected['details']['staticParameters']['transmissionRate']['destination']}
        run keyword if    ${rate_source} != 9830.4  append to list    ${rate_list}    ${rate_source}
        run keyword if    ${rate_destination} != 9830.4  append to list    ${rate_list}    ${rate_source}
    END
    should be equal    ${rate_list}    ${ref_list}

BTS_startup_rate_selection_for_[Q]SFP28_transceiver_module
    [Arguments]    ${dist_name}
    [Documentation]    check transmission rate info
    Check sfp transmission rate info
    COAM Navigate to login page via webUI
    Close Start Up View    timeout=60
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=Link speed
    ...    new_value=Auto
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM Wait gnb And Cells ready    timeout=15min
    Check sfp transmission rate info
    [Teardown]    Selenium Logout And Close Browser

Check time stamp in rf log
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1    ${log_name}=7841_rflog
    ...    ${txt1}="Cooled transceiver detected"    ${txt2}="Sfp state changed from: Initializing, to: Ready"
    [Documentation]    collect rf log and check the time difference < 90s
    Collect RF Logs To TestPC    log_name=${log_name}    ru_index=${ru_index}
    Run  rm -rf ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}.zip -d ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}/1011_runtime.zip -d ${log_path}/${log_name}
    Run  unxz ${log_path}/${log_name}/runtime_DEFAULT.log.xz
    Run  unzip ${log_path}/${log_name}/1011_startup.zip -d ${log_path}/${log_name}
    Run  unxz ${log_path}/${log_name}/startup_DEFAULT.log.xz
    ${startup_file}    set variable    ${log_path}/${log_name}/startup_DEFAULT.log
    ${runtime_file}    set variable    ${log_path}/${log_name}/runtime_DEFAULT.log
    ${Detected_time}    Run    command=grep ${txt1} ${startup_file} ${runtime_file} | tail -1
    ${Ready_time}    Run    command=grep ${txt2} ${startup_file} ${runtime_file} | tail -1
    ${check_time}    Check_timestamp_rflog    detect_time=${Detected_time}    ready_time=${Ready_time}
    should be true    ${check_time} == 1


Check sfp information
    [Arguments]    ${link_list}=${default_link_list}
    Perform BTS Site Reset
    Sleep    2min
    COAM Wait gnb And Cells ready    timeout=15min
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}=    Get Information about SFP links
    Check value range    links=${links}    link_list=${link_list}



Check value range
    [Arguments]    ${links}    ${link_list}
    [Documentation]    EIF sfp has no destination information,make power2=power1 so that can check conveniently
    FOR  ${link_status}  IN  @{link_list}
        ${link}    set variable    ${links[${link_status}]}[0]
        ${rxpower1}    set variable    ${link['data']['measurements']['RXOpticalPowerDBM']['source']}
        ${rxpower2}    run keyword if    ${link_status}=='connected'
        ...    set variable    ${link['data']['measurements']['RXOpticalPowerDBM']['destination']}
        ...    ELSE    set variable    ${rxpower1}
        ${txpower1}    set variable    ${link['data']['measurements']['TXOpticalPowerDBM']['source']}
        ${txpower2}    run keyword if    ${link_status}=='connected'
        ...    set variable    ${link['data']['measurements']['TXOpticalPowerDBM']['destination']}
        ...    ELSE    set variable    ${txpower1}
        ${temperature1}    set variable    ${link['data']['measurements']['moduleTemperature']['source']}
        ${temperature2}    run keyword if    ${link_status}=='connected'
        ...    set variable    ${link['data']['measurements']['moduleTemperature']['destination']}
        ...    ELSE    set variable    ${temperature1}
        ${rxPowerLowAlarmThreshold}    set variable    ${link['details']['thresholds']['rxPowerLowAlarmThreshold']['source']}
        ${rxPowerHighAlarmThreshold}    set variable    ${link['details']['thresholds']['rxPowerHighAlarmThreshold']['source']}
        ${txPowerLowAlarmThreshold}    set variable    ${link['details']['thresholds']['txPowerLowAlarmThreshold']['source']}
        ${txPowerHighAlarmThreshold}    set variable    ${link['details']['thresholds']['txPowerHighAlarmThreshold']['source']}
        ${temperatureHighAlarmThreshold}    set variable    ${link['details']['thresholds']['temperatureHighAlarmThreshold']['source']}
        ${temperatureLowAlarmThreshold}    set variable    ${link['details']['thresholds']['temperatureLowAlarmThreshold']['source']}
        ${check_thr}    Check_value_threshold    value1=${rxpower1}    value2=${rxpower2}    lowthreshold=${rxPowerLowAlarmThreshold}
        ...    highthreshold= ${rxPowerHighAlarmThreshold}
        should be true    ${check_thr} == 1
        ${check_thr}    Check_value_threshold    value1=${temperature1}   value2=${temperature2}
        ...    lowthreshold=${temperatureLowAlarmThreshold}    highthreshold=${temperatureHighAlarmThreshold}
        should be true    ${check_thr} == 1
        ${check_thr}    Check_value_threshold    value1=${txpower1}    value2=${txpower2}    lowthreshold=${txPowerLowAlarmThreshold}
        ...    highthreshold= ${txPowerHighAlarmThreshold}
        should be true    ${check_thr} == 1
    END


BTS startup SFP power level compatibility validation
    [Arguments]    ${RF_port}=RF1    ${power}=PL2
    Connect to Common Unit Master    alias=ASIK Master
    ${power_txt}    csn.execute     timeout 5 /opt/trs/bin/trs-eth-d monitor    connection=ASIK Master    timeout=30
    ${result}    Select_power_information_smod    str1=${power_txt}
    should be true    ${result} == 1
    Connect to BBMOD    abil_alias=ABIL Master    asik_alias=ASIK Master
    csn.execute    sfp_tester mem_dump /tmp/my_dump_file_1.txt    connection=ABIL Master
    sleep    10
    ${pl_txt}    csn.execute    grep -A 6 ${RF_port} /tmp/my_dump_file_1.txt    connection=ABIL Master
    log to console    ${pl_txt}
    ${check_num}    Check_dump_file_powerlevel    dump_txt=${pl_txt}    power=${power}
    Should Be True    ${check_num} == 1
    [Teardown]    run keywords    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master


Connect to BBMOD
    [Arguments]    ${abil_alias}=ABIL Master    ${asik_alias}=ASIK Master
    ${BBMOD_txt}    csn.execute    ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${asik_alias}    timeout=30
    ${hostname}    Check_BBMOD_type    BBMOD_txt=${BBMOD_txt}
    ssh.Connect to    hostname=${hostname}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               proxy=${asik_alias}    alias=${abil_alias}
