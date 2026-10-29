*** Settings ***
Documentation    This is for feature CB010887 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jun.8.chen@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}


*** Keywords ***
Upload Swconfig File And Reset Site
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_path}=${CURDIR}/swconfig.txt    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=swconfig
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    Log To Console    Start update Swconfig file.
    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${alias}
    Do gNB Reset site and Wait Onair
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${alias}

Check UE Capability Via CPIF Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${value}=t2r4
    Setup Pcap File    file_path=${cpif_log_path}   filter=f1ap.procedureCode==13 && nr-rrc.supportedBandCombinationList_v1540
    ${srs_TxSwitch_value}    Get Field Value From PCAP    field_name=nr-rrc.supportedSRS_TxPortSwitch
    ...                                                   filter_expression=nr-rrc.bandList_v1540 == 1
    ...                                                   attribute_name=showname
    Should Contain    ${srs_TxSwitch_value[0][0]}    ${value}    msg=UE Capability is not T2R4 in UE Capability Information message

Check SRSResourceSet Via CPIF Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    Setup Pcap File   file_path=${cpif_log_path}    filter=f1ap.procedureCode==12 && nr-rrc.srs_ResourceSetToAddModList && nr-rrc.c1==0
    ${SRSusageList}    Get Field Value From PCAP    field_name=nr-rrc.usage
    ...                                             filter_expression=nr-rrc.resourceType == 2
    ...                                             attribute_name=showname
    Should Contain    ${SRSusageList[0][0]}    codebook    msg=Codebook SRS resource is not Assigned in RRC Message!
    Should Contain    ${SRSusageList[0][1]}    antennaSwitching    msg=TAS SRS resource is not Assigned in RRC Message!

Verify srsForBeamMgmt Whether Are Same Between SCF And RRC Message
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${cell_idx}=1    ${srs_num}=${3}
    ${c_SRS}    ${b_SRS}    ${periodicityAndOffset}    ${slot_List}    Get srsForBeamMgmt Via CPIF Log    cpif_log_path=${cpif_log_path}
    ...                                                                                                   srs_num=${srs_num}
    ${bSRS}    ${cSRS}    ${srsUePeriodicity}    Get srsForBeamMgmt Via SCF    cell_idx=${cell_idx}
    BuiltIn.Should Be Equal    ${periodicityAndOffset}    ${srsUePeriodicity}    msg=SRS srsUePeriodicity is not the same in gnb and RRC!
    BuiltIn.Should Be Equal    ${c_SRS}   ${cSRS}    msg=SRS cSRS is not the same in gnb and RRC!
    BuiltIn.Should Be Equal    ${b_SRS}   ${bSRS}    msg=SRS bSRS is not the same in gnb and RRC!
    [Return]    ${slot_List}    ${srsUePeriodicity}

Get srsForBeamMgmt Via CPIF Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${srs_num}=${3}
    Setup Pcap File   file_path=${cpif_log_path}    filter=f1ap.procedureCode==12 && nr-rrc.srs_ResourceToAddModList && nr-rrc.c1==0
    ${c_SRSList}    Get Field Value From PCAP    field_name=nr-rrc.c_SRS
    ...                                          filter_expression=nr-rrc.resourceType == 2
    ...                                          attribute_name=show
    ${b_SRSList}    Get Field Value From PCAP    field_name=nr-rrc.b_SRS
    ...                                          filter_expression=nr-rrc.resourceType == 2
    ...                                          attribute_name=show
    ${periodicityAndOffsetList}    Get Field Value From PCAP    field_name=nr-rrc.periodicityAndOffset_p
    ...                                                         filter_expression=nr-rrc.resourceType == 2
    ...                                                         attribute_name=showname
    ${c_SRSList}    Remove Duplicates    ${c_SRSList[0]}
    ${b_SRSList}    Remove Duplicates    ${b_SRSList[0]}
    ${periodicityAndOffsetList}    Remove Duplicates    ${periodicityAndOffsetList[0]}
    ${periodicityAndOffsetList}    Split String    ${periodicityAndOffsetList[0]}    ${SPACE}
    ${slot_List}    Get Field Value From PCAP    field_name=nr-rrc.${periodicityAndOffsetList[1]}
    ...                                          filter_expression=nr-rrc.resourceType == 2
    ...                                          attribute_name=show
    ${slot_List_length_srs}    Get Length    ${slot_List[0]}
    Should Be True    ${slot_List_length_srs}==${srs_num}    msg=slot must have ${srs_num} values.
    ${slot_List}    Remove Duplicates    ${slot_List[0]}
    ${slot_List_length}    Get Length    ${slot_List}
    Should Be True    ${slot_List_length}==${2}    msg=slot must have two values.
    ${c_SRSList_length}    Get Length    ${c_SRSList}
    Should Be True    ${c_SRSList_length}==${1}    msg=c_SRS value is not unique.
    ${b_SRSList_length}    Get Length    ${b_SRSList}
    Should Be True    ${b_SRSList_length}==${1}    msg=b_SRS value is not unique.
    [Return]    ${c_SRSList[0]}    ${b_SRSList[0]}    ${periodicityAndOffsetList[1]}    ${slot_List}

