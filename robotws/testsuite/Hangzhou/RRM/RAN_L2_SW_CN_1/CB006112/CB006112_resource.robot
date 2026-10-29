*** Settings ***
Library      ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
*** Variables ***
${WTS_DIR}    /opt/iphy/latest
${LOCAL_WTS_DIR}    ${CURDIR}/config/WTS_CFG
${LOCAL_IPHY_DIR}     ${CURDIR}/config/IPHY
${SCF_DIR}    ${CURDIR}/config/
${6112_scf_tdd}    ${SCF_DIR}/SCF_VONR_TDD.xml
${6112_scf_fdd}    ${SCF_DIR}/SCF_VONR_FDD.xml
${6112_scf_tdd_ho}    ${SCF_DIR}/SCF_VONR_TDD_HO.xml
${6112_scf_fdd_tdd}    ${SCF_DIR}/SCF_VONR_2CC_FDD_TDD.xml
${WTS_XML}    wts_ASIL_ABIO_L1BYPASS.xml
${tti_dl_csv}    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv
${tti_ul_csv}    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
${CELL1_SIB}    eNB 2 cell 1: SystemInformationBlockType2-NR updated

*** Keywords ***
Common Suite Setup
    [Arguments]    ${6112_scf}
    Suite Setup Update GNB    log=${False}
    Full Commission With SCF File    ${6112_scf}    
    Reboot TL And Check Configured
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Configure GNB3 VM Interfaces
	
Recover TL
    [Arguments]    ${6112_scf}
    Common Test Teardown 2
    Recover Config    ${6112_scf}
    Verify Coam Site Is Ready
	
Recover Config
    [Arguments]    ${6112_scf}
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    Log To Console    recover gnb configuratio...
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${6112_scf}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown
	
Setup TL For Each Case
    [Arguments]    ${scf_file}    ${swconfig_param}    ${wts_cfg_name}    ${wts_xml_name}
    Verify Coam Site Is Ready
    Common Test Setup 2
    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}    scf_file=${SCF_DIR}/${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Set WTS Files Name For Each Cases    ${wts_cfg_name}    ${wts_xml_name}
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}
	
Verify Coam Site Is Ready With New Cfg
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Run Keyword If    '${res}'=='False'    Reboot TL And Check Configured

Set WTS Files Name For Each Cases
    [Arguments]    ${wts_cfg_name}    ${wts_xml_name}
    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_name}
    Log To Console    ${WTS_CFG}
    Set Suite Variable    ${WTS_AP_XML}    ${wts_xml_name}
    Log To Console    ${WTS_AP_XML}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}

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

SA GBR Call For Multi UE
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA Non GBR call for multi UE | 1 |
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}
    Trigger 5QI 5 Setup    ${ue_id}
    Trigger 5QI 1 Setup    ${ue_id}

Trigger 5QI 5 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 5 Setup | 1 |
    Log To Console    start 5QI-5 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Trigger 5QI 1 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Unsuccessful SA GBR UE Attach
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA Non GBR call for multi UE | 1 |
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}
    Trigger 5QI 5 Setup    ${ue_id}
    Trigger Unsuccessful 5QI 1 Setup   ${ue_id}
	
Trigger Unsuccessful 5QI 1 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " PDU Session Resource Modify Unsuccessful Transfer " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:PDU Session Setup | 1 |
    Log To Console
    ...    | SA 5G    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer
    ...    timeout=3minutes
    Log To Console    ${output}
	
Check Voice Call Reject
    BuiltIn.Log To Console    Voice call reject...
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=GnbAsik
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB.username}@${GNB.ip}:/tmp/node_CPRT00/tmp/startup_cp_rt.log ${OUTPUT_DIR}
    Sleep    10s
    ${Fail_info1}    OperatingSystem.Run    cat ${OUTPUT_DIR}/startup_cp_rt.log | grep -i Fail
    Should Contain Any    ${Fail_info1}    Failed to allocate drb resource
    ...    GbrDrb Check Fail since exceed available
    #Should Contain    ${Fail_info1}
    #...    CauseRadioNetwork::noRadioResourcesAvailable

Catch TTitrace With Streaming Mode And Convert To CSV
    Start Ttitrace With Streaming Mode
    Sleep    8s    wait to catch ttitrace...
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/

Catch TTitrace With Streaming Mode And Convert To CSV For A0201
    Start Ttitrace With Streaming Mode
    Sleep    4s    wait to catch ttitrace...
    Stop Ttitrace
    Teardown Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
	
Verify DL PA Timer Enable With Streaming Mode   
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_dl_csv}   
    ...    dlTdSchedSubcellData.resReqClassPrio
    ${5qi_sfn_list}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_dl_csv}    
    ...    dlFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn    
    ${sfn_interval_lt}=    TTITRACEANALYZER.count_interval    ${5qi_sfn_list}
    ${PA_event_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_dl_csv}   
    ...    paTimerData.event
    #Should Contain    ${prioriy_list}    25.0
    #Should Contain    ${sfn_interval_lt}     ${4}
    Should Contain    ${PA_event_list}    START
    
