*** Settings ***
Documentation
...    author: fraxu
...    contact: frank.1.xu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Library    taf.analyzer.pcap   WITH NAME   pcap
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
#Library    Resources/calc.py
Library    Collections
Library    taf.pdu
Library    String
Library    Process
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py

Resource          ../../common/taf_coam.robot
Resource          ../../common/coam_resource.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource         ../../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_keywords.robot
#Resource         ../../../../../../resources/sites/Ulm/Common/pmcounters.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot

*** Variables ***

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${file_name}    ue_attach.pcap
${x2_log_path}    /home/ute/testcase
${filter}    /usr/bin/tshark -r {pcap_file} -Y  "x2ap" -T pdml
${full_path}    BTS/NRBTS-${nrbts_id}/NRDU-1/NF1UD
${nrbts_id}    917

${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${TSHARK_SgNBReleaseRequest}    ${TSHARK_5GC000776_COMMON} -T fields -e x2ap.SgNBReleaseRequest_element
${TSHARK_SgNBReleaseRequest_pdml}    ${TSHARK_5GC000776_pdml} -T fields -e x2ap.SgNBReleaseRequest_element
${TSHARK_5GC000776_COMMON}    /usr/bin/tshark -r {pcap_file} -X lua_script:{luashark_path} -Y  \"x2ap\"
${TSHARK_5GC000776_pdml}    /usr/bin/tshark -r ${x2_log_path}/${file_name} -X lua_script:${luashark_path} -Y  \"x2ap\"


*** Keywords ***
Check GNB on air
    Log    \nStep1:Check GNB cell on air    console=yes
    Check GNB cell on air
    Enable Counter collect

Modify the parameter actNonGbrServiceDiff and actMultiDrbNSA to true
    log to console    change actNonGbrServiceDiff to true and check
    Set parameter actNonGbrServiceDiff  key=actNonGbrServiceDiff    value=${true}
    log to console    change actMultiDrbNSA to true and check
    Set parameter actMultiDrbNSA   key=actMultiDrbNSA    value=${true}
    log to console    change MRBTS-917/NRBTS-917/NRDRB-4 schedulWeight to 10  and check
    Set parameter QCI7 schedulWeight    key=schedulWeight    value=${10}
    log to console    change MRBTS-917/NRBTS-917/NRDRB-6 schedulWeight to 1  and check
    Set parameter QCI9 schedulWeight   key=schedulWeight    value=${1}

2 UE send full UDP UL data and full UDP DL data
    log to console    \n *** Step 2: 2 UE check UDP UL throughput ***\n
    2UE L3 call start
    Start Capture wireshark log
    2UE Start UL traffic       direction=ul    throuthput=120M    protocol=udp
    2UE Start DL traffic       direction=dl    throuthput=600M    protocol=udp
    Check none release and Stop call

Check the PDCP PM counters to verify the average DL and UL Rate Ratio of the 2 UE
    log to console    Step 4: Check the DL and UL PDCP PM counters
    Check DL PDCP PM counter M55314C02007
    Check DL PDCP PM counter M55314C02009
    Check UL PCDP PM counter M55314C04007
    Check UL PCDP PM counter M55314C04009


Enable Counter collect
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    ${reportingIntervalPm}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    run keyword if    "${reportingIntervalPm}" != "5min"     Set reportingIntervalPm to 5min
    ...    ELSE    log   Already 5min!
    ${reportingIntervalPm_1}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    sleep    ${reportingIntervalPm_1}

2UE Start UL traffic
    [Arguments]    ${UE_TYPE}=samsung    ${direction}=ul    ${throuthput}=120M    ${protocol}=udp    ${ul_tp}=${120}    ${dl_tp}=${600}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=180
    ...    iperf_type=via_command    ue_index=${0}    protocol=${protocol}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=180
    ...    iperf_type=via_command    ue_index=${1}    protocol=${protocol}

   sleep    120

    #Log To Console    \n ###UE Stop UDP UL traffic###
    power_ue.Stop traffic    direction=${direction}    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
    power_ue.Stop traffic    direction=${direction}    ue_index=${1}    ue_type=${UE_TYPE}    iperf_type=via_command

2UE Start DL traffic
    [Arguments]    ${UE_TYPE}=samsung    ${direction}=ul    ${throuthput}=120M    ${protocol}=udp    ${ul_tp}=${120}    ${dl_tp}=${600}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=180
    ...    iperf_type=via_command    ue_index=${0}    protocol=${protocol}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=180
    ...    iperf_type=via_command    ue_index=${1}    protocol=${protocol}

    sleep    120

    #Log To Console    \n ###UE Stop UDP DL traffic###
    power_ue.Stop traffic    direction=${direction}    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
    power_ue.Stop traffic    direction=${direction}    ue_index=${1}    ue_type=${UE_TYPE}    iperf_type=via_command


Check DL PDCP PM counter M55314C02007
    [Arguments]    ${counter_id}=M55314C02007    ${full_path}=full    ${date}=all    ${connection}=COAM
    Connect to gnb coam via ssl    connection=COAM
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${full_path}    date=${date}
    ${len}    get length  ${counter_value}
    [Return]    ${counter_value}

Check DL PDCP PM counter M55314C02009
    [Arguments]    ${counter_id}=M55314C02009    ${full_path}=full    ${date}=all    ${connection}=COAM
    Connect to gnb coam via ssl    connection=COAM
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${full_path}    date=${date}
    ${len}    get length  ${counter_value}
    [Return]    ${counter_value}

Check UL PCDP PM counter M55314C04007
    [Arguments]    ${counter_id}=M55314C02009    ${full_path}=full    ${date}=all    ${connection}=COAM
    Connect to gnb coam via ssl    connection=COAM
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${full_path}    date=${date}
    ${len}    get length  ${counter_value}
    [Return]    ${counter_value}

Check UL PCDP PM counter M55314C04009
    [Arguments]    ${counter_id}=M55314C02009    ${full_path}=full    ${date}=all    ${connection}=COAM
    Connect to gnb coam via ssl    connection=COAM
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${full_path}    date=${date}
    ${len}    get length  ${counter_value}
    [Return]    ${counter_value}


#    [Arguments]    ${full_path}=BTS/NRBTS-${nrbts_id}/NRDU-1/NF1UD
#    Check PM counter Result    full_path=${full_path}    counter_id=M55314C02007
#    Check PM counter Result    full_path=${full_path}    counter_id=M55314C02009

Check PM counter Result
    [Arguments]    ${counter_id}    ${full_path}=full
    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
    List Should Contain Value    ${counter_result}
#    :For    ${i}    IN    @{counter_result}
#    \    Exit for loop if    ${i}==${Scheduled_UE_num}

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}=full   ${date}=all    ${connection}=COAM
    Connect to gnb coam via ssl    connection=COAM
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}

