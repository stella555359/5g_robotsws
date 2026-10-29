*** Settings ***
Documentation      author: Shuhui Lou
...                 contact: shuhui.lou@nokia-sbell.com
...                This robot file is for cb007010-D.

Suite Setup       Suite setup for 2479
Suite Teardown    Teardown Suite
Force Tags
...    PY36
Resource          ../5GC002479/Resources/5GC002479_Resouce.robot
Resource           ../CB007010-B/Resource/CB007010-B_resource.robot

*** Test Cases ***
[1]5GC002479_HJ_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Dual_Core
    [Documentation]     KPI1A
    [Tags]     CRT_TRUNK
    [Setup]    run keywords  KW.Setup case  AND  SetUp Case
    [Teardown]  run keywords    Teardown case    AND    KW.Teardown case
    ONAP.start VES simulator and netopeer2
    sleep    2min
    AlarmWatchdog.remove_allow_alarms    fault_id=4639
    TC.GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core

*** Keywords ***
Suite setup for 2479
    kw.suite setup for 2479

Teardown Suite
     5GC002479_Resouce.kw.teardown suite

