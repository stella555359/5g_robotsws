*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CB012364 CBRS Test Teardown

Resource    Resources/CB012364_common_keywords.robot


Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012364

Force Tags    CRT_TRUNK    PY39

*** Variables ***

*** Test Cases ***

[1]CB012364-A_01_NR_static_Mplane_connect_to_IPV6_Primary_DP_IP_port
    [Tags]    CIT_TRUNK
    CB012364-A_01_NR_static_Mplane_connect_to_IPV6_Primary_DP_IP_port

*** Keywords ***
