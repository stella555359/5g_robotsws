*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Ragunath Seenan
...              :contact: ragunath.seenan@nokia.com

Variables    ta5g_global_var

Resource         ../../../../resources/robot/common_log_collection.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Resource         ../../../../resources/robot/Iperf_Traffic.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../../resources/robot/TTI_Traces.robot
Resource         ../../../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource         ../../../../resources/robot/Airphone.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Resource         ../../../../resources/ECEcommon/common_setup_teardown.robot

Library          BuiltIn
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library          ute_admin                         WITH NAME   ute_adm
Library          Collections
Library          OperatingSystem
Library          ta5g_tshark
Library          ta5g_commissioning
Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library          taf.transport.ssh                 WITH NAME    csn
Library          String
Library          SSHLibrary
Library          ./python/execute_command.py
Library          ../../../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../../../resources/NPS/SWENG/python_libs/luashark_tools.py
Library          ../../../../resources/python/BIP_Capture.py
Library          ../../../../resources/python/CPRT_Capture.py
Library          ./python/avg_ue_stats.py
Library          ./python/read_csv.py

*** Variables ***
${port}                    22
${ymlUteLinuxTrimCrLf}
${on_air}   Cell Setup completed
@{tcpboostpugstate}       TCP Data Indication from L2-LO Status:PUGACTIVATE
...                       entering state: pugIdleState
...                       entering state: pugRampupInitialWaitState
...                       CS1 Entry for TCP PUG
...                       entering state: pugRampupState
...                       entering state: pugStableState
@{tcpboostpugstate1}      CS1 Entry for TCP PUG
...                       TCP Data Indication from L2-LO Status:PUGACTIVATE
@{tcpboostpugstaternti}    rnti:\${uernti}, TCP Data Indication from L2-LO Status:PUGACTIVATE
...                        rnti:\${uernti}, entering state: pugIdleState
...                        rnti:\${uernti}, entering state: pugRampupInitialWaitState
...                        rnti:\${uernti}, entering state: pugRampupState
...                        rnti:\${uernti}, entering state: pugStableState

#...                       TCP Data Indication from L2Hi Status:Deactivate

*** Keywords ***

Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Verify DL Ping Traffic
    [Arguments]    ${ip}    ${ue_id}    ${scell_idx}    ${ping_unit}    ${exp_dl_avg_ping}
    [Documentation]    Verify Ping Traffic between TCP Client and Server
    Log to Console    Verify DL Ping Traffic between TCP Client and Server
    ${ping_process}=   Start Process    ping ${ip}    shell=True    stdout=/tmp/ping_stdout.txt   alias=myproc
    ${ping_ue_stats}    Validate AVG DL DATA TRAFFIC in UE STATS    ${ue_id}    ${scell_idx}    ${ping_unit}    ${exp_dl_avg_ping}
    ${result}=    Terminate Process    ${ping_process}
    [Return]      ${ping_ue_stats}

Verify UL Ping Traffic
    [Arguments]    ${ip}    ${ue_id}    ${scell_idx}    ${ping_unit}    ${exp_ul_avg_ping}
    [Documentation]    Verify Ping Traffic between TCP Client and Server
    Log to Console    Verify UL Ping Traffic between TCP Client and Server
    ${ping_process}=   Start Process    ping ${ip}    shell=True    stdout=/tmp/ping_stdout.txt   alias=myproc
    ${ping_ue_stats}    Validate AVG UL DATA TRAFFIC in UE STATS    ${ue_id}    ${scell_idx}    ${ping_unit}    ${exp_ul_avg_ping}
    ${result}=    Terminate Process    ${ping_process}
    [Return]      ${ping_ue_stats}

Start Ping Traffic
    [Arguments]    ${ip}
    [Documentation]    Start Ping Traffic between TCP Client and Server
    ${ping_process}=   Start Process    ping ${ip}    shell=True    stdout=/tmp/ping_stdout.txt   alias=myproc
    [Return]      ${ping_process}

Stop Ping Traffic
    [Arguments]    ${ping_process}
    [Documentation]    Stop Ping Traffic between TCP Client and Server
    ${result}=    Terminate Process    ${ping_process}
    [Return]      ${result}

Check Cell On Air
    [Arguments]    ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                   file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=${on_air}     timeout=240

UE Register should be Successful with External Trf Type
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}      ${gw_id}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=external
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

MultiUE Register should be Successful with External Trf Type
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    Log to Console     UE Register with Trf type external
    ${crnti_list}       Create List
    set global variable   ${crnti_list}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=external
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

Store UE STATS OUTPUT
    [Arguments]    ${unit}
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Log to Console    ${output}
    should contain    ${output}    Average
    should contain    ${output}    ${unit}
    [Return]      ${output}

