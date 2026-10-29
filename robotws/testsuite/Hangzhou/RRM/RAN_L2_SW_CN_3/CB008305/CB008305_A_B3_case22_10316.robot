*** Settings ***
Suite Setup       Qualcomm Common Suite Setup
#Suite Teardown    Qualcomm Common Suite Teardown
Test Setup        Qualcomm Common Test Setup
#Test Teardown     Qualcomm Common Test Teardown
Force Tags        qualcomm    owner_l3gao     SBTS00  SBTS22R4   CRT
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot
Library           taf.sbts.oam.coam.admin
Library           taf.pdu


Documentation     gNB10316  @{Rdparameter}
...    PMcounter 0x340000:15
...    8450 must contain bwp efs

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
@{LOG_NAME_LIST}    gnb_snapshot
${UE1_ID}         10a5c6e6  #MCS B1-2-3-4   MTP8450   com23
${UE3_ID}         ca3e3465  #MCS B5-6-7-8   MTP8450   com36
${UE2_ID}         f19fafe0  #MCS B9-10-11-12   MTP8350   com32
${UE4_ID}         72d1d395  #MCS B9-10-11-12   MTP8350   com9
${UE_DL_PORT1}    5001
${UE_DL_PORT2}    5002
${UE_DL_PORT3}    5003
${UE_DL_PORT4}    5004
${UE_UL_PORT}    5005
${DL_LOG}    /tmp/iperf_server_on_ue_log.txt
${UL_LOG}    /tmp/iperf_server_on_pc_log.txt
${DL_SEND_DATA_CMD_RANK4}    -u -t 1800 -i 1 -P 1 -f m -b 1400.00M -l 1400B -T 64
${DL_SEND_DATA_CMD_RANK3}    -u -t 1800 -i 1 -P 1 -f m -b 1050.00M -l 1400B -T 64
${DL_SEND_DATA_CMD_RANK0}    -u -t 1800 -i 1 -P 1 -f m -b 100 -l 1400B -T 64
${DL_SEND_DATA_CMD_50kbps}    -u -t 1800 -i 1 -P 1 -f m -b 0.05M -l 1400B -T 64
${UL_SEND_DATA_CMD}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 200M -t 600
${UL_SEND_DATA_CMD_50kbps}    -u -c 192.168.255.1 -P 1 -i 1 -f m -w 4M -b 0.05M -t 600
${EXPORT_GRID_TP}    Common Displays;Events and Debug Msgs vs. Time
${EXPORT_GRID}    ${None}
#&{GNBMIRRORINGCONFIGS}     L2HI_MIRRORING='true'   L2RT_MIRRORING='true'     NUMBER_OF_FILES=17    FILE_SIZE_MBYTES=200
${SCFC_NAME}     CB008305_case22.xml
${GNB_SWCONFIG_QUAL_NAME}     gnb_swconfig.txt
#${GNB_SWCONFIG_QUAL_NAME_before}  qual_swconfig_10316.txt
${TTITRACE_TAG}    ttitrace
${4G_S1_local_IP}    10.108.175.74S
@{Rdparameter}    0x340000:15    0x580430:1
${ATT_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22att_10db.csv
${PHASE_FILE_PATH}    ${CONFIG_DIR_PATH}/qualcomm_config/8305_case23_22phase_10db.csv
${FIX_RANK4}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x04
${FIX_RANK3}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x03
${FIX_RANK1}      QSHRequest cfg nr5gmac 0x00 0x05 0x02 0x00 0x01
${dmc_file}    ${CONFIG_DIR_PATH}/qualcomm_config/NR5G_Debugging_TP_powersaving.dmc
${UE_NUM}    2
${iperfpc_ip}   10.108.183.187
${PHASE_att_FILE_PATH}   ${CONFIG_DIR_PATH}/qualcomm_config/2QC_8layer_2SA_256QAM.csv
#${PHASE_att_FILE_PATH}   ${CONFIG_DIR_PATH}/qualcomm_config/4QC_16layer_2NSA_2SA.csv

*** Test Cases ***
CB008305_C_B2_case22_2UEs_rank2_Powersaving
#    Active GNB L2 feature debug traces    position=1
#    Add GNB swconfig    @{Rdparameter}
#    detach all UEs
    Qualcomm prepare gnb onair
#    Prepare UE for SA_NSA env
#    Set Mcs Channel Phase And Attenuation same time    ${PHASE_att_FILE_PATH}
#    qualcomm_send_qxdm_command    ${UE1_ID}    ${FIX_RANK4}
#    qualcomm_send_qxdm_command    ${UE2_ID}    ${FIX_RANK4}
    Attach 2 UEs and check MU pair SRS configuration
    Start QXDM trace      ${UE1_ID}    ${UE2_ID}    ${dmc_file}
    Start capture only gnb syslog in 'powersaving_disable' file
    Start UE full buffer with UErank'4''4'
    Wait '15s' for stable
    Start collect ttitrace
    run keyword and continue on failure   Wait for '4s' to stop ttitrace with name'tti_2_bwp_disable'
    run keyword and continue on failure   Check TP and bler with rank by ttitrace   1300
    ...    3    tti_2_bwp_disable   tti_case22_bwpdisable    4    4
   Stop capture only gnb syslog in 'powersaving_disable' file

#    Start capture only gnb syslog in 'powersaving_enable' file
#    Start UE full buffer with UErank'0''4'
#    Wait '10s' for stable
#    Start collect ttitrace
#    run keyword and continue on failure   Wait for '4s' to stop ttitrace with name'tti_1_bwp_enable'
#    run keyword and continue on failure   Check TP and bler with rank by ttitrace   1300
#    ...    3    tti_1_bwp_enable   tti_case22_bwpenable    0    4
##    Stop UE data
#    Stop capture only gnb syslog in 'powersaving_enable' file
#    Stop QXDM trace    ${UE1_ID}    ${UE2_ID}    ${dmc_file}

*** Keywords ***
Prepare UE for SA_NSA env
    lock one 4G cell   287    ${4G_S1_local_IP}
    Set ue to SA simple    ${UE1_ID}
    Wait '5s' for stabible
    Set ue to SA simple   ${UE2_ID}
    Wait '35s' for stable    #wait for UE4 come back

Stop UE data
    FOR   ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Stop DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}
         Qualcomm Stop UL Data    ${UE${num}_ID}    ${UE_UL_PORT}
    END

