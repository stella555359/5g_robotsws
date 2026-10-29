*** Settings ***
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    ../python/file_handler.py    WITH NAME    FH
Library    taf.sw.dcap.rd    WITH NAME    dcap
Library    taf.transport.ssh    WITH NAME    sshtrans
Library    taf.converters.emil    WITH NAME    emil_converter
Resource   variables/Rjio_variables.robot


*** Keywords ***
save_full_snapshot
    [Arguments]     ${snapshot_path}   ${connection}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    OperatingSystem.Join Path     ${snapshot_path}    snapshot_${timestamp}.zip
    coam.Get Snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full
    ...    timeout=1500    connection=${connection}

Start_DCAP
    [Arguments]    ${mplane_ip}
    dcap.connect_to  host=10.58.239.215   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    # @{gnb_trace_custom_profile}    Create List    controlPlane5g    SCF5g    condor5gSyslog
    @{gnb_trace_custom_profile}    Create List    controlPlane5g    condor5gSyslog
    &{bts1_info}   create dictionary  host=${mplane_ip}   port=443    username=Nemuadmin    password=nemuuser
    ${output}    dcap.start_trace     duration=-1    bts=&{bts1_info}
    # ...    gnb_trace_profile=dcap-lite-default
    ...    gnb_custom_profile=${gnb_trace_custom_profile}
    ...    bts_trace_profile=dcap-lite-default     wait_for_activation=True    timeout=1800
    ${trace_id}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable    ${trace_id}
    BuiltIn.Log to console     [ INFO ]: DCAP Lite Trace started.

Stop_DCAP
    dcap.stop_trace    trace_id=${trace_id}
    log    "DCAP logging stopped"
    BuiltIn.Log To Console     ${trace_id}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${dcap_log_file}    OperatingSystem.Normalize Path    ${TS_CASE_LOG_PATH}/DCAP_logs
    Create Directory    ${dcap_log_file}
    # Set Suite Variable    ${dcap_log_file}    ${common_log_file_path}/${current_file_name}/${time_stamp}/${TEST_NAME}/
    Set Suite Variable    ${dcap_log_file}
    dcap.get_results    result_id=${trace_id}    target_dir=${dcap_log_file}    timeout=1800

DCAP_EMIL_DECODER
    [Documentation]     Emil Decode to CSV
    ...     1. extract data
    ...     2. filter 5gm file and add in Single folder
    ...     3. pass the isted file from dirct
    [Arguments]     ${Utf Folder Path}
    ...        ${UTF IP}=10.58.239.215
    ${Extracted Folder Path}    Extract UTF Downloaded File    utf file path=${Utf Folder Path}
    ${List of emil file}    Filter Emil Log    Extracted Folder Path=${Extracted Folder Path}
    ${dcap}  Create Dictionary
    ...    host=${UTF IP}    port=443    username=utfuser    password=utfadmin!
    ${Decoded_emil_folder}    OperatingSystem.Create Directory    path=${Utf Folder Path}/Decoded_emil_folder
    ${length}    Get Length    item=${List of emil file}
    FOR    ${5gmfile}    IN RANGE    ${length}
        BuiltIn.Set Test Variable   ${Decoded_emil_path}    ${Utf Folder Path}/Decoded_emil_folder
        ${5gm_file_Path}    BuiltIn.Convert To String    ${List of emil file}[${5gmfile}]
        Log    ${Utf Folder Path}/Decoded_emil_folder
        emil_converter.create_emil_converter_for_source    name=emil_json
        ...    file_path_pattern=${5gm_file_Path}
        ...    output_directory=${Decoded_emil_path}
        ...    dcap=${dcap}
        emil_converter.setup    emil_json
        emil_converter.convert    emil_json
        emil_converter.teardown    emil_json
    END
    RETURN    ${Decoded_emil_path}

Extract UTF Downloaded File
    [Documentation]    Keyword Extract the ziped UTF downloaded file
    ...     : Using linux command can we able to achive unzip -r filename.zip
    ...     :Using Python standalone can be done same.
    ...     :Param ${utf file path}
    ...     :Return ${TARGET PATH}
    [Arguments]    ${utf file path}
	BuiltIn.Log To Console    message=[ INFO ]: Started UTF File Extraction
	BuiltIn.Set Test Variable    ${TARGET PATH}     ${utf file path}/Extracted
	OperatingSystem.Create Directory    path=${TARGET PATH}
    Sleep    10s
	${status}    FH.Unzip Folder    zip_file_path=${utf file path}    target_path=${TARGET PATH}
    Sleep    10s
    # Should Be Equal    ${status}    ${True}    [ ERROR ]: UTF File Not extracted Properly.
    BuiltIn.Log To Console    message=[ INFO ]: UTF File Extraction completed. Stored Path: ${TARGET PATH}
    RETURN    ${TARGET PATH}

Extraction of nest loop
    [Arguments]    ${Files Inner Folder}    ${Avaialble_control_plane_file}    ${Extracted Folder Path}
    ...    ${item}    ${Inner Folder}
    FOR   ${5gm File}    IN    @{Files Inner Folder}
        BuiltIn.Convert To String    ${5gm File}
        @{String_split}    Split String    string=${5gm File}    separator=.
        IF   '${String_split}[-1]' == '5gm'
            Collections.Append To List    ${Avaialble_control_plane_file}
            ...    ${Extracted Folder Path}/${item}/${Inner Folder}/${5gm File}
        END
    END

Avoid_rf_3_1_2_for nested loop
    [Arguments]    ${Inner Folders}    ${Extracted Folder Path}   ${item}
    ...    ${Avaialble_control_plane_file}
    FOR    ${Inner Folder}   IN   @{Inner Folders}
        ${Files Inner Folder}    OperatingSystem.List Files In Directory
        ...    path=${Extracted Folder Path}/${item}/${Inner Folder}
        Extraction of nest loop    ${Files Inner Folder}    ${Avaialble_control_plane_file}
        ...    ${Extracted Folder Path}    ${item}    ${Inner Folder}
    END

Filter Emil Log
    [Documentation]    Filter Emil logs From UTF Extracted folder
    ...    :params ${Extracted Folder Path}
    [Arguments]    ${Extracted Folder Path}
    ${Listing Extracted item}    OperatingSystem.List Directory    ${Extracted Folder Path}
    ${Folder Name}    UTF Inner Folder Name
    @{Avaialble_control_plane_file}    BuiltIn.Create List
    FOR  ${item}  IN  @{Listing Extracted item}
        IF    ${item} == ${Folder Name}
            ${Inner Folders}    OperatingSystem.List Directories In Directory
            ...    path=${Extracted Folder Path}/${item}
            Avoid_rf_3_1_2_for nested loop    ${Inner Folders}    ${Extracted Folder Path}    ${item}
            ...    ${Avaialble_control_plane_file}
            BREAK
        END
    END
    RETURN   @{Avaialble_control_plane_file}

UTF Inner Folder Name
    [Documentation]    To Find Inner Folder Name By Using DateTime Module
    ...    :Condition - In Case, UTF Folder Name Structure Changes Code Need to be Modify Accordingly.
    ...     As per Current status Inner Folder Structe Designed By Date Time. 
    ...    : Return ${Folder name}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d
    # -%H:%M:%S
    Convert To String    ${time_stamp}
    ${list string}    String.Split String    ${time_stamp}    separator=-
    ${Folder Name}    BuiltIn.Catenate    ${list string}[0]${list string}[1]${list string}[2]
    RETURN    ${Folder Name}
