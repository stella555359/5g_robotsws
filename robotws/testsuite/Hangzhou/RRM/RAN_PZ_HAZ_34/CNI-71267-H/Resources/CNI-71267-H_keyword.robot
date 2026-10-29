*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CNI-71267-H in 5G22R1 program


Library             taf.transport.ssh    WITH NAME    csn
Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.analyzer.pcap   WITH NAME   pcap
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library             ./CNI-71267-H_variables.py
Variables           ./CNI-71267-H_variables.py

*** Variables ***
${gnb_index}    0
${du_index}     0

${connection}    GNB_OAM

${file_name}    VoNR.pcap
${filter}    /usr/bin/tshark -r {input_file} -Y  "ngap.fiveQI && ngap.PDUSessionResourceModifyListModReq" -T pdml > {output_file}
${TEST_LOG_DIRECTORY}    /home/ute/casetest/bbttss/

${host}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
#${host}    10.101.51.139
${username}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
${password}    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
L3 call start
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${4G_check}=${False}    ${reset_sol}=ue_reboot
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}    reset_sol=${reset_sol}    #detach_request=${false}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}

L3 call start second
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${4G_check}=${False}    ${reset_sol}=ue_reboot
    log to console    L3 call setup and check
#    Log To Console    \n ### Prepare UE ###
#    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}    reset_sol=${reset_sol}    #detach_request=${false}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}

Start Device traffic
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${direction}=dl    ${throughput}=1M    ${reset_sol}=${True}
    ...    ${iperf_port}=default
    Log To Console    \n ###UE Start traffic ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throughput}    duration=900
    ...    iperf_port=${iperf_port}

Stop Device traffic
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50    ${direction}=dl    ${iperf_port}=default
    Log To Console    \n ###UE Stop traffic###
    power_ue.Stop traffic    direction=${direction}    ue_index=${ue_index}    ue_type=${UE_TYPE}    iperf_port=${iperf_port}

L3 Call Stop
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

Start Capture wireshark log
    [Arguments]    ${gnb_index}=0    ${file_name}=${file_name}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIB
    csn.Execute    command=rm -rf /tmp/${file_name}    connection=ASIB
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ASIB
    #Should be empty    ${output}
    ${cmd}=    catenate    tcpdump -i br1 -w /tmp/${file_name} &>/dev/null &
    csn.send command    command=${cmd}    connection=ASIB
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=ASIB
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIB

Stop Capture wireshark log
    [Arguments]    ${enb_index}=0
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIB
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=ASIB
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9    connection=ASIB
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIB

Download wireshark Log To TestPC
    [Arguments]    ${enb_index}=0
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=ASIB
    csn.Download file    remote_path=/tmp/${file_name}    local_path=${log_path}/${file_name}   connection=ASIB
    csn.execute    command=rm -rf /tmp/${file_name}     connection=ASIB
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=ASIB

Check VoNR Success
    ${all_packets}=    pcap.load_pcap_file    command_template=${filter}    pcap_file=${log_path}/${file_name}
    ${VoNR_Fliter} =  Catenate    ngap.fiveQI == 1
    ${VoNR_Required} =    pcap.filter_packets_by_expression
    ...    filter_expression=${VoNR_Fliter}
    ${VoNR_Required_value} =    pcap.get_field_value_by_xpath    pdml_list=${VoNR_Required}    xpath=.//ngap.fiveQI
	${VoNR_Required_value_length}    get length    ${VoNR_Required_value}
	Run Keyword If    ${VoNR_Required_value_length} == 0    Stop VoNR call
    should not be empty    ${VoNR_Required_value}    msg=make VoNR call fail
    should be equal    ${VoNR_Required_value[0]}    1

Make VoNR call(+9988)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=9988
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    Log To Console    \n ### VoNR Call Steup ###
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

Stop VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

Get bwp type
    [Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2PS    log_name=bwp_type.txt
    csn.Connect to    hostname=${host}    username=${username}    password=${password}    alias=ASIB
    ${Aal2lo_cmd}=    catenate    cat /tmp/bwp_type.txt | grep -a "switched to bwpType" | grep -av grep
    ${output} =    csn.execute    command=${Aal2lo_cmd}    connection=ASIB
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${bwptype}=   check from syslog    alias=ASIB
    [Return]    ${bwptype}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIB

Start Btslog Collect
    [Arguments]    ${names}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${log_dir}=/tmp/btslog2
    Log To Console    \n ### Btslog Collect Start ###
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}

