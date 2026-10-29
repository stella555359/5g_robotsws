*** Settings ***
Documentation      This file includes all keywords for UTF log collection
...                :copyright: Nokia
...                :author   : Bhakti Kapatel
...                :contact  : bhakti.ka_patel@nokia.com
Library     OperatingSystem
Library     Collections
Library     taf.sw.dcap.rd       WITH NAME    rd
Library     DateTime
Library    ../PythonLib/dcap.py
Library     taf.file.pack
Library     Process
Library     BuiltIn
Library     String
Library     re
*** Variables ***
${port}             9443
${rd_version}       dcapv3
${secure}           True
${alias}            target_bts
${bts_ip}           10.0.1.2
${bts_port}         443
${Username}         Nemuadmin
${password}         nemuuser
${start_service}              DCAP_Basic_controller start
${stop_service}               DCAP_Basic_controller stop
${path}             /home/ute/logs

*** Keywords ***
Initialize UTF
    [Documentation]     This KW will initialize UTF application on VM
    Run     ${start_service}
    Sleep   20s

Terminate UTF
    [Documentation]     This KW will terminate the UTF application on VM
    Run     ${stop_service}
    Sleep   20s

Connect to UTF
    [Documentation]     This KW will establish a connection to VM to start log collection
    [Arguments]     ${host}      ${port}     ${rd_version}=${rd_version}    ${secure}=${secure}
    rd.connect_to       host=${host}        port=${port}        rd_version=${rd_version}    secure=${secure}
    [Return]        ${alias}

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
    [Arguments]     ${option}
    ${gnb_custom_profile}=      Create List
    Run keyword if      '${option}'=='1'
    ...          Append to list     ${gnb_custom_profile}     cp_5g
    ...                    ELSE IF      '${option}'=='2'
    ...          Append to list     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g
    ...                    ELSE IF      '${option}'=='3'
    ...          Append to list     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g    pmFiles5g
    ...                    ELSE IF      '${option}'=='4'
    ...          Append to list     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g    pmFiles5g   condor5gSyslog
    ...                    ELSE IF      '${option}'=='5'
    ...          Append to list     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g    pmFiles5g   condor5gSyslog      SCF5g
    ...                    ELSE IF      '${option}'=='6'
    ...          Append to list     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g    pmFiles5g   condor5gSyslog      SCF5g
    ...          L2Ps_Component
    ...                    ELSE IF      '${option}'=='7'
    ...          Append to list     ${gnb_custom_profile}     cp_5g     immediateSnapshot_5g    pmFiles5g   condor5gSyslog      SCF5g
    ...          L2Ps_Component     bip_interface_mirroring
    &{bts_info}=    Create Dictionary    host=10.0.1.2    port=443    username=Nemuadmin     password=nemuuser
    ${output}     rd.start_trace     tag=start_trace      duration=-1     bts=${bts_info}
    ...           gnb_custom_profile=${gnb_custom_profile}
    Log to console      \n${output}
    ${trace_id}   Get From Dictionary   ${output}     tracer_id
    [Return]      ${trace_id}

Stop UTF Trace
    [Documentation]     KW to stop UTF logs
    [Arguments]         ${trace_id}
    rd.stop_trace    trace_id=${trace_id}
    ${utf_log_path}    rd.get_results   result_id=${trace_id}       target_dir=${path}    timeout=200
    Set Global variable     ${utf_log_path}

Extract and Find 5gm File
    [Documentation]    Extracts final dcap file recursively and returns the path of the .5gm file
    [Arguments]    ${zip_file_path}
    ${extracted_dir}    set variable    /home/ute/logs/Dcap
    Create Directory    ${extracted_dir}
    ${5gm_file}    Extract_zip_up  ${zip_file_path}    ${extracted_dir}
    LOG TO CONSOLE     \n5gm file path:'${5gm_file}'
    [Return]    ${5gm_file}

Convert to json
    [Documentation]    This keyword converts multiple .5gm files into JSON files.
    ...                It returns a list of decoded JSON contents.
    [Arguments]    ${host}    @{paths}
    rd.connect_to    host=${host}    port=${PORT}    secure=${SECURE}
    ${decoded_files_json}=    Create List
    FOR    ${path}    IN    @{paths}
        ${upload_result}=    rd.upload_encoded_file    file_name=${path}
        Get Encoded Files Info
        ${operation_status}=    Get From Dictionary    ${upload_result}    operation_status
        ${session_id}=    Get From Dictionary    ${upload_result}    session_id
        ${grid_id}=    Set Variable    ${upload_result['grid_ids'][0]}
        ${file_id}=    Set Variable    ${upload_result['file_ids'][0]}
        ${decoded_content_json}=    Get Decoded File Contents In JSON    session_id=${session_id}    data_source_id=${file_id}      tree=n
        Append To List    ${decoded_files_json}    ${decoded_content_json}
    END
    [Return]    ${decoded_files_json}

Get Json of Extracted Emil
    [Documentation]     This KW shall take .zip file of the dcap and extract it
    ...         Convert the .5gm file to json file
    [Arguments]         ${utf_log_path}     ${vm_ip}
    ${5gm_file}     Extract and Find 5gm File   ${utf_log_path}
    ${decoded_content_json}      Convert to json      ${vm_ip}       ${5gm_file}
    [Return]    ${decoded_content_json}

Install And Check Dcap Updates
    [Arguments]    ${vm}
    Run     ${start_service}
    sleep    5s
    ${command}=    Set Variable   /sharedvolume/check_updates.sh
    ${result} =	Run Process	    ${command}	  stdout=${CURDIR}/stdout.txt
    # Read the content of the stdout.txt file
    ${stdout_content}=    Get File    ${CURDIR}/stdout.txt
    # Extract the installer file name using a regular expression
    ${installer_url}=    Get Regexp Matches    ${stdout_content}    utf_lab_installer\.[A-Z0-9]+\.[0-9]+\.sh
    ${installer_file_name}=    Get From List    ${installer_url}    0
    # Log the installer file name to the console
    Log To Console    \nThe installer file name is: ${installer_file_name}
    Run    mv /home/ute/Downloads/${installer_file_name} .
    ${dcap_version_update}=    set variable    sudo UTE_CLOUD=1 bash ${installer_file_name} ${vm}
    LOG TO CONSOLE     \n${dcap_version_update}
    Run    ${dcap_version_update}

Verify pattern is present in Json file
    [Arguments]    ${file}    ${pattern}
    ${result}       Parse_Emil_Json_File_For_Message     ${file}    ${pattern}
    Log to Console      ${result}
    pass execution if    ${result}    should be true
    [Return]        ${result}
