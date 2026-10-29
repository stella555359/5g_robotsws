*** Settings ***
Suite Setup       Qualcomm Common Suite Setup
Suite Teardown    Qualcomm Common Suite Teardown
Test Setup        Qualcomm Common Test Setup
#Test Teardown     Qualcomm Common Test Teardown
Force Tags        qualcomm    owner_l3gao    SBTS00   SBTS22R4   CRT
Resource          ../../resources/KISS/robot/common_resource.robot
Resource          ../../resources/sg10/internal_resource/internal_resource.robot
Library           taf.sbts.oam.coam.admin
Library           taf.pdu


Documentation     gNB10316  @{Rdparameter}
...    PMcounter 0x340000:15

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${UE1_ID}         10a5c6e6  #MCS B1-2-3-4   MTP8450
${UE2_ID}         ca3e3465  #MCS B5-6-7-8   MTP8450
${UE3_ID}         f19fafe0  #MCS B9-10-11-12   MTP8350
${UE4_ID}         72d1d395  #MCS B9-10-11-12   MTP8350
${UE_DL_PORT}    5001
${UE_UL_PORT}    5004
${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
${DL_SEND_DATA_CMD}    -u -t 8000 -i 1 -P 1 -f m -b 600.00M -l 1400B -T 64
${DL_SEND_DATA_CMD_rank4}    -u -t 8000 -i 1 -P 1 -f m -b 600.00M -l 1400B -T 64
${DL_SEND_DATA_CMD_rank3}    -u -t 8000 -i 1 -P 1 -f m -b 450.00M -l 1400B -T 64
${DL_SEND_DATA_CMD_rank2}    -u -t 8000 -i 1 -P 1 -f m -b 300.00M -l 1400B -T 64
${DL_SEND_DATA_CMD_rank1}    -u -t 8000 -i 1 -P 1 -f m -b 150.00M -l 1400B -T 64
${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
${EXPORT_GRID}    ${None}
&{GNBMIRRORINGCONFIGS}     L2HI_MIRRORING='false'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=300
${SCFC_NAME}     CB008701_case15.xml
${GNB_SWCONFIG_QUAL_NAME}     gnb_swconfig.txt
${4G_S1_local_IP}    10.108.175.74
@{Rdparameter}    0x340000:15    #0x420062:1  8701 enable &0x340000 pm counter 1min

${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22att_10db.csv
${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22phase_10db.csv
${PHASE_att_FILE_PATH}   ${CONFIG_DIR_PATH}/qualcomm_config/4QC_16layer_2.csv
${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
${FIX_RANK2}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x02
${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP.dmc
${UE_NUM}   4
#@{rnti_list_suite}   3488    35336    1648    33496

*** Test Cases ***
CB008701_A_B4_case15_PMcounter_dlMuMaxNumLayerPerMuRbg_variblity_test
#    Modify Qualcomm gNB Swconfig
#    Qualcomm prepare gnb onair
#    Prepare for sa env
#    Set Mcs Channel Phase And Attenuation same time    ${PHASE_att_FILE_PATH}

#    Start capture only gnb syslog in 'rrc' file
#    Attach qualcomm ue and make call stable    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}
    Capture Qualcomm SA UE RRC logs and analysis   ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#    Start UE full buffer with rank'4'
#    Wait '30s' for stabible
    Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#    Stop capture only gnb syslog in 'rrc' file

#    log to console  counter check MU16layer_4UE_rank4
#    Start capture only gnb syslog in 'MU16layer_4UE_rank4' file
#    qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#    Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8701_case15_mulayer16.json
#    Wait '60s' for stable
#    run keyword and continue on failure    Check counters with Mulayer '16' layer
#    run keyword and continue on failure    Start collect bip log
#    run keyword and continue on failure    Wait for '3s' to stop bip log with name'MU16layer_4UE_rank4'
#    Start collect ttitrace
#    Wait for '2s' to stop ttitrace with name'MU16layer_4UE_rank4'
#    run keyword and ignore error  check TP and bler with ttitrace   570    2    MU16layer_4UE_rank4   tti_case15_rank4
#    Stop capture only gnb syslog in 'MU16layer_4UE_rank4' file
#
#    log to console  16layer counter check MU16layer_3UE_rank4_1UE_rank3
#    Start capture only gnb syslog in 'MU16layer_3UE_rank4_1UE_rank3' file
#    Stop UE data
#    Start UE full buffer with rank'3'
#    qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK3}
#    Wait '60s' for stable
#    run keyword and continue on failure    Check counters with Mulayer '15' layer
#    run keyword and continue on failure    Start collect bip log
#    run keyword and continue on failure    Wait for '3s' to stop bip log with name'MU16layer_3UE_rank4_1UE_rank3'
#    Start collect ttitrace
#    Wait for '2s' to stop ttitrace with name'MU16layer_3UE_rank4_1UE_rank3'
#    run keyword and continue on failure    check TP and bler with ttitrace   570    2    MU16layer_3UE_rank4_1UE_rank3   tti_case15_rank3
#    Stop capture only gnb syslog in 'MU16layer_3UE_rank4_1UE_rank3' file

#    log to console  16layer counter check MU16layer_3UE_rank4_1UE_rank2
    Start capture only gnb syslog in 'MU16layer_3UE_rank4_1UE_rank2' file
    Stop UE data
    Start UE full buffer with UErank'2''4''4''4'
    qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK2}
    Wait '5s' for stable
    run keyword and continue on failure    Check counters with Mulayer '14' layer
#    run keyword and continue on failure    Start collect bip log
#    run keyword and continue on failure    Wait for '3s' to stop bip log with name'MU16layer_3UE_rank4_1UE_rank2'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'MU16layer_3UE_rank4_1UE_rank2'
    run keyword and continue on failure     Check TP and bler with rank by ttitrace    570    1    MU16layer_3UE_rank4_1UE_rank2
    ...    tti_case15_pair_power   2   4   4   4
    Stop capture only gnb syslog in 'MU16layer_3UE_rank4_1UE_rank2' file
    Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}    ${dmc_file}
#    attach UE '50' times


*** Keywords ***
Attach qualcomm ue and make call stable
    [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm detach ue    ${UE${num}_ID}
         Qualcomm attach ue hardly    ${UE${num}_ID}
    END
    Start UE full buffer with rank'4'
    Wait '5s' for stabible
    Stop UE data
#    detach all UEs

attach UE '${attach_time}' times
    FOR    ${num_x}   IN RANGE  1   ${attach_time}+1
         Start capture only gnb syslog in 'attach_multi_time_${num_x}' file
         Attach qualcomm ue and make call stable     ${UE1_ID}    ${UE2_ID}    ${UE3_ID}    ${UE4_ID}
         Stop capture only gnb syslog in 'attach_multi_time_${num_x}' file
    END

detach all UEs
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm detach ue    ${UE${num}_ID}
    END

Capture Qualcomm SA UE RRC logs and analysis
    [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
    Qualcomm Execute Adb Cmd    ${UE1_ID}    reboot
    Qualcomm Execute Adb Cmd    ${UE2_ID}    reboot
    Qualcomm Execute Adb Cmd    ${UE3_ID}    reboot
    Qualcomm Execute Adb Cmd    ${UE4_ID}    reboot
    sleep    60s
    ${rnti_list}   create list
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
         Qualcomm detach ue    ${UE${num}_ID}
         Qualcomm attach ue hardly    ${UE${num}_ID}
         ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}
         Download qualcomm log    ${ue_absolutely_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
         ${ret}    Get_Rach_Msg4_Crnti   ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt
         set suite variable     ${rnti}     ${ret}
         append to list    ${rnti_list}    ${rnti}
         run keyword and continue on failure    filter_qcat_message
          ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
         run keyword and continue on failure    check_log_with_au2anlysis
          ...        ${CURDIR}/ini/8701_case15_rrclog_UE${num}.ini    p    save_log_directory=${test_log_directory()}
         log to console     check  UE_${UE${num}_ID} RRC logs
    END
    set suite variable   ${rnti_list_suite}    ${rnti_list}

Start UE full buffer with rank'${rank_V}'
    csn.connect to  10.106.164.21    username=ute  password=%EjvHVvvkQD6  alias=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    ${ret}   csn.send command   pkill -9 iperf    connection=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    run keyword if  ${rank_V}==1   Qualcomm Start DL Data    ${UE1_ID}    ${UE_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD_rank1}
    run keyword if  ${rank_V}==2   Qualcomm Start DL Data    ${UE1_ID}    ${UE_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD_rank2}
    run keyword if  ${rank_V}==3   Qualcomm Start DL Data    ${UE1_ID}    ${UE_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD_rank3}
    run keyword if  ${rank_V}==4   Qualcomm Start DL Data    ${UE1_ID}    ${UE_DL_PORT}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
    Qualcomm Start UL Data    ${UE1_ID}    ${UE_UL_PORT}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
    FOR    ${num}   IN RANGE  2   ${UE_NUM}+1
         Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT}+${num}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
         Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}+${num}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
    END


Start UE full buffer with UErank'${UE1_rank}''${UE2_rank}''${UE3_rank}''${UE4_rank}'
    csn.connect to  10.106.164.21   username=ute  password=%EjvHVvvkQD6  alias=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    ${ret}   csn.send command   pkill -9 iperf    connection=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT}+${num}    ${DL_LOG}    ${DL_SEND_DATA_CMD_rank${UE${num}_rank}}
         Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}+${num}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
    END

Stop UE data
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Stop DL Data    ${UE${num}_ID}    ${UE_DL_PORT}+${num}
         Qualcomm Stop UL Data    ${UE${num}_ID}    ${UE_UL_PORT}+${num}
    END

Download QC logs and check rrc
    FOR    ${num}   IN RANGE  1   ${NUM}+1
         Download qualcomm log    ${ue${num}_logs_path}.hdf     ${EXPORT_GRID}    ${UE${num}_ID}_rrc_raw.txt
         Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT}+${num}    ${DL_LOG}    ${DL_SEND_DATA_CMD}
         Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}+${num}    ${UL_LOG}    ${UL_SEND_DATA_CMD}
         log to console     comment  check RRC logs
         run keyword and continue on failure    filter_qcat_message
          ...       ${test_log_directory()}${/}${UE${num}_ID}_rrc_raw.txt      ::=    ${test_log_directory()}${/}RRC_UE${num}.txt
         run keyword and continue on failure    check_log_with_au2anlysis
    ...        ${CURDIR}/ini/8701_case15_rrclog_UE${num}.ini    p    save_log_directory=${test_log_directory()}
    END


