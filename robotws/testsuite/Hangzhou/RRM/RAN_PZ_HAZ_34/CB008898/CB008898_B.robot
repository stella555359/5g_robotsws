*** Settings ***
Resource    ./Resources/CB008898_common_keywords.robot
Variables    ./Resources/CB008898_Variables.py

Documentation
...   author: xiaodan.li & qingqing.zhang
...   contact: qingqing.zhang@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008898-A

Suite Setup     Run keywords
...            Common Suite Setup for COAM    AND
...            Common Case TestLine Setup for 8898

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run keyword if    '${gnb_instance0}' == '${gnb_id}[1]'
...               Run Keyword And Ignore Error     Common Case TestLine Setup    Lock_ENB_Need=True
...               enb_dist_name=${enb_dist_name}    enb_parameter=administrativeState    enb_value=unlocked    AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb0_10175}    MRBTS-10175_TL365_golden_scf_8898
${golden_scf_name_gnb0_36411}    golden_scf_8898
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${swconfig_8898_B}    /opt/workspace/SCF/swconfig_8898.txt
${ue_type}    ${tl.ues[0].capabilities[0]}
${tput_dl_pcell_paired_10175}    1050
${tput_dl_scell_paired_10175}    1030
${tput_dl_pcell_paired_36411}    780
${tput_dl_scell_paired_36411}    780
${tput_dl_pcell_unpaired_10175}    530
${tput_dl_scell_unpaired_10175}    530
${tput_dl_pcell_unpaired_36411}    375
${tput_dl_scell_unpaired_36411}    365
${tput_dl_pcell_1UE_coma_10175}    330
${tput_dl_scell_1UE_coma_10175}    330
${tput_dl_pcell_2UE_coma_10175}    200
${tput_dl_scell_2UE_coma_10175}    200
${tput_dl_pcell_1UE_coma_36411}    265
${tput_dl_scell_1UE_coma_36411}    265
${tput_dl_pcell_2UE_coma_36411}    150
${tput_dl_scell_2UE_coma_36411}    150
${tput_dl_pcell_001}    200
${filename_attach_B01_01}    log_name_B001_attach_2UE_paired.pcap
${filename_attach_B01_02}    log_name_B001_attach_2UE_unpaired.pcap
${filename_attach_B01_03}    log_name_B001_attach_UE1_paired.pcap
${filename_attach_B01_04}    log_name_B001_attach_UE2_paired.pcap
${filename_attach_A_B_01}    log_name_A_B_attach_2cell_reducedEnergySaving.pcap
${filename_attach_B_004_1}    log_name_B004_attach_2UE_pcell_enable_actDlSrsForCA.pcap
${filename_attach_B_004_2}    log_name_B004_attach_2UE_pscell_disable_actDlSrsForCA.pcap
${filename_attach_B_004_3}    log_name_B004_attach_2UE_scell_enable_actDlSrsForCA.pcap
${filename_attach_B10_1}    log_name_B010_attach_2UE_Tapping_DIFF.pcap
${filename_attach_B10_2}    log_name_B010_attach_2UE_RTbeam_enable.pcap
@{value_B001_10175}    ${30000000}    ${60000000}    ${30000000}    ${60000000}
@{value_B001_36411}    ${25000000}    ${40000000}    ${25000000}    ${40000000}
${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
@{beamSetType_A_B_01}    DFTNORMAL    DFTNORMAL
@{beamSetType_014}    DFTNORMAL    DYNAMIC
@{beamSetType_paired}    DFTTAPERING    DFTTAPERING
@{beamSetType_unpaired}    DFTNORMAL    DFTNORMAL
@{beamSetType_8133}    DFTNORMALMUTED    DFTNORMALMUTED
@{beamSetType_A_B_02}    DFTTAPERING    DYNAMICMUTED
@{beamSetType_A_B_03}    DFTNORMALMUTED    DYNAMIC
@{beamSetType_B_004}    DFTTAPERING    DYNAMIC
@{beamSetType_B_010}    DFTTAPERING    DFTNORMAL
@{beamSetType_legcy}    DYNAMIC    DYNAMIC
${filename_attach_UE1_AB2004}    log_name_A_B2004_attach_UE1_n_sync.pcap
${filename_attach_UE2_AB2004}    log_name_A_B2004_attach_UE2_n_sync.pcap
${filename1_attach_UE1_AB2004}    log_name_A_B2004_attach_UE1_sync.pcap
${filename1_attach_UE2_AB2004}    log_name_A_B2004_attach_UE2_sync.pcap
${filename_attach_UE1_AB2005_attach_1st}    log_name_A_B2005_attach_UE1_1st.pcap
${filename_attach_UE1_AB2005}    log_name_A_B2005_attach_UE1_sync.pcap
${filename_attach_UE2_AB2005}    log_name_A_B2005_attach_UE2_sync.pcap
#${bip}    /opt/workspace/CRT/Master/Case_Logs/BTS-10175_10.57.227.99_20240614_233338_BIP/L2L1_Bip.pcap


*** Test Cases ***
[1]CB008898-B#B1_001_Scell_MUMIMO_pair_with_DFT_beams
    [Documentation]    This case describes Scell use the same DFT beam set with Pcell when they using different
    ...                dlMimoMode setting.
    [Setup]    robot_common_operations.Common Case Setup
    Wait until keyword succeeds    4x   10s    Step for 8898_B1_001
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}     AND
    ...           Run Keyword And Ignore Error    Detech and stop multiues traffic     UE_NUM=${2}

