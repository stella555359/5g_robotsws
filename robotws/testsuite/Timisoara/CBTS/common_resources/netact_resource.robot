*** Settings ***
Documentation  This suite contains netact KWs


*** Keywords ***
Open SSH Connection To Netact
    [Documentation]
    ...  This keyword opens connection to Netact.
    ...  ${netact_ip} must be given as an argument.
    ...  ${NETACT_USERNAME} and ${NETACT_PASSWORD} are set in vcu/vdu_frame.robot resources.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${netact_ip}

    SSHLibrary.Open Connection  ${netact_ip}  prompt=$  timeout=20s
    SSHLibrary.Login  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    SSHLibrary.Write  pwd
    ${login_output}  SSHLibrary.Read Until Prompt
    ${login_status}  Run Keyword And Return Status
    ...  Should Contain  ${login_output}  /home/omc
    Run Keyword If  ${login_status} == ${FALSE}
    ...  Fail  Connection to Netact failed. [NOK]
