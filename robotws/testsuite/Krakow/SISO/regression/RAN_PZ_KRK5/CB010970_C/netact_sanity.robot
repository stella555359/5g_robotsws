*** Settings ***
Documentation
...    Maintainer: Piotr Siedlak, piotr.siedlak@nokia.com
...    Author: Barbara Wozniak, barbara.wozniak@nokia.com
...    Suite based on sanity tests to verify NetAct integration with MRBTS and ASI from VRF_KRK_T02.

Resource    ./resources/keywords.robot

Suite Setup       keywords.Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...               swconfig_from_path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010970_C/resources/swconfig.txt
Suite Teardown      Suite Teardown

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}      61673    61675

*** Test Cases ***
Cm_Upload_Asir
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Delete ANTMOD From Configuration
    Upload ASI Configuration And Verify
    [Teardown]    Test Teardown    service_names=cmwas

Cm_Provision
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Check Configuration
    Provision New Configuration Plan With MRBTS Name
    [Teardown]    Run keywords    Restore MRBTS Name
    ...           AND             Test Teardown    service_names=cmwas

Reset_Hub
    [Setup]    Run Keywords    Test Setup    service_name=cmwas
    ...        AND             Upload ASI Configuration
    ...        AND             Delete HWResetReq Objects
    Provision New Configuration Plan To Reset Hub
    [Teardown]    Test Teardown    service_names=cmwas
