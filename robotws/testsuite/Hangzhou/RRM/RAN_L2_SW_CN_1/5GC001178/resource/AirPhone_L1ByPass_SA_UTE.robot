*** Settings ***
Library           taf.transport.ssh    WITH NAME    ssh
Library           BuiltIn
Library           String
Library           ute_wtssim
Library           ta5g_iperf_traffic
Library           ute_admin
Library           Process
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           OperatingSystem
Resource          taf/rfrl/common_resources/robot/coam.robot


*** Variables ***
&{AP}                   hostname=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
&{GNB}                  hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
${WTS_DIR}              /opt/iphy/latest
${WTS_CFG}              basic_l1bypass_sa_call_tdd_cmwv.cfg
${WTS_AP_XML}           AirPhoneConfig_l1bypass_tdd_sa_cmwv.xml
${UL_PORT}        7071
${DL_PORT}        7070
${WEBUI_HOST}     192.168.255.1
${WEBUI_USER}     Nemuadmin
${WEBUI_PWD}      nemuuser
${UE_ID}          1
${BEARER_ID}      2
${iperf_egrep}    egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${SIB_UPDATED}    SystemInformationBlockType1-NR updated

*** Keywords ***
Make Sure BTS Site Is Ready
    Log To Console    Make sure BTS site is ready at most 5 times...
    FOR    ${index}    IN RANGE    ${5}
         Log To Console    ===============Reboot Time: ${index}==============
         Reboot Testline Via Webui
         ${res}    Run Keyword And Return Status    Wait Coam Site to be Ready
         Exit For Loop If    '${res}'=='True'
         Sleep    5s

    END
Reboot Testline Via Webui
    Log To Console    Reboot Testline Via Webui...
    Reset gNB WebUI
    Sleep    5s

Reset gNB WebUI
    Login Page Via WebUI
    selenium_coam.Refresh Page
    selenium_coam.reset_site
    [Teardown]    selenium_coam.logout

Reboot Testline Via SSH
    Log To Console    Reboot testline via ssh...
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP.password} ssh ${AP.username}@${AP.hostname} 'reboot'
    Sleep    2s
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.hostname} 'reboot'

Wait Coam Site to be Ready
    Log To Console    verify bts site is ready...
    Wait Until Keyword Succeeds    15min    30s    Verify BTS Is Configured
    Wait Until Keyword Succeeds    10min    30s    Verify Radio Is Online

Verify BTS Is Configured
    Log To Console    verify BTS is configured...
    Run Keyword And Ignore Error    ute_admin.Setup Admin
    ${bts_state}    ute_admin.Get Mrbts State
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    ute_admin.Teardown Admin

Verify Radio Is Online
    Log To Console    verify Radio is online...
    Run Keyword And Ignore Error    ute_admin.Setup Admin
    ${bts_hw_info}    ute_admin.Get Bts Info
    ${radio_state}    Set Variable
    ...    ${bts_hw_info['radioModules']['rmod'][0]['status']['availabilityStatus']}
    Log To Console    [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    Online    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    ute_admin.Teardown Admin

Check gNB F1 State is Successfully
    Log To Console    Check gNB F1 State is Successfully...
    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
    FOR    ${var}    IN RANGE    40
         ssh.send_command    bget 0\:1 /tmp/node_CPRT00/tmp/startup_cp_rt.log /tmp/
         ${match_f1_info}    ssh.execute    command=cat /tmp/startup_cp_rt.log | grep "F1 setup"
         ${matchh_result}    ${error}    run keyword and ignore error    should contain    ${match_f1_info}    successfully
         exit for loop if    '${matchh_result}'=='PASS'
         sleep    10sec
    END
    should contain    ${match_f1_info}    successfully
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect

Configure VM Interfaces
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3

UTE Sctp Connect Setting in WTS And Airphone
    Log To Console    modify sctp timeout...
    OperatingSystem.Run    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_min=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_initial=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_max=800
    SSH.Connect To    ${AP.hostname}    ${AP.username}    ${AP.password}
    ${command}    Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...    sysctl -w net.sctp.rto_min=200 &&
    ...    sysctl -w net.sctp.rto_initial=200 &&
    ...    sysctl -w net.sctp.rto_max=800
    SSH.Execute    ${command}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Start UTE WTS
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error     Clean edaemon and egate
    OperatingSystem.Remove File    ${WTS_DIR}/AirPhoneConfig*.xml
    OperatingSystem.Remove File    ${WTS_DIR}/basic*.cfg
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    OperatingSystem.Run    cp /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources/l1b_tdd_sa_cmwv/9.1800/${WTS_CFG} ${WTS_DIR}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
    OperatingSystem.Run    cp /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources/l1b_tdd_sa_cmwv/9.1800/${WTS_AP_XML} ${WTS_DIR}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}

clean edaemon and egate
    Log To Console    clean edaemon and egate...
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate

UE SIB Decoding
    Log To Console    UE SIB Decoding...
    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=${SIB_UPDATED}    timeout=600
	sleep    10sec

