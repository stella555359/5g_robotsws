*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup    Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown for COAM
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          Resources/5GC001116_MTK_common_keyword.robot
Resource          ../5GC000534_EB/Resources/MCS.robot
Resource          ../5GC002538/Resources/2538_keyword.robot
Resource          Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}

${scf_path}    /home/ute/Downloads/SCF


${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${ul_srs}      \"uldata_srsreceivereq\"
${srs_command_template}     {tshark_path} -r {pcap_file}
...      -Y ${ul_srs} -T pdml
${srs_bm}      UlData_srsReceiveReqSubcell_t.srsBmEnable
${sumimo}      UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
${luashark_path_22R1}      /home/ute/Downloads/Lua/generated_luashark_SBTS22R1/luashark.lua
${luashark_path_22R2}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R2/luashark.lua
${luashark_path_22R3}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R3/luashark.lua
${luashark_path_22R4}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R4/luashark.lua
${luashark_path_trunk}    /home/ute/Downloads/Lua/generated_luashark_TRUNK/luashark.lua
${tshark_path}    /usr/bin/tshark
@{beamset_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
@{beamset_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    102    102
${pa_value}    25eload Case SCF and Commission
@{pa_port}    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18
...    19    20    21    22    23    24    25    27    28    29    30    31    32

@{check_print}    ERR/

*** Test Cases ***
[1]CB011160_5G_AB_16_Verify_CellSetup_And_Tput_With_3CC_Configuration_Max_4MMSE_UEs_per_cc_128PRB_8DxU_comb4(Diff bfSubbandSize)
    [Tags]    CB009496    CRT_TRUNK
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB011160.xml
    Wait Until Keyword Succeeds   15 min  5 sec    Verify all cells should be onair
    ${cellid}    Create List    ${4223277}
    Set Test Variable    ${cellid}
    Reboot cpe for test    ue_index=${9}
    Sleep    5min
    UE Attach For Dingli    ue_index=${9}
    UE Send DL Traffic    ue_index=${9}    send_traffic=1600M/sec    send_duration=3600
    Capture BIP Log and Download By Web
    UE Check DL Traffic    dl_target=1200
    [Teardown]    Case Teardown

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${result}    String.split string    string=${target_version}    separator=_
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Comment    Run Keyword And Ignore Error    Recover swconfig file
#    Run Keyword And Ignore Error    Multi UE Stop UL traffic    num=${num}
    Run Keyword And Ignore Error    UE Stop UL traffic
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    close_ssh    hostname=${tl.ues[8].ssh_connection_details.addr}
    ...    username=${tl.ues[8].ssh_connection_details.username}    password=${tl.ues[8].ssh_connection_details.password}
    robot_common_operations.Common Case Teardown
    Run keyword and ignore error    CI_interface.Common Case Teardown


Common Suite Setup for COAM
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown for COAM
    robot_common_operations.Common Suite Teardown


MCS Set Beam
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${vertical_angle}    ${horizontal_angle}
    MCS Setup    ip=${tl.mcses.ip_addr}    vendor=hbte
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
        ${index}    evaluate    ${num}-1
        MCS Set Phases According to Angles    vertical_angle=${${vertical_angle}[${index}]}
        ...    horizontal_angle=${${horizontal_angle}[${index}]}    vertical_distance=${2.1}
        ...    horizontal_distance=${0.5}    output_group_id=${num}
    END
    MCS Teardown


UE Attach For Dingli
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=${false}    power_reset=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=False
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]

UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=1500M/sec    ${send_duration}=3600   ${ue_mode}=NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}

UE Send UL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50M/sec    ${send_duration}=3600   ${ue_mode}=NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}


UE Check UL Traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=ul
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${tput}

Dingli Stop traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=dl    ${ue_mode}=NSA    ${apn_address}=ims
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn_address}

Dingli Stop Ul traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=ul    ${ue_mode}=SA    ${apn_address}=ims
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn_address}

