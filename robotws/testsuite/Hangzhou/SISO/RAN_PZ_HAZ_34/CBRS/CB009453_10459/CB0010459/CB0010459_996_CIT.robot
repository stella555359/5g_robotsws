*** Settings ***
Suite Setup          CB0010459 CIT CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Resource    ../resources/CB009453_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009453

Force Tags    SBTS00   
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB010459_24_Verify_HW_BandWidth_Limitation_when_C2_got_terminated
    [Tags]    CIT_TRUNK
    CB010459_24_Verify_HW_BandWidth_Limitation_when_C2_got_terminated

[1]CB010459_26_Verify_HW_BandWidth_Limitation_when_C2_deleted
    [Tags]    CIT_TRUNK
    CB010459_26_Verify_HW_BandWidth_Limitation_when_C2_deleted

*** Keywords ***
