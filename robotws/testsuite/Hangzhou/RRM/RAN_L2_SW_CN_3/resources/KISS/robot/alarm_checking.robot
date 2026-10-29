*** Settings ***
Documentation    This is for alarm checking, it's focus on rest api
...              Please do not modify the file without notification to author
...              Author:
...              Squard: H
Library    String
Library    OperatingSystem
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    oam_coam



*** Variables ***
${trunk_rolll_needed}    ${True}

*** Keywords ***
Check Alarm and stop robot testing when unexpected alarm raised
    run keyword and ignore error    run keyword if    ${trunk_rolll_needed}    _Check alarm and raised fatal error

_Check alarm and raised fatal error
    [Arguments]  ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=Trunk_roll_check
    ${bts_host}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${username}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ${password}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${gnb_oam_ip}  set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    run keyword if    '${bts_host}' != ''    oam_coam.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}
    ...    ELSE    oam_coam.connect_to
    ...    bts_host=${gnb_oam_ip}    name=${connection}    username=Nemuadmin    password=nemuuser
    @{truck_roll_fault}    Create List    ${10}    ${1806}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}
    FOR   ${active_alarm}    IN   @{active_alarms}
            ${roll}    run keyword and return status    Collections.List Should not Contain Value    ${truck_roll_fault}    ${active_alarm['faultId']}
            run keyword if    not ${roll}
            ...    fatal error    msg=Fault ${active_alarm['faultId']}, possible truck roll issue, case failed!!!!!
    END
    [Teardown]  coam.teardown    connection=${connection}

