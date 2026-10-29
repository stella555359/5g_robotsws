*** Settings ***
Documentation    The keyword for paging
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com


*** Keywords ***
Get The Numeber Of Beams
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...               Description: Get the numeber of beams and return.
    [Arguments]    ${cell_id}=1
#    ${cell_group_id}    Evaluate    ${cell_id}-${1}
    ${cell_group_id}    Set Variable    ${cell_id}
    COAM Navigate to login page via webUI
    ${beamset_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_group_id}
    ...    abbr=numberOfTransmittedSsBlocks
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ${beamnumber_para_value}    Fetch From Left    string=${beamset_para_value}    marker=${SPACE}
    ${number_of_beam}    Convert To Integer    ${beamnumber_para_value}
    [Return]    ${number_of_beam}
    [Teardown]    COAM selenium logout

Check Paging Send On NGAP
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Checkpoint:PAGING is sent on NGAP, with correct tac.
    ...               Comment: use condition ngap.procedureCode == 24 filter Paging message on NGAP.
    [Arguments]    ${wireshark_log}    ${tac}=200
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log}    filter=ngap
    ${tac_on_wireshrk}    Get Field Value From Pdml
    ...    filter_expression=ngap.TAIListForPaging
    ...    xpath=.//ngap.TAIListForPagingItem_element/ngap.tAI_element/ngap.tAC
    ...    attribute_name=show
    Should Be Equal    ${tac}    ${tac_on_wireshrk}[0]    msg=Paging is not send for tac:${tac}
    ${paging_length}    Get Length    ${tac_on_wireshrk}
    [Return]    ${paging_length}

Check RRC Connection After Paging
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log}    filter=${filter}    alias=${alias}
    ${rrc_setup_request_after_paging}    Catenate    f1ap.procedureCode == 13&&nr-rrc.c1==1
    ${rrc_setup_request_after_paging_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${rrc_setup_request_after_paging}    pcap_parser=${alias}
    Should Be Equal    ${rrc_setup_request_after_paging_status}    ${True}    msg=RRC connection is not setup after paging send

Check Paging Send On F1AP
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Checkpoint:PAGING is sent on F1AP, with correct nrCellIdentity
    ...               Comment: use condition f1ap.procedureCode == 18 filter Paging message on F1AP.
    [Arguments]    ${wireshark_log}    ${list_cell_index}=12    ${connection}=GNB_OAM
    @{list_cell_index}    Convert to list    ${list_cell_index}
    ${nrCellIdentity_mapping}    Get NRCellIdentity And Cell Index Mapping    connection=${connection}
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log}    filter=f1ap
    ${nRCellIdentity_list_on_wireshark}    Get Field Value From Pdml    filter_expression=f1ap.PagingCell_list
    ...                                                                 xpath=.//f1ap.nRCellIdentity
    ...                                                                 attribute_name=value
    ${nRCellIdentity_list}    Create List
    FOR    ${item}    IN    @{nRCellIdentity_list_on_wireshark}
        ${nRCellIdentity_on_wireshrk}    Get Substring     ${item}    0   9
        ${nRCellIdentity_on_wireshrk}    Convert To Binary    ${nRCellIdentity_on_wireshrk}    base=16
        ${nRCellIdentity_on_wireshrk}    Convert To Integer    ${nRCellIdentity_on_wireshrk}    base=2
        Append To List    ${nRCellIdentity_list}    ${nRCellIdentity_on_wireshrk}
    END
    FOR    ${index}    IN    @{list_cell_index}
        Run Keyword And Continue On Failure    List Should Contain Value    ${nrCellIdentity_list}    ${nrCellIdentity_mapping[${index}]}
        ...    msg=paging is not send on f1ap for nrCellIdentity:${nrCellIdentity_mapping[${index}]}
    END

