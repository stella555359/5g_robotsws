*** Settings ***
Documentation
...     Test Suite Purpose:
...         Generic purpose prisma keywords
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com

*** Keywords ***
Close airmosaic
    [Documentation]     Close all session of airmosaic on the VM
    ${alias}        Connect to TestPC        test_pc
    ssh.execute     ps -ef|grep airmosaic|grep -v grep | awk '{print $2}'|xargs sudo kill -9    connection=${alias}
    ssh.disconnect  connection=${alias}

Check cells are detected by Prisma
    [Arguments]     ${pcisToCheck}
    wait until keyword succeeds     1 min    10 sec  Connect to LSU
    ${NumElements}     get length      ${pcisToCheck}
    FOR     ${index}    IN RANGE    0      ${NumElements}
            ${pci}                   Get From List   ${pcisToCheck}      ${index}
            Log to console  \n----------------------\nChecking PCI:\n${pci}\n----------------------\n
            ssh.send command
            ...     /lsu/bin/trcinfo -${prisma_ppu_cell_5G[${index}]} | grep "FOUND SSS" | head -10
            ...     connection=LSU_Prisma    timeout=30
            sleep   6s
            ${output} =                     ssh.Read Output     connection=LSU_Prisma
            should not be empty                  ${output}
            should contain                  ${output}       FOUND SSS CELL_ID=${pci}
            log to console                  ${output}
    END
#    ssh.send command                /lsu/bin/trcinfo -${prisma_ppu_cell_4G} | grep SSS  connection=LSU_Prisma    timeout=30
#    ${output} =                     ssh.Read Output     connection=LSU_Prisma
#    should not be empty             ${output}
#    should contain                  ${output}     SYNC_SSS->DN_ADJ_FREQ_OFF lteCellId=
#    log to console                  ${output}
#    ssh.send command                /lsu/bin/trcinfo -${prisma_ppu_cell_4G[0:-1]}${${prisma_ppu_cell_4G[-1]}+${1}} | grep SSS
#    ...                                                                                 connection=LSU_Prisma    timeout=30
#    ${output} =                     ssh.Read Output     connection=LSU_Prisma
#    should not be empty             ${output}
#    should contain                  ${output}     SYNC_SSS->DN_ADJ_FREQ_OFF lteCellId=
#    log to console                  ${output}

Start Prisma and check cells
    [Arguments]     ${pcisToCheck}
    Start LSU uu Ext01
    Sleep       150s
    Wait Until Keyword Succeeds    6x       20sec
    ...            Check cells are detected by Prisma       ${pcisToCheck}
    # Should be true      ${Cells_detected}
    # log to console          Cells Detected value: ${Cells_detected}

Check cells status in Prisma
    kw_Prisma_Taf.Get Prisma Cells Status

Launch Prisma
    [Documentation]     -Restart of LSU and TSTM of Prisma
    ...                 -Start airmosaic and connect to TSTM
    ...                 -Save last counter file
    [Arguments]     ${pcisToCheck}     ${os}=Debian
    log to console      Start airmosaic and connect to TSTM
    Close airmosaic
    Generate yaml for Airmosaic         ${custom}
    ...                                 ${AP_PRISMA_TAF_YAML_FULLPATH}
    ...                                 ${dedicated_scenario}
    Loading Prisma Configuration of TL
    Setup Prisma Configuration of TL
    wait until keyword succeeds     20min    5min     Start Prisma and check cells       ${pcisToCheck}
    Start tstm uu
    sleep                           60sec
    Run Keyword If     '${os}'=='Windows'        Start airmosaic and connect to tstm Windows
    ...    ELSE        Start airmosaic and connect to tstm Ext01

Start Prisma Call
    [Arguments]         ${scenario}=none        #${firstcell}=1
    #run keyword unless             '${scenario}' == 'none'
    #...                            set global variable      ${specific_scenario}        ${scenario}
    run keyword if             '${scenario}' != 'none'
    ...                            set global variable      ${specific_scenario}        ${scenario}
    Execute Dedicated Prisma Scenario With Arg      ${specific_scenario}
    Get Prisma counters
    set global variable            ${prisma_started}       true

Get Prisma counters
    ${prismacounters}=               prismaTaf.get_counters     node_name=${airmosaic}
    log to console      ${prismacounters}

Connect to LSU
    [Documentation]     Create ssh connection on LSU Prisma
    ssh.connect to
    ...            hostname=${tl.ues[0].lsu_uu_ssh_connection_details.addr}
    ...            username=${tl.ues[0].lsu_uu_ssh_connection_details.username}
    ...            password=${tl.ues[0].lsu_uu_ssh_connection_details.password}
    ...            alias=LSU_Prisma

Get Prisma bug report
    [Documentation]     To Get Prisma Bug report
    Log To Console                  Getting the Prisma Bug report....
    ${collectedBugReport}       prismaTaf.get_bug_report       output_file=${LOG_PATH}
    ...                             node_name=${airmosaic}
    Log To Console      ---- The Prisma Bug Report is: ${collectedBugReport}  -----

Get Prisma Test Results
    [Documentation]     To Get Prisma Test Results
    [Tags]              Get the Prisma Test Results
    Log To Console      Getting the Prisma Test Results....
    ${collectedTestResults}      prismaTaf.get_test_result      node_name=${airmosaic}
    Create File         ${resultDir}/myCollectedTestResults.txt       ${collectedTestResults}
    sleep               2sec
    # To re-read the file with content=Collected Test Result
    run keyword and continue on failure         Operating system.Get File            ${resultDir}/myCollectedTestResults.txt
    Log To Console      The Prisma test results are: ${collectedTestResults}

