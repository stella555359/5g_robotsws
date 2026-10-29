*** Settings ***
Resource    ./Resources/CB008898_common_keywords.robot
Variables    ./Resources/CB008898_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008898-A

Suite Setup    Run keywords
...            Common Suite Setup for COAM    AND
...            Common Case TestLine Setup for 8898

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'    Run Keyword And Ignore Error
...               Common Case TestLine Setup    Lock_ENB_Need=True
...               enb_dist_name=${enb_dist_name}    enb_parameter=administrativeState    enb_value=unlocked    AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb0_10175}    MRBTS-10175_TL365_golden_scf_8898
${golden_scf_name_gnb0_36411}    golden_scf_8898
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${swconfig_8898_B}    /opt/workspace/SCF/swconfig_8898.txt
${ue_type}    ${tl.ues[0].capabilities[0]}
${tput_dl_pcell_10175}    533
${tput_dl_scell_10175}    540
${tput_dl_pcell_36411}    390
${tput_dl_scell_36411}    390
${tput_dl_pcell_001}    200
${dl_throughput}    300M
@{value_A004_10175}    ${40000000}
@{value_A004_36411}    ${30000000}
${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
@{beamSetType_014}    DFTNORMAL    DYNAMIC
@{beamSetType_1}    DFTNORMALMUTED    DFTNORMALMUTED
@{beamSetType_2}    DFTNORMALMUTED    DYNAMIC
${filename_attach_UE1_AB2004}    log_name_A_B2004_attach_UE1_n_sync.pcap
${filename_attach_UE2_AB2004}    log_name_A_B2004_attach_UE2_n_sync.pcap
${filename1_attach_UE1_AB2004}    log_name_A_B2004_attach_UE1_sync.pcap
${filename1_attach_UE2_AB2004}    log_name_A_B2004_attach_UE2_sync.pcap
${tput_dl_pcell_AB2004_10175}    530
${tput_dl_scell_AB2004_10175}    530
${tput_dl_pcell_AB2004_36411}    390
${tput_dl_scell_AB2004_36411}    390
${process_num_10175}    ${4}
${process_num_36411}    ${4}
${dl_throughput_014}    700M
${tput_dl_pcell_014}    300
${tput_dl_scell_014}    300

*** Test Cases ***
[1]CB008898-A#B1_004_Scell_use_same_DFT_beamset_with_Pcell_when_using_different_dlMimoMode_single_Ue
    [Documentation]    This case describes Scell use the same DFT beam set with Pcell when they using different
    ...                dlMimoMode setting.
    [Setup]    robot_common_operations.Common Case Setup
    Online Close 2200 on gnb    Add_Para_Online=${List_TO_ADD_2200_Close}
    Log to console    \n*** UE attach ***
    prepare UE and MCS
    MultiUE one Attach with client
    ${8898_bip_A004}=    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=tput_dl_pcell=${tput_dl_pcell_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_${gnb_instance0}}
    ...    counter_id=${counter_id_A004}    dic_path_1=${dic_path_A004_CELL1}    dic_path_2=${dic_path_A004_CELL2}    value=${value_A004}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=30s
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A004}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Online recover 2200 on gnb    Add_Para_Online=${List_TO_ADD_2200_${gnb_instance0}}     AND
    ...           stop traffic and MCS teardown with new way    mcs_type=${mcs_type}

[1]CB008898-A#B1_011_Pcell_and_Scell_sync_check_when_Scell_deactivate_and_activate_several_times
    [Documentation]    This case describes Pcell and Scells sync status check when Scell deactivate and activate for several times. for test purpose,
    ...                set sCellActivationMethod=bufferBased and Scell's dlMimoMode to 4x4 or 4x2 Closed Loop Spatial Multiplexing.
    [Setup]    robot_common_operations.Common Case Setup
    Online Close 2200 on gnb    Add_Para_Online=${List_TO_ADD_2200_Close_1}
    Log to console    \n*** UE attach ***
    prepare MultilUE and MCS A
    MultiUE one Attach with client
    FOR    ${index}    IN RANGE    ${10}
        ${sleep_time}    Set variable If    '${index}'=='${1}'    180s    30s
       Wait until keyword succeeds    3X    5s    Start UE traffic and check 2CC tput
        ...    tput_dl_pcell=${tput_dl_pcell_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_${gnb_instance0}}
        ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=${sleep_time}
        Stop traffic with appserver    iperf_port=${DL_PORT}
        sleep    5s
    END
    ${8898_bip_A011}=    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_${gnb_instance0}}
    ...    counter_id=${counter_id_A004}    dic_path_1=${dic_path_A004_CELL1}    dic_path_2=${dic_path_A004_CELL2}
    ...    value=${value_A004_${gnb_instance0}}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=30s
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A011}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Online recover 2200 on gnb    Add_Para_Online=${List_TO_ADD_2200_1_${gnb_instance0}}    AND
    ...           stop traffic and MCS teardown with new way    mcs_type=${mcs_type}

