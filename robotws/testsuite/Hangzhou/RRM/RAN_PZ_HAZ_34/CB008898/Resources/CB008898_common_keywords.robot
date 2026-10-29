*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB008898

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008247/Resources/CB008247_case_steps_SG3.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008898/Resources/CB008898_Variables.py

*** Variables ***
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${dl_throughput}    300M
@{beamSetType}    DFTNORMAL    DFTNORMAL
${NSA_attach_mode}          5G_NSA
${SA_attach_mode}           5G_SA
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${frequency_364}    2600_0.25_ALL | 0DB~90DB
@{gnb_id}    36411    10175
${APN_36411}    ${tl.ues[0].pdn}
${APN_10175}    ${tl.ues[0].pdn}
${ue_mode_36411}    yiyuan
${ue_mode_10175}    NULL
${process_num_10175}    ${4}
${process_num_36411}    ${3}
${PCI_filter_trunk}    DlData_PdschGrantL1sw.pdschScramblingSeqInit
${PCI_filter_ntrunk}    DlData_PdschGrant.pdschScramblingSeqInit
${xpath_trunk}    DlData_PdschGrantL1sw
${xpath_ntrunk}    DlData_PdschGrant
${filter_trunk}    dldata_pdschsendreql1sw
${filter_ntrunk}    dldata_pdschsendreq
*** Keywords ***
Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${ParameterToDelete}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    Delete_Para_Online=${ParameterToDelete}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Online Close 2200 on gnb
    [Arguments]    ${Add_Para_Online}=${List_TO_ADD_2200_Close}
    Modify Parameters for Cases    Modify_Para_Online=${Modify_Para_Online_2200_Close}
    ...    Delete_Para_Online=${ParameterToDelete_2200_Close}
    Check the COAM gnb RU status ready
    Online modify NIDD on gnb    Add_Para_Online=${Add_Para_Online}

Online recover 2200 on gnb
    [Arguments]    ${Add_Para_Online}=${LIST_TO_ADD_2200_${gnb_instance0}}
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_2200_Open}    Add_Para_Online=${Add_Para_Online}

prepare UE and MCS
    [Arguments]
    Log to console    \n*** prepare MCS ***
    MCS SETUP AND SET ATT
    Prepare MultiUE with client

prepare MultilUE and MCS
    [Arguments]    ${att_value_UE0}=${10}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${0}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${87}    ${horizontal_1}=${14}   ${vertical_2}=${86}    ${horizontal_2}=${29}
    ...    ${vertical_3}=${82}    ${horizontal_3}=${-14}    ${vertical_4}=${80}    ${horizontal_4}=${-30}
    ...    ${vertical_5}=${-7}    ${horizontal_5}=${-57}   ${vertical_6}=${-16}    ${horizontal_6}=${-57}
    ...    ${vertical_7}=${3}    ${horizontal_7}=${11}    ${vertical_8}=${-9}    ${horizontal_8}=${11}
    Log to console    step2 prepare UE and MCS
    Prepare and setup MCS
    MCS 2UE AND SET ATT    att_value_UE0=${att_value_UE0}    att_value_UE1=${att_value_UE1}
    ...    att1_value_UE0=${att1_value_UE0}    att1_value_UE1=${att1_value_UE1}
    ...    vertical_1=${vertical_1}    horizontal_1=${horizontal_1}    vertical_2=${vertical_2}    horizontal_2=${horizontal_2}
    ...    vertical_3=${vertical_3}    horizontal_3=${horizontal_3}    vertical_4=${vertical_4}    horizontal_4=${horizontal_4}
    ...    vertical_5=${vertical_5}    horizontal_5=${horizontal_5}    vertical_6=${vertical_6}    horizontal_6=${horizontal_6}
    ...    vertical_7=${vertical_7}    horizontal_7=${horizontal_7}    vertical_8=${vertical_8}    horizontal_8=${horizontal_8}
    Prepare MultiUE with client

Prepare and setup MCS
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='topyoung'
    ...    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${frequency_364}

