*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB006138         PY36
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
Variables         Resources/3CC_modify_para.py

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

#bip wireshark
${f1ap_filter}    \"f1ap\"
${luashark_path_trunk}    /home/ute/Downloads/Lua_trunk/generated_luashark/luashark.lua
${luashark_path_23R3}    /home/ute/Downloads/Lua_SBTS23R3/generated_luashark/luashark.lua
${command_template_trunk}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_trunk} -Y ${f1ap_filter} -T pdml
${command_template_23R3}    {tshark_path} -r {pcap_file} -X lua_script:${luashark_path_23R3} -Y ${f1ap_filter} -T pdml
${f1ap_addScellID}    f1ap.sCellIndex
${f1ap_patternID}    f1ap.patternid

${data_transfer_dl}     2100Mbits/sec
${data_transfer_ul}     80Mbits/sec
${Expected_Throughput_DL}     1200
${Expected_Throughput_UL}     40

*** Test Cases ***
[1]CB012170-SR-A_09_UETput_SSB_power_boosting_in_mMIMO_cMAArChile_64T64R
    [Tags]    CB012170    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/12170_on_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    sleep      3s
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check patternID from bip log
    log to console      "UE_attach_Tput"
    spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    log to console      "check_Tput"
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1][1.0] CB006138_5G_D_7_Aperiodic_CSI_interworking_for_3CC_CA_blind
    [Tags]    CB006138    CB008311    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8311_6138_scf.xml
    sleep    10min
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1][1.0] CB006138_5G_AA_11_Blind_Scell_activation_TDD_TDD_FDD_3CC_CA_Single_UE_does_not_support_band_combinations_BF_deactivated
    [Tags]    CB006138    2CC_TT    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/case2_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput_2CC_TT"
    Run Keyword And Ignore Error    Check 2CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1][2.0] CB006138_5G_AD_35_Mixed_mode_CA_DRX_disable_interworking_5GC002200_Single UE
    [Tags]    CB006138    CB008311    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8311_6138_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=80Mbits/sec
    ...                                     data_transfer_ul=50Mbits/sec
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 1CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 8311 DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    Connect to Common Unit Master
    Start Bip Log Capture on nokk
    log to console      "UE_attach_Tput_again"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=1300Mbits/sec
    ...                                     data_transfer_ul=50Mbits/sec
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}    Stop Bip Log Capture on nokk and download BIP Logs to testPC
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1]CNI_81817_05_BCAlgorithmChange_3CC_4CC_CA_Addition_Layer_chBW_Selection
    [Tags]    CB006138    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/case1_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1]CNI_80224_03_3CC_TTF_actPerCsiReportBundlingTddFr1_2200_simultaneous_PCellandSCell
    [Tags]    CB006138    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/case1_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1]CNI_80224_04_4CC_TTFF_actPerCsiReportBundlingTddFr1_2200_simultaneous_SCell
    [Tags]    CB006138    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/case1_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1][1.0] CB008532_5G_A_1_gNB_Configuration_TDD_FDD_DL_4CC CA
    [Tags]    CB006138    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/case1_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Log Capture on nokk
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1][1.0] CB008532_5G_B_1_4CC_CA_blind_Scell_Addition_RRC_Connection_Reestablishment_on_serving_cell
    [Tags]    CB006138    3CC    CIT_TRUNK
    [Setup]    Case Setup 6138
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/case1_default_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    Start Bip Logs Capture for 6138
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=7
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    ${list_log_path_local}     Stop Bip Logs Capture and Download Logs for 6138
    set test variable    ${bip_log_path}    ${list_log_path_local}
    Run Keyword And Ignore Error    Check 3CC add from bip log
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check 3CC DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

*** Keywords ***
Case Setup 6138
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Run keyword if    'SBTS23R3' in ${result}    set test variable    ${command_template}    ${command_template_23R3}
    ...       ELSE     set test variable    ${command_template}    ${command_template_trunk}
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932