[1]CB008898-A#B1_014_Pcell_and_Scells_sync_check_with_different_left_and_right_EdgeAngle_setting
    [Documentation]    This case describes Pcell and Scells sync status check when Pcell and Scells using different left&right_EdgeAngle setting.
    ...                for Pcell / Scell2 using DFT beams for PDSCH to transfer data to UE because they are using same DFT beam mute setting,
    ...                and Scell1 using PMI beam or SSB beam according to DL SU-MIMO configuration of Scell1.
    [Setup]    robot_common_operations.Common Case Setup
    Log to console    \n*** L_R_EdgeAngle 8898 ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_L_R_EdgeAngle_${gnb_instance0}}
    Log to console    \n*** UE attach ***
    prepare UE and MCS
    MultiUE one Attach with client
    ${8898_bip_A014}=    Wait until keyword succeeds    3X    5s
    ...    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_${gnb_instance0}}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=30s
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A014}    beamSetType=${beamSetType_014}    Sync=False
    Log to console    \n*** lowerEdgeAngle 8898 ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_up_lo_EdgeAngle_${gnb_instance0}}
    Log to console    \n*** UE attach ***
    MultiUE one Attach with client
    ${8898_bip_A015}=    Wait until keyword succeeds    3X    5s
    ...    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_${gnb_instance0}}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=5s
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A015}    beamSetType=${beamSetType_014}    Sync=False
    Log to console    \n*** Recovey_EdgeAngle 8898 ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_Recover_EdgeAngle_${gnb_instance0}}
    Log to console    \n*** UE attach ***
    MultiUE one Attach with client
    ${8898_bip_A014_1}=    Wait until keyword succeeds    3X    5s
    ...    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_${gnb_instance0}}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=10s
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A014_1}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           stop traffic and MCS teardown with new way    mcs_type=${mcs_type}

[1]CB008898-A#B2_004_Scell_use_beams_check_with_multi_UEs_different_Pcell_different_actDlSrsForCA_setting
    [Documentation]    This case describes Scell use the same DFT beamset with Pcell after multi UEs attach to different
     ...    Pcell, add and activate Scell with TDD FR1 intra-band 2CC or 3CC CA, Pcell and Scells are from the same RRU
     ...    when actDlSrsForCA all activated. otherwise, Scell should use legacy beams for PDSCH data transfer.
    [Setup]    robot_common_operations.Common Case Setup
    Log to console    \n*** UE and MCS Prepare ***
    Run keyword If    '${gnb_instance0}' == '${gnb_id}[0]'    prepare MultilUE and MCS A    att1_value_UE1=${22}
    ...    ELSE    prepare MultilUE and MCS    att_value_UE0=${20}    att_value_UE1=${20}
    Log to console    \n*** disable CB008898 on scell ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_A_B2_004}
    Attach and check 2CC DFTBeam    beamSetType=${beamSetType_014}
    ...    filename1_UE1=${filename_attach_UE1_AB2004}    filename1_UE2=${filename_attach_UE2_AB2004}
    ...    tput_dl_pcell=${tput_dl_pcell_AB2004_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_AB2004_${gnb_instance0}}
    ...    Sync=False    target_file_name=l1l2bip_AB2004_disable_CB008898
    Log to console    \n*** enable CB008898 on scell ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_A_B2_004_1}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'    MCS 2UE AND SET ATT    att1_value_UE0=${0}    att1_value_UE1=${22}
    ...    horizontal_5=${-53}    vertical_5=${-6}    horizontal_6=${-53}    vertical_6=${3}
    ...    vertical_7=${3}    horizontal_7=${11}    vertical_8=${-6}    horizontal_8=${11}
    Attach and check 2CC DFTBeam    beamSetType=${beamSetType}
    ...    filename1_UE1=${filename1_attach_UE1_AB2004}    filename1_UE2=${filename1_attach_UE2_AB2004}
    ...    tput_dl_pcell=${tput_dl_pcell_AB2004_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_AB2004_${gnb_instance0}}
    ...    Sync=True    target_file_name=l1l2bip_AB2004_enable_CB008898
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}     AND
    ...           Run Keyword And Ignore Error    Detech and stop multiues traffic     UE_NUM=${2}

