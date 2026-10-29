*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB007326

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
#Library           resources/python_libs/TestCaseRequirement.py
#Library           resources/python_libs/cells.py
#Library           resources/python_libs/systemd.py
#Library           resources/python_libs/verify_rf.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
Library           Attenuation.Attenuation    WITH NAME    atten
Library           taf.hw.rf_attenuator    WITH NAME    attenuator
#Library           sigspark.SigSpark    WITH NAME    spark
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig

*** Variables ***
${ue_type}            ${tl.ues[0].capabilities[0]}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
#${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
#${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${gnb_addr}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enb_address}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${att_api_port}         ${tl.attenuator[0].port}
${max_attenuation_value}     ${127}
${vendor}               ${tl.attenuator[0].vendor}
${model}                ${tl.attenuator[0].model}
${5GRU_atten_ip_376}    ${tl.attenuator[0].ip_addr}
${5GRU_ANT_356_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT_356_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU_ANT_356_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU_ANT_356_4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4GRU1_ANT1}    ${tl.attenuator[0].attenuator_ports[5]}
${4GRU1_ANT2}    ${tl.attenuator[0].attenuator_ports[6]}
${att_port_1_388}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_388}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_388}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_388}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_388}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_388}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_388}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_8_388}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_1_377}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_377}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_377}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_377}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_377}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_377}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_377}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_8_377}                ${tl.attenuator[0].attenuator_ports[6]}
${traffic_duration}    600
${Send_Tput_DL}    800M
#${localFilePath_swconfig_570}    /opt/workspace/CRT/Master/SCF_file/swconfig.txt
${gnb_instance}    ${tl.gnbs[0].instance_id}
@{counter_dic_path}    BTS/MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/PDCP2
#@{counter_dic_path}    BTS/BTS/NRBTS-${gnb_instance}/PDCP2
@{gnb_id_list}    356111    37711    388
#${TS_LOG_PATH_BASE_cloud}    /home/ute/workspace/CRT/Master/Case_Logs/
#${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
#${ute_log_path_cloud}    /home/ute/test_results/
#${tl_scf_dir_path_cloud}    /home/ute/Auto5G/commissionings/HGZ/
${testline_name}      null
${CONFIGURATION}      null
@{att_port_356}    ${5GRU_ANT_356_1}    ${5GRU_ANT_356_2}    ${5GRU_ANT_356_3}    ${5GRU_ANT_356_4}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

*** Keywords ***
Prepare with COAM classical BTS cell onair
    [Arguments]    ${scf_filename}=${tl_scf_filename}
    Perform full commission for COAM gnb    scf_filename=${scf_filename}
    Check gnb COAM classical start normally
    Check the gnb cell status onair

Perform full commission for COAM gnb
    [Arguments]    ${scf_filename}    ${is_pdl_checking_needed}=${False}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${scf_filename}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
#    Check Airscale HW module status
    Check the gnb RU status ready

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    20min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Modify NIDD parameter online
    [Arguments]    ${parameters_to_update}    ${timeout}=${600}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5s
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${Delete_Para_Online}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    Delete_Para_Online=${Delete_Para_Online}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

### UE ###
Precondition for Sansumg UE
    [Arguments]    ${ue_type}    ${ui_version}=S20UI2.5    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}    reset_sol=pc_reset

Check phone attach successfully
#    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a
#    unlock the screen    ue_index=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True

### PA adjust ###
#Adjust gNB_RU Attenuation
#    [Arguments]    ${value1}=${0}    ${value2}=${127}
#    ${release_info}    Get sagnb release
#    run keyword if    '${gnb_instance}'=='${gnb_id_list[0]}'    Adjust trunk gNB Attenuation    value1=${20}    value2=${value2}
#    ...    ELSE IF    '${gnb_instance}'=='${gnb_id_list[2]}'    Adjust 22R1 gNB Attenuation    value1=${value1}    value2=${value2}
#    ...    ELSE    Adjust 22R2 gNB Attenuation    value1=${value1}    value2=${value2}
#    Set Suite Variable    ${release}    ${release_info}

Adjust trunk gNB Attenuation
    [Arguments]    ${value1}=${value1}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_376}
    ...    value_1=${value1}    value_2=${value1}    value_3=${value1}    value_4=${value1}
    ...    att_port_1=${5GRU_ANT_356_1}    att_port_2=${5GRU_ANT_356_2}
    ...    att_port_3=${5GRU_ANT_356_3}    att_port_4=${5GRU_ANT_356_4}
    ...    attenuation_port_numbers=${5GRU_ANT_356_1}