MCS 2UE AND SET ATT
    [Arguments]
    ...    ${att_value_UE0}=${90}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${90}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${96}    ${horizontal_1}=${13}   ${vertical_2}=${96}    ${horizontal_2}=${26}
    ...    ${vertical_3}=${102}    ${horizontal_3}=${-19}    ${vertical_4}=${102}    ${horizontal_4}=${-36}
    ...    ${vertical_5}=${-7}    ${horizontal_5}=${-57}   ${vertical_6}=${-16}    ${horizontal_6}=${-57}
    ...    ${vertical_7}=${3}    ${horizontal_7}=${11}    ${vertical_8}=${-9}    ${horizontal_8}=${11}
    Log to console    Set MCS PA
    Run keyword if    '${mcs_type}'=='haojin'
    ...    HAOJIN MCS SETUP AND SET ATT for MultiUE    mcs_type=${mcs_type}
    ...    att_value_UE0=${att_value_UE0}    att_value_UE1=${att_value_UE1}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${vertical_1}    horizontal_1=${horizontal_1}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${vertical_2}    horizontal_2=${horizontal_2}
    ...    P5_out=${9}     P6_out=${10}    vertical_3=${vertical_3}    horizontal_3=${horizontal_3}
    ...    P7_out=${11}    P8_out=${12}    vertical_4=${vertical_4}    horizontal_4=${horizontal_4}
    Run keyword if    '${mcs_type}'=='topyoung'     Run Keywords
    ...    TOPYOUNG MCS SETUP AND SET ATT for Two UEs with different ATT    mcs_type=${mcs_type}
    ...    att_value_UE0=${att1_value_UE0}    att_value_UE1=${att1_value_UE1}
    ...    P1_out=${5}    P2_out=${6}    vertical_1=${vertical_5}    horizontal_1=${horizontal_5}
    ...    P3_out=${7}    P4_out=${8}    vertical_2=${vertical_6}    horizontal_2=${horizontal_6}
    ...    P5_out=${13}     P6_out=${14}    vertical_3=${vertical_7}    horizontal_3=${horizontal_7}
    ...    P7_out=${15}    P8_out=${16}    vertical_4=${vertical_8}    horizontal_4=${horizontal_8}
    ...    AND    TOPYOUN SET Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=${90}
    ...    att_value2=${90}     first_beam_begin_output_port=${5}      first_beam_end_output_port=${8}    begin_input_port=${65}
    ...    second_beam_begin_output_port=${13}    second_beam_end_output_port=${15}    end_input_port=${128}

Get 2Cell CprtPatternId
    [Arguments]    ${cell_idx_pcell}=${1}    ${cell_idx_scell}=${2}    ${beamSetType}=${beamSetType}
    ${cprtPatternIdDict_cell_List}    Create List
    ${cprtPatternIdDict_cell1}    Get BeampatternIdDict From CPRT Logs new version    cell_idx=${cell_idx_pcell}
    ...    patternIdList_index=${-1}
    ${cprtPatternIdList_cell1}    Get From Dictionary    ${cprtPatternIdDict_cell1}    ${beamSetType[0]}
    ${cprtPatternIdList_cell1_length}    get length    ${cprtPatternIdList_cell1}
    Should Be True    ${cprtPatternIdList_cell1_length} > 0
    ${cprtPatternIdDict_cell2}    Get BeampatternIdDict From CPRT Logs new version    cell_idx=${cell_idx_scell}
    ...    patternIdList_index=${-1}
    ${cprtPatternIdList_cell2}    Get From Dictionary    ${cprtPatternIdDict_cell2}    ${beamSetType[1]}
    ${cprtPatternIdList_cell2_length}    get length    ${cprtPatternIdList_cell2}
    Should Be True    ${cprtPatternIdList_cell2_length} > 0
    Append to List    ${cprtPatternIdDict_cell_List}    ${cprtPatternIdDict_cell1}    ${cprtPatternIdDict_cell2}
    [Return]    ${cprtPatternIdDict_cell_List}

Get 2Cell phyCellId
    [Arguments]    ${cell_idx_pcell}=${1}    ${cell_idx_scell}=${2}
    ${phyCellId_cell_List}    Create List
    ${phyCellId_cell1}=    get required cell info   required_info=physicalCellId    cell_index=${cell_idx_pcell}   gnb_index=${0}
    ${phyCellId_cell2}=    get required cell info   required_info=physicalCellId    cell_index=${cell_idx_scell}   gnb_index=${0}
    Append to List    ${phyCellId_cell_List}    ${phyCellId_cell1}    ${phyCellId_cell2}
    [Return]    ${phyCellId_cell_List}