UE Register
    Log To Console    UE attach
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data    ue_register id\=${UE_ID}
    ...               pass_regexp=REGISTRATION COMPLETE    timeout=3minutes
    ${output1}        Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE
    ...               partial_match=${TRUE}
    Log to Console    \n${output1}

    Should Contain    ${output}    Initial UE Message Success    ignore_case=True
    ${output}         Get Lines Matching Regexp    ${output}    Initial UE Message Success
    ...               partial_match=${TRUE}
    Log to Console    ${output}

    ${command}        Set Variable    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data    ${command}
    ...               pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}         Get Lines Matching Regexp    ${output}    Initial Context Setup Successful
    ...               partial_match=${TRUE}
    Log to Console    ${output}

UE Deregister
    Log To Console    UE Deregister...
    ${command}        Set Variable    ue_deregister id=1 ue_deregister_type=switch_off
    ${output}         Execute Egate Command and Wait for Data    ${command}
    ...               pass_regexp=UE Context Release Complete    timeout=3minutes
    ${output1}        Get Lines Matching Regexp    ${output}    UE Context Release Complete
    ...               partial_match=${TRUE}
    Log to Console    \n${output1}

Delete PM BTS counter file
    Log To Console    Delete PM BTS counter file on SA
    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
    ssh.execute    rm /tmp/PM.BTS*
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect

Start Traffic
    Log To Console    Start Traffic within 200sec on SA
    ta5g_iperf_traffic.Start Downlink Traffic    ue_ip=1.2.4.2    throughput=5m    duration=200s



UTE Start Traffic within 10sec on SA
    Send Downlink Traffic Data
    Send Uplink Traffic Data

Execute Iperf in Linux
    [Arguments]    ${args}=${EMPTY}    ${pipeArgs}=${EMPTY}
    ${result}    Run Keyword    Process.Start Process    iperf ${args} ${pipeArgs}    shell=${TRUE}
    [Return]    ${result}

Send Downlink Traffic Data
    Execute Iperf in Linux             args=-c 1.2.4.2 -u -p ${DL_PORT} -l 1300 -b 5M -i 1 -t 10
    Execute Iperf in Linux             args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_DL.txt
    Log to Console                     Running DL Traffic for 10s
    Sleep                              30s

Send Uplink Traffic Data
    [Documentation]    Run UL Traffic and Verify Throughput
    Execute Iperf in Linux             args=-c 72.23.0.1 -u -p ${UL_PORT} -l 1300 -b 2M -i 1 -t 10
    Execute Iperf in Linux             args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_UL.txt
    Log to console                     Running UL Traffic for 10s
    Sleep                              30s

Check Traffic Throughput on iperf Server
    [Arguments]    ${dir}    ${throughput}
    OperatingSystem.Run    ${iperf_egrep} /tmp/iperf_${dir}.txt | awk '{print $(1)}' > ${OUTPUT DIR}/iperf_${dir}_parsed.txt
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

Stop UL Traffic in WTS on SA
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9

Stop DL Traffic in WTS on SA
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9

Get the bts counter ${counter_id} as 0
    ssh.connect to    ${GNB.hostname}    ${GNB.username}    ${GNB.password}
    ssh.execute    gunzip /tmp/PM.BTS*.gz
    ssh.execute    rm /tmp/PM.BTS*.xml
    ${counter_info}    ssh.execute    cat /tmp/PM.BTS* | grep ${counter_id}
    ${regexp_matche_list}    get regexp matches    ${counter_info}    <${counter_id}>(\\d+)</${counter_id}>    1
    BuiltIn.Log    ${regexp_matche_list}
    ${value}    get from list    ${regexp_matche_list}    0
    should be true    ${value}==0
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect

Login Page Via WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Check gNB State is Onair
    Login Page Via WebUI
    ${bts_state}    selenium_coam.Get Bts Status
    Should Be Equal As Strings    ${bts_state}    On air    ignore_case=${TRUE}
    [Teardown]    selenium_coam.logout

Modify the reportingIntervalPm to 15 min
    Login Page Via WebUI
    ${bts_ID}    selenium_coam.get_bts_id
    ${reportingIntervalPm}    selenium_coam.get parameter value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    filter_param=Performance measurement data reporting interval    abbr=reportingIntervalPm
	set suite variable    ${reportingIntervalPm}
    run keyword if    '${reportingIntervalPm}'!='15min'    selenium_coam.set parameter value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
	...    filter_param=Performance measurement data reporting interval    new_value=15min
	selenium_coam.validate plan
    ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=180
    [Teardown]    run keyword and ignore error    selenium_coam.logout

Restore reportingIntervalPm
    Login Page Via WebUI
    ${bts_ID}    selenium_coam.get_bts_id
    run keyword if    '${reportingIntervalPm}'!='15min'    selenium_coam.set parameter value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/PMCADM-1
	...    filter_param=Performance measurement data reporting interval    new_value=${reportingIntervalPm}
    selenium_coam.validate plan
    ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=180
    [Teardown]    run keyword and ignore error    selenium_coam.logout