Verify UL PA Timer Enable With Streaming Mode   
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}   
    ...    ulTdSchedSubcellData.resReqClassPrio
    ${5qi_sfn_list}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_ul_csv}   
    ...    ulFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn    
    ${sfn_interval_lt}=    TTITRACEANALYZER.count_interval    ${5qi_sfn_list}
    ${PA_event_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv} 
    ...    paTimerData.event
    #Should Contain    ${prioriy_list}    25.0
    #Should Contain    ${sfn_interval_lt}     ${4}
    Should Contain    ${PA_event_list}    START

Modify GuaranteedFlowBitRateDLUL
    [Arguments]    ${gfbr_dlul}
    [Documentation]    This keyword is used to modify guaranteedFlowBitRateUL
    ...    Expected output is none on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gfbr_dlul | Yes | gfbr_dlul |
    ...    Example:
    ...    | Modify guaranteedFlowBitRateDLUL | 5 |
    Log To Console    Modify guaranteedFlowBitRate for dl and ul...
    ute_wtssim.Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=3 mfbr_dl=${gfbr_dlul} mfbr_ul=${gfbr_dlul} gfbr_dl=${gfbr_dlul} gfbr_ul=${gfbr_dlul}
    Log To Console    Done...

Start TTI Trace Logs
    [Arguments]    ${wait_time}=5s
    Start GNB TTI Trace
    Sleep    ${wait_time}
    Stop And Decode GNB TTI Trace    ${OUTPUT_DIR}/tti
	
Stop GBR Traffic
    SA Stop Traffic For Multi UE    7074    7075
	
Release GBR UE
    SA 5G Detach    ${UE3_ID}
	
Verify UL voipVcdTimerData As Expected
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/tti/output_ul.csv    ./ul/
    Log To Console    Check  adaptVoipPacketSize from TTI trace
    @{adaptVoipPacketSize_ul}=    Ttitrace Filter Source Column Return Self Column    ${OUTPUT_DIR}/tti/output_ul.csv
    ...    voipVcdTimerData.adaptVoipPacketSize     ["0", "", "0.0"]    except    no

    ${num}    Set Variable    0
    FOR    ${var}    IN    @{adaptVoipPacketSize_ul}
         ${num}    Evaluate    ${num}+1
    END
    ${number_of_67}=    Collections.Count Values In List    ${adaptVoipPacketSize_ul}    67.0
    Log To Console    ${number_of_67}
    ${correct_rate}    Evaluate    float(${number_of_67})/${num}
    Log To Console    ${correct_rate}
    Should be true    ${correct_rate}>0.4
	
Start UL And DL Traffic To Make High Load
    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    60M    120
    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    160M    120
    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    60M    120
    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    160M    120
	
Start UL And DL Voice Traffic Per 30ms
    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7074    75    20000    120
    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    75    20000    120
	
Stop Data Transfer
    SA Stop Traffic For Multi UE    7070    7071
    SA Stop Traffic For Multi UE    7072    7073
    SA Stop Traffic For Multi UE    7074    7075
	
Release UE
    SA 5G Detach    ${UE1_ID}
    SA 5G Detach    ${UE2_ID}
    SA 5G Detach    ${UE3_ID}

Start TTI Trace Logs For BO SA FDD
    [Arguments]    ${wait_time}=5s
    Catch Ttitrace Log    wait_time=${wait_time}
    Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/tti

Verify Scell DL Traffic Transfered As Expected
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/tti/2730_L2TtiTrace_EventsSnapshot.bin.0.dl.csv    ${OUTPUT_DIR}/dl/
    Log To Console    Check tbSize from TTI trace
    @{tbSize_dl}=    get_specified_column_from_csv_file    ${OUTPUT_DIR}/dl/dlFdSchedData_sfn.csv    tbSize
    FOR    ${i}    IN    @{tbSize_dl}
         Should Be True    ${i}>0
    END

Stop Non GBR Data Transfer
    SA Stop Traffic For Multi UE    7070    7071
    SA Stop Traffic For Multi UE    7072    7073
	
Verify DL PA Timer Disable
    ${5qi_sfn_list}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_dl_csv}     
    ...    dlFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn    
    ${sfn_interval_lt}=    TTITRACEANALYZER.count_interval    ${5qi_sfn_list}
    ${the_rate_bigger_than_4}    change_2D_list_to_1D_and_Cal_the_rate_bigger_than_4    ${sfn_interval_lt}
    Run Keyword If    ${the_rate_bigger_than_4}>0.01    Fail    There is still PA  	
    
Verify UL PA Timer Disable
    ${5qi_sfn_list}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_ul_csv}    
    ...    ulFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn    
    ${sfn_interval_lt}=    TTITRACEANALYZER.count_interval    ${5qi_sfn_list}
    ${the_rate_bigger_than_4}    change_2D_list_to_1D_and_Cal_the_rate_bigger_than_4    ${sfn_interval_lt}
    Run Keyword If    ${the_rate_bigger_than_4}>0.01    Fail    There is still PA
	
