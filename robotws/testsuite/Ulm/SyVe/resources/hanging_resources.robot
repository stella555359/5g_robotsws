*** Settings ***
Documentation    Keywords related to hanging resources

Library    taf.ul.hanging_resources   WITH NAME   resources
Resource    ../../resources/Common/gnb.robot


*** Keywords ***
Get Resources Before Test For All Nodes
    [Documentation]    :Author: Sandra Schöffel
    ...    This function is defined to get the resource usage before the test for all nodes.
    ...    :param node_type: (default=gnb) Type of node (enb/gnb)

    [Arguments]  ${node_type}=gnb
    ${node_count}  Get Length  ${tl.${node_type}s}
    Log To Console  get used resources and save in var "resources_usage_before_test"
    FOR    ${node}    IN RANGE    ${node_count}
       ${resources_usage_before_test}    resources.Get Resources Usage   node_id=${node}   node_type=${node_type}
       Set Test Variable    ${resources_usage_before_test_${node_type}_${node}}  ${resources_usage_before_test}
    END


Get Resources After Test For All Nodes
    [Documentation]    :Author: Sandra Schöffel
    ...    This function is defined to get the resource usage after the test for all nodes.
    ...    :param node_type: (default=gnb) Type of node (enb/gnb)

    [Arguments]  ${node_type}=gnb
    ${node_count}  Get Length  ${tl.${node_type}s}
    Log To Console  get used resources and save in var "resources_usage_after_test"
    FOR    ${node}    IN RANGE    ${node_count}
       ${resources_usage_after_test}    resources.Get Resources Usage   node_id=${node}   node_type=${node_type}
       Set Test Variable    ${resources_usage_after_test_${node_type}_${node}}  ${resources_usage_after_test}
    END


Verify Resource Usage For All Nodes
    [Documentation]    :Author: Sandra Schöffel
    ...    This function is defined to verfiy the resource usage after the test for all nodes.
    ...    :param node_type: (default=gnb) Type of node (enb/gnb)

    [Arguments]  ${node_type}=gnb
    ${node_count}  Get Length  ${tl.${node_type}s}
    Log To Console  verify used resources

    FOR    ${node}    IN RANGE    ${node_count}
       ${tolerance_check}=   Evaluate   lambda res1, res2: abs(int(res1)-int(res2)) <= 2

       ${gnb_release}   gnb.Get Release Name   node_id=${node}

       ${post_timer_wheel_path}  Set Variable If
       ...   $node_type=='gnb' and $gnb_release not in ['SBTS25R1','SBTS25R2','SBTS25R3','SBTS26R1','SBTS26R2']   //postTimerWheel/total
       ...   ${True}   //postTimerWheel

       Run Keyword And Continue On Failure      resources.Selected Resources Should Match Comparison
       ...    ${resources_usage_before_test_${node_type}_${node}}
       ...    ${resources_usage_after_test_${node_type}_${node}}
       ...    ${post_timer_wheel_path}      ${tolerance_check}
    END


## -> one keyword that provide a list of exclusions
No Check Of Resource NbOfFreeCRNTI
    [Documentation]    exclude nbOfFreeCRNTI from the resource comparison
    ...                known resource to exclude in FDD
    # robocop: disable=too-few-calls-in-keyword
    resources.Configure Default Excluding Resource Paths   add=//nbOfFreeCRNTI
