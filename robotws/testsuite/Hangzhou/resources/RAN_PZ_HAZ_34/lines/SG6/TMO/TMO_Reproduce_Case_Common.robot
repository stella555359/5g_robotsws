*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource    ./TMO_common_keywords.robot


*** Keywords ***
Rep5605006.Parameter Modification
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_lbpsRTXSOffTime}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0',
    ...    'parameter':'lbpsRTXSOffTime','value':'120'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1',
    ...    'parameter':'lbpsRTXSOffTime','value':'120'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2',
    ...    'parameter':'lbpsRTXSOffTime','value':'120'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0','parameter':'lbpsRTXMaxLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1','parameter':'lbpsRTXMaxLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2','parameter':'lbpsRTXMaxLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0','parameter':'lbpsRTXMinLoad','value':'3'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1','parameter':'lbpsRTXMinLoad','value':'3'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2','parameter':'lbpsRTXMinLoad','value':'3'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0','parameter':'lbpsMaxLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1','parameter':'lbpsMaxLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2','parameter':'lbpsMaxLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0','parameter':'lbpsMinLoad','value':'3'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1','parameter':'lbpsMinLoad','value':'3'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2','parameter':'lbpsMinLoad','value':'3'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0','parameter':'lbpsLastCellMinLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1','parameter':'lbpsLastCellMinLoad','value':'4'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2','parameter':'lbpsLastCellMinLoad','value':'4'}
    ${lbpsPeriodList_context}    Evaluate
    ...    {'lbpsSuspended':'notSuspended','lbpsDuration':'1440','lbpsStartTimeHour':'0','lbpsStartTimeMinute':'0'}
    ${lbpsPeriodList}    Create List    ${lbpsPeriodList_context}
    FOR    ${index}    IN RANGE     6
        Append To List     ${lbpsPeriodList}    ${lbpsPeriodList_context}
    END
    ${update_lbpsPeriodList}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0',
    ...    'parameter':'lbpsPeriodList','value':${lbpsPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1',
    ...    'parameter':'lbpsPeriodList','value':${lbpsPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2',
    ...    'parameter':'lbpsPeriodList','value':${lbpsPeriodList}}
    ${lbpsCellPeriodList_context}     Evaluate
    ...    {'lbpsCellDuration':'1440','lbpsCellStartTimeHour':'0','lbpsCellStartTimeMinute':'0'}
    ${lbpsCellPeriodList}    Create List    ${lbpsCellPeriodList_context}
    ${lbpsCell_length}    Set Variable If    '${tl_prefix}'=='T283'    55
    ...                                      '${tl_prefix}'=='T813'    27
    ...                                      '${tl_prefix}'=='T284'    27
    ...                                       27
    FOR    ${index}    IN RANGE     ${lbpsCell_length}
        Append To List     ${lbpsCellPeriodList}    ${lbpsCellPeriodList_context}
    END
    ${update_lbpsCellPeriodList}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0',
    ...    'parameter':'lbpsCellPeriodList','value':${lbpsCellPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1',
    ...    'parameter':'lbpsCellPeriodList','value':${lbpsCellPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2',
    ...    'parameter':'lbpsCellPeriodList','value':${lbpsCellPeriodList}}
    ${update_a2MeashoSsbRsrpSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21',
    ...    'parameter':'a2MeashoSsbRsrpSA','value':[{'a2ThresholdhoSsbRsrpSA':'120'}]}
    ${update_a1MeashoSsbRsrpSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21',
    ...    'parameter':'a1MeashoSsbRsrpSA','value':[{'a1ThresholdhoSsbRsrpSA':'127'}]}
    ${NRHOIF_index}    Set Variable If    '${tl_prefix}'=='T080'    2
    ...                                   '${tl_prefix}'=='T813'    1
    ...                                   '${tl_prefix}'=='T284'    2
    ...                                   '${tl_prefix}'=='T283'    2
    ${ssbFrequency}    Set Variable If    '${tl_prefix}'=='T080'    520110
    ...                                   '${tl_prefix}'=='T813'    501390
    ...                                   '${tl_prefix}'=='T284'    520110
    ...                                   '${tl_prefix}'=='T283'    520110
    ${update_NRHOIF}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21/NRHOIF-${NRHOIF_index}',
    ...    'parameter':'a5MeasEnabled','value':'rsrp'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21/NRHOIF-${NRHOIF_index}',
    ...    'parameter':'ssbFrequency','value':'${ssbFrequency}'},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21/NRHOIF-${NRHOIF_index}',
    ...    'parameter':'a5MeasSsbRsrp','value':[{'a5Threshold1SsbRsrp':'120','a5Threshold2SsbRsrp':'56'}]}
    ${update_params}    catenate    ${update_lbpsRTXSOffTime},${update_lbpsPeriodList},${update_a2MeashoSsbRsrpSA},
    ...    ${update_a1MeashoSsbRsrpSA},${update_NRHOIF},${update_lbpsCellPeriodList}
    ${update_params_list}    Evaluate    [${update_params}]
    Delete CA Relation Based On CellIndex    pcell_index=301
    Delete CA Relation Based On CellIndex    pcell_index=21
    Update Params Through RestApi    params_need_to_modify=${update_params_list}

Rep5605012.Parameter Modification
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    ${update_actThpDist}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actThpDist','value':'true'}
    ${update_actThpDist}     Evaluate    ${update_actThpDist}
    #only 24R3~25R1 available
    ${update_thpHistUplinkMaxRange}     Evaluate
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter':'thpHistUplinkMaxRange','value':'130000'}
    #only 24R3~25R1 available
    ${update_thpHistUplinkMinRange}     Evaluate
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter':'thpHistUplinkMinRange','value':'100'}
    ${thpHistUplinkMinRange_list}     Create List
    FOR    ${index}    IN RANGE    1    21
        ${thpHistUplinkMinRange}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1/NRPMQAP-${index}',
        ...    'parameter':'thpHistUplinkMinRange','value':'100'}
        ${thpHistUplinkMinRange}    Evaluate    ${thpHistUplinkMinRange}
        Append To List       ${thpHistUplinkMinRange_list}      ${thpHistUplinkMinRange}
    END
    #only 24R3~25R1 available
    ${update_thpHistScale}     Evaluate
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter':'thpHistScale','value':'logarithmic'}
    ${thpHistScale_list}     Create List
    FOR    ${index}    IN RANGE    1    21
        ${thpHistScale}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1/NRPMQAP-${index}',
        ...    'parameter':'thpHistScale','value':'logarithmic'}
        ${thpHistScale}     Evaluate    ${thpHistScale}
        Append To List       ${thpHistScale_list}      ${thpHistScale}
    END
    ${durationThresDiscardUl_list}     Create List
    FOR    ${index}    IN RANGE    1    18
        ${durationThresDiscardUl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${index}',
        ...    'parameter':'durationThresDiscardUl','value':'20'}
        ${durationThresDiscardUl}     Evaluate    ${durationThresDiscardUl}
        Append To List       ${durationThresDiscardUl_list}      ${durationThresDiscardUl}
    END
    FOR    ${index}    IN RANGE    19    21
        ${durationThresDiscardUl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${index}',
        ...    'parameter':'durationThresDiscardUl','value':'20'}
        ${durationThresDiscardUl}     Evaluate    ${durationThresDiscardUl}
        Append To List       ${durationThresDiscardUl_list}      ${durationThresDiscardUl}
    END
    FOR    ${index}    IN RANGE    32   47
        ${durationThresDiscardUl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${index}',
        ...    'parameter':'durationThresDiscardUl','value':'20'}
        ${durationThresDiscardUl}     Evaluate    ${durationThresDiscardUl}
        Append To List       ${durationThresDiscardUl_list}      ${durationThresDiscardUl}
    END
    ${volThresDiscardUl_list}     Create List
    FOR    ${index}    IN RANGE    1    18
        ${volThresDiscardUl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${index}',
        ...    'parameter':'volThresDiscardUl','value':'1000'}
        ${volThresDiscardUl}     Evaluate   ${volThresDiscardUl}
        Append To List       ${volThresDiscardUl_list}      ${volThresDiscardUl}
    END
    FOR    ${index}    IN RANGE    19    21
        ${volThresDiscardUl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${index}',
        ...    'parameter':'volThresDiscardUl','value':'1000'}
        ${volThresDiscardUl}     Evaluate   ${volThresDiscardUl}
        Append To List       ${volThresDiscardUl_list}      ${volThresDiscardUl}
    END
    FOR    ${index}    IN RANGE    32    47
        ${volThresDiscardUl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${index}',
        ...    'parameter':'volThresDiscardUl','value':'1000'}
        ${volThresDiscardUl}     Evaluate   ${volThresDiscardUl}
        Append To List       ${volThresDiscardUl_list}      ${volThresDiscardUl}
    END
    ${update_thpTimeCalc}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'thpTimeCalc','value':'enabled'}
    ${update_thpTimeCalc}     Evaluate   ${update_thpTimeCalc}
    ${update_actPerCCULUserThpt}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actPerCCULUserThpt','value':'true'}
    ${update_actPerCCULUserThpt}     Evaluate    ${update_actPerCCULUserThpt}
    ${update_actBufferBasedSCellAddition}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actBufferBasedSCellAddition','value':'disabled'}
    ${update_actBufferBasedSCellAddition}     Evaluate    ${update_actBufferBasedSCellAddition}
    ${update_sCellDeactivationTimerGNB_NRCELL301}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'sCellDeactivationTimerGNB','value':'ms80'}
    ${update_sCellDeactivationTimerGNB_NRCELL301}    Evaluate   ${update_sCellDeactivationTimerGNB_NRCELL301}
    ${update_sCellDeactivationTimerGNB_NRCELL21}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-21',
    ...    'parameter':'sCellDeactivationTimerGNB','value':'ms80'}
    ${update_sCellDeactivationTimerGNB_NRCELL21}     Evaluate   ${update_sCellDeactivationTimerGNB_NRCELL21}
    ${update_miNrHighRlcCell}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1',
    ...    'parameter':'miNrHighRlcCell','value':'5min'}
    ${update_miNrHighRlcCell}      Evaluate    ${update_miNrHighRlcCell}
    ${update_drbInactivityTimerSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSA','value':'5'}
    ${update_drbInactivityTimerSA}     Evaluate   ${update_drbInactivityTimerSA}
    ${update_srbInactivityTimerSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSA','value':'10'}
    ${update_srbInactivityTimerSA}     Evaluate   ${update_srbInactivityTimerSA}
    ${update_list}      Run Keyword If    '${version}'=='24R3' or '${version}'=='25R1'    Create List
    ...    ${update_actThpDist}    ${update_thpHistUplinkMaxRange}    ${update_thpHistUplinkMinRange}
    ...    ${update_thpHistScale}     ${update_thpTimeCalc}    ${update_actPerCCULUserThpt}    ${update_actBufferBasedSCellAddition}
    ...    ${update_sCellDeactivationTimerGNB_NRCELL301}    ${update_sCellDeactivationTimerGNB_NRCELL21}
    ...    ${update_miNrHighRlcCell}     ${update_drbInactivityTimerSA}    ${update_srbInactivityTimerSA}
    ...    ELSE    Create List
    ...    ${update_actThpDist}     ${update_thpTimeCalc}    ${update_actPerCCULUserThpt}    ${update_actBufferBasedSCellAddition}
    ...    ${update_sCellDeactivationTimerGNB_NRCELL301}    ${update_sCellDeactivationTimerGNB_NRCELL21}
    ...    ${update_miNrHighRlcCell}     ${update_drbInactivityTimerSA}    ${update_srbInactivityTimerSA}
    ${update_params_list}    Combine Lists    ${update_list}    ${thpHistUplinkMinRange_list}    ${thpHistScale_list}
    ...     ${durationThresDiscardUl_list}      ${volThresDiscardUl_list}
    Update Params Through RestApi    params_need_to_modify=${update_params_list}

Reproduce_5605005.Start Brust DL UDP Traffic
    [Arguments]    ${run_script_path}=/home/vrf4_sg6/5605005/${tl_prefix}
    ...            ${test_model_sh_script_path}=/home/vrf4_sg6/5605005/${tl_prefix}/7UE_DL_Burst/
    ${app_ip}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.addr}
    ${app_user}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.username}
    ${app_pwd}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.password}
    csn.connect to    hostname=${app_ip}    username=${app_user}    password=${app_pwd}    alias=appserver
    log to console    start multi-ue dl burst test
    ${run_all_sh_path}    Join Path    ${run_script_path}    run_all.sh
    csn.send command
    ...    command=sh ${run_all_sh_path} ${test_model_sh_script_path}
    ...    connection=appserver
#    ${pid_txt}    Join Path    ${run_script_path}    pids.txt
#    File Should Exist    ${pid_txt}    msg=File pids.txt exists not gernerated in ${run_script_path},start burst scripts failed.

Reproduce_5605005.Stop Brust DL UDP Traffic
    [Arguments]    ${run_script_path}=/home/vrf4_sg6/5605005/${tl_prefix}
    ${app_ip}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.addr}
    ${app_user}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.username}
    ${app_pwd}    Set Variable    ${tl.ues[${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}].iperf_details.ssh_connection_details.password}
    csn.connect to    hostname=${app_ip}    username=${app_user}    password=${app_pwd}    alias=appserver
    log to console    stop multi-ue dl burst test
    ${stop_all_sh_path}    Join Path    ${run_script_path}    stop_all.sh
    csn.send command
    ...    command=sh ${stop_all_sh_path}
    ...    connection=appserver
    [Teardown]    Csn.disconnect    connection=appserver

