*** Settings ***
Documentation    This file contains 5GC000738 delta commissioning keywords


Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Keywords ***
Update gnb parameters list
    [Arguments]    ${nrbts_distname}    ${listname}    &{kwargs}
    delta_store.add_list_parameters_to_delta    dist_name=${nrbts_distname}    list_name=${listname}    &{kwargs}

Update gnb parameter
    [Arguments]    ${nrbts_distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${nrbts_distname}    &{kwargs}

Update mo and parameter to delta
    [Arguments]    ${nrbts_distname}    &{kwargs}
    delta_store.add_managed_object_and_parameter_to_delta    dist_name=${nrbts_distname}    &{kwargs}

Delete managed object to delta
    [Arguments]    ${nrbts_distname}    &{kwargs}
    delta_store.delete_managed_object_from_delta    dist_name=${nrbts_distname}    &{kwargs}