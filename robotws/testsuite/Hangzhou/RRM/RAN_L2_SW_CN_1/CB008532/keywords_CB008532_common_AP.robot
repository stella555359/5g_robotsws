*** Settings ***


*** Variables ***
${PCELL_ID}           3
${PCELL_PCI}          52
${WTS_DIR}            /opt/iphy/latest
#${CUR_WTS_DIR}       /opt/iphy/latest
${LOCAL_WTS_DIR}      ${CURDIR}/config/WTS_CFG
${LOCAL_IPHY_DIR}     ${CURDIR}/config/IPHY
${LOCAL_CFG_DIR}      ${CURDIR}/config/
${RIGHT_GNB_SH}       ABIO_BIP_mirroring_2slot_right.sh
${config_path}        ${EMPTY}
${GNB2_XN_ADDR}        10.0.3.151/32
${GNB2_NG_ADDR}        10.0.3.153/32
${PROXY_SERVER2_IP}    192.168.6.252/32
&{GNB_ASIK}       ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GNBDU
&{AP_ASIK}        ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=AP
${TL_config}      /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/SANSA_FS_ECPRI_CMWV_FDD+TDD/
${swconfig_gnb}      swconfig_gnb.txt
${swconfig_ap}       swconfig_ap.txt
${RD}                0x4B000F=1

*** Keywords ***
Common Suite Setup
    Suite Setup Update GNB    log=${False}
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Set SCF Path
    Deploy GNB BIP Script

Deploy GNB BIP Script
    [Documentation]    This keyword is to deploy gnb bip script to gnb
    Log To Console    start deploy gNB BIP script...
    OperatingSystem.Run And Return Rc And Output    scp ${LOCAL_CFG_DIR}/${RIGHT_GNB_SH} toor4nsn@192.168.255.1:/user/toor4nsn/

Set SCF Path
    [Documentation]    This keyword is to set the direcotry of delta json.
    Log To Console    ${SW_BRANCH}
    Set Suite Variable    ${SCF_DIR}    ${CURDIR}/config/SBTS00/SCF
    Log To Console    ${SCF_DIR}

CB008532 Feature Activation
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-${PCELL_ID}    maxNumScellsDlFr1    3

CB008532 Feature Deactivation
    Online delete One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-${PCELL_ID}    maxNumScellsDlFr1    3

Set WTS Files Name For Each Cases
    [Arguments]    ${wts_cfg_name}
    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_name}
    Log To Console    ${WTS_CFG}
    Set Suite Variable    ${WTS_AP_XML}
    Log To Console    ${WTS_AP_XML}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}

Setup TL For Each Case
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${gNB_swconfig}
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured
    #Verify Coam Site Is Ready
    Common Test Setup 2
    Send Swconfig for GNB    ${TL_config}/${swconfig_gnb}
    #Add RD Parameters To GNB Swconfig File    ${RD}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x4B000F=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'crasign /ffs/run/swconfig.txt'
    Send Swconfig for AP     ${TL_config}/${swconfig_ap}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    Full Commission With SCF File    ${scf_file}
    Sleep     60s     \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Set WTS Files Name For Each Cases    ${wts_cfg_name}
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}

Verify Coam Site Is Ready With New Cfg
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured

Start UTE WTS And Check Cell Setup
    [Documentation]    This keyword is to kill Running WTS Binaries,start edaemon, egate and clean log files.
    [Arguments]    ${local_wts_cfg} 
    Log To Console    \nStarting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}    save_egate=${True}
    ute_wtssim.Start Egate Process
    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*
    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${local_wts_cfg}
    ...    pass_regexp=SystemInformationBlockType4-NR updated    timeout=5min
    Sleep     60s    \nFor each scells status
    Verify Cell Setup
    Sleep    60s    wait for all cells' sib come up...\n

