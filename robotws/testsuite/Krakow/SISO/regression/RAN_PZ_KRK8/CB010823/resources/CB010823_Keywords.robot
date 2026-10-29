*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Keywords for 10823 feature tests

Library             taf.selenium.sbts    WITH NAME    selenium_sbts
Library             taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Library             on_air_tl_preparation.testline_preparation    WITH NAME    tl_prep
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            taf/rfrl/bts/robot/gnb.robot
Resource            taf/rfrl/bts/robot/common/gnb_scf.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***
Handle Startup Window
    ${window_exists}=    selenium_sbts.start_up_view_window_exists
    IF    ${window_exists} == ${True}
        selenium_sbts.close_start_up_view_window
    END

Test Setup
    Log to console    \n--Test Setup started--\n
    Wait For Site To Be Onair
    Common preconditions
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    https://192.168.255.129    Nemuadmin    nemuuser    version=${build_prefix}
    Handle Startup Window
    Log to console    \n--Test Setup done--\n
    Log to console    \n--Starting test ${TEST_NAME}--\n

Test Teardown
    Log to console    \n--Finished test ${TEST_NAME}--\n
    Log to console    \n--Test Teardown started--\n
    Common postconditions
    Run keyword and ignore error    selenium_sbts.logout
    Run keyword and ignore error    selenium_sbts.close_browser
    Run keyword and ignore error    selenium_sbts.disable_virtual_display
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    Set suite variable    ${build_prefix}    ${ENB_BUILD.split("_")[0]}
    Set suite variable    ${is_legacy_build}    ${{True if "${build_prefix}" == "SBTS24R3" else False}}
    TRY
        tl_prep.Power On All Pdu Ports
    EXCEPT
        Log to console    \n--Failed to turn on PDU ports, continuing...--\n
    END
    Perform Full Commissioning and Wait for onAir    prefix_tag=${None}    asir_hub=${True}
    Common Suite Setup
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Common Suite Teardown
    Log to console    \n--Suite Teardown done--\n

Verify values of checkpoints in RUreport
    [Arguments]    ${RUreport}    ${TriggerType}    ${RequestTime}    ${VerifyId43}=${False}

    CheckRUReport
    ...    RUreport=${RUreport}
    ...    ID=40
    ...    CheckPoint=RU SW package and NVM integrity
    ...    TriggerType=${TriggerType}
    ...    RequestTime=${request_time}
    CheckRUReport    RUreport=${RUreport}
    ...    ID=41    CheckPoint=RU Memory usage    TriggerType=${TriggerType}    RequestTime=${request_time}
    CheckRUReport    RUreport=${RUreport}
    ...    ID=42    CheckPoint=RU Temperature sensor    TriggerType=${TriggerType}    RequestTime=${request_time}

    IF    '${VerifyId43}' == '${True}'
        CheckRUReport
        ...    RUreport=${RUreport}
        ...    ID=43
        ...    CheckPoint=Extended RU DDR tests
        ...    TriggerType=${TriggerType}
        ...    RequestTime=${request_time}
    END

CheckRUReport
    [Arguments]    ${RUreport}    ${ID}    ${CheckPoint}    ${TriggerType}    ${RequestTime}
    IF    ${True}==${is_legacy_build}
        Run Keyword
        ...    Legacy_CheckRUReport
        ...    ${RUreport}
        ...    ${ID}
        ...    ${CheckPoint}
        ...    ${TriggerType}
        ...    ${RequestTime}
    ELSE
        Run Keyword    New_CheckRUReport    ${RUreport}    ${ID}    ${CheckPoint}    ${TriggerType}    ${RequestTime}
    END


New_CheckRUReport
    [Arguments]    ${RUreport}    ${ID}    ${CheckPoint}    ${TriggerType}    ${RequestTime}
    FOR    ${item}    IN    @{RUreport}
        TRY
            ${target_distinguisged_name}=    Set Variable    ${item["Target distinguished name"]}
            IF    ${{'ASIRMOD_R-1' not in '${target_distinguisged_name}'}}
                CONTINUE
            END
            IF    '${item['Check point name']}'!='${ID}'    CONTINUE
            should be true    '${item['Target distinguished name']}'=='${CheckPoint}'
            should be true    '${item['Last definitive check status']}'=='${TriggerType}'
            should be true    '${item['Execution time of last definitive status GMT+0100']}' in @{expected_execution_values}
            ${execution_time}=    Set Variable    ${item['Trigger type']}
            ${execution_time}=    parse_execution_time    ${execution_time}
            should be true    '${execution_time}'>='${RequestTime}'
        EXCEPT    .*KeyError.*    type=Regexp
            Log    \n-- KeyError: ${item} --\n    console=${True}
        END
    END

Legacy_CheckRUReport
    [Arguments]    ${RUreport}    ${ID}    ${CheckPoint}    ${TriggerType}    ${RequestTime}
    FOR    ${item}    IN    @{RUreport}
        IF    '${item['Radio module']}'!='ASIRMOD_R-1'    CONTINUE
        IF    '${item['ID']}'!='${ID}'    CONTINUE
        should be true    '${item['Check point']}'=='${CheckPoint}'
        should be true    '${item['Trigger type']}'=='${TriggerType}'
        should be true    '${item['Last execution result']}' in @{legacy_expected_execution_values}
        ${execution_time}=    Set Variable    ${item['Last execution time']}
        ${execution_time}=    legacy_parse_execution_time    ${execution_time}
        should be true    '${execution_time}'>='${request_time}'
    END

Verify diagnostic check with triggertype
    [Arguments]    ${reference_time}    ${trigger_type}
    Handle Startup Window
    ${customized_report}=    selenium_sbts.get_report
    Log to console    \n-- Output --\n
    Log to console    ${customized_report}
    Log to console    \n-- RU check report --\n
    Log to console    ${customized_report["RU diagnostic check report"]}
    Verify values of checkpoints in RUreport    RUreport=${customized_report["RU diagnostic check report"]}
    ...    TriggerType=${trigger_type}    RequestTime=${reference_time}