check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
        ${ackNack}    read_csv_columns    ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...   dlFdSchedData.ackNack    rnti={T_rnti}
        ${ret1}    evaluate  ${ackNack}.count('ACK')/len(${ackNack})
        should be true  ${ret1}>0.98
    END
    FOR      ${key}     IN     @{keys}    #check TP
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        run keyword if  ${result}<${throughput}   should be true  ${result}>(${throughput}*3/4)
    END
              ...  ELSE  should be true  ${result}>${throughput}
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

Check TP and bler with rank by ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}   ${UE1_rank}   ${UE2_rank}   ${UE3_rank}   ${UE4_rank}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR   ${num}   IN RANGE   1   ${UE_NUM}+1
        ${result}  evaluate   ${a[${rnti_list_suite[${num}-1]}]}/${time_avg}/1024/1000
        should be true  ${result}>(${throughput}*${UE${num}_rank}/4)
    END

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti

Qualcomm attach ue hardly
    [Arguments]    ${ue_id}
    FOR    ${reboot_count}    IN RANGE    1    5
        ${out}    ${attach_status}     Run Keyword And Ignore Error   Qualcomm Attach With Adb    ${ue_id}
        Run Keyword if    '${attach_status}'=='True'    Exit For Loop
        Qualcomm Execute Adb Cmd     ${ue_id}    reboot
        Sleep    60
        ${reboot_count}    Set Variable    ${reboot_count}+1
        Qualcomm Detach With Adb      ${ue_id}
    END

