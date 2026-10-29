*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB008746         PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          Resources/5GC000679_common_keyword_Dingli.robot
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008744/Resources/CB008744_C_commen_keywords.robot
Variables         Resources/3CC_modify_para.py

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

#bip wireshark
${x2ap_filter}    \"x2ap\"
${luashark_path_trunk}    /home/ute/Downloads/Lua_trunk/generated_luashark/luashark.lua
${luashark_path_23R2}    /home/ute/Downloads/Lua_SBTS23R2/generated_luashark/luashark.lua
${command_template_trunk}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_trunk} -Y ${x2ap_filter} -T pdml
${command_template_23R2}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_23R2} -Y ${x2ap_filter} -T pdml
${x2ap_SPID}    x2ap.SubscriberProfilelDforRFP

${data_transfer_dl}     2100Mbits/sec
${data_transfer_ul}     80Mbits/sec
${Expected_Throughput_DL}     100
${Expected_Throughput_UL}     1

*** Test Cases ***
[1]CB008746_5G_A_IWK7_01_With_CA_interworking_MUEs_NSA_SA_NSA_FT_2CC_CA_SA_TTF_3CC_CA_with_PCell_SAS_activated
    [Tags]    CB008746    CIT_TRUNK
    [Setup]    Case Setup 8746
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8746_IWK7_01.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Log Capture on nokk
    log to console      "UE7_attach_Tput"
    Run Keyword And Ignore Error    spark UE7 attach and start DL tput
    log to console      "UE5_attach_Tput"
    Run Keyword And Ignore Error    spark UE5 attach and start DL tput
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=300Mbits/sec    n=2
    log to console      "UE4_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=150Mbits/sec    n=3
    ${list_log_path_local}    Stop Bip Log Capture on nokk and download BIP Logs to testPC
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Run Keyword And Ignore Error    Check UE SPID from bip X2 log
    log to console      "check_Tput_on_UE"
    Run Keyword And Ignore Error    Check Tput for one UE    n=6
    Run Keyword And Ignore Error    Check Tput for one UE    n=4
    Run Keyword And Ignore Error    Check Tput for one UE    n=2
    Run Keyword And Ignore Error    Check Tput for one UE    n=3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=6    apn_address=wap1nokiacom
    sleep      300s
    run keyword and ignore error    Check 8746 PM counters
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=6    apn_address=wap1nokiacom

[1]CB008746_5G_A_IWK8_06_With_GBR_Service_interworking_MUEs_NSA_SA_MPLMNs_FDD_TDD_GBR_nonGBR_differentBW
    [Tags]    CB008746    CIT_TRUNK
    [Setup]    Case Setup 8746
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8746_IWK8_06.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=1
    Set test variable    ${ue_type}
    log to console      "UE2_attach_Tput"
    Run Keyword And Ignore Error    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=1    get_spark_license=False
    sleep      3s
    log to console      "send_CMD_UE2"
    Run Keyword And Ignore Error    spark send CMD on UE2 case2
    Run Keyword And Ignore Error    power_ue.Start traffic     ue_type=${ue_type}    direction=dl
    ...    throughput=25Mbits/sec    duration=3000    ue_index=1    ue_mode=SA    apn_address=mdrbnokiacom
    log to console      "check_Tput_on_UE"
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=15
    ...                                                          ue_index=1
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=mdrbnokiacom
    sleep      300s
    Run Keyword And Ignore Error    Check 8746 PM counters case2
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=mdrbnokiacom

