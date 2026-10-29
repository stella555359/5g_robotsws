*** Settings ***
Library    Collections
Library    taf.transport.ssh                    WITH NAME   ssh
Library    taf.collectors.core                  WITH NAME   cc
Library    taf.collectors.btslog                WITH NAME   btslog
Library    ./pcap_verification/run_tcpdump.py   WITH NAME   tcpdump_py
Library    rrm_fixture.py
Library    logs.py
Library    ./webUI_operations.py
Library    ./preconditions_py.py


Resource   ./connections.robot
Resource   ./preconditions.robot

Documentation  Set of keywords log gathering

*** Variables ***
${log_index}
${gnbMirroring_filtering}=   off

*** Keywords ***
Start tracing on SMOD
    [Documentation]   Keyword starts tracing on SMOD Master node as default and/or on SMOD Slave node with given argument.
    ...               Usage to capture traces on both nodes as below:
    ...                 Start tracing on SMOD  True  True
    ...               or
    ...                 Start tracing on SMOD  smod slave=True
    ...               ${interface} - capture packets on all interfaces as default, possible on given interface,
    ...                              e.g. x2 interface - fp0.${tl.gnbs[0].cu.x2c.vlan_id}
    ...               ${filter} -    sctp as default, possible to catch e.g. number of packets "-c <num_of_packets>"
    ...               ${log_index} - empty as default, enable to capture and save logs if this keyword is used more than
    ...                              once in the test, samples value could be: 1st_run, 2nd_run etc, set outside the keyword,
    ...                              sample of usage in 5GC001836 TCs
    [Arguments]       ${smod master}=True   ${smod slave}=True
    ...               ${filename}=${test_name}_SMOD${log_index}
    ...               ${interface master}=any   ${interface slave}=any   ${filter master}=sctp   ${filter slave}=sctp

    ${smod type}=            Get SMOD Name
    ${smod slave}=           Set SMOD Slave     ${smod slave}
    ${smod master alias}=    Connect to SMOD
    ${smod slave alias}=     Connect to SMOD SLAVE
    Set suite variable        ${smod master}
    Set suite variable        ${smod slave}

    Run Keyword if   ${smod master}
    ...        ssh.send_command
    ...              command=tcpdump -i ${interface master} ${filter master} -w "/tmp/${filename}_${smod master alias}.pcap"
    ...              connection=${smod master alias}
    Run Keyword if   ${smod slave}
    ...        ssh.send_command
    ...              command=tcpdump -i ${interface slave} ${filter slave} -w "/tmp/${filename}_${smod slave alias}.pcap"
    ...              connection=${smod slave alias}

Stop tracing and download logs from SMOD
    [Documentation]  Stop and dwonload logs from node/s defined during starting tracing
    [Arguments]      ${filename}=${test_name}_SMOD${log_index}  ${offset}=0s  ${stop_tracing}=YES
    BuiltIn.Sleep   ${offset}  wait till logs collected
    ${smod master alias}=    Connect to SMOD
    ${smod slave alias}=     Connect to SMOD SLAVE

    Run Keyword if   ${smod master}
    ...    Run keywords
    ...        Run Keyword If  '${stop_tracing}' == 'YES'   ssh.execute
    ...              command=killall tcpdump
    ...              connection=${smod master alias}                                                             AND
    ...        ssh.execute
    ...              command=chmod 777 /tmp/${filename}_${smod master alias}.pcap
    ...              connection=${smod master alias}                                                             AND
    ...        ssh.download_file
    ...              /tmp/${filename}_${smod master alias}.pcap
    ...              ${LOG_PATH}/${filename}_${smod master alias}.pcap
    ...              connection=${smod master alias}                                                             AND
    ...        Run Keyword If  '${stop_tracing}' == 'YES'   ssh.execute
    ...              command=rm "/tmp/${filename}_${smod master alias}.pcap"
    ...              connection=${smod master alias}

    Run Keyword if   ${smod slave}
    ...    Run keywords
    ...        Run Keyword If  '${stop_tracing}' == 'YES'   ssh.execute
    ...              command=killall tcpdump
    ...              connection=${smod master alias}                                                             AND
    ...        ssh.execute
    ...              command=chmod 777 /tmp/${filename}_${smod slave alias}.pcap
    ...              connection=${smod slave alias}                                                              AND
    ...        ssh.download_file
    ...              /tmp/${filename}_${smod slave alias}.pcap
    ...              ${LOG_PATH}/${filename}_${smod slave alias}.pcap
    ...              connection=${smod slave alias}                                                              AND
    ...        Run Keyword If  '${stop_tracing}' == 'YES'   ssh.execute
    ...              command=rm "/tmp/${filename}_${smod slave alias}.pcap"
    ...              connection=${smod slave alias}

    Run Keyword if    ${smod master} and ${smod slave}
    ...    logs.merge pcap  ${LOG_PATH}  /${filename}.pcap
    ...              "${LOG_PATH}/${filename}_${smod master alias}.pcap" "${LOG_PATH}/${filename}_${smod slave alias}.pcap"
    ...    ELSE IF    ${smod master}     rename pcap     ${LOG_PATH}/${filename}_${smod master alias}.pcap
    ...                ${LOG_PATH}/${filename}.pcap
    ...    ELSE IF    ${smod slave}      rename pcap     ${LOG_PATH}/${filename}_${smod slave alias}.pcap
    ...                ${LOG_PATH}/${filename}.pcap
    [Return]   ${LOG_PATH}/${filename}.pcap

