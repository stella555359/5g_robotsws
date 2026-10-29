*** Settings ***
Documentation    Suite description
...    author: y63li
...    contact: ying.15.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : CB010636

Library      ./CB010636_CDE.py
Library      ./demo.py
Library      testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB010636.Resources.sigspark_mmw3.SigSpark    WITH NAME    sigspark_mmw3
Library      taf.hw.rf_attenuator    WITH NAME    att
Library      taf.sw.dcap.rd		WITH NAME	DCAP
Library      taf.collectors.btslog		WITH NAME	btslog
Library      taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     ./CB010636_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Variables    ./BTS_info.py


*** Variables ***
${EXP_GAP}               0.012
${expected_tput_dl_T}    200
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_ports_1}              ${tl.attenuator[0].attenuation_port_numbers[0]}
${att_ports_2}              ${tl.attenuator[0].attenuation_port_numbers[1]}
${att_ports_3}              ${tl.attenuator[0].attenuation_port_numbers[2]}
${att_ports_4}              ${tl.attenuator[0].attenuation_port_numbers[3]}
${att_ports_number}         ${tl.attenuator[0].attenuation_port_numbers[0]}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   HBTE
${HBTE_max_value_TL915}           ${127}    ##no signal
@{att_value}                0    22    127   ##rank4  no signal

#${fsp_hostnames}    asp-1b             #for 904
${GNB_COAM_ALIAS_1}    GNB_OAM_1
${GNB_COAM_ALIAS_2}    GNB_OAM_2
${DU_OAM_IP_1}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_IP_2}        ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_username}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_password}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${host_addr}     ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}    ${tl.test_pc.default_ssh_connection_details.username}
${host_password}    ${tl.test_pc.default_ssh_connection_details.password}
@{selenium_gnb_login}
${btsid_1}      ${tl.gnbs[0].instance_id}
${btsid_2}      ${tl.gnbs[1].instance_id}
${alias_1}    929
${alias_2}    915
&{bts_1}      host=${bts_host_1}    username=Nemuadmin    password=nemuuser    port=443
&{bts_2}     host=${bts_host_2}    username=Nemuadmin    password=nemuuser    port=443
${bts_host_1}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_host_2}    ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${UE_TYPE}          ${tl.ues[0].capabilities[-1]}
${data_tranfer}     650Mbits/sec
${ul_duration}     20
${dl_duration}     20
${dltp}     5
${ultp}     2
${SA_UE_MODE}    SA
${SA_attach_mode}    5G_SA
${SA_nettype}    SA+NSA
${apn_addr}    mdrbnokiacom
${TS_CASE_LOG_PATH}    /home/ute/logs
${DCAP_port}     443
${TEST_LOG_DIRECTORY}       /home/ute/logs
${AF_PATH}    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_0000_240327_000004_release_BTSSM_downloadable_A54.zip
#for -CDE
${emil_log_PC_win}    C:\\\\temp\\\\emil_trace
${emil_exe_path_win}    C:\\\\Emil
${emil_log_PC}    /cygdrive/c/temp/emil_trace
${emil_exe_path}    /cygdrive/c/Emil
${EMIL_HOST}    10.68.86.137
${EMIL_USER}     nokia5G
${EMIL_PASSWORD}      noki@123


*** Keywords ***
###Common setup####



Test Scenario2_1UE_1DRB
    [Arguments]    ${reportinterval}=5      ${data_tranfer}=1200Mbits/sec      ${call_duration}=10
    ${timestamp_start}      Run Keyword And Continue On Failure     Attach 1UE and Verify Status
    Set Suite Variable       ${timestamp_start}
    Run Keyword And Continue On Failure     Start DL and UL Traffic for 1UE and 1DRB
    ...    ue_mode=${SA_UE_MODE}
    ...    call_duration=${call_duration}      data_tranfer=${data_tranfer}
    Run Keyword And Continue On Failure     Detach for 1UE
    ${timestamp_end}    Get current time from GNB
    Set Suite Variable       ${timestamp_end}
    ${pre_case_time_info_start}     ${newest_timestamp_epoch_start}     Calculate PM counter Timestamp
        ...      cur_timestamp=${timestamp_start}
    ${pre_case_time_info_end}     ${newest_timestamp_epoch_end}     Calculate PM counter Timestamp
       ...      cur_timestamp=${timestamp_end}
    Set Suite Variable       ${newest_timestamp_epoch_end}
    Set Suite Variable       ${newest_timestamp_epoch_start}
    Run Keyword And Continue On Failure       Calculate PM counter Timestamp List
    ...      ${newest_timestamp_epoch_end}      ${newest_timestamp_epoch_start}      ${reportinterval}


Test Scenario3_1UE_MultiDRB
    [Arguments]    ${reportinterval}=5
    ${timestamp_start}      Run Keyword And Continue On Failure     Attach 1UE and Verify Status
    Set Suite Variable       ${timestamp_start}
    Run Keyword And Continue On Failure     Start DL and UL Traffic for 1UE
    ...    ue_mode=${SA_UE_MODE}
    ...    call_duration=${call_duration}
    Run Keyword And Continue On Failure     Detach for 1UE
    ${timestamp_end}    Get current time from GNB
    Set Suite Variable       ${timestamp_end}
    ${pre_case_time_info_start}     ${newest_timestamp_epoch_start}     Wait PM counter Update    cur_timestamp=${timestamp_start}
    ${pre_case_time_info_end}     ${newest_timestamp_epoch_end}     Wait PM counter Update    cur_timestamp=${timestamp_end}
    Set Suite Variable       ${newest_timestamp_epoch_end}
    Set Suite Variable       ${newest_timestamp_epoch_start}
    Run Keyword And Continue On Failure       Calculate PM counter Timestamp List
    ...      ${newest_timestamp_epoch_end}      ${newest_timestamp_epoch_start}      ${reportinterval}

