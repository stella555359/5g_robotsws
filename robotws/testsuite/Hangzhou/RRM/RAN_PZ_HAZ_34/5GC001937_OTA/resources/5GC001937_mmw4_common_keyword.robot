*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/coam.robot
Library     BuiltIn
Library     taf.sbts.oam.coam.admin              WITH NAME    coam
Library     taf.transport.ssh      WITH NAME    csn
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library     licence_keeper.licence_keeper     WITH NAME    LK
Library     ./5GC001937_mmw4_common_keywords.py
Library     ./samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark
Library     samsung_sigspark.BaseClient    WITH NAME    samsung_BaseClient
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library     kpi_reporter.KpiReporter    WITH NAME    KpiReporter
Library     ute_reporting_portal




*** Variables ***
${LKC_LOGIN_USER}        qianyou.zhu@nokia-sbell.com
${LKC_LOGIN_PWD}         Noki@123
${LKC_CLIENT_PORT}       6006
${LKC_CLIENT_ALIAS}      lkc
${LKC_CLIENT_PATH}       /cygdrive/c/Users/nokia5G/Desktop/QPM_LK1.5.1(Wroclaw-Hangzhou)
${5G_QXDM_PATH}          C:/tools/QXDM_TA
${QCAT_EXE_PATH}         "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe"
${ul_power_port_list}    ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}    ${tl.ues[0].iperf_details.ports[3:6]}
${UE_TYPE}                samsung
${TS_CASE_LOG_PATH}       ${output_dir}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${LOG_PATH}               ${output_dir}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${CU_ip}                  ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
${tl_name}                ${tl.gnbs[0].global_bts_id}
${gNB_ssh_name}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_pass}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ue_number}              ${2}
${duration}               ${5000}
${ul_tput_udp}            300M
${dl_tput_udp}            2250M
${ul_tput_tcp}            100M
${dl_tput_tcp}            200M
${log_time}               5min
${exp_ul}                 ${210}
${exp_dl}                 ${4203}
${deviation}              5%
${total_count}            ${300}
${control_pc}             ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}        ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}        ${tl.ues[0].ssh_connection_details.password}
@{case_row_list}          NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
@{all_cell_list}          16385    16386    16387    16388    16389    16390    16391    16392

*** Keywords ***
########### check bts on air #################
Set Default scf name
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00.xml
    ...     ${CURDIR_path}SCF_${version_list[0]}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}


Setup Commission SCF
    [Arguments]  ${connection}=GNB_OAM
    robot_common_operations.Common Suite Setup
    Set Default scf name
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    timeout=600
    sleep    5min
#    Check cell on air
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}


Check cell on air
    [Timeout]    20 min
    Wait until cluster is on cell on air status    timeout=20 min
    wait until keyword succeeds    5 min    10 sec    Verify all cells should be onair
    ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
    should be equal as strings  ${rus_connect_success}    True


########## modify parameter ###################
Modify Value On DU
    [Arguments]    ${structure_modify_list}=None    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=coam_admin
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    run keyword if  ${is_common}    Modify Common parameter via Coam    input_list=${common_modify_list}    connection=${connection}
    Check cell on air
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

Modify Common Parameter As Examples
    [Arguments]  ${Modify_007case_step5_1}    ${False}
    Modify Value On DU    common_modify_list=${Modify_007case_step5_1}   is_structure=${False}

Modify Structure And Common Parameter As Examples
    [Arguments]  ${Modify_011case_step5_1}    ${Modify_011case_step5_2}    ${keywords_list1}
    Modify Value On DU     structure_modify_list=${Modify_011case_step5_1}   common_modify_list=${Modify_011case_step5_2}
    ...    class_name=BRGPRT_A    keywords_list=${keywords_list1}

Modify SCF And Commission SCF
    [Arguments]   ${save_path}    ${input_list}
    ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
    Modify_GNB_SCF    file_path=${default_scf}  save_path=${save_path}   input_list=${input_list}
    Setup Commission SCF    default_path=${save_path}


############# UE attach relevant ###################
attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_index=${item}    ue_type=samsung
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END


stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${protocol}=tcp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_num}=${4}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

UE Attach and Start Traffic
    [Arguments]  ${ue_num}    ${ul_throughput}    ${dl_throughput}    ${ul_duration}    ${dl_duration}    ${protocol}    ${if_ul}    ${if_dl}
    attach multi power ue    ue_num=${ue_num}
    start multi power ue traffic ul and dl    ue_num=${ue_num}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}    ul_duration=${ul_duration}    dl_duration= ${dl_duration}
    Sleep   10s