Get srsForBeamMgmt Via SCF
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]      ${bSRS}=none    ${cSRS}=none    ${srsUePeriodicity}=none
    ...              ${cell_idx}=1    ${connection}=GNB_OAM    ${timeout}=600
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
    ${srs_params}    Create Dictionary    bSRS=${bSRS}    cSRS=${cSRS}    srsUePeriodicity=${srsUePeriodicity}
    ${srs_params_list}    Evaluate    [${srs_params}]
    ${srs_mo}    Create Dictionary    dist_name=${dist_name}    value=${srs_params_list}    parameter=srsForBeamMgmt
    ${srs_mo_list}    Evaluate    [${srs_mo}]
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    gnb_index=0
    ${srsForBeamMgmt_values}    coam_parameter.get_list_values_from_scf_file
    ...    parameters=${srs_mo_list}
    ...    connection=${connection}
    ...    timeout=${timeout}
    ${bSRS}    Set Variable    ${srsForBeamMgmt_values[0]['value'][0]['bSRS']}
    ${cSRS}    Set Variable    ${srsForBeamMgmt_values[0]['value'][0]['cSRS']}
    ${srsUePeriodicity}    Set Variable    ${srsForBeamMgmt_values[0]['value'][0]['srsUePeriodicity']}
    ${srsUePeriodicity}    Set Variable If    '${srsUePeriodicity}'=='slots40'    sl40    ${srsUePeriodicity}
    ${srsUePeriodicity}    Set Variable If    '${srsUePeriodicity}'=='slots80'    sl80    ${srsUePeriodicity}
    ${srsUePeriodicity}    Set Variable If    '${srsUePeriodicity}'=='slots10'    sl10    ${srsUePeriodicity}
    ${srsUePeriodicity}    Set Variable If    '${srsUePeriodicity}'=='slots160'    sl160    ${srsUePeriodicity}
    [Return]    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Get numberOfRxBeamforming Via SCF
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]      ${cell_idx}=1    ${connection}=GNB_OAM    ${timeout}=600
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    gnb_index=0
    ${numberOfRxBeamforming}    coam_parameter.get_single_value_from_scf_file
    ...                         parameter=numberOfRxBeamforming
    ...                         dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}
    ...                         connection=${connection}
    ...                         timeout=${timeout}
    [Return]    ${numberOfRxBeamforming}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Check Values On UlData_SrsReceiveRespBmPs
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${slot_List}    ${dtx_value}=NON_DTX    ${srsUePeriodicity}=sl10
    ${new_value1}    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Evaluate    int(${slot_List[0]}) + ${10}
    ${new_value2}    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Evaluate    int(${slot_List[1]}) + ${10}
    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Append To List    ${slot_List}    ${new_value1}
    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Append To List    ${slot_List}    ${new_value2}
    ${slot_List}    Remove Duplicates    ${slot_List}
    FOR    ${slot}   IN    @{slot_List}
        ${item}    Evaluate    int(${slot})
        ${slot}    Evaluate    ${item} % ${20}
        ${filter_with_slot}    Set Variable    3gpp.slot==${slot}
        Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceiverespbmps
        ${dtx_values_list}    Get Field Value From PCAP    field_name=UlData_srsRespBmPsResources_t.dtx
        ...                                                filter_expression=${filter_with_slot}
        ...                                                attribute_name=showname
        ${dtx_values_list}    Remove Duplicates    ${dtx_values_list}
        ${dtxDl_values_list}    Get Field Value From PCAP    field_name=UlData_srsRespBmPsResources_t.dtxDl
        ...                                                  filter_expression=${filter_with_slot}
        ...                                                  attribute_name=showname
        ${dtxDl_values_list}    Remove Duplicates    ${dtxDl_values_list}
        ${final_dtx_list}    Combine Lists    ${dtx_values_list}    ${dtxDl_values_list}
        ${final_dtx_list}    Strat To Deal With The List    value_list=${final_dtx_list}
        ${final_dtx_list}    Remove Duplicates    ${final_dtx_list}
        ${dtx_values_length}    Get Length    ${final_dtx_list}
        Should Be True    ${dtx_values_length}==${2}    msg=dtx_value is not unique.
        ${final_dtx_list_1}    Split String    ${final_dtx_list[0]}    ${SPACE}
        ${final_dtx_list_2}    Split String    ${final_dtx_list[1]}    ${SPACE}
        BuiltIn.Should Be Equal    ${final_dtx_list_1[-2]}    ${dtx_value}    msg=dtx_value is not ${dtx_value}!
        BuiltIn.Should Be Equal    ${final_dtx_list_2[-2]}    ${dtx_value}    msg=dtx_value is not ${dtx_value}!
    END

Check Values On UlData_SrsReceiveRespBmPs For Multi UE
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${dtx_value}=NON_DTX
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceiverespbmps
    ${dtx_values_list}    Get Field Value From PCAP    field_name=UlData_srsRespBmPsResources_t.dtx
    ...                                                filter_expression=UlData_srsRespBmPsResources_t.dtx
    ...                                                attribute_name=showname
    ${dtx_values_list}    Remove Duplicates    ${dtx_values_list}

    ${dtxDl_values_list}    Get Field Value From PCAP    field_name=UlData_srsRespBmPsResources_t.dtxDl
    ...                                                  filter_expression=UlData_srsRespBmPsResources_t.dtxDl
    ...                                                  attribute_name=showname
    ${dtxDl_values_list}    Remove Duplicates    ${dtxDl_values_list}
    ${final_dtx_list}    Combine Lists    ${dtx_values_list}    ${dtxDl_values_list}
    ${final_dtx_list}    Strat To Deal With The List    value_list=${final_dtx_list}
    ${final_dtx_list}    Remove Duplicates    ${final_dtx_list}
    ${dtx_values_length}    Get Length    ${final_dtx_list}
    Should Be True    ${dtx_values_length}==${2}    msg=dtx_value is not unique.
    ${final_dtx_list_1}    Split String    ${final_dtx_list[0]}    ${SPACE}
    ${final_dtx_list_2}    Split String    ${final_dtx_list[1]}    ${SPACE}
    BuiltIn.Should Be Equal    ${final_dtx_list_1[-2]}    ${dtx_value}    msg=dtx_value is not ${dtx_value}!
    BuiltIn.Should Be Equal    ${final_dtx_list_2[-2]}    ${dtx_value}    msg=dtx_value is not ${dtx_value}!

