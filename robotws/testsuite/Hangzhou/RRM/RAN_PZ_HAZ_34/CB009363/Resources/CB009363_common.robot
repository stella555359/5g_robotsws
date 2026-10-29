*** Settings ***
Documentation    This is for feature CB009363 related common keywords.
...              Please do not modify the file without notification to author
...              Author:stella.lin@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Check PatternId In UlData_PuschReceiveReq
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${patternId_values_list}    Get Field Value From PCAP    field_name=UlData_eCpriConfigStruct_t.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
#        ${length}    Get Length    ${patternId_values}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${4}    msg=patterid IE not have 4 items.
        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values} if int(x)==${0} or len(${patternId_values})!=${4}]
        ${length}    Get Length    ${patternId_equal_to_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the patternId is equal to 0.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.01}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,equal to 0

Check Rxpower And Sinr In UlData_PuschReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceiverespps
    ${rxpower_values_list}    Get Field Value From PCAP    field_name=UlData_puschAntMeas_t.rxPowerOfAnt
    ...                                                    filter_expression=${filter_with_subcell}
    ${sinr_values_list}    Get Field Value From PCAP    field_name=UlData_puschAntMeas_t.sinrOfAnt
    ...                                                 filter_expression=${filter_with_subcell}
    ${rxpower_values_length}    Get Length    ${rxpower_values_list}
    Should Be True    ${rxpower_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rx_power_invalid}    Set Variable    ${0}
    ${ant_sinr_invalid}    Set Variable    ${0}
    FOR    ${rxpower_values}   IN    @{rxpower_values_list}
        ${length}    Get Length    ${rxpower_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=rxpower IE not have 8 items.
        ${rxpower_below_110}    Evaluate    [x for x in ${rxpower_values} if abs(float(x))>abs(float(-120))]
        ${length}    Get Length    ${rxpower_below_110}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}    msg=${length} items of the rxpower is below -110.
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}
        ...     msg=${length} items of the rxpower is below -120.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${rx_power_invalid}    Evaluate    ${rx_power_invalid}+${flag}
    END
    FOR    ${sinr_values}   IN    @{sinr_values_list}
        ${length}    Get Length    ${sinr_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=rxpower IE not have 8 items.
        ${sinr_below_zero}    Evaluate    [x for x in ${sinr_values} if float(x)<=${0}]
        ${length}    Get Length    ${sinr_below_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the sinr is below zero.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${ant_sinr_invalid}    Evaluate    ${ant_sinr_invalid}+${flag}
    END
    ${rx_power_invalid_ratio}    Evaluate    ${rx_power_invalid}/${rxpower_values_length}
    ${ant_sinr_invalid_ratio}    Evaluate    ${ant_sinr_invalid}/${rxpower_values_length}
    Run Keyword And Continue On Failure    Should Be True   ${rx_power_invalid_ratio}<=0.015
    ...    msg=${rx_power_invalid_ratio} percent of the rxpower is invalid ,below -110.
    Run Keyword And Continue On Failure    Should Be True    ${ant_sinr_invalid_ratio}<=0.015
    ...    msg=${ant_sinr_invalid_ratio} percent of the ant sinr is invalid, below zero.

Check DTX And CRC Based On PUCCH Format
    [Arguments]    ${file_path}
    ...            ${subcell_id}
    ...            ${pucch_format}=3
    ...            ${uldata_pucchreceiverespps}=uldata_pucchreceiverespps
    ...            ${UlData_pucchReceiveRespPsPucchResource_t}=UlData_pucchReceiveRespPsPucchResource_t
#    ${rnti}    Get UE Rnti From BIP    file_path=${file_path}    subcell_id=${subcell_id}
    ${pcuuchformat1}    Set Variable    ${UlData_pucchReceiveRespPsPucchResource_t}.pucchFormat == 1
    ${pcuuchformat3}    Set Variable    ${UlData_pucchReceiveRespPsPucchResource_t}.pucchFormat == 3
    ${filter_with_subcell_and_pucch_format}    Set Variable If   '${pucch_format}'=='3'
    ...    3gpp.subcellid==${subcell_id} && ${pcuuchformat3}
    ...    '${pucch_format}'=='13'    3gpp.subcellid==${subcell_id} && ${pcuuchformat3} || ${pcuuchformat1}
    ...    '${pucch_format}'=='1'    3gpp.subcellid==${subcell_id} && ${pcuuchformat1}
    Setup Pcap File   file_path=${file_path}    filter=${uldata_pucchreceiverespps}
    ${pucch_format_values_list_tmp}    Get Field Value From PCAP    field_name=${UlData_pucchReceiveRespPsPucchResource_t}.pucchFormat
    ...                                                             filter_expression=3gpp.subcellid==${subcell_id}
    @{pucch_format_values_list}    Remove Duplicates    ${pucch_format_values_list_tmp}
    @{compare_pucchformat13_list}    Evaluate    [['1'],['3']]
    @{compare_pucchformat3_list}    Evaluate    [['3']]
    @{compare_format}    Set Variable If    '${pucch_format}'=='3'    ${compare_pucchformat3_list}    ${compare_pucchformat13_list}
    ${diff}    Evaluate    [x for x in ${compare_format} if x not in ${pucch_format_values_list}]
    ${length}    Get Length    ${diff}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${length}    ${0}
    ...    msg=pucch format ${diff} are not included under specific traffic.
    ${crc_values_list}    Get Field Value From PCAP    field_name=${UlData_pucchReceiveRespPsPucchResource_t}.crc
    ...                                                filter_expression=${filter_with_subcell_and_pucch_format}
    ${dtx_values_list}    Get Field Value From PCAP    field_name=${UlData_pucchReceiveRespPsPucchResource_t}.dtx
    ...                                                filter_expression=${filter_with_subcell_and_pucch_format}
    ${crc_length}    Get Length    ${crc_values_list}
    Should Be True    ${crc_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${crc_invalid}    Set Variable    ${0}
    ${dtx_invalid}    Set Variable    ${0}
    FOR    ${crc_values}   IN    @{crc_values_list}
        ${crc_nok}    Evaluate    [x for x in ${crc_values} if float(x)!=${0}]
        ${length}    Get Length    ${crc_nok}
        ${pucch_format_display}    Set Variable If    '${pucch_format}'=='13'    1_PUCCH_FORMAT_3    3
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}    msg=CRC NOK under PUCCH_PORMAT_${pucch_format_display}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}
        ...     msg=CRC NOK under PUCCH_PORMAT_${pucch_format_display}
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${crc_invalid}    Evaluate    ${crc_invalid}+${flag}
    END
    FOR    ${dtx_values}   IN    @{dtx_values_list}
        ${non_dtx}    Evaluate    [x for x in ${dtx_values} if float(x)!=${0}]
        ${length}    Get Length    ${non_dtx}
        ${pucch_format_display}    Set Variable If    '${pucch_format}'=='13'    1_PUCCH_FORMAT_3    3
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}    msg=DTX under PUCCH_PORMAT_${pucch_format_display}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}
        ...     msg=CRC NOK under PUCCH_PORMAT_${pucch_format_display}
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${dtx_invalid}    Evaluate    ${dtx_invalid}+${flag}
    END
    ${crc_invalid_ratio}    Evaluate    ${crc_invalid}/${crc_length}
    ${dtx_invalid_ratio}    Evaluate    ${dtx_invalid}/${crc_length}
    ${pucch_format_display}    Set Variable If    '${pucch_format}'=='13'    1_PUCCH_FORMAT_3    3
    Run Keyword And Continue On Failure    Should Be True     ${crc_invalid_ratio}<=0.1
    ...    msg=CRC NOK under PUCCH_PORMAT_${pucch_format_display}, RATIO is ${crc_invalid_ratio}
    Run Keyword And Continue On Failure    Should Be True     ${dtx_invalid_ratio}<=0.1
    ...    msg=DTX under PUCCH_PORMAT_${pucch_format_display}, RATIO is ${dtx_invalid_ratio}

