*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite    ${CFGFILE_PATH}/Trunk_4AEQE_23R2_IWK_ulmimo_16UE_oldbwp.xml
#Suite Teardown     Teardown Suite
Resource          ./Resource/wts_airphone_resources.robot

*** Variables ***
${WTS_CFG}              AAA_WTS1.lua
${WTS_CFG1}              AAA_WTS2.lua
*** Test Cases ***
RTM_test_with_ap_TrafficMode0
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case for ap  wts_cfg=${WTS_CFG1}  TrafficMode=0
    [Teardown]  Teardown Case  TrafficMode=0
    Generate kpi report until success with AP  TrafficMode=0

RTM_test_with_ap_TrafficMode1
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case for ap  wts_cfg=${WTS_CFG1}  TrafficMode=1
    [Teardown]  Teardown Case   TrafficMode=1
    Generate kpi report until success with AP  TrafficMode=1

RTM_test_with_OTA_TrafficMode0
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Create Test Directory
    [Teardown]  Teardown Case for OTA   TrafficMode=0
    Generate kpi report with OTA    report_name=VRF4_SG1_Degraded_KPIs  TrafficMode=0   TrafficModeForViavi=0

RTM_test_with_OTA_TrafficMode1
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Create Test Directory
    [Teardown]  Teardown Case for OTA   TrafficMode=1
    Generate kpi report with OTA    report_name=VRF4_SG1_Degraded_KPIs  TrafficMode=0   TrafficModeForViavi=1

RTM_test_with_OTA_TrafficMode2
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Create Test Directory
    [Teardown]  Teardown Case for OTA   TrafficMode=2
    Generate kpi report with OTA    report_name=VRF4_SG1_Degraded_KPIs  TrafficMode=0   TrafficModeForViavi=2
