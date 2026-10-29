*** Settings ***
Documentation    [PURPOSE] Set of keywords used for CB006112 test

*** Variables ***
${UE1_ID}    1
${UE2_ID}    2
${UE3_ID}    3
${UE4_ID}    4
${tti_dl_csv}    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv
${tti_ul_csv}    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
${ASIK_PASSWORD}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_USERNAME}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${TL_ip}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}

*** Keywords ***
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

Start TTI Trace Logs
    [Arguments]    ${wait_time}=5s
    Start GNB TTI Trace
    Sleep    ${wait_time}
    Stop And Decode GNB TTI Trace    ${OUTPUT_DIR}/tti

Start TTI Trace Logs For BO SA FDD
    [Arguments]    ${wait_time}=5s
    Catch Ttitrace Log    wait_time=${wait_time}
    Decode TTI Trace And Send To Control PC One By One    ${OUTPUT_DIR}/tti

Stop Data Transfer
    SA Stop Traffic For Multi UE    7070    7071
    SA Stop Traffic For Multi UE    7072    7073
    SA Stop Traffic For Multi UE    7074    7075

Release UE
    SA 5G Detach    ${UE1_ID}
    SA 5G Detach    ${UE2_ID}
    SA 5G Detach    ${UE3_ID}

Verify DL PA Timer Enable
    @{pa_list_details}    Test Check Log For CB006112    dl    ${OUTPUT_DIR}/tti/2730_L2TtiTrace_EventsSnapshot.bin.0.dl.csv
    : FOR    ${index}    ${pa_check_list}    IN ENUMERATE    @{pa_list_details}
    \    Run Keyword If    ${index}==1    Should Contain    '${pa_check_list}'    25
    ...    ELSE IF    ${index}==2    Should Contain    '${pa_check_list}'    4
    ...    ELSE IF    ${index}==3    Should Contain    '${pa_check_list}'    2
    ...    ELSE    Log To Console    No need to check.

Verify UL PA Timer Enable
    @{pa_list_details}    Test Check Log For CB006112    ul    ${OUTPUT_DIR}/tti/2730_L2TtiTrace_EventsSnapshot.bin.0.ul.csv
    : FOR    ${index}    ${pa_check_list}    IN ENUMERATE    @{pa_list_details}
    \    Run Keyword If    ${index}==1    Should Contain    '${pa_check_list}'    25
    ...    ELSE IF    ${index}==2    Should Contain    '${pa_check_list}'    4
    ...    ELSE IF    ${index}==3    Should Contain    '${pa_check_list}'    2
    ...    ELSE    Log To Console    No need to check.

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

Check PM Counter
    [Arguments]    ${counter_id}    ${counter_value}
    Log To Console    check ${counter_id}
    SSH.Connect to    &{GNB_ASIK}[ip]    &{GNB_ASIK}[username]    &{GNB_ASIK}[password]
    SSH.Execute    gunzip /tmp/PM.BTS*.gz
    SSH.Execute     rm /tmp/PM.BTS*.xml
    ${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep ${counter_id}
    ${counter_list}    get regexp matches    ${counter_info1}    <${counter_id}>(\\d+)</${counter_id}>    1
    BuiltIn.Log    ${counter_list}
    Should Contain     ${counter_list}    ${counter_value}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Catch TTitrace With Streaming Mode And Convert To CSV
    Start Ttitrace With Streaming Mode
    Sleep    10s    wait to catch ttitrace...
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/

Verify DL PA Timer Enable With Streaming Mode   
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_dl_csv}   
    ...    dlTdSchedSubcellData.resReqClassPrio
    ${5qi_sfn_list}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_dl_csv}    
    ...    dlFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn    
    ${sfn_interval_lt}=    TTITRACEANALYZER.count_interval    ${5qi_sfn_list}
    ${PA_event_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_dl_csv}   
    ...    paTimerData.event
    Should Contain    ${prioriy_list}    25.0
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
    Should Contain    ${prioriy_list}    25.0
    #Should Contain    ${sfn_interval_lt}     ${4}
    Should Contain    ${PA_event_list}    START