Reproduce_5605005.PA Value Setting FOR TL282
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${3}
    @{channels}    Set Variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuators[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuators[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN RANGE    1    13
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(10)
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        sleep   5sec
    END

Reproduce_5605004.PA Value Setting FOR TL282
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${3}    ${value}=110
    @{channels}    Set Variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable     ${tl.attenuators[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuators[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    FOR    ${index}    IN RANGE    1    5
        ${index}    Convert To Integer    ${index}
        ${value}    Evaluate    float(${value})
        Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5X    5sec   attenuator.set_attenuation
        ...    port=${index}   value=${value}   attenuator_device=${configured_attenuator}    confirm=True
        sleep   5sec
    END

Reproduce_5605005.PA Value Setting
    Run Keyword If    '${tl_prefix}'=='T080'   Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=3
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=6
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    Run Keyword If    '${tl_prefix}'=='T284'    Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=2   ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    Run Keyword If    '${tl_prefix}'=='T073'    Reproduce_5605005_TL073.PA Value Setting
    Run Keyword If    '${tl_prefix}'=='T813'   Run Keywords    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    pa_off_value=${50}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=3
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Modify PA Value Setting For Required RU    modify_ru_id=6
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}



RepCase_5605005_CaseSetUp
    Run Keyword If    '${tl_prefix}'=='T073'    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
    Run Keyword If    '${tl_prefix}'=='T080'    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
    Run Keyword If    '${tl_prefix}'=='T284'    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}
    ...    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}

RepCase_5605005_CaseTeardown
    Run Keyword If    '${tl_prefix}'=='T073'   Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${False}    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T080'     Run Keyword And Continue On Failure
    ...     SetUp.Precondition For First gNB   is_commission=${False}    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T284'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${False}    check_rollback_is_needed=${False}

RepCase_5605005_rollback_commission
    Run Keyword If    '${tl_prefix}'=='T073'    Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T080'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}
    Run Keyword If    '${tl_prefix}'=='T284'     Run Keyword And Continue On Failure
    ...    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

TMO.Start BIP Capture
    [Arguments]    ${nr_phy_cell_ids}=813    ${capture_time}=10
    ...            ${target_file_name}=l1l2bip_log    ${gnb_index}=0    ${target_dir}=${TS_CASE_LOG_PATH}
    ${trace_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${target_file_name}    Set Variable    ${target_file_name}_${trace_timestamp}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
    ...                                          nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                          gnb_index=${gnb_index}
    sleep    ${capture_time}
    ${bip_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...                                                                 target_dir=${target_dir}
    [Return]    ${bip_log_path[0]}
    [Teardown]    Run Keyword And Ignore Error    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

RepCase_5605006.Get PatternId Range From Syslog
    [Arguments]    ${syslog_start_time}    ${syslog_end_time}    ${syslog_path}=/tmp/btslog2
    ${syslog_start_time}  	DateTime.Convert Date 	${syslog_start_time}     epoch
    ${syslog_end_time}  	DateTime.Convert Date 	${syslog_end_time}     epoch
    @{syslog_files_for_case}   Create List
    ${string_files} = 	Run 	cd ${syslog_path}&&find -name "SYSLOG_*.LOG"
    ${files}   Split String    ${string_files}   \n
    FOR    ${file}    IN    @{files}
        ${syslog_modtime} = 	OperatingSystem.Get Modified Time 	${syslog_path}//${file}    epoch
        Run Keyword If    ${syslog_end_time} > ${syslog_modtime} > ${syslog_start_time}    Copy Files
        ...    ${syslog_path}//${file}   	${TS_CASE_LOG_PATH}
        Run Keyword If    ${syslog_end_time} > ${syslog_modtime} > ${syslog_start_time}
        ...    Append To List     ${syslog_files_for_case}    ${syslog_path}//${file}
    END
    ${all_patter_in_syslog}     Create List
    FOR    ${syslog_item}    IN    @{syslog_files_for_case}
        ${empty_list}    Create List
#        ${output}    run    grep -n 'SCellParametersReq' ${syslog_item}
#        ${status}    Run Keyword And Return Status     Should Not Be Empty    ${output}
#        ${output}    Get File    ${syslog_item}
        ${output}    run    grep -n 'CellParametersReq' ${syslog_item}
        ${status}    Run Keyword And Return Status     Should Not Be Empty    ${output}
        ${patter}    Run Keyword If    ${status}    Get Regexp Matches    ${output}    "patternIdMin":(\\d+),"patternIdMax":(\\d+)   1    2
        ${all_patter_in_syslog}    Run Keyword If    ${status}    combine lists   ${all_patter_in_syslog}    ${patter}
        ...    ELSE    combine lists    ${all_patter_in_syslog}    ${empty_list}
    END
    ${all_patter_in_syslog}    Remove Duplicates    ${all_patter_in_syslog}
    log to console   all patter in syslog is : ${all_patter_in_syslog}
    Should Not Be Empty    ${all_patter_in_syslog}    msg=failed to get pattern id range from syslog
    [Return]    ${all_patter_in_syslog}


RepCase_5605006.Get PatternId From BIP
    [Arguments]    ${file_path}    ${physical_id}=813
    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
    ${filter_exp}    Run Keyword If    '${version}'=='master'
    ...    catenate    3gpp.dmrsScramblingSequenceInt == ${physical_id} && 3gpp.rnti != 65535 &&
    ...    DlData_PdschGrantL1sw.modulationOrder != 2
    ...    ELSE IF    '${version}'=='25R2'
    ...    catenate    3gpp.dmrsScramblingSequenceInt == ${physical_id} && 3gpp.rnti != 65535 &&
    ...    DlData_PdschGrantL1sw.modulationOrder != 2
    ...    ELSE
    ...    catenate    3gpp.dmrsScramblingSequenceInt == ${physical_id} && 3gpp.rnti != 65535 &&
    ...    DlData_PdschGrant.modulationOrder != 2
    ${message}    Set Variable If    '${version}'=='master'    dldata_pdschsendreql1sw
    ...                              '${version}'=='25R2'    dldata_pdschsendreql1sw
    ...                                                        dldata_pdschsendreq
    ${filed_name}    Set Variable If    '${version}'=='master'     DlData_PdschGrantL1sw.patternId_item
    ...                                 '${version}'=='25R2'     DlData_PdschGrantL1sw.patternId_item
    ...                                                            DlData_PdschGrant.patternId_item
    Setup Pcap File   file_path=${file_path}    filter=${message}
    ${patternId_values_list}    Get Field Value From PCAP    field_name=${filed_name}
    ...    filter_expression=${filter_exp}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_values_list}     Remove Duplicates    ${patternId_values_list}
    log to console    ${patternId_values_list}
    [Return]    ${patternId_values_list}

RepCase_5605006.Get Pattern Range
    [Arguments]    ${patternId_values_list_in_bip}    ${all_patter_in_syslog}
    ${max_pattern_id}    Evaluate    [max(x) for x in ${patternId_values_list_in_bip}]
    ${min_pattern_id}    Evaluate    [min(x) for x in ${patternId_values_list_in_bip}]
    ${all_pattern_id}    combine lists    ${max_pattern_id}    ${min_pattern_id}
    ${max_pattern_id}    Evaluate    max(${all_pattern_id})
    ${min_pattern_id}    Evaluate    min(${all_pattern_id})
    log to console    ${max_pattern_id}
    log to console    ${min_pattern_id}
    ${condition}    Set Variable    int(${max_pattern_id})<=int(item[1]) and int(${min_pattern_id})>=int(item[0])
    ${range_index}    Evaluate    [index for (index, item) in enumerate(${all_patter_in_syslog}) if ${condition}]
    log to console   ${range_index}
    [Return]    ${range_index}

RepCase_5605006.Check Pattern Id In Same Range
    [Arguments]    ${syslog_start_time}
    ...            ${syslog_end_time}
    ...            ${patternId_values_list_in_bip_step2}
    ...            ${patternId_values_list_in_bip_step4}
    ...            ${syslog_path}=/tmp/btslog2
    ${patter_in_syslog}    Run Keyword And Continue On Failure     RepCase_5605006.Get PatternId Range From Syslog
    ...    syslog_start_time=${syslog_start_time}
    ...    syslog_end_time=${syslog_end_time}
    ...    syslog_path=${syslog_path}
#    ${patter_in_syslog}    catenate    ('6', '10'),('21', '30'),('101', '130'),('1024', '1451'),('1452', '1879'),
#    ...    ('1880', '2284'),('2285', '2500'),('2906', '3310'),('3311', '3738'),('3739', '4166'),
#    ...    ('4167', '4571'),('4572', '4787'),('5193', '5597')
#    ${patter_in_syslog}    Run Keyword And Continue On Failure    Evaluate    [${patter_in_syslog}]
    ${physical_id}     Set Variable If    '${tl_prefix}'=='T813'    594
    ...                                       '${tl_prefix}'=='T284'    150
    ...                                       '${tl_prefix}'=='T283'    301
    ...                                       '${tl_prefix}'=='T080'    318
    ${patter_in_bip_step2}    Run Keyword And Continue On Failure    RepCase_5605006.Get PatternId From BIP
    ...    file_path=${patternId_values_list_in_bip_step2}
    ...    physical_id=${physical_id}
    ${patter_in_bip_step4}    Run Keyword And Continue On Failure    RepCase_5605006.Get PatternId From BIP
    ...    file_path=${patternId_values_list_in_bip_step4}
    ...    physical_id=${physical_id}
    ${range_index_step2}    RepCase_5605006.Get Pattern Range     patternId_values_list_in_bip=${patter_in_bip_step2}
    ...    all_patter_in_syslog=${patter_in_syslog}
    ${range_index_step4}    RepCase_5605006.Get Pattern Range     patternId_values_list_in_bip=${patter_in_bip_step4}
    ...    all_patter_in_syslog=${patter_in_syslog}
    Lists Should Be Equal    ${range_index_step2}    ${range_index_step4}
    ...    msg=pattern changed. step2 is ${patter_in_syslog[${range_index_step2}[0]]},step4 is ${patter_in_syslog[${range_index_step4}[0]]}

RepCase_5603147.Stop Traffic And Detach
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${14}    dl_port=${redcap_ue_dl_port}
    Run Keyword And Ignore Error    M60_RedCap.Stop Traffic    ue_index=${15}    dl_port=${normal_ue_dl_port}
    Run Keyword And Ignore Error    M60_RedCap.UE Detach     ue_index=${14}
    Run Keyword And Ignore Error    M60_RedCap.UE Detach     ue_index=${15}    ue_type=${normal_ue_type}

RepCase_5603147.Check Tput And Bler Per UE
    [Arguments]    ${pcell_tti_trace}     ${scell_tti_trace}
    ${ues_ul_tputs}    Run Keyword And Continue On Failure     calculate_ubler_and_ultput_for_ues
    ...    file_path=${pcell_tti_trace}    txNumer_2=2     txNumer_1=1
    ${ues_dl_tputs}    Run Keyword And Continue On Failure     calculate_dlbler_and_dltput_for_ues
    ...    file_path=${pcell_tti_trace}        txNumer_2=2     txNumer_1=1
    ${scell_ue_dl_tputs}    Run Keyword And Continue On Failure     calculate_dlbler_and_dltput_for_ues
    ...    file_path=${scell_tti_trace}    txNumer_2=2     txNumer_1=1
    ${pcell_ul_ues}    Get Dictionary Keys    ${ues_ul_tputs}
    ${ul_ues_length}    Get Length    ${pcell_ul_ues}
    Should Be True    '${ul_ues_length}'>='${2}'    msg=ul ues are not include 2 ues. actual is ${ul_ues_length} UEs.
    ${pcell_dl_ues}    Get Dictionary Keys    ${ues_dl_tputs}
    ${dl_ues_length}    Get Length    ${pcell_dl_ues}
    Should Be True    '${dl_ues_length}'>='${2}'    msg=dl ues are not include 2 ues. actual is ${ul_ues_length} UEs.
    ${pcell_ul_dict_values}    Get Dictionary Values    ${ues_ul_tputs}
    ${ues_ul_tput}     Evaluate     [float(x['tput']) for x in ${pcell_ul_dict_values}]
    sort list     ${ues_ul_tput}
    ${normal_ue_ul_tput}    Set Variable    ${ues_ul_tput[-1]}
    ${redcap_ue_ul_tput}    Set Variable    ${ues_ul_tput[-2]}
    ${ues_ul_bler}     Evaluate     [float(x['bler']) for x in ${pcell_ul_dict_values}]
    ${ul_bler}    Evaluate    max(${ues_ul_bler})
    ${ues_ul_ibler}     Evaluate     [float(x['ibler']) for x in ${pcell_ul_dict_values}]
    ${ul_ibler}    Evaluate    max(${ues_ul_ibler})
    ${pcell_dl_dict_values}    Get Dictionary Values    ${ues_dl_tputs}
    ${ues_dl_tput}     Evaluate     [float(x['tput']) for x in ${pcell_dl_dict_values}]
    sort list     ${ues_dl_tput}
    ${ues_dl_bler}     Evaluate     [float(x['bler']) for x in ${pcell_dl_dict_values}]
    ${ues_dl_ibler}     Evaluate     [float(x['ibler']) for x in ${pcell_dl_dict_values}]
    ${normal_ue_dl_tput}    Set Variable   ${ues_dl_tput[-1]}
    ${redcap_ue_dl_tput}    Set Variable   ${ues_dl_tput[-2]}
    ${scell_dict_values}    Get Dictionary Values     ${scell_ue_dl_tputs}
    ${scell_tput}     Evaluate     [float(x['tput']) for x in ${scell_dict_values}]
    ${scell_bler}     Evaluate     [float(x['bler']) for x in ${scell_dict_values}]
    ${scell_ibler}     Evaluate     [float(x['ibler']) for x in ${scell_dict_values}]
    sort list     ${scell_tput}
    ${scell_tput}    Set Variable    ${scell_tput[-1]}
    ${scell_bler}    Evaluate    max(${scell_bler})
    ${scell_ibler}    Evaluate    max(${scell_ibler})
    Run Keyword And Continue On Failure    Should Be True    ${normal_ue_dl_tput}>=${1150}
    ...    msg=cell 301 dl tput for normal ue is lower than 1150Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${redcap_ue_dl_tput}>=${133}
    ...    msg=cell 301 dl tput for normal ue is lower than 135Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${normal_ue_ul_tput}>=${122}
    ...    msg=cell 301 ul tput for redcap ue is lower than 122Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${redcap_ue_ul_tput}>=${11}
    ...    msg=cell 301 ul tput for redcap ue is lower than 11Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${ul_bler}<=${0.02}    msg=pcell 301 bler is more than 2%
    Run Keyword And Continue On Failure    Should Be True    ${ul_ibler}<=${0.02}    msg=pcell 301 ibler is more than 2%
    Run Keyword And Continue On Failure    Should Be True    ${scell_tput}>=${1130}    msg=scell 311 tput is lower than 1130Mbps.
    Run Keyword And Continue On Failure    Should Be True    ${scell_bler}<=${0.02}    msg=scell 311 bler is more than 2%
    Run Keyword And Continue On Failure    Should Be True    ${scell_ibler}<=${0.02}    msg=scell 311 ibler is more than 2%

RepCase_5605003.Modify weightForSCellSelection
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    ${list_cells_for_weight50}    Create List    ${1}    ${2}    ${3}
    ${list_cells_for_weight1}    Create List    ${11}    ${12}    ${13}    ${41}    ${42}    ${43}    ${14}    ${15}    ${16}
    ${list_cells_for_weight10}    Create List    ${21}    ${22}    ${23}
    ${list_cells_for_weight100}    Create List    ${301}    ${302}    ${303}    ${311}    ${312}    ${313}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_params}    Create List
    FOR    ${cell_index}    IN    @{list_cells_for_weight50}
        ${weightForSCellSelection}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'weightForSCellSelection','value':'50'}
        ${update_param}    Evaluate    [${weightForSCellSelection}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    FOR    ${cell_index}    IN    @{list_cells_for_weight1}
        ${weightForSCellSelection}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'weightForSCellSelection','value':'1'}
        ${update_param}    Evaluate    [${weightForSCellSelection}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    FOR    ${cell_index}    IN    @{list_cells_for_weight10}
        ${weightForSCellSelection}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'weightForSCellSelection','value':'10'}
        ${update_param}    Evaluate    [${weightForSCellSelection}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    FOR    ${cell_index}    IN    @{list_cells_for_weight100}
        ${weightForSCellSelection}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
        ...    'parameter':'weightForSCellSelection','value':'100'}
        ${update_param}    Evaluate    [${weightForSCellSelection}]
        ${update_params}    Combine Lists   ${update_params}    ${update_param}
    END
    Update Params Through RestApi    params_need_to_modify=${update_params}    connection=${connection}    gnb_index=${gnb_index}

#--------  Test Case Steps -------#
TestCase.Reproduce_5605004
#    Modify weightForSCellSelection
#    Log to console    INFO:--start to config relation cells--
#    Configure Relation Cells
#    Log to console    INFO:--start to disable 9531 function--
#    ${version}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Run Keyword If    '${version}'=='24R2' or '${version}'=='24R1'    Disable 9531 Function For 24R2
#    ...    ELSE    Disable 9531 Function
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    ${report_timestamps}    Create List
    log to console  INFO:--generate source cell and target cell info--
    ${source_cell}    Set Variable    ${PCELL_INDEX}
    ${target_cell}    Set Variable    ${case_params.get('inter_gnb_ho_cell')}
#    ${source_cell_info}     Set Variable    ${SOURCE_CELL_MAPPING[${source_cell}]}
#    ${target_cell_info}     Set Variable    ${TARGET_CELL_MAPPING[${target_cell}]}
#    ${source_cell_ru_index}    Set Variable    ${source_cell_info['ru_index_mapping']}
#    ${target_cell_ru_index}    Set Variable    ${target_cell_info['ru_index_mapping']}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    Connect to gnb coam via ssl    connection=GNB_OAM1    gnb_index=1
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${target_cell}
    ...    connection=GNB_OAM1    timeout=300
    Run Keyword And Continue On Failure    Run Keyword If    '${ue_type}'=='qct_dx50'
    ...    Procedures.Check network mode    ue_index=${used_ue_index}
    log to console  INFO:--start to set PA value for source and target cell--
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...                                        ue_index=${used_ue_index}
    PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
    ...                                              gnb_id=${1}
    ...                                              pa_value=${127}
    log to console  INFO:--start trigger inter-gnb handover process for 3 rounds--
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${start_time_syslog}    Get Syslog Formatted Time
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Sleep  10sec
    Connect to Common Unit Master     alias=ASIK Master1   gnb_index=${1}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=target_cprt_${timestamp}
    ...    tcpdump_collector_name=target_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master1
    ...    gnb_index=${1}
    ...    du_index=0
    Sleep  10sec
    Get Syslog Start Time
    ${sleep_seconds}    Caculate timeToSleep Before Next Counters Period
    log to console    INFO:-- need to sleep ${sleep_seconds} before next counter start --
    Sleep    ${sleep_seconds}sec
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    Add Time To Date    ${call_start_time}    -301    exclude_millis=true
    FOR    ${round}    IN RANGE    ${3}
        log to console  INFO:-- start to attach for UE-1 ROUND-${round} --
        log to console  INFO:--restore PA value ROUND-${round} --
        PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
        ...                                              gnb_id=${1}
        ...                                              pa_value=127
        Modify PA Value Setting For Required RU    modify_ru_id=0
        ...                                        ue_index=${used_ue_index}
#        Run Keyword If    '${tl_prefix}'=='T073'    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${used_ue_index}
#        ...    ELSE IF    '${tl_prefix}'=='T080'    Spark_common_keywords.Start UE Attach in X65 multi UE x65
#        ...                                         ue_index=${used_ue_index}
#        Sleep  2sec
        power_ue.UE Attach    ue_type=${ue_type}    ue_index=${used_ue_index}
        log to console  INFO:--start to ping traffic ROUND-${round}--
#        Run Keyword If    '${tl_prefix}'=='T073'    Start Ping Traffic    ue_index=${used_ue_index}
#        ...    ELSE IF    '${tl_prefix}'=='T080'    Start Ping Traffic For Spark    ue_index=${used_ue_index}
        Start Ping Traffic    ue_index=${used_ue_index}
        Sleep   8sec
        log to console  INFO:--trigger inter-gnb handover for ROUND-${round}--
        ${target_pa_value}     Set Variable If    '${tl_prefix}'=='T073'    ${10}
        ...                                       '${tl_prefix}'=='T080'    ${10}
        PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
        ...                                              gnb_id=${1}
        ...                                              pa_value=${target_pa_value}
        Sleep  3sec
        ${souce_pa_value}     Set Variable If    '${tl_prefix}'=='T073'    ${50}
        ...                                      '${tl_prefix}'=='T080'    ${25}
        Modify PA Value Setting For Required RU    modify_ru_id=0
        ...                                        ue_index=${used_ue_index}
        ...                                        pa_off_value=${souce_pa_value}
        Sleep  4sec
        log to console  INFO:--stop ping traffic ROUND-${round} --
#        Run Keyword If    '${tl_prefix}'=='T073'    Stop Ping Traffic    ue_index=${used_ue_index}
#        ...    ELSE IF    '${tl_prefix}'=='T080'    Stop Ping Traffic For Spark    ue_index=${used_ue_index}
        Stop Ping Traffic    ue_index=${used_ue_index}
        log to console  INFO:--detach ROUND-${round} --
        power_ue.UE Detach    ue_type=${ue_type}    ue_index=${used_ue_index}
    END
    Sleep  5sec
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    ${target_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=target_cprt_${timestamp}
    ...    tcpdump_collector_name=target_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master1
#    Sleep    10min
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_end_time}    Add Time To Date    ${call_end_time}    600    exclude_millis=true
    ${diff_time}    Subtract Date From Date    ${call_end_time}   ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}   900
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    ${end_time_syslog}    Get Syslog Formatted Time
    Set Test Variable    ${call_start_time}
    Set Test Variable    ${call_end_time}
    ${report_timestamp}     Create List    ${call_start_time}    ${call_end_time}
    Append to List    ${report_timestamps}   ${report_timestamp}
    log to console  INFO:--check attach and handover success--
    ${attach_cell_index}    Run Keyword And Continue On Failure    Get Attach Cell Index From Wireshark
    ...    cpif_log_path=${source_cell_wireshark}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_cell_index}    ${PCELL_INDEX}
    ...    msg=attach ERROR,target cell is ${PCELL_INDEX},actual is ${attach_cell_index}
    ${A3A5_status}    Run Keyword And Return Status    HO.Check A5A3 Measurement Report    cpif_log_path=${source_cell_wireshark}
    ...    exp_source_pci=318
    ...    exp_target_pci=569
    ...    rounds=${3}
    ${RRC_Reconfigured_Status}    Run Keyword And Return Status    HO.Check RRC Reconfigure And RRC Reconfigure Complete For Inter-gnb
    ...    source_cpif_log_path=${source_cell_wireshark}
    ...    target_cpif_log_path=${target_cell_wireshark}
    ...    rounds=${3}
    ${RRC_Reestablishment_source}    Run Keyword And Return Status    HO.Check RRC Reestablishment
    ...    cpif_log_path=${source_cell_wireshark}
    ${RRC_Reestablishment_target}    Run Keyword And Return Status    HO.Check RRC Reestablishment
    ...    cpif_log_path=${target_cell_wireshark}
