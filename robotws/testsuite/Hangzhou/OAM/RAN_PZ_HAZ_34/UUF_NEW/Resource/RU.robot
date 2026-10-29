*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Get Detected RU Info From Testline
    [Arguments]   ${connection}

    ${testline}   Run Keyword If   "${connection.find("_dual")}"=="-1"   Set Variable   ${connection}
    ...   ELSE   Set Variable   ${connection[:${connection.find('_dual')}]}

    ${primary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_host']}
    ${secondary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_host']}
    ${primary_container_id}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_container_id']}
    ${secondary_container_id}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_container_id']}

    # Get Container ID
    ${container_id}   Set Variable If
    ...   "${connection.find("_dual")}"=="-1"   ${primary_container_id}
    ...   "${connection.find("_dual")}"!="-1"   ${secondary_container_id}

    # Get Hostname
    ${hostname}   Set Variable If
    ...   "${connection.find("_dual")}"=="-1"   ${primary_host}
    ...   "${connection.find("_dual")}"!="-1"   ${secondary_host}


    ${connected_RU}   Create Dictionary
    # Get Container ID
    # ${hostname}   csn.Execute   command=hostname   connection=${connection}
    # ${hostname}   Strip String   ${hostname}
    # ${container_id}   Set Variable If
    # ...    "${hostname}"=="fct-0a"   0x1018
    # ...    "${hostname}"=="asc-0a"   0x1018
    # ...    "${hostname}"=="fct-4a"   0x2018
    # ...    NONE

    # Get SW Release
    ${sw_file_name}   csn.Execute   command=ls /ffs/run | grep TargetBD.*.xml | grep -v .xml.   connection=${connection}
    @{sw_version_list}   Get Regexp Matches   ${sw_file_name}   TargetBD_(.*?)_   1
    Run Keyword And Ignore Error   Remove values From List   ${sw_version_list}   BSR
    ${sw_release}    Strip String   ${sw_version_list[0]}

    # Get Detected RU List
    ${detected_RUs}   csn.Execute   command=cat /ffs/run/config/FRIps.txt   connection=${connection}
    FOR   ${ru}   IN   @{detected_RUs.splitlines()}
        ${check_ru_info}    Run Keyword And Return Status    should contain    ${ru}    ;
        Continue For Loop If   '${check_ru_info}' == '${False}'

        ${ru_sn}   Set Variable   ${ru.split(";")[3]}
        ${ru_ip}   Set Variable   ${ru.split(";")[2]}
        ${ru_type}   Set Variable   ${ru.split(";")[4]}

        ${ru_passwd}   UUF_Utils.get_ru_username_password   ru_type=${ru_type}   build_release=${sw_release}
        ...   if_need_handle_dollar=${False}
        ${ru_username}   ${ru_password}   Run Keyword If   ${ru_passwd}   Set Variable   ${ru_passwd[0]['username']}   ${ru_passwd[0]['password']}
        ...   ELSE   Set Variable   root   ${EMPTY}

        ${ru_info}   Create Dictionary
        ...   ru_ip=${ru_ip}
        ...   ru_type=${ru_type}
        ...   testline_alias=${connection}
        ...   hostname=${hostname}
        ...   container_id=${container_id}
        ...   ru_username=${ru_username}
        ...   ru_password=${ru_password}
        Run Keyword If   not "${ru_ip}"=="0.0.0.0"   Set to Dictionary   ${connected_RU}   ${ru_sn}=${ru_info}
    END
    [Return]   ${connected_RU}


Connect To FHNET Container
    [Timeout]    5m
    [Arguments]   ${testline_alias}   ${container_id}=0x1018
    ...   ${fhnet_ipaddr}=192.168.255.254   ${fhnet_username}=toor4nsn   ${fhnet_password}=oZPS0POrRieRtu

    ${container_alias}   Set Variable   ${testline_alias}_${container_id}

    ${connection}    csn.get_connection_by_alias    alias=${testline_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close

    csn.Connect to
    ...   hostname=${fhnet_ipaddr}
    ...   username=${fhnet_username}
    ...   password=${fhnet_password}
    ...   alias=${container_alias}
    ...   proxy=${testline_alias}
    [Return]   ${container_alias}


Connect To RU Via Testline FHNET Container
    [Timeout]    5m
    [Arguments]   ${ru_info}   ${container_alias}

    ${ru_sn}   Set Variable   ${ru_info[0]}
    ${ru_ip}   Set Variable   ${ru_info[1]['ru_ip']}
    ${ru_type}   Set Variable   ${ru_info[1]['ru_type']}
    ${ru_username}   Set Variable   ${ru_info[1]['ru_username']}
    ${ru_password}   Set Variable   ${ru_info[1]['ru_password']}


    ${testline_alias}   Set Variable   ${ru_info[1]['testline_alias']}
    # ${container_id}   Set Variable   ${ru_info[1]['container_id']}

    # ${container_alias}   Set Variable   ${testline_alias}_${container_id}
    # ${container_alias}   Connect To FHNET Container   testline_alias=${testline_alias}   container_id=${container_id}

    ${ru_alias}   Set Variable   RU_${ru_sn}

    Run Keyword And Ignore Error   csn.Execute
    ...   command=ssh-keygen -f "/user/toor4nsn/.ssh/known_hosts" -R ${ru_ip}
    ...   connection=${testline_alias}
    ...   timeout=60

    csn.Connect to
    ...   hostname=${ru_ip}
    ...   username=${ru_username}
    ...   password=${ru_password}
    ...   alias=${ru_alias}
    ...   proxy=${container_alias}
    [Return]   ${ru_alias}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

Check if remote file size not increased
    [Arguments]   ${file_path}   ${connection}   ${timeout}=120s
    Wait Until Keyword Succeeds   ${timeout}   5s   csn.File Exists
    ...   remote_path=${file_path}   connection=${connection}   timeout=${30}
    ${prev_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Sleep   1s
    ${final_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Should Be Equal   ${prev_size}    ${final_size}

Get File Size
    [Arguments]   ${file_path}   ${connection}
    ${file_info}   csn.Execute   command=ls -la ${file_path}   connection=${connection}
    [Return]   ${file_info.split()[4]}

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
UUF Get RU PC Info Accordind To Serial
    [Arguments]    ${ru_serial_list}
    @{RU_serial_pc_info}   Create List

    FOR   ${ru_serial}   IN   @{ru_serial_list}
        ${isRuSerialString}   Evaluate   "${ru_serial.__class__.__name__}"=="str"
        ${new_ru_serial}   Set Variable If   ${isRuSerialString}   ${ru_serial}   ${ru_serial[0]}

        @{Single_RU_serial_pc}    UUF Get Single RU PC Info Accordind To Serial    ru_serial=${new_ru_serial}
        Run Keyword And Ignore Error    Append To List    ${RU_serial_pc_info}    @{Single_RU_serial_pc}
    END
    [Return]    ${RU_serial_pc_info}


UUF Get Single RU PC Info Accordind To Serial
    [Arguments]    ${ru_serial}
    @{Single_RU_serial_pc}   Create List
    FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
        Run Keyword If    '${ru_serial}'=='${ru_detail['ru_serial']}'    Run Keywords    Append To List   ${Single_RU_serial_pc}    ${ru_detail}
        ...    AND    exit for loop
    END
    [Return]    ${Single_RU_serial_pc}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# Login To RU Frome testline And Execute Command
Login to RU via System Module and execute command
    [Timeout]   20m
    [Arguments]  ${testline}   ${command_list}   ${cmd_with_sudo}=${False}   ${timeout}=${60}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}

    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}
    ${primary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_host']}
    ${secondary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_host']}
    ${primary_container_id}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_container_id']}
    ${secondary_container_id}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_container_id']}


    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    Run Keyword If   ${isDualCore}
    ...   csn.Connect to  hostname=${secondary_host}  username=${ssh_username}  password=${ssh_password}  proxy=${testline}  alias=${testline}_dual

    &{primary_detected_ru}   Get Detected RU Info From Testline   connection=${testline}
    &{secondary_detected_ru}   Run Keyword If   ${isDualCore}   Get Detected RU Info From Testline   connection=${testline}_dual
    ...   ELSE   Create Dictionary
    &{testline_detected_ru}   Create Dictionary   &{primary_detected_ru}   &{secondary_detected_ru}

    ${primary_container_alias}   Connect To FHNET Container   testline_alias=${testline}   container_id=${primary_container_id}
    ${secondary_container_alias}   Run Keyword If   ${isDualCore}
    ...   Connect To FHNET Container   testline_alias=${testline}_dual   container_id=${secondary_container_id}

    FOR   ${ru_info}   IN   @{testline_detected_ru.items()}
        ${testline_alias}   Set Variable   ${ru_info[1]["testline_alias"]}
        ${container_id}   Set Variable   ${ru_info[1]["container_id"]}

        ${container_alias}   Set Variable   ${testline_alias}_${container_id}
        Run Keyword And Ignore Error   Single RU Execute Command
        ...   ru_info=${ru_info}
        ...   command_list=${command_list}
        ...   cmd_with_sudo=${cmd_with_sudo}
        ...   container_alias=${container_alias}
        ...   timeout=${timeout}
    END
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${secondary_container_alias}      AND
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${testline}_dual                  AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${primary_container_alias}                                         AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}

Single RU Execute Command
    [Timeout]   5m
    [Arguments]   ${ru_info}   ${command_list}   ${cmd_with_sudo}   ${timeout}   ${container_alias}

    # continue for loop if   ${ru_info[1]['type']} in ${Default_LMI_ON_RU}
    # ${If_Default_LMI_ON}   Run Keyword and Return Status   list should contain value   ${Default_LMI_ON_RU}   ${ru_info[1]['type']}
    # continue for loop if   ${If_Default_LMI_ON}
    ${ru_sn}   Set Variable   ${ru_info[0]}
    ${ru_username}   Set Variable   ${ru_info[1]['ru_username']}
    ${ru_type}   Set Variable   ${ru_info[1]['ru_type']}


    ${status}   ${ru_alias}   Run Keyword And Ignore Error
    ...   Connect To RU Via Testline FHNET Container   ru_info=${ru_info}   container_alias=${container_alias}
    Run Keyword If   "${status}"=="FAIL"   Log To Console   [ERROR] Connect To RU(${ru_type}, ${ru_sn}) Failed.
    Return From Keyword If   "${status}"=="FAIL"

    FOR   ${command}   IN   @{command_list}
        ${no_sudo}   Run Keyword And Return Status   Should Not Contain   ${command}   sudo
        ${exec_cmd}   Set Variable If
        ...   '${ru_username}'!='root' and ${cmd_with_sudo} and ${no_sudo}   sudo ${command}
        ...   '${ru_username}'=='root'   ${command.replace("sudo ", "")}
        ...   ${command}
        Log To Console   Execute Command On RU(${ru_type}, ${ru_sn}): ${exec_cmd}
        csn.Send Command   command=${exec_cmd}   connection=${ru_alias}   timeout=${timeout}
        Sleep   1s
    END

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_alias}



#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# Enable lmi-eth on
UUF Enable RU LMI Connection Through Testline
    [Timeout]   20m
    Log To Console   RU_LOG_FLAG: ${RU_LOG_FLAG}
    Log To Console   RU_SYSLOG_FLAG: ${RU_SYSLOG_FLAG}
    Return From Keyword If   (not ${RU_LOG_FLAG}) and (not ${RU_SYSLOG_FLAG})
    # FOR   ${testline}   IN   @{ALL_GNB_LIST}    @{CONCURRENT_ENB_LIST}
    #     Login to RU via System Module and execute command   ${testline}   command=lmi-eth on   cmd_with_sudo=${True}
    # END
    Log To Console   Enable RU lmi-eth on
    @{command_list}   Create List
    ...   lmi-eth on
    ...   touch /ram/disable_swman_cleanup

    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{CONCURRENT_ENB_LIST}
        Run Keyword And Ignore Error
        ...   Login to RU via System Module and execute command   testline=${testline}   command_list=${command_list}   cmd_with_sudo=${True}
    END



# UUF Enable RU LMI Connection Through PC
#     [Arguments]  ${testline}
#     Log To Console   ${RU_LOG_FLAG}
#     ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
#     ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
#     ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
#     ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
#     ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
#     ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

#     COAM Login    bts_host=${webem_addr}    username=${webem_username}    password=${webem_password}    alias=${testline}
#     ${software_dict}    UUF Get Software Version    ${testline}
#     ${active_release}   Set Variable   ${software_dict['active_release']}
# #    log to console      ${testline} active_release is ${software_dict['active_release']}

#     ${ALL_RU_LIST}    Remove Duplicates    ${ALL_RU_LIST}
#     FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
#         ${hostname}   Set Variable   ${ru_detail['test_pc_addr']}
#         ${username}   Set Variable   ${ru_detail['test_pc_username']}
#         ${password}   Set Variable   ${ru_detail['test_pc_password']}
#         ${ru_type}   Set Variable   ${ru_detail['ru_type']}
#         ${ru_addr}   Set Variable   ${ru_detail['ru_addr']}

#         ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 ${hostname}
#         #if hostname is unreachable, ret will be 1, if pc is reachable, ret will be 0
#         ${pc_reachable}    Set Variable If    "${ret}"=="0"    ${True}    ${False}
#         run keyword if    '${pc_reachable}'=='False'
#         ...    log to console    ${hostname} cannot reachable，will skip Enable RU LMI Connection Through PC!
#         continue for loop if   '${pc_reachable}' == '${False}'

#         ${If_Default_LMI_ON}   Run Keyword and Return Status   list should contain value   ${Default_LMI_ON_RU}   ${ru_type}
#         continue for loop if   ${If_Default_LMI_ON}

#         ${ru_info}    UUF_Utils.get_ru_username_password    ${ru_type}    ${active_release}    if_need_handle_dollar=${False}
#         Run Keyword And Ignore Error    UUF_Utils.enable_ssh_to_ru    ${hostname}    ${username}    ${password}    ${ru_addr}    ${ru_info}
#     END

#     [Teardown]    Run Keyword And Ignore Error   COAM Logout   connection=${testline}


#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# Enable RU swconfig
Check ALL RU swconfig From LMI
    [Timeout]   20m
    Return From Keyword If   (not ${RU_LOG_FLAG}) and (not ${RU_SYSLOG_FLAG})

    FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
        Run Keyword And Ignore Error   Check Single RU swconfig From LMI   ru_detail=${ru_detail}
    END


Check Single RU swconfig From LMI
    [Timeout]   5m
    [Arguments]   ${ru_detail}
    ${test_pc_addr}   Set Variable   ${ru_detail['test_pc_addr']}
    # ${test_pc_username}   Set Variable   ${ru_detail['test_pc_username']}
    # ${test_pc_password}   Set Variable   ${ru_detail['test_pc_password']}
    ${ru_type}   Set Variable   ${ru_detail['ru_type']}
    ${ru_addr}   Set Variable   ${ru_detail['ru_addr']}
    ${ru_serial}   Set Variable   ${ru_detail['ru_serial']}

    ${return_dict}      Connect To RU From TestPC   ru_detail=${ru_detail}

    ${test_pc_alias}   Get Variable Value   ${return_dict["test_pc_alias"]}
    ${ru_alias}   Get Variable Value   ${return_dict["ru_alias"]}
    ${ru_username}   Get Variable Value   ${return_dict["ru_username"]}
    ${ru_password}   Get Variable Value   ${return_dict["ru_password"]}

    Run Keyword If   "${test_pc_alias}"=="FAIL" or "${ru_alias}"=="FAIL" or "${test_pc_alias}"=="" or "${ru_alias}"==""
    ...   Log To Console   [ERROR] Connect To RU(${ru_serial}, ${ru_addr}) From TestPC(${test_pc_addr}) Failed.
    Return From Keyword If   "${test_pc_alias}"=="FAIL" or "${ru_alias}"=="FAIL" or "${test_pc_alias}"=="" or "${ru_alias}"==""

    # Get Test PC 192.168 Ip Addr
    ${ru_ip_segment}   Should Match Regexp   ${ru_addr}   \\d+.\\d+.\\d+
    ${output}   csn.Execute   command=sudo cat /etc/network/interfaces | grep ${ru_ip_segment}   connection=${test_pc_alias}
    ${test_pc_192_ip}    Should Match Regexp   ${output}   (\\d+).(\\d+).(\\d+).(\\d+)
    ${segment1}   Convert To Hex   ${test_pc_192_ip[1]}   length=2
    ${segment2}   Convert To Hex   ${test_pc_192_ip[2]}   length=2
    ${segment3}   Convert To Hex   ${test_pc_192_ip[3]}   length=2
    ${segment4}   Convert To Hex   ${test_pc_192_ip[4]}   length=2
    ${test_pc_192_ip_hex}   Set Variable   0x${segment1}${segment2}${segment3}${segment4}

    ${ru_swconfig_command}   Set Variable   ccsShell.sh rad -mpw 0x10042 ${test_pc_192_ip_hex}


    # ${ru_swconfig_command}   Get Variable Value   ${RU_GW_IP["${test_pc_192_ip}"]}
    # Run Keyword If   "${ru_swconfig_command}"==""
    # ...   Log To Console   [ERROR] TestPC IP Don't Supported: ${test_pc_192_ip}
    # Return From Keyword If   "${ru_swconfig_command}"==""

    ${sudo}   Set Variable If   "${ru_username}"!="root"   sudo${SPACE}   ${EMPTY}
    Run Keyword If   "${TEST_MODE}"=="UUF"   Run Keywords
    ...   csn.Send Command   command=${sudo} rm -rf /rom/swconfig.txt   connection=${ru_alias}
    ...   AND
    ...   csn.Send Command   command=${sudo} rm -rf /rom/swconfig_local.txt   connection=${ru_alias}
    ...   AND
    ...   Sleep   1s

    # Return From Keyword If   "${ru_type}"=="AHLOA" or "${ru_type}"=="AHFIB"

    csn.Send Command   command=${ru_swconfig_command}   connection=${ru_alias}
    Sleep   1s
    Log To Console   Command: ${ru_swconfig_command}

    csn.Send Command   command=ccsShell.sh rad -mpw 0x10043 0xC739   connection=${ru_alias}
    Sleep   1s
    Log To Console   Command: ccsShell.sh rad -mpw 0x10043 0xC739

    csn.Send Command   command=ccsShell.sh rad -mpw 0x10041 2   connection=${ru_alias}
    Sleep   1s
    Log To Console   Command: ccsShell.sh rad -mpw 0x10041 2


    # csn.Execute   command=${ru_swconfig_command}   connection=${ru_alias}
    # Log To Console   Command: ${ru_swconfig_command}

    # csn.Execute   command=ccsShell.sh rad -pw 0x10043 0xC739   connection=${ru_alias}
    # Log To Console   Command: ccsShell.sh rad -pw 0x10043 0xC739

    # csn.Execute   command=ccsShell.sh rad -pw 0x10041 2   connection=${ru_alias}
    # Log To Console   Command: ccsShell.sh rad -pw 0x10041 2


    # ${output}   csn.Execute   command=cat /rom/swconfig.txt   connection=${ru_alias}
    # ${output}   Strip String   ${output}
    # Log To Console   ${ru_type}(${ru_serial}) RU swconfig.txt: ${output}
    # ${output}   csn.Execute   command=cat /rom/swconfig_local.txt   connection=${ru_alias}
    # ${output}   Strip String   ${output}
    # Log To Console   ${ru_type}(${ru_serial}) RU swconfig_local.txt: ${output}

    ${sudo}   Set Variable If   "${ru_username}"!="root"   sudo${SPACE}   ${EMPTY}
    csn.Send Command   command=${sudo}touch /ram/disable_swman_cleanup   connection=${ru_alias}
    Sleep   1s

    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_alias}   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_alias}


Connect To RU From TestPC
    [Timeout]   5m
    [Arguments]   ${ru_detail}

    &{return_dict}   Create Dictionary
    ...   test_pc_alias=FAIL
    ...   ru_alias=FAIL
    ...   ru_username=FAIL
    ...   ru_password=FAIL


    ${test_pc_addr}   Set Variable   ${ru_detail['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${ru_detail['test_pc_username']}
    ${test_pc_password}   Set Variable   ${ru_detail['test_pc_password']}
    ${ru_type}   Set Variable   ${ru_detail['ru_type']}
    ${ru_addr}   Set Variable   ${ru_detail['ru_addr']}
    ${ru_serial}   Set Variable   ${ru_detail['ru_serial']}

    Log To Console   Connect To RU From TestPC:
    Log To Console   test_pc_addr: ${test_pc_addr}
    Log To Console   ru_type: ${ru_type}
    Log To Console   ru_addr: ${ru_addr}
    Log To Console   ru_serial: ${ru_serial}


    ${isTestPCNotExist}   Evaluate
    ...   "${test_pc_addr}"=="" or "${test_pc_addr}"=="1.1.1.1" or "${test_pc_addr}"=="10.10.10.10" or "${test_pc_addr}"=="None"
    Run Keyword If   ${isTestPCNotExist}   Log To Console   RU(${ru_type}, ${ru_serial}) PC IP(${test_pc_addr}) Don't Exist, Skip Connecting.
    Return From Keyword If   ${isTestPCNotExist}   ${return_dict}


    ${gnb_source_release}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['gnb']['source']['release']}
    ${gnb_target_release}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['gnb']['target']['release']}
    ${enb_source_release}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['source']['release']}
    ${enb_target_release}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['target']['release']}


    @{release_list}   Create List   ${gnb_source_release}   ${gnb_target_release}   ${enb_source_release}   ${enb_target_release}
    ${release_list}   Remove Duplicates   ${release_list}
    Remove Values From List   ${release_list}   ${EMPTY}   ${None}   None   NONE

    @{all_user_passwd_list}   Create List
    FOR   ${release}   IN   @{release_list}
        ${user_passwd_list}    UUF_Utils.get_ru_username_password   ru_type=${ru_type}   build_release=${release}   if_need_handle_dollar=${False}
        Append To List   ${all_user_passwd_list}   @{user_passwd_list}
    END
    ${all_user_passwd_list}   Remove Duplicates   ${all_user_passwd_list}
    Remove Values From List   ${all_user_passwd_list}   ${EMPTY}

    Log To Console   Connect To Test PC: ${test_pc_addr}
    ${test_pc_alias}   Set Variable   ${test_pc_addr}
    ${test_pc_connected}   Run Keyword And Return Status
    ...   csn.Connect to   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_alias}
    ...   timeout=${10}
    Return From Keyword If   not ${test_pc_connected}   ${return_dict}
    Log To Console   Connect To Test PC Finished.

    Log To Console   Connect To RU: ${ru_serial}
    FOR   ${user_passwd}   IN   @{all_user_passwd_list}
        ${ru_username}   Set Variable   ${user_passwd["username"]}
        ${ru_password}   Set Variable   ${user_passwd["password"]}

        ${ru_alias}   Set Variable   ${ru_serial}
        ${status}   Run Keyword And Return Status
        ...   csn.Connect to   hostname=${ru_addr}   username=${ru_username}   password=${ru_password}   alias=${ru_alias}   proxy=${test_pc_alias}
        ...   timeout=${10}
        Run Keyword If   ${status}   Log To Console   Connect To RU Finished.
        Run Keyword If   ${status}   Set To Dictionary   ${return_dict}
        ...   test_pc_alias=${test_pc_alias}
        ...   ru_alias=${ru_alias}
        ...   ru_username=${ru_username}
        ...   ru_password=${ru_password}
        Return From Keyword If   ${status}   ${return_dict}
    END
    Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_alias}
    [Return]   ${return_dict}
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_alias}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Catch Detected RU Logs via System Module
    [Arguments]   ${testline}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${ru_list}=ALL

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}

    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}

    ${primary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_host']}
    ${secondary_host}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_host']}
    ${primary_container_id}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['primary_container_id']}
    ${secondary_container_id}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['secondary_container_id']}


    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    Run Keyword If   ${isDualCore}
    ...   csn.Connect to  hostname=${secondary_host}  username=${ssh_username}  password=${ssh_password}  proxy=${testline}  alias=${testline}_dual

    &{primary_detected_ru}   Get Detected RU Info From Testline   connection=${testline}
    &{secondary_detected_ru}   Run Keyword If   ${isDualCore}   Get Detected RU Info From Testline   connection=${testline}_dual
    ...   ELSE   Create Dictionary
    &{testline_detected_ru}   Create Dictionary   &{primary_detected_ru}   &{secondary_detected_ru}
    ${testline_not_detected_ru}   Evaluate   [c for c in ${ALL_CONFIG_SCF['${testline}']['rmod_serial_list']} if c not in ${testline_detected_ru}]

    ${new_testline_detected_ru}   Create Dictionary
    FOR   ${ru_sn}   IN   @{testline_detected_ru}
        Exit For Loop If   $ru_list=="ALL"
        Run Keyword If   "${ru_sn}" in ${ru_list}   Set To Dictionary   ${new_testline_detected_ru}   ${ru_sn}=${testline_detected_ru["${ru_sn}"]}
    END

    ${testline_detected_ru}   Set Variable If   $ru_list=="ALL"   ${testline_detected_ru}   ${new_testline_detected_ru}
    ${testline_not_detected_ru}   Run Keyword If   $ru_list=="ALL"   Set Variable   ${testline_not_detected_ru}
    ...   ELSE   Evaluate   [c for c in ${ru_list} if c in ${testline_not_detected_ru}]

    Log To Console   ${testline} testline_detected_ru: ${testline_detected_ru}
    Log To Console   ${testline} testline_not_detected_ru: ${testline_not_detected_ru}

    # //TODO:
    # @{testline_not_detected_ru}=['1M204306415', '1M204306414']
    # @{RU_Log_through_LMI} = [
    #     '1M204306415',
    #     '1M204306414',
    #       ('AS201818029',
    #        {'container_id': '0x1018',
    #         'hostname': 'fct-0a',
    #         'ru_ip': '172.16.73.128',
    #         'ru_password': 'root',
    #         'ru_type': 'AHCA',
    #         'ru_username': 'root',
    #         'testline_alias': 'gnb_0'}),
    # ]

    ${smod_ru_log_list}    Create List
    ${RU_Log_through_LMI}    Create List   @{testline_not_detected_ru}

    ${primary_status}   ${primary_container_alias}   Run Keyword And Ignore Error
    ...   Connect To FHNET Container   testline_alias=${testline}   container_id=${primary_container_id}
    ${secondary_status}   ${secondary_container_alias}   Run Keyword And Ignore Error
    ...   Run Keyword If   ${isDualCore}
    ...   Connect To FHNET Container   testline_alias=${testline}_dual   container_id=${secondary_container_id}
    ${fhnet_not_connect}   Evaluate   "${primary_status}"=="FAIL" or "${secondary_status}"=="FAIL"
    Run Keyword If   ${fhnet_not_connect}   Append To List   ${RU_Log_through_LMI}   @{testline_detected_ru.items()}
    Return From Keyword If   ${fhnet_not_connect}   ${RU_Log_through_LMI}    ${smod_ru_log_list}

    FOR   ${ru_info}   IN   @{testline_detected_ru.items()}
        ${testline_alias}   Set Variable   ${ru_info[1]["testline_alias"]}
        ${container_id}   Set Variable   ${ru_info[1]["container_id"]}

        ${container_alias}   Set Variable   ${testline_alias}_${container_id}

        ${status}   ${return}   Run Keyword And Ignore Error   Collect RU Log via Testline
        ...   testline=${testline}
        ...   ru_info=${ru_info}
        ...   container_alias=${container_alias}
        ...   log_dir=${log_dir}
        ...   prefix=${prefix}
        Run Keyword If   "${status}"=="FAIL"   Append To List   ${RU_Log_through_LMI}    ${ru_info}
        Continue For Loop If   "${status}"=="FAIL"

        ${RU_log_exists}   Set Variable   ${return[0]}
        ${ru_log_path}   Set Variable   ${return[1]}

        Run Keyword If    ${RU_log_exists}    Append To List    ${smod_ru_log_list}    ${ru_log_path}
        Run Keyword If   not ${RU_log_exists}   Append To List    ${RU_Log_through_LMI}    ${ru_info}
    END
    [Return]   ${RU_Log_through_LMI}    ${smod_ru_log_list}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${secondary_container_alias}      AND
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${testline}_dual                  AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${primary_container_alias}                                         AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}


