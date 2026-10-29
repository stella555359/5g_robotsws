*** Settings ***
Documentation    This is for feature CB09109 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiangsheng.chu@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008015/Resources/CB008015_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007737/Resources/CB007737_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009109/Resources/CB009109_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/UEs/MTK_common_keywords.robot


*** Keywords ***
CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer
    [Arguments]    ${pcell_index}         ${gnb_index}=${0}
#    ...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
#    ...            ${wireshark_capture_interface}=-i any '((sctp) and ${filter_ports})' -s 0
    ...            ${wireshark_capture_interface}=-i any -s 0 -p
    ...            ${asik_connection_alias}=ASIK Master
    run keyword and ignore error    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${pcell_index}
    ${ue_type}    translate_power_ue_type_from_testline
    power_ue.Prepare UE    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    Sleep    5sec
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    ${cpif_first_nrdrx}    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${False}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${True}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_scell_tput=${False}
    ...                            wireshark_log_prefix=cpif_first_nrdrx
    ...                            check_pcell_tput_type=not_peak
    ...                            is_need_stop_traffic=${False}
    ...                            interface=${wireshark_capture_interface}
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=11       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=5       target_LongCycleStartOffset=3
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=cpif_first_vonr_nrdrx
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_capture_interface}
    Make Vonr Call For Qualcomm
    sleep    5s
    ${cpif_first_vonr_nrdrx}    Run Keyword And Continue On Failure
    ...                                Stop tcpdump log collection    tcpdump_collector_name=cpif_first_vonr_nrdrx
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_vonr_nrdrx}
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=9       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=4       target_LongCycleStartOffset=3
    Get DRX release in wireshark       cpif_log_path=${cpif_first_vonr_nrdrx}
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=first_hangup_vonr_nrdrx
#    ...    asik_connection_alias=${asik_connection_alias}
#    ...    gnb_index=${gnb_index}
#    ...    options=${wireshark_capture_interface}
    Hang Up Vonr Call For Qualcomm
    sleep    5s
#    ${first_hangup_vonr_nrdrx}    Run Keyword And Continue On Failure
#    ...                                Stop tcpdump log collection    tcpdump_collector_name=first_hangup_vonr_nrdrx
#    Get DRX release in wireshark       cpif_log_path=${first_hangup_vonr_nrdrx}
#    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
#    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
#    ...   Get DRX parameter in wireshark     cpif_log_path=${first_hangup_vonr_nrdrx}
#    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
#    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
#    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
#    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
#    ...      target_milliSeconds=7       target_InactivityTimer=11       target_HARQ_Timer=28
#    ...      target_RetransmissionTimer=5       target_LongCycleStartOffset=3
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    ${nonGbr_value}    Set Variable      MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRX-11
    ${voNR_value}      Set Variable      MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRX-10
    Modify nonGbrNrDrxDN and voNRNrDrxDN Value      pcell_index=${pcell_index}     nonGbr_value=${nonGbr_value}     voNR_value=${voNR_value}
    ${cpif_second_nrdrx}    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${False}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${True}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_scell_tput=${False}
    ...                            wireshark_log_prefix=cpif_second_nrdrx
    ...                            is_need_stop_traffic=${False}
    ...                            check_pcell_tput_type=not_peak
    ...                            interface=${wireshark_capture_interface}
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_nrdrx}
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=8       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=5       target_LongCycleStartOffset=3
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=cpif_second_vonr_nrdrx
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_capture_interface}
    Make Vonr Call For Qualcomm
    sleep    5s
    ${cpif_second_vonr_nrdrx}    Run Keyword And Continue On Failure
    ...                                Stop tcpdump log collection    tcpdump_collector_name=cpif_second_vonr_nrdrx
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_vonr_nrdrx}
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=8       target_HARQ_Timer=14
    ...      target_RetransmissionTimer=4       target_LongCycleStartOffset=3
    Get DRX release in wireshark       cpif_log_path=${cpif_second_vonr_nrdrx}
#    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=cpif_second_hangup_vonr_nrdrx
#    ...    asik_connection_alias=${asik_connection_alias}
#    ...    gnb_index=${gnb_index}
#    ...    options=${wireshark_capture_interface}
    Hang Up Vonr Call For Qualcomm
    sleep    5s