#    ${test_valid_status}    Evaluate
#    ...    ${A3A5_status} and ${RRC_Reconfigured_Status} and ${RRC_Reestablishment_source} and ${RRC_Reestablishment_target}
    ${test_valid_status}    Evaluate
    ...    ${A3A5_status} and ${RRC_Reconfigured_Status}
    run keyword if  not ${test_valid_status}    Fail    msg=handover is not success for 3 times.
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_time_syslog}
    ...    syslog_end_time=${end_time_syslog}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=GNB_OAM0    gnb_index=${0}
    ${status}    ${colleted_snapshot}    Run Keyword And Ignore Error    COAM Save snapshot via rest api
    ...                                    connection=GNB_OAM0
    ...                                    timeout=900
    Set Test Variable    ${colleted_snapshot}
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=180 minutes
    ...    snapshot_zip_path=${colleted_snapshot}
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Return]    ${report_timestamps}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    run      rm -rf ${colleted_snapshot}    AND
    ...    Run Keyword And Ignore Error     Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}    AND
    ...    Run Keyword And Ignore Error     Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=target_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}   AND
    ...    Run Keyword And Ignore Error   Stop Ping Traffic    ue_index=${used_ue_index}    AND
    ...    Run Keyword And Ignore Error   Stop Ping Traffic For Spark    ue_index=${used_ue_index}    AND
    ...    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master0    AND
    ...    Run Keyword And Ignore Error   csn.execute    command=killall tcpdump    connection=ASIK Master1    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master0    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master1    AND
    ...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=GNB_OAM0    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api
    ...                                    connection=GNB_OAM0
    ...                                    timeout=900     AND
    ...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=GNB_OAM1    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api
    ...                                    connection=GNB_OAM1
    ...                                    timeout=900

TestCase.Reproduce_5603052
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]      ${start_L3_call}=True    ${good}=good    ${mid}=mid    ${bad}=bad    ${enb_index}=${1}
    ...              ${warn_err_fail_case}=True
    log    ${warn_err_fail_case}
    # L3 call one turn, start SA l3 call with good -> mid -> bad -> mid -> good -> stop l3 call
    log    ${start_L3_call}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Log To Console    ${\n}INFO:-- modify CA configuration 2CC --
    Update Parameter to prepare L3 call    para_value=false
    ...                                   enb_index=${fdd_enb_index}
    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
    Run Keyword And Continue On Failure    Run Keyword If   '${tl_prefix}'=='T080'    Lock Or Unlock Single Cell
    ...                                    cell_index=3    cell_type=nr    action=block
    Run Keyword And Continue On Failure    Run Keyword If   '${tl_prefix}'=='T080'    Lock Or Unlock Single Cell
    ...                                    cell_index=23    cell_type=nr    action=block
    ${L3_call_succesful}    ${call_start_try0}     ${call_end_try0}
    ...                  Get KPI Report with difference RSRP and TP in 15min    whether_need_ue_log=${False}
    ...                                   enb_index=${enb_index}    good=${good}    mid=${mid}    bad=${bad}    UTC_timezone=${False}
    ${L3_call_succesful1}    ${call_start_try1}     ${call_end_try1}    Run Keyword If    ${L3_call_succesful}=='False'
    ...                  Get KPI Report with difference RSRP and TP in 15min     whether_need_ue_log=${False}
    ...                                   enb_index=${enb_index}    good=${good}    mid=${mid}    bad=${bad}    UTC_timezone=${False}
    ${call_start_time}    Set Variable If   '${L3_call_succesful}'=='True'    ${call_start_try0}    ${call_end_try0}
    ${call_end_time}      Set Variable If   '${L3_call_succesful}'=='True'    ${call_end_try0}      ${call_end_try1}
    ${diff_time}    Subtract Date From Date    ${call_end_time}    ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}    901
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    log to console    ${call_end_time}
    Set Test Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}

