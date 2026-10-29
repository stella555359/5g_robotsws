# *** Settings ***
# Force Tags    PY36
# Documentation     author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Suite Setup
# Suite Teardown
# 
# Resource          resources/894_A_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${errorMsg1}    It is required that there exist MOs IPRTV6
# 
# *** Test Cases ***
# [1]5GC001566-5GC000894_A_003_IP rule creation failure (IP version mismatch)
#     [Documentation]       Creat an IPV4 Address as the format of IPV6 on the WebUI and validate, check the error
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1:Login and check
#     Step2:Modify Configuration and Check Error
#     [Teardown]    Run keywords  Rest Logout DU   AND   CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Step1:Login and check
#     Log To Console     Check BTS Should Be Normal
#     Rest Login DU
#     Wait Until BTS Should Be Normal
# 
# Step2:Modify Configuration and Check Error
#     ${get_managed_objects}=    coam.get_managed_objects    class_name=RTPOL_A    connection=${conn}
#     ${parameters}    Get From Dictionary     @{get_managed_objects}[0]    parameters
#     ${staticRoutes_list}    get from dictionary    ${parameters}     routingPolicies
#     FOR    ${staticRoute}    IN    @{staticRoutes_list}
#         ${items}     Get Dictionary Items    ${staticRoute}
#         Remove None value from Dictionary    items=${items}    staticRoute=${staticRoute}
#     END
#     Set To Dictionary    ${staticRoutes_list[0]}    srcIpAddress    ::::::
#     log    ${staticRoutes_list}
#     &{output}    coam.Perform Parameter Recommissioning
#     ...    dist_name=${dist_name}
#     ...    parameter=${parameter}
#     ...    value=${staticRoutes_list}
#     ...    operation=${operation}
#     ...    skip_parameter_relation_errors=${True}
#     ...    should_activate=${False}
#     ...    connection=${conn}
#     &{activate_result}     set variable    ${output['validationResult']['pdlValidationResult']['logs']}
#     @{activate_result1}    set variable    ${activate_result['relationErrors']}
#     &{activate_result2}    set variable    @{activate_result1}[0]
#     ${activate_result3}    set variable    ${activate_result2['feedback']}
#     should contain    ${activate_result3}    ${errorMsg1}