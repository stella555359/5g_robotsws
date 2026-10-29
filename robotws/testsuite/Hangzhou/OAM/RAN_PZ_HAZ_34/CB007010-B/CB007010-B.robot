*** Settings ***
Documentation      author: Shuhui Lou
...                 contact: shuhui.lou@nokia-sbell.com
...                This robot file is for cb007010.

Suite Setup       KW.Setup Suite
Suite Teardown    KW.Teardown Suite
Force Tags               SG_01   5G_RAN
Resource           ./Resource/CB007010-B_resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB008181_SR_A_07_CM_Delta_Plan_Provision_Operation_No_Service_Outage
    [Documentation]
    [Tags]     CRT_TRUNK
    [Setup]    KW.Setup case
    [Teardown]  KW.Teardown case
    TC.CB008181_SR_A_07_CM_Delta_Plan_Provision_Operation_No_Service_Outage