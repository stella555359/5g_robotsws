*** Settings ***
Documentation        keywords for logs capture, decode, parse...
...                  update: 27.07.2020: add keywords from 509 B2 B1


Library      taf.collectors.tcpdump                  WITH NAME      tcpdump
Library      taf.collectors.core                     WITH NAME      core
Library      ../python/logs_handler.py
#Resource     ../../../resources_sg_radioPerf/robot/Keywords_gNB.robot


*** Keywords ***
Stop gNB X2 traces
    [Documentation]     Stop X2 traces collection on gNB
    [Arguments]         ${collectors}=X2Traces
    Log                Stop X2 traces on gNB     console=${DEBUG_MODE_CONSOLE}
    #run keyword and ignore error         core.stop_collectors        names=${collectors}
    run keyword and ignore error       logs_handler.Stop Tcpdump    name=${collectors}
    ...                                                 host=${ASIK_ADDR[0]}
    ...                                                 user=${ASIK_USERNAME[0]}
    ...                                                 password=${ASIK_PASSWORD[0]}
    #run keyword and ignore error        core.teardown_collectors    names=${collectors}


Start gNB X2 traces
    [Documentation]     Start X2 traces collection on gNB
    [Arguments]         ${collectors}=X2Traces    ${br_id}=1
    Log 				Start X2 traces on gNB   console=${DEBUG_MODE_CONSOLE}
    # Configure X2 traces on gNB
    ${asib_config}=      create dictionary    host=${ASIK_ADDR[0]}
    ...                                     user=${ASIK_USERNAME[0]}
    ...                                     password=${ASIK_PASSWORD[0]}
    tcpdump.create_tcpdump_collector    name=${collectors}
    ...                                 options=-i br${br_id}.${CORE_VLAN[0]}
    ...                                 executor=${asib_config}
    # Start X2 traces
    core.setup_collectors   names=${collectors}
    core.start_collectors   names=${collectors}


Stop and collect gNB X2 traces
    [Documentation]     Stop X2 traces collection on gNB and collects the log files in default path.
    [Arguments]         ${target_path}      ${target_filename}=tcpdump_X2Traces.pcap
    ...                 ${collect_add_time}=60s     ${collectors}=X2Traces
    Log	      	Stop and collect X2 traces on gNB and collect traces (file=${target_filename}, path= ${target_path})
    ...         console=${DEBUG_MODE_CONSOLE}

    #run keyword and ignore error         core.stop_collectors        names=${collectors}
    run keyword and ignore error        logs_handler.Stop Tcpdump    name=${collectors}
    ...                                                 host=${ASIK_ADDR[0]}
    ...                                                 user=${ASIK_USERNAME[0]}
    ...                                                 password=${ASIK_PASSWORD[0]}
    Sleep      3s
    logs_handler.Collect Tcpdump    name=${collectors}
    ...                host=${ASIK_ADDR[0]}
    ...                user=${ASIK_USERNAME[0]}
    ...                password=${ASIK_PASSWORD[0]}
    ...                target_dir=${target_path}
    ...                target_file=${target_filename}

    Log          wait ${collect_add_time}      console=${DEBUG_MODE_CONSOLE}
    Sleep        ${collect_add_time}
