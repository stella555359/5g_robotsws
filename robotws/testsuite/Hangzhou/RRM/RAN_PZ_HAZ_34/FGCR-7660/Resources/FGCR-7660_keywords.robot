*** Settings ***
Documentation
...   This is for  TA common keywords
...   squad group: MMW_SG1
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./FGCR-7660_variables.robot
#Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Variables   ../TestDate/FGCR-7660_SCF_modify.py
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    ../../5GC001581/Resources/5GC001581_keywords.robot
Library     ./FGCR-7660_verify_throughput_form_gNB.py    WITH NAME    FR7660
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    taf/rfrl/common_resources/robot/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/pm_counter.robot
Library    taf.analyzer.pcap     WITH NAME    cap
Library     taf.rfrl.common_resources.python.SWConfig     WITH NAME    swconf
Library     taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_average_throughput.py
#Library     verify_throughput_from_GNB_log.py    WITH NAME    verify_tput
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_setup_teardown.robot

*** Variables ***
${UE_TYPE}    ${tl.ues[0].capabilities[1]}
${UE_TYPE_1}    ${tl.ues[1].capabilities[1]}
${UE_TYPE_2}    ${tl.ues[2].capabilities[1]}
${UE_TYPE_3}    ${tl.ues[3].capabilities[1]}

*** Keywords ***

Start traffic uldl
    [Documentation]    author: Fang ludan
    [Arguments]    ${ue_index}    ${ue_type}=${UE_TYPE}
    ...     ${iperf_ul}=${None}    ${iperf_dl}=${None}
    ...          ${ue_alias}=UE_${ue_index}
    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_ul}    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${iperf_dl}    ${tl.ues[${ue_index}].iperf_details.port}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl    throughput=300M   duration=${dl_and_ul_time}
    ...    iperf_port=${iperf_ul}    ue_index=${ue_index}       buffer_size=1024B    dt_name=dt_dl    process_num=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M   duration=${dl_and_ul_time}
    ...    iperf_port=${iperf_dl}    ue_index=${ue_index}       buffer_size=1024B    dt_name=dt_ul    iperf_type=via_command
    ...    process_num=${1}



Check CC number in X2log
    [Documentation]    author: Fang ludan
    ...     Description:check cc number in X2log
    [Arguments]    ${x2ap_log}     ${cell_num_exp}
    ${filtered_packets}   pcap.load_pcap_file    pcap_file=${x2ap_log}     command_template=${X2AP_COMMAND}
    ${request}      pcap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)
    ${cell_num}    pcap.get_field_value_by_name    field_name=nr-rrc.sCellToAddModList    attribute_name=show
    should be equal as integers    ${cell_num[0]}      ${cell_num_exp}

Check CC number_0 in X2log
    [Documentation]    author: Fang ludan
    ...     Description:check cc number in X2log
    [Arguments]    ${x2ap_log}
    ${filtered_packets}   pcap.load_pcap_file    pcap_file=${x2ap_log}     command_template=${X2AP_COMMAND}
    ${request}      pcap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)
    ${cell_num}    pcap.get_field_value_by_name    field_name=nr-rrc.sCellToAddModList    attribute_name=show
    should be empty      ${cell_num}

