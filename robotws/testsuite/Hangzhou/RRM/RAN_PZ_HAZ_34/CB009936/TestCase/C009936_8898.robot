*** Settings ***
Force Tags    PY36
Documentation     author: qingqing zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB009936

Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008898/Resources/CB008898_common_keywords.robot
Variables         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_variables.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/spark_multiUE.robot

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Common Case TestLine Setup for gnb1

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Common Case TestLine Setup    is_commission=True
...                                             golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}.xml    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/SCF/
${MRBTS1_ID}    ${tl.gnbs[0].instance_id}
${tput_dl_pcell_paired}    2800
${tput_dl_scell_paired}    1000
${tput_dl_pcell_1UE_coma}    800
${tput_dl_scell_1UE_coma}    350
${tput_dl_pcell_2UE_coma}    100
${tput_dl_scell_2UE_coma}    100
${dl_throughput}      500M
@{beamSetType_paired}    DFTTAPERING    DFTTAPERING
@{beamSetType_A_B_01}    DFTNORMAL    DFTNORMAL
@{beamSetType_legcy}    DYNAMIC    DYNAMIC
${filename_attach_8898_UE1}    /CB009936_CB008898_attach1.pcap
${filename_attach_8898_UE2}    /CB009936_CB008898_attach2.pcap
@{allow_fault_list}    4291    6327
@{UE_NUM}    ${0}    ${1}
#${UE1_RNTI_ID}    316
#${UE2_RNTI_ID}    48936

*** Test Cases ***
[1]CB009936_CB008898-B#B1_002_Scell_MUMIMO_pair_with_DFT_beams_then_fallback_to_legacy_beams_when_SRS_CoMa_aged
    [Documentation]
    ...    This case is check throughput when enable comb4
    [Tags]    classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_8898_${gnb_instance0}}
    prepare spark MultilUE and MCS    att_value_UE0=${0}    att_value_UE1=${0}
    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    Get UE_RNTI_ID on DIFF cell
    ...    filename1=${filename_attach_8898_UE1}    filename2=${filename_attach_8898_UE2}
    Start multi ues traffic     dl_throughput=${dl_throughput}
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_attach_9936_8898_${gnb_instance0}}
    MCS 2UE AND SET ATT    att_value_UE0=${20}    att_value_UE1=${20}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_paired}    beamSetType_UE2=${beamSetType_paired}
    ...    tput_dl_pcell=${tput_dl_pcell_paired}    tput_dl_scell=${tput_dl_scell_paired}
    ...    target_file_name=l1l2bip_AB2005_paired
    Log to console    \n*** trriger UE2 SRS_CoMa_aged ***
    MCS 2UE AND SET ATT    att_value_UE0=${20}    att_value_UE1=${55}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_A_B_01}    beamSetType_UE2=${beamSetType_legcy}
    ...    tput_dl_pcell=${tput_dl_pcell_1UE_coma}    tput_dl_scell=${tput_dl_scell_1UE_coma}
    ...    Sync_UE1=True    Sync_UE2=False    target_file_name=l1l2bip_UE2_SRS_CoMa_aged
    Log to console    \n*** trriger UE1 SRS_CoMa_aged and 2UE both into CoMa_aged status ***
    MCS 2UE AND SET ATT    att_value_UE0=${65}    att_value_UE1=${60}    att1_value_UE0=${35}    att1_value_UE1=${45}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_legcy}    beamSetType_UE2=${beamSetType_legcy}
    ...    tput_dl_pcell=${tput_dl_pcell_2UE_coma}    tput_dl_scell=${tput_dl_scell_2UE_coma}
    ...    Sync_UE1=False    Sync_UE2=False    target_file_name=l1l2bip_UE1_UE2_SRS_CoMa_aged
    Log to console    \n*** trriger UE1 and UE2 restore sync ***
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_paired}    beamSetType_UE2=${beamSetType_paired}
    ...    tput_dl_pcell=${tput_dl_pcell_paired}    tput_dl_scell=${tput_dl_scell_paired}
    ...    Sync_UE1=True    Sync_UE2=True    target_file_name=l1l2bip_UE1_UE2_restore_sync
    [Teardown]    Run Keywords    Detech and stop multi ues traffic
    ...    AND    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list}


*** Keywords ***
prepare spark MultilUE and MCS
    [Arguments]    ${att_value_UE0}=${10}    ${att_value_UE1}=${90}    ${att1_value_UE0}=${0}    ${att1_value_UE1}=${90}
    ...    ${vertical_1}=${96}    ${horizontal_1}=${13}   ${vertical_2}=${96}    ${horizontal_2}=${26}
    ...    ${vertical_3}=${102}    ${horizontal_3}=${-19}    ${vertical_4}=${102}    ${horizontal_4}=${-36}
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
    spark_MultiUE.Prepare UE

Common Case TestLine Setup for gnb1
    ${release_info}    Get sagnb release
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...    golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}_72e.xml
    ...    ParameterToDelete=${PARAMS_TO_delete_bwpdn_8898}
    ...    ListToAdd=${LIST_TO_add_bwpdn_8898}
    ...    ParamterToModify=${ParamterToModify_9936_8898}
    ...    ListParamterToModify=${ListParamterToModify_8898}
    sleep    3min

