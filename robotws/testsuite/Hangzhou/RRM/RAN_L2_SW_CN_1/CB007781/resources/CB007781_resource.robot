*** Settings ***
Resource    ../../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${AP_ASIK_IP}                192.168.200.1
${AP_ASIK_LONER_IP}          192.168.253.86
${CONF_FILE_LONER_DIR}       /etc/5g-layer-1
${CONF_FILE_MASTER_DIR}      /ffs/run/boardcfg/1/C/mcu-aspa/boot
${MAX_WAITTIME_TP_ENABLE}    12s

*** Keywords ***
Add Noise To AP L1
    Log    ${output_dir}
    ${local_save_path}    Get Const Customizer From AP    ${output_dir}
    Modify AP L1 Noise    ${local_save_path}
    Send AP L1 New Noise File To AP    ${local_save_path}

Get Const Customizer From AP
    [Arguments]    ${save_dir}
    ute_fsmaccess.Setup Wts Fsm Access
    Log    Copy AP loner const_customizer.conf to master
    ute_fsmaccess.Execute Command On Wts    scp toor4nsn@${AP_ASIK_LONER_IP}:${CONF_FILE_LONER_DIR}/const_customizer.conf ${CONF_FILE_MASTER_DIR}
    ute_fsmaccess.Execute Command On Wts    ls -l ${CONF_FILE_MASTER_DIR} | grep const_customizer.conf
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@${AP_ASIK_IP}:${CONF_FILE_MASTER_DIR}/const_customizer.conf ${save_dir}/const_customizer.conf
    OperatingSystem.Should Exist    ${save_dir}/const_customizer.conf
    ${path}    Set Variable    ${save_dir}/const_customizer.conf
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${path}

Modify AP L1 Noise
    [Arguments]    ${path}
    Log    Update tx_noise_gen_en_ant0/tx_noise_gen_en_ant1/tx_noise_gen_en_ant2/tx_noise_gen_en_ant3's value to 1
    : For    ${index}    IN RANGE    0    4
    \    ${content} =    OperatingSystem.Get File    path=${path}
    \    ${noise_regexp} =    Set Variable    tx_noise_gen_en_ant${index} = (?P<noise_old>\\d)
    \    ${replace_noise_with} =    Set Variable    tx_noise_gen_en_ant${index} = 1
    \    ${new_content} =    String.Replace String Using Regexp
    ...    string=${content}
    ...    pattern=${noise_regexp}
    ...    replace_with=${replace_noise_with}
    \    OperatingSystem.Create File    path=${path}    content=${new_content}

Send AP L1 New Noise File To AP
    [Arguments]    ${path}
    Log    Send new noise file to AP master and sign for it.
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@${AP_ASIK_IP}:/ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf
    ${crasign_cmd}    Set Variable    crasign /ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf
    ${craverify_cmd}    Set Variable    craverify /ffs/run/boardcfg/1/C/mcu-aspa/boot/const_customizer.conf*
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${AP_ASIK_IP} ${crasign_cmd}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${AP_ASIK_IP} ${craverify_cmd}
    Should Be Equal As Integers    ${rc}    0

SA Start UL Traffic And Decrease SINR TO Trigger TP Enabled
    [Arguments]    ${mbps}=5    ${duration}=10    ${len}=1300    ${max_num_pusch_down}=10
    Log To Console    start UL traffic...
    Execute Iperf In Linux    args=-c 72.23.0.1 -u -p ${ul_port} -l ${len} -b ${mbps}M -i 1 -t ${duration}
    Sleep    3s
    Execute Iperf In Linux    args=-s -u -p ${ul_port} -i 1 -B 10.0.2.1
    ...    pipe_args=| tee /tmp/iperf_ul.txt
    Log To Console    Running UL Traffic ${mbps}M in backgroud, wait 60s till traffic stable then trigger TP enabled.
    Sleep    60s
#    ${pusch_power} =    Set Variable    0
#    : For    ${index_time}    IN RANGE    1    ${max_num_pusch_down}+1
#    \    ${pusch_power} =    Evaluate    ${pusch_power}-5
#    \    Adjust Sinr Target Pusch Step By Step    1    ${pusch_power}
#    \    Sleep    5s    reason=wait for pusch Sinr adjust
#    ute_wtssim.Execute Egate Command    cmd=ue_disp id=${ue_id}
#    Run Keyword And Continue On Failure    Judge TP Enabled Tag To Confirm Whether Continue Second Trigger Method
#    Judge TP Enabled Tag To Confirm Whether Continue Second Trigger Method
     Adjust pathloss and Pusch Transmit power To Trigger TP Enabled

