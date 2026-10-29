*** Settings ***
Documentation      author: Lixia Wang
...                 contact: lixia.wang@nokia-sbell.com
...                This robot file is for CB008502-A feature

Suite Setup          SuiteSetup
Suite Teardown       SuiteTearDown

Force Tags           SG_01   5G_RAN
Resource           Resource/CB008502_Resource.robot
Resource           ../5GC002479/Resources/5GC002479_CP_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB008502_01_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_25_eCPRI
    [Documentation]     This test case describes the Fronthaul Ethernet data rate(25G) detection and selection during BTS Deployment phase.
    ...               SFP28 must be used at both ends of the same optical link.
    [Tags]
    [Setup]    CB008502 Test Setup
    [Teardown]  CB008502 Test Teardown
    KW.CB008502_01_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_25_eCPRI

[1]CB008502_02_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
    [Documentation]     This test case describes the Fronthaul Ethernet data rate(10G) detection and selection during BTS Deployment phase.
    ...               SFP28 must be used at both ends of the same optical link.
    [Tags]
    [Setup]    CB008502 Test Setup
    [Teardown]  CB008502 Test Teardown
    KW.CB008502_02_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI

[1]CB008502_04_Ethernet_mode_reconfiguration_during_BTS_runtime
    [Documentation]     This case is to test ecpri data rate detection during SBTS runtime. Link speed is changeing between 25G and 10G
    ...               SFP28 must be used at both ends of the same optical link.
    [Tags]
    [Setup]    CB008502 Test Setup
    [Teardown]  CB008502 Test Teardown
    KW.CB008502_04_Ethernet_mode_reconfiguration_during_BTS_runtime