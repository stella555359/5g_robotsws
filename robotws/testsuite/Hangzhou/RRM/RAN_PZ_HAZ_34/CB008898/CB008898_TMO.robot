*** Settings ***
Resource    ./Resources/CB008898_common_keywords.robot
Variables    ./Resources/CB008898_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008898-A

Suite Setup    Run Keywords
...            Common Suite Setup for COAM    AND
...            Common Case TestLine Setup for 8898 TMO    golden_scf_name=${golden_scf_name_gnb0_36411_TMO}

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
${golden_scf_name_gnb0_36411_TMO}    golden_scf_8898_gnb1_TMO
${golden_scf_name_gnb0_36411_TMO_30M}    golden_scf_8898_gnb1_TMO_100M_30M.xml
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ue_type}    ${tl.ues[0].capabilities[0]}
${tput_dl_pcell_014}    1400
${tput_dl_scell_014}    1050
${tput_dl_pcell_001}    200
${dl_throughput}    300M
@{value_A004}    ${40000000}
${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
@{beamSetType_014}    DFTNORMAL    DYNAMIC
@{beamSetType_1}    DFTNORMALMUTED    DFTNORMALMUTED
@{beamSetType_2}    DFTNORMALMUTED    DYNAMIC
${filename_attach_UE1_AB2004}    log_name_A_B2004_attach_UE1_n_sync.pcap
${filename_attach_UE2_AB2004}    log_name_A_B2004_attach_UE2_n_sync.pcap
${filename1_attach_UE1_AB2004}    log_name_A_B2004_attach_UE1_sync.pcap
${filename1_attach_UE2_AB2004}    log_name_A_B2004_attach_UE2_sync.pcap
${tput_dl_pcell_AB2004}    1200
${tput_dl_scell_AB2004}    1200
${process_num_10175}    ${3}
${process_num_36411}    ${9}
${8898_bip_A014_1}    /opt/workspace/CRT/Master/Case_Logs//BTS-36411_10.57.227.102_20240822_135215_BIP/L2L1_Bip.pcap
${dl_throughput_014}    700M

*** Test Cases ***
[1]CB008898-A#B1_014_Pcell_and_Scells_sync_check_with_different_left_and_right_EdgeAngle_setting
    [Documentation]    This case describes Pcell and Scells sync status check when Pcell and Scells using different left&right_EdgeAngle setting.
    ...                for Pcell / Scell2 using DFT beams for PDSCH to transfer data to UE because they are using same DFT beam mute setting,
    ...                and Scell1 using PMI beam or SSB beam according to DL SU-MIMO configuration of Scell1.
    [Setup]    robot_common_operations.Common Case Setup
    Log to console    \n*** L_R_EdgeAngle 8898 ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_L_R_EdgeAngle_${gnb_instance0}}
    Log to console    \n*** UE attach ***
    prepare MultilUE and MCS A
    MultiUE one Attach with client
    ${8898_bip_A014}=    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_014}    tput_dl_scell=${tput_dl_scell_014}
    ...    dl_throughput=${dl_throughput}    process_num=${9}    sleep_time=30s
    ...    target_file_name=l1l2bip_A014
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A014}    beamSetType=${beamSetType_014}    Sync=False
    Log to console    \n*** lowerEdgeAngle 8898 ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_up_lo_EdgeAngle_${gnb_instance0}}
    Log to console    \n*** UE attach ***
    MultiUE one Attach with client
    ${8898_bip_A015}=    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_014}    tput_dl_scell=${tput_dl_scell_014}
    ...    dl_throughput=${dl_throughput}    process_num=${9}    sleep_time=5s
    ...    target_file_name=l1l2bip_A015
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A015}    beamSetType=${beamSetType_014}    Sync=False
    Log to console    \n*** Recovey_EdgeAngle 8898 ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_Recover_EdgeAngle_${gnb_instance0}}
    Log to console    \n*** UE attach ***
    MultiUE one Attach with client
    ${8898_bip_A014_1}=    Start 2CC Traffic And Capture Biplog
    ...    tput_dl_pcell=${tput_dl_pcell_014}    tput_dl_scell=${tput_dl_scell_014}
    ...    dl_throughput=${dl_throughput}    process_num=${9}    sleep_time=5s
    ...    target_file_name=l1l2bip_A014_1
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A014_1}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           stop traffic and MCS teardown with new way    mcs_type=${mcs_type}

[1]CB008898-A#B1_004_Scell_use_same_DFT_beamset_with_Pcell_when_using_different_dlMimoMode_single_Ue
    [Documentation]    This case describes Scell use the same DFT beam set with Pcell when they using different
    ...                dlMimoMode setting.
    [Setup]    robot_common_operations.Common Case Setup
    Online Close 2200 on gnb    Add_Para_Online=${List_TO_ADD_2200_Close}
    Log to console    \n*** UE attach ***
    prepare MultilUE and MCS A
    MultiUE one Attach with client
    ${8898_bip_A004}=    Start 2CC Traffic And Capture Biplog    tput_dl_pcell=${tput_dl_pcell_014}    tput_dl_scell=${tput_dl_scell_014}
    ...    counter_id=${counter_id_A004}    dic_path_1=${dic_path_A004_CELL1}    dic_path_2=${dic_path_A004_CELL2}    value=${value_A004}
    ...    dl_throughput=${dl_throughput}    process_num=${9}    sleep_time=30s    target_file_name=l1l2bip_A004
    Check 2CC DFTBeam Should equal/not_equal    file_path=${8898_bip_A004}
    [Teardown]    Run keywords
    ...           Common Case Teardown for COAM    AND
    ...           Online recover 2200 on gnb    Add_Para_Online=${List_TO_ADD_2200_${gnb_instance0}}     AND
    ...           stop traffic and MCS teardown with new way    mcs_type=${mcs_type}

*** Keywords ***
Common Case TestLine Setup for 8898 TMO
    [Arguments]    ${golden_scf_name}=${golden_scf_name}
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Common Case TestLine Setup    golden_scf_name=${golden_scf_name}_${release}.xml    ModifySCF_Beforecommission=True
    ...    ParamterToModify=${ParamterToModify_8898_based}
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

prepare MultilUE and MCS A
    [Arguments]    ${att1_value_UE0}=${0}    ${att1_value_UE1}=${90}
    prepare MultilUE and MCS    att1_value_UE0=${att1_value_UE0}    att1_value_UE1=${att1_value_UE1}
    ...    horizontal_5=${-53}    vertical_5=${-6}    horizontal_6=${-53}    vertical_6=${3}
    ...    vertical_7=${3}    horizontal_7=${11}    vertical_8=${-6}    horizontal_8=${11}