TestCase.Reproduce_5605002
    [Arguments]    ${warn_err_fail_case}=True
    log    ${warn_err_fail_case}
    ${remote_log_path}    OperatingSystem.Join Path    ${TS_CASE_LOG_PATH}    8311_kpi
    OperatingSystem.Create Directory    ${remote_log_path}
    Set Test Variable     ${remote_log_path}
    ${case_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${spark_ue_logpath} =   Catenate    SEPARATOR=_   ${spark_ue_logpath}   ${case_time}
    ${spark_ue_logname} =   Catenate    SEPARATOR=_   ${target_version}   ${case_time}
    Set Test Variable   ${spark_ue_logname}
    Set Test Variable   ${spark_ue_logpath}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Update_TMO_3CC_Configration    ue_index=${CASE_FOR_KPI_CHOOSED_UE['${tl_prefix}']}
    Update Parameter to prepare L3 call    para_value=false
    ...                                   enb_index=${fdd_enb_index}
    Update The Prach Index    cell_index=${PCELL_INDEX}    prach_index=9
    Change cellBarred Parameter Value On Gnb    pcell_index=${PCELL_INDEX}    exp_status=notBarred
    Run Keyword And Ignore Error    MultiUE Prepare UE     low_RSRP=True
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${fail_time}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    1    191
           log to console      "UE Attach_${i}"
           ${success_status}    Run Keyword And Return Status    MultiUE Attach without check TP in UE
           ...    logpath=${spark_ue_logpath}    logname=run_1_${i}    save_ue_log=False
           ...    DL_200M_8311=DL_10M_8311
           sleep   2s
           ${fail_time}     Run Keyword If    '${success_status}'=='${False}'    Evaluate    ${fail_time}+${1}
           ...    ELSE     Evaluate    ${fail_time}+${0}
    END
    Get Syslog Start Time
    FOR    ${i}    IN RANGE    1    11
           log to console      "UE Attach_no_tp_${i}"
           ${success_status}    Run Keyword And Return Status    MultiUE Attach without check TP in UE
           ...    logpath=${spark_ue_logpath}    logname=run_1_${i}    DL_200M_8311=DL_10M_8311
           sleep   2s
           ${fail_time}     Run Keyword If    '${success_status}'=='${False}'    Evaluate    ${fail_time}+${1}
           ...    ELSE     Evaluate    ${fail_time}+${0}
    END
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    Run Keyword And Ignore Error    power_ue.UE Attach     ue_type=sigspark_multiUE
    Set Test Variable    ${FAIL_TIME}    ${fail_time}

TestCase.Reproduce_5605005
    ${sleep_time}    Set Variable If    '${tl_prefix}'=='T073'    10800
    ...       '${tl_prefix}'=='T080'    12600
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ${multi_ue_attach_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
    ...    '${tl_prefix}'=='T080'    ${${19},${20},${22},${23},${24},${25},${26}}
    run keyword and ignore error    Perform Mutli-UE Start Log
    ...     ues_index=${multi_ue_attach_indexs}
    Perform Mutli-UE Attach    ues_index=${multi_ue_attach_indexs}
    Perform Import TestPlan    ues_index=${multi_ue_attach_indexs}
    Sleep    10min
    ${report_timestamps}    Create List
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${start_syslog_burst}    Get Syslog Formatted Time
    Sleep    30min
    ${end_syslog_burst}    Get Syslog Formatted Time
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_syslog_burst}
    ...    syslog_end_time=${end_syslog_burst}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${current_time}    ${call_start_time}
    log to console     syslog check spend time:${diff_time}
    ${duration}    Evaluate   ${sleep_time}-${diff_time}
    log to console     start to sleep:${duration}sec
    Sleep     ${duration}sec
    ${start_time_syslog}    Get Syslog Formatted Time
    Sleep    30min
    ${end_time_syslog}    Get Syslog Formatted Time
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamp}     Create List    ${call_start_time}    ${call_end_time}
    Append to List    ${report_timestamps}   ${report_timestamp}
    run keyword and ignore error    Perform Mutli-UE Stop Log
    ...     ues_index=${multi_ue_attach_indexs}
    Perform Mutli-UE Disconnect    ues_index=${multi_ue_attach_indexs}
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_time_syslog}
    ...    syslog_end_time=${end_time_syslog}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Return]    ${report_timestamps}

TestCase.Reproduce_5605501
    [Arguments]    ${warn_err_fail_case}=True
    log    ${warn_err_fail_case}
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${0}    connection=GNB_OAM0
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    Get Syslog Start Time
    #lock AMF
    Update AMF Status     administrativeState=Locked
    Sleep    1sec
    #change params for NRCELL-301/302/303/311/312/313
    ${delete_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-302',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-303',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-312',
    ...    'parameter':'enforcePrimaryPathOverLte'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-313',
    ...    'parameter':'enforcePrimaryPathOverLte'}
    ${delete_params}    Evaluate   [${delete_enforcePrimaryPathOverLte}]
    Delete Params Through RestApi    parameters_to_delete_via_api=${delete_params}    is_verify_onair=${False}
    #change params for NRCELL-1/2/3
    ${update_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'true'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'true'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'true'}
    ${update_ulTransPrecodeCtl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'-30','ulTransPrecodeOnSinrThresh':'-80'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'-30','ulTransPrecodeOnSinrThresh':'-80'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'-30','ulTransPrecodeOnSinrThresh':'-80'}]}
    ${update_params_list}    Evaluate    [${update_enforcePrimaryPathOverLte},${update_ulTransPrecodeCtl}]
    Update Params Through RestApi    params_need_to_modify=${update_params_list}    is_verify_onair=${False}
    #unlock AMF
    Sleep    10sec
    Update AMF Status     administrativeState=Unlocked
    Check TMO Gnb Ready And All Cell On Air
#    check counter M55150C00035 more than 2 measurement period
    ${report_timestamps_round0}      Create List
    ${report_timestamps_round1}      Create List
    ${call_start_time_UTC_round0}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time_round0}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Sleep    15min
    ${call_end_time_UTC_round0}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_round0}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_timestamp_round0}    Create List    ${call_start_time_round0}    ${call_end_time_round0}
    Append To List    ${report_timestamps_round0}    ${call_timestamp_round0}
    #lock AMF
    Update AMF Status     administrativeState=Locked
    Sleep  1sec
    #change params for NRCELL-301/302/303/311/312/313
    ${add_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-302',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-303',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-311',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-312',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-313',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'}
    ${add_params}    Evaluate   [${add_enforcePrimaryPathOverLte}]
    Add Params Through RestApi    parameters_to_add_via_api=${add_params}    is_verify_onair=${False}
    #change params for NRCELL-1/2/3
    ${update_enforcePrimaryPathOverLte}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'},{'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'enforcePrimaryPathOverLte','value':'false'}
    ${update_ulTransPrecodeCtl}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'40','ulTransPrecodeOnSinrThresh':'0'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'40','ulTransPrecodeOnSinrThresh':'0'}]},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOffSinrThresh':'40','ulTransPrecodeOnSinrThresh':'0'}]}
    ${update_params_list}    Evaluate    [${update_enforcePrimaryPathOverLte},${update_ulTransPrecodeCtl}]
    Update Params Through RestApi    params_need_to_modify=${update_params_list}    is_verify_onair=${False}
    #unlock AMF
    Sleep    10sec
    Update AMF Status     administrativeState=Unlocked
    Check TMO Gnb Ready And All Cell On Air
    log to console  INFO:--check syslog: ERR_WARN--
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    ${error_file}    Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
#    check counter M55150C00035 more than 2 measurement period
    ${call_start_time_UTC_round1}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time_round1}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Sleep    15min
    ${call_end_time_UTC_round1}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_round1}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_timestamp_round1}    Create List    ${call_start_time_round1}    ${call_end_time_round1}
    Append To List    ${report_timestamps_round1}    ${call_timestamp_round1}
    Sleep    30min
    [Return]    ${report_timestamps_round0}    ${report_timestamps_round1}
    [Teardown]   Run Keyword And Ignore Error     Save Current SCF And Save Snapshot


TestCase.Reproduce_5603153
    [Arguments]    ${warn_err_fail_case}=True
    log    ${warn_err_fail_case}
    log to console    \n--- step1: start l3 call before upgrade---
    Disable actDlSrsBm and releated params via Admin API
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    ${btsName_before_upgrade}    ${gnb_version_before_upgrade}     Get BtsName and SwVersion
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    ${timestamp_before_upgrade}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
    ${tput_before_upgrade}    Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
    ...    ue_index=${ue_index}    whether_do_ue_prepare=${False}    get_spark_license=${False}
    [Return]     ${tput_before_upgrade}    ${timestamp_before_upgrade}    ${btsName_before_upgrade}    ${gnb_version_before_upgrade}

