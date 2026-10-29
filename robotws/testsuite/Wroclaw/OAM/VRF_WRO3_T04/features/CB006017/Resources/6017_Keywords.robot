*** Settings ***
Documentation
...          Keywords for CB006017

Library          ../../../common_resources/netact/netact_operations.py
Resource         ../../../common_resources/netact/netact_operations.robot
Resource         ../../../common_resources/admin/admin.robot

Library          taf.transport.ssh            WITH NAME    ssh
Library          taf.config.scf               WITH NAME    scf
Library          taf.sbts.oam.coam.admin      WITH NAME    coam_admin
Library          SSHLibrary
Library          ./6017_functions.py
Variables        ./6017_variables.py

*** Variables ***

${flag}                   0x1018
@{SW_WITH_FHNET_00}       SBTS26R2   SBTS26R1    SBTS25R3    SBTS25R2    SBTS25R1    SBTS24R3    SBTS24R2

*** Keywords ***
Preprocess String
    [Arguments]         ${string}
    ${string}=          Escape Ascii                       ${string}
    ${string}=          Replace string using regexp        ${string}       \r     \
    ${string}=          Replace string using regexp        ${string}       \n     \
    ${string}=          Strip String                       ${string}
    [Return]            ${string}

CB006017 Setup
    ${initial_scf_filepath}=   Download SCF   filename=initial_scf.xml
    Set Suite Variable         ${initial_scf_filepath}

Get default value from initial SCF
    [Arguments]         ${p_name}
    ${status}=          Run Keyword and Return Status
    ...                                              scf.Load Scf                file_path=${initial_scf_filepath}
    Should be true      ${status}
    ${scf_value}=       scf.get_value_from_scf       dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                              p_name=${p_name}
    [Return]            ${scf_value}

Change parameter to value via Netact
    [Arguments]  ${dist_name}   ${parameter}   ${value}    ${connection}
    &{param}=                   Create dictionary  ${parameter}  ${value}
    Log                         Changing ${parameter} parameter to "${value}"    console=True
    Set parameter using netact  dist_name=${dist_name}
    ...                         param_changes=${param}
    ...                         path_to_scf=${scf_filepath}
    ...                         na_instance=${connection}
    Sleep                       time_=30s                  reason=Waiting for delta commissioning to finish....

Change SSH parameters via Netact
    [Arguments]     ${client_alive_value}   ${login_delay_value}    ${banner_value}
    Download SCF and create NetAct connection
    &{param}=                   Create dictionary   sshClientAliveTimer           ${client_alive_value}
    ...                                             sshSessionLoginDelayTimer     ${login_delay_value}
    ...                                             platLoginBannerText           ${banner_value}
    Log                         Changing sshClientAliveTimer/sshSessionLoginDelayTimer/platLoginBannerText values
    ...                         console=True
    Set parameter using netact  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                         param_changes=${param}
    ...                         path_to_scf=${scf_filepath}
    ...                         na_instance=${connection}
    Sleep                       time_=30s                  reason=Waiting for delta commissioning to finish....
    [Teardown]      Disconnect from netact      ${connection}

Activate RU Synchronization via Netact
    Download SCF and create NetAct connection
    Change parameter to value via Netact    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     parameter=actSyncToRU
    ...                                     value=true
    ...                                     connection=${connection}
    [Teardown]      Disconnect from NetAct      ${connection}

Deactivate RU Synchronization via Netact
    Download SCF and create NetAct connection
    Change parameter to value via Netact    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                     parameter=actSyncToRU
    ...                                     value=false
    ...                                     connection=${connection}
    [Teardown]      Disconnect from NetAct      ${connection}

Change SSH parameter value via Netact
    [Arguments]     ${parameter}        ${value}
    Download SCF and create NetAct connection
    Change parameter to value via Netact        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                         parameter=${parameter}
    ...                                         value=${value}
    ...                                         connection=${connection}
    [Teardown]      Disconnect from NetAct      ${connection}

