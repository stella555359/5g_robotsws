*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library           BuiltIn
Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
Library           taf.sbts.oam.coam.admin              WITH NAME    coam
Library           ./5G000577_common_keywords.py
Variables         ./5G000577_modify_para.py
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Library           taf.selenium.gnb.oam.coam.cu    WITH NAME   selenium_cu
Library           taf.transport.ssh      WITH NAME    csn



*** Keywords ***
Teardown gNB cOAM SSL Connection
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=GNB_OAM

Modify parameters online and Active Plan
    [Arguments]    ${PARAMS_TO_MODIFY}   ${time}    ${bts_ip}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${bts_ip}    username=${gNB_username}    password=${gNB_password}
    FOR    ${item}    IN    @{PARAMS_TO_MODIFY}
         ${dist_name}       get from dictionary     ${item}     dist_name
         ${filter_param}    get from dictionary     ${item}     filter_param
         ${new_value}       get from dictionary     ${item}     value
         selenium_coam.set_parameter_value   dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True
    Sleep  ${time}
    [Teardown]    Run keyword and ignore error     selenium_coam.logout

Modify parameters online and Active Plan On CU
    [Arguments]    ${dscp_value}=20    ${cplane_value}=21    ${dlDataSplitMode_value}=dlOverF1U   ${plan_name}=Modify_scf    ${flag}=dscp
    selenium_cu.enable_virtual_display
    selenium_cu.login    url=https://${CU_ip}   username=${gNB_username}    password=${gNB_password}    browser=Firefox
    selenium_cu.choose_plan    plan_name=CURRENT_PLAN
    ${cu_scf_path}    selenium_cu.save_cu_configuration
    log to console  ${cu_scf_path}
    ${modify_scf_path}    set variable   ${LOG_PATH}/Modify_scf.xml
    run keyword if  '${flag}'=='dscp'    paramsFile    filePath=${cu_scf_path}    dscp_value=${dscp_value}    cPlanedscp_value=${cplane_value}
    ...    save_path=${modify_scf_path}
    run keyword if  '${flag}'=='dlDataSplitMode'    Modify_dlDataSplitMode_Value    filePath=${cu_scf_path}  save_path=${modify_scf_path}
    ...    dlDataSplitMode_value=${dlDataSplitMode_value}
    selenium_cu.logout
    sleep  20s
    selenium_cu.login    url=https://${CU_ip}   username=${gNB_username}    password=${gNB_password}    browser=Firefox
    selenium_cu.load_commissioning_file_and_check_load_status    file_path=${modify_scf_path}    plan_name=${plan_name}   timeout=60
    selenium_cu.choose_plan    plan_name=${plan_name}
    selenium_cu.activate_plan
    sleep  15min
    ${dir_path}    get_file_path    file_path=${cu_scf_path}
    log to console  ${dir_path}
    csn.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=connection_ute
    csn.Execute   command=sudo rm -rf ${dir_path}   connection=connection_ute
    [Teardown]    Run keyword and ignore error    run keywords    csn.Disconnect    connection=connection_ute    AND    selenium_cu.logout

Modify DSCP Value On eNB
    [Arguments]  ${new_value}    ${cPlaneDscp}    ${parammeter}=qciTab7    ${dist_name}=${MR_NR_UDSCP_eNB_NAME}   ${connection}=coam_admin
    coam.connect_to    bts_host=${eNB_ip}   name=coam_admin
    ${get_managed_objects}     coam.get_managed_objects     class_name=LNBTS_A    connection=${connection}
    ${param}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${qciTab7}    get from dictionary     ${param}    ${parammeter}
    ${new_value}    Modify_eNB_DSCP_Value    input_dict=${qciTab7}     new_value=${new_value}
    &{output1}    coam.Perform Parameter Recommissioning    dist_name=${dist_name}    parameter=cPlaneDscp    value=${cPlaneDscp}
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    Sleep   3min
    &{output2}    coam.Perform Parameter Recommissioning    dist_name=${dist_name}    parameter=${parammeter}    value=${new_value}
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${connection}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target}   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Connect to TestPc
    [Arguments]  ${hostname}=${TEST_PC_IP}    ${username}=${TEST_PC_USERNAME}    ${password}=${TEST_PC_PASSWORD}
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=TESTPC
    [Return]   ${connection}

Get DSCP On CU
    [Arguments]    ${CU_parameter_web}
    selenium_cu.enable_virtual_display
    selenium_cu.login    url=https://${CU_ip}   username=${gNB_username}    password=${gNB_password}    browser=Firefox
    ${parameter_value_list}    Create list
    FOR     ${item}    IN    @{CU_parameter_web}
         ${object_name}    get from dictionary     ${item}     object_name
         ${filter_param}    get from dictionary     ${item}     filter_param
         ${abbreviation}    get from dictionary     ${item}     abbreviation
         ${parameter_value}    selenium_cu.get_parameter_value  object_name=${object_name}
         ...  filter_param=${filter_param}    abbreviation=${abbreviation}
         Append To List    ${parameter_value_list}    ${parameter_value}
    END
    [Return]     ${parameter_value_list}
    [Teardown]    Run keyword and ignore error     selenium_cu.logout

