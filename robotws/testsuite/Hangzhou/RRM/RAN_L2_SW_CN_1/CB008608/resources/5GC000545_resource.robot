*** Settings ***
Documentation    ...
Resource    ../../CUDU_L2_AIC/common_aic_setup_teardown.robot


*** Variables ***
${AP_ASIK_IP}                192.168.200.1
${AP_ASIK_LONER_IP}          192.168.253.86
${CONF_FILE_LONER_DIR}       /etc/5g-layer-1
${CONF_FILE_MASTER_DIR}      /ffs/run/boardcfg/1/C/mcu-aspa/boot
${MAX_WAITTIME_TP_ENABLE}    12s

*** Keywords ***

Judge TP Enabled Tag To Confirm Whether Continue Second Trigger Method
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${output_dir}/egate_console.log
    ${egate_tp_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log    transformPrecoder enabled
    Run Keyword If    '${egate_tp_tag}'=='${empty}'    Adjust pathloss and Pusch Transmit power To Trigger TP Enabled



Kill Iperf Process
    Run Keyword and ignore error    OperatingSystem.Run    cp /tmp/iperf_ul.txt ${output_dir}/iperf_ul.txt
    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs sudo kill -9


Adjust PUSCH Pathloss
    [Arguments]    ${pusch_pathloss}=80    ${max_num_pusch_pathloss}=8
    FOR    ${index_time}    IN RANGE    1    ${max_num_pusch_pathloss}+1
        ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pusch_pathloss}
        ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1
        ${pusch_pathloss} =    Evaluate    ${pusch_pathloss}+10
        Sleep    1s
    END

Adjust Pusch Transmit Power
    [Arguments]     ${pusch_tx_power}=-100    ${max_num_pusch_tx_power}=4
    FOR    ${index_time}    IN RANGE    1    ${max_num_pusch_tx_power}+1
        ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pusch_tx_power=${pusch_tx_power}
        ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
        ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1
        ${pusch_tx_power} =    Evaluate    ${pusch_tx_power}-100
        Sleep    3s
    END
    ute_wtssim.Execute Egate Command    cmd=ue_disp id=${ue_id}

Increase SINR To Trigger TP Disabled
    Run Keyword and ignore error    Adjust Pusch Transmit Power    -200    1
    Sleep    10s    reason=wait for pusch transmit power adjust
    Run Keyword and ignore error    Adjust Pusch Transmit Power    0    1
    Sleep    3s    reason=wait for pusch transmit power adjust
    Run Keyword and ignore error    Adjust Sinr Target Pusch Step By Step    1    20
    Sleep    10s    reason=wait for pusch Sinr adjust

Egate Console Confirm TP Enabled Keyword
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${output_dir}/egate_console.log
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



Convert BIP To CSV By MCShark And Do Regex Check
    [Arguments]    ${bip_dir}    ${bip_tag_name}    ${check_point_regexp}
    @{matches_list}    Create List
    ${filter}=    Set Variable    uldata_puschreceivereq||uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti
    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
    ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfPrb
    ...    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
    Convert BIP To CSV By MCShark   ${bip_dir}/l1bipl1.pcap    ${bip_dir}/Bip_${bip_tag_name}.csv    ${filter}    ${csv_title_list}
    ${matches}    Get Match List From BIP Csv File    ${bip_dir}/Bip_${bip_tag_name}.csv    ${check_point_regexp}
    Append To List    ${matches_list}    ${matches}
    Log    ${matches_list}
    [Return]    ${matches_list}

Verify UL Not ACK Rate After TP Enabled
    [Arguments]    ${max_crc_nok_rate}=0.38
    Verify UL Not ACK Rate Less Than Target    ${test_log_directory}/_TP_Enable    ${max_crc_nok_rate}

Verify UL Not ACK Rate After TP Disabled
    [Arguments]    ${max_crc_nok_rate}=0.3
    Verify UL Not ACK Rate Less Than Target    ${test_log_directory}/_TP_Disable    ${max_crc_nok_rate}

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
    [Arguments]    ${max_num_pathloss}=4
    ${init_pathloss} =    Set Variable    60
    FOR    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
        ${init_pathloss} =    Evaluate    ${init_pathloss}+10
        Adjust Sinr Target Pathloss Step By Step    11    ${init_pathloss}
        Sleep    5s    reason=wait for pathloss up
    END
    ute_wtssim.Execute Egate Command    cmd=ue_disp id=${ue_id}

Increase SINR Pathloss To Trigger TP Disabled
    Adjust Sinr Target Pathloss Step By Step    1    90
    Sleep    3s    reason=wait for pathloss down
    Adjust Sinr Target Pathloss Step By Step    1    80
    Sleep    3s    reason=wait for pathloss down
    Adjust Sinr Target Pathloss Step By Step    1    70
