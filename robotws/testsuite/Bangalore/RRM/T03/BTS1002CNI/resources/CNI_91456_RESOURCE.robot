*** Settings ***
Documentation
...                 author: Sahadeb Ghosh
...                 contact sahadeb.ghosh@nokia.com
...                 Description: Resource File for CNI-94156
...                 The purpose of the test case is to verify RRC Connection Established Time

Library             String
Library             DateTime
Library             Collections
Library             OperatingSystem
Library             taf.sw.dcap.rd    WITH NAME    rd
Library             taf.transport.ssh    WITH NAME    ssh
Library             taf.config.scf    WITH NAME    scf
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Library             taf.hw.rf_attenuator.attenuator    WITH NAME    at
Resource            ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library             Process
Library             taf.converters.emil    WITH NAME    emil
Library             ./testsuite/Bangalore/RRM/T03/BTS1002CNI/resources/searchTimecalculation.py


*** Variables ***
${bts_ip}                       192.168.255.129
${UE_PC_IP}                     10.45.150.150    # Windows UE PC IP
${BTS_M_plane_ip}               10.58.239.180    # BTS M PLane IP
${Windows_user}                 inbabtslabuser    # Windows UE PC username
${Windows_pass}                 BT5l@bus3rl0g1n    # Windows UE PC password
${gNB_IP}                       192.168.255.129    # gnb LMP IP
&{BTS_INFO}                     host=${BTS_M_plane_ip}    port=${port}    # BTS details
${attenuator_host}              10.45.153.196    ###PVA_DETAILS###    # Attenuator IP
@{at_channel1}                  ${9}    ${10}    ${11}    ${12}    # Attenuation port used
@{at_channel2}                  ${13}    ${14}    ${15}    ${16}    # Attenuation post used
${attenuator_port}              ${3001}    # Attenuator Port
@{ports1}                       ${9}    ${10}    ${11}    ${12}
@{ports2}                       ${13}    ${14}    ${15}    ${16}
@{atvalues0}                    90dB    90dB    90dB    90dB
@{atvalues1}                    70dB    70dB    70dB    70dB
@{atvalues2}                    0dB    0dB    0dB    0dB
${at_vendor}                    TOPYOUNG    # PVA vendor name
${at_model}                     TAS_16T16_0_2G6_90_1S_DEJS    # PVA model number
${DCAP_host}                    10.41.209.117    ###DCAP_DETAILS###
${Default_DCAP_duration}        30
${dcap_log_timeout}             1200
${port}                         443
${secure}                       True
${rd_version}                   dcapv3
${PATH}                         /home/ute/dcapfiles/
${Unzip_Path}                   /home/ute/dcapfiles/Extracted/
${TEST_LOG_DIRECTORY}           /home/ute/Dcap
${dcap_username}                utfuser
${dcap_password}                utfadmin!
${UE_file}                      ta_ue_config.yaml    ###UE_DETAILS###
${direction}                    dl
@{UE_alias}                     UE_1
@{capabilities}                 Legacy_1
@{data_transfer_protocol}       UDP
${ssh_port}                     443
${EXTENSION_CP1}                .5gm    ###EMIL_DETAILS###
${EXTENSION_CP2}                .emil   ###EMIL_DETAILS###
${CSVTYPE}                      .csv    ###EMIL_DETAILS###
${emil_path}                    C:\\Emil
${emil_profile1}                C:\\Emil\\profiles\\Auto\ select
${emil_profile2}                C:\\Emil\\profiles\\5G
${uepc_Log_path}                C:\\automationLOG
${connection}                   Active_Session
${PATTERN1}                     (?i)\\d{2}:\\d{2}:\\d{2}\\.\\d{6}[,;]"rrcSetupRequest"    ###capture RRC message pattern
${PATTERN2}                     (?i)\\d{2}:\\d{2}:\\d{2}\\.\\d{6}[,;]"rrcSetupComplete"    ###capture RRC message pattern
${Change_Permission}            sudo chmod -R 777 /home/ute/dcapfiles/


