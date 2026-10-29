*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library           Process
Library           SSHLibrary
Library           taf.sbts.oam.coam.admin  WITH NAME  admin
Library           ../../resources/Emil.py
Resource          ../../resources/ca_IWK.robot


*** Variables ***
${INSTALL_EMIL}                False                                                           # Boolean value that determines if 'Step 1: Install
# Emil' should be executed. Default value: False
${EMIL_FILE_SOURCE_PATH}       C:/Users/sranwro2/Desktop/Emil_RnD_Dat08270839_rev22170.deb     # Absolute path where installation file can be found
# on PC. Default value: C:/Users/sranwro2/Desktop/Emil_RnD_Dat08270839_rev22170.deb
${EMIL_FILE_DESTINATION}       /tmp/Emil_RnD_Dat08270839_rev22170.deb                          # Absolute path to location where EMIL installation
# file can be downloaded on VM. Default value:/tmp/Emil_RnD_Dat08270839_rev22170.deb

${DOWNLOAD_SACK}               False                                                           # Boolean value that determines if 'Step 2: Download
# Sack' should be executed. Default value: False
${UPLOAD_SACK_TO_WIN_PC}       False                                                           # Boolean value that determines if 'Step 3: Copy Sack
# To Windows' should be executed. Default value: False
${SACK_DIR_ON_LINUX}           /opt/nokia/emil/Sacks                                           # Absolute path to directory where SACK should be
# downloaded in 'Step 2: Download Sack' and/or from where SACK should be uploaded to Windows in 'Step 3: Copy Sack To Windows'. Default value:
# /opt/nokia/emil/Sacks
${USER_SW_VERSION}             ${EMPTY}                                                        # SW version defined by user.,
# e.g. SBTS00_ENB_9999_201020_000019. Optional parameter. Default value: ${EMPTY}
${SACK_DIR_ON_WINDOWS}                                                                         # Path from cygvin directory to directory where SACK
# should be downloaded to Windows PC in 'Step 3: Copy Sack To Windows', e.g. /cygdrive/c/Users/wimaxpi/AppData/Local/Emil/Sacks

${CREATE_CSV}                  False                                                           # Boolean value that determines if 'Step 4: Create CSV
# For EMIL' should be executed. Default value: False
${DESTINATION_PATH_FOR_CSV}    /tmp/EMIL_logs/emil.csv                                         # Absolute path where CSV file for EMIL will be saved.
# Default value: /tmp/EMIL_logs/emil.csv


*** Keywords ***
TC__DEV__Emil_env_preparation

    Set Tags    CA-IWK   OWNER-monika.ceglarek@nokia.com    AUTHOR-monika.ceglarek@nokia.com
    ...    MAINTAINER-monika.ceglarek@nokia.com    GROUP_IN_CHARGE-IWK_Pz_WRO_4_Vrf

    Step 1: Install Emil
    Step 2: Download Sack
    Step 3: Copy Sack To Windows
    Step 4: Create CSV For EMIL


Step 1: Install Emil
    Return From Keyword If  not ${INSTALL_EMIL}
    Log  Step 1: Install Emil  console=True

    ${ip}  ${login}  ${password} =  Get PC Data
    Create Directory  ${LOG_PATH}/misc_logs/install_emil

    SSHLibrary.Open Connection  ${ip}
    SSHLibrary.Login  ${login}  ${password}
    SSHLibrary.Get File  ${EMIL_FILE_SOURCE_PATH}  ${EMIL_FILE_DESTINATION}
    Log  EMIL installation  console=True
    ${result} =  Run Process  bash
    ...                       -c
    ...                       sudo mkdir -p /opt/nokia/emil; sudo dpkg --instdir /opt/nokia/emil --install ${EMIL_FILE_DESTINATION} >> script_log
    ...                       cwd=${LOG_PATH}/misc_logs/install_emil
    Log  Script result: ${result}  console=True
    Log  ${result.stdout}; ${result.stderr}
    Should Be Equal AS Integers  0  ${result.rc}  msg=RC is different from 0.
    Log  Installation was successful.  console=True
    [Teardown]  SSHLibrary.Close All Connections


Step 2: Download Sack
    Return From Keyword If  not ${DOWNLOAD_SACK}
    Log  Step 2: Download Sack  console=True

    ${sw_version} =  Get SW Version  ${USER_SW_VERSION}
    ${release}    Fetch From Left    ${sw_version}  _
    ${dir_exists} =  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${SACK_DIR_ON_LINUX}
    IF  not ${dir_exists}
        Create Directory  ${SACK_DIR_ON_LINUX}
    END
    Download Sack  ${release}  ${sw_version}  ${SACK_DIR_ON_LINUX}
    ${sack_path_on_linux} =  Get SACK Directory Path For Parent Directory  ${SACK_DIR_ON_LINUX}
    OperatingSystem.Directory Should Exist  ${sack_path_on_linux}  msg=SACK directory was not found on disc after download.
    Log  Sack ${sack_path_on_linux} was successfully downloaded and extracted.  console=True