##################### check tp by adb ################################
Get multiple UE package Data
    [Arguments]  ${ue_num}
    ${package_data_list}    Create list
    ${data_list}    Create list
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc via cygwin    ue_index=${ue_index}
        ${ue_serial_number}    set variable  ${tl.ues[${ue_index}].serial_number}
        csn.send_command    command=adb -s ${ue_serial_number} shell ps -ef | grep com.android.phone |awk {'print $2'}    connection=cygwin
        ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
        csn.send_command    connection=cygwin
        ...    command=adb -s ${ue_serial_number} shell cat /proc/${pid.split("\r")[0]}/net/dev | grep rmnet_data0 |awk '{print $2,$10}' &
        ${speed}    csn.Read Output    connection=cygwin
        ${date}  	Get Current Date    result_format=timestamp
        Append to list    ${package_data_list}    ${speed}
        Append to list    ${data_list}    ${date}
        run keyword and ignore error   Csn.Disconnect	connection=cygwin
    END
    [Return]  ${package_data_list}    ${data_list}

Kill QXDM and QPSK exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM QXDM.exe    connection=cpc_${ue_index}
    csn.send command    command=taskkill /F /IM QPSTServer.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Kill ClientMain exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM ClientMain.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Prepare LKC
    [Arguments]    ${ue_index}
    ${UE_pc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${UE_pc_user} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${UE_pc_password} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    ${res} =    LK.licence_keeper_client_is_running    alias=${LKC_CLIENT_ALIAS}
    Run Keyword If    ${res} == ${True}     Kill ClientMain exe    ue_index=${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${Client_path}    catenate  SEPARATOR=   ${LKC_CLIENT_PATH}    ;./ClientMain.exe
    csn.send command
    ...    command=cd ${Client_path}    connection=cpc_${ue_index}    timeout=100
    Sleep    5s
    LK.connect    host=${UE_pc_ip}    port=${LKC_CLIENT_PORT}
    LK.login    username=${LKC_LOGIN_USER}    password=${LKC_LOGIN_PWD}

Keep 5G Licence
    LK.get_licence_qxdm_5g
    LK.get_licence_qcat_5g

Get Qualcomm License
    [Arguments]    ${ue_index}
    Kill QXDM and QPSK exe    ue_index=${ue_index}
    Prepare LKC    ue_index=${ue_index}
    Keep 5G Licence

Capture QXDM5 log
    [Arguments]    ${ue_index}    ${QXDM_log_name}    ${time}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=cmd /c python ${5G_QXDM_PATH}/QXDM5Logcatch.py -t ${time} -p MDM -c ${5G_QXDM_PATH}/volume.dmc -s ${5G_QXDM_PATH}
    ...    /${QXDM_log_name}.hdf
    ...    connection=cpc_${ue_index}    timeout=300
    sleep    5s
    Csn.disconnect      connection=cpc_${ue_index}

5G isf decoder to txt and save to local
    [Arguments]    ${ue_index}    ${QXDM_log_name}
    Connect to control pc enhanced    ue_index=${ue_index}
    wait until keyword succeeds    2min    2s    Csn.Assert file exists
    ...    remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.hdf    connection=cpc_${ue_index}
    Log to console   \nINFO:5G Qmdl decoder to txt
    csn.force_reconnect       connection=cpc_${ue_index}
    ${result}   Csn.execute
    ...  command=cmd /c ${QCAT_EXE_PATH} -txt ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ...  connection=cpc_${ue_index}
    Log to console   \nINFO:${result}
    Csn.download file
    ...   remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.txt
    ...   local_path=${output_dir}/${QXDM_log_name}.txt
    ...   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.hdf   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.txt   connection=cpc_${ue_index}
    Csn.disconnect   connection=cpc_${ue_index}



####################### check tp by Asslog ##################################
Capture Aasyslog
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${filter}=L2Lo    ${log_name}=data_dl.txt    ${log_ip}=127.0.0.1    ${timeout}=15m
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition     gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}    log_name=${log_name}
	...    log_ip=${log_ip}    timeout=${timeout}

Get UL And DL TP From Aaslog
    [Arguments]   ${file_name}
    ${cell_number}    Get cell numbers in gnb
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    host=${gNB_ip}   username=${gNB_ssh_name}
    ...    password=${gNB_ssh_pass}    log_name=${file_name}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    ${dl_list}    create list    ${dl_average_tp}    ${dl_peak_tp}    ${dl_minimum_tp}
    ${ul_list}    create list    ${ul_average_tp}    ${ul_peak_tp}    ${ul_minimum_tp}
    [Return]    ${dl_list}    ${ul_list}

UE Start Traffic and Check Aasyslog
    [Arguments]  ${ue_num}    ${ul_throughput}    ${dl_throughput}    ${protocol}    ${sleep_time}    ${file_name}    ${if_ul}    ${if_dl}
    ...    ${except_ul_tp}    ${except_dl_tp}
    start multi power ue traffic ul and dl    ue_num=${ue_num}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    sleep    10s
    AAsys log captrue    gnb_index=${0}    du_index=${0}    sleep_time=${sleep_time}    filter=${EMPTY}    log_name=${file_name}
    stop multi power ue traffic ul and dl     ue_num=${ue_num}    protocol=${protocol}   if_ul=${if_ul}    if_dl=${if_dl}
    Check TP From Aasyslog     file_name=${file_name}    except_ul_tp=${except_ul_tp}    except_dl_tp=${except_dl_tp}

Check TP From Aasyslog
    [Arguments]  ${file_name}
    ${dl_list}     ${ul_list}   Get UL And DL TP From Aaslog    file_name=${file_name}
    log to console  ${dl_list}[0]
    log to console  ${ul_list}[0]
#    run keyword and continue on failure  should be true    @{ul_list}[0]>${exp_ul}
#    run keyword and continue on failure  should be true    @{dl_list}[0]>${exp_dl}
    [Return]    ${dl_list}     ${ul_list}

Power UE Check TP From Aasyslog
    [Arguments]  ${log_path}    ${if_ul}=${True}    ${if_dl}=${True}    ${exp_ul_tp}=${exp_ul}    ${exp_dl_tp}=${exp_dl}
    ...    ${ul_list}=${all_cell_list}     ${dl_list}=${all_cell_list}
    Copy Aasys log From Du    file_name=${log_path}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${output_dir}/${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=0.98
    ...    min_percent=0.85    actCarrierAggregation=${True}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${output_dir}/${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=0.98
    ...    min_percent=0.85    actCarrierAggregation=${True}

Copy Aasys log From Du
    [Arguments]  ${file_name}    ${bts_host}=${gNB_ip}    ${connection}=ASIK_Master
    csn.Connect to    hostname=${bts_host}    username=${gNB_ssh_name}    password=${gNB_ssh_pass}    alias=${connection}
    csn.download_file    remote_path=/tmp/${file_name}    local_path=${output_dir}/${filename}    connection=${connection}
    sleep    2s
    [Teardown]  Csn.Disconnect	connection=${connection}

Capture Aasys log and Capture iperf log
    [Arguments]  ${ue_num}    ${protocol}    ${file_name}    ${time}    ${if_ul}    ${if_dl}   ${ul_port_list}=${None}    ${dl_port_list}=${None}
    Log to console    Unused variable dl_port_list/ul_port_list:${dl_port_list},${ul_port_list}
    Log to console    Unused variable if_ul/if_dl:${if_ul},${if_dl}
    Log to console    Unused variable protocol:${protocol}
    Capture Aasyslog    log_name=${file_name}    filter=${EMPTY}
#    ${tput_file_list_ul}    run keyword if  ${if_ul}==${True}    Start multiple UE tput checking via iperf for ports    ue_num=${ue_num}
#    ...    port_list=${ul_port_list}    direction=ul
#    ${tput_file_list_dl}    run keyword if  ${if_dl}==${True}    Start multiple UE tput checking via iperf for ports    ue_num=${ue_num}
#    ...    port_list=${dl_port_list}    direction=dl
    ${package_data_list1}    ${data_list1}    Get multiple UE package Data    ue_num=${ue_num}
    Sleep    ${time}
#    ${local_tput_file_list_ul}    run keyword if  ${if_ul}==${True}    Stop multiple UE tput checking via iperf for ports    ue_num=${ue_num}
#    ...        port_list=${ul_port_list}    tput_file_list=${tput_file_list_ul}    direction=ul
#    ${local_tput_file_list_dl}    run keyword if  ${if_dl}==${True}    Stop multiple UE tput checking via iperf for ports    ue_num=${ue_num}
#    ...        port_list=${dl_port_list}    tput_file_list=${tput_file_list_dl}    direction=dl
    ${package_data_list2}    ${data_list2}    Get multiple UE package Data    ue_num=${ue_num}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
#    stop multi power ue traffic ul and dl    ue_num=${ue_num}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    [Return]    ${package_data_list1}    ${package_data_list2}    ${data_list1}    ${data_list2}
#    [Teardown]  detach multi power ue    ue_num=${ue_num}

####################### capture X2 log ##################################
Connect to Common Unit ENB
    [Arguments]  ${proxy}=OAM    ${alias}=ENB_Connection
    Log to console    Unused variable proxy:${proxy}
    csn.Connect to    hostname=${eNB_ip}    username=${gNB_ssh_name}    password=${gNB_ssh_pass}
    ...    alias=${alias}

Start to Capture X2 Log on ENB
    [Arguments]    ${filename}
    Connect to Common Unit ENB
    csn.send command    command=killall tcpdump    connection=ENB_Connection
    Start to Capture wireshark Log    listen_port=br1    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ENB_Connection

Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.send command    command=tcpdump -n -i ${listen_port} ip -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

#Read Wireshark Log
#    [Arguments]    ${filename}    ${filter}=${None}
#    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${connection}   ${filter}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Convert pcap file to txt
    [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
    [Teardown]  run keyword and ignore error  csn.Disconnect	connection=${connection}

Stop and Download X2 Log
    [Arguments]    ${filename}    ${asik}=ENB_Connection
    Connect to Common Unit ENB
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${asik}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}    connection=${asik}
    run keyword and continue on failure  csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${output_dir}/${filename}
    ...    connection=${asik}
    sleep    2s
    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
    [Teardown]  Csn.Disconnect	connection=${asik}

Capture X2 Log And UE Attach
    [Arguments]    ${x2_file}    ${ue_num}
    attach multi power ue    ue_num=${ue_num}
    Start to Capture X2 Log on ENB    filename=${x2_file}

Stop X2 log and Check X2 log
    [Arguments]    ${file_name}
    Stop and Download X2 Log    filename=${file_name}.pcap    asik=ENB_Connection
    Convert pcap file to txt   source=${output_dir}/${file_name}.pcap   target=${output_dir}/${file_name}.txt   filter=x2ap   connection=TEST_PC
    ${value}  Check_UE_Release_Info_From_X2_log   file_path=${output_dir}/${file_name}.txt
    run keyword and continue on failure  should be true  ${value}

Test One UE on QXDM
    [Arguments]  ${QXDM_log_name}=QXDM_01
    Get Qualcomm License    ue_index=${0}
    attach multi power ue    ue_num=${1}
    Capture QXDM5 log    ue_index=${0}   QXDM_log_name=${QXDM_log_name}    time=60
    start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=100M    dl_throughput=1024M   protocol=udp
    stop multi power ue traffic ul and dl    ue_num=${1}    protocol=udp
    5G isf decoder to txt and save to local    ue_index=${0}    QXDM_log_name=${QXDM_log_name}
    [Teardown]   detach multi power ue   ue_num=${1}

################# Snopshot ###########################
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=5min
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${snapshot_path}    Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}


################ check tp through iperf ################
Start tput checking via iperf for multiple ports
    [Arguments]    ${iperf_port_list}    ${direction}    ${ue_id}=${1}
    ${iperf_port_list}    Convert variable to list type    input_var=${iperf_port_list}
    ${tput_file_list}    create list
    FOR    ${port}    IN    @{iperf_port_list}
        ${tput_file}    run keyword if    '${direction}'=='ul'
        ...      wait until keyword succeeds    1 m    3 s
        ...      Start ul tput checking via iperf    iperf_ul_port=${port}    ue_id=${ue_id}
        ...    ELSE IF    '${direction}'=='dl'
        ...      wait until keyword succeeds    1 m    3 s
        ...      Start dl tput checking via iperf    ue_id=${ue_id}    iperf_dl_port=${port}
        ...    ELSE    log to console    '${direction}' should be ul or dl, please use correct value.
        append_to_list    ${tput_file_list}    ${tput_file}
    END
    [Return]    ${tput_file_list}

Start ul tput checking via iperf
    [Arguments]    ${iperf_ul_port}=${IPERF_UL_PORT}    ${ue_id}=${1}
    log to console    Start to check ul tput for ue${ue_id}_port${iperf_ul_port}
    @{filter_conditions}    create list    iperf    ${iperf_ul_port}
    ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
    run keyword if    '${pid}'!='${EMPTY}'    Kill process on APPServer    pid=${pid}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tput_file}    set variable    /tmp/Tput_ue${ue_id}_ul_p${iperf_ul_port}_${timestamp}
    ssh.send_command    command=iperf -s -u -i 1 -w 2M -p ${iperf_ul_port} > ${tput_file} &    connection=EPCAPP
    sleep    200ms
    ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
    should not be empty    ${pid}
    [Return]    ${tput_file}

Check process existence on APPServer
    [Arguments]    ${filter_conditions}
    ${filter_conditions}    Convert variable to list type    input_var=${filter_conditions}
    ${filters}    set variable    ${EMPTY}
    FOR    ${condition}    IN    @{filter_conditions}
        ${filters}    set variable if    '${filters}'=='${EMPTY}'    ${condition}   ${filters}|grep ${condition}
    END
    ${cmd_check_process}    set variable    ps -ef | grep -v gerp | grep ${filters} | awk '{print $2}'
    ssh.send_command    command=${cmd_check_process}    connection=EPCAPP
    ${pid}    ssh.read_output    connection=EPCAPP
    ${pid}    replace_string    string=${pid}   search_for=\n    replace_with=${SPACE}
    [Return]    ${pid}

Kill process on APPServer
    [Arguments]    ${pid}
    return from keyword if    '${pid}'=='${EMPTY}'
    ssh.send_command    command=kill -9 ${pid}    connection=EPCAPP
    ssh.send_command    command=ps ${pid} | grep -v -i pid | awk '{print $2}'    connection=EPCAPP
    ${pid}    ssh.read_output    connection=EPCAPP
    should be empty    ${pid}

Start dl tput checking via iperf
    [Arguments]    ${ue_id}=${1}    ${iperf_dl_port}=${tl.ues[${ue_id}-1].iperf_details.port}    ${iperf_path}=${None}    ${ue_type}=${UE_TYPE}
    ${iperf_path}   run keyword if    ${iperf_path}!=${None}                set variable    ${iperf_path}
    ...    ELSE IF    ${iperf_path}==${None} and '${ue_type}'=='samsung'    set variable    /data/local/tmp/iperf
    ...    ELSE IF    ${iperf_path}==${None} and '${ue_type}'=='qct_dx50'     set variable    /system/bin/iperf
    ...    ELSE       ${iperf_path}==${None}    log to console  iperf path is unknown,please specify

    log to console    Start to check dl tput for ue${ue_id}_port${iperf_dl_port}
    @{filter_conditions}    create list    iperf    ${iperf_dl_port}
    ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
    run keyword if    '${pid}'!='${EMPTY}'    Kill process on adb device    pid=${pid}    ue_id=${ue_id}
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tput_file}    set variable    /tmp/Tput_ue${ue_id}_dl_p${iperf_dl_port}_${timestamp}
    ${cmd_iperf_server}    set variable if    '${ue_type}'=='samsung' or '${ue_type}'=='qct_dx50'
    ...    adb -s ${serial_number} shell ${iperf_path} -s -u -i -w 2M -p ${iperf_dl_port} > ${tput_file} &
    ...    ${iperf_path} -s -u -i -w 2M -p ${iperf_dl_port} > ${tput_file} &
    ssh.send_command    command=${cmd_iperf_server}    connection=cygwin
    ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
    should not be empty    ${pid}
    [Return]    ${tput_file}