*** Keywords ***
Verify Emil logs timestamp
    [Documentation]    Convert emil file and verify
    Convert Emil File to CSV to check timestamp

Convert Emil File to CSV to check timestamp
    [Documentation]    Convert Emil logs collected from DCAP
    Log to console    \nConverting Emil logs and verifying
    ${path1}    Set Variable    ${PATH}
    Set Test Variable    ${path1}
    ${source_paths}    Set Variable    ${Unzip_Path}
    create Directory    ${Unzip_Path}
    ${files}    OperatingSystem.List Files In Directory    ${path1}
    FOR    ${zip}    IN    @{files}
        Run Process    unzip    ${path1}/${zip}    cwd=${source_paths}
        OperatingSystem.Copy File    ${path1}/${zip}    ${out}
    END
    ${check}    OperatingSystem.List Directory    ${source_paths}
    FOR    ${value}    IN    @{check}
        ${date}    Set Variable    ${value}
        BREAK
    END
    ${it}    OperatingSystem.List Directory    ${source_paths}/${date}
    Create Directory    ${source_paths}/${date}/Emil_log
    FOR    ${out_index}    IN    @{it}
        ${all_files}    OperatingSystem.List Directory    ${source_paths}/${date}/${out_index}
        ${filtered_files}    Evaluate    [file for file in ${all_files} if file.endswith(('${EXTENSION_CP1}', '${EXTENSION_CP2}'))]    modules=os
        Log Many    ${filtered_files}
        FOR    ${file}    IN    @{filtered_files}
            ${source}    Set Variable    ${source_paths}/${date}/${out_index}/${file}
            ${dest}    Set Variable    ${source_paths}/${date}/Emil_log
            Copy File    ${source}    ${dest}
        END
    END
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=mcg_vm
    Run keyword And Ignore Error    Start Emil To Convert Emil File To Csv
    ...    source_path=${dest}

Start Emil To Convert Emil File To Csv
    [Documentation]    Upload Emil logs to MCG PC and convert emil to csv file
    [Arguments]    ${source_path}
    ${source_emil_file}    OperatingSystem.List Directory    ${source_path}
    ${extension_check}    Set Variable    ${source_emil_file}[0]
    ${ext} =    BuiltIn.Evaluate    os.path.splitext("${extension_check}")[1]    modules=os
    ${Numberofemilfile}    Get Length    ${source_emil_file}
    ssh.Execute    command=mkdir ${uepc_Log_path}    connection=mcg_vm
    FOR    ${file}    IN RANGE    0    ${Numberofemilfile}
        ssh.upload_file    local_path=${source_path}/${source_emil_file}[${file}]
        ...    remote_path=${uepc_Log_path}\\${source_emil_file}[${file}]
        ...    connection=mcg_vm
        sleep    20s
        Run keyword and ignore error    ssh.Execute    command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f
        ...    connection=mcg_vm    timeout=30s
        ${src_file}    Set Variable    ${uepc_Log_path}\\${source_emil_file}[${file}]
        ${cmd}    Set Variable
        ...    cd "${emil_path}" && Emil.exe \"${src_file}\" -tocsv -autoclose -destination \"${uepc_Log_path}\" -ProfilePath \"${emil_profile1}\"
        sleep    10s
        LOG    ${cmd}
        ${output}    ssh.Execute    command=${cmd}    connection=mcg_vm    timeout=5m
        LOG    ${output}
        ${csvfile1}    String.Replace String    string=${source_emil_file}[${file}]    search_for=${ext}    replace_with=${CSVTYPE}
        ssh.download_file    remote_path=${uepc_Log_path}\\${csvfile1}
        ...    local_path=${source_path}/${csvfile1}    connection=mcg_vm
        Set Test Variable    ${CSV_Path}    ${source_path}
    END

