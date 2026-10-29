*** Settings ***
Documentation    This is for feature CB010774 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jun.8.chen@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}


*** Keywords ***
10774 Update Related Parameters For Paging
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${InactivityTimer_value}=10
    ...            ${pagingOffset_value}=1
    ...            ${actPagingSsbOptimization_value}=offset
    ...            ${numOfPagingFrames_value}=halfT
    ...            ${fPdcchMonOccsnPo_value}=0
    ...            ${cell_idex}=1
    ...            ${connection}=GNB_OAM
    ...            ${bwpDN_item1}=7
    ...            ${bwpDN_item2}=77
    ...            ${bwpDN_item3}=10073
    ...            ${bwpDN_item4}=20070
    ...            ${bwpDN_item5}=30326
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${basic_param_list}    Update Basic Parameters For paging    InactivityTimer_value=${InactivityTimer_value}
    ...                                                          pagingOffset_value=${pagingOffset_value}
    ...                                                          actPagingSsbOptimization_value=${actPagingSsbOptimization_value}
    ...                                                          numOfPagingFrames_value=${numOfPagingFrames_value}
    ...                                                          fPdcchMonOccsnPo_value=${fPdcchMonOccsnPo_value}
    ...                                                          cell_idex=${cell_idex}
    ${cellBwpList_list}    Update Basic Parameters For BWP    bwpDN_item1=${bwpDN_item1}
    ...                                                       bwpDN_item2=${bwpDN_item2}
    ...                                                       bwpDN_item3=${bwpDN_item3}
    ...                                                       bwpDN_item4=${bwpDN_item4}
    ...                                                       bwpDN_item5=${bwpDN_item5}
    ${cellBwpList}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList}    Evaluate    ${cellBwpList}
    ${cellBwpList_param_list}    Create List    ${cellBwpList}
    ${update_param_list}    Combine Lists    ${basic_param_list}    ${cellBwpList_param_list}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

10774 Update Related Parameters For 8406
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${InactivityTimer_value}=10
    ...            ${pagingOffset_value}=0
    ...            ${fPdcchMonOccsnPo_value}=1
    ...            ${actPagingSsbOptimization_value}=offset
    ...            ${numOfPagingFrames_value}=quaterT
    ...            ${pooling_value}=false
    ...            ${cell_idex}=1
    ...            ${connection}=GNB_OAM
    ...            ${basicBeamSet_value}=beamSet_2
    ...            ${pucchSize_value}=36
    ...            ${numberOfTransmittedSsBlocks_value}=2 beams
    ...            ${bwpDN_item1}=8406
    ...            ${bwpDN_item2}=4061
    ...            ${bwpDN_item3}=4062
    ...            ${bwpDN_item4}=4063
    ...            ${bwpDN_item5}=4064
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${basic_param_list}    Update Basic Parameters For paging    InactivityTimer_value=${InactivityTimer_value}
    ...                                                          pagingOffset_value=${pagingOffset_value}
    ...                                                          actPagingSsbOptimization_value=${actPagingSsbOptimization_value}
    ...                                                          numOfPagingFrames_value=${numOfPagingFrames_value}
    ...                                                          fPdcchMonOccsnPo_value=${fPdcchMonOccsnPo_value}
    ...                                                          cell_idex=${cell_idex}
    ${pooing_param_list}    Update Basic Parameters For pooing    pooling_value=${pooling_value}
    ${numberOfTransmittedSsBlocks1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELLGRP-0',
    ...    'parameter':'numberOfTransmittedSsBlocks','value':'${numberOfTransmittedSsBlocks_value}'}
    ${numberOfTransmittedSsBlocks1}    Evaluate    ${numberOfTransmittedSsBlocks1}
    ${numberOfTransmittedSsBlocks2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELLGRP-1',
    ...    'parameter':'numberOfTransmittedSsBlocks','value':'${numberOfTransmittedSsBlocks_value}'}
    ${numberOfTransmittedSsBlocks2}    Evaluate    ${numberOfTransmittedSsBlocks2}
    &{basicBeamSet_list}    Create Dictionary    basicBeamSet=${basicBeamSet_value}
    ${basicBeamSet1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'beamSet','value':${basicBeamSet_list}}
    ${basicBeamSet1}    Evaluate    ${basicBeamSet1}
    ${basicBeamSet2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'beamSet','value':${basicBeamSet_list}}
    ${basicBeamSet2}    Evaluate    ${basicBeamSet2}
    &{pucchSize_list}    Create Dictionary    pucchSize=${pucchSize_value}
    ${pucchSize1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'pdcchAutoConfig','value':${pucchSize_list}}
    ${pucchSize1}    Evaluate    ${pucchSize1}
    ${pucchSize2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'pdcchAutoConfig','value':${pucchSize_list}}
    ${pucchSize2}    Evaluate    ${pucchSize2}
    ${cellBwpList_list}    Update Basic Parameters For BWP    bwpDN_item1=${bwpDN_item1}
    ...                                                       bwpDN_item2=${bwpDN_item2}
    ...                                                       bwpDN_item3=${bwpDN_item3}
    ...                                                       bwpDN_item4=${bwpDN_item4}
    ...                                                       bwpDN_item5=${bwpDN_item5}
    ${cellBwpList1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList1}    Evaluate    ${cellBwpList1}
    ${cellBwpList2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList2}    Evaluate    ${cellBwpList2}
    ${chbw_cell1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'chBw','value':'80MHz'}
    ${chbw_cell1}    Evaluate    ${chbw_cell1}
    ${update_param_list_other}    Create List    ${numberOfTransmittedSsBlocks1}    ${numberOfTransmittedSsBlocks2}
    ...                                          ${basicBeamSet1}    ${basicBeamSet2}    ${pucchSize1}    ${pucchSize2}
    ...                                          ${cellBwpList1}    ${cellBwpList2}    ${chbw_cell1}
    ${update_param_list}    Combine Lists    ${basic_param_list}    ${pooing_param_list}    ${update_param_list_other}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

