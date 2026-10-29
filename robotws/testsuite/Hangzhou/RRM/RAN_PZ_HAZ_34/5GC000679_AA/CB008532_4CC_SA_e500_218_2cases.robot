# *** Settings ***
# Documentation     author: Chen Xiaodong
# ...               contact: xiaodong.d.chen@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       679 Suite Setup
# Suite Teardown    679 Suite TearDown
# Force Tags        CB008532         
# ...    PY36
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Resource          Resources/5GC000679_common_keyword.robot
# Resource          ../5GC001655/Resources/1347_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
# #${tmp_swconfig_dir_2}    ${CURDIR}/../../../../commissionings/HGZ/${testline_name}
# ${tmp_swconfig_dir}    /home/ute/Downloads/TL218/4CC
# ${case1_default_scf}    ${tmp_swconfig_dir}/case1_default_scf.xml
# ${case2_default_scf}    ${tmp_swconfig_dir}/case2_default_scf.xml
# ${E500_4CC_Muti_UEs_SA}    ${tmp_swconfig_dir}/E500_scripts_4CC_Muti_UEs_SA
# 
# #bip wireshark
# ${f1ap_filter}    \"f1ap\"
# ${luashark_path_22R3}    /home/ute/Downloads/Lua_SBTS22R3/generated_luashark/luashark.lua
# ${command_template_22R3}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_22R3} -Y ${f1ap_filter} -T pdml
# ${f1ap_addScellID}    f1ap.sCellIndex 
# 
# *** Test Cases ***
# [1]CB008532_5G_A_1_gNB_Configuration_TDD_FDD_DL_4CC CA
#     [Tags]    CB008532    4CC    CIT_TRUNK
#     [Setup]    Case Setup ready
#     Load Case SCF and Commission new    default_scf=${case1_default_scf}
#     Synchron gNB and VIAVI
#     Connect to Common Unit Master
#     Start Bip Log Capture on nokk   
#     Cobham UE attach    ue_num=1    e500_script_path=${E500_4CC_Muti_UEs_SA}   BW=${100}    type=SA
#     ${list_log_path_local}    Stop Bip Log Capture on nokk and download BIP Logs to testPC
#     set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
#     log to console      "start_Tput"
#     Start DL and UL data for Muti UEs    ue_num=1    ul_throughput=30M    dl_throughput=2700M
#     Check 4CC add from bip log    
#     log to console      "check_Tput"
#     Sleep    8s
#     Get MAC DL UL throughput on VIAVI    e500_script_path=${E500_4CC_Muti_UEs_SA}
#     ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=700    cellid=331251722
#     ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=700    cellid=331251723
#     ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=50    cellid=331251716
#     ${DL_tput_cell4}    Check throughput on gNB    direction=dl    throughput=50    cellid=331252213
#     ${4CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}+${DL_tput_cell4}
#     Should be true    ${4CC_DL_tput}>=2200
#     [Teardown]    Run Keyword And Continue On Failure    Recover test ENV    E500_Muti_UEs=${E500_4CC_Muti_UEs_SA}    type=SA
# 
# [1]CB008532_5G_B_1_4CC_CA_blind_Scell_Addition_RRC_Connection_Reestablishment_on_serving_cell
#     [Tags]    CB008532    4CC    CIT_TRUNK
#     [Setup]    Case Setup ready
#     Load Case SCF and Commission new    default_scf=${case2_default_scf}
#     Synchron gNB and VIAVI
#     Connect to Common Unit Master
#     Start Bip Log Capture on nokk   
#     Cobham UE attach    ue_num=1    e500_script_path=${E500_4CC_Muti_UEs_SA}   BW=${100}    type=SA
#     ${list_log_path_local}    Stop Bip Log Capture on nokk and download BIP Logs to testPC
#     set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
#     log to console      "start_Tput"
#     Start DL and UL data for Muti UEs    ue_num=1    ul_throughput=30M    dl_throughput=2700M
#     Check 4CC add from bip log    
#     log to console      "check_Tput"
#     Sleep    8s
#     Get MAC DL UL throughput on VIAVI    e500_script_path=${E500_4CC_Muti_UEs_SA}
#     ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=700    cellid=331251722
#     ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=700    cellid=331251723
#     ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=50    cellid=331251716
#     ${DL_tput_cell4}    Check throughput on gNB    direction=dl    throughput=50    cellid=331252213
#     ${4CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}+${DL_tput_cell4}
#     Should be true    ${4CC_DL_tput}>=2200
#     Run Keyword And Ignore Error    E500 attach and verify    attach_script_path=${E500_4CC_Muti_UEs_SA}/SA_5G_1rUEattach.txt
#     ...                             type=SA     e500_alias=e500
#     Sleep    10s
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=700
#     ...                                                        cellid=331251722
#     [Teardown]    Run Keyword And Continue On Failure    Recover test ENV    E500_Muti_UEs=${E500_4CC_Muti_UEs_SA}    type=SA
# 
# [1]CNI_80224_04_4CC_TTFF_actPerCsiReportBundlingTddFr1_2200_simultaneous_SCell
#     [Tags]    TTFF    4CC  
#     [Setup]    Case Setup ready
#     Load Case SCF and Commission new    default_scf=${case2_default_scf}
#     Synchron gNB and VIAVI
#     Connect to Common Unit Master
#     Start Bip Log Capture on nokk   
#     Cobham UE attach    ue_num=1    e500_script_path=${E500_4CC_Muti_UEs_SA}   BW=${100}    type=SA
#     ${list_log_path_local}    Stop Bip Log Capture on nokk and download BIP Logs to testPC
#     set test variable    ${bip_log_path}    @{list_log_path_local}[0]
#     Csn.Disconnect    connection=ASIK Master
#     log to console      "start_Tput"
#     Start DL and UL data for Muti UEs    ue_num=1    ul_throughput=30M    dl_throughput=2700M
#     Check 4CC add from bip log    
#     log to console      "check_Tput"
#     Sleep    8s
#     Get MAC DL UL throughput on VIAVI    e500_script_path=${E500_4CC_Muti_UEs_SA}
#     ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=700    cellid=331251722
#     ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=700    cellid=331251723
#     ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=50    cellid=331251716
#     ${DL_tput_cell4}    Check throughput on gNB    direction=dl    throughput=50    cellid=331252213
#     ${4CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}+${DL_tput_cell4}
#     Should be true    ${4CC_DL_tput}>=2200
#     Run Keyword And Ignore Error    E500 attach and verify    attach_script_path=${E500_4CC_Muti_UEs_SA}/SA_5G_1rUEattach.txt
#     ...                             type=SA     e500_alias=e500
#     Sleep    10s
#     Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=700
#     ...                                                        cellid=331251722
#     [Teardown]    Run Keyword And Continue On Failure    Recover test ENV    E500_Muti_UEs=${E500_4CC_Muti_UEs_SA}    type=SA
# 
# *** Keywords ***
# Start Bip Log Capture on nokk
#     [Arguments]     ${mirror_port}=any    ${asik_alias}=ASIK Master
#     Enable mirror port on Loki    mirror_port=${mirror_port}
#     ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
#     ${channel}    Call Method    ${connection}    invoke_shell
#     Call Method    ${channel}    send    lxc-attach -n 0x1514\n
#     Sleep    1s
#     Call Method    ${channel}    send    tcpdump -i any -w /tmp/F1AP.pcap\n
# 
# Stop Bip Log Capture on nokk and download BIP Logs to testPC
#     [Arguments]     ${interface}=any
#     Run Keyword And Ignore Error    Stop BIP Capture On ASIK    interface=${interface}
#     ${list_log_path_local}    Download BIP Logs From nokk To TestPC and rename it
#     [Return]    ${list_log_path_local}
# 
# Download BIP Logs From nokk To TestPC and rename it
#     [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master    ${download_type}=Download
#     ...            ${log_prefix}=${None}    ${bip_prefix}=F1AP    ${bip_path2}=/tmp/node_CPIF00/tmp
#     @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${bip_path2}
#     ...                  connection=${connection}    file_indicator=${bip_prefix}*
#     should not be empty  ${list_log_names}    msg=No bip logs found with log prefix F1AP under asik tmp folder
#     Sort List    ${list_log_names}
#     @{list_log_path_local}    Create list
#     FOR  ${log_name}  IN  @{list_log_names}
#       ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
#       ${bip_name}    fetch from left    ${log_name}    .
#       ${bip_name_new}    Set Variable If    '${log_prefix}'!='${None}'    ${log_prefix}_${bip_name}_${timestamp}.pcap
#       ...                                                                 ${bip_name}_${timestamp}.pcap
#       Run Keyword If    '${download_type}'=='Download'    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
#       ...                                                 remote_path=${bip_path2}/${log_name}
#       ...                                                 local_path=${log_path}/${bip_name_new}
#       ...                                                 connection=${connection}
#       ...    ELSE IF    '${download_type}'=='SSHpass'    Wait Until Keyword Succeeds   2 min  5 sec    Run Process
#       ...               sshpass -p ${asik_password} scp -r ${asik_username}@${asik_addr}:${bip_path2}/${log_name} ${log_path}/${bip_name_new}
#       ...               shell=yes
#       ...    ELSE    Fail    msg=the value ${download_type} is not a valid value
#       Append to list    ${list_log_path_local}    ${log_path}/${bip_name_new}
#       csn.execute      command=rm -rf ${/}tmp${/}node_CPIF00${/}tmp${/}${log_name}    connection=${connection}
#     END
#     [Return]    ${list_log_path_local}
# 
# Check 4CC add from bip log
#     [Arguments]
#     log to console      "bip_4cc_check"
#     bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}   
#     ...                                                      command_template=${command_template_22R3}        
#     ${4cc_addcell_list}    Get value from Bip Log    field_name=${f1ap_addScellID}
#     ${length}    Get Length    ${4cc_addcell_list}
#     Should Be True    ${length}==3
