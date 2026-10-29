# @Time    : 2022/2/15 13:17
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : bip.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common bip keywords
...    Include Keywords:
...    Download MCShark To UTE
...    Get MCShark Version
...    Convert BIP To CSV By MCShark
...    Connect To BTS Csn Via Lmp
...    Get L1L2 ABIO Traffic To ASIL Cpu
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Get BIP File List
    [Documentation]    jin.2.zhang@nokia-sbell.com
    [Arguments]    ${log_path}   ${connection}=UTE_CON      ${bip_prefix}=BTS1910_2011_mirroring_L2L1   ${mergecap_wait}=120s
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=UTE_CON

    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${log_path}    connection=${connection}
    ...    file_indicator=${bip_prefix}*
    should not be empty  ${list_log_names}   msg=No bip logs found with log prefix tcpdumpL2L1Bip
    Sort List    ${list_log_names}

    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
      Append to list    ${list_log_path_local}    ${log_path}/${log_name}
      sleep    1s
    END

    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable    ${list_log_path_local_all}    ${log_path}/${timestamp}.pcap
    Run   mergecap -w ${list_log_path_local_all} ${log_path}/${bip_prefix}*
    sleep   ${mergecap_wait}
    Run   rm -rf ${log_path}/${bip_prefix}*
    [Return]    ${list_log_path_local_all}

Start to collect bip log new
    [Documentation]    jin.2.zhang@nokia-sbell.com
    [Arguments]    ${nr_phy_cell_ids}   ${host}=192.168.255.129   ${username}=Nemuadmin  ${password}=nemuuser  ${port}=443
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${username}
    ...  password=${password}
    ...  port=${port}

    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...  timeout=1500

    core.setup_collectors    names=l1l2bip
    core.start_collectors    names=l1l2bip
    core.Set Suite Alias     l1l2bip

Stop to collect bip log new
    [Documentation]    jin.2.zhang@nokia-sbell.com
    [Arguments]    ${target_dir}
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip       target_dir=${target_dir}
    core.teardown_collectors    names=l1l2bip

Merge Multiple Bip Files Into One File
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${module_location}=primary
#    ${bip_prefix}    Set Variable If    "${module_location}"=="primary"    BTS${MRBTS_ID}_1011_mirroring_L2L1
#    ...    BTS${MRBTS_ID}_2011_mirroring_L2L1
#    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
#    Set Suite Variable    ${list_log_path_local_all}    ${BIP_FILE_PATH}/${timestamp}.pcap
#    Run    mergecap -w ${BIP_FILE_PATH}/${timestamp}.pcap ${BIP_FILE_PATH}/${bip_prefix}*
#    Wait Until Created    ${BIP_FILE_PATH}/${timestamp}.pcap    timeout=1min
#    Run    rm -rf ${BIP_FILE_PATH}/${bip_prefix}*
#    [Return]    ${BIP_FILE_PATH}/${timestamp}.pcap
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable    ${list_log_path_local_all}    ${BIP_FILE_PATH}/${timestamp}.pcap
    Run    mergecap -w ${BIP_FILE_PATH}/${timestamp}.pcap ${BIP_FILE_PATH}/BTS*
    Wait Until Created    ${BIP_FILE_PATH}/${timestamp}.pcap    timeout=1min
    Run    rm -rf ${BIP_FILE_PATH}/BTS*
    [Return]    ${BIP_FILE_PATH}/${timestamp}.pcap

Collect Bip Log And Convert To CSV
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_ids}    ${module_location}    ${bip_file}    ${bip_filter}    ${bip_fields}
    Start to collect bip log new    ${cell_ids}
    Stop to collect bip log new    ${TS_CASE_LOG_PATH}
    ${merged_bip_file}    Merge Multiple Bip Files Into One File    module_location=${module_location}
    Convert BIP To CSV By MCShark    bip_file=${merged_bip_file}
    ...    output_file=${bip_file}    filter=${bip_filter}
    ...    csv_title_list=${bip_fields}