Check process existence on adb device
    [Arguments]    ${filter_conditions}    ${ue_id}=${1}
    ${filter_conditions}    Convert variable to list type    input_var=${filter_conditions}
    ${filters}    set variable    ${EMPTY}
    FOR    ${condition}    IN    @{filter_conditions}
        ${filters}    set variable if    '${filters}'=='${EMPTY}'    ${condition}   ${filters}|grep ${condition}
    END
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    ${cmd_check_process}    set variable    adb -s ${serial_number} shell ps -ef | grep -v gerp | grep ${filters} | awk '{print $2}'
    ssh.send_command    command=${cmd_check_process}    connection=cygwin
    ${pid}    ssh.read_output    connection=cygwin
    ${pid}    replace_string    string=${pid}   search_for=\n    replace_with=${SPACE}
    ${pid}    replace_string    string=${pid}   search_for=\r    replace_with=${SPACE}
    [Return]    ${pid}

Convert variable to list type
    [Arguments]    ${input_var}
    ${is_list}    evaluate    isinstance(${input_var},list)
    ${output_var}    run keyword if    ${is_list}==${False}    create list    ${input_var}
    ...    ELSE    set variable    ${input_var}
    [Return]    ${output_var}

Stop tput checking via iperf for multiple ports
    [Arguments]    ${iperf_port_list}    ${direction}    ${ue_id}=${1}
    run keyword if    '${direction}'=='dl'    Connect to control pc via cygwin    ue_index=${${ue_id}-1}
    ...    ELSE    Connect to EPC APP
    ${iperf_port_list}    Convert variable to list type    input_var=${iperf_port_list}
    FOR    ${port}    IN    @{iperf_port_list}
        run keyword if    '${direction}'=='ul'
        ...      wait until keyword succeeds    2 m    3 s
        ...      Stop ul tput checking via iperf    iperf_ul_port=${port}
        ...    ELSE IF    '${direction}'=='dl'
        ...      wait until keyword succeeds    2 m    3 s
        ...      Stop dl tput checking via iperf    ue_id=${ue_id}    iperf_dl_port=${port}
        ...    ELSE    log to console    '${direction}' should be ul or dl, please use correct value.
    END
    ${connection}    set variable if    '${direction}'=='dl'    cygwin   EPCAPP
    [Teardown]  Run keyword and ignore error    Csn.Disconnect	connection=${connection}