10774 Update Related Parameters For 1070
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${InactivityTimer_value}=10
    ...            ${pagingOffset_value}=2
    ...            ${actPagingSsbOptimization_value}=offset
    ...            ${numOfPagingFrames_value}=quaterT
    ...            ${pooling_value}=true
    ...            ${fPdcchMonOccsnPo_value}=0
    ...            ${cell_idex}=1
    ...            ${pucchSize_value}=24
    ...            ${connection}=GNB_OAM
    ...            ${bwpDN_item1}=1070
    ...            ${bwpDN_item2}=10701
    ...            ${bwpDN_item3}=10702
    ...            ${bwpDN_item4}=10703
    ...            ${bwpDN_item5}=10704
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${basic_param_list}    Update Basic Parameters For paging    InactivityTimer_value=${InactivityTimer_value}
    ...                                                          pagingOffset_value=${pagingOffset_value}
    ...                                                          actPagingSsbOptimization_value=${actPagingSsbOptimization_value}
    ...                                                          numOfPagingFrames_value=${numOfPagingFrames_value}
    ...                                                          fPdcchMonOccsnPo_value=${fPdcchMonOccsnPo_value}
    ...                                                          cell_idex=${cell_idex}
    ${pooing_param_list}    Update Basic Parameters For pooing    pooling_value=${pooling_value}
    ${pagingOffset2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'pagingOffset','value':'${pagingOffset_value}'}
    ${pagingOffset2}    Evaluate    ${pagingOffset2}
    ${actPagingSsbOptimization_list2}    Create List    ${actPagingSsbOptimization_value}
    ${actPagingSsbOptimization2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'actPagingSsbOptimization','value':${actPagingSsbOptimization_list2}}
    ${actPagingSsbOptimization2}    Evaluate    ${actPagingSsbOptimization2}
    ${fPdcchMonOccsnPo_list2}    Create List    ${fPdcchMonOccsnPo_value}
    ${fPdcchMonOccsnPo2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'fPdcchMonOccsnPo','value':${fPdcchMonOccsnPo_list2}}
    ${fPdcchMonOccsnPo2}    Evaluate    ${fPdcchMonOccsnPo2}
    &{pucchSize_list}    Create Dictionary    pucchSize=${pucchSize_value}
    ${pucchSize1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'pdcchAutoConfig','value':${pucchSize_list}}
    ${pucchSize1}    Evaluate    ${pucchSize1}
    ${pucchSize2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'pdcchAutoConfig','value':${pucchSize_list}}
    ${pucchSize2}    Evaluate    ${pucchSize2}
    ${cellBwpList_list}    Update Basic Parameters For BWP    bwpDN_item1=${bwpDN_item1}
    ...                                                       bwpDN_item2=${bwpDN_item2}
    ...                                                       bwpDN_item3=${bwpDN_item3}
    ...                                                       bwpDN_item4=${bwpDN_item4}
    ...                                                       bwpDN_item5=${bwpDN_item5}
    ${cellBwpList1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList1}    Evaluate    ${cellBwpList1}
    ${cellBwpList2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList2}    Evaluate    ${cellBwpList2}
    ${chbw_cell1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'chBw','value':'80MHz'}
    ${chbw_cell1}    Evaluate    ${chbw_cell1}
    ${update_param_list_other}    Create List    ${pagingOffset2}    ${actPagingSsbOptimization2}    ${fPdcchMonOccsnPo2}
    ...                                          ${pucchSize1}    ${pucchSize2}    ${cellBwpList1}    ${cellBwpList2}    ${chbw_cell1}
    ${update_param_list}    Combine Lists    ${basic_param_list}    ${pooing_param_list}    ${update_param_list_other}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

