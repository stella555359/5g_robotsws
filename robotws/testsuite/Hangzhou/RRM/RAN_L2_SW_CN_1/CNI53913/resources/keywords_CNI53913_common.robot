*** Settings ***
Resource          ./../../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${RD_PARAM}            0x58012B=1
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
@{LOG_NAME_LIST}       btslog    snapshot
${COUNT}               0
${TRF_ID1}              1
${TRF_ID2}              2
${TRF_ID3}              3
${TRF_ID4}              4
${multi_drbs_basic_file_path}    ${CURDIR}
${GNB_ip}                     192.168.255.1
${GNB_username}               toor4nsn
${GNB_password}               oZPS0POrRieRtu
${LOG_PATH}       ${OUTPUT DIR}

*** Keywords ***
Case Setup Use Multi-UEs lua Start WTS And Check OnAir
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Use Multi-UEs lua Start UTE WTS
    Setup X2 Connection
    Verify Cell Setup

Change CQI to number
    [Arguments]    ${ue_id}    ${CQI_value}
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id\=${UE_ID} cqi_mode\=fixed cqi\=${CQI_value}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${UE_ID}
    Run keyword if    '${CQI_value}'=='1'
    ...    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=2 dl_bler\=200
    ...    ELSE    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=2 dl_bler\=0
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${UE_ID} testmode\=bler action\=activate profile_id\=2
    ute_wtssim.Execute Egate Command    cmd=enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
    Sleep    3s    reason=wait command finish
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Sleep    3s    reason=wait command finish

Connect to GNB
    SSH.Connect To    hostname=${GNB_ip}    username=${GNB_username}    password=${GNB_password}    alias=GNB

Connect to WTS
    SSH.connect to    hostname=${TLPC_IP}    username=${TLPC_SSH_UE}    password=${TLPC_SSH_PWD}    alias=WTS

Modify swconfig for CNI53913
    Connect to WTS
    SSH.send_command    command=scp 192.168.255.1:/ffs/run/swconfig.txt ${LOG_PATH}/swconfig.txt    connection=WTS
    Sleep    3s    reason=wait command finish
    Modify File Parameter    ${LOG_PATH}/swconfig.txt    0x580011    \#0x580011
    Modify File Parameter    ${LOG_PATH}/swconfig.txt    0x580012    \#0x580012
    Modify File Parameter    ${LOG_PATH}/swconfig.txt    0x580013    \#0x580013
    Modify File Parameter    ${LOG_PATH}/swconfig.txt    0x580014    \#0x580014
    Modify File Parameter    ${LOG_PATH}/swconfig.txt    0x58000E    \#0x58000E
    Modify File Parameter    ${LOG_PATH}/swconfig.txt    0x580010    \#0x580010
    Sleep    3s    reason=wait command finish
    SSH.send_command    command=scp ${LOG_PATH}/swconfig.txt 192.168.255.1:/ffs/run/swconfig.txt    connection=WTS
    Sleep    3s    reason=wait command finish
    Connect to GNB
    SSH.send_command    command=crasign /ffs/run/swconfig.txt    connection=GNB
    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS
    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB

Make L3call and Verify tput for case004
    ute_wtssim.Execute Egate Command
    ...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=start_traffic_kbps_with_range\(11,15,2,dl,${TRF_ID1},120000\)
    Sleep    60s    reason=wait for throughput stable
    ${dl_average1}    NSA Get UE Average Traffic    11    ${BEARER_ID}    dl
    ${dl_average2}    NSA Get UE Average Traffic    12    ${BEARER_ID}    dl
    ${dl_average3}    NSA Get UE Average Traffic    13    ${BEARER_ID}    dl
    ${dl_average4}    NSA Get UE Average Traffic    14    ${BEARER_ID}    dl
    ${dl_average5}    NSA Get UE Average Traffic    15    ${BEARER_ID}    dl
    should be true    ${dl_average2}>${dl_average1}*0.95
    should be true    ${dl_average2}<${dl_average1}*1.05
    should be true    ${dl_average1}>${dl_average3}
    should be true    ${dl_average1}>${dl_average4}
    should be true    ${dl_average1}>${dl_average5}
    should be true    ${dl_average4}>${dl_average3}*0.95
    should be true    ${dl_average4}<${dl_average3}*1.05
    should be true    ${dl_average5}>${dl_average3}*0.95
    should be true    ${dl_average5}<${dl_average3}*1.05