Stop ul tput checking via iperf
    [Arguments]    ${iperf_ul_port}=${IPERF_UL_PORT}
    @{filter_conditions}    create list    iperf    ${iperf_ul_port}
    ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
    wait until keyword succeeds    5x    200ms    Kill process on APPServer    pid=${pid}

Stop dl tput checking via iperf
    [Arguments]    ${ue_id}=${1}    ${iperf_dl_port}=${tl.ues[${ue_id}-1].iperf_details.port}
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    @{filter_conditions}    create list    iperf    ${iperf_dl_port}
    ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
    wait until keyword succeeds    5x    200ms    Kill process on adb device   ue_id=${ue_id}    pid=${pid}

Kill process on adb device
    [Arguments]    ${pid}    ${ue_id}=${1}
    return from keyword if    '${pid}'=='${EMPTY}'
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid}    connection=cygwin
    ssh.send_command    command=adb -s ${serial_number} shell ps ${pid} | grep -v -i pid | awk '{print $2}'    connection=cygwin
    ${pid}    ssh.read_output    connection=cygwin
    should be empty    ${pid}

Download tput files to test pc
    [Documentation]    Author: Cui Lingxue
    ...    Download a list of tput files from control PC or APP server.
    ...    :param  direction: ul or dl.
    ...    :param  tput_file_list: a list of tput files or singal tput file to be downloaded.
    ...    :param  ue_id: starting from 1, ue_id=ue_index+1
    ...    :param  local_tput_dir: directory path on testPC.
    ...    :return local_tput_file_list: path on testPC of downloaded files.
    [Arguments]    ${direction}    ${tput_file_list}    ${ue_id}=${1}    ${local_tput_dir}=${TS_CASE_LOG_PATH}
    run keyword if    '${direction}'=='dl'    Connect to control pc via cygwin    ue_index=${${ue_id}-1}
    ...    ELSE    Connect to EPC APP
    ${connection}    set variable if    '${direction}'=='dl'    cygwin   EPCAPP
    ${tput_file_list}    Convert variable to list type    input_var=${tput_file_list}
    ${is_folder_exist}    run keyword and return status    directory_should_exist    path=${local_tput_dir}
    run keyword if    '${is_folder_exist}'=='False'    create_directory    path=${local_tput_dir}
    log to console  ${tput_file_list}
    ssh.download_file    remote_path=${tput_file_list}   local_path=${local_tput_dir}    connection=${connection}

    @{local_tput_file_list}    create_list
    FOR    ${file}    IN    @{tput_file_list}
        ${file_name}    fetch_from_right    string=${file}    marker=/
        ${local_tput_file}    join_path    ${local_tput_dir}    ${file_name}
        append_to_list    ${local_tput_file_list}    ${local_tput_file}
    END

    FOR    ${file}    IN    @{tput_file_list}
        run keyword and continue on failure    ssh.send_command    command=rm -rf ${file}    connection=${connection}
    END
    [Return]    ${local_tput_file_list}
    [Teardown]  Run keyword and ignore error    Csn.Disconnect	connection=${connection}