Get hash from BTS for user
    [Arguments]       ${user}
    ssh.Connect to    hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}    alias=bts_connection
    ${hash}=          ssh.execute    command=cat /etc/shadow | grep ${user} | cut -d':' -f2-
    ...                              connection=bts_connection
    ssh.disconnect                   connection=bts_connection
    ${hash}=          Fetch from left     string=${hash}      marker=:
    [Return]          ${hash}

Get hash from RU for user
    [Arguments]       ${user}       ${password}
    ${RU_IP}=         Get RU IP
    ${sw_ver}=    admin.Get Software Release Name
    ${number}=    Set Variable If    "${sw_ver}" in ${SW_WITH_FHNET_00}        00    80
    Connect to RU from SMOD via SSH      user=${user}
    ...                                  password=${password}
    ...                                  number=${number}
    SSHLibrary.Write                     text=sudo cat /etc/shadow | grep ${user} | cut -d':' -f2-
    sleep                                 5s    reason=Wait for command execiution
    ${default_output}=                   SSHLibrary.Read
    SSHLibrary.Close Connection
    ${hash}=                             Crop first line                  string=${default_output}
    ${hash}=                             Fetch from left     string=${hash}      marker=:
    [Return]          ${hash}

Get sshLoginDelayTimer from RU
    ${sw_ver}=    admin.Get Software Release Name
    ${number}=    Set Variable If    "${sw_ver}" in ${SW_WITH_FHNET_00}        00    80
    Connect to RU from SMOD via SSH     user=serviceuser
    ...                                 password=${SERVICEUSER_DEFAULT_PASSWORD}
    ...                                 flag=${flag}
    ...                                 number=${number}
    SSHLibrary.Write                    text=cat /etc/pam.d/sshd | grep pam_faildelay.so | cut -d"=" -f2-
    Sleep                               5s    reason=Wait for command execiution
    ${default_output}=                  SSHLibrary.Read
#    ${param}=                           Crop last line                  string=${default_output}
#    ${param}=                           Crop first line                 string=${param}
    ${param}=                           Get Line	   ${default_output}	    5
    ${param}=                           Preprocess String               ${param}
    [Return]                            ${param}

Get sshLoginDelayTimer from BTS
    [Arguments]       ${connection}
    ${timer}=         ssh.execute                  command=cat /etc/pam.d/sshd | grep pam_faildelay.so | cut -d"=" -f2-
    ...                                            connection=${connection}
    ${timer}=         Preprocess String       ${timer}
    [Return]          ${timer}

Values for sshLoginDelayTimer should be equal on BTS and RU
    ${connection}=      ssh.Connect to    hostname=${LMP_IP}                    username=${SSH_USERNAME}
    ...                 password=${SSH_PASSWORD}
    ${bts_param}=       Get sshLoginDelayTimer from BTS     connection=${connection}
    ${ru_param}=        Get sshLoginDelayTimer from RU
    Should be equal     ${bts_param}        ${ru_param}
    [Teardown]          ssh.disconnect                      connection=${connection}

Get SSH parameters from BTS
    ${connection}=    ssh.Connect to    hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}
    ${params}=        ssh.execute          command=cat /etc/ssh/sshd_config | grep Client | cut -d" " -f2- | sort | uniq
    ...                                    connection=${connection}
    ${param}=         Get sshLoginDelayTimer from BTS      connection=${connection}
    ssh.disconnect                         connection=${connection}
    ${params}=        Preprocess String        ${params}
    ${param}=         Preprocess String         ${param}
    [Return]          ${params}            ${param}