#Makesure UTEVM Sherpa tool can work
#    OperatingSystem.Run    sudo usermod -a -G sherpa ute
#    OperatingSystem.Run    sudo setcap cap_net_raw,cap_net_admin=eip /opt/Nokia/Sherpa_5G_18/Sherpa

Multi-UEs attach and L3 call
    [Arguments]    ${number_ue}
    FOR    ${index}    IN RANGE    ${UE_ID}    ${UE_ID}+${number_ue}
         NSA LTE Attach    ${index}    ${PROFILE_ID}
         NSA 5G Attach    ${index}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    END
    ${End_ue}    evaluate    ${number_ue}+10
    ute_wtssim.Execute Egate Command
  	...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=start_traffic_kbps_with_range\(${UE_ID},${End_ue},2,dl,${TRF_ID1},150000\)
    Sleep    60s    reason=wait for throughput stable
    ${Exp_tput}    evaluate    300/${number_ue}
    ${DL_average_list}    Create List
    FOR    ${index}    IN RANGE    ${UE_ID}    ${UE_ID}+${number_ue}
         NSA Check Average Traffic bigger than target    ${index}    ${BEARER_ID}    dl    ${Exp_tput}
         ${DL_average}    NSA Get UE Average Traffic    ${index}    ${BEARER_ID}    dl
         Append To List    ${DL_average_list}     ${DL_average}
    END
    Log To Console    ${DL_average_list}

Multi-UEs sgnb_release_and_detach
    [Arguments]    ${number_ue}
    ${End_ue}    evaluate    ${UE_ID}+${number_ue}-1
    ute_wtssim.Execute Egate Command
  	...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=stop_traffic\(${UE_ID},${End_ue},2,dl\)
  	Sleep    30s    reason=wait command finish
    ute_wtssim.Execute Egate Command
	  ...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=sgnb_release_and_detach_multi_ue_with_range\(${UE_ID},${End_ue},${BEARER_ID}\)
    ...    pass_regexp=detached
    Sleep    60s    reason=wait command finish

NSA DL Stop Traffic and Detach
    [Arguments]    ${ue_id}    ${bearer_id}
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir=dl
    Sleep    3s    reason=wait command finish
    NSA LTE Detach    ${ue_id}
    Sleep    3s    reason=wait command finish

NSA Start 600M DL Traffic and get tput
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    150    ${TRF_ID1}
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    150    ${TRF_ID2}
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    150    ${TRF_ID3}
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    150    ${TRF_ID4}
    Sleep    60s    reason=wait for throughput stable
    ${DL_average}    NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
	[Return]    ${DL_average}

Sherpa log capture and check
    Start Sherpa L2stream Log    ${L2STREAM_CONFIG}
    Sleep    8s    reason=wait command finish
    Stop Sherpa L2stream Log     ${LOG_PATH}
    Makesure UTEVM Sherpa tool can work
    Convert Pcap To Sherpa Csv     ${LOG_PATH}
    Sherpa Analyzer Check Values Is True    ${SHERPA_CSV_DIRECTORY}micro__ControlFlows.csv    TEXT    formatReport=1
    Sherpa Analyzer Check Values Is True    ${SHERPA_CSV_DIRECTORY}micro__ControlFlows.csv    TEXT    bufferThreshold:1
    Sherpa Analyzer Check Values Is True    ${SHERPA_CSV_DIRECTORY}micro__ControlFlows.csv    TEXT    maxthroughput:[0-9]+kB/s