Start QXDM trace
    [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
    END

Stop QXDM trace
    [Arguments]    ${UE1_ID}    ${UE2_ID}   ${UE3_ID}    ${UE4_ID}     ${dmc}
    FOR    ${num}   IN RANGE  1   ${UE_NUM}
         ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}    quit_app=false
         sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
    END
    ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE4_ID}    ${log_path}
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/

Download qualcomm log
    [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
    ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    filter=${export_grid}
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}
    ...              ${test_log_directory()}/${name}

Modify Qualcomm gNB Swconfig
	Add Qualcomm GNB swconfig    @{Rdparameter}

Add Qualcomm GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
    ...     save_path=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt

Prepare for nsa env
    [Arguments]    ${UE1_ID}    ${UE2_ID}
    Unblock one 4G cell    287    ${4G_S1_local_IP}
    Set ue to NSA    ${UE1_ID}
    Wait '5s' for stabible
    Set ue to NSA    ${UE2_ID}
    Wait '5s' for stabible
    Set ue to NSA    ${UE3_ID}
    Wait '5s' for stabible
    Set ue to NSA    ${UE4_ID}
    Wait '5s' for stabible

Prepare for sa env
    lock one 4G cell    287     ${4G_S1_local_IP}
    Set ue to SA    ${UE1_ID}
    Wait '5s' for stabible
    Set ue to SA    ${UE2_ID}
    Wait '5s' for stabible
    Set ue to SA    ${UE3_ID}
    Wait '5s' for stabible
    Set ue to SA    ${UE4_ID}
    Wait '5s' for stabible