[1]CB008898-B#B1_008_Pcell_disable_DFT_beam_sync_up_with_released_Scell_when_actDlMuMimoEnh_is_true
    [Documentation]    This case check ET case CB008898-B#B1_004_Scell_MUMIMO_sync_check_with_different_actDlSrsForCA_setting
    [Setup]    robot_common_operations.Common Case Setup
    Log to console    \n*** pcell enable actDlSrsForCA and scell disable actDlSrsForCA ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_B_B1_004}
    Log to console    \n*** UE attach ***
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
#    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
#    ...    vertical_5=${-4}    horizontal_5=${-53}    vertical_6=${-16}    horizontal_6=${-53}
#    ...    vertical_7=${3}    horizontal_7=${11}    vertical_8=${-9}    horizontal_8=${11}
    sync check with different actDlSrsForCA setting    attach_logname=${filename_attach_B_004_1}
    Log to console    \n*** pcell and scell disable actDlSrsForCA ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_pcell_actDlSrsForCA_off}
    sync check with different actDlSrsForCA setting    attach_logname=${filename_attach_B_004_2}
    Log to console    \n*** scell enable actDlSrsForCA and pcell disable actDlSrsForCA ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_scell_actDlSrsForCA_on}
    sync check with different actDlSrsForCA setting    attach_logname=${filename_attach_B_004_3}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_B_B1_004_recover}    AND
    ...           Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}     AND
    ...           Run Keyword And Ignore Error    Detech and stop multiues traffic     UE_NUM=${2}

