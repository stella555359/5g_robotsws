*** Settings ***
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.gnb.oam.coam.admin    WITH NAME    admin
Library           ute_wtssim
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           Collections
Library           DateTime
Library           OperatingSystem
Resource          taf/rfrl/common_resources/robot/coam.robot

*** Variables ***
${ABIL_MASTER}    192.168.253.20
${AP_HOST}        ${tl.ues[0].airphone_cloud.oam_ssh_connection_details.addr}
${AP_USER}        ${tl.ues[0].airphone_cloud.oam_ssh_connection_details.username}
${AP_PWD}         ${tl.ues[0].airphone_cloud.oam_ssh_connection_details.password}
${DL_PORT}        7070
${DU_HOST}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_USER}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_PWD}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${HW_STATUS_CHECK}    export PYTHONPATH\=/opt/hwmt/python\; python /opt/hwmt/python/hwapi/AdetS\.py \-s
${LTE_HOST}       ${tl.core.default_ssh_connection_details.addr}
${LTE_USER}       ${tl.core.default_ssh_connection_details.username}
${LTE_PWD}        ${tl.core.default_ssh_connection_details.password}
${PDU_SESSION_UP}    ue_pdu_session_setup pdu=1 ue=${UE_ID} nwslice=1 gw=1
${PDU_UP_SUCCESS}    Initial Context Setup Successful
${PING_MATCH}     from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
${SIB_UPDATED}    SystemInformationBlockType1-NR updated
${UE_REGISTERED}    UE now in NG RM Registered state
${UL_PORT}        7071
${WEBUI_HOST}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${EPCSIM_CFG}     ${tl.core.cfg_filename}
${UE_ID}          1
${GNB_ID}         2
${CELL_ID}        2
${BEARER_ID}      2
${iperf_egrep}    egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'

*** Keywords ***
Active LTE Emu Cfg Until Setup PDU Session Success
    ssh.Connect to    hostname=${LTE_HOST}    username=${LTE_USER}    password=${LTE_PWD}    alias=WTS
	${execute_info}    ssh.execute    cd ${tl.core.dir_path}; sudo ./edaemon --port ${tl.core.edaemon_port}    connection=WTS
	sleep    1s
	FOR    ${var}    IN RANGE    5
	     ${execute_info}    ssh.execute    cd ${tl.core.dir_path}; ./egate --port ${tl.core.egate_port}    connection=WTS
	     sleep    1s
	     ${ps_egate_info}    ssh.execute    ps -ef | grep egate | grep -v grep    connection=WTS
	     ${run_result}    ${error}    run keyword and ignore error    should contain    ${ps_egate_info}    egate
	     exit for loop if    '${run_result}'=='PASS'
	END
	should contain    ${run_result}    PASS
    setup_egate    egate_port=20000    host_ip=${LTE_HOST}
	Execute Egate Command    cmd=cfg file\=${EPCSIM_CFG}    pass_regexp=${SIB_UPDATED}    timeout=450
	sleep    10sec
	Execute Egate Command    cmd=ue_register id\=${UE_ID}    pass_regexp=${UE_REGISTERED}    timeout=150
	sleep    10sec
	Execute Egate Command    cmd=${PDU_SESSION_UP}    pass_regexp=${PDU_UP_SUCCESS}    timeout=150
	[Teardown]    Disconnect WTS And Egate Session

Check gNB State is Onair
    Login Page Via WebUI
    ${bts_state}    selenium_coam.Get Bts Status
    Should Be Equal As Strings    ${bts_state}    On air    ignore_case=${TRUE}
    [Teardown]    selenium_coam.logout

Check gNB F1 State is Successfully
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    FOR    ${var}    IN RANGE    40
         ssh.send_command    rm startup_cp_rt.log    connection=gNB_ASIK
         ssh.send_command    bget 0\:1 /tmp/node_CPRT00/tmp/startup_cp_rt.log /tmp/    connection=gNB_ASIK
         ${match_f1_info}    ssh.execute    command=cat /tmp/startup_cp_rt.log | grep "F1 setup"    connection=gNB_ASIK
         ${matchh_result}    ${error}    run keyword and ignore error    should contain    ${match_f1_info}    successfully
         exit for loop if    '${matchh_result}'=='PASS'
         sleep    10sec
    END
    should contain    ${match_f1_info}    successfully
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_ASIK