Stop Btslog Collect
    [Arguments]    ${names}=btslog
    Log To Console    \n ### Btslog Collect Stop ###
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}    target_dir=${TEST_LOG_DIRECTORY}

    core.Teardown Collectors    names=${names}
    ${btslog_name}    Join Path    ${TEST_LOG_DIRECTORY}    ${names}
    [Return]    ${btslog_name}

Check Btslog For Bwptype
    [Arguments]    ${btslog_name}=${TEST_LOG_DIRECTORY}/btslog
    #Log    Checking BTS Syslog to confirm parameter change.    console=True
	#${Aasyslog_prints}=    Create list
	#...    L2-PS*
    ${output}    Check Btslog    btslog_name=${btslog_name}
    ...             filter=switched to bwpType
    log to console    ${btslog_name}
    [Return]    ${output}

Check Btslog
    [Arguments]    ${btslog_name}    ${filter}
    Log    Checking BTS Syslog to confirm parameter change.    console=True
    OperatingSystem.Run    command=tar zxvf ${btslog_name}/syslog_files.tgz -C/${btslog_name}/
    ${output}    OperatingSystem.Run    command=cat ${btslog_name}/SYSLOG*.LOG | grep -a "${filter}" | grep -av grep
    Should Not Be Empty    ${output}
    [Return]    ${output}

Get bwp type in btslog
    #[Arguments]    ${ue_index}=${0}    ${UE_TYPE}=qct_dx50
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    ${bwp_type_file}    Stop Btslog Collect
    ${output}    Check Btslog For Bwptype    btslog_name=${bwp_type_file}
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${bwptype}=   check from btslog    alias=ute    log_path=${bwp_type_file}/SYSLOG*.LOG
    csn.execute    command=rm ${bwp_type_file}/SYSLOG*.LOG    connection=ute
    [Return]    ${bwptype}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=ute

Get cell bwpDN
    ${cellBwpList}    Get NIDD parameter value    class_name=NRCELL_A    pattern=cellBwpList    connection=${connection}
    [Return]    ${cellBwpList}

Compare cellBwptype
    [Arguments]    ${cellBwplist}
    ${bwptype_list}    Create List    dedicated    powerSaving    initial
    Sort List    ${bwptype_list}
    @{bwptype_list_be_compared}=    Create List
    ${index_length}    get length    ${cellBwplist}
    FOR    ${index}    IN RANGE    ${index_length}
        ${bwptype}    admin_cli.get_parameters    dist_name=${cellBwpList[${index}]['bwpDN']}    pattern=bwpType    connection=${connection}
        ${bwptype_value}    set variable     ${bwptype['bwpType']}
        Append To List    ${bwptype_list_be_compared}    ${bwptype_value}
    END
    Sort List    ${bwptype_list_be_compared}
    Should Be Equal    ${bwptype_list_be_compared}    ${bwptype_list}

Set nrcell_1 parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    ...    ${skip_parameter_relation_errors}=False
    ${status}=    run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=${connection}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    sleep    3s
    [Return]    ${status}

Act Gnb debug on ABIO
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${host}    username=${username}    password=${password}    alias=ASIB
    ${addons_cmd}=    catenate    mkdir /ffs/run/swpool/L2RT/addons
    ${filepath_cmd}=    catenate    mkdir -p /tmp/var/preserve
    ${add_flag_cmd_1}=    catenate    echo "L2.L2_PS.BWP_ADAPTATION=1" > /tmp/var/preserve/feature_log_activation.txt
    ${add_flag_cmd_2}=    catenate    echo "L2.L2_PS.DL.DCI=1" >> /tmp/var/preserve/feature_log_activation.txt
    ${tgz_cmd}=    catenate    cd /tmp ; tar czfP var/preserve/trace.tgz var/preserve/feature_log_activation.txt
    ${transfer_cmd}=    catenate    mv /tmp/var/preserve/trace.tgz /ffs/run/swpool/L2RT/addons/
    ${crasign_cmd}=    catenate    crasign /ffs/run/swpool/L2RT/addons/trace.tgz
    ${ln_cmd}=    catenate    ln -f /ffs/run/swpool/L2RT/addons/trace.tgz /ffs/run/boardcfg/5/A/mcu-aspd/addons/trace.tgz
    ${ln_p7_cmd}=    catenate    ln -f /ffs/run/swpool/L2RT/addons/trace.tgz.p7 /ffs/run/boardcfg/5/A/mcu-aspd/addons/trace.tgz.p7
    ${hash_cmd}=    catenate    rm /ffs/run/HashContainer* ; reboot
    csn.execute    command=${addons_cmd} ; ${filepath_cmd} ; ${add_flag_cmd_1} ; ${add_flag_cmd_2} ; ${tgz_cmd}    connection=ASIB
    csn.execute    command=${transfer_cmd} ; ${crasign_cmd} ; ${ln_cmd} ; ${ln_p7_cmd} ; ${hash_cmd}    connection=ASIB
	sleep    10s
    Wait Until Keyword Succeeds    15min    5s    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=ASIB