Strat To Deal With The List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${value_list}
    ${final_list}    Create List
    FOR    ${value}    IN    @{value_list}

        ${final_list}    Combine Lists    ${final_list}    ${value}
    END
    [Return]    ${final_list}

Check SrsPower Values On UlData_SrsReceiveRespBmPs
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${srspower}=${None}
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceiverespbmps
    ${srspower_values_list}    Get Field Value From PCAP    field_name=UlData_srsRespBmPsResources_t.srsPower_item
    ...                                                     filter_expression=UlData_srsRespBmPsResources_t.dtx
    ...                                                     attribute_name=show
    ${srspower_values_list}    Remove Duplicates    ${srspower_values_list}
    FOR    ${srspower_values}    IN    @{srspower_values_list}
        ${srspower_values}    Remove Duplicates    ${srspower_values}
        Check The Value Of List    item_list=${srspower_values}    value=${srspower}
    END

Check The Value Of List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${item_list}    ${value}=${None}
    FOR    ${item}    IN    @{item_list}
        Run Keyword If    ${value} == ${None}    Should Be True    ${item} >= -120
        ...    ELSE    Should Be True    ${item} <= -120
    END

Get patternId Dict Via CPRT Log
    [Documentation]    Desription: Get patternIdDict from cprt log.
    ...                PREDEFINED beam, Default SSB beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=SCellParametersReq
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfo List Via CPRT Log
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    Set Variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*SCellParametersReq(.*?)ruMaxRemasks*
    ${patternIdInfoList_log} =    Get Regexp Matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1    2
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${patternIdInfoList_log2}    Run Keyword If    ${patternIdInfoList_len} == ${0}
    ...    Fetch PatternIdInfo List Via CPRT Log    cell_idx=${cell_idx}    connection=${connection}
    ${patternIdInfoList_log}    set variable if    ${patternIdInfoList_len} == ${0}   ${patternIdInfoList_log2}    ${patternIdInfoList_log}
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch patternId Of Different Beams    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${cprtPatternIdDict}

Check EleSteeringCenter Degree Via CPRT Log
    [Documentation]    Desription: Get patternIdDict from cprt log.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=eleSteeringCenter
    ${eleSteeringCenter_log}    ${nrcellid}    Get PatternIdInfo List Via CPRT Log    cell_idx=${cell_idx}
    ...                                                                               connection=${connection}
    ...                                                                               grep_info=${grep_info}
    ${eleSteeringCenter_exp}    Set Variable    DftBeamWeightGenerator.*eleSteeringCenter:(.*?)\\r\\r\\n
    ${eleSteeringCenter_log}    Get Regexp Matches    ${eleSteeringCenter_log}   ${eleSteeringCenter_exp}    1
    ${eleSteeringCenter_log}    Remove Duplicates    ${eleSteeringCenter_log}
    ${eleSteeringCenter_log_len}    Get Length    ${eleSteeringCenter_log}
    Should Be True    ${eleSteeringCenter_log_len}==${1}    msg=EleSteeringCenter Degree is not unique.
    BuiltIn.Should Be Equal    ${eleSteeringCenter_log[0]}    6.000000    msg=EleSteeringCenter Degree is not 6.000000!

Check Tilt Value Via CPRT Log
    [Documentation]    Desription: Get patternIdDict from cprt log.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=DftBeamWeightGenerator
    ${tilt_log}    ${nrcellid}    Get PatternIdInfo List Via CPRT Log    cell_idx=${cell_idx}
    ...                                                                  connection=${connection}
    ...                                                                  grep_info=${grep_info}
    ${tilt_exp}    Set Variable    DftBeamWeightGenerator.*?tilt:(.*?). beamArrayH
    ${tilt_log}    Get Regexp Matches    ${tilt_log}   ${tilt_exp}    1
    ${tilt_log}    Remove Duplicates    ${tilt_log}
    ${tilt_log_len}    Get Length    ${tilt_log}
    Should Be True    ${tilt_log_len}==${1}    msg=Tilt Value is not unique.
    BuiltIn.Should Be Equal    ${tilt_log[0]}    99    msg=Tilt Value is not 9!

Get PatternIdInfo List Via CPRT Log
    [Documentation]    Desription: Get PatternIdInfoList Log info from cprt log
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=patternIdInfoList
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${fsm_type}=    coam_gnb_classical.COAM Get FSM Type    connection=${connection}
    ${cell_mapping}=    coam_gnb_classical.get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${nrcellid}=    Evaluate    int(${cell_mapping[${cell_idx}]['nrCellIdentity']})
    ${alias}    set variable if    '${fsm_type}'=='ASIB'    ASIK Slave    ASIK Master
    Run Keyword If    '${fsm_type}'=='ASIB'    Connect to Common Unit Master    alias=${alias}
    ...    ELSE    Connect to Common Unit Slave    alias=${alias}
    ${cprt_patternIdList} =    set variable    cat /tmp/node_CPRT*/tmp/startup_cp_rt.log| grep -i '${grep_info}'
    ${cprt_xz_patternIdList} =  set variable  xzcat /ffs/run/logs/CPRT*_aasyslog/startup_cp_rt.log.xz| grep -i '${grep_info}'
    ${cprt_xz_output} =    csn.execute    command=${cprt_xz_patternIdList}   connection=${alias}
    ${cprt_xz_match} =    Run Keyword And Ignore Error    should contain    ${cprt_xz_output}    ${grep_info}
    ${cprt_output}    run keyword if    '${cprt_xz_match[0]}'=='FAIL'    csn.execute    command=${cprt_patternIdList}    connection=${alias}
    ${patternIdInfoList_log}    set variable if    '${cprt_xz_match[0]}'=='FAIL'    ${cprt_output}    ${cprt_xz_output}
    [Return]    ${patternIdInfoList_log}    ${nrcellid}