#Connect to gnb coam via ssl
#    [Arguments]  ${connection}=COAM    ${gnb_index}=0
#    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
#    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
#    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
#    ...   name=${connection}

Check UL PCDP PM counters
    [Arguments]    ${full_path}=BTS/NRBTS-${nrbts_id}/NRDU-1/NF1UD
    Check PM counter Result    full_path=${full_path}    counter_id=M55314C04007
    Check PM counter Result    full_path=${full_path}    counter_id=M55314C04009

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1
    log to console    ${counter_id}    ${dic_path}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${dic_path}    date=${date}
    ${len}    get length  ${counter_value}
    should be true  ${len} > ${min_len}
    [Return]    ${counter_value[0]}


Set reportingIntervalPm to 5min
    COAM Update Parameter    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=5min
    sleep    30s

#COAM Update Parameter
#    [Arguments]   ${dist_name}   ${parameter}   ${value}   ${connection}=COAM
#    coam.perform_parameter_recommissioning   dist_name=${dist_name}   parameter=${parameter}   value=${value}
#    ...   operation=update
#    ...   skip_parameter_relation_errors=${true}
#    ...   should_activate=${true}
#    ...   timeout=60
#    ...   connection=${connection}

Check GNB cell on air
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

#COAM Check Dedicated Cell Status
#    [Arguments]   ${status}
#    Should Contain   ${status['proceduralStatus']}   configured
#    Should Contain   ${status['availabilityStatus']}   Online
#    Should Contain   ${status['operationalState']}   Enabled
#    Should Contain   ${status['usageState']}   Active

#COAM Check All Cells Onair
#    [Arguments]   ${connection}=COAM
#    ${cell_list}   COAM Get Cell List   connection=${connection}
#    :FOR   ${cell}   IN   @{cell_list}
#       ${status}   Set Variable   ${cell['status']}
#       Run Keyword and Continue on Failure   COAM Check Dedicated Cell Status   status=${status}
#    END

