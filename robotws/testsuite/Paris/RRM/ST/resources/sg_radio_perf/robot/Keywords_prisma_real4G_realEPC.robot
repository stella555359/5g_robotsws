*** Settings ***
Documentation
...           Description : keywords for prisma real4G realEPC
...           AUTHOR (I&V):  Annie Wong        annie.wong@nokia.com
...
...                      04.05.20:  last update

Library      taf.transport.ssh               WITH NAME       ssh
Library      taf.ue.prisma                   WITH NAME       prismaTaf
Library      ../python/sdrcfg_handler.py     WITH NAME       sdr
#Library      ../../../../../resources/sites/NPS/PROD/python/yamlPrisma.py
#Resource     ../../../../../resources/sites/NPS/PROD/robot/kw_Prisma_Taf.robot

Library      ../../../../../../../testsuite/Paris/resources/ST/python/yamlPrisma.py
Resource     ../../../../../../../testsuite/Paris/resources/ST/robot/kw_Prisma_Taf.robot

*** Keywords ***
Initialize Prisma And Stop LSU UU
    Load Prisma Config
    #----------- Stopping LSU-S1 part
    #prismaTaf.stop lsu                   node_name=${lsu_s1_node}
    #prismaTaf.stop epc                   node_name=${lsu_s1_node}
    #prismaTaf.clean epc log              node_name=${lsu_s1_node}
    #----------- Stopping TSTM-Uu part
    prismaTaf.stop tstm                   node_name=${lsu_tstmuu}
    prismaTaf.clean tstm log              node_name=${lsu_tstmuu}
    #---------- Stopping TSTM-X2 part
    #prismaTaf.stop tstm                  node_name=${lsu_tstmx2}
    #prismaTaf.clean tstm log             node_name=${lsu_tstmx2}
    #--------- Stopping LSU-Uu part
    prismaTaf.stop lsu                    node_name=${lsu_x2uu_node}


Load Prisma Config
    #-----------create prisma yaml file
    Generate yaml for Airmosaic         ${custom}
    ...                                 ${AP_PRISMA_TAF_YAML_FULLPATH}
    ...                                 ${scenario_prisma_file_name}
    LSUUU open ssh connection
    #----------- Loading the prisma configuration of the TL
    Loading Prisma Configuration of TL
    #------------Starting setup of prisma configuration
    Setup Prisma Configuration of TL


Setup Prisma LSU Start Mosaic Connect to TSTM
    Initialize Prisma And Stop LSU UU
    Start Prisma UU And Detect PSS SSS MASTER LOCK        gnb_cellid=${cellId}
    Start Mosaic And Connect to TSTM and Detect Prisma PCI      gnb_cellid=${cellId}


Start Prisma UU And Detect PSS SSS MASTER LOCK
    [Arguments]          ${gnb_cellid}=1
    log         Start Prisma LSU Uu part (./start_nr5g)     console=${DEBUG_MODE_CONSOLE}
    Start LSU uu with 4G part
    ### new add more time (old 120s)
    log      Sleep 3min...     console=${DEBUG_MODE_CONSOLE}
    Sleep               180s
    log      Start Prisma TSTM Uu Ms gui part with All Checks (./start_nr5g_Uu_ms_gui)     console=${DEBUG_MODE_CONSOLE}
    Start tstm uu
    ### new
    log      Sleep 5min...     console=${DEBUG_MODE_CONSOLE}
    Sleep               300s
    log        Start the PSS detection           console=${DEBUG_MODE_CONSOLE}
    Check LSUUu PSS detection
    sleep          10s
    log        Start the SSS detection on Cell ID ${gnb_cellid}       console=${DEBUG_MODE_CONSOLE}
    Check Prisma LSUUu SSS detection    ${gnb_cellid}
    sleep          10s
    Log        Start the MASTERLOCK detection                         console=${DEBUG_MODE_CONSOLE}
    wait until keyword succeeds         15min       30s      Check Prisma LSUUu MASTERLOCK detection
    sleep          10s


Start Mosaic
    [Documentation]     Start Airmosaic.
    ...                 using the startup command defined into the yaml file
    ...                 In the script_path, section start_mosaic: cd /opt/Prisma/airmosaic_lteuu/bin/ ;
    ...                 ./airmosaic_lteuu --nogui --nosplash -J-Dcli.mode=true --enable-harness
    ...                 1 argument expected: node_name=${airmosaic}
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min