Download MCShark To UTE
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}

    ${sw_version}    Get MCShark Version
    ${cmd}    Catenate    wget -r -np -nH --header="Authorization: Bearer cmVmdGtuOjAxOjE3OTI5MjExOTA6ME1uaG1sTzdKYTduOVpVNnM1TVpJcDNueVND"
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    ls ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${wireshark_version}*bookworm.so | head -n 1
    set suite variable     ${MCShark}

    ${cmd2}    Set Variable    ls ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${wireshark_version}*bookworm.so
    ${rc2}    ${output2}    OperatingSystem.Run And Return Rc And Output    ${cmd2}

    ${exist1}     Run keyword and return status    Should not contain    ${output2}    No such file or directory
    #${exist2}     Run keyword and return status    Should not contain    ${output}    404 Not Found

    ${is_MCShark_exist}=  Run Keyword if  '${exist1}'=='${True}'
    ...     set variable  ${True}

    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*bookworm.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/

    log to console    download mcshark successfully to UTE

Get MCShark Version
    [Documentation]    jian.1.chen@nokia-sbell.com
    Connect to gnb coam via ssl
    ${sw_version}    coam.get_sw_version    connection=GNB_OAM
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}
    [Teardown]    COAM Teardown gnb connections

Merge BIP Files To One File
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${bip_files_path}
    List Files In Directory    ${bip_files_path}

Convert BIP To CSV By MCShark
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Time -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Connect To BTS Csn Via Lmp
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    csn.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

Get L1L2 ABIO Traffic To ASIL Cpu
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${file_path}=/tmp/tcpdump_L2L1.pcap
    ...    ${timeout}=2s
    ${asil}=  Create Dictionary
    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    tcpdump.create_tcpdump_collector
    ...    name=tcpdump
    ...    options=-v -i nac_eth2 -C 100 -W 20 -w ${file_path}
    ...    executor=${asil}
    ${asil_commands}=    Create List
    ...    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C1B1(6)" -s 1 -v 303
    ...    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C1B1(6)" -s 1 -v 304
    ...    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C1B1(6)" -s 1 -v 305
    ...    bcicmd -n 3msd -c "/dbg3ms/port 36 set learning 0 0 1"
    ...    bcicmd -n 3msd -c '/dbg3ms/mirror set 35 13 both'
    ...    bcicmd -n 3msd -c "/dbg3ms/vlan add 303 13 untagged"
    ...    bcicmd -n 3msd -c "/dbg3ms/vlan add 304 13 untagged"
    ...    bcicmd -n 3msd -c "/dbg3ms/vlan add 305 13 untagged"
    ...    bcicmd -n 3msd -c "/dbg3ms/vlan remove 303 21"
    ...    bcicmd -n 3msd -c "/dbg3ms/vlan remove 304 21"
    ...    bcicmd -n 3msd -c "/dbg3ms/vlan remove 305 21"
    ...    dbgnac set port 2 speed 25000
    ...    dbgnac enable port 2
    ...    dbgnac set port 2 loop e t
    ...    dbgnac mirror sport 0 dport 2 e b
    ...    dbgnac mirror sport 2 dport 20 e b
    ...    /usr/bin/netd_uspace_lnk 2 1 25000 1
    ...    ifconfig nac_eth2 up
    ...    ifconfig nac_eth2 promisc
    l1l2bip.create_generic_l1l2bip_collector
    ...    name=Genericl1l2bip
    ...    collector=tcpdump
    ...    executor=${asil}
    ...    setup_commands=${asil_commands}
    core.setup_collectors    names=Genericl1l2bip
    core.start_collectors    names=Genericl1l2bip
    sleep    ${timeout}
    core.stop_collectors    names=Genericl1l2bip
    core.teardown_collectors    names=Genericl1l2bip

Check_Bip_Sub_Info_By_Special_Item
    [Documentation]    xudong.1.li@nokia-sbell.com
    [Arguments]    ${file_path}    ${item}    ${item_value}    ${father_dict}
    ${special_row_values} =    get_the_special_item_row_values    ${file_path}
    ...    ${item}    ${item_value}
    ${event_result}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Sub Dictionary    ${special_row_values}    ${father_dict}
    Should Be True     '${event_result}'=='True'
