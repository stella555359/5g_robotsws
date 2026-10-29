*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02

Library    ./CB013945_TTI_Trace_Analysis.py
Library    taf.rfrl.common_resources.python.SWConfig   WITH NAME    swconf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
@{cpe_ue_index}    0    1    2    3    4
${spark_ue_index}    5
@{pci}    92    92    93    93    94
@{2mimocell_ids}    185663489    185663490
@{cell_id}    185663491
${ul_process_num}    5
@{counter_id}   M55308C10002    M55308C10006    M55308C35005    M55308C35007    M55308C10004
@{full_path}    CELLS/NRCELL-1/NCELA/PRB_USED_PUSCH
...             CELLS/NRCELL-1/NCELA/PRB_AVAIL_PUSCH_BB_POOL
...             CELLS/NRCELL-1/NCELA/PRB_UL_MU_MIMO_4LAYER
...             CELLS/NRCELL-1/NCELA/PRB_UL_MU_MIMO_2PAIR_UE
...             CELLS/NRCELL-1/NCELA/PRB_AVAIL_PUSCH
${ul_tp}    ${230}
${dl_tp}    ${1500}

*** Keywords ***
Check_Dynamic_Switch_to_RAT0
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${rat_result}    check_dynamic_switch_status
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name=rat0Bitmap
    should be True    ${rat_result}

Check_2UEs_DL_Mumimo_Paired
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    Log to console     \n***check Mumimo paired***
    Run Keyword And Ignore Error    ssh.send command    command=rm -rf /home/ute/output_log/*
    ...    connection=ute
    Run Keyword And Ignore Error    ssh.disconnect    connection=ute
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${dl_mumimo}    check_dl_muStatus
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name=muStatus
    should be True    ${dl_mumimo}

Perform and Check Vonr Call
    [Arguments]    ${mo_ueindex}=0    ${duration}=20
    spark.Update_test_plan    ue_alias=UE_${mo_ueindex}    call_type=0
    ...    Duration=${duration}
    sleep    3s
    spark.Start_test_plan  ue_alias=UE_${mo_ueindex}    task_name=CallMO
    sleep    10s

Spark_MultiUE Prepare
    [Arguments]    ${ue_list}    ${get_spark_license}=false
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${spark_ue_index}
    Set Test Variable    ${ue_type}
    FOR    ${ue_index}    IN    @{ue_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}     power_reset=true    get_spark_license=${get_spark_license}
        sleep    5s
    END
    log to console      UE ${ue_list} prepare

Spark_MultiUE Attach
    [Arguments]    ${ue_list}
    FOR    ${ue_index}    IN    @{ue_list}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
        ...    attach_mode=5G_SA    power_reset=true
        sleep    10s
        spark verify attach and retry if attach failed   5Grach_ed=${5Grach_ed_0}    ue_index=${ue_index}    retry_times=3
        sleep    3s
    END
    log to console      UE ${ue_list} attach

Spark_MultiUE Detach
    [Arguments]    ${ue_list}
    FOR    ${ue_index}    IN    @{ue_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${spark_ue_index}
        Set Test Variable    ${ue_type}
        power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=true
        sleep    5s
    END
    log to console      UE ${ue_list} detach

MultiUE Start dlul traffic
    [Arguments]    ${ue_list}    ${apn}    ${ues_dltput}    ${ues_ultput}
    FOR    ${ue_index}    IN    @{ue_list}
        Run Keyword If   '${ues_dltput}[${ue_index}]'!='0MKbits/sec'    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    throughput=${ues_dltput}[${ue_index}]    protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        Run Keyword If   '${ues_ultput}[${ue_index}]'!='0MKbits/sec'    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=ul    throughput=${ues_ultput}[${ue_index}]    protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        sleep    1s
    END
    log to console      UE ${ue_list} start dlul traffic

spark verify attach and retry if attach failed
    [Arguments]    ${5Grach_ed}    ${ue_index}    ${retry_times}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed}    4G_check=False
    FOR    ${times}    IN RANGE    ${retry_times}
        ${status}    ${ue_ip}    run keyword and ignore error
        ...    spark.get_ue_ip_on_ue    ue_alias=UE_${ue_index}    ue_mode=MultiUE_SA
        ${ue_ip_valid}    Run Keyword And Return Status    should not be equal    ${ue_ip}    0.0.0.0
        Run Keyword If    '${status}'!='PASS' or '${ue_ip_valid}'!='True'    Spark_Ue_recovery    ue_index=${ue_index}
        ...   ELSE   Exit For Loop
    END
    Run Keyword If    '${status}' == 'PASS'    log to console      ue ${ue_index} attach success and get ip: ${ue_ip}
    ...   ELSE   log to console      ue ${ue_index} attach failed for ${retry_times} times

Spark_Ue_recovery
    [Arguments]    ${ue_index}
    log to console      ue ${ue_index} attach failed, try to recovery
    spark.send_at_command_on_ue    command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
    sleep    120s
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=true
    sleep    60s
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_SA    power_reset=true
    sleep    30s

Check_Start_Prb_Randomization
    [Arguments]    ${ue_index}    ${cpe_ue_index}    ${dl_tp}
    Muti_CPE_UEs_DL_Traffic    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}    dl_tp=${dl_tp}
    Catch_Logs_with_gnb_logs
    Check_2UEs_DL_Mumimo_Paired
    Multi CPE stop dl traffic    ue_index=${ue_index}    cpe_ue_index=${cpe_ue_index}
    ${random_start_prb_num}    set variable    ${0}
    ${specific_ttitrace_file}    Get_and_Unzip_Tti_Log
    ${random_start_prb_num}    check_start_prb_num
    ...    csv_file=${specific_ttitrace_file}[0]
    ...    filter_name=type
    ...    expect_name=startPrb
    should be True    ${random_start_prb_num} != 0

Modify_Swconfig_And_Crasign
    [Arguments]    ${swconfig_modify}    ${localFilePath}
    Connect to Common Unit Master    gnb_index=0    du_index=0    alias=ASIB
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=${localFilePath}/swconfig.txt    asik_alias=ASIB
    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${localFilePath}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${localFilePath}/swconfig.txt    asik_alias=ASIB
    Run keyword and ignore error    csn.disconnect    connection=ASIB

Delete_Swconfig_Paramter_And_Crasign
    [Arguments]    ${swconfig_modify}    ${localFilePath}
    Connect to Common Unit Master    gnb_index=0    du_index=0    alias=ASIB
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=${localFilePath}/swconfig.txt    asik_alias=ASIB
    swconf.delete parameter of swConfig file    parametersList=${swconfig_modify}    filePath=${localFilePath}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${localFilePath}/swconfig.txt    asik_alias=ASIB
    Run keyword and ignore error    csn.disconnect    connection=ASIB