*** Keywords ***
Common Case TestLine Setup for 8898
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'
    ...    Common Case TestLine Setup    golden_scf_name=${golden_scf_name_gnb0_${gnb_instance0}}_${release}.xml
    ...    ModifySCF_Beforecommission=True    ParamterToModify=${ParamterToModify_8898_based}
    ...    ELSE    Common Case TestLine Setup    golden_scf_name=${golden_scf_name_gnb0_${gnb_instance0}}_${release}.xml
    ...    ModifySCF_Beforecommission=True    ParameterToDelete=${ParameterToDelete_8898_based}
    ...    ParamterToModify=${ParamterToModify_8898_based}    ListToAdd=${ListToAdd_8898_based}
    ...    Lock_ENB_Need=True    enb_dist_name=${enb_dist_name}    enb_parameter=administrativeState    enb_value=locked
    ...    Is_Swconfig=True    swconfig_file=${swconfig_8898_B}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_8898_A004}    Add_Mo_Online=${Add_Mo_Online_NRREL}

Start 2CC Traffic And Check Energysavingstate And Capture Biplog
    [Arguments]     ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL    ${dl_throughput}=${dl_throughput}    ${bbmod_slots}=1
    ...    ${status_cell1}=reducedEnergySaving    ${status_cell2}=reducedEnergySaving
    Log to console    \n*** start traffic and check tput ***
    Start UE traffic and check 2CC tput    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    dl_throughput=${dl_throughput}
    Log to console    \n*** check EnergySavingState ***
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=${status_cell1}   cell_index=${1}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=${status_cell2}   cell_index=${2}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
    [Teardown]    Stop traffic with appserver    iperf_port=${DL_PORT}
    [Return]     ${bip}

Attach and check 2CC DFTBeam
    [Arguments]    ${tput_dl_pcell}=${tput_dl_pcell}    ${tput_dl_scell}=${tput_dl_scell}    ${dl_throughput}=${dl_throughput}
    ...    ${beamSetType}=${beamSetType_014}
    ...    ${filename1_UE1}=${filename_attach_UE1_AB2004}    ${filename1_UE2}=${filename_attach_UE2_AB2004}
    ...    ${Sync}=True    ${target_file_name}=l1l2bip
    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    Multi UE attach and get UE_RNTI_ID with DIFF cell
    ...    filename1=${filename1_UE1}    filename2=${filename1_UE2}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'    MCS 2UE AND SET ATT    att1_value_UE0=${0}    att1_value_UE1=${10}
    ...    horizontal_5=${-53}    vertical_5=${-6}    horizontal_6=${-53}    vertical_6=${3}
    ...    vertical_7=${3}    horizontal_7=${11}    vertical_8=${-6}    horizontal_8=${11}
    ${8898_bip_AB2_004}=    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    dl_throughput=${dl_throughput}    process_num=${process_num_${gnb_instance0}}    sleep_time=30s
    ...    target_file_name=${target_file_name}
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_AB2_004}
    ...    cell_idx_pcell=${1}    cell_idx_scell=${2}    rnti=${UE1_RNTI_ID}    beamSetType=${beamSetType}    Sync=${Sync}
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_AB2_004}
    ...    cell_idx_pcell=${2}    cell_idx_scell=${1}    rnti=${UE2_RNTI_ID}    beamSetType=${beamSetType}    Sync=${Sync}

prepare UE and MCS A B2004
    Log to console    \n*** prepare MCS ***
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    MCS 2UE AND SET ATT    att_value_UE0=${20}    att_value_UE1=${20}

prepare MultilUE and MCS A
    [Arguments]    ${att1_value_UE0}=${0}    ${att1_value_UE1}=${90}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'    prepare MultilUE and MCS
    ...    att1_value_UE0=${att1_value_UE0}    att1_value_UE1=${att1_value_UE1}
    ...    horizontal_5=${-53}    vertical_5=${-6}    horizontal_6=${-53}    vertical_6=${3}
    ...    vertical_7=${3}    horizontal_7=${11}    vertical_8=${-6}    horizontal_8=${11}
    ...    ELSE    prepare UE and MCS