10774 Update Related Parameters For 1208
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${InactivityTimer_value}=10
    ...            ${pagingOffset_value}=0
    ...            ${actPagingSsbOptimization_value}=offset
    ...            ${numOfPagingFrames_value}=halfT
    ...            ${pooling_value}=false
    ...            ${fPdcchMonOccsnPo_value}=0
    ...            ${cell_idex}=1
    ...            ${pucchSize_value}=36
    ...            ${connection}=GNB_OAM
    ...            ${bwpDN_item1}=1208
    ...            ${bwpDN_item2}=12081
    ...            ${bwpDN_item3}=12082
    ...            ${bwpDN_item4}=12083
    ...            ${bwpDN_item5}=12084
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${basic_param_list}    Update Basic Parameters For paging    InactivityTimer_value=${InactivityTimer_value}
    ...                                                          pagingOffset_value=${pagingOffset_value}
    ...                                                          actPagingSsbOptimization_value=${actPagingSsbOptimization_value}
    ...                                                          numOfPagingFrames_value=${numOfPagingFrames_value}
    ...                                                          fPdcchMonOccsnPo_value=${fPdcchMonOccsnPo_value}
    ...                                                          cell_idex=${cell_idex}
    ${pooing_param_list}    Update Basic Parameters For pooing    pooling_value=${pooling_value}
    ${actTddCsiRsOpt}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actTddCsiRsOpt','value':'${pooling_value}'}
    ${actTddCsiRsOpt}    Evaluate    ${actTddCsiRsOpt}
    &{pucchSize_list}    Create Dictionary    pucchSize=${pucchSize_value}
    ${pucchSize1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'pdcchAutoConfig','value':${pucchSize_list}}
    ${pucchSize1}    Evaluate    ${pucchSize1}
    ${cellBwpList_list}    Update Basic Parameters For BWP    bwpDN_item1=${bwpDN_item1}
    ...                                                       bwpDN_item2=${bwpDN_item2}
    ...                                                       bwpDN_item3=${bwpDN_item3}
    ...                                                       bwpDN_item4=${bwpDN_item4}
    ...                                                       bwpDN_item5=${bwpDN_item5}
    ${cellBwpList1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList1}    Evaluate    ${cellBwpList1}
    ${cellBwpList2}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'cellBwpList','value':${cellBwpList_list}}
    ${cellBwpList2}    Evaluate    ${cellBwpList2}
    ${chbw_cell1}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'chBw','value':'80MHz'}
    ${chbw_cell1}    Evaluate    ${chbw_cell1}
    ${update_param_list_other}    Create List    ${actTddCsiRsOpt}    ${pucchSize1}    ${cellBwpList1}    ${cellBwpList2}    ${chbw_cell1}
    ${update_param_list}    Combine Lists    ${basic_param_list}    ${pooing_param_list}    ${update_param_list_other}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${update_param_list}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Update Basic Parameters For paging
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${InactivityTimer_value}=10
    ...            ${pagingOffset_value}=0
    ...            ${actPagingSsbOptimization_value}=offset
    ...            ${numOfPagingFrames_value}=halfT
    ...            ${fPdcchMonOccsnPo_value}=0
    ...            ${cell_idex}=1
    ${drbInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${drbInactivityTimerSA}    Evaluate    ${drbInactivityTimerSA}
    ${srbInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'srbInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${srbInactivityTimerSA}    Evaluate    ${srbInactivityTimerSA}
    ${drbRrcInactInactivityTimerSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'drbRrcInactInactivityTimerSA','value':'${InactivityTimer_value}'}
    ${drbRrcInactInactivityTimerSA}    Evaluate    ${drbRrcInactInactivityTimerSA}
    ${pagingOffset}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'pagingOffset','value':'${pagingOffset_value}'}
    ${pagingOffset}    Evaluate    ${pagingOffset}
    ${actPagingSsbOptimization_list}    Create List    ${actPagingSsbOptimization_value}
    ${actPagingSsbOptimization}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'actPagingSsbOptimization','value':${actPagingSsbOptimization_list}}
    ${actPagingSsbOptimization}    Evaluate    ${actPagingSsbOptimization}
    ${fPdcchMonOccsnPo_list}    Create List    ${fPdcchMonOccsnPo_value}
    ${fPdcchMonOccsnPo}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'fPdcchMonOccsnPo','value':${fPdcchMonOccsnPo_list}}
    ${fPdcchMonOccsnPo}    Evaluate    ${fPdcchMonOccsnPo}
    ${numOfPagingFrames}    Catenate   {'dist_name':'NRBTS-${NRBTS_ID}/NRCELL-${cell_idex}',
    ...    'parameter':'numOfPagingFrames','value':'${numOfPagingFrames_value}'}
    ${numOfPagingFrames}    Evaluate    ${numOfPagingFrames}
    ${update_param_list}    Create List    ${drbInactivityTimerSA}    ${srbInactivityTimerSA}    ${drbRrcInactInactivityTimerSA}
    ...                                    ${pagingOffset}    ${actPagingSsbOptimization}    ${numOfPagingFrames}    ${fPdcchMonOccsnPo}
    [Return]    ${update_param_list}