Collect RU Log via Testline
    [Timeout]   15m
    [Arguments]   ${testline}   ${ru_info}   ${container_alias}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL
    ${ru_sn}   Set Variable   ${ru_info[0]}
    ${ru_username}   Set Variable   ${ru_info[1]['ru_username']}
    ${ru_type}   Set Variable   ${ru_info[1]['ru_type']}

    ${vm_ru_log_path}   Set Variable   ${log_dir}/RULOG_${prefix}_${testline}_${ru_type}_${ru_sn}.zip

    ${status}   ${ru_alias}   Run Keyword And Ignore Error
    ...   Connect To RU Via Testline FHNET Container   ru_info=${ru_info}   container_alias=${container_alias}
    Run Keyword If   "${status}"=="FAIL"   Log To Console   [ERROR] Connect To RU(${ru_type}, ${ru_sn}) Failed.
    Return From Keyword If   "${status}"=="FAIL"   ${False}   NONE

    ${sudo_cmd}   Set Variable If   '${ru_username}'=='root'   ${EMPTY}   sudo${SPACE}
    ${ru_log_path}    Set Variable    /ram/ru_log_${ru_sn}.zip
    Log To Console   start to catch this radio log: ${ru_info}
    csn.Execute     cd /usr/bin;${sudo_cmd}ccsShell.sh log -a -c full -z ${ru_log_path}    connection=${ru_alias}   timeout=${600}

    Wait Until Keyword Succeeds   1m   5s   Check if remote file size not increased   file_path=${ru_log_path}   connection=${ru_alias}
    ${RU_log_exists}   Run Keyword and Return Status   csn.Download File
    ...   remote_path=${ru_log_path}   local_path=${vm_ru_log_path}   connection=${ru_alias}
    ${output}=    Run    ls -la ${vm_ru_log_path}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    No such file
    ${RU_log_exists}    set variable if    '${status}'=='False' or '${output.split()[4]}' == '0'    ${False}   ${True}

    Log To Console   catch ${ru_sn} radio log done.
    [Return]   ${RU_log_exists}    ${vm_ru_log_path}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_alias}



# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================

UUF Catch RU Log From LMI
    [Arguments]  ${testline}    ${ru_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL
    Log To Console   ${RU_LOG_FLAG}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}
    ${lmi_ru_log_list}    create list

    ${active_release}   UUF Get SW Release From SSH   testline=${testline}

    FOR   ${ru_detail}   IN   @{ru_list}
        ${ru_log_path}   UUF Single RU Catch RU Log From LMI   ru_detail=${ru_detail}   active_release=${active_release}
        ...   log_dir=${log_dir}   prefix=${prefix}
        Run Keyword If   "${ru_log_path}"!="" and "${ru_log_path}"!="None"
        ...   Append To List   ${lmi_ru_log_list}    ${ru_log_path}
    END
    [Return]      ${lmi_ru_log_list}


UUF Single RU Catch RU Log From LMI
    [Arguments]   ${ru_detail}   ${active_release}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL
    ${hostname}   Set Variable   ${ru_detail['test_pc_addr']}
    ${username}   Set Variable   ${ru_detail['test_pc_username']}
    ${password}   Set Variable   ${ru_detail['test_pc_password']}
    ${ru_type}   Set Variable   ${ru_detail['ru_type']}
    ${ru_addr}   Set Variable   ${ru_detail['ru_addr']}
    ${ru_serial}   Set Variable   ${ru_detail['ru_serial']}
    ${ru_log_path}   Set Variable   ${log_dir}/RULOG_${prefix}_${hostname}_${ru_type}_${ru_serial}.tar

    ${ret}   ${output}   Run And Return Rc And Output    sudo ping -c 3 ${hostname}
    #if hostname is unreachable, ret will be 1, if pc is reachable, ret will be 0
    ${pc_reachable}   Set Variable If    "${ret}"=="0"    ${True}    ${False}
    Run Keyword If   not ${pc_reachable}
    ...   Log To Console   TestPC(${hostname}) cannot reachable，will skip Catch RU Log Through PC!
    # continue for loop if    '${hostname}'=='1.1.1.1'
    # continue for loop if   '${pc_reachable}' == '${False}'
    Return From Keyword If   not ${pc_reachable}   ${EMPTY}


    ${ru_info}    UUF_Utils.get_ru_username_password    ${ru_type}    ${active_release}    if_need_handle_dollar=${False}
    ${If_Default_LMI_ON}   Run Keyword and Return Status   List Should Not Contain Value   ${Default_LMI_ON_RU}   ${ru_type}
    Run Keyword If    ${If_Default_LMI_ON}   Run Keyword And Ignore Error
    ...   UUF_Utils.enable_ssh_to_ru
    ...   pc_ip=${hostname}   pc_username=${username}   pc_password=${password}
    ...   ru_ip=${ru_addr}   ru_info=${ru_info}

    # csn.Connect to    hostname=${hostname}   username=${username}   password=${password}   alias=RU_PC
    # csn.Execute   rm -f /home/${hostname}/.ssh/known_hosts   connection=RU_PC

    ${status}   ${return_list}   Run Keyword And Ignore Error
    ...   UUF_Utils.connet_to_ru_via_lmi
    ...   PC_ip=${hostname}   PC_user=${username}   PC_password=${password}
    ...   ru_ip=${ru_addr}   ru_type=${ru_type}   build_release=${active_release}

    Return From Keyword If   "${status}"=="FAIL"   ${EMPTY}

    ${connection_ru}   Set Variable   ${return_list[0]}
    ${connection_pc}   Set Variable   ${return_list[1]}


    ${remote_path}   Set Variable   /ram/RULOG_${hostname}.tar
    Log To Console   Start To Collect ${hostname}/${ru_type} Log!
    ${status}   Run Keyword And Return Status
    ...   csn.Execute   command=ccsShell.sh log -a -c full -z RULOG_${hostname}.tar   timeout=600   connection=${connection_ru}
    Return From Keyword If   not ${status}   ${EMPTY}

    Wait Until Keyword Succeeds   1m   5s   Check if remote file size not increased
    ...   file_path=${remote_path}   connection=${connection_ru}
    Run Keyword And Ignore Error   csn.Download File    remote_path=${remote_path}
    ...   local_path=${ru_log_path}   timeout=300   connection=${connection_ru}

    ${output}   OperatingSystem.Run   ls -la ${ru_log_path}
    ${status}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file
    ${file_size}   Get Variable Value   ${output.split()[4]}   0
    Run Keyword If   (not ${status}) or '${file_size}'=='0'   Run Keywords
    ...   Log To Console    ${ru_serial} RU log not exist in VM!   AND
    ...   Return From Keyword   ${EMPTY}

    [Return]   ${ru_log_path}
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection_ru}   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection_pc}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Kill PC Specific Processes
    [Arguments]   ${processes_name}
    FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
         ${test_pc_addr}   Set Variable   ${ru_detail['test_pc_addr']}
         ${test_pc_username}   Set Variable   ${ru_detail['test_pc_username']}
         ${test_pc_password}   Set Variable   ${ru_detail['test_pc_password']}
         Run Keyword And Ignore Error   Kill Single PC Specific Processes
         ...   ${test_pc_addr}   ${test_pc_username}   ${test_pc_password}   ${processes_name}
    END