Configure switching parameters
    [Arguments]    ${para}
    #${powerSavingBwpSwitching}    Get NIDD parameter value    class_name=NRBTS_A    pattern=powerSavingBwpSwitching    connection=${connection}
    #run keyword if    ${powerSavingBwpSwitching['${key}']} != ${value}
    #...    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
    #...    parameter=${key}    operation=update    value=${value}    connection=${connection}
    admin_cli.perform_object_recommissioning    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
    ...    parameter=${para}    operation=update    connection=${connection}

Case_10 Precondition
    ${maxNumberVoNRPowerSaving}    Get NIDD parameter value    class_name=NRCELL_A    pattern=maxNumberVoNRPowerSaving    connection=${connection}
    run keyword if    ${maxNumberVoNRPowerSaving} != 5    Set nrcell_1 parameter    key=maxNumberVoNRPowerSaving    value=5
    ${maxNumberUesPowerSaving}    Get NIDD parameter value    class_name=NRCELL_A    pattern=maxNumberUesPowerSaving    connection=${connection}
    run keyword if    ${maxNumberUesPowerSaving} != 5    Set nrcell_1 parameter    key=maxNumberUesPowerSaving    value=5
    Wait Until Keyword Succeeds    5min    5s    COAM Check GNB cell on air    connection=${connection}

Case Precondition
    [Arguments]    ${para_powerSavingBwpSwitching}=${powerSavingBwpSwitching}
    ${actVoNR}    Get NIDD parameter value    class_name=NRCELL_A    pattern=actVoNR    connection=${connection}
    run keyword if    '${actVoNR}' != 'true'    Set nrcell_1 parameter    key=actVoNR    value=true
    Configure switching parameters    para=${para_powerSavingBwpSwitching}
    ${actPowerSavingBWP}    Get NIDD parameter value    class_name=NRCELL_A    pattern=actPowerSavingBWP    connection=${connection}
    run keyword if    '${actPowerSavingBWP}' != 'true'    Set nrcell_1 parameter    key=actPowerSavingBWP    value=true
    Wait Until Keyword Succeeds    5min    5s    COAM Check GNB cell on air    connection=${connection}

Case_7 Precondition
    [Arguments]    ${para_powerSavingBwpSwitching}=${powerSavingBwpSwitching_for_case7_1}
    ${actVoNR}    Get NIDD parameter value    class_name=NRCELL_A    pattern=actVoNR    connection=${connection}
    run keyword if    '${actVoNR}' != 'true'    Set nrcell_1 parameter    key=actVoNR    value=true
    Configure switching parameters    para=${para_powerSavingBwpSwitching}
    ${actPowerSavingBWP}    Get NIDD parameter value    class_name=NRCELL_A    pattern=actPowerSavingBWP    connection=${connection}
    run keyword if    '${actPowerSavingBWP}' != 'true'    Set nrcell_1 parameter    key=actPowerSavingBWP    value=true
    Wait Until Keyword Succeeds    5min    5s    COAM Check GNB cell on air    connection=${connection}

Check whether addons exist
    csn.Connect to    hostname=${host}    username=${username}    password=${password}    alias=ASIB
    ${checke_addons_cmd}=    catenate    cd /ffs/run/swpool/L2RT/addons
    ${output}=    csn.execute    command=${checke_addons_cmd}    connection=ASIB
    ${addons_status}=    Evaluate    "No such file or directory" in """${output}"""
    [Return]    ${addons_status}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIB

Precondition
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    ${cellBwpList}    Get cell bwpDN
    Compare cellBwptype    cellBwplist=${cellBwpList}
    ${addons_exist}    Check whether addons exist
    run keyword if    ${addons_exist}    Act Gnb debug on ABIO


Teardown
    admin_cli.teardown    connection=${connection}
    run keyword and ignore error    csn.Disconnect	connection=ASIB
    run keyword and ignore error    Stop Device traffic    UE_TYPE=${UE_TYPE}    direction=dl
    run keyword and ignore error    Stop Device traffic    UE_TYPE=${UE_TYPE}    direction=ul
    run keyword and ignore error    L3 Call Stop    UE_TYPE=${UE_TYPE}
    Stop VoNR call

Start And Check VoNR Call
	Start Capture wireshark log
	Make VoNR call(+9988)
	sleep    5s
	Stop Capture wireshark log
	Download wireshark Log To TestPC
	Check VoNR Success

