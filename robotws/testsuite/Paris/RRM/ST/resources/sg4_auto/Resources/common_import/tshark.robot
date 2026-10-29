*** Settings ***

Documentation     Keywords for tshark

Library           String

Library     taf.collectors.tshark       WITH NAME   tshark
Library     taf.transport.ssh           WITH NAME   ssh

Resource    ./testline.robot
Resource    ./connect.robot

*** Keywords ***
Start Tshark
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Tshark on s1 interface of Testpc
    ...
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    ${s1_interface}=        Get S1 Interface on TestPC
    tshark.create_tshark_collector
    ...     name=s1_tshark
    ...     options=-i ${s1_interface}
    ...     executor=${testpc_ssh_config}
    tshark.setup_collectors    names=s1_tshark
    tshark.start_collectors    names=s1_tshark
    tshark.set_suite_alias     s1_tshark


Stop Tshark
    ${target_dir}=      Get testcase log directory
    tshark.stop_collectors         names=s1_tshark
    tshark.collect_collectors      names=s1_tshark  target_dir=${target_dir}
    tshark.teardown_collectors     names=s1_tshark


#### PRIVATE ####

Get S1 Interface on TestPC
    [Documentation]    [PRIVAT]
    ...         :Author: Soenke Kullberg
    ${test_pc_alias}=   connect.Connect to TestPC
    ${enb_ip}       Convert To String   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ${enb_net_class_c}  ${rest}  Split String From Right     ${enb_ip}    separator=.  max_split=1
    ${output}   ssh.execute     command=sudo route | grep '^${enb_net_class_c}' | grep -o '[^ ]*$'     connection=${test_pc_alias}
    #  Unclear  "eth1.3010" or  eth1  is needed
    ${s1_interface}     Fetch From Left   ${output}    marker=.
    [Return]    ${s1_interface}
