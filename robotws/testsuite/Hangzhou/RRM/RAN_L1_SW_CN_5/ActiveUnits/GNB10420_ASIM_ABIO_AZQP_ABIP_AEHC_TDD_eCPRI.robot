*** Settings ***
Documentation
...    Author:  yuguo.hou@nokia-sbell.com
...    Contact: yuguo.hou@nokia-sbell.com
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
&{PA_dict}    ip=10.108.228.24    init_value=1:30;2:30;3:30;4:30     target_value=1:120;2:120;3:120;4:120

*** Test Cases ***
GNB10420_ASIM_ABIO_AZQP_ABIP_AEHC_TDD_eCPRI
    [Tags]    ABIO    ABIP    SMAwave    INIT
    Run Keyword And Continue On Failure    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}Testability_ABIO_1xAZQP_NRTDD_1xNRCEL_72a_${btsid}.xml
