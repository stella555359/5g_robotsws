*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB008154 feature.

Resource    ../../../../common_resources/certificates/certificates.robot
Library     8154_split1_utils.py

*** Keywords ***
Configure CMP And Initialize Certificates
    [Arguments]    ${ca_subject_name}
    Configure CMP                           ca_subject_name=${ca_subject_name}
    Initialize Certificates

Checking If The Correct Certificates Are Installed
    [Arguments]  ${certificate_CN}
    ${output}=    Get Certificates List    cert_type=All
    ${status}=    find_CN_in_certificate    ${output}    ${certificate_CN}
    [Return]    ${status}

Initialize Certificates Using NetAct
    ${conn_net}=  Wait Until Keyword Succeeds   5min  60sec    Connect to NetAct
    Wait Until Keyword Succeeds   5min  60sec    Initialize Certificates From NetAct
    ...                                          connection=${conn_net}
    ...                                          dist_name=MRBTS-${bts_id}/MNL-1/CERTH-1/CMP-1
    [Teardown]   Disconnect from NetAct  ${conn_net}