Configure Gnb With Full SCF For Local TL
    [Arguments]    ${scf_file}
    Log To Console    start gnb commission...
    ${bts_id}    Get BTS Id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${SCF_DIR}/${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300    
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

SA Start DLUL UDP Traffic
    [Arguments]    ${dlmbps}=100    ${ulmbps}=10    ${duration}=20    ${len}=1400
    [Documentation]    This keyword is to start DL and UL TCP traffic by iperf at the same time.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | Yes | mbps, default is 5M |
    ...    | ulmbps | Yes | mbps, default is 5M |
    ...    | duration | Yes | duration, default is 20s |
    ...    Example:
    ...    | SA Start DLUL TCP Traffic | 20 | 10 | 10 |
    Log To Console    ready to start DL and UL TCP traffic at the same time...
    Start UDP DL Traffic By Iperf    ${dlmbps}    ${duration}    ${len}
    Start UDP UL Traffic By Iperf    ${ulmbps}    ${duration}    ${len}
    Sleep    ${duration}s    reason=wait for traffic

Start UDP DL Traffic By Iperf
    [Arguments]    ${dlmbps}=100    ${duration}=20    ${len}=1400
    [Documentation]    This keyword is to start DL UDP traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | No | mbps, default is 100M |
    ...    | duration | No | duration, default is 20s |
    ...    | len | No | |
    ...    Example:
    ...    | Start UDP DL Traffic By Iperf | 120 | 60 | 1400 |
    Log To Console    start DL traffic...
    Execute Iperf In Linux    args=-c 1.2.4.2 -u -p ${DL_PORT} -l ${len} -b ${dlmbps}M -i 1 -t ${duration}
    Execute Iperf In Linux    args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
    ...        pipe_args=| tee /tmp/iperf_dl.txt
    Log To Console    Running DL Traffic ${dlmbps}M for ${duration}s 

Start UDP UL Traffic By Iperf
    [Arguments]    ${ulmbps}=20    ${duration}=20    ${len}=1400
    [Documentation]    This keyword is to start UL UDP traffic by iperf.
    ...    | Input Parameters | Man. | Description |
    ...    | dlmbps | No | mbps, default is 20M |
    ...    | duration | No | duration, default is 20s |
    ...    | len | No | |
    ...    Example:
    ...    | Start UDP UL Traffic By Iperf | 30 | 60 | 1400 |
    Log To Console    start UL traffic...
    Execute Iperf In Linux    args=-c 72.23.0.1 -u -p ${UL_PORT} -l ${len} -b ${ulmbps}M -i 1 -t ${duration}
    Execute Iperf In Linux    args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
    ...        pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console    Running UL Traffic ${ulmbps}M for ${duration}s

Stop DL UL Traffic Of Iperf
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9

Capture TTItrace And BIP Logs Of BO
    [Arguments]    ${tc_id}    ${log_id}=1    ${duration}=5
    Caputre TTItrace    ${tc_id}    ${log_id}    ${duration}
    Sleep    15s    reason=Wait for ttitrace end.
    #Capture BIP For ABIO    ${tc_id}    ${log_id}    ${duration}

Caputre TTItrace
    [Arguments]    ${tc_id}    ${log_id}=1    ${duration}=5
    Log To Console     start ttitrace...
    Sleep    5s    reason=Make sure the scells stauts are OK.
    Start Ttitrace With Streaming Mode    names=${log_id}
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    names=${log_id}    log_dir=${OUTPUT_DIR}/${tc_id}/ttitrace/${log_id}/

Capture BIP For ABIO   
    [Arguments]    ${tc_id}    ${log_id}=1    ${duration}=5    
    Start Gnb BIP Log For Two ABIOs    ${RIGHT_GNB_SH}
    Sleep    10s    reason=Wait for start bip script.
    Stop Gnb BIP Log For Two ABIOs   ${OUTPUTDIR}/${tc_id}/BIP/${log_id}
    Sleep    ${duration}s    reason=Wait for collecting logs.

Start Gnb BIP Log For Two ABIOs
    [Documentation]    This keyword is to capture gnb L2L1 BIP for 2 ABIOs
    [Arguments]    ${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=GNB_BIP
    SSH.Send Command    command=rm -rf /tmp/*pcap*    connection=GNB_BIP
    SSH.Send Command    command=sh /user/toor4nsn/${exec_script} 1>/dev/null 2>&1 &    connection=GNB_BIP
    Set Suite Variable    ${cmd}           tcpdump -vvv -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${cmd}    GNB_BIP
    Log To Console   \nINFO:bip start success...

Stop Gnb BIP Log For Two ABIOs
    [Documentation]    This keyword is to stop gnb L2L1 BIP for 2 ABIOs 
    [Arguments]    ${log_dir}
    Log To Console    \nINFO:Stop GNB BIP log...
    ${cmd}    Set Variable    tcpdump -vvv -i
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off    ${cmd}    GNB_BIP
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count For Two ABIOs	    ${log_dir}
    Log To Console   \nINFO:bip end success...
    [Return]    ${bip_counts}

Verify GNB Bip Log Exist
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${GNB_ASIK.ip} ls -al /tmp/5GBipL2L1_filtering_off.pcap*
    Should Be True    "${rc}"=="0"	

Copy BIP Files And Return Count For Two ABIOs	
    [Arguments]    ${path}
    Log To Console    \ncopy bip files to ${path}...
    OperatingSystem.Run    mkdir ${path} -p
    Wait Until Keyword Succeeds    10 s    2 s    Verify GNB Bip Log Exist
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${AP_ASIK.username}@${GNB_ASIK.ip}:/tmp/5GBipL2L1_filtering_off.pcap* ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    pattern=5GBipL2L1_filtering_off.pcap*
    [Return]    ${count}

Check Scell Activition Info
    [Arguments]    ${cells_num}    ${scell_act_times}
    Log To Console    \nINFO:Check whether the scells has been actived...
    Sleep    10s    reason=Wait for scell activation finished
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    1    ${cells_num}
        ${pattern}=      set variable    SCellIndex ${id} activated successfully at airphone
        ${check_rst}    run    command=cat /opt/iphy/latest/egate_console.log | grep "${pattern}" |wc -l
        Should Be True    ${check_rst}==${scell_act_times[${id}-1]}
    END

Get And Check Cells TP 
    [Arguments]    ${dir}    ${cell_nums}
    ${pcell_tput}    Get CA Cell Average Throughput    1    ${dir}    pcell    0
    Log To Console    Pcell Throughtput of ${dir} is ${pcell_tput}
    Should Be True    ${pcell_tput}>0    Pcell Throughtput of ${dir} is abnormal.
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${scell__tput}    Get CA Cell Average Throughput    1    ${dir}    scell    ${id}
        Log To Console    Scell${id} Throughtput of {dir} is ${scell__tput}.
    END

Check PCSI Periodicity On Each Cell
    [Arguments]    ${case_id}    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2ACheck/TC${case_id}/ttitrace_pcsi.ini    output_ul.csv    ${csv_file_path}

Check BeamReport Periodicity On TDD Cell
    [Arguments]    ${case_id}    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2ACheck/TC${case_id}/ttitrace_beamreport.ini    output_ul.csv    ${csv_file_path}

A1 triggered Scell Addition
    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A1 srsrp_nr=110 phycell_id=50
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

A2 triggered Pcell Change
    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A2 srsrp_nr=80 srsrq_nr=66 scell=1 scell_rsrp=115 scell_rsrq=100
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Set WTS UE To Single Cell
    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
    @{old_params_list}    Create List    enb=2 cell=[0-9]
    @{new_params_list}    Create List    enb=2 cell=3
    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}

SA CA 5G PDU Session Setup
    [Arguments]    ${ue_id}    ${A1_add}=${False}    ${drx_on}=${False}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | A1_add | No | ${True} |
    ...    | drx_on | No | ${True} |
    ...    Example:
    ...    | SA CA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful     timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output_0}    Initial Context Setup Successful    partial_match=${true}
    ${output}    Run Keyword Unless    ${A1_add}    String.Get Lines Matching Regexp    ${output_0}
    ...    SCellIndex 1 activated successfully    partial_match=${true}
    ${output}    Run Keyword If     ${drx_on}    String.Get Lines Matching Regexp    ${output_0}     drx-Config setup    partial_match=${true}
    Run Keyword If    ${A1_add}    _Trigger A1 Scell Addition    ${ue_id}
    Log To Console    ${output}

Check Pcell And Scell TPut
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_tp1}=    Get CA Cell Average Throughput For Scell    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${scell_tp2}=    Get CA Cell Average Throughput For Scell    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
    ${scell_tp3}=    Get CA Cell Average Throughput For Scell    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3
    ${scell_total_tp}    Evaluate    ${scell_tp1}+${scell_tp2}+${scell_tp3}
    Should Not Be Equal As Integers    ${scell_total_tp}    ${0}    Dl TP of All Scells are zero!!!

Attach SA UE1 4CC
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup 4CCCA    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=3
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=4
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    wait until keyword succeeds    5min    10s    Check Pcell And Scell TPut
    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5

Attach SA UE2 3CC
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup 3CCCA    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    Sleep    5s
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_tp1}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${scell_tp2}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2

Get CA SCell Number
    [Arguments]    ${ue_id}
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=pdsch scell\=secondary
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_scell}    Set Variable    CellIndex-\\d
    ${Scell_list}    String.Get Regexp Matches    ${output}    ${regexp_scell}
    [Return]    ${Scell_list}

Check UE1 No SCell Release Immediately
    [Arguments]    ${Scell_list}
    List Should Contain Value    ${Scell_list}    CellIndex-1
    List Should Contain Value    ${Scell_list}    CellIndex-2
    List Should Contain Value    ${Scell_list}    CellIndex-3

Check UE1 SCell Addition 4CC
    [Arguments]    ${Scell_list}
    List Should Contain Value    ${Scell_list}    CellIndex-1
    List Should Contain Value    ${Scell_list}    CellIndex-2
    List Should Contain Value    ${Scell_list}    CellIndex-3

Check UE2 Only 2Scell Addition
    [Arguments]    ${Scell_list}
    List Should Contain Value    ${Scell_list}    CellIndex-1
    List Should Contain Value    ${Scell_list}    CellIndex-2
    List Should Not Contain Value    ${Scell_list}    CellIndex-3

SA 5G PDU Session Setup 4CCCA
    [Arguments]    ${ue_id}
    Log To Console    start 5G PDU Session Setup CA...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=SCellIndex 3 activated successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

SA 5G PDU Session Setup 3CCCA
    [Arguments]    ${ue_id}
    Log To Console    start 5G PDU Session Setup CA...
    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=SCellIndex 2 activated successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Online Delete NRREL
    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_CFG_DIR}/delta_8532_DeleteREL.xml
    Delta Commission With SCF File    ${json_file}
    Sleep    30s

Check UE1 Release
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${UE1releaseregex}=    Set Variable    UE\\d: detached
    ${UErelease_list}=    String.Get Regexp Matches    ${content}    ${UE1releaseregex}
    List Should Contain Value    ${UErelease_list}    UE1: detached

Check MaxPayloadSize After Scelladdition
    ${max16}=    Set Variable    maxPayloadSize 16
    ${ret}    OperatingSystem.Run    cat ${WTS_DIR}/egate_console.log|grep maxPayloadSize
    Should Contain    ${ret}    ${max16}

Clear PM Counter Reports
    ${cmd}    Set Variable    rm /tmp/PM.BTS*
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'
    Sleep    5s    reason=wait for handling

Connect To GNB DU
    SSH.Connect To    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}    password=${GNB_ASIK.password}    alias=GNB-DU

Get PM File
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}/PMFile/CA
    Check PM File
    Get PM File To Local    ${log_path}

Check PM File
    Connect To GNB DU
    ${output}    SSH.Execute    ls -lrt /tmp/PM.BTS*|wc -l    connection=GNB-DU
    ${num}    Replace String   ${output}   \r\n   ${EMPTY}
    Should Be True    ${num}>=1
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU

Get PM File To Local
    [Arguments]    ${log_path}
    OperatingSystem.Run And Return Rc And Output    rm -rf ${log_path}/*
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/PM.BTS* ${log_path}
    OperatingSystem.Run And Return Rc And Output    gunzip ${log_path}/PM.BTS*.gz

Get PM Counter Value From Xml
    [Arguments]    ${mode}    ${meas_type}    ${counter}    ${flag}=CA
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/${flag}/PM.BTS*.xml|grep ${counter}
    ${pcell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-3<\/DN><\/MO><NE-WBTS_1.0 measurementType="${meas_type}">
    ${count_var}    Set Variable    <${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${count_var2}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex} =    Run Keyword If    '${mode}' == '1'
    ...    Catenate    SEPARATOR=    ${pcell_var}    ${count_var}
    ...    ELSE    Catenate    SEPARATOR=    ${pcell_var}    ${count_var2}
    Log To Console    ${regex}
    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
    BuiltIn.Log    ${list}
    ${len}    Get Length    ${list}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${list}    ${id}
        LOG    ${counter_value}    
        Exit Loop Based On Flag    ${counter_value}    ${flag}    
    END
    Run Keyword And Ignore Error  SSH.Disconnect
    [Return]    ${counter_value}

Exit Loop Based On Flag
    [Arguments]    ${counter_value}    ${flag}=CA 
    Run Keyword If    '${flag}' == 'CA'
    ...    Exit For Loop If    '${counter_value}'>'0'
    ...    ELSE    Exit For Loop If    '${counter_value}'=='0'

Check PM Counter For CA
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C09501
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C09502
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C09503
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSACU    M55138C03001
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSACU    M55138C03002
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C03001
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C03002
    Should Be True    ${rd_counter_value}>0

Online Delete NRREL For TDD
    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_CFG_DIR}/delta_8532_DeleteREL_TDD.xml
    Delta Commission With SCF File    ${json_file}
    Sleep    30s    reason=wait for SCF changed

UE RRC Reestablish To One Cell
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${physcellid}=50    ${cell_id}=1
    ${output}    ute_wtssim.Execute Egate Command    ue_rrc_reestablish id\=${ue_id} gnb\=${gnb_id} cell\=${cell_id} cause\=otherFailure
    ...    pass_regexp=scramblingID ${physcellid}    timeout=5min
    Log To Console    ${output}

Check PM Counter For NonCA
    Wait Until Keyword Succeeds    15min    1min    Get PM File    ${SUITE_LOG_DIRECTORY}/PMFile/NonCA
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C09501    NonCA
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C09502    NonCA
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C09503    NonCA
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSACU    M55138C03001    NonCA
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSACU    M55138C03002    NonCA
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C03001    NonCA
    Should Be True    ${rd_counter_value}==0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    RSADU    M55139C03002    NonCA
    Should Be True    ${rd_counter_value}==0

Setup 1T3F TL For Each Case
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}   ${gNB_swconfig}
    Verify Coam Site Is Ready
    Common Test Setup 2
    Send Swconfig for GNB    ${TL_config}/${swconfig_gnb}
    Add RD Parameters To GNB Swconfig File    ${RD}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'crasign /ffs/run/swconfig.txt'
    Send Swconfig for AP     ${TL_config}/${swconfig_ap}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    Full Commission With SCF File    ${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Online Delete NRREL For TDD
    Set WTS Files Name For Each Cases    ${wts_cfg_name}
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}

Get Scellindex
    ${Scellindex}=    Set Variable    sCellIndex[\\s\\S]{1,150}physCellId\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${Scellindex_list}=    String.Get Regexp Matches    ${content}    ${Scellindex}    1
    [Return]    ${Scellindex_list}

Check 4CC Cell Contain TDD
    [Arguments]    ${Scellindex_list}
    List Should Contain Value    ${Scellindex_list}    53

Trigger 2T+2F A1 Scell Addition
   [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=101
    ...    pass_regexp=SCellIndex 3 activated successfully

Trigger F+T+T A1 Scell Addition
   [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=101
    ...    pass_regexp=SCellIndex 2 activated successfully

Trigger Reestablish To FDD
    ${command}    Set Variable    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Get MeasID A1
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[0]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA1}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA1}

Get MeasID A1 After Reestablish
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[1]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA1}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA1}

Attach SA UE1 Do A1 To 4CC
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA1}=    Get MeasID A1
    Trigger 2T+2F A1 Scell Addition    ${UE_ID}    meas_id=${measIdA1}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${scell_tp1}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    ${scell_tp2}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=2
    ${scell_tp3}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=3

Get CA Cell Average Throughput For Scell
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get  Scell Average throughput
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_dl_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Set Variable    CellIndex-${scell_index}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?\\s+){3}(?P<AvgTput>\\d+.?\\d*)
    ${arg_tput_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    Log    Cell ${scell_index}throughput: ${arg_tput_list}[0]    console=True
    ${result}=    Convert To Number    ${arg_tput_list}[0]
    #Should Not Be Equal As Integers    ${result}    ${0}    Get CA throughput error!!!
    [Return]    ${result}

SA Check Average Traffic Bigger Than Target Egate Command
    [Arguments]    ${ue_id}    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | SA Check Average Traffic bigger than target | 1 | 2 | ul | 10 |
    ...    | SA Check Average Traffic bigger than target | 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=qfi_stats ue\=${ue_id} pdu=1 qfi=1 type=l3 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average ${dir} tput is: ${mavg}M \n
    ${tp_delta}    Evaluate    ${avg}*0.000001-${tp_rate}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n

Attach SA UE1 Do A1 To 4CC Only With UL
    [Arguments]    ${cases_id}    ${expected_pcell_csirsnums}    ${expected_tddscell_csirsnums}    ${UE_ID}=1    ${ul_tp_set}=175
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Check Num Of CSIRS    ${expected_pcell_csirsnums}    ${expected_tddscell_csirsnums}
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    Capture TTItrace And BIP Logs Of BO    ${cases_id}
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/${cases_id}/ttitrace/1    1
    Check ACSI On PCell    ${cases_id}    ${OUTPUT_DIR}/${cases_id}/ttitrace/1

Trigger A1 For 2T2F    
    [Arguments]    ${UE_ID}=1    
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA1}=    Get MeasID A1
    Trigger 2T+2F A1 Scell Addition    ${UE_ID}    meas_id=${measIdA1}

Check Num Of CSIRS
    [Arguments]    ${expected_pcell_csirsnums}    ${expected_tddscell_csirsnums}     ${tdd_pcell_id}=52    ${tdd_scell_id}=53
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${cellid}=    Set Variable    nrofPorts p8,[\\s\\S]*?cdm-Type cdm4-FD2-TD2,[\\s\\S]*?scramblingID\\s(?P<scramblingID>\\d+)
    ${content}=    OperatingSystem.Get File    ${WTS_DIR}/egate_console.log
    ${cell_id_list}=    String.Get Regexp Matches    ${content}    ${cellid}    scramblingID
    BuiltIn.Log    ${cell_id_list}
    ${len}    Get Length    ${cell_id_list}
    BuiltIn.Log    ${len}
    ${pcell_csirs_num}=    Get Count    ${cell_id_list}    ${tdd_pcell_id}
    BuiltIn.Log    ${pcell_csirs_num}
    ${scell_csirs_num}=    Get Count    ${cell_id_list}    ${tdd_scell_id}
    BuiltIn.Log    ${scell_csirs_num}
    Should Be True    ${pcell_csirs_num} == ${expected_pcell_csirsnums}
    Should Be True    ${scell_csirs_num} == ${expected_tddscell_csirsnums}    

A2 trigger Scell Release
    [Arguments]    ${scell_meas_id}    ${scell_id}    ${scell_rsrp}=70    ${ue_id}=1
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${scell_meas_id} event=A2 scell=${scell_id} scell_rsrp=${scell_rsrp}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Check ACSI On PCell
    [Arguments]    ${case_id}    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2ACheck/${case_id}/ttitrace_pcsi.ini    output_ul.csv    ${csv_file_path}

Attach SA UE1 Before A1
    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=3
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=4
    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=5
    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0

Trigger T+FFF A1 Scell Addition
   [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=80
    ...    pass_regexp=SCellIndex 3 activated successfull

Check 4CC Cell 1T3F
    [Arguments]    ${Scellindex_list}
    List Should Contain Value    ${Scellindex_list}    50
    List Should Contain Value    ${Scellindex_list}    51
    List Should Contain Value    ${Scellindex_list}    54

Get MeasID A2 release
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[0]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA2}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA2}

Trigger A2 Release
   [Arguments]    ${UE_ID}    ${meas_id}=1    ${SCellIndex}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=${SCellIndex} scell_rsrp=50
    ...    pass_regexp=rrcReconfigurationComplete

Get SRSport In Egatelog Before A1ScellAddition
    ${SRSportindex}=    Set Variable    nrofSRS-Ports\\sports(\\d)
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${SRSport_list}=    String.Get Regexp Matches    ${content}    ${SRSportindex}    1
    [Return]    ${SRSport_list}

Get SRSport In Egatelog After A1ScellAddition
    ${SRSportindex}=    Set Variable    nrofSRS-Ports\\sport(\\d)
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${SRSport_list}=    String.Get Regexp Matches    ${content}    ${SRSportindex}    1
    [Return]    ${SRSport_list}

Check SRSport Before A1ScellAddition
    [Arguments]    ${SRSport_list}
    List Should Contain Value    ${SRSport_list}    2

Check SRSport After A1ScellAddition
    [Arguments]    ${SRSport_list}
    Should Be True    '${SRSport_list}[1]'=='1'

Trigger TDD A2 Release
   [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=3 scell_rsrp=30 phycell_id=53
    ...    pass_regexp=rrcReconfigurationComplete

Trigger FDD1 A2 Release
   [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=2 scell_rsrp=30 phycell_id=51
    ...    pass_regexp=rrcReconfigurationComplete

Trigger FDD2 A2 Release
   [Arguments]    ${UE_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=30 phycell_id=50
    ...    pass_regexp=rrcReconfigurationComplete

Get A1Threshold After TDDcell Release
    ${A1Thresholdindex}=    Set Variable    a1\\SThreshold\\srsrp\\s\\S\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${A1Threshold_list}=    String.Get Regexp Matches    ${content}    ${A1Thresholdindex}    1
    [Return]    ${A1Threshold_list}

Check A1Threshold After TDDcell Release
    [Arguments]    ${A1Threshold_list}
    Should Be True    '${A1Threshold_list}[1]'=='90'

Get A1Threshold After FDDcell AllRelease
    ${A1Thresholdindex}=    Set Variable    a1\\SThreshold\\srsrp\\s\\S\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${A1Threshold_list}=    String.Get Regexp Matches    ${content}    ${A1Thresholdindex}    1
    [Return]    ${A1Threshold_list}

Check A1Threshold After FDDcell AllRelease
    [Arguments]    ${A1Threshold_list}
    Should Be True    '${A1Threshold_list}[2]'=='60'
    
Trigger A1 Event
    [Arguments]    ${meas_id}    ${srsrp}    ${ue_id}=1
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    [Return]    ${output}

Check No ACSI On PCell
    [Arguments]    ${case_id}    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/A2ACheck/${case_id}/ttitrace_no_pcsi.ini    output_ul.csv    ${csv_file_path}

Trigger A2 Event
    [Arguments]    ${meas_id}    ${srsrp_nr}    ${srsrq_nr}    ${scell_rsrp1}    ${scell_rsrq1}    ${scell_rsrp2}
    ...    ${scell_rsrq2}    ${scell_rsrp3}    ${scell_rsrq3}    ${newpcell}    ${ue_id}=1
    ${command}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} scell=1 scell_rsrp=${scell_rsrp1} scell_rsrq=${scell_rsrq1}
    ...    scell=2 scell_rsrp=${scell_rsrp2} scell_rsrq=${scell_rsrq2}
    ...    scell=3 scell_rsrp=${scell_rsrp3} scell_rsrq=${scell_rsrq3}
    Log To Console    ${command}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    ${flag}    Catenate    reconfigurationWithSync with physCellId ${newpcell} is present in masterCellGroup.
    ...    Handover will be triggered using CBRA.
    Should Contain    ${output}    ${flag}

Get Counter Value Under MNC 
    [Arguments]    ${meas_type}    ${counter}    ${flag}=CA
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/${flag}/PM.BTS*.xml|grep ${counter}
    ${pcell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-3<\/DN><\/MO>
    ${mnc_var}    Set Variable    <MO dimension="MCCMNC"><DN>PLMN-PLMN\/MCC-311\/MNC-489<\/DN><\/MO><NE-WBTS_1.0 measurementType="${meas_type}">
    ${count_var}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex}    Catenate    SEPARATOR=    ${pcell_var}    ${mnc_var}    ${count_var}
    Log To Console    ${regex}
    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
    BuiltIn.Log    ${list}
    ${len}    Get Length    ${list}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${list}    ${id}
        LOG    ${counter_value}
        Exit Loop Based On Flag    ${counter_value}    ${flag}
    END
    Run Keyword And Ignore Error  SSH.Disconnect
    [Return]    ${counter_value}

Get Counter Value Under SSTSD
    [Arguments]    ${meas_type}    ${counter}    ${flag}=CA
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/${flag}/PM.BTS*.xml|grep ${counter}
    ${pcell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1<\/DN><\/MO>
    ${mnc_var}    Set Variable    <MO dimension="MCCMNC"><DN>PLMN-PLMN\/MCC-311\/MNC-489<\/DN><\/MO>
    ${sd_var}    Set Variable    <MO dimension="SSTSD"><DN>PLMN-PLMN\/SST-1\/SD-13714341<\/DN><\/MO><NE-WBTS_1.0 measurementType="${meas_type}">
    ${count_var}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex}    Catenate    SEPARATOR=    ${pcell_var}    ${mnc_var}    ${sd_var}    ${count_var}
    Log To Console    ${regex}
    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
    BuiltIn.Log    ${list}
    ${len}    Get Length    ${list}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${list}    ${id}
        LOG    ${counter_value}
        Exit Loop Based On Flag    ${counter_value}    ${flag}
    END
    Run Keyword And Ignore Error  SSH.Disconnect
    [Return]    ${counter_value}

Check Counters For Pcell Change
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml   2    NCAC    M55118C09501
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get Counter Value Under MNC    NRANS    M55145C03001
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get Counter Value Under SSTSD    NSL    M55149C02501
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get Counter Value Under MNC    NRANS    M55145C03002
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get Counter Value Under SSTSD    NSL    M55149C02502
    Should Be True    ${rd_counter_value}>0

Check Activated Cell Id
    [Arguments]    ${content}    ${scell_id}    ${physcellid}
    ${regex}    Set Variable    sCellIndex\\s${scell_id},\\s+sCellConfigCommon\\s+{\\s+physCellId\\s(?P<physCellId>\\d+)
    ${cellid}    Get Regexp Matches    ${content}    ${regex}    physCellId
    Log    ${cellid}
    Should Be True    ${cellid[0]}==${physcellid}         


Check PM Counter For CAD23
    Wait Until Keyword Succeeds    15min    1min    Get PM File
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C06506
    Should Be True    ${rd_counter_value}>0
    ${rd_counter_value}    Get PM Counter Value From Xml    2    NCAC    M55118C06507
    Should Be True    ${rd_counter_value}>0
	
Get sCellToReleaseList
    ${sCellToReleaseList}=    Set Variable    sCellToReleaseList[\\s\\S]{1,35}(\\d{1,2})
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${sCellToRelease_list}=    String.Get Regexp Matches    ${content}    ${sCellToReleaseList}    1
    [Return]    ${sCellToRelease_list}

Check 4CC Cell 1T3F Again
    [Arguments]    ${Scellindex_list}
    ${num1}    Get Match Count    ${Scellindex_list}    50
    ${num2}    Get Match Count    ${Scellindex_list}    51
    ${num3}    Get Match Count    ${Scellindex_list}    54
    Should be true   ${num1}==2
    Should be true   ${num2}==2
    Should be true   ${num3}==2

Configure VM Interface For HO
    [Arguments]    ${ip_addr_1}    ${ip_addr_2}    ${ip_addr_3}
    [Documentation]    This keyword is to configure HO related interfaces on VM interfaces including GNB2 NG, XN and proxy.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add ${ip_addr_1} dev eth3
    OperatingSystem.Run    sudo ip addr add ${ip_addr_2} dev eth3
    OperatingSystem.Run    sudo ip addr add ${ip_addr_3} dev eth2

Configure UE History Info For HO
    [Arguments]    ${real_gnb_id}    ${real_cell_id}    ${sim_gnb_id}    ${sim_cell_id}
    [Documentation]    This keyword is to configure Simulated GNB info and UE history info.
    Log To Console    configure VM interfaces...
    ${history_1}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x0${real_cell_id}
    ...    gnb_id=${real_gnb_id} time_ue_stayed_in_cell=97
    ${history_2}    Catenate    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x0${sim_cell_id}
    ...    gnb_id=${sim_gnb_id} time_ue_stayed_in_cell=98
    ${history_3}    Set Variable    ue_history_information_list id=1 action=commit
    ${history_4}    Set Variable    ue_enb_param id=1 ue_history_list=1
    ute_wtssim.Execute Egate Command    ${history_1}
    ute_wtssim.Execute Egate Command    ${history_2}
    ute_wtssim.Execute Egate Command    ${history_3}
    ute_wtssim.Execute Egate Command    ${history_4}
    ute_wtssim.Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${output}    ute_wtssim.Execute Egate Command    cmd=gnb_xn_link_up gnb=3 target=2
    ...    pass_regexp=is up    timeout=60
    Log To Console    ${output}

Intra-frequency HO To Sim GNB For UE1
    [Arguments]    ${sim_cell_pci}
    Log To Console
    ...    | SA 5G    start Intra-frequency handover from real gNB to simulated gNB for UE1...
    ${ho_to_sim}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=${sim_cell_pci}
    ...    nrsrp_nr=100 nrsrq_nr=50
    ${output}    ute_wtssim.Execute Egate Command    ${ho_to_sim}
    ...    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    timeout=3minutes
    Log To Console    ${output}

Intra-frequency HO To Real GNB For UE1
    [Arguments]    ${real_cell_pci}    ${real_gnb_id}
    Log To Console
    ...    | SA 5G    start Intra-frequency handover from simulated gNB to real gNB for UE1...
    ${ho_to_real}    Catenate    ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id=${real_cell_pci}
    ...    nrsrp_nr=100 nrsrq_nr=50
    ${output}    ute_wtssim.Execute Egate Command    ${ho_to_real}
    ...    pass_regexp=PATH SWITCH REQUEST ACK [\\s\\S]+ to GNB - ${real_gnb_id}
    ...    timeout=3minutes
    Log To Console    ${output}