Verify UL PA Timer Enabled With Streaming Mode for AB201
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}
    ...    ulTdSchedSubcellData.resReqClassPrio
    Should Contain    ${prioriy_list}    25.0

Verify UL PA Timer Disabled With Streaming Mode
    ${prioriy_list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${tti_ul_csv}
    ...    ulTdSchedSubcellData.resReqClassPrio
    Should Not Contain    ${prioriy_list}    25.0

Set Delta Jason Config Path
    Log To Console    ${SW_VERSION}
#    Set Suite Variable    ${Delata_JSON_PATH}    ${CURDIR}/../config/${SW_BRANCH}/SCF
    Set Suite Variable    ${Delata_JSON_PATH}    ${CURDIR}/../config/
    Log To Console    ${Delata_JSON_PATH}
    [Return]    ${Delata_JSON_PATH}

Recover TL
    Recover Config
    Clean Edaemon And Egate

Configure Gnb
    [Arguments]    ${delta_file}
    Delta Commission Json File With Admin    delta_json=${delta_file}

Load Cfg File
    [Arguments]    ${cfg_file}
    Log To Console    ${cfg_file}
    ute_wtssim.Execute Egate Command    cfg file\=${cfg_file}    pass_regexp=NG link is Up    timeout=360

Setup XP
    [Arguments]    ${nor_subframe}    ${prb_list}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}=30    ${max_prb_ratio}=70
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup DSS Link
    Configure Support GBR as TRUE in CRM server
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    UL Resource cell Reservation    ${min_prb_ratio}    ${max_prb_ratio}
    Cell Allocation    nor_subframe=${nor_subframe}    prb_list=${prb_list}
    Log To Console    ******XP setup sucess******

Start Collect XP log on LteEmu
    [Arguments]    ${Case_index}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    mkdir ${OUTPUT_DIR}/${Case_index} && rm -rf /tmp/XP*
    Log To Console    start XP pcap logs on ...
    Process.Start Process    sudo tcpdump -i any -C 500M -w /tmp/XP.pcap -vv    shell=True
    Log To Console    XP log ongoing...

Check Voice Call Reject
    [Arguments]    ${Case_index}
    Download And Unzip Lua File    sw=${SW_VERSION_TOTAL}
    ${gbr_reject_filter}    Catenate    ngap.radioNetwork == 22
    Wait Until Keyword Succeeds    2 min    7 s    cap.Read Cap    cap_file=${OUTPUT_DIR}/${Case_index}/XP.pcap
    ...    X=lua_script:${output_dir}/generated_luashark/xpshark.lua    display_filter=${gbr_reject_filter}
    ${status}    Run Keyword and Return Status     cap.Check Expression    ${gbr_reject_filter}    log=${True}
    Log To Console    GBR call is rejected as expected

SA GBR Call For Multi UE for E05
    [Arguments]    ${ue_id}
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup For Multi UE    ${ue_id}
    Trigger 5QI 5 Setup    ${ue_id}
    Trigger E05 5QI 1 Setup   ${ue_id}

Stop Collect XP log on LteEmu
    [Arguments]    ${Case_index}
    Log To Console    stop XP pcap log by pkill
    OperatingSystem.Run    ps -ef|grep tcpdump|grep -v grep|grep eth0 |awk '{print $2}'|xargs sudo kill -2
    Log To Console    XP pcap log capture stoped
    ${res}    Copy XP Pcap Files And Return Count    ${OUTPUT_DIR}/${Case_index}
    Run Keyword If    '${res}'!='True'    Log To Console    'seems x2.pcap not existed'