Stop tracing on SMOD
    [Documentation]  Abort tracing on node/s defined during start tracing, use in Teardown section
     ...             as protection when TC failed after starting logs collection
    ${smod master alias}=    Connect to SMOD
    ${smod slave alias}=     Connect to SMOD SLAVE
    Run Keyword if   ${smod master}
    ...        ssh.execute
    ...              command=killall tcpdump
    ...              connection=${smod master alias}
    Run Keyword if   ${smod slave}
    ...        ssh.execute
    ...              command=killall tcpdump
    ...              connection=${smod slave alias}


Get Logs From CPIF
  [Documentation]
  ...  The purpose of this example is to present sending command by nested connection
  ...  (through OAM to CPIF in this case).
  ...  Alias assigned in the Connect to OAM keyword is then used to serve as a proxy.
  [Arguments]     ${hostname}=cpif-0.local  ${filename}=CPIF_journal.log   ${alias}=CPIF    ${proxy}=OAM
  Connect to OAM      alias=${proxy}
  ssh.connect to      hostname=${hostname}
  ...                 username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...                 password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
  ...                 alias=${alias}
  ...                 proxy=${proxy}
  ssh.execute    command=journalctl -b > ${filename}   connection=CPIF
  ssh.download_file    /home/robot/${filename}   ${LOG_PATH}/${filename}  connection=CPIF


Start tcpdump on CU
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any
    ${alias}=    Connect to gNB


    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              Start tracing on SMOD  smod master=True   smod slave=True   filename=${filename}   interface master=${interface}
    ...                                     interface slave=${interface}   filter master=sctp   filter slave=sctp
    ...              ELSE
    ...              ssh.send_command    command=sudo tcpdump sctp -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    sleep   3 s


Teardown tcpdump on CU and download logs
    [Arguments]     ${filename}=${test_name}.pcap
    Run Keyword and Ignore Error    Stop tcpdump on CU and download logs    filename=${filename}


Stop tcpdump on CU and download logs
    [Arguments]     ${filename}=${test_name}.pcap
    sleep   3 s
    ${alias}=        Connect to gNB

    Run Keyword if       '${BTS_TYPE}' == 'ClassicalBts'
    ...                  Download pcap from SMOD and rename    filename=${filename}

    Run Keyword If       '${BTS_TYPE}' != 'ClassicalBts'
    ...                  ssh.execute
    ...                  command=sudo killall tcpdump
    ...                  connection=${alias}
    Sleep  5s
    ssh.execute          command=chmod 777 /tmp/${filename}
    ...                  connection=${alias}

    Run Keyword If       '${BTS_TYPE}' != 'ClassicalBts'
    ...                  ssh.download_file
    ...                  /tmp/${filename}
    ...                  ${LOG_PATH}/${filename}
    ...                  connection=${alias}

    Run Keyword If       '${BTS_TYPE}' != 'ClassicalBts'
    ...                  ssh.execute
    ...                  command=sudo rm "/home/robot/${filename}"
    ...                  connection=${alias}
    sleep   3 s