Check TP and bler with rank by ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}   ${UE1_rank}   ${UE2_rank}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv   ${time_avg}    ratio=0    filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR   ${num}   IN RANGE   1   ${UE_NUM}+1     #check tp based on given crnti
        ${result1}  evaluate   ${a[${rnti_list_suite[${num}-1]}]}/${time_avg}/1024/1000
        ${target_tp}  evaluate   ${throughput}*${UE${num}_rank}/4
        should be true  ${result1}>${target_tp}
    END
    FOR    ${T_rnti}   IN    @{rnti_list_suite}     #check bler
        ${ackNack}    read_csv_columns    ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
    ...   dlFdSchedData.ackNack    rnti={T_rnti}
        ${ret1}    evaluate  ${ackNack}.count('ACK')/len(${ackNack})
        should be true  ${ret1}>0.98
    END
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/

Attach 2 UEs and check MU pair SRS configuration
    Start capture only gnb syslog in 'rrclogs' file
    detach all UEs
    Attach qualcomm ue and make call stable    ${UE1_ID}   ${UE2_ID}
    Capture Qualcomm NSA UE RRC logs and analysis    ${UE1_ID}    ${UE2_ID}    ${dmc_file}
    Stop capture only gnb syslog in 'rrclogs' file

detach all UEs
    FOR    ${num}   IN RANGE  1   ${UE_NUM}
         Qualcomm detach ue    ${UE${num}_ID}
    END
Attach qualcomm ue and make call stable
    [Arguments]    ${UE1_ID}    ${UE2_ID}
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm detach ue    ${UE${num}_ID}
         Qualcomm attach ue hardly    ${UE${num}_ID}
    END
    Start UE full buffer with UErank'4''4'
    Wait '5s' for stabible
    Stop UE data

Start UE full buffer with UErank'${UE1_rank}''${UE2_rank}'
    csn.connect to  ${iperfpc_ip}    username=ute  password=%EjvHVvvkQD6  alias=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    ${ret}   csn.send command   pkill -9 iperf    connection=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Start DL Data    ${UE${num}_ID}    ${UE_DL_PORT${num}}    ${DL_LOG}    ${DL_SEND_DATA_CMD_rank${UE${num}_rank}}
         Qualcomm Start UL Data    ${UE${num}_ID}    ${UE_UL_PORT}   ${UL_LOG}    ${UL_SEND_DATA_CMD}
    END