Ten UEs attach with different bler and L3 call
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=10 dl_bler\=100,100,100,100,100,100,100,100
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=20 dl_bler\=200,200,200,200,200,200,200,200
    FOR    ${index}    IN RANGE    ${UE_ID}    ${UE_ID}+10
         ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${index}    pass_regexp=UE IS ACTIVE    timeout=300
         Log To Console    lte_attach_is_ok
         ute_wtssim.Execute Egate Command    cmd=enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
         Sleep    3s    reason=wait command finish
         ute_wtssim.Execute Egate Command
         ...    cmd=ue_dc_enb_start ue\=${index} target_gnb\=${GNB_ID} target_cells\=${CELL_ID} bearer\=${BEARER_ID} type\=split_scg
         ...    pass_regexp=reported successful RA    timeout=300
         Log To Console    UE_attach_is_ok
         Sleep    3s    reason=wait command finish
    END
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=11 testmode\=bler action\=activate profile_id\=10 scell\=5
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=12 testmode\=bler action\=activate profile_id\=10 scell\=5
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=13 testmode\=bler action\=activate profile_id\=10 scell\=5
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=14 testmode\=bler action\=activate profile_id\=20 scell\=5
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=15 testmode\=bler action\=activate profile_id\=20 scell\=5
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=16 testmode\=bler action\=activate profile_id\=20 scell\=5
    ute_wtssim.Execute Egate Command    ue_testmode_set_nr id\=17 testmode\=bler action\=activate profile_id\=20 scell\=5
    Sleep    3s    reason=wait command finish
    ute_wtssim.Execute Egate Command
  	...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=start_traffic_kbps_with_range\(11,20,2,dl,${TRF_ID1},80000\)
    Sleep    60s    reason=wait for throughput stable
    ${DL_average_list}    Create List
    FOR    ${index}    IN RANGE    ${UE_ID}    ${UE_ID}+10
         ${DL_average}    NSA Get UE Average Traffic    ${index}    ${BEARER_ID}    dl
         Append To List    ${DL_average_list}     ${DL_average}
    END
    Log To Console    ${DL_average_list}

Test Teardown
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate
    common_log_capture.Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts

Two UEs attach and intermittent L3 call
    ute_wtssim.Execute Egate Command
    ...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=lte_attach_with_profile_multi_ue_with_range\(11,12,${PROFILE_ID}\)
    ...    pass_regexp=UE IS ACTIVE    timeout=300
    Log To Console    UE Attach to LTE is OK
    Sleep    15s    reason=wait command finish
    ute_wtssim.Execute Egate Command
    ...    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=sgnb_addition_multi_ue_with_range\(11,12,${BEARER_ID},${GNB_ID},${CELL_ID}\)
    ...    pass_regexp=reported successful RA    timeout=200
    Log To Console    UE Attach to 5G is OK
    Sleep    15s    reason=wait command finish
    ute_wtssim.Execute Egate Command    cmd=script file\=${WTS_DIR}/multi_ue_script.lua entry\=case005\(11,12,2,2,dl,${TRF_ID1},150000\)

Use Multi-UEs lua Start UTE WTS
    Log To Console    Use Multi-UEs lua Start WTS...
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    Run    sed -i 's/set_uec file=.*\.xml/set_uec file=${WTS_AP_XML}/' ${WTS_DIR}/multi_ue_nsa_call_tdd_64QAM_cmW.lua
    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/multi_ue_nsa_call_tdd_64QAM_cmW.lua
    ...    pass_regexp=(SimMode is ready now|UEC-1 is active)
    Wait Until Keyword Succeeds    120sec    15sec
    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE

Upload multi UE scripts to WTS
    Connect to WTS
    SSH.send_command    command=cp ${multi_drbs_basic_file_path}/multi_ue_nsa_call_tdd_64QAM_cmW.lua ${WTS_DIR}    connection=WTS
    SSH.send_command    command=cp ${multi_drbs_basic_file_path}/multi_ue_script.lua ${WTS_DIR}    connection=WTS
    Run Keyword And Ignore Error    SSH.Disconnect    connection=WTS

Verify tput after CQI change for case001
    [Arguments]    ${DL_average1}    ${DL_average2}    ${DL_average3}
    Should Be True    ${DL_average2}<${DL_average1}
    Should Be True    ${DL_average2}<${DL_average3}
    Should be true    ${DL_average3}>${DL_average1}*0.95
    Should be true    ${DL_average3}<${DL_average1}*1.05
