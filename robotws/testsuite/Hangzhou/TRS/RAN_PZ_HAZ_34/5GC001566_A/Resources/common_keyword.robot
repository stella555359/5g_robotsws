*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           BuiltIn
Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
Library           taf.sbts.oam.coam.admin              WITH NAME    coam
Library           ./5G000519_common_keywords.py
Variables         ./5G000519_modify_para.py
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Library           taf.selenium.gnb.oam.coam.cu    WITH NAME   selenium_cu
Library           taf.transport.ssh      WITH NAME    csn



*** Keywords ***
Setup Commission SCF
    [Arguments]   ${default_path}
     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_path}
     Wait Until Keyword Succeeds    16min    2min   common_keyword.Check cell on air
     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Check cell on air
    [Arguments]      ${connection}=GNB_OAM
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses         connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir


Get BTS Version And Perare SCF
    [Arguments]    ${CURDIR_path}     ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Clear Log On Ute
    [Arguments]    ${file_path}    ${connection}=TestPC
    common_keyword.Connect to TestPc    connection=${connection}
    csn.Send Command    command=sudo rm -rf ${file_path}/*.txt    connection=${connection}
    csn.Send Command    command=sudo rm -rf ${file_path}/*.pcap    connection=${connection}
    csn.Send Command    command=sudo rm -rf ${file_path}/mac*   connection=${connection}
    [Teardown]  Run keyword and ignore error    csn.Disconnect    connection=${connection}

Connect to TestPc
    [Arguments]   ${connection}    ${hostname}=${TEST_PC_IP}    ${username}=${TEST_PC_USERNAME}    ${password}=${TEST_PC_PASSWORD}
    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=${connection}

Clear DU Mac Counter
    [Arguments]    ${connection}=GNB
    csn.Connect to     hostname=${gNB_ip}    username=${gNB_ssh_username}    password=${gNB_ssh_password}   alias=${connection}
    csn.Send Command  command=echo 1 > /var/run/cpss/ports/1/clear_port_mac_counters    connection=${connection}
    csn.Send Command  command=echo 1 > /var/run/cpss/ports/2/clear_port_mac_counters    connection=${connection}
    [Teardown]  Run keyword and ignore error    csn.Disconnect    connection=${connection}

Copy Mac Counter From DU To Ute
    [Arguments]  ${connection}    ${Download_file}=${LOG_PATH}
    ${counter_path}    set variable  /var/run/cpss/ports/
    csn.Send Command  command=sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "${gNB_ip}"          connection=${connection}
    csn.Send Command  command=sudo sshpass -p ${gNB_ssh_password} scp -r ${gNB_ssh_username}@${gNB_ip}:${counter_path}2/mac_counters ${Download_file}
    ...    connection=${connection}
    Sleep   10s
    csn.Send Command  command=sudo mv ${Download_file}/mac_counters ${Download_file}/mac2_counters    connection=${connection}
    Sleep   3s
    csn.Send Command  command=sudo sshpass -p ${gNB_ssh_password} scp -r ${gNB_ssh_username}@${gNB_ip}:${counter_path}1/mac_counters ${Download_file}
    ...    connection=${connection}
    Sleep   10s
    csn.Send Command  command=sudo mv ${Download_file}/mac_counters ${Download_file}/mac1_counters    connection=${connection}
    Sleep   3s
    ${mac_counter_list}    create list    ${Download_file}/mac1_counters    ${Download_file}/mac2_counters
    [Return]  ${mac_counter_list}


Creat TestCenter Packet
    [Arguments]    ${file_name}    ${time}    ${connection}=TestPC
    common_keyword.Connect to TestPc    connection=${connection}
    Clear DU Mac Counter
    csn.Send Command  command=sudo tclsh ${CURDIR}/${file_name}    connection=${connection}
    Sleep    ${time}
    ${mac_counter_list}    Copy Mac Counter From DU To Ute    connection=${connection}
    ${drop_package_number}    Parsing_Mac_Counters_File    file_path_list=${mac_counter_list}
    [Return]  ${drop_package_number}
    [Teardown]  Run keyword and ignore error    csn.Disconnect    connection=${connection}

#need to check our init file
Connect to control pc via cygwin
    [Arguments]    ${ue_index}=${1}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=${alias}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${connection}   ${filter}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Convert pcap to text By filter
    [Arguments]     ${pcap_file}    ${filter_list}    ${txt_list}   ${connection}=TestPC
    common_keyword.Connect to TestPc    connection=${connection}
    ${txt_path_list}    create list
    ${list_len}    get length  ${txt_list}
    FOR    ${i}    IN RANGE    ${list_len}
         Convert pcap to text    source=/home/ute/Downloads/519_A/${pcap_file}    target=${LOG_PATH}/${txt_list}[${i}]
         ...    filter=${filter_list}[${i}]   connection=${connection}
         Append to list   ${txt_path_list}    ${LOG_PATH}/${txt_list}[${i}]
    END
    [Return]   ${txt_path_list}
    [Teardown]  run keyword and ignore error  csn.Disconnect	connection=${connection}

Get Different Package Number And Calculation Ratio
    [Arguments]  ${file_path_list}    ${value}
    ${count_list}    Get_Different_Package_Time    file_path_list=${file_path_list}
    ${return_value}    Calculation_Different_Package_Ratio    input_list=${count_list}    value=${value}
    should be equal as strings    ${return_value}    ${True}

Get TRS Counter Change List
    [Arguments]    ${input_counter}   ${name}=GNB_OAM1    ${bts_ip}=${gNB_ip}
    ${connection}    coam.connect_to    bts_host=${bts_ip}     name=${name}
    ...     bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}   bts_port=${443}
    Log    PM Wait To Nearest Measurement Period    console=yes
    ${after_list}    Wait Until Keyword Succeeds      15min  3min   Judge TRS Counters List Length    input_List=${input_counter}
    ...    connection=${connection}
    [Return]  ${after_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Judge TRS Counters List Length
    [Arguments]    ${input_List}    ${connection}
    ${input_list_length}    get length  ${input_List}
    ${after_list}    Get TRS BRGPRT-2 Counters List    connection=${connection}
    ${after_list_length}    get length  ${after_list}
    ${number}   Evaluate    ${after_list_length}-${input_list_length}
    Should Be Equal As Integers     ${number}    2
    log to console  ${after_list}
    [Return]  ${after_list}

Get TRS Counters List via Api
     [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${counter_info}    Get TRS BRGPRT-2 Counters List    connection=${connection}
    [Teardown]   Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]  ${counter_info}

Get TRS BRGPRT-2 Counters List
    [Arguments]    ${connection}
    ${counters_info}    coam.get_counters_info    connection=${connection}    timeout=120
    ${TRS_info}    get from dictionary    ${counters_info}    TRS
    ${TNL_info}    get from dictionary    ${TRS_info}    TNL-1
    ${TRS_info}    get from dictionary    ${TNL_info}    BRGPRT
    ${BRGPRT_info}    get from dictionary    ${TRS_info}    BRGPRT-2
    ${BRGPRT_2_info}    get from dictionary    ${BRGPRT_info}    Bridge_Port_Stats
    ${Bridge_Port_Stats}    get from dictionary   ${BRGPRT_2_info}    M51363C7
    ${counters_info}    Get Dictionary Values    ${Bridge_Port_Stats}
    [Return]  ${counters_info}

Juge TRS BRGPRT-2 Counter Is Right
    [Arguments]    ${max}   ${drop_number}    ${counter_info}
    ${number}    Evaluate    ${counter_info}[-1]+${counter_info}[-2]
    ${return_value}   Check_TRS_Counter_Value    input_number=${number}   drop_number=${drop_number}   max=${max}
    should be equal as strings    ${return_value}   ${True}

Modify Value On DU
    [Arguments]    ${structure_modify_list}=None    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=coam_admin
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection= ${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    run keyword if  ${is_common}    Modify Common parameter via Coam    input_list=${common_modify_list}    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}
    FOR    ${item}  IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}
