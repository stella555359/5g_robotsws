*** Settings ***
Documentation    This file contains 5GC000509 Delta commissioning keywords

Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Keywords ***
Update Cipher Parameters
    [Arguments]    ${nrbts_distname}    ${listname}    &{kwargs}
    delta_store.add_list_parameters_to_delta    dist_name=${nrbts_distname}   list_name=${listname}    &{kwargs}

Update NullFallback Parameter
    [Arguments]    ${nrbts_distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${nrbts_distname}    &{kwargs}

Update CBRA Preamble Parameter
    [Arguments]    ${nrcell_distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${nrcell_distname}    &{kwargs}

