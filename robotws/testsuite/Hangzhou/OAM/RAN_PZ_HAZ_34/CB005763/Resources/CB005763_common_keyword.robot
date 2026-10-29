*** Settings ***
Documentation      author: Shi Jeffrey
...                contact: jeffrey.shi@nokia-sbell.com
...                This robot file is for CB005763

Resource   ../../../../resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library    taf.collectors.core   WITH NAME   core
Library    taf.sbts.oam.coam.admin  WITH NAME   admin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.selenium.sbts   WITH NAME   selenium_sbts
Library    taf.transport.ssh   WITH NAME   csn

*** Keywords ***
Power_off_radio
    [Arguments]    ${ru_index}=8
    log to console    try to power off radio
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    3 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}

Power_on_radio
    [Arguments]    ${ru_index}=8
    log to console    try to power on radio
    Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}

check_fault_addition_information
    [Arguments]    ${match_key}=RU power loss
    log to console    check fault 10 include message 'RU power loss'
    Wait Until Keyword Succeeds    2min    30s    Connect to gnb coam via ssl    connection=FID10
    ${alarms_info}=    admin.get_active_alarms    severity=critical    connection=FID10
    FOR  ${alarm}    IN    @{alarms_info}
        IF    '${alarm['faultId']}'=='10'
            log to console    find fault 10
            should contain    ${alarm['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']}    ${match_key}    ignore_case=True
            Exit For Loop
        END
    END
    [Teardown]    admin.teardown    connection=FID10