Multi UE Attach And Send Traffic
    [Arguments]    ${dl_traffic}=1000M/sec    ${ul_traffic}=100M/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        UE Attach For Dingli    ue_index=${ue_no}
        sleep    2s
        Run Keyword And Continue On Failure    UE Send DL Traffic    ue_index=${ue_no}
        ...    send_traffic=${dl_traffic}    send_duration=${send_duration}
		Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
		...    send_traffic=${ul_traffic}    send_duration=${send_duration}
    END

Multi UE Check Tput
    [Arguments]    ${num}=1    ${check_traffic_dl}=50    ${check_traffic_ul}=50
    FOR    ${ue_no}    IN RANGE    ${num}
        ${dl_tput}    UE Check DL Traffic    ue_index=${ue_no}
		${ul_tput}    UE Check UL Traffic    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Should Be True    ${dl_tput}>${check_traffic_dl}
		Run Keyword And Continue On Failure    Should Be True    ${ul_tput}>${check_traffic_ul}
    END

Multi UE Attach And Send UL Traffic
    [Arguments]    ${send_traffic}=260M/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        UE Attach For Dingli    ue_index=${ue_no}
        sleep    2s
        Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_traffic}    send_duration=${send_duration}
        sleep    120s
    END

Multi UE Check UL Tput
    [Arguments]    ${num}=1    ${check_tput}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        ${tput}    UE Check UL Traffic    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Should Be True    ${tput}>${check_tput}
    END

Multi UE Stop traffic
    [Arguments]    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Dingli Stop traffic    ue_index=${ue_no}
    END

Multi UE Stop UL traffic
    [Arguments]    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Dingli Stop Ul traffic    ue_index=${ue_no}
		Dingli Stop traffic    ue_index=${ue_no}
        UE Detach For Dingli    ue_index=${ue_no}
    END

UE Stop UL traffic
    Dingli Stop Ul traffic    ue_index=${9}
	Dingli Stop traffic    ue_index=${9}
    UE Detach For Dingli    ue_index=${9}

UE Detach For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=False

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Download File From ASIK To TestPC
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    Connect to Common Unit Master
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folde
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}

Check item from crpt file
    [Arguments]    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log    ${check_value}=-138    ${check_item}="gainCorrection":(\S\d*)
    ${output}    get_value_from_log_file    file_path=${file_path}    check_item=${check_item}
    Should Contain    ${output}    ${check_value}

Get Ul SRS pdml From Bip
    [Arguments]    ${pcap_file}=${bip_log_path}    ${output}=${TS_CASE_LOG_PATH}/srs.pdml
    Set Test Variable    ${ul_command}    ${tshark_path} -r ${pcap_file} -X lua_script:${luashark_path} -Y ${ul_srs} -T pdml > ${output}
    Run    ${ul_command}

Check SRS Enable From Bip File
    [Arguments]    ${pcap_file}=${bip_log_path}    ${remove_false_value}=0    ${remove_true_value}=1
    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${srs_command_template}
    ${sumimo_result}    Get value from Bip Log    field_name=${sumimo}
    ${srsbm_result}    Get value from Bip Log    field_name=${srs_bm}
    should not be empty    ${srsbm_result}
    Remove values from list    ${sumimo_result}    ${remove_false_value}
    Remove values from list    ${srsbm_result}    ${remove_true_value}
    Should Be Empty    ${srsbm_result}

Restore Attenuation Channels
    [Arguments]    ${initial_att_values}    ${channels}
    ${modify_channel}    create dictionary
    ${len}    get length    ${channels}
    FOR    ${index}    IN RANGE    ${len}
        ${new_index}    evaluate    ${channels}[${index}]-1
        Set To Dictionary    ${modify_channel}    ${pa_port}[${new_index}]=${initial_att_values}[${index}]
    END
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${modify_channel}

Start Capture Pcap File On Lokki
    [Arguments]     ${mirror_port}=any    ${filename}=Attachlog.pcap    ${asik_alias}=ASIK Master
    Connect to Common Unit Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n 0x1514\n
    Sleep    1 sec
    Call Method    ${channel}    send    tcpdump -i any -p sctp -w /tmp/${filename}\n

Stop Capture Pcap File
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump    connection=ASIK Master
    [Teardown]