Capture Qualcomm NSA UE RRC logs and analysis
    [Arguments]    ${UE1_ID}    ${UE2_ID}    ${dmc}
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
         set global variable  ${num}
         run keyword and continue on failure    check_log_with_au2anlysis
          ...        ${CURDIR}/ini/8305_case22_rrclog_UE${num}.ini    p    save_log_directory=${test_log_directory()}
    END
    set suite variable   ${rnti_list_suite}    ${rnti_list}

Get ue DL throughput and bler
    [Arguments]    ${txt_file_name}
    log to console    start to get ue throughput and bler
    ${UE1_pcell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_scell_tput}    get_dl_scell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_pcell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
    ${UE1_scell_bler}    get_dl_scell_bler    ${test_log_directory()}/${txt_file_name}
    [Return]    ${UE1_pcell_tput}    ${UE1_scell_tput}    ${UE1_pcell_bler}    ${UE1_scell_bler}

Get ue UL throughput and bler
    [Arguments]    ${txt_file_name}
    log to console    start to get ue throughput and bler
    ${UE1_pcell_tput_ul}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${UE1_pcell_bler_ul}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
    [Return]    ${UE1_pcell_tput_ul}    ${UE1_pcell_bler_ul}

Prepare for nsa env
    [Arguments]    ${UE1_ID}    ${UE2_ID}
    Unblock one 4G cell    287    ${4G_S1_local_IP}
    Wait '10s' for stable
    Set ue to SA    ${UE1_ID}
    Wait '5s' for stable
    Set ue to SA    ${UE2_ID}
#    Wait '5s' for stable
#    Set ue to NSA    ${UE3_ID_8450}

Prepare for sa env
    [Arguments]    ${UE1_ID}    ${UE2_ID}
    lock one 4G cell    287     ${4G_S1_local_IP}
    Set ue to SA    ${UE1_ID}
    Wait '5s' for stable
    Set ue to SA    ${UE2_ID}
    Wait '5s' for stable


Set ue to NSA simple
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    80000    80
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
    Qualcomm Write Nvitem    ${ue_id}    74087    0
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    qualcomm_execute_adb_cmd    ${ue_id}    reboot

Set ue to SA simple
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    80000    64
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    74213    0
    Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '2s' for stable


Set ue to NSA
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    80000    80
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
    Qualcomm Write Nvitem    ${ue_id}    74087    0
    qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
    Wait '5s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.radio.multisim.config ssss
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 1
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 1
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_1 1
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '50s' for stable
    Qualcomm Set Apn    ${ue_id}    NSA     stdata3
    Wait '5s' for stable



Set ue to SA
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    80000    64
    Wait '5s' for stable
    Qualcomm Write Nvitem    ${ue_id}    74213    0
    Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
    Qualcomm Write Nvitem    ${ue_id}    67218    1
    Qualcomm Write Nvitem    ${ue_id}    73991    0
    Wait '2s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
    Wait '5s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.radio.multisim.config ssss
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 2
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 2
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.vendor.radio.5g_mode_pref_1 2
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stable
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '50s' for stable
    Qualcomm Set Apn    ${ue_id}    SA    stdata3
    Wait '5s' for stable

