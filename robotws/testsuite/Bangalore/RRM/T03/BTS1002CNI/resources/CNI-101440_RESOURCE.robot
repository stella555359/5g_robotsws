*** Settings ***
Documentation
...                 Description: Resource File for CB101440

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
${attenuator_host}              10.45.153.196    # Attenuator IP ###PVA_DETAILS###
@{at_channel1}                  ${9}    ${10}    ${11}    ${12}    # Attenuation port used
@{at_channel2}                  ${13}    ${14}    ${15}    ${16}    # Attenuation post used
${attenuator_port}              ${3001}    # Attenuator Port
@{ports1}                       ${9}    ${10}    ${11}    ${12}
@{ports2}                       ${13}    ${14}    ${15}    ${16}
@{values0}                      0dB    0dB    0dB    0dB
@{values1}                      70dB    70dB    70dB    70dB
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
${EXTENSION}                    .lcbin    ###EMIL_DETAILS###
${CSVTYPE}                      .csv
${emil_path}                    C:\\Emil
${emil_profile1}                C:\\Emil\\profiles\\Auto\ select
${emil_profile2}                C:\\Emil\\profiles\\5G
${uepc_Log_path}                C:\\automationLOG
${connection}                   Active_Session
${Change_Permission}            sudo chmod -R 777 /home/ute/dcapfiles/


*** Keywords ***
Get Date
    [Documentation]    Get date to create testcase folder
    ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}    Convert to String    ${date}
    Set Test variable    ${Folder}    ${date}

Prepare UE and Attach UE with default bearers
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}

Verify Emil logs
    [Documentation]    Convert emil file and verify
    [Arguments]    @{values}
    Convert Emil File to CSV
    Verify Converted emil fiLE    @{values}

Convert Emil File to CSV
    [Documentation]    Convert Emil logs collected from DCAP
    Log to console    \nConverting Emil logs and verifying
    ${path1}    Set Variable    ${PATH}
    Set Test variable    ${path1}
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
        ${filtered_files}    Evaluate    [file for file in ${all_files} if file.endswith('${EXTENSION}')]    modules=os
        Log Many    ${filtered_files}
        FOR    ${file}    IN    @{filtered_files}
            ${source}    Set Variable    ${source_paths}/${date}/${out_index}/${file}
            ${dest}    Set Variable    ${source_paths}/${date}/Emil_log
            Copy File    ${source}    ${dest}
        END
    END
    ssh.Connect_to    ${UE_PC_IP}    ${Windows_user}    ${Windows_pass}    alias=mcg_vm
    Run keyword And Ignore Error    Start ntrace Emil To Convert Emil File To Csv
    ...    source_path=${dest}

Start ntrace Emil To Convert Emil File To Csv
    [Documentation]    Upload Emil logs to MCG PC and convert emil to csv file
    [Arguments]    ${source_path}
    ${source_emil_file}    OperatingSystem.List Directory    ${source_path}
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
        ${csvfile1}    String.Replace String    string=${source_emil_file}[${file}]    search_for=${EXTENSION}    replace_with=${CSVTYPE}
        ssh.download_file    remote_path=${uepc_Log_path}\\${csvfile1}
        ...    local_path=${source_path}/${csvfile1}    connection=mcg_vm
        Set Test Variable    ${CSV_Path}    ${source_path}
    END

Verify Converted Emil File
    [Documentation]    Validation of Emil logs
    [Arguments]    @{values}
    ${all_files}    OperatingSystem.List Directory    ${CSV_Path}
    ${filtered_CSVfiles}    Evaluate    [file for file in ${all_files} if file.endswith('${CSVTYPE}')]    modules=os
    Log Many    ${filtered_CSVfiles}

    FOR    ${check}    IN    @{values}
        FOR    ${file}    IN    @{filtered_CSVfiles}
            ${filepath}     Set Variable      ${CSV_Path}/${file}
            ${content}    read_file    ${filepath}
            ${result}    Run Keyword And Ignore Error    Should Contain    ${content}    ${check}
            Log    ${result}
            IF    '${result[0]}' == 'PASS'
                Log    ${check} found in Emil log
                BREAK
            END
        END

        IF    '${result[0]}' == 'FAIL'
            Fail    Test case failed because ${check} was not found in Emil log
        END
    END

Attenuation
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    Log to console    \n--Attenuation Inprogress--\n
    at.set_ports_attenuation    ports=${ports1}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports1}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel2}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports2}
    at.set_ports_attenuation    ports=${ports2}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports2}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    at.set_ports_attenuation    ports=${ports1}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports1}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel2}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports2}
    at.set_ports_attenuation    ports=${ports2}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports2}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    at.set_ports_attenuation    ports=${ports1}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports1}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel2}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports2}
    at.set_ports_attenuation    ports=${ports2}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports2}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    Log to console    \n--Attenuation Inprogress--\n
    at.set_ports_attenuation    ports=${ports1}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports1}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel2}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports2}
    at.set_ports_attenuation    ports=${ports2}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports2}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    at.set_ports_attenuation    ports=${ports1}    values=${values1}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.set_ports_attenuation    ports=${ports1}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s

Setting Attenuator
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel1}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports1}
    at.set_ports_attenuation    ports=${ports1}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
    at.setup_attenuator    ip_addr=${attenuator_host}    port=${attenuator_port}    attenuation_port_numbers=${at_channel2}
    ...    vendor=${at_vendor}    model=${at_model}
    log to console    ${ports2}
    at.set_ports_attenuation    ports=${ports2}    values=${values0}    confirm=True    confirmation_delay=10s
    sleep    10s