Get tput info from file
    [Documentation]    Author: Cui Lingxue
    ...    Return: ue tput info for each drb and total of all drbs on ul or dl direction.
    ...           example: {'ue1_ul': {'p71824': 23.6, 'total': 23.6}, 'ue1_dl': {'p71825': 129.93, 'total': 129.93}}
    [Arguments]    ${tput_file_list}
    ${file_group_dict}    classify_tput_files_into_file_groups    tput_file_list=${tput_file_list}
    ${tput_group_dict}    calculate_tput_for_file_groups    file_group_dict=${file_group_dict}
    [Return]    ${tput_group_dict}


Spark Start UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.start_log    ue_alias=${ue_alias}

Spark Stop UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}    ${log_name}=${TS_CASE_LOG_PATH}/uelog_sigspark_UE${ue_index}.xml
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.stop_log    ue_alias=${ue_alias}    logname=${log_name}   filter=test

Start Prepare UE
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ${status}    Run Keyword And Return Status    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    Run Keyword If    '${status}'=='False'    Restart App    ue_type=${ue_type}    ue_index=${ue_index}

Restart App
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    ...                Documentation:Restart Spark APP and disable data service
    [Arguments]    ${ue_index}=${0}
    samsung_spark.restartapp    index=${ue_index}
    Sleep    2 sec
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}