Kill Single PC Specific Processes
    [Arguments]   ${test_pc_addr}   ${test_pc_username}   ${test_pc_password}   ${processes_name}

    Log To Console   Connect To Test PC: ${test_pc_addr}
    ${test_pc_alias}   Set Variable   ${test_pc_addr}
    ${test_pc_connected}   Run Keyword And Return Status
    ...   csn.Connect to   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_alias}
    ...   timeout=${10}
    Return From Keyword If   not ${test_pc_connected}   Log To Console    Cannot connect to ${test_pc_alias}.
#    ${output1}   csn.Execute   command=ps aux | grep "${processes_name}"| grep -v "grep"   connection=${test_pc_alias}
#    Log To Console    ${processes_name} return: ${output1}.

    ${output}   csn.Execute   command=ps aux | grep "${processes_name}" | grep -v "grep" |wc -l   connection=${test_pc_alias}
    ${output}   Split String   ${output}   \r\n
    Log To Console    ${processes_name} processes nubmer is: ${output[0]}

    run keyword if  "${output[0]}" != "0"   Run Keyword And Ignore Error
    ...   csn.Execute   command=kill -9 $(ps -ef|grep "${processes_name}"|grep -v grep|awk '{print $2}')   connection=${test_pc_alias}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_alias}


# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================