Get DSCP On BaseStation
    [Arguments]    ${bts_addr}    ${bts_parameter_web}
    selenium_coam.login    url=https://${bts_addr}    username=${gNB_username}    password=${gNB_password}
    ${parameter_value_list}    Create list
    FOR     ${item}    IN    @{bts_parameter_web}
         ${dist_name}    get from dictionary     ${item}     dist_name
         ${filter_param}    get from dictionary     ${item}     filter_param
         ${abbr}    get from dictionary     ${item}     abbr
         ${parameter_value}    selenium_coam.get_parameter_value  dist_name=${dist_name}
         ...  filter_param=${filter_param}    abbr=${abbr}
         Append To List    ${parameter_value_list}    ${parameter_value}
    END
    [Return]     ${parameter_value_list}
    [Teardown]    Run keyword and ignore error     selenium_coam.logout

Get DSCP Value On eNB
    [Arguments]    ${parameter1}    ${parameter2}    ${abbr}
    coam.connect_to    bts_host=${eNB_ip}    name=coam_admin
    ${dscp_value_list}    create list
    ${get_managed_objects}     coam.get_managed_objects     class_name=LNBTS_A    connection=coam_admin
    ${param}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${qciTab7}      get from dictionary     ${param}    qciTab7
    ${dscp_value}    get from dictionary    ${qciTab7}    dscp
    ${cplanedscp_value}    get from dictionary     ${param}    cPlaneDscp
    Append to list    ${dscp_value_list}    ${dscp_value}
    Append to list    ${dscp_value_list}    ${cplanedscp_value}
    [Return]    ${dscp_value_list}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=coam_admin

attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
         ${status}    run keyword and return status    power ue attach again    ${item}
         run keyword if  not ${status}    power ue attach again    ${item}
    END

power ue attach again
    [Arguments]    ${ue_index}=${1}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

detach multi power ue
    [Arguments]    ${ue_num}=${1}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
          power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}=${1}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000
    ...    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
          run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
          ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
          sleep    1s
          run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
          ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    END

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}=${1}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
         ...    protocol=${protocol}
         run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
    END

Start to Capture wireshark Log
    [Arguments]    ${port_list}  ${filename_list}  ${connection1}    ${connection2}
    log to console  ${port_list}
    ${oam_connection}    csn.Connect To     hostname=${oam_ip}   username=${oam_username}   password=${oam_password}   alias=${connection1}
    ${list_len}    get length  ${port_list}
    ${list_len_tmp}    evaluate   ${list_len}-2
    FOR  ${i}    IN RANGE    ${list_len_tmp}
        csn.send command   command=ssh mmw-tl${tl_name}-1-upue-000.local -- sudo tcpdump -n -i ${port_list}[${i}] -w /tmp/${filename_list}[${i}]
        ...  connection=${connection1}
    END
    csn.send command    command=ssh mmw-tl${tl_name}-1-cpif-000.local -- sudo tcpdump -n -i ${port_list}[2] -w /tmp/${filename_list}[2]
    ...    connection=${connection1}
    ${eNB_connection}    csn.Connect To     hostname=${eNB_ip}   username=${eNB_name}   password=${eNB_password}   alias=${connection2}
    csn.send command    command=tcpdump -i ${port_list}[3] -w /tmp/${filename_list}[3]
    ...     connection=${connection2}
    sleep    3s
    ${connection_list}    create list  ${oam_connection}    ${eNB_connection}
    [Return]  ${connection_list}