Start UE Attach
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    samsung_spark.power_off    ue_alias=${ue_alias}
    Sleep    10s
    samsung_spark.power_on    ue_alias=${ue_alias}

Start UE Detach
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    samsung_spark.power_off    ue_alias=${ue_alias}

start multi power ue traffic ul and dl by spark attach
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    run keyword and continue on failure    run keyword if    ${if_dl}    Multi UE start dl traffic    ue_num=${ue_num}
    ...    dl_throughput=${dl_throughput}    dl_duration=${dl_duration}    protocol=${protocol}
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_ul}    Multi UE start ul traffic    ue_num=${ue_num}
    ...    ul_throughput=${ul_throughput}    ul_duration=${ul_duration}    protocol=${protocol}

Multi UE start ul traffic
    [Arguments]  ${ue_num}    ${ul_throughput}    ${ul_duration}    ${protocol}
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Start traffic    ue_index=${item}    direction=ul    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung
        ...    iperf_type=via_command    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
    END

Multi UE start dl traffic
    [Arguments]  ${ue_num}    ${dl_throughput}    ${dl_duration}    ${protocol}
    FOR    ${item}    IN RANGE    ${ue_num}
        Start DL traffic via spark attach    ue_index=${item}    traffic=${dl_throughput}    time=${dl_duration}
        ...    iperf_port=${dl_power_port_list}[${item}]    protocol=${protocol}
    END