Get Prisma Scenario Logger
    [Documentation]     To Get Prisma Scenario Logger
    [Tags]              Get the Prisma Scenario Logger
    Log To Console                  \nGetting the Prisma Scenario Logger Started
    ${collectedScenarioLogger}      prismaTaf.get_scenario_logger       output_file=${resultDir}/myCollectedScenarioLogger.txt
    ...                             node_name=${airmosaic}
    # To re-read the file with content=Scenario Logger
    run keyword and continue on failure         Operating system.Get File            ${resultDir}/myCollectedScenarioLogger.txt
  # Log To Console      ---- The Prisma Scenario Logger is: ${collectedScenarioLogger}  -----
    Log To Console      GEtting the Prisma Scenario Logger Ended

LSU Get Report
    [Documentation]     To get LSU get report
    log to console                  \nGetting LSU Get report started
    Connect to LSU
    ${file}=            ssh.execute         ls /tmp/lsugetreport*.tar | tail -1                 timeout=3        connection=LSU_Prisma
    log                             +${file}+
    ${file}=            split to lines  ${file}
    log                 +${file[0]}+
    ${file}=            fetch from right    ${file[0]}      /tmp/
    log                 ${file}
    run keyword and ignore error         ssh.execute         /lsu/bin/lsugetreport ok      timeout=120    connection=LSU_Prisma
    wait until keyword succeeds     3min    5sec        Check new LSU get report    ${file}
    sleep               1min
    ${file}=            Check new LSU get report    ${file}
    ssh.download_file   /tmp/${file}   ${resultDir}/lsugetreport.tar   connection=LSU_Prisma
    log to console                  Getting LSU Get report ended

Check new LSU get report
    [Documentation]         Check there is new LSUgetreport file
    [Arguments]             ${old_file}
    Connect to LSU
    ${file}=            ssh.execute         ls /tmp/lsugetreport*.tar | tail -1         timeout=3        connection=LSU_Prisma
    log                             +${file}+
    ${file}=            split to lines  ${file}
    log                 +${file[0]}+
    ${file}=            fetch from right    ${file[0]}      /tmp/
    log                 ${file}
    should not be equal     '${file}'   '${old_file}'
    [Return]            ${file}

Prisma end of test
    [Documentation]     Wait the end of Prisma test by checking that Prisma is in state
    ...                 SCENARIO_COMPLETED or SCENARIO_AVAILABLE
    log to console      Prisma end of test
    Log To Console                  Getting Prisma scenario status and checking completed....
    # Wait until Keyword Succeeds     3 min       5 s                         Check Simulator Scenario Completed
    ${scenarioExecutionStatus}=     prismaTaf.get_scenario_status               node_name=${airmosaic}
    Log to console                  ----------- Scenario Execution Status is: ${scenarioExecutionStatus} -----------
    #run keyword unless     '${scenarioExecutionStatus}'=='SCENARIO_COMPLETED' or '${scenarioExecutionStatus}'=='SCENARIO_AVAILABLE'
    #...     Stop Airmosaic Scenario Exec Via Taf
    run keyword if     '${scenarioExecutionStatus}'!='SCENARIO_COMPLETED' and '${scenarioExecutionStatus}'!='SCENARIO_AVAILABLE'
    ...     Stop Airmosaic Scenario Exec Via Taf

Save Prisma logs
    [Documentation]  Call keywords Prisma test result file and scenario logger
    log to console      Save Prisma logs
    run keyword and ignore error    prisma.Get Prisma Test Results
    run keyword and ignore error    prisma.Get Prisma Scenario Logger
    run keyword and ignore error    LSU Get Report

Stop Airmosaic Scenario Exec Via Taf
    [Documentation]     To stop Airmosaic scenario execution.
    ...                 tbc
    Log To Console                      Prisma scenario execution stopping now ....
    ${isTestExecutionStoppedStatus}     prismaTaf.stop_test_running                     node_name=${airmosaic}
    Log To Console                      ---- Is test execution stopped completed: ${isTestExecutionStoppedStatus}  -----
    sleep                               60 s

Start airmosaic and connect to tstm Ext01
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    log                                 ${default_sid_file}
    log                                 ${scenario_prisma_folder}
    prismaTaf.prepare test              ${default_sid_file}
    ...                                 ${scenario_prisma_folder}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}

Start airmosaic and connect to tstm Windows
    prismaTaf.start mosaic              node_name=${airmosaic}
    ${alias}        Connect to TestPC        test_pc
    ssh.execute     cd "r'${AM_PATH}"    connection=${alias}
    ssh.execute     airmosaic_harness64 --nogui --nosplash -J-Dcli.mode=true --enable-harness   connection=${alias}

    ssh.disconnect  connection=${alias}
    sleep                               1min
    log                                 ${default_sid_file}
    log                                 ${scenario_prisma_folder}
    prismaTaf.prepare test              ${default_sid_file}
    ...                                 ${scenario_prisma_folder}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}

Start airmosaic and connect to tstm WA To Reconnect Ext01
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    Stop And Restart tstm uu process
    Sleep           60s
    prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}
    Sleep           60s

Start LSU uu Ext01
    ${response}=        				prismaTaf.create 5g cell
	...									node_name=${lsu_x2uu_node}
	...									timeout=${400}
    sleep               				60s
    ${isLSU_uuStartCompleted}=          Evaluate    "lsustart completed correctly" in """${response}"""
    Should be true                      ${isLSU_uuStartCompleted}

Connect to tstm Ext01
    prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}