Stop Upue log and Download Log
    [Arguments]    ${filename_list}    ${connection1}   ${connection2}
    csn.Execute    command=ssh mmw-tl${tl_name}-1-upue-000.local -- sudo killall tcpdump    connection=${connection1}
    csn.Execute    command=ssh mmw-tl${tl_name}-1-cpif-000.local -- sudo killall tcpdump    connection=${connection1}
    csn.Execute    command=killall tcpdump    connection=${connection2}
    ${list_len}    get length   ${filename_list}
    ${list_len_tmp1}    evaluate   ${list_len}-2
    FOR  ${i}    IN RANGE    ${list_len_tmp1}
         csn.send command    command=sudo scp mmw-tl${tl_name}-1-upue-000.local:/tmp/${filename_list}[${i}] ${log_dir}   connection=${connection1}
         sleep    1min
         csn.send command    command=ssh mmw-tl${tl_name}-1-upue-000.local -- sudo rm /tmp/${filename_list}[${i}]    connection=${connection1}
    END
    csn.send command    command=sudo scp mmw-tl${tl_name}-1-cpif-000.local:/tmp/${filename_list}[2] ${log_dir}    connection=${connection1}
    sleep    1min
    csn.send command    command=ssh mmw-tl${tl_name}-1-cpif-000.local -- sudo rm /tmp/${filename_list}[2]    connection=${connection1}
    sleep    10s
    csn.disconnect    connection=${connection1}
    csn.disconnect    connection=${connection2}
    ${test_pc_connection}    csn.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}
    ...    alias=connection_ute
    csn.Execute   command=sudo rm /root/.ssh/known_hosts    connection=connection_ute
    ${list_len_tmp2}    evaluate  ${list_len}-1
    FOR   ${m}    IN RANGE    ${list_len_tmp2}
         csn.Execute   command=sudo sshpass -p rastre1 scp robot@${oam_ip}:${log_dir}/${filename_list}[${m}] ${LOG_PATH}
         ...     connection=connection_ute
    END
    csn.Execute   command=sudo sshpass -p ${eNB_password} scp ${eNB_name}@${eNB_ip}:/tmp/${filename_list}[-1] ${LOG_PATH}
    ...     connection=connection_ute
    sleep    10s
    log to console  Download Log successful
    [Teardown]  Run keyword and ignore error    csn.Disconnect    connection=${test_pc_connection}

Remove Files From Ute
    [Arguments]  ${filename_list}
    ${test_pc_connection}    csn.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}
    ...    alias=connection_ute
    ${txt_list}    Covert_PcapFileName_To_TxtFileName    input_list=${filename_list}
    ${list_len}    get length  ${filename_list}
    FOR  ${i}    IN RANGE    ${list_len}
         csn.Execute   command=sudo rm ${LOG_PATH}/${filename_list}[${i}]    connection=connection_ute
         csn.Execute   command=sudo rm ${LOG_PATH}/${txt_list}[${i}]    connection=connection_ute
    END
    [Teardown]  Run keyword and ignore error    csn.Disconnect    connection=${test_pc_connection}

Batch Convert pcap to text
    [Arguments]     ${pcap_file_list}
    ${connection}    common_keyword.Connect to TestPc
    ${txt_list}    Covert_PcapFileName_To_TxtFileName    input_list=${pcap_file_list}
    ${txt_path_list}    create list
    ${list_len}    get length  ${pcap_file_list}
    FOR    ${i}    IN RANGE    ${list_len}
         Convert pcap to text    source=${LOG_PATH}/${pcap_file_list}[${i}]    target=${LOG_PATH}/${txt_list}[${i}]
         ...    connection=${connection}
         Append to list   ${txt_path_list}    ${LOG_PATH}/${txt_list}[${i}]
    END
    [Return]   ${txt_path_list}
    [Teardown]  run keyword and ignore error  csn.Disconnect	connection=${connection}

Download Asslog And Check DLRate
    [Arguments]    ${min_value}    ${max_value}
    csn.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=connection_ute
    csn.Execute   command=sudo sshpass -p ${eNB_password} scp ${eNB_name}@${gNB_ip}:/tmp/data_dl.txt ${LOG_PATH}
    ...     connection=connection_ute
    ${return_value}    Parsing_Asslog    file_path=${LOG_PATH}/data_dl.txt    min_value=${min_value}    max_value=${max_value}
    should be equal as strings  ${return_value}    ${True}
    [Teardown]  run keyword and ignore error    csn.Disconnect    connection=connection_ute

Check F1U And X2U Ip In Text
    [Arguments]  ${txt_path_list}   ${src_dst_iplist}
    FOR    ${i}    IN RANGE    ${2}
         ${txt_path_tmp}    set variable   ${txt_path_list}[${i}]
         ${src_dst_tmp}    set variable   ${src_dst_iplist}[${i}]
         ${return_value}    Get_IpAddress_In_Text    file_path=${txt_path_tmp}   src_ip=${src_dst_tmp}[0]  dst_ip=${src_dst_tmp}[1]
         should be equal as strings   ${return_value}    ${True}
    END

Reset gNB
    [Arguments]    ${timeout}=5min   ${bts_ip}=${gNB_ip}    ${wait_for_reconnection}=${False}
    ${connection}    coam.connect_to    bts_host=${bts_ip}   name=coam_admin
    coam.reset_site    timeout=${timeout}    connection=${connection}    wait_for_reconnection=${wait_for_reconnection}
    Sleep     15min
    [Teardown]  run keyword and ignore error  coam.Teardown    connection=${connection}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
    coam.connect_to    bts_host=${bts_ip}   name=${connection}
    FOR    ${item}  IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}