Fetch PatternIdInfo List Via CPRT Log
    [Documentation]    Desription: Fetch PatternIdInfoList from cprt log, used for 2200 not enabled.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=patternIdInfoList
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfo List Via CPRT Log
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    [Return]    ${patternIdInfoList_log}

Fetch patternId Of Different Beams
    [Documentation]    Desription: Get patternIdInfoList from cprt log.
    [Arguments]    ${patternIdInfoList_log}    ${predefined_beam}=PREDEFINED    ${DEFAULT_beam}=DEFAULT    ${DFT_beam}=DFTNORMAL
    &{cprtPatternIdDict}    Create Dictionary
    ${beamSetType_list}    create list    ${predefined_beam}    ${DEFAULT_beam}    ${DFT_beam}
    FOR  ${beamSetType}  IN  @{beamSetType_list}
     ${patternIdMin_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.:(\\d+)
     ${patternIdMax_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.*?patternIdMax.:(\\d+)
     ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
     ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
     ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
     ${patternId_list}    Remove Duplicates    ${patternId_list}
     Set To Dictionary    ${cprtPatternIdDict}    ${beamSetType}    ${patternId_list}
    END
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch patternId Of DFT Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
#    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
#    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch patternId Of PMI Beam
#    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    ${DEFAULT_beam_len}    Get Length    ${cprtPatternIdDict['${DEFAULT_beam}']}
    Should Be True    ${DEFAULT_beam_len}==${4}    msg=For PDCCH and PUCCH, by default one SSB beam is not used
    [Return]    ${cprtPatternIdDict}

Fetch patternId Of DFT Beam
    [Documentation]    Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.*<LOG.*>..(\\d+)..patternIdMax
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}    Fetch patternId Of DFT Beam Again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch patternId Of DFT Beam Again
    [Documentation]    Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL    ${DFT_exp}=DFT
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_exp}.*<LOG.*>.*dMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_exp}.*<LOG.*>.*dMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}

Fetch patternId Of PMI Beam
    [Documentation]    Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC    ${PMI_exp}=DYNA
    ${patternIdMin_exp}    set variable    beamSetType...${PMI_exp}.*<LOG.*>.*dMin.:(\\d+).*beamSetType
    ${patternIdMax_exp}    set variable    beamSetType...${PMI_exp}.*<LOG.*>.*dMin.*?patternIdMax.:(\\d+).*beamSetType
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch patternId Of PMI Beam Again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch patternId Of PMI Beam Again
    [Documentation]    Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...${PMI_beam}...patternIdMin.*<LOG.*>(\\d+)..patternIdMax
    ${patternIdMax_exp}    set variable    beamSetType...${PMI_beam}...patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    [Return]    ${cprtPatternIdDict}

Get PatternId For DlData_PdschSendReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${pci}    ${ue_num}=${1}
    ${pci_list_len}    Get Length    ${pci}
    Setup Pcap File   file_path=${bip_file_path}    filter=dldata_pdschsendreql1sw && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${pci_list_in_bip}    Get Field Value From PCAP    field_name=_3gpp.dmrsScramblingSequenceInt
    ...                                         filter_expression=3gpp.dmrsScramblingSequenceInt
    ...                                         attribute_name=show
    ${pci_list_in_bip}    Remove Duplicates    ${pci_list_in_bip}
    ${final_pci_list}    Create List
    FOR    ${item}    IN    @{pci_list_in_bip}
        ${final_pci_list}    Combine Lists    ${final_pci_list}    ${item}
    END
    Sort List    ${final_pci_list}
    ${pci_list_in_bip_len}    Get Length    ${final_pci_list}
    ${rnti_list}    Get Field Value From PCAP    field_name=_3gpp.rnti    filter_expression=3gpp.rnti    attribute_name=show
    ${rnti_list}    Remove Duplicates    ${rnti_list}
    ${rnti_list_len}    Get Length    ${rnti_list}
    Run Keyword And Continue On Failure    Should Be True    ${pci_list_len}==${pci_list_in_bip_len}    msg=pci num is not correct.
    Run Keyword And Continue On Failure    Should Be True    ${rnti_list_len}==${ue_num}    msg=One UE not mapping one rnti.
    ${final_pdschsendreq_dict}    Create Dictionary
    FOR    ${final_pci}    IN    @{final_pci_list}
        Setup Pcap File   file_path=${bip_file_path}    filter=dldata_pdschsendreql1sw && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
        ${pdschsendreq_list}    Get Field Value From PCAP    field_name=DlData_PdschGrantL1sw.patternId_item
        ...                                                  filter_expression=3gpp.dmrsScramblingSequenceInt == ${final_pci}
        ...                                                  attribute_name=show
        ${pdschsendreq_list}    Remove Duplicates    ${pdschsendreq_list}
        ${final_pdschsendreq_list}    Strat To Deal With The List    value_list=${pdschsendreq_list}
        ${final_pdschsendreq_list}    Remove Duplicates    ${final_pdschsendreq_list}
        Remove Values From List     ${final_pdschsendreq_list}    0
        Set To Dictionary    ${final_pdschsendreq_dict}    ${final_pci}    ${final_pdschsendreq_list}
    END
    [Return]    ${final_pdschsendreq_dict}