Get SSH parameters from RU
    ${sw_ver}=    admin.Get Software Release Name
    ${number}=    Set Variable If    "${sw_ver}" in ${SW_WITH_FHNET_00}        00    80
    Connect to RU from SMOD via SSH        user=serviceuser
    ...                                    password=${SERVICEUSER_DEFAULT_PASSWORD}
    ...                                    flag=${flag}
    ...                                    number=${number}
    ${default_output}=    SSHLibrary.Execute Command    cat /etc/ssh/sshd_config | grep Client | cut -d" " -f2- | sort | uniq
    Sleep                                  5s    reason=Wait for command execiution
#    ${default_output}=                     SSHLibrary.Read
    ${param}=                              Get sshLoginDelayTimer from RU
#    ${params}=                             Crop last line                  string=${default_output}
#    ${params}=                             Crop first line                 string=${params}
    ${params}=       Remove String     ${default_output}    ${\n}
    SSHLibrary.Close Connection
#    ${params}=                             Preprocess String         ${params}
    ${param}=                              Preprocess String         ${param}
    [Return]                               ${params}       ${param}

Hashes from BTS and RU for user should be equal
    [Arguments]        ${user}                       ${ru_password}=${SERVICEUSER_DEFAULT_PASSWORD}
    ${bts_hash}=       Get hash from BTS for user    user=${user}
    ${ru_hash}=        Get hash from RU for user     user=${user}       password=${ru_password}
    Should be equal    ${bts_hash}    ${ru_hash}

Banners on RU and BTS should be equal
    ${bts_banner}=      Get SSH banner from BTS
    ${ru_banner}=       Get SSH banner from RU
    Should be equal     ${bts_banner}       ${ru_banner}

SSH Parameters on RU and BTS should be equal
    ${bts_params}       ${bts_param}=      Get SSH parameters from BTS
    ${ru_params}        ${ru_param}=       Get SSH parameters from RU
    Should be equal     ${bts_params}      ${ru_params}
    Should be equal     ${bts_param}       ${ru_param}

Check if login on RU was successful for user
    [Arguments]       ${user}                   ${password}
    [Timeout]         3 minutes
    ${sw_ver}=    admin.Get Software Release Name
    ${number}=    Set Variable If    "${sw_ver}" in ${SW_WITH_FHNET_00}        00    80
    Connect to RU from SMOD via SSH       user=${user}        password=${password}   number=${number}
    [Teardown]                            SSHLibrary.Close Connection

Check if login on RU was not successful for user
    [Arguments]       ${user}       ${password}
    Run keyword and expect error    *
    ...                             Check if login on RU was successful for user    user=${user}    password=${password}

Get SSH banner from RU
    ${sw_ver}=    admin.Get Software Release Name
    ${number}=    Set Variable If    "${sw_ver}" in ${SW_WITH_FHNET_00}        00    80
    ${SERVICEUSER_DEFAULT_PASSWORD}=    Set Variable    Pl(FzaYj5~c5;q
    Connect to RU from SMOD via SSH     user=serviceuser
    ...                                 password=${SERVICEUSER_DEFAULT_PASSWORD}
    ...                                 flag=${flag}
    ...                                 number=${number}
    SSHLibrary.Write                    text=cat /etc/issue
    Sleep                               5s    reason=Wait for command execiution
    ${default_output}=                  SSHLibrary.Read
#    ${banner}=                          get_output_banner     string=${default_output}
    ${banner}=                          Get Line   	${default_output}   5
    ${banner}=                          Preprocess String     ${banner}
    [Return]                            ${banner}

Get SSH banner from BTS
    ssh.Connect to    hostname=${LMP_IP}           username=${SSH_USERNAME}
    ...               password=${SSH_PASSWORD}    alias=bts_connection
    ${banner}=        ssh.execute                  command=cat /etc/ssh/banner
    ...                                            connection=bts_connection
    ${banner}=        Preprocess String            ${banner}
    ssh.disconnect                                 connection=bts_connection
    [Return]          ${banner}

Manually Trigger the Service Account synchronization to RU RF MODULE
    Manually trigger the service account synchronization
