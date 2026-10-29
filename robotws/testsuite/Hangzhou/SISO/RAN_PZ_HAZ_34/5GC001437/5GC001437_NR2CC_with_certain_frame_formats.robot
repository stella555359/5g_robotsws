*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot


*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
#${if_commissioning}   False

*** Test Cases ***
[1][1.0] 5GC001437_NR2CC_with_certain_frame_formats
    [Documentation]    check NR2CC with certain frame formats BFC stat
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    \n checking BFC stat....
    check_BFC_stat_on_RU
    log to console    \n end.
    [Teardown]    SISO Coam Test Teardown


*** Keywords ***
check_BFC_stat_on_RU
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}

    ${check_cmd}    Set Variable    bfcali -stat|grep "Calibration attempts"
    log to console    \n *** check_cmd is ${check_cmd} ***
    csn.send_command    command=${check_cmd}    connection=RU_${ru_index}
    ${readOutput}=     csn.readOutput    connection=RU_${ru_index}
    log to console    \n *** readoutput is ${readoutput} ***
    @{lines} =	Split To Lines	${readoutput}
    ${line_num}    get length    {lines}
    FOR    ${index}    IN RANGE    ${line_num}
        log to console    \n *** line ${index} is ${lines}] ***
    END
    [Teardown]    run keywords   run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}    AND
    ...                          run keyword and ignore error    csn.disconnect    connection=ASIK Master


