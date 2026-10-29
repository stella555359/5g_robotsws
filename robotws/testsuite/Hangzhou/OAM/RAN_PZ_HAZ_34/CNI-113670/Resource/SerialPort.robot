*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-113670 Automation

Resource   Common.robot


*** Keywords ***
Empty Serial Port Output File
    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    csn.Download File   remote_path=/tmp/putty.txt   local_path=${OUTPUT_DIR}/putty_${time}.txt   connection=${testpc_connection}

    Run Keyword And Ignore Error   csn.Execute   command=sudo chmod 777 /tmp/putty.txt   connection=${testpc_connection}
    Run Keyword And Ignore Error   csn.Execute   command=cat /dev/null > /tmp/putty.txt   connection=${testpc_connection}

    [Teardown]   csn.Disconnect   connection=${testpc_connection}


Enable LMI From Serial Port
    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}

    ${connection_obj}   csn.get_connection_by_alias   alias=${testpc_connection}
    ${channel}   Call Method   ${connection_obj}   invoke_shell
    Call Method   ${channel}   send   sudo -i\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   stty -F /dev/ttyUSB0 115200\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "serviceuser" > /dev/ttyUSB0\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g\=" > /dev/ttyUSB0\n
    Sleep   3s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.6s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.7s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.8s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.9s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   1.0s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   1.1s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    Call Method   ${channel}   send   echo "sudo lmi-eth on" > /dev/ttyUSB0\n
    Sleep   0.5s
    # Call Method   ${channel}   recv   ${65535}

    # ${output}   Call Method   ${channel}   recv   ${65535}
    # ${output}   Convert To String   ${output}

    Call Method   ${channel}   close

    [Teardown]   csn.Disconnect   connection=${testpc_connection}


Reset RU From LMI
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

    csn.Execute   command=sudo /sbin/reboot   connection=${ru_lmi_connection}

    # ${connection_obj}   csn.get_connection_by_alias   alias=${connection}
    # ${channel}   Call Method   ${connection_obj}   invoke_shell
    # Call Method   ${channel}   send   sudo -i\n
    # Sleep   1s
    # Call Method   ${channel}   recv   ${65535}
    # Call Method   ${channel}   send   /sbin/reboot\n
    # Sleep   1s
    # Call Method   ${channel}   recv   ${65535}

    # Call Method   ${channel}   close

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_lmi_connection}
    ...   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


Wait Login Content
    ${testpc_connection}   Set Variable   test_pc
    ${testpc_ipaddr}       Get Variable Value   ${RANDOM_AEHC["test_pc_addr"]}
    ${testpc_username}     Get Variable Value   ${RANDOM_AEHC["test_pc_username"]}
    ${testpc_password}     Get Variable Value   ${RANDOM_AEHC["test_pc_password"]}
    csn.Connect To   hostname=${testpc_ipaddr}   username=${testpc_username}   password=${testpc_password}   alias=${testpc_connection}
    Wait Until Keyword Succeeds   20m   1s   Check Login Content   testpc_connection=${testpc_connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


Check Login Content
    [Arguments]   ${testpc_connection}
    ${output}   csn.Execute   command=cat /tmp/putty.txt | grep -a "stratix10-aehb login:"   connection=${testpc_connection}
    Should Not Be Empty   ${output}




# Reset RU From Testline
#     ${testline_ipaddr}   Set Variable   10.57.225.67
#     ${testline_username}   Set Variable   toor4nsn
#     ${testline_password}   Set Variable   oZPS0POrRieRtu
#     ${testline_connection}   Set Variable   testline
#     csn.Connect to   hostname=${testline_ipaddr}   username=${testline_username}   password=${testline_password}   alias=${testline_alias}

#     # Get Container ID
#     ${output}   csn.Execute   command=hostname   connection=${testline_alias}
#     ${primary_host}   Strip String   ${output}
#     ${container_id}   Set Variable If
#     ...   '${primary_host}'=='fct-0a'   0x1018
#     ...   "${primary_host}"=="asc-0a"   0x1018
#     ...   '${primary_host}'=='fct-4a'   0x2018
#     ...   0x1018

#     # Get Detected RU List
#     ${all_ru_list}   csn.Execute   command=cat /ffs/run/config/FRIps.txt   connection=${testline_alias}
#     ${ru_ip}   Set Variable
#     FOR   ${ru_detail}   IN   @{all_ru_list.splitlines()}
#         ${check_ru_info}   Run Keyword And Return Status   Should Contain   ${ru_detail}   ;
#         Continue For Loop If   '${check_ru_info}' == '${False}'

#         ${ru_detail_sn}   Set Variable   ${ru_detail.split(";")[3]}
#         ${ru_detail_ip}   Set Variable   ${ru_detail.split(";")[2]}
#         ${ru_detail_type}   Set Variable   ${ru_detail.split(";")[4]}
#         Continue For Loop If   "${ru_type}"!="AEHC"

#         ${ru_ip}   Set Variable If   "${ru_detail_ip}"!="0.0.0.0"   ${ru_detail_ip}
#         Exit For Loop If   "${ru_detail_ip}"!="0.0.0.0"
#     END

#     # Setup Container SSH Service
#     ${connection_obj}   csn.get_connection_by_alias   alias=${testline_alias}
#     ${channel}   Call Method   ${connection_obj}   invoke_shell
#     Call Method   ${channel}   send   lxc-attach -n ${container_id}\n
    # Sleep   1s
    # Call Method   ${channel}   recv   ${65535}
    # Call Method   ${channel}   send   ps -ef|grep sshd\n
    # Sleep   3s
    # ${output}   Call Method   ${channel}   recv   ${65535}
    # ${output}   Convert To String   ${output}
    # ${status}   Run Keyword And Return Status   Should Not Contain   ${output}   PermitRootLogin yes
    # ${sshd_command}   Set Variable   /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    # Run Keyword If   ${status}   Run Keywords
    # ...   Call Method   ${channel}   send   ${sshd_command}\n
    # ...   AND
    # ...   Sleep   3s
    # ...   AND
    # ...   Call Method   ${channel}   recv   ${65535}
    # Call Method   ${channel}   close

#     # Connect To Container
#     ${fhnet_ipaddr}   Set Variable   192.168.255.254
#     ${fhnet_username}   Set Variable   toor4nsn
#     ${fhnet_password}   Set Variable   oZPS0POrRieRtu
#     ${container_alias}   Set Variable   container
#     csn.Connect to
#     ...   hostname=${fhnet_ipaddr}
#     ...   username=${fhnet_username}
#     ...   password=${fhnet_password}
#     ...   alias=${container_alias}
#     ...   proxy=${testline_alias}

#     # Connect To RU
#     ${ru_ip}   Set Variable   ${ru_ip}
#     ${ru_username}   Set Variable   serviceuser
#     ${ru_password}   Set Variable   7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=
#     ${ru_alias}   Set Variable   RU
#     Run Keyword And Ignore Error   csn.Execute
#     ...   command=ssh-keygen -f "/user/toor4nsn/.ssh/known_hosts" -R ${ru_ip}
#     ...   connection=${testline_alias}
#     ...   timeout=60
#     csn.Connect to
#     ...   hostname=${ru_ip}
#     ...   username=${ru_username}
#     ...   password=${ru_password}
#     ...   alias=${ru_alias}
#     ...   proxy=${container_alias}

#     csn.Execute   command=sudo /sbin/reboot   connection=${ru_alias}

#     [Teardown]   Run Keywords
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_alias}
#     ...   AND
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${container_alias}
#     ...   AND
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline_alias}