#COAM Get Cell List
#    [Arguments]   ${connection}=COAM
#    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
#    ${cell_list}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
#    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
#    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
#    [Return]   ${cell_list}

Set parameter
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter actNonGbrServiceDiff
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter actMultiDrbNSA
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter QCI7 schedulWeight
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917/NRDRB-4
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

Set parameter QCI9 schedulWeight
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-917/NRBTS-917/NRDRB-6
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

teardown
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=samsung
    CI_interface.Common Case Teardown

Start Capture wireshark log
    [Arguments]    ${enb_index}=0
    ...    ${host}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${file_name}=ue_attach.pcap
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=LTEenb
    csn.Execute    command=rm -rf /tmp/${file_name}    connection=LTEenb
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}' |xargs kill -9    connection=LTEenb
    #Should be empty    ${output}
    ${cmd}=    catenate    tcpdump -i br1 -w /tmp/${file_name} &>/dev/null &
    csn.send command    command=${cmd}    connection=LTEenb
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'    connection=LTEenb
    Should not be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=LTEenb

Stop Capture wireshark log
    [Arguments]    ${enb_index}=0
    ...    ${host}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=LTEenb
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep |awk '{print $2}'    connection=LTEenb
    #Should not be empty    ${output}
    ${output}    csn.execute    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'|xargs kill -9    connection=LTEenb
    Should be empty    ${output}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=LTEenb

Download wireshark Log To TestPC
    [Arguments]    ${enb_index}=0
    ...    ${host}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}
    csn.Connect To     hostname=${host}    username=${username}    password=${password}    alias=LTEenb
    csn.Download file    remote_path=/tmp/${file_name}    local_path=${x2_log_path}/${file_name}   connection=LTEenb
    csn.execute    command=rm -rf /tmp/${file_name}     connection=LTEenb
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=LTEenb

2UE L3 call start
    L3 call start    ue_index=0    #throughput_ul=120M    throughput_dl=600M
    L3 call start    ue_index=1    #throughput_ul=120M    throughput_dl=600M

Connect and Modify the parameter on enblte skip errors
    log to console    change MRBTS-239/LNBTS-239/LNCEL-1 defaultLnRelGnbCellId to 7 and check
    enb_lte.Connect to eNB via ssl
    Set parameter defaultLnRelGnbCellId to 7    key=defaultLnRelGnbCellId    value=${7}

enb_lte.Connect to eNB via ssl
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
    enblte.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}


Modify the parameter on enblte and skip errors
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    ...                                            skip_parameter_relation_errors=True

Set parameter defaultLnRelGnbCellId to 7
    [Arguments]  ${key}    ${value}    ${dict_name}=MRBTS-239/LNBTS-239/LNCEL-1
    enblte.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=enblte
    sleep    60s


Check none release and Stop call
    Check none release
    L3 call stop    ue_index=0
    L3 call stop    ue_index=1

Check none release
    stop Capture wireshark log
    Download wireshark Log To TestPC
    check none_release_require

Check 2UE throughput
    [Arguments]    ${UE_TYPE}=samsung    ${direction}=ul    ${throuthput}=120M    ${protocol}=udp    ${ul_tp}=${100}    ${dl_tp}=${450}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=900
    ...    iperf_type=via_command    ue_index=${0}    protocol=${protocol}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=900
    ...    iperf_type=via_command    ue_index=${1}    protocol=${protocol}

    sleep    600
    run keyword if    '${direction}'=='ul'    check throughput for ul    ultp=${ul_tp}
    run keyword if    '${direction}'=='dl'    check throughput for dl    dltp=${dl_tp}

    #Log To Console    \n ###UE Stop UDP UL traffic###
    power_ue.Stop traffic    direction=${direction}    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
    power_ue.Stop traffic    direction=${direction}    ue_index=${1}    ue_type=${UE_TYPE}    iperf_type=via_command


check throughput for ul
    [Arguments]    ${ultp}=${100}    ${cell_id}=${31129601}    ${ul_throughput}=${0}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_ul.txt

    FOR    ${index}    IN RANGE    0    2
        ${ul_throughput_tmp}    Caculate UL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${${cell_id}+${index}}
        ${ul_throughput}=    Evaluate    ${ul_throughput}+${ul_throughput_tmp}
    END

    Log to console    ul_throughput = ${ul_throughput}
    Run keyword and continue on failure    should be true    ${ul_throughput} > ${ultp}