#    ${cpif_second_hangup_vonr_nrdrx}    Run Keyword And Continue On Failure
#    ...                                Stop tcpdump log collection    tcpdump_collector_name=cpif_second_hangup_vonr_nrdrx
#    Get DRX release in wireshark       cpif_log_path=${cpif_second_hangup_vonr_nrdrx}
#    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
#    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
#    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_hangup_vonr_nrdrx}
#    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
#    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
#    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
#    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
#    ...      target_milliSeconds=7       target_InactivityTimer=8       target_HARQ_Timer=28
#    ...      target_RetransmissionTimer=5       target_LongCycleStartOffset=3
    [Teardown]    run keywords    Run Keyword And Ignore Error    Stop Traffic With Power UE    AND
    ...                           Run Keyword And Ignore Error     Hang Up Vonr Call For Qualcomm

CB009109_B_02_SA_non-VONR_call_setup_when_feature_deactivate_then_activate_feature_and_setup_VoNR_Bearer
    [Arguments]    ${pcell_index}    ${gnb_index}=${0}
#    ...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
#    ...            ${wireshark_capture_interface}=-i any '((sctp) and ${filter_ports})' -s 0
    ...            ${wireshark_capture_interface}=-i any -s 0 -p
    ...            ${asik_connection_alias}=ASIK Master
    run keyword and ignore error    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${pcell_index}
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    ${ue_type}    translate_power_ue_type_from_testline
    power_ue.Prepare UE    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    Sleep    5sec
    Run Keyword And Ignore Error    Enable Mobile Data
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=cpif_first_nrdrx
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_capture_interface}
    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${False}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_pcell_tput=${False}
    ...                            whether_collect_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            wireshark_log_prefix=cpif_first_nrdrx
    ...                            check_pcell_tput_type=not_peak
    ...                            is_need_stop_traffic=${False}
    ...                            interface=${wireshark_capture_interface}
    Make Vonr Call For Qualcomm
    sleep    5s
    Hang Up Vonr Call For Qualcomm
    sleep    5s
    ${cpif_first_nrdrx}    Run Keyword And Continue On Failure
    ...                                Stop tcpdump log collection    tcpdump_collector_name=cpif_first_nrdrx
    ${5QI_vaule}    Get 5QI parameter in wireshark   cpif_log_path=${cpif_first_nrdrx}
    should be equal   5    ${5QI_vaule[0][0]}
    should be equal   7    ${5QI_vaule[1][0]}
    should be equal   1    ${5QI_vaule[2][0]}
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=8       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=4       target_LongCycleStartOffset=3
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}     num=1
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=9       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=4       target_LongCycleStartOffset=3
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}     num=2
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=8       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=4       target_LongCycleStartOffset=3
    ${actual_5qi_release_list}    ${actual_drx_config_release_list}
    ...                                           Get 5QI parameter and drx config in wireshark    cpif_log_path=${cpif_first_nrdrx}
    @{actual_5qi_release_target_value}    Create list    1
    @{actual_drx_config_release_target_value}    Create list    0
    FOR    ${actual_5qi_release_value}    IN    @{actual_5qi_release_list}
        ${actual_5qi_release_value}    Remove Duplicates    ${actual_5qi_release_value}
        ${status}    Run Keyword And Return Status    List Should Contain Sub List
        ...                                                  ${actual_5qi_release_value}    ${actual_5qi_release_target_value}
        exit for loop if    ${status}
    END
    FOR    ${actual_drx_config_release_vlaue}    IN    @{actual_drx_config_release_list}
        ${actual_drx_config_release_vlaue}    Remove Duplicates    ${actual_drx_config_release_vlaue}
        ${status}    Run Keyword And Return Status
        ...          List Should Contain Sub List    ${actual_drx_config_release_vlaue}    ${actual_drx_config_release_target_value}
        exit for loop if    ${status}
    END
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    ${modify_param}    Create List
    &{actDrbDrx_param}    Create Dictionary
	...                             dist_name=NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}
	...                             parameter=actDrbDrx    value=true
	Append To List    ${modify_param}    ${actDrbDrx_param}
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_param}    timeout=900
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=cpif_second_nrdrx
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_capture_interface}
    Run Keyword And Ignore Error   csn.disconnect    connection=GNB_OAM
    Run Keyword And Ignore Error    Enable Mobile Data
    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${False}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_pcell_tput=${False}
    ...                            whether_collect_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            wireshark_log_prefix=cpif_first_nrdrx
    ...                            check_pcell_tput_type=not_peak
    ...                            is_need_stop_traffic=${False}
    ...                            interface=${wireshark_capture_interface}
    Make Vonr Call For Qualcomm
    sleep    5s
    Hang Up Vonr Call For Qualcomm
    sleep    5s
    ${cpif_second_nrdrx}    Run Keyword And Continue On Failure
    ...                                Stop tcpdump log collection    tcpdump_collector_name=cpif_second_nrdrx
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    ${5QI_vaule_list}    Get 5QI parameter in wireshark   cpif_log_path=${cpif_second_nrdrx}
    @{5QI_vaule_target_value}    Create list    5    7   1
    FOR    ${5QI_vaule}    IN    @{5QI_vaule_list}
        ${5QI_vaule}    Remove Duplicates    ${5QI_vaule}
        List Should Contain Sub List    ${5QI_vaule_target_value}    ${5QI_vaule}
    END
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_nrdrx}
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=9      target_HARQ_Timer=14
    ...      target_RetransmissionTimer=4       target_LongCycleStartOffset=7
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_nrdrx}     num=1
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=8       target_HARQ_Timer=28
    ...      target_RetransmissionTimer=5       target_LongCycleStartOffset=3
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_nrdrx}     num=2
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=11      target_HARQ_Timer=28
    ...      target_RetransmissionTimer=5    target_LongCycleStartOffset=3
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_second_nrdrx}     num=3
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=7       target_InactivityTimer=8      target_HARQ_Timer=28
    ...      target_RetransmissionTimer=5    target_LongCycleStartOffset=3
    ${actual_5qi_release_list}    ${actual_drx_config_release_list}
    ...                                                         Get 5QI parameter and drx config in wireshark     cpif_log_path=${cpif_second_nrdrx}
    @{actual_5qi_release_target_value}    Create list    1    7
    @{actual_drx_config_release_target_value}    Create list    0
    FOR    ${actual_5qi_release_value}    IN    @{actual_5qi_release_list}
        ${actual_5qi_release_value}    Remove Duplicates    ${actual_5qi_release_value}
        ${status}    Run Keyword And Return Status    List Should Contain Sub List
        ...                                  ${actual_5qi_release_target_value}    ${actual_5qi_release_value}
        exit for loop if    ${status}
    END
    FOR    ${actual_drx_config_release_vlaue}    IN    @{actual_drx_config_release_list}
        ${actual_drx_config_release_vlaue}    Remove Duplicates    ${actual_drx_config_release_vlaue}
        ${status}    Run Keyword And Return Status    List Should Contain Sub List
        ...                                    ${actual_drx_config_release_target_value}    ${actual_drx_config_release_vlaue}
        exit for loop if    ${status}
    END