Check Paging Send To L1
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Checkpoint:PAGING is sent to L1 ABIL
    ...               Comment: use condition nr-rrc.pagingRecordList == 1 filter Paging message
    [Timeout]    30 min
    [Arguments]    ${bip_log}    ${list_abil_index}=12    ${alias}=parser    ${num_of_paging}=3
    @{list_abil_index}    Convert to list    ${list_abil_index}
    ${beam_num}    Set Variable    ${0}
    FOR    ${index}    IN    @{list_abil_index}
        ${number_of_beam}    Get The Numeber Of Beams    cell_id=${index}
        ${beam_num}    Evaluate    ${beam_num}+${number_of_beam}
    END
    ${condition_sudcellid}    Set Variable    nr-rrc.pagingRecordList && DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId
    Convert Bip Pcap To Pdml    file_path=${bip_log}    filter=${condition_sudcellid}    alias=${alias}
    ${subcellid_list}    pcap.get_field_value_by_name    field_name=DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId
    ...                                                  pcap_parser=${alias}
    ${subcellid_list}    Remove Duplicates    ${subcellid_list}
    ${paging_status}    Set Variable    ${False}
    FOR    ${subcellid}    IN    @{subcellid_list}
        ${condition_expression}    Set Variable
        ...    nr-rrc.pagingRecordList && DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId == ${subcellid}
        Convert Bip Pcap To Pdml    file_path=${bip_log}    filter=${condition_expression}    alias=${alias}
        ${paging_list_on_L1}    pcap.get_field_value_by_name    field_name=nr-rrc.pagingRecordList    pcap_parser=${alias}
        ${paging_length}    Get Length    ${paging_list_on_L1}
        ${status}    Evaluate    ${paging_length}==${num_of_paging}*${beam_num}
        ${subcell_id}    Run Keyword If    ${status}    Set Variable    ${subcellid}
        ${paging_status}    Set Variable If    ${status}    ${True}    ${paging_status}
        Exit For Loop If    "${status}"=="True"
    END
    Should Be True   '${paging_status}'=='True'
    [Return]    ${subcell_id}

Check Paging Send To L1 For BBMOD Mixed
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    ...               Checkpoint:PAGING is sent to L1 ABIL
    ...               Comment: use condition nr-rrc.pagingRecordList == 1 filter Paging message
    ...               Just for tool "gnb_logs" to capture bip logs
    [Timeout]    25 min
    [Arguments]    ${bip_log}    ${list_abil_index}=12    ${alias}=parser
    @{list_abil_index}    Convert to list    ${list_abil_index}
    ${condition_expression}    Set Variable    nr-rrc.pagingRecordList
    Extract Zip File    ${bip_log}    ${bip_log.split(".zip")[0]}
    @{file}    Split String    ${bip_log}    /
    ${abil_bip_filename}    Run
    ...    command=cd ${bip_log.split(".zip")[0]}/${file[-1].split(".zip")[0]};ls -l |grep ABIL |grep fsp |awk '{print $9}'
    ${output}=    Split String    ${abil_bip_filename}    \r\n
    ${abil_bip_file}    Set Variable    ${bip_log.split(".zip")[0]}/${file[-1].split(".zip")[0]}/${output[0]}
    Convert Bip Pcap To Pdml    file_path=${abil_bip_file}    filter=${condition_expression}    alias=${alias}
    ${paging_list_on_L1}    pcap.get_field_value_by_name    field_name=nr-rrc.pagingRecordList    pcap_parser=${alias}
    ${abil_paging_length}    Get Length    ${paging_list_on_L1}
    ${abio_bip_filename}    Run    command=cd ${bip_log.split(".zip")[0]}/${file[-1].split(".zip")[0]};ls -l |grep ABIO |awk '{print $9}'
    ${output}=    Split String    ${abio_bip_filename}    \r\n
    ${abio_bip_file}    Set Variable    ${bip_log.split(".zip")[0]}/${file[-1].split(".zip")[0]}/${output[0]}
    Convert Bip Pcap To Pdml    file_path=${abio_bip_file}    filter=${condition_expression}    alias=${alias}
    ${paging_list_on_L1}    pcap.get_field_value_by_name    field_name=nr-rrc.pagingRecordList    pcap_parser=${alias}
    ${abio_paging_length}    Get Length    ${paging_list_on_L1}
    ${paging_length}    Evaluate    ${abil_paging_length}+${abio_paging_length}
    ${beam_num}    Set Variable    ${0}
    FOR    ${index}    IN    @{list_abil_index}
        ${number_of_beam}    Get The Numeber Of Beams    cell_id=${index}
        ${beam_num}    Evaluate    ${beam_num}+${number_of_beam}
    END
    Should Be True   ${paging_length}==${beam_num} or ${paging_length}==2*${beam_num}    msg=paging length is wrong

