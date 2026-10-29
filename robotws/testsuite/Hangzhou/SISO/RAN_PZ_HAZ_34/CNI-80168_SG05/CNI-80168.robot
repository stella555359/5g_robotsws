*** Settings ***
Suite Setup          SISO Coam Suite setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables   Variable/variable_CNI-80168.py
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    Resource/CNI-80168_Common_KW.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/excel_chart.py

Documentation
...    Author:liu yue
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CNI-80168 in SBTS23R1 program

Force Tags   5G_RAN    5G_RAN_TDD


*** Test Cases ***
[1]CNI-80168_AQQL_005_Alarm_Major_Antenna_Calibration_Error_TX2922_RX2923
    Mute pipe on RU to trigger fault 2292
    sleep    60min
    ${severity}    Get alarm severity
    Run Keyword If    '${severity}' != 'None'
    ...    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=2922    severity=${severity}
    Should Not Be Equal    ${severity}    None
    ${cells_info}   coam.get_cells_info  cell_type=nr    timeout=20    connection=GNB_OAM
    FOR    ${cell}    IN    @{cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
    END
    Perform RU Reset
    sleep    2min
    Wait until keyword succeeds    10min    10 sec   verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=2922
    [Teardown]    selenium logout and close browser

#[1]CNI-80168_AQQL_004_Alarm_Minor_Antenna_Calibration_Error_TX2922_RX2923
#    Mute pipe on RU to trigger fault 2292 minor
#    sleep    60min
#    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=2922    severity=Minor
#    Perform RU Reset
#    sleep    2min
#    Wait until keyword succeeds    10min    10 sec   verify all cells should be onair
#    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=2922
#    [Teardown]    selenium logout and close browser
