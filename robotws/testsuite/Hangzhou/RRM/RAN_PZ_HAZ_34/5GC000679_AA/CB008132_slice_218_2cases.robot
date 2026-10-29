*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB008132         PY36
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
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}              /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T218

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
[1][1.0] CB008132_5G_C_06_NSA_SA_2_PLMN_F_T_2CC_CA_NonCA_MUEs_with_all_Cells_SAS_activated_ABIO
    [Tags]    CB008132
    [Setup]    Case Setup 8132
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8132_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 8132
    log to console      "UE7_attach_Tput"
    Run Keyword And Ignore Error    spark UE7 attach and start DL tput
    log to console      "UE5_attach_Tput"
    Run Keyword And Ignore Error    spark UE5 attach and start DL tput
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=300Mbits/sec    n=2
    log to console      "UE4_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=150Mbits/sec    n=3
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 8132
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check UE SPID from bip X2 log
    log to console      "check_Tput_on_UE"
    Run Keyword And Ignore Error    Check Tput for one UE    n=6
    Run Keyword And Ignore Error    Check Tput for one UE    n=4
    Run Keyword And Ignore Error    Check Tput for one UE    n=2
    Run Keyword And Ignore Error    Check Tput for one UE    n=3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=6    apn_address=wap1nokiacom
    sleep    600s
    log to console      "check_counters"
    Run Keyword And Ignore Error    Check counter value for 8132
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=6    apn_address=wap1nokiacom

[1][1.0] CB008132_5G_C_02_NSA_1_PLMN_F_T_2CC_CA_MUEs_with_all_Cells_SAS_activated_wo_FDM
    [Tags]    CB008132
    [Setup]    Case Setup 8132
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8132_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 8132
    log to console      "UE7_attach_Tput"
    Run Keyword And Ignore Error    spark UE7 attach and start DL tput
    log to console      "UE5_attach_Tput"
    Run Keyword And Ignore Error    spark UE5 attach and start DL tput
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=300Mbits/sec    n=2
    log to console      "UE4_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=150Mbits/sec    n=3
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 8132
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check UE SPID from bip X2 log
    log to console      "check_Tput_on_UE"
    Run Keyword And Ignore Error    Check Tput for one UE    n=6
    Run Keyword And Ignore Error    Check Tput for one UE    n=4
    Run Keyword And Ignore Error    Check Tput for one UE    n=2
    Run Keyword And Ignore Error    Check Tput for one UE    n=3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=6    apn_address=wap1nokiacom
    sleep    600s
    log to console      "check_counters"
    Run Keyword And Ignore Error    Check counter value for 8132
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=6    apn_address=wap1nokiacom

[1]CB009084_5G_FB2_02_MUEs_SAS_enhanced_MU-MIMO_NSA_SA_TDD
    [Tags]    CB009084
    [Setup]    Case Setup 8132
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8132_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 8132
    log to console      "UE7_attach_Tput"
    Run Keyword And Ignore Error    spark UE7 attach and start DL tput
    log to console      "UE3_attach_Tput"
    Run Keyword And Ignore Error    spark UE34 attach and start DL tput    data_transfer_dl=300Mbits/sec    n=2
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 8132
    set test variable    ${bip_log_path}    ${list_log_path_local}
    log to console      "check_Tput_on_UE"
    Run Keyword And Ignore Error    Check Tput for one UE    n=6
    Run Keyword And Ignore Error    Check Tput for one UE    n=2
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=6    apn_address=wap1nokiacom
    sleep    600s
    log to console      "check_counters"
    Run Keyword And Ignore Error    Check counter value for 8132
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=6    apn_address=wap1nokiacom

[1][1.0] CB008132_5G_B_01_SA_1_PLMN_single_Slice_T_F_2CC_CA_MUEs_with_PCell_SAS_activated_wo_FDM
    [Tags]    CB008132
    [Setup]    Case Setup 8132
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8132_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 8132
    log to console      "UE7_attach_Tput"
    Run Keyword And Ignore Error    spark UE7 attach and start DL tput
    log to console      "UE5_attach_Tput"
    Run Keyword And Ignore Error    spark UE5 attach and start DL tput
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 8132
    set test variable    ${bip_log_path}    ${list_log_path_local}
    log to console      "check_Tput_on_UE"
    Run Keyword And Ignore Error    Check Tput for one UE    n=6
    Run Keyword And Ignore Error    Check Tput for one UE    n=4
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=6    apn_address=wap1nokiacom
    sleep    600s
    log to console      "check_counters"
    Run Keyword And Ignore Error    Check counter value for 8132
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=6    apn_address=wap1nokiacom

*** Keywords ***
Case Setup 8132
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Run keyword if    'SBTS23R2' in ${result}    set test variable    ${command_template}    ${command_template_23R2}
    ...       ELSE     set test variable    ${command_template}    ${command_template_trunk}
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932
    ERR_WRN_Check.Stop BTSLogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable     ${execution_env_type}       DEBUG

Check counter value for 8132
    ${counter_DL_PRB_USED_DATA_NRG}        Get BTS Counters from webUI    counter_id=M55910C00001
    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}    Get BTS Counters from webUI    counter_id=M55910C00002
    ${counter_PRB_AVAIL_PDSCH_SLICES}      Get BTS Counters from webUI    counter_id=M55308C10007

Start Bip Logs Capture for 8132
    ${8132_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${8132_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${8132_timestamp}

Stop Bip Logs Capture and Download Logs for 8132
    ${bip_log_local}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${8132_timestamp}
    set test variable    ${bip_log}    ${bip_log_local}[0]
    [Return]    ${bip_log}

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
    spark.send_at_command_on_ue    command=at+cfun=1,1    ue_alias=UE_${ue_index}

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
    spark.send_at_command_on_ue    command=at+cfun=1,1    ue_alias=UE_${ue_index}

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
