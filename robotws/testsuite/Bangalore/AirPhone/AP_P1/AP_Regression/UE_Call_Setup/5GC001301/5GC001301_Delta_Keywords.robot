*** Settings ***
Documentation    This file contains 5GC001301 delta commissioning keywords

Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Keywords ***
Update frame parameters
    [Arguments]    ${nrbts_distname}    ${listname}    &{kwargs}
    delta_store.add_list_parameters_to_delta    dist_name=${nrbts_distname}    list_name=${listname}    &{kwargs}

Update gnb parameter
    [Arguments]    ${nrbts_distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${nrbts_distname}    &{kwargs}