Update Basic Parameters For pooing
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${pooling_value}=false
    ${actBbPoolExtensionTddFr1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actBbPoolExtensionTddFr1','value':'${pooling_value}'}
    ${actBbPoolExtensionTddFr1}    Evaluate    ${actBbPoolExtensionTddFr1}
    ${actBbPoolTddFr1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actBbPoolTddFr1','value':'${pooling_value}'}
    ${actBbPoolTddFr1}    Evaluate    ${actBbPoolTddFr1}
    ${actBbPoolTddFr1AlgEnh}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actBbPoolTddFr1AlgEnh','value':'${pooling_value}'}
    ${actBbPoolTddFr1AlgEnh}    Evaluate    ${actBbPoolTddFr1AlgEnh}
    ${actBbPoolTddFr1Enh}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actBbPoolTddFr1Enh','value':'${pooling_value}'}
    ${actBbPoolTddFr1Enh}    Evaluate    ${actBbPoolTddFr1Enh}
    ${actExplicitCsirsPoolSolution}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actExplicitCsirsPoolSolution','value':'${pooling_value}'}
    ${actExplicitCsirsPoolSolution}    Evaluate    ${actExplicitCsirsPoolSolution}
    ${actLargeBbPoolTddFr1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actLargeBbPoolTddFr1','value':'${pooling_value}'}
    ${actLargeBbPoolTddFr1}    Evaluate    ${actLargeBbPoolTddFr1}
    ${actLargeBbPoolTddFr1Enh}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}',
    ...    'parameter':'actLargeBbPoolTddFr1Enh','value':'${pooling_value}'}
    ${actLargeBbPoolTddFr1Enh}    Evaluate    ${actLargeBbPoolTddFr1Enh}
    ${update_param_list}    Create List    ${actBbPoolExtensionTddFr1}    ${actBbPoolTddFr1}    ${actBbPoolTddFr1AlgEnh}
    ...                                    ${actBbPoolTddFr1Enh}    ${actExplicitCsirsPoolSolution}
    ...                                    ${actLargeBbPoolTddFr1}    ${actLargeBbPoolTddFr1Enh}
    [Return]    ${update_param_list}

Update Basic Parameters For BWP
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${bwpDN_item1}=7
    ...            ${bwpDN_item2}=77
    ...            ${bwpDN_item3}=10073
    ...            ${bwpDN_item4}=20070
    ...            ${bwpDN_item5}=30326
    ${cellBwpList_item1}    Catenate   {'actPdcchCceFragmentControl':'false','actUpperThrAckNackFiltering':'false',
    ...    'actUpperThrAckNackHrFiltering':'false','bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_item1}',
    ...    'cellBwpId':'0','pdcchResourcePreference':'peakRate'}
    ${cellBwpList_item1}    Evaluate    ${cellBwpList_item1}
    ${cellBwpList_item2}    Catenate   {'actPdcchCceFragmentControl':'false','actUpperThrAckNackFiltering':'false',
    ...    'actUpperThrAckNackHrFiltering':'false','bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_item2}',
    ...    'cellBwpId':'1','pdcchResourcePreference':'peakRate'}
    ${cellBwpList_item2}    Evaluate    ${cellBwpList_item2}
    ${cellBwpList_item3}    Catenate   {'actPdcchCceFragmentControl':'false','actUpperThrAckNackFiltering':'false',
    ...    'actUpperThrAckNackHrFiltering':'false','bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_item3}',
    ...    'cellBwpId':'2','pdcchResourcePreference':'peakRate'}
    ${cellBwpList_item3}    Evaluate    ${cellBwpList_item3}
    ${cellBwpList_item4}    Catenate   {'actPdcchCceFragmentControl':'false','actUpperThrAckNackFiltering':'false',
    ...    'actUpperThrAckNackHrFiltering':'false','bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_item4}',
    ...    'cellBwpId':'3','pdcchResourcePreference':'peakRate'}
    ${cellBwpList_item4}    Evaluate    ${cellBwpList_item4}
    ${cellBwpList_item5}    Catenate   {'actPdcchCceFragmentControl':'false','actUpperThrAckNackFiltering':'false',
    ...    'actUpperThrAckNackHrFiltering':'false','bwpDN':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwpDN_item5}',
    ...    'cellBwpId':'4','pdcchResourcePreference':'peakRate'}
    ${cellBwpList_item5}    Evaluate    ${cellBwpList_item5}
    ${cellBwpList_list}    Create List    ${cellBwpList_item1}    ${cellBwpList_item2}    ${cellBwpList_item3}
    ...                                   ${cellBwpList_item4}    ${cellBwpList_item5}
    [Return]    ${cellBwpList_list}

