*** Settings ***
Documentation    This file contains 5GC000511 delta commissioning keywords

Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Keywords ***
Update Prach Parameters
    [Arguments]    ${nrcell_distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${nrcell_distname}    &{kwargs}
