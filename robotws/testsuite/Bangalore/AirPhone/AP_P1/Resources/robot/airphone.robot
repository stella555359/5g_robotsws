*** Settings ***
Documentation    This contains basic Airphone related keywords which are needed to run the Airphone TC.
...              : author Venkatesh

Library    taf.transport.ssh    WITH NAME    ssh
Resource   ../Variables/Common_Variables.robot

*** Keywords ***
Reboot Airphone UE
    [Documentation]     This Keyowrd can be used to reboot Airphone UE
    ssh.Connect to    ${AP_IP}    ${AP_Username}    ${NOKIA_PASS}     alias=ap_coam
    ssh.execute    command=reboot    connection=ap_coam
    [Teardown]    ssh.disconnect    connection=ap_coam