Get PatternId For UlData_PuschReceiveReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${beam_number}=${numberOfRxBeamforming}
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_puschreceivereq && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${puschreceivereq_list}    Get Field Value From PCAP    field_name=UlData_eCpriConfigStruct_t.patternId_item
    ...                                                     filter_expression=UlData_eCpriConfigStruct_t.patternId_item
    ...                                                     attribute_name=show
    ${puschreceivereq_list}    Remove Duplicates    ${puschreceivereq_list}
    ${final_puschreceivereq_list}    Create List
    FOR    ${puschreceivereq}    IN    @{puschreceivereq_list}
        ${count_list}    Get Match Count    ${puschreceivereq}    0
        ${count_of_0}    Set Variable If    '${beam_number}'=='4Rx'    2    0
        Should Be True    ${count_list}==${count_of_0}
        Should Not Be True    ${puschreceivereq[0]}==${puschreceivereq[1]}
        ${final_puschreceivereq_list}    Combine Lists    ${final_puschreceivereq_list}    ${puschreceivereq}
    END
    ${final_puschreceivereq_list}    Remove Duplicates    ${final_puschreceivereq_list}
    Remove Values From List     ${final_puschreceivereq_list}    0
    [Return]    ${final_puschreceivereq_list}

Get PatternId For UlData_PuschReceiveReqL1RU Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${pci}    ${ue_num}=${1}    ${beam_number}=${numberOfRxBeamforming}
    ${pci_list_length}    Get Length    ${pci}
    ${length1}    Run Keyword If    ${pci_list_length}==${4}    Evaluate    ${2} * ${1}
    ...    ELSE    Evaluate    ${2} * ${ue_num}
    ${length2}    Evaluate    ${4} * ${ue_num}
    ${count_of_value}    Set Variable If    '${beam_number}'=='4Rx'    ${length1}    ${length2}
    ${final_puschreceivereq_dict}    Create Dictionary
    FOR    ${item}    IN    @{pci}
        Setup Pcap File   file_path=${bip_file_path}    filter=uldata_puschreceivereql1ru && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
        ${puschreceivereq_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrantL1ru_t.patternId_item
        ...                                                     filter_expression=3gpp.dmrsScramblingSequenceInt == ${item}
        ...                                                     attribute_name=show
        ${puschreceivereq_list}    Remove Duplicates    ${puschreceivereq_list}
        ${final_puschreceivereq_list}    Strat To Check The List    value_list=${puschreceivereq_list}    count=${count_of_value}
        ${final_puschreceivereq_list}    Remove Duplicates    ${final_puschreceivereq_list}
        Remove Values From List     ${final_puschreceivereq_list}    0
        Set To Dictionary    ${final_puschreceivereq_dict}    ${item}    ${final_puschreceivereq_list}
    END
    [Return]    ${final_puschreceivereq_dict}

Strat To Check The List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${value_list}    ${count}
    ${final_list}    Create List
    FOR    ${value}    IN    @{value_list}
        ${count_list}    Get Match Count    ${value}    0
        Should Be True    ${count_list}==0
        ${value_length}    Get Length    ${value}
        Should Be True    ${value_length}==${count}
        List Should Not Contain Duplicates    ${value}
        ${final_list}    Combine Lists    ${final_list}    ${value}
    END
    [Return]    ${final_list}

Get PatternId For DlData_CsiRsSendReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}
    Setup Pcap File   file_path=${bip_file_path}    filter=dldata_csirssendreql1sw
    ${csirssendreq_patternId_list}    Get Field Value From PCAP    field_name=DlData_CsiRsResourceL1sw_t.patternId_item
    ...                                                            filter_expression=DlData_CsiRsResourceL1sw_t.trsInfo == 0
    ...                                                            attribute_name=show
    ${csirssendreq_patternId_list}    Remove Duplicates    ${csirssendreq_patternId_list}
    ${final_csirssendreq_patternId_list}    Create List
    FOR    ${csirssendreq_patternId}    IN    @{csirssendreq_patternId_list}
        ${final_csirssendreq_patternId_list}    Combine Lists    ${final_csirssendreq_patternId_list}    ${csirssendreq_patternId}
    END
    ${final_csirssendreq_patternId_list}    Remove Duplicates    ${final_csirssendreq_patternId_list}
    Remove Values From List     ${final_csirssendreq_patternId_list}    0
    [Return]    ${final_csirssendreq_patternId_list}

Get PatternId With trsInfo=DISABLED For DlData_CsiRsSendReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${pci}
    ${final_csirssendreq_patternId_dict}    Create Dictionary
    FOR    ${item}    IN    @{pci}
        Setup Pcap File   file_path=${bip_file_path}    filter=dldata_csirssendreql1sw
        ${csirssendreq_trsInfo_list}    Get Field Value From PCAP    field_name=DlData_CsiRsResourceL1sw_t.trsInfo
        ...                                      filter_expression=DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt == ${item}
        ...                                      attribute_name=show
        ${csirssendreq_patternId_list}    Get Field Value From PCAP    field_name=DlData_CsiRsResourceL1sw_t.patternId_item
        ...                                      filter_expression=DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt == ${item}
        ...                                      attribute_name=show
        ${trsInfo_patternId_mapping}    Evaluate    list(zip(${csirssendreq_trsInfo_list},${csirssendreq_patternId_list}))
        ${final_csirssendreq_patternId_list}    List Action For DlData_CsiRsSendReq    value_list=${trsInfo_patternId_mapping}
        ${final_csirssendreq_patternId_list}    Remove Duplicates    ${final_csirssendreq_patternId_list}
        Remove Values From List     ${final_csirssendreq_patternId_list}    0
        Set To Dictionary    ${final_csirssendreq_patternId_dict}    ${item}    ${final_csirssendreq_patternId_list}
    END
    [Return]    ${final_csirssendreq_patternId_dict}

