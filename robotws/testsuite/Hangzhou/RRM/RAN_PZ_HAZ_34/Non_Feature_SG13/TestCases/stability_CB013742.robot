*** Settings ***
Documentation     Stability case
Test Timeout      120 minutes
Suite Setup       Sg13 Common Suite Setup
Suite Teardown    Sg13 Common Suite Teardown
Test Setup    SG13 Common Test Setup    ${allowed_faults_ids}
Test Teardown    SG13 Common Test Teardown
Force Tags    spark    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABIOB1_ABIPB2_1xAEHC    7_5_UTE5G402T37374


Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/internal_resource/internal_resource.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
...          WITH NAME    nrdim_get_tput
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


*** Variables ***
${CONFIG_DIR_PATH}         ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${SCFC_NAME}    scfc_stability_case01.xml
${UE_ID}       1
${UE_NUM_SA}    2
${allowed_faults_ids}    61652,4654,61524,4655,61649,4592
${TS_CASE_LOG_PATH}      ${TEST_LOG_DIRECTORY()}/All
${NRCELL1_CELLID}          612335616

&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
...                      L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...                      NUMBER_OF_FILES=30     FILE_SIZE_MBYTES=100


*** Test Cases ***
Case05_CB013742 RRC Reconfiguration Stability Check
    Step1:Commission the above configuration on WebUI
    Step2:attach UEs and send full buffer and check logs
    ${total_counter_001}    ${total_counter_002}=    Step3:Set attenuation values    10
    run keyword and continue on failure    Step4:Check Cell Counter Values
    ...    ${total_counter_001}    ${total_counter_002}
    step5:stop all UEs data and detach all UEs

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Start Collecting GNB Syslog in 'before_onair' File
    Log To Console    Modify GNB swconfig
    Modify GNB swconfig
    # debug purpose using case local SCFC
#   ${Golden_SCF_Path}=    CI_commssion.Get SCF File Path    testline=${TL_NAME}
#   ...    stream=${SW_VERSION}

    ${Golden_SCF_Path}    Set Variable    ${CONFIG_DIR_PATH}/scfc_stability_case01.xml

    Set Test Variable    ${Golden_SCF_Path}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}${SCFC_NAME}
    copy_file    ${Golden_SCF_Path}    ${scfc_path}
    Perform Full Commission     ${scfc_path}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-37374/NRBTS-37374   actCoverageNonCoherentUes
    ...    true    online
    Perform online change value    MRBTS-37374/NRBTS-37374/NRPMRNL-1    miNrRRCC
    ...    15min    online
    TAF_ADMIN.teardown admin    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    ${dl_peak_tput}   Get theoretical throughput from nrdim    SCF_Path=${scfc_path}
    set suite variable    ${dl_peak_tput}
    Log To Console   \n-------------Theoretical thp is ${dl_peak_tput}---------------
    ${parent_dir}=    Join Path    ${CURDIR}    ..
    set suite variable    ${parent_dir}
    Stop Collecting GNB Syslog in 'before_onair' File


Step2:attach UEs and send full buffer and check logs
    Log To Console   \n-------------step2:attach UEs--------------
    Start capture only gnb syslog in 'after_onair' file
	FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	    Log To Console    UE${num} attachs
	    Spark UE Attach    ue_index=${num}    power_reset=true
	    Wait '10s' for stabible

	    # Send UL Traffic only, rate 20M
	    Log To Console    UE${num} sending UL traffic

	    Spark UE Send UL Traffic    ue_index=${num}    send_traffic=2MKbits/sec
	    ...    send_duration=900    apn_address=dxdata8    ue_mode=None
    END

#   record cell throughput and compare with previsous throughput
	Wait '10s' for stabible
	${cellsid}    create list    ${NRCELL1_CELLID}
	Log To Console   ${cellsid}
    Spark UE Check Tput    ue_index=${num}    direction=ul    expect_traffic=2
    ...    check_source=aasyslog    duration=2m    cells=${cellsid}
    ...    target_avg_percent=0.80    min_percent=0.75
    Stop capture only gnb syslog in 'after_onair' file