SCF Parameter pagingTargetRate Need To Modify
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]   ${cell_id}=NRBTS-${NRBTS_ID}/NRCELL-1
    ...           ${pagingTargetRate}=MCS0_SF2
    &{pagingTargetRate}    Create Dictionary    dist_name=${cell_id}   parameter=pagingTargetRate    value=${pagingTargetRate}
    @{params_need_to_modify}    Create List    ${pagingTargetRate}
    [Return]    @{params_need_to_modify}

Check UE Enter Into RRC Idle State
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Checkpoint:PAGING is sent on NGAP, with correct tac.
    ...               Comment: use condition ngap.NRCellIdentity == 0x0000000521 && ngap.procedureCode == 41 filter UEContextReleaseComplete
    [Arguments]    ${wireshark_log}    ${cell_index}=1    ${connection_coam}=GNB_OAM    ${gnb_index}=0
    ${nrCellIdentity_dic}    Get NR Cell And Cell Identity Mapping   connection=${connection_coam}    gnb_index=${gnb_index}
    ${cell_nrCellIdentity}    Convert To Hex    ${nrCellIdentity_dic[${cell_index}]}    prefix=0x    length=10
    ${filter_expression}    Catenate    ngap.NRCellIdentity == ${cell_nrCellIdentity} and ngap.procedureCode == 41
    Setup Pcap File   file_path=${wireshark_log}    filter=${filter_expression}
    ${test_value}    Get Field Value From PCAP    field_name=ngap.tAC
    ...                                           filter_expression=ngap.tAC
    ...                                           attribute_name=showname
    Should Not Be Empty    ${test_value}    msg=UE-${cell_index} is not enter to RRC Idle State after srbInactivityTimerSA timer expired.
    [Return]    ${test_value}

Check UE Enter Into RRC Release State
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log}    ${ranEdrxPagingCycl_value}=rf1024
    ${filter_expression}    Catenate    f1ap.procedureCode == 6 and nr-rrc.ran_PagingCycle
    Setup Pcap File   file_path=${wireshark_log}    filter=${filter_expression}
    ${test_value}    Get Field Value From PCAP    field_name=nr-rrc.ran_ExtendedPagingCycle_r17
    ...                                           filter_expression=nr-rrc.ran_ExtendedPagingCycle_r17
    ...                                           attribute_name=showname
    Should Not Be Empty    ${test_value}    msg=Do not enter to RRC Release State after srbInactivityTimerSA timer expired.
    ${ranEdrxPagingCycl}    Set Variable    ${test_value[0][0]}
    ${ranEdrxPagingCycl}    Set Variable    ${ranEdrxPagingCycl.split(' ')[1]}
    Should Be True    '${ranEdrxPagingCycl}'=='${ranEdrxPagingCycl_value}'
    [Return]    ${test_value}

