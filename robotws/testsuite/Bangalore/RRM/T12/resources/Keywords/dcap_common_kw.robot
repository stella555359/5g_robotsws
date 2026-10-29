*** Settings ***
Documentation      This file includes all keywords for UTF log collection
...                :copyright: Nokia
...                :author   : Bhakti Kapatel
...                :contact  : bhakti.ka_patel@nokia.com
Library     BuiltIn
Library     Collections
Library     DateTime
Library     OperatingSystem
Library     Process
Library     String
Library     re
Library     ${CURDIR}/../PythonLib/dcap.py
Library     taf.file.pack
Library     taf.sw.dcap.rd       WITH NAME    rd


*** Variables ***
${PORT}             9443
${RD_VERSION}       dcapv3
${SECURE}           True
${ALIAS}            target_bts
${BTS_IP}           10.0.1.2
${BTS_PORT}         443
${USERNAME}         Nemuadmin
${PASSWORD}         nemuuser
${START_SERVICE}              DCAP_Basic_controller start
${STOP_SERVICE}               DCAP_Basic_controller stop
${PATH}             /home/ute/logs


*** Keywords ***
Initialize UTF
    [Documentation]     This KW will initialize UTF application on VM
    Run     ${start_service}
    Sleep   20s

Terminate UTF
    [Documentation]     This KW will terminate the UTF application on VM
    Run     ${stop_service}
    Sleep   20s

Connect To UTF
    [Documentation]     This KW will establish a connection to VM to start log collection
    [Arguments]     ${host}      ${port}     ${rd_version}=${RD_VERSION}    ${secure}=${SECURE}
    rd.Connect To       host=${host}        port=${port}        rd_version=${rd_version}    secure=${secure}
    [Return]        ${ALIAS}

Start UTF Trace
    [Documentation]     KW to ensure collection of necessary logs for the test
    ...         This KW accepts a number as input and translates it into the list of logs needed
    ...         for the test. Select the number options below as needed:
    ...         1 : cp_5g
    ...         2 : cp_5g, immediateSnapshot_5g
    ...         3 : cp_5g, immediateSnapshot_5g, pmFiles5g
    ...         4 : cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog
    ...         5 : cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g
    ...         6 : cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component
    ...         7 : cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component,
    ...         bip_interface_mirroring
    [Arguments]    ${option}    ${host}=${BTS_IP}    ${port}=${BTS_PORT}    ${username}=${USERNAME}    ${password}=${PASSWORD}
    ${gnb_custom_profile}      Create List
    Run keyword If      '${option}'=='1'
    ...          Append To List     ${gnb_custom_profile}     cp_5g
    ...          ELSE IF      '${option}'=='2'
    ...          Append To List     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g
    ...          ELSE IF      '${option}'=='3'
    ...          Append To List     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g    pmFiles5g
    ...          ELSE IF      '${option}'=='4'
    ...          Append To List     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g
    ...          pmFiles5g   condor5gSyslog
    ...          ELSE IF      '${option}'=='5'
    ...          Append To List     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g
    ...          pmFiles5g   condor5gSyslog      SCF5g
    ...          ELSE IF      '${option}'=='6'
    ...          Append To List     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g
    ...          pmFiles5g       condor5gSyslog      SCF5g
    ...          L2Ps_Component
    ...          ELSE IF      '${option}'=='7'
    ...          Append To List     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g
    ...          pmFiles5g          condor5gSyslog      SCF5g
    ...          L2Ps_Component     bip_interface_mirroring
    &{bts_info}    Create Dictionary    host=${host}    port=${port}    username=${username}     password=${password}
    ${output}     rd.Start Trace     tag=start_trace      duration=-1     bts=${bts_info}
    ...           gnb_custom_profile=${gnb_custom_profile}
    Log To Console      \n${output}
    ${trace_id}   Get From Dictionary   ${output}     tracer_id
    [Return]      ${trace_id}

Stop UTF Trace
    [Documentation]     KW to stop UTF logs
    [Arguments]         ${trace_id}
    rd.Stop Trace    trace_id=${trace_id}
    ${UTE_LOG_PATH}    rd.Get Results   result_id=${trace_id}       target_dir=${path}    timeout=200
    Set Global Variable     ${UTE_LOG_PATH}

Extract And Find 5gm File
    [Documentation]    Extracts final dcap file recursively and returns the path of the .5gm file
    [Arguments]    ${zip_file_path}
    ${extracted_dir}    Set Variable    /home/ute/logs/Dcap
    Create Directory    ${extracted_dir}
    ${5gm_file}    Extract Zip Up    ${zip_file_path}     ${extracted_dir}
    Log To Console     \n5gm file path:'${5gm_file}'
    [Return]    ${5gm_file}

Convert To Json
    [Documentation]    This keyword converts multiple .5gm files into JSON files.
    ...                It returns a list of decoded JSON contents.
    [Arguments]    ${host}    @{paths}
    rd.Connect To    host=${host}    port=${PORT}    secure=${SECURE}
    ${decoded_files_json}    Create List
    FOR    ${path}    IN    @{paths}
        ${upload_result}    rd.Upload Encoded File    file_name=${path}
        Get Encoded Files Info
        # ${operation_status}    Get From Dictionary    ${upload_result}    operation_status
        ${session_id}          Get From Dictionary    ${upload_result}    session_id
        # ${grid_id}    Set Variable    ${upload_result['grid_ids'][0]}
        ${file_id}    Set Variable    ${upload_result['file_ids'][0]}
        ${decoded_content_json}    Get Decoded File Contents In JSON    session_id=${session_id}
        ...    data_source_id=${file_id}      tree=n
        Append To List    ${decoded_files_json}    ${decoded_content_json}
    END
    [Return]    ${decoded_files_json}

Get Json Of Extracted Emil
    [Documentation]     This KW shall take .zip file of the dcap and extract it
    ...         Convert the .5gm file to json file
    [Arguments]         ${utf_log_path}     ${vm_ip}
    ${5gm_file}     Extract And Find 5gm File   ${utf_log_path}
    ${decoded_content_json}      Convert To Json      ${vm_ip}       ${5gm_file}
    [Return]    ${decoded_content_json}

Install And Check Dcap Updates
    [Documentation]    Install And Check Dcap Updates
    [Arguments]    ${vm}
    Run      ${start_service}
    Sleep    5s
    ${command}    Set Variable    /sharedvolume/check_updates.sh
    Run Process	  ${command}	  stdout=${CURDIR}/stdout.txt
    # Read the content of the stdout.txt file
    ${stdout_content}    Get File    ${CURDIR}/stdout.txt
    # Extract the installer file name using a regular expression
    ${installer_url}    Get Regexp Matches    ${stdout_content}    utf_lab_installer\.[A-Z0-9]+\.[0-9]+\.sh
    ${installer_file_name}    Get From List    ${installer_url}    0
    # Log the installer file name to the console
    # Log To Console    \nThe installer file name is: ${installer_file_name}
    Run    mv /home/ute/Downloads/${installer_file_name} .
    ${dcap_version_update}    Set Variable    sudo UTE_CLOUD=1 bash ${installer_file_name} ${vm}
    # Log To Console     \n${dcap_version_update}
    Run    ${dcap_version_update}

Verify Pattern Is Present In Json File
    [Documentation]    Verify Pattern Is Present In Json File
    [Arguments]    ${file}    ${pattern}
    ${result}       Parse Emil Json File For Message     ${file}    ${pattern}
    Log To Console      ${result}
    Pass Execution If    ${result}    should be true
    [Return]        ${result}