Step3:Set attenuation values
    [Arguments]    ${loop_times}=1

    Log To Console    \n-------------Step3: Set attenuation values (${loop_times} times)---------------

    ${pa_vendor}=    Set Variable    HJ
    ${pa_ip}=        Set Variable    10.64.56.166
    ${pa_port}=      Set Variable    50000
    ${cell_id}=      Set Variable    0

    # Initialize accumulator variables
    ${total_counter_001}=    Set Variable    0
    ${total_counter_002}=    Set Variable    0

    # Fix: correct step parameters
    ${sequence1}=    Generate Integer Sequence    10    60    50
    ${sequence2}=    Generate Integer Sequence    60    10    -50
    Log    Generated sequence1: ${sequence1}
    Log    Generated sequence2: ${sequence2}
    Start GNB Ttitrace With Streaming Mode
    FOR    ${cycle}    IN RANGE    ${loop_times}
        Log To Console    Starting attenuation cycle ${cycle + 1}/${loop_times}

        # Ascending sequence: 40 -> 60
        FOR    ${value}    IN    @{sequence1}
            Log    Setting attenuation value: ${value}
            Set PA Multi Channel Value    ${pa_vendor}    ${pa_ip}    ${pa_port}    ${value}

        END
        Sleep    5s
        # Descending sequence: 60 -> 40
        FOR    ${value}    IN    @{sequence2}
            Log    Setting attenuation value: ${value}
            Set PA Multi Channel Value    ${pa_vendor}    ${pa_ip}    ${pa_port}    ${value}

        END
        Sleep    5s
        Log To Console    Completed attenuation cycle ${cycle + 1}/${loop_times}

        # Get counter and accumulate
        # ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        # Sleep    ${remaining_time}
        ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
        Log    Downloaded PM counter file: ${counter_file}

        # Get counter values M55124C03001 and M55124C03002 from the downloaded file
        ${counter_001}=    get_counter_value_from_counter_file
        ...    counter_file=${counter_file}    counter_id=M55124C03001    cell_id=${cell_id}
        ${counter_002}=    get_counter_value_from_counter_file
        ...    counter_file=${counter_file}    counter_id=M55124C03002    cell_id=${cell_id}

        Log To Console    Cycle ${cycle + 1} - M55124C03001 value: ${counter_001}
        Log To Console    Cycle ${cycle + 1} - M55124C03002 value: ${counter_002}

        # Accumulate counter values
        ${total_counter_001}=    Evaluate    ${total_counter_001} + ${counter_001}
        ${total_counter_002}=    Evaluate    ${total_counter_002} + ${counter_002}

        Log To Console    Running total - M55124C03001: ${total_counter_001}
        Log To Console    Running total - M55124C03002: ${total_counter_002}
    END

    Log To Console    Final total counters - M55124C03001: ${total_counter_001}, M55124C03002: ${total_counter_002}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TS_CASE_LOG_PATH}
    # Return accumulated counter values
        # Compress pcap file and delete original file
    IF    "${pacp}" != "${EMPTY}" and "${pacp}" != "None"
        Log To Console    Compressing pcap file: ${pacp}
        Compress Pcap File    ${pacp}
    ELSE
        Log    Warning: No pcap file path returned from Stop GNB Ttitrace    WARN
    END
    RETURN    ${total_counter_001}    ${total_counter_002}

Set PA Multi Channel Value
    [Documentation]    Set attenuation values for multiple PA channels simultaneously
    [Arguments]    ${pa_vendor}    ${pa_ip}    ${pa_port}    ${value}

    # Create PA configuration for all channels
    ${pa_channel_1}=    Create List    ${pa_vendor}:${pa_ip}:${pa_port}:5:${value}
    ${pa_channel_2}=    Create List    ${pa_vendor}:${pa_ip}:${pa_port}:6:${value}
    ${pa_channel_3}=    Create List    ${pa_vendor}:${pa_ip}:${pa_port}:7:${value}
    ${pa_channel_4}=    Create List    ${pa_vendor}:${pa_ip}:${pa_port}:8:${value}

    Log    PA Channel commands: ${pa_channel_1}, ${pa_channel_2}, ${pa_channel_3}, ${pa_channel_4}

    # Set all channels simultaneously
    Set Attenuation Arbitrary Values    ${pa_channel_1}    time_interval=1s
    Set Attenuation Arbitrary Values    ${pa_channel_2}    time_interval=1s
    Set Attenuation Arbitrary Values    ${pa_channel_3}    time_interval=1s
    Set Attenuation Arbitrary Values    ${pa_channel_4}    time_interval=1s