Stop GBR Data Transfer
    SA Stop Traffic For Multi UE    7074    7075
	
Verify DL PA Timer Enable For 6112 B3 01
    @{pa_list_details}    Test Check Log For CB006112    dl    ${OUTPUT_DIR}/tti/2730_L2TtiTrace_EventsSnapshot.bin.0.dl.csv
    : FOR    ${index}    ${pa_check_list}    IN ENUMERATE    @{pa_list_details}
    \    Run Keyword If    ${index}==1    Should Contain    '${pa_check_list}'    25
    ...    ELSE IF    ${index}==4    Should Not Contain    ${pa_check_list}    0
    ...    ELSE IF    ${index}==2    Check Schedule Inverval For 6112 B3 01    DL    ${pa_check_list}
    ...    ELSE    Log To Console    No need to check.

Verify UL PA Timer Enable For 6112 B3 01
    @{pa_list_details}    Test Check Log For CB006112    ul    ${OUTPUT_DIR}/tti/2730_L2TtiTrace_EventsSnapshot.bin.0.ul.csv
    : FOR    ${index}    ${pa_check_list}    IN ENUMERATE    @{pa_list_details}
    \    Run Keyword If    ${index}==1    Should Contain    '${pa_check_list}'    25
    ...    ELSE IF    ${index}==4    Should Not Contain    ${pa_check_list}    0
    ...    ELSE    Log To Console    No need to check.

Check Schedule Inverval For 6112 B3 01
    [Arguments]    ${direction}    ${pa_check_list}
    Log To Console    ********* The ${direction} schedule interval is ${pa_check_list} !
    Should Be True    ${pa_check_list} != None
    :FOR    ${element}  IN  @{pa_check_list}
    \    Should Be True    ${element} <= 4
	
Compare Counter
    ${M55308C11001}    Periodic Read PM Counter    M55308C11001    30min
    ${M55308C11002}    Periodic Read PM Counter    M55308C11002    1min
    ${sleep_rate_true}    Evaluate    float(${M55308C11002}[0])/(float(${M55308C11001}[0])+float(${M55308C11002}[0]))
    Log To Console    Sleep Rate Is ${sleep_rate_true} When actVoipPacketAggr Is True
    Delta Commission With SCF File    ${delta_json}
    Teardown All Aliases For Wts
    Teardown All Connections
    Reboot TL And Check Configured
    #Start UTE WTS 002    
    #Verify BTS Is OnAir
    Start UTE WTS And Check Cell Setup    wts_cfg_ASIL_ABIO_TDD_DRX.cfg
    SA Non GBR Call For Multi UE    ${UE1_ID}
    SA Non GBR Call For Multi UE    ${UE2_ID}
    SA GBR Call For Multi UE    ${UE3_ID}
    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    10M    
    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    10M    
    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    10M    
    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    10M    
    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7074    40    1600
    ${M55308C11001}    Periodic Read PM Counter    M55308C11001    30min
    ${M55308C11002}    Periodic Read PM Counter    M55308C11002    1min
    ${sleep_rate_false}    Evaluate    float(${M55308C11002}[0])/(float(${M55308C11001}[0])+float(${M55308C11002}[0]))
    Log To Console    Sleep Rate Is ${sleep_rate_false} When actVoipPacketAggr Is False
    ${difference}    Evaluate    ${sleep_rate_true}-${sleep_rate_false}
    Should Be True    ${difference}!=0
	
Periodic Read PM Counter
    [Arguments]    ${counter_id}    ${time}=10min
    ${counter_list}    wait until keyword succeeds    ${time}    5sec    PM Counter Value Exists    ${counter_id}
    [Return]    ${counter_list}
	
PM Counter Value Exists
    [Arguments]    ${counter_id}
    ${counter_list}    Get PM Counter    ${counter_id}
    Should Not Be Empty    ${counter_list}
    [Return]    ${counter_list}
    
