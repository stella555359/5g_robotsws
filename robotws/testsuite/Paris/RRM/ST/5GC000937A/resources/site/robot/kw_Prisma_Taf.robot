*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for Prisma via taf.ue.prisma official Prisma Libs
...
...     Version: 1.2.2
...     Date: 30/04/2020
...
...     AUTHOR (I&V-1):
...         Philippe Vignerte   philippe.vignerte @nokia.com
...         Michel WU           michel.wue@nokia.com


*** Keywords ***

Setup Prisma IP Addresses
    [Documentation]     To set Prisma Ip addresses variable available for the rest of Test Suite.
    Set Suite Variable      ${lsuS1_ip}         ${AP_LSU_CORE_ip}
    Set Suite Variable      ${lsuUu_ip}         ${AP_LSU_UU_ip}
    Set Suite Variable      ${tstmUu_ip}        ${AP_TSTM_UU_ip}
    Set Suite Variable      ${tstmX2_ip}        ${AP_TSTM_UU_ip}

Check Prisma LSUUu Gain
    [Documentation]     To check Prisma UL and DL GAIN on SDRv4 configuration file
    ...                 Comparison is done with the values of UL/DL Gains configured on sdrcfg1 file for cell1
    ssh.Send Command            ls |grep -i GAIN /home/user/lsu_scripts/sdrcfg?
    ...                         timeout=120         connection=LSUUU
    ${GAIN_status}              ssh.Read Output     connection=LSUUU
    Log                         ---- GAIN value found in sdrcfg prisma files: ${GAIN_status} -----
    ${ULGAIN0_lines}=           Get Lines Containing String     ${GAIN_status}      ULGAIN0_RF_00
    Should Contain              ${ULGAIN0_lines}        ${sdrULGain}
    ${ULGAIN1_lines}=           Get Lines Containing String     ${GAIN_status}      ULGAIN1_RF_00
    Should Contain              ${ULGAIN1_lines}        ${sdrULGain}
    ${DLGAIN0_lines}=           Get Lines Containing String     ${GAIN_status}      DLGAIN0_RF_00
    Should Contain              ${DLGAIN0_lines}        ${sdrDLGain}
    ${DLGAIN1_lines}=           Get Lines Containing String     ${GAIN_status}      DLGAIN1_RF_00
    Should Contain              ${DLGAIN1_lines}        ${sdrDLGain}

Check Prisma LSUUu PSS detection
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
    Log                         ---- PSS detected: ${PSS_status} -----
    # to fix the new way Prisma is displaying the PSS is detected since v5.7.4
    ${lines}=                   Get Lines Containing String         ${PSS_status}       PSS detection start
    Should Contain              ${lines}                                                PSS detection start
    ${lines}=                   Get Lines Containing String         ${PSS_status}       PSS->SSS
    Should Contain              ${lines}                                                PSS->SSS

Check Prisma LSUUu SSS detection
    [Documentation]     To check Prisma has successfully detected the Synchronization Signals SSS
    ...                 KW is requiring an Argument to define which cell ID to detect ${GN_CELLID}.
    [Arguments]         ${GN_CELLID}
    Log                     ---- gNB Cell ID will be in testSuite: ${GN_CELLID} -----
    Log                     ---- gNB Cell ID will be in Variables: ${cellId} -----
    #Searching for SSS indication using trcinfo util (p0-2 + p0-3 + p0-4 for 4CC)

    ${sss_cmd_ppu2}=        Set Variable        /lsu/bin/trcinfo -p0-2 | grep -i SSS
    ${sss_cmd_ppu3}=        Set Variable        /lsu/bin/trcinfo -p0-3 | grep -i SSS
    ${sss_cmd_ppu4}=        Set Variable        /lsu/bin/trcinfo -p0-4 | grep -i SSS
    ${sss_cmd_ppu5}=        Set Variable        /lsu/bin/trcinfo -p0-5 | grep -i SSS
    ssh.Send Command        ${sss_cmd_ppu2} ; ${sss_cmd_ppu3} ; ${sss_cmd_ppu4} ; ${sss_cmd_ppu5}
    ...                     timeout=120         connection=LSUUU
    ${SSS_status}           ssh.Read Output     connection=LSUUU
    Log                     ---- SSS detected: ${SSS_status} -----
    ${SSSlines}=            Get Lines Containing String                 ${SSS_status}       SSS->DONE
    Should Contain          ${SSSlines}         SSS->DONE id1=
    ${SSSlines2}=           Get Lines Containing String                 ${SSS_status}       SYNC->SSS
    Should Contain          ${SSSlines2}        SYNC->SSS CELL_ID=${GN_CELLID}
    Should Match Regexp     ${SSS_status}       SYNC->SSS\\s+CELL_ID=\\d+