Get theoretical throughput from nrdim
    [Arguments]    ${SCF_Path}    ${pcellid}=0
    ${dl_expect_pcell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${SCF_Path}    cell_id=${pcellid}
    [Return]    ${dl_expect_pcell}[0]

Add RD
    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt
    ...    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt


Set UE pos
    Set Mcs3 Channel Phase And Attenuation    ${parent_dir}/TestData/${ATT_FILE_PATH}
    ...    ${parent_dir}/TestData/${PHASE_FILE_PATH}    frequency=2450_1_ALL


Modify GNB swconfig
    ${cur_relative_dir}    set variable
    ...    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/Non_Feature_SG13/TestCases
    ${sw_relative_dir}    set variable    commissionings/HGZ
    ${swconfig_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}
    ...    ${sw_relative_dir}
    Log To Console    ${swconfig_base_path}
    setup_txt    src_file=${swconfig_base_path}/${TL_NAME}/swconfig.txt
    ...    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:15             #as PM counter period update to 15/15=1min
    add_txt_node    0x1003F:1         #AaSysLogInputLevel, 0 = disable 1 = debug
    ...    2 = info 3 = warning 4 = error 5 = vip 6 = disable
    add_txt_node    0x10040:2         # SYSLOG output severity prints (0=disable
    ...    1=debug 2=info 3=warning 4=error 5=vip 6=disable)
    add_txt_node    0x10041:5         # Output mode which devices prints are forwarded
    ...    (0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid)
    add_txt_node    0x5900B9:1        # rdPdcchDmrsScramblingId
    add_txt_node    0x58012d:3        # k1min=4
    add_txt_node    0x5800f4:4        # k2min=4
    teardown_txt
    GNB Upload Swconfig    ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt

Generate Integer Sequence
    [Documentation]    Generate an integer sequence with specified step size
    ...               Supports both positive and negative step values
    ...               Returns a list of integers
    [Arguments]    ${start_value}    ${end_value}    ${step_size}

    # Log    Generating integer sequence: start=${start_value}, end=${end_value},
    # ...    step=${step_size}

    # Validate step size is not zero
    IF    ${step_size} == 0
        Fail    Step size cannot be zero
    END

    @{sequence}=    Create List
    ${current_value}=    Convert To Integer    ${start_value}
    ${end_value}=        Convert To Integer    ${end_value}
    ${step_size}=        Convert To Integer    ${step_size}

    # Handle positive step size (increasing sequence)
    IF    ${step_size} > 0
        WHILE    ${current_value} <= ${end_value}
            Append To List    ${sequence}    ${current_value}
            ${current_value}=    Evaluate    ${current_value} + ${step_size}
        END
    ELSE
        # Handle negative step size (decreasing sequence)
        WHILE    ${current_value} >= ${end_value}
            Append To List    ${sequence}    ${current_value}
            ${current_value}=    Evaluate    ${current_value} + ${step_size}
        END
    END

    Log    Generated integer sequence: ${sequence}
    RETURN    ${sequence}

Step4:Check Cell Counter Values
    [Documentation]    Check PM counters M55124C03001 and M55124C03002 for NECUP ratio validation
    [Tags]    CB013742    counter_check
    [Arguments]    ${total_counter_001}    ${total_counter_002}

    Log To Console    \n-------------Step4: Check Cell Counter Values---------------

    # Check counters for M55124C03001 and M55124C03002
    Check NECUP Counter Ratio    ${total_counter_001}    ${total_counter_002}