Adjust 22R1 gNB Attenuation
    [Arguments]    ${value1}=${value1}    ${value2}=${value2}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_376}
    ...    value_1=${value1}    value_2=${value1}    value_3=${value1}    value_4=${value1}
    ...    att_port_1=${att_port_1_388}    att_port_2=${att_port_2_388}
    ...    att_port_3=${att_port_3_388}    att_port_4=${att_port_4_388}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_376}
    ...    value_1=${value2}    value_2=${value2}    value_3=${value2}    value_4=${value2}
    ...    att_port_1=${att_port_5_388}    att_port_2=${att_port_6_388}
    ...    att_port_3=${att_port_7_388}    att_port_4=${att_port_8_388}

Adjust 22R2 gNB Attenuation
    [Arguments]    ${value1}=${value1}    ${value2}=${value2}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_376}
    ...    value_1=${value1}    value_2=${value1}    value_3=${value1}    value_4=${value1}
    ...    att_port_1=${att_port_1_377}    att_port_2=${att_port_2_377}
    ...    att_port_3=${att_port_3_377}    att_port_4=${att_port_4_377}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_376}
    ...    value_1=${value2}    value_2=${value2}    value_3=${value2}    value_4=${value2}
    ...    att_port_1=${att_port_5_377}    att_port_2=${att_port_6_377}
    ...    att_port_3=${att_port_7_377}    att_port_4=${att_port_8_377}

adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}    ${att_port_2}     ${att_port_3}    ${att_port_4}     ${atten_ip}
    ...             ${attenuation_port_numbers}=${att_port_1}    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    5s

adjust the enb HBTE attenuation value
    [Arguments]     ${value_1}=${0}     ${value_2}=${0}    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${5GRU_atten_ip_376}    port=${att_api_port}
    ...    attenuation_port_numbers=${4GRU1_ANT1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${4GRU1_ANT1}    value=${value_1}
    attenuator.set_attenuation     port=${4GRU1_ANT2}    value=${value_2}
    ${value_port_1}    attenuator.read_attenuation    port=${4GRU1_ANT1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${4GRU1_ANT2}
    should be equal    ${value_port_2}    ${value_2}
    sleep    5s

adjust the HBTE attenuation value tl388
    [Arguments]     ${value_1}     ${value_2}
    ...             ${att_port_1}    ${att_port_2}     ${atten_ip}    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    sleep    5s

Get all xiaomi11 pointer variable tl377
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1245 1878
    Set Suite Variable    ${close_task}    717 2920
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

#Get sagnb release
#    [Arguments]   ${host}=${gnb_addr}   ${username}=${gnb_username}   ${password}=${gnb_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info


gNB connections to ssh
    [Arguments]    ${connection}
    csn.Connect To    alias=${connection}


#tcp tput#
SA L3 call attach with udp data and check PM counter
    [Arguments]    ${ue_index}=${0}
    Wait until keyword succeeds    3X    10s    Check phone attach successfully
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${Send_Tput_DL}    duration=${traffic_duration}    ue_index=${ue_index}    protocol=udp
    sleep    60s
    Check the cell DLUL throughput    cellid=16383
    Wait until keyword succeeds    10min    1min
    ...    Check the PM counter should not be zero    counter_id=${counter_id}    dic_path=${counter_dic_path}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    protocol=udp
    [Teardown]

Check the cell DLUL throughput
    [Arguments]    ${cellid}=1        #${bandwidth}=100M
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}
    Wait Until Keyword Succeeds   3x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${0}
    ...    ue_type=${ue_type}    direction=dl    throughput=10    cellid=${nrcellid}    sleep_time=${20}

Tear down UE traffic and detach
    run keywords
    ...    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    ...    protocol=udp    AND
    ...    power_ue.UE Detach  ue_type=${ue_type}

### enb ###
enb connection
    [Arguments]    ${alias}=enb
    csn.Connect To    hostname=${enb_address}    username=${enb_username}    password=${enb_password}    alias=${alias}

### counter ###
Check the PM counter should not be zero
    [Arguments]    ${counter_id}    ${dic_path}
    ${counter_result_value}    Create List
    ${counter_result}    Create List
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        ${counter_dict}    Create Dictionary    ${counter_id[${index}]}=${counter_value[0]}
        append to list    ${counter_result_value}    ${counter_value[0]}
        append to list    ${counter_result}    ${counter_dict}
    END
    ${counter_result_lenth}    Get Length    ${counter_result_value}
    Should be equal    ${counter_lenth}    ${counter_result_lenth}
    Should not contain    ${counter_result_value}    ${0}    msg=check counter fail
    [Teardown]    COAM Teardown gnb connections

Locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Locked LTE cell 388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

lock LTE
    run keyword if   '${gnb_instance}'=='${gnb_id_list[0]}'    locked LTE cell
    ...    ELSE    locked LTE cell 388

Unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Unlocked LTE cell 388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Unlock LTE
    run keyword if   '${gnb_instance}'=='${gnb_id_list[0]}'    Unlocked LTE cell
    ...    ELSE    Unlocked LTE cell 388

Get all xiaomi11 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1260 2090
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Get all xiaomi11 pointer variable tl388
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1251 2208
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Set automatic rotation on UEs
    Set automatic rotation
#    Set automatic rotation    ue_index=${1}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

unlock the screen
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
#    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    Run Keyword If   '${release}'=='SBTS22R3_ENB_9999'
    ...    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    ...    ELSE    csn.send_command   command=adb -s ${serial_number} shell input swipe 738 2958 733 1002    connection=${connection}
    sleep    2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}


