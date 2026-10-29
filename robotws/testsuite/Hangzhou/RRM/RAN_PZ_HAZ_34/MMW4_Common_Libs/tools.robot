*** Settings ***
Documentation     Author: debbie.wang@nokia-sbell.com
...               always used tools in TA

Resource       login_logout.robot

*** Keywords ***
Send traffic from testcenter
    [Documentation]    use testcenter to start traffic
    [Arguments]     ${hostname}    ${connection}    ${testcenter_tclfile}    ${username}=ute    ${password}=ute    ${alias}=test_pc
    Login BaseStation By Ssh    hostname=${hostname}    username=${username}    password=${password}    alias=${alias}
    csn.send command    command=sudo tclsh ${testcenter_tclfile}    connection=${connection}
    [Teardown]    Disconnect Any SSH    connection=${connection}