[1]CB008898-A#B2_005_Scell_DFT_beam_fallback_when_Pcell_SRS_CoMa_aged_multi_Ues
    [Documentation]    This case describes Scells use DFT beams will fallback to legacy beams for PDSCH data transfer
    ...    when Pcell SRS CoMa aged when multi UEs attach to Pcell, add and activate Scell with TDD FR1 intra-band
    ...    2CC or 3CC CA, Pcell and Scells are from the same RRU.when they using different dlMimoMode setting
    [Setup]    robot_common_operations.Common Case Setup
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_A_B2_005_${gnb_instance0}}
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${20}    att1_value_UE0=${0}    att1_value_UE1=${22}
    Log to console    \n*** UE1 do WR to attach cell1***
    Run keyword If    '${gnb_instance0}' == '${gnb_id}[1]'
    ...    Multi UE attach and get UE_RNTI_ID    filename=${filename_attach_UE1_AB2005_attach_1st}    ue_alias=${uegroup}[0]
    Log to console    \n*** 2UE attach and check paired***
    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    Run keyword If    '${gnb_instance0}' == '${gnb_id}[1]'    get UE_RNTI_ID with DIFF cell
    ...    filename1=${filename_attach_UE1_AB2005}    filename2=${filename_attach_UE2_AB2005}
    ...    ELSE    Multi UE attach and get UE_RNTI_ID with DIFF cell
    ...    filename1=${filename_attach_UE1_AB2005}    filename2=${filename_attach_UE2_AB2005}
    Start multi UE traffic    UE_NUM=${2}    dl_port=${dl_port}    dl_throughput=${dl_throughput}
    sleep    120s
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${5}    att1_value_UE1=${0}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_paired}    beamSetType_UE2=${beamSetType_paired}
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_paired_${gnb_instance0}}
    ...    target_file_name=l1l2bip_AB2005_paired
    Log to console    \n*** trriger UE2 SRS_CoMa_aged ***
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${60}    att1_value_UE0=${0}    att1_value_UE1=${45}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_A_B_01}    beamSetType_UE2=${beamSetType_legcy}
    ...    tput_dl_pcell=${tput_dl_pcell_1UE_coma_${gnb_instance0}}    tput_dl_scell=${tput_dl_pcell_1UE_coma_${gnb_instance0}}
    ...    Sync_UE1=True    Sync_UE2=False    target_file_name=l1l2bip_AB2005_UE2_SRS_CoMa_aged
    Log to console    \n*** trriger UE1 SRS_CoMa_aged and 2UE both into CoMa_aged status ***
    MCS 2UE AND SET ATT    att_value_UE0=${65}    att_value_UE1=${60}    att1_value_UE0=${35}    att1_value_UE1=${45}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_legcy}    beamSetType_UE2=${beamSetType_legcy}
    ...    tput_dl_pcell=${tput_dl_pcell_2UE_coma_${gnb_instance0}}    tput_dl_scell=${tput_dl_pcell_2UE_coma_${gnb_instance0}}
    ...    Sync_UE1=False    Sync_UE2=False    target_file_name=l1l2bip_AB2005_UE1_UE2_SRS_CoMa_aged
    Log to console    \n*** trriger UE1 restore sync ***
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${60}    att1_value_UE0=${0}    att1_value_UE1=${45}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_A_B_01}    beamSetType_UE2=${beamSetType_legcy}
    ...    tput_dl_pcell=${tput_dl_pcell_1UE_coma_${gnb_instance0}}    tput_dl_scell=${tput_dl_pcell_1UE_coma_${gnb_instance0}}
    ...    Sync_UE1=True    Sync_UE2=False    target_file_name=l1l2bip_AB2005_UE1_restore_sync
    Log to console    \n*** trriger UE2 restore sync ***
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    Check pcell coma aged status    UE1_RNTI_ID=${UE1_RNTI_ID}    UE2_RNTI_ID=${UE2_RNTI_ID}
    ...    beamSetType_UE1=${beamSetType_paired}    beamSetType_UE2=${beamSetType_paired}
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_pcell_paired_${gnb_instance0}}
    ...    Sync_UE1=True    Sync_UE2=True    target_file_name=l1l2bip_AB2005_UE2_restore_sync
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}     AND
    ...           Run Keyword And Ignore Error    Detech and stop multiues traffic     UE_NUM=${2}

[1]CB008898-B#B1_010_Pcell_and_Scells_MU_MIMO_sync_check_with_different_dlMuMimoTapering_setting_and_8322_IWK
     [Documentation]
    [Setup]    robot_common_operations.Common Case Setup
    Log to console    \n*** pcell and scell tapping different ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_B_B1_010}
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    ${UE_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename_attach_B10_1}     UE_NUM=${2}
    ${8898_bip_B010_1}=    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_unpaired_${gnb_instance0}}
    ...    counter_id=${counter_id_B001}    dic_path_1=${dic_path_B001_CELL1}    dic_path_2=${dic_path_B001_CELL2}
    ...    value_min_pcell=${value_B001_${gnb_instance0}}[0]    value_max_pcell=${value_B001_${gnb_instance0}}[1]
    ...    scell_is_PMIbeam=True
    ...    value_min_scell=${value_B001_${gnb_instance0}}[2]   value_max_scell=${value_B001_${gnb_instance0}}[3]
    ...    paired_pcell=True    paired_scell=False
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_B010_1}
    ...    beamSetType=${beamSetType_B_010}    rnti_list=${UE_RNTI_ID}