Prepare testline to cell onair for NSA
    Update the swconfig file  localFilePath=${SWCONFIG_DEFAULT_FILE_PATH}
    Prepare with COAM classical BTS cell onair


Update the swconfig file
    [Arguments]    ${localFilePath}
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master with gnbindex   gnb_index=${0}    alias=ASIK Master
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Start traffic xiaomi
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1400B
    ...            &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC xiaomi    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}

Start DL traffic and check the TP on EPC xiaomi
    [Documentation]    stat DL traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    ...    :param  protocal: Traffic protocal type. E.G udp/tcp
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    ...            ${process_num}=${1}    ${seg_size}=1180    ${window}=2M
    run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with first UE xiaomi   ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...    ELSE    Start DL TCP traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}

Start DL traffic and check the TP on EPC with first UE xiaomi
    [Arguments]    #${swipe}=${swipe}    #${iperf_button}=${iperf_button}        #${Home_button}=${Home_button}
#    ...            ${open_iperf_location}=${open_iperf_location}
    ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    ...            ${process_num}=${1}
    Get Commercial UE IP xiaomi   ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Get Commercial UE IP xiaomi
    [Arguments]    ${ue_index}=${0}   #${cap_index}=${0}    #${capabilities}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
#    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get Commercial UE IP with first UE    ue_index=${ue_index}

Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    Default directory for ute cloud

Default directory for ute cloud
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min    ${response_timeout}=10
    ${cur_dir}    run    pwd
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua

    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    Run keyword if    ${has_cbts}   wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM    timeout=${response_timeout}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    set suite variable    ${epc_log_path}    ${SUITE_LOG_PATH}
    set suite variable    ${TS_LOG_PATH_BASE}     ${SUITE_LOG_PATH}
    Set Suite Variable    ${ute_log_path}    ${SUITE_LOG_PATH}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/

    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

#Default directory for ute cloud
#    [Documentation]    Author: Ren Biyao
#    ...     Description: default dir scf and swconfig and log dir for ute cloud.
#    ${cur_dir}    run    pwd
#    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
#    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
#    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
#    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_cloud}
#    Set Suite Variable    ${ute_log_path}    ${ute_log_path_cloud}
#    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
#    Common Suite Setup for COAM

Get EnergySavingState
    [Arguments]    ${required_info}=energySavingState    ${status}=reducedEnergySaving    ${cell_index}=${1}
    ${get_status}    get required cell info    required_info=${required_info}    cell_index=${cell_index}
    should be equal    ${get_status}    ${status}

Check the PM counter CB011016
    [Arguments]    ${counter_id}    ${dic_path}    ${value_min}    ${value_max}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True   ${value_max} > ${counter_value[0]} > ${value_min}
    END
    [Teardown]    COAM Teardown gnb connections

Common UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
