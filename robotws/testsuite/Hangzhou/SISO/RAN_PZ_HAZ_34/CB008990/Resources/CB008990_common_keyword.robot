*** Settings ***
Variables    ../TestData/variable_8990.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

Documentation
...    author: jiangjing lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Keywords ***
RU_Reset_8990
     FOR   ${index}   IN RANGE   0    30
         log to console    reset all rus....
         Reset All Rus
         Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
     END

RU_Lock_Unlock_8990
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    FOR   ${index}   IN RANGE   0    30
        log to console    lock ru1
        Wait Until keyword Succeeds    3x    10s    selenium_coam.lock_ru    ru_index=${1}
        sleep    5s
#        run keyword and ignore error    Selenium Logout And Close Browser
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
        log to console    unlock ru1
#        Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
        Wait Until keyword Succeeds    3x    10s    selenium_coam.unlock_ru    ru_index=${1}
        sleep    5s
#        run keyword and ignore error    Selenium Logout And Close Browser
        wait until keyword succeeds  5min  20sec  RU Should Be Unlocked
        Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
        ${ru_index_list}  Get All RU Index
        Get X2 link shutdown waiting time
        log to console    lock all rus
#        Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
        run keyword and ignore error    COAM Teardown gnb connections
        Lock and Unlock all RUs    lock_list=${ru_index_list}
    END
    [Teardown]    run keywords    run keyword and ignore error    Unlock all RUs and check status
    ...    ru_index_list=${ru_index_list}    check_alarm=${False}    gnb_type=${gNb_CuType}    AND
    ...    run keyword and ignore error    Selenium Logout And Close Browser

Reset All Rus
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RF Module Reset from GUI    ru_index=${ru_index}
    END

DFE-DFE_link_fault_activation
    [Arguments]    ${ru_index}=${1}
    log to console    import 60M config1 scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    Commissioning SCF And Check On Air      scf_path=${SCF_upload}
    log to console    use root accout to login RU1
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    log to console    execute    '/ action create CPRIPortControl /CPRIPortControl'
    ${cmd}    Set Variable    echo "/ action create CPRIPortControl /CPRIPortControl"|frmonShellClient 127.0.0.1 2000
    ${output}    csn.execute    command=${cmd}    connection=RU
    sleep    2s
    log to console    execute    '/CPRIPortControl action disable 3'
    ${cmd}   Set Variable    echo '/CPRIPortControl action disable 3'|frmonShellClient 127.0.0.1 2000
    ${output}    csn.execute    command=${cmd}    connection=RU
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    check fault 1981 reported
    Wait Until Keyword Succeeds   1min    2s    Expect Fault Should Present    faultId=1904
    log to console    check Operational state of RU1 changed to disabled
    Wait until keyword succeeds    5min    5s    check ru operational state    expect_state=disabled    ru_index=${ru_index}
    log to console    check fault 1981 disappeared
    Wait Until Keyword Succeeds   5min   2s    Expect Fault Should Absent    faultId=1904
    log to console    check Operational state of RU1 recovery to enabled
    Wait Until Keyword Succeeds   10min   5s    check ru operational state    expect_state=enabled    ru_index=${ru_index}
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master

DFE no TX Data fault activation
    [Arguments]    ${ru_index}=${1}
    log to console    import 60M config1 scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _PureNR_80_60_30.xml
    Commissioning SCF And Check On Air      scf_path=${SCF_upload}
    log to console    use root accout to login RU1
    Connect to Common Unit Master
    Connect to RU With Allocated IP
    log to console    execute    '/ action create CarrierFaultInjection /DEFNOTX'
    ${cmd}    Set Variable    echo "/ action create CarrierFaultInjection /DEFNOTX"|frmonShellClient 127.0.0.1 2000
    ${output}    csn.execute    command=${cmd}    connection=RU
    sleep    2s
    log to console    execute    '/DEFNOTX action break_tx_data_transmission "NR958.TX1_1_1" "antenna1a"'
    ${cmd}   Set Variable    echo '/DEFNOTX action break_tx_data_transmission "NR958.TX1_1_1" "antenna1a"'|frmonShellClient 127.0.0.1 2000
    ${output}    csn.execute    command=${cmd}    connection=RU
    Should Contain    ${output}    done ok
    sleep    2s
    log to console    check fault 1981 reported
    Wait Until Keyword Succeeds   3min    2s    Expect Fault Should Present    faultId=1981
    log to console    check Operational state of RU1 changed to disabled
    Wait until keyword succeeds    5min    5s    check ru operational state    expect_state=disabled    ru_index=${ru_index}
    log to console    check fault 1981 disappeared
    Wait Until Keyword Succeeds   5min   2s    Expect Fault Should Absent    faultId=1981
    log to console    check Operational state of RU1 recovery to enabled
    Wait Until Keyword Succeeds   10min   5s    check ru operational state    expect_state=enabled    ru_index=${ru_index}
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master

check ru operational state
    [Arguments]    ${expect_state}    ${ru_index}
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    @{RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    FOR    ${RU}    IN    @{RUs}
        ${config_rmod}    Set variable    ${RU['id']['configuration']}
        log to console    ${config_rmod}
        ${rmod_index}    Fetch from right    ${config_rmod}    RMOD-
        log to console    ${rmod_index}
        run keyword if     '${rmod_index}' != '${ru_index}'    continue for loop
        run keywords    Should be equal as strings    ${RU['status']['operationalState']}    ${expect_state}    AND    exit for loop
    END
