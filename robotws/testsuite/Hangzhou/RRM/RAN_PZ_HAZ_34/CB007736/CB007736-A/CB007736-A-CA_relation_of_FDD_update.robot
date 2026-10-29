# *** Settings ***
# Force Tags    PY36
# Documentation     author: yifan hu
# ...                 contact: yifan.hu@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : CB007736-A
# 
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007736/Resources/CB007736_common_keyword.robot
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007736/Resources/variables_7736.py
# Library     taf.selenium.sbts      WITH NAME       selenium_coam
# 
# Suite Setup    Run Keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    Common Suite Setup for COAM    AND
# ...    Prepare with COAM classical BTS cell onair    AND
# ...    Get release info    AND
# ...    close DSS cell on gnb and delete XP    AND
# ...    Lock DSS cell on enb
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword And Ignore Error    Unlock DSS cell on enb    AND
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# ...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# 
# *** Variables ***
# ${gnb_path}    /tmp
# ${tl_scf_filename}    7736_DSS.xml
# ${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
# ${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${nglogname1}       7736A_B301_scell3.pcap
# ${nglogname2}       7736A_B301_scell2.pcap
# ${nglogname3}       7736AB_B205_1.pcap
# ${nglogname4}       7736AB_B205_2.pcap
# ${nglogname5}       7736AB_B205_3.pcap
# ${nglogname6}       7736AB_B302_1.pcap
# ${nglogname7}       7736AB_B302_2.pcap
# ${nglogname8}       7736AC_B301_scell5.pcap
# ${nglogname9}       7736AC_B301_scell14.pcap
# ${nglogname10}      7736AD_B209_1.pcap
# ${nglogname11}      7736AD_B209_2.pcap
# ${nglogname12}      7736AD_B209_3.pcap
# ${nglogname13}      7736AD_B303_1.pcap
# ${nglogname14}      7736AD_B303_2.pcap
# ${nglogname15}      7736AE_B301_1.pcap
# ${nglogname16}      7736AE_B301_2.pcap
# ${nglogname17}      7736AE_B302_1.pcap
# ${nglogname18}      7736AE_B302_2.pcap
# ${nglogname19}      7271_DMRS_1.pcap
# ${interface1}    any
# ${expected_tput_dl}    390
# ${expected_tput_dl_2}    370
# ${expected_tput_dl_3}    360
# ${expected_tput_ul}    95
# @{pci_361}    38    39    41    42    43    44
# @{pci_371}    48    49    51    52    53    54
# @{pci_380}    48    49    51    52    53    54
# @{BTSID}    36111    37111    38011
# @{ALLOWED_FAULT}    61652    61524    61649    9000    4592    4527    1932    4334    61074    61618    4687    4655    4654    6450
# @{list_cell_index_abil}    1    2    11
# @{list_cell_index_abio}    4    5    14
# @{list_cell_group_index_abil}    0    1    11
# @{list_cell_group_index_abio}    3    4    14
# 
# *** Test Cases ***
# #[1]CB007736_5G_A_B3_001_CA_FDD_relation_update_online_with_webui_and_peakTP_check_with_2CC_on_1ABIL
# #    [Documentation]
# #    ...    This case is to verify 2CC scell addition and check 2CC peak tput
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_A_B3_pre}
# #    Check only default Fault Present
# #    ADD cell1 NRREL to cell3
# #    power_ue.Prepare UE    ue_type=${ue_type}
# #    Record the counter action timer
# #    SA L3 call with DLUL data and check peak    nglogname=${nglogname1}
# #    ...    scell_pci=@{pci}[2]    scellid=3    att2=${127}    att3=${20}
# #    sleep    ${utc_left}min
# #    Check the PM counter should not be zero
# #    ...    counter_id=${counter_id_scell_act}    dic_path=${counter_dic_path_cell3}
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    Modify NIDD parameter online   parameters_to_update=${PARAMETERS_TO_UPDATE_A_B3_2}
# #    Record the counter action timer
# #    SA L3 call with DLUL data and check peak    nglogname=${nglogname2}
# #    ...    scell_pci=@{pci}[1]    scellid=2    att2=${20}    att3=${127}
# #    sleep    ${utc_left}min
# #    Check the PM counter should not be zero
# #    ...    counter_id=${counter_id_scell_act}    dic_path=${counter_dic_path_cell2}
# #    [Teardown]    run keywords
# #    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
# #    ...    Run Keyword And Ignore Error    Modify NIDD parameter online
# #    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_A_B3_recover}    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_A_B3_teardown}
# 
# #[1]CB007736_5G_AB_B1_001_3CC_config_webui_check_with_cellmap_Inter_core_of_same_L2RT_instance_on_1ABIL
# #    [Documentation]
# #    ...    This case is to verify 3CC scell addition and check expected bts fault exist
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_pre}
# #    Check the gnb cell status onair
# #    Check only default Fault Present
# #    Add cell1 NRREL to cell2&cell3
# #    Check expect Fault Present    expect_alarm=4001
# #    Restart gNB
# #    Check the gnb cell status onair
# #    Check expect Fault Present    expect_alarm=4036
# #    Modify NIDD parameter online   parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_1}
# #    Check the gnb cell status onair
# #    Check only default Fault Present
# #    [Teardown]    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AB_B1_teardown}
# 
# [1]CB007736_5G_AB_B2_005_SISO_common_reset_with_3CC_config_and_cell_mapping_Inter_core_with3cc_on_2abil
#     [Documentation]
#     ...    This case is to verify 3CC scell addition and check 3CC peak tput after cell lock&unlock and RU reset
#     [Tags]    CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B2_pre}
#     Check only default Fault Present
#     ADD cell2 NRREL to cell1&cell11
#     Restart ABIL via WEBUI
#     power_ue.Prepare UE    ue_type=${ue_type}
#     UE attach and check CA relation_3CC    nglogname=${nglogname3}    scell1_pci=@{pci}[0]    scell2_pci=@{pci}[4]
#     ...    att_ru1=${127}    att_ru2=${0}
#     power_ue.UE Detach  ue_type=${ue_type}
#     Lock Unlock cell1&cell11
#     UE attach and check CA relation_3CC    nglogname=${nglogname4}    scell1_pci=@{pci}[0]    scell2_pci=@{pci}[4]
#     ...    att_ru1=${127}    att_ru2=${20}
#     Start DL traffic and check 3CC tput    scellid1=1    scellid2=11    pcellid=2    att_ru1=${20}    att_ru2=${20}
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${40}
#     ...    combined_ant3=${40}    combined_ant4=${40}
#     RU reset and check scell re-addition    nglogname=${nglogname5}    scell1_pci=@{pci}[0]    scell2_pci=@{pci}[4]
#     Check 3CC DL tput    scellid1=1    scellid2=11    pcellid=2
#     [Teardown]    run keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
#     ...    Run Keyword And Ignore Error    Modify NIDD parameter online
#     ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B2_1}    AND
#     ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AB_B2_teardown}
# 
# [1]CB007736_5G_AB_B3_002_Pcell_IntraGnb_interFeq_HO_from_inter_L2RT_FDD_CA_to_mix_intra_inter_L2RT_FDD_CA_on_2ABIL
#     [Documentation]
#     ...    This case is to verify 3CC scell addition and check 3CC peak tput after pcell HO
#     [Tags]    CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_pre}
#     Check only default Fault Present
#     ADD cell2 NRREL to cell1&cell11
#     ADD cell5 NRREL to cell1&cell11
#     HO preparation
#     power_ue.Prepare UE    ue_type=${ue_type}
#     UE attach and check CA relation_3CC    att_ru1=${127}    att_ru2=${20}
#     ...    nglogname=${nglogname6}    scell1_pci=@{pci}[0]    scell2_pci=@{pci}[4]
#     Start DLUL traffic and check 3CC tput    scellid1=1    scellid2=11    pcellid=2
#     ...    att_ru1=${20}    att_ru2=${20}
#     Perform UE HO from cell2 to cell5    nglogname=${nglogname7}
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${127}    att_ru5=${20}
#     ...    combined_ant3=${20}    combined_ant4=${20}
#     Check 3CC DLUL tput    scellid1=1    scellid2=11    pcellid=5    tput_dl_pcell=${expected_tput_dl_2}
#     [Teardown]    run keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
#     ...    Run Keyword And Ignore Error    Modify NIDD parameter online
#     ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_1}    AND
#     ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AB_B3_teardown}
# 
# #[1]CB007736_5G_AC_B3_001_CA_relation_update_online_with_webui_and_peakTP_check_with_2CC_on_1ABIO
# #    [Documentation]
# #    ...    This case is to verify 2CC scell addition and check 2CC peak tput
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AC_B3_pre}
# #    Check only default Fault Present
# #    ADD cell5 NRREL to cell4
# #    power_ue.Prepare UE    ue_type=${ue_type}
# #    SA L3 call with DLUL data and check peak_ABIO    nglogname=${nglogname8}
# #    ...    scell_pci=@{pci}[2]    scellid=4    att4=${20}
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    Modify NIDD parameter online   parameters_to_update=${PARAMETERS_TO_UPDATE_AC_B3_3}
# #    SA L3 call with DLUL data and check peak_ABIO    nglogname=${nglogname9}
# #    ...    scell_pci=@{pci}[5]    scellid=14    att4=${20}
# #    [Teardown]    run keywords
# #    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
# #    ...    Run Keyword And Ignore Error    Modify NIDD parameter online
# #    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_unlock}    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AC_B3_teardown}
# #
# #[1]CB007736_5G_AD_B1_001_3CC_config_webui_check_with_cellmap_Inter_core_of_same_L2RT_instance_on_1ABIO
# #    [Documentation]
# #    ...    This case is to verify 3CC scell addition and check expected bts fault exist
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_pre}
# #    Check the gnb cell status onair
# #    Check only default Fault Present
# #    Add cell4 NRREL to cell5&cell14_blind
# #    run keyword if    ${gnb_instance}==@{BTSID}[2]    Check expect Fault Present    expect_alarm=4001
# #    ...    ELSE    Check expect Fault Present    expect_alarm=4670
# #    Restart gNB
# #    Check the gnb cell status onair
# #    Check expect Fault Present    expect_alarm=4036
# #    Modify NIDD parameter online   parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_1}
# #    Check the gnb cell status onair
# #    Check only default Fault Present
# #    [Teardown]    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AD_B1_teardown}
# #
# #[1]CB007736_5G_AD_B2_009_SISO_common_reset_with_3CC_config_and_cellmap_Inter_core_with_3cc_on_ABIO
# #    [Documentation]
# #    ...    This case is to verify 3CC scell addition and check 3CC peak tput after cell lock&unlock and RU reset
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B2_pre}
# #    Check only default Fault Present
# #    ADD cell5 NRREL to cell4&cell14
# #    Restart ABIO via WEBUI
# #    power_ue.Prepare UE    ue_type=${ue_type}
# #    UE attach and check CA relation_3CC    nglogname=${nglogname10}    scell1_pci=@{pci}[2]    scell2_pci=@{pci}[5]
# #    ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${127}    att_ru5=${20}
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    Lock Unlock cell4&cell14
# #    UE attach and check CA relation_3CC    nglogname=${nglogname11}    scell1_pci=@{pci}[2]    scell2_pci=@{pci}[5]
# #    ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${127}    att_ru5=${20}
# #    Start DL traffic and check 3CC tput    scellid1=4    scellid2=14    pcellid=5
# #    ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}    att_ru5=${20}
# #    Adjust gNB_RU Attenuation for CA    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}
# #    ...    att_ru5=${40}    combined_ant3=${127}    combined_ant4=${127}
# #    RU reset and check scell re-addition_ABIO    nglogname=${nglogname12}    scell1_pci=@{pci}[2]    scell2_pci=@{pci}[5]
# #    Check 3CC DL tput    scellid1=4    scellid2=14    pcellid=5
# #    [Teardown]    run keywords
# #    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
# #    ...    Run Keyword And Ignore Error    Modify NIDD parameter online
# #    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_unlock}    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AD_B2_teardown}
# #
# #[1]CB007736_5G_AD_B3_003_Pcell_IntraGnb_interFeq_HO_from_inter_L2RT_FDD_CA_to_intra_L2RT_FDD_CA_on_2ABIO
# #    [Documentation]
# #    ...    This case is to verify 3CC scell addition and check 3CC peak tput after pcell HO
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B3_pre}
# #    Check only default Fault Present
# #    ADD cell4 NRREL to cell5&cell14
# #    ADD cell5 NRREL to cell4&cell14
# #    power_ue.Prepare UE    ue_type=${ue_type}
# #    UE attach and check CA relation_3CC    att_ru1=${127}    att_ru2=${127}    att_ru4=${127}
# #    ...    att_ru5=${20}    nglogname=${nglogname13}    scell1_pci=@{pci}[2]    scell2_pci=@{pci}[5]
# #    Start DLUL traffic and check 3CC tput    scellid1=4    scellid2=14    pcellid=5
# #    ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}    att_ru5=${20}
# #    Perform UE HO from cell5 to cell4    nglogname=${nglogname14}
# #    Adjust gNB_RU Attenuation for CA    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}
# #    ...    att_ru5=${20}    combined_ant3=${20}    combined_ant4=${20}
# #    Check 3CC DLUL tput    scellid1=5    scellid2=14    pcellid=4
# #    [Teardown]    run keywords
# #    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
# #    ...    Run Keyword And Ignore Error    Modify NIDD parameter online
# #    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B3_1}    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AD_B3_teardown}
# #
# #[1]CB007736_5G_AE_B3_001_CA_relation_update_online_with_webui_and_peakTP_check_from_2CC_to_3CC_mix_Pcell_on_ABIL
# #    [Documentation]
# #    ...    This case is to verify 3CC scell addition and check 3CC peak tput in mix env
# #    [Tags]
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_pre}
# #    Check only default Fault Present
# #    ADD cell1 NRREL to cell4
# #    power_ue.Prepare UE    ue_type=${ue_type}
# #    UE attach and check CA relation_2CC    att_ru1=${20}    att_ru2=${127}    att_ru4=${127}
# #    ...    att_ru5=${127}    nglogname=${nglogname15}    scell_pci=@{pci}[2]
# #    Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${127}    att_ru4=${20}
# #    ...    att_ru5=${127}    combined_ant3=${20}    combined_ant4=${20}
# #    Start UE DLUL traffic
# #    Check 2CC DLUL tput    pcellid=1    scellid=4
# #    Stop UE DLUL traffic
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    ADD cell1 NRREL to cell2
# #    UE attach and check CA relation_3CC    att_ru1=${20}    att_ru2=${127}    att_ru4=${127}
# #    ...    att_ru5=${127}    nglogname=${nglogname16}    scell1_pci=@{pci}[1]    scell2_pci=@{pci}[2]
# #    Start DLUL traffic and check 3CC tput    scellid1=2    scellid2=4    pcellid=1
# #    ...    att_ru1=${20}    att_ru2=${20}    att_ru4=${20}    att_ru5=${127}
# #    Stop UE DLUL traffic
# #    sleep    30s
# #    Start DLUL traffic and check 3CC tput    scellid1=2    scellid2=4    pcellid=1
# #    ...    att_ru1=${20}    att_ru2=${20}    att_ru4=${20}    att_ru5=${127}
# #    Stop UE DLUL traffic
# #     [Teardown]    run keywords
# #    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
# #    ...    Run Keyword And Ignore Error    Modify NIDD parameter online
# #    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_unlock}    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown_AE    parameters1=${PARAMETERS_TO_UPDATE_AE_B3_teardown1}
# #    ...    parameters2=${PARAMETERS_TO_UPDATE_AE_B3_teardown2}
# 
# [1]CB007736_5G_AE_B3_002_CA_relation_update_online_with_webui_and_peakTP_check_from_2CC_to_3CC_mix_Pcell_on_ABIO
#     [Documentation]
#     ...    This case is to verify 3CC scell addition and check 3CC peak tput in mix env
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_02_pre}
#     Check only default Fault Present
#     power_ue.Prepare UE    ue_type=${ue_type}
#     ADD cell1 NRREL to cell4
#     UE attach and check CA relation_2CC    att_ru1=${0}    att_ru2=${127}    att_ru4=${127}
#     ...    att_ru5=${127}    nglogname=${nglogname17}    scell_pci=@{pci}[2]
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${127}    att_ru4=${20}
#     ...    att_ru5=${127}    combined_ant3=${20}    combined_ant4=${20}
#     Start UE DLUL traffic
#     Check 2CC DLUL tput    pcellid=1    scellid=4
#     Stop UE DLUL traffic
#     power_ue.UE Detach  ue_type=${ue_type}
#     ADD cell1 NRREL to cell14
#     UE attach and check CA relation_3CC    att_ru1=${0}    att_ru2=${127}    att_ru4=${127}
#     ...    att_ru5=${127}    nglogname=${nglogname18}    scell1_pci=@{pci}[2]    scell2_pci=@{pci}[5]
#     Start DLUL traffic and check 3CC tput    scellid1=4    scellid2=14    pcellid=1
#     ...    att_ru1=${20}    att_ru2=${127}    att_ru4=${20}    att_ru5=${127}    tput_dl_scell2=${expected_tput_dl_3}
#     Stop UE DLUL traffic
#     sleep    30s
#     Start DLUL traffic and check 3CC tput    scellid1=4    scellid2=14    pcellid=1
#     ...    att_ru1=${20}    att_ru2=${127}    att_ru4=${20}    att_ru5=${127}    tput_dl_scell2=${expected_tput_dl_3}
#     Stop UE DLUL traffic
#      [Teardown]    run keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
#     ...    Run Keyword And Ignore Error    Modify NIDD parameter online
#     ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_unlock}    AND
#     ...    Run Keyword And Ignore Error    Case Teardown_AE    parameters1=${PARAMETERS_TO_UPDATE_AE_B3_02_teardown1}
#     ...    parameters2=${PARAMETERS_TO_UPDATE_AE_B3_02_teardown2}
# 
# [1]CB007271-5G-C-CB007736_5G_3CC_config_Scell_activation_checking_after_ULDMRS_online_parameter_modification
#     [Documentation]
#     ...    This case is to verify Scell_activation_checking_after_ULDMRS_online_parameter_modification
#     [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_pre}
#     Check only default Fault Present
#     ADD cell1 NRREL to cell2&cell4
#     power_ue.Prepare UE    ue_type=${ue_type}
#     UE attach and check CA relation_3CC    att_ru1=${0}
#     ...    nglogname=${nglogname19}    scell1_pci=@{pci}[1]    scell2_pci=@{pci}[2]
#     Start DLUL traffic and check 3CC tput    scellid1=2    scellid2=4    pcellid=1
#     ...    att_ru1=${20}    att_ru2=${20}    att_ru4=${20}
#     env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_modify}
#     Check 2CC DLUL tput    pcellid=1    scellid=4
#     [Teardown]    run keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
#     ...    Run Keyword And Ignore Error    Modify NIDD parameter online
#     ...    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_recover}    AND
#     ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_DMRS_teardown}
# *** Keywords ***
# Perform UE HO from cell2 to cell5
#     [Arguments]    ${nglogname}    ${target_cellID}=@{pci}[3]
#     ...    ${interface}=${interface1}
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${40}    att_ru5=${127}
#     ...    combined_ant3=${127}    combined_ant4=${127}
#     Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
#     Sleep    5s
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${40}    att_ru5=${40}
#     ...    combined_ant3=${127}    combined_ant4=${127}
#     Sleep    3s
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${50}    att_ru5=${40}
#     ...    combined_ant3=${127}    combined_ant4=${127}
#     Sleep    1s
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${60}    att_ru5=${40}
#     ...    combined_ant3=${127}    combined_ant4=${127}
#     Sleep    1s
#     Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${127}    att_ru5=${20}
#     ...    combined_ant3=${127}    combined_ant4=${127}
#     Sleep    10s
#     Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
#     Check inter-F intra-gNB HO procedure    logname=${nglogname}    target_cellID=${target_cellID}
#     [Teardown]    Teardown Stop Capture Wireshark Logs on gNB
# 
# Perform UE HO from cell5 to cell4
#     [Arguments]    ${nglogname}    ${target_cellID}=@{pci}[2]
#     ...    ${interface}=${interface1}
#     Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
#     Adjust gNB_RU Attenuation for CA    att_ru1=${127}    att_ru2=${127}    att_ru4=${127}
#     ...    att_ru5=${40}    combined_ant3=${127}    combined_ant4=${127}
#     sleep    5s
#     Adjust gNB_RU Attenuation for CA    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}
#     ...    att_ru5=${40}    combined_ant3=${127}    combined_ant4=${127}
#     sleep    5s
#     Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
#     Check inter-F intra-gNB HO procedure    logname=${nglogname}    target_cellID=${target_cellID}
#     [Teardown]    Teardown Stop Capture Wireshark Logs on gNB
# 
# RU reset and check scell re-addition
#     [Arguments]    ${nglogname}    ${scell1_pci}    ${scell2_pci}
#     ...    ${interface}=${interface1}
#     Perform RU Reset    ru_index=${1}    download_dir=${epc_log_path}
# #    Perform RU Reset    ru_index=${2}    download_dir=${epc_log_path}
# #    COAM Wait for gnb ready and cell setup    gnb_type='SA'
#     Wait until cluster is on cell on air status
#     ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
#     ...    list_cell_index=${list_cell_index_abil}    list_cell_group_index=${list_cell_group_index_abil}
#     sleep    5s
#     Check scell re-addition        nglogname=${nglogname}    scell1_pci=${scell1_pci}    scell2_pci=${scell2_pci}
#     ...    att_ru1=${20}    att_ru2=${20}    att_ru4=${127}    att_ru5=${127}
# 
# RU reset and check scell re-addition_ABIO
#     [Arguments]    ${nglogname}    ${scell1_pci}    ${scell2_pci}
#     ...    ${interface}=${interface1}
#     Perform RU Reset    ru_index=${4}    download_dir=${epc_log_path}
# #    COAM Wait for gnb ready and cell setup    gnb_type='SA'
#     Wait until cluster is on cell on air status
#     ...    is_x2_check_from_enb_needed=${False}    is_enb_status_check_needed=${False}
#     ...    list_cell_index=${list_cell_index_abio}    list_cell_group_index=${list_cell_group_index_abio}
#     sleep    5s
#     Check scell re-addition        nglogname=${nglogname12}    scell1_pci=${scell1_pci}    scell2_pci=${scell2_pci}
#     ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}    att_ru5=${20}
# 
