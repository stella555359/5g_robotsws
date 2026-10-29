*** Settings ***
Documentation    Suite description
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007873/resources/kw_cb007873.py
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Keywords ***
Set attenuator for 7873 step 1
    Turn off attenuation
    Turn off attenuation_2
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0   # CellID 107

Set attenuator for 7873 step 2
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0   # CellID 101

Set attenuator for 7873 step 3
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=60   # CellID 104
    Sleep   5s
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=20   # CellID 104

Set attenuator for 7873 step 35db for 104
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=0   # CellID 104

Set connection To LTE
    ssh.connect_to   hostname=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...              username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...              password=${tl.test_pcs[0].default_ssh_connection_details.password}
    ...              alias=LTE

Start tcpdump logs on LTE
    [Arguments]  ${filename}=test.pcap
    ...          ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=LTE_asik
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}  proxy=LTE
    Wait until keyword succeeds    5 min    1 min
    ...    ssh.send_command    command=tcpdump sctp -i any -w ${filename}   connection=${alias}
    sleep  3s

Stop tcpdump logs on LTE and download logs
    [Arguments]  ${filename}=test.pcap
    ...          ${alias}=LTE_asik
    sleep  3s
    ssh.execute  command=killall tcpdump  connection=${alias}
    sleep  3s
    ssh.download_file   /user/toor4nsn/${filename}  ${OUTPUT_DIR}/${TEST_NAME}.pcap  connection=${alias}
    sleep  3s
    ssh.disconnect  connection=${alias}

Verify SCell configuration
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog 7873
    check if exist in syslog 7873   ConcreteNsaCaSCellCandidateSelectionProcedure
    ...                         Finished with status Status:ok and selected SCells

