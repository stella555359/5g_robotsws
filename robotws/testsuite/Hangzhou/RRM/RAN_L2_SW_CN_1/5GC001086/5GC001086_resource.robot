*** Settings ***

*** Keywords ***
Capture TTItrace
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    3s    reason=Wait for logs
    Stop Ttitrace    log_dir=${OUTPUT_DIR}

Common Suite Setup
    [Arguments]    ${5GC001086_scf}
    Suite Setup Update GNB    log=${False}
    Full Commission With SCF File    ${5GC001086_scf}
    Reboot TL And Check Configured
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Configure GNB3 VM Interfaces

Set SCF Path
    [Documentation]    This keyword is to set the direcotry of delta json.
    Log To Console    ${SW_VERSION}
    Set Suite Variable    ${SCF_DIR}    ${CURDIR}/config/${SW_VERSION}/SCF
    Log To Console    ${SCF_DIR}

Deploy GNB BIP Script
    [Documentation]    This keyword is to deploy gnb bip script to gnb
    Log To Console    start deploy gNB BIP script...
    OperatingSystem.Run And Return Rc And Output    scp ${LOCAL_CFG_DIR}/${RIGHT_GNB_SH} toor4nsn@192.168.255.1:/user/toor4nsn/

Setup TL For Each Case
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${wts_xml_name}
    Common Test Setup 2

    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    #Configure Gnb With Full SCF For Local TL    ${scf_file}
    Suite Setup Update GNB    scf_file=${SCF_DIR}/${scf_file}
    Sleep    60s    \nFor Site reset
    Verify Coam Site Is Ready With New Cfg
    Set WTS Files Name For Each Cases    ${wts_cfg_name}    ${wts_xml_name}
    Start UTE WTS And Check Cell Setup    ${wts_cfg_name}

Full Commission With SCF File For UTE
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform full commissioning，please use the scf with full configuration saved.
    #Get Software Version
    #${scf_pull_path}=    Check Config File Absolute Path Or Relative Path    ${scf_file}
    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
    Modify File Parameter    ${SCF_DIR}/${scf_file}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify VlanId In SCF File    ${SCF_DIR}/${scf_file}
    ${new_scf_path}    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Migration SCF To New Release    ${SCF_DIR}/${scf_file}
    ${new_scf_path}=    Set Variable If    "${new_scf_path}"=="${None}"    ${SCF_DIR}/${scf_file}    ${new_scf_path}
    File Should Exist    ${new_scf_path}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id[0]}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

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



Set TestMode for SRS
    [Arguments]     ${profile_id}    ${init_pos}    ${UE_ID}
    Log To Console    Set TestMode for SRS
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_srs_beam_pos_nr profile_id\=${profile_id} init_pos\=${init_pos} srsMode\=fixed
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${UE_ID} testmode=ue_srs_beam_pos action=activate profile_id=${profile_id}

Set actUlSrsBm To False
    Delta Commission With SCF File    ${delta_json}
    Teardown All Aliases For Wts
    Teardown All Connections
    Reboot TL And Check Configured

Check Srsreceivereq From Wirshark
    [Arguments]    ${log_id}    ${SRSPeriod}
    Convert BIP To CSV By MCShark For Srsreceivereq    ${log_id}
    ${sfn1}    ${sfn2}    Check sfn In Srsreceivereq    ${log_id}
    ${sfn_delta}    Evaluate    ${sfn2}-${sfn1}
    should be equal as numbers    ${sfn_delta}    ${SRSPeriod}

Convert BIP To CSV By MCShark For Srsreceivereq
    [Arguments]    ${log_id}    ${list}=3gpp.sfn
    ${filter}=    Set Variable    uldata_srsreceivereq
    @{csv_title_list}=    Create List    ${list}
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    ${filter}    ${csv_title_list}
    END