TestCase.Reproduce_5605012
    [Arguments]    ${warn_err_fail_case}=True
    log    ${warn_err_fail_case}
    Rep5605012.Parameter Modification
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    301
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Lock Or Unlock Single Cell    cell_index=1    action=block
    Run keyword If    '${tl_prefix}'=='T080'    Lock Or Unlock Single Cell    cell_index=11    cell_type=lte    action=block
    ${cell_301_pa_value}    Set Variable If    '${tl_prefix}'=='T080'    ${24}
    ...                                        '${tl_prefix}'=='T283'    ${38}
    ${cell_21_pa_value}    Set Variable If    '${tl_prefix}'=='T080'    ${35}
    ...                                        '${tl_prefix}'=='T283'    ${30}
    PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
    ...                                              gnb_id=${0}
    ...                                              pa_value=${cell_301_pa_value}
    PA Value Setting For Required RU Required gNB    modify_ru_id=${6}
    ...                                              gnb_id=${0}
    ...                                              pa_value=${cell_21_pa_value}
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
    ...    ue_type=${ue_type}    get_spark_license=${False}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
    Sleep    10sec
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    ${attach_cell_index}    Run Keyword And Continue On Failure    Get Attach Cell Index From Wireshark
    ...    cpif_log_path=${source_cell_wireshark}    connection=GNB_OAM${0}    gnb_index=${0}
    Should Be Equal As Integers    ${attach_cell_index}    ${PCELL_INDEX}
    ...    msg=attach ERROR,target cell is ${PCELL_INDEX},actual is ${attach_cell_index}
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Get Syslog Start Time
    FOR    ${INDEX}    IN RANGE    ${20}
        log to console     start to start traffic for round-${INDEX}
        Run Keyword And Continue On Failure    traffic_via_iperf.Start UL traffic via iperf from andriod UE
        ...        ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
        ...        ul_time=200
        ...        ul_port=${tl.ues[${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
        ...        ul_throughput=30M
        ...        ul_length=1400B
        ...        appserver=APPserver
        ...        protocol=udp
        ...        iperf_path=iperf
        ...        process_num=${1}
        Sleep  10sec
#        Close the iperf process on android ue    ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
#        ...          iperf_port=${tl.ues[${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
        Run Keyword And Continue On Failure     traffic_via_iperf.Start UL traffic via iperf from andriod UE
        ...        ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
        ...        ul_time=200
        ...        ul_port=${tl.ues[${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
        ...        ul_throughput=0.1M
        ...        ul_length=1400B
        ...        appserver=APPserver
        ...        protocol=udp
        ...        iperf_path=iperf
        ...        process_num=${1}
        Sleep    100sec
#        Run Keyword And Ignore Error    M60_RedCap.Check Tput    direction=UL    cellid=301
#        ...    expect_ul_tput=15
#        ...    duration=10
#        Run Keyword And Ignore Error    M60_RedCap.Check Tput    direction=UL    cellid=21
#        ...    expect_ul_tput=3
#        ...    duration=10
        Run Keyword And Continue On Failure     Close the iperf process on android ue
        ...          ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
        ...          iperf_port=${tl.ues[${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
#        Sleep    15sec
        Sleep    25sec
    END
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable    ${call_start_time}
    Set Test Variable    ${call_end_time}
    log to console  INFO:--check syslog: ERR_WARN--
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    ${error_file}    Run Keyword And Continue On Failure    Find Syslog Errors During A Specific Period of Time
    ...    syslog_start_time=${SYSLOG_START_TIME}
    [Teardown]   Run Keyword And Ignore Error     Save Current SCF And Save Snapshot


TestCase.Reproduce_5605006
    [Arguments]    ${warn_err_fail_case}=True
    log    ${warn_err_fail_case}
    #Step0_precondition
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    301    21
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Log to console    INFO:--modify parameters Via RestAPI---
    Rep5605006.Parameter Modification
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${0}    connection=GNB_OAM0
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    #Step1:reset gnb and wait on air
    ${gnb_restart_time_start}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Perform gNB Reset site and Wait Onair
    ${gnb_restart_time_end}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${gnb_restart_time_start}    Add Time To Date    ${gnb_restart_time_start}    -600    exclude_millis=true
    ${gnb_restart_time_end}    Add Time To Date    ${gnb_restart_time_end}    600    exclude_millis=true
    Set Test Variable   ${GNB_RESTART_TIME_START}    ${gnb_restart_time_start}
    Set Test Variable   ${GNB_RESTART_TIME_END}    ${gnb_restart_time_end}
    Log to console    INFO:--modify pa vaue: nrcell301 to -85db,nrcell-21 rsrp ---
    ${nrcell_301_pa_value}    Set Variable If    '${tl_prefix}'=='T080'    10
    ...                                          '${tl_prefix}'=='T813'    22
    ...                                          '${tl_prefix}'=='T284'    30
    ...                                          '${tl_prefix}'=='T283'    30
    ${nrcell_21_pa_value}    Set Variable If    '${tl_prefix}'=='T080'    25
    ...                                         '${tl_prefix}'=='T813'    20
    ...                                         '${tl_prefix}'=='T284'    45
    ...                                         '${tl_prefix}'=='T283'    30
    ${necell_21_ru_index}    Set Variable If    '${tl_prefix}'=='T080'    6
    ...                                         '${tl_prefix}'=='T813'    6
    ...                                         '${tl_prefix}'=='T284'    1
    ...                                         '${tl_prefix}'=='T283'    6
    ${nr_phy_cell_ids}     Set Variable If    '${tl_prefix}'=='T813'    594
    ...                                       '${tl_prefix}'=='T284'    150
    ...                                       '${tl_prefix}'=='T283'    301
    ...                                       '${tl_prefix}'=='T080'    318
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${nrcell_301_pa_value}
    Modify PA Value Setting For Required RU    modify_ru_id=${necell_21_ru_index}
    ...    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${nrcell_21_pa_value}
    ${report_timestamps_round0}      Create List
    ${report_timestamps_round1}      Create List
    #Step2:attach
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    log to console  INFO:--start attach-
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=SA
    ...                                              ue_type=${ue_type}
    ...                                              ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...                                              4G_check=False
    #Step3:start DL traffic for 30min then stop traffic 20min---Report-ROUND0
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                    dl_throughput=1000MKbits/sec
    ...                                    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...                                    whether_start_ul_call=${False}
    ...                                    start_keep_on_duration=3600
    Sleep    7min
    ${sleep_seconds}    Caculate timeToSleep Before Next Counters Period
    log to console    INFO:-- need to sleep ${sleep_seconds} before next counter start --
    Sleep    ${sleep_seconds}sec
    ${call_start_time_UTC_round0}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time_round0}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Sleep    10min
    ${status}    ${bip_step2}    Run Keyword And Ignore Error    TMO.Start BIP Capture
    ...     nr_phy_cell_ids=${nr_phy_cell_ids}
    ${status}    ${ttitrace_file_step2}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5
    ...    cell_index=301
    ...    duration=5
    ...    direction=dlAndUl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 301 -b    bbmod_slots=5    duration=10
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    5min
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ${sleep_time}    Set Variable If    '${tl_prefix}'=='T080'    35min
    ...                                  '${tl_prefix}'=='T813'    35min
    ...                                  '${tl_prefix}'=='T284'    35min
    ...                                  '${tl_prefix}'=='T283'    40min
    ...                                  35min
    Sleep   ${sleep_time}
    ${call_end_time_UTC_round0}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_round0}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_start_time_round0}    Add Time To Date    ${call_start_time_round0}    600    exclude_millis=true
    ${call_timestamp_round0}    Create List    ${call_start_time_round0}    ${call_end_time_round0}
    Append To List    ${report_timestamps_round0}    ${call_timestamp_round0}
    #Step4:start DL traffic for 30min then stop traffic 20min---Report-ROUND1
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                    dl_throughput=1800MKbits/sec
    ...                                    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...                                    whether_start_ul_call=${False}
    ...                                    start_keep_on_duration=3600
    Sleep    10min
#    Run Keyword If    '${tl_prefix}'=='T284'    Modify PA Value Setting For Required RU    modify_ru_id=${necell_21_ru_index}
#    ...    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
#    ...    pa_off_value=127
    Run Keyword And Ignore Error    Modify PA Value Setting For Required RU    modify_ru_id=${necell_21_ru_index}
    ...    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=127
    ${sleep_seconds}    Caculate timeToSleep Before Next Counters Period
    log to console    INFO:-- need to sleep ${sleep_seconds} before next counter start --
    Sleep    ${sleep_seconds}sec
    ${call_start_time_UTC_round1}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time_round1}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Sleep    10min
    ${status}    ${bip_step4}    Run Keyword And Ignore Error    TMO.Start BIP Capture
    ...     nr_phy_cell_ids=${nr_phy_cell_ids}
    ${status}    ${ttitrace_file_step4}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5
    ...    cell_index=301
    ...    duration=5
    ...    direction=dlAndUl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 301 -b    bbmod_slots=5    duration=10
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    5min
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    Sleep   ${sleep_time}
    ${call_end_time_UTC_round1}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time_round1}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_start_time_round1}    Add Time To Date    ${call_start_time_round1}    600    exclude_millis=true
    ${call_timestamp_round1}    Create List    ${call_start_time_round1}    ${call_end_time_round1}
    Append To List    ${report_timestamps_round1}    ${call_timestamp_round1}
    #check point
    Run Keyword And Ignore Error    RepCase_5605006.Check Pattern Id In Same Range
    ...    syslog_start_time=${GNB_RESTART_TIME_START}
    ...    syslog_end_time=${GNB_RESTART_TIME_END}
    ...    patternId_values_list_in_bip_step2=${bip_step2}
    ...    patternId_values_list_in_bip_step4=${bip_step4}
    Sleep    30min
    [Return]    ${report_timestamps_round0}    ${report_timestamps_round1}
    [Teardown]   Run Keyword And Ignore Error     Save Current SCF And Save Snapshot

TestCase.Reproduce_5605014
    Rep5605014.Parameter Modification
    Delete All NRREL On CellIndex
    Check TMO Gnb Ready And All Cell On Air
    Check TMO Gnb Ready And All Cell On Air    gnb_id=1    connection=GNB_OAM1
    Set All NR Cell To Barred Status
    Set All NR Cell To Barred Status    gnb_index=${1}
    Check TMO Gnb Ready And All Cell On Air
    Check TMO Gnb Ready And All Cell On Air    gnb_id=1    connection=GNB_OAM1
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=6
    ...    ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${15}
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    log to console  INFO:--start attach-
    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}
#    ${attach_info}    Procedures.Start TMO Attach    ue_mode=NSA
#    ...                                              ue_type=${ue_type}
#    ...                                              ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}
#    ...                                              4G_check=False
    log to console    INFO:--start to l3 call
    Start DL traffic via iperf on Appserver    ue_addr=10.64.21.89
    ...                                        dl_time=3600
    ...                                        dl_port=${tl.ues[${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=300MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1372}
    ...                                        window=2M
    ${pci_list}    Create List   570  571  572  573  574  575  576  577  578  579  580  581  582  583  584  585  586  587  588  1005
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
    ...                                          gnb_id=${1}
    ...                                          pa_value=${20}
    Sleep    2min
    PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
    ...                                          gnb_id=${1}
    ...                                          pa_value=${127}
    Sleep    15sec
    FOR   ${pci}    IN    @{pci_list}
        log to console   start to modify pci to ${pci}
        Rep5605014.Modify PCI    pci_value=${pci}    cell_index=301    gnb_index=1
        Check TMO Gnb Ready And All Cell On Air    gnb_id=1    connection=GNB_OAM1
        PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
        ...                                              gnb_id=${1}
        ...                                              pa_value=${20}
        Sleep    10sec
        PA Value Setting For Required RU Required gNB    modify_ru_id=${0}
        ...                                              gnb_id=${1}
        ...                                              pa_value=${127}
        Sleep    15sec
    END
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${active_alarms_list}    coam.get_active_alarms    connection=GNB_OAM     timeout=${180}
    ${8150_pci_list}    Run Keyword And Continue On Failure    get_8150_pci_list_from_alarm_details
    ...    alarm_info_list=${active_alarms_list}
    Rep5605014.Parameter Modification    status=true
    Check TMO Gnb Ready And All Cell On Air
    Sleep   60sec
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${active_alarms_after}    coam.get_active_alarms    connection=GNB_OAM     timeout=${180}
    Run Keyword And Continue On Failure    verify_8150_cancelled    alarm_info_list=${active_alarms_after}
    ${target_pci_in_mr}    Rep5605014.Get PCI List From A5A3 Measurement Report    cpif_log_path=${source_cell_wireshark}
    ${pci_length}    Get Length    ${8150_pci_list}
    Should Be True    ${pci_length}>=${15}    msg=pci number is less than 15.
    [Teardown]     Run Keywords    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM

TestCase.Reproduce_5605003
    Log to console    INFO:--start to config relation cells--
    ${swap_report_timestamps}    Create List
    Configure Relation Cells
#    Run Keyword If    '${tl_prefix}'!='T073'    Configure Relation Cells
#    ...     ELSE    Configure Relation Cells    addition_method=covBasedA4
    Run Keyword If    '${tl_prefix}'=='T073'    RepCase_5605003.Modify weightForSCellSelection
    ${SCELL_INDEX_LIST}    Set Variable    ${case_params.get('scell_idx_list')}
    Set Test Variable    ${SCELL_INDEX_LIST}
    Run Keyword If    '${tl_prefix}'!='T073'    Set Case PA Or MCS Port Value
    ...    attenuator_list=${attenuator_list}    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    ELSE    Reproduce_5605003_TL073.PA Value Setting
    #change not-barred status
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    Set Test Variable     ${fdd_enb_index}
    FOR    ${enb_index}    IN RANGE    ${enb_length}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
    END
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Log to console  start to prepare UE
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    #Only for TL080 and TL073
    log to console    start multi-UE DL Burst traffic
    ${multi_ue_prepare_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
    ...    '${tl_prefix}'=='T080'    ${${19},${20},${21},${22},${23},${24},${25},${26}}
    ${multi_ue_attach_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
    ...    '${tl_prefix}'=='T080'    ${${19},${20},${22},${23},${24},${25},${26}}
    Run Keyword If  '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
    ...    Run Keyword And Ignore Error    Perform Mutli-UE Prepare    ues_index=${multi_ue_prepare_indexs}
    Log to console    INFO:--modify additional parameters based on TL
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${drbInactivityTimerSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSA','value':'600'}
    ${srbInactivityTimerSA}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSA','value':'600'}
    ${update_param}     evaluate    [${drbInactivityTimerSA},${srbInactivityTimerSA}]
    Update Params Through RestApi    params_need_to_modify=${update_param}    gnb_index=0
    Log to console  start to attach UE
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Sleep    10sec
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    ${attach_cell_index}    Run Keyword And Continue On Failure    Get Attach Cell Index From Wireshark
    ...    cpif_log_path=${source_cell_wireshark}    connection=GNB_OAM0    gnb_index=${0}
    Should Be Equal As Integers    ${attach_cell_index}    ${PCELL_INDEX}
    ...    msg=attach ERROR,target cell is ${PCELL_INDEX},actual is ${attach_cell_index}
    ${ue_ip_dict}    Get ALL PDU IP Address From Wireshark    cpif_log_path=${source_cell_wireshark}
    ${ipv6_addr}    Run Keyword If    '${tl_prefix}'=='T080'
    ...    Get IPV6 Address From UE    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ${ue_addr}    Set Variable If    '${tl_prefix}'=='T080'     ${ipv6_addr}    ${ue_ip_dict['data']}
    log to console    ip address is ${ue_addr},start to start DL traffic
    Start DL traffic Through Appserver         ue_addr=${ue_addr}
    ...                                        dl_time=1800
    ...                                        dl_port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=1600MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1400}
    ...                                        window=2M
    Sleep   10sec
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    Start DL traffic Through Appserver         ue_addr=${ue_addr}
    ...                                        dl_time=1800
    ...                                        dl_port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=1MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1400}
    ...                                        window=2M
    #Only for TL080 and TL073
    log to console    start multi-UE DL Burst traffic
#    ${multi_ue_prepare_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
#    ...    '${tl_prefix}'=='T080'    ${${19},${20},${21},${22},${23},${24},${25},${26}}
#    ${multi_ue_attach_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
#    ...    '${tl_prefix}'=='T080'    ${${19},${20},${22},${23},${24},${25},${26}}
#    Run Keyword If  '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
#    ...    Run Keyword And Ignore Error    Perform Mutli-UE Prepare    ues_index=${multi_ue_prepare_indexs}
    Run Keyword If  '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
    ...    Run Keyword And Ignore Error    Perform Mutli-UE Attach    ues_index=${multi_ue_attach_indexs}
    Run Keyword If  '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
    ...    Run Keyword And Ignore Error        Reproduce_5605005.Start Brust DL UDP Traffic
    ...    run_script_path=/home/vrf4_sg6/5605003/${tl_prefix}
    ...    test_model_sh_script_path=/home/vrf4_sg6/5605003/${tl_prefix}/8UE_DL_Burst/
    Sleep   30sec
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell swap to T(301)+T(311)+F(1)+F(22)--
    ${source_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    40
    ...                                           '${tl_prefix}'=='T816'    40
    ...                                           '${tl_prefix}'=='T813'    40
    ${target_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    32
    ...                                           '${tl_prefix}'=='T816'    34
    ...                                           '${tl_prefix}'=='T813'    20
    ${start_syslog_swap}    Get Syslog Formatted Time
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    Add Time To Date    ${call_start_time}    -301    exclude_millis=true
    ${A6_status}    Run Keyword And Return Status    CA.Trigger A6 Scell Swap     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    rounds=13    source_swap_pa_value=${source_swap_pa_value}    target_swap_pa_value=${target_swap_pa_value}
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${call_end_time}   ${call_start_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}   900
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    ${end_syslog_swap}    Get Syslog Formatted Time
    ${report_timestamp}     Create List    ${call_start_time}    ${call_end_time}
    Append to List    ${swap_report_timestamps}   ${report_timestamp}
    run keyword if  not ${A6_status}    Fail    msg=A6 swap not success.
    #start to verify 4CC success
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
#    Sleep   5sec
    Start DL traffic Through Appserver         ue_addr=${ue_addr}
    ...                                        dl_time=1800
    ...                                        dl_port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=1600MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1400}
    ...                                        window=2M
    Sleep    1min
    ${4cc_status}    Run Keyword And Return Status    Procedures.Check TMO Throughput
    ...    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    addition_scell_index_list=${SCELL_INDEX_LIST}
    ...    check_scell_tput_type=not_peak
    ...    check_ul_pcell_tput_type=no_data
    ...    check_pcell_tput_type=not_peak
    ...    tput_collect_duration=90
    ...    min_scell_percent=0
    ...    min_DL_percent=0
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    Run Keyword And Ignore Error     Recover Collect Syslog On GNB
    run keyword if  not ${4cc_status}    Fail    msg=4CC not success.
    ${burst_dl_timestamps}     Set Variable    ${None}
#    ${burst_dl_timestamps}   Run Keyword If  '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
#    ...    Run Keyword And Continue On Failure    DL.Burst Traffic
#    ...    start_burst_dl_needed=${False}
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_syslog_swap}
    ...    syslog_end_time=${end_syslog_swap}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Return]    ${swap_report_timestamps}    ${burst_dl_timestamps}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error     Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}    AND
    ...    Run Keyword And Ignore Error    Reproduce_5605005.Stop Brust DL UDP Traffic
    ...    run_script_path=/home/vrf4_sg6/5605003/${tl_prefix}

TestCase.Reproduce_5605003_T080
    # Step1: L3 call Process
    Run Keyword And Ignore Error    Run keyword if    '${ue_type}' == 'mtk'
    ...     MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Run Keyword And Ignore Error    Run Keyword If    '${ue_type}'=='qct_dx50'
    ...    Procedures.Check network mode    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}    get_spark_license=${False}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ${ipv6_addr}    Get IPV6 Address From UE    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    log to console    ip address is ${ipv6_addr}
    Start DL traffic Through Appserver         ue_addr=${ipv6_addr}
    ...                                        dl_time=1200
    ...                                        dl_port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=1600MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1372}
    ...                                        window=2M
    Run Keyword And Ignore Error    MultiUE Prepare UE For Spark
    Run Keyword And Ignore Error    power_ue.UE Detach     ue_type=sigspark_multiUE
    Get Syslog Start Time
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    power_ue.UE Attach     ue_type=sigspark_multiUE
    Sleep    10sec
    ${source_cell_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    cprt_collector_name=source_cprt_${timestamp}
    ...    tcpdump_collector_name=source_cell_wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    ${attach_cell_index}    Run Keyword And Continue On Failure    Get Attach Cell Index From Wireshark
    ...    cpif_log_path=${source_cell_wireshark}    connection=GNB_OAM0    gnb_index=${0}
    Should Be Equal As Integers    ${attach_cell_index}    ${PCELL_INDEX}
    ...    msg=attach ERROR,target cell is ${PCELL_INDEX},actual is ${attach_cell_index}
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell addition and activation success--
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    Add Time To Date    ${call_start_time}    -301    exclude_millis=true
    log to console  INFO:--start to 8UE traffic--
    Run Keyword And Ignore Error    Reproduce_5605005.Start Brust DL UDP Traffic    sh_file_path=/home/vrf4_sg6/5605003
    Sleep    3min
    Run Keyword And Continue On Failure    Procedures.Check TMO Throughput
    ...    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    addition_scell_index_list=${SCELL_INDEX_LIST}
    ...    check_scell_tput_type=not_peak
    ...    check_ul_pcell_tput_type=no_data
    ...    check_pcell_tput_type=not_peak
    ...    tput_collect_duration=90
    ...    min_scell_percent=0
    ...    min_DL_percent=0
    Run Keyword And Ignore Error     Recover Collect Syslog On GNB
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell swap to T(301)+T(311)+F(1)+F(22)--
    ${source_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    40
    ...                                           '${tl_prefix}'=='T816'    40
    ${target_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    20
    ...                                           '${tl_prefix}'=='T816'    10
    CA.Trigger A6 Scell Swap     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    rounds=10    source_swap_pa_value=${source_swap_pa_value}    target_swap_pa_value=${target_swap_pa_value}
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_end_time}    Add Time To Date    ${call_end_time}    600    exclude_millis=true
    ${diff_time}    Subtract Date From Date    ${call_end_time}   ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}   900
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    Set Test Variable    ${call_end_time}
    [Teardown]    Run Keyword And Ignore Error    Reproduce_5605005.Stop Brust DL UDP Traffic     sh_file_path=/home/vrf4_sg6/5605003

TestCase.Reproduce_5605003_T073
    # Step1: L3 call Process
    Run Keyword And Ignore Error    Run keyword if    '${ue_type}' == 'mtk'
    ...     MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Run Keyword And Ignore Error    Run Keyword If    '${ue_type}'=='qct_dx50'
    ...    Procedures.Check network mode    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    Get Syslog Start Time
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell addition and activation success--
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    Add Time To Date    ${call_start_time}    -301    exclude_millis=true
    ${ip_type}    Set Variable If    '${tl_prefix}'=='T073'    4
    ...                              '${tl_prefix}'=='T080'    6
    ...                              '${tl_prefix}'=='T816'    4
    ${attach_info}     Procedures.Verify CA Basic L3 Call    dl_throughput=2400MKbits/sec
    ...                                                      ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                                      whether_check_on_air=${False}
    ...                                                      enb_index=${fdd_enb_index}
    ...                                                      whether_start_ul_call=${False}
    ...                                                      check_scell_tput_type=not_peak
    ...                                                      check_ul_pcell_tput_type=no_data
    ...                                                      check_pcell_tput_type=not_peak
    ...                                                      tput_collect_duration=60
    ...                                                      min_scell_percent=0
    ...                                                      min_DL_percent=0
    ...                                                      ip_type=${ip_type}
    Run Keyword And Ignore Error    MultiUE Prepare UE For Spark
    Run Keyword And Ignore Error    power_ue.UE Detach     ue_type=sigspark_multiUE
    Sleep    5sec
    Run Keyword And Ignore Error    power_ue.UE Attach     ue_type=sigspark_multiUE
    Run Keyword And Ignore Error    Reproduce_5605005.Start Brust DL UDP Traffic    sh_file_path=/home/vrf4_sg6/5605003
    Sleep    2min
#    Run Keyword If    '${attach_info}'=='${None}'     Fail     msg=attach failed.
    Run Keyword And Ignore Error     Recover Collect Syslog On GNB
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell swap to T(301)+T(311)+F(1)+F(22)--
    ${source_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    40
    ...                                           '${tl_prefix}'=='T816'    40
    ${target_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    20
    ...                                           '${tl_prefix}'=='T816'    10
    CA.Trigger A6 Scell Swap     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    rounds=10    source_swap_pa_value=${source_swap_pa_value}    target_swap_pa_value=${target_swap_pa_value}
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_end_time}    Add Time To Date    ${call_end_time}    600    exclude_millis=true
    ${diff_time}    Subtract Date From Date    ${call_end_time}   ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}   900
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    Set Test Variable    ${call_end_time}
    [Teardown]    Run Keyword And Ignore Error    Reproduce_5605005.Stop Brust DL UDP Traffic     sh_file_path=/home/vrf4_sg6/5605003

TestCase.Reproduce_5605003_T816
    # Step1: L3 call Process
    Run Keyword And Ignore Error    Run keyword if    '${ue_type}' == 'mtk'
    ...     MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode
    ...     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Run Keyword And Ignore Error    Run Keyword If    '${ue_type}'=='qct_dx50'
    ...    Procedures.Check network mode    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    Procedures.Start UE Prepare    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    Get Syslog Start Time
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell addition and activation success--
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    Add Time To Date    ${call_start_time}    -301    exclude_millis=true
    ${attach_info}    Procedures.Verify CA Basic L3 Call     dl_throughput=2400MKbits/sec
    ...                                                      ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                                      whether_check_on_air=${False}
    ...                                                      enb_index=${fdd_enb_index}
    ...                                                      whether_start_ul_call=${False}
    ...                                                      check_scell_tput_type=not_peak
    ...                                                      check_ul_pcell_tput_type=no_data
    ...                                                      check_pcell_tput_type=not_peak
    ...                                                      tput_collect_duration=60
    ...                                                      min_scell_percent=0
    ...                                                      min_DL_percent=0
#    Run Keyword If    '${attach_info}'=='${None}'     Fail     msg=attach failed.
    Sleep   2min
    Run Keyword And Ignore Error     Recover Collect Syslog On GNB
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell swap to T(301)+T(311)+F(1)+F(22)--
    ${source_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    40
    ...                                           '${tl_prefix}'=='T816'    60
    ...                                           '${tl_prefix}'=='T283'    60
    ...                                           '${tl_prefix}'=='T813'    40
    ${target_swap_pa_value}    Set Variable If    '${tl_prefix}'=='T073'    25
    ...                                           '${tl_prefix}'=='T080'    20
    ...                                           '${tl_prefix}'=='T816'    40
    ...                                           '${tl_prefix}'=='T283'    40
    ...                                           '${tl_prefix}'=='T813'    20
    Run Keyword And Continue On Failure    CA.Trigger A6 Scell Swap     ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    rounds=10    source_swap_pa_value=${source_swap_pa_value}    target_swap_pa_value=${target_swap_pa_value}
    log to console  INFO:--start T(301)+T(311)+F(1)+F(21) CA scell deactivation (by reduce the data transfer amountt)--
    Run Keyword And Continue On Failure    Close the iperf process on APPserver
    ...    port=${tl.ues[${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    Sleep   5sec
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call
    ...                                    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                    dl_throughput=1MKbits/sec
    ...                                    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...                                    whether_start_ul_call=${False}
    Sleep    5sec
    CA.Trigger A6 Scell Swap
    ...    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    rounds=10    source_swap_pa_value=${source_swap_pa_value}    target_swap_pa_value=${target_swap_pa_value}
    ...    tcpdump_name=inactive
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${call_end_time}    Add Time To Date    ${call_end_time}    600    exclude_millis=true
    ${diff_time}    Subtract Date From Date    ${call_end_time}   ${call_start_time}
    log to console    ${diff_time}
    ${call_end_time}    Run Keyword If    ${diff_time}<=900    Add Time To Date    ${call_start_time}   900
    ...    exclude_millis=true
    ...    ELSE    Set Variable    ${call_end_time}
    Set Test Variable    ${call_start_time}
    Set Test Variable    ${call_end_time}

RepCase_5605013.Check_Delay_UTU_Result
    [Arguments]    ${ru_log_path}    ${output_report_path}=${TS_CASE_LOG_PATH}/delay_utu_result.xlsx    ${lte_port_number}=0    ${nr_port_number}=1
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${output_report_path}    Set Variable    ${TS_CASE_LOG_PATH}/delay_utu_result_${timestamp}.xlsx
    check_cpri_forwading_data       ru_log_path=${ru_log_path}
    ...                             output_report_path=${output_report_path}
    ...                             lte_port_number=${lte_port_number}
    ...                             nr_port_number=${nr_port_number}

RepCase_5605013.Get_RU_Hlapi_State_Log
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]   ${ru_index}=${1}    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${gnb_index}=${0}
    ...    ${connection}=GNB_OAM${gnb_index}    ${timeout}=600
    Connect to gnb coam via ssl    connection=${connection}   gnb_index=${gnb_index}
    ${prefix_name}    Set Variable If    '${stream_version}'=='25R1'    BTS    BTS${MRBTS_ID}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${hlapi_file_name}    ${zip_full_name}    get_ru_hlapi_state_log_path     bts_prefix=${prefix_name}    serial_number=${serial_number}
    ...    snapshot_path=${snapshot_unzip_file_path}
    ${hlapi_unzip_path}    Join Path    ${snapshot_path}    hlapi_state_log_${timestamp}
    extract zip file    ${snapshot_unzip_file_path}/${zip_full_name}    ${hlapi_unzip_path}
    ${hlapi_ru_log}    Set Variable     ${hlapi_unzip_path}/${hlapi_file_name}
    [Return]    ${hlapi_ru_log}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Rep5605013.Parameter Modification
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${actCpriLinkRecovery}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1',
    ...    'parameter':'actCpriLinkRecovery','value':'true'}
    ${cpriSyncBreakTime}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1',
    ...    'parameter':'cpriSyncBreakTime','value':'200'}
    ${actRecovFromSecondaryController}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1',
    ...    'parameter':'actRecovFromSecondaryController','value':'true'}
    ${actSyncLinkSwitchover}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1',
    ...    'parameter':'actSyncLinkSwitchover','value':'true'}
    ${actRuResetResiliency}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1',
    ...    'parameter':'actRuResetResiliency','value':'true'}
