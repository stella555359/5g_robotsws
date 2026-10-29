*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

Library    7841.py
Library    XML    use_lxml=True    WITH NAME    Myxml
Library    Collections


Documentation
...    author: Shi Zhihao
...    contact: zhihao.shi@nokia-sbell.com
...    Group: HGZ_SG4

*** Variables ***

*** Keywords ***
BTS_startup_SFP_power_level_compatibility_validation
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
    &{power_req}    create dictionary    <1W=00    <1.5W=00,01    <2W=00,01,10,11
    ${check_power_level}    set variable if    '${sfp_list}[0]'=='AOMC'    <1.5W
    ...    '${sfp_list}[0]'=='AOSK'    <1.5W
    ...    '${sfp_list}[0]'=='AOSD'    <1.5W
    ...    '${sfp_list}[0]'=='AOSE'    <2W
    ...    Undefined
    Connect to Common Unit Master    alias=ASIK Master
    ${power_txt}    csn.execute     timeout 5 /opt/trs/bin/trs-eth-d monitor    connection=ASIK Master    timeout=30
    ${result}    Run Keyword If    '${stream}' == 'SBTS22R4'
    ...    Select_power_information_smod_22r4    str1=${power_txt}
    ...    ELSE    Select_power_information_smod    str1=${power_txt}
    should be true    ${result} == 1
    Connect to fsp_1b    abil_alias=fsp_1b
    csn.execute    sfp_tester mem_dump /tmp/my_dump_file_1.txt    connection=fsp_1b
    sleep    10
    Wait until keyword succeeds    2min    30 sec    csn.download file    remote_path=/tmp/my_dump_file_1.txt
    ...    local_path=${log_path}/my_dump_file_1.txt    connection=fsp_1b
    ${check_result}    get_dump_file_result    dump_file=${log_path}/my_dump_file_1.txt
    ${power_level_bits} =	Get SFP Power Level Bits    memory_segment=${check_result}
    Should Contain    ${power_req}[${check_power_level}]    ${power_level_bits}
    [Teardown]    run keywords    Run Keyword And Ignore Error    csn.disconnect    connection=fsp_1b    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master


The_BTS_shall_support_NIDD_parameter
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify SFPOperatorMode is used to enable/disable skipping
    ...    compliance validation of the transceiver module. True value of the parameter means skip compliance validation.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.09.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${sfp_info_list}    get sfp info list
    ${sfp_list}    get sfp type list    sfp_info_list=${sfp_info_list}
    Download SFPWhiteList from BTS
    Modify sfp module in sfpwhitelist    sfp_list=${sfp_list}
    Upload sfpwhitelist to BTS    log_name=new_${SFPWhiteList_name}
    Perform BTS Site Reset
    sleep    540s
    COAM Wait gnb And Cells ready    timeout=15min
    sleep    10
    Check fault 4657 should present
    Modify parameter sfpOperatorMode    new_value=true
    Wait Until Keyword Succeeds    2min   30s    Expect Fault Should Absent    faultId=4657
    [Teardown]    run keywords    Case Tear down


BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify cooled SFP+/SFP28 transceiver modules when BTS starts
    ...    up or operator plugs in/replaces a SFP+/SFP28 transceiver module.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.09.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Perform BTS Site Reset
    sleep    540s
    COAM Wait gnb And Cells ready    timeout=15min
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}    Get Information about SFP links
    Check value range    links=${links}
    ${sfp_info_list}    get sfp info list
    ${status}    get cooled Transceiver Declaration status    sfp_info_list=${sfp_info_list}
    ${stream}    get stream from version  version=${Active_SW_version}
    ${txt1}    set variable if    '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Cooled transceiver detected
    ...    Cooled sfp detected
    Run Keyword If    '${status}' == 'True'    Check time stamp in rf log    txt1=${txt1}


Download SFPWhiteList from BTS
    [Arguments]    ${asik_alias}=ASIK Master    ${log_path}=${TS_CASE_LOG_PATH}
    Log To Console    Download SFPWhiteList from BTS
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
    Log To Console    Delete sfp module in sfpwhitelist
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
    Log To Console    Upload sfpwhitelist to BTS
    Connect to Common Unit Master  alias=${asik_alias}
    csn.upload_file    remote_path=/ffs/run/swpool/OAM/${SFPWhiteList_name}    local_path=${log_path}/${log_name}
    ...    connection=${asik_alias}
    sleep    10
    csn.execute     crasign /ffs/run/swpool/OAM/${SFPWhiteList_name}    connection=${asik_alias}
    sleep    5
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}


Check fault 4657 should present
    [Arguments]    ${connection}=GNB_OAM
    Log To Console    Check Fault 4657 number in WebUI
    ${sfp_info_list}    get sfp info list    connection=${connection}
    ${sfp_num}    Get Length    ${sfp_info_list}
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
    sleep    540s
    COAM Wait gnb And Cells ready    timeout=15min
    Modify parameter sfpOperatorMode    new_value=false
    sleep    10s


Modify parameter sfpOperatorMode
    [Arguments]    ${dist_name}=MRBTS-${mrbtsID}/EQM-1/APEQM-1     ${new_value}=false
    Log To Console    Modify SFP Operator Mode to ${new_value}
    COAM Navigate to login page via webUI
    Close Start Up View    timeout=60
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=SFP Operator Mode
    ...    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    Selenium Logout And Close Browser


Check time stamp in rf log
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1    ${log_name}=7841_rflog
    ...    ${txt1}="Cooled sfp detected"    ${txt2}="Sfp state changed from: Initializing, to: Ready"
    Log To Console    Collect RF log and check the time difference < 90s
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


Check value range
    [Arguments]    ${links}
    Log To Console    EIF SFP has no destination inform and make power2=power1 so that can check conveniently
    ${link_list}    create list    'connected'    'notConnected'
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

Connect to fsp_1b
    [Arguments]    ${abil_alias}=fsp_1b    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    ${hostname}    Set Variable    fsp-1b
    ssh.Connect to    hostname=${hostname}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               proxy=${asik_alias}    alias=${abil_alias}

get cooled Transceiver Declaration status
    [Arguments]  ${sfp_info_list}
    ${status}    set variable    ${False}
    FOR    ${sfp_info}    IN    @{sfp_info_list}
        ${status}    run keyword and return status  Should Be Equal As Strings   ${sfp_info['cooled']}    True
        exit for loop if    ${status}
    END
    [Return]   ${status}

get sfp type list
    [Arguments]  ${sfp_info_list}
    ${sfp_type_list}    create list
    FOR    ${sfp_info}    IN    @{sfp_info_list}
        append to list    ${sfp_type_list}    ${sfp_info['sfp_type']}
    END
    Sort List   ${sfp_type_list}
    ${sfp_type_list}    Remove Duplicates    ${sfp_type_list}
    [Return]   ${sfp_type_list}

Get SFP Power Level Bits
    [Arguments]    ${memory_segment}=None
    ${binary_result} =	   Convert To Binary    ${memory_segment}    base=16    length=8
    @{binary_list} =    Evaluate    list('${binary_result}')
    ${power_level_high_bit} =    Get From List    ${binary_list}    2
    ${power_level_low_bit} =    Get From List    ${binary_list}    6
    ${power_level_bits} =	Catenate	SEPARATOR=    ${power_level_high_bit}    ${power_level_low_bit}
    log to console    \nHigh power level declaration is ${power_level_high_bit}, low power level declaration is ${power_level_low_bit}
    [Return]   ${power_level_bits}
