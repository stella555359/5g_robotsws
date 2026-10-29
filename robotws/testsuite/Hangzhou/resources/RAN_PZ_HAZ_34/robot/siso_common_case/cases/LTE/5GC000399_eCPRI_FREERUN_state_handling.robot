*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Variables ***

*** Keywords ***
5GC000399_eCPRI_FREERUN_state_handling
    [Setup]    Test Setup
    ${modify_params}    Generate Modify Parameters      modify_params=${TOP_DOMAIN_NUMBER_MODIFY}
    ${orig_params}  Generate Origion Parameters  modify_params=${modify_params}
    modify parameters on webem    modify_params=${modify_params}    despite_errors=${True}
    Wait For Expect Fault Present LTE   faultId=${16}     timeout=180
    Wait For Expect Fault Present LTE   faultId=${4298}     timeout=180
    modify parameters on webem    modify_params=${orig_params}
    Wait For Expect Fault To Disappear LTE   faultId=${16}   timeout=180
    Wait For Expect Fault To Disappear LTE   faultId=${4298}     timeout=180
    [Teardown]   Test Teardown
