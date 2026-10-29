*** Settings ***

Documentation     
    ...     Keywords for dcap handling, default is set to emil traces
    ...
    ...     trace type is generally set by custom profile variable;
    ...     possible options (only gNB (5G) options) are listed here:
    ...    | cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component,
    ...    | L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa,             |
    ...    | L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream
    ...
    ...    these values are defined in 
    ...
    ...    https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.sw.dcap.rd.interface.rd.start_trace
    ...
    ...    and mapped to a tracer_id and trace interface. This mapping and detailed setting for each profile can be found in dcap code: 
    ...
    ...    robotws/.venv/lib/python3.6/site-packages/taf/sw/dcap/rd/cm/cm_base.py
    ...
    ...    several traces can be started and stopped together by creating a list of custom profiles, but at the moment it's not 
    ...    possible to start single traces on after the other.
    ...    
    ...    The following table shows the tested custom profiles and the supported sequence for each.
    ...    If you mix multiple custom profiles be sure they are compatible with each other.
    ...    Mixing profiles that require only start/stop with profiles that require start/stop/collect works but requires also 
    ...    start/stop/collect sequence.
    ...    Consider putting the Collect in the teardown of the keyword, so that if the stop fails you are still able to get some logs.
    ...    Feel free to modify the table if your experience does not match the information provided there or if there is missing data.
    ...    
    ...    | Custom Profile          | Start/Stop/Collect  | Start/Collect |
    ...    | cp_5g                   | X                   |               |
    ...    | immediateSnapshot_5g    | X                   |               |
    ...    | pmFiles5g               |                     | X             |
    ...    | condor5gSyslog          |                     |               |
    ...    | SCF5g                   |                     | X             |
    ...    | L2Ps_Component          | (need cells on air) |               |
    ...    | L2Lo_Component          | (need cells on air) |               |
    ...    | L2HiRlc_Component       | (need cells on air) |               |
    ...    | L2HiPdcp_Component      | (need cells on air) |               |
    ...    | L2Ps_Sherpa             | (need cells on air) |               |
    ...    | L2Lo_Sherpa             | (need cells on air) |               |
    ...    | L2HiRlc_Sherpa          | (need cells on air) |               |
    ...    | L2HiPdcp_Sherpa         | (need cells on air) |               |
    ...    | bip_interface_mirroring | (need cells on air) |               |
    ...    | L1stream                |                     |               |
    ...

Library    String

Library    taf.collectors.dcap   WITH NAME   collect_dcap
Library    python/connect.py     WITH NAME   connect_py

Resource   testline.robot
Resource   connect.robot

*** Variables ***
${P_admin_console}              ${False}    # debug output to console

*** Keywords ***


start dcap container 
    [Documentation]
    ...	starts DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${retry_counter}=6
    ${dcap_alias}   connect.Connect to test pc proxy for node   ${node_id}   ${node_type}
    ssh.execute   /usr/local/bin/DCAP_Basic_controller   connection=${dcap_alias} 
    ssh.assert exit status   1   connection=${dcap_alias}
    ...   msg=DCAP startup failed, check DCAP deployment on Test-VM for ${node_type}${node_id}!
    ssh.execute  /usr/local/bin/DCAP_Basic_controller start  connection=${dcap_alias}

    FOR   ${loop_counter}   IN RANGE   ${retry_counter}
       ssh.execute   /usr/local/bin/DCAP_Basic_controller status   connection=${dcap_alias} 
       ${rc}   ssh.get exit status   connection=${dcap_alias} 
       EXIT FOR LOOP IF   ${rc}==${0}

       BuiltIn.Log   dcap not yet working, sleep 10s (loop ${loop_counter})   console=${P_admin_console}
       sleep   10s 
    END

    Run Keyword If   ${rc}!=${0}   FAIL   startup DCAP container failed on Test-VM for ${node_type}${node_id}!
  

stop dcap container
    [Documentation]
    ...	stops DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${dcap_alias}   connect.Connect to test pc proxy for node   ${node_id}   ${node_type}
    ssh.execute   /usr/local/bin/DCAP_Basic_controller   connection=${dcap_alias} 
    ${rc}   ssh.get exit status   connection=${dcap_alias} 
    Run Keyword If   '${rc}'=='${1}'   ssh.execute   /usr/local/bin/DCAP_Basic_controller stop   connection=${dcap_alias}


start dcap container for all nodes
    [Documentation]
    ...	starts DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]   ${node_type}=gnb
    ${node_num}   Get Length   ${tl.${node_type}s}
    FOR   ${node_id}   IN RANGE   ${node_num}
       start dcap container   ${node_id}   ${node_type}
    END