MCS SETUP AND SET ATT
    [Arguments]
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    att_value_1=${25}     att_value_2=${25}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${10}    att_value2=${15}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    frequency=None    att_value1=${0}    att_value2=${0}    vertical_angle=${-6}
    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-15}

Start 2CC Traffic And Capture Biplog
    [Arguments]     ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL    ${dl_throughput}=${dl_throughput}
    ...    ${counter_id}=${EMPTY}    ${dic_path_1}=${EMPTY}    ${dic_path_2}=${EMPTY}    ${value}=${EMPTY}    ${UE_NUM}=${1}
    ...    ${dl_throughput}=${dl_throughput}    ${process_num}=${process_num_${gnb_instance0}}    ${sleep_time}=180s
    ...    ${target_dir}=${epc_log_path}    ${target_file_name}=l1l2bip    ${capture_time}=3s
    ${len_counter}    Get Length    ${counter_id}
    Run keyword If    ${len_counter}>${0}    Prepare to caculate PM counter    period=start
    Log to console    \n*** start traffic and check tput ***
    Wait until keyword succeeds    3X    5s    Start UE traffic and check 2CC tput
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    dl_throughput=${dl_throughput}    UE_NUM=${UE_NUM}    process_num=${process_num}    sleep_time=${sleep_time}
    Run keyword If    ${len_counter}>${0}    Prepare to caculate PM counter    period=end
    Run keyword If    ${len_counter}>${0}    Check counter for 8898    counter_id=${counter_id}
    ...    dic_path_1=${dic_path_1}    dic_path_2=${dic_path_2}    value=${value}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download
    ...    target_dir=${target_dir}    target_file_name=${target_file_name}    capture_time=${capture_time}
    [Teardown]    stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
    [Return]     ${bip}

Start 2UEs 2CC Traffic And Capture Biplog
    [Arguments]     ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL    ${dl_throughput}=${dl_throughput}
    ...    ${counter_id}=${EMPTY}    ${dic_path_1}=${EMPTY}    ${dic_path_2}=${EMPTY}    ${value_min_pcell}=${EMPTY}
    ...    ${value_max_pcell}=${EMPTY}    ${value_min_scell}=${EMPTY}    ${value_max_scell}=${EMPTY}    ${UE_NUM}=${1}
    ...    ${paired_pcell}=True    ${paired_scell}=True    ${scell_is_PMIbeam}=False
    ...    ${process_num}=${process_num_${gnb_instance0}}    ${sleep_time}=180s
    ...    ${target_dir}=${epc_log_path}    ${target_file_name}=l1l2bip    ${capture_time}=3s
    ${len_counter}    Get Length    ${counter_id}
    Run keyword If    ${len_counter}>${0}    Prepare to caculate PM counter    period=start
    Log to console    \n*** start traffic and check tput ***
    Start UE traffic and check 2CC tput    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    dl_throughput=${dl_throughput}
    ...    UE_NUM=${UE_NUM}    process_num=${process_num}    sleep_time=${sleep_time}
    Run keyword If    ${len_counter}>${0}    Prepare to caculate PM counter    period=end
    Run keyword If    ${len_counter}>${0} and ${paired_pcell} == True    Check counter for 8898_B paired
    ...    counter_id=${counter_id}    dic_path_1=${dic_path_1}    value_min=${value_min_pcell}    value_max=${value_max_pcell}
    ...    ELSE IF    ${len_counter}>${0} and ${paired_pcell} != True
    ...    Check counter for 8898_B Unpaired    counter_id=${counter_id}    dic_path=${dic_path_1}
    Run keyword If    ${len_counter}>${0} and ${paired_scell} == True    Check counter for 8898_B paired    counter_id=${counter_id}
    ...    dic_path_1=${dic_path_2}    value_min=${value_min_scell}    value_max=${value_max_scell}
    ...    ELSE IF    ${len_counter}>${0} and ${paired_scell} != True and ${scell_is_PMIbeam} == False
    ...    Check counter for 8898_B Unpaired    counter_id=${counter_id}    dic_path=${dic_path_2}
    ...    ELSE IF    ${len_counter}>${0} and ${paired_scell} != True and ${scell_is_PMIbeam} == True
    ...    Check counter for 8898_B Unpaired use PMIbeam    counter_id=${counter_id}    dic_path=${dic_path_2}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download
    ...    target_dir=${target_dir}    target_file_name=${target_file_name}    capture_time=${capture_time}
    [Teardown]    Detech and stop multiues traffic     UE_NUM=${2}
    [Return]     ${bip}

