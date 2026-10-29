#*** Settings ***
#Force Tags    PY36
#Documentation     author: qingqing zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB008140-K
#
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_K_variables.py
#
#
#Suite Setup    Run Keywords
#...            robot_common_operations.Common Suite Setup    AND
#...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
#...            Common Case TestLine Setup with gnb1 and gnb3
#
#Suite Teardown    Run Keywords
#...               robot_common_operations.Common Suite Teardown    AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${gnb_path}    /tmp
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${scf_path}    /opt/workspace/SCF/
#${scf_name_gnb0}    Configuration_scf_GNB1_CB008140_peak.xml
#${scf_name_gnb2}    Configuration_scf_GNB3_CB008140_peak.xml
#${scf_name_gnb3}    Configuration_scf_GNB4_CB008140_peak.xml
#${interface1}    any
#${filename_001_attach_gnb0}    log_name_K_001_gNB1_attach.pcap
#${filename_001_attach_gnb2}    log_name_K_001_gNB3_attach.pcap
#${filename1_001_attach_gnb0}    log_name1_K_001_gNB1_attach.pcap
#${filename1_001_attach_gnb2}    log_name1_K_001_gNB3_attach.pcap
#${filename_001_gnb0}    log_name_K_001_gNB1_cell_edge.pcap
#${filename_001_gnb2}    log_name_K_001_gNB3_cell_edge.pcap
#${filename1_001_gnb0}    log_name_K_001_gNB1_cell_center.pcap
#${filename1_001_gnb2}    log_name_K_001_gNB3_cell_center.pcap
#${filename_007_attach_UE1_gnb0}    log_name_K_007_gNB1_attach_UE1.pcap
#${filename_007_attach_UE1_gnb3}    log_name_K_007_gNB4_attach_UE1.pcap
#${filename_007_attach_UE2_gnb0}    log_name_K_007_gNB1_attach_UE2.pcap
#${filename_007_attach_UE2_gnb2}    log_name_K_007_gNB3_attach_UE2.pcap
#${filename1_007_attach_UE1_gnb0}    log_name1_K_007_gNB1_attach_UE1.pcap
#${filename1_007_attach_UE1_gnb2}    log_name1_K_007_gNB3_attach_UE1.pcap
#${filename1_007_attach_UE2_gnb2}    log_name1_K_007_gNB3_attach_UE2.pcap
#${filename1_007_attach_UE2_gnb3}    log_name1_K_007_gNB4_attach_UE2.pcap
#${filename2_007_attach_UE1_gnb0}    log_name2_K_007_gNB1_attach_UE1.pcap
#${filename2_007_attach_UE1_gnb2}    log_name2_K_007_gNB3_attach_UE1.pcap
#${filename2_007_attach_UE2_gnb2}    log_name2_K_007_gNB3_attach_UE2.pcap
#${filename2_007_attach_UE2_gnb3}    log_name2_K_007_gNB4_attach_UE2.pcap
#${filename_007_gnb0}    log_name_K_007_gNB1_pcell_lock_unlock.pcap
#${filename_007_gnb2}    log_name_K_007_gNB3_pcell_lock_unlock.pcap
#${filename_007_gnb3}    log_name_K_007_gNB4_pcell_lock_unlock.pcap
#${filename1_007_gnb0}    log_name_K_007_gNB1_scell_lock.pcap
#${filename1_007_gnb2}    log_name_K_007_gNB3_scell_lock.pcap
#${filename1_007_gnb3}    log_name_K_007_gNB4_scell_lock.pcap
#${filename2_007_gnb0}    log_name_K_007_gNB1_scell_unlock.pcap
#${filename2_007_gnb2}    log_name_K_007_gNB3_scell_unlock.pcap
#${filename2_007_gnb3}    log_name_K_007_gNB4_scell_unlock.pcap
#${filename3_007_gnb0}    log_name_K_007_gNB1_pcell_shutdown.pcap
#${filename3_007_gnb2}    log_name_K_007_gNB3_pcell_shutdown..pcap
#${filename_008_attach_gnb0}    log_name_K_008_gNB1_attach.pcap
#${filename_008_attach_gnb2}    log_name_K_008_gNB3_attach.pcap
#${filename1_008_attach_gnb0}    log_name1_K_008_gNB1_attach.pcap
#${filename1_008_attach_gnb2}    log_name1_K_008_gNB3_attach.pcap
#${filename2_008_attach_gnb0}    log_name2_K_008_gNB1_attach.pcap
#${filename2_008_attach_gnb2}    log_name2_K_008_gNB3_attach.pcap
#${filename_008_gnb0}    log_name_K_008_gNB1_scell_A2release.pcap
#${filename_008_gnb2}    log_name_K_008_gNB3_scell_A2release.pcap
#${filename1_008_gnb0}    log_name_K_008_gNB1_scell_shutdown.pcap
#${filename1_008_gnb2}    log_name_K_008_gNB3_scell_shutdown.pcap
#${filename2_008_gnb0}    log_name_K_008_gNB1_scell_3CC_to_2CC.pcap
#${filename2_008_gnb2}    log_name_K_008_gNB3_scell_3CC_to_2CC.pcap
#${filename_021_attach_gnb0}    log_name_K_021_gNB1_attach.pcap
#${filename_021_attach_gnb3}    log_name_K_021_gNB4_attach.pcap
#${filename1_021_attach_gnb0}    log_name1_K_021_gNB1_attach.pcap
#${filename1_021_attach_gnb3}    log_name1_K_021_gNB4_attach.pcap
#${filename_021_gnb0}    log_name_K_021_gNB1_ABIL_reset.pcap
#${filename_021_gnb3}    log_name_K_021_gNB4_ABIL_reset.pcap
#${filename1_021_gnb0}    log_name1_K_021_gNB1_ABIO_reset.pcap
#${filename1_021_gnb3}    log_name1_K_021_gNB4_ABIO_reset.pcap
#${filename_017_attach_gnb0}    log_name_K_017_gNB1_attach.pcap
#${filename_017_attach_gnb2}    log_name_K_017_gNB3_attach.pcap
#${filename_017_gnb0}    log_name_K_017_gNB1_NRREl_Delete.pcap
#${filename_017_gnb2}    log_name_K_017_gNB3_NRREl_Delete.pcap
#${filename1_017_gnb0}    log_name1_K_017_gNB1_NRREl_Delete.pcap
#${filename1_017_gnb2}    log_name1_K_017_gNB3_NRREl_Delete.pcap
#${filename2_017_gnb0}    log_name2_K_017_gNB1_ingnbresourcestatusupdate.pcap
#${filename2_017_gnb2}    log_name2_K_017_gNB3_ingnbresourcestatusupdate.pcap
#
#@{ue_index_MTU_38711}    ${1}    ${2}
#@{ue_index_MTU_38611}    ${1}    ${2}
#
#@{gnb_list_K001}    ${0}    ${2}
#@{gnb_ips}    ${bts_host0}    ${bts_host2}    ${bts_host3}
#@{gnb_list_K007}    ${0}    ${2}    ${3}
#@{gnb_list_K007_1}    ${0}    ${3}
#@{gnb_list_K007_2}    ${2}    ${3}
#@{scell_index_list_cell2_and_cell31}    ${2}    ${31}
#@{scell_index_list_cell1_and_cell11}    ${1}    ${11}
#@{scell_index_list_cell31}    ${31}
#@{scell_index_list_cell2}    ${2}
#@{scell_index_list_cell1}    ${1}
#@{scell_index_list_cell11}    ${11}
#@{extgnb_index_gnb3}    ${2}
#@{extgnb_index_gnb1}    ${0}
#@{extgnb_index_gnb4}    ${3}
#@{extgnb_index_gnb3_3CC}    ${2}    ${2}
#@{extgnb_index_gnb1_3CC}    ${0}    ${0}
#${Send_Tput_DL_F+F}    1500
#${expected_tput_F}    390
#${expected_tput_F_007}    350
#@{ue_list}    ${3}    ${8}
#@{ALLOWED_FAULT}    61652    61524    61649    7307    4592    4527    6450    62001    62003    61618    4687    4655    4654
#*** Test Cases ***
#
#[1]CB008140-5G-K_001_Pcell_lock_with_Graceful_Cell_Shutdown_blind
#    [Documentation]    Cell lock with Graceful Cell Shutdown enabled is performed on the cell in prime-gNB which is the PCell
#    ...    for inter-gNB CA UEs
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for K001
#        MultiUE.Prepare UE
#    ## trigger cell-edge
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#        Attach and check CA setup    filename=filename_001_attach_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3}    gnb_list=${gnb_list_K001}
#    ...    UEContextModificationResponse_nums=${2}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F+F}
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}
#    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${5}
#    Collect log for graceful cell shutdown    filename=filename_001_gnb    gnb_list=${gnb_list_K001}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN}
#    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_F}    tput_dl_scell=${expected_tput_F}   scellid=${11}
#    ...    pcellid=${2}    gnb_prime=${2}    gnb_external=${0}
#    MultiUE.Stop DL Traffic
#    MultiUE.Detach
#    ### trigger cell-center
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_K001_1}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_K001_1}    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_K001_1}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB1_K001_1}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Attach and check CA setup    filename=filename1_001_attach_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2_and_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3_3CC}    gnb_list=${gnb_list_K001}
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}
#    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${5}
#    Collect log for graceful cell shutdown    filename=filename1_001_gnb    gnb_list=${gnb_list_K001}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN}
#    Check wireshark log for K001_1    logname=${filename_001_gnb0}    logname1=${filename_001_gnb2}
#    Check wireshark log for K001_2    logname=${filename1_001_gnb0}    logname1=${filename1_001_gnb2}
#    [Teardown]     run keywords    MultiUE.Detach    AND
#    ...    Case recover for K001    AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_K001}
#
#[1]CB008140-5G-K_007_Pcell_lock_without_Graceful_Cell_Shutdown_multible_external_gnbs
#    [Documentation]    Cell lock without Graceful Cell Shutdown enabled is performed on the cell in prime-gNB which is
#    ...    the PCell for inter-gNB CA UEs
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for K007
#    Multi MTU power and prepare ue
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    ### UE1 attach gnb1_cell1
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename_007_attach_UE1_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2}    ue_index=${0}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb4}    gnb_list=${gnb_list_K007_1}
#    ### UE2 attach gnb1_cell1
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename_007_attach_UE2_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2}    ue_index=${1}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3}    gnb_list=${gnb_list_K001}
#    Collect log for graceful cell shutdown    filename=filename_007_gnb    gnb_list=${gnb_list_K007}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_LOCK}
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_CELL1_UNLOCK}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K007}
#    MultiUE.Detach    ue_index=${0}
#    MultiUE.Detach    ue_index=${1}
#     ###UE1 attach gnb1_cell1
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename1_007_attach_UE1_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2}    ue_index=${0}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3}    gnb_list=${gnb_list_K001}
#    ### UE2 attach gnb3_cell2
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}
#    MultiUE.band restriction    ue_index=${1}    band=25:41:66:77
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename1_007_attach_UE2_gnb
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell2}     ue_index=${1}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb4}    gnb_list=${gnb_list_K007_2}
#    Collect log for graceful cell shutdown    filename=filename1_007_gnb    gnb_list=${gnb_list_K007}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB3_CELL2_LOCK}    gnb_index=${2}
#    Collect log for graceful cell shutdown    filename=filename2_007_gnb    gnb_list=${gnb_list_K007}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB3_CELL2_UNLOCK}    gnb_index=${2}    wait_time=30s
#    MultiUE.Detach    ue_index=${0}
#    MultiUE.Detach    ue_index=${1}
#    ###UE1 attach gnb1_cell1
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename2_007_attach_UE1_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2}    ue_index=${0}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3}    gnb_list=${gnb_list_K001}
#    ### UE2 attach gnb3_cell2
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename2_007_attach_UE2_gnb
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell2}     ue_index=${1}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb4}    gnb_list=${gnb_list_K007_2}
#    MultiUE.Start DL Traffic    ue_index=${1}    throughput_for_DL=${Send_Tput_DL_F+F}
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}    gnb4_cell2_value=${0}
#    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${5}    gnb4_cell2_value=${0}
#    Collect log for graceful cell shutdown    filename=filename3_007_gnb    gnb_list=${gnb_list_K001}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN}
#    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_F_007}    tput_dl_scell=${expected_tput_F007}   scellid=${2}
#    ...    pcellid=${2}    gnb_prime=${2}    gnb_external=${3}
#    MultiUE.Stop DL Traffic
#    Check wireshark log for K007    logname=${filename_007_gnb0}    logname1=${filename_007_gnb2}    logname2=${filename_007_gnb3}
#    Check wireshark log for K007_1    logname=${filename1_007_gnb0}    logname1=${filename1_007_gnb2}    logname2=${filename1_007_gnb3}
#    Check wireshark log for K007_2   logname=${filename2_007_gnb2}
#    [Teardown]    run keywords    MultiUE.band restriction    ue_index=${1}    band=2:25:41:66:77    AND
#    ...    MultiUE.Detach    ue_index=${0}    AND
#    ...    MultiUE.Detach    ue_index=${1}    AND
#    ...    Multi MTU power and recovery ue    AND
#    ...    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_CELL1_UNLOCK}    AND
#    ...    Delete NRREL online    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K007_1}    AND
#    ...    Delete NRREL online    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB3_K001}    gnb_index=${2}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation  AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_K001}
#
#[1]CB008140-5G-K_008_Scell_lock_with_Graceful_Cell_Shutdown_covBasedA1_bufferbased
#    [Documentation]    Cell lock with Graceful Cell Shutdown enabled is performed on the cell in prime-gNB which is the
#    ...    PCell for inter-gNB CA UEs.
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for K008
#    MultiUE.Prepare UE
#    ## trriger scell shutting down with A2 release
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}     gnb3_cell2_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename_008_attach_gnb
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1}    UEContextModificationResponse_nums=${2}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}    gnb_list=${gnb_list_K001}
#    Collect log for graceful cell shutdown    filename=filename_008_gnb    gnb_list=${gnb_list_K001}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN}    gnb_index=${0}
#    MultiUE.Detach
#    ##trriger scell shutting down reset
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_CELL1_UNLOCK}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K008_1}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}     gnb3_cell2_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename1_008_attach_gnb
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1}    UEContextModificationResponse_nums=${3}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}    gnb_list=${gnb_list_K001}
#    Collect log for graceful cell shutdown    filename=filename1_008_gnb    gnb_list=${gnb_list_K001}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN}    gnb_index=${0}
#    MultiUE.Detach
#    ### 3CC to 2CC because of scell shutdown
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_CELL1_UNLOCK}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_K008_2}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB1_K008_2}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K008_2}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB3_K008_2}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}     gnb1_cell3_value=${0}    gnb3_cell2_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename2_008_attach_gnb
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1_and_cell11}     UEContextModificationResponse_nums=${2}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1_3CC}    gnb_list=${gnb_list_K001}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F+F}
#    Collect log for graceful cell shutdown    filename=filename2_008_gnb    gnb_list=${gnb_list_K001}
#    ...    PARAMETERS=${PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN}    gnb_index=${0}
#    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_F}    tput_dl_scell=${expected_tput_F}   scellid=${11}
#    ...    pcellid=${2}    gnb_prime=${2}    gnb_external=${0}
#    MultiUE.Stop DL Traffic
#    Check wireshark log for K008_1    logname=${filename_008_gnb2}    logname1=${filename_008_gnb0}
#    Check wireshark log for K008_2    logname=${filename1_008_gnb2}    logname1=${filename1_008_gnb0}
#    Check wireshark log for K008_3    logname=${filename2_008_gnb2}    logname1=${filename2_008_gnb0}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list_K007}
#    [Teardown]    run keywords    MultiUE.Detach    AND
#    ...    Case recover for K008    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation  AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_K001}
#
#[1]CB008140-5G-K_017_CA_Relationship_removal_requiring_cell_reset
#    [Documentation]    Parameters are modified to remove the CA relationship between PCell and ext-SCell(s)
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    MultiUE.Prepare UE
#    Case prepare for K017
#    ###Delete An NRREL and check TPUT
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Wait until keyword succeeds    4x   10s    Attach and check CA setup    filename=filename_017_attach_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2_and_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3_3CC}    gnb_list=${gnb_list_K001}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F+F}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}    gnb3_cell3_value=${0}
#    Collect log for delete NRREl    filename=filename_017_gnb    gnb_list=${gnb_list_K001}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K017}    gnb_index=${0}
#    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_F}    tput_dl_scell=${expected_tput_F}   scellid=${2}
#    ...    pcellid=${1}    gnb_prime=${0}    gnb_external=${2}
#    MultiUE.Stop DL Traffic
#    Collect log for delete NRREl    filename=filename1_017_gnb    gnb_list=${gnb_list_K001}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DELETE_Parameter_GNB1_K017}    gnb_index=${0}
#    Collect log for check Ingnbresourcestatusupdat    filename=filename2_017_gnb    gnb_list=${gnb_list_K001}
#    Check wireshark log for K017_1    logname=${filename_017_gnb0}    logname1=${filename_017_gnb2}
#    Check wireshark log for K017_2    logname=${filename1_017_gnb0}    logname1=${filename1_017_gnb2}
#    ...    logname2=${filename2_017_gnb0}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list_K007}
#    [Teardown]     run keywords    MultiUE.Detach    AND
#    ...    Delete NRREL online    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K007_1}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation  AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_K001}
#
#[1]CB008140-5G-K_027_Incompatible_IGCA_Xp_communication_failure_alarm_recovery_via_removing_ext-gNB3_from_the_CA_relation
#    [Documentation]    This user scenario describes recovery from the Inter-gNB CA Xp communication failure alarm with the
#    ...    ext-gNB2 by removing ext-gNB3 from the CA relation with the prime gNB1.
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    MultiUE.Prepare UE
#    Case prepare for K027
#    Wait until keyword succeeds    3min    20s   Check expect Fault Present    expect_alarm=7331    gnb_index=${0}
#    Modify Parameters for Cases   gnb_index=${0}   Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_K027}
#    Check only default Fault Present    gnb_list=${gnb_list_K001}
#    Case prepare for K021
#    Check only default Fault Present    gnb_list=${gnb_list_K001}
#     ##pcell's RU reset
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename_021_attach_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb4}    gnb_list=${gnb_list_K007_1}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell3_value=${10}
#    Collect log for Reset ABIO/ABIL    filename=filename_021_gnb    gnb_list=${gnb_list_K007_1}
#    ...    gnb_index=${0}     abil_index=${1}
#    MultiUE.Detach
#    ###scell's RU reset
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Run Keyword And Ignore Error    Attach and check CA setup    filename=filename1_021_attach_gnb
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb4}    gnb_list=${gnb_list_K007_1}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell3_value=${10}
#    Collect log for Reset ABIO/ABIL    filename=filename1_021_gnb    gnb_list=${gnb_list_K007_1}
#    ...    gnb_index=${3}     abil_index=${2}
#    Check wireshark log for K021_1    logname=${filename_021_gnb0}    logname1=${filename_021_gnb3}
#    Check wireshark log for K021_2    logname=${filename1_021_gnb0}    logname1=${filename1_021_gnb3}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list_K007}
#    [Teardown]     run keywords    MultiUE.Detach    AND
#    ...    Case recover for K021    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation  AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_K001}
#
#*** Keywords ***
#Common Case TestLine Setup with gnb1 and gnb3
#    @{scf_list}    Create List
#    Append to List    ${scf_list}    ${scf_path}${scf_name_gnb0}    ${scf_path}${scf_name_gnb2}    ${scf_path}${scf_name_gnb3}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_K007}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_K007}
#
#Case prepare for K001
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_K001}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_K001}    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB1_K001}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DElETE_GNB1_K001}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K001}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB3_K001}    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB3_K001}
#
#Case recover for K001
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_CELL1_UNLOCK}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_K001}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K001}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB1_K001_recover}
#    Modify Parameters for Cases   gnb_index=${2}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB3_K001}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DElETE_Recover_GNB3_K001}
#
#Case prepare for K007
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_K007}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_K007}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K007}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB3_K007}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB4_K007}
#
#Case prepare for K007_1
#    Delete NRREL online    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K007}
#
#Case prepare for K008
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_K008}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB1_K008}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K008}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB3_K008}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB3_K008}
#
#Case recover for K008
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_recover_GNB1_K008}
#    ...    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB1_K008}
#    Modify Parameters for Cases   gnb_index=${2}    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB3_K008}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB3_K008}
#    ...    Modify_Para_Online=${PARAMETERS_TO_recover_GNB3_K008}
#
#Case prepare for K017
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_K017}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_K017}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K017}
#
#Case prepare for K021
#    Modify Parameters for Cases   gnb_index=${0}   Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_K021}
#    ...    Modify_Para_Online=${PARAMETERS_TO_MODIFY_XP_true}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_K007}
#
#Case recover for K021
#    Modify Parameters for Cases   gnb_index=${0}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_K007_1}
#
#Case prepare for K027
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_XP_Wrong}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_K027}
#
#Attach and check CA setup
#    [Arguments]    ${filename}    ${scell_index_list}    ${extgnb_index_list}        ${pcell_index}    ${gnb_list}
#    ...    ${Primegnb_index}    ${ue_index}=${ue_index_${gnb_instance0}}    ${UEContextModificationResponse_nums}=${3}
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    MultiUE.Attach    ue_index=${ue_index}
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    ###check CA setup succuss
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${${filename}${Primegnb_index}}
#    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
#    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
#    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}
#    [Teardown]    Run Keyword And Ignore Error     Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#
#Collect log for graceful cell shutdown
#    [Arguments]    ${filename}    ${gnb_list}    ${PARAMETERS}    ${gnb_index}=${0}    ${wait_time}=300s
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    Modify Parameters for Cases   gnb_index=${gnb_index}    Modify_Para_Online=${PARAMETERS}
#    sleep    ${wait_time}
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#   [Teardown]    Run Keyword And Ignore Error     Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#
#Collect log for Reset ABIO/ABIL
#    [Arguments]    ${filename}    ${gnb_list}    ${gnb_index}=${0}     ${url}=${WEBUI_host${gnb_index}}    ${abil_index}=${1}
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    Reset ABIO/ABIL Selenium    gnb_index=${0}    url=${url}    abil_index=${abil_index}
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    Wait until keyword succeeds    20 min    20s
#    ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
#   [Teardown]    Run Keyword And Ignore Error     Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#
#Collect log for delete NRREl
#    [Arguments]    ${filename}    ${gnb_list}    ${Delete_Mo_Online}='NULL'    ${Delete_Para_Online}='NULL'    ${gnb_index}=${0}
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    Modify Parameters for Cases   gnb_index=${gnb_index}    Delete_Mo_Online=${Delete_Mo_Online}
#    ...    Delete_Para_Online=${Delete_Para_Online}
#    Sleep    90s
#    Wait until keyword succeeds    20 min    20s
#    ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#   [Teardown]    Run Keyword And Ignore Error     Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#
#Collect log for check Ingnbresourcestatusupdat
#    [Arguments]    ${filename}    ${gnb_list}
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#    Sleep    3s
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#   [Teardown]    Run Keyword And Ignore Error     Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
#
#
#Check wireshark log for K001_1
#    [Arguments]    ${logname}    ${logname1}    ${event}=0
#    Check intergNB HO process on source gNB    logname=${logname}    ip_source=${xnap_gnb1}   ip_target=${xnap_gnb3}
#    Check intergNB HO process on target gNB    logname=${logname1}   ip_source=${xnap_gnb1}    ip_target=${xnap_gnb3}
#    ...    npap_ip_target=${xnap_gnb3}
#    Check wireshark log for Measurement EventA1 after HO    logname=${logname1}
#    ...    cell_index=${2}    gnb_index=${2}
#    ##check target CA setup succuss
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell11}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}    UEContextModificationResponse_nums=${1}
#    ##check source CA release
#    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}
#
#Check wireshark log for K001_2
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    ## RRC Reestablishment in Extgnb
#    Check RRC Reestablishment to a cell   logname=${logname1}    source_cell_index=${1}    target_cell_index=${2}
#    ...    source_gnb_index=${0}    target_gnb_index=${2}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell11}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}    UEContextModificationResponse_nums=${1}
#
#Check wireshark log for K007
#    [Arguments]    ${logname}    ${logname1}    ${logname2}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ### reset message in Extgnb1
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ### reset message in Extgnb2
#    Check F1ap reset messages    logname=${logname2}
#    Check XNap reset messages    logname=${logname2}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#    Check XNap update messages    logname=${logname2}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#
#
#Check wireshark log for K007_1
#    [Arguments]    ${logname}    ${logname1}    ${logname2}
#    ### reset message in gnb1
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host2}    ip.dst=${bts_host0}
#    ### reset message in gnb3
#    Check F1ap reset messages    logname=${logname1}
#    Check E1ap reset messages in Primegnb    logname=${logname1}
#    Check NGap reset messages in Primegnb    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host2}    ip.dst=${bts_host0}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host2}    ip.dst=${bts_host3}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host2}    ip.dst=${bts_host0}
#    ...     lcrid_pcell_cell=${2}     gnb_index_pcell=${2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host2}    ip.dst=${bts_host3}
#    ...     lcrid_pcell_cell=${2}     gnb_index_pcell=${2}
#    ### reset message in gnb4
#    Check F1ap reset messages    logname=${logname2}
#    Check XNap reset messages    logname=${logname2}    ip.src=${bts_host2}    ip.dst=${bts_host3}
#
#
#Check wireshark log for K007_2
#    [Arguments]    ${logname}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host2}    ip.dst=${bts_host0}
#    ...     lcrid_pcell_cell=${2}     gnb_index_pcell=${2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host2}    ip.dst=${bts_host3}
#    ...     lcrid_pcell_cell=${2}     gnb_index_pcell=${2}
#
#Check wireshark log for K008_1
#    [Arguments]    ${logname}    ${logname1}
#    Get cell id multignb    lcrid_pcell=${2}    scell_index_list=${scell_index_list_cell1}
#    ...    PrimegNB_index=${2}    extgnb_index_list=${extgnb_index_gnb1}
#    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=0
#    Check Measurement message on PrimegNB    logname=${logname}    cell_index=${2}    gnb_index=${2}    event_id=3
#    ...    meas_lengths=${1}
#    Check IgNBCAUeContextModificationRequest message has scell ToBeRemoved    logname=${logname}    release_cell=${extcell_id}[0]
#    Check IgNBCAUeContextModificationResponse message has scell ToBeRemoved    logname=${logname}    scelllcird=1
#    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
#    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname1}
#
#Check wireshark log for K008_2
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    Check XNap IgNbCAconfigurationUpdateIndication messages    logname=${logname}
#     ...    lcrid_shutdown_cell=${1}    gnb_index_shutdown=${0}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    # RRC Reestablishment in Extgnb
#    Check RRC Reestablishment to a cell   logname=${logname}    source_cell_index=${2}    target_cell_index=${2}
#    ...    source_gnb_index=${2}    target_gnb_index=${2}
#    Check RRC Reestablishment single cell successful   logname=${logname}
#
#Check wireshark log for K008_3
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    Check XNap IgNbCAconfigurationUpdateIndication messages    logname=${logname}
#     ...    lcrid_shutdown_cell=${1}    gnb_index_shutdown=${0}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    # RRC Reestablishment in Extgnb
#    Check RRC Reestablishment to a cell   logname=${logname}    source_cell_index=${2}    target_cell_index=${2}
#    ...    source_gnb_index=${2}    target_gnb_index=${2}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell11}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}    UEContextModificationResponse_nums=${1}
#
#Check wireshark log for K014_1
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_locked_cell=${1}     gnb_index_lock=${0}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_locked_cell=${1}     gnb_index_lock=${0}
#    ## RRC Reestablishment in Extgnb
#    Check RRC Reestablishment to a cell   logname=${logname1}    source_cell_index=${1}    target_cell_index=${1}
#    ...    source_gnb_index=${0}    target_gnb_index=${0}
#    lcrid_RRE_cell=${2}    gnb_index_RRE=${2}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell11}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}    UEContextModificationResponse_nums=${1}
#
#Check wireshark log for K017_1
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    Check XNap IgNbCAconfigurationUpdateIndication has scell remove    logname=${logname}
#     ...    lcrid_remove_cell=${31}    gnb_index_remove=${2}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#
#
#Check wireshark log for K017_2
#    [Arguments]    ${logname}    ${logname1}    ${logname2}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    Check IgNBCARemoval messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}
#    Check IgNBCARemoval messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host2}
#    Check IgNBCAResourceStatusUpdate message existence or not    logname=${logname2}
#    ...    ip.src=${bts_host2}    ip.dst=${bts_host0}
#
#Check wireshark log for K021_1
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}    server_cell_num=${3}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host0}    ip.dst=${bts_host3}
#    ...    lcrid_pcell_cell=${1}     gnb_index_pcell=${0}    server_cell_num=${3}
##    ## RRC Reestablishment in Extgnb
##    Check RRC Reestablishment to a cell   logname=${logname1}    source_cell_index=${1}    target_cell_index=${2}
##    ...    source_gnb_index=${0}    target_gnb_index=${2}
##    Check RRC Reestablishment single cell successful   logname=${logname1}
#
#Check wireshark log for K021_2
#    [Arguments]    ${logname}    ${logname1}
#    ### reset message in Primegnb
#    Check F1ap reset messages    logname=${logname}
#    Check E1ap reset messages in Primegnb    logname=${logname}
#    Check NGap reset messages in Primegnb    logname=${logname}
#    Check XNap reset messages    logname=${logname}    ip.src=${bts_host3}    ip.dst=${bts_host0}
#    Check XNap update messages    logname=${logname}    ip.src=${bts_host3}    ip.dst=${bts_host0}
#    ...    lcrid_pcell_cell=${31}     gnb_index_pcell=${3}    server_cell_num=${2}
#    ### reset message in Extgnb
#    Check F1ap reset messages    logname=${logname1}
#    Check XNap reset messages    logname=${logname1}    ip.src=${bts_host3}    ip.dst=${bts_host0}
#    Check XNap update messages    logname=${logname1}    ip.src=${bts_host3}    ip.dst=${bts_host0}
#    ...    lcrid_pcell_cell=${31}     gnb_index_pcell=${3}    server_cell_num=${2}
##    ## RRC Reestablishment in Prignb
##    Check RRC Reestablishment to a cell   logname=${logname}    source_cell_index=${1}    target_cell_index=${1}
##    ...    source_gnb_index=${0}    target_gnb_index=${0}
##    Check RRC Reestablishment single cell successful   logname=${logname}