List Action For DlData_CsiRsSendReq
    [Arguments]    ${value_list}
    ${final_list}    Create List
    FOR  ${item}  IN  @{value_list}
        ${result_list}    Get The Related Values From Tuple    keys_list=${item[0]}    values_list=${item[1]}
        ${final_list}    Combine Lists    ${final_list}    ${result_list}
    END
    [Return]    ${final_list}

Get The Related Values From Tuple
    [Arguments]    ${keys_list}    ${values_list}    ${step}=${4}
    ${length}    Get Length    ${keys_list}
    ${result_list}    Create List
    FOR  ${item}  IN RANGE  ${length}
        ${vlaue}    Get From List    ${keys_list}    ${item}
        ${status}    Run Keyword And Return Status    Should Be Equal    ${vlaue}    0
        ${index_value}    Evaluate    int(${item}) * ${step}
        ${index_value_end}    Evaluate    ${index_value} + ${4}
        ${tmp_list}    Create List
        ${result_list}    Run Keyword If    ${status}    Combine Lists    ${result_list}    ${values_list[${index_value}:${index_value_end}]}
        ...    ELSE    Combine Lists    ${result_list}    ${tmp_list}
    END
    [Return]    ${result_list}

Check Symbol In UlData_SrsReceiveReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                In uldtaa_srsReceiveReq, there’re symbol 10 and 12 both scheduled
    [Arguments]    ${bip_file_path}
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceivereq
    ${Symbol_list}    Get Field Value From PCAP    field_name=UlData_srsBmResource_t.symbolPosition
    ...                                            filter_expression=UlData_srsBmResource_t.symbolPosition
    ...                                            attribute_name=show
    ${Symbol_list}    Remove Duplicates    ${Symbol_list}
    ${final_Symbol_list}    Strat To Deal With The List    value_list=${Symbol_list}
    ${final_Symbol_list}    Remove Duplicates    ${final_Symbol_list}
    ${Symbol_list_len}    Get Length    ${final_Symbol_list}
    Should Be True    ${Symbol_list_len}==${2}    msg=Symbol value do not contain 2 items.
    Should Contain    ${final_Symbol_list}    10    msg=srsBmEnable value don't contain 10!
    Should Contain    ${final_Symbol_list}    12    msg=srsBmEnable value don't contain 12!

