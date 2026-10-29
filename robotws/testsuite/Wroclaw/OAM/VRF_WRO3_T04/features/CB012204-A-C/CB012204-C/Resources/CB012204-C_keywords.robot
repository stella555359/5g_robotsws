*** Settings ***
Documentation
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../../cloud_common_resources/alarms/alarms.robot
Resource    ./../../../../cloud_common_resources/tls/tls.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot

Library     ./../Resources/selenium_resources.py
Library     OperatingSystem
Library     taf.transport.ssh  WITH NAME  ssh
Library     SSHLibrary

*** Variables ***
${WSUSER_LOGIN}             wsuser
${DEFAULT_WSUSER_PWD}       A0zY~rP#8Mx@
${NEW_WSUSER_PWD}           Qwerty12#
${SERVICEUSER_LOGIN}        serviceuser
${SERVICEUSER_PWD}          Pl(FzaYj5~c5;q
${SERVICEUSER_NEW_PWD}      Qwerty13#
${SERVICEUSER_NEW_PWD_2}    Qwerty14#
${SERVICEUSER_NEW_PWD_3}    Qwerty15#
${SSH_TUNNEL_REQ}           MRBTS-${MRBTS}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
${SSH_PASS}                 password:
${SSH_PERM_DENIED}          Permission denied
${SSH_PORT}                 51217

*** Keywords ***
Generate RSA SSH Key
    [Documentation]    Keyword will generate RSA SSH key using and will return
    ...                it's value to variable named ssh_pub_key
    ...                Input: ssh-keygen -P "" -t rsa -b 4096 -f your_key_name
    ...                Output: value of RSA public key to variable.
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${RSA_key}    ${serviceuser_pass}
    ${pod_name}        Get Pod Prefix        hw_type=vDU
    Log    Generating RSA public and private keys    console=true
    SSHLibrary.Open Connection         ${LMP_VDU_IP}    port=${SSH_PORT}
    SSHLibrary.Login    ${SERVICEUSER_LOGIN}    ${serviceuser_pass}
    Sleep  3s           reason=Wait until terminal executes the command
    SSHLibrary.Write    ssh-keygen -P "" -t rsa -b 4096 -f ${RSA_key}
    Sleep  10s          reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    Sleep  2s           reason=Wait until terminal executes the command
    SSHLibrary.Write    cat /user/serviceuser/${RSA_key}.pub
    Sleep  2s           reason=Wait until terminal executes the command
    ${ssh_pub_key}      SSHLibrary.Read until    serviceuser@${pod_name}-nic-a-0
    Log                 Printing RSA public key value    console=true
    Log                 ${ssh_pub_key}    console=true
    Sleep    3s         reason=Wait until terminal executes the command
    [Return]            ${ssh_pub_key}
    SSHLibrary.Close Connection


Add SSH Key to vDU
    [Documentation]    Keyword will create structure and fill needed parameters
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    ...                Input: ssh_key_value: is the alue of public RSA key
    ...                       Key_descp: description for the key visible in webEM started with #
    ...                                  example: key_descp=#First RSA KEY check
    [Arguments]    ${ssh_key_value}    ${key_descp}
    Log    Creating rootUserPublicKeys structure, and addiing RSA public key    console=true
    ${values_dict}=    create dictionary
    set to dictionary    ${values_dict}     keyDescription      ${key_descp}
    ...                                     keyValue            ${ssh_key_value}
    ${values_list}    create list           ${values_dict}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=rootUserPublicKeys
    ...                             operation=update
    ...                             hw_type=vDU
    ...                             param_value=${values_list}
    Log    Key added, validating and activating new delta plan    console=true

RANNIC SSH Connection
    [Documentation]    Checking connection do RANNIC as serviceuser and toor4nsn
    ...                with checking its privilages to execute commands.
    ...                Input: RSA_Key name and serviceuser password
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${RSA_key}    ${serviceuser_pass}
    Log    Establishing ssh connection    console=true
    SSHLibrary.Open Connection         ${LMP_VDU_IP}    port=${SSH_PORT}
    SSHLibrary.Login    ${SERVICEUSER_LOGIN}    ${serviceuser_pass}
    Sleep  5s           reason=Wait until terminal executes the command
    SSHLibrary.Write    pwd
    Sleep  2s           reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    /user/serviceuser
    Log                 ${output}    console=true
    Log                 Check if serviceuser can successfuly gather logs on RANNIC    console=true
    SSHLibrary.Write    trblctl collect --outdir /tmp/TEST_LOG
    Sleep    60s        reason=Wait until terminal executes the command
    ${output}           SSHLibrary.Read
    Should Contain      ${output}    ${SSH_PERM_DENIED}
    Log                 ${output}    console=true
    Sleep    2s         reason=Wait until terminal executes the command
    SSHLibrary.Write    ssh -i ${RSA_key} toor4nsn@127.0.0.1
    Sleep  5            reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    ${status}=          Run keyword and return status     Should Contain    ${output}    fingerprint
    Run Keyword If     '${status}'=='True'   SSHLibrary.Write     text=yes
    ...    ELSE         SSHLibrary.Write    text=
    Sleep    2s         reason=Wait until terminal executes the command
    SSHLibrary.Write    pwd
    Sleep    2s         reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    /user/toor4nsn
    Log to console      ${output}
    Log                 Check if toor4nsn can successfuly gather logs on RANNIC    console=true
    SSHLibrary.Write    trblctl collect --outdir /tmp/TEST_LOG_TOOR
    Sleep    60s        reason=Wait until terminal executes the command
    ${output}           SSHLibrary.Read
    Should not Contain  ${output}    ${SSH_PERM_DENIED}
    Log                 ${output}    console=true
    Log                 Delete gathered test logs    console=true
    SSHLibrary.Write    rm -rf /tmp/TEST_LOG_TOOR
    Sleep    3s         reason=Wait until terminal executes the command
    [Teardown]          SSHLibrary.Close Connection

RANNIC SSH Connection After Manual Synchronization
    [Arguments]    ${serviceuser_pass}
    Log    Establishing ssh connection    console=true
    SSHLibrary.Open Connection         ${LMP_VDU_IP}    port=${SSH_PORT}
    SSHLibrary.Login    ${SERVICEUSER_LOGIN}    ${serviceuser_pass}
    Sleep  5s           reason=Wait until terminal executes the command
    SSHLibrary.Write    pwd
    Sleep  2s           reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    Should Contain      ${output}    /user/serviceuser
    Log                 ${output}    console=true
    Sleep    3s         reason=Wait until terminal executes the command
    [Teardown]          SSHLibrary.Close Connection

Enable SSH Access and Port
    [Documentation]    Keyword is enabling SSH connection to RANNIC
    ...                parameter actSshToRanNic must be set to true first
    ...                Input: operation=enable/disable
    ...                       example dist_name: MRBTS-${MRBTS}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${dist_name}    ${operation}    ${hw_type}=vDU
    Log    Enabling SSH connection to RANNIC    console=true
    ${connection}=    Connect to ADMIN      hw_type=${hw_type}
    vdu_admin.config_ssh_tunnel             dist_name=${dist_name}
    ...                                     operation=${operation}
    ...                                     vdu_connection=${connection}
    [Teardown]         Run keyword and ignore error    Disconnect from ADMIN    connection=${connection}    hw_type=${hw_type}

Manual Synchronization Trigger
    [Documentation]    KW for manual trigger synchronization to RANNIC
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${hw_type}=vDU
    ${connection}=     Connect to ADMIN    hw_type=${hw_type}
    vdu_admin.synchronize_to_ran_nics      vdu_connection=${connection}

Remove All Generated Keys
    [Documentation]    Keyword will delete all generated RSA keys on rannic devices.
    ...                Input: RSA_Key name, serviceuser password
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${RSA_key}    ${serviceuser_pass}
    Log    Establishing ssh connection    console=true
    SSHLibrary.Open Connection         ${LMP_VDU_IP}    port=${SSH_PORT}
    SSHLibrary.Login    ${SERVICEUSER_LOGIN}    ${serviceuser_pass}
    Sleep  5s           reason=Wait until terminal executes the command
    SSHLibrary.Write    ssh -i ${RSA_key} toor4nsn@127.0.0.1
    Sleep  5            reason=Wait until terminal executes the command
    ${output}=          SSHLibrary.Read
    ${status}=          Run keyword and return status     Should Contain    ${output}    fingerprint
    Run Keyword If     '${status}'=='True'   SSHLibrary.Write     text=yes
    ...    ELSE         SSHLibrary.Write    text=
    Sleep    2s         reason=Wait until terminal executes the command
    Log                 Delete gathered RSA keys   console=true
    SSHLibrary.Write    rm -rf /user/serviceuser/RSA_key && rm -rf /user/serviceuser/RSA_key.pub
    Sleep    3s         reason=Wait until terminal executes the command
    SSHLibrary.Write    rm -rf /user/serviceuser/2ND_RSA_key && rm -rf /user/serviceuser/2ND_RSA_key
    Sleep    3s         reason=Wait until terminal executes the command
    SSHLibrary.Write    rm -rf /user/serviceuser/3RD_RSA_key && rm -rf /user/serviceuser/3RD_RSA_key
    Sleep    3s         reason=Wait until terminal executes the command
    [Teardown]          SSHLibrary.Close Connection
