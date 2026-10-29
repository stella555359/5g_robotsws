*** Settings ***
Documentation    This is for CB009109 common keywords.
...              Please do not modify the file without notification to author
...              Author: xiangsheng.chu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Variables   CB009109_variables.py

*** Variables ***

*** Keywords ***
Get DRX parameter in wireshark
    [Arguments]    ${cpif_log_path}     ${num}=0
    ${filter_expression}    Catenate    nr-rrc.drx_Config == 1 && nr-rrc.criticalExtensions == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_milliSeconds}    pcap.get_field_value    field_name=nr-rrc.milliSeconds
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_InactivityTimer}    pcap.get_field_value    field_name=nr-rrc.drx_InactivityTimer
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_HARQ_TimerDL}    pcap.get_field_value    field_name=nr-rrc.drx_HARQ_RTT_TimerDL
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_HARQ_TimerUL}    pcap.get_field_value    field_name=nr-rrc.drx_HARQ_RTT_TimerUL
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
     ${actual_RetransmissionTimerDL}    pcap.get_field_value    field_name=nr-rrc.drx_RetransmissionTimerDL
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_RetransmissionTimerUL}    pcap.get_field_value    field_name=nr-rrc.drx_RetransmissionTimerUL
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_LongCycleStartOffset}    pcap.get_field_value    field_name=nr-rrc.drx_LongCycleStartOffset
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${source_milliSeconds}    Set Variable   ${actual_milliSeconds[${num}][0]}
    ${source_InactivityTimer}    Set Variable   ${actual_InactivityTimer[${num}][0]}
    ${source_HARQ_TimerDL}    Set Variable   ${actual_HARQ_TimerDL[${num}][0]}
    ${source_HARQ_TimerUL}    Set Variable   ${actual_HARQ_TimerUL[${num}][0]}
    ${source_RetransmissionTimerDL}    Set Variable   ${actual_RetransmissionTimerDL[${num}][0]}
    ${source_RetransmissionTimerUL}    Set Variable   ${actual_RetransmissionTimerUL[${num}][0]}
    ${source_LongCycleStartOffset}    Set Variable   ${actual_LongCycleStartOffset[${num}][0]}
    [Return]     ${source_milliSeconds}       ${source_InactivityTimer}       ${source_HARQ_TimerDL}    ${source_HARQ_TimerUL}
    ...      ${source_RetransmissionTimerDL}     ${source_RetransmissionTimerUL}      ${source_LongCycleStartOffset}

Check DRX parameter
    [Arguments]    ${source_milliSeconds}       ${source_InactivityTimer}       ${source_HARQ_TimerDL}    ${source_HARQ_TimerUL}
    ...      ${source_RetransmissionTimerDL}     ${source_RetransmissionTimerUL}      ${source_LongCycleStartOffset}
    ...      ${target_milliSeconds}       ${target_InactivityTimer}       ${target_HARQ_Timer}
    ...      ${target_RetransmissionTimer}       ${target_LongCycleStartOffset}
    should be equal   ${source_milliSeconds}    ${target_milliSeconds}
    should be equal   ${source_InactivityTimer}    ${target_InactivityTimer}
    should be equal   ${source_HARQ_TimerDL}    ${target_HARQ_Timer}
    should be equal   ${source_HARQ_TimerUL}    ${target_HARQ_Timer}
    should be equal   ${source_RetransmissionTimerDL}    ${target_RetransmissionTimer}
    should be equal   ${source_RetransmissionTimerUL}    ${target_RetransmissionTimer}
    should be equal   ${source_LongCycleStartOffset}    ${target_LongCycleStartOffset}


Modify nonGbrNrDrxDN and voNRNrDrxDN Value
    [Documentation]    Author：xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${pcell_index}    ${nonGbr_value}     ${voNR_value}   ${connection}=GNB_OAM    ${gnb_index}=0
    @{params_to_modify}    Create List
    &{nongbr_params_to_modify_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}
    ...                         parameter=nonGbrNrDrxDN    value=${nonGbr_value}
    Append To List    ${params_to_modify}    ${nongbr_params_to_modify_dict}
    &{vonr_params_to_modify_dict}    Create Dictionary    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${pcell_index}
    ...                         parameter=voNRNrDrxDN    value=${voNR_value}
    Append To List    ${params_to_modify}    ${vonr_params_to_modify_dict}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api     parameters_to_update_via_api=${params_to_modify}
    ...                                             connection=${connection}
    ...                                             timeout=${180}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get DRX release in wireshark
    [Arguments]    ${cpif_log_path}
    [Documentation]    Author：xiangsheng.chu@nokia-sbell.com
    ${filter_expression}    Catenate    nr-rrc.drx_Config == 0 && nr-rrc.criticalExtensions == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_drx_release}    pcap.get_field_value    field_name=nr-rrc.drx_Config
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_drx_release}    Set Variable   ${actual_drx_release[0][0]}
    should be equal   ${actual_drx_release}    0

