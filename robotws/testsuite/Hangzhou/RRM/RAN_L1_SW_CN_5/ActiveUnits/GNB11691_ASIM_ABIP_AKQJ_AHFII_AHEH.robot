*** Settings ***
Documentation
...    Author:  Qian.3.zhang
...    Contact: qian.3.zhang@nokia-sbell.com
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases *** 
ASIM_ABIP_AKQJ_AHFII_AHEH_NRTDD_1xNRCEL
    [Tags]    ABIP    SMAwave    INIT    BTS11691
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009029${/}ASIM_ABIP_AKQJ_AHFII_AHEH_Full_Commission.xml

