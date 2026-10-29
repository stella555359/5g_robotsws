*** Settings ***
Documentation     author: Annie Hu
...               Group: HGZ_SG5
...               contact: Annie.hu@nokia-sbell.com


Resource          ../../5GC002118/Resource/5GC002118_common_KW.robot
Variables         ../TestData/Trunk_scf_modify.py

*** Variables ***
${frame_structure}            1116_0ms_GP1_A8
${band}                      100
${case_rate}                0.7

*** Keywords ***
"${Step}" Modify parameters for Feature
    log to console    \n"${Step}": Modify parameters for Feature
    Get Modify SCF Params And Expected Tput
    #Modify SCF Params And Commission      ${Modify_Params}
    ##Modify SCF and Wait gnb Onair
    #COAM Wait For Gnb Ready And Cell Setup    timeout=15 min

Get Modify SCF Params And Expected Tput
    log to console    \n***Get Modify Params And Expected Tput***
    #${program}    Get program version based on stream version
    #import variables  ${CURDIR}/variable/frame_structure_variables_${program}.py
    ${Modify_Params}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Modify_Params
    ${Peak_Tput_DL}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Peak_Tput_DL
    ${Peak_Tput_UL}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Peak_Tput_UL
    ${Expect_Rate}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Expect_Rate
    ${Duration}  get from dictionary  ${Band_Tput_${band}_${frame_structure}}  Duration
    set test variable  ${Modify_Params}
    set test variable  ${Duration}
    #${status}  ${output}  run keyword and ignore error  variable should exist  ${rate_for_stream}
    #${case_rate}    run keyword if  '${status}'=='PASS'  get from dictionary  ${rate_for_stream}  ${program}
    #...                       ELSE  set variable  peak
    ${actual_rate}      set variable if      '${case_rate}'=='peak'    ${Expect_Rate}    ${case_rate}
    ${Tput_DL}  ${Tput_UL}  ${Expect_Tput_DL}  ${Expect_Tput_UL}  Calculate Send Tput And Expected Tput    ${Peak_Tput_DL}
    ...    ${Peak_Tput_UL}  ${actual_rate}
    set test variable  ${Tput_DL}
    set test variable  ${Tput_UL}
    set test variable  ${Expect_Tput_DL}
    set test variable  ${Expect_Tput_UL}
    set test variable  ${actual_rate}



L3 Call And Check Peak Throughput
     log to console    \n***L3 Call And Check Peak Throughput***
     ${status}    set variable
     FOR  ${i}  IN RANGE  ${3}
	    ${status}  run keyword and return status     L3 Call And Check Throughput  dl_tp=${Tput_DL}  ul_tp=${Tput_UL}
	     ...        duration=${Duration}  dl_exp=${Expect_Tput_DL}  ul_exp=${Expect_Tput_UL}   actual_rate=${actual_rate}
	    exit for loop if    ${status}
     END
	 run keyword if      not ${status}    FAIL


L3 Call And Check Throughput
    [Arguments]  ${4G_check}=${False}    ${dl_tp}=300M  ${ul_tp}=100M    ${duration}=${30}
    ...    ${dl_exp}=60    ${ul_exp}=20    ${actual_rate}=0.1
    ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    Teardown the Aasyslog save progress
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=${4G_check}
    ${traffic_duration}  evaluate  ${duration}*10+100
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${traffic_duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${traffic_duration}
#    ${dl_status}  ${output}  run keyword and ignore error  power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_exp}    sample=${duration}    start_offset=${duration}
#    ${ul_status}  ${output}  run keyword and ignore error  power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_exp}    sample=${duration}    start_offset=${duration}
    Verify tput from GNB within duration and record data to csv    total_time=60    exp_dl_tput=${dl_exp}
    ...    exp_ul_tput=${ul_exp}    interval=10    duration_time_for_once=200s
    ...    tput_percentage=${actual_rate}    is_need_to_capture_log=${False}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
#    run keyword if  '${dl_status}'=='FAIL' or '${ul_status}'=='FAIL'  FAIL  throughput are less than expect
    [Teardown]  run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}


Check Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ${current_val}    Get Parameter via webUI     dist_name=${dist_name}
    ...                                           filter_param=${filter_param}
    ...                                           p_name=${p_name}
    should be equal    ${current_val}    ${expected_val}


Change Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ${errors}    run keyword if  not '${current_val}'=='${expected_val}'
    ...                     Set Parameter value via webUI     expected_val=${expected_val}
    ...                                                       dist_name=${dist_name}
    ...                                                       filter_param=${filter_param}
    ...                                                       p_name=${p_name}
    ...                                                       is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                       need_active=${need_active}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    Run keyword if    ${need_active}==${True}
    ...    should be equal    ${current_val}    ${expected_val}
    [Return]    ${current_val}    ${errors}
