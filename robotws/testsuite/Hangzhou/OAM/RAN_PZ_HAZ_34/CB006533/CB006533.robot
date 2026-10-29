*** Settings ***
Documentation     author:sky
...               contact:skymei
...               squad group: SG_01
...               feature : CB006533
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Force Tags
...    PY36
Resource          ../CB006533/Resources/CB006533_Resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
*** Test Cases ***
SiteReset
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.SiteResetWithRetry    retry_times=2

BBReset
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.BBMODResetOneByOneWithRetry    retry_times=2

RFReset
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.RFResetOneByOneWithRetry    retry_times=2

[1]CB006533-SR_01_RU_detection_with_eCPRI_MPlane_IPv6_address
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006533-SR_01_RU_detection_with_eCPRI_MPlane_IPv6_address

[1]CB006533-SR_31_eCPRI_MPlane_IP_version_migration
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006533-SR_31_eCPRI_MPlane_IP_version_migration

[1]CB006533-SR_02_Basic_Operability_regression
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.CB006533-SR_02_Basic_Operability_regression

IPV6Check
    [Setup]    SetUp Case
    [Teardown]  Teardown case
    TC.IPV6Check

*** Keywords ***
Suite Setup
    Run Keywords    TestSuite.Start    AND    Suite setup for 6533

Suite Teardown
    TestSuilt.Stop