Verify peak tput of each cell
     [Documentation]    Author: Fang ludan
    ...                Description: Check ul and dl peak throughput of each cells
    ...                dl_cell can be 1 or 1,2,3,4,5,6,7,8
    ...                ul_cell can be 1 or 1,2
    ...                :para${duration} is the whole time for checking tput. In this case, 600s will be the total time.
    [Arguments]    ${dl_cell}   ${ul_cell}  ${expected_ul_tput}   ${expected_dl_tput_max}    ${expected_dl_tput_min}
    ...    ${dl_num_exp}   ${ul_num_exp}
    ...    ${duration_time_for_once}=30    ${duration}=${DURATION_TIME}    ${local_log_folder}=${TS_CASE_LOG_PATH}
    ...    ${is_need_to_capture_log}=${False}
    ${list_dl_cell}    string2list    ${dl_cell}
    ${list_ul_cell}    string2list    ${ul_cell}
    ${start_time}    DateTime.get current date     result_format=epoch    exclude_millis=True
    ${end_time}    Evaluate    ${start_time}+${duration}
    @{list_tput_info}    Create list
    ${current_time_stamp}    set variable    ${start_time}
    ${check_0_tput_flag}     set variable    ${0}

    FOR    ${i}    IN RANGE    ${start_time}    ${end_time}
         ${Tput_records_dir}    Join path     ${local_log_folder}    Tput_Logs${current_time_stamp}
         Create directory     ${Tput_records_dir}
         connect to common unit master
         ssh.disconnect    connection=ASIK Master
         connect to common unit master
         @{saved_tput_file_list}    Run keyword and continue on failure    Retry log capturing if file content is empty
         ...    duration=${duration_time_for_once}
         ${dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
         ...    local_log_folder=${Tput_records_dir}
         ${ul_avg_peak_tput_info}
         ...    FR7660.get_details_of_peak_tput_each_cells   tput_file=${dict_local_tput_file_path['UL_L2LO']}
         ...    list_cell=${list_ul_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
         ${dl_avg_peak_tput_info}
         ...    FR7660.get_details_of_peak_tput_each_cells   tput_file=${dict_local_tput_file_path['DL_L2LO']}
         ...    list_cell=${list_dl_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
         ${ul_tput_num}     ${ul_tput_sum}   get ul tput num and sum      ul_avg_peak_tput_info=${ul_avg_peak_tput_info}
         ${dl_tput_num}     ${dl_tput_sum}   get dl tput num and sum      dl_avg_peak_tput_info=${dl_avg_peak_tput_info}
         ${check_peak_tput_status}    Run keyword and return status    run keywords
         ...   should be true    ${ul_tput_sum}>=${expected_ul_tput}  AND
         ...   Should be true    ${dl_tput_sum}>=${expected_dl_tput_min}     AND
         ...   Should be true     ${dl_tput_sum}<=${expected_dl_tput_max}
         ${check_tput_num_status}    Run keyword and return status
         ...    should be true    '${ul_tput_num}'=='${ul_num_exp}' or '${ul_tput_num}'=='2'
         Run keyword and continue on failure    Should be true    ${check_peak_tput_status}
         Run keyword and continue on failure    Should be true    ${check_tput_num_status}
         Run keyword if  ${check_peak_tput_status}==${False} and ${check_tput_num_status}==${False}
         ...    Capture event trace and bip simultaneously     local_log_folder=${Tput_records_dir}
         ${current_time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
         Exit for loop if    ${current_time_stamp}>${end_time}
         ssh.disconnect    connection=ASIK Master
    END



get ul tput num and sum
    [Documentation]    Author: fang ludan
    ...   Description: to get throughput cell num and sum.
    [Arguments]   ${ul_avg_peak_tput_info}  ${ul_tput_num}=0    ${ul_tput_sum}=0
    FOR    ${i}    IN      @{ul_avg_peak_tput_info}
            ${ul_tput_num}   run keyword if    ${i}>0     evaluate   ${ul_tput_num}+1       ELSE     set variable    ${ul_tput_num}
            ${ul_tput_sum}   run keyword if    ${i}>0     evaluate   ${ul_tput_sum}+${i}    ELSE     set variable    ${ul_tput_sum}
    END
    [return]    ${ul_tput_num}     ${ul_tput_sum}

get dl tput num and sum
    [Arguments]   ${dl_avg_peak_tput_info}   ${dl_tput_num}=0   ${dl_tput_sum}=0
    [Documentation]    Author: fang ludan
    ...   Description: to get throughput cell num and sum.
    FOR   ${i}    IN      @{dl_avg_peak_tput_info}
           ${dl_tput_num}   run keyword if    ${i}>0      evaluate   ${dl_tput_num}+1       ELSE     set variable    ${dl_tput_num}
           ${dl_tput_sum}   run keyword if    ${i}>0      evaluate    ${dl_tput_sum}+${i}   ELSE     set variable    ${dl_tput_sum}
    END
    [return]    ${dl_tput_num}     ${dl_tput_sum}




Retry commercial ue attach if failed no prepare
    [Timeout]    15 min
    [Documentation]    Author: fang ludan
    ...   Description: try attach via airplane mode.
    ...   ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${ue_type}=${UE_TYPE}    ${retry_time}=5    ${ue_index}=${0}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
        ${attach_status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
        ...    4G_check=True    ue_index=${ue_index}
        Exit for loop if    ${attach_status}
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console   UE_${ue_index} attached failed, retry detach time ${detach_time}
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE_${ue_index} attach with ${retry_time} times and still failed



get UE Type for 7660
    [Timeout]    15 min
    [Documentation]    Author: fang ludan
    ...   Description: to get all UE typr.
#     ${UE_TYPE}    translate_power_ue_type_from_testline   ue_index=0
#    Set suite variable    ${UE_TYPE}
#    ${UE_TYPE_1}    translate_power_ue_type_from_testline   ue_index=1
#    Set suite variable    ${UE_TYPE_1}
#    ${UE_TYPE_2}    translate_power_ue_type_from_testline   ue_index=2
#    Set suite variable    ${UE_TYPE_2}
#    ${UE_TYPE_3}    translate_power_ue_type_from_testline   ue_index=3
#    Set suite variable    ${UE_TYPE_3}
    Log To Console    get UE Type for 7660


Case Preparation for 7660
    Common case setup
    Connect to gnb coam via ssl
    &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
    Set test variable    ${NR_CELL_ID_MAPPING}



Close iperf progress for sam
    [Documentation]    Author: fang ludan
    ...    2020/4/22 Biyao modify to adapt to power_ue.robot
    ...    ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...     data_transfer_direction: supported values are both, ul, dl
    [Arguments]   ${ue_index}     ${data_transfer_direction}=both     ${ue_type}=${UE_TYPE}
    run keyword if     '${ue_type}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${None}    ${tl.ues[1].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${None}    ${tl.ues[1].iperf_details.port}
    Run keyword if    '${data_transfer_direction}'=='both'
    ...    Run keywords     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    ...            dt_name=dt_ul    iperf_port=${iperf_ul}      ue_index=${ue_index}     AND
    ...                     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    ...            dt_name=dt_dl    iperf_port=${iperf_dl}      ue_index=${ue_index}
    ...    ELSE IF    '${data_transfer_direction}'=='ul'
    ...        power_ue.Stop traffic    ue_type=${ue_type}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}    iperf_port=${iperf_ul}    ue_index=${ue_index}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...        power_ue.Stop traffic    ue_type=${ue_type}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}    iperf_port=${iperf_dl}      ue_index=${ue_index}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl


Suite preparation for 7660
    [Documentation]    Author: fang ludan
                ...    modify and commission SCF
    [Timeout]    20 min
    Preparation with swconfig modification and comissioning    swconfig_modify=${None}
    ...    scf_modify=${MODIFY_tmp}   is_called_in_test_case_level=${False}
    ...    is_pdl_checking_needed=${False}
     ...    scf_template_path=${SCF_DEFAULT_FILE_PATH_7660}    swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH_7660}
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}
    wait until keyword succeeds    5 min    10 sec    Verify all cells should be onair
#    ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
#    should be equal as strings  ${rus_connect_success}    True
    ${UE_TYPE}    translate_power_ue_type_from_testline
    Set variables for UTE cloud
    Set suite variable    ${UE_TYPE}



Prepare UE for 7660
    [Documentation]    Author: fang ludan
                ...   prepare UE for 7660
    [Timeout]    20 min

    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    power_ue.Prepare UE    ue_type=${UE_TYPE_1}    ue_index=${1}
    power_ue.Prepare UE    ue_type=${UE_TYPE_2}     ue_index=${2}
    power_ue.Prepare UE    ue_type=${UE_TYPE_3}    ue_index=${3}



UE detach for 7660
    [Documentation]    Author: fang ludan
                ...   UE detach for 7660
    [Timeout]    20 min
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Detach    ue_type=${UE_TYPE_1}     ue_index=${1}
    power_ue.UE Detach    ue_type=${UE_TYPE_2}    ue_index=${2}
    power_ue.UE Detach    ue_type=${UE_TYPE_3}    ue_index=${3}




Modify SCF on ENB for 7660
    [Documentation]    Author: fang ludan
                ...   modify parameter on ENB
    [Timeout]    20 min
    [Arguments]   ${online_modify_parameters}
    Connect to eNB via ssl
    run keyword if    ${online_modify_parameters}!=${NONE}
    ...    coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${online_modify_parameters}
        ...    connection=enblte


case teardown for 7660
    [Documentation]    Author: fang ludan
                ...   add UE detach in teardown
    [Timeout]    20 min
    UE detach for 7660
    Common case teardown
    CI_interface.Common Case Teardown

attach multi power ue
    [Arguments]    ${ue_index}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    [Return]   ${5Grach_ed_0}

UE attach agin
    [Arguments]  ${ue_index}
    log to console    ue attach agin
    power_ue.UE Detach    ue_index=${ue_index}   ue_type=samsung
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False


Verify UE attach by UE Index
    [Arguments]  ${ue_num}    ${5Grach_ed_list}
    FOR  ${item}    IN RANGE    ${ue_num}
        ${attach_status}    run keyword and return status    power_ue.Verify attach    ue_type=samsung    5Grach_ed=${5Grach_ed_list}[${item}]
        ...    4G_check=True    ue_index=${item}
        run keyword if  not ${attach_status}==${True}    UE attach agin    ue_index=${item}
    END

detach multi power ue
    [Arguments]    ${ue_num}=${4}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${ue_index}]
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${ue_index}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${ue_index}]


stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index}    ${protocol}=tcp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=samsung    iperf_type=via_command
    ...    protocol=${protocol}    iperf_port= ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${tl.ues[${ue_index}].iperf_details.port}

Capture event trace and bip simultaneously
    [Documentation]    Author: Ren Biyao
    [Arguments]    ${gnb_index}=0    ${local_log_folder}=${TS_CASE_LOG_PATH}    ${asik_alias}=ASIK Master

    ${tput_log_file_path_gnb}    Start tput log capture    gnb_index=${gnb_index}    asik_alias=${asik_alias}
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts with retry
    Start TTI trace log capturing
    sleep    1s
    ${list_bip_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=${asik_alias}
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${local_log_folder}
    @{saved_tput_file_list}    Split tput log to ul and dl files    gnb_index=${gnb_index}    asik_alias=${asik_alias}
    ...    tput_log_file_path_gnb_combined=${tput_log_file_path_gnb}
    &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
    ...    local_log_folder=${local_log_folder}    asik_alias=${asik_alias}
    &{ul_tput}    check_average_throughput.get_tput_info_for_l2lo    tput_file=${dict_local_tput_file_path['UL_L2LO']}
    &{dl_tput}    check_average_throughput.get_tput_info_for_l2lo    tput_file=${dict_local_tput_file_path['DL_L2LO']}
    Log to console    ul_tput:${ul_tput}, dl_tput:${dl_tput}
    [Teardown]  Run keyword and ignore error    Run keywords    check_average_throughput.stop_tput_aasyslog_capturing
    ...    asik_alais=${asik_alias}    AND    Stop TTI trace log capturing    AND
    ...    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
