*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Module for the temprary NIDD paramter migration check.
...   Operation = upgrade
...               delta_plan_update
...               check_temp_nidd
...               check_target_nidd

Resource    ./library/_temp_nidd_check.robot
Resource    ./CERTA_Module.robot



*** Keywords ***
Temp Nidd Check
    [Arguments]    ${operation}
    ...            ${product_type}=gnb
    ...            ${bts_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${target_release}=24R3
    ...            ${target_version}=${None}
    ...            ${timeout}=${3600}
    [Documentation]     Module for the temprary NIDD paramter migration check.

    Run Keyword If    '${product_type}'=="gnb"
    ...    Classical Temp Nidd Check    operation=${operation}
    ...                                 gnb_index=${bts_index}
    ...                                 cudu_index=${cudu_index}
    ...                                 target_release=${target_release}
    ...                                 target_version=${target_version}
    ...                                 timeout=${timeout}

    Run Keyword If    '${product_type}'!="gnb"
    ...    Log To Console    \nProduct type ${product_type} NOT supported!