#    ${sequentialRuSwUpgrade}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/MNL-1',
#    ...    'parameter':'sequentialRuSwUpgrade','value':'true'}
    ${update_param}    Catenate    ${actCpriLinkRecovery},${cpriSyncBreakTime},${actRecovFromSecondaryController},
    ...    ${actSyncLinkSwitchover},${actRuResetResiliency}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Rep5605014.Parameter Modification
    [Arguments]    ${status}=false
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${actAutoNrNbRemoval}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRANR-1',
    ...    'parameter':'actAutoNrNbRemoval','value':'${status}'}
    ${actAutoEutraNbRemoval}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRANR-1',
    ...    'parameter':'actAutoEutraNbRemoval','value':'${status}'}
    ${actSaUeBasedAnrEutra}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actSaUeBasedAnrEutra','value':'${status}'}
    ${actSaUeBasedAnrNr}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actSaUeBasedAnrNr','value':'${status}'}
    ${actDisableUlProactGrantAnr}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actDisableUlProactGrantAnr','value':'${status}'}
    ${actNsaUeBasedAnrNr}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actNsaUeBasedAnrNr','value':'${status}'}
    ${actSaUeBasedInterFreqAnrNr}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actSaUeBasedInterFreqAnrNr','value':'${status}'}
    ${lte_not_barred}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/LNBTS-8080/LNCEL-1/SIB-0',
    ...    'parameter':'cellBarred','value':'notBarred'}
