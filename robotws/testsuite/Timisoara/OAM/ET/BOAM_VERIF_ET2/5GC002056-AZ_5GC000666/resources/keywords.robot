*** Settings ***
Documentation
...    Author: pawel.rokicki@nokia.com
...    Maintainer: Zygmunt.Rugowski@nokia.com
...    Description: 5gNB snapshot collecting - parity for 5GC000470-E

Library    String
Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin   WITH NAME   admin
Library    XML  lxml=True
Library    SSHLibrary    WITH NAME    ssh_lib
Library    keywords.py

*** Variables ***
${mrbtsId}=    ${tl.gnbs[0].instance_id}
${VM_IP}=    ${tl.test_pc.default_ssh_connection_details.addr}
${VM_username}=    ${tl.test_pc.default_ssh_connection_details.username}
${VM_password}=    ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***
Get External Snapshot
    [Documentation]
    ...  Initiates snapshot collecting and sends it to remote LSS server
    [Arguments]    ${COVERAGE}
    ...            ${timeout}=20min
    admin.get_remote_snapshot    coverage=${COVERAGE}    timeout=${timeout}

Extract Snapshot
    [Documentation]
    ...  Extracts snapshot.zip to directory
    [Arguments]    ${snapshot_path}
    ...            ${extract_directory}
    run keyword and ignore error    empty directory    ${extract_directory}
    Run    unzip ${snapshot_path} -d ${extract_directory}

Check For Summary File
    [Documentation]
    ...  Checks for snapshot file list
    [Arguments]    ${extract_directory}
    sleep    5s
    OperatingSystem.File Should Exist    ${extract_directory}/snapshot_file_list.txt

Check If File Is Not Empty
    [Documentation]
    ...  Checks if file is not empty
    [Arguments]    ${filename}
    File Should Not Be Empty    ${filename}

Collect Snapshot
    [Documentation]
    ...  Initiate snapshot collection, wait for max 15 minutes for it to collect and download
    [Arguments]    ${NAME}
    ...            ${COVERAGE}
    Wait Until Keyword Succeeds    5x    5 minutes    admin.get_snapshot    target_file_name=${NAME}
    ...                       coverage=${COVERAGE}

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    admin.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    ${lssIPaddress}
    Set To Dictionary    ${list_param_to_change}    lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    admin.perform_parameter_recommissioning    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip

Assert lssConfig parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${BTS_info}    admin.get detected hw info
    ${mrbts_path}    Set Variable   ${BTS_info['systemModules'][0]['cabinetId']['internal']}
    ${smod_location_path}      Fetch From left      ${mrbts_path}     /EQM
    ${lss_dict}=    admin.get_parameters
    ...                dist_name=${smod_location_path}/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...                pattern=lss
    Dictionary Should Contain Value    ${lss_dict['lssConfig']}    ${lssIPaddress}
    Dictionary Should Contain Value    ${lss_dict['lssConfig']}    ${${lssPortNo}}

Check for existence of remote snapshot
    [Arguments]    ${host}
    ...            ${user}
    ...            ${pass}
    ...            ${dir}
    ssh_lib.Open Connection   ${host}
    ssh_lib.Login    ${user}    ${pass}
    ${FileList}=    ssh_lib.List Directory    ${dir}
    log    ${FileList}
    Should Contain Match    ${FileList}    Snapshot_MRBTS-${mrbtsId}*

Remove external snapshot
    [Arguments]    ${dir}
    ssh_lib.Execute Command    rm -rf ${dir}/*${mrbtsId}*

Get List of All Snapshot Files
    [Arguments]    ${snapshot_path}    ${stream}    ${tlda_path}=/home/ute/    ${result_directory_path}=/home/ute/tlda/result
    ...        ${tlda_extract_directory}=/home/ute/tlda
    ${file_name}=    Set Variable    Technical_Log_Decoder_Analyzer_linux-${stream}.zip
    download_from_artifactory    ${stream}    ${file_name}    ${tlda_path}
    run     unzip ${tlda_path}${file_name} -d ${tlda_extract_directory}
    run     python ${tlda_extract_directory}/tlda.py --techlog_path ${snapshot_path} --only decompress --output ${result_directory_path}
    @{snapshot_files}=    list_all_snapshot_files    ${result_directory_path}/extracted
    run    rm -r /home/ute/tlda
    [Return]    ${snapshot_files}

Get List of All Mandatory Files
    [Arguments]    ${stream}    ${result_directory_path}=/tmp/
    ${file_name}=    Set Variable    snapshot_documentation-${stream}.tgz
    download_from_artifactory    ${stream}   ${file_name}    ${result_directory_path}
    unpack_documentation    ${result_directory_path}${file_name}     ${result_directory_path}snapshot_documentation-${stream}
    ${unpacked_directory_path}    Set Variable    ${result_directory_path}snapshot_documentation-${stream}
    @{mandatory_files}=    get_list_of_mandatory_files    ${unpacked_directory_path}/${stream}_trbl_log_list.csv
    [Return]    ${mandatory_files}