Download pcap from SMOD and rename
    [Arguments]    ${filename}=${test_name}.pcap
    ${file}=    Stop tracing and download logs from SMOD    filename=${filename}
    Move file   ${file}   ${LOG_PATH}/${filename}


Connection to abil master if release is 5G19B else slave
    ${abil_alias_name}=     return_master_if_release_is_5G19B_else_slave
    ${abil_alias}=          Connect to ABIL ${abil_alias_name}
    [Return]                ${abil_alias}


Start tcpdump on DU
    [Arguments]     ${filename}=${test_name}.pcap
    ${alias}=           Connection to abil master if release is 5G19B else slave
    ssh.send_command    command=tcpdump -i any -w "/tmp/${filename}"
    ...                 connection=${alias}


Stop tcpdump on DU and download logs
    [Arguments]     ${filename}=${test_name}.pcap
    ${alias}=           Connection to abil master if release is 5G19B else slave
    ssh.execute         command=killall tcpdump
    ...                 connection=${alias}
    ssh.download file   remote_path=/tmp/${filename}
    ...                 local_path=${LOG_PATH}/${filename}
    ...                 connection=${alias}
    ssh.execute         command=rm "/tmp/${filename}"
    ...                 connection=${alias}
    [Return]   ${filename}


Kill tcpdump on CU
    ${alias}=           Connect to gNB
    ssh.execute         command=killall tcpdump
    ...                 connection=${alias}


Kill tcpdump on DU
    ${alias}=           Connection to abil master if release is 5G19B else slave
    ssh.execute         command=killall tcpdump
    ...                 connection=${alias}


Get startup_DEFAULT.log from ASIK
    Connect to ASIK
    ${is_log_packed}=     ssh.file_exists   /tmp/startup_DEFAULT.log.xz   connection=ASIK
    ${is_log_unpacked}=   ssh.file_exists   /tmp/startup_DEFAULT.log   connection=ASIK
    Run keyword if   ${is_log_packed}
    ...   ssh.download_file    /tmp/startup_DEFAULT.log.xz  ${LOG_PATH}/startup_DEFAULT.log.xz   connection=ASIK
    Run keyword if   ${is_log_unpacked}
    ...   Get unpcked startup_DEFAULT.log


Get unpcked startup_DEFAULT.log
    ssh.download_file    /tmp/startup_DEFAULT.log  ${LOG_PATH}/startup_DEFAULT.log   connection=ASIK
    Run   zip ${LOG_PATH}/startup_DEFAULT.zip ${LOG_PATH}/startup_DEFAULT.log
    Run   rm ${LOG_PATH}/startup_DEFAULT.log


Start syslog collection
    [Arguments]   ${name}=SYSLOG
    ...           ${path}=/tmp/btslog2
    btslog.Create btslog collector
    ...                         name=${name}
    ...                         log_dir=${path}
    btslog.Setup collectors     names=${name}
    btslog.Start collectors     names=${name}
    btslog.Set suite alias      ${name}


Stop syslog collection
    [Arguments]   ${name}=SYSLOG
    ...           ${path}=/tmp/btslog2
    btslog.Stop collectors      names=${name}
    btslog.Collect collectors   names=${name}
    btslog.Teardown collectors  names=${name}
    Remove directory   ${path}   recursive=${True}


Start tcpdump
  [Documentation]
  ...  Start tcpdump on asik and send the output to the local VM
    tcpdump_py.start_tcpdump


Stop tcpdump
  [Documentation]
  ...  Kill tcpdump and zip the logs
    tcpdump_py.stop_tcpdump
    Run   call("zip -r pcap_logs.zip *.pcap", shell=True)

#***************************************** L1L2 tracing ****************************************************************