Verify SCell configuration SA
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog 7873
    check if exist in syslog 7873   ConcreteCaSCellCandidateSelectionProcedure
    ...                         Finished with status Status:ok and selected SCells: [NRCellIdentity:

Verify SCell activation
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog 7873
    check if exist in syslog 7873   handleActivateMacCe     handleActivateMacCe done for UE

Verify call release
    # [Arguments]    ${file_path}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    unpack collected syslog 7873
    # check if exist in syslog 7873    resendMacCe      resendMacCe done for UE
    check if exist in syslog 7873   Lifecycle of UE        Lifecycle of UE finished

unpack collected syslog 7873
    Run    rm ${OUTPUT DIR}/${SUITE NAME}/*.LOG
    Run    tar -xf ${OUTPUT DIR}/${SUITE NAME}/${test_name}/SYSLOG/syslog_files.tgz -C ${OUTPUT DIR}/${SUITE NAME}
    Run    cat ${OUTPUT DIR}/${SUITE NAME}/SYSLOG* > ${OUTPUT DIR}/${SUITE NAME}/SYSLOG_all.LOG
    Run    mv ${OUTPUT DIR}/${SUITE NAME}/SYSLOG_all.LOG ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log

check if exist in syslog 7873
    [Arguments]    ${grepfilter}    ${expected value}
    ${syslogOutput}    Run    grep -i "${grepfilter}" ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    should contain    ${syslogOutput}    ${expected value}

Change cellBarred
    [Arguments]    ${value}    ${cell_id}=107    ${alias}=cOAM

    Log to console      Connect to cOAM.
    coam.Connect to    name=${alias}
    ${bts_info}    coam.Get bts info    connection=cOAM
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    Set suite variable    ${bts_id}
    coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    ...                                       parameter=cellBarred
    ...                                       operation=update
    ...                                       value=${value}
    ...                                       skip_parameter_relation_errors=${True}
    ...                                       connection=${alias}
    coam.Teardown     connection=${alias}
    # Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin

Read counters value 7873
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55114C00021   M55114C00028
    Append To List    ${counters}    M55115C00007
    Append To List    ${counters}    M55115C00008
    Append To List    ${counters}    M55115C00015
    Append To List    ${counters}    M55118C02000
    Append To List    ${counters}    M55118C03000
    Append To List    ${counters}    M55118C04000
    Append To List    ${counters}    M55118C05000
    # Append To List    ${counters}    M55118C05509
    # Append To List    ${counters}    M55118C05510
    Append To List    ${counters}    M55316C02000
    Append To List    ${counters}    M55316C03001
    Append To List    ${counters}    M55316C05001
    Append To List    ${counters}    M55316C09000
    FOR    ${counter}    IN      @{counters}
        ${value}     Get sum of n last counter values   4  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 7873
    log to console              Verify PM counters values
    Sleep                       150s
    ${counters}                 Read Counters Value 7873
    ${M55114C00021}             get_counter_value     ${counters}     101   M55114C00021
    ${M55114C00028}             get_counter_value     ${counters}     101   M55114C00028
    ${M55115C00007}             get_counter_value     ${counters}     104   M55115C00007
    ${M55115C00008}             get_counter_value     ${counters}     101   M55115C00008
    ${M55115C00015}             get_counter_value     ${counters}     101   M55115C00015
    ${M55118C02000}             get_counter_value     ${counters}     101   M55118C02000
    ${M55118C03000}             get_counter_value     ${counters}     101   M55118C03000
    ${M55118C04000}             get_counter_value     ${counters}     101   M55118C04000
    ${M55118C05000}             get_counter_value     ${counters}     104   M55118C05000
    # ${M55118C05509}             get_counter_value     ${counters}     101   M55118C05509
    # ${M55118C05510}             get_counter_value     ${counters}     101   M55118C05510
    ${M55316C02000}             get_counter_value     ${counters}     101   M55316C02000
    ${M55316C03001}             get_counter_value     ${counters}     101   M55316C03001
    ${M55316C05001}             get_counter_value     ${counters}     101   M55316C05001
    ${M55316C09000}             get_counter_value     ${counters}     104   M55316C09000
    Should Be True      0<${M55114C00021}
    Should Be True      0<${M55114C00028}
    Should Be True      0<${M55115C00007}
    Should Be True      0<${M55115C00008}
    Should Be True      0<${M55115C00015}
    Should Be True      0<${M55118C02000}
    Should Be True      0<${M55118C03000}
    Should Be True      0<${M55118C04000}
    Should Be True      0<${M55118C05000}
    # Should Be True      0<${M55118C05509}
    # Should Be True      0<${M55118C05510}
    Should Be True      0<${M55316C02000}
    Should Be True      0<${M55316C03001}
    Should Be True      0<${M55316C05001}
    Should Be True      0<${M55316C09000}

Verify PM Counters 7873 SA
    log to console              Verify PM counters values
    ${counters}                 Read Counters Value 7873
    ${M55114C00021}             get_counter_value     ${counters}     101   M55114C00021
    ${M55114C00028}             get_counter_value     ${counters}     101   M55114C00028
    ${M55115C00007}             get_counter_value     ${counters}     104   M55115C00007
    ${M55115C00008}             get_counter_value     ${counters}     101   M55115C00008
    ${M55115C00015}             get_counter_value     ${counters}     101   M55115C00015
    ${M55118C02000}             get_counter_value     ${counters}     101   M55118C02000
    ${M55118C03000}             get_counter_value     ${counters}     107   M55118C03000
    ${M55118C04000}             get_counter_value     ${counters}     101   M55118C04000
    ${M55118C05000}             get_counter_value     ${counters}     104   M55118C05000
    ${M55316C02000}             get_counter_value     ${counters}     107   M55316C02000
    ${M55316C03001}             get_counter_value     ${counters}     107   M55316C03001
    ${M55316C05001}             get_counter_value     ${counters}     107   M55316C05001
    ${M55316C09000}             get_counter_value     ${counters}     104   M55316C09000
    # Should Be True      0<${M55114C00021}
    # Should Be True      0<${M55114C00028}
    # Should Be True      0<${M55115C00007}
    # Should Be True      0<${M55115C00008}
    # Should Be True      0<${M55115C00015}
    # Should Be True      0<${M55118C02000}
    # Should Be True      0<${M55118C03000}
    # Should Be True      0<${M55118C04000}
    # Should Be True      0<${M55118C05000}
    Should Be True      0<${M55316C02000}
    Should Be True      0<${M55316C03001}
    Should Be True      0<${M55316C05001}
    Should Be True      0<${M55316C09000}
