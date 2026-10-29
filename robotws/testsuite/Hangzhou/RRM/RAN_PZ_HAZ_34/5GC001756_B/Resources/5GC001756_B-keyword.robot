*** Settings ***
Documentation     author: Shenrao
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shushu.huang@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
Library    taf.analyzer.pcap   WITH NAME   pcap
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot


*** Variables ***

${dltp}    10
${ultp}    5
${OAM_IP}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_LOGIN}                     toor4nsn
${DU_PASSWORD}                  oZPS0POrRieRtu
${gnb_path}    /tmp/
${epc_log_path}    /home/ute/testcase
${filter}    /usr/bin/tshark -r {input_file} -Y  "nsetapx" -T pdml > {output_file}

*** Keywords ***
Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=COAM

Suite teardown
    admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}

Reboot UE for NSA
    _Prepare Variables    ue_index=${0}
     csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${0}
    _Reboot_UE    connection=cpc_${0}
    csn.disconnect      connection=cpc_${0}

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

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=gnb
    csn.Connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Connect to DU
    ssh.connect_to              hostname=${OAM_IP}      username=${DU_LOGIN}        password=${DU_PASSWORD}    alias=ASIL_Mater

Disconnect from DU
    ssh.disconnect    connection=ASIL_Mater

Check ESTABLISHED Not Empty
    [Arguments]   ${connection}=COAM
    ${output}    csn.execute    netstat -ant|grep 48151 |grep 10.68.90.147 | awk '{print $4}'| tail -n 1    connection=ASIL_Mater
    Should not be empty    ${output}


Modify actPCMDReport
    [Arguments]    ${actPCMDReport}
    BuiltIn.Log    Modify actPCMDReport paramter...     console=${True}
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-917/NRBTS-917    parameter=actPCMDReport
    ...    operation=update    value=${actPCMDReport}    connection=COAM
    [Teardown]    Teardown cOAM session

Start Capture PCMD Tcpdump Logs
    [Arguments]    ${PCMDlogname}    ${ip_addr}=${asik_addr}    ${gnb}=gnb    ${interface}=br0
    RUN KEYWORD AND IGNORE ERROR    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Start To Capture Wireshark Logs    filename=${PCMDlogname}    connection=${gnb}    interface=${interface}

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${filename}    connection=${connection}

Stop and Save Logs
    [Arguments]    ${PCMDlogname}    ${ip_addr}=${asik_addr}    ${gnb}=gnb
    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Stop and download Logs    logname=${PCMDlogname}    connection=${gnb}

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}/${logname}   connection=${connection}
    sleep    3

Start UL traffic
    [Arguments]    ${UE_TYPE}=samsung    ${direction}=ul    ${throuthput}=120M    ${protocol}=udp    ${ul_tp}=${120}    ${dl_tp}=${600}
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=${direction}   throughput=${throuthput}    duration=180
    ...    iperf_type=via_command    ue_index=${0}    protocol=${protocol}
   sleep    15s
    Log To Console    \n ###UE Stop UDP UL traffic
    power_ue.Stop traffic    direction=${direction}    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command


Analysis Avg_SINR PCMD trace
    ${all_packets}=    pcap.load_pcap_file    command_template=${filter}    pcap_file=${epc_log_path}/${PCMDlogname1}

    ${sumOfSinrSamples_Fliter} =  Catenate    nsetapx.sumOfSinrSamples
    ${sumOfSinrSamples} =    pcap.filter_packets_by_expression
    ...    filter_expression=${sumOfSinrSamples_Fliter}
    ${sumOfSinrSamples_value} =    pcap.get_field_value_by_xpath    pdml_list=${sumOfSinrSamples}    xpath=.//nsetapx.sumOfSinrSamples
    ${number1}    Get Length    ${sumOfSinrSamples_value}
    FOR    ${i}    IN RANGE    ${number1}
        ${value1}    set variable    ${sumOfSinrSamples_value[${i} ]}
        Should Be True    ${value1} > 0
    END

    ${numOfSinrSamples_Fliter} =  Catenate    nsetapx.numOfSinrSamples
    ${numOfSinrSamples} =    pcap.filter_packets_by_expression
    ...    filter_expression=${numOfSinrSamples_Fliter}
    ${numOfSinrSamples_value} =    pcap.get_field_value_by_xpath    pdml_list=${numOfSinrSamples}    xpath=.//nsetapx.numOfSinrSamples
    ${number2}    Get Length    ${numOfSinrSamples_value}
    FOR    ${i}    IN RANGE    ${number2}
        ${value2}    set variable    ${numOfSinrSamples_value[${i}]}
        Should Be True    ${value2} > 0
    END

Analysis InitialTA PCMD trace
    ${all_packets}=    pcap.load_pcap_file    command_template=${filter}    pcap_file=${epc_log_path}/${PCMDlogname2}

    ${taData_Fliter} =  Catenate    nsetapx.taData
    ${taData} =    pcap.filter_packets_by_expression
    ...    filter_expression=${taData_Fliter}
    ${taData_value} =    pcap.get_field_value_by_xpath    pdml_list=${taData}    xpath=.//nsetapx.taData
    ${number1}    Get Length    ${taData_value}
    Should Be True    ${number1}==1


teardown
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