Check NECUP Counter Ratio
    [Documentation]    Check NECUP counter ratio and validate it's >= 99.90%
    [Arguments]    ${counter_001}    ${counter_002}

    Log    Received accumulated counter values:
    Log    M55124C03001 total value: ${counter_001}
    Log    M55124C03002 total value: ${counter_002}

    # Validate counters are greater than 0
    Should Be True    ${counter_001} > 0
    ...    M55124C03001 should be greater than 0, got: ${counter_001}
    Should Be True    ${counter_002} > 0
    ...    M55124C03002 should be greater than 0, got: ${counter_002}

    # Calculate ratio: M55124C03001 / M55124C03002 * 100
    ${ratio}=    Evaluate    (${counter_002} / ${counter_001}) * 100
    ${ratio_rounded}=    Evaluate    round(${ratio}, 2)

    Log    NECUP Counter Ratio: ${ratio_rounded}%

    # Validate ratio is >= 99.90%
    ${ratio_ok}=    Evaluate    ${ratio} >= 99.90

    IF    not ${ratio_ok}
        # Generate detailed error message
        ${error_msg}=    Set Variable    NECUP Counter Ratio Check FAILED!
        ${error_msg}=    Set Variable    ${error_msg}\nAccumulated M55124C03001: ${counter_001}
        ${error_msg}=    Set Variable    ${error_msg}\nAccumulated M55124C03002: ${counter_002}
        ${error_msg}=    Set Variable    ${error_msg}\nCalculated Ratio: ${ratio_rounded}%
        ${error_msg}=    Set Variable    ${error_msg}\nExpected: >= 99.90%
        ${error_msg}=    Set Variable    ${error_msg}\nResult: FAIL

        Log    ${error_msg}    ERROR
        Fail    ${error_msg}
    ELSE
        ${success_msg}=    Set Variable    NECUP Counter Ratio Check PASSED!
        ${success_msg}=    Set Variable    ${success_msg}\nAccumulated M55124C03001: ${counter_001}
        ${success_msg}=    Set Variable    ${success_msg}\nAccumulated M55124C03002: ${counter_002}
        ${success_msg}=    Set Variable    ${success_msg}\nCalculated Ratio: ${ratio_rounded}%
        ${success_msg}=    Set Variable    ${success_msg}\nExpected: >= 99.80%
        ${success_msg}=    Set Variable    ${success_msg}\nResult: PASS

        Log    ${success_msg}    INFO
    END

Step5:stop all UEs data and detach all UEs
    Log To Console   \n-------------step5:stop all UEs data and detach all UEs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        # Spark UE Stop traffic    dl    ue_index=${num}
        Spark UE Detach    ue_index=${num}
    END



Compress Pcap File
    [Documentation]    Compress pcap file using tar and remove original file
    [Arguments]    ${pcap_file_path}

    # Check if file exists
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${pcap_file_path}
    IF    not ${file_exists}
        Log    Warning: Pcap file does not exist: ${pcap_file_path}    WARN
        RETURN
    END

    # Get file information
    ${file_dir}=     Get File Directory    ${pcap_file_path}
    ${file_name}=    Get File Name         ${pcap_file_path}
    ${base_name}=    Get File Base Name    ${pcap_file_path}

    # Generate compressed file name (original_name.tar.gz)
    ${compressed_file}=    Set Variable    ${file_dir}/${base_name}.tar.gz

    Log To Console    Compressing ${file_name} to ${base_name}.tar.gz

    # Use tar command to compress file (-C specifies directory to avoid full path)
    ${result}=    Run Process    tar    -czf    ${compressed_file}    -C    ${file_dir}
    ...    ${file_name}    timeout=300s    # 5 minute timeout

    # Check if compression was successful
    IF    ${result.rc} == 0
        Log To Console    Successfully compressed to: ${compressed_file}

        # Verify compressed file exists
        File Should Exist    ${compressed_file}

        # Remove original file
        Remove File    ${pcap_file_path}
        Log To Console    Original pcap file removed: ${pcap_file_path}

        # Log compression information
        ${original_size}=    Get File Size    ${compressed_file}
        Log    Compressed file created: ${compressed_file} (size: ${original_size} bytes)

    ELSE
        Log    ERROR: Failed to compress pcap file    ERROR
        Log    tar command output: ${result.stdout}    ERROR
        Log    tar command error: ${result.stderr}    ERROR
        Fail    Failed to compress pcap file: ${pcap_file_path}
    END

Get File Directory
    [Documentation]    Get the directory path of a file
    [Arguments]    ${file_path}
    ${dir_path}=    Evaluate    os.path.dirname("${file_path}")    modules=os
    RETURN    ${dir_path}

Get File Name
    [Documentation]    Get the file name (including extension)
    [Arguments]    ${file_path}
    ${file_name}=    Evaluate    os.path.basename("${file_path}")    modules=os
    RETURN    ${file_name}

Get File Base Name
    [Documentation]    Get the base file name (without extension)
    [Arguments]    ${file_path}
    ${file_name}=    Get File Name    ${file_path}
    ${base_name}=    Evaluate    os.path.splitext("${file_name}")[0]    modules=os
    RETURN    ${base_name}