Check Prisma LSUUu MASTERLOCK detection
    [Documentation]     To check Prisma has successfully detected the Synchronization Signals MASTER LOCK
    #Searching for MASTER LOCK indication using trcinfo util
    ssh.Send Command            /lsu/bin/trcinfo -p0-2 | grep -i LOCKED
    ...                         timeout=120         connection=LSUUU
    sleep                       60s
    ${MASTERLOCK_status}        ssh.Read Output     connection=LSUUU
    Log                         ---- Enough MASTER LOCK detected: ${MASTERLOCK_status} -----
    ${nb_lines}=                Get Lines Containing String     ${MASTERLOCK_status}    LOCKED
    ${nb_lines2}=               Get Length                      ${nb_lines}
    Log                         ---- Number of lines found (via Count Values In List): ${nb_lines} -----
    Log                         ---- Number of lines2 found (via get Length): ${nb_lines2} -----
    should be true              ${nb_lines2} > 10

Check Prisma LSUUu PCI detection
    [Documentation]     To check Prisma has successfully decoded the PCI, the phycial Cell Id
    ...                 emitted by the gNB on Air.
    ...                 KW is requiring an Argument to define which cell ID to detect ${GN_CELLID}.
    [Arguments]         ${GN_CELLID}
    Log                 ---- gNB Cell ID will be in testSuite: ${GN_CELLID} -----
    Log                 ---- gNB Cell ID will be in Variables: ${cellId} -----
    #Searching for SSS indication using trcinfo util
    ${cmd_ppu2}=        Set Variable        /lsu/bin/trcinfo -p0-2 | grep -i "detected pci"
    ${cmd_ppu3}=        Set Variable        /lsu/bin/trcinfo -p0-3 | grep -i "detected pci"
    ${cmd_ppu4}=        Set Variable        /lsu/bin/trcinfo -p0-4 | grep -i "detected pci"
    ${cmd_ppu5}=        Set Variable        /lsu/bin/trcinfo -p0-5 | grep -i "detected pci"
    ssh.Send Command    ${cmd_ppu2} ; ${cmd_ppu3} ; ${cmd_ppu4} ; ${cmd_ppu5}
    ...                 timeout=120         connection=LSUUU
    # Fix to allow times to collect the PCI detection infos
    Sleep               120s
    ${PCI_status}       ssh.Read Output     connection=LSUUU
    log                 ${PCI_status}
    Log                 ---- PCI detected: ${PCI_status} -----
    Should Contain      ${PCI_status}       detected pci=${GN_CELLID}

Check Prisma LSUUu PCI detection Reworked
    [Documentation]     To check Prisma has successfully decoded the PCI, the phycial Cell Id
    ...                 emitted by the gNB on Air.
    ...                 KW is requiring an Argument to define which cell ID to detect ${GN_CELLID}.
    [Arguments]         ${GN_CELLID}
    Log                         ---- gNB Cell ID will be in testSuite: ${GN_CELLID} -----
    Log                         ---- gNB Cell ID will be in Variables: ${cellId} -----
    #Searching for SSS indication using trcinfo util
    ssh.Send Command            /lsu/bin/trcinfo -p0-2 | grep -i SSS
    ...                         timeout=120         connection=LSUUU
    ${PCI_status}               ssh.Read Output     connection=LSUUU
    Log                         ${PCI_status}
    Log                         ---- PCI detected: ${PCI_status} -----
    Should Match Regexp         ${PCI_status}       SYNC->SSS\\s+CELL_ID=\\d+
    ${PCIlines}=                Get Lines Containing String     ${PCI_status}       SSS->DONE
    Should Contain              ${PCIlines}         SSS->DONE id1=
    ${PCIlines2}=               Get Lines Containing String     ${PCI_status}       SYNC->SSS
    Should Contain              ${PCIlines2}        SYNC->SSS CELL_ID=${GN_CELLID}


Check Prisma LSUUu RACH completion cell=${cellId}
    ssh.Send Command            trcinfo -p0-9 | grep -i contention
    ...                         timeout=60              connection=LSUUU
    ${RACH_status}               ssh.Read Output        connection=LSUUU
    Should Contain              ${RACH_status}          RA_SuccessCompletion UeId=${cellId} CONTENTION=1
    log                         Attach completed

LSUUU open ssh connection
    [Documentation]         To open an ssh connection to LSU-UU Prisma server and get a valid alias.
    ssh.Connect To          ${AP_LSU_UU_ip}         user        user        alias=LSUUU
    Set Suite Variable      ${lsuUu_alias}          LSUUU

LSUUU close ssh connection
    [Documentation]         To close the opened ssh connections to LSU-UU Prisma server.
    ssh.Disconnect          connection=LSUUU

