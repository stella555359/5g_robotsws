*** Settings ***
Documentation   This is common keyword for CB007094 cases WebEM part.
...              Author: Zhe Lin
...              Contact: zhe.1.lin@nokia-sbell.com
...              Squard: HZ SG7
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Resource   ../../UUF/Resource/webui_coam.robot
Resource   ../../UUF/Resource/common.robot
Resource   ../../common/L3_Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library   taf.transport.ssh   WITH NAME   csn
Library    taf.ul.parser.pcap   WITH NAME   wireshark
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Variables  ../../libraries/global_vars.py

*** Variables ***
${index_list}    7
${coam_alias}    COAM
${fetch}    TX =
${bip_log_path}    /home/ute/zhe/bip
${tshark_path}    /usr/bin/tshark
${MRBTS_ID}   ${tl.gnbs[0].global_bts_id}
${instance_id}    ${tl.gnbs[0].instance_id}
${lua_script}    lua_script:/home/ute/zhe/bip/luashark/
${command_1st_part}    /usr/bin/tshark -r {input_file} -X
${command_2nd_part}    -Y "dldata_pdschsendreq" -T pdml > {output_file}
*** Keywords ***

Set artificial status and check BTS status
    [Arguments]    ${arti_load}
    #${MRBTS_ID}   selenium_coam.get_bts_id
    ${arti_MCS}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${instance_id}/NRCELL-1
    ...    filter_param=MCS index for artificial load
    ${arti_load_value}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${instance_id}/NRCELL-1
    ...   filter_param=Target total load with artificial load
    Run Keyword If   '${arti_load_value}'!='${arti_load}'    modify artificial load    arti_load=${arti_load}
    ${bts_status}    selenium_coam.get_bts_status
    Log to Console    artificial load is set to ${arti_load}, gnb is ${bts_status}


modify artificial load
    [Arguments]    ${arti_load}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${instance_id}/NRCELL-1
    ...    filter_param=Target total load with artificial load    new_value=${arti_load}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

RF TX output
    ${NoArti_TX}   Create List
    COAM Login    alias=${coam_alias}
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=ASIK
    Connect to RU With Allocated IP    ru_alias=RU_1   asik_alias=ASIK   connection=${coam_alias}
    csn.Connect to   hostname=192.168.100.3   username=root   password=w@=EIj7P6R0bVy85OjCVa^ho&8   proxy=RU_1   alias=RU3
    FOR   ${index}   IN RANGE  8
        ${TX_power}   csn.Execute   command=dapd -stat ${index} | grep TX    connection=RU3
        ${TX_power_value}    fetch from right    ${TX_power}    ${fetch}
        ${TX_value}    Strip String    ${TX_power_value}    characters=\r\n
        Append To List   ${NoArti_TX}   ${TX_value}
    END
    csn.Disconnect   connection=ASIK
    COAM Logout
    [Return]    ${NoArti_TX}

TX calculation
#    ${Arti_TX}    create list
#    ${NoArti_TX}    create list
    [Arguments]    ${Arti_TX}    ${NoArti_TX}
    ${TX_Diff}    create list
    FOR   ${index}   IN RANGE  8
        ${a}    set variable    ${Arti_TX}[${index}]
        ${b}    set variable    ${NoArti_TX}[${index}]
        ${TX_Diff_Value}    Evaluate     ${a}- ${b}
        Append To List   ${TX_Diff}    ${TX_Diff_Value}
        Should be true    ${TX_Diff}[${index}] > 5
    END

Collect and Download BIP with L3 call
    [Arguments]    ${call_enable}=${true}
    COAM Login    alias=GNB_OAM
    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=bip
    Bip Capture with gnbMirroring scripts with retry    connection=bip   filtering=dldata_pdschsendreq
    Run keyword if    '${call_enable}' == '${true}'    Run keyword and ignore error  UE attach and start traffic    tput=1000M
    csn.Connect To   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=asik
#   This connect to is used for stop bip, last bip connection is stopped by call
    ${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${bip_log_path}    connection=asik
    Stop UE traffic
    Run keyword and ignore error    COAM Logout   connection=GNB_OAM
    csn.disconnect    connection=bip
    [Return]    ${bip_log}

Set Command Filter
    ${gnb_release}   Get gnb release
    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS22R2
    ...   ELSE   set variable   ${gnb_release}
    ${luashark_version}    Run keyword if   '${gnb_release}'=='TRUNK'   set variable    generated_luashark_22R2/
    ...   ELSE IF   '${gnb_release}'=='SBTS22R1'    set variable    generated_luashark_22R1/
    ...   ELSE   set variable    generated_luashark_21B/
    [Return]    ${luashark_version}

Get Value from Pcap
    [Arguments]    ${input_file}    ${xpath}
    ${luashark_path}    Set Command Filter
    ${command_filter}    set variable   ${command_1st_part} ${lua_script}${luashark_path}luashark.lua ${command_2nd_part}
    log to console    ${command_filter}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${input_file}    command_template=${command_filter}
    ${tshark_value}    wireshark.get_field_value_by_xpath    pdml_list=${all_packets}   xpath=${xpath}
    [Return]   ${tshark_value}

#Filter Pcap
#    [Arguments]    ${input_file}    ${filter}
#    ${all_packets}    wireshark.load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
#    ...    luashark_path=${luashark_path}
#    ${filter_packets}    wireshark.filter_packets_by_expression    filter_expression=${filter}
#    [Return]   ${filter_packets}

Stop UE traffic
    [Arguments]    ${ue_index}=0    ${tput}=300
    ${ue_type}    Get UE type    ${ue_index}
    Run keyword and ignore error    power_ue.Check Throughput    ue_type=${ue_type}   direction=DL   throughput=${tput}
    ...   ue_index=${ue_index}
    sleep   5s
    Stop Traffic and Detach    ue_type=${ue_type}   direction=DL    ue_index=${ue_index}

Get UE type
    [Timeout]   30s
    [Arguments]    ${ue_index}=0
    ${ue_type}   ue.get_ue_type   ${tl.ues[${ue_index}]}
    [Return]   ${ue_type}

UE attach and start traffic
    [Arguments]    ${ue_index}=0    ${4G_check}=${true}    ${tput}=300M    ${duration}=60s
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    Sleep   2 s
    Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=${4G_check}
    log to console    start traffic
    power_ue.Start traffic   ue_type=${ue_${ue_index}_type}   direction=DL   throughput=${tput}   duration=${duration}
    run keyword and ignore error   power_ue.Check throughput   ue_type=${ue_${ue_index}_type}   direction=DL
    ...    throughput=${tput}

RM BIP LOG in VM
    RUN    rm ${bip_log_path}/tcpdump_L2L1_*
