#*** Settings ***
#Documentation
#...   author: zhangqionghua
#...   contact: qionghua.zhang@nokia-sbell.com
#...   squad group: SG_03
#...    Feature CNI-45793 about 5GC000886 in 5G20A program
#
#Library    OperatingSystem
#Library    Collections
#Library    String
#Library    BuiltIn
#Library    Telnet
#Library    ../../5GC000738/Resources/get_pm_counter.py
#Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.hw.rf_attenuator    WITH NAME    att
#Library    taf.config.testline    WITH NAME    testline
#Library    taf.epcsim    WITH NAME    epc
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
#Resource   taf/rfrl/common_resources/robot/gnb_classical.robot
##Library    taf.analyzer.pcap    WITH NAME    cap
#Library    taf.analyzer.pcap     WITH NAME    cap
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
#Library    taf.rfrl.common_resources.python.SWConfig
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
#Library    licence_keeper.licence_keeper     WITH NAME    LK
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
#Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#
#*** Variables ***
#${WEBUI_COAM2}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
#${TS_LOG_PATH_BASE}      /opt/workspace/CIT/Master/Case_Logs
#${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
#${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
#${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${SN}    ${tl.ues[0].serial_number}
#${gnb_path}    /tmp/
#${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
#${tl_scf_dir_path}    /home/ute/TA/SCF/
#${tl_scf_filename}    TL240_gnb1_scf.xml
#${tl_scf2_filename}    TL240_gnb2_scf.xml
#${TESTLINE_NAME}    7_5_CLOUD402T0${tl.enbs[0].instance_id}
#${enbx2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-2
#${enbx2_para}    administrativeState
#${enb_path}    /user/toor4nsn
#${epcsim_ip}    ${tl.core.default_ssh_connection_details.addr}
#${realepc_ip}    ${tl.core.mme_ip}
#${PM_counter_UL}    M55323C03007
#${PM_counter_DL}    M55323C01007
#${e1ap}    e1ap_15_3_0_1903_n01
#
###Attenuator parameter before taf ready
#${att_ipaddr}     ${tl.attenuator[0].ip_addr}    #FOR TL240 PA ip other pa plz set in case level
#${att_port_1}    ${tl.attenuator[0].attenuator_ports[1]}
#${att_port_2}    ${tl.attenuator[0].attenuator_ports[2]}
#${att_port_3}    ${tl.attenuator[0].attenuator_ports[3]}
#${att_port_4}    ${tl.attenuator[0].attenuator_ports[4]}
#${att_api_port}    ${tl.attenuator[0].port}
#${vendor}    HBTE
#
#${value_1}    ${127}
#${value_2}    ${0}
#${value_3}    ${127}
#${value_4}    ${127}
#${max_attenuation_value}    ${127}
#
#${ul_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
#${dl_port}    ${tl.ues[0].iperf_details.port}
#
#*** Keywords ***
#Perform full commission for COAM gnb2
#    coam.connect_to    bts_host=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#    ...    username=${tl.gnbs[1].cu.oam_http_connection_details.username}
#    ...    password=${tl.gnbs[1].cu.oam_http_connection_details.password}
#    ...    bts_port=${443}    name=GNB2_OAM
#    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf2_filename}    connection=GNB2_OAM
#    coam.teardown    connection=GNB2_OAM
#
#Check the gnb2 cell status onair
#    coam.connect_to    bts_host=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#    ...    username=${tl.gnbs[1].cu.oam_http_connection_details.username}
#    ...    password=${tl.gnbs[1].cu.oam_http_connection_details.password}
#    ...    bts_port=${443}    name=GNB2_OAM
#    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air    connection=GNB2_OAM
#    coam.teardown    connection=GNB2_OAM
#
#Prepare the classical COAM BTS cell onair for gnb1
#    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair for gnb1
#    set suite variable    ${cell_status}
#
#Prepare with COAM classical BTS cell onair for gnb1
#    Perform full commission for COAM gnb for gnb1
#    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
#    Check gnb COAM classical start normally
#    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
#    Check the gnb cell status onair
#
#Perform full commission for COAM gnb for gnb1
#    Connect to gnb coam via ssl
#    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_filename}    timeout=600
#    COAM Teardown gnb connections
#
#adjust the HBTE attenuation value
#    [Documentation]    Auther:cris.cai@nokia-sbell.com
#    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
#    ...                for value plz set in your case level
#    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    att.set_attenuation     port=${att_port_1}    value=${value_1}
#    att.set_attenuation     port=${att_port_2}    value=${value_2}
#    att.set_attenuation     port=${att_port_3}    value=${value_3}
#    att.set_attenuation     port=${att_port_4}    value=${value_4}
#    ${value_port_1}    att.read_attenuation    port=${att_port_1}
#    should be equal    ${value_port_1[0]}    ${value_1}
#    ${value_port_2}    att.read_attenuation    port=${att_port_2}
#    should be equal    ${value_port_2[0]}    ${value_2}
#    ${value_port_3}    att.read_attenuation    port=${att_port_3}
#    should be equal    ${value_port_3[0]}    ${value_3}
#    ${value_port_4}    att.read_attenuation    port=${att_port_4}
#    should be equal    ${value_port_4[0]}    ${value_4}
#
#
#Make 5GUE unnormal release for adjust the HBTE
#    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    att.set_attenuation     port=${att_port_1}    value=${value_1}
#    att.set_attenuation     port=${att_port_2}    value=${value_2}
#    att.set_attenuation     port=${att_port_3}    value=${value_3}
#    att.set_attenuation     port=${att_port_4}    value=${value_4}
#    ${value_port_1}    att.read_attenuation    port=${att_port_1}
#    should be equal    ${value_port_1[0]}    ${value_1}
#    ${value_port_2}    att.read_attenuation    port=${att_port_2}
#    should be equal    ${value_port_2[0]}    ${value_1}
#    ${value_port_3}    att.read_attenuation    port=${att_port_3}
#    should be equal    ${value_port_3[0]}    ${value_3}
#    ${value_port_4}    att.read_attenuation    port=${att_port_4}
#    should be equal    ${value_port_4[0]}    ${value_4}
#
#
#Adjust the atten with UE inter HO
#    [Arguments]    ${status}=pass
#    ${5Grachold}    Verify 5GRACH success times on gnb side    abil=asp1a    gnb_index=1
#    Set test variable    ${5Grachold}
#    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    att.set_attenuation     port=${att_port_2}    value=${value_1}
#    att.set_attenuation     port=${att_port_4}    value=${value_2}
#    ${value_port_2}    att.read_attenuation    port=${att_port_2}
#    should be equal    ${value_port_2[0]}    ${value_1}
#    ${value_port_4}    att.read_attenuation    port=${att_port_4}
#    should be equal    ${value_port_4[0]}    ${value_2}
#
#
#Change the HBTE attenuation value for port2
#    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#    att.set_attenuation     port=${att_port_2}    value=${value_1}
#    ${value_port_2}    att.read_attenuation    port=${att_port_2}
#    should be equal    ${value_port_2[0]}    ${value_1}
#
#
#make DL traffic and check
#    Connect to control pc via cygwin
#    Start DL traffic and check the TP on EPC with huawei UE    Home_button=82    open_iperf_location=500 2050    traffic=20.00M
#    Stop DL traffic and check the TP on EPC
#    check DL traffic
#
#make UL traffic and check
#    Connect to control pc via cygwin
#    Start UL traffic and check the TP on Commercial with first UE    Home_button=82    open_iperf_location=500 2050
#    ...    EPC_IP=${tl.core.default_ssh_connection_details.addr}    UL_port=${tl.ues[0].iperf_details.port}
#    ...    iperf_button=100 280
#    check UL traffic
#
#check DL traffic
#    [Arguments]    ${alias}=ABIL Master
#    Connect to Capacity Unit Master    alias=${alias}
#    ${dl_tp_l2lo}=    Get_And_Calculate_DL_throughput    alias=${alias}    duration=50    location=${16}
#    should be true    ${dl_tp_l2lo} > ${dl_expect}
#    ssh.disconnect      connection=${alias}
#
#check UL traffic
#    [Arguments]    ${alias}=ABIL Master
#    Connect to Capacity Unit Master    alias=${alias}
#    ${ul_tp_l2lo} =    Get_And_Calculate_UL_throughput    alias=${alias}    duration=30
#    should be true    ${ul_tp_l2lo} > ${ul_expect}
#    ssh.disconnect      connection=${alias}
#
#Check Huawei attach successfully
#    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=1
#    ${5Grach_ed}    Verify 5GRACH success times on gnb side    abil=${abil}    gnb_index=${gnb_index}
#    Connect to control pc via cygwin
#    Commercial UE click AIRPLANE once    Home_button=82    airplane=960 290    close_task=538 1979
##    wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command
#    sleep    120s
#    ${5Grach_ing}    Verify 5GRACH success times on gnb side    abil=${abil}    gnb_index=${gnb_index}
#    run keyword if     '${5Gstatus}'=='PASS'    should be true    ${5Grach_ing}>${5Grach_ed}
#    run keyword if     '${5Gstatus}'=='PASS'    Log to console    INFO:5G UE setup successfully.
#    run keyword if     '${5Gstatus}'=='FAIL'    should be true    ${5Grach_ing}==${5Grach_ed}
#    run keyword if     '${5Gstatus}'=='FAIL'    Log to console    INFO:5G UE setup unsuccessfully.
#    sleep    3s
#
#Verify 5GRACH success times on gnb side
#    [Arguments]    ${abil}=asp1a    ${gnb_index}=1
#    wait until keyword succeeds    1 min    10 sec    Connect to BB${gnb_index} master     alias=asik
#    wait until keyword succeeds    1 min    10 sec    Connect to ${abil}    alias=${abil}    proxy=asik
#    ${output} =    csn.execute    command=journalctl -b | grep "flow control starts" |grep -v grep
#    ...                           connection=${abil}
#    run keyword and ignore error    csn.disconnect    connection=${abil}
#    run keyword and ignore error    csn.disconnect    connection=asik
#    @{list}    split string    ${output}    \n
#    ${len} =    Get Length    ${list}
#    [return]    ${len}
#
#Start DL traffic and check the TP on EPC with huawei UE
#    [Arguments]    ${Home_button}=3    ${swipe}=500 2050 500 800    ${open_iperf_location}=480 860
#    ...    ${DL_port}=${tl.ues[0].iperf_details.port}    ${time}=10    ${interval}=1    ${traffic}=10.00M
#    ...    ${buffer_size}=1024B    ${iperf_button}=88 288
##    Connect to control pc via cygwin
#    sleep   2s
#    #####Press the Home button to open the screen#####
#    Run Keyword And Ignore Error    csn.send_command    command=adb shell input keyevent ${Home_button}    connection=cygwin
#    sleep   3s
#    #####Swipe up to unlock the phone#####
#    Run Keyword And Ignore Error    csn.send_command    command=adb shell input swipe ${swipe}    connection=cygwin
#    sleep   3s
#    csn.send_command    command=adb shell pm clear com.magicandroidapps.iperf    connection=cygwin
#    csn.send_command    command=adb shell am start -n com.magicandroidapps.iperf/com.magicandroidapps.iperf.iperf    connection=cygwin
#    csn.send_command    command=adb shell input tap ${open_iperf_location}    connection=cygwin
#    sleep    0.5
#    csn.send_command    command=adb shell input text iperf    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -s    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -u    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -i    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text ${interval}    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -p    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text ${DL_port}    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -P    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text 1    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -f    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text m    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text -l    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input keyevent 62    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input text ${buffer_size}    connection=cygwin
#    sleep   0.5s
#    csn.send_command    command=adb shell input tap ${iperf_button}    connection=cygwin
#    Connect to control pc via cygwin
#    Get Commercial UE IP with huawei UE
#    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
#    sleep   2s
#    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
#    csn.send_command
#    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
#    ...    connection=EPCAPP
#
#Get Commercial UE IP with huawei UE
#    [Arguments]    ${command}=adb shell ifconfig |grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1 | tail -1 | head -1
##    Connect to control pc via cygwin
#    sleep   5s
#    csn.send_command    command=${command}
#    ...    connection=cygwin
#    ${UE_IP}=    csn.Read Output    connection=cygwin
#    ${UE_IP}=    Strip String    ${UE_IP}
#    Set Suite Variable    ${UE_IP}    ${UE_IP}
#    csn.disconnect      connection=cygwin
#
#
#Commission for gnb2 for recover
#    Perform full commission for COAM gnb    scf=${tl_scf_dir_path}${tl_scf2_filename}
#    ...                                     gnb_ip=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#
#
#
#
#