BWP DN Recommissioning Common Keyword
    [Arguments]   ${scf_path}=${TS_CASE_LOG_PATH}
    ...           ${delta_id}=bwpdn_Recommissioning
    ...           ${connection}=bwpdn_Recommissioning
    ...           ${framestructure}=11160ms
    ...           ${whether_do_cell2}=${False}
    Log To Console   ${\n}INFO: ---bwpdn Recommissioning start---
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}

    ${scf_file_name}   Set Variable    Before_bwpdn_Recommissioning.xml
    coam.get_current_scf_file   local_dir_path=${scf_path}   file_name=${scf_file_name}    connection=${connection}   timeout=${60}
    ${ALL_RECOM_VAR1}    Get All BWP DN Information From SCF    scf_name=${scf_path}/${scf_file_name}    cell_id=1
    ${ALL_RECOM_VAR2}    Run Keyword If    ${whether_do_cell2}    Get All BWP DN Information From SCF    scf_name=${scf_path}/${scf_file_name}
    ...                                                                                                  cell_id=2
    coam.create_delta   delta_id=${delta_id}
    Update Delta Cell Bwp List    delta_id=${delta_id}    origin_mapping=${ALL_RECOM_VAR1}    framestructure=${framestructure}    cell_id=1
    Run Keyword If    ${whether_do_cell2}    Update Delta Cell Bwp List    delta_id=${delta_id}
    ...                                                                    origin_mapping=${ALL_RECOM_VAR2}
    ...                                                                    framestructure=${framestructure}
    ...                                                                    cell_id=2
    ${delta_file}   coam.get_delta   delta_id=${delta_id}
    Log To Console   ${delta_file}
    Log To Console   COAM Perform Delta Recommissioning...
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${900}
    ...   connection=${connection}
    coam.get_current_scf_file   local_dir_path=${scf_path}
    ...                         file_name=After_bwpdn_Recommissioning.xml
    ...                         connection=${connection}
    ...                         timeout=${60}
    Log To Console   COAM Perform Delta Recommissioning Finished!
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Get All BWP DN Information From SCF
    [Arguments]   ${scf_name}    ${cell_id}=1
    ${scf_xml}   XML.Parse XML   ${scf_name}
    &{ALL_RECOM_VAR}   Create Dictionary
    @{cellBwpList}   Create List
    ${bwpDN_item_elem_list}   XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[@distName="MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}"]/list[@name="cellBwpList"]/item
    FOR   ${bwpDN_item_elem}   IN   @{bwpDN_item_elem_list}
        ${bwpDN_param}   Get cellBwpList Parameter   bwpDN_item_elem=${bwpDN_item_elem}
        Append To List   ${cellBwpList}   ${bwpDN_param}
    END
    Log To Console   cellBwpList: ${cellBwpList}
    Set To Dictionary   ${ALL_RECOM_VAR}   cellBwpList=${cellBwpList}
    [Return]    ${ALL_RECOM_VAR}