Check PCCH and BCCH configuration Mapping In SIB Message
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Comment: use condition eth.dst == 02:40:43:80:11:04 && nr-rrc.c1 == 1 SIB Message
    [Arguments]    ${bip_log}    ${list_abil_index}=1    ${connection}=GNB_OAM    ${luashark_path}=/home/ute/luashark/luashark.lua
    ...            ${arb_name}=arb0p0    ${bb_card_type}=ABIL
    ${pcch_bcch_configure_in_scf}    Get PCCH and BCCH configuration From SCF    list_cell_index=${list_abil_index}
    ...                                                                          connection=${connection}
    ${result_mapping}    Create Dictionary    n2=0     v256=3    quaterT=1    one=2   0=0    2=2
    Run Keyword If     '${bb_card_type}'=='ABIL'     Connect to All Capacity Unit Loner
    @{list_abil_index}    Convert to list    ${list_abil_index}
    FOR    ${abil_index}    IN    @{list_abil_index}
        ${result_in_scf}    Get From Dictionary     ${pcch_bcch_configure_in_scf}     ${abil_index}
        ${index}    Evaluate    ${abil_index}-${1}
        ${abil_mac_address}    Run Keyword If    '${bb_card_type}'=='ABIL'    Get ABIL Loner Mac Address
        ...                                                                   connection_alias=ABIL Loner${index}
        ...                                                                   arb_name=${arb_name}
        Run Keyword If    '${bb_card_type}'=='ABIL'    pcap.Read Cap    cap_file=${bip_log}
        ...                                                             display_filter=nr-rrc.c1 == 1 and eth.dst == ${abil_mac_address}
        ...                                                             X=lua_script:${luashark_path}
        ...    ELSE    pcap.Read Cap    cap_file=${bip_log}
        ...            display_filter=nr-rrc.c1 == 1 and DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId == 0x0${index}
        ...            X=lua_script:${luashark_path}
        ${parameters_need_to_check}    Catenate
        ...    nr-rrc.modificationPeriodCoeff == ${result_mapping['${result_in_scf['modPeriodCoeff']}']} and
        ...    nr-rrc.defaultPagingCycle == ${result_mapping['${result_in_scf['drxDefaultPaging']}']} and
        ...    nr-rrc.quarterT == ${result_mapping['${result_in_scf['numOfPagingFrames']}']} and
        ...    nr-rrc.ns == ${result_mapping['${result_in_scf['numPagingOccsnPagingFrame']}']} and
        ...    nr-rrc.sCS120KHZoneT_SCS60KHZhalfT_SCS30KHZquarterT_SCS15KHZoneEighthT_item ==
        ...    ${result_mapping['${result_in_scf['fPdcchMonOccsnPo']}']}
        pcap.check_expression    condition_expression=${parameters_need_to_check}
    END

Verfiy Short Message Send On gnb Side
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Modified by jun.8.chen@nokia-sbell.com for adapt single or more cells
    ...               Comment: use condition nr-rrc.t300 to get from SIB Message
    [Arguments]    ${bip_log}    ${old_t300_value}    ${new_t300_value}    ${luashark_path}=/home/ute/luashark/luashark.lua
    ...            ${list_abil_index}=12    ${arb_name}=arb0p0    ${bb_card_type}=ABIL
    Connect to Common Unit Master
    Run Keyword If    '${bb_card_type}'=='ABIL'    Connect to All Capacity Unit Loner
    ${result_mapping}    Create Dictionary    400ms=3     600ms=4    300ms=2
    @{list_abil_index}    Convert to list    ${list_abil_index}
    FOR    ${abil_index}    IN    @{list_abil_index}
        ${index}    Evaluate    ${abil_index}-${1}
        ${abil_mac_address}    Run Keyword If    '${bb_card_type}'=='ABIL'    Get ABIL Loner Mac Address
        ...    connection_alias=ABIL Loner${index}
        ...    arb_name=${arb_name}
        Run Keyword If    '${bb_card_type}'=='ABIL'    pcap.Read Cap    cap_file=${bip_log}
        ...                                                            display_filter=nr-rrc.c1 == 1 and eth.dst == ${abil_mac_address}
        ...                                                            X=lua_script:${luashark_path}
        ...    ELSE    pcap.Read Cap    cap_file=${bip_log}
        ...            display_filter=nr-rrc.c1 == 1 and DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId == 0x0${index}
        ...            X=lua_script:${luashark_path}
        ${t300_values_list_on_wireshark}    pcap.Get Element Value    element_expression=nr-rrc.t300
        ...                                                           element_idx=${0}
        ...                                                           default_value=${True}
        ${expect_t300_list}    Create List    ${result_mapping['${old_t300_value}']}    ${result_mapping['${new_t300_value}']}
        ${t300_values}    Remove Duplicates    ${t300_values_list_on_wireshark}
        Lists Should Be Equal    ${t300_values}    ${expect_t300_list}
        ...    msg=short message not send from gnb.t300 value on wiresahrk is:${t300_values},actual configuration is:${expect_t300_list}
    END