#    should be equal   7    ${actual_5qi_release[0][0]}
#    should be equal   0    ${actual_drx_config_release[0][0]}
#    should be equal   1    ${actual_5qi_release[1][0]}
#    should be equal   0    ${actual_drx_config_release[1][0]}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Stop Traffic With Power UE    AND
    ...                           Run Keyword And Ignore Error     Hang Up Vonr Call For Qualcomm

CB009109_B_05_SA_VONR_call_setup_with_VoNR_Bearer_5QI-1_with_cell_level_associated_lower_priority_DRX
    [Arguments]    ${pcell_index}
#    ...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
#    ...            ${wireshark_capture_interface}=-i any '((sctp) and ${filter_ports})' -s 0
    ...            ${wireshark_capture_interface}=-i any -s 0 -p
    run keyword and ignore error    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${pcell_index}
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=0
    ${ue_type}    translate_power_ue_type_from_testline
    power_ue.Prepare UE    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    Sleep    5sec
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_first_nrdrx
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=0
    ...                                                                             du_index=0
    Run Keyword And Ignore Error    Enable Mobile Data
    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${False}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${True}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_pcell_tput=${False}
    ...                            whether_collect_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            wireshark_log_prefix=cpif_first_nrdrx
    ...                            check_pcell_tput_type=not_peak
    ...                            is_need_stop_traffic=${False}
    ...                            interface=${wireshark_capture_interface}
    Make Vonr Call For Qualcomm
    sleep    5s
    Hang Up Vonr Call For Qualcomm
    sleep    5s
    ${cpif_first_nrdrx}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                                                          tcpdump_collector_name=cpif_first_nrdrx
    ...                            target_dir=${TS_CASE_LOG_PATH}    gnb_index=0    du_index=0
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    ${5QI_vaule_list}    Get 5QI parameter in wireshark   cpif_log_path=${cpif_first_nrdrx}
    @{5QI_vaule_target_value}    Create list    5    7   1
    FOR    ${5QI_vaule}    IN    @{5QI_vaule_list}
        ${5QI_vaule}    Remove Duplicates    ${5QI_vaule}
        List Should Contain Sub List    ${5QI_vaule_target_value}    ${5QI_vaule}
    END
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}     num=0
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=8       target_InactivityTimer=9      target_HARQ_Timer=28
    ...      target_RetransmissionTimer=4    target_LongCycleStartOffset=7
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}     num=1
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=8       target_InactivityTimer=9      target_HARQ_Timer=0
    ...      target_RetransmissionTimer=5    target_LongCycleStartOffset=7
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}     num=2
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=8       target_InactivityTimer=8      target_HARQ_Timer=14
    ...      target_RetransmissionTimer=5    target_LongCycleStartOffset=3
    ${milliSeconds}       ${InactivityTimer}       ${HARQ_TimerDL}    ${HARQ_TimerUL}
    ...   ${RetransmissionTimerDL}     ${RetransmissionTimerUL}      ${LongCycleStartOffset}
    ...   Get DRX parameter in wireshark     cpif_log_path=${cpif_first_nrdrx}     num=3
    Check DRX parameter    source_milliSeconds=${milliSeconds}        source_InactivityTimer=${InactivityTimer}
    ...                   source_HARQ_TimerDL=${HARQ_TimerDL}            source_HARQ_TimerUL=${HARQ_TimerUL}
    ...      source_RetransmissionTimerDL=${RetransmissionTimerDL}     source_RetransmissionTimerUL=${RetransmissionTimerUL}
    ...      source_LongCycleStartOffset=${LongCycleStartOffset}
    ...      target_milliSeconds=8       target_InactivityTimer=9      target_HARQ_Timer=0
    ...      target_RetransmissionTimer=5    target_LongCycleStartOffset=7
    ${actual_5qi_release_list}    ${actual_drx_config_release_list}
    ...                                                           Get 5QI parameter and drx config in wireshark     cpif_log_path=${cpif_first_nrdrx}