# Disable All REL5 RU Flag Cleanup

#     ${RU_disable_cleanup_info}   Create List

#     FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{CONCURRENT_ENB_LIST}
#         ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
#         ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
#         ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
#         @{ru_list}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['ru_list']}   @{EMPTY}

#         COAM Login    bts_host=${webem_addr}    username=${webem_username}    password=${webem_password}    alias=${testline}
#         ${software_dict}    UUF Get Software Version    ${testline}
#         ${active_release}   Set Variable   ${software_dict['active_release']}

#         ${RU_disable_cleanup_info}    Run Keyword And Ignore Error    Disable Single REL5 RU Flag Cleanup
#         ...    ${ru_list}    ${active_release}    ${RU_disable_cleanup_info}
#         Run Keyword And Ignore Error   COAM Logout   connection=${testline}
#     END

# Disable Single REL5 RU Flag Cleanup
#     [Arguments]  ${ru_list}    ${active_release}    ${RU_disable_cleanup_info}
#     FOR   ${ru_detail}   IN   @{ru_list}
#         ${hostname}   Set Variable   ${ru_detail['test_pc_addr']}
#         ${username}   Set Variable   ${ru_detail['test_pc_username']}
#         ${password}   Set Variable   ${ru_detail['test_pc_password']}
#         ${ru_type}   Set Variable   ${ru_detail['ru_type']}
#         ${ru_addr}   Set Variable   ${ru_detail['ru_addr']}

#         ${If_REL5_RU}   Run Keyword and Return Status   list should contain value   ${REL5_RU_List}   ${ru_type}
#         continue for loop if   '${If_REL5_RU}'=='False'
#         continue for loop if   ${hostname} in ${RU_disable_cleanup_info}

#         ${connection_ru}   ${connection_pc}   UUF_Utils.connet_to_ru_via_lmi   ${hostname}   ${username}
#         ...   ${password}   ${ru_addr}   ${ru_type}    ${active_release}

#         csn.Execute   command=touch /ram/disable_swman_cleanup   timeout=60   connection=${connection_ru}
#         csn.File Exists   remote_path=/ram/disable_swman_cleanup   connection=${connection_ru}

#         Append To List    ${RU_disable_cleanup_info}    ${hostname}

#         Run Keyword And Ignore Error   csn.Disconnect   connection=${connection_ru}
#         Run Keyword And Ignore Error   csn.Disconnect   connection=${connection_pc}
#     END
#     [Return]  ${RU_disable_cleanup_info}