Check sfn In Srsreceivereq
    [Arguments]    ${log_id}
    @{sfn_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    3gpp.sfn    ["1025", ""]    except    no
    [Return]    @{sfn_list}[0]    @{sfn_list}[1]

Check No Srsreceivereq From Wirshark
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For Srsreceivereq    ${log_id}
    ${sfn_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    3gpp.sfn    ["1025", ""]    except    no
    ${count}    Get Length    ${sfn_list}
    should be equal as numbers   ${count}    0

Check PatternID From Wirshark
    [Arguments]    ${log_id}    ${list_id}
    Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq    ${log_id}
    ${PatternID}    Check PatternID In Puschreceivereq    ${log_id}    ${list_id}
    [Return]   	${PatternID}

Check PatternID In Puschreceivereq
    [Arguments]    ${log_id}    ${list_id}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv     UlData_eCpriConfigStruct_t.patternId_item    ["0,0"]    except    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0
    ${PatternID}    Get From List    ${data_list_1}    ${list_id}
    [Return]   	${PatternID}

Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_puschreceivereq
    @{csv_title_list}=    Create List    UlData_eCpriConfigStruct_t.patternId_item
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv    ${filter}    ${csv_title_list}
    END

Test actUlSrsBm Enable Successfully And Check ThroughPut
    Suite Setup Start WTS And Check OnAir
    Set TestMode for SRS    UE_ID=${UE11_ID}    profile_id=1    init_pos=0
    NSA LTE Attach    ue_id=${UE11_ID}    profile_id=1
    NSA 5G Attach    ue_id=${UE11_ID}    gnb_id=2    cell_id=1    bearer_id=2
    NSA Start DL Traffic    ue_id=${UE11_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
    NSA Start UL Traffic    ue_id=${UE11_ID}    bearer_id=2    mbps=${ul_tp_set}    trf_id=1
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
    Set TestMode for SRS    UE_ID=${UE11_ID}    profile_id=2    init_pos=2
    Sleep    10s    reason=Wait for TestMode enable
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3
    ${ul_tp1}=    NSA Get UE Average Traffic    ue_id=${UE11_ID}    bearer_id=2    dir=ul
    Set Test Variable    ${ul_tp1}
    log    UL Troughput is ${ul_tp1}    console=True

Test Change port and Srs Function
    Suite Setup Start WTS And Check OnAir
    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=1    init_pos=0
    SA 5G Attach    ${UE1_ID}
    SA Internal    ${UE1_ID}    ${PDU_ID}
    SA 5G PDU Session Setup    ${UE1_ID}
    SA Start UL Traffic Internal    ${UE1_ID}    ${PDU_ID}    50    ${TRF_ID}
    Start Gnb BIP Log
    Sleep    2s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1   
    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=2    init_pos=2
    Trigger SA TestMode Change    3    20    140	
    Trigger SA TestMode Port Set   ${UE1_ID}    activate    3
    Sleep    2s    reason=Wait for testmnode stable
    Start Gnb BIP Log
    Sleep    2s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/2
    Trigger SA TestMode Port Set   ${UE1_ID}    deactivate    3
    Sleep    3s    reason=Wait for TestMode enable
    Start Gnb BIP Log
    Sleep    2s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3

Convert BIP To CSV By MCShark For UlData_SrsReceiveReq
    [Arguments]       ${id}  
    ${filter}=    Set Variable    uldata_srsreceivereq
    @{csv_title_list}=    Create List   3gpp.sfn    3gpp.slot    UlData_srsBmResource_t.bmCyclicShift
    Convert BIP To CSV By MCShark     ${TEST_LOG_DIRECTORY}/BIP/${id}/5GBipL2L1_filtering*.pcap*    
    ...    ${OUTPUT_DIR}/srsreq.csv    ${filter}    ${csv_title_list}
	
Check Patternid Beam Changed
    ${patternId_1}    Check PatternID From Wirshark    BIP/1    2
    ${patternId_2}    Check PatternID From Wirshark    BIP/3    -2
    Should Not Be Equal    ${patternId_2}    ${patternId_1}
	
Check Beam and Srs Port
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq    1
    A2A_Check_CSV_Table    ${CURDIR}/Resources/F0013_2port.ini    ${OUTPUT_DIR}/srsreq.csv
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq    2
	A2A_Check_CSV_Table    ${CURDIR}/Resources/F0013_1port.ini    ${OUTPUT_DIR}/srsreq.csv
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq    3
    A2A_Check_CSV_Table    ${CURDIR}/Resources/F0013_2port.ini    ${OUTPUT_DIR}/srsreq.csv

SA Internal
    [Arguments]    ${UE_ID}    ${PDU_ID}
    ute_wtssim.Execute Egate Command  
    ...    cmd=set_pdu_param ue=${UE_ID} pdu=${PDU_ID} trf_type=internal

Trigger SA TestMode Change
    [Arguments]    ${profile_id}    ${pcmax}    ${pathloss}    
    Log To Console    add UE testmode NR profile...
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=${profile_id} pcmax=${pcmax} pathloss=${pathloss}

Trigger SA TestMode Port Set	
    [Arguments]    ${ue_id}    ${action}    ${profile_id}
    Log To Console    set UE Testmode NR...
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=${action} profile_id=${profile_id}

Test DFT best beam selection and SRSPeriod
    Check Srsreceivereq From Wirshark    /BIP/1    8
    ${patternId_1}    Check PatternID From Wirshark    /BIP/1    2
    ${patternId_2}    Check PatternID From Wirshark    /BIP/3    -2
    Should Not Be Equal    ${patternId_2}    ${patternId_1}


Test actUlSrsBm Disable Successfully And Check ThroughPut
    Set actUlSrsBm To False
    Suite Setup Start WTS And Check OnAir
    Set TestMode for SRS    ue_id=${UE11_ID}    1    1
    NSA LTE Attach    ue_id=${UE11_ID}    profile_id=1
    NSA 5G Attach    ue_id=${UE11_ID}    gnb_id=2    cell_id=1    bearer_id=2
    NSA Start DL Traffic    ue_id=${UE11_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
    NSA Start UL Traffic    ue_id=${UE11_ID}    bearer_id=2    mbps=${ul_tp_set}    trf_id=1
    ${ul_tp2}=    NSA Get UE Average Traffic    ue_id=${UE11_ID}    bearer_id=2    dir=ul
    log    UL Troughput is ${ul_tp2}    console=True
    Should be true     ${ul_tp1}>${ul_tp2}-5
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/2
    Check No Srsreceivereq From Wirshark    /BIP/2
	
Check BWP Switch
    [Arguments]    ${first}    ${second}    ${number}=1
    Log To Console    \nCheck BWP Switch from bwpId ${first} to ${second}...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${bwp_switch}    Set Variable    Bwp Switched from bwpId ${first} to ${second}
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${bwp_switch}"|wc -l
    Should Be True    ${check_rst}>=${number}

SA Start UL Bps Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${bps}    ${trf_id}=1
    Log To Console    start UL bps traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul bps\=${bps} trf_id\=${trf_id}
    Sleep    5s    reason=wait UL traffic is stable
	
Set TestMode for Pathloss
    [Arguments]     ${ue_id}    ${profile_id}    ${pcmax}=20    ${pathloss}=140
    Log To Console    Set TestMode for SINR Pathloss
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id\=${profile_id} pcmax\=${pcmax} pathloss\=${pathloss}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=${profile_id}

Set DTX For RrmComaAgedTimer Timeout
    [Arguments]     ${profile_id}=2    ${init_pos}=1    ${dtx_start}=100    ${num_dtx}=20    ${UE_ID}=11
    Log To Console    Set DTX For RrmComaAgedTimer Timeout
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_srs_beam_pos_nr profile_id\=${profile_id} init_pos\=${init_pos} dtx_start\=${dtx_start} num_dtx\=${num_dtx} srsMode\=fixed
    Sleep    2s
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${UE_ID} testmode=ue_srs_beam_pos action=activate profile_id=${profile_id}
    Sleep     20s

Stop GNB Syslog
    [Arguments]    ${log_dir}
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${log_dir}/Gnb_syslog.tar.gz
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${log_dir}/Gnb_syslog.tar.gz
    Set Test Variable    ${btslog}    ${CURDIR}/${output}
    Sleep    10s

Check RrmCoMaAgedTimer Timeout
    BuiltIn.Log To Console    Check RrmCoMaAgedTimer Timeout...
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Send Command    command=bget 1:0 /tmp/node_L2RT20/tmp/ASP-2730_startup.log /tmp
    Sleep    2s
    ${RrmCoMaAgedTimer_info}    SSH.Execute    cat /tmp/ASP-2730_startup.log | grep -i SrsUlBmManager
    Should Contain    ${RrmCoMaAgedTimer_info}
    ...    rrmCoMaAgedTimer timeout
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Check RrmCoMaAgedTimer Timeout From Syslog
    ${RrmCoMaAgedTimer_info}=    Catenate    SEPARATOR=  rrmCoMaAgedTimer timeout
    ${rc}    ${ret}=    OperatingSystem.Run And Return Rc And Output    grep '${RrmCoMaAgedTimer_info}' ${btslog}
    @{Srslog}=    Split To Lines    ${ret}
    Log To Console    Check RrmCoMaAgedTimer Timeout...
    Should Not Be Empty    @{Srslog}[0]

NSA UE Attach and Get Throughput
    [Arguments]    ${UE_ID}=11    ${dl_tp_set}=100    ${ul_tp_set}=50    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2
    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${ul_tp_set}    trf_id=1
    Wait Until Keyword Succeeds    3min    5s    NSA UE Check Throughput    ${UE_ID}    ${dl_tp_threshold}    ${ul_tp_threshold}

Check The Number Of SRS Port
    [Arguments]    ${log_id}    ${SRSPort}
    Convert BIP To CSV By MCShark For BmCyclicShift   ${log_id}
    ${count}    Check BmCyclicShift In Srsreceivereq    ${log_id}
    should be equal as numbers    ${count}    ${SRSPort}

Convert BIP To CSV By MCShark For BmCyclicShift
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    UlData_srsBmResource_t.bmCyclicShift
    @{csv_title_list}=    Create List    UlData_srsBmResource_t.bmCyclicShift
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${TEST_LOG_DIRECTORY}/${log_id}/bmCyclicShift.csv    ${filter}    ${csv_title_list}
    END

Check BmCyclicShift In Srsreceivereq
    [Arguments]    ${log_id}
    ${BmCyclicShift_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/bmCyclicShift.csv    UlData_srsBmResource_t.bmCyclicShift   ["", ""]    except    no
    ${count}    Get Length    ${BmCyclicShift_list[0]}
    [Return]    ${count}
    
Check LegacySRS In Srsreceivereq
    [Arguments]    ${log_id}
    Log To Console    check legacySRS in srsreceivereq...
    Convert BIP To CSV By MCShark For Srsreceivereq    ${log_id}    list=UlData_srsReceiveReqUes_t.ueType
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    UlData_srsReceiveReqUes_t.ueType    ["0"]    include    no
    ${count}    Get Length    ${data_list}
    Should Be True    ${count}!=0
	
Check SSB Beam In Puschreceivereq
    [Arguments]    ${log_id}
    Log To Console    check SSB beam in puschreceivereq...
    Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq    ${log_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv    UlData_eCpriConfigStruct_t.patternId_item
    ...    ["101,106,0,0"]    include    no
    ${count}    Get Length    ${data_list}
    Should Be True    ${count}!=0
	
Check PowerSavingBWP and ASRS
    SA Start UL Bps Traffic Internal    ${UE1_ID}    pdu_id=1    bps=60    trf_id=1
    Set TestMode for Pathloss    ${UE1_ID}    profile_id=3
    Sleep    10s    reason=Wait for TestMode enable
    Check BWP Switch    first=1    second=2    number=2
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/4
    Check legacySRS In Srsreceivereq    /BIP/4
    Check SSB Beam In Puschreceivereq    /BIP/4

Check SrsSlot From Wirshark
    [Arguments]    ${log_id}    ${SrsSlot}
    Convert BIP To CSV By MCShark For Srsreceivereq    ${log_id}    3gpp.slot
    @{slot_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    3gpp.slot    ["", ""]    except    no
    should be equal as numbers    @{slot_list}[1]    ${SrsSlot}


L3 Call and Traffic
    [Arguments]    ${ue_Id}=${UE1_ID}    ${dl_tput}=175    ${ul_tput}=175
    SA Attach    ${UE1_ID}
    SA Start UL Traffic Internal    ${ue_Id}    1    ${ul_tput}
    SA Start DL Traffic Internal    ${ue_Id}    1    ${dl_tput}
    Sleep    10s    reason=Wait for logs
    SA UE Check Throughput    ${UE1_ID}    170    40
    Capture And Decode TTItrace    log_id=1
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1

SA Attach
    [Arguments]    ${sa_ue_id}
    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
    ...    ue_register
    ...    set_pdu_param
    ...    ue_pdu_session_setup
    SA 5G Attach    ue_id=${sa_ue_id}
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${sa_ue_id}

Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=2
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Check UL DTXCRC Rate
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_ul.csv    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]
    Check Rate    ${csv_file_path}    output_ul.csv    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]

Check DL DTXNACK Rate
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_dl.csv    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${csv_file_path}    output_dl.csv    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${csv_file_path}    output_dl.csv    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]

Check Rate
    [Arguments]    ${csv_file_path}    ${csv}=output_dl.csv      ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]
    ...    ${failed}=["NACK","DTX"]
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    Get Total Number    ${csv_file_path}    ${csv}    ${name}    ${total}
    ${failed_number}    Get Total Failed Number    ${csv_file_path}    ${csv}    ${name}    ${failed}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}<0.1

Collect Bip And Beam Change
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=2    init_pos=2
    Sleep    10s    reason=Wait for TestMode enable
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3

Trigger A2 MG Setup And Check
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA2}=    Get MeasID A2
    Trigger A2 MG Setup    ${UE1_ID}   meas_id=${measIdA2}
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/4
    Capture And Decode TTItrace    log_id=2
    SA UE Check Throughput    ${UE1_ID}    170    40
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/2
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/2
    Check Srsreceivereq From Wirshark    /BIP/4    4

Trigger A2 MG Setup
   [Arguments]    ${UE1_ID}    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE1_ID} meas_id=${meas_id} event=A2 srsrp_nr=70 srsrq_nr=70
    ...    pass_regexp=gapUE setup
    Sleep    5s