stop dcap container for all nodes
    [Documentation]
    ...	stops DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]    ${node_type}=gnb
    ${node_num}   Get Length    ${tl.${node_type}s}
    FOR    ${node_id}    IN RANGE    ${node_num}
           stop dcap container  ${node_id}  ${node_type}
    END


Start DCAP Tracing
    [Documentation]
    ...     Start DCAP tracing on given Node
    ...
    ...    | node_id        | Id of gNB or eNB                                                          |
    ...    | node_type      | either enb or gnb                                                         |
    ...    | custom_profile | The gNB (5G) custom profile name list of the start trace to be started    |
    ...    | ..             | e.g. one or several of: cp_5g, immediateSnapshot_5g, pmFiles5g,           |
    ...    | ..             | condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component, L2HiRlc_Component, |
    ...    | ..             | L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa,             |
    ...    | ..             | L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream                        |
    ...    | ..             | If the list argument ``custom_profile``is not used cp_5g will be set      |
    ...    | ..             | to activate Emil trace collection!                                        |
    ...
    ...    https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.sw.dcap.rd.interface.rd.start_trace
    ...
    ...    *Example*
    ...    | @{my_profile}        Create List  cp_5g  SCF5g 
    ...    | Start DCAP Tracing   custom_profile=${my_profile}
    ...
    ...    *Returns*    collector alias
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${custom_profile}=@{EMPTY}

    @{custom_profile}   Run Keyword If   not ${custom_profile}   Create List   cp_5g
    ...   ELSE   Create List   @{custom_profile}

    ${node_type}    String.Convert To Lower Case   ${node_type}
    ${nb_test_pc}   connect_py.get_test_pc_for_nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}

    &{bts}  Create Dictionary
    ...   host=${tl.${node_type}s[${node_id}].cu.oam_http_connection_details.addr}
    ...   port=443
    ...   username=${tl.${node_type}s[${node_id}].cu.oam_http_connection_details.username}
    ...   password=${tl.${node_type}s[${node_id}].cu.oam_http_connection_details.password}

    &{trace}   Create Dictionary
    ...   bts=${bts}
    ...   gnb_custom_profile=${custom_profile}

    &{hops}   Create Dictionary
    ...   host=${nb_test_pc.default_ssh_connection_details.addr}
    ...   user=${nb_test_pc.default_ssh_connection_details.username}
    ...   password=${nb_test_pc.default_ssh_connection_details.password}

    ${collectorname}   Set Variable   dcap_${node_type}_${node_id}

    Run Keyword If   "${nb_test_pc.default_ssh_connection_details.addr}"=="${tl.test_pc.default_ssh_connection_details.addr}"
    ...         collect_dcap.Create DCAP Trace Collector
    ...         name=${collectorname}
    ...         trace=${trace}
    ...  ELSE   collect_dcap.Create DCAP Trace Collector
    ...         name=${collectorname}
    ...         trace=${trace}
    ...         hops=${hops}
    
    collect_dcap.Setup Collectors   names=${collectorname}
    collect_dcap.Set Suite Alias    ${collectorname}
    collect_dcap.Start Collectors   names=${collectorname}
    [Return]   ${collectorname}

Stop DCAP Tracing
    [Documentation]
    ...     Stop DCAP tracing on given Node
    ...
    ...    | node_id    | Id of gNB or eNB  |
    ...    | node_type  | either enb or gnb |

    [Arguments]   ${node_id}=${0}   ${node_type}=gnb

    ${node_type}   String.Convert To Lower Case   ${node_type}
    collect_dcap.Stop Collectors   names=dcap_${node_type}_${node_id}
    

Collect DCAP Traces
    [Documentation]
    ...     Collect DCAP traces on given Node
    ...
    ...    | node_id        | Id of gNB or eNB          |
    ...    | node_type      | either enb or gnb         |
    ...    | target_dir     | where traces are stored   |
    ...
    ...    *Returns*    path to collected traces

    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${target_dir}=${None}

    ${node_type}    String.Convert To Lower Case   ${node_type}
    ${target_dir}   Run Keyword If   $target_dir is None   testline.Get Testcase Log Directory
    ...   ELSE      Set Variable    ${target_dir}

    collect_dcap.Collect Collectors   names=dcap_${node_type}_${node_id}   target_dir=${target_dir}
    [Return]   ${target_dir}/dcap_${node_type}_${node_id}

