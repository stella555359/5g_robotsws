# *** Settings ***
# Force Tags    PY36
# Documentation     author: yifan hu
# ...                 contact: yifan.hu@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : CB007736-A
# 
# Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007736/Resources/CB007736_common_keyword.robot
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007736/Resources/variables_7736.py
# 
# 
# Suite Setup    Run Keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    Common Suite Setup for COAM    AND
# ...    Get release info    AND
# ...    Prepare with COAM classical BTS cell onair    AND
# ...    Unlock DSS cell on enb
# 
# 
# Suite Teardown    Run Keywords
# ...               robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# ...               Run Keyword And Ignore Error    close DSS cell on gnb and delete XP    AND
# ...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# 
# *** Variables ***
# ${gnb_path}    /tmp
# ${tl_scf_filename}    7736_DSS.xml
# ${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
# ${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${nglogname1}       7736A_B103_scell.pcap
# ${nglogname2}       7736A_D103_scell.pcap
# ${interface1}    any
# ${expected_tput_dl}    360
# ${expected_tput_ul}    73
# ${expected_tput_dl_dss_prb}    227
# ${expected_tput_dl_dss}    234
# ${expected_tput_ul_dss}    39
# @{pci_361}    38    39    41    42    43    44
# @{pci_371}    48    49    51    52    53    54
# @{pci_380}    48    49    51    52    53    54
# @{BTSID}    36111    37111    38011
# @{ALLOWED_FAULT}    61652    61524    61649    9000    4592    4527    1932    4334    61074    61618    4687    4655    4654    6450
# 
# *** Test Cases ***
# #[1]CB007736_5G_AB_B1_003_3CC_config_peakTP_check_in_same_L2RT_instance_Interworking_with_Dss_and_PRB_Blanking
# #    [Documentation]
# #    ...    This case is to verify 3CC scell addition and check 3CC peak tput in dss env
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2
# #    [Setup]    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_03_pre}
# #    Lock&unlock DSS cell on enb_abil
# #    Check only default Fault Present
# #    ADD cell2 NRREL to cell1&cell3
# #    power_ue.Prepare UE    ue_type=${ue_type}
# #    UE attach and check CA relation_3CC    nglogname=${nglogname1}    scell1_pci=@{pci}[0]    scell2_pci=@{pci}[2]
# #    ...    att_ru1=${127}    att_ru2=${20}    att_ru3=${127}    att_ru4=${127}    att_ru5=${127}
# #    Start DLUL traffic and check 3CC tput    scellid1=1    scellid2=3    pcellid=2
# #    ...    att_ru1=${20}    att_ru2=${20}    att_ru3=${20}    att_ru4=${127}    att_ru5=${127}
# #    ...    tput_dl_pcell=${expected_tput_dl_dss}    tput_dl_scell1=${expected_tput_dl}
# #    ...    tput_dl_scell2=${expected_tput_dl_dss}    tput_ul=${expected_tput_ul_dss}
# #    [Teardown]    run keywords
# #    ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
# #    ...    Run Keyword And Ignore Error    Modify NIDD parameter online
# #    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_03_unlock}    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AB_B1_03_teardown}
# 
# [1]CB007736_5G_AD_B1_003_3CC_config_peakTP_check_with_cellmap_same_L2RT_instance_Interworking_with_Dss_and_PRB_Blanking
#     [Documentation]
#     ...    This case is to verify 3CC scell addition and check 3CC peak tput in dss env
#     [Tags]    CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     Lock&unlock DSS cell on enb_abio
#     env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_pre}
#     sleep    120s
#     Check only default Fault Present
#     ADD cell5 NRREL to cell4&cell14_dss
#     power_ue.Prepare UE    ue_type=${ue_type}
#     UE attach and check CA relation_3CC    nglogname=${nglogname2}    scell1_pci=@{pci}[2]    scell2_pci=@{pci}[5]
#     ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${127}    att_ru5=${0}
#     Start DLUL traffic and check 3CC tput    scellid1=4    scellid2=14    pcellid=5
#     ...    att_ru1=${127}    att_ru2=${127}    att_ru4=${20}    att_ru5=${20}
#     ...    tput_dl_pcell=${expected_tput_dl_dss_prb}    tput_dl_scell1=${expected_tput_dl_dss}
#     ...    tput_dl_scell2=${expected_tput_dl}    tput_ul=${expected_tput_ul_dss}
#     [Teardown]    run keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    Tear down UE traffic and detach    AND
#     ...    Run Keyword And Ignore Error    Modify NIDD parameter online
#     ...    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_unlock}    AND
#     ...    Run Keyword And Ignore Error    Case Teardown    parameters=${PARAMETERS_TO_UPDATE_AD_B1_03_teardown}
# *** Keywords ***
# 
# 