Unblock one 4G cell
    [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
    TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='blocked'
    END
    ...  TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
    TAF_ADMIN.teardown    connection=${alias}


Get ue throughput and bler
    [Arguments]    ${txt_file_name}
    log to console    start to get ue throughput and bler
    ${cell_tput}    get_dl_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${cell_bler}    get_dl_pcell_bler    ${test_log_directory()}/${txt_file_name}
    ${ul_tput}    get_ul_pcell_tput    ${test_log_directory()}/${txt_file_name}
    ${ul_bler}    get_ul_pcell_bler    ${test_log_directory()}/${txt_file_name}
    [Return]    ${cell_tput}    ${cell_bler}    ${ul_tput}    ${ul_bler}

Capture two Qualcomm UE RRC logs
    [Arguments]    ${ue1_id}    ${ue2_id}     ${dmc}   ${log_path}=${TXT_DEF_PATH}
    Qualcomm Start Qxdm Trace    ${ue1_id}    dmc_file=${dmc}
    Qualcomm Start Qxdm Trace    ${ue2_id}    dmc_file=${dmc}
    Qualcomm detach ue    ${ue1_id}
    Wait '2s' for stable
    Qualcomm detach ue    ${ue2_id}
    Wait '2s' for stable
    Qualcomm attach ue    ${ue1_id}
    Wait '2s' for stable
    Qualcomm attach ue   ${ue2_id}
    Wait '2s' for stable
    ${ue1_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue1_id}    ${log_path}   quit_app=false
    ${ue2_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue2_id}    ${log_path}
    [Return]    ${ue1_absolutely_path}     ${ue2_absolutely_path}


Download qualcomm log
    [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
    ${qc_log}    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    filter=${export_grid}
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${qc_log}
    ...              ${test_log_directory()}/${name}



Modify GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}     gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        modify txt node        ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME_before}
    ...     save_path=${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
    FOR    ${parameter}    IN    @{Rdparameter}
        run keyword and ignore error    delete txt node    ${parameter}
        add txt node       ${parameter}
    END
    teardown txt

Capture two Qualcomm UE traffic logs
    [Arguments]    ${ue1_id}    ${ue2_id}       ${log_path}=${TXT_DEF_PATH}
    Qualcomm Start Qxdm Trace    ${ue1_id}    dmc_file=None
    Qualcomm Start Qxdm Trace    ${ue2_id}    dmc_file=None
    Wait '15s' for stable
    ${ue1_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue1_id}    ${log_path}   quit_app=false
    ${ue2_absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue2_id}    ${log_path}
    [Return]    ${ue1_absolutely_path}     ${ue2_absolutely_path}

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}_tti/tti

Ping powersaving UE
    [Arguments]    ${device_id}
    ${ue_ip}=    Qualcomm Get Ip With Adb    ${device_id}
    csn.connect to  10.106.164.21    username=ute  password=%EjvHVvvkQD6  alias=serve
    ${ret}   csn.send command   /usr/bin/nohup ping ${ue_ip} -s 128 1>nul 2>&1 0</dev/null &    connection=serve
    ${ret}   csn.execute  ps -ef | grep ping   connection=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    ${ret}   csn.send command   pkill -9 iperf    connection=serve

kill ping and iperf for all UE
    csn.connect to  10.106.164.21   username=ute  password=%EjvHVvvkQD6  alias=serve
    ${ret}   csn.execute  ps -ef | grep ping   connection=serve
    ${ret}   csn.send command   pkill -9 ping    connection=serve
    ${ret}   csn.execute  ps -ef | grep ping   connection=serve
    ${ret}   csn.execute  ps -ef | grep iperf   connection=serve
    ${ret}   csn.send command   pkill -9 iperf    connection=serve

Set Mcs Channel Phase And Attenuation same time
    [Arguments]    ${att_phase_csv}      ${frequency}=2600
    Obtain MCS Info
    MCS Setup    host_ip=${host_ip}    device_ip=${device_ip}    db_path=${db_path}    username=${UE_PC_USER}    password=${UE_PC_PASS}
    MCS Set Frequency    frequency=${frequency}
    Mcs Set Channel Phase And Attenuation   att_phase=${att_phase_csv}
    ${all_channel_info}=    MCS Query Channel Phase And Attenuation    channel=ALL
    Log    ${all_channel_info}
    MCS Teardown


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

lock one 4G cell
    [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
    TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
    END
    ...   TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
    TAF_ADMIN.teardown    connection=${alias}

Start QXDM trace
    [Arguments]    ${UE1_ID}    ${UE2_ID}   ${dmc}
    FOR    ${num}   IN RANGE  1   ${UE_NUM}+1
         Qualcomm Start Qxdm Trace    ${UE${num}_ID}    dmc_file=${dmc}
    END

Stop QXDM trace
    [Arguments]    ${UE1_ID}    ${UE2_ID}   ${dmc}
    FOR    ${num}   IN RANGE  1   ${UE_NUM}
         ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE${num}_ID}    ${log_path}    quit_app=false
         sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
    END
    ${ue_absolutely_path}    Qualcomm Stop Qxdm Trace    ${UE2_ID}    ${log_path}
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${ue_absolutely_path}.hdf    ${test_log_directory()}/