Get cellBwpList Parameter
    [Arguments]   ${bwpDN_item_elem}
    &{bwpDN_param}   Create Dictionary
    ${bwpDN_param_elem_list}   XML.Get Elements   ${bwpDN_item_elem}   xpath=p
    FOR   ${param_elem}   IN   @{bwpDN_param_elem_list}
        ${key}   XML.Get Element Attribute   ${param_elem}   name=name   xpath=.
        ${value}   XML.Get Element Text   ${param_elem}   xpath=.
        Set To Dictionary   ${bwpDN_param}   ${key}=${value}
    END
    [Return]   ${bwpDN_param}

Update Delta Cell Bwp List
    [Arguments]   ${delta_id}    ${origin_mapping}    ${framestructure}=11160ms    ${cell_id}=1
    ${cellBwpList}    Set Variable    ${BWP_INFO_MAPPING_TABLE["${framestructure}"]["cellBwpList"]}
    ${new_cellBwpList}   Copy List   ${origin_mapping["cellBwpList"]}   deepcopy=${True}
    FOR   ${index}   IN RANGE   len(${cellBwpList})
        ${item}   Set Variable   ${cellBwpList[${index}]}
        Update Delta Cell Bwp List Parameter   index=${index}   item=${item}   new_cellBwpList=${new_cellBwpList}
    END
    Log To Console   new_cellBwpList:
    Log To Console   ${new_cellBwpList}
    coam.append_list_items_to_delta   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...                               cellBwpList   @{new_cellBwpList}   delta_id=${delta_id}

Update Delta Cell Bwp List Parameter
    [Arguments]   ${index}    ${item}    ${new_cellBwpList}
    FOR   ${key}   IN   @{item}
        ${value}   Set Variable If
        ...   "${key}"=="bwpDN"   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${item["${key}"]}
        ...   ${item["${key}"]}
        Set To Dictionary   ${new_cellBwpList[${index}]}   ${key}   ${value}
    END

CB010774 UE Attach For Paging
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}

Check UE Enter Into RRC Inactive State
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}
    ${filter_expression}    Catenate    f1ap.procedureCode == 6 and nr-rrc.ran_PagingCycle
    Setup Pcap File   file_path=${wireshark_log}    filter=${filter_expression}
    ${test_value}    Get Field Value From PCAP    field_name=nr-rrc.ran_PagingCycle
    ...                                           filter_expression=nr-rrc.ran_PagingCycle
    ...                                           attribute_name=show
    Should Not Be Empty    ${test_value}    msg=Do not enter to RRC inactive State after srbInactivityTimerSA timer expired.

