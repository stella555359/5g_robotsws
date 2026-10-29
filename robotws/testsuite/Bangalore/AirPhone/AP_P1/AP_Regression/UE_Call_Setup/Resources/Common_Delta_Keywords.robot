*** Settings ***
Documentation     Contains Common delta commissioning keywords

Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store

*** Keywords ***
Update DL Forwarding Parameters
    [Arguments]    ${nrbts_distname}    &{kwargs}
    delta_store.update managed object and parameter to delta    dist_name=${nrbts_distname}    &{kwargs}