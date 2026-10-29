*** Settings ***
Documentation
...   This is for  TA common keywords
...   squad group: MMW_SG1
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./5GC000721_variables.robot
Library     OperatingSystem
Variables   ../TestDate/5GC000721_SCF.py
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Library     ../../FGCR-7660/Resources/FGCR-7660_verify_throughput_form_gNB.py    WITH NAME    721
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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource     ../../5GC001911-CA/resource/5GC001911-CA_keywords.robot


*** Keywords ***
check physCellId
    [Documentation]    author: Fang ludan
    ...     Description:check physCellId in X2log
    [Arguments]    ${x2ap_log}     ${physCellId_exp}
    ${filtered_packets}    pcap.load_pcap_file    pcap_file=${x2ap_log}     command_template=${X2AP_COMMAND}
    ${request}      pcap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)
    ${cellId}      Get field value by xpath       packets=${request}    field_name=.//nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId

    should be equal as integers    ${cellId[0]}      ${physCellId_exp}


#Get field value by xpath
#    [Arguments]    ${packets}    ${field_name}    ${attribute_name}=show
#    ${values}    pcap.get_field_value_by_xpath    pdml_list=${packets}    xpath=${field_name}    attribute_name=${attribute_name}
#    [Return]    ${values}



#check tput with 721
#    Documentation]    author: Fang ludan
#    ...     Description:check tput with 721
#    [Arguments]    ${x2ap_log}     ${physCellId_exp}


Verify peak tput of each cell for 721
     [Documentation]    Author: Fang ludan
    ...                Description: Check ul and dl peak throughput of each cells
    ...                dl_cell can be 1 or 1,2,3,4,5,6,7,8
    ...                ul_cell can be 1 or 1,2
    ...                :para${duration} is the whole time for checking tput. In this case, 600s will be the total time.
    [Arguments]    ${dl_cell}   ${ul_cell}  ${expected_ul_tput}   ${expected_dl_tput_max}    ${expected_dl_tput_min}
    ...    ${dl_num_exp}   ${ul_num_exp}
    ...    ${duration_time_for_once}=60    ${duration}=${DURATION_TIME}    ${local_log_folder}=${TS_CASE_LOG_PATH}
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
        @{saved_tput_file_list}    Run keyword and continue on failure    Retry log capturing if file content is empty
        ...    duration=${duration_time_for_once}
        ${dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
        ...    local_log_folder=${Tput_records_dir}
        ${ul_avg_peak_tput_info}
        ...    721.get_details_of_peak_tput_each_cells   tput_file=${dict_local_tput_file_path['UL_L2LO']}
        ...    list_cell=${list_ul_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
        ${dl_avg_peak_tput_info}
        ...    721.get_details_of_peak_tput_each_cells   tput_file=${dict_local_tput_file_path['DL_L2LO']}
        ...    list_cell=${list_dl_cell}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
        ${ul_tput_num}     ${ul_tput_sum}   get ul tput num and sum      ul_avg_peak_tput_info=${ul_avg_peak_tput_info}
        ${dl_tput_num}     ${dl_tput_sum}   get dl tput num and sum      dl_avg_peak_tput_info=${dl_avg_peak_tput_info}
        ${check_peak_tput_status}    Run keyword and return status    run keywords   should be true    ${ul_tput_sum}>10  AND
        ...   Should be true    ${dl_tput_sum}>20     AND   Should be true     ${dl_tput_sum}<=${expected_dl_tput_max}
        ${check_tput_num_status}    Run keyword and return status    run keywords    Should be true     ${ul_tput_num}>=${ul_num_exp}  AND
        ...   Should be true     ${dl_tput_num}>=${dl_num_exp}
        Run keyword and continue on failure    Should be true    ${check_peak_tput_status}
        Run keyword and continue on failure    Should be true    ${check_tput_num_status}
        Run keyword if  ${check_peak_tput_status}==${False} and ${check_tput_num_status}==${False}
        ...    Capture event trace and bip simultaneously     local_log_folder=${Tput_records_dir}
        ${current_time_stamp}    DateTime.get current date    result_format=epoch    exclude_millis=True
        Exit for loop if    ${current_time_stamp}>${end_time}
    END