Get PM Counter
    [Arguments]    ${counter_id}
    Log To Console    check ${counter_id}
    ssh.connect to    &{GNB_ASIK}[ip]    &{GNB_ASIK}[username]    &{GNB_ASIK}[password]    
    ssh.execute    gunzip /tmp/PM.BTS*.gz
    ssh.execute    rm /tmp/PM.BTS*.xml
    ${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep ${counter_id}
    ${counter_list}    get regexp matches    ${counter_info1}    <${counter_id}>(\\d+)</${counter_id}>    1
    Log To Console    The PM counter ${counter_id} contains following values:
    Log To Console    ${counter_list}
    [Return]    ${counter_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
	
Start UTE WTS 002
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Log To Console    \n\rStarting WTS02...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    Start Wts Applications    egate_port=20000    edaemon_ports=22222
    ...    tool_dir=/opt/wts/latest    cfg_file=${WTS_CFG}
    Wait Until Keyword Succeeds    300sec    15sec
    ...    Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE
    #Check UTE ASIK AP Cell Setup
	
Verify UL PA Timer Disable With Streaming Mode
    ${status}    Run Keyword And Return Status    Verify UL PA Timer Enable With Streaming Mode
    Should Be True    ${status}==False

Configure GNB3 VM Interfaces
    Log To Console    configure GNB3 interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth4
	
Set UE Parameter For Handover
    Log To Console    Set UE paramter for handover before register
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_history_information_list id=1 action=commit
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_enb_param id=1 ue_history_list=1
    ute_wtssim.Execute Egate Command
    ...    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${output}    ute_wtssim.Execute Egate Command    cmd=gnb_xn_link_up gnb=3 target=2
    ...    pass_regexp=is up    timeout=60
    Log To Console    ${output}
	
UE1 GBR Call Setup
    SA Attach For UE1
    SA 5G PDU Session Setup For Multi UE    ${UE1_ID}
    Trigger 5QI 1 Setup    ${UE1_ID}
	
SA Attach For UE1
    Log To Console    start 5G attach for UE1...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id\=${UE1_ID} ue_nr_capabilities=${UE1_CAPABILITY}
    ...    pass_regexp=REGISTRATION COMPLETE    timeout=3minutes
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable
	
Intra-frequency Handover To Sim GNB For UE1
    Log To Console
    ...    | SA 5G    start Intra-frequency handover from real gNB to sim gNB for UE1...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=48 nrsrp_nr=70 nrsrq_nr=30
    ...    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    ...    timeout=3minutes
    Log To Console    ${output}
	
SA Non GBR Call For Multi UE With Attach 2 Times
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA Non GBR call for multi UE | 1 |
    #SA Attach For UE3 1st
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}
	
SA Attach For UE3 1st
    Log To Console    start 5G attach for UE3 1st...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id\=${UE3_ID}
    ...    pass_regexp=UE3: detached    timeout=3minutes
    ${output1}    String.Get Lines Matching Regexp    ${output}    UE3: detached    partial_match=${true}
    Log To Console    \n${output1}
    Sleep    3s    reason=wait 5G attach is stable
	
Intra-frequency Handover To Real GNB For UE1
    Log To Console
    ...    | SA 5G    start Intra-frequency handover from sim gNB to gnb gNB for UE1...
    ${output}    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=50 nrsrp_nr=70 nrsrq_nr=30
    ...    pass_regexp=PATH SWITCH REQUEST ACK with RAN UE NGAP ID
    ...    timeout=3minutes
    Log To Console    ${output}
	
UE2 GBR Call Setup
    SA 5G Attach    ${UE2_ID}
    SA 5G PDU Session Setup For Multi UE    ${UE2_ID}
    Trigger 5QI 1 Setup    ${UE2_ID}
	
Start UL And DL Voice Traffic For UE2
    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7070    75    30000    300
    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7071    75    30000    300
	
UE3 GBR Call Setup
    #SA Attach For UE3 1st
    SA 5G Attach    ${UE3_ID}
    SA 5G PDU Session Setup For Multi UE    ${UE3_ID}
    #Trigger 5QI 1 Setup For UE3
    Trigger 5QI 1 Setup    ${UE3_ID}
	
Check UE3 5QI1 Setup Failed Due To Exceed Available Cell Time Domain Capability
    BuiltIn.Log To Console    Check UE3 5QI1 Setup Failed Due To Exceed Available Cell Time Domain Capability...
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    ssh.send_command    command=rm /tmp/startup_cp_rt.log
    sleep    2s
    ssh.send_command    command=bget 0:1 /tmp/node_CPRT00/tmp/startup_cp_rt.log /tmp/
    sleep    2s
    ${C18_info1}    ssh.execute    cat /tmp/startup_cp_rt.log | grep -i Fail
    should contain    ${C18_info1}    Gbr Drb Admission Fail since exceed Available Cell Time Domain Cap UL For GBR Bearers
    ${C18_info2}    ssh.execute    cat /tmp/startup_cp_rt.log | grep -i UeContextModificationFailure
    should contain    ${C18_info2}
    ...    UeContextModificationFailure has been sent with cause:CauseRadioNetwork::noRadioResourcesAvailable
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect
	
GBR And Non GBR UE Attach And PDU 5QI Setup
    SA Non GBR Call For Multi UE    ${UE1_ID}
    SA Non GBR Call For Multi UE    ${UE2_ID}
    SA GBR Call For Multi UE    ${UE3_ID}
    SA Non GBR Call For Multi UE    ${UE4_ID}
	
GBR And Non GBR Tput Start
    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    60M    9999
    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    20M    9999
    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    60M    9999
    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    20M    9999
    SA Start UDP DL Traffic For Multi UE    ${UE4_ID}    7076    1400    60M    9999
    SA Start UDP UL Traffic For Multi UE    ${UE4_ID}    7077    1400    20M    9999
    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    40    16000    9999
    Sleep    3s    reason=wait the tput stable
	
Verify UL PA Timer Enabled With Streaming Mode for AB201
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}
    ...    ulTdSchedSubcellData.resReqClassPrio
    Should Contain    ${prioriy_list}    25.0
	