Used BIP File Rename
    [Arguments]    ${bip_file_path}
    ${path_prefix}    Fetch From Left    ${bip_file_path}    fct_L2L1
    ${new_bip_file_path}    Join Path    ${path_prefix}    l2l2_Bip_used.pcap
    copy file    ${bip_file_path}    ${new_bip_file_path}
    [Return]    ${new_bip_file_path}

Check PUSCHTransformPrecoder Enabled
    [Arguments]    ${file_path}    ${subcell_id}    ${enable_disable_flag}=1
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${puschTransformPrecoder_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
    ...                                                            filter_expression=${filter_with_subcell}
    ${puschTransformPrecoder_values_length}    Get Length    ${puschTransformPrecoder_list}
    Should Be True    ${puschTransformPrecoder_values_length} >${1}    msg=no valid data filter out.please check the bip log.
    ${disable}    Set Variable    ${0}
    FOR    ${puschTransformPrecoder_values}   IN    @{puschTransformPrecoder_list}
        ${enable_disable_flag}    Convert To String    ${enable_disable_flag}
        ${state}    Set Variable If    '${enable_disable_flag}'=='1'    enable    disable
        ${status}     Run Keyword And Return Status    Should Be Equal As Integers
        ...    ${puschTransformPrecoder_values[0]}    ${enable_disable_flag}    msg=puschTransformPrecoder is not ${state}.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${disable}    Evaluate    ${disable}+${flag}
    END
    ${disable_ratio}    Evaluate    ${disable}/${puschTransformPrecoder_values_length}
    ${state}    Set Variable If    '${enable_disable_flag}'=='1'    enable    disable
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${disable_ratio}   0
    ...    msg=PUSCHTransformPrecoder is not ${state} , RATIO is ${disable_ratio}

Update ulTransPrecodeSinrThresh Related Params
    [Arguments]    ${cell_index}=3    ${on_thresh}=180    ${off_thresh}=200
    Log To Console    \n***start to update ulTransPrecodeSinrThresh***
    ${update_thresh_param}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'ulTransPrecodeCtl','value':[{'ulTransPrecodeOnSinrThresh':'${on_thresh}',
    ...    'ulTransPrecodeOffSinrThresh':'${off_thresh}'}]}
    ${update_param}     evaluate    [${update_thresh_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Check Vaild Values In UlData_PuschReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}    ${expect_sinr}=20
    Log Many    ${subcell_id}    ${expect_sinr}
    ${filter_expression}    Catenate    (uldata_puschreceiverespps) && (3gpp.subcellid == 0) && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    pcap.setup    infile=${file_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${rxpower_values_list}    pcap.get_field_value    field_name=UlData_puschAntMeas_t.rxPowerOfAnt
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${ant_sinr_values_list}    pcap.get_field_value    field_name=UlData_puschAntMeas_t.sinrOfAnt
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${sinr_values_list}    pcap.get_field_value    field_name=UlData_UePuschReceiveRespPs_t.sinr_item
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${rxpower_values_length}    Get Length    ${rxpower_values_list}
    Should Be True    ${rxpower_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rx_power_invalid}    Set Variable    ${0}
    ${ant_sinr_invalid}    Set Variable    ${0}
    FOR    ${rxpower_values}   IN    @{rxpower_values_list}
        ${length}    Get Length    ${rxpower_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=rxpower IE not have 8 items.
        ${invalid_rxpower}    Evaluate    [x for x in ${rxpower_values} if abs(float(x))==abs(float(-255))]
        ${length}    Get Length    ${invalid_rxpower}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${8}
        ...     msg=8 items of the rxpower is invalid -255
        ${flag}    Set Variable If    '${status}'=='${True}'    ${1}    ${0}
        ${rx_power_invalid}    Evaluate    ${rx_power_invalid}+${flag}
    END
    FOR    ${ant_sinr_values}   IN    @{ant_sinr_values_list}
        ${length}    Get Length    ${ant_sinr_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=rxpower IE not have 8 items.
        ${invalid_sinr}    Evaluate    [x for x in ${ant_sinr_values} if abs(float(x))==abs(float(-255))]
        ${length}    Get Length    ${invalid_sinr}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${8}    msg=8 items of the sinr is invalid -255
        ${flag}    Set Variable If    '${status}'=='${True}'    ${1}    ${0}
        ${ant_sinr_invalid}    Evaluate    ${ant_sinr_invalid}+${flag}
    END
#    FOR    ${sinr_values}   IN    @{sinr_values_list}
#        ${invalid_sinr}    Evaluate    [x for x in ${sinr_values} if abs(float(x))>=abs(float(20))]
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}
#        ...    msg=sinr above ${expect_sinr} exist, please adjust the PA value.
#    END
    ${rx_power_invalid_ratio}    Evaluate    ${rx_power_invalid}/${rxpower_values_length}
    ${ant_sinr_invalid_ratio}    Evaluate    ${ant_sinr_invalid}/${rxpower_values_length}
    Run Keyword And Continue On Failure    Should Be True     ${rx_power_invalid_ratio}<=0.015
    ...    msg=${rx_power_invalid_ratio} percent of the rxpower is invalid -255
    Run Keyword And Continue On Failure    Should Be True    ${ant_sinr_invalid_ratio}<=0.015
    ...    msg=${ant_sinr_invalid_ratio} percent of the ant sinr is invalid -255

Check Values On UlData_SrsReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceiverespps
    ${rxpower_values_list}    Get Field Value From PCAP    field_name=UlData_srsAntMeas_t.rxPowerOfAnt
    ...                                                    filter_expression=${filter_with_subcell}
    ${ant_sinr_values_list}    Get Field Value From PCAP    field_name=UlData_srsAntMeas_t.sinrOfAnt
    ...                                                     filter_expression=${filter_with_subcell}
    ${ul_rank_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveRespPsUes_t.ulRank
    ...                                             filter_expression=${filter_with_subcell}
    ${rxpower_values_length}    Get Length    ${rxpower_values_list}
    Should Be True    ${rxpower_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rx_power_invalid}    Set Variable    ${0}
    ${ant_sinr_invalid}    Set Variable    ${0}
    ${rank_invalid}    Set Variable    ${0}
    FOR    ${rxpower_values}   IN    @{rxpower_values_list}
        ${length}    Get Length    ${rxpower_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=rxpower IE not have 8 items.
        ${invalid_rxpower}    Evaluate    [x for x in ${rxpower_values} if abs(float(x))==abs(float(-255))]
        ${length}    Get Length    ${invalid_rxpower}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${8}
        ...     msg=8 items of the rxpower is invalid -255
        ${flag}    Set Variable If    '${status}'=='${True}'    ${1}    ${0}
        ${rx_power_invalid}    Evaluate    ${rx_power_invalid}+${flag}
    END
    FOR    ${ant_sinr_values}   IN    @{ant_sinr_values_list}
        ${length}    Get Length    ${ant_sinr_values}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=rxpower IE not have 8 items.
        ${invalid_sinr}    Evaluate    [x for x in ${ant_sinr_values} if abs(float(x))==abs(float(-255))]
        ${length}    Get Length    ${invalid_sinr}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${8}    msg=8 items of the sinr is invalid -255
        ${flag}    Set Variable If    '${status}'=='${True}'    ${1}    ${0}
        ${ant_sinr_invalid}    Evaluate    ${ant_sinr_invalid}+${flag}
    END
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${ul_not_rank1}    Evaluate    [x for x in ${ul_rank} if int(x)!=${1}]
        ${length}    Get Length    ${ul_not_rank1}
        ${status}     Run Keyword And Return Status     Should Be True    ${length}==${0}
        ...    msg=not all the rank is equal to rank1 on UlData_SrsReceiveRespPs.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${rank_invalid}    Evaluate    ${rank_invalid}+${flag}
    END
    ${rx_power_invalid_ratio}    Evaluate    ${rx_power_invalid}/${rxpower_values_length}
    ${ant_sinr_invalid_ratio}    Evaluate    ${ant_sinr_invalid}/${rxpower_values_length}
    ${rank_invalid_ratio}    Evaluate    ${rank_invalid}/${rxpower_values_length}
    Run Keyword And Continue On Failure    Should Be True     ${rx_power_invalid_ratio}<=0.015
    ...    msg=${rx_power_invalid_ratio} percent of the rxpower is invalid -255
    Run Keyword And Continue On Failure    Should Be True    ${ant_sinr_invalid_ratio}<=0.015
    ...    msg=${ant_sinr_invalid_ratio} percent of the ant sinr is invalid -255
    Run Keyword And Continue On Failure    Should Be True    ${rank_invalid_ratio}<=0.8
    ...    msg=${rank_invalid_ratio} percent of the rank is not rank1

Check UL Rank On UlData_PuschReceiveRespPs
    [Arguments]    ${file_path}    ${subcell_id}    ${expect_rank}=2
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id} && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceiverespps
    ${ul_rank_list}    Get Field Value From PCAP    field_name=UlData_UePuschReceiveRespPs_t.ulRank
    ...                                             filter_expression=${filter_with_subcell}
    ${ul_rank_length}    Get Length    ${ul_rank_list}
    Should Be True    ${ul_rank_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rank_invalid}    Set Variable    ${0}
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${error_rank}    Evaluate    [x for x in ${ul_rank} if int(x)!=int(${expect_rank})]
        ${length}    Get Length    ${error_rank}
        ${status}     Run Keyword And Return Status     Should Be True    ${length}==${0}
        ...    msg=not all the rank is equal to rank${expect_rank} on UlData_PuschReceiveRespPs.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${rank_invalid}    Evaluate    ${rank_invalid}+${flag}
    END
    ${rank_invalid_ratio}    Evaluate    ${rank_invalid}/${ul_rank_length}
    Run Keyword And Continue On Failure    Should Be True    ${rank_invalid_ratio}<=0.01
    ...    msg=${rank_invalid_ratio} percent of the rank is not rank${expect_rank}

Check UL Rank On UlData_PuschReceiveReq
    [Arguments]    ${file_path}    ${subcell_id}    ${expect_rank}=2
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id} && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${ul_rank_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrant_t.numOfLayers
    ...                                             filter_expression=${filter_with_subcell}
    ${ul_rank_length}    Get Length    ${ul_rank_list}
    Should Be True    ${ul_rank_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${rank_invalid}    Set Variable    ${0}
    FOR    ${ul_rank}   IN    @{ul_rank_list}
        ${error_rank}    Evaluate    [x for x in ${ul_rank} if int(x)!=int(${expect_rank})]
        ${length}    Get Length    ${error_rank}
        ${rank_invalid}    Evaluate    ${rank_invalid}+${length}
    END
    ${rank_invalid_precent}    Evaluate    ${rank_invalid}/${ul_rank_length}
    Run Keyword And Continue On Failure    Should Be True    ${rank_invalid_precent}<0.02
    ...    msg=ul rank has expect rank on UlData_PuschReceiveReq, the precent is ${rank_invalid_precent}.

Check UlData_SrsReceiveReq Exist
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceivereq
    ${test_value_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqUes_t.startPrb
    ...                                             filter_expression=${filter_with_subcell}
    ${test_length}    Get Length    ${test_value_list}
    Should Be True    ${test_length}>${1}    msg=no message : UlData_SrsReceiveReq

Check PBoost Value On Cell Edge
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${pboost_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrant_t.pBoost
    ...                                             filter_expression=${filter_with_subcell}
    ${pboost_length}    Get Length    ${pboost_list}
    Should Be True    ${pboost_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${pboost}   IN    @{pboost_list}
        ${pboost_not_above_zero}    Evaluate    [x for x in ${pboost} if float(x)<=${0}]
        ${length}    Get Length    ${pboost_not_above_zero}
        Run Keyword And Continue On Failure    Should Be True    ${length}==${0}
        ...    msg=pBoost is not above zero ,actual is ${pboost}.
    END

Change 8Rx To 4Rx Via WebUI
    COAM Navigate to login page via webUI   download_dir= ${TS_CASE_LOG_PATH}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console  start to change cell1 to 16D8U numberOfRxBeamforming 8RX/ numberOfRxPucch=8RX
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=16DL8UL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=8Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=8Rx
    log to console  start to change cell3 to 8D4U numberOfRxBeamforming 4RX/ numberOfRxPucch=4RX
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL4UL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=4Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=4Rx
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-3    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-4    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-9
    ...    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-10
    ...    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-11
    ...    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-12
    ...    timeout=15
    log to console  start to change cell2 to 8D8U numberOfRxBeamforming 8RX/ numberOfRxPucch=4RX
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL8UL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=8Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=4Rx
#    log to console  start to change cell2 to 8D8U(2*4RX)
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL8UL
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=4Rx
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=4Rx
#    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-3    timeout=15
#    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-4    timeout=15
#    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-9
#    ...    timeout=15
#    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-10
#    ...    timeout=15
#    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-11
#    ...    timeout=15
#    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-12
#    ...    timeout=15
#    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
#    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
#    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5
#    ...    include_subobject=${True}   id_value=5    timeout=15
#    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
#    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
#    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5
#    ...    include_subobject=${True}   id_value=6    timeout=15
#    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
#    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
#    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5
#    ...    include_subobject=${True}   id_value=7    timeout=15
#    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
#    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
#    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5
#    ...    include_subobject=${True}   id_value=8    timeout=15
    log to console  start to validate and activate
    selenium_coam.validate_plan    timeout=240
    selenium_coam.activate_plan    timeout=300
    Sleep   60 sec
    log to console  activate done!wait for gnb on air......
    Connect to gnb coam via ssl    connection=GNB_OAM0   gnb_index=0
    Wait Gnb Ready And Cell On Air    timeout=30 min    connection=GNB_OAM0
    [Teardown]  Run Keywords    Run Keyword And Ignore Error      COAM Teardown gnb connections    connection=GNB_OAM0    AND
    ...   Run Keyword And Ignore Error    COAM selenium logout

Change 8Rx To 4Rx Via WebUI On Trunk
    COAM Navigate to login page via webUI   download_dir= ${TS_CASE_LOG_PATH}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console  start to change cell2 to 8D8U numberOfRxBeamforming 8RX/ numberOfRxPucch=4RX
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL8UL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=8Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=4Rx

    log to console  start to change cell3 to 8D4U numberOfRxBeamforming 4RX/ numberOfRxPucch=4RX
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL4UL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=4Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=4Rx

    log to console  start to change cell4 to 8D8U numberOfRxBeamforming 8RX/ numberOfRxPucch=4RX
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL8UL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ...    filter_param=Number of Rx beamforming    abbr=numberOfRxBeamforming    new_value=8Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ...    filter_param=Number of Rx PUCCH    abbr=numberOfRxPucch    new_value=4Rx


    log to console  start to validate and activate
    selenium_coam.validate_plan    timeout=240
    selenium_coam.activate_plan    timeout=300
    Sleep   60 sec
    log to console  activate done!wait for gnb on air......
    Connect to gnb coam via ssl    connection=GNB_OAM0   gnb_index=0
    Wait Gnb Ready And Cell On Air    timeout=30 min    connection=GNB_OAM0
    [Teardown]  Run Keywords    Run Keyword And Ignore Error      COAM Teardown gnb connections    connection=GNB_OAM0    AND
    ...   Run Keyword And Ignore Error    COAM selenium logout

Check eAXCId And PatternId In UlData_PucchReceiveReq
    [Arguments]    ${file_path}
    ...            ${subcell_id}
    ...            ${uldata_pucchreceivereq}=uldata_pucchreceivereq
    ...            ${UlData_pucchReceiveReqPucchResource_t}=UlData_pucchReceiveReqPucchResource_t
#    ${rnti}    Get UE Rnti From BIP    file_path=${file_path}    subcell_id=${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=${uldata_pucchreceivereq}
    ${patternId_values_list}    Get Field Value From PCAP    field_name=${UlData_pucchReceiveReqPucchResource_t}.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
        ${length}    Get Length    ${patternId_values}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${4}    msg=patterid IE not have 4 items.
        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values} if int(x)==${0} or len(${patternId_values})!=${4}]
        ${length}    Get Length    ${patternId_equal_to_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the patternId is equal to 0.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.1}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,equal to 0
    ${eAxcId_values_list}    Get Field Value From PCAP    field_name=${UlData_pucchReceiveReqPucchResource_t}.ceAxCIndex_item
    ...                                                   filter_expression=${filter_with_subcell}
    ${eAxcId_invalid}    Set Variable    ${0}
    FOR    ${eAxcId_values}   IN    @{eAxcId_values_list}
#        ${length}    Get Length    ${eAxcId_values}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${8}    msg=eAxcid IE not have 8 items.
        ${compare_list}    Create List    0  1  2  3  4  5  6  7
        ${status}     Run Keyword And Return Status    lists should be equal    ${eAxcId_values}    ${compare_list}
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${eAxcId_invalid}    Evaluate    ${eAxcId_invalid}+${flag}
    END
    ${eAxcId_invalid_ratio}    Evaluate    ${eAxcId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${eAxcId_invalid_ratio}<=${0.1}
    ...    msg=${eAxcId_invalid_ratio} percent of the eAxcId is invalid ,equal to 0

Check Pattern ID In uldata_srsreceivereq
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceivereq
    ${patternId_values_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqUes_t.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
#        ${length}    Get Length    ${patternId_values}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${4}    msg=patterid IE not have 4 items.
#        ${pattern_len}    Set Variable If    '${STREAM_VERSION}'=='master'    ${8}
#        ...                                  '${STREAM_VERSION}'=='24R2'   ${4}
#        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values[0:4]} if int(x)==${0} or len(${patternId_values})!=${pattern_len}]
        ${patternId_equal_to_zero}    Evaluate    [x for x in ${patternId_values[0:4]} if int(x)==${0}]
        ${length}    Get Length    ${patternId_equal_to_zero}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}    msg=${length} items of the patternId is equal to 0.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.01}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,equal to 0

Update Refine Beam Related Params
    [Arguments]    ${cell_index}=1    ${nrBtsBeamRefinementP2}=false   ${actUlSrsBm}=true
    Log To Console    \n***start to update nrBtsBeamRefinementP2***
    ${update_nrBtsBeamRefinementP2}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'beamSet','value':[{'nrBtsBeamRefinementP2':'${nrBtsBeamRefinementP2}'}]}
    ${update_actUlSrsBm}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'actUlSrsBm','value':'${actUlSrsBm}'}
    ${update_param}     evaluate    [${update_nrBtsBeamRefinementP2},${update_actUlSrsBm}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Check PatternId With Refine Beam In UlData_PuschReceiveReq
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${patternId_values_list}    Get Field Value From PCAP    field_name=UlData_eCpriConfigStruct_t.patternId_item
    ...                                                      filter_expression=${filter_with_subcell}
    ${patternId_values_length}    Get Length    ${patternId_values_list}
    Should Be True    ${patternId_values_length}>${1}    msg=no valid data filter out.please check the bip log.
    ${patternId_invalid}    Set Variable    ${0}
    FOR    ${patternId_values}   IN    @{patternId_values_list}
#        ${length}    Get Length    ${patternId_values}
#        Run Keyword And Continue On Failure    Should Be True    ${length}==${4}    msg=patterid IE not have 4 items.
        ${patternId_below_1000}    Evaluate    [x for x in ${patternId_values} if int(x)>=${1000} or len(${patternId_values})!=${4}]
        ${length}    Get Length    ${patternId_below_1000}
        ${status}     Run Keyword And Return Status    Should Be True    ${length}==${0}
        ...    msg=${length} items of the patternId is below 1000.
        ${flag}    Set Variable If    '${status}'=='${False}'    ${1}    ${0}
        ${patternId_invalid}    Evaluate    ${patternId_invalid}+${flag}
    END
    ${patternId_invalid_ratio}    Evaluate    ${patternId_invalid}/${patternId_values_length}
    Run Keyword And Continue On Failure    Should Be True    ${patternId_invalid_ratio}<=${0.01}
    ...    msg=${patternId_invalid_ratio} percent of the patternId is invalid ,above 1000

Check eAXCId In UlData_PuschReceiveReq
    [Arguments]    ${file_path}    ${subcell_id}    ${ue_numbers}=2
    ${item_length}     Set Variable If    '${ue_numbers}'=='2'    2
    ...                                    4
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceivereq
    ${rnti_list_values}    Get Field Value From PCAP    field_name=_3gpp.rnti
    ...                                                 filter_expression=${filter_with_subcell}
    ${eAxcId_values_list}    Get Field Value From PCAP    field_name=UlData_eCpriConfigStruct_t.ceAxCIndex_item
    ...                                                   filter_expression=${filter_with_subcell}
    ${eAxcId_values_length}    Get Length    ${eAxcId_values_list}
    Should Be True    ${eAxcId_values_length}>${1}    msg=no message UlData_PuschReceiveReq filter out.
    ${ue_numbers}    Convert To Integer    ${ue_numbers}
    ${eAxcId_invalid}    Set Variable    ${0}
    ${index}    Set Variable    ${0}
    FOR    ${eAxcId_values}   IN    @{eAxcId_values_list}
        ${rnti_number}    Set Variable If    '${ue_numbers}'=='2'    2    4
        ${condition}    Set Variable If    '${ue_numbers}'=='2'
        ...    index == 0 or index == 1 or index == 2 or index == 3 or index == 8 or index == 9 or index == 10 or index == 11
        ...    index == 0 or index == 1 or index == 8 or index == 9 or index == 16 or index == 17 or index == 24 or index == 25
        ${actual_eAxcId}    Evaluate    [value for index, value in enumerate(${eAxcId_values}) if ${condition}]
        ${length}    Get Length    ${actual_eAxcId}
        ${length_status}    Run Keyword And Return Status    Should Be Equal As Numbers    ${length}    8
        ...    msg=eAXCID is not have 8 items.
        ${compare_list}    Create List    0   1   2  3  4  5  6  7
        ${result}    Evaluate    list(set(${actual_eAxcId})-set(${compare_list}))
        ${context_status}   Run Keyword And Return Status    Should Be Empty   ${result}
        ...    msg=eAXCID is not correct, expect is ${compare_list},actual is ${actual_eAxcId}.
        ${rnti}    Set Variable    ${rnti_list_values[${index}]}
        ${rnti_length}    Get Length    ${rnti}
        Run Keyword If    '${rnti_length}'=='${rnti_number}'    Should Be Equal     ${length_status}    ${True}
        ...    msg=eAXCID is not have 8 items.
        Run Keyword If    '${rnti_length}'=='${rnti_number}'    Should Be Equal     ${context_status}    ${True}
        ...    msg=eAXCID is not correct, expect is ${compare_list},actual is ${actual_eAxcId}.
        ${index}    Evaluate    ${index}+${1}
    END

Get UE Rnti From BIP
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter}    Catenate   UlData_UePuschReceiveRespHarqU_t.crc == 0 && UlData_UePuschReceiveRespHarqU_t.dtx == 0
    ...    && 3gpp.subcellid == ${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_puschreceiverespharqu
    ${rnti_list}    Get Field Value From PCAP    field_name=_3gpp.rnti
    ...                                          filter_expression=${filter}
    [Return]    ${rnti_list[0]}

Load And Activate BSR package
    Log To Console     ---start to download BSR package---
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.load_software_package_from_local_drive    file_path=${BSR_Package_Path}
    sleep    15s
    selenium_coam.software_update    is_activate=${True}
    sleep    15s
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

Activate BSR Via WebEM
    ${BSR_file_name}    Set Variable    ${BSR_Package_Path.split('/')[-1].split('.')[0]}
    Log To Console    ---Activate BSR through WebEM---
    ${actCustomBsr}   catenate   {'abbr':'actCustomBsr','dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'filter_param':'Activate custom beam set realization','new_value':'true'}
    ${customBeamSetName}   catenate   {'abbr':'customBeamSetName','dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'filter_param':'Custom Beam Set Name','new_value':'${BSR_file_name}'}
    ${Enable_BSR}    Evaluate     [${actCustomBsr},${customBeamSetName}]
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${Enable_BSR}     download_dir=${TS_CASE_LOG_PATH}

Disable BSR Via WebEM
    Log To Console    ---Disable BSR through WebEM---
    ${actCustomBsr}   catenate   {'abbr':'actCustomBsr','dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'filter_param':'Activate custom beam set realization','new_value':'false'}
    ${customBeamSetName}   catenate   {'abbr':'customBeamSetName','dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'filter_param':'Custom Beam Set Name','new_value':''}
    ${Enable_BSR}    Evaluate     [${actCustomBsr},${customBeamSetName}]
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${Enable_BSR}     download_dir=${TS_CASE_LOG_PATH}

Delete installed BSR
    ${BSR_file_name}    Set Variable    ${BSR_Package_Path.split('/')[-1].split('.')[0]}
    Log To Console    \n*** Delete installed BSR ***
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info
    @{bsr_package_list}=    Create List    ${BSR_file_name}
    selenium_coam.delete_beam_set_realization_software_item    bsr_package_list=@{bsr_package_list}
    sleep    15s
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

Check installed BSR Status
    ${BSR_file_name}    Set Variable    ${BSR_Package_Path.split('/')[-1].split('.')[0]}
    Log To Console    ---Check BSR installed status---
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info    timeout=${120}
    ${actCustomBsr}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate custom beam set realization    abbr=actCustomBsr    timeout=${120}
    ${BSR_Status}    set variable if
    ...          '${actCustomBsr}'=='false'    Not in use
    ...          '${actCustomBsr}'=='true'    In use
    Should Be Equal    ${beam_set_realization_software[0]['Status']}    ${BSR_Status}
    Should Be Equal    ${beam_set_realization_software[0]['BSR package']}    ${BSR_file_name}
    [Teardown]    Run Keyword and ignore error    Run keywords    COAM selenium logout    AND    selenium_coam.disable_message_box

Check Uninstalled BSR Status
    ${BSR_file_name}    Set Variable    ${BSR_Package_Path.split('/')[-1].split('.')[0]}
    Log To Console    Check delete BSR not in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info
    ${actCustomBsr}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate custom beam set realization    abbr=actCustomBsr    timeout=${120}
    Run Keyword And Continue On Failure    Should Be equal    ${actCustomBsr}    false
    Run Keyword And Continue On Failure    List Should Not Contain Value     ${beam_set_realization_software}    ${BSR_file_name}
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

Restore For BSR Function
    Disable BSR Via WebEM
    Sleep  10s
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}
    Delete installed BSR
    Sleep  10s
    Check Uninstalled BSR Status
    Sleep  10s
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}

Check StartPrb For SRS
    [Arguments]    ${file_path}    ${subcell_id}
    ${filter_with_subcell}    Set Variable    3gpp.subcellid==${subcell_id}
    Setup Pcap File   file_path=${file_path}    filter=uldata_srsreceivereq
    ${srsBmSubbandId}    Get Field Value From PCAP    field_name=UlData_srsBmResource_t.srsBmSubbandId
    ...                                               filter_expression=${filter_with_subcell}
    ${startPrb}    Get Field Value From PCAP    field_name=UlData_srsBmResource_t.startPrb
    ...                                         filter_expression=${filter_with_subcell}
    ${srsBmSubbandId_length}    Get Length    ${srsBmSubbandId}
    Should Be True    ${srsBmSubbandId_length}>${1}    msg=no valid data filter out.please check the bip log.
    FOR    ${index}    IN RANGE   len(${srsBmSubbandId})
        Run Keyword And Continue On Failure    Should Be Equal As Integers    ${startPrb[${index}][0]}
        ...    ${startprb_mapping_table['${srsBmSubbandId[${index}][0]}']}
        ...    msg=srs startprb is not correct.
    END

Modify Parameter cSRS
    [Arguments]    ${cell_index}=1    ${cSRS}=56
    Log To Console    \n***start to update cSRS***
    ${update__param}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'srsForBeamMgmt','value':[{'cSRS':'${cSRS}'}]}
    ${update__param_cSRS}    Evaluate    [${update__param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update__param_cSRS}    gnb_index=0

Disable 2200 And Enable Refine Beam Via WebUI
    Log To Console    ---Start to disable 2200 And enable Refine Beam Via WebUI---
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=BTS Beam Refinement P2
    ...    abbr=nrBtsBeamRefinementP2
    ...    new_value=true
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=BTS Beam Refinement P2
    ...    abbr=nrBtsBeamRefinementP2
    ...    new_value=true
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=BTS Beam Refinement P2
    ...    abbr=nrBtsBeamRefinementP2
    ...    new_value=true
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate uplink SRS based beam management
    ...    abbr=actUlSrsBm
    ...    new_value=false
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Activate uplink SRS based beam management
    ...    abbr=actUlSrsBm
    ...    new_value=false
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Activate uplink SRS based beam management
    ...    abbr=actUlSrsBm
    ...    new_value=false
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Downlink MIMO Mode
    ...    abbr=dlMimoMode
    ...    new_value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Downlink MIMO Mode
    ...    abbr=dlMimoMode
    ...    new_value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...    timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Downlink MIMO Mode
    ...    abbr=dlMimoMode
    ...    new_value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of CSI-RS resource period in one CSI report period
    ...    abbr=csirsNumberWithinReportPeriod_Set1
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Number of CSI-RS resource period in one CSI report period
    ...    abbr=csirsNumberWithinReportPeriod_Set1
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Number of CSI-RS resource period in one CSI report period
    ...    abbr=csirsNumberWithinReportPeriod_Set1
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Maximum CSI-RS number
    ...    abbr=maxCsirsNumber
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Maximum CSI-RS number
    ...    abbr=maxCsirsNumber
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Maximum CSI-RS number
    ...    abbr=maxCsirsNumber
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=CSI-RS power
    ...    abbr=csirsPower
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=CSI-RS power
    ...    abbr=csirsPower
    ...    timeout=${120}
    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=CSI-RS power
    ...    abbr=csirsPower
    ...    timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                         filter_param=Activate PDSCH beam power balance
    ...                                         abbr=actPdschBeamPowerBalance
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                                         filter_param=Activate PDSCH beam power balance
    ...                                         abbr=actPdschBeamPowerBalance
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...                                         filter_param=Activate PDSCH beam power balance
    ...                                         abbr=actPdschBeamPowerBalance
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                         filter_param=Activate CSI-RS beam power balance
    ...                                         abbr=actCsirsBeamPowerBalance
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                                         filter_param=Activate CSI-RS beam power balance
    ...                                         abbr=actCsirsBeamPowerBalance
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...                                         filter_param=Activate CSI-RS beam power balance
    ...                                         abbr=actCsirsBeamPowerBalance
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                         filter_param=Activate DL dynamic switch allocation
    ...                                         abbr=actDlDynSwitchAlloc
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                                         filter_param=Activate DL dynamic switch allocation
    ...                                         abbr=actDlDynSwitchAlloc
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...                                         filter_param=Activate DL dynamic switch allocation
    ...                                         abbr=actDlDynSwitchAlloc
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                         filter_param=BTS Beam Refinement P2
    ...                                         abbr=nrBtsBeamRefinementP2
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                                         filter_param=BTS Beam Refinement P2
    ...                                         abbr=nrBtsBeamRefinementP2
    ...                                         new_value=false
    ...                                         timeout=${120}
    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...                                         filter_param=BTS Beam Refinement P2
    ...                                         abbr=nrBtsBeamRefinementP2
    ...                                         new_value=false
    ...                                         timeout=${120}
    log to console  start to validate and activate
    selenium_coam.validate_plan    timeout=240
    selenium_coam.activate_plan    timeout=300
    Sleep   60 sec
    log to console  activate done!wait for gnb on air......
    Connect to gnb coam via ssl    connection=GNB_OAM0   gnb_index=0
    Wait Gnb Ready And Cell On Air    timeout=30 min    connection=GNB_OAM0
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM0    AND
    ...    Run Keyword And Ignore Error    COAM selenium logout    AND    Run Keyword And Ignore Error    selenium_coam.disable_message_box

Check MUGroup Paried Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
    ...             ${group_paird_percent_exp}=0.1
    calculate_ul_ulmugroup_status     file_path=${ttitrace_filt_path}
    ...                                   group_paird_percent_exp=${group_paird_percent_exp}

Update_actUlMuMimoGroupPairing_Values
    [Documentation]     actUlMuMimoGroupPairing: true
    [Arguments]    ${cell_index}=1
    ...            ${connection}=GNB_OAM
    ...            ${NRBTS_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...            ${NRULMUMIMO_id}=0
    Log To Console    \n***start to nrcelltype and numberOfRxBeamforming***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=0
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRCELL-${cell_index}/NRULMUMIMO-${NRULMUMIMO_id}',
    ...                 'parameter':'actUlMuMimoGroupPairing','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRCELL-${cell_index}/NRULMUMIMO-${NRULMUMIMO_id}',
    ...                 'parameter':'actUlMuMimoTapering','value':'true'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

UPdate All ATT Value FOR All UE RSRP TO 85 on Branch
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=48
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=53
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=54
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=55
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}


UPdate All ATT Value FOR All UE RSRP TO 85 on Trunk
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=45
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=43
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=42
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

WR FOR MUMIMIMO
    Run Keyword And Ignore Error    Lock Cell    connection=GNB_OAM_0
    Sleep    5sec
    Run Keyword And Ignore Error    Unlock Cell    connection=GNB_OAM_0
    Wait Gnb Ready And Cell On Air    connection=GNB_OAM_0
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM_0


Lock Cell
    [Arguments]    ${cell_id}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    Log To Console    Cell ${cell_id} Locked
    perform_cell_lock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=120
    sleep    60s    #wait for cell locked

Unlock Cell
    [Arguments]    ${cell_id}=1    ${connection}=GNB_OAM
    Log To Console    Cell ${cell_id} Unlocked
    Connect to gnb coam via ssl    connection=${connection}
    perform_cell_unlock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=120
    sleep    60s    #wait for cell unlocked

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${asik_alais}=ASIK Master
    [Documentation]    Author:xiaoxia.hao@nokia.com
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${asik_alais}
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${asik_alais}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

Cycle UPdate ATT Value
    [Arguments]    ${att_value}=40    ${target_att_Value}=54
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${att_value}
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    FOR    ${i}    IN RANGE    1    10
        ${new_att_value}    evaluate    int(${att_value})+5
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
        Sleep  5sec
        ${att_value}    Set Variable    ${new_att_value}
        exit for loop if    int(${new_att_value})>${target_att_Value}
    END

Cycle Fallback ATT Value
    [Arguments]    ${att_value}=40    ${target_att_Value}=5
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${att_value}
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    FOR    ${i}    IN RANGE    1    10
        ${new_att_value}    evaluate    int(${att_value})-5
        Log To Console    update ATT value to ${new_att_value}
        Mcs.Set ATT Value For Four Output Ports
        ...    mcs_type=${mcs_type}    mcs_index=${1}     att_value=${new_att_value}
        ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
        Sleep  5sec
        ${att_value}    Set Variable    ${new_att_value}
        exit for loop if    int(${new_att_value})<${target_att_Value}
    END

Check DL beamType Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}    ${beamType_value}=SUBBAND
    ${beamType}    ${beamType_value_count}    calculate_dl_beamtype_Counter     file_path=${ttitrace_filt_path}    beamType_value=${beamType_value}
    ${beamType_rate}    evaluate    ${beamType}/${beamType_value_count}
    run keyword and continue on failure    Should Be True    ${beamType_rate}>0.98

Update_Param_For_CB011116
    [Arguments]    ${cell_index}=1    ${skip_parameter_relation_errors}=True
    Log To Console    \n***start to mmdify for CB009527***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${update_param}    catenate
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actHighSpeedCell','value':'false'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actDlSrsSubbandBm','value':'true'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'dlDMRSAdditionalPosition',
    ...                                                                                    'value':'One additional DMRS'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'prachSequenceType',
    ...                                                                                    'value':'RestrictedTypeA'},
    ...            {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'ulDMRSAdditionalPosition',
    ...                                                                                    'value':'One additional DMRS'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
    ...                                          skip_parameter_relation_errors=${skip_parameter_relation_errors}
