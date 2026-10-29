*** Settings ***
Documentation
...     description:    Keyword for test cases for the CB008154 feature.

Resource    ../../../../common_resources/certificates/certificates.robot
Resource    ../../../../common_resources/netact/netact_operations.robot


*** Keywords ***
Install Certificates Using NetAct
    [Arguments]   ${cert_path}
    ${conn_net}=  Wait Until Keyword Succeeds   5min  60sec    Connect to NetAct
    ${output}     Wait Until Keyword Succeeds   3min  60sec    Install Certificate With NetAct
    ...                                          connection=${conn_net}
    ...                                          path_to_cert=${cert_path}
    [Return]  ${output}
    [Teardown]     Disconnect from NetAct    ${conn_net}