Get RRC pdml From Bip
    [Arguments]    ${pcap_file}    ${output}=${TS_CASE_LOG_PATH}/rrc.pdml
    Set Test Variable    ${rrc_command}    ${tshark_path} -r ${pcap_file} -T pdml > ${output}
    Run    ${rrc_command}

Set PA Value For Attenuation Channels
    [Arguments]    ${channels}    ${pa_value}
    ${modify_channel}    create dictionary
    ${len}    get length    ${channels}
    FOR    ${index}    IN RANGE    ${len}
        ${new_index}    evaluate    ${channels}[${index}]-1
        Set To Dictionary    ${modify_channel}    ${pa_port}[${new_index}]=${pa_value}
    END
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${modify_channel}

Capturing Aasyslog And Modify Attenuation In The Duration
    [Documentation]    Keep capturing Aasyslog for given duration.
    [Arguments]    ${channels}    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=600s
    ...            ${Teardown_after_finished}=${True}    ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/
    ...            ${log_name}=Aasys_CCS_MCU.txt    ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001
    ...            ${aa_sys_udp_port}=0xC738    ${filter}=${EMPTY}    ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}    timeout=${duration}
    ${begin_value}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    FOR    ${index}    IN RANGE    43
        ${step_pa_value}    Evaluate    ${index}+${begin_value}[0]
        Set PA Value For Attenuation Channels    channels=${channels}    pa_value=${step_pa_value}
        sleep    1s
    END
    Start Bip Log with Suitable Means
    FOR    ${index}    IN RANGE    43    53
        ${step_pa_value}    Evaluate    ${index}+${begin_value}[0]
        Set PA Value For Attenuation Channels    channels=${channels}    pa_value=${step_pa_value}
        sleep    1s
    END
    ${bip_file}    Stop Bip Log with Suitable Means
    set test variable    ${bip_log_path}    ${bip_file}[0]
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'
    ...           Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                  host=${host}    username=${username}    password=${password}

Check CPRT Log Result
    [Arguments]    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log    ${gain_value}=-138    ${pSRSact}=true
    ...    ${occasiondelay}=98    ${runum_row}=8    ${runum_col}=2    ${num_row}=NUMBEROFCOLTRX_8    ${num_col}=NUMBEROFROWTRX_2
    ${output1}    get_value_from_log_file    file_path=${file_path}    check_item="gainCorrection":(\\S\\d*)
    ${output2}    get_value_from_log_file    file_path=${file_path}    check_item="pSRSact":(\\w{4,10})
    ${output3}    get_value_from_log_file    file_path=${file_path}    check_item="occasionDelay":(\\d{1,10})
    ${output4}    get_value_from_log_file    file_path=${file_path}    check_item="ruNumOfTrxInRow":(\\d)
    ${output5}    get_value_from_log_file    file_path=${file_path}    check_item="ruNumOfTrxInColumn":(\\d)
    ${output6}    get_value_from_log_file    file_path=${file_path}    check_item="numberOfColTRX":"(\\w{8,20})
    ${output7}    get_value_from_log_file    file_path=${file_path}    check_item="numberOfRowTRX":"(\\w{8,20})
    Should Contain    ${output1}    ${gain_value}
    Should Contain    ${output2}    ${pSRSact}
    Should Contain    ${output3}    ${occasiondelay}
    Should Contain    ${output4}    ${runum_row}
    Should Contain    ${output5}    ${runum_col}
    Should Contain    ${output6}    ${num_row}
    Should Contain    ${output7}    ${num_col}


UE Check DL Traffic
    [Arguments]    ${ue_index}=${0}    ${dl_target}=${1400}    ${duration}=300s
    ${ue_type}    Get UE type    ue_index=${ue_index}
    ${full_log_path}    power_ue.Collect Tput    ue_index=${ue_index}    ue_type=huawei    duration=${duration}
    power_ue.Check Tput    ue_type=huawei    direction=dl    cells=${cellid}
    ...    target_throughput=${dl_target}    log=${full_log_path}    target_avg_percent=0.98