Modify UE Signal
    [Arguments]    ${ue_id}    ${delta}
    ${delta_cmd}    Set Variable    sinr_target_srs=${delta} sinr_target_pusch=${delta} sinr_target_pucch=${delta} sinr_target_preamble=${delta}
    ${CMD_SIGNAL_PRF}    Set Variable    ul_sinr_testmode_nr profile_id=1 ${delta_cmd}
    ${CMD_PRF_DISP}    Set Variable    ul_sinr_testmode_nr profile_id=1
    ${CMD_PRF_ACT}    Set Variable    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1
    ute_wtssim.Execute Egate Command    cmd=${CMD_SIGNAL_PRF}
    ute_wtssim.Execute Egate Command    cmd=${CMD_PRF_DISP}
    ${output}    ute_wtssim.Execute Egate Command    cmd=${CMD_PRF_ACT}
    Should Not Contain    ${output}    UE may be OFF or killed
    Log To Console    set_UE_signal_is_ok, UE_${ue_id}'s signal change is: ${delta}
	
Verify UL PA Timer Disabled With Streaming Mode
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}
    ...    ulTdSchedSubcellData.resReqClassPrio
    Should Not Contain    ${prioriy_list}    25.0

Check PM counter
    ${M55310C19001}    Periodic Read PM Counter    M55310C19001    30min
    ${M55310C02001}    Periodic Read PM Counter    M55310C02001    1min
    ${value}    Evaluate    float(${M55310C02001}[0])/float(${M55310C19001}[0])
    Log To Console    ${value}
    should be true    ${value}>0.3
    should be true    ${value}<1.6
	
Verify DRX Enable
    ${dl_preSched}=    streaming_ttitrace_analyzer.FiLter Source Column Return Self    ${tti_dl_csv}   
    ...    dlPreSchedData.csListEvent
    ${ul_preSched}=    streaming_ttitrace_analyzer.FiLter Source Column Return Self    ${tti_ul_csv}   
    ...    ulPreSchedData.csListEvent
    ${total_preSched}    Evaluate    ${dl_preSched}+${ul_preSched}
    Should Contain    ${total_preSched}    EXITDRXSTATUSEXCEPTRETXTIMER
	
Verify UL VoipVcdTimerData As Expected For C04
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/tti/output_ul.csv    ./ul/
    Log To Console    Check  adaptVoipPacketSize from TTI trace
    @{adaptVoipPacketSize_ul}=    Ttitrace Filter Source Column Return Self Column    ${OUTPUT_DIR}/tti/output_ul.csv
    ...    voipVcdTimerData.adaptVoipPacketSize     ["0", "", "0.0"]    except    no

    ${num}    Set Variable    0
    FOR    ${var}    IN    @{adaptVoipPacketSize_ul}
         ${num}    Evaluate    ${num}+1
    END
    ${number_of_76}=    Collections.Count Values In List    ${adaptVoipPacketSize_ul}    76.0
    Log To Console    ${number_of_76}
    ${correct_rate}    Evaluate    float(${number_of_76})/${num}
    Log To Console    ${correct_rate}
    Should Be True    ${correct_rate}>0.5
	
Check PM Counter For C04
    Log To Console    wait 30min for counter is complete...
    ${counter_value1}    wait until keyword succeeds    30min    3min    Get Counter    M55138C01001
    ${counter_value2}    wait until keyword succeeds    1min    10sec    Get Counter    M55138C01002
    ${counter_value3}    wait until keyword succeeds    15min    10sec    Get Counter    M55138C01004
	