Get 5QI parameter in wireshark
    [Arguments]    ${cpif_log_path}
    [Documentation]    Author：xiangsheng.chu@nokia-sbell.com
    ${filter_expression}    Catenate    nr-rrc.criticalExtensions == 0 && nas-5gs.sm.5qi
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    ...           override_preference_setting=nas-5gs.null_decipher:TRUE
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_5qi_release}    pcap.get_field_value    field_name=nas-5gs.sm.5qi
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    [Return]     ${actual_5qi_release}

Get 5QI parameter and drx config in wireshark
    [Arguments]    ${cpif_log_path}
    [Documentation]    Author：xiangsheng.chu@nokia-sbell.com
    ${filter_expression}    Catenate    nr-rrc.criticalExtensions == 0 && nas-5gs.sm.5qi && nr-rrc.drx_Config
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    ...           override_preference_setting=nas-5gs.null_decipher:TRUE
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_5qi_release}    pcap.get_field_value    field_name=nas-5gs.sm.5qi
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_drx_config_release}    pcap.get_field_value    field_name=nr-rrc.drx_Config
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    [Return]     ${actual_5qi_release}     ${actual_drx_config_release}

Update Ho_pcell_index to notbarred
    [Documentation]    Author: xiangsheng.chu@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}
    ...            ${ue_mode}=SA
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${timeout}=300
    ...            ${cellBarred_value}=notBarred
    @{param_list}    Create List
    ${cellBarred}     Create Dictionary      dist_name=MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}/NRCELL-${ho_pcell_index}
    ...                                      parameter=cellBarred
    ...                                      value=${cellBarred_value}
    Append To List    ${param_list}    ${cellBarred}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}   timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check DRX Infor From CPIF
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    nr-rrc.drx_Config == 1 && nr-rrc.criticalExtensions == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    &{drx_vaule_from_cpif}    Create Dictionary
    @{drx_dield_list}    Create list     milliSeconds    drx_InactivityTimer    drx_HARQ_RTT_TimerDL
    ...                                         drx_HARQ_RTT_TimerUL    drx_RetransmissionTimerDL
    ...                                         drx_RetransmissionTimerUL    drx_LongCycleStartOffset
    FOR    ${drx_dield}    IN    @{drx_dield_list}
        ${cpif_value_list}    pcap.get_field_value    field_name=nr-rrc.${drx_dield}    filter=${filter_expression}    pcap_parser=test0
        ${cpif_value}=  Evaluate    [x[0] for x in ${cpif_value_list}]
        Set To Dictionary   ${drx_vaule_from_cpif}    ${drx_dield}=${cpif_value}
    END
    ${len}     Get Length    ${drx_vaule_from_cpif}[drx_InactivityTimer]
    Run Keyword If    len(${drx_vaule_from_cpif}[drx_InactivityTimer])==4    Remove From List    ${CHECK_DRX_INFORMATION_LIST}    0
    log    ${CHECK_DRX_INFORMATION_LIST}
    FOR    ${index}    IN RANGE    len(${CHECK_DRX_INFORMATION_LIST})
            should be equal   ${drx_vaule_from_cpif}[milliSeconds][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_milliSeconds]
            should be equal   ${drx_vaule_from_cpif}[drx_InactivityTimer][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_InactivityTimer]
            should be equal   ${drx_vaule_from_cpif}[drx_HARQ_RTT_TimerDL][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_HARQ_Timer]
            should be equal   ${drx_vaule_from_cpif}[drx_HARQ_RTT_TimerUL][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_HARQ_Timer]
            should be equal   ${drx_vaule_from_cpif}[drx_RetransmissionTimerDL][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_RetransmissionTimer]
            should be equal   ${drx_vaule_from_cpif}[drx_RetransmissionTimerUL][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_RetransmissionTimer]
            should be equal   ${drx_vaule_from_cpif}[drx_LongCycleStartOffset][${index}]
            ...               ${CHECK_DRX_INFORMATION_LIST[${index}]}[target_LongCycleStartOffset]
    END