#    ${a2MeashoSsbRsrpSA}    catenate    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
#    ...    'parameter':'a2MeashoSsbRsrpSA','value':[{'a2ThresholdhoSsbRsrpSA':'76'}]}
#    ${a2MeashoSsbRsrp}    catenate    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
#    ...    'parameter':'a2MeashoSsbRsrp','value':[{'a2ThresholdhoSsbRsrp':'76'}]}
#    ${a1MeashoSsbRsrpSA}    catenate    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
#    ...    'parameter':'a1MeashoSsbRsrpSA','value':[{'a1ThresholdhoSsbRsrpSA':'78'}]}
#    ${a1MeashoSsbRsrp}    catenate    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301',
#    ...    'parameter':'a1MeashoSsbRsrp','value':[{'a1ThresholdhoSsbRsrp':'78'}]}
    ${update_param}    Catenate    ${actAutoNrNbRemoval},${actAutoEutraNbRemoval},${actSaUeBasedAnrEutra},
    ...    ${actSaUeBasedAnrNr},${actDisableUlProactGrantAnr},${actNsaUeBasedAnrNr},${actSaUeBasedInterFreqAnrNr},${lte_not_barred}
#    ...    ${a2MeashoSsbRsrpSA},${a2MeashoSsbRsrp},${a1MeashoSsbRsrpSA},${a1MeashoSsbRsrp}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Rep5605014.Modify PCI
    [Arguments]    ${pci_value}    ${cell_index}    ${gnb_index}=1
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    Log To Console    \n***start to modify pci***
    ${physCellId}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'physCellId','value':'${pci_value}'}
    ${update_param}     evaluate    [${physCellId}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_index}

Rep5605014.Get PCI List From A5A3 Measurement Report
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    nr-rrc.measResultNeighCells == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_pci_all}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${actual_pci}    Remove Duplicates    ${actual_pci_all}
    ${target_pci}    Evaluate    [x[-1] for x in ${actual_pci}]
    [Return]    ${target_pci}


Get IPV6 Address From UE
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${output}    csn.execute    command=adb shell ifconfig   connection=cpc_${ue_index}
    Sleep    10s
    ${ipv6_addr}    get_ipv6_addr_from_ipconfig    output=${output}
    [Return]    ${ipv6_addr}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

Start DL traffic Through Appserver
    [Documentation]  This keyword connect to Appserver and start the iperf data.
    ...    2020-03-19 Liu Zheng: remove sudo, if appserver username is not root account, it will wait until input the password,
    ...    then kw execute for more than 5 minutes. so remove the sudo. it also suitable for root account.
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${5}
    ...    ${seg_size}=${1180}    ${window}=2M
    csn.Connect to    hostname=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=${appserver}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}'    connection=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}    seg_size=${seg_size}
    ...    window=${window}
    sleep    3s
    Check the iperf progress exist    connection=APPserver    port=${dl_port}
    [Teardown]    csn.disconnect    connection=APPserver

Reproduce_5605003_TL073.PA Value Setting
    #second AVHA PA port NRCELL-302
    ${8UE_ports}    Catenate    A1B1,A2B2,A3B3,A4B4,A1B5,A2B6,A3B7,A4B8,A1B9,A2B10,A3B11,A4B12,A1B13,A2B14,A3B15,A4B16
    ...    ,A1B17,A2B18,A3B19,A4B20,A1B21,A2B22,A3B23,A4B24,A1B25,A2B26,A3B27,A4B28,A1B29,A2B30,A3B21,A4B32
    Set Maritix PA Port    value=30    port_list=${8UE_ports}   attenuator_index=2
    #second AHLOB2 PA port NRCELL-2
    Set Maritix PA Port    value=30    port_list=A9B1,A10B2,A11B3,A12B4   attenuator_index=2
    #second AHFII2 PA port NRCELL-22
    Modify PA Value Setting For Required RU    modify_ru_id=7    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}

Reproduce_5605005_TL073.PA Value Setting
    #second AVHA PA port NRCELL-302
#    ${8UE_ports}    Catenate    A1B1,A2B2,A3B3,A4B4,A1B5,A2B6,A3B7,A4B8,A1B9,A2B10,A3B11,A4B12,A1B13,A2B14,A3B15,A4B16
#    ...    ,A1B17,A2B18,A3B19,A4B20,A1B21,A2B22,A3B23,A4B24,A1B25,A2B26,A3B27,A4B28,A1B29,A2B30,A3B21,A4B32
    ${8UE_ports}    Catenate    A1B5,A2B6,A3B7,A4B8,A1B9,A2B10,A3B11,A4B12,A1B13,A2B14,A3B15,A4B16
    ...    ,A1B17,A2B18,A3B19,A4B20,A1B21,A2B22,A3B23,A4B24,A1B25,A2B26,A3B27,A4B28,A1B29,A2B30,A3B21,A4B32
    Set Maritix PA Port    value=0    port_list=${8UE_ports}   attenuator_index=2
    #second AHLOB2 PA port NRCELL-2
    Set Maritix PA Port    value=30    port_list=A9B1,A10B2,A11B3,A12B4   attenuator_index=2
    #second AHFII2 PA port NRCELL-22
    Modify PA Value Setting For Required RU    modify_ru_id=7    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}

CB007163 Params modification
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
#    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
#    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
#    Log To Console    \n***start to modify actEndcHo***
#    ${actEndcHo}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1',
#    ...    'parameter':'actEndcHo','value':'enabled'}
#    Log To Console    \n***start to modify actEndcHoPrefLay***
#    ${actEndcHoPrefLay}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-${LNCELL_index}',
#    ...    'parameter':'actEndcHoPrefLay','value':'true'}
#    ${update_param}     evaluate    [${actEndcHo},${actEndcHoPrefLay}]
#    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_index}
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${add_obj_delta}    coam_parameter.create_objects_delta    parameters=${CB007163_object_added}    connection=${connection}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CB007163_params_update}
    ...    connection=${connection}    timeout=600
    ${add_params_delta}    coam_parameter.create_add_parameters_delta     parameters=${CB007163_param_added}
    ...    connection=${connection}
    ${params_delta}    Create List    ${add_obj_delta['updated']}    ${add_params_delta['updated']}    ${update_params_delta['updated']}
    log to console      update delta is :${params_delta}
    ${delta_json}    merge_JsonFiles    filename=${params_delta}    output_file_path=/home/ute/SCF/CB007163_parameter_modified_all.json
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007163_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

CB007163 HO Params modification
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CB007163_HO_param_modified}
    ...    connection=${connection}    timeout=600
    coam_parameter.perform_scf_delta_commission    delta_file=${update_params_delta['updated']}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


CB007035 Params modification
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${add_obj_delta}    coam_parameter.create_objects_delta    parameters=${CB007035_object_added}    connection=${connection}
    ${update_params_7035}    Set Variable If     '${stream_version}' == '25R3'    ${CB007035_params_update_25R3}    ${CB007035_params_update}
    ${add_params_7035}    Set Variable If     '${stream_version}' == '25R3'    ${CB007035_param_added_25R3}    ${CB007035_param_added}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${update_params_7035}
    ...    connection=${connection}    timeout=600
    ${add_params_delta}    coam_parameter.create_add_parameters_delta     parameters=${add_params_7035}
    ...    connection=${connection}
    ${params_delta}    Create List    ${add_obj_delta['updated']}    ${update_params_delta['updated']}    ${add_params_delta['updated']}
    log to console      update delta is :${params_delta}
    ${delta_json}    merge_JsonFiles    filename=${params_delta}    output_file_path=/home/ute/SCF/CB007035_parameter_modified_all.json
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007035_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

CB007334 Params modification
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CB007334_params_update}
    ...    connection=${connection}    timeout=600
    ${delete_params}    coam_parameter.create_delete_objects_delta    parameters=${CB007334_delete_params}    connection=${connection}
    ${params_delta}    Create List    ${delete_params['updated']}    ${update_params_delta['updated']}
    ${delta_json}    merge_JsonFiles    filename=${params_delta}    output_file_path=/home/ute/SCF/CB007334_parameter_modified_all.json
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007035_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

CB007334 Update Cell Lock Status
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CB007334_Change_Cell_lock_status}
    ...    connection=${connection}    timeout=600
    coam_parameter.perform_scf_delta_commission    delta_file=${update_params_delta['updated']}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007035_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

CB007334 Update Cell Unlock Status
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CB007334_Change_Cell_Unlock_status}
    ...    connection=${connection}    timeout=600
    coam_parameter.perform_scf_delta_commission    delta_file=${update_params_delta['updated']}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007035_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


CB007035 Params modification after ANR
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${add_params_delta}    coam_parameter.create_add_parameters_delta     parameters=${CB007035_param_added_after_ANR}
    ...    connection=${connection}
    coam_parameter.perform_scf_delta_commission    delta_file=${add_params_delta['updated']}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007035_parameter_modified_all.json
    ${7035_scf_file}    Run Keyword And Ignore Error    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

CNI145514 Params modification
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${add_obj_delta}    coam_parameter.create_objects_delta    parameters=${CNI_145514_object_added}    connection=${connection}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CNI_145514_params_update}
    ...    connection=${connection}    timeout=600
    ${params_delta}    Create List    ${add_obj_delta['updated']}    ${update_params_delta['updated']}
    log to console      update delta is :${params_delta}
    ${delta_json}    merge_JsonFiles    filename=${params_delta}    output_file_path=/home/ute/SCF/CNI_145514_parameter_modified_all.json
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007035_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Parameter maxParallelIncX2SetupOrECUOvl0 Modification
    [Arguments]    ${value}=10
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${maxParallelIncX2SetupOrECUOvl0}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1',
    ...    'parameter':'maxParallelIncX2SetupOrECUOvl0','value':'${value}'}
    ${update_param}     evaluate    [${maxParallelIncX2SetupOrECUOvl0}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0    check_on_air=${False}

Parameter maxParallelIncX2SetupOrECUOvl0 Modification on enb
    [Arguments]    ${value}=10
    Connect to eNB via ssl
    ${MRBTS_ID}    Set Variable    ${tl.enbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.enbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${maxParallelIncX2SetupOrECUOvl0}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}',
    ...    'parameter':'maxParallelIncX2SetupOrECUOvl0','value':'${value}'}
    ${update_param}     evaluate    [${maxParallelIncX2SetupOrECUOvl0}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0    check_on_air=${False}
    ...     connection=enblte
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param}
#    ...                                            timeout=${120}
#    ...                                            connection=enblte
#    ...                                            skip_parameter_relation_errors=${False}
    [Teardown]    Enblte close down

05437018_Parameter Modification
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${srPeriodicityDrb_drb13}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-13',
    ...    'parameter':'srPeriodicityDrb','value':'40ms'}
    ${cellAggrLevel_drb13}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-13',
    ...    'parameter':'cellAggrLevel','value':['FR1 CA incompatible']}
    ${srPeriodicityDrb_drb14}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-14',
    ...    'parameter':'srPeriodicityDrb','value':'80ms'}
    ${cellAggrLevel_drb14}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-14',
    ...    'parameter':'cellAggrLevel','value':['FR1 CA eligible']}
    ${update_param}     evaluate    [${srPeriodicityDrb_drb13},${cellAggrLevel_drb13},${srPeriodicityDrb_drb14},${cellAggrLevel_drb14}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

EDA05437018 add 5QI8
    ${return_code}    ${return_result}    drb_change    imsi=${tl.ues[${EDA05437018_CHOOSED_UE['${tl_prefix}']}].imsi}
    ...    rule=ADD-5QI8-VRF-YSJ
    run keyword if    '${return_result}' == 'Success'    run keywords
    ...    log    ${rule} operate Success!
    ...    AND    log to console    ${rule} operate Success!
    ...    ELSE    run keywords
    ...    log    ${rule} operate Failed!
    ...    AND    log to console    ${rule} operate Failed!
    ...    AND    fail    msg=need to check on SRN CHINA web page
    sleep    30s    reason=wait for QCI08 added

Record test_resultFor MultiBuild
    [Arguments]    ${test_result}    ${restore_path}=/home/ute/Compass_Report
    ${full_path}    create_kpi_report_directories    base_path=${restore_path}
    ...    subdirs=${TEST NAME}
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${0}    connection=GNB_OAM
    record_all_build_test_result_to_excel    build=${sw_version}    test_result=${test_result}
    ...    excel_path=${full_path}/test_result.xlsx
    [Return]    ${full_path}/test_result.xlsx

EDA05437018 Record TestResult And Compare UL Bler
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ul_ttitrace_before}
    ...            ${ul_ttitrace_after}
    ${ue_tputs_before}    calculate_ubler_and_ultput_for_ues    file_path=${ul_ttitrace_before}
    ${ue_tputs_after}    calculate_ubler_and_ultput_for_ues    file_path=${ul_ttitrace_after}
    ${ue_rnti_list_before}    Get Dictionary Keys    ${ue_tputs_before}
    ${ue_rnti_list_after}    Get Dictionary Keys    ${ue_tputs_after}
    FOR    ${rnti}    IN    @{ue_tputs_before}
        ${tput_before}    Set Variable    ${ue_tputs_before['${rnti}']['tput']}
        ${bler_before}    Set Variable    ${ue_tputs_before['${rnti}']['bler']}
    END
    FOR    ${rnti}    IN    @{ue_tputs_after}
        ${tput_after}    Set Variable    ${ue_tputs_after['${rnti}']['tput']}
        ${bler_after}    Set Variable    ${ue_tputs_after['${rnti}']['bler']}
    END
