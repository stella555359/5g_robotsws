*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***

*** Keywords ***
General_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] If set to false, the session enters the "Down" state. Only control messages with state
    ...    "Admin Down" are sent to the peer. All active alarms of the BFD session are cleared.If set to true, the session
    ...    leaves the "Down" state. It will reach the "Up" state if the remote peer is also in "Up" state.
    ...    If the BFD session fails, alarms are raised for it.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.07.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${iface}=eth2.s0.m0.1    ${bfd_session}=BFD-1
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console   \n down ${iface} in ru_${ru_index}
    operate interface in ru    ru_index=${ru_index}    interface=${iface}    operate=down
    log to console   \n Check Fault 61605 appear in WebUI
    Wait until keyword succeeds    3min    30s    Expect Fault Should Present
    ...    faultId=61605    configObjectName=${bfd_session}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-2/IPAPP-1/${bfd_session}
    ...    filter_param=BFD session admin down state control    abbr=bfdAdminUp    new_value=false
    log to console   \n Check Fault 61605 disappear in WebUI
    Wait until keyword succeeds    3min    30s    Expect Fault Should Absent    faultId=61605
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-2/IPAPP-1/${bfd_session}
    ...    filter_param=BFD session admin down state control    abbr=bfdAdminUp    new_value=true
    log to console   \n Check Fault 61605 appear in WebUI
    Wait until keyword succeeds    3min    30s    Expect Fault Should Present
    ...    faultId=61605    configObjectName=${bfd_session}
    log to console   \n up ${iface} in ru_${ru_index}
    operate interface in ru    ru_index=${ru_index}    interface=${iface}    operate=up
    log to console   \n Check Fault 61605 disappear in WebUI
    Wait until keyword succeeds    3min    30s    Expect Fault Should Absent    faultId=61605
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