Get PCCH and BCCH configuration From SCF
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${list_cell_index}=12     ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    @{list_abil_index}    Convert to list    ${list_cell_index}
    &{pcch_bcch_configure_in_scf}    Create Dictionary
    FOR    ${cell_id}    IN    @{list_abil_index}
        ${modPeriodCoeff}     coam_parameter.get_single_value_from_scf_file
        ...                        parameter=modPeriodCoeff
        ...                        dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...                        connection=${connection}
        ${drxDefaultPaging}     coam_parameter.get_single_value_from_scf_file
        ...                          parameter=drxDefaultPaging
        ...                          dist_name=NRBTS-${NRBTS_ID}
        ...                          connection=${connection}
        ${numOfPagingFrames}     coam_parameter.get_single_value_from_scf_file
        ...                           parameter=numOfPagingFrames
        ...                           dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...                           connection=${connection}
        ${numPagingOccsnPagingFrame}     coam_parameter.get_single_value_from_scf_file
        ...                                   parameter=numPagingOccsnPagingFrame
        ...                                   dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...                                   connection=${connection}
        ${fPdcchMonOccsnPo}     coam_parameter.get_single_value_from_scf_file
        ...                          parameter=fPdcchMonOccsnPo
        ...                          dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...                          connection=${connection}
         ${parameter_dict}    Create Dictionary    modPeriodCoeff=${modPeriodCoeff}    drxDefaultPaging=${drxDefaultPaging}
        ...                        numOfPagingFrames=${numOfPagingFrames}    numPagingOccsnPagingFrame=${numPagingOccsnPagingFrame}
        ...                        fPdcchMonOccsnPo=${fPdcchMonOccsnPo[0]}
        Set To Dictionary    ${pcch_bcch_configure_in_scf}    ${cell_id}=${parameter_dict}
    END
    [Return]    &{pcch_bcch_configure_in_scf}
    [Teardown]    coam.teardown    connection=${connection}