Copy XP Pcap Files And Return Count
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy xp pcap log to ${log_dir}
    Log To Console    copy XP pcap files to ${log_dir}...
    OperatingSystem.Run    scp /tmp/XP* ${log_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/XP*
    [Return]    ${res}

Trigger E05 5QI 1 Setup
    [Arguments]    ${ue_id}
    Log To Console
    ...    | SA 5G    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer
    ...    timeout=3minutes
    Log To Console    ${output}

#Prepare Test Env
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
##    Modify Gnb Sw Coniguration
##    Backup AP Config File
#    Configure Airphone

Prepare Test Env
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Backup Gnb Sw Coniguration
    Modify Gnb Sw Coniguration
    Backup AP Config File
    Configure Airphone
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#    Set Config Path
#    Adjust Network Configuration For Different Branch
#    Create GNB BIP Dir

Modify Gnb Sw Coniguration
    ${cmd}    Set Variable    echo "0x59005D=1">>/ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'

Configure Airphone
    Modify GSCN On Airphone    50    ${GSCN}
    ${cmd}    Set Variable  sed -i "s|<cell>[0-9].[0-9]</cell>|<cell>1.1</cell>|" /ffs/run/simmode/iphy.xml
    Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIL'
    ...    OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'
    ...    ELSE
    ...    Modify Cell IDs in iphy

Modify Cell IDs in iphy
    SSH.Execute    sed -i "s|<cell>2.1</cell>|<cell>1.1</cell>|" /ffs/run/simmode/iphy.xml    connection=${AP_ASIK.connection}
    SSH.Execute    sed -i "s|<cell>2.2</cell>|<cell>1.2</cell>|" /ffs/run/simmode/iphy.xml    connection=${AP_ASIK.connection}


Recover Config
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    Log To Console    recover gnb configuratio...
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${OUTPUT_DIR}/SCF_before_suite.xml
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown

Backup AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml ./iphy-bak-TA.xml
    SSH.Execute    command=${cmd}    connection=${AP_ASIK.connection}

Configure Support GBR as TRUE in CRM server
    Log To Console    Configuring support GBR in CRM server
    #ute_wtssim.Execute Egate Command    dss_enb_param id\=2 feature_flag\=on message_sets\=V1,DMS2
    ute_wtssim.Execute Egate Command    enb_cell_dss_param enb\=2 id\=1 dl_crm_sf_capabilities\=gbr_support

Get CPRT log
    [Arguments]    ${LOG_PATH}
    ${cprt_node_id}=    Get CPRT Node Id
    Run    cd ${LOG_PATH} && unzip snapShot_gnb.zip && unzip 2515_runtime.zip && xz -d runtime_cp_rt.log.xz

Setup a folder for subcase
    [Arguments]    ${Case_index}
    Run    cd ${output_dir} && mkdir ${Case_index}
    Sleep    15s

Check Voice Call Reject in E05E06
    [Arguments]    ${LOG_PATH}
    BuiltIn.Log To Console    Check voice call rejected in cprt journal log...
    Get CPRT log    ${LOG_PATH}
    Sleep    2s
    ${E06_info1}    OperatingSystem.Run    cat ${LOG_PATH}/runtime_cp_rt.log | grep -i Fail
    Should Contain Any   ${E06_info1}    Failed to allocate drb resource
    ...    cause:CauseRadioNetwork::noRadioResourcesAvailable
    ...    GbrDrb Check Fail since exceed available CellBitRateCapDL
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Check ULDL GBRreport in local cprt log
    [Arguments]    ${LOG_PATH}
    BuiltIn.Log To Console    Check ULDL GBRreport in local cprt log...
    Get CPRT log    ${LOG_PATH}
    Sleep    2s
    ${E01_info}    OperatingSystem.Run    cat ${LOG_PATH}/runtime_cp_rt.log | grep -i dlGbrPrbLoadLargeBwp
    Should Contain Any   ${E01_info}    dlGbrPrbLoadLargeBwp:5
    ...    dlGbrPrbLoadLargeBwp:6
    ...    ulGbrPrbLoadLargeBwp:14
    ...    ulGbrPrbLoadLargeBwp:13
    ...    ulGbrPrbLoadLargeBwp:12
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Reboot gnb and ap via ssh
    Log To Console    -------- Reboot testline via ssh --------
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'

Check TL Type And Suite Setup
    ${testline_type}=    Get Testline Type
    Run Keyword If    '${testline_type}'=='CLOUD_5G_I_LO_AP_LO'    Run Keywords
    ...    Suite Setup Update GNB    scf_file=${SCF_2F}    iphy_file=${IPHY_2F}
    ...    AND    Backup Scf    ${OUTPUT_DIR}    before_suite
    ...    ELSE    Suite Setup Update GNB

Backup Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
    OperatingSystem.Run And Return Rc And Output    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'
