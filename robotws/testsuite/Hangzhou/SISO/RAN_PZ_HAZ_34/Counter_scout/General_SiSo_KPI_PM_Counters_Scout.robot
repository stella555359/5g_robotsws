*** Settings ***
Suite Setup          SISO Coam Suite Setup
#Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         230 min

Resource    ./resource/scout_counter_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
#Variables   ./TestData/variables.py
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature 25R3 EDA Action Task For 04330985

Force Tags    RAN_5G_TDD
...    PY36

*** Test Cases ***
[1]General_SiSo_KPI_compare_counter_Scout
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    run keyword if    '${stream}'=='SBTS26R1'    Perform SW rollback and check cells onAir
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    wait.wait_until_next_quarter
    ...                                             return_with_timezone=${False}
    Selenium Login And Disable Screen Lock
    ${TL_Name}=    selenium_coam.get_bts_name
    log to console    testline name is ${TL_Name}
    Selenium Logout And Close Browser
    ${first_time}    Export couter start and end datetime
    wait.wait_until_next_hour
    sleep    20min
    Perform SW rollback and check cells onAir
    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    sleep    10s
    ${second_time}    Export couter start and end datetime
    wait.wait_until_next_hour
    sleep    20min
    ${report}    Generate KPI Compare Report through scout    scout_tl=${TL_Name}
    ...    template_id=${1248}
    ...    report_name=TA_Scout_KPI_compare_report
    ...    first_start_time=${first_time}[0]
    ...    first_end_time=${first_time}[1]
    ...    second_start_time=${second_time}[0]
    ...    second_end_time=${second_time}[1]
    ...    second_period_description=${Active_SW_version}
    ${report_id}=    get_comparator_report_id    data=${report}
    timer.wait_until_keyword_succeeds_timer         5min
    ...                                             15s
    ...                                             Validate Scout Report Is Ready
    ...                                             report_id=${report_id}
    scout_comparator.validate_report                report_id=${report_id}
    [Teardown]    Selenium Logout And Close Browser