Verify Converted emil fiLE to measure time
    [Documentation]    Validation of emil logs
    [Arguments]    ${ueConnectionEstablishmentMode}
    ${ueConnectionEstablishmentMode}    String.Strip String    ${ueConnectionEstablishmentMode}
    ${all_files}    OperatingSystem.List Directory    ${CSV_Path}
    ${filtered_CSVfiles}    Evaluate    [file for file in ${all_files} if file.endswith('${CSVTYPE}')]    modules=os
    Log Many    ${filtered_CSVfiles}
    FOR    ${file}    IN    @{filtered_CSVfiles}
        ${result_time}    set variable    FAIL
        ${FILE_PATH}    Set variable    ${CSV_Path}/${file}
        ${RRC_Setup_Request}    Run Keyword And Ignore Error    search_pattern_in_file    ${FILE_PATH}    ${PATTERN1}
        ${RRC_Setup_Complete}    Run Keyword And Ignore Error    search_pattern_in_file    ${FILE_PATH}    ${PATTERN2}
        log to console    rrc setup: ${RRC_Setup_Request[1]}
        IF    '${RRC_Setup_Request[1]}' != 'No match found'
            ${RRC_Setup_Request_time_stamp}    Evaluate
            ...    re.search(r'\\d{2}:\\d{2}:\\d{2}\\.\\d{6}', '${RRC_Setup_Request[1]}').group(0)
            ...    modules=re
            ${RRC_Setup_Complete_time_stamp}    Evaluate
            ...    re.search(r'\\d{2}:\\d{2}:\\d{2}\\.\\d{6}', '${RRC_Setup_Complete[1]}').group(0)
            ...    modules=re
            log to console    \nRRC Setup request time Stamp: ${RRC_Setup_Request_time_stamp}
            log to console    \nRRC Setup Comleted time Stamp: ${RRC_Setup_Complete_time_stamp}
            ${RRC_Establishment_Time}    calculate_time_difference    ${RRC_Setup_Complete_time_stamp}    ${RRC_Setup_Request_time_stamp}
            log to console    UE Connection established mode: ${ueConnectionEstablishmentMode}
            IF    '${ueConnectionEstablishmentMode}' == 'useDedicatedBwp'
                ${RRC_Establishment_Time_Feature_Disable}    Set Variable    ${RRC_Establishment_Time}
                Set Test Variable    ${RRC_Establishment_Time_Feature_Disable}
                Log To Console    \nRRC Establisment time Feature Disable: ${RRC_Establishment_Time_Feature_Disable}${SPACE}ms
                ${result_time}    Set Variable    PASS
            ELSE
                ${RRC_Establishment_Time_Feature_Enable}    Set Variable    ${RRC_Establishment_Time}
                Set Test Variable    ${RRC_Establishment_Time_Feature_Enable}
                Log To Console    \nRRC Establisment time Feature Enable: ${RRC_Establishment_Time_Feature_Enable}${SPACE}ms
                ${result_time}    Set Variable    PASS
            END
        END
        IF    '${result_time}' == 'PASS'    BREAK
    END
    IF    '${result_time}' == 'FAIL'
        Fail    Test case failed because RRC setup not found in Emil log
    END

Calulate the Time Difference
    ${RRC_setup_enhancement_time}    Evaluate    ${RRC_Establishment_Time_Feature_Disable} - ${RRC_Establishment_Time_Feature_Enable}
    ${RRC_setup_enhancement_time}    Convert to String    ${RRC_setup_enhancement_time}
    Log to console    RRC Setup time enhancement with feature enabled : ${RRC_setup_enhancement_time}${SPACE}ms

Cell Attenuation
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    Log to console    \n--Attenuation Inprogress--\n
    at.set_ports_attenuation    ports=${ports1}    values=${atvalues0}    confirm=True    confirmation_delay=10s
    sleep    10s
    Log to console    \n--Attenuation Set--\n
    ${set_attenuation}    at.read_ports_attenuation    ports=${ports1}
    Log to console    ${set_attenuation}