Prepare Test and ConnectToTstm
    [Documentation]     To connect to Tstm from Airmosaic.
    ...                 prepare the test by loading the SID file to be used along with the yaml configuration file.
    ...                 The SID configuration file should be located into the ${sid_file_name}
    ...                 The Prisma configuration files should be located into the ${airmosaic_config_files_path_name}
    #log                                 ${sid_file_name}
    #log                                 ${airmosaic_config_files_path_name}
    prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}


Start Mosaic And Connect to TSTM and Detect Prisma PCI
    [Arguments]          ${gnb_cellid}=1
    #log        Start Mosaic
    Start Mosaic
    #log        Prepare sid file and Connect to TSTM
    #run keyword and ignore error         Prepare Test and ConnectToTstm
    Prepare Test and ConnectToTstm
	#------------Prisma sequence: Waiting on Airmosaic to get the status=or SCENARIO_AVAILABLE
	#------------  or SIMINIT_COMPLETED (first call: Check Simulator Ready For SIMINIT Via Taf)
    Wait until Keyword Succeeds         5 min      5 s      Check Simulator Ready
    #log        Start the PCI (CELL ID) detection on Cell ID ${gnb_cellid}
    Check Prisma LSUUu PCI detection    ${gnb_cellid}
    sleep        10s
    Get Prisma Cells Status


Check Simulator Ready
    # values returned possible:
    #        :return: status, optionals
    #                NONE, SIMINIT_AVAILABLE_INVALID, SIMINIT_AVAILABLE,
    #                RUNNING_SIMINIT, RUNNING_SIMINIT_SCEAVAIL, SIMINIT_COMPLETED,
    #                SCENARIO_AVAILABLE, SCENARIO_RUNNABLE,
    #                RUNNING_SCENARIO, SCENARIO_COMPLETED, ABNORMAL_FAIL, SID_OPENING
    sleep          10s
    ${AirmosaicStatus}      prismaTaf.get_scenario_status            node_name=${airmosaic}
    log          AirmosaicStatus=${AirmosaicStatus}
    Should Be True       '${AirmosaicStatus}'=='SCENARIO_RUNNABLE' or '${AirmosaicStatus}'=='SIMINIT_COMPLETED'


Launch Airmosaic Test Scenario
    Log           Start Prisma Scenario: ${scenario_prisma_file_name}
    prismaTaf.execute_test      ${scenario_prisma_file_name}     node_name=${airmosaic}
    #... Check Prisma Scenario is running ...
    ${executionStatus}=             prismaTaf.get_scenario_status         node_name=${airmosaic}
    Log           executionStatus: ${executionStatus}
    Check Simulator Scenario Is Running


Stop Airmosaic Test Scenario
    run keyword and ignore error     Get Prisma Test Results
    ${executionStatus}=      prismaTaf.get_scenario_status     node_name=${airmosaic}
    Log               Current Scenario Execution Status is: ${executionStatus}
    #execution status should be 'SCENARIO_COMPLETED' or 'SCENARIO_AVAILABLE'
    Log               Stop Prisma scenario execution now
    run keyword and ignore error     prismaTaf.stop_test_running        node_name=${airmosaic}
    sleep       10s
    ${executionStatus}=      prismaTaf.get_scenario_status     node_name=${airmosaic}
    log      scenario status is: ${executionStatus}
    log      prismaTaf.clear_test:
    prismaTaf.clear_test             node_name=${airmosaic}


Close Mosaic
    [Documentation]     run rest api to close airmosaic
    prismaTaf.close mosaic              node_name=${airmosaic}
    sleep                               30s


Stop Airmosaic scenario and Stop LSU
    Log     Stop Airmosaic sce...    console=${DEBUG_MODE_CONSOLE}
    run keyword and ignore error     Stop Airmosaic Test Scenario
    Log     Close Mosaic...    console=${DEBUG_MODE_CONSOLE}
    run keyword and ignore error     Close Mosaic
    Log     Stop LSU UU...     console=${DEBUG_MODE_CONSOLE}
    run keyword and ignore error     Stop LSU UU