Get Load lineup Prisma
    [Documentation]         Get load lineup of Prisma serveurs: LSU-UU and LSU-S1
    # Get load lineup of Prisma LSU-S1
    ${LSU_S1_lineup_filename}=      Set Variable                ${custom['PATH_Storage']}/LSU_S1_lineup.txt
    ssh.Connect To          ${AP_LSU_CORE_ip}           ${AP_LSU_CORE_login}      ${AP_LSU_CORE_passwd}    alias=LSUS1
    Create File                     ${LSU_S1_lineup_filename}   \|========\|\n\| LSU S1 \|\n\|========\|\n
    @{ListCmdS1}        Create List     basic-env       lsuv3-base      ipsig       iups        pylsuwww        monsrv
    :FOR    ${CmdS1}    IN      @{ListCmdS1}
    \           Append To File                  ${LSU_S1_lineup_filename}                       \n${CmdS1}\n----------\n
    \           ssh.Send Command    cat /etc/version/lsu|grep -i\t${CmdS1}      timeout=120         connection=LSUS1
    \           ssh.Assert exit status          0                                               connection=LSUS1
    \           ${output}=  ssh.Read Output     connection=LSUS1
    \           Append To File                  ${LSU_S1_lineup_filename}                       ${output}
    ${PrismaLsuS1Load}=             Get File                    ${LSU_S1_lineup_filename}
    ssh.Disconnect                  connection=LSUS1
    # Get load lineup of Prisma LSU-UU
    ${LSU_Uu_lineup_filename}=      Set Variable                ${custom['PATH_Storage']}/LSU_Uu_lineup.txt
    ssh.Connect To          ${AP_LSU_UU_ip}             ${AP_LSU_UU_login}      ${AP_LSU_UU_passwd}    alias=LSUUU
    Create File             ${LSU_Uu_lineup_filename}   \|========\|\n\| LSU UU \|\n\|========\|\n
    @{ListCmdUU}    Create List    iups    lsuv3-base  pylsuwww    lte-l2
    ...          sdrLte  bb-nr5g     monsrv      iptgapp     ipsig   rtp
    :FOR    ${CmdUU}    IN  @{ListCmdUU}
    \           Append To File                  ${LSU_Uu_lineup_filename}                       \n${CmdUU}\n----------\n
    \           ssh.Send Command    cat /etc/version/lsu|grep -i\t${CmdUU}          timeout=120    connection=LSUUU
    \           ssh.Assert exit status          0                                               connection=LSUUU
    \           ${output}=  ssh.Read Output     connection=LSUUU
    \           Append To File                  ${LSU_Uu_lineup_filename}                       ${output}
    ${PrismaLsuUULoad}=             Get File                    ${LSU_Uu_lineup_filename}
    ssh.Disconnect                  connection=LSUUU

Loading Prisma Configuration of TL
    [Documentation]     To Load the Prisma configuration file according to the TL definition
    ...                 Here ${AP_PRISMA_TAF_YAML_FULLPATH} (was ${Prisma_yaml}) variable must point
    ...                 to the CV33_prisma_nps.yam
    ...                 containing all the commands used for Prisma servers and airmosaic startup/stop.
    ...                 With:
    ...                 - ${AP_PRISMA_TAF_YAML_FULLPATH} var: is set into the var_test_suite.robot file
    ...                 - ${tl} var is defined into the __init__.py file related to each TL.
    ...                 Using the taf.ue.prisma Libs
    prismaTaf.load config       ${AP_PRISMA_TAF_YAML_FULLPATH}         ${tl}

Setup Prisma Configuration of TL
    [Documentation]     To setup the Prisma configuration.
    ...                 It will create connect session between TSTM-Uu and Airmosaic application
    ...                 Using the taf.ue.prisma Libs
    prismaTaf.setup

Start LSU s1
    [Documentation]     Start LSU-S1 and check startup successfully completed
    ${response}=        prismaTaf.start lsu    node_name=${lsu_s1_node}     timeout=${120}
    Log                 ---- Start lsu S1 status: ${response}
    ${isLSU_s1StartCompleted}=    Evaluate    "lsustart completed correctly" in """${response}"""
    Should be true      ${isLSU_s1StartCompleted}

Start init epc
    [Documentation]     Start LSU-S1 (init_epc)
    prismaTaf.init epc              node_name=${lsu_s1_node}    timeout=${120}

Start LSU uu
    [Documentation]     to start LSU-Uu and check startup successfully completed
    ${response}=        prismaTaf.create 5g cell    node_name=${lsu_x2uu_node}    timeout=${180}
    Log                 ---- Create 5g cell status: ${response}
    sleep               1min
    ${isLSU_uuStartCompleted}=      Evaluate    "lsustart completed correctly" in """${response}"""
    Should be true                  ${isLSU_uuStartCompleted}

Start LSU uu with 4G part
    [Documentation]     to start LSU-Uu and check startup successfully completed
    # Modif FM increase timer
    #${response}=        prismaTaf.create 5g cell    node_name=${lsu_x2uu_node}    timeout=${180}
    #${response}=        prismaTaf.create 5g cell    node_name=${lsu_x2uu_node}    timeout=${600}
    ${response}=        prismaTaf.create 5g cell    node_name=${lsu_x2uu_node}    timeout=${800}
    Log                 ---- Create 5g cell status: ${response}
    sleep               1min
    ${isLSU_uuStartCompleted}=      Evaluate    "lsustart completed correctly" in """${response}"""
    Should be true                  ${isLSU_uuStartCompleted}
    ${isLSU_uuStart4GPartCompleted}=      Evaluate    "OBJECT: LTE CELL" in """${response}"""
    Should be true                  ${isLSU_uuStart4GPartCompleted}

