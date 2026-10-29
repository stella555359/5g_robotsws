*** Settings ***
Documentation    CI interface keywords, trigger all CI related step keyword.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info

*** Variables ***
${trunk_rolll_needed}    ${True}

*** Keywords ***
Check Alarm and stop robot testing when unexpected alarm raised
    run keyword and ignore error    run keyword if    ${trunk_rolll_needed}    __Check alarm and raised fatal error


__Check alarm and raised fatal error
    ${check_result}    Run keyword and return status
    ...    Wait Until Keyword Succeeds    5 min    30 s    __Check alarm and raise error
    run keyword if    not ${check_result}    fatal error    msg=Fault ${active_alarm['faultId']}, possible truck roll issue, case failed!!!!!

__Check alarm and raise error
    [Arguments]  ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=Trunk_roll_check
    Log    Use this only for pipeline to pas ${gnb_index}
    ${has_enb}    testline_info.has_enb    ${tl}
    ${enb_oam_ip}    run keyword if    ${has_enb}    set variable if    ${tl.enbs[${enb_index}].airscale}
    ...    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}    ${tl.enbs[${enb_index}].oam_ip.v4}
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    @{truck_roll_fault}    Create List    ${10}    ${1806}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${roll}    run keyword and return status    Collections.List Should not Contain Value    ${truck_roll_fault}    ${active_alarm['faultId']}
        run keyword if    not ${roll}
        ...    fail
    END
    [Teardown]  coam.teardown    connection=${connection}