Get Counter
    [Arguments]    ${counter_id}
    Log To Console    check ${counter_id}
    SSH.Connect to    &{GNB_ASIK}[ip]    &{GNB_ASIK}[username]    &{GNB_ASIK}[password]    
    SSH.Execute    gunzip /tmp/PM.BTS*.gz
    SSH.Execute     rm /tmp/PM.BTS*.xml
    ${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep ${counter_id}
    ${counter_list}    get regexp matches    ${counter_info1}    <${counter_id}>(\\d+)</${counter_id}>    1
    BuiltIn.Log    ${counter_list}
    Should Contain     ${counter_list}    1
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Modify 5QI 1 qosflows
    [Arguments]    ${ue_id}
    Log To Console    modify 5QI-1 qosflows for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_modify=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
	
Verify UL AdaptVoipPacketSize As Expected
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/tt2/output_ul.csv    ./ul/
    Log To Console    Check  adaptVoipPacketSize from TTI trace
    @{adaptVoipPacketSize_ul}=    Ttitrace Filter Source Column Return Self Column    ${OUTPUT_DIR}/tt2/output_ul.csv
    ...    voipVcdTimerData.adaptVoipPacketSize     ["0", "", "0.0"]    except    no

    FOR    ${i}    IN    @{adaptVoipPacketSize_ul}
         ${res}=    Run Keyword And Ignore error    Should Be True    ${i}<76
         Run Keyword If    ${res} == ('PASS', None)    Exit For Loop
    END
    Should Contain    ${res}    PASS

    ${num}    Set Variable    0
    FOR    ${var}    IN    @{adaptVoipPacketSize_ul}
         ${num}    Evaluate    ${num}+1
    END
    ${number_of_76}=    Collections.Count Values In List    ${adaptVoipPacketSize_ul}    76.0
    Log To Console    ${number_of_76}
    ${correct_rate}    Evaluate    float(${number_of_76})/float(${num})
    Log To Console    ${correct_rate}
    Should Be True    ${correct_rate}>0.5
	
Setup TL For CA
    [Arguments]    ${scf_file}
    Verify Coam Site Is Ready
    Common Test Setup 2
    Suite Setup Update GNB    scf_file=${SCF_DIR}/${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    CB006112_resource.Start WTS And Check OnAir
	
Start WTS And Check OnAir
    [Documentation]    This keyword is to start WTS, wait for onAir
    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
    CB006112_resource.Cell1 UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    Verify Cell Setup
    Display Egate Status
    Sleep    60s    wait for 3 cells' sib all come up...
	
Cell1 UE SIB Decoding Should Be Successful
    ta5g_egate.Wait For Egate Console Output    expected_message=${CELL1_SIB}    timeout=300s
    Log    sib_decoding_is_ok

Display Egate Status
    ${output}=    ute_wtssim.Execute Egate Command    cmd=sim_state_disp    return_output=True
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_summary    return_output=True
	
SA Start DL and UL Traffic
    Log To Console    Start DL Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
    Log To Console    Start UL Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=1 trf_id=3 mbps=175 dir=ul
	
Modify PDU Session with VONR
    ${command}    Set Variable    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2 by=amf
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    Log To Console    ${output_0}
    ${command}    Set Variable    ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=3 by=amf
    ${output_1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
	
SA Start VONR DL TCP and UDP Traffic
    Log To Console    Start DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=3 trf_id=1 mbps=10 dir=dl protocol=udp
    Log To Console    Start UL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=3 pdu=1 qfi=3 trf_id=2 mbps=10 dir=ul protocol=udp
    Sleep    5s    reason=wait DL TCP traffic is stable
	
Check Vonr DRX Reject
    BuiltIn.Log To Console    Voice Vonr DRX Reject...
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=GnbAsik
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ram/node_CPRT00/tmp/startup_cp_rt.log* ${OUTPUT_DIR}	
    ${BC01_info1}    OperatingSystem.Run    cat ${OUTPUT_DIR}/startup_cp_rt.log | grep -i Drx
    Should Contain    ${BC01_info1}    allocate VoNr Drx Pucch Resource failed
    ${BC01_info2}    OperatingSystem.Run    cat ${OUTPUT_DIR}/startup_cp_rt.log | grep -i Fail
    Should Contain Any    ${BC01_info2}    CauseMisc::notEnoughUserPlaneProcessingResources
    ...    CauseRadioNetwork::noRadioResourcesAvailable

CA Start TTI Trace Logs For BO SA FDD
    [Arguments]    ${wait_time}=5s
    CA Catch Ttitrace Log    wait_time=${wait_time}
    CA Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/tt2
	
CA Catch Ttitrace Log
    [Arguments]    ${wait_time}=5
    [Documentation]    This keyword is to start gnb ttitrace.
    ...    Examples:
    ...    | Catch Ttitrace Log | wait_time=5s |
    Log To Console    INFO:start tti trace on asp...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 2:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 2:${cpu_id} ls -l /tmp/ 2>/dev/null|grep -e ".*ram.*L2RT30"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    ${regexp_ID}    Should Match Regexp    ${container_id}   [^0x]
    Set Suite Variable    ${regexp_ID}
    ${ttitrace_cmd}=    Set Variable    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 2:${cpu_id} timeout ${wait_time} lxc-attach -n ${container_id} ${ttitrace_cmd}
    OperatingSystem.Run    ${cmd}
    CA Show Ttitrace Log On ASP
	
CA Show Ttitrace Log On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ttitrace_bin_log}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 2:${cpu_id} ls -lrt /var/eventsTrace/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ttitrace_bin_log}
    Log To Console    INFO:ttitrace log list:${output}
	
CA Decode TTI Trace And Send To Control PC One By One
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to decode tti trace logs collected by keyword Start GNB TTI Trace
    ...    and put the result csv files in to ${log_dir}. In this process, one .sh script is used.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | No | default value is ${TEST_LOG_DIRECTORY} |
    ...
    ...    Examples:
    ...    | Decode TTI Trace And Send To Control PC One By One | log_dir=/home/ute/logs/ |
    ...
    Log To Console    INFO:start to decode tti .bin logs to csv
    ${decode_ttitrace}=    Set Variable
    ...    ${CURDIR}/../CUDU_L2/scripts/shell/2cell_decode_ttitrace_on_PC.sh
    OperatingSystem.Run And Return Rc And Output    sh ${decode_ttitrace} ${log_dir}
    Log To Console    INFO:finish to decode tti .bin logs to csv
	
Verify Scell DL Traffic Transfered As Expected For CA
    ttitrace_filter_table_with_all_different_message    ${OUTPUT_DIR}/tti/${regexp_ID}730_L2TtiTrace_EventsSnapshot.bin.0.dl.csv    ${OUTPUT_DIR}/dl/
    Log To Console    Check numOf5qi1Prb from TTI trace
    @{numOf5qi1Prb_dl}=    get_specified_column_from_csv_file    ${OUTPUT_DIR}/dl/dlFdSchedData_sfn.csv    numOf5qi1Prb
    FOR    ${i}    IN    @{numOf5qi1Prb_dl}
         Should Be True    ${i}==0
    END	 
    Log To Console    Check tbSize from TTI trace
    @{tbSize_dl}=    get_specified_column_from_csv_file    ${OUTPUT_DIR}/dl/dlFdSchedData_sfn.csv    tbSize
    FOR    ${i}    IN    @{tbSize_dl}
         Should Be True    ${i}>0
    END
	
Verify Pcell UL Traffic Transfered As Expected
    @{pa_list_details}    Check For Schedule Interval UL    ul    ${OUTPUT_DIR}/tt2/${regexp_ID}830_L2TtiTrace_EventsSnapshot.bin.0.ul.csv
    : FOR    ${index}    ${pa_check_list}    IN ENUMERATE    @{pa_list_details}
    \    Run Keyword If    ${index}==1   Should Contain    '${pa_check_list}'    2
    
Verify Pcell DL Traffic Transfered As Expected
    @{pa_list_details}    Check For Schedule Interval DL    dl    ${OUTPUT_DIR}/tt2/${regexp_ID}830_L2TtiTrace_EventsSnapshot.bin.0.dl.csv
    : FOR    ${index}    ${pa_check_list}    IN ENUMERATE    @{pa_list_details}
    \    Run Keyword If    ${index}==1    Should Contain    '${pa_check_list}'    2
	
Start Gnb Cell Setup Log Match Both Frame
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    Run Keyword If     '${slot_id}'=='1'
    ...    Start Gnb Cell Setup Log On ASIB    ip=192.168.253.16
    ...    cmd=timeout 20 tcpdump -i any -w /user/toor4nsn/cellsetup_gnb.pcap
    Run Keyword If     '${slot_id}'=='5'
    ...    Start Gnb Cell Setup Log On ASIB   ip=192.168.253.32
    ...    cmd=timeout 20 tcpdump -i any -w /user/toor4nsn/cellsetup_gnb.pcap
	
Start Gnb Cell Setup Log On ASIB
    [Arguments]    ${ip}=${GNB_ASIK_SLAVE.ip}    ${cmd}=${GNBCELLSETUP_CMD}
    [Documentation]    This keyword is to start gnb Cell Setup Log and save in /ffs/run/logs/cellsetup_gnb.pcap on GNB ASIK.
    ...    ${GNBCELLSETUP_CMD}    tcpdump -i any -w /ffs/run/logs/cellsetup_gnb.pcap
    ...
    ...    Examples:
    ...    | Start Gnb Cell Setup Log |
    ...
    Log To Console    Clear The Gnb Cell Setup Log
    ssh.connect to    &{GNB_ASIK}[ip]    &{GNB_ASIK}[username]    &{GNB_ASIK}[password]    alias=ClearCell_ASIK
    SSH.Execute    rm -rf /user/toor4nsn/cellsetup_gnb.pcap    connection=ClearCell_ASIK
    Log To Console    start gnb Cell Setup Logs...
    SSH.Send Command    command=${cmd}    connection=ClearCell_ASIK
    Log To Console    gnb Cell Setup log ongoing
	
Stop Gnb Cell Setup Log Match Both Frame
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    ssh.connect to    &{GNB_ASIK}[ip]    &{GNB_ASIK}[username]    &{GNB_ASIK}[password]    alias=ClearCell_ASIK
    OperatingSystem.Run    scp ${AP_ASIK.username}@${GNB_ASIK.ip}:/user/toor4nsn/cellsetup_gnb.pcap ${log_dir}
    Sleep    30s
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/cellsetup_gnb.pcap
    Run Keyword If    '${res}'!='True'    Log To Console    'seems cellsetup_gnb.pcap not existed'
	
Verify SCell Configured For UE
    BuiltIn.Log To Console    Verify SCell Configured For UE
    cap.Read Cap    cap_file=${SUITE_LOG_DIRECTORY}/cellsetup_gnb.pcap    display_filter=f1ap
    ${physCellId} =    cap.get_element_value    element_expression=nr-rrc.physCellId    element_idx=${0}    default_value=True
    ...    condition_expression=nr-rrc.physCellId==50
    Should contain    ${physCellId}    50
	
Verify Drx Config 5QI-6 and 5QI-1
    BuiltIn.Log To Console    Verify Drx Config after 5QI-6 5QI-5 and 5QI-1
    cap.Read Cap    cap_file=${SUITE_LOG_DIRECTORY}/cellsetup_gnb.pcap   display_filter=f1ap
    ${drx-InactivityTimer}=    cap.get_element_value   element_expression=nr-rrc.drx-InactivityTimer   element_idx=${0}    default_value=True
    ...    condition_expression=F1ap.procedureCode == 7 and f1ap.F1AP_PDU == 1 and nr-rrc.drx_Config == 1
    ${length}    Get Length    ${drx-InactivityTimer}
    BuiltIn.Should Be True    ${drx-InactivityTimer}[0]==7    #Check Drx Config after 5QI-6
    BuiltIn.Should Be True    ${drx-InactivityTimer}[${${length}-1}]==4    #Check Drx Config after 5QI-1
	
Verify Scells Addition
    [Arguments]    ${scell_id}=50
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${Scellindex}=    Set Variable    sCellIndex[\\s\\S]{1,150}physCellId\\s(\\d{1,2})
    ${content}=    OperatingSystem.Get File    ${WTS_DIR}/egate_console.log
    ${Scellindex_list}=    String.Get Regexp Matches    ${content}    ${Scellindex}    1
    List Should Contain Value    ${Scellindex_list}    ${scell_id}
	
Verify Drx Config
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${DRX_info}    OperatingSystem.Run    cat ${WTS_DIR}/egate_console.log | grep -i drx-InactivityTimer
    Should Contain    ${DRX_info}    drx-InactivityTimer ms40
    Should Contain    ${DRX_info}    drx-InactivityTimer ms4
	
CA Common Test Setup
    [Arguments]    ${6112_scf}    ${iphy_file}
    Modify IPHY File And Send to Airphone    ${iphy_file}
    Full Commission With SCF File    ${6112_scf}    
    Reboot TL And Check Configured
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Configure GNB3 VM Interfaces

SA Non GBR Call For UEs
    [Arguments]    ${ue_id}
    SA Attach For UEs    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}