[1]CB008746_5G_A_IWK9_04_With_multiple_BWP_interworking_MUEs_NSA_SA_MPLMNs_FDD_TDD_differentBW
    [Tags]    CB008746    CIT_TRUNK
    [Setup]    Case Setup 8746
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8746_IWK9_04.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    log to console      "UE1_attach_Tput"
    Run Keyword And Ignore Error    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=0    get_spark_license=False
    sleep      3s
    Run Keyword And Ignore Error    spark send CMD on UE1 case3
    Run Keyword And Ignore Error    power_ue.Start traffic     ue_type=${ue_type}    direction=dl
    ...     throughput=300Mbits/sec    duration=3000    ue_index=0    ue_mode=SA    apn_address=wap1nokiacom
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=2    get_spark_license=False
    sleep      3s
    Run Keyword And Ignore Error    spark send CMD on UE34    ue_index=2
    Run Keyword And Ignore Error    power_ue.Start traffic     ue_type=${ue_type}    direction=dl
    ...     throughput=1200Mbits/sec    duration=3000    ue_index=2    ue_mode=SA    apn_address=wap1nokiacom
    log to console      "check_Tput_on_UE"
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=1160
    ...                                                          ue_index=0
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=294
    ...                                                          ue_index=2
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=3    apn_address=wap1nokiacom
    sleep      300s
    Run Keyword And Ignore Error    Check 8746 PM counters case3
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=3    apn_address=wap1nokiacom

[1]CB008746_5G_B_B1_01_MUEs_SAS_PRBpooling_FDD_CA_2T2F_NSA
    [Tags]    CB008746    CIT_TRUNK
    [Setup]    Case Setup 8746
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8746_IWK7_01.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Log Capture on nokk
    log to console      "UE7_attach_Tput"
    Run Keyword And Ignore Error    spark UE7 attach and start DL tput
    log to console      "UE5_attach_Tput"
    Run Keyword And Ignore Error    spark UE5 attach and start DL tput
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=300Mbits/sec    n=2
    log to console      "UE4_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=150Mbits/sec    n=3
    ${list_log_path_local}    Stop Bip Log Capture on nokk and download BIP Logs to testPC
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Run Keyword And Ignore Error    Check UE SPID from bip X2 log
    log to console      "check_Tput_on_UE"
    Run Keyword And Ignore Error    Check Tput for one UE    n=6
    Run Keyword And Ignore Error    Check Tput for one UE    n=4
    Run Keyword And Ignore Error    Check Tput for one UE    n=2
    Run Keyword And Ignore Error    Check Tput for one UE    n=3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=6    apn_address=wap1nokiacom
    sleep      300s
    run keyword and ignore error    Check 8746 PM counters
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=6    apn_address=wap1nokiacom

[1]CB008746_5G_C_B1_01_MUEs_SAS_enhanced_MU-MIMO_16Layers_NSA_TDD
    [Tags]    CB008746    CIT_TRUNK
    [Setup]    Case Setup 8746
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8746_IWK9_04.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    log to console      "UE1_attach_Tput"
    Run Keyword And Ignore Error    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=0    get_spark_license=False
    sleep      3s
    Run Keyword And Ignore Error    spark send CMD on UE1 case3
    Run Keyword And Ignore Error    power_ue.Start traffic     ue_type=${ue_type}    direction=dl
    ...      throughput=300Mbits/sec    duration=3000    ue_index=0    ue_mode=SA    apn_address=wap1nokiacom
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=2    get_spark_license=False
    sleep      3s
    Run Keyword And Ignore Error    spark send CMD on UE34    ue_index=2
    Run Keyword And Ignore Error    power_ue.Start traffic     ue_type=${ue_type}    direction=dl
    ...    throughput=1200Mbits/sec    duration=3000    ue_index=2    ue_mode=SA    apn_address=wap1nokiacom
    log to console      "check_Tput_on_UE"
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=1160
    ...                                                          ue_index=0
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=294
    ...                                                          ue_index=2
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=3    apn_address=wap1nokiacom
    sleep      300s
    Run Keyword And Ignore Error    Check 8746 PM counters case3
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=3    apn_address=wap1nokiacom

*** Keywords ***
Case Setup 8746
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Run keyword if    'SBTS23R2' in ${result}    set test variable    ${command_template}    ${command_template_23R2}
    ...       ELSE     set test variable    ${command_template}    ${command_template_trunk}
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932