#    Log to console    \n*** enable RT beam，AEQK not support RT beam ***
#    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_enable_RTbeam}    Delete_Mo_Online=${Delete_Para_channelgroup}
#    ${UE_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename_attach_B10_1}     UE_NUM=${2}
    ### AEQK only support 4DL4UL when enable RT beam, So scell cannot reach 8 layer ###
#    ${8898_bip_B010_2}=    Run Keyword And Ignore Error    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
#    ...    tput_dl_pcell=${tput_dl_pcell_unpaired}    tput_dl_scell=${tput_dl_scell_unpaired}
#    ...    counter_id=${counter_id_B001}    dic_path_1=${dic_path_B001_CELL1}    dic_path_2=${dic_path_B001_CELL2}
#    ...    value_min_pcell=${value_B001}[0]    value_max_pcell=${value_B001}[1]
#    ...    value_min_scell=${value_B001}[2]   value_max_scell=${value_B001}[3]    paired_pcell=False    paired_scell=True
#    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_B010_2}[-1]
#    ...    beamSetType=${beamSetType_B_004}    rnti_list=${UE_RNTI_ID}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_B_B1_010_recover}    AND
    ...           Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}     AND
    ...           Run Keyword And Ignore Error    Detech and stop multiues traffic     UE_NUM=${2}

[1]CB008898-A#B1_001_Scell_use_same_DFT_beamset_with_Pcell_with_2CC_CA_single_RRU_1208_frameStructure_all_active_8133_feature
    [Documentation]    This case describes Scell use the same DFT beam set with Pcell after UE attach to Pcell, add and
    ...    activate Scell with TDD FR1 intra-band 2CC CA, Pcell and Scell are from the same RRU and all use 1208 framestructure.
    [Setup]    robot_common_operations.Common Case Setup
    Log to console    \n*** Enable CB008133 feature ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_8133}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving    cell_index=${1}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving    cell_index=${2}
    Log to console    \n*** UE attach ***
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    ${UE_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename_attach_A_B_01}     UE_NUM=${2}
    Log to console    \n*** Start tput and pcell and scell enter the reducedEnergySaving ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_Pscell_EnergySaving}
    ${8898_bip_A_B_01}=    Start 2CC Traffic And Check Energysavingstate And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_unpaired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_unpaired_${gnb_instance0}}
    ...    target_file_name=8898_bip_A_B_01
    Log to console    \n*** pcell and scell enter energysaving. all use DTFNORMAL beam and it will sync ***
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A_B_01}
    ...    beamSetType=${beamSetType_8133}    rnti_list=${UE_RNTI_ID}
    Log to console    \n*** Start tput and pcell exit the reducedEnergySaving ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_Pcell_exit_EnergySaving}
    Start multiUEs traffic with appserver    dl_tput_multiue=${dl_throughput}    process_num=${process_num_${gnb_instance0}}
    ${8898_bip_A_B_02}=    Check 2CC Traffic And Check Energysavingstate And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_unpaired_${gnb_instance0}}
    ...    status_cell1=notEnergySaving    status_cell2=reducedEnergySaving    target_file_name=8898_bip_A_B_02
    Log to console    \n*** Scell exit the reducedEnergySaving ***
    ${8898_bip_A_B_03}=    Check 2CC Traffic And Check Energysavingstate And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_paired_${gnb_instance0}}
    ...    status_cell1=notEnergySaving    status_cell2=notEnergySaving    target_file_name=8898_bip_A_B_03
    Stop multiues traffic with appserver
    Log to console    \n*** pcell exit energysaving and scell enter energysaving. it will not sync ***
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A_B_02}
    ...    beamSetType=${beamSetType_A_B_02}    rnti_list=${UE_RNTI_ID}    Sync=False
    Log to console    \n*** pcell and scell exit energysaving. all use DTF beam and it will sync ***
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A_B_03}
    ...    beamSetType=${beamSetType_paired}    rnti_list=${UE_RNTI_ID}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving   cell_index=${1}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=reducedEnergySaving   cell_index=${2}
    Log to console    \n*** Start tput and pcell enter the reducedEnergySaving ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_Pcell_enter_EnergySaving}
    Start multiUEs traffic with appserver    dl_tput_multiue=${dl_throughput}    process_num=${3}
    ${8898_bip_A_B_04}=    Check 2CC Traffic And Check Energysavingstate And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_unpaired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_unpaired_${gnb_instance0}}
    ...    status_cell1=reducedEnergySaving    status_cell2=notEnergySaving    target_file_name=8898_bip_A_B_04
    Log to console    \n*** pcell enter energysaving and scell exit energysaving. it will not sync ***
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A_B_04}
    ...    beamSetType=${beamSetType_A_B_03}    rnti_list=${UE_RNTI_ID}    Sync=False
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_8133_close}    AND
    ...           Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}     AND
    ...           Run Keyword And Ignore Error    Detech and stop multiues traffic     UE_NUM=${2}