SA Attach For UEs
    [Arguments]    ${ue_id}
    Log To Console    start 5G attach for ${ue_id}...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id\=${UE_ID} ue_nr_capabilities=${UE1_CAPABILITY}
    ...    pass_regexp=REGISTRATION COMPLETE    timeout=3minutes
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable


SA GBR Call For UEs
    [Arguments]    ${ue_id}
    SA Attach For UEs    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}
    Trigger 5QI 1 Setup    ${ue_id}

Start GNB Syslog For 6112
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}
    sleep    2s

Stop And Collect Syslog For 6112
    [Arguments]    ${log_dir}
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=True    destination=${log_dir}/Gnb_syslog
    Set Test Variable    ${btslog}    ${log_dir}/Gnb_syslog/Gnb_syslog_*

Check Failed Allocate Drb
    ${rc}    ${Fail_info}=    OperatingSystem.Run And Return Rc And Output    grep -i gbrDrb ${btslog}
    Should Contain Any    ${Fail_info}    exceed remainingCellTimeDomainCapUL
    ...    Gbr drbs are not available

Catch Streaming Ttitrace
    [Arguments]    ${time}=2
    Start Ttitrace With Streaming Mode
    Sleep    ${time}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/
	
Check GBR traffic Interval
    [Arguments]    ${UE_ID}
    SA Single UE Attach    ${UE_ID}
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=3 mbps=175 dir=ul
    Sleep     3s    reason=Wait for traffic
    Catch Streaming Ttitrace
    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB006112_BC_ul.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/
    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB006112_BC_dl.ini    output_dl.csv    ${TEST_LOG_DIRECTORY}/ttitrace/

