*** Settings ***
Documentation    This file contains 5GC001200 delta commissioning keywords

Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Keywords ***
Update Delta List Parameter
    [Arguments]    ${distname}    ${listname}    &{kwargs}
    delta_store.add_list_parameters_to_delta    dist_name=${distname}   list_name=${listname}    &{kwargs}

Update Delta Parameter
    [Arguments]    ${distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${distname}   &{kwargs}
