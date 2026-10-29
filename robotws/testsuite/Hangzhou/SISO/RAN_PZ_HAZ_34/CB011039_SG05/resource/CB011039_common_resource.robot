*** Settings ***
Documentation     author: yue liu
...               Group: HGZ_SG5
...               contact: yue.2.liu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010823/resource/CB010823_Common_KW.robot

*** Keywords ***
CB011039-5G-H_Radio_Module_online_dignostics_test_during_fail_safe_mode
    RU enter fail safe mode
    Check alarm and RMOD status fail
    Check RMOD diagnostic report
    Check RMOD customized diagnostic report
    #RU exit fail safe mode

RU enter fail safe mode
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master
    log to console    RU enter fail safe mode\n
    Connect to Common Unit Master    alias=${asik_alias}
    FOR    ${ru_index}    IN    @{test_ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
        ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
        ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
        ${cmd_temp}   Set Variable
        ...    echo "/ action create ResetControl /CI/resetControl/module /module"|${sudo} frmonShellClient localhost 2000
        ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
        Should Contain    ${output}    done ok
        sleep    2s
        ${cmd_temp}   Set Variable
        ...    echo "/CI/resetControl/module action enable_fail_safe_mode"|${sudo} frmonShellClient localhost 2000
        ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
        Should Contain    ${output}    done ok
        sleep    2s
        Perform RU Reset    ru_index=${ru_index}
    END

Check alarm and RMOD status fail
    [Arguments]      ${ru_index}=${1}
    log to console    Check alarm and RMOD status fail\n
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=2934
    FOR    ${ru_index}    IN    @{test_ru_list}
        wait until keyword succeeds    10min    30s    RU Should Be Failed     ru_index=${ru_index}
    END

RU exit fail safe mode
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master
    log to console    RU exit fail safe mode\n
    Connect to Common Unit Master    alias=${asik_alias}
    FOR    ${ru_index}    IN    @{test_ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
        ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
        ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
        ${cmd_temp}   Set Variable
        ...    echo "/ action create ResetControl /CI/resetControl/module /module"|${sudo} frmonShellClient localhost 2000
        ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
        Should Contain    ${output}    done ok
        sleep    2s
        ${cmd_temp}   Set Variable
        ...    echo "/CI/resetControl/module action disable_fail_safe_mode"|${sudo} frmonShellClient localhost 2000
        ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
        Should Contain    ${output}    done ok
        sleep    2s
        Perform RU Reset    ru_index=${ru_index}
        sleep    2s
    END
    Check alarm and RMOD status online

Check alarm and RMOD status online
    [Arguments]    ${ru_index}=1
    log to console    Check alarm and RMOD status online
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=2934
    FOR    ${ru_index}    IN    @{test_ru_list}
        wait until keyword succeeds    10min    30s    RU Should Be Online    ru_index=${ru_index}
    END

Check RMOD diagnostic report
    [Arguments]
    log to console    Check RMOD diagnostic report
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate diagnostic check    abbr=actDiagnosticCheck    new_value=true
    ${timestartTmp}   Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    sleep    3s
    log to console  \n Activate diagnostic check
    selenium_coam.start diagnostic check    scope=Full diagnostic check   timeout=600   allow_service_impact=${True}
    ${close_tag}    selenium_coam.Start Up View Window Exists    timeout=500
    Run Keyword if    ${close_tag}    selenium_coam.close start up view window
    sleep    600s
    #wait until keyword succeeds    25min    1min    Cell Should Be Enabled    cell_idx=${3}    cell_group_idx=${2}
    sleep    120s
    ${reports}    wait until keyword succeeds    3x   20s    selenium_coam.get report
    ${checkIDs}    create list   10   18   21   26   40   41   42   43
    FOR    ${report}  IN  @{reports.keys()}
        ${v}=    Get From Dictionary    ${reports}    ${report}
        log to console  \n***report key[${report}]***
        Run Keyword if   "${report}"=="RU diagnostic check report"   Check Diagnostic Report Result   reports=${v}
        ...  checkIDs=${checkIDs}  timestart=${timestart}
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    [Teardown]   Run Keyword And Ignore Error    Selenium Logout And Close Browser

Check RMOD customized diagnostic report
    log to console    Check RMOD customized diagnostic report
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${timestartTmp}   Get the real time from GNB
    ${timestart}      robot.libraries.DateTime.convert date    ${timestartTmp}    epoch
    log to console  \n Activate customized diagnostic check
    #${checkpoints}    create list   10 - Online Input Voltage on Radio Module    18 - Radio Module Temperature Supervision
    #...    21 - Radio Module ethernet link   26 - Radio Module FAN    40 - RU SW package and NVM integrity
    #...    41 - RU Memory usage   42 - RU Temperature sensor
    #...    43 - Extended RU DDR tests (RST)
    #&{radio_checkpoints}   create dictionary   RMOD-1 / RMOD_R-1 (AEQE)=${checkpoints}
    #selenium_coam.start diagnostic check    scope=Customized diagnostic check   radio_checkpoints=${radio_checkpoints}
    #...    timeout=600
    selenium_coam.start diagnostic check    scope=Customized diagnostic check    timeout=900
    ${close_tag}    selenium_coam.Start Up View Window Exists    timeout=500
    Run Keyword if    ${close_tag}    selenium_coam.close start up view window
    sleep    600s
    sleep    120s
    ${reports}    wait until keyword succeeds    3x   20s    selenium_coam.get report
    ${checkIDs}    create list   10   18   21   26   40   41   42   43
    FOR    ${report}  IN  @{reports.keys()}
        ${v}=    Get From Dictionary    ${reports}    ${report}
        log to console  \n***report key[${report}]***
        Run Keyword if   "${report}"=="RU diagnostic check report"   Check Diagnostic Report Result   reports=${v}
        ...  checkIDs=${checkIDs}  timestart=${timestart}
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    [Teardown]   Run Keyword And Ignore Error    Selenium Logout And Close Browser

Get test RU index
    #[Arguments]    ${connection}=GNB_OAM
    log to console    get AEQY or AEQE ru index
    @{test_ru_list}    Create list
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
        ${ru_type}   set variable  ${ru_info}[productName]
        Run keyword if    '${ru_type}'=='AEQY' or '${ru_type}'=='AEQE'    Append To List    ${test_ru_list}    ${ru_index}
    END
    Set suite variable    @{test_ru_list}
    [Return]    @{test_ru_list}

RU Should Be Failed
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    failed
    ...  msg=Current RU administrativeState is not in failed status
    Should be equal as strings    ${ru_status['status']['operationalState']}       disabled
    ...  msg=Current RU operationalState is not in disabled status
