*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    ./resource/CB008502_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008502 in SBTS24R3 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB008502_02_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
    [Tags]     CRT_TRUNK
    BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI



*** Keywords ***