Check gNB HW Status is up
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    : FOR    ${var}    IN RANGE    45
	\    ${result_list}    create list
    \    ${match_HW_info}    ssh.execute    ${HW_STATUS_CHECK}    connection=gNB_ASIK
    \    ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM1\_FCT\\s+([a-z]+)
    \    ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
    \    Append To List    ${result_list}    ${contain_result}
    \    ${match_result}    ${match_info}    run keyword and ignore error    should match regexp    ${match_HW_info}    FSM1\_FSP1\\s+([a-z]+)
    \    ${contain_result}    ${error}    run keyword and ignore error    should contain    ${match_info[-1]}    ready
    \    Append To List    ${result_list}    ${contain_result}
    \    ${HW_state_result}    ${error}    run keyword and ignore error    should not contain    ${result_list}    FAIL
    \    exit for loop if    '${HW_state_result}'=='PASS'
    \    sleep    10
    should not contain    ${result_list}    FAIL
	[Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_ASIK

Check Traffic in gNB ABIL Master
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    ssh.connect to    hostname=${ABIL_MASTER}    username=${DU_USER}    password=${DU_PWD}    proxy=gNB_ASIK    alias=ABIL_Matser
    ${date_info}    ssh.execute    date    connection=ABIL_Matser
    ${time_info}    should match regexp    ${date_info}    [0-9,\\:]{8}
    sleep    10s
    ${journalctl_info}    ssh.execute    journalctl --since ${time_info} | grep -i TBS    connection=ABIL_Matser
    ${match_result}    ${DL_data_info}    should match regexp    ${journalctl_info}    DataPdu\:\\s+\\S+\\|(\\d+)\]
    ${match_result}    ${UL_data_info}    should match regexp    ${journalctl_info}    UL\:\\s+(\\d+)\\s+Bytes\\s+received
    ${compare_result}    run keyword if    ${DL_data_info}>300000 and ${UL_data_info}>300000    set variable    PASS    ELSE    set variable
    ...    FAIL
    should contain    ${compare_result}    PASS
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=ABIL_Master

Connect to WTS
    ssh.connect to    hostname=${LTE_HOST}    username=${LTE_USER}    password=${LTE_PWD}    alias=WTS

Disconnect WTS And Egate Session
    Run Keyword And Ignore Error    teardown_egate
	Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Login Page Via WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Reboot gNB Via WebUI
    Login Page Via WebUI
    selenium_coam.reset_site
    [Teardown]    selenium_coam.logout

Reboot gNB Via Ssh
    ssh.connect to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=gNB_ASIK
    ssh.send_command    reboot    connection=gNB_ASIK
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_ASIK

Reboot WTS Via Ssh
    Connect to WTS
    ssh.send_command    sudo reboot    connection=WTS
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Reboot AP Via Ssh
    ssh.connect to    hostname=${AP_HOST}    username=${AP_USER}    password=${AP_PWD}    alias=Airphone
    ssh.send_command    reboot    connection=Airphone
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=Airphone

Reboot Testline And Make Sure HW is up
    Reboot gNB Via Ssh
	Reboot AP Via Ssh
	Reboot WTS Via Ssh
	sleep    150sec
	: FOR    ${var}    IN RANGE    40
    \    ${ping_info}    run    ping -c 5 ${DU_HOST}
    \    ${run_result}    ${error}    run keyword and ignore error    should match regexp    ${ping_info}    ${PING_MATCH}
    \    exit for loop if    '${run_result}'=='PASS'
    \    sleep    10
    Check gNB HW Status is up

Save Snapshot
    [Arguments]    ${alias}=cOAM    ${timeout}=15 min
    Create cOAM session with alias
	${sw_id}=              Get Software Version      alias=cOAM
	${snapshot_path}=     set variable  ${OUTPUT_DIR}/Snapshot_${sw_id}.zip
	admin.get_snapshot     target_file_name=${snapshot_path}    timeout=${timeout}    connection=cOAM
    [Teardown]    Teardown cOAM session