Match PDSCH UE Stats
    [Arguments]    ${ue_id}    ${scell_idx}    ${unit}
    Log to Console    PDSCH UE stats for given CC
    Sleep    30s
    wtsrunner.ue_stats_nr   id=${ue_id}    scell=${scell_idx}    type=pdsch
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    Store UE STATS OUTPUT    ${unit}
    Get Lines Matching Regexp    ${output}    NR PDSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}

Match PUSCH UE Stats
    [Arguments]    ${ue_id}    ${scell_idx}    ${unit}
    Log to Console    PUSCH UE stats for given CC
    Sleep    60s
    wtsrunner.ue_stats_nr   id=${ue_id}    scell=${scell_idx}    type=pusch
    wtsrunner.ue_stats_nr   id=${ue_id}    scell=${scell_idx}    type=pdsch
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    Store UE STATS OUTPUT    ${unit}
    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}

Validate AVG DL DATA TRAFFIC in UE STATS
    [Arguments]    ${ue_id}    ${scell_idx}     ${unit}    ${exp_dl_avg}
    ${pdsch_ue_stats}    Match PDSCH UE Stats    ${ue_id}    ${scell_idx}    ${unit}
    ${avg_tput}   avg_ue_stats.get_avg_dl_data_traffic    ${pdsch_ue_stats}    ${unit}
    Log to Console    ${avg_tput}
    Log to Console    ${exp_dl_avg}
    [Return]      ${avg_tput}

Validate AVG UL DATA TRAFFIC in UE STATS
    [Arguments]    ${ue_id}    ${scell_idx}     ${unit}    ${exp_ul_avg}
    ${pusch_ue_stats}    Match PUSCH UE Stats    ${ue_id}    ${scell_idx}    ${unit}
    ${avg_tput}   avg_ue_stats.get_avg_ul_data_traffic    ${pusch_ue_stats}    ${unit}
    Log to Console    ${avg_tput}
    Log to Console    ${exp_ul_avg}
    [Return]      ${avg_tput}

Verify TCP Boost Grant event in ulPreSchedData
    [Arguments]    ${csvFile}
    Log to Console     Verifying ULTCPBOOSTGRANT in ttitrace
    ${x}=    check_ultcpboostgrant    ${csvFile}
    Should Contain    ${x}    Pass
    [Return]      ${x}

Verify ResReqClassPrio in ulTdSchedSubcellData
    [Arguments]    ${csvFile}
    Log to Console     Verifying ResReqClassPrio in ttitrace
    ${y}=    check_resReqClassPrio    ${csvFile}
    Should Contain    ${y}    Pass
    [Return]      ${y}

Verify TCP Indication and PUG entry in syslog
    [Arguments]    ${syslog}
    Log to Console     Verifying PUG events in syslog
    ${status} =   run    command=sudo cat ${syslog} | grep "TCP Data Indication\\|CS1 Entry\\|state: pug"
    FOR   ${item}   IN    @{tcpboostpugstate}
        should contain    ${status}    ${item}
    END

Verify TCP PUG elgibility check in syslog
    [Arguments]    ${syslog}    ${crnti_list}
    Log to Console     Verifying PUG eligibility check in syslog
    ${status} =   run    command=sudo cat ${syslog} | grep "SrPeriodicity eligibility check fail srPeriodity:20, MinSrPeriodicity:40"
    FOR   ${item}   IN    @{crnti_list}
        should contain    ${status}    ${item}
    END

Verify TCP Boost Traffic entry in Sherpa
    [Arguments]    ${sherpacsv}
    Log to Console     Verifying tcpboosttraffic in sherpa logs
    ${count} =   run    command=sudo cat ${sherpacsv} | grep -c "tcpBoostTraffic"
    Should Not Be Equal    ${count}    ${0}
    Log to Console     Total tcpBoostTraffic entry in sherpa is ${count}

Check PM counter value
    [Arguments]    ${PM_dir}   ${PM_counter}   ${moc}=NRCELL-1
    ${pi_value}=   Get PM counter value   pm_files_location=${PM_dir}   pi_id=${PM_counter}    moc=NRCELL-1
    ${pi_value}=   convert to integer    ${pi_value}
    [Return]    ${pi_value}
    Log to Console    ${moc}

Get and Validate TCP BOOST TOTAL DURATION PM Counter
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Set Suite variable   ${PM_dir1}
    ${M55308C00038}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C00038
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C00038    expected_value=2000

Get and Validate TCP BOOST NUM OF CYCLES PM Counter
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${M55308C00039}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C00039
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C00039    expected_value=1

Get and Validate TCP BOOST PROACTIVE UL GRANTS PM Counter
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${M55308C00040}    Check PM counter value   ${PM_dir1}    PM_counter=M55308C00040
    PM_Counters.Check PM counter value equal or bigger than   expected_value=1   pm_files_location=${PM_dir1}
    ...  pi_id=M55308C00040   moc=NRCELL-1