Start UE traffic and check 2CC tput
    [Arguments]     ${tput_dl_pcell}=${tput_dl_pcell}    ${tput_dl_scell}=${tput_dl_scell}    ${duration}=30s
    ...    ${scellid}=2   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${0}    ${ue_type}=huawei    ${UE_NUM}=${1}
    ...    ${dl_port}=${DL_PORT}    ${dl_throughput}=${dl_throughput}
    ...    ${process_num}=${process_num_${gnb_instance0}}    ${sleep_time}=180s
    Start multi UE traffic    UE_NUM=${UE_NUM}    dl_port=${dl_port}    dl_throughput=${dl_throughput}    process_num=${process_num}
    sleep    ${sleep_time}
    Check 2CC tput    scellid=${scellid}    pcellid=${pcellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}
    ...    ue_type=${ue_type}    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    duration=${duration}

Start multi UE traffic
    [Arguments]    ${UE_NUM}=${1}    ${dl_port}=${DL_PORT}    ${dl_throughput}=${dl_throughput}
    ...    ${process_num}=${process_num_${gnb_instance0}}
    FOR    ${index}    IN RANGE   ${UE_NUM}
        Start MUE dltraffic with appserver      ue_addr=${${uegroup}[${index}]_IP}    dl_port=${dl_port}
        ...    dl_throughput=${dl_throughput}    process_num=${process_num}
        ${dl_port}    Evaluate    ${dl_port}+100
    END

Check 2CC tput
    [Arguments]     ${tput_dl_pcell}=${tput_dl_pcell}    ${tput_dl_scell}=${tput_dl_scell}    ${duration}=30s
    ...    ${scellid}=2   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${0}    ${ue_type}=huawei
    log to console    check 2CC tput with nrcellid
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list    ${nrcellid_pcell}
    ${nrcellid_scell}    Create list    ${nrcellid_scell}
    ${tput_log_prime}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}    gnb_index=${0}
    ${tput_log_external}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}   gnb_index=${0}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}

Detech and stop multiues traffic
    [Arguments]    ${appserver}=APPserver    ${UE_NUM}=${1}    ${alias}=pioneer
    FOR    ${index}    IN RANGE   ${UE_NUM}
        Close the iperf process on APPserver    port=${dl_port}   appserver=${appserver}
        Detach MultiUE    ue=${uegroup}[${index}]
        ${dl_port}    Evaluate    ${dl_port}+100
    END
    Run Keyword And Ignore Error    client.stoplog      service=${alias}

Start multiUEs traffic and check 2CC tput on UE side
    [Arguments]     ${tput_dl_ALL}=${tput_dl_pcell}    ${dl_throughput}=${dl_throughput}
    Start multiUEs traffic with appserver    dl_tput_multiue=${dl_throughput}
    sleep    30s
    log to console    check 2CC tput with nrcellid
    Check multiUEs traffic with pioneer client    tput_target=${tput_dl_ALL}


Check Counter for 8898
     [Arguments]    ${counter_id}=NULL    ${dic_path_1}=NULL    ${dic_path_2}=NULL    ${value}=NULL
    sleep    60s
    Check the PM counter should be greater than 1    counter_id=${counter_id}    dic_path=${dic_path_1}    value=${value}
    Check the PM counter should be greater than 1    counter_id=${counter_id}    dic_path=${dic_path_2}    value=${value}