Verify Vonr DRX Reject From Pcap
    [Arguments]    ${pcap_file}
    BuiltIn.Log To Console    Verify Vonr DRX Reject From Pcap
    cap.Read Cap    cap_file=${pcap_file}    display_filter=f1ap
    ${status} =    cap.get_element_value    element_expression=f1ap.misc    element_idx=${0}    default_value=True
    ...    condition_expression=f1ap.misc == 1
    Should Contain    ${status}    1

Check Timers are right
    [Arguments]    ${ratio1}    ${ratio2}    ${ratio3}    ${ratio4}    ${ratio5}
    Sleep    2min    reason=Wait for next pm counter
    @{M55308C25001}    Periodic Read PM Counter    M55308C25001
    @{M55308C25002}    Periodic Read PM Counter    M55308C25002
    @{M55308C23001}    Periodic Read PM Counter    M55308C23001
    @{M55308C24002}    Periodic Read PM Counter    M55308C24002
    @{M55309C11001}    Periodic Read PM Counter    M55309C11001
    Should Be True     @{M55308C25001}[0]<${ratio1}*5
    ${Avg_UL_Delay_5QI1}     Evaluate    float(@{M55308C25001}[0]/@{M55308C25002}[0])
    Should Be True    ${Avg_UL_Delay_5QI1}<15
    Should Be True    @{M55308C23001}[0]<${ratio3}*3
    Should Be True     @{M55308C24002}[0]>${ratio4}*0.5 and @{M55308C24002}[0]<${ratio4}*3
    Should Be True     @{M55309C11001}[0]>${ratio5}*0.5 and @{M55309C11001}[0]<${ratio5}*3
