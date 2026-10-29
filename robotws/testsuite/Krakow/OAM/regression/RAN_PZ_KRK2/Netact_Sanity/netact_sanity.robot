*** Settings ***
Documentation
...    Author: Barbara Wozniak, barbara.wozniak@nokia.com
...    Maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...    Sanity tests to verify NetAct integration with MRBTS and ASI.

Resource    ./resources/keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown

*** Test Cases ***
[1][1.0] Test_cases_MRBTS_integrate
    [Tags]    integrate
    [Setup]    Common Preconditions
    Should Be Equal    ${integration_mrbts_result}    PASS
    [Teardown]    Common Postconditions

[1][1.0] Test_cases_ASI_integrate
    [Tags]    integrate
    [Setup]    Common Preconditions
    Should Be Equal    ${integration_asir_result}    PASS
    [Teardown]    Common Postconditions

[1][1.0] Test_cases_alarm_upload_MRBTS
    [Setup]    Run Keywords    Test Setup    service_name=fmwas
    ...        AND             Block Cell
    Alarm Upload For MRBTS
    [Teardown]    Run Keywords    Unblock Cell
    ...           AND             Test Teardown    service_name=fmwas

[1][1.0] Test_cases_alarm_upload_ASIR
    [Setup]    Run Keywords    Test Setup    service_name=fmwas
    ...        AND             Block ANTMOD
    Alarm Upload For ASI
    [Teardown]    Run Keywords    Unblock ANTMOD
    ...           AND             Test Teardown    service_name=fmwas

[1][1.0] Test_cases_cm_upload_MRBTS
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Delete EQM From Configuration
    Upload MRBTS Configuration And Verify
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] Test_cases_cm_upload_ASIR
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Delete ANTMOD From Configuration
    Upload ASI Configuration And Verify
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] Test_cases_cm_provision
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Check Configuration
    Provision New Configuration Plan With MRBTS Name
    [Teardown]    Run keywords    Restore MRBTS Name
    ...           AND             Test Teardown    service_names=cmwas

[1][1.0] Test_cases_reset_ant
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Upload ASI Configuration
    ...        AND             Delete HWResetReq Objects
    Provision New Configuration Plan To Reset Ant
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] Test_cases_reset_hub
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Upload ASI Configuration
    ...        AND             Delete HWResetReq Objects
    Provision New Configuration Plan To Reset Hub
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] Test_cases_sw_upload
    [Tags]  upload
    [Setup]    Test Setup    service_name=cmwas
    Upload SW Version
    [Teardown]    Test Teardown    service_names=cmwas

Sw_Upgrade_Sw_Rollback
    [Tags]    uuf
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...                                      check_sw=${False}
    ...        AND             Import Build To Upgrade
    ...        AND             Rollback SW If Needed
    ...        AND             Set Reporting Portal Variables
    Run UUF Loop
    [Teardown]    Test Teardown    service_names=cmwas

[1][1.0] Test_cases_sw_upgrade
    [Tags]    uuf
    [Setup]    Common Preconditions
    Should Be Equal    ${UPGRADE_RESULT}    PASS
    [Teardown]    Common Postconditions

[1][1.0] Test_cases_sw_rollback
    [Tags]    uuf
    [Setup]    Common Preconditions
    Should Be Equal    ${ROLLBACK_RESULT}    PASS
    [Teardown]    Common Postconditions