Check counter for 8898_B paired
    [Arguments]    ${counter_id}=NULL    ${dic_path_1}=NULL    ${value_min}=NULL    ${value_max}=NULL
    sleep    60s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id}    dic_path=${dic_path_1}
    ${M55308C34005_2layer}    Set Variable    ${counter_value_list}[0]
    ${M55308C34006_3layer}    Set Variable    ${counter_value_list}[1]
    ${M55308C34007_4layer}    Set Variable    ${counter_value_list}[2]
    ${M55308C34008_5layer}    Set Variable    ${counter_value_list}[3]
    ${M55308C34009_6layer}    Set Variable    ${counter_value_list}[4]
    ${M55308C34010_7layer}    Set Variable    ${counter_value_list}[5]
    ${M55308C34011_8layer}    Set Variable    ${counter_value_list}[6]
    ${M55308C34013}    Set Variable    ${counter_value_list}[7]
    ${M55308C34028}    Set Variable    ${counter_value_list}[8]
    ${M55308C34029}     Set Variable    ${counter_value_list}[9]
    Should Be True    ${value_min} < ${M55308C34011_8layer} < ${value_max}
    Should Be True    ${value_min} < ${M55308C34013} < ${value_max}
    Should Be True    ${M55308C34028}/${M55308C34029}*100 > 95

Check counter for 8898_B unpaired
    [Arguments]    ${counter_id}=NULL    ${dic_path}=NULL
    sleep    60s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id}    dic_path=${dic_path}
    ${M55308C34005_2layer}    Set Variable    ${counter_value_list}[0]
    ${M55308C34006_3layer}    Set Variable    ${counter_value_list}[1]
    ${M55308C34007_4layer}    Set Variable    ${counter_value_list}[2]
    ${M55308C34008_5layer}    Set Variable    ${counter_value_list}[3]
    ${M55308C34009_6layer}    Set Variable    ${counter_value_list}[4]
    ${M55308C34010_7layer}    Set Variable    ${counter_value_list}[5]
    ${M55308C34011_8layer}    Set Variable    ${counter_value_list}[6]
    ${M55308C34013}    Set Variable    ${counter_value_list}[7]
    ${M55308C34028}    Set Variable    ${counter_value_list}[8]
    ${M55308C34029}     Set Variable    ${counter_value_list}[9]
    Should Be True    ${M55308C34005_2layer} == 0
    Should Be True    ${M55308C34006_3layer} == 0
    Should Be True    ${M55308C34007_4layer} == 0
    Should Be True    ${M55308C34008_5layer} == 0
    Should Be True    ${M55308C34009_6layer} == 0
    Should Be True    ${M55308C34010_7layer} == 0
    Should Be True    ${M55308C34011_8layer} == 0
    Should Be True    ${M55308C34013} == 0
    Should Be True    ${M55308C34028} == 0
    Should Be True    ${M55308C34029} > 0

Check counter for 8898_B Unpaired use PMIbeam
    [Arguments]    ${counter_id}=NULL    ${dic_path}=NULL
    sleep    60s
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id}    dic_path=${dic_path}
    ${M55308C34005_2layer}    Set Variable    ${counter_value_list}[0]
    ${M55308C34006_3layer}    Set Variable    ${counter_value_list}[1]
    ${M55308C34007_4layer}    Set Variable    ${counter_value_list}[2]
    ${M55308C34008_5layer}    Set Variable    ${counter_value_list}[3]
    ${M55308C34009_6layer}    Set Variable    ${counter_value_list}[4]
    ${M55308C34010_7layer}    Set Variable    ${counter_value_list}[5]
    ${M55308C34011_8layer}    Set Variable    ${counter_value_list}[6]
    ${M55308C34013}    Set Variable    ${counter_value_list}[7]
    ${M55308C34028}    Set Variable    ${counter_value_list}[8]
    ${M55308C34029}     Set Variable    ${counter_value_list}[9]
    Should Be True    ${M55308C34005_2layer} == 0
    Should Be True    ${M55308C34006_3layer} == 0
    Should Be True    ${M55308C34007_4layer} == 0
    Should Be True    ${M55308C34008_5layer} == 0
    Should Be True    ${M55308C34009_6layer} == 0
    Should Be True    ${M55308C34010_7layer} == 0
    Should Be True    ${M55308C34011_8layer} == 0
    Should Be True    ${M55308C34013} == 0
    Should Be True    ${M55308C34028} == 0
    Should Be True    ${M55308C34029} == 0

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    timeout=300
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Calculate PatternidList Diff From CPRT and BIP
    [Arguments]    ${cprtPatternIdList}    ${bipPatternIdList}
    ${PatternidList_diff_2beam}    Create List
    FOR    ${bipPatternId}    IN    @{bipPatternIdList}
        ${PatternidList Diff}    Evaluate    ${bipPatternId}-${cprtPatternIdList[0]}
        Append to List    ${PatternidList_diff_2beam}    ${PatternidList Diff}
    END
    [Return]    ${PatternidList_diff_2beam}