Activate L1L2 traces on ASIK
    [Documentation]     Keywords based on scripts \\eseefsn50.emea.nsn-net.net\rotta4internal\5G\Oulu_L3_CAMP\gnbMirroring\V23
    ...                 only for ASIK and one ABIL
    ...                 MIRRORING_MODE               remote/standalone
    ...                     remote mirrors to EIF2, standalone makes tcpdump in the ABIL Slave Xeon
    ...                 ENABLE_SYSCOM_MIRRORING      true/false,
    ...                     mirrors syscom traffic between ASIK and ABIL
    ...                 CARRIER_AGGREGATION          true/false
    ...                     for GC2/GD2 L2-RT instances
    [Arguments]         ${operation}=enable   ${mirroring mode}=standalone   ${syscom mirroring}=true   ${carrier aggregation}=false
    set test variable   ${mirroring mode}
    set test variable   ${syscom mirroring}
    set test variable   ${carrier aggregation}
    Set mirroring in ABIL LONER    ${operation}
    Set mirroring in ASIK          ${operation}   ${mirroring mode}   ${syscom mirroring}   ${carrier aggregation}
    sleep   5s          time needed to fully activate gNB mirroring procedure

Deactivate L1L2 traces on ASIK
    [Arguments]         ${operation}=disable   ${mirroring mode}=standalone   ${syscom mirroring}=true   ${carrier aggregation}=false
    Set mirroring in ABIL LONER    ${operation}
    Set mirroring in ASIK   ${operation}   ${mirroring mode}   ${syscom mirroring}   ${carrier aggregation}

Delete L1L2 traces on ASIK
    [Arguments]         ${filename}=${test_name}_l1l2.pcap
    ${ASIK}=            Connect to ASIK
    ${ABIL_SLAVE}=      Connect to ABIL SLAVE
    ssh.execute         command=killall tcpdump                     connection=${ABIL_SLAVE}
    ssh.execute         command=rm "/ffs/run/config/${filename}"      connection=${ASIK}

Start L1L2 traces on ASIK
    [Documentation]
    ...  Start tcpdump on asik always with tcpdump filter '-c' (number of capture packets) to save ASIK's storage
    [Arguments]         ${filename}=${test_name}_l1l2.pcap   ${filter}=${EMPTY}   ${capture time}=10 s
    ...                 ${with trace activation}=true
    Run Keyword If     '${with trace activation}' == 'true'
    ...                 Activate L1L2 traces on ASIK
    ${ABIL_SLAVE}=      Connect to ABIL SLAVE
    ssh.send command    command=tcpdump -i ethbp1 ${filter} -w "/ffs/run/config/${filename}"   connection=${ABIL_SLAVE}
    sleep               ${capture time}    set time needed to capture requested tcpdump packets

Stop L1L2 traces on ASIK and get logs
    [Arguments]         ${filename}=${test_name}_l1l2.pcap
    ${ASIK}=            Connect to ASIK
    ${ABIL_SLAVE}=      Connect to ABIL SLAVE
    ssh.execute         command=killall tcpdump                     connection=${ABIL_SLAVE}
    ssh.download file   remote_path=/ffs/run/config/${filename}
    ...                 local_path=${LOG_PATH}/${filename}
    ...                 connection=${ASIK}
    ssh.execute         command=rm "/ffs/run/config/${filename}"      connection=${ASIK}
    Delete L1L2 traces on ASIK   filename=${filename}
    [Return]   ${filename}

#***********************************************************************************************************************

Start tcpdump on LTE
    [Arguments]       ${filename}=${test_name}_lte.pcap   ${interface}=any
    ${lte_pc}=         Connect to LTE BTS
    ssh.send_command   command=tcpdump sctp -i ${interface} -w "${filename}"
    ...                connection=${lte_pc}
    sleep   3 s


Stop tcpdump on LTE and get logs
    [Arguments]     ${filename}=${test_name}_lte.pcap
    sleep   3 s
    ${lte_pc}=    Connect to LTE BTS

    ssh.execute   command=killall tcpdump
    ...           connection=${lte_pc}
    Sleep  5s
    ssh.download_file   remote_path=/user/toor4nsn/${filename}
    ...                 local_path=${LOG_PATH}/${filename}
    ...                 connection=${lte_pc}


Get cell setup tcpdump logs
    [Arguments]  ${abil_pcap_name}=${test_name}__abil_cell_setup.pcap
    ...          ${asik_pcap_name}=${test_name}__asik_cell_setup.pcap
    Trigger site reset
    Wait until keyword succeeds   600   1   Is ASIK and ABIL ready
    Sleep   15
    Start tcpdump on CU   filename=${asik_pcap_name}
    Start tcpdump on DU   filename=${abil_pcap_name}
    webUI_operations.Wait for all cells on air state
    Sleep   10   reason=To make sure the log is caught
    Stop tcpdump on DU and download logs   filename=${abil_pcap_name}
    Stop tcpdump on CU and download logs   filename=${asik_pcap_name}
    [Return]  ${LOG_PATH}/${abil_pcap_name}   ${LOG_PATH}/${asik_pcap_name}