Trigger A3 Handover
    [Arguments]    ${UE_ID}    ${meas_id}=1
    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=70 srsrq_nr=70
    ...    ssinr_nr=10 phycell_id=51 nrsrp_nr=65 nrsrq_nr=40 nsinr_nr=50
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Get MeasID A2
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA2
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[0]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measIdA2}=    Set Variable    @{measId_list}[0]
    [Return]    ${measIdA2}

Get MeasID A3 After A2
    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA3
    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
    ${report_id}=    Set Variable    @{report_id_list}[0]
    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
    ${measId}=    Set Variable    @{measId_list}[0]
    [Return]    ${measId}

Trigger InterFreq And IntraDU HO And Check
    Save Egate Log    log_path=${Egatelog_path}
    ${measIdA3}=    Get MeasID A3 After A2
    Trigger A3 Handover    ${UE1_ID}   meas_id=${measIdA3}
    Capture And Decode TTItrace    log_id=3
    SA UE Check Throughput    ${UE1_ID}    170    40
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3

Trigger Rank1 And Collect Bip
    Trigger SA TestMode Change    3    30    130
    Trigger SA TestMode Port Set   ${UE1_ID}     activate    3
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/2

Get Total Number
    [Arguments]    ${csv_file_path}    ${csv}=output_dl.csv    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${csv_file_path}/${csv}    ${name}    ${total}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed Number
    [Arguments]    ${csv_file_path}    ${csv}=output_dl.csv    ${name}=dlFdSchedData.ackNack    ${failed}=["NACK","DTX"]
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${csv_file_path}/${csv}    ${name}     ${failed}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Set 2UE Attach And Send Traffic
    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=1    init_pos=0
    SA 5G CA Attach    ${UE1_ID}
    SA Start UL Traffic Internal    ${UE1_ID}    pdu_id=1    mbps=20    trf_id=1
    SA Start DL Traffic Internal    ${UE1_ID}    pdu_id=1    mbps=20    trf_id=1
    Set TestMode for SRS    UE_ID=${UE2_ID}    profile_id=1    init_pos=0
    SA 5G CA Attach    ${UE2_ID}
    SA Start UL Traffic Internal    ${UE2_ID}    pdu_id=1    mbps=20    trf_id=2
    SA Start DL Traffic Internal    ${UE2_ID}    pdu_id=1    mbps=20    trf_id=2
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1

Set Beam Pos For 2UE
    Set TestMode for SRS    UE_ID=${UE1_ID}    profile_id=2    init_pos=2
    Set TestMode for SRS    UE_ID=${UE2_ID}    profile_id=2    init_pos=2
    Start Gnb BIP Log
    Sleep    3s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/3

Check SRS Slot When enable InfTddFrameMuting
    [Arguments]    ${log_id}
    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${OUTPUT_DIR}/InfTddFrameMuting.csv    filter=uldata_srsreceivereq
    ...    csv_title_list=${COLUMN_NAME}
    Run    sed -i 's/"//g' ${OUTPUT_DIR}/InfTddFrameMuting.csv
    Sleep    3s    reason=Wait for csv stable
    A2A_Check_CSV_Table    ${CURDIR}/Resources/InfTddFrameMuting_slot.ini    ${OUTPUT_DIR}/InfTddFrameMuting.csv