#    ${bler_before_number}    Convert To Number    ${bler_before}
#    ${bler_after_number}    Convert To Number    ${bler_after}
    ${test_result}    Create Dictionary    tput_before=${tput_before}   tput_after=${tput_after}
    ...     bler_before=${bler_before}    bler_after=${bler_after}
    ${output_file}    Record test_result For MultiBuild    test_result=${test_result}
    [Return]    ${output_file}

Update Cell Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    [Arguments]    ${cell_index}=301    ${administrativeState}=Locked    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=administrativeState    value=${administrativeState}
    @{param_list}    Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Counter M55110C00040
    [Arguments]    ${counter_generatd_time}
    ${bts_Name}    Get Bts Name For Gnb    gnb_id=${0}
    ${counters}    Catenate
    ...    {'M55110C00040': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NX2CB/X2_ENDC_CONF_UPDATE_REATT_SENT'}
    ${counter_info_dict_list}    Evaluate    [${counters}]
    ${counters_result_dict}    ${counter_info_dict_list}    Get BTS Counters Value Via WebUI
    ...    counter_info_dict_list=${counter_info_dict_list}    timeout=360
    ${counter_id_mapping_values}    Create Dictionary
    ${counter_items}    Get Dictionary Items    ${counter_info_dict_list}[0]
    ${timestamps}    Set Variable    ${counters_result_dict['${counter_items}[0]']}
    ${started_counter_timestamps}    Get Dictionary Keys    ${timestamps}
    FOR    ${started_counter_timestamp}   IN    @{started_counter_timestamps}
         ${ended_conuter_timestamp}    robot.libraries.DateTime.Add Time To Date    ${started_counter_timestamp}    00:05:00
         ${ended_time}    robot.libraries.DateTime.Convert Date    ${ended_conuter_timestamp}    Epoch
         ${started_time}    robot.libraries.DateTime.Convert Date    ${started_counter_timestamp}    Epoch
         ${status}    Run Keyword And Return Status    Should Be True
         ...          '${started_time}' <= '${counter_generatd_time}' <= '${ended_time}'
         ${counter_belonged_to_timestamp}    Set Variable    ${started_counter_timestamp}
         Exit For Loop If    '${status}'=='True'
    END
    FOR    ${counter_item}    IN    @{counter_info_dict_list}
        ${counter_id}    Get Dictionary Keys    ${counter_item}
        ${counter_timestamps}     Set Variable    ${counters_result_dict['${counter_id}[0]']}
        ${counter_value}    Set Variable    ${counter_timestamps['${counter_belonged_to_timestamp}']}
        ${counter_value_new}     Convert To Integer     ${counter_value}
        Run Keyword And Continue On Failure     Should Be True     ${counter_value_new}>${0}    msg=M55110C00040 is not >0.
    END

CB012474 Params modification
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    csn.reset_cache
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${update_params_delta}    coam_parameter.Create Update Parameters Delta     parameters=${CB012474_params_update}
    ...    connection=${connection}    timeout=600
    ${add_params_delta}    coam_parameter.create_add_parameters_delta     parameters=${CB012474_param_added}
    ...    connection=${connection}
    ${params_delta}    Create List    ${add_params_delta['updated']}    ${update_params_delta['updated']}
    log to console      update delta is :${params_delta}
    ${delta_json}    merge_JsonFiles    filename=${params_delta}    output_file_path=/home/ute/SCF/CB012474_parameter_modified_all.json
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    ...    connection=${connection}
#    run    rm -rf /home/ute/SCF/CB007163_parameter_modified_all.json
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check LNRELGNBCELL Object Existence
    [Arguments]    ${scf_path}
    ...            ${gnb_index}=${0}
    ...            ${status}=NotExist
    ...            ${gnbcell_index}=255
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    ${ret}    Grep File    ${scf_path}    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-1/LNRELGNBCELL-\\d+   regexp=True
    ${objects}    Get Regexp Matches      ${ret}      MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-1/LNRELGNBCELL-\\d+
    Run Keyword If    '${status}'=='NotExist'     List Should Not Contain Value    ${objects}
    ...    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-1/LNRELGNBCELL-${gnbcell_index}    msg=LNRELGNBCELL-${gnbcell_index} is not removed.
    ...    ELSE    List Should Contain Value     ${objects}    MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}1/LNCEL-1/LNRELGNBCELL-${gnbcell_index}
    ...    msg=LNRELGNBCELL-${gnbcell_index} is not added.

CB007344_Repeat_Remove_Add_LNRELGNBCELL
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
        FOR    ${item}    IN RANGE    ${9}
        Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        Sleep    20sec
        Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${ue_type}
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    END
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${add_scf_file}    Run Keyword And Continue On Failure    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Check LNRELGNBCELL Object Existence    scf_path=${add_scf_file}     status=Exist
    ...            gnbcell_index=255
    log to console  INFO:--start to send 254 B1-NR-
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${30}
    FOR    ${item}    IN RANGE    ${13}
        Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        Sleep    20sec
        Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${ue_type}
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Sleep   2min
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${remove_scf_file}    Run Keyword And Continue On Failure    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Run Keyword And Continue On Failure    Check LNRELGNBCELL Object Existence    scf_path=${remove_scf_file}

Parameter anrNrNbrRelRemGuardTime Modification
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    Log To Console    \n***start to modify parameters***
    ${anrNrNbrRelRemGuardTime}    catenate   {'dist_name':'MRBTS-816/LNBTS-8161/ANR-0',
    ...    'parameter':'anrNrNbrRelRemGuardTime','value':'2'}
    ${update_param}     evaluate    [${anrNrNbrRelRemGuardTime}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0    check_on_air=${False}

DL.Multi UE Burst Traffic
    [Arguments]    ${run_script_path}=/home/vrf4_sg6/5605005/${tl_prefix}
    ...            ${test_model_sh_script_path}=/home/vrf4_sg6/5605005/${tl_prefix}/7UE_DL_Burst/
    ...            ${round}=${13}
#    Reproduce_5605005.Start Brust DL UDP Traffic
#    ...       run_script_path=${run_script_path}
#    ...       test_model_sh_script_path=${test_model_sh_script_path}
#    ${sleep_time}    Set Variable If    '${tl_prefix}'=='T073'    12600
#    ...                                 '${tl_prefix}'=='T813'    14400
#    ...                                 '${tl_prefix}'=='T080'    14400
#    ${burst_dl_timestamps}     Create List
#    ${burst_call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#    ${burst_call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${start_syslog_burst}    Get Syslog Formatted Time
#    Sleep    1h
#    ${end_syslog_burst}    Get Syslog Formatted Time
#    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
#    ...    syslog_start_time=${start_syslog_burst}
#    ...    syslog_end_time=${end_syslog_burst}
#    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
#    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
#    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
#    Run Keyword And Continue On Failure    Check ERR Syslog Existed
#    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${diff_time}    Subtract Date From Date    ${current_time}    ${burst_call_start_time}
#    log to console     syslog check spend time:${diff_time}
#    ${duration}    Evaluate   ${sleep_time}-${diff_time}-3600
#    Sleep     ${duration}sec
#    ${burst_call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#    ${burst_call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#    ${burst_report_timestamp}     Create List    ${burst_call_start_time}    ${burst_call_end_time}
#    Append to List    ${burst_dl_timestamps}   ${burst_report_timestamp}
    ${burst_dl_timestamps}     Create List
    ${burst_call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${burst_call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    FOR    ${round}     IN RANGE    ${round}
        Log to console    start round-${round} DL burst traffic
        Run Keyword And Ignore Error
        ...    Reproduce_5605005.Stop Brust DL UDP Traffic     run_script_path=${run_script_path}
        ${start_syslog_burst}    Get Syslog Formatted Time
        Reproduce_5605005.Start Brust DL UDP Traffic
        ...       run_script_path=${run_script_path}
        ...       test_model_sh_script_path=${test_model_sh_script_path}
        Sleep    30min
        ${end_syslog_burst}    Get Syslog Formatted Time
#        Reproduce_5605005.Stop Brust DL UDP Traffic     run_script_path=${run_script_path}
    END
    ${burst_call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${burst_call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${burst_report_timestamp}     Create List    ${burst_call_start_time}    ${burst_call_end_time}
    Append to List    ${burst_dl_timestamps}   ${burst_report_timestamp}
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_syslog_burst}
    ...    syslog_end_time=${end_syslog_burst}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Return]    ${burst_dl_timestamps}
    [Teardown]    Run Keyword And Ignore Error    Reproduce_5605005.Stop Brust DL UDP Traffic     run_script_path=${run_script_path}

T813.KPI Test With DL Burst Traffic
    ######-----8UE INFO In Init File: UE0(QC X85),UE1(QC X65),UE4-UE9(DingLI)-----#######
    #####----UEs Prepare----####
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    ${ue1_type}    translate_power_ue_type_from_testline    ue_index=${1}
    Set Test Variable    ${ue0_type}
#    Set Test Variable    ${ue1_type}
    power_ue.Prepare UE    ue_index=${0}   ue_type=${ue0_type}    get_spark_license=${False}
##    power_ue.Prepare UE    ue_index=${1}   ue_type=${ue1_type}    get_spark_license=${False}
    DingLi_Client.UE Prepare    ue_index=${4}    ues_index=${${0},${1},${2},${3},${4},${5}}
    Log to console    start DL burst traffic before attach
    Run Keyword And Ignore Error    Reproduce_5605005.Start Brust DL UDP Traffic
    ...       test_model_sh_script_path=/home/vrf4_sg6/5605005/${tl_prefix}/7UE_DL_Burst/
    #####----UEs Attach----####
#    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${300}
#    sleep    15sec
#    DingLi_Client.SA And NSA Mode Change    UE_mode=5G_SA     ues_index=${${0},${1},${2},${3},${4},${5}}
#    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach Without Get UE IP
#    ...    ues_index=${${0},${1},${2},${3},${4},${5}}
#    ...    UE_mode=5G_SA
    DingLi_Client.Power Off And Power On Without Get UEIP    ues_index=${${0},${1},${2},${3},${4},${5}}
#    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=Ding UE attach failed.
    power_ue.UE Attach    ue_type=${ue0_type}    ue_index=${0}
##    power_ue.UE Attach    ue_type=${ue1_type}    ue_index=${1}
    #####----DO KPI TESTING----####
    Sleep  5min
    ${burst_dl_timestamps}    DL.Multi UE Burst Traffic
    ...    test_model_sh_script_path=/home/vrf4_sg6/5605005/${tl_prefix}/7UE_DL_Burst/
    [Return]    ${burst_dl_timestamps}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue0_type}    ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}
    ...    AND    Run Keyword And Ignore Error    DingLi_Client.Detach    ues_index=${${0},${1},${2},${3},${4},${5}}

T080.KPI Test With DL SFTP
    ${multi_ue_prepare_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
    ...    '${tl_prefix}'=='T080'    ${${19},${20},${21},${22},${23},${24},${25},${26}}
    Perform Mutli-UE Prepare    ues_index=${multi_ue_prepare_indexs}
    ${sleep_time}    Set Variable If    '${tl_prefix}'=='T073'    10800
    ...       '${tl_prefix}'=='T080'    12600
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=301
    ...    connection=GNB_OAM    timeout=300
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ${multi_ue_attach_indexs}   Set Variable If     '${tl_prefix}'=='T073'    ${${15},${16},${17},${18},${19},${20},${21},${22}}
    ...    '${tl_prefix}'=='T080'    ${${19},${20},${22},${23},${24},${25},${26}}
    run keyword and ignore error    Perform Mutli-UE Start Log
    ...     ues_index=${multi_ue_attach_indexs}
    Perform Mutli-UE Attach    ues_index=${multi_ue_attach_indexs}
    Perform Import TestPlan    ues_index=${multi_ue_attach_indexs}
    Sleep    10min
    ${report_timestamps}    Create List
    ${call_start_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_start_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${start_syslog_burst}    Get Syslog Formatted Time
    Sleep    30min
    ${end_syslog_burst}    Get Syslog Formatted Time
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_syslog_burst}
    ...    syslog_end_time=${end_syslog_burst}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${current_time}    ${call_start_time}
    log to console     syslog check spend time:${diff_time}
    ${duration}    Evaluate   ${sleep_time}-${diff_time}
    log to console     start to sleep:${duration}sec
    Sleep     ${duration}sec
    ${start_time_syslog}    Get Syslog Formatted Time
    Sleep    30min
    ${end_time_syslog}    Get Syslog Formatted Time
    ${call_end_time_UTC}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${call_end_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamp}     Create List    ${call_start_time}    ${call_end_time}
    Append to List    ${report_timestamps}   ${report_timestamp}
    run keyword and ignore error    Perform Mutli-UE Stop Log
    ...     ues_index=${multi_ue_attach_indexs}
    Perform Mutli-UE Disconnect    ues_index=${multi_ue_attach_indexs}
    ${syslog_file}    Run Keyword And Continue On Failure    Get syslog file with duration and Compress File
    ...    syslog_start_time=${start_time_syslog}
    ...    syslog_end_time=${end_time_syslog}
    ${syslog_file_path}    Run Keyword And Continue On Failure    Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=120 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Return]    ${report_timestamps}