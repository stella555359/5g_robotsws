*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-113670 Automation

Resource   Common.robot


*** Keywords ***
Trigger DFE Failure From LMI
    [Arguments]   ${severity}
    ${RANDOM_DFE}   Set Variable If
    ...   "${severity}"=="critical"   ${RANDOM_CRITICAL_DFE}
    ...   "${severity}"=="none_critical"   ${RANDOM_NONE_CRITICAL_DFE}
    ${RANDOM_DFE_IP_LIST}   Set Variable If
    ...   "${severity}"=="critical"   ${RANDOM_CRITICAL_DFE_IP_LIST}
    ...   "${severity}"=="none_critical"   ${RANDOM_NONE_CRITICAL_DFE_IP_LIST}

    Log To Console   Trigger DFE Failure From LMI: ${severity}
    Log To Console   RANDOM_DFE: ${RANDOM_DFE}
    Log To Console   RANDOM_DFE_IP_LIST: ${RANDOM_DFE_IP_LIST}

    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${ru_lmi_connection}   Set Variable   ru_lmi
    ${ru_lmi_ipaddr}       Get Variable Value   ${RANDOM_AEHC["ru_addr"]}
    ${ru_lmi_username}     Get Variable Value   ${RANDOM_AEHC["ru_username"]}
    ${ru_lmi_password}     Get Variable Value   ${RANDOM_AEHC["ru_password"]}
    csn.Connect To   hostname=${ru_lmi_ipaddr}   username=${ru_lmi_username}   password=${ru_lmi_password}
    ...   alias=${ru_lmi_connection}   proxy=${testpc_connection}

    csn.Execute   command=cat /mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}
    csn.Execute   command=cat /mnt/runtime/node_failures.txt   connection=${ru_lmi_connection}
    csn.Execute   command=cat /tmp/disabled_nodes.txt   connection=${ru_lmi_connection}

    csn.Execute   command=sudo nft add table pcitable   connection=${ru_lmi_connection}
    csn.Execute   command=sudo nft add chain pcitable pcichain '{ type filter hook input priority 0 ; }'   connection=${ru_lmi_connection}
    FOR   ${DFE_IP}   IN   @{RANDOM_DFE_IP_LIST}
        csn.Execute   command=sudo nft add rule pcitable pcichain ip saddr ${DFE_IP} drop   connection=${ru_lmi_connection}
    END


    # ${connection_obj}   csn.get_connection_by_alias   alias=${ru_lmi_connection}
    # ${channel}   Call Method   ${connection_obj}   invoke_shell
    # Call Method   ${channel}   send   sudo -i\n
    # Sleep   1s

    # Call Method   ${channel}   send   nft add table pcitable\n
    # Sleep   1s

    # Call Method   ${channel}   send   nft add chain pcitable pcichain '{ type filter hook input priority 0 ; }'\n
    # Sleep   1s

    # FOR   ${DFE_IP}   IN   @{RANDOM_DFE_IP_LIST}
    #     Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr ${DFE_IP} drop\n
    #     Sleep   0.5s
    # END

    # Call Method   ${channel}   close

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_lmi_connection}
    ...   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


Check DFE Failure Reset Counter
    [Arguments]   ${reset_counter}
    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${ru_lmi_connection}   Set Variable   ru_lmi
    ${ru_lmi_ipaddr}       Get Variable Value   ${RANDOM_AEHC["ru_addr"]}
    ${ru_lmi_username}     Get Variable Value   ${RANDOM_AEHC["ru_username"]}
    ${ru_lmi_password}     Get Variable Value   ${RANDOM_AEHC["ru_password"]}
    csn.Connect To   hostname=${ru_lmi_ipaddr}   username=${ru_lmi_username}   password=${ru_lmi_password}
    ...   alias=${ru_lmi_connection}   proxy=${testpc_connection}

    csn.Execute   command=cat /mnt/runtime/node_failures.txt   connection=${ru_lmi_connection}
    csn.Execute   command=cat /tmp/disabled_nodes.txt   connection=${ru_lmi_connection}

    ${reset_counter_file_exist}   csn.File Exists   remote_path=/mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}
    Run Keyword If   "${reset_counter}"!="0" and (not ${reset_counter_file_exist})   Fail   Reset Counter Don't Exist: Number ${reset_counter}
    Return From Keyword If   not ${reset_counter_file_exist}

    ${value}   csn.Execute   command=cat /mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}
    Run Keyword And Ignore Error   Should Be Equal As Numbers   ${reset_counter}   ${value}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_lmi_connection}
    ...   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