Attach 1UE and Verify Status
    log to console       Prepare ue 1
    Run Keyword And Continue On Failure    sigspark_mmw3.require_ue    ue_alias=UE_${1}
    ...    get_spark_license=${True}    power_reset=true    index=${1}      ue_num_input=${2}      detach_request=true
    ${cur_timestamp}    Get current time from GNB
    log to console       Attach ue1 time is ${cur_timestamp}
    ${5Grach_ed}    Run Keyword And Continue On Failure    sigspark_mmw3.attach_ue    attach_mode=5G_SA
    ...    power_reset=true     ue_alias=UE_${1}
    log to console       UE attach verify is not supported by TA and wait some time
    #sleep   45s
    #log to console       Detach for 1UE
    #Run Keyword And Continue On Failure    sigspark_mmw3.detach_ue   ue_alias=UE_${1}     power_reset=true
    #log to console       Attach ue 1
    #${5Grach_ed}    Run Keyword And Continue On Failure    sigspark_mmw3.attach_ue    attach_mode=5G_SA
    #...    power_reset=true     ue_alias=UE_${1}
    [Return]   ${cur_timestamp}

Start DL and UL Traffic for 1UE
    log to console       Start Traffic on UE1
    [Arguments]    ${ue_mode}      ${call_duration}=15     ${buffer_size}=1400B
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=${tl.ues[0].iperf_details.port}       ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40000      ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40001     ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    log to console       wait Traffic end
    ${wait_duration}      Evaluate     ${reportinterval}*60+${call_duration}
    sleep    ${wait_duration}s

Start DL and UL Traffic for 1UE and 1DRB
    log to console       the First Start Traffic on UE1
    [Arguments]    ${ue_mode}      ${call_duration}=15     ${buffer_size}=1400B      ${data_tranfer}=1200Mbits/sec
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=${tl.ues[1].iperf_details.port}         ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40000      ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40001      ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    sleep    ${call_duration}s
    sleep    8s
    log to console       the Second Start Traffic on UE1
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=${tl.ues[1].iperf_details.port}         ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40000      ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40001      ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    log to console       no traffic and wait
    ${wait_duration}      Evaluate     ${reportinterval}*60+${call_duration}
    sleep    ${call_duration}s
    sleep    3s

Detach for 1UE
    log to console       Detach for 1UE
    Run Keyword And Continue On Failure    sigspark_mmw3.detach_ue   ue_alias=UE_${1}     power_reset=true
    Run Keyword And Continue On Failure    sigspark_mmw3.teardown       ue_alias=UE_${1}

Attach 2UE and Verify Status
    log to console       Prepare ue 1
    Run keyword and ignore error     sigspark_mmw3.require_ue    ue_alias=UE_${0}
    ...    get_spark_license=${True}    power_reset=true    index=${0}      ue_num_input=${1}      detach_request=true
    log to console       Prepare ue 2
    Run keyword and ignore error     sigspark_mmw3.require_ue    ue_alias=UE_${1}        detach_request=true
    ...    get_spark_license=${False}    power_reset=true    index=${1}      ue_num_input=${2}
    log to console       Attach ue 1
    ${cur_timestamp}    Get current time from GNB
    ${5Grach_ed}    Run keyword and ignore error    sigspark_mmw3.attach_ue    attach_mode=5G_SA
    ...    power_reset=true     ue_alias=UE_${0}
    log to console       Attach ue 2
    ${5Grach_ed}    Run keyword and ignore error    sigspark_mmw3.attach_ue   attach_mode=5G_SA
    ...    power_reset=true     ue_alias=UE_${1}
    log to console       UE attach verify is not supported by TA
    sleep   2s
    [Return]   ${cur_timestamp}

Start DL and UL Traffic for 2UE
    log to console       Start Traffic on UE1
    [Arguments]    ${ue_mode}      ${call_duration}=15     ${buffer_size}=1400B
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${0}    direction=dl
    ...     iperf_port=${tl.ues[0].iperf_details.port}       ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=mdrbnokiacom
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    log to console       Start Traffic on UE2
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=${tl.ues[1].iperf_details.port}       ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${0}    direction=dl
    ...     iperf_port=40000      ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=mdrbnokiacom
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    log to console       Start Traffic on UE2
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40000       ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${0}    direction=dl
    ...     iperf_port=40001     ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=mdrbnokiacom
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    log to console       Start Traffic on UE2
    Run Keyword And Continue On Failure     sigspark_mmw3.Start Data Transfer     ue_alias=UE_${1}    direction=dl
    ...     iperf_port=40001       ue_mode=${ue_mode}
    ...     throughput=${data_tranfer}    duration=${call_duration}      apn_address=dxdata3
    ...     buffer_size=${buffer_size}     protocol=UDP      duration=${call_duration}
    log to console       wait Traffic end
    sleep    ${call_duration}s


Detach for 2UE
    log to console       Detach for 2UE
    sleep      60s
    Run Keyword And Continue On Failure    sigspark_mmw3.detach_ue   ue_alias=UE_${0}     power_reset=true
    Run Keyword And Continue On Failure    sigspark_mmw3.detach_ue    ue_alias=UE_${1}    power_reset=true
    Run Keyword And Continue On Failure    sigspark_mmw3.teardown       ue_alias=UE_${0}
    #Run Keyword And Continue On Failure    sigspark_mmw3.teardown       ue_alias=UE_${1}

Get logs file from DCAP
    Download DCAP files
    ${TEST}      Set Variable      ${TEST_LOG_DIRECTORY}
    ${IP1}      Set Variable      ${DU_OAM_IP_1}
    ${IP2}      Set Variable      ${DU_OAM_IP_2}
    ${cmd_tmp}    Catenate  rm -rf ${TEST}/Emil_CSV; mkdir ${TEST}/Emil_CSV;mkdir ${TEST}/Emil_CSV/${IP1};mkdir ${TEST}/Emil_CSV/${IP2};
    Run    ${cmd_tmp}
    Decode Log File And Convet File Format
    csn.Connect to    hostname=${host_addr}     username=${host_username}     password=${host_password}    alias=ute
    Csn.Connect to   hostname=${EMIL_HOST}    username=${EMIL_USER}    password=${EMIL_PASSWORD}
    ...    alias=Emil_decode
    Get the exact emil log and convert to txt   emil_file_path=${pcell_file}
    ...      emil_csv_UTE=${TEST_LOG_DIRECTORY}/Emil_CSV/${DU_OAM_IP_1}
    Get the exact emil log and convert to txt   emil_file_path=${scell_file}
    ...     emil_csv_UTE=${TEST_LOG_DIRECTORY}/Emil_CSV/${DU_OAM_IP_2}
    ${TTI_CSV_merged}    CB010636_CDE.merge_csv_list_of_dicts    file_path=${TEST_LOG_DIRECTORY}
    ...      file_name=MacPduMuxReq.csv
    ${Emil_CSV_merged}    CB010636_CDE.merge_csv_list_of_dicts    file_path=${TEST_LOG_DIRECTORY}/Emil_CSV
    ...      file_name=*.csv
    Set Suite Variable       ${TTI_CSV_merged}
    Set Suite Variable       ${Emil_CSV_merged}
    [Return]     ${TTI_CSV_merged}        ${Emil_CSV_merged}
    [Teardown]    run keywords     csn.Disconnect    connection=Emil_decode     AND      csn.Disconnect     connection=ute