check throughput for dl
    [Arguments]    ${dltp}=${450}    ${cell_id}=${31129601}    ${dl_throughput}=${0}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_dl.txt

    FOR    ${index}    IN RANGE    0    8
        ${dl_throughput_tmp}    Caculate DL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${${cell_id}+${index}}
        ${dl_throughput}=    Evaluate    ${dl_throughput}+${dl_throughput_tmp}
    END

    Log to console    dl_throughput = ${dl_throughput}
    Run keyword and continue on failure    should be true    ${dl_throughput} > ${dltp}


L3 call stop
    [Arguments]    ${UE_TYPE}=samsung    ${dltp}=${0}    ${ultp}=${0}    ${4G_check}=${True}    ${ue_index}=${0}    ${Cell_id}=${51}

    #Log To Console    \n ###UE Stop traffic###
    #power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}
    #power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}


check none_release_require
     ${SgNBReleaseRequest}    Get value from output pdml files    file_path=${x2_log_path}/${file_name}
     ...    command_template=${TSHARK_SgNBReleaseRequest}    command_to_convert_pdml=${TSHARK_SgNBReleaseRequest_pdml}
    should be true    len(${SgNBReleaseRequest}) == 0



teardown_multi_ue
    [Arguments]    ${UE_TYPE}=samsung
    log to console    \n in teardown stage
    run keyword and ignore error    admin_cli.teardown    connection=LTEenb
    Log To Console    \n ###UE Stop UDP UL traffic###
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
    power_ue.Stop traffic    direction=ul    ue_index=${1}    ue_type=${UE_TYPE}    iperf_type=via_command
    Log To Console    \n ###UE Stop UDP DL traffic###
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.Stop traffic    direction=dl    ue_index=${1}    ue_type=${UE_TYPE}

    L3 call stop    ue_index=0
    L3 call stop    ue_index=1


###KW for call#####
L3 call start
    [Arguments]    ${UE_TYPE}=samsung    ${4G_check}=${True}    ${ue_index}=${0}    #${throughput_ul}=120M    ${throughput_dl}=600M
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}    ue_index=${ue_index}


Making call and check TP for one UE
    [Arguments]    ${throughput_ul}=150M    ${throughput_dl}=1500M      ${call_duration}=90    ${cell_id}=14843905
    ...     ${4G_check}=${False}    ${UE_TYPE}=samsung     ${ue_index}=${0}      ${ultp}=${20.0}    ${dltp}=${1000.0}
    ...     ${protocol}=udp
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}    ue_index=${ue_index}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul  throughput=${throughput_ul}
    ...    iperf_type=via_command    ue_index=${ue_index}    protocol=${protocol}
    ...    duration=999999999
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl  throughput=${throughput_dl}
    ...    iperf_type=via_command    ue_index=${ue_index}    protocol=${protocol}
    ...    duration=999999999
    Log To Console    \n ### Wait for call###
    sleep     3s
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    aasyslog.Aasyslog Precondition     gnb_index=${0}    du_index=${0}
    Run keyword and continue on failure    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_ul.txt
    ${ul_throughput_tmp}    Run keyword and continue on failure
    ...    Caculate UL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${cell_id}    sleep_time=${call_duration}
    Run keyword and continue on failure    should be true    ${ul_throughput_tmp} > ${ultp}
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    aasyslog.Aasyslog Precondition     gnb_index=${0}    du_index=${0}
    Run keyword and continue on failure    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2Lo   log_name=data_dl.txt
    ${dl_throughput_tmp}    Run keyword and continue on failure
    ...    Caculate DL throughput on gnb L2Lo with re    log_type=Aasyslog    cellid=${cell_id}    sleep_time=${call_duration}
    Log to console    ul_throughput = ${ul_throughput_tmp}     dl_throughput = ${dl_throughput_tmp}
    Run keyword and continue on failure    should be true    ${dl_throughput_tmp} > ${dltp}
    [Teardown]   Run Keywords    Run Keyword And Ignore Error
       ...    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
       ...    AND   Run Keyword And Ignore Error
       ...    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
       ...    AND   Run Keyword And Ignore Error
       ...    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}