Check 2CC DFTBeam Should equal/not_equal
    [Arguments]    ${file_path}    ${beamSetType}=${beamSetType}    ${rnti}=${None}
    ...    ${cell_idx_pcell}=${1}    ${cell_idx_scell}=${2}    ${Sync}=True
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    get_release_check_result    release_year_diff=25    release_num_diff=1
    Log to console    \n*** check 2CC DFTBeam ***
    ${PatternidList_diff_2beam_2CC}    Create List
    ${cprtPatternIdDict_cell_List}    Get 2Cell CprtPatternId    cell_idx_pcell=${cell_idx_pcell}    cell_idx_scell=${cell_idx_scell}
    ...    beamSetType=${beamSetType}
    ${phyCellId_cell_List}    Get 2Cell phyCellId    cell_idx_pcell=${cell_idx_pcell}    cell_idx_scell=${cell_idx_scell}
    FOR    ${index}    ${phyCellId_cell}    IN ENUMERATE    @{phyCellId_cell_List}
        ${cprtPatternIdList}    ${bipPatternIdList}    Run keyword If    '${check_result}'=='True'
        ...    Get PatternidList From CPRT and BIP with mcshark
        ...    file_path=${file_path}    beamSetType=${beamSetType[${index}]}    rnti=${rnti}
        ...    cprtPatternIdDict=${cprtPatternIdDict_cell_List[${index}]}    phyCellId=${phyCellId_cell}
        ...    PCI_filter=${PCI_filter_trunk}    xpath=${xpath_trunk}    filter=${filter_trunk}
        ...    ELSE    Get PatternidList From CPRT and BIP with mcshark
        ...    file_path=${file_path}    beamSetType=${beamSetType[${index}]}    rnti=${rnti}
        ...    cprtPatternIdDict=${cprtPatternIdDict_cell_List[${index}]}    phyCellId=${phyCellId_cell}
        ...    PCI_filter=${PCI_filter_ntrunk}    xpath=${xpath_ntrunk}    filter=${filter_ntrunk}
        Remove Values From List    ${bipPatternIdList}    0    65535
        ${bipPatternIdList_length}    get length     ${bipPatternIdList}
        Should Be True    ${bipPatternIdList_length} > 0
        ${cprtPatternIdList_length}    get length    ${cprtPatternIdList}
        Should Be True    ${cprtPatternIdList_length} > 0
        ${compare_status}    Run Keyword If    '${beamSetType[${index}]}'!='DFTTAPERING'
        ...    Compare PatternidList From CPRT and BIP
        ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
        ${compare_status1}    ${bipPatternIdList1}    Run Keyword If    '${beamSetType[${index}]}'=='DFTTAPERING'
        ...    Compare PatternidList From CPRT and BIP for paired or unpaired
        ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
        ${compare_status}    Run Keyword If    '${beamSetType[${index}]}'=='DFTTAPERING'    Set Variable    ${compare_status1}
        ...    ELSE    Set Variable    ${compare_status}
        ${bipPatternIdList}    Run Keyword If    '${beamSetType[${index}]}'=='DFTTAPERING'    Set Variable    ${bipPatternIdList1}
        ...    ELSE    Set Variable    ${bipPatternIdList}
        Run Keyword If   ${compare_status}!= ${True}    FAIL    "${beamSetType[${index}]} Beam is not used!"
        ${PatternidList_diff_2beam}    Calculate PatternidList Diff From CPRT and BIP
        ...    cprtPatternIdList=${cprtPatternIdList}    bipPatternIdList=${bipPatternIdList}
        Append to List    ${PatternidList_diff_2beam_2CC}    ${PatternidList_diff_2beam}
    END
    Run keyword IF    ${Sync}==True
    ...    Lists Should Be Equal    ${PatternidList_diff_2beam_2CC[0]}    ${PatternidList_diff_2beam_2CC[1]}

