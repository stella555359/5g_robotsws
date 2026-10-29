*** Settings ***
Documentation    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    History: Do some adaption for CB008681
...    feature : CB009402 calculate KPI base on IMS
Suite Setup          TestSuite_setup_withIMS
Suite Teardown       TestSuite_teardown_withIMS
Force Tags        CRT_24R1
Resource           Resource/CB009402_Common_KW.robot
Resource           ../CB008681_ASIL/Resources/OMKPI_KW_interface.robot
*** Test Cases ***
CB009402-SR-C-16-Manual_remote_power_reset_downtime_KPI#11
    [Documentation]    KPI11
    [Tags]     CRT_24R1
    [Setup]    SISO Coam Test Setup
    [Teardown]  SISO Coam Test Teardown
    ${KPI11_MAX}=    Set Variable    ${KPI['KPI11']['KPI11_MAX']}
    ${KPI11_AVG}=    Set Variable    ${KPI['KPI11']['KPI11_AVG']}
    set test variable    ${KPI11_AVG}
    set test variable    ${KPI11_MAX}
    set test variable     ${KPI_intotall}    0
    OAM_KPI_11_remote_power_reset_downtime_IMS    WebUI_reset_times=${KPI['KPI11']['reset_times']}

CB009402-SR-C-18-Manual_capacity_module_power_reset_KPI#14
    [Documentation]    KPI11
    [Tags]     CRT_24R1
    [Setup]    SISO Coam Test Setup
    [Teardown]  SISO Coam Test Teardown
    ${KPI14_MAX}=    Set Variable    ${KPI['KPI14']['KPI_MAX']}
    ${KPI14_AVG}=    Set Variable    ${KPI['KPI14']['KPI_AVG']}
    set test variable    ${KPI14_AVG}
    set test variable    ${KPI14_MAX}
    set test variable     ${KPI_intotall}    0
    FOR    ${bbmod}    IN    @{KPI['KPI14']['BBMOD_list']}
        OAM_KPI_14_capacity_module_power_reset_IMS    WebUI_reset_times=${KPI['KPI14']['reset_times']}
        ...    baseband_unit=${bbmod}
    END
*** Keywords ***