Check if file exist
    ${ASIK}=    Connect to SMOD
    ${output_all}    ssh.execute    command=ls /tmp/ | grep .pcap
    ...                 connection=${ASIK}
    log     ${output_all}
    ${ABIL}=    Connect to BBMOD SLAVE
    ${output_all}    ssh.execute    command=ls /tmp/ | grep .pcap
    ...                 connection=${ABIL}
    log     ${output_all}

#*********************************************gnbMirroring**********************************************************************
Start gnbMirroring
    [Documentation]  Upload and start the gnbMirroring.sh script on ASIK. Needs to be stopped.
    ...  ${gnbMirroring_filtering} - on/off or tcpdump filter like: '!(ether[24:2] = 0x0122 || ether[24:2] = 0x0233)' -c 10000
    [Arguments]   ${gnbMirroring_filtering}=off   ${max_file_size_mbytes}=500   ${capturing_time_seconds}='infinite'
    ...           ${syscom_mirroring}=off    ${bb_slots}=${None}
    ${filter}=   Assign specific filter to gnbMirroring   filtering=${gnbMirroring_filtering}
    Enable Mirroring In BB Slots    ${bb_slots}
    Set global variable    ${gnbMirroring_filtering}   ${filter}
    Upload gnbMirroring Script To ASIK
    ${asik_alias}=    Connect to ASIK
    set test variable  ${p1}   --filtering=${gnbMirroring_filtering} --number_of_files=1 --file_size_mbytes=${max_file_size_mbytes}
    set test variable  ${p2}   --capturing_time_seconds=${capturing_time_seconds}
    set test variable  ${p3}   --syscom_mirroring=${syscom_mirroring}
    ssh.Send Command   command=nohup sh /ffs/run/config/scripts/gnbMirroring.sh ${p1} ${p2} ${p3}   connection=${asik_alias}
    ssh.Read Output Until    Filter    timeout=30    connection=${asik_alias}
    Log to console   Started gnbMirroring.sh!


Stop gnbMirroring And Gather L1L2 logs
    [Documentation]  Stops the gnbMirroring.sh script and downloads logs from ASIK to a chosen directory.
    [Arguments]   ${filename}=${test_name}_L1L2.pcap
    ${asik_alias}=           Connect to ASIK
    ${abil_master_alias}=    Connect to ABIL MASTER
    ssh.Execute         command=killall tcpdump   connection=${abil_master_alias}
    Sleep  5s
    Log to console      gnbMirroring.sh stopped!
    Wait until keyword succeeds   30s   3s
    ...                           ssh.Assert File Exists    /tmp/tcpdump_L2L1_bip_filtering_${gnbMirroring_filtering}.pcap
    ...                                                     connection=${asik_alias}
    ssh.Download File   local_path=${LOG_PATH}/${filename}
    ...                       remote_path=/tmp/tcpdump_L2L1_bip_filtering_${gnbMirroring_filtering}.pcap
    ...                       connection=${asik_alias}
    ssh.Execute   command=rm /tmp/tcpdump_L2L1*   connection=${asik_alias}
    Restore original gnbMirroring
    [Return]   ${LOG_PATH}/${filename}


Upload gnbMirroring Script To ASIK
    [Documentation]   Uploads the gnbMirroring.sh script, which sets up and collects L1L2 logs.
    [Arguments]       ${script_folder}=${EXECDIR}/testsuite/Wroclaw/RRM/resources/gnbMirroring
    ${asik_alias}=    Connect To ASIK
    ${remote_path}=   Set Variable    /ffs/run/config/scripts
    ssh.Execute       command=mkdir ${remote_path}   connection=${asik_alias}
    ssh.Upload File   local_path=${script_folder}/gnbMirroring.sh
    ...               remote_path=${remote_path}/gnbMirroring.sh
    ...               connection=${asik_alias}
    ssh.Upload File   local_path=${script_folder}/gnbMirroringConfig.sh
    ...               remote_path=${remote_path}/gnbMirroringConfig.sh
    ...               connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/gnbMirroring.sh         connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/gnbMirroringConfig.sh   connection=${asik_alias}