Check pcell coma aged status
    [Arguments]    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    ${beamSetType_UE1}    ${beamSetType_UE2}
    ...    ${tput_dl_pcell}=${tput_dl_pcell}    ${tput_dl_scell}=${tput_dl_pcell}
    ...    ${pcellid}=${4}    ${scellid}=${16}    ${Sync_UE1}=True    ${Sync_UE2}=True
    ...    ${epc_log_path}=${epc_log_path}    ${target_file_name}=l1l2bip
    Check 2CC tput    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    scellid=${scellid}    pcellid=${pcellid}
    ${bip}=    Capture biplog and download    target_dir=${epc_log_path}    target_file_name=${target_file_name}    capture_time=3s
    Check 2CC DFTBeam Should equal/not_equal new version    file_path=${bip}    beamSetType=${beamSetType_UE1}
    ...    cell_idx_pcell=${36501}    cell_idx_scell=${36502}    rnti=${UE1_RNTI_ID}    Sync=${Sync_UE1}
    Check 2CC DFTBeam Should equal/not_equal new version    file_path=${bip}    beamSetType=${beamSetType_UE2}
    ...    cell_idx_pcell=${36502}    cell_idx_scell=${36501}    rnti=${UE2_RNTI_ID}    Sync=${Sync_UE2}

Get UE_RNTI_ID on DIFF cell
    [Arguments]    ${filename1}    ${filename2}
#    MultiUE one Attach with client    apn=weistatic
#    client.sendat    command=AT+ GTACT =14,,,5077    ue=${uegroup}[0]
#    Sleep    1s
#    client.sendat    command=AT+ GTACT =14,,,5077    ue=${uegroup}[1]
#    Sleep    10s
#    Detach MultiUE    ue=${uegroup}[0]
#    Sleep    3s
#    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_attach_${gnb_instance0}}
    ${UE2_RNTI_ID}    spark Multi UE attach and get UE_RNTI_ID    filename=${filename2}    ue_index=${1}
    ${UE1_RNTI_ID}    spark Multi UE attach and get UE_RNTI_ID    filename=${filename1}
    [Return]    ${UE1_RNTI_ID[-1]}    ${UE2_RNTI_ID[-1]}

spark Multi UE attach and get UE_RNTI_ID
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${ue_index}=${0}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    Spark_multiUE.attach UE    ue_index=${ue_index}
    sleep    5s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${filename}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    [Return]    ${UE_RNTI_ID}

Check 2CC DFTBeam Should equal/not_equal new version
    [Arguments]    ${file_path}    ${beamSetType}=${beamSetType}    ${rnti}=${None}
    ...    ${cell_idx_pcell}=${1}    ${cell_idx_scell}=${2}    ${Sync}=True
    Log to console    \n*** check 2CC DFTBeam ***
    ${PatternidList_diff_2beam_2CC}    Create List
    ${cprtPatternIdDict_cell_List}    Get 2Cell PatternId    cell_idx_pcell=${cell_idx_pcell}
    ...    cell_idx_scell=${cell_idx_scell}    beamSetType=${beamSetType}
    ${phyCellId_cell_List}    Get 2Cell phyCellId    cell_idx_pcell=${cell_idx_pcell}    cell_idx_scell=${cell_idx_scell}
    FOR    ${index}    ${phyCellId_cell}    IN ENUMERATE    @{phyCellId_cell_List}
        ${cprtPatternIdList}    ${bipPatternIdList}
        ...    Get PatternidList From CPRT and BIP with mcshark
        ...    file_path=${file_path}    beamSetType=${beamSetType[${index}]}    rnti=${rnti}
        ...    cprtPatternIdDict=${cprtPatternIdDict_cell_List[${index}]}    phyCellId=${phyCellId_cell}
        ...    PCI_filter=${PCI_filter_trunk}    xpath=${xpath_trunk}    filter=${filter_trunk}
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

Get 2Cell PatternId
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

Start multi ues traffic
    [Arguments]    ${dl_throughput}=${dl_throughput}    ${process_num}=${process_num_${gnb_instance0}}
    Spark_multiUE.start DL traffic    dl_throughput=${dl_throughput}    process_num=${process_num}
    Spark_multiUE.start DL traffic    dl_throughput=${dl_throughput}    process_num=${process_num}    ue_index=${1}
    ...                               dl_port=${${${tl.ues[0].iperf_details.port}}+${100}}

#    ...    ${UE_NUM}=${1}    ${dl_port}=${DL_PORT}    ${dl_throughput}=${dl_throughput}
#    ...    ${process_num}=${process_num_${gnb_instance0}}
#    FOR    ${index}    IN   @{UE_NUM}
#        Start MUE dltraffic with appserver      ue_addr=${${uegroup}[${index}]_IP}    dl_port=${dl_port}
#        ...    dl_throughput=${dl_throughput}    process_num=${process_num}
#        ${dl_port}    Evaluate    ${dl_port}+100
#    END

Detech and stop multi ues traffic
    [Arguments]
    Spark_multiUE.stop DL traffic    ue_index=${0}
    Spark_multiUE.stop DL traffic    iperf_port=${${${tl.ues[0].iperf_details.port}}+${100}}
    Spark_multiUE.detach UE
    Spark_multiUE.detach UE    ue_index=${1}
    [Teardown]    Spark_multiUE.stop ue log
#    ...   ${appserver}=APPserver    ${UE_NUM}=${1}    ${alias}=pioneer
#    FOR    ${index}    IN   @{UE_NUM}
#        Close the iperf process on APPserver    port=${dl_port}   appserver=${appserver}
#        Detach MultiUE    ue=${uegroup}[${index}]
#        ${dl_port}    Evaluate    ${dl_port}+100
#    END
#    Run Keyword And Ignore Error    client.stoplog      service=${alias}