#    should be equal   7    ${actual_5qi_release[0][0]}
#    should be equal   0    ${actual_drx_config_release[0][0]}
#    should be equal   1    ${actual_5qi_release[1][0]}
#    should be equal   0    ${actual_drx_config_release[1][0]}
    @{actual_5qi_release_target_value}    Create list    1    7
    @{actual_drx_config_release_target_value}    Create list    0
    FOR    ${actual_5qi_release_value}    IN    @{actual_5qi_release_list}
        ${actual_5qi_release_value}    Remove Duplicates    ${actual_5qi_release_value}
        ${status}    Run Keyword And Return Status    List Should Contain Sub List
        ...                                           ${actual_5qi_release_target_value}    ${actual_5qi_release_value}
        exit for loop if    ${status}
    END
    FOR    ${actual_drx_config_release_vlaue}    IN    @{actual_drx_config_release_list}
        ${actual_drx_config_release_vlaue}    Remove Duplicates    ${actual_drx_config_release_vlaue}
        ${status}    Run Keyword And Return Status    List Should Contain Sub List
        ...                                           ${actual_drx_config_release_target_value}    ${actual_drx_config_release_vlaue}
        exit for loop if    ${status}
    END
    [Teardown]    run keywords    Run Keyword And Ignore Error    Stop Traffic With Power UE    AND
    ...                           Run Keyword And Ignore Error     Hang Up Vonr Call For Qualcomm