Compare PatternidList From CPRT and BIP for paired or unpaired
    [Arguments]    ${cprtPatternIdList}    ${bipPatternIdList}
    ${bipPatternIdList_tapering}    Create List
    FOR    ${bipPatternId}    IN    @{bipPatternIdList}
        Run keyword If   ${cprtPatternIdList[0]} <= ${bipPatternId} <= ${cprtPatternIdList[1]}
        ...    Append To List    ${bipPatternIdList_tapering}    ${bipPatternId}
    END
    ${status}    Run keyword and return status    Should Not Be Empty    ${bipPatternIdList_tapering}
    Run Keyword If   ${status}!=True    FAIL    "DFTTAPERING and DFTNORMAL Beam is not used!"
    [Return]    ${status}    ${bipPatternIdList_tapering}

Get EnergySavingState
    [Arguments]    ${required_info}=energySavingState    ${status}=reducedEnergySaving    ${cell_index}=${1}
    ${get_status}    get required cell info    required_info=${required_info}    cell_index=${cell_index}
    should be equal    ${get_status}    ${status}

Multi UE attach and get UE_RNTI_ID with DIFF cell
    [Arguments]    ${filename1}    ${filename2}    ${gnb_instance0}=${gnb_instance0}
    ...    ${Modify_Para_Online_cell1}=${Modify_Para_Online_cell1_attach_${gnb_instance0}}
    ...    ${Modify_Para_Online_cell2}=${Modify_Para_Online_cell2_attach_${gnb_instance0}}
    Run Keyword And Ignore Error    Detach MultiUE    ue=${uegroup}
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_cell1}
    ${UE1_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename1}    ue_alias=${uegroup}[0]
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_cell2}
    ${UE2_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename2}    ue_alias=${uegroup}[1]
    [Return]    ${UE1_RNTI_ID[0]}    ${UE2_RNTI_ID[0]}

get UE_RNTI_ID with DIFF cell
    [Arguments]    ${filename1}    ${filename2}    ${gnb_instance0}=${gnb_instance0}
    Run Keyword And Ignore Error    Detach MultiUE    ue=${uegroup}
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_attach_${gnb_instance0}}
    ${UE2_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename2}    ue_alias=${uegroup}[1]
    ${UE1_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename1}    ue_alias=${uegroup}[0]
    [Return]    ${UE1_RNTI_ID[0]}    ${UE2_RNTI_ID[0]}

Multi UE attach and get UE_RNTI_ID
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${UE_NUM}=${1}    ${ue_alias}=${uegroup}[0]
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    Run keyword if     "${UE_NUM}" == "${1}"
    ...    MultiUE one Attach with client    ue_alias=${ue_alias}    apn=${APN_${gnb_instance0}}
    ...    ELSE     MultiUEs Attach with client    apn=${APN_${gnb_instance0}}
    sleep    5s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${filename}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    [Return]    ${UE_RNTI_ID}

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    ${UE_RNTI_ID}    Remove Duplicates    ${UE_RNTI_ID}
    [Return]    ${UE_RNTI_ID}

Get BeampatternIdDict From CPRT Logs when enable 8133
    [Documentation]
    ...                Desription: Get patternIdDict from cprt log.
    ...                PREDEFINED beam, PMI beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=CellParametersReq
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*CellParametersReq(.*?)\\r\\r\\n.*CellParametersReq(.*?)ruMaxRemasks*
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1    2    3
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${patternIdInfoList_log2}    Run Keyword If    ${patternIdInfoList_len} == ${0}
    ...    Fetch PatternIdInfoList From CPRT Logs    cell_idx=${cell_idx}    connection=${connection}
    ${patternIdInfoList_log}    set variable if    ${patternIdInfoList_len} == ${0}   ${patternIdInfoList_log2}    ${patternIdInfoList_log}
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch BeampatternId Of Different Beams From Output    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${cprtPatternIdDict}