Get the exact emil log and convert to txt
    [Arguments]    ${emil_file_path}     ${emil_csv_UTE}
    csn.Execute   command=ls -R ${emil_file_path}/ | grep .5gm > ${emil_file_path}/dcap_log_name.txt
    ...    connection=ute
    csn.Execute   command=wc -l ${emil_file_path}/dcap_log_name.txt >> ${emil_file_path}/dcap_log_name.txt
    ...    connection=ute
    ${range}    csn.Execute   command=awk 'END{print $1}' ${emil_file_path}/dcap_log_name.txt    connection=ute
    ${range}    Convert To Integer    ${range}
    ${range}=    Evaluate    ${range}+1
    FOR    ${i}    IN RANGE    1    ${range}
        ${emil_log_name}    csn.Execute    command=sed -n ${i}p ${emil_file_path}/dcap_log_name.txt    connection=ute
        ${emil_log_name}    strip string    ${emil_log_name}
        csn.Execute   command=cp $(find ${emil_file_path}/ -name ${emil_log_name}) ${emil_file_path}
        ...    connection=ute
        csn.Execute   command=rm -rf ${emil_csv_UTE}/tmp;mkdir ${emil_csv_UTE}/tmp
        ...    connection=ute
        convert to csv   emil_log_UTE=${emil_file_path}    emil_log_name=${emil_log_name}
        ...       emil_csv_UTE=${emil_csv_UTE}
        sleep    2s
    END