Add GNB RadParam for CB009409
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x58057f=32" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x58057a=3" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${sa_st_ue_id}    ${sa_en_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    ${ue_to_bearer_list}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${sa_st_ue_id}    ${sa_en_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}=  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${bearer_list}       Create List
    Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}

Create Modify PDU session
    [Arguments]     ${sa_st_ue_id}     ${sa_st_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${sa_st_ue_id}          ${ue_to_bearer_list}=${bearer_list}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${sa_st_ue_id}    ${sa_st_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1
        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}
    END
    log to console  ${gfbr_mfbr_profile}

Add PDU session
     [Arguments]     ${ue_id}      ${pdu_id}      ${gw_id}     ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
     [Documentation]    This keyword starts the ADD PDU  session and modification
        Run Keyword If   ${pdu_id} == 2
        ...     Modified UE PDU Addition should be Successful       ${ue_id}     ${pdu_id}     1   ${gw_id}
       ${x}=   Run Keyword If    ${pdu_id} != ${2}  execute_command.modify_pdu_session_verify     ${ue_id}    ${pdu_id}
       ...     qosflows_to_add=${Q_O_ADD}   ue_to_bearer_list=${ue_to_bearer_list}
        ...    ELSE
        ...    VONR GBR NON GBR Add PDU session    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ue_to_bearer_list=${ue_to_bearer_list}
        Should Contain    ${x}   Pass

Modified UE PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${RAN_UE_NGAP_ID}=      Evaluate    ${ue_id}-${1}
    ${pdu_addition_pattern}=    Set Variable    Pdu Session Resource Setup Response Message with RAN UE NGAP ID
    ${output}=      Read WTS Output For Pattern And Print matching Lines    ${pdu_addition_pattern}    ${Timeout_SA}
    ${str_len}=     Get Length     ${output}
    Should Not Be Equal     ${str_len}      ${0}
    BuiltIn.Log                ue_pdu_addition_is_ok
    sleep    30s

VONR GBR NON GBR Add PDU session
    [Arguments]    ${ue_id}    ${pdu_id}    ${Q_O_ADD}      ${ue_to_bearer_list}=${bearer_list}
      ${check}=		execute_command.modify_pdu_session_verify    ${ue_id}    ${pdu_id}   qosflows_to_add=${Q_O_ADD}
      ...   ue_to_bearer_list=${ue_to_bearer_list}
      Should Contain    ${check}   Pass
      [Return]      ${check}

Verify TCP Boost Grant event in ulPreSchedData for VoNR interaction
    [Arguments]    ${csvFile}
    Log to Console     Verifying ULTCPBOOSTGRANT in ttitrace
    ${output}=    check_ultcpboostgrant    ${csvFile}
    Should not Contain    ${output}    Pass
    [Return]      ${output}

Verify ResReqClassPrio in ulTdSchedSubcellData for VONR interaction
    [Arguments]    ${csvFile}
    Log to Console     Verifying ResReqClassPrio in ttitrace
    ${result}=    check_resReqClassPrio    ${csvFile}
    Should not Contain    ${result}    Pass
    [Return]      ${result}

Verify MultiUE TCP Boost Grant event in ulPreSchedData
    [Arguments]    ${csvFile}    ${crnti_list}
    Log to Console     Verifying ULTCPBOOSTGRANT in ttitrace
    FOR   ${rnti}   IN    @{crnti_list}
        ${x}=    check_multiUEultcpboostgrant    ${csvFile}    ${rnti}
        Should Contain    ${x}    Pass
    END
    [Return]      ${x}

Verify MultiUE ResReqClassPrio in ulTdSchedSubcellData
    [Arguments]    ${csvFile}    ${crnti_list}
    Log to Console     Verifying ResReqClassPrio in ttitrace
    FOR   ${rnti}   IN    @{crnti_list}
        ${y}=    check_multiUEresReqClassPrio    ${csvFile}    ${rnti}
        Should Contain    ${y}    Pass
    END
    [Return]      ${y}

Verify MultiUE TCP Indication and PUG entry in syslog
    [Arguments]    ${syslog}    ${crnti_list}
    Log to Console     Verifying MultiUE PUG events in syslog
    FOR   ${uernti}   IN    @{crnti_list}
        Verify TCP Indication and PUG entry in syslog with RNTI    ${syslog}    ${uernti}
    END

Verify TCP Indication and PUG entry in syslog with RNTI
    [Arguments]    ${syslog}    ${uernti}
    Log to Console     Verifying PUG events in syslog
    ${status} =   run    command=sudo cat ${syslog} | grep "TCP Data Indication\\|state: pug"
    log to console  ${uernti}
    ${tcpboostpugstaterntinew}       Create List
    FOR   ${item}   IN    @{tcpboostpugstaternti}
        ${newitem} =    Replace variables    ${item}
        Append To List    ${tcpboostpugstaterntinew}    ${newitem}
    END
    FOR   ${item}   IN    @{tcpboostpugstaterntinew}
        should contain    ${status}    ${item}
    END