Start S1 link on LSU s1
    [Documentation]     Start LSU-S1 (./start_epc) and check the first step of startup successfully completed
    ...                 Then Start LSU-S1 (./init_epc)
    ...                 Then Start Airmosaic and Connect to tstm (that will trigger the X2 link steup)
    ...                 Then check the second step of LSU-S1 startup successfully completed (S1 Setup Successful)
    prismaTaf.stop epc              node_name=${lsu_s1_node}
    prismaTaf.clean epc log         node_name=${lsu_s1_node}
    prismaTaf.start lsu             node_name=${lsu_s1_node}        timeout=${120}
    Log                             -------- start epc ----------
    prismaTaf.start epc             node_name=${lsu_s1_node}        timeout=${120}
    Sleep                           120s
    Log                             -------- get epc log ----------
    ${response1}=                   prismaTaf.get epc log           node_name=${lsu_s1_node}
    ...                             expected_regex="MultiSchedule\.tsm Started, Waiting for UDP Client Request"
    Log                             -------- response is : ${response1} ----------
    Log                             -------- index 0 of response is : ${response1[0]} ----------
    Log                             -------- index 1 of response is : ${response1[1]} ----------
    Should be true                  ${response1[0]} == True

    # Cleaning up the LSU-S1 epc log
    prismaTaf.clean epc log         node_name=${lsu_s1_node}

    # Trigger the LSU-S1 ./init_epc command
    Start init epc
    Sleep                           2min

    # Start the Aimosaic application and trigger the Airmosaic ConnectToTstm command
    Log                             ------- Start the Aimosaic application and trigger the Airmosaic ConnectToTstm command ----------
    Start airmosaic and connect to tstm
    sleep                           1min
    Log                             -------- get epc log ----------
    ${response2}=                   prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                                                         expected_regex="S1 Setup Successful"
    Log                             -------- response is : ${response2} ----------
    Log                             -------- index 0 of response is : ${response2[0]} ----------
    Log                             -------- index 1 of response is : ${response2[1]} ----------
    Should Be True                  ${response2[0]}==True

Start S1 link on LSU s1 With WA To Reconnect
    [Documentation]     Start LSU-S1 (./start_epc) and check the first step of startup successfully completed
    ...                 Then Start LSU-S1 (./init_epc)
    ...                 Then Start Airmosaic and Connect to tstm (that will trigger the X2 link steup)
    ...                 Then check the second step of LSU-S1 startup successfully completed (S1 Setup Successful)
    [Arguments]           ${config_name}=""
    prismaTaf.stop epc              node_name=${lsu_s1_node}
    prismaTaf.clean epc log         node_name=${lsu_s1_node}
    prismaTaf.start lsu             node_name=${lsu_s1_node}        timeout=${120}
    Log                             -------- start epc ----------
    prismaTaf.start epc             node_name=${lsu_s1_node}        timeout=${120}
    Sleep                           120s
    Log                             -------- get epc log ----------
    ${response1}=                   prismaTaf.get epc log           node_name=${lsu_s1_node}
    ...                             expected_regex="MultiSchedule\.tsm Started, Waiting for UDP Client Request"
    Log                             -------- response is : ${response1} ----------
    Log                             -------- index 0 of response is : ${response1[0]} ----------
    Log                             -------- index 1 of response is : ${response1[1]} ----------
    Should be true                  ${response1[0]} == True

    # Cleaning up the LSU-S1 epc log
    prismaTaf.clean epc log         node_name=${lsu_s1_node}

    # Trigger the LSU-S1 ./init_epc command
    Start init epc
    Sleep                           2min

    # Start the Aimosaic application and trigger the Airmosaic ConnectToTstm command
    Log                -------- Start the Aimosaic application and trigger the Airmosaic ConnectToTstm command --------
    Start airmosaic and connect to tstm WA To Reconnect    ${config_name}
    sleep                           1min
    Log                             -------- get epc log ----------
    ${response2}=                   prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                                                         expected_regex="S1 Setup Successful"
    Log                             -------- response is : ${response2} ----------
    Log                             -------- index 0 of response is : ${response2[0]} ----------
    Log                             -------- index 1 of response is : ${response2[1]} ----------
    Should Be True                  ${response2[0]}==True