Sctp Connect Setting in WTS And Airphone
    ssh.connect to    hostname=${AP_HOST}    username=${AP_USER}    password=${AP_PWD}    alias=Airphone
    ssh.execute    command=sysctl -w net.sctp.sack_timeout=10;sysctl -w net.sctp.rto_min=200    connection=Airphone
	sleep    1s
	ssh.execute    command=sysctl -w sysctl -w net.sctp.rto_initial=200;sysctl -w net.sctp.rto_max=800    connection=Airphone
	Run Keyword And Ignore Error    ssh.Disconnect    connection=Airphone
	Connect to WTS
    ${info_tmp}    ssh.execute    command=sudo sysctl -w net.sctp.sack_timeout=10;sudo sysctl -w net.sctp.rto_min=200    connection=WTS
	sleep    1s
	${info_tmp}    ssh.execute    command=sudo sysctl -w sysctl -w net.sctp.rto_initial=200;sudo sysctl -w net.sctp.rto_max=800    connection=WTS
	Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Stop Traffic in WTS on SA
    Connect to WTS
    ssh.send_command    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
    ssh.send_command    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9    connection=WTS
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Start DL Traffic within 30sec on SA
    Connect to WTS
    ${cfg_info}    ssh.execute    command=cat ${tl.core.dir_path}/${tl.core.cfg_filename} \| grep \"UPF_ADDR\=\"    connection=WTS
    ${upf_match_list}    ${upf_match_info}    should match regexp    ${cfg_info}    ([0-9,\.]+)\.\\d
    ssh.send_command    nohup iperf -s -u -p ${DL_PORT} -i 1 -B 192.168.6.121 > \ /tmp/iperf_DL.txt    connection=WTS
    ssh.send_command    nohup iperf -c ${upf_match_info}.2 -u -p ${DL_PORT} -l 1400 -b 5M -i 1 -t 30 2>&1 &    connection=WTS
    BuiltIn.Log    Running DL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Start UL Traffic within 30sec on SA
    Connect to WTS
    ${cfg_info}    ssh.execute    command=cat ${tl.core.dir_path}/${tl.core.cfg_filename} \| grep \"ue_nat_ip\=\"    connection=WTS
    ${upf_match_list}    ${upf_match_info}    should match regexp    ${cfg_info}    ue\_nat\_ip\=([0-9,\.]+)\\s+
    ssh.send_command    nohup iperf -s -u -p ${UL_PORT} -i 1 -B 192.168.6.121 > /tmp/iperf_UL.txt    connection=WTS
    ssh.send_command    nohup iperf -c ${upf_match_info} -u -p ${UL_PORT} -l 1400 -b 2M -i 1 -t 30 2>&1 &    connection=WTS
    BuiltIn.Log    Running UL Traffic for 10sec    console=yes
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

Check Traffic Throughput on iperf Server
    [Arguments]    ${dir}    ${throughput}
    Connect to WTS
    ssh.download_file    /tmp/iperf_${dir}.txt    ${OUTPUT DIR}/iperf_${dir}.txt    connection=WTS
    OperatingSystem.Run    ${iperf_egrep} ${OUTPUT DIR}/iperf_${dir}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${output}    OperatingSystem.Run    cat ${OUTPUT DIR}/iperf_${dir}_parsed.txt
    ${add_tmp}    Set Variable    0
    ${packet_number}    Set Variable    0
    ${list}    Split String    ${output}    \n
    FOR    ${var}    IN    @{list}
         ${add_tmp}    Evaluate    ${var}+${add_tmp}
         ${packet_number}    Evaluate    ${packet_number}+1
    END
    ${avg}    Evaluate    ${add_tmp}/${packet_number}
    ${throughput_delta}    Evaluate    abs(${throughput}-${avg})
    ${throughput_threshold}    Evaluate    ${throughput}*0.1
    Should Be True    ${throughput_delta}<${throughput_threshold}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=WTS