convert to csv
    [Arguments]    ${emil_log_UTE}    ${emil_log_name}   ${emil_csv_UTE}
    log to console    \n Upload emil script
    log to console     EMIL host is ${EMIL_HOST}
    csn.Execute    command=rm -f "${emil_exe_path}\\\\covert_to_csv.bat"
    ...    connection=Emil_decode
    csn.Execute    command=rm -rf "${emil_log_PC}";mkdir -p "${emil_log_PC}\\\\CSV_File"
    ...    connection=Emil_decode
    log to console    \n create bat command
    ${cmd}=    catenate    start /wait Emil.exe "${emil_log_PC_win}\\\\${emil_log_name}" -tocsv PerTrace
    ...    -AutoClose   -destination ${emil_log_PC_win}\\\\CSV_File
    set suite variable    ${cmd}
    OperatingSystem.Create File     path=${emil_log_UTE}/covert_to_csv.bat    content=${cmd}
    log to console    \n convert to txt
    OperatingSystem.Run    sshpass -p ${EMIL_PASSWORD} scp ${emil_log_UTE}/${emil_log_name} ${EMIL_USER}@${EMIL_HOST}:${emil_log_PC}/
    OperatingSystem.Run    sshpass -p ${EMIL_PASSWORD} scp ${emil_log_UTE}/covert_to_csv.bat ${EMIL_USER}@${EMIL_HOST}:${emil_exe_path}/
    csn.Execute    command=cd "${emil_exe_path}"    connection=Emil_decode
    log to console    \n convert emil to txt
    csn.Execute    command=cd "${emil_exe_path}";cmd.exe /c covert_to_csv.bat    connection=Emil_decode
    OperatingSystem.Run    sshpass -p ${EMIL_PASSWORD} scp ${EMIL_USER}@${EMIL_HOST}:${emil_log_PC}/CSV_File/* ${emil_csv_UTE}/tmp
    ${time}    Get Time    epoch
    csn.Execute   command=cd ${emil_csv_UTE}/tmp/;for file in *;do mv "$file" "${time}_$file";done
        ...    connection=ute
    csn.Execute   command=cp ${emil_csv_UTE}/tmp/* ${emil_csv_UTE}/
        ...    connection=ute
    csn.Execute   command=rm -r ${emil_csv_UTE}/tmp;
        ...    connection=ute
  #  [Teardown]    run keywords     csn.Disconnect    connection=Emil_decode

Get Counter from TTI
    [Arguments]    ${TTI_CSV_merged}        ${Emil_CSV_merged}     ${cell_info}      ${timeout}=60 minutes
    [Timeout]     ${timeout}
    CB010636_CDE.add_timestamp_to_csv     file_path=${TTI_CSV_merged}
    log to console     Get RNTI
    ${ca_info}     CB010636_CDE.get_rnti_and_ca_from_csv     Emil_file_path=${Emil_CSV_merged}           cell_info=${cell_info}
    log to console     Get Counter From TTI
    ${Cell_RLC_Counter_dic}    ${Cell_Mac_Counter_dic}    CB010636_CDE.get_burst_amount_and_time_per_cc
    ...    csv_file_path=${TTI_CSV_merged}
    ...    cell_info=${cell_info}    ca_info=${ca_info}    threshold_vol=${0}     threshold_tim=${0}
    Set Suite Variable      ${Cell_RLC_Counter_dic}
    Set Suite Variable      ${Cell_Mac_Counter_dic}
    [Return]     ${Cell_RLC_Counter_dic}    ${Cell_Mac_Counter_dic}

Calculate PM counter Timestamp
    [Arguments]    ${cur_timestamp}        ${reporting_interval}=5
    csn.Connect to    hostname=${DU_OAM_IP_1}     username=${bts_username}     password=${bts_password}
    ...      alias=${GNB_COAM_ALIAS_1}
    &{pre_case_time_info}    CB010636_CDE.calculate_waiting_time_for_log_capturing_or_log_generation
    ...      reporting_interval=${reporting_interval}
    ...      cur_timestamp=${cur_timestamp}
    log to console    pre_case_time_info is ${pre_case_time_info}
	Run Keyword and Ignore Error    log to console    wait time is ${pre_case_time_info}[wait_time_sec]
	#sleep    ${pre_case_time_info}[wait_time_sec]
	${newest_timestamp_epoch}      convert date    ${pre_case_time_info}[log_generator_timestamp]   epoch
	${newest_timestamp_epoch}    Evaluate    int(${newest_timestamp_epoch}+${reporting_interval}*60)
	Set Suite Variable       ${pre_case_time_info}
	Set Suite Variable       ${newest_timestamp_epoch}
	[Return]     ${pre_case_time_info}     ${newest_timestamp_epoch}
	[Teardown]   csn.Disconnect    connection=${GNB_COAM_ALIAS_1}

Calculate PM counter Timestamp List
     [Arguments]    ${newest_timestamp_epoch_end}        ${newest_timestamp_epoch_start}      ${reportinterval}=5
     ${max_loop}    Evaluate    int((${newest_timestamp_epoch_end}-${newest_timestamp_epoch_start})/(${reportinterval}*60))+1
     ${timestamp0}    set Variable    ${newest_timestamp_epoch_end}
     @{timestamp_list}    Create List
     FOR    ${index}    IN RANGE    ${Max_loop}
         ${timestamp0}     Evaluate    ${newest_timestamp_epoch_end}-${reportinterval}*(${index}+1)*60
         Append To List  ${timestamp_list}   ${timestamp0}
         Set Suite Variable       ${timestamp_list}
         Set Suite Variable       ${timestamp0}
     END
     log to console    timestamp_list is ${timestamp_list}

Calculate Wait Time For PM counter Update In WebEM
    [Arguments]    ${newest_timestamp_epoch_end}
    ${cur_timestamp1}     Get current time from GNB
    ${cur_timestamp1_epoch}      convert date    ${cur_timestamp1}    epoch
    log to console    the time befor get PM counter In WebEM is ${cur_timestamp1_epoch}
    ${wait_time}     Run Keyword If  ${cur_timestamp1_epoch} <= ${newest_timestamp_epoch_end}
    ...    Evaluate    ${newest_timestamp_epoch}-${cur_timestamp1_epoch}+60
    ...    ELSE     Set Variable       ${60}
    Set Suite Variable    ${wait_time}
    Run Keyword And Continue On Failure    sleep    ${wait_time}s
    Run Keyword And Continue On Failure    log to console    wait_time is ${wait_time}

Get current time from GNB
    csn.Connect to    hostname=${DU_OAM_IP_1}     username=${bts_username}     password=${bts_password}
    ...     alias=${GNB_COAM_ALIAS_1}
    ${cur_timestamp}    CB010636_CDE.get_timestamp_from_gnb    connection=${GNB_COAM_ALIAS_1}
    Set Suite Variable       ${cur_timestamp}
	[Return]     ${cur_timestamp}
	[Teardown]   csn.Disconnect    connection=${GNB_COAM_ALIAS_1}

Get Multi Cells Multi PM Counters value for CB010636-ACDE
    log to console    \n    ****Get Pcell counter dict
    ${pcell_counter_dict}    Run Keyword And Continue On Failure
    ...      Get All Counter Values List              ${PM_COUNTER_LIST}
    ...                                                               connection=${GNB_COAM_ALIAS_1}
    ...                                                               host=${DU_OAM_IP_1}
    log to console    \n    ****Get Scell counter dict
    ${scell_counter_dict}    Run Keyword And Continue On Failure
    ...      Get All Counter Values List              ${PM_COUNTER_LIST}
    ...                                                               connection=${GNB_COAM_ALIAS_2}
    ...                                                                host=${DU_OAM_IP_2}

    ${mac_counter_dict_577}     Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters       ${MAC_COUNTER_INFO_LIST_577}
    ...      ${pcell_counter_dict}      ${timestamp_list}
    ${mac_counter_dict_scell}     Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters       ${MAC_COUNTER_INFO_LIST_Scell}
    ...      ${scell_counter_dict}      ${timestamp_list}
    #start--PM Counter DL_RLC_PDU_VOL_UE_TPUT M55349C03002 and DL_RLC_PDU_TIME_UE_TPUT M55349C04002
    ${rlch_counter_dict_577}     Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters     ${RLCH_COUNTER_INFO_LIST_577}
    ...      ${pcell_counter_dict}      ${timestamp_list}
    ${rlch_counter_dict_scell}          Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters     ${RLCH_COUNTER_INFO_LIST_Scell}
    ...      ${scell_counter_dict}      ${timestamp_list}
    #end---PM Counter DL_RLC_PDU_VOL_UE_TPUT M55349C03002 and DL_RLC_PDU_TIME_UE_TPUT M55349C04002
    ${rlc_pmqap_counter_dict_577}            Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters     ${RLC_PMQAP_COUNTER_INFO_LIST_577}
    ...       ${pcell_counter_dict}      ${timestamp_list}
    ${rlc_pmqap_counter_dict_scell}          Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters     ${RLC_PMQAP_COUNTER_INFO_LIST_Scell}
    ...      ${scell_counter_dict}      ${timestamp_list}
    ${rlcl_counter_dict_577}          Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters    ${RLCL_COUNTER_INFO_LIST_577}
    ...        ${pcell_counter_dict}      ${timestamp_list}
    ${rlcl_counter_dict_scell}          Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters    ${RLCL_COUNTER_INFO_LIST_Scell}
    ...         ${scell_counter_dict}       ${timestamp_list}
    ${pdcp_pmqap_counter_dict_577}          Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters     ${PDCP_PMQAP_COUNTER_INFO_LIST_577}
    ...      ${pcell_counter_dict}      ${timestamp_list}
    ${pdcp_pmqap_counter_dict_scell}          Run Keyword And Continue On Failure
    ...      Get Multi Cells Multi PM Counters     ${PDCP_PMQAP_COUNTER_INFO_LIST_Scell}
    ...      ${scell_counter_dict}      ${timestamp_list}
    ${mac_counter_dict_merged}    Run Keyword And Continue On Failure
    ...      Evaluate    dict(${mac_counter_dict_577}) | dict(${mac_counter_dict_scell})
    ${rlch_counter_dict_merged}    Run Keyword And Continue On Failure
    ...      Evaluate    dict(${rlch_counter_dict_577}) | dict(${rlch_counter_dict_scell})
    ${rlc_pmqap_counter_dict_merged}      Run Keyword And Continue On Failure
    ...      Evaluate    dict(${rlc_pmqap_counter_dict_577}) | dict(${rlc_pmqap_counter_dict_scell})
    ${pdcp_pmqap_counter_dict_merged}      Run Keyword And Continue On Failure
    ...      Evaluate    dict(${pdcp_pmqap_counter_dict_577}) | dict(${pdcp_pmqap_counter_dict_scell})
    ${rlcl_counter_dict_merged}    Run Keyword And Continue On Failure
    ...      Evaluate    dict(${rlcl_counter_dict_577}) | dict(${rlcl_counter_dict_scell} )
    Run Keyword And Continue On Failure       Set Suite Variable     ${mac_counter_dict_merged}
    Run Keyword And Continue On Failure       Set Suite Variable     ${rlch_counter_dict_merged}
    Run Keyword And Continue On Failure       Set Suite Variable     ${rlc_pmqap_counter_dict_merged}
    Run Keyword And Continue On Failure       Set Suite Variable     ${rlcl_counter_dict_merged}
    Run Keyword And Continue On Failure       Set Suite Variable     ${rlcl_counter_dict_577}
    Run Keyword And Continue On Failure       Set Suite Variable     ${rlcl_counter_dict_scell}
    #Set Suite Variable     ${pdcp_pmqap_counter_dict_merged}


Check RLC PMQAP PM Counter
    [Documentation]     DL_RLC_PDU_VOL_UE_TPUT_PMQAP      M55353C00002
    ...                 DL_RLC_PDU_TIME_UE_TPUT_PMQAP    M55353C00003
    FOR    ${PCI}     IN      @{cell_info.keys()}
        Log to console     Check DL_RLC_PMQAP PM Counter
        ${cell_pmqap_counter_webem}    set Variable    ${rlc_pmqap_counter_dict_merged['${PCI}']}

        ${Cell_RLC_PMQAP_Counter_TTI_Keys_LIST}    Get Dictionary Keys     ${Cell_RLC_Counter_dic}
        ${is_exist}    RUN KEYWORD AND RETURN STATUS
        ...    Should Contain    ${Cell_RLC_PMQAP_Counter_TTI_Keys_LIST}    ${PCI}
        ${Cell_RLC_PMQAP_Counter_TTI}         Run Keyword If    ${is_exist}
        ...    set Variable      ${Cell_RLC_Counter_dic[${PCI}]['RLC_UE_TPUT_DRB']}
        Run Keyword If    ${is_exist}
        ...    Run Keyword And Continue On Failure    Check RLC PMQAP PM Counter For One Cell
        ...    ${cell_pmqap_counter_webem}     ${Cell_RLC_PMQAP_Counter_TTI}
        ...    ELSE    Run Keyword And Continue On Failure        Check RLC PMQAP PM Counter Is Zero For One Cell
        ...    ${cell_pmqap_counter_webem}
    END

Check RLC PMQAP PM Counter For One Cell
    [Arguments]    ${cell_pmqap_counter_webem}     ${Cell_RLC_PMQAP_Counter_TTI}
    FOR    ${pmqap_id}    IN      @{cell_pmqap_counter_webem.keys()}
        ${WEBEM_VOL_value}    set Variable   ${cell_pmqap_counter_webem['${pmqap_id}']['M55353C00002']}
        ${WEBEM_TIM_value}    set Variable   ${cell_pmqap_counter_webem['${pmqap_id}']['M55353C00003']}
        ${channel_id}    set Variable    ${pmqap_channnel_info['${pmqap_id}']}
        ${Cell_RLC_PMQAP_Counter_TTI_Keys_LIST}    Get Dictionary Keys     ${Cell_RLC_PMQAP_Counter_TTI}
        ${is_exist}    RUN KEYWORD AND RETURN STATUS
        ...    Should Contain    ${Cell_RLC_PMQAP_Counter_TTI_Keys_LIST}    ${channel_id}
        ${Cell_RLC_PMQAP_DRB_Counter_TTI}         Run Keyword If    ${is_exist}
        ...    set Variable      ${Cell_RLC_PMQAP_Counter_TTI[${channel_id}]}
        Run Keyword If    ${is_exist}
        ...      Run Keyword And Continue On Failure
        ...      Check RLC PMQAP PM Counter for Per DRB of One Cell     ${Cell_RLC_PMQAP_DRB_Counter_TTI}
        ...      ${WEBEM_VOL_value}      ${WEBEM_TIM_value}
        ...      ELSE      Run Keywords
        ...      Run Keyword And Continue On Failure    Should Be True     ${WEBEM_VOL_value} == ${0}
        ...      AND    Run Keyword And Continue On Failure    Should Be True     ${WEBEM_TIM_value} == ${0}
    END

Check RLC PMQAP PM Counter Is Zero For One Cell
    [Arguments]    ${cell_pmqap_counter_webem}    ${Is_Zero}=${True}
    FOR    ${pmqap_id}    IN      @{cell_pmqap_counter_webem.keys()}
        ${WEBEM_VOL_value}    set Variable   ${cell_pmqap_counter_webem['${pmqap_id}']['M55353C00002']}
        ${WEBEM_TIM_value}    set Variable   ${cell_pmqap_counter_webem['${pmqap_id}']['M55353C00003']}
        Run Keyword If    ${Is_Zero}      Run Keywords
        ...      Run Keyword And Continue On Failure    Should Be True     ${WEBEM_VOL_value} == ${0}
        ...      AND      Run Keyword And Continue On Failure    Should Be True     ${WEBEM_TIM_value} == ${0}
        ...      ELSE      Run Keywords
        ...      Run Keyword And Continue On Failure    Should Be True     ${WEBEM_VOL_value} > ${0}
        ...      AND    Run Keyword And Continue On Failure    Should Be True     ${WEBEM_TIM_value} > ${0}
    END

Check RLC PMQAP PM Counter for Per DRB of One Cell
        [Arguments]    ${Cell_RLC_PMQAP_DRB_Counter_TTI}      ${WEBEM_VOL_value}      ${WEBEM_TIM_value}
        ${TTI_VOL_value}    set Variable   ${Cell_RLC_PMQAP_DRB_Counter_TTI['VOL_DRB']}
        ${TTI_TIM_value}    set Variable   ${Cell_RLC_PMQAP_DRB_Counter_TTI['TIM_DRB']}
        ${is_ignore}    RUN KEYWORD AND RETURN STATUS
        ...    Should Be True    ${TTI_VOL_value} > ${512}
        ${gap_VOL}     Run Keyword If    ${is_ignore}
        ...      Evaluate    abs(${WEBEM_VOL_value}-${TTI_VOL_value})/${TTI_VOL_value}
        ${gap_TIM}         Run Keyword If    ${is_ignore}
        ...      Evaluate    abs(${WEBEM_TIM_value}-${TTI_TIM_value})/${TTI_TIM_value}
        Run Keyword If    ${is_ignore}
        ...      Run Keywords
        ...      Run Keyword And Continue On Failure    Should Be True     ${gap_VOL} <= ${exp_gap}
        ...      AND    Run keyword and ignore error    Should Be True     ${gap_TIM} <= ${exp_gap}
        ...      ELSE     log to console     Counter VOL and TIM value is small and will be ignore


Check RLC_PDU PM Counter M55349C03002 and M55349C04002 and M55349C00046
     FOR    ${key}    IN      @{cell_info.keys()}
        ${PCI}    set Variable    ${key}
        Log to console     Check cell_${PCI} PM Counter DL_RLC_PDU_VOL_UE_TPUT and DL_RLC_PDU_TIME_UE_TPUT
        Log to console     Check cell_${PCI} PM Counter DL_RLC_PDU_UE_TPUT_DENOM_FR1
        ${cell_RLC_counter_webem}    set Variable   ${rlch_counter_dict_merged['${PCI}']}
        Set Suite Variable    ${cell_RLC_counter_webem}
        ${WEBEM_VOL_value}    set Variable   ${cell_RLC_counter_webem['M55349C03002']}
        ${WEBEM_TIM_value}    set Variable   ${cell_RLC_counter_webem['M55349C04002']}
        ${WEBEM_DENOM_value}    set Variable   ${cell_RLC_counter_webem['M55349C00046']}
        ${Cell_RLC_Counter_TTI_Keys_LIST}    Get Dictionary Keys     ${Cell_RLC_Counter_dic}
        ${is_exist}    RUN KEYWORD AND RETURN STATUS
        ...    Should Contain    ${Cell_RLC_Counter_TTI_Keys_LIST}    ${PCI}
        ${Cell_RLC_Counter_TTI}     Run Keyword If    ${is_exist}    set Variable      ${Cell_RLC_Counter_dic[${PCI}]}
        Set Suite Variable    ${Cell_RLC_Counter_TTI}
        Run Keyword If    ${is_exist}
         ...    Check RLC_PDU PM Counter For One Cell    ${cell_RLC_counter_webem}      ${Cell_RLC_Counter_TTI}
         ...    ELSE      Run Keywords
         ...    Run Keyword And Continue On Failure    Should Be True     ${WEBEM_VOL_value} == ${0}
         ...    AND    Run Keyword And Continue On Failure    Should Be True     ${WEBEM_TIM_value} == ${0}
         ...    AND    Run Keyword And Continue On Failure    Should Be True     ${WEBEM_DENOM_value} == ${0}
    END

Check RLC_PDU PM Counter For One Cell
    [Arguments]    ${cell_RLC_counter_webem}     ${Cell_RLC_Counter_TTI}
    ${WEBEM_VOL_value}    set Variable   ${cell_RLC_counter_webem['M55349C03002']}
    ${WEBEM_TIM_value}    set Variable   ${cell_RLC_counter_webem['M55349C04002']}
    ${WEBEM_DENOM_value}    set Variable   ${cell_RLC_counter_webem['M55349C00046']}
    ${TTI_VOL_value}    set Variable   ${Cell_RLC_Counter_TTI['DL_RLC_PDU_VOL_UE_TPUT_sum_merged']}
    ${TTI_VOL_CC_value}    set Variable   ${Cell_RLC_Counter_TTI['DL_RLC_PDU_VOL_UE_TPUT_sum_CC']}
    ${TTI_TIM_value}    set Variable   ${Cell_RLC_Counter_TTI['DL_RLC_PDU_TIME_UE_TPUT_sum_merged']}
    ${TTI_TIM_CC_value}    set Variable   ${Cell_RLC_Counter_TTI['DL_RLC_PDU_TIME_UE_TPUT_sum_CC']}
    ${TTI_DENOM_value}    set Variable   ${Cell_RLC_Counter_TTI['DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum']}
    ${is_ignore}    RUN KEYWORD AND RETURN STATUS
    ...    Should Be True    ${TTI_VOL_value} > ${512}
    ${gap_VOL}    Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_VOL_value}-${TTI_VOL_value})/${TTI_VOL_value}
    ${gap_VOL_CC}    Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_VOL_value}-${TTI_VOL_CC_value})/${TTI_VOL_CC_value}
    ${gap_TIM}    Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_TIM_value}-${TTI_TIM_value})/${TTI_TIM_value}
    ${gap_TIM_CC}    Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_TIM_value}-${TTI_TIM_CC_value})/${TTI_TIM_CC_value}
    ${gap_DENOM_CC}    Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_DENOM_value}-${TTI_DENOM_value})/${TTI_DENOM_value}
    Run Keyword If    ${is_ignore}     Run Keywords
    ...      Run Keyword And Continue On Failure    Should Be True     ${gap_VOL} <= ${exp_gap}
    ...      AND      Run Keyword And Continue On Failure    Should Be True     ${gap_VOL_CC} <= ${exp_gap}
    ...      AND     Run keyword and ignore error    Should Be True     ${gap_TIM} <= ${exp_gap}
    ...      AND     Run keyword and ignore error    Should Be True     ${gap_TIM_CC} <= ${exp_gap}
    ...      AND     Run Keyword And Continue On Failure    Should Be True     ${gap_DENOM_CC} <= ${exp_gap}
    ...      ELSE     log to console     Counter VOL and TIM value is small and will be ignore

Check RLC_PDU_CC PM Counter
    FOR    ${PCI}     IN      @{cell_info.keys()}
        Log to console     Check DL_RLC_CC PM Counter
        ${cell_RLC_CC_counter_webem}   set Variable    ${rlch_counter_dict_merged['${PCI}']}
        Set Suite Variable     ${cell_RLC_CC_counter_webem}
        ${Cell_RLC_CC_Counter_TTI_Keys_LIST}    Get Dictionary Keys     ${Cell_RLC_Counter_dic}
        ${is_exist}    RUN KEYWORD AND RETURN STATUS
        ...    Should Contain    ${Cell_RLC_CC_Counter_TTI_Keys_LIST}    ${PCI}
        ${Cell_RLC_CC_Counter_TTI}     Run Keyword If    ${is_exist}    set Variable      ${Cell_RLC_Counter_dic[${PCI}]}
        Run Keyword If    ${is_exist}
        ...     Run Keyword And Continue On Failure    Check RLC_PDU_CC PM Counter For One Cell
        ...    ${cell_RLC_CC_counter_webem}    ${Cell_RLC_CC_Counter_TTI}
        ...    ELSE    Run Keyword And Continue On Failure     Check RLC_PDU_CC PM Counter Is Zero For One Cell
    END

Check RLC_PDU_CC PM Counter Is Zero For One Cell
    FOR    ${CC}    IN      @{DL_RLC_CC_FR1_SA_Counter.keys()}
        ${VOL_name}    set Variable    ${DL_RLC_CC_FR1_SA_Counter[${CC}]['VOL']}
        ${TIME_name}    set Variable    ${DL_RLC_CC_FR1_SA_Counter[${CC}]['TIME']}
        ${WEBEM_VOL_value}    set Variable   ${cell_RLC_CC_counter_webem['${VOL_name}']}
        ${WEBEM_TIM_value}    set Variable   ${cell_RLC_CC_counter_webem['${TIME_name}']}
        Run Keyword And Continue On Failure    Should Be True     ${WEBEM_VOL_value} == ${0}
        Run Keyword And Continue On Failure    Should Be True     ${WEBEM_TIM_value} == ${0}
    END


Check RLC_PDU_CC PM Counter For One Cell
    [Arguments]    ${cell_RLC_CC_counter_webem}     ${Cell_RLC_CC_Counter_TTI}
    ${Cell_RLC_CC_Counter_TTI_Keys}    Get Dictionary Keys     ${Cell_RLC_CC_Counter_TTI['DL_RLC_VOL_UE_TPUT_FR1_SA_CC']}
    ${WEBEM_VOL_value_SUM}    set Variable     ${0}
    ${WEBEM_TIM_value_SUM}    set Variable     ${0}
     FOR    ${CC}    IN      @{DL_RLC_CC_FR1_SA_Counter.keys()}
        ${VOL_name}    set Variable    ${DL_RLC_CC_FR1_SA_Counter[${CC}]['VOL']}
        ${TIME_name}    set Variable    ${DL_RLC_CC_FR1_SA_Counter[${CC}]['TIME']}
        ${WEBEM_VOL_value}    set Variable   ${cell_RLC_CC_counter_webem['${VOL_name}']}
        ${WEBEM_TIM_value}    set Variable   ${cell_RLC_CC_counter_webem['${TIME_name}']}
        Set Suite Variable    ${WEBEM_VOL_value}
        Set Suite Variable    ${WEBEM_TIM_value}
        Set Suite Variable    ${CC}
        ${WEBEM_VOL_value_SUM}   Evaluate    ${WEBEM_VOL_value}+${WEBEM_VOL_value_SUM}
        ${WEBEM_TIM_value_SUM}   Evaluate    ${WEBEM_TIM_value}+${WEBEM_TIM_value_SUM}
        Set Suite Variable    ${WEBEM_VOL_value_SUM}
        Set Suite Variable    ${WEBEM_TIM_value_SUM}
        ${is_exist}    RUN KEYWORD AND RETURN STATUS
        ...    Should Contain    ${Cell_RLC_CC_Counter_TTI_Keys}    ${CC}
        Run Keyword If    ${is_exist}    Check RLC_PDU_CC PM Counter For Per CC Of One Cell
        ...    ${Cell_RLC_CC_Counter_TTI}    ${WEBEM_VOL_value}     ${WEBEM_TIM_value}    ${CC}
        ...    ELSE    Run Keywords
        ...            Run Keyword And Continue On Failure    Should Be True     ${WEBEM_VOL_value} == ${0}    AND
        ...            Run Keyword And Continue On Failure    Should Be True     ${WEBEM_TIM_value} == ${0}
    END
    ${TTI_VOL_value_}    set Variable   ${Cell_RLC_CC_Counter_TTI['DL_RLC_PDU_VOL_UE_TPUT_sum_merged']}
    ${TTI_VOL_CC_value}    set Variable   ${Cell_RLC_CC_Counter_TTI['DL_RLC_PDU_VOL_UE_TPUT_sum_CC']}
    ${TTI_TIM_value}    set Variable   ${Cell_RLC_CC_Counter_TTI['DL_RLC_PDU_TIME_UE_TPUT_sum_merged']}
    ${TTI_TIM_CC_value}    set Variable   ${Cell_RLC_CC_Counter_TTI['DL_RLC_PDU_TIME_UE_TPUT_sum_CC']}
    ${gap_VOL}    Evaluate    abs(${WEBEM_VOL_value_SUM}-${TTI_VOL_value})/${TTI_VOL_value}
    ${gap_VOL_CC}    Evaluate    abs(${WEBEM_VOL_value_SUM}-${TTI_VOL_CC_value})/${TTI_VOL_CC_value}
    ${gap_TIM}    Evaluate    abs(${WEBEM_TIM_value_SUM}-${TTI_TIM_value})/${TTI_TIM_value}
    ${gap_TIM_CC}    Evaluate    abs(${WEBEM_TIM_value_SUM}-${TTI_TIM_CC_value})/${TTI_TIM_CC_value}
    Run Keyword And Continue On Failure    Should Be True     ${gap_VOL} <= ${exp_gap}
    Run Keyword And Continue On Failure    Should Be True     ${gap_VOL_CC} <= ${exp_gap}
    Run keyword and ignore error    Should Be True     ${gap_TIM} <= ${exp_gap}
    Run keyword and ignore error    Should Be True     ${gap_TIM_CC} <= ${exp_gap}


Check RLC_PDU_CC PM Counter For Per CC Of One Cell
    [Arguments]    ${Cell_RLC_CC_Counter_TTI}    ${WEBEM_VOL_value}     ${WEBEM_TIM_value}     ${CC}
    ${TTI_VOL_value}    set Variable   ${Cell_RLC_CC_Counter_TTI['DL_RLC_VOL_UE_TPUT_FR1_SA_CC'][${CC}]}
    ${TTI_TIM_value}    set Variable   ${Cell_RLC_CC_Counter_TTI['DL_RLC_TIM_UE_TPUT_FR1_SA_CC'][${CC}]}
    ${is_ignore}    RUN KEYWORD AND RETURN STATUS
    ...    Should Be True    ${TTI_VOL_value} > ${512}
    ${gap_VOL}     Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_VOL_value}-${TTI_VOL_value})/${TTI_VOL_value}
    ${gap_TIM}         Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_TIM_value}-${TTI_TIM_value})/${TTI_TIM_value}
    Run Keyword If    ${is_ignore}     Run Keywords
    ...      Run Keyword And Continue On Failure    Should Be True     ${gap_VOL} <= ${exp_gap}
    ...      AND      Run keyword and ignore error    Should Be True     ${gap_TIM} <= ${exp_gap}
    ...    ELSE    Run Keyword And Continue On Failure     Check RLC_PDU_CC PM Counter Is Zero For One Cell



Check MAC_SDU PM Counter M55309C00002 and M55309C00003
     FOR    ${key}    IN      @{cell_info.keys()}
         ${PCI}    set Variable    ${key}
         Log to console     Check cell_${PCI} PM Counter DL_MAC_SDU_VOL_UE_TPUT and DL_MAC_SDU_TIME_UE_TPUT
         ${cell_MAC_counter_webem}     set Variable      ${mac_counter_dict_merged['${PCI}']}
         ${Cell_MAC_Counter_TTI_Keys_LIST}    Get Dictionary Keys     ${Cell_Mac_Counter_dic}
         ${is_exist}    RUN KEYWORD AND RETURN STATUS
         ...    Should Contain    ${Cell_MAC_Counter_TTI_Keys_LIST}    ${PCI}
         ${Cell_MAC_Counter_TTI}     Run Keyword If    ${is_exist}    set Variable      ${Cell_Mac_Counter_dic[${PCI}]}
         Run Keyword If    ${is_exist}
         ...    Check MAC_SDU PM Counter For One Cell    ${cell_MAC_counter_webem}      ${Cell_MAC_Counter_TTI}
         ...    ELSE       Run Keywords
         ...    Run Keyword And Continue On Failure
         ...      Should Be True     ${cell_MAC_counter_webem['M55309C00002']} == ${0}
         ...    AND    Run Keyword And Continue On Failure
         ...      Should Be True     ${cell_MAC_counter_webem['M55309C00003']} == ${0}
    END

Check MAC_SDU PM Counter For One Cell
    [Arguments]    ${cell_MAC_counter_webem}     ${Cell_MAC_Counter_TTI}
    ${WEBEM_VOL_value}    set Variable   ${cell_MAC_counter_webem['M55309C00002']}
    ${TTI_VOL_value}    set Variable   ${Cell_MAC_Counter_TTI['DL_MAC_SDU_VOL_UE_TPUT_sum']}
    ${WEBEM_TIM_value}    set Variable   ${cell_MAC_counter_webem['M55309C00003']}
    ${TTI_TIM_value}    set Variable   ${Cell_MAC_Counter_TTI['DL_MAC_SDU_TIME_UE_TPUT_sum']}
    ${is_ignore}    RUN KEYWORD AND RETURN STATUS
    ...    Should Be True    ${TTI_VOL_value} > ${512}
    ${VOL_Gap}     Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_VOL_value}-${TTI_VOL_value})/${TTI_VOL_value}
    ${TIM_Gap}      Run Keyword If    ${is_ignore}
    ...      Evaluate    abs(${WEBEM_TIM_value}-${TTI_TIM_value})/${TTI_TIM_value}
    Run Keyword If    ${is_ignore}     Run Keywords
    ...      Run Keyword And Continue On Failure    Should Be True     ${VOL_Gap} <= ${exp_gap}
    ...      AND       Run Keyword And Continue On Failure    Should Be True     ${TIM_Gap} <= ${exp_gap}


Adjust One HBTE ATT Value
    [Arguments]      ${PA_Info}    ${PA_IP}=${att_ipaddr}
    ...     ${HBTE_max_value}=${HBTE_max_value_TL915}
    ...     ${model}=PA-8-2-6-127-0.5-B-S
   ${Port_Value_dic}    set Variable     ${PA_Info['Port_Value']}
   ${att_connection_port}      Get Dictionary Keys    ${PA_Info['Port_Value']}
   ${PA_IP_0}    Run Keyword If    '${PA_Info['IP']}'=='None'     set Variable    ${PA_IP}
   ...   ELSE      set Variable     ${PA_Info['IP']}
   att.setup_attenuator    ip_addr=${PA_IP_0}    port=${PA_Info['Port']}
    ...      attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR    ${key}    IN      @{Port_Value_dic.keys()}
      att.set_attenuation     port=${key}    value=${Port_Value_dic[${key}]}
       ${value_port1}    att.read_attenuation    port=${key}
       ${value_port1}    convert to integer    ${value_port1}
      should be equal    ${value_port1}    ${Port_Value_dic[${key}]}
    END

Check MAC And RLC counter Is Zero Or Not
    [Arguments]      ${Is_Zero}=${True}
      Run Keyword And Continue On Failure       Check RLC PMQAP PM Counter Is Zero Or Not      ${Is_Zero}


Check RLC PMQAP PM Counter Is Zero Or Not
    [Documentation]     DL_RLC_PDU_VOL_UE_TPUT_PMQAP      M55353C00002
    ...                 DL_RLC_PDU_TIME_UE_TPUT_PMQAP    M55353C00003
    [Arguments]      ${Is_Zero}=${True}
    FOR    ${PCI}     IN      @{cell_info.keys()}
        Log to console     Check DL_RLC_PMQAP PM Counter
        ${cell_pmqap_counter_webem}    set Variable    ${rlc_pmqap_counter_dict_merged['${PCI}']}
        ...    ELSE    Run Keyword And Continue On Failure        Check RLC PMQAP PM Counter Is Zero For One Cell
        ...    ${cell_pmqap_counter_webem}      ${Is_Zero}
    END

Check CB010636-CDE Counter
    Run Keyword And Continue On Failure     Check RLC_PDU PM Counter M55349C03002 and M55349C04002 and M55349C00046
    Run Keyword And Continue On Failure     Check MAC_SDU PM Counter M55309C00002 and M55309C00003
    Run Keyword And Continue On Failure     Check RLC PMQAP PM Counter
    ${TEST_STATUS}    RUN KEYWORD AND RETURN STATUS     Check RLC_PDU_CC PM Counter
    ${Pass_Or_Fail}    Run Keyword If    ${TEST_STATUS}      set Variable      Pass
    ...      ELSE      set Variable      Fail
    log to console    Check RLC_PDU_CC PM Counter Status is ${Pass_Or_Fail}