Start Bip Log Capture on nokk
    [Arguments]     ${mirror_port}=any    ${asik_alias}=ASIK Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n 0x1514\n
    Sleep    1 sec
    Call Method    ${channel}    send    tcpdump -i any -w /tmp/X2AP.pcap\n

Stop Bip Log Capture on nokk and download BIP Logs to testPC
    [Arguments]     ${interface}=any
    Run Keyword And Ignore Error    Stop BIP Capture On ASIK    interface=${interface}
    ${list_log_path_local}    Download BIP Logs From nokk To TestPC and rename it
    [Return]    ${list_log_path_local}

Download BIP Logs From nokk To TestPC and rename it
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master    ${download_type}=Download
    ...            ${log_prefix}=${None}    ${bip_prefix}=X2AP    ${bip_path2}=/tmp/node_CPIF00/tmp
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${bip_path2}
    ...                  connection=${connection}    file_indicator=${bip_prefix}*
    should not be empty  ${list_log_names}    msg=No bip logs found with log prefix X2AP under asik tmp folder
    Sort List    ${list_log_names}
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
      ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
      ${bip_name}    fetch from left    ${log_name}    .
      ${bip_name_new}    Set Variable If    '${log_prefix}'!='${None}'    ${log_prefix}_${bip_name}_${timestamp}.pcap
      ...                                                                 ${bip_name}_${timestamp}.pcap
      Run Keyword If    '${download_type}'=='Download'    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
      ...                                                 remote_path=${bip_path2}/${log_name}
      ...                                                 local_path=${log_path}/${bip_name_new}
      ...                                                 connection=${connection}
      ...    ELSE IF    '${download_type}'=='SSHpass'    Wait Until Keyword Succeeds   2 min  5 sec    Run Process
      ...             sshpass -p ${asik_password} scp -r ${asik_username}@${asik_addr}:${bip_path2}/${log_name} ${log_path}/${bip_name_new}
      ...               shell=yes
      ...    ELSE    Fail    msg=the value ${download_type} is not a valid value
      Append to list    ${list_log_path_local}    ${log_path}/${bip_name_new}
      csn.execute      command=rm -rf ${/}tmp${/}node_CPIF00${/}tmp${/}${log_name}    connection=${connection}
    END
    [Return]    ${list_log_path_local}

Check UE SPID from bip X2 log
    [Arguments]
    log to console      "UE_SPID_check"
    bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}
    ...                                                      command_template=${command_template}
    ${UE_SPID_list}    Get value from Bip Log    field_name=${x2ap_SPID}
    ${length}    Get Length    ${UE_SPID_list}
    Should Be True    ${length}==2
    Should Be True    ${UE_SPID_list}[0]==200
    Should Be True    ${UE_SPID_list}[1]==2

Check 8746 PM counters
    ${counter1}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55359C00001
    ${counter2}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55910C00002
    ${counter3}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55359C00000
    ${counter4}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55910C00001

Check 8746 PM counters case2
    ${counter1}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55308C10007
    ${counter2}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55359C00000
    ${counter3}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55359C00001

Check 8746 PM counters case3
    ${counter1}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55308C10007
    ${counter2}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55910C00001
    ${counter3}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55910C00002
    ${counter4}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55359C00000
    ${counter5}    1347_common_keyword.Check BTS Counters via webUI    counter_id=M55359C00001

spark UE7 attach and start DL tput
    [Arguments]     ${data_transfer_dl}=820Mbits/sec    ${data_transfer_ul}=10Mbits/sec
    ...             ${ue_mode}=SA    ${n}=6    ${apn_address}=wap1nokiacom
    [Documentation]    Attach_start_DL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=False
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Continue On Failure    spark send CMD on UE7
    sleep      15s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

spark UE5 attach and start DL tput
    [Arguments]     ${data_transfer_dl}=800Mbits/sec    ${data_transfer_ul}=10Mbits/sec
    ...             ${ue_mode}=SA    ${n}=4    ${apn_address}=wap1nokiacom
    [Documentation]    Attach_start_DL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=False
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Continue On Failure    spark send CMD on UE5
    sleep      15s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

