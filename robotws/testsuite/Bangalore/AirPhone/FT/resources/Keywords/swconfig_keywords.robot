*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: This File contains common keywords which are needed to update
...               gnb and ap swconfig.txt file

Library    OperatingSystem
Library    String
Library    taf.transport.ssh    WITH NAME    ssh
Library    ../Python/SWConfigHelper.py   WITH NAME   swconfig_helper
Resource   ../Variables/general_common_variables.robot

*** Keywords ***
Download SWConfig File From GNB
    [Arguments]    ${sw_config_path}    ${file_name}=swconfig_gnb.txt
    ${gnb_swconfig_local_path}    Download File From Host    host=${GNB_HOST}    username=${GNB_USER}
    ...    password=${GNB_PASS}    remote_path=/ffs/run/swconfig.txt    local_path=${sw_config_path}/${file_name}
    ...    alias=ssh_gnb
    [Return]    ${gnb_swconfig_local_path}

Download SWConfig File From AP
    [Arguments]    ${sw_config_path}    ${file_name}=swconfig_ap.txt
    ${ap_swconfig_local_path}    Download File From Host    host=${AP_HOST}    username=${AP_USER}
    ...    password=${AP_PASS}    remote_path=/ffs/run/swconfig.txt    local_path=${sw_config_path}/${file_name}
    ...    alias=ssh_ap
    [Return]    ${ap_swconfig_local_path}

Download File From Host
    [Arguments]    ${host}    ${username}    ${password}    ${remote_path}    ${local_path}    ${alias}=default
    ssh.Connect_to      hostname=${host}    username=${username}    password=${password}    alias=${alias}
    ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${alias}
    [Teardown]    ssh.disconnect    connection=${alias}
    [Return]    ${local_path}

Modify SWConfig File For GNB
    [Arguments]    ${sw_config_filepath}    ${file_name}=swconfig_gnb_updated.txt    &{kwargs}
    ${dir_path}    ${file}    Split String From Right    ${sw_config_filepath}    separator=/    max_split=1
    ${updated_swconfig_path_gnb}    Generate Swconfig File    sw_config_path=${dir_path}/${file_name}
    ...    downloaded_swconfig_path=${sw_config_filepath}    &{kwargs}
    [Return]    ${updated_swconfig_path_gnb}

Modify SWConfig File For AP
    [Arguments]    ${sw_config_filepath}    ${file_name}=swconfig_ap_updated.txt    &{kwargs}
    ${dir_path}    ${file}    Split String From Right    ${sw_config_filepath}    separator=/    max_split=1
    ${updated_swconfig_path_ap}    Generate Swconfig File    sw_config_path=${dir_path}/${file_name}
    ...    downloaded_swconfig_path=${sw_config_filepath}    &{kwargs}
    [Return]    ${updated_swconfig_path_ap}

Generate Swconfig File
    [Arguments]    ${sw_config_path}    ${downloaded_swconfig_path}    &{kwargs}
    swconfig_helper.load_sw_config_file    ${downloaded_swconfig_path}
    swconfig_helper.update_field    &{kwargs}
    ${updated_swconfig_path}    swconfig_helper.generate_swconfig_file    ${sw_config_path}
    [Return]    ${updated_swconfig_path}

Upload Swconifg File to GNB And Perform Signature
    [Arguments]    ${swconfig_file_path}
    Upload File to Host    host=${GNB_HOST}    username=${GNB_USER}    password=${GNB_PASS}
    ...    local_path=${swconfig_file_path}    remote_path=/ffs/run/swconfig.txt    alias=ssh_gnb
    Perform Crasign of Swconfig in GNB
    Perform Craverify of Swconfig in GNB

Upload Swconifg File to AP And Perform Signature
    [Arguments]    ${swconfig_file_path}
    Upload File to Host    host=${AP_HOST}    username=${AP_USER}    password=${AP_PASS}
    ...    local_path=${swconfig_file_path}    remote_path=/ffs/run/swconfig.txt    alias=ssh_ap
    Perform Crasign of Swconfig in AP
    Perform Craverify of Swconfig in AP

Upload File to Host
    [Arguments]    ${host}    ${username}    ${password}    ${local_path}    ${remote_path}    ${alias}=default
    ssh.Connect_to    hostname=${host}    username=${username}    password=${password}    alias=${alias}
    ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    [Teardown]    ssh.disconnect    connection=${alias}

Perform Crasign of Swconfig in GNB
    ssh.Connect_to    hostname=${GNB_HOST}    username=${GNB_USER}    password=${GNB_PASS}    alias=ssh_gnb
    Perform Crasign    swconfig_remote_path=/ffs/run/swconfig.txt    connection_alias=ssh_gnb

Perform Crasign of Swconfig in AP
    ssh.Connect_to    hostname=${AP_HOST}    username=${GNB_USER}    password=${GNB_PASS}    alias=ssh_ap
    Perform Crasign    swconfig_remote_path=/ffs/run/swconfig.txt    connection_alias=ssh_ap

Perform Crasign
    [Arguments]    ${swconfig_remote_path}    ${connection_alias}
    ${stdout}    ssh.execute    crasign ${swconfig_remote_path}    connection=${connection_alias}
    Should be Empty    ${stdout}    msg= Failed to crasigin swconfig file.
    [Teardown]    ssh.disconnect    connection=${connection_alias}

Perform Craverify of Swconfig in GNB
    ssh.Connect_to    hostname=${GNB_HOST}    username=${GNB_USER}    password=${GNB_PASS}    alias=ssh_gnb
    Perform Craverify    swconfig_remote_path=/ffs/run/swconfig.txt    connection_alias=ssh_gnb

Perform Craverify of Swconfig in AP
    ssh.Connect_to    hostname=${AP_HOST}    username=${GNB_USER}    password=${GNB_PASS}    alias=ssh_ap
    Perform Craverify    swconfig_remote_path=/ffs/run/swconfig.txt    connection_alias=ssh_ap

Perform Craverify
    [Arguments]    ${swconfig_remote_path}    ${connection_alias}
    ${stdout}    ssh.execute    craverify ${swconfig_remote_path}   connection=${connection_alias}
    Should Contain    ${stdout}    craverify    msg= Failed to craverify swconfig file.
    [Teardown]    ssh.disconnect    connection=${connection_alias}