Stop LSU UU
    LSUUU close ssh connection
    #----- Stopping TSTM-Uu part
    prismaTaf.stop tstm                   node_name=${lsu_tstmuu}
    prismaTaf.clean tstm log              node_name=${lsu_tstmuu}
    #----- Stopping LSU-Uu part
    prismaTaf.stop lsu                    node_name=${lsu_x2uu_node}
    sleep                                 20s


Teardown Sequence With Prisma LSU UU
    Create Connections
    Close Connections
    LSUUU close ssh connection
    Teardown Sessions
    #--- Stopping TSTM-Uu part
    prismaTaf.stop tstm                   node_name=${lsu_tstmuu}
    prismaTaf.clean tstm log              node_name=${lsu_tstmuu}
    #----Stopping LSU-Uu part
    prismaTaf.stop lsu                    node_name=${lsu_x2uu_node}
    sleep                                  30s
    #----To properly stop the linux process
    Terminate All Processes                     kill=True


Backup and Change sdrcfg1 onto LSUUU
    [Arguments]        ${backup_sdrcfg}     ${new_sdrcfg}       ${remote_sdrcfg}=/home/user/lsu_scripts/sdrcfg1
    ${lsu_ip}=          set variable        ${tl.ues[0].lsu_uu_ssh_connection_details.addr}
    ${lsu_username}=    set variable        ${tl.ues[0].lsu_uu_ssh_connection_details.username}
    ${lsu_password}=    set variable        ${tl.ues[0].lsu_uu_ssh_connection_details.password}
    ${lsu_cnx}       ssh.connect_to      ${lsu_ip}      ${lsu_username}     ${lsu_password}
    sdr.download_sdrcfg      cnx=${lsu_cnx}      local_sdrcfg=${backup_sdrcfg}    remote_sdrcfg=${remote_sdrcfg}
    sdr.upload_sdrcfg        cnx=${lsu_cnx}      local_sdrcfg=${new_sdrcfg}       remote_sdrcfg=${remote_sdrcfg}
    ssh.disconnect           connection=${lsu_cnx}


Restore sdrcfg1 onto LSUUU
    [Arguments]         ${backup_sdrcfg}    ${remote_sdrcfg}=/home/user/lsu_scripts/sdrcfg1
    ${lsu_ip}=          set variable        ${tl.ues[0].lsu_uu_ssh_connection_details.addr}
    ${lsu_username}=    set variable        ${tl.ues[0].lsu_uu_ssh_connection_details.username}
    ${lsu_password}=    set variable        ${tl.ues[0].lsu_uu_ssh_connection_details.password}
    ${lsu_cnx}       ssh.connect_to      ${lsu_ip}      ${lsu_username}     ${lsu_password}
    sdr.upload_sdrcfg        cnx=${lsu_cnx}      local_sdrcfg=${backup_sdrcfg}     remote_sdrcfg=${remote_sdrcfg}
    ssh.disconnect           connection=${lsu_cnx}

Check LSUUu PSS detection
    [Documentation]     To check Prisma has successfully detected the Synchronization Signals PSS
    ...                 We are searching for the string 'PSS detection confirmed'
    #Searching for PSS indication using trcinfo util (p0-2 + p0-3 + p0-4 + p0-5 for 4CC)
    ${pss_cmd_ppu2}=        Set Variable        /lsu/bin/trcinfo -p0-2 | grep -i PSS
    ${pss_cmd_ppu3}=        Set Variable        /lsu/bin/trcinfo -p0-3 | grep -i PSS
    ${pss_cmd_ppu4}=        Set Variable        /lsu/bin/trcinfo -p0-4 | grep -i PSS
    ${pss_cmd_ppu5}=        Set Variable        /lsu/bin/trcinfo -p0-5 | grep -i PSS
    ssh.Send Command            ${pss_cmd_ppu2} ; ${pss_cmd_ppu3} ; ${pss_cmd_ppu4} ; ${pss_cmd_ppu5}
    ...                         timeout=120         connection=LSUUU
    ${PSS_status}               ssh.Read Output     connection=LSUUU
    Log                         ---- PSS detection: ${PSS_status} -----
    # to fix the new way Prisma is displaying the PSS is detected since v5.7.4
    # ${lines}=                   Get Lines Containing String         ${PSS_status}       PSS detection start
    # Should Contain              ${lines}                                                PSS detection start
    ${lines}=                   Get Lines Containing String         ${PSS_status}       PSS->SSS
    Should Contain              ${lines}                                                PSS->SSS