Judge TP Enabled Tag To Confirm Whether Continue Second Trigger Method
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${output_dir}/egate_console.log
    ${egate_tp_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log    transformPrecoder enabled
    Run Keyword If    '${egate_tp_tag}'=='${empty}'    Adjust Pathloss And Pusch Transmit Power To Trigger TP Enabled

Adjust Pathloss And Pusch Transmit Power To Trigger TP Enabled
    ${pathloss}    Set Variable    30
    ${pathloss_adjust_times}    Set Variable    6
    Adjust PUSCH Pathloss    pusch_pathloss=${pathloss}    max_num_pusch_pathloss=${pathloss_adjust_times}
    Adjust Pusch Transmit Power

Kill Iperf Process
    Run Keyword And Ignore Error    OperatingSystem.Run    cp /tmp/iperf_ul.txt ${output_dir}/iperf_ul.txt
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs sudo kill -9

Adjust Sinr Target Pusch Step By Step
    [Arguments]    ${ue_id}=1    ${sinr_target_pusch}=-10
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=${sinr_target_pusch}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=activate profile_id=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1

Adjust Pusch Transmit Power
    [Arguments]    ${pusch_tx_power}=-100    ${max_num_pusch_tx_power}=4
    : For    ${index_time}    IN RANGE    1    ${max_num_pusch_tx_power}+1
    \    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pusch_tx_power=${pusch_tx_power}
    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
    \    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1
    \    ${pusch_tx_power} =    Evaluate    ${pusch_tx_power}-100
    \    Sleep    8s
    ute_wtssim.Execute Egate Command    cmd=ue_disp id=${ue_id}

Increase SINR To Trigger TP Disabled
    Run Keyword And Ignore Error    Adjust Pusch Transmit Power    -200    1
    Sleep    10s    reason=wait for pusch transmit power adjust
    Run Keyword And Ignore Error    Adjust Pusch Transmit Power    0    1
    Sleep    3s    reason=wait for pusch transmit power adjust
    Run Keyword And Ignore Error    Adjust Sinr Target Pusch Step By Step    1    20
    Sleep    10s    reason=wait for pusch Sinr adjust

Egate Console Confirm TP Enabled Keyword
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${output_dir}/egate_console.log
    ${egate_tp_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log    transformPrecoder enabled
    Should Not Be Empty    ${egate_tp_tag}

Egate Console Confirm TP Disabled Keyword
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${output_dir}/egate_console.log
    ${egate_tp_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log    transformPrecoder disabled
    Should Not Be Empty    ${egate_tp_tag}

Method2 For Egate Console Confirm TP Enabled Keyword
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${output_dir}/egate_console.log
    ${cmd}=    Set Variable    grep -i "transformPrecoder enabled" ${output_dir}/egate_console.log
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Contain    ${output}    transformPrecoder enabled    ignore_case=True

Convert All BIP Log To Csv Files And Do Regex Check
    [Arguments]    ${bip_log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    @{matches_list}    Create List
    ${count}    OperatingSystem.Count Items In Directory    ${bip_log_dir}    pattern=5GBipL2L1_filtering_off.pcap*
    FOR    ${index}    IN RANGE    ${count}
    Log To Console    \nDeal with BIP_LOG:5GBipL2L1_filtering_off.pcap${index}...
    ${bip_log}    Catenate    SEPARATOR=//    ${bip_log_dir}    5GBipL2L1_filtering_off.pcap${index}
    ${csv_content}    Convert BIP Log Pcap To Csv    ${bip_log}    ${filter}
    ...    ${column_name}    ${csv_name_tag}${index}
    ${matches}    Get Match List From BIP Csv File    ${csv_content}    ${check_point_regexp}
    Append To List    ${matches_list}    ${matches}
    Log    ${matches_list}
    END
    [Return]    ${matches_list}

Convert BIP To CSV By MCShark And Do Regex Check
    [Arguments]    ${bip_dir}    ${bip_tag_name}    ${check_point_regexp}
    @{matches_list}    Create List
    ${filter}=    Set Variable    uldata_puschreceivereq||uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti
    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
    ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfPrb
    ...    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_dir}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${bip_dir}/Bip_${bip_tag_name}.csv    ${filter}    ${csv_title_list}
         ${matches}    Get Match List From BIP Csv File    ${bip_dir}/Bip_${bip_tag_name}.csv    ${check_point_regexp}
         Append To List    ${matches_list}    ${matches}
         Log    ${matches_list}
    END
    [Return]    ${matches_list}

Get UL Tput After TP Enabled And Make Sure Larger Than 0
    ${ul_avg_enabled} =    SA Get UE Average Traffic    dir=${dir_ul}
    Should Be True    ${ul_avg_enabled}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue

Get UL Tput After TP Disabled And Make Sure Larger Than 0
    ${ul_avg_disabled} =    SA Get UE Average Traffic    dir=${dir_ul}
    Should Be True    ${ul_avg_disabled}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue

Verify UL Not ACK Rate After TP Enabled
    [Arguments]    ${max_crc_nok_rate}=0.38
    Verify UL Not ACK Rate Less Than Target    ${test_log_directory}_TP_Enable    ${max_crc_nok_rate}

Verify UL Not ACK Rate After TP Disabled
    [Arguments]    ${max_crc_nok_rate}=0.3
    Verify UL Not ACK Rate Less Than Target    ${test_log_directory}_TP_Disable    ${max_crc_nok_rate}

Config Endc Parameter
    [Arguments]
    ute_wtssim.Execute Egate Command
    ...    cmd=enb_endc_param id=1 serving_cell_index_range_scg=5:31

Adjust Sinr Target Pathloss Step By Step
    [Arguments]    ${ue_id}=11    ${sinr_target_pathloss}=60
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=5
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1

NSA Start UL Traffic And Decrease SINR TO Trigger TP Enabled
    [Arguments]    ${max_num_pathloss}=5
    ${init_pathloss} =    Set Variable    60
    : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
    \    ${init_pathloss} =    Evaluate    ${init_pathloss}+10
    \    Adjust Sinr Target Pathloss Step By Step    11    ${init_pathloss}
    \    Sleep    5s    reason=wait for pathloss up
    ute_wtssim.Execute Egate Command    cmd=ue_disp id=${ue_id}
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${output_dir}/egate_console.log
    ${nsa_egate_tp_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log    transformPrecoder enabled
    Run Keyword If    '${nsa_egate_tp_tag}'=='${empty}'    Adjust Sinr Target Pathloss Step By Step    11    120

Increase SINR Pathloss To Trigger TP Disabled
    Adjust Sinr Target Pathloss Step By Step    1    100
    Sleep    3s    reason=wait for pathloss down
    Adjust Sinr Target Pathloss Step By Step    1    80
    Sleep    3s    reason=wait for pathloss down
    Adjust Sinr Target Pathloss Step By Step    1    60

