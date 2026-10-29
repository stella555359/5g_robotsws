*** Settings ***
Documentation    Author: shatang
...              \n used for quick download gNB package and auto upgrade gNb,now only support tl00

Resource    ../resources/KISS/robot/internal_upgrade.robot
Resource    ../resources/KISS/robot/common_gnb.robot
Resource    ../resources/KISS/robot/common_airphone.robot
Library    ${CURDIR}/../resources/VRF3_T05/internal_resource/python/get_gnb_package.py
Library           String

*** Test Cases ***
upgrade gnb
    ${pkg}    ${url}    ${sw_path}    Get Latest Gnb Package
    Log To Console    \r\n Latest package: ${pkg}
    Log To Console    \r\n Download url: ${url}
    Log To Console    \r\n sw_path: ${sw_path}
    Download Gnb Package    ${url}
    upgrade gnb and check status    ${pkg}    ${sw_path}

*** Keywords ***
upgrade gnb and check status
    [Arguments]    ${pkg}    ${sw_path}
    Get GNB Software Version
    Run Keyword If    "${SW_VERSION_TOTAL}" == "${pkg}"    Return From Keyword
    gnb check status
    gnb upgrade with admin     ${sw_path}
    Wait '180s' for stabible
    gnb check sw build   ${pkg}
   	Get GNB Software Version

gnb upgrade with admin
    [Arguments]    ${sw_path}
    COAM.setup admin
    ${ret}    COAM.Get Bts Statuses
    log to console    \r\n...Start Update Software...
    COAM.Update Software    ${sw_path}    should_activate=${True}     timeout=1200
    log to console    \r\n...Reset Site...
    Run Keyword And Ignore Error    COAM.Reset Site
    [Teardown]    COAM.teardown admin

gnb check sw build
    [Arguments]    ${pkg}
    COAM.setup admin
    ${swinfo}    COAM.Get Software Info
    ${ret}    evaluate    '${swinfo["Active SW version"][-10:]}'=='${pkg[-10:]}'
    run keyword if    '${ret}'!='${True}'    Fail    gnb sw version is ${swinfo["Active SW version"]}, not ${pkg}
    [Teardown]    COAM.teardown admin

Wait '${time}' for stabible
    sleep    ${time}
