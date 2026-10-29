*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         60 min

Resource    ./resource/CB009333_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008238 in 5G23R2 program

Force Tags    5G_RAN_TDD

*** Variables ***

*** Test Cases ***
[1]CB009333-C_01_01_caSupportEnabled_only_on_Scell_for_T+T_2CC_when_sCellActivationMethod_bufferBased_on_Classical_SA
    [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK    1S-2CC-4D-4U_CA_50M_50M
    Selenium Login And Disable Screen Lock
    Step 4 DL CA UE make L3Call and attach to Pcell and check TTI
    [Teardown]    Run keywords     Selenium Logout And Close Browser
*** Keywords ***