Check Paging Send On F1AP After Inactive
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               Checkpoint:PAGING is sent on F1AP, with correct nrCellIdentity
    ...               Comment: use condition f1ap.procedureCode == 18 filter Paging message on F1AP.
    [Arguments]    ${wireshark_log}    ${list_cell_index}=12
#    [Arguments]    ${wireshark_log}    ${list_cell_index}=12    ${connection}=GNB_OAM
    @{list_cell_index}    Convert to list    ${list_cell_index}
#    ${nrCellIdentity_mapping}    Get NRCellIdentity And Cell Index Mapping    connection=${connection}
    ${nrCellIdentity_mapping}    Create Dictionary    ${1}=${4785}    ${2}=${4786}
    Setup Pcap File   file_path=${wireshark_log}    filter=f1ap.procedureCode == 18
    ${nRCellIdentity_list_on_wireshark}    Get Field Value From PCAP    field_name=f1ap.nRCellIdentity
    ...                                                                 filter_expression=f1ap.PagingCell_list
    ...                                                                 attribute_name=showname
    ${nRCellIdentity_list}    Create List
    FOR    ${item}    IN    @{nRCellIdentity_list_on_wireshark[0]}
        ${item1}    Split String    ${item}    ${SPACE}
        ${item2}    Split String    ${item1[-1]}    ]
        Append To List    ${nRCellIdentity_list}    ${item2[0]}
    END
    FOR    ${index}    IN    @{list_cell_index}
        ${value}    Evaluate    str(${nrCellIdentity_mapping[${index}]})
        Run Keyword And Continue On Failure    List Should Contain Value    ${nrCellIdentity_list}    ${value}
        ...    msg=paging is not send on f1ap for nrCellIdentity:${nrCellIdentity_mapping[${index}]}
    END

Check UE Enter Into RRC Idle State For WA
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Comment: use condition ngap.NRCellIdentity == 0x0000000521 && ngap.procedureCode == 41 filter UEContextReleaseComplete
    [Arguments]    ${wireshark_log}    ${cell_index}=1
#    [Arguments]    ${wireshark_log}    ${cell_index}=1    ${connection_coam}=GNB_OAM    ${gnb_index}=0
#    ${nrCellIdentity_dic}    Get NR Cell And Cell Identity Mapping   connection=${connection_coam}    gnb_index=${gnb_index}
    ${nrCellIdentity_dic}    Create Dictionary    ${1}=${4785}    ${2}=${4786}
    ${cell_nrCellIdentity}    Convert To Hex    ${nrCellIdentity_dic[${cell_index}]}    prefix=0x    length=10
    ${filter_expression}    Catenate    ngap.NRCellIdentity == ${cell_nrCellIdentity} and ngap.procedureCode == 41
    Setup Pcap File   file_path=${wireshark_log}    filter=${filter_expression}
    ${test_value}    Get Field Value From PCAP    field_name=ngap.tAC
    ...                                           filter_expression=ngap.tAC
    ...                                           attribute_name=showname
    Should Not Be Empty    ${test_value}    msg=UE-${cell_index} is not enter to RRC Idle State after srbInactivityTimerSA timer expired.
    [Return]    ${test_value}