Step 3: Copy Sack To Windows
    Return From Keyword If  not ${UPLOAD_SACK_TO_WIN_PC}
    Log  Step 3: Copy Sack To Windows  console=True

    ${sack_path_on_linux} =    Get SACK Directory Path For Parent Directory  ${SACK_DIR_ON_LINUX}
    ${sack_path_on_windows} =  Get SACK Directory Path For Parent Directory  ${SACK_DIR_ON_WINDOWS}

    ${ip}  ${login}  ${password} =  Get PC Data
    SSHLibrary.Open Connection  ${ip}
    SSHLibrary.Login  ${login}  ${password}
    Log  Copying SACK from ${sack_path_on_linux} to ${sack_path_on_windows}...  console=True
    SSHLibrary.Put Directory  ${sack_path_on_linux}  ${sack_path_on_windows}
    Log  Sack was successfully copied to Windows PC.  console=True
    [Teardown]  SSHLibrary.Close All Connections


Get SACK Directory Path For Parent Directory
    [Arguments]  ${parent_dir}
    ${sw_version} =  Get SW Version  ${USER_SW_VERSION}
    ${branch}  ${version}=  Split String  ${sw_version}  separator=_  max_split=1
    ${version} =  Remove String  ${version}  ENB_
    ${path} =  Join Path  ${parent_dir}  ${branch}_IDA_${version}
    [Return]  ${path}


Step 4: Create CSV For EMIL
    Return From Keyword If  not ${CREATE_CSV}
    Log  Step 4: Create CSV For EMIL  console=True

    Create CSV EMIL File  ${DESTINATION_PATH_FOR_CSV}
    Log  CSV file created.  console=True


Create CSV EMIL File
    [Arguments]  ${destination_path}  ${bts_name}=4G_SBTS  ${bts_ip}=192.168.255.129  ${tcp_port}=15004
    ...          ${via_board}=0x00  ${via_cpu}=0x00  ${authenticate}=Yes  ${admin_login}=Nemuadmin
    ...          ${admin_password}=nemuuser  ${ssh_authenticate}=Yes  ${bts_login}=toor4nsn
    ...          ${bts_password}=oZSP0POrRieRtu  ${active_profiles}=Full Call Scenarios
    ${headline} =  Catenate  SEPARATOR=,${SPACE}
    ...                      BTS name
    ...                      BTS IP
    ...                      TCP port
    ...                      Via board
    ...                      Via cpu
    ...                      Authenticate
    ...                      user name
    ...                      password
    ...                      SSH Authenticate
    ...                      SSH Username
    ...                      SSH Password
    ...                      active profiles\r\n
    OperatingSystem.Create File  ${destination_path}  ${headline}

    ${line} =      Catenate  SEPARATOR=,
    ...                      ${bts_name}
    ...                      ${bts_ip}
    ...                      ${tcp_port}
    ...                      ${via_board}
    ...                      ${via_cpu}
    ...                      ${authenticate}
    ...                      \"${admin_login}\"
    ...                      \"${admin_password}\"
    ...                      ${ssh_authenticate}
    ...                      \"${bts_login}\"
    ...                      \"${bts_password}\"
    ...                      \"${active_profiles}\"

    OperatingSystem.Append To File  ${destination_path}  ${line}


Get PC Data
    ${ue_pools_exists} =  Run Keyword And Return Status  Variable Should Exist  ${UE_POOLS}
    IF  not ${ue_pools_exists}
        Import Variables  ${ABSTRACT_LIB_CONFIG}
    END
    ${ue_name} =  Evaluate  list(${UE_POOLS['AndroidUePool']['inline_config']}.keys())[0]
    ${conf} =     Set Variable  ${UE_POOLS['AndroidUePool']['inline_config']['${ue_name}']['CONSTRUCTOR_PARAMETERS']['configuration']}
    [Return]  ${conf['ue_pc_ip']}  ${conf['login']}  ${conf['password']}


TC Setup
    Log  TC Setup  console=True
    Create Log Directories
    Log Variables   level=DEBUG
    Setup Admin  bts_host=192.168.255.129  admin_api_log_dir=${LOG_PATH}/admin_api_logs
    Log To Console  Connection to ADMIN on eNB side started.


TC Teardown
    Log  TC Teardown   console=True
    Create Directory  ${LOG_PATH}/admin_api_logs/
    Teardown All Aliases For Admin
    Log To Console  ADMIN connections closed.