Start Bip Logs Capture for 6138
    ${6138_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${6138_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${6138_timestamp}

Stop Bip Logs Capture and Download Logs for 6138
    ${bip_log_local}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${6138_timestamp}
    set test variable    ${bip_log}    ${bip_log_local}[0]
    [Return]    ${bip_log}

Start Bip Log Capture on nokk
    [Arguments]     ${mirror_port}=any    ${asik_alias}=ASIK Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n 0x1514\n
    Sleep    1 sec
    Call Method    ${channel}    send    tcpdump -i any -w /tmp/F1AP.pcap\n

Stop Bip Log Capture on nokk and download BIP Logs to testPC
    [Arguments]     ${interface}=any
    Run Keyword And Ignore Error    Stop BIP Capture On ASIK    interface=${interface}
    ${list_log_path_local}    Download BIP Logs From nokk To TestPC and rename it
    [Return]    ${list_log_path_local}

Download BIP Logs From nokk To TestPC and rename it
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master    ${download_type}=Download
    ...            ${log_prefix}=${None}    ${bip_prefix}=F1AP    ${bip_path2}=/tmp/node_CPIF00/tmp
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${bip_path2}
    ...                  connection=${connection}    file_indicator=${bip_prefix}*
    should not be empty  ${list_log_names}    msg=No bip logs found with log prefix F1AP under asik tmp folder
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

Check patternID from bip log
    [Arguments]
    log to console      "bip_patternID_check"
    bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}
    ...                                                      command_template=${command_template}
    ${patternID_list}    Get value from Bip Log    field_name=${f1ap_patternID}

Check 3CC add from bip log
    [Arguments]
    log to console      "bip_3cc_check"
    bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}
    ...                                                      command_template=${command_template}
    ${3cc_addcell_list}    Get value from Bip Log    field_name=${f1ap_addScellID}
    ${length}    Get Length    ${3cc_addcell_list}
    Should Be True    ${length}==2

Check 1CC add from bip log
    [Arguments]
    log to console      "bip_1cc_check"
    bip_common_keyword.Load BIP Log with Template Command    pcap_file=${bip_log_path}
    ...                                                      command_template=${command_template}
    ${1cc_addcell_list}    Get value from Bip Log    field_name=${f1ap_addScellID}
    ${length}    Get Length    ${1cc_addcell_list}
    Should Be True    ${length}==0

Check 2CC DL UL Tput on GNB
    [Documentation]    check 2CC DL&UL tput on gnb
    ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=140    cellid=331251722
    ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=140    cellid=331251723
    ${2CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}
    Should be true    ${2CC_DL_tput}>=500
    ${UL_tput_cell1}    Check throughput on gNB    direction=ul    throughput=30    cellid=331251722

Check 3CC DL UL Tput on GNB
    [Documentation]    check 3CC DL&UL tput on gnb
    ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=500    cellid=331251722
    ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=150    cellid=331252213
    ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=150    cellid=331251714
    ${3CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}
    Should be true    ${3CC_DL_tput}>=800
    ${UL_tput_cell1}    Check throughput on gNB    direction=ul    throughput=30    cellid=331251722

Check 8311 DL UL Tput on GNB
    [Documentation]    check 3CC DL&UL tput on gnb
    ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=80    cellid=331251722
    ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=0    cellid=331252213
    ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=0    cellid=331251714
    ${1CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}
    Should be true    ${1CC_DL_tput}>=80
    ${UL_tput_cell1}    Check throughput on gNB    direction=ul    throughput=18    cellid=331251722

spark send CMD on UE
    [Arguments]    ${ue_index}    ${ue_alias}=UE_${ue_index}
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,509070,30,41    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+QNWPREFCFG="nr5g_band",41:25:66:71     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s

Spark UE attach
    [Arguments]    ${n}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Continue On Failure    spark send CMD on UE    ue_index=${n}

spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${apn_address}    ${ue_mode}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    Run Keyword And Continue On Failure    Spark UE attach    n=${n}
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