Trigger Critical DFE Failure From LMI
    Log To Console   Trigger Critical DFE Failure From LMI
    Log To Console   RANDOM_CRITICAL_DFE: ${RANDOM_CRITICAL_DFE}
    Log To Console   RANDOM_CRITICAL_DFE_IP_LIST: ${RANDOM_CRITICAL_DFE_IP_LIST}

    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${ru_lmi_connection}   Set Variable   ru_lmi
    ${ru_lmi_ipaddr}       Get Variable Value   ${RANDOM_AEHC["ru_addr"]}
    ${ru_lmi_username}     Get Variable Value   ${RANDOM_AEHC["ru_username"]}
    ${ru_lmi_password}     Get Variable Value   ${RANDOM_AEHC["ru_password"]}
    csn.Connect To   hostname=${ru_lmi_ipaddr}   username=${ru_lmi_username}   password=${ru_lmi_password}
    ...   alias=${ru_lmi_connection}   proxy=${testpc_connection}

    # csn.Execute   command=echo -n "6" > /mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}

    ${connection_obj}   csn.get_connection_by_alias   alias=${ru_lmi_connection}
    ${channel}   Call Method   ${connection_obj}   invoke_shell
    Call Method   ${channel}   send   sudo -i\n
    Sleep   1s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   nft add table pcitable\n
    Sleep   1s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   nft add chain pcitable pcichain '{ type filter hook input priority 0 ; }'\n
    Sleep   1s
    # Call Method   ${channel}   recv   ${65535}

    FOR   ${CRITICAL_DFE_IP}   IN   @{RANDOM_CRITICAL_DFE_IP_LIST}
        Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr ${CRITICAL_DFE_IP} drop\n
        Sleep   0.5s
        # Call Method   ${channel}   recv   ${65535}
    END

    # Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr 192.168.100.10 drop\n
    # Sleep   1s
    # # Call Method   ${channel}   recv   ${65535}

    # Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr 192.168.101.10 drop\n
    # Sleep   1s
    # # Call Method   ${channel}   recv   ${65535}

    # Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr 192.168.102.10 drop\n
    # Sleep   1s
    # # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   close

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_lmi_connection}
    ...   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}



Trigger None Critical DFE Failure From LMI
    Log To Console   Trigger None Critical DFE Failure From LMI
    Log To Console   RANDOM_NONE_CRITICAL_DFE: ${RANDOM_NONE_CRITICAL_DFE}
    Log To Console   RANDOM_NONE_CRITICAL_DFE_IP_LIST: ${RANDOM_NONE_CRITICAL_DFE_IP_LIST}

    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${ru_lmi_connection}   Set Variable   ru_lmi
    ${ru_lmi_ipaddr}       Get Variable Value   ${RANDOM_AEHC["ru_addr"]}
    ${ru_lmi_username}     Get Variable Value   ${RANDOM_AEHC["ru_username"]}
    ${ru_lmi_password}     Get Variable Value   ${RANDOM_AEHC["ru_password"]}
    csn.Connect To   hostname=${ru_lmi_ipaddr}   username=${ru_lmi_username}   password=${ru_lmi_password}
    ...   alias=${ru_lmi_connection}   proxy=${testpc_connection}

    # csn.Execute   command=echo -n "3" > /mnt/runtime/preventerResetCounter.txt   connection=${ru_lmi_connection}

    ${connection_obj}   csn.get_connection_by_alias   alias=${ru_lmi_connection}
    ${channel}   Call Method   ${connection_obj}   invoke_shell
    Call Method   ${channel}   send   sudo -i\n
    Sleep   1s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   nft add table pcitable\n
    Sleep   1s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   nft add chain pcitable pcichain '{ type filter hook input priority 0 ; }'\n
    Sleep   1s
    # Call Method   ${channel}   recv   ${65535}


    FOR   ${NONE_CRITICAL_DFE_IP}   IN   @{RANDOM_NONE_CRITICAL_DFE_IP_LIST}
        Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr ${NONE_CRITICAL_DFE_IP} drop\n
        Sleep   0.5s
        # Call Method   ${channel}   recv   ${65535}
    END


    # Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr 192.168.100.9 drop\n
    # Sleep   1s
    # # Call Method   ${channel}   recv   ${65535}

    # Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr 192.168.101.9 drop\n
    # Sleep   1s
    # # Call Method   ${channel}   recv   ${65535}

    # Call Method   ${channel}   send   nft add rule pcitable pcichain ip saddr 192.168.102.9 drop\n
    # Sleep   1s
    # # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   close

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_lmi_connection}
    ...   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}