Get PatternId For Related Message Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${pci}    ${ue_num}=${1}
    ${pdschsendreq_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For DlData_PdschSendReq Via BIP Log    bip_file_path=${bip_file_path}    ue_num=${ue_num}    pci=${pci}
    ${puschreceivereq_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For UlData_PuschReceiveReqL1RU Via BIP Log    bip_file_path=${bip_file_path}    ue_num=${ue_num}    pci=${pci}
    ${csirssendreq_patternId_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId With trsInfo=DISABLED For DlData_CsiRsSendReq Via BIP Log    bip_file_path=${bip_file_path}    pci=${pci}
    [Return]    ${pdschsendreq_dict}    ${puschreceivereq_dict}    ${csirssendreq_patternId_dict}

Compare PatternidList Between CPRT And BIP_Between PDSCH And CSIRS
    [Arguments]    ${pdschsendreq_dict}
    ...            ${puschreceivereq_dict}
    ...            ${csirssendreq_patternId_dict}
    ...            ${cprtPatternIdDict}
    ...            ${pci}
    ...            ${beam_type}=DFTNORMAL
    FOR    ${item}    IN    @{pci}
        ${bipPatternIdList}    Combine Lists    ${pdschsendreq_dict['${item}']}    ${puschreceivereq_dict['${item}']}
        Sort List    ${pdschsendreq_dict['${item}']}
        Sort List    ${csirssendreq_patternId_dict['${item}']}
        Lists Should Be Equal    ${pdschsendreq_dict['${item}']}    ${csirssendreq_patternId_dict['${item}']}
        ${min_value}    Set Variable    ${cprtPatternIdDict['${item}']['${beam_type}'][0]}
        ${max_value}    Set Variable    ${cprtPatternIdDict['${item}']['${beam_type}'][1]}
        ${flilter_list}    Evaluate   [x for x in ${bipPatternIdList} if int(x)>=int(${min_value}) and int(x)<=int(${max_value})]
        ${bipPatternIdList_len}    Get Length    ${bipPatternIdList}
        ${flilter_list_len}    Get Length    ${flilter_list}
        Should Be True    ${bipPatternIdList_len}==${flilter_list_len}
        ...    msg=Beam pattern ids range is not in cprt startup log during cell setup
    END

Get PatternId For PDSCH And CSIRS Message Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${pci}    ${ue_num}=${1}
    ${pdschsendreq_dict}    Get PatternId For DlData_PdschSendReq Via BIP Log    bip_file_path=${bip_file_path}
    ...                                                                          ue_num=${ue_num}
    ...                                                                          pci=${pci}
    ${csirssendreq_patternId_dict}    Get PatternId With trsInfo=DISABLED For DlData_CsiRsSendReq Via BIP Log
    ...    bip_file_path=${bip_file_path}    pci=${pci}
    [Return]    ${pdschsendreq_dict}    ${csirssendreq_patternId_dict}

Compare PatternidList Between CPRT And BIP
    [Arguments]    ${pdschsendreq_dict}
    ...            ${csirssendreq_patternId_dict}
    ...            ${cprtPatternIdDict}
    ...            ${pci}
    ...            ${beam_type}=DEFAULT
    FOR    ${item}    IN    @{pci}
        ${bipPatternIdList}    Combine Lists    ${pdschsendreq_dict['${item}']}    ${csirssendreq_patternId_dict['${item}']}
        ${min_value}    Set Variable    ${cprtPatternIdDict['${item}']['${beam_type}'][1]}
        ${max_value}    Set Variable    ${cprtPatternIdDict['${item}']['${beam_type}'][-1]}
        ${flilter_list}    Evaluate   [x for x in ${bipPatternIdList} if int(x)>=int(${min_value}) and int(x)<=int(${max_value})]
        ${bipPatternIdList_len}    Get Length    ${bipPatternIdList}
        ${flilter_list_len}    Get Length    ${flilter_list}
        Should Be True    ${bipPatternIdList_len}==${flilter_list_len}
        ...    msg=Beam pattern ids range is not in cprt startup log during cell setup
    END

Compare PatternidList Between CPRT And BIP For PUSCH
    [Arguments]    ${puschreceivereq_dict}    ${pci}    ${cprtPatternIdDict}    ${beam_type}=DEFAULT
    FOR    ${item}    IN    @{pci}
        ${puschreceivereq_list}    Set Variable    ${puschreceivereq_dict['${item}']}
        Should Not Be Empty    ${puschreceivereq_list}
        ${min_value}    Set Variable    ${cprtPatternIdDict['${item}']['${beam_type}'][1]}
        ${max_value}    Set Variable    ${cprtPatternIdDict['${item}']['${beam_type}'][-1]}
        ${flilter_list}    Evaluate   [x for x in ${puschreceivereq_list} if int(x)>=int(${min_value}) and int(x)<=int(${max_value})]
        ${puschreceivereq_list_len}    Get Length    ${puschreceivereq_list}
        ${flilter_list_len}    Get Length    ${flilter_list}
        Should Be True    ${puschreceivereq_list_len}==${flilter_list_len}
        ...    msg=Beam pattern ids range is not in cprt startup log during cell setup
    END

Check Whether uldata_srsreceiveRespPs Message In BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                If check no message in bip, so ${whether_in_value} is ${False}
    ...                If check message in bip, so ${whether_in_value} is ${True}
    [Arguments]    ${bip_file_path}    ${whether_in_value}=${False}
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceiverespps
    ${uldata_srsreceiverespps_status}    Run Keyword And Return Status    pcap.get_packets    filter=uldata_srsreceiverespps
    ...                                                                                       pcap_parser=parser
    Should Be Equal    ${uldata_srsreceiverespps_status}    ${whether_in_value}

Check srsSuMimoEnable In UlData_SrsReceiveReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${srsSuMimoEnable_value}=${False}
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceivereq
    ${srsSuMimoEnable_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
    ...                                                     filter_expression=UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
    ...                                                     attribute_name=showname
    ${srsSuMimoEnable_list}    Remove Duplicates    ${srsSuMimoEnable_list}
    ${srsSuMimoEnable_list_len}    Get Length    ${srsSuMimoEnable_list}
    Should Be True    ${srsSuMimoEnable_list_len}==${1}    msg=srsSuMimoEnable value is not unique.
    ${srsSuMimoEnable_list}    Split String    ${srsSuMimoEnable_list[0][0]}    ${SPACE}
    ${srsSuMimoEnable_value}    Evaluate    str(${srsSuMimoEnable_value})
    BuiltIn.Should Be Equal    ${srsSuMimoEnable_list[-1]}   ${srsSuMimoEnable_value}    msg=SsrsSuMimoEnable value is not False!

Check srsSuMimoEnable In UlData_SrsReceiveReq For Special Slot
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${srs_slot_List}    ${srsUePeriodicity}=sl10
    ${new_value1}    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Evaluate    int(${srs_slot_List[0]}) + ${10}
    ${new_value2}    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Evaluate    int(${srs_slot_List[1]}) + ${10}
    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Append To List    ${srs_slot_List}    ${new_value1}
    Run Keyword If    '${srsUePeriodicity}'=='sl10'    Append To List    ${srs_slot_List}    ${new_value2}
    ${srs_slot_List}    Remove Duplicates    ${srs_slot_List}
    ${srsSuMimo_list}    Create List
    FOR    ${srs_slot}   IN    @{srs_slot_List}
        ${filter_with_slot}    Set Variable    3gpp.slot==${srs_slot}
        Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceivereq
        ${srsSuMimoEnable_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
        ...                                                     filter_expression=${filter_with_slot}
        ...                                                     attribute_name=showname
        ${srsSuMimoEnable_list}    Remove Duplicates    ${srsSuMimoEnable_list}
        ${value_list}    Split String    ${srsSuMimoEnable_list[0][0]}    ${SPACE}
        ${value}    Evaluate    str(${True})
        ${status}    Run Keyword And Return Status    BuiltIn.Should Be Equal    ${value_list[-1]}   ${value}
        Run Keyword If    ${status}    Append To List    ${srsSuMimo_list}    ${srs_slot}
    END
    ${srsSuMimo_list_len}    Get Length    ${srsSuMimo_list}
    Should Be True    ${srsSuMimo_list_len}==${2}
    ...    msg=Not 2 special slots equal true in one frame when 1208 and srsUePeriodicity=slots10.
    ${difference}    Evaluate    int(${srsSuMimo_list[0]}) - int(${srsSuMimo_list[1]})
    ${abs_difference}    Evaluate    abs(${difference})
    Should Be True    ${abs_difference}==${10}

Check srsBmEnable In UlData_SrsReceiveReq Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${srsBmEnable_value}=${True}
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_srsreceivereq
    ${srsBmEnable_list}    Get Field Value From PCAP    field_name=UlData_srsReceiveReqSubcell_t.srsBmEnable
    ...                                                 filter_expression=UlData_srsReceiveReqSubcell_t.srsBmEnable
    ...                                                 attribute_name=showname
    ${srsBmEnable_list}    Remove Duplicates    ${srsBmEnable_list}
    ${srsBmEnable_list_len}    Get Length    ${srsBmEnable_list}
    Should Be True    ${srsBmEnable_list_len}==${1}    msg=srsBmEnable value is not unique.
    ${srsBmEnable_list}    Split String    ${srsBmEnable_list[0][0]}    ${SPACE}
    ${srsBmEnable_value}    Evaluate    str(${srsBmEnable_value})
    BuiltIn.Should Be Equal    ${srsBmEnable_list[-1]}   ${srsBmEnable_value}    msg=srsBmEnable value is not True!

Check The Rank Of PUSCH Via BIP Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${bip_file_path}    ${pusch_rank}=2
    Setup Pcap File   file_path=${bip_file_path}    filter=uldata_puschreceivereq && 3gpp.rnti != 65535 && 3gpp.rnti != 65521
    ${pusch_rank_list}    Get Field Value From PCAP    field_name=UlData_puschReceiveReqGrant_t.numOfLayers
    ...                                                filter_expression=UlData_puschReceiveReqGrant_t.numOfLayers
    ...                                                attribute_name=show

    ${pusch_rank_list}    Remove Duplicates    ${pusch_rank_list}
    ${pusch_rank_list_len}    Get Length    ${pusch_rank_list}
    Should Be True    ${pusch_rank_list_len}==${1}    msg=pusch_rank value is not unique.
    BuiltIn.Should Be Equal    ${pusch_rank_list[0][0]}   ${pusch_rank}    msg=pusch_rank value is not ${pusch_rank}!

Check Tput With Power UE For Multi UE
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Descrition: Verify throughput with power ue.
    [Arguments]    ${direction_component_list}
    ...            ${tput_log}
    ...            ${expect_ul_tput}=${None}
    ...            ${expect_dl_tput}=${None}
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${target_avg_percent}=0.95
    ...            ${min_percent}=0.85
    ...            ${actCarrierAggregation}=${False}
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=spark
    ...            ${ue_type}=${ue_type}
    ${list_nrcell_ids}    Get NRCELLID based on CELLID    cellid=${cellid}
    ...                                                   connection=${connection}
    ...                                                   list_all_cell_ids=${list_all_cell_ids}
    ...                                                   gnb_index=${gnb_index}
    FOR    ${item}    IN    @{direction_component_list}
        ${direction}    Set Variable    ${item.split('_')}[0]
        ${expect_tput}    Set Variable If    '${direction}'=='UL'     ${expect_ul_tput}
        ...                                  '${direction}'=='DL'     ${expect_dl_tput}
        Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}
        ...                                                           log=${tput_log}    cells=${list_nrcell_ids}
        ...                                                           target_throughput=${expect_tput}
        ...                                                           target_avg_percent=${target_avg_percent}
        ...                                                           actCarrierAggregation=${actCarrierAggregation}
        ...                                                           check_source=${check_source}
        ...                                                           min_percent=${min_percent}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Cell PhysCellId Mapping
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    gnb_index=0
    ${cells_info}    coam.get_cell_list    connection=${connection}
    ${cell_num}    Get Length    ${cells_info['cells']['nr']}
    ${cell_pci_dict}    Create Dictionary
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        ${pci}    Evaluate    str(${cells_info['cells']['nr'][${cell_id}]['physicalCellId']})
        ${cell_id}    Evaluate    ${cell_id}+1
        ${cell_id}    Evaluate    str(${cell_id})
        Set To Dictionary    ${cell_pci_dict}    ${cell_id}    ${pci}
    END
    [Return]    ${cell_pci_dict}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Capture TTI with gnb logs For 10887
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...              Description: Capturing event trace log,Also will check the tput value by tti trace
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=10
    ...            ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${file_path}    Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}/ttitrace_streaming_${timestamp}
    ${tti_file_path_ul}    Decode Ttitrace Logs    collector_names=${collector_names}    direction=ul
    Sleep    5sec
    ${tti_file_path_dl}    Decode Ttitrace Logs    collector_names=${collector_names}    direction=dl
    [Return]    ${tti_file_path_ul}    ${tti_file_path_dl}

Check Multi UEs Bler Via TTiTrace
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${tti_file_path_ul}    ${tti_file_path_dl}    ${unexpect_bler}=0.02
    ${unexpect_bler}    Evaluate    float(${unexpect_bler})
    ${ul_details}    Create Dictionary
    ${output_dic}    calculate_ubler_and_ultput_for_ues    file_path=${tti_file_path_ul}
    ${ul_details}    Evaluate    dict(${ul_details}) | dict(${output_dic})
    ${ul_rnti_list}    Get Dictionary Keys    ${ul_details}
    FOR    ${rnti}    IN    @{ul_rnti_list}
        ${average_bler}    Set Variable    ${ul_details['${rnti}']['bler']}
        Run Keyword If    ${average_bler}>${unexpect_bler}    Fail    msg=avg ul bler of ue ${rnti} is ${average_bler}, too high!
    END

    ${dl_details}    Create Dictionary
    ${output_dic}    calculate_dlbler_and_dltput_for_ues    file_path=${tti_file_path_dl}
    ${dl_details}    Evaluate    dict(${dl_details}) | dict(${output_dic})
    ${dl_rnti_list}    Get Dictionary Keys    ${dl_details}
    FOR    ${rnti}    IN    @{dl_rnti_list}
        ${average_bler}    Set Variable    ${dl_details['${rnti}']['bler']}
        Run Keyword If    ${average_bler}>${unexpect_bler}    Fail    msg=avg dl bler of ue ${rnti} is ${average_bler}, too high!
    END