*** Keywords ***
Common Case TestLine Setup for 8898
#    ${release}=    Get sagnb release title
    ${release}    Get sagnb release
    set suite variable    ${release}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'
    ...    Common Case TestLine Setup    golden_scf_name=${golden_scf_name_gnb0_${gnb_instance0}}_${release}.xml
    ...    ModifySCF_Beforecommission=True    ParamterToModify=${ParamterToModify_8898_B001}
    ...    ParameterToDelete=${ParameterToDelete_8898_new}
    ...    MOsToAdd=${MostoADD_8898}
    ...    ListToAdd=${ListToAdd_8898}
    ...    ListParamterToModify=${ListToModify_8898}
    ...    ELSE    Common Case TestLine Setup    golden_scf_name=${golden_scf_name_gnb0_${gnb_instance0}}_${release}.xml
    ...    ModifySCF_Beforecommission=True    ParameterToDelete=${ParameterToDelete_8898_based}
    ...    ParamterToModify=${ParamterToModify_8898_B001}    ListToAdd=${ListToAdd_8898_based}
    ...    Lock_ENB_Need=True    enb_dist_name=${enb_dist_name}    enb_parameter=administrativeState    enb_value=locked
    ...    Is_Swconfig=True    swconfig_file=${swconfig_8898_B}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Online modify NIDD on gnb    Add_Mo_Online=${Add_Mo_Online_NRREL}

Start 2CC Traffic And Check Energysavingstate And Capture Biplog
    [Arguments]     ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL    ${dl_throughput}=${dl_throughput}
    ...    ${target_file_name}=${target_file_name}
    Log to console    \n*** start traffic and check tput ***
    Start multiUEs traffic with appserver    dl_tput_multiue=${dl_throughput}    process_num=${process_num_${gnb_instance0}}
    sleep    10s
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    target_dir=${epc_log_path}    target_file_name=${target_file_name}    capture_time=3s
    Log to console    \n*** check EnergySavingState ***
    Check 2CC tput    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    duration=10s
    [Return]     ${bip}
    [Teardown]    Stop multiues traffic with appserver

Check 2CC Traffic And Check Energysavingstate And Capture Biplog
    [Arguments]     ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL    ${target_file_name}=${target_file_name}
    ...    ${status_cell1}=reducedEnergySaving    ${status_cell2}=reducedEnergySaving
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=${status_cell1}   cell_index=${1}
    Wait until keyword succeeds    2 min    5s    Get EnergySavingState    status=${status_cell2}   cell_index=${2}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    target_dir=${epc_log_path}    target_file_name=${target_file_name}    capture_time=1s
    Log to console    \n*** check tput ***
    Check 2CC tput    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    duration=10s
    Log to console    \n*** check EnergySavingState ***
    Run Keyword And Ignore Error    Get EnergySavingState    status=${status_cell1}   cell_index=${1}
    Run Keyword And Ignore Error    Get EnergySavingState    status=${status_cell2}   cell_index=${2}
    [Return]     ${bip}