CB009109_B_10_SA_inter_frequency_ANR_HO_with_parameter_fallback
    [Arguments]    ${pcell_index}         ${gnb_index}=${0}
#    ...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
#    ...            ${wireshark_capture_interface}=-i any '((sctp) and ${filter_ports})' -s 0
    ...            ${wireshark_capture_interface}=-i any -s 0 -p
    ...            ${asik_connection_alias}=ASIK Master
    run keyword and ignore error    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${pcell_index}
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=127   RU_id=4
    ${ue_type}    translate_power_ue_type_from_testline
    power_ue.Prepare UE    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    Sleep    5sec
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=cpif_first_nrdrx
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=${wireshark_capture_interface}
    Run Keyword And Ignore Error    Enable Mobile Data
    Make_L3_Call_And_Check_Tput
    ...                            is_do_require_ue=${False}
    ...                            ul_data_transfer=120M
    ...                            dl_data_transfer=1400M
    ...                            is_wireshark_log_capture=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            check_pcell_tput=${False}
    ...                            whether_collect_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            wireshark_log_prefix=cpif_first_nrdrx
    ...                            check_pcell_tput_type=not_peak
    ...                            is_need_stop_traffic=${False}
    ...                            interface=${wireshark_capture_interface}
    Run Keyword And Ignore Error    Stop Traffic With Power UE    is_detach=${False}
    Update Ho_pcell_index to notbarred    ho_pcell_index=4
    ${pa_value_cell3}    Set Variable If    '${stream}'=='SBTS00'    20    0
    ${pa_value_cell4}    Set Variable If    '${stream}'=='SBTS00'    42    22
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_value_cell3}   RU_id=4
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_value_cell4}   RU_id=3
    sleep    15s
    ${cpif_first_nrdrx}    Run Keyword And Continue On Failure
    ...                                Stop tcpdump log collection    tcpdump_collector_name=cpif_first_nrdrx
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Continue On Failure
    ...           Check CGI For ANR From Wireshark    log_path=${cpif_first_nrdrx}    drxLongCycle_value=640ms     drxOnDurationTimer_value=10ms
    Run Keyword And Continue On Failure    Check DRX Infor From CPIF    cpif_log_path=${cpif_first_nrdrx}
    ${actual_5qi_release_list}    ${actual_drx_config_release_list}
    ...                           Get 5QI parameter and drx config in wireshark     cpif_log_path=${cpif_first_nrdrx}
    @{actual_5qi_release_target_value}    Create list    7
    @{actual_drx_config_release_target_value}    Create list    0
    FOR    ${actual_5qi_release_value}    IN    @{actual_5qi_release_list}
        ${actual_5qi_release_value}    Remove Duplicates    ${actual_5qi_release_value}
        ${status}    Run Keyword And Return Status    List Should Contain Sub List
        ...                                                  ${actual_5qi_release_value}    ${actual_5qi_release_target_value}
        exit for loop if    ${status}
    END
    FOR    ${actual_drx_config_release_vlaue}    IN    @{actual_drx_config_release_list}
        ${actual_drx_config_release_vlaue}    Remove Duplicates    ${actual_drx_config_release_vlaue}
        ${status}    Run Keyword And Return Status
        ...          List Should Contain Sub List    ${actual_drx_config_release_vlaue}    ${actual_drx_config_release_target_value}
        exit for loop if    ${status}
    END
    ${5QI_vaule_list}    Get 5QI parameter in wireshark   cpif_log_path=${cpif_first_nrdrx}
    @{5qi_target_value}    Create list    5    7
    FOR    ${5qi_value}    IN    @{5QI_vaule_list}
        ${5qi_value}    Remove Duplicates    ${5qi_value}
        List Should Contain Sub List    ${5qi_target_value}    ${5qi_value}
    END
    [Teardown]    run keywords    Run Keyword And Ignore Error    Stop Traffic With Power UE    AND
    ...                           Run Keyword And Ignore Error     Hang Up Vonr Call For Qualcomm