Set ue to NSA
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    80000    80
    Wait '5s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
    Qualcomm Write Nvitem    ${ue_id}    74087    0
    qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
    Wait '5s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.radio.multisim.config ssss
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 1
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 1
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_1 1
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '50s' for stabible
    Qualcomm Set Apn    ${ue_id}    NSA     stdata3
    Wait '5s' for stabible

Set ue to SA
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    80000    64
    Wait '5s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    74213    0
    Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
    Qualcomm Write Nvitem    ${ue_id}    67218    1
    Qualcomm Write Nvitem    ${ue_id}    73991    0
    Wait '2s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
    Wait '5s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.radio.multisim.config ssss
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 2
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 2
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.vendor.radio.5g_mode_pref_1 2
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '50s' for stabible
    Qualcomm Set Apn    ${ue_id}    SA    stdata3
    Wait '5s' for stabible

Unblock one 4G cell
    [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
    TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='blocked'
    END
    ...  TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
    TAF_ADMIN.teardown    connection=${alias}

lock one 4G cell
    [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
    TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='unblocked'
    END
    ...   TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
    TAF_ADMIN.teardown    connection=${alias}






Check counters with Mulayer '${layer_num}' layer
    run keyword if    ${layer_num}==16     check 8701 counter with MUlayer 16
    run keyword if    ${layer_num}==15     check 8701 counter with MUlayer 15
    run keyword if    ${layer_num}==14     check 8701 counter with MUlayer 14
    run keyword if    ${layer_num}==13     check 8701 counter with MUlayer 13
    run keyword if    ${layer_num}==12     check 8701 counter with MUlayer 12
    run keyword if    ${layer_num}==11     check 8701 counter with MUlayer 11
    run keyword if    ${layer_num}==10     check 8701 counter with MUlayer 10
    run keyword if    ${layer_num}==9      check 8701 counter with MUlayer 9
    run keyword if    ${layer_num}==8    check 8701 counter with MUlayer 8
    run keyword if    ${layer_num}==0      check 8701 counter with MUlayer 0
    run keyword if    ${layer_num}==255      check 8701 counter with MUlayer 255   #255 means MUMIMO false


Get 8701 counters
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55308C34023_PRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34023    cell_id=1
	${M55308C34022_PRB_DL_MU_MIMO_15LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34022    cell_id=1
	${M55308C34021_PRB_DL_MU_MIMO_14LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34021    cell_id=1
	${M55308C34020_PRB_DL_MU_MIMO_13LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34020    cell_id=1
	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34019    cell_id=1
	${M55308C34018_PRB_DL_MU_MIMO_11LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34018    cell_id=1
	${M55308C34017_PRB_DL_MU_MIMO_10LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34017    cell_id=1
	${M55308C34016_PRB_DL_MU_MIMO_9LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34016    cell_id=1
    #CB008305
	${M55308C34011_PRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34011    cell_id=1
	${M55308C34010_PRB_DL_MU_MIMO_7LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34010    cell_id=1
	${M55308C34009_PRB_DL_MU_MIMO_6LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34009    cell_id=1
	${M55308C34008_PRB_DL_MU_MIMO_5LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34008    cell_id=1
 	${M55308C34007_PRB_DL_MU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34007    cell_id=1
  	${M55308C34006_PRB_DL_MU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34006    cell_id=1
  	${M55308C34005_PRB_DL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34005    cell_id=1
  	${M55308C34004_PRB_DL_SU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34004   cell_id=1
  	${M55308C34003_PRB_DL_SU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34003   cell_id=1
    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34002   cell_id=1
    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34001   cell_id=1

	${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34027   cell_id=1
	${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34026   cell_id=1
	${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34025   cell_id=1
	${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34024   cell_id=1
    #CB008305
	${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34015   cell_id=1
	${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34014   cell_id=1
	${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34013   cell_id=1
	${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34012  cell_id=1
	${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34028  cell_id=1
	${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34029  cell_id=1

   	${M55308C10001_PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001   cell_id=1

    ${MU_MIMO_layer_list}    create list    ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}    ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}
    ...     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}
    ...     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}
    ...     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}
    ...     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}     ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
    ...     ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}     ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
    ...     ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}     ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
    ...     ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
    ${MU_MIMO_layer_total}    evaluate    sum(${MU_MIMO_layer_list})

    ${SU_MIMO_layer_list}    create list     ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
    ...     ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
    ${SU_MIMO_layer_total}    evaluate    sum(${SU_MIMO_layer_list})

    ${MU_paired_UE_list}     create list        ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}     ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}
    ...    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}     ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}
    ...    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}     ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
    ...    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
    ${MU_paired_UE_total}    evaluate    sum(${MU_paired_UE_list})

    run keyword and continue on failure   should be true   ${MU_MIMO_layer_total}==${MU_paired_UE_total}
    run keyword and continue on failure   should be true   ${SU_MIMO_layer_total}==${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
    ${SU_MIMO_layer_plus_SU_layer}    evaluate     ${SU_MIMO_layer_total}+${MU_MIMO_layer_total}
    ${mu_prb_and_legacy_pdsch_prb}    evaluate     ${SU_MIMO_layer_plus_SU_layer}-${M55308C10001_PRB_USED_PDSCH}
    run keyword and continue on failure   should be true  ${mu_prb_and_legacy_pdsch_prb}<(${SU_MIMO_layer_plus_SU_layer}/10)

    set global variable    ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}
    set global variable    ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}
    set global variable    ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}
    set global variable    ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}
    set global variable    ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}
    set global variable    ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}
    set global variable    ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}
    set global variable    ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}
    set global variable    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
    set global variable    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
    set global variable    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
    set global variable    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
    set global variable    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}
    set global variable    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
    set global variable    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
    set global variable    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}
    set global variable    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
    set global variable    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}
    set global variable    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
    set global variable    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}
    set global variable    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}
    set global variable    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}
    set global variable    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}
    set global variable    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}
    set global variable    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
    set global variable    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
    set global variable    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
    set global variable    ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}
    set global variable    ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}


check 8701 counter with MUlayer 16
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 15
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 14
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 13
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 12
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true     ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true     ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 11
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 10
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>=0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 9
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 8
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0

    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0

    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}>0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}>=0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 0
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}==0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 255
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}==0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}==0
