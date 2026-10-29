*** Settings ***
Library    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener_vran/ListenerCloud.py
...    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener_vran/default_template_vcu.yaml
...    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener_vran/default_template_vdu.yaml    15min

Documentation
...            author:       Bartosz Szlezak, bartosz.szlezak@nokia.com
...            maintainer:   Bartosz Szlezak, bartosz.szlezak@nokia.com

Resource   ../krk3_common/main_vran.robot

Suite Setup       Testline Setup    reach_on_air=yes
Suite Teardown    Testline Teardown
Test Setup        Test Case Setup    reach_on_air=no

*** Test Cases ***
PM_Analyze_Listener_VRAN_demo
    Start SA L3 Call    ue_id=1
    Sleep    60s
    Stop SA L3 Call    ue_id=1

