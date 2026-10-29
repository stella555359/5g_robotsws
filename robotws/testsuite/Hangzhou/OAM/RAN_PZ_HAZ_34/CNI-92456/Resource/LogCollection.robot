*** Settings ***
Resource   Common.robot

*** Variables ***

*** Keyword ***
# =================================================================================================================================================
# =================================================================================================================================================
# =================================================================================================================================================
# BTSLOG
Start Syslog Process
    [Arguments]   ${test_pc_addr}   ${test_pc_username}   ${test_pc_password}
    Log To Console   Start Syslog Process In PC: ${test_pc_addr}
    csn.Connect to   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}

    Run Keyword And Ignore Error   Clean BTSlog Process   connection=${test_pc_addr}
    Run Keyword And Ignore Error   Clean BTSlog File   connection=${test_pc_addr}

    &{executor}   Create Dictionary    host=${test_pc_addr}   user=${test_pc_username}   password=${test_pc_password}
    btslog.create_btslog_collector
    ...   name=btslog_${test_pc_addr}
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    ...   executor=${executor}
    btslog.Set Global Alias   btslog_${test_pc_addr}
    core.setup_collectors   names=btslog_${test_pc_addr}
    core.start_collectors   names=btslog_${test_pc_addr}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Stop Syslog Process
    [Arguments]   ${test_pc_addr}   ${test_pc_username}   ${test_pc_password}
    Log To Console   Stop Syslog Process In PC: ${test_pc_addr}
    Run Keyword And Ignore Error   core.stop_collectors   names=btslog_${test_pc_addr}


Save Syslog Process
    [Arguments]   ${test_pc_addr}   ${test_pc_username}   ${test_pc_password}
    Log To Console   Save Syslog Process In PC: ${test_pc_addr}
    csn.Connect to   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}

    ${btslog_name}   Set Variable   SYSLOG_${test_pc_addr}.LOG
    csn.Execute   command=cd /tmp/btslog2; cat SYSLOG_*.LOG > ${btslog_name}   connection=${test_pc_addr}

    csn.Download File
    ...   remote_path=/tmp/btslog2/${btslog_name}
    ...   local_path=${OUTPUT_DIR}/${btslog_name}
    ...   connection=${test_pc_addr}
    ...   timeout=${300}
    # Run Keyword And Ignore Error   Clean BTSlog File   connection=${test_pc_addr}
    Log To Console   Syslog: ${OUTPUT_DIR}/${btslog_name}
    [Return]   ${OUTPUT_DIR}/${btslog_name}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Clean BTSlog Process
    [Arguments]   ${connection}

    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -nogui'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog'            connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer          connection=${connection}   timeout=${60}

    ${status}   ${iptables_ruls}   Run Keyword And Ignore Error   csn.Execute    sudo iptables -L   connection=${connection}   timeout=${60}
    ${contain_100}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.100.0/24
    ${contain_101}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.101.0/24
    Run Keyword And Ignore Error   run keyword if  not ${contain_100}   csn.Execute
    ...   command=sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT   timeout=${60}   connection=${connection}
    Run Keyword And Ignore Error   run keyword if  not ${contain_101}    csn.Execute
    ...   command=sudo iptables -I INPUT -p udp -s 192.168.101.1/24 -j ACCEPT   timeout=${60}   connection=${connection}


Clean BTSlog File
    [Arguments]   ${connection}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin         connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.LOG               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.zip               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=mkdir /tmp/btslog2                             connection=${connection}   timeout=${60}


# =================================================================================================================================================
# =================================================================================================================================================
# =================================================================================================================================================
# L1 Journal
Start Collect L1 Journal Logs
    [Arguments]   ${ssh_addr}   ${ssh_username}   ${ssh_password}   ${loki_index}=1
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=L1JN
    csn.Send Command   command=bsh 1:${loki_index} journalctl -f > /tmp/journal.log &    connection=L1JN
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=L1JN


Stop Collect L1 Journal Logs
    [Arguments]   ${ssh_addr}   ${ssh_username}   ${ssh_password}
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=L1JN
    csn.Execute   command=ps -ef | grep ssh | grep journalctl | grep -v grep | awk '{print $2}' | xargs kill -15   connection=L1JN
    csn.Execute   command=chmod 777 /tmp/journal.log   connection=L1JN
    csn.Download File   remote_path=/tmp/journal.log    local_path=${OUTPUT_DIR}/journal.log   connection=L1JN
    [Return]   ${OUTPUT_DIR}/journal.log
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=L1JN


# =================================================================================================================================================
# =================================================================================================================================================
# =================================================================================================================================================
# Configure L1 IQ
Configure L1 IQ
    [Arguments]   ${webem_addr}   ${webem_username}   ${webem_password}
    coam.connect_to
    ...   bts_host=${webem_addr}
    ...   bts_port=${443}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${OUTPUT_DIR}
    ...   name=L1IQ

    ${bbmod_dn}   coam.get_managed_objects   class_name=BBMOD_R   timeout=${60}   connection=L1IQ
    ${ul_lte_subcell_list}   Create List   ${1}
    coam.configure_uplane_l1_iq_data
    ...   module_dn=${bbmod_dn[0]['distName']}
    ...   capture_on_event=${True}
    ...   ul_lte_subcell_list=${ul_lte_subcell_list}
    ...   connection=L1IQ
    [Teardown]   coam.teardown   connection=L1IQ

# Configure L1 UL Event
Configure L1 UL Event
    [Arguments]   ${ssh_addr}   ${ssh_username}   ${ssh_password}   ${loki_index}=1
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=L1JN
    csn.Execute   command=bsh 1:${loki_index} confmgmtbrowser write CommonPhy enableAutoSnapshot 1   connection=L1JN
    csn.Execute   command=bsh 1:${loki_index} confmgmtbrowser write CommonPhy minutesToTrigAutoBTSSnapshot 10   connection=L1JN
    csn.Execute   command=bsh 1:${loki_index} confmgmtbrowser write CommonPhy nbOfEventsToTrigAutoBTSSnapshot 1   connection=L1JN
    csn.Execute   command=bsh 1:${loki_index} confmgmtbrowser write LteUlPhy phyEventEnableExt 2147483648   connection=L1JN
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=L1JN