Check multi UE 2CC DFTBeam Should equal/not_equal
    [Arguments]    ${file_path}    ${beamSetType}=${beamSetType}    ${rnti_list}=${None}
    ...    ${cell_idx_pcell}=${1}    ${cell_idx_scell}=${2}    ${Sync}=True
    FOR    ${rnti}    IN    @{rnti_list}
        Check 2CC DFTBeam Should equal/not_equal    file_path=${file_path}    beamSetType=${beamSetType}
        ...    rnti=${rnti}    cell_idx_pcell=${cell_idx_pcell}    cell_idx_scell=${cell_idx_scell}    Sync=${Sync}
    END

sync check with different actDlSrsForCA setting
    [Arguments]    ${attach_logname}
    ${UE_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${attach_logname}    UE_NUM=${2}
    ${bip_logname}=    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_unpaired_${gnb_instance0}}
    Log to console    \n*** pcell use DFT beam，scell use PMI beam ***
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${bip_logname}
    ...    beamSetType=${beamSetType_B_004}   rnti_list=${UE_RNTI_ID}    Sync=False

#Attach and check 2CC DFTBeam
#    [Arguments]    ${tput_dl_pcell}=${tput_dl_pcell}    ${tput_dl_scell}=${tput_dl_scell}    ${dl_throughput}=${dl_throughput}
#    ...    ${beamSetType}=${beamSetType_014}
#    ...    ${filename1_UE1}=${filename_attach_UE1_AB2004}    ${filename1_UE2}=${filename_attach_UE2_AB2004}
#    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    Multi UE attach and get UE_RNTI_ID with DIFF cell
#    ...    filename1=${filename1_UE1}    filename2=${filename1_UE2}
#    ${8898_bip_AB2_004}=    Start 2CC Traffic And Capture Biplog    UE_NUM=${2}
#    ...    tput_dl_pcell=${tput_dl_scell}    tput_dl_scell=${tput_dl_scell}
#    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_AB2_004}
#    ...    cell_idx_pcell=${1}    cell_idx_scell=${2}    rnti=${UE1_RNTI_ID}
#    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_AB2_004}
#    ...    cell_idx_pcell=${2}    cell_idx_scell=${1}    rnti=${UE2_RNTI_ID}

Check pcell coma aged status
    [Arguments]    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    ${beamSetType_UE1}    ${beamSetType_UE2}
    ...    ${tput_dl_pcell}=${tput_dl_pcell}    ${tput_dl_scell}=${tput_dl_pcell}
    ...    ${pcellid}=${1}    ${scellid}=${2}    ${Sync_UE1}=True    ${Sync_UE2}=True
    ...    ${epc_log_path}=${epc_log_path}    ${target_file_name}=l1l2bip
    Wait until keyword succeeds    3X    10s     Check 2CC tput    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    scellid=${scellid}    pcellid=${pcellid}
    ${bip}=    Capture biplog and download    target_dir=${epc_log_path}    target_file_name=${target_file_name}    capture_time=3s
    Check 2CC DFTBeam Should equal/not_equal    file_path=${bip}    beamSetType=${beamSetType_UE1}
    ...    cell_idx_pcell=${1}    cell_idx_scell=${2}    rnti=${UE1_RNTI_ID}    Sync=${Sync_UE1}
    Check 2CC DFTBeam Should equal/not_equal    file_path=${bip}    beamSetType=${beamSetType_UE2}
    ...    cell_idx_pcell=${2}    cell_idx_scell=${1}    rnti=${UE2_RNTI_ID}    Sync=${Sync_UE2}
#    [Teardown]    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}