Get NRCellIdentity And Cell Index Mapping
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               ${result} : e.g. {1: {'nrCellIdentity': 1249, 'cell_group_id': 0, 'physicalCellId': 60},
    ...                                 2: {'nrCellIdentity': 1250, 'cell_group_id': 1, 'physicalCellId': 61}}
    ...               Return ${nrCellIdentity_mapping}: e.g. {1:1249,2:1250}
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${result}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${keys}     Get Dictionary Keys    ${result}
    ${nrCellIdentity_mapping}    Create Dictionary
    FOR   ${key}   IN    @{keys}
        ${item}    Set Variable    ${result}[${key}]
        Set To Dictionary    ${nrCellIdentity_mapping}     ${key}   ${item['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity_mapping}
    [Teardown]    coam.teardown    connection=${connection}

Get ABIL Loner Mac Address
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Checkpoint:PAGING is sent on NGAP, with correct tac.
    ...               Comment: use condition ngap.procedureCode == 24 filter Paging message on NGAP.
    [Arguments]    ${connection_alias}    ${arb_name}=arb0p0
    ${output}    csn.execute    command=ifconfig    connection=${connection_alias}
    ${address}    Get Regexp Matches    ${output}   ${arb_name}.*HWaddr\\s(\\d+:\\d+:\\d+:\\d+:\\d+:\\d+)    1
    [Return]    ${address[0]}

Get srbInactivityTimerSA Timer From SCF
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${nrbts_id}=${NRBTS_ID}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${srbinactivity_timer}     coam_parameter.get_single_value_from_scf_file
    ...                        parameter=srbInactivityTimerSA
    ...                        dist_name=NRBTS-${nrbts_id}
    ...                        connection=${connection}
    [Return]    ${srbinactivity_timer}
    [Teardown]    coam.teardown    connection=${connection}

Update SI Modification Parameter On SCF
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]   ${drbInactivityTimerSA}=10
    ...           ${srbInactivityTimerSA}=15
    ...           ${t300}=600ms
    ...           ${list_cell_idex}=1
    ...           ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${drbInactivityTimerSA_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}
    ...                                                   parameter=drbInactivityTimerSA
    ...                                                   value=${drbInactivityTimerSA}
    ${srbInactivityTimerSA_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}
    ...                                                   parameter=srbInactivityTimerSA
    ...                                                   value=${srbInactivityTimerSA}
    @{list_cell_idex}    Convert To List    ${list_cell_idex}
    ${si_modification_parameters}    Create List    ${drbInactivityTimerSA_param}    ${srbInactivityTimerSA_param}
    FOR    ${cell_id}     IN    @{list_cell_idex}
        ${t300_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    parameter=t300    value=${t300}
        Append To List     ${si_modification_parameters}    ${t300_param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${si_modification_parameters}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Update TAC Parameter On SCF
    [Documentation]   Stella.lin@nokia-sbell.com
    [Arguments]   ${tac_cell_1}=270
    ...           ${tac_cell_2}=270
    ...           ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    coam.get_current_scf_file   local_dir_path=${TS_CASE_LOG_PATH}   file_name=scf_backup.xml    timeout=10   connection=${connection}
    scf.load_scf   file_path=${TS_CASE_LOG_PATH}/scf_backup.xml
    ${tracking_area_config_under_nrplmnset_1}   scf.is_element_in_object    dist_name=NRBTS-${NRBTS_ID}/NRCELL-1/NRPLMNSET_SA-1
    ...                                                                     p_name=trackingAreaDN
    ${tracking_area_config_under_nrplmnset_2}   scf.is_element_in_object    dist_name=NRBTS-${NRBTS_ID}/NRCELL-2/NRPLMNSET_SA-1
    ...                                                                     p_name=trackingAreaDN
    ${tac_modification_parameters}    Create List
    ${tac_cell_1_nrplmnset_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-1/NRPLMNSET_SA-1
    ...                                         parameter=trackingAreaDN
    ...                                         value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/TRACKINGAREA-${tac_cell_1}
    ${tac_cell_2_nrplmnset_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-2/NRPLMNSET_SA-1
    ...                                         parameter=trackingAreaDN
    ...                                         value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/TRACKINGAREA-${tac_cell_2}
    ${tac_cell_1_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                         parameter=trackingAreaDN
    ...                                         value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/TRACKINGAREA-${tac_cell_1}
    ${tac_cell_2_param}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}/NRCELL-2
    ...                                         parameter=trackingAreaDN
    ...                                         value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/TRACKINGAREA-${tac_cell_2}
    Run Keyword If    ${tracking_area_config_under_nrplmnset_1}
    ...               Append To List    ${tac_modification_parameters}    ${tac_cell_1_nrplmnset_param}
    ...    ELSE       Append To List    ${tac_modification_parameters}    ${tac_cell_1_param}
    Run Keyword If    ${tracking_area_config_under_nrplmnset_2}
    ...               Append To List    ${tac_modification_parameters}    ${tac_cell_2_nrplmnset_param}
    ...    ELSE       Append To List    ${tac_modification_parameters}    ${tac_cell_2_param}
#    Append To List    ${tac_modification_parameters}    ${tac_cell_1_param}    ${tac_cell_2_param}
#    Run Keyword If    ${tracking_area_config_under_nrplmnset_1}    Append To List    ${tac_modification_parameters}
#    ...                                                                              ${tac_cell_1_nrplmnset_param}
#    Run Keyword If    ${tracking_area_config_under_nrplmnset_2}    Append To List    ${tac_modification_parameters}
#    ...                                                                              ${tac_cell_2_nrplmnset_param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${tac_modification_parameters}
    ...                                            timeout=${180}
    ...                                            connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Verify UE Decode Short Message For Huawei
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Comment: check on ue side. verify ue has decode short message
    [Arguments]    ${ue_log}    ${expect_t300_value}
    spark.read_log    logname=${ue_log}
    ${res}    spark.get_expected_val    msg=NR SystemInformationBlock1
    ...    expression=c1.systemInformationBlockType1.ue-TimersAndConstants.t300
    ${res}    Fetch From Left    ${res}    :
    Should Be Equal    ${res}    ${expect_t300_value}

Start Ping Test On Appserver
    [Documentation]  This keyword connect to Appserver and start ping.
    [Arguments]     ${ue_addr}    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep ping|grep -v grep|grep ${ue_addr}| awk '{print $2}' |xargs kill -9    connection=${appserver}
    csn.send command    command=ping -c 30 -W 60 ${ue_addr} &    connection=APPserver
    sleep    25s
    csn.send_command    command=ps -ef|grep ping|grep -v grep| awk '{print $2}'    connection=${appserver}
    ${output}    csn.read_output    size=1000    connection=${appserver}
    Should Not Be Empty    ${output}

Get GNB Capacity Unit Type
    [Documentation]    Get the Capacity Unit board Type
    ...                Connect to Capacity Unit Master with IP or hostname which search from ASIK Master.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    du_index=${du_index}    alias=${asik_alias}    gnb_index=${gnb_index}
    Connect to Capacity Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    hw_slot=${hw_slot}    alias=${alias}
    ${bb_board_name}    Get hardware type    alias=${alias}
    [Return]    ${bb_board_name}
    [Teardown]    csn.disconnect    connection=${asik_alias}

Get First Subcellid Of Cell
    [Documentation]    Auther: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=GNB_${gnb_index}
    ${subcellid}    ssh.execute    command=cat /ram/NrCellMappingInfo.txt | grep -i "121" | awk '{print $8}'   connection=GNB_${gnb_index}
    ${subcellid}    Fetch From Left     ${subcellid}   \r\n
    [Return]    ${subcellid}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=GNB_${gnb_index}

# --- For Mixed BBMOD BIP ---
Verify Keywords Of File On VM
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    ...                Description: Check the file on UTE whether contain the specific words
    ...                             Need to push the script gnb_logs(such as:gnb_logs_2.17) to /home/ute/gnb_logs on UTE
    ...                             For success to start bip: Wait for Press <Enter> again to stop and dump logs...
    ...                             For success to stop bip: Log file downloaded:
    [Arguments]    ${success_words}=Wait for Press <Enter> again to stop and dump logs...
    ...            ${path}=/home/ute/gnb_logs    ${filename}=tool.log    ${connection}=test_vm
    ${output}    csn.execute    command=cat ${path}/${filename}    connection=${connection}
    Log    ${output}
    Should Contain    ${output}    ${success_words}

Start To Capture Bip Log Via gnb_logs Script
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    ...                Description: Check the file on UTE whether contain the specific words
    [Arguments]    ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${ute_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${ute_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${alias}=test_vm
    ...            ${path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${command_suf}=-b
    ...            ${success_words}=Wait for Press <Enter> again to stop and dump logs...
    ...            ${filename}=tool.log
    csn.connect to    hostname=${ute_ip}    username=${ute_username}    password=${ute_password}    alias=${alias}
    csn.send command    command=rm ${path}/*.zip    connection=${alias}
    csn.execute    command=rm ${path}/${filename}    connection=${alias}
    ${connection}    csn.get_connection_by_alias    alias=${alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Set Test Variable    ${bip_channel}    ${channel}
    Call Method    ${channel}    send    cd ${path};./gnb_logs ${gnb_ip} ${command_suf}\n
    Wait Until Keyword Succeeds   3 min  10 sec   Verify Keywords Of File On VM    success_words=${success_words}
    ...                                                                            path=${path}
    ...                                                                            filename=${filename}
    ...                                                                            connection=${alias}

Stop And Dowonload Bip Logs
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${alias}=test_vm
    ...            ${path}=/home/ute/gnb_logs
    ...            ${success_words}=Log file downloaded:
    ...            ${filename}=tool.log
    ...            ${log_dir_ute}=${TS_CASE_LOG_PATH}
    Call Method    ${bip_channel}    send    \n
    Sleep    2 sec
    Wait Until Keyword Succeeds   3 min  10 sec   Verify Keywords Of File On VM    success_words=${success_words}
    ...                                                                            path=${path}
    ...                                                                            filename=${filename}
    ...                                                                            connection=${alias}
    ${tmp_log_name}    csn.execute    command=cd ${path};ls -l | grep BIP.zip | awk '{print $9}'    connection=${alias}
    ${log_name}    Fetch From Left    ${tmp_log_name}    \r\n
    csn.execute    command=cp ${path}/${log_name} ${log_dir_ute}    connection=${alias}
    ${log_full_path_ute}     join path    ${log_dir_ute}    ${log_name}
    [Return]    ${log_full_path_ute}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Call Method    ${bip_channel}    close    AND
    ...                           Run Keyword And Ignore Error    csn.send command    command=rm ${path}/*.zip    connection=${alias}    AND
    ...                           Run Keyword And Ignore Error    csn.execute    command=rm ${path}/${filename}    connection=${alias}    AND
    ...                           Run Keyword And Ignore Error    csn.disconnect    connection=${alias}