# Added to overcome config_nae argument - PhVi 2020-12-17
Start S1 link on LSU s1 With WA To Reconnect v2
    [Documentation]     Start LSU-S1 (./start_epc) and check the first step of startup successfully completed
    ...                 Then Start LSU-S1 (./init_epc)
    ...                 Then Start Airmosaic and Connect to tstm (that will trigger the X2 link steup)
    ...                 Then check the second step of LSU-S1 startup successfully completed (S1 Setup Successful)
    ...                 v2 without argument for config_name
    #[Arguments]           ${config_name}=""
    prismaTaf.stop epc              node_name=${lsu_s1_node}
    prismaTaf.clean epc log         node_name=${lsu_s1_node}
    prismaTaf.start lsu             node_name=${lsu_s1_node}        timeout=${120}
    Log                             -------- start epc ----------
    prismaTaf.start epc             node_name=${lsu_s1_node}        timeout=${120}
    Sleep                           120s
    Log                             -------- get epc log ----------
    ${response1}=                   prismaTaf.get epc log           node_name=${lsu_s1_node}
    ...                             expected_regex="MultiSchedule\.tsm Started, Waiting for UDP Client Request"
    Log                             -------- response is : ${response1} ----------
    Log                             -------- index 0 of response is : ${response1[0]} ----------
    Log                             -------- index 1 of response is : ${response1[1]} ----------
    Should be true                  ${response1[0]} == True

    # Cleaning up the LSU-S1 epc log
    prismaTaf.clean epc log         node_name=${lsu_s1_node}

    # Trigger the LSU-S1 ./init_epc command
    Start init epc
    Sleep                           2min

    # Start the Aimosaic application and trigger the Airmosaic ConnectToTstm command
    Log          -------- Start the Aimosaic application and trigger the Airmosaic ConnectToTstm command --------
    # Start airmosaic and connect to tstm WA To Reconnect    ${config_name}
    Start airmosaic and connect to tstm WA To Reconnect v2
    sleep                           1min
    Log                             -------- get epc log ----------
    ${response2}=                   prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                                                         expected_regex="S1 Setup Successful"
    Log                             -------- response is : ${response2} ----------
    Log                             -------- index 0 of response is : ${response2[0]} ----------
    Log                             -------- index 1 of response is : ${response2[1]} ----------
    Should Be True                  ${response2[0]}==True


Start airmosaic and connect to tstm
    [Documentation]     Start Airmosaic.
    ...                 Then prepare the test by loading the SID file to be used along with the yaml configuration file.
    ...                 The SID configuration file should be located into the ${sid_file}
    ...                 The Prisma configuration files should be located into the ${airmosaic_config_files_path_name}
    [Arguments]           ${config_name}=""
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    ${local_sid_file_name}=             Get sid Filename     ${config_name}
    log                                 ${local_sid_file_name}
    log                                 ${airmosaic_config_files_path_name}
    prismaTaf.prepare test              ${local_sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}