Start DL traffic via spark attach
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp    ${process_num}=${5}
    run keyword if    '${protocol}'=='udp'        Start DL UDP traffic via spark attach    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...    ELSE    Start DL TCP traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=1280

Start DL UDP traffic via spark attach
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    Get Commercial UE IP    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

UE attach by Spark
    [Arguments]  ${ue_num}=${1}    ${ue_type}=huawei_sigspark
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        ${5Grach_ed}    wait until keyword succeeds    4X    2min    Prepare UE and Attach UE by spark    ue_index=${ue_index}
        power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
        Log To Console    Attach UE_${ue_index} success
    END

Prepare UE and Attach UE by spark
    [Arguments]  ${ue_index}
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
#    samsung_spark.enable_ue_data_service    ue_alias=UE_${ue_index}
    ${5Grach_ed}    samsung_spark.attach_ue    ue_alias=UE_${ue_index}   attach_mode=5G_NSA     power_reset=False    timeout=90000
    log to console    UE_${ue_index}
    log to console    ${5Grach_ed}
    [Return]  ${5Grach_ed}

Start data traffic and Record TP Log and Aasys Log
    [Arguments]  ${ue_num}    ${ul_throughput}   ${dl_throughput}   ${ul_duration}    ${dl_duration}    ${protocol}   ${file_name}    ${time}
    ...    ${if_ul}=${True}    ${if_dl}=${False}
    Spark Start UE Log    ue_index=0
    start multi power ue traffic ul and dl by spark attach    ue_num=${ue_num}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    Sleep    30s
    Capture Aasyslog    log_name=${file_name}    filter=${EMPTY}
    Sleep    ${time}

Stop data traffic and Stop Record TP Log and Aasys Log
    [Arguments]  ${ue_num}    ${if_ul}    ${if_dl}    ${protocol}    ${spark_log_name}    ${ue_type}=samsung
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Spark Stop UE Log    ue_index=${ue_index}    log_name=${TS_CASE_LOG_PATH}/${spark_log_name}_UE${ue_index}.xml
    END
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}
        ...    direction=ul    protocol=${protocol}    iperf_port=${ul_power_port_list}[${ue_index}]
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}
        ...    direction=dl    protocol=${protocol}    iperf_port=${dl_power_port_list}[${ue_index}]
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END


Get Each UE TP From Spark
    [Arguments]  ${ue_num}    ${spark_log_name}    ${list_length}    ${row_list}=${case_row_list}
    @{dl_tput_info}    Create list
    @{ul_tput_info}    Create list
    @{dl_bler_info}    Create list
    @{ul_bler_info}    Create list
    @{total_result_list}    Create List
    FOR    ${ue_index}    IN RANGE  ${ue_num}
        ${result_dic}    Get_UE_TP_Bler_From_spark_log    file_path=${TS_CASE_LOG_PATH}/${spark_log_name}_UE${ue_index}.csv
        ...    list_length=${list_length}    row_list=${row_list}
        ${DL_bler}    get from dictionary  ${result_dic}    DL_bler
        ${UL_bler}    get from dictionary  ${result_dic}    UL_bler
        ${DL_tp}    get from dictionary  ${result_dic}    DL_tp
        ${UL_tp}    get from dictionary  ${result_dic}    UL_tp
        APPEND TO LIST   ${dl_tput_info}    ${DL_tp}[0]
        APPEND TO LIST   ${ul_tput_info}    ${UL_tp}[0]
        APPEND TO LIST   ${dl_bler_info}    ${DL_bler}[0]
        APPEND TO LIST   ${ul_bler_info}    ${UL_bler}[0]
        append to list   ${total_result_list}   ${result_dic}
    END
    [Return]    ${ul_tput_info}    ${dl_tput_info}   ${ul_bler_info}    ${dl_bler_info}    ${total_result_list}


