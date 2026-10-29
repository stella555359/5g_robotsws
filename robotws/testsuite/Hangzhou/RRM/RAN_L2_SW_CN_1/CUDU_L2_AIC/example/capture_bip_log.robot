*** Settings ***
Resource          ../common_aic_setup_teardown.robot
Force Tags        CONFIGS_7_5_UTE5GAIC015/test_config.yaml
Suite Setup       Run Keywords    Common Suite Setup
Suite Teardown    Common Suite Teardown    debug
Test Setup        Create Test Directory
Test Teardown     Common Test Teardown    debug

*** Variables ***


*** Test Cases ***
L1BIPRT_bip_log
    Start BIP Log    L1BIPRT
    Sleep    4s
    Stop BIP Log    L1BIPRT

L2BIPRT_bip_log
    Start BIP Log    L2BIPRT
    Sleep    6s
    Stop BIP Log    L2BIPRT

L1BIPL1_bip_log
    Start BIP Log    L1BIPL1
    Sleep    4s
    Stop BIP Log    L1BIPL1


L2BIPHI_bip_log
    Start BIP Log    L2BIPHI
    Sleep    6s
    Stop BIP Log    L2BIPHI