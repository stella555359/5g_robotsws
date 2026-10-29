*** Settings ***
Documentation
...              This Task serves to collect a group of logs in manual testing
Library    taf.ul.log_collection
Library    DateTime

*** Variables ***
${TARGET_DIR}         /tmp
${COLLECT_SNAPSHOT}   ${True}

*** Tasks ***
Collect All Logs
    ${config_string}=    Catenate    {"SyslogLog"     : {"type": "syslog"},
    ...                               "BipLog"        : {"type": "bip"},
    ...                               "TTITrace"      : {"type": "uplane_trace",
    ...                                                  "components": "L2Ps,L2Lo"},
    ...                               "ProtocolLog1"  : {"type": "protocols",
    ...                                                  "interfaces": "f1c,e1c"},
    ...                               "ProtocolLog2"  : {"type": "protocols",
    ...                                                  "interfaces": "ngc,xnc,x2c"},
    ...                               "EmilLog"       : {"type": "emil"},
    ...                               "AllLogs"       : {"type": "group",
    ...                                                  "members": "SyslogLog, EmilLog, BipLog, ProtocolLog1, ProtocolLog2, TTITrace"},
    ...                               "SnapshotLogs"  : {"type": "snapshot"},
    ...                               "PmCounterLogs" : {"type": "pmcounters"},
    ...                               "CollectOnly"   : {"type": "group",
    ...                                                  "members": "SnapshotLogs, PmCounterLogs"}}


    ${log_configuration}=    Evaluate   ${config_string}

    Create Collectors Using Testline Information    names=AllLogs, CollectOnly
    ...                                             configuration=${log_configuration}
    ...                                             network_elements=gnb_0

    taf.ul.log_collection.Setup Collectors    names=AllLogs
    ${ts}   Get Current Date   result_format=timestamp
    Log To Console    \n[${ts}] Setup Complete, now starting collectors
    taf.ul.log_collection.Start Collectors    names=AllLogs

    # PAUSE THE TESTCASE AND WAIT FOR PRESSING ENTER KEY

    ${starting_timestamp}   Get Current Date   result_format=timestamp

    Log To Console   \n[${starting_timestamp}] Logs are started. Hit ENTER to stop the logs and collect them!
    ${output}    Evaluate    input("")

    ${stopping_timestamp}   Get Current Date   result_format=timestamp
    Log To Console   \n[${stopping_timestamp}] Collecting all startable Logs...

    taf.ul.log_collection.Stop Collectors      names=AllLogs
    taf.ul.log_collection.Collect Collectors   names=AllLogs    target_dir=${TARGET_DIR}
    taf.ul.log_collection.Teardown Collectors  names=AllLogs

    ${timestamp}   Get Current Date   result_format=timestamp
    Log To Console   \n[${timestamp}] All startable Logs collected

    IF   ${COLLECT_SNAPSHOT}
        ${timestamp}   Get Current Date   result_format=timestamp
        Log To Console   \n[${timestamp}] Collecting snapshots and pm counters
    END

    taf.ul.log_collection.Setup Collectors     names=CollectOnly
    taf.ul.log_collection.Collect Collectors   names=CollectOnly     target_dir=${TARGET_DIR}
    taf.ul.log_collection.Teardown Collectors  names=CollectOnly

    ${syslog_files}=   taf.ul.log_collection.Get Log File    log_type=syslog         target_dir=${TARGET_DIR}   network_element=gnb_0
    ${bip_files}=      taf.ul.log_collection.Get Log File    log_type=bip            target_dir=${TARGET_DIR}   network_element=gnb_0
    ${emil_logs}=      taf.ul.log_collection.Get Log File    log_type=Emil           target_dir=${TARGET_DIR}   network_element=gnb_0
    ${uplane_logs}=    taf.ul.log_collection.Get Log File    log_type=uplane_trace   target_dir=${TARGET_DIR}   network_element=gnb_0

    ${timestamp}   Get Current Date   result_format=timestamp
    Log To Console    \n[${timestamp}] All Logs collected
    Log To Console    \nAll Logs collected in: ${TARGET_DIR}
    Log To Console    \nSyslog: ${syslog_files}
    Log To Console    \nBIP Trace: ${bip_files}
    Log To Console    \nEmil: ${emil_logs}
    Log To Console    \nUplane: ${uplane_logs}



