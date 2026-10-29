*** Settings ***
Documentation
...  author:     Patryk Tatarek
...  contact:    patryk.tatarek@nokia.com

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../../cloud_common_resources/alarms/alarms.robot
Resource    ./../../../../cloud_common_resources/tls/tls.robot

Library     OperatingSystem
Library     taf.transport.ssh  WITH NAME  ssh
Library     SSHLibrary

*** Variables ***
${ipsec_status}=           'status': 'Established'
${old_default_password}         nemuuser\
${error_minlenght}              Incorrect value of minPasswordLength
${new_password}                 Nokia@123a
${SERVICEUSER_LOGIN}            serviceuser
${SERVICEUSER_PWD}              Pl(FzaYj5~c5;q
${SERVICEUSER_NEW_PWD}          Qwerty13#
${SSH_TUNNEL_REQ}               MRBTS-${MRBTS}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
${SSH_PORT}                     51217
${SSH_PERM_DENIED}              Permission denied
${local_password}=              Qwerty!23$
${WSUSER_LOGIN}             wsuser
${DEFAULT_WSUSER_PWD}       A0zY~rP#8Mx@
${NEW_WSUSER_PWD}           Qwerty12#
${path_to_files}               ${CURDIR}/Files
#${IP_VM}                       ${tl.test_pc.default_ssh_connection_details.addr}
${IP_VM}                       10.44.180.38
${username}                    ${tl.test_pcs[0].default_ssh_connection_details.username}

*** Keywords ***
Verify IP Secuirty Associations
    ${ike}=           Get IP Security Associations    pod=TNL-6-UPUE_po-upue-0
    ...                                               policy_nr=1000    hw_type=vCU
    ${ike_str}=       Convert to String    ${ike}
    Should Contain    ${ike_str}    ${ipsec_gw}
    Should Contain    ${ike_str}    ${ipsec_status}

Switch localIpAddress in XML to NGU Address from specific TL
    ${xml}=            OperatingSystem.Get File
    ...                ${CURDIR}/Delta_files/IPSEC_config.xml
    ${xml}=            Replace String Using Regexp    ${xml}
    ...                <p name="localIpAddress">.*</p>    <p name="localIpAddress">${NGU_VCU}</p>
    Create File        ${CURDIR}/Delta_files/IPSEC_config.xml

Add SSH Key to vDU
    [Documentation]    Keyword will create structure and fill needed parameters
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    ...                Input: ssh_key_value: is the alue of public RSA key
    ...                       Key_descp: description for the key visible in webEM started with #
    ...                                  example: key_descp=#First RSA KEY check
    [Arguments]    ${ssh_key_value}    ${key_descp}
    Log    Creating rootUserPublicKeys structure, and addiing RSA public key    console=true
    ${values_dict}=      create dictionary
    set to dictionary    ${values_dict}     keyDescription      ${key_descp}
    ...                                     keyValue            ${ssh_key_value}
    ${values_list}       create list        ${values_dict}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=rootUserPublicKeys
    ...                             operation=update
    ...                             hw_type=vDU
    ...                             param_value=${values_list}
    Log    Key added, validating and activating new delta plan    console=true

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

Generate RSA SSH Key
    [Documentation]    Keyword will generate RSA SSH key using and will return
    ...                it's value to variable named ssh_pub_key
    ...                Input: ssh-keygen -P "" -t rsa -b 4096 -f your_key_name
    ...                Output: value of RSA public key to variable.
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${RSA_key}    ${serviceuser_pass}
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
    ${ssh_pub_key}      SSHLibrary.Read until    po-cran1-nic-a-0
    Log                 Printing RSA public key value    console=true
    Log                 ${ssh_pub_key}    console=true
    Sleep    3s         reason=Wait until terminal executes the command
    [Return]            ${ssh_pub_key}
    SSHLibrary.Close Connection

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

Change Service User Password
    [Documentation]    Description:    Update password for specified serviceuser account
    ...                Input:          hw_type = vCU/vDU
    ...                                Serviceuser accounts: wsuser, toor4nsn, serviceuser
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${username}    ${new_password}    ${password}=xd    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-connection}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
    ...                ELSE    Set Variable      ${pre-connection}
    Log    Changing password    console=true
    ${jakas_zmienna}    Run Keyword If    '${hw_type}'=='vCU'   vcu_admin.update_service_account_password     username=${username}
    ...                password=${password}    new_password=${new_password}    connection=${temp_conn}
    ...    ELSE IF    '${hw_type}'=='vDU'   vdu_admin.update_service_account_password     username=${username}
    ...                password=${password}    new_password=${new_password}    vdu_connection=${temp_conn}
    ...    ELSE        FAIL                  hw_type doesn't exist
    Log    ${jakas_zmienna}    console=true
    [Teardown]         Run Keyword If    "${pre-connection}"=="${NONE}"    Disconnect from ADMIN
    ...                                  connection=${temp_conn}    hw_type=${hw_type}

Send Files to Test PC
    [Documentation]   This keyword send files from VM to Test PC
    ${VM_PASS}  Run   sudo cat /etc/ute/vncpasswd
    SSHLibrary.Open Connection      ${IP_VM}
    SSHLibrary.Login                ${username}   ${VM_PASS}
    SSHLibrary.Write                pwd
    SSHLibrary.Read
    SSHLibrary.Write                text=scp ${path_to_files}/user.txt ${PC_username}@${PC_IP}:/home/ute
    SSHLibrary.Read Until           expected=password:
    SSHLibrary.Write                text=${PC_password}
    SSHLibrary.Write                text=scp ${path_to_files}/pass.txt ${PC_username}@${PC_IP}:/home/ute
    SSHLibrary.Read Until           expected=password:
    SSHLibrary.Write                text=${PC_password}
    Sleep    5                      reason=Wait until terminal execute the command
    SSHLibrary.Close Connection