spark UE34 attach and start DL tput
    [Arguments]     ${data_transfer_dl}    ${n}    ${data_transfer_ul}=10Mbits/sec
    ...             ${ue_mode}=NSA       ${apn_address}=wap1nokiacom
    [Documentation]    Attach_start_DL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=False
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Continue On Failure    spark send CMD on UE34     ue_index=${n}
    sleep      15s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

spark send CMD on UE7
    [Arguments]    ${ue_index}=6
    [Documentation]    send CMD for UE_0 by spark
    Run Keyword And Ignore Error    spark.send_at_command_on_ue
    ...                             command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=UE_${ue_index}
    sleep      5s
    Run Keyword And Ignore Error    spark.send_at_command_on_ue
    ...                             command=at+qnwlock="common/5g",6,509070,30,41    ue_alias=UE_${ue_index}
    sleep      5s
    Run Keyword And Ignore Error    spark.send_at_command_on_ue
    ...                             command=at+QNWPREFCFG="nr5g_band",41:25:66:71     ue_alias=UE_${ue_index}
    sleep      5s
    Run Keyword And Ignore Error    spark.send_at_command_on_ue
    ...                             command=at+cgdcont=1,"IPV4V6","wap1.nokia.com"     ue_alias=UE_${ue_index}
    log to console      "attach_UE_${ue_index}"
    Run Keyword And Ignore Error    spark.send_at_command_on_ue
    ...                             command=at+cfun=1,1     ue_alias=UE_${ue_index}

spark send CMD on UE5
    [Arguments]    ${ue_index}=4
    [Documentation]    send CMD for UE_4 by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",7,528510,30,41    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command=at+QNWPREFCFG="nr5g_band",41:25:66:71     ue_alias=UE_${ue_index}
    log to console      "attach_UE_${ue_index}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=UE_${ue_index}

spark send CMD on UE34
    [Arguments]    ${ue_index}
    [Documentation]    send CMD for UE_2 and UE_3 by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="nr5g_disable_mode",1    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command= AT+QNWPREFCFG="mode_pref",AUTO    ue_alias=UE_${ue_index}
    log to console      "attach_UE_${ue_index}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=UE_${ue_index}

spark send CMD on UE2 case2
    [Arguments]    ${ue_index}=1
    [Documentation]    send CMD for UE_2 by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",501,391970,15,25    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command=at+QNWPREFCFG="nr5g_band",41:25:66:71     ue_alias=UE_${ue_index}
    log to console      "attach_UE_${ue_index}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=UE_${ue_index}

spark send CMD on UE1 case3
    [Arguments]    ${ue_index}=0
    [Documentation]    send CMD for UE_6 by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,501390,30,41    ue_alias=UE_${ue_index}
    sleep      5s
    spark.send_at_command_on_ue    command=at+QNWPREFCFG="nr5g_band",41:25:66:71     ue_alias=UE_${ue_index}
    log to console      "attach_UE_${ue_index}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=UE_${ue_index}

spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${ue_mode}    ${attach_mode}    ${apn_address}=wap1nokiacom
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    Run Keyword And Continue On Failure    Spark UE attach    n=${n}    attach_mode=${attach_mode}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

All spark UEs attach and start DLUL traffic
    [Arguments]     ${apn_address}=${apn1}    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
    FOR    ${i}    IN RANGE    8
        spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
        ...                                     data_transfer_ul=${data_transfer_ul}
        ...                                     n=${i}
        ...                                     ue_mode=${ue_mode}
        ...                                     attach_mode=${attach_mode}
        ...                                     apn_address=${apn_address}
    END

Check 3CC DL UL Tput on GNB
    [Documentation]    check 3CC DL&UL tput on gnb
    ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=500    cellid=331251722
    ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=150    cellid=331252213
    ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=150    cellid=331251714
    ${3CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}
    Should be true    ${3CC_DL_tput}>=800
    ${UL_tput_cell1}    Check throughput on gNB    direction=ul    throughput=30    cellid=331251722
