*** Settings ***
Documentation
...    Author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...    Maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...    Tests to verify ASiR FP package.

Resource    ./resources/keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown

*** Test Cases ***
[1][1.0] TC02_ASIR_NetAct_FP_Integration
    [Tags]    integrate
    Should Be Equal    ${integration_asir_result}    PASS

[1][1.0] TC03_ASIR_NetAct_FP_CM_Upload
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Delete ANTMOD From Configuration
    Upload ASI Configuration And Verify
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] TC05_ASIR_NetAct_FP_Alarm_Upload
    [Setup]    Run Keywords    Test Setup    service_name=fmwas
    ...        AND             Block ANTMOD
    Alarm Upload For ASI
    [Teardown]    Run Keywords    Unblock ANTMOD
    ...           AND             Test Teardown    service_name=fmwas

[1][1.0] TC07_ASIR_NetAct_FP_Reset_ASIR_Hub_from_Netact_when_TLS_Force
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Upload ASI Configuration
    ...        AND             Delete HWResetReq Objects
    Provision New Configuration Plan To Reset Hub
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] TC08_ASIR_NetAct_FP_CM_Plan_Provisioning
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Check Configuration
    Provision New Configuration Plan With MRBTS Name
    [Teardown]    Run keywords    Restore MRBTS Name
    ...           AND             Test Teardown    service_names=cmwas

[1][1.0] TC09_ASIR_NetAct_FP_HWRESETRES
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Upload ASI Configuration
    ...        AND             Delete HWResetReq Objects
    Provision New Configuration Plan To Reset Ant
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] TC10_ASIR_NetAct_FP_Alarm_Lifting
    [Tags]    alarm_lifting
    [Setup]    Test Setup    service_name=fmwas
    Alarm Lifting
    [Teardown]    Delete Node and Alias    service_names=fmwas

[1][1.0] TC11_ASIR_NetAct_FP_Alarm_Cancel_from_NE
    [Tags]    alarm_lifting
    [Setup]    Run Keywords    Set Test Variable    @{allowed_alarms}   @{CUSTOM_ALLOWED_ALARMS}
    ...        AND    Add Node And Check SW   service_name=fmwas   check_sw=${True}
    Alarm Cancel from NE
    [Teardown]    Test Teardown    service_names=fmwas

[1][1.0] TC12_ASIR_NetAct_FP_SWM_Upload
    [Tags]  upload
    [Setup]    Test Setup    service_name=cmwas
    Upload SW Version
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] TC01_ASIR_NetAct_FP_Deintegration
    [Tags]    integrate
    [Setup]    Add Node And Check SW    service_name=fmwas    check_sw=${True}
    Deintegrate ASI
    Should Be Equal    ${deintegration_asir_result}    PASS
    [Teardown]    Delete Node and Alias    service_names=fmwas

Sw_Upgrade_Sw_Rollback
    [Tags]    uuf
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...                                      check_sw=${False}
    ...        AND             Import Build To Upgrade
    ...        AND             Rollback SW If Needed
    ...        AND             Set Reporting Portal Variables
    Run UUF Loop
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] TC13_ASIR_NetAct_FP_SWM_Provsion
    [Tags]    integrate
    Should Be Equal    ${UPGRADE_RESULT}    PASS

[1][1.0] TC14_ASIR_NetAct_FP_SWM_Rollback
    [Tags]    integrate
    Should Be Equal    ${ROLLBACK_RESULT}    PASS