Step for 8898_B1_001
    prepare MultilUE and MCS    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    Log to console    \n*** 2 UEs paired with same pcell ***
    ${UE_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename_attach_B01_01}     UE_NUM=${2}
    ${8898_bip_B001}=    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_paired_${gnb_instance0}}
    ...    counter_id=${counter_id_B001}    dic_path_1=${dic_path_B001_CELL1}    dic_path_2=${dic_path_B001_CELL2}
    ...    value_min_pcell=${value_B001_${gnb_instance0}}[0]    value_max_pcell=${value_B001_${gnb_instance0}}[1]
    ...    value_min_scell=${value_B001_${gnb_instance0}}[2]   value_max_scell=${value_B001_${gnb_instance0}}[3]
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_B001}
    ...    beamSetType=${beamSetType_paired}    rnti_list=${UE_RNTI_ID}
    Log to console    \n*** 2 UEs unpaired with same pcell ***
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for MultiUE    mcs_type=${mcs_type}
         ...    att_value_UE0=${10}    att_value_UE1=${10}
         ...    P1_out=${13}    P2_out=${14}    vertical_1=${87}    horizontal_1=${14}
         ...    P3_out=${15}    P4_out=${16}    vertical_2=${86}    horizontal_2=${29}
         ...    P5_out=${9}     P6_out=${10}    vertical_3=${87}    horizontal_3=${14}
         ...    P7_out=${11}    P8_out=${12}    vertical_4=${86}    horizontal_4=${29}
    ...    ELSE    TOPYOUNG MCS SETUP AND SET ATT for Two UEs with different ATT    mcs_type=${mcs_type}
    ...    att_value_UE0=${0}    att_value_UE1=${0}
    ...    vertical_1=${3}    horizontal_1=${11}    vertical_2=${-9}    horizontal_2=${11}
    ...    vertical_3=${3}    horizontal_3=${11}    vertical_4=${-9}    horizontal_4=${11}
    ${UE_RNTI_ID}    Multi UE attach and get UE_RNTI_ID    filename=${filename_attach_B01_02}     UE_NUM=${2}
    ${8898_bip_B002}=    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
    ...    tput_dl_pcell=${tput_dl_pcell_unpaired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_unpaired_${gnb_instance0}}
    ...    counter_id=${counter_id_B001}    dic_path_1=${dic_path_B001_CELL1}    dic_path_2=${dic_path_B001_CELL2}
    ...    value_min_pcell=${value_B001_${gnb_instance0}}[0]    value_max_pcell=${value_B001_${gnb_instance0}}[1]
    ...    value_min_scell=${value_B001_${gnb_instance0}}[2]   value_max_scell=${value_B001_${gnb_instance0}}[3]
    ...    paired_pcell=False    paired_scell=False
    Check multi UE 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_B002}
    ...    beamSetType=${beamSetType_unpaired}    rnti_list=${UE_RNTI_ID}
    Log to console    \n*** 2 UEs unpaired with different pcell ***
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${20}    att1_value_UE0=${5}    att1_value_UE1=${0}
    ${UE1_RNTI_ID}    ${UE2_RNTI_ID}    get UE_RNTI_ID with DIFF cell
    ...    filename1=${filename_attach_B01_03}    filename2=${filename_attach_B01_04}
    MCS 2UE AND SET ATT    att_value_UE0=${10}    att_value_UE1=${10}    att1_value_UE0=${0}    att1_value_UE1=${0}
    ${8898_bip_B003}=    Start 2UEs 2CC Traffic And Capture Biplog    UE_NUM=${2}
    ...    tput_dl_pcell=${tput_dl_pcell_paired_${gnb_instance0}}    tput_dl_scell=${tput_dl_scell_paired_${gnb_instance0}}
    ...    counter_id=${counter_id_B001}    dic_path_1=${dic_path_B001_CELL1}    dic_path_2=${dic_path_B001_CELL2}
    ...    value_min_pcell=${value_B001_${gnb_instance0}}[0]    value_max_pcell=${value_B001_${gnb_instance0}}[1]
    ...    value_min_scell=${value_B001_${gnb_instance0}}[2]   value_max_scell=${value_B001_${gnb_instance0}}[3]
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_B003}    beamSetType=${beamSetType_paired}
    ...    rnti=${UE1_RNTI_ID}
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_B003}    beamSetType=${beamSetType_paired}
    ...    rnti=${UE2_RNTI_ID}    cell_idx_pcell=${2}    cell_idx_scell=${1}
    [Teardown]    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