#*********************************************end of gnbMirroring***************************************************************
Start tcpdump on BBMOD
    [Arguments]   ${BSH_NAME}   ${filename}=${test_name}.pcap
    ${alias}=           Connect to BBMOD ${BSH_NAME}
    ssh.send_command    command=tcpdump sctp -i any -w "/tmp/${filename}"
    ...                 connection=${alias}


Stop tcpdump on BBMOD and download logs
    [Arguments]   ${BSH_NAME}   ${filename}=${test_name}.pcap
    ${alias}=           Connect to BBMOD ${BSH_NAME}
    ssh.execute         command=killall tcpdump
    ...                 connection=${alias}
    ssh.download file   remote_path=/tmp/${filename}
    ...                 local_path=${LOG_PATH}/${filename}
    ...                 connection=${alias}
    ssh.execute         command=rm "/tmp/${filename}"
    ...                 connection=${alias}
    [Return]   ${LOG_PATH}/${filename}


Kill tcpdump on ${ALIAS}
    ssh.execute         command=killall tcpdump
    ...                 connection=${ALIAS}


Kill tcpdump on SMOD and BBMOD
    ${bbmod_master}=    Connect to BBMOD MASTER
    Kill tcpdump on ${bbmod_master}
    ${bbmod_slave}=     Connect to BBMOD SLAVE
    Kill tcpdump on ${bbmod_slave}
    ${smod_master}=     Connect to SMOD
    Kill tcpdump on ${smod_master}


#*********************************************ABIO_BIP_Mirroring**********************************************************************
Start ABIO BIP Mirroring
    [Documentation]  Upload and start the ABIO_BIP_Mirroring.sh script on ASIK. Needs to be stopped.
    Upload ABIO BIP Mirroring Script To ASIK
    ${asik_alias}=    Connect to ASIK
    ssh.Send Command   command=nohup sh /ffs/run/config/scripts/ABIO_BIP_Mirroring.sh 1   connection=${asik_alias}
    ssh.Read Output Until    collecting L1L2 logs    timeout=20    connection=${asik_alias}
    Log to console   Started ABIO_BIP_Mirroring.sh!


Stop ABIO BIP Mirroring And Gather L1L2 logs
    [Documentation]  Stops the ABIO_BIP_Mirroring.sh script and downloads logs from ASIK to a chosen directory.
    [Arguments]   ${filename}=${test_name}_ABIO_L1L2.pcap
    ${asik_alias}=           Connect to ASIK
    ${abil_master_alias}=    Connect to ABIL MASTER
    ssh.Execute         command=killall tcpdump   connection=${abil_master_alias}
    ssh.Execute         command=killall tcpdump   connection=${asik_alias}
    Log to console      ABIO_BIP_Mirroring.sh stopped!
    Wait until keyword succeeds   30s   3s
    ...                           ssh.Assert File Exists    /tmp/trace_ABIO.pcap0
    ...                                                     connection=${asik_alias}
    ssh.Download File   local_path=${LOG_PATH}/${filename}
    ...                       remote_path=/tmp/trace_ABIO.pcap0
    ...                       connection=${asik_alias}
    ssh.Execute   command=rm /tmp/trace_ABIO*   connection=${asik_alias}
#    Restore original gnbMirroring
    [Return]   ${LOG_PATH}/${filename}


Upload ABIO BIP Mirroring Script To ASIK
    [Documentation]   Uploads the ABIO_BIP_Mirroring.sh script, which sets up and collects L1L2 logs.
    ${asik_alias}=    Connect To ASIK
    ${remote_path}=   Set Variable    /ffs/run/config/scripts
    ssh.Execute       command=mkdir ${remote_path}   connection=${asik_alias}
    ssh.Upload File   local_path=${EXECDIR}/testsuite/Wroclaw/RRM/resources/ABIO_BIP_Mirroring/ABIO_BIP_Mirroring.sh
    ...               remote_path=${remote_path}/ABIO_BIP_Mirroring.sh
    ...               connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/ABIO_BIP_Mirroring.sh         connection=${asik_alias}
#*********************************************End of ABIO_BIP_Mirroring***************************************************************