Check RRC Resume After Paging
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser
    Setup Pcap File   file_path=${wireshark_log}    filter=${filter}    alias=${alias}
    ${rrc_setup_request_after_paging}    Catenate    f1ap.procedureCode == 13&&nr-rrc.c1==4
    ${rrc_setup_request_after_paging_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${rrc_setup_request_after_paging}    pcap_parser=${alias}
    Should Be Equal    ${rrc_setup_request_after_paging_status}    ${True}    msg=RRC connection is not setup after paging send

Check Paging Send To L1 Via BIP
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Timeout]    30 min
    [Arguments]    ${bip_log}    ${cell_index}=1
    ${number_of_beam}    Get The Numeber Of Beams    cell_id=${cell_index}
    Set Test Variable    ${number_of_beam}
    Setup Pcap File   file_path=${bip_log}    filter=nr-rrc.pagingRecordList == 1
    ${subcellid_list_origin}    Get Field Value From PCAP    field_name=_3gpp.subcellid
    ...                                                      filter_expression=3gpp.subcellid
    ...                                                      attribute_name=show
    ${subcellid_list}    Remove Duplicates    ${subcellid_list_origin}
    ${subcellid_len}    Get Length   ${subcellid_list}
    Should Be True    ${subcellid_len}!=${0}
    FOR    ${subcellid}    IN    @{subcellid_list}
        ${number}    Count Values in list    ${subcellid_list_origin}    ${subcellid}
        Should Be True    ${number}==${number_of_beam}    msg=paging number in bip is not correct.
    END

Verify The Paging Information In Syslog
    [Documentation]    jun.8.chen@nokia-sbell.com
    [Arguments]    ${syslog_file_path}    ${log_path}=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    tar -zxvf ${log_path}/${syslog_file_path}/syslog_files.tgz -C ${log_path}/${syslog_file_path}
    ${file_name}    OperatingSystem.Run    cd ${log_path}/${syslog_file_path}; ls *.LOG
    ${pattern_string}    Set Variable    schedulePaging from fd hyperSfn
    ${paging_output}    OperatingSystem.Run    cd ${log_path}/${syslog_file_path}; cat ${file_name} | grep -i "${pattern_string}"
    ${paging_log}    Get Regexp Matches    ${paging_output}   ${pattern_string}
    ${paging_length}    Get Length    ${paging_log}
    ${beam_total}    Evaluate    2 * ${number_of_beam}
    Should Be True    ${paging_length}==${beam_total}

Check DCI Item Via BIP
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Timeout]    30 min
    [Arguments]    ${slot_in_fact_list}    ${bip_log}    ${pci}=299    ${frame_len}=${1}
    ${filter_expression}    Catenate    3gpp.rnti==65534 && dldata_pdcchsendreql1sw && DlData_DciInfoL1sw.dciScramblingSequenceInit==${pci}
    Setup Pcap File   file_path=${bip_log}    filter=${filter_expression}
    ${sfn_list}    Get Field Value From PCAP    field_name=_3gpp.sfn
    ...                                         filter_expression=3gpp.sfn
    ...                                         attribute_name=show
    ${sfn_list}    Remove Duplicates    ${sfn_list}
    ${sfn_len}    Get Length   ${sfn_list}
    Should Be True    ${sfn_len}==${frame_len}
    ${slot_tmp_list}    Create List
    Setup Pcap File   file_path=${bip_log}    filter=${filter_expression}
    ${slot_list}    Get Field Value From PCAP    field_name=_3gpp.slot
    ...                                          filter_expression=3gpp.slot
    ...                                          attribute_name=show
    ${slot_len}    Get Length   ${slot_list}
    ${slot_in_fact_len}    Get Length   ${slot_in_fact_list}
    Should Be True    ${slot_len}==${slot_in_fact_len}
    FOR    ${slot}    IN    @{slot_list}
        Append To List    ${slot_tmp_list}    ${slot[0]}
    END
    Sort List    ${slot_in_fact_list}
    Sort List    ${slot_tmp_list}
    Lists Should Be Equal    ${slot_in_fact_list}    ${slot_tmp_list}
    Setup Pcap File   file_path=${bip_log}    filter=${filter_expression}
    ${numOfSymbols_list}    Get Field Value From PCAP    field_name=DlData_DciInfoL1sw.numOfSymbols
    ...                                                  filter_expression=DlData_DciInfoL1sw.numOfSymbols
    ...                                                  attribute_name=show
    ${numOfSymbols_list}    Remove Duplicates    ${numOfSymbols_list}
    ${numOfSymbols_len}    Get Length   ${numOfSymbols_list}
    Should Be True    ${numOfSymbols_len}==${1}
    ${number}    Count Values in list    ${numOfSymbols_list[0]}    1
    Should Be True    ${number}==${2}    msg=DCI item number in bip is not correct.