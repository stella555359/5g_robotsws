*** Settings ***
Documentation
...  Helpfull keyword to download automatically the DIAG.cfg for the feature on UE's PC
...  Author: fabienne.magueur@nokia.com


Library         OperatingSystem
Library         Process
Library         Collections
Library         String

Library         ${CURDIR}/../resources/custom_robot_keywords

*** Variables ***
${artifactory_diag_url}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/your_name/


*** Keywords ***
Update Diag File
    [Arguments]    ${diagcfgtest}

    ${ue_config_file}=    Set variable    %{ABSTRACT_LIB_CONFIG}
    import variables    ${ue_config_file}

    ${diag_file_path}=    set variable    ${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.diag_cfg_path}
    log    ${diag_file_path}
    ${diag_file_name}    Fetch from right    ${diag_file_path}    /


    Download diag file from artifactory    diagcfgtest=${diagcfgtest}    diagFileName=${diag_file_name}
    Save diag file from ue pc    pathToDiagFile=${diag_file_path}
    upload diag file to ue pc    diagFileName=${diag_file_name}
    sleep    10
    Set test variable    ${diag_file_name}    ${diag_file_name}

Download diag file from artifactory
    [Documentation]    This keyword downloads DIAG.cfg file from artifactory
    ...                Name of the file shall be provided as argument
    ...                diagcfgtest: name of the file in artifactory. Ex: DIGA_5G_1732
    ...                diagFileName: target name of the file on Ue PC, extracted from diag_cfg_path in yaml ue configuration file. Ex: DIAG_5G.cfg
    [Arguments]    ${diagcfgtest}    ${diagFileName}

    log    ${artifactory_diag_url}
    ${cmd}      catenate         cd /${logs_path}/;timeout 60 sudo wget     ${artifactory_diag_url}/${diagcfgtest}
    ${resp}     Run         ${cmd}
    log     ${cmd}
    ${resp}     Run         cp ${logs_path}/${diagcfgtest} ${logs_path}/${diagFileName}
    log     ${resp}

Upload diag file to ue pc
    [Documentation]    This keyword downloads DIAG.cfg file from VM to UePC
    ...                Name of the file shall be provided as argument
    ...                diagFileName: target name of the file on Ue PC, extracted from diag_cfg_path in yaml ue configuration file. Ex: DIAG_5G.cfg
    [Arguments]    ${diagFileName}
    copy_files_from_local_to_uepc_server_dir    alias=${Ue_alias}     local_files=${logs_path}/${diagFileName}    timeout=20

Save diag file from ue pc
    [Documentation]    This keyword uploads DIAG.cfg file from UePc to VM
    ...                pathToDiagFile: diag_cfg_path in yaml ue configuration file. Ex: c:/pyroserver/DIAG_5G.cfg
    [arguments]    ${pathToDiagFile}
    copy_files_from_uepc_to_local_dir    alias=${Ue_alias}     remote_files=${pathToDiagFile}    local_dir=${save_path}    timeout=30

Restore Diag File on ue pc
    [Documentation]    This keyword restores DIAG.cfg file saved through "Save diag file from ue pc" on UePc
    ...                diagFileName: target name of the file on Ue PC, extracted from diag_cfg_path in yaml ue configuration file. Ex: DIAG_5G.cfg
    [Arguments]    ${diagFileName}
    copy_files_from_local_to_uepc_server_dir    alias=${Ue_alias}     local_files=${save_path}/${diagFileName}    timeout=20