Start airmosaic and connect to tstm WA To Reconnect
    [Documentation]     Start Airmosaic.
    ...                 Then prepare the test by loading the SID file to be used along with the yaml configuration file.
    ...                 The SID configuration file should be located into the ${sid_file}
    ...                 The Prisma configuration files should be located into the ${airmosaic_config_files_path_name}
    ...                 2019-05-16: PhVi - WA to try reconnect if the Connect does not succeed the first time
    [Arguments]         ${config_name}=""
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    ${local_sid_file_name}=             Get sid Filename        ${config_name}
    log                                 ${local_sid_file_name}
    log                                 ${airmosaic_config_files_path_name}

    # Added to apply WA to stop and restart the TSTM UU ms GUI process just before the prepareTest command
    Stop And Restart tstm uu process
    Sleep           60s
    Run Keyword And Continue On Failure         prismaTaf.prepare test              ${local_sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${600}
    ...                                 node_name=${airmosaic}
    Sleep           60s

# Added to overcome config_nae argument - PhVi 2020-12-17
Start airmosaic and connect to tstm WA To Reconnect v2
    [Documentation]     Start Airmosaic.
    ...                 Then prepare the test by loading the SID file to be used along with the yaml configuration file.
    ...                 The SID configuration file should be located into the ${sid_file}
    ...                 The Prisma cStart S1 link on LSU s1 With WA To Reconnectonfiguration files should be located
    ...                 into the ${airmosaic_config_files_path_name}
    ...                 2019-05-16: PhVi - WA to try reconnect if the Connect does not succeed the first time
    ...                 v2 without argument for config_name
    # [Arguments]         ${config_name}=""
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min
    #${local_sid_file_name}=             ${sid_file_name}
    log                                 ${sid_file_name}
    #log                                 ${local_sid_file_name}
    log                                 ${airmosaic_config_files_path_name}

    # Added to apply WA to stop and restart the TSTM UU ms GUI process just before the prepareTest command
    Stop And Restart tstm uu process
    Sleep           60s

    Should Be String                    ${sid_file_name}
    Should Be String                    ${airmosaic_config_files_path_name}
    Should Be String                    ${airmosaic}

    Run Keyword And Continue On Failure         prismaTaf.prepare test              ${sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${600}
    ...                                 node_name=${airmosaic}
    Sleep           60s


Start S1 link and airmosaic for simulated enb
    prismaTaf.stop epc          node_name=${lsu_s1_node}
    prismaTaf.clean epc log     node_name=${lsu_s1_node}
    prismaTaf.start epc         node_name=${lsu_s1_node}
    sleep                       120s
    ${response1}=               prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                         expected_regex="MultiSchedule\.tsm Started, Waiting for UDP Client Request"
    ${isStartEPCphase1}=        Evaluate
    ...                         "MultiSchedule.tsm Started, Waiting for UDP Client Request" in """${response1}"""
    Should be true              ${isStartEPCphase1}
    prismaTaf.init epc          node_name=${lsu_s1_node}
    sleep                       3min
    Start airmosaic and connect to tstm
    sleep                       180s
    ${response2}=               prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                                                     expected_regex="S1 Setup Successful"
    ${isStartEPCphase2}=        Evaluate                    "S1 Setup Successful" in """${response2}"""
    Should be true              ${isStartEPCphase2}

Start S1 link and airmosaic for real enb
    prismaTaf.stop epc              node_name=${lsu_s1_node}
    prismaTaf.clean epc log         node_name=${lsu_s1_node}
    prismaTaf.start epc             node_name=${lsu_s1_node}
    sleep                           30s
    ${response1}=                   prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                             expected_regex="MultiSchedule\.tsm Started, Waiting for UDP Client Request"
    ${isStartEPCphase1}=            Evaluate
    ...                             "MultiSchedule.tsm Started, Waiting for UDP Client Request" in """${response1}"""
    Should be true                  ${isStartEPCphase1}
    prismaTaf.init epc              node_name=${lsu_s1_node}
    sleep                           3min
    ${response2}=                   prismaTaf.get epc log       node_name=${lsu_s1_node}
    ...                                                         expected_regex="S1 Setup Successful"
    ${isStartEPCphase2}=            Evaluate                    "S1 Setup Successful" in """${response2}"""
    Should be true                  ${isStartEPCphase2}
    Start airmosaic and connect to tstm

Start Airmosaic
    [Documentation]     Start Airmosaic.
    ...                 using the startup command defined into the CV33_prisma_nps.yaml file
    ...                 In the script_path, section start_mosaic: cd /opt/Prisma/airmosaic_lteuu/bin/ ;
    ...                 ./airmosaic_lteuu --nogui --nosplash -J-Dcli.mode=true --enable-harness
    ...                 1 argument expected: node_name=${airmosaic}
    ...                 tbc
    prismaTaf.start mosaic              node_name=${airmosaic}
    sleep                               1min

Connect to tstm
    [Documentation]     To connect to Tstm from Airmosaic.
    ...                 using the startup command defined into the CV33_prisma_nps.yaml file
    ...                 start_mosaic: cd /opt/Prisma/airmosaic_lteuu/bin/ ;
    ...                 ./airmosaic_lteuu --nogui --nosplash -J-Dcli.mode=true --enable-harness
    ...                 2 arguments expected: ${sid_file_name} & ${AP_PRISMA_TAF_YAML_FULLPATH}
    ...                 tbc
    [Arguments]           ${config_name}=""
    ${local_sid_file_name}=             Get sid Filename     ${config_name}
    log                                 ${local_sid_file_name}
    log                                 ${airmosaic_config_files_path_name}
    prismaTaf.prepare test              ${local_sid_file_name}
    ...                                 ${airmosaic_config_files_path_name}
    ...                                 timeout=${180}
    ...                                 node_name=${airmosaic}

Start tstm uu
    [Documentation]     Start TSTM-Uu-ms-gui (start_nr5g_Uu_ms_gui). It will include the clean tstm_Uu_ms_gui logs.
    ...                 And check if TSTM-Uu-ms-gui startup is successfully completed.
    prismaTaf.clean tstm log            node_name=${lsu_tstmuu}
    Log                                 -------- start tstm Uu ms gui ----------
    prismaTaf.start tstm                node_name=${lsu_tstmuu}                     timeout=${30}
    Sleep                               1min
    Log                                 -------- get tstm tstm Uu ms gui log ----------
    ${response}=                        prismaTaf.get tstm log                      node_name=${lsu_tstmuu}
    ...                                                                             expected_regex="SOKLISTEN"
    Log                                 -------- response is: ${response} ----------
    Log                                 -------- index 0 of response is : ${response[0]} ----------
    Log                                 -------- index 1 of response is : ${response[1]} ----------
    Should be true                      ${response[0]}==True
    ${lines}=                           Get Lines Containing String                 ${response[1]}      SOKLISTEN
    Log                                 -------- mylines: ${lines} ----------
    Should Contain                      ${lines}                                    SOKLISTEN

Stop And Restart tstm uu process
    [Documentation]     Stop and restart TSTM-Uu-ms-gui (start_nr5g_Uu_ms_gui).
    ...                 It will include the clean tstm_Uu_ms_gui logs.
    ...                 And check if TSTM-Uu-ms-gui startup is successfully completed.
    ...                 WA to some failure to do Connect to Tstm (prepareTest)
    # Stopping TSTM-Uu part
    prismaTaf.stop tstm                 node_name=${lsu_tstmuu}
    prismaTaf.clean tstm log            node_name=${lsu_tstmuu}
    # Waiting period
    Sleep                               30s
    Start tstm uu

Start tstm X2
    [Documentation]  Start TSTM-X2 (start_nr_5g_X2). It will include first stop_tstm_X2, then will clean tstm_X2 logs.
    ...              And check if TSTM-X2 startup is successfully completed.
    #prismaTaf.stop tstm                node_name=${lsu_tstmx2}                             timeout=${30}
    prismaTaf.clean tstm log            node_name=${lsu_tstmx2}
    Log                                 -------- start tstm X2 ----------
    prismaTaf.start tstm                node_name=${lsu_tstmx2}                             timeout=${30}
    Sleep                               1min
    Log                                 -------- get tstm X2 log ----------
    ${response}=                        prismaTaf.get tstm log                              node_name=${lsu_tstmx2}
    ...                                 expected_regex="SOKLISTEN"
    Log                                 -------- response is: ${response} ----------
    Log                                 -------- index 0 of response is : ${response[0]} ----------
    Log                                 -------- index 1 of response is : ${response[1]} ----------
    Should be true                      ${response[0]}==True
    ${lines}=                           Get Lines Containing String             ${response[1]}      SOKLISTEN
    Log                                 -------- mylines: ${lines} ----------
    Should Contain                      ${lines}                                            SOKLISTEN

Check Simulator Ready Via Taf
    [Documentation]  values returned possible:
    ...         :return: status, optionals
    ...                NONE, SIMINIT_AVAILABLE_INVALID, SIMINIT_AVAILABLE,
    ...                RUNNING_SIMINIT, RUNNING_SIMINIT_SCEAVAIL, SIMINIT_COMPLETED,
    ...                SCENARIO_AVAILABLE, SCENARIO_RUNNABLE,
    ...                RUNNING_SCENARIO, SCENARIO_COMPLETED, ABNORMAL_FAIL, SID_OPENING
    ${AirmosaicStatus}      prismaTaf.get_scenario_status                           node_name=${airmosaic}
    Should Be True          '${AirmosaicStatus}'=='SCENARIO_RUNNABLE'

Check Simulator Ready For SIMINIT Via Taf
    [Documentation]  values returned possible:
    ...        :return: status, optionals
    ...                NONE, SIMINIT_AVAILABLE_INVALID, SIMINIT_AVAILABLE,
    ...                RUNNING_SIMINIT, RUNNING_SIMINIT_SCEAVAIL, SIMINIT_COMPLETED,
    ...                SCENARIO_AVAILABLE, SCENARIO_RUNNABLE,
    ...                RUNNING_SCENARIO, SCENARIO_COMPLETED, ABNORMAL_FAIL, SID_OPENING
    ${AirmosaicStatus}      prismaTaf.get_scenario_status                           node_name=${airmosaic}
    Should Be True          '${AirmosaicStatus}'=='SIMINIT_COMPLETED' or '${AirmosaicStatus}'=='SIMINIT_AVAILABLE'

Check Simulator Scenario Completed
    [Documentation]  values returned possible:
    ...        :return: status, optionals
    ...                NONE, SIMINIT_AVAILABLE_INVALID, SIMINIT_AVAILABLE,
    ...                RUNNING_SIMINIT, RUNNING_SIMINIT_SCEAVAIL, SIMINIT_COMPLETED,
    ...                SCENARIO_AVAILABLE, SCENARIO_RUNNABLE,
    ...                RUNNING_SCENARIO, SCENARIO_COMPLETED, ABNORMAL_FAIL, SID_OPENING
    ${isScenarioCompleted}      prismaTaf.get_scenario_status                   node_name=${airmosaic}
    Should Be True
    ...                         '${isScenarioCompleted}'=='SCENARIO_COMPLETED' or '${isScenarioCompleted}'=='SCENARIO_AVAILABLE'

Check Simulator Scenario Is Running
    [Documentation]  values returned possible:
    ...        :return: status, optionals
    ...                NONE, SIMINIT_AVAILABLE_INVALID, SIMINIT_AVAILABLE,
    ...                RUNNING_SIMINIT, RUNNING_SIMINIT_SCEAVAIL, SIMINIT_COMPLETED,
    ...                SCENARIO_AVAILABLE, SCENARIO_RUNNABLE,
    ...                RUNNING_SCENARIO, SCENARIO_COMPLETED, ABNORMAL_FAIL, SID_OPENING
    ${isScenarioCompleted}      prismaTaf.get_scenario_status                   node_name=${airmosaic}
    Should Be True              '${isScenarioCompleted}'=='RUNNING_SCENARIO'

Get Prisma Cells Status
    [Documentation]     To get the Prisma Cells Status
    Log                                 Getting the Prisma Cells Status....
    ${collectedPrismaCellsStatus}       prismaTaf.get_cell_status                   node_name=${airmosaic}
    Log                                 ---- Collected Prisma Cells status is: ${collectedPrismaCellsStatus} -----

Startup Prisma Scenario
    [Documentation]     To start Prisma scenario
    Log                 Prisma scenario starting up ....
    Log                 TRYING THE EXECUTE SCENARION COMMAND NEXT ....

Execute Dedicated Prisma Scenario
    [Documentation]     To execute a dedicated Prisma scenario
    Log                 ----------- Prisma scenario executing now is: ${scenario_prisma_file_name} .... -----------
    Log                 ----------- Prisma Scenario to be used-option1: ${scenario_prisma_file_full_name} -----------
    Log                 ----------- Prisma Scenario to be used-option2: ${generated_scenario_prisma_file_name}
    ${isTestExecutionStatus}        prismaTaf.execute_test
    ...                             ${generated_scenario_prisma_file_name}      node_name=${airmosaic}
    Log                 ---- Is test executed successfully (None expected): ${isTestExecutionStatus} -----

Execute Dedicated Prisma Scenario With Arg
    [Documentation]     To execute a dedicated Prisma scenario with Argument
    ...                 Argument is here the dedicated Prisma scenario file to be excuted
    [Arguments]         ${inputPrismaDedicatedScenarioFile}
    Log                 ----------- Prisma scenario executing now is: ${scenario_prisma_file_name} .... -----------
    Log                 ----------- Prisma Scenario to be used-option1: ${scenario_prisma_file_full_name} -----------
    Log                 ----------- Prisma Scenario to be used-option2: ${generated_scenario_prisma_file_name} --------
    Log                 ----------- Prisma Scenario to be used-option3: ${inputPrismaDedicatedScenarioFile} -----------
    ${isTestExecutionStatus}        prismaTaf.execute_test
    ...                 ${inputPrismaDedicatedScenarioFile}      node_name=${airmosaic}
    Log                 ---- Is test executed successfully (None expected): ${isTestExecutionStatus} -----
    # Called with the following dedicated Prisma scenario file undr:   ${2CC_scenario_prisma_file_name}

Check Scenario Status
    [Documentation]     To get the Prisma scenario status
    Log                                 Getting Prisma scenario status ....
    Wait until Keyword Succeeds         15 min          5 s                 Check Simulator Ready

Wait for traffic running
    Sleep       360s

Stop Dedicated Prisma Scenario
    [Documentation]     To stop a dedicated Prisma scenario
    Log                                 Prisma scenario execution stopping now ....
    ${isTestExecutionStoppedStatus}     prismaTaf.stop_test_running                     node_name=${airmosaic}
    Log                                 ---- Is test execution stopped completed: ${isTestExecutionStoppedStatus} -----

Check Scenario Is Completed
    [Documentation]     To get the Prisma scenario status and check it is completed
    Log                             Getting Prisma scenario status and checking completed....
    Wait until Keyword Succeeds     15 min          5 s                 Check Simulator Scenario Completed

Get Prisma Test Results
    [Documentation]     To Get Prisma Test Results
    Log                 Getting the Prisma Test Results....
    ${collectedTestResults}           prismaTaf.get_test_result      node_name=${airmosaic}
    Create File         ${LOG_PATH}/myCollectedTestResults.txt       ${collectedTestResults}
    # To re-read the file with content=Collected Test Result
    OperatingSystem.Get File          ${LOG_PATH}/myCollectedTestResults.txt
    Log                 ---- The Prisma test results are: ${collectedTestResults} -----

Get Prisma Scenario Logger
    [Documentation]     To Get Prisma Scenario Logger
    Log                 Getting the Prisma Scenario Logger....
    ${collectedScenarioLogger}      prismaTaf.get_scenario_logger    output_file=None    node_name=${airmosaic}
    Log                 ---- The Prisma Scenario Logger is: ${collectedScenarioLogger} -----

Get Prisma Scenario Logger And Put To File
    [Documentation]     To Get Prisma Scenario Logger
    Log                 Getting the Prisma Scenario Logger....
    ${collectedScenarioLogger_v2}      prismaTaf.get_scenario_logger
    ...                                output_file=${LOG_PATH}/myCollectedScenarioLogger_v2.txt
    ...                                node_name=${airmosaic}
    # To re-read the file with content=Scenario Logger
    Get File            ${LOG_PATH}/myCollectedScenarioLogger_v2.txt
    Log                 ---- The Prisma Scenario Logger is: ${collectedScenarioLogger_v2} -----

Get Prisma Bug Report
    [Documentation]     To Get Prisma Bug Report
    Log                         Getting the Prisma Bug Report....
    ${collectedBugReport}       prismaTaf.get_bug_report            output_file=${LOG_PATH}/myBugRreport.zip
    ...                         node_name=${airmosaic}
    Log                         ---- The Prisma Scenario Logger is: ${collectedScenarioLogger} -----

Stop Prisma Scenario
    [Documentation]     To stop Prisma scenario
    Log                         Prisma scenario stopping ....
    Log                         DO NOT RUN THE TRAFFIC STOP COMMAND ....