Send Data to RP
    [Arguments]   ${total_result_list}    ${syslog_dl_list}    ${syslog_ul_list}    ${if_ul}    ${if_dl}    ${protocol}
    ${total_tp_dict}    Caculate_total_tp    total_message_dict=${total_result_list}
    Log to console    Unused variable protocol:${protocol}
    ${ul_tp_list}    get from dictionary    ${total_tp_dict}    ul
    ${dl_tp_list}    get from dictionary    ${total_tp_dict}    dl
    ${ul_avg}     set variable if    ${ul_tp_list[0]}>${syslog_ul_list[0]}     ${ul_tp_list[0]}    ${syslog_ul_list[0]}
    ${ul_max}     set variable if    ${ul_tp_list[1]}>${syslog_ul_list[1]}     ${ul_tp_list[1]}    ${syslog_ul_list[1]}
    ${ul_min}     set variable if    ${ul_tp_list[2]}>${syslog_ul_list[2]}     ${ul_tp_list[2]}    ${syslog_ul_list[2]}
    ${dl_avg}    set variable if    ${dl_tp_list[0]}>${syslog_dl_list[0]}     ${dl_tp_list[0]}    ${syslog_dl_list[0]}
    ${dl_max}    set variable if    ${dl_tp_list[1]}>${syslog_dl_list[1]}     ${dl_tp_list[1]}    ${syslog_dl_list[1]}
    ${dl_min}    set variable if    ${dl_tp_list[2]}>${syslog_dl_list[2]}     ${dl_tp_list[2]}    ${syslog_dl_list[2]}
    run keyword if    ${if_ul}    Run Keyword And Ignore Error    KpiReporter.add_ul_throughput_into_report_list    exp_ul=${exp_ul}Mbits/sec
    ...    ul_avg=${ul_avg}Mbits/sec    ul_max=${ul_max}Mbits/sec    ul_min=${ul_min}Mbits/sec
    run keyword if    ${if_dl}    Run Keyword And Ignore Error    KpiReporter.add_dl_throughput_into_report_list    exp_dl=${exp_dl}Mbits/sec
    ...    dl_avg=${dl_avg}Mbits/sec    dl_max=${dl_max}Mbits/sec    dl_min=${dl_min}Mbits/sec
    [Return]  ${total_tp_dict}

Commmon Case Teardown
    [Arguments]  ${total_result_list}    ${syslog_dl_list}    ${syslog_ul_list}    ${if_ul}    ${if_dl}    ${protocol}    ${flag}=${True}
    ${total_tp_dict}    Send Data to RP    total_result_list=${total_result_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    ...    syslog_dl_list=${syslog_dl_list}    syslog_ul_list=${syslog_ul_list}
    run keyword if    ${flag}    Run Keyword And Ignore Error     KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}
    ...    logs_dir=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error     Clear All DU Connection From UTE    connect_ip=${gNB_ip}
    Check UL And DL Tp    total_tp_dict=${total_tp_dict}    syslog_dl_list=${syslog_dl_list}    syslog_ul_list=${syslog_ul_list}
    ...    if_ul=${if_ul}    if_dl=${if_dl}
    sleep    10min
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
    [Return]  ${total_tp_dict}

Check UL And DL Tp
    [Arguments]  ${total_tp_dict}    ${syslog_dl_list}    ${syslog_ul_list}    ${if_ul}    ${if_dl}
    ${dl_all_tp}    Get From Dictionary    ${total_tp_dict}    dl
    ${dl_avg_tp}    set variable if     ${dl_all_tp}[0]>${syslog_dl_list[0]}     ${dl_all_tp}[0]    ${syslog_dl_list[0]}
    ${ul_all_tp}    Get From Dictionary    ${total_tp_dict}    ul
    ${ul_avg_tp}    set variable if     ${ul_all_tp}[0]>${syslog_ul_list[0]}     ${ul_all_tp}[0]    ${syslog_ul_list[0]}
    ${ul_result}    Check_Avg_TP    act_value=${ul_avg_tp}    exp_value=${exp_ul}    deviation=${deviation}
    ${dl_result}    Check_Avg_TP    act_value=${dl_avg_tp}    exp_value=${exp_dl}    deviation=${deviation}
    run keyword if    ${if_ul}    Run Keyword And Continue On Failure    should be true    ${ul_result}
    run keyword if    ${if_dl}    Run Keyword And Continue On Failure    should be true    ${dl_result}

Clear All DU Connection From UTE
    [Arguments]    ${connect_ip}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.send_command    command=ps -ef | grep ${connect_ip} | awk '{print $2}' | xargs kill -9    connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

Suite Case Teardown
    [Arguments]  ${ue_num}=${3}
    FOR    ${ue_index}    IN RANGE    ${ue_num}
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END
    Run Keyword And Ignore error    Clear All Log Frome Control PC
    robot_common_operations.Common Suite Teardown

Clear All Log Frome Control PC
    [Arguments]    ${connection}=Control_pc
    csn.Connect to     hostname=${control_pc}   username=${control_pc_name}    password=${control_pc_pass}  alias=${connection}
    csn.send_command    command=cd '/cygdrive/c/tmp/uelog/AUTO';rm -rf *    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/Spark1.1.1998.9/Data/Tmp';rm -rf *    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/Spark1.1.1998.2/Data/Tmp';rm -rf *    connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

Case Teardown
    [Arguments]    ${ue_num}
    detach multi power ue    ue_num=${ue_num}
    Save Snapshot
