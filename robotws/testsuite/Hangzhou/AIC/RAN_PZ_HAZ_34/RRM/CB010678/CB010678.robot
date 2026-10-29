*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite
Suite Teardown      Teardown Suite
Resource          Resource/CB010678_Resources.robot

*** Test Cases ***
Test VDU rannic reset
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Test VDU rannic reset

Test VDU cell lock unlock
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Test VDU cells lock unlock

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Test VDU cell block unblock

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Test VDU Reset

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Test RUs lock_unlock

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case
    [Teardown]  Teardown case
    TC.Test VDU RUs reset

Test 1N pod none critical container OAMASM failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMASM
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container OAMASM failure

Test 1N pod none critical container OAMCM failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMCM
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container OAMCM failure



Test 1N pod none critical container OAMCONFIG trsconfig failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMCONFIG trsconfig
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container OAMCONFIG trsconfig failure

Test 1N pod none critical container OAMCONFIG tas failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMCONFIG tas
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container OAMCONFIG tas failure

Test 1N pod none critical container OAMCONFIG ims failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMCONFIG ims
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container OAMCONFIG ims failure

Test 1N pod none critical container L2RT failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case L2RT
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container L2RT failure

Test 1N pod none critical container L2HI failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case L2HI
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container L2HI failure

#Test 1N pod critical container OAMEXT oamagent failure
#    [Documentation]
#    [Tags]    CRT_TRUNK
#    [Setup]    Setup case OAMEXT oamagent
#    #[Teardown]  Teardown case
#    TC.Test 1N pod critical container OAMEXT oamagent failure

Test 1N pod critical container OAMBB failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMBB
    [Teardown]  Teardown case
    TC.Test 1N pod critical container OAMBB failure

Test 1N pod critical container AHM l1commproxy failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case AHM l1commproxy
    [Teardown]  Teardown case
    TC.Test 1N pod critical container AHM l1commproxy failure


Test 1N pod none critical container OAMCONFIG cpconfig failure
    [Documentation]
    [Tags]    CRT_TRUNK
    [Setup]    Setup case OAMCONFIG cpconfig
    [Teardown]  Teardown case
    TC.Test 1N pod none critical container OAMCONFIG cpconfig failure