*** Settings ***
Documentation
...  author:     Julia Wijas
...  contact:    julia.wijas@nokia.com

Resource    ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource    ../../../../cloud_common_resources/rest_api/rest_api.robot
Resource    ../../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../cloud_common_resources/tls/tls.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../../../cloud_common_resources/connections/connections.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../../cloud_common_resources/test_pc/test_pc.robot
Resource    ../../../../cloud_common_resources/counters/counters.robot
Resource    ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource    ../../../../cloud_common_resources/tls/tls.robot
Library    BuiltIn
Library    String
Library    SSHLibrary       encoding=None
Library    DateTime

*** Variables ***
${SERVICEUSER_LOGIN}        serviceuser
${SERVICEUSER_PWD}          Pl(FzaYj5~c5;q
${SERVICEUSER_NEW_PWD}      Qwerty13#
${SSH_PORT}                 51217
${SSH_PASS}                 password:
${SSH_PERM_DENIED}          Permission denied
${SSH_TUNNEL_REQ}           MRBTS-${MRBTS}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
${for_spliting_logs}=     >1${SPACE}
${status_pass_log}=       eventStatus="SUCCESS"
${status_fail_log}=       eventStatus="FAILURE"

*** Keywords ***
Check difference between two counters
    [Arguments]     ${nft_before}       ${nft_after}     ${loop}
    ${nft_before_int}=    Get From List    ${nft_before}    0
    ${nft_after_int}=    Get From List    ${nft_after}    0
    ${counters_difference}=  Evaluate  ${nft_after_int} > ${nft_before_int}+0.75*${loop}
    Should Be True  ${counters_difference}

Test Setup NMS
    [Arguments]    ${hw}
    ${NMS_LAB}=     Integrate Cloud BTS with NMS Lab without TLS   hw_type=${hw}
    Set Suite Variable    ${NMS_LAB}
    [Return]    ${NMS_LAB}

Test Teardown NMS
    [Arguments]    ${hw}
    Deintegrate Cloud BTS from NMS Lab
    ...    LAB_NAME=${NMS_LAB}
    ...    hw_type=${hw}

Login to RANNIC
    Log      Changing password for serviceuser                          console=true
    Change Service Account Password    username=${SERVICEUSER_LOGIN}    old_password=${SERVICEUSER_PWD}
    ...                                new_password=${SERVICEUSER_NEW_PWD}                  hw_type=vDU
    Log    Changing parameter actSshToRanNic on vDU                     console=true
    Run keyword and ignore error    Change Parameter on BTS             dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=actSshToRanNic           param_value=true    hw_type=vDU
    Wait until keyword succeeds     3x    10s    Enable SSH Access and Port
    ...                                          dist_name=${SSH_TUNNEL_REQ}
    ...                                          operation=Enable
    Log    Set SSH public key for RAN NIC        console=true
    ${ssh_pub_key}=    wait until keyword succeeds    3x    20s     Generate RSA SSH Key
    ...                                                             RSA_key=RSA_key
    ...                                                             serviceuser_pass=${SERVICEUSER_NEW_PWD}
    Add SSH Key to vDU      ${ssh_pub_key}       key_descp=#First RSA KEY check
    Log    Perform RANNIC SSH login to serviceuser          console=true
    RANNIC SSH Connection   RSA_key=RSA_key    serviceuser_pass=${SERVICEUSER_NEW_PWD}

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
    SSHLibrary.Write    lococtl -tar /tmp/TEST_LOG
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
    SSHLibrary.Write    lococtl -tar /tmp/TEST_LOG_TOOR
    Sleep    60s        reason=Wait until terminal executes the command
    ${output}           SSHLibrary.Read
    Should not Contain  ${output}    ${SSH_PERM_DENIED}
    Log                 ${output}    console=true
    Log                 Delete gathered test logs    console=true
    SSHLibrary.Write    rm -rf /tmp/TEST_LOG && rm -rf /tmp/TEST_LOG.tgz && rm -rf /tmp/TEST_LOG_TOOR && rm -rf rm -rf /tmp/TEST_LOG_TOOR.tgz
    Sleep    3s         reason=Wait until terminal executes the command
    [Teardown]          SSHLibrary.Close Connection

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
    ${values_list}    create list           ${values_dict}
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
    [Arguments]    ${RSA_key}          ${serviceuser_pass}
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
    ${ssh_pub_key}      SSHLibrary.Read until    serviceuser@po-cran1-nic-a-0
    Log                 Printing RSA public key value    console=true
    Log                 ${ssh_pub_key}    console=true
    Sleep    3s         reason=Wait until terminal executes the command
    [Return]            ${ssh_pub_key}
    SSHLibrary.Close Connection

Collect and check ATL logs NESAS
    [Arguments]            ${hw_type}        ${username}
    Log                    Verify MantaRay logs   console=True
    Sleep    2h            reason=Log will be generated after 2h
    ${atl_log}=            Gather ATL for BTS    LAB_NAME=srnclab1045    hw_type=${hw_type}
    Create File            /home/ute/atl_log.txt             ${atl_log}
    ${split_log}=   Split String    ${atl_log}  ${for_spliting_logs}
    @{atl_pass_login_logs}=       Create List
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d
    ${VM_ip}=           Get VM address
    FOR  ${atl_log}  IN  @{split_log}
        ${login}=               Run Keyword and Return Status    Should Contain    ${atl_log}    eventType="Login"
        ${login_status}=        Run Keyword If     '${login}'=='True'
        ...                     Run Keyword and Return Status    Should Contain    ${atl_log}    ${status_pass_log}
        Run Keyword If  '${login_status}'=='True'  Append To List  ${atl_pass_login_logs}  ${atl_log}
    END
    ${atl_pass_login_logs}=    Evaluate    " ".join(${atl_pass_login_logs})
    Should Contain       ${atl_pass_login_logs}    ${username}
    Should Contain       ${atl_pass_login_logs}    ${current_date}
    Should Contain       ${atl_pass_login_logs}    sessionId
    Should Contain       ${atl_pass_login_logs}    ${VM_ip}
