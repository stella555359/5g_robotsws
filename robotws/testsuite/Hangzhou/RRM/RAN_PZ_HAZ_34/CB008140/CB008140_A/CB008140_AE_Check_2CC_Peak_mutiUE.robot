#*** Settings ***
#Force Tags    PY36
#Documentation     author: qingqing zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB008140-AB
#
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_A_Variables.py
#
#
#Suite Setup    Run Keywords
#...            robot_common_operations.Common Suite Setup
#...            AND    Run Keyword And Ignore Error    Common Suite Setup for COAM
#...            AND    Common Case TestLine Setup with gnb1 and gnb2 and gnb4
#
#Suite Teardown    Run Keywords
#...               robot_common_operations.Common Suite Teardown    AND
#...               Adjust gNB_RU Attenuation    AND
#...               Common Case TestLine Setup recover    AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${gnb_path}    /tmp
#${tl_scf_gnb0}    Configuration_scf_GNB1_CB008140_peak.xml
#${tl_scf_gnb0_7736}    Configuration_scf_GNB1_CB008140_CB007736.xml
#${tl_scf_gnb2}    Configuration_scf_GNB3_CB008140_peak.xml
#${tl_scf_gnb3}    Configuration_scf_GNB4_CB008140_peak.xml
#${scf_path}    /opt/workspace/SCF/
#${logname_AE007}    AE007_gnb2.pcap
#${interface1}    any
#${expected_tput_ul}    105
#${expected_tput_ul_AE007}    93
#${expected_tput_ul_T_38511}    76
#${expected_tput_ul_T_38611}    76
#${expected_tput_ul_T_38711}    90
#${expected_tput_dl_F_DSS}    249
#${expected_tput_dl_F}    390
#${expected_tput_dl_T}    1420
#${expected_tput_dl_T_40M}    540
#${expected_tput_dl_T_30M}    380
#${Send_Tput_DL_F_F}    800
#${Send_Tput_DL_F_T}    1800
#${Send_Tput_DL_T_T}    2000
##@{counter_gnb3_M55310C01007}    ${1}
##@{counter_gnb3_M55310C01009}    ${1}
#@{counter_gnb2}    ${0}    ${100000000}    ${100000000}
#@{counter_gnb3}    ${100000000}    ${100000000}
#@{counter_gnb2_M55316C05001}    ${1}
#@{counter_gnb3_M55316C09001}    ${1}
#
#${filename_gnb3_003_attach}    log_name_AE_003_gNB3_attach.pcap
#${filename_gnb1_007_attach}    log_name_AE_007_gNB1_attach.pcap
#${filename1_GG001_gnb2}    log1_name_GG_001_gNB2.pcap
#${filename1_GG001_gnb3}    log1_name_GG_001_gNB3.pcap
#${filename_gnb1_AB_B3_attach}       7736AB_B205_1.pcap
#${filename1_gnb1_AB_B3_attach}       7736AB_B205_2.pcap
#${filename2_gnb1_AB_B3_re_addition}       7736AB_B205_re_addition.pcap
#${filename_gnb1_AB_B3_002_attach}       7736AB_B202_1.pcap
#${filename1_gnb1_AB_B3_002_attach}       7736AB_B202_2.pcap
#${filename_gnb1_AD_B1_attach}       7736AD_B1_1.pcap
#${filename1_gnb1_AD_B1_attach}       7736AD_B1_2.pcap
#@{APN_mdrb}    mdrb.nokia.com    mdrbnokiacom
#${port_mdrb}    52387
#${APN_DX}    dxdata1
#@{gnb_ips}    ${bts_host0}    ${bts_host2}    ${bts_host3}
#@{gnb_ips_AE}    ${bts_host2}    ${bts_host3}
#@{gnb_ips_7736}    ${bts_host0}
#@{gnb_list}    ${0}    ${2}    ${3}
#@{gnb_list_AE}    ${2}    ${3}
#@{gnb_list_7736}    ${0}
#@{scell_index_list_cell2}    ${2}
#@{extgnb_index_gnb4}    ${3}
#@{ALLOWED_FAULT}    61652    61524    61649    9000    4592    4527    7311    4334    61074    4655    4687    7307    4654
#@{branch}    SBTS23R3_ENB_0000    SBTS24R2_ENB_9999
#*** Test Cases ***
#[1]CB008140-5G-AE_003_Buffer_based_scell_activation_for_Ignb_CA_2CC_with_data_transfer_peak_reach_by_single_UE_T_T_BF
#    [Documentation]
#    ...    This case is check throughput with Ignb CA 2CC by T+T
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    ${expected_tput_dl_T}    ${expected_tput_dl_T_40M}    Get two gnbs theoretical throughput from nrdim
#    ...    scellid=3    pcellid=31    gnb_prime=${3}    gnb_external=${2}
#    Case prepare for AE003
#    MultiUE.Prepare UE
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Adjust gNB_RU Attenuation     gnb4_cell3_value=${5}    gnb3_cell3_value=${0}
#    ...    ELSE IF    '${gnb_instance0}' == '@{gnb_id}[1]'
#    ...    Adjust gNB_RU Attenuation     gnb4_cell3_value=${20}    gnb3_cell3_value=${32}
#    ...    ELSE    Adjust gNB_RU Attenuation     gnb4_cell3_value=${25}    gnb3_cell3_value=${0}
#    UE attach and collect log    filename=${filename_gnb3_003_attach}
#    Sleep    180s
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=3    pcellid=31    tput_dl_pcell=${expected_tput_dl_T}
#    ...    tput_dl_scell=${expected_tput_dl_T_40M}        tput_ul_pcell=${expected_tput_ul_T_${gnb_instance0}}
#    ...    gnb_prime=${3}    gnb_external=${2}
#    ...    dl_throughput=${Send_Tput_DL_T_T}    ul_throughput=${Send_Tput_UL}
#    MultiUE.Stop DLUL traffic
#    MultiUE.Detach
#    UE attach and collect log    filename=${filename_gnb3_003_attach}
#    Sleep    2s
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=3    pcellid=31    tput_dl_pcell=${expected_tput_dl_T}
#    ...    tput_dl_scell=${expected_tput_dl_T_40M}        tput_ul_pcell=${expected_tput_ul_T_${gnb_instance0}}
#    ...    gnb_prime=${3}    gnb_external=${2}
#    ...    dl_throughput=${Send_Tput_DL_T_T}    ul_throughput=${Send_Tput_UL}    time=150s
#    MultiUE.Stop DLUL traffic
#    MultiUE.Detach
#    UE attach and collect log    filename=${filename_gnb3_003_attach}
#    Sleep    2s
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=3    pcellid=31    tput_dl_pcell=${expected_tput_dl_T}
#    ...    tput_dl_scell=${expected_tput_dl_T_40M}   gnb_prime=${3}    gnb_external=${2}
#    ...    dl_throughput=${Send_Tput_DL_T_T}    ul_throughput=${Send_Tput_UL}    time=300s
#    MultiUE.Stop DLUL traffic
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_AE}    gnb_list=${gnb_list_AE}
#    [Teardown]    run keywords
#    ...    MultiUE.Detach    AND
#    ...    Case recover for AE003    AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_AE}
#
#[1]CB008140-5G-AE_005_Buffer_based_scell activation_and_deactivation_for_Ignb_CA_2CC_by_single_UE_F_F
#    [Documentation]
#    ...    This case is check throughput with Ignb CA 2CC by F+F
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    ${expected_tput_dl_F_pcell}    ${expected_tput_dl_F_scell}    Get two gnbs theoretical throughput from nrdim
#    ...    scellid=2    pcellid=1    gnb_prime=${2}    gnb_external=${3}
#    Case prepare for AE005
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}    gnb4_cell2_value=${0}
#    Start capture multi gNB log    filename=filename1_GG001_gnb    gnb_list=${gnb_list_AE}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename1_GG001_gnb    gnb_list=${gnb_list_AE}
#    Check wireshark log for GG001    logname=${filename1_GG001_gnb2}    logname1=${filename1_GG001_gnb3}
#    Prepare with PM counter time to caculate    period=start
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=2    pcellid=1    tput_dl_pcell=${expected_tput_dl_F_pcell}
#    ...    tput_dl_scell=${expected_tput_dl_F_scell}        tput_ul_pcell=${expected_tput_ul}
#    ...    gnb_prime=${2}    gnb_external=${3}
#    ...    dl_throughput=${Send_Tput_DL_F_F}    ul_throughput=${Send_Tput_UL}
##    protocol=${protocol_TCP}
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}    gnb4_cell2_value=${0}
#    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_dl_F_pcell}    tput_dl_scell=${expected_tput_dl_F_scell}   scellid=2
#    ...    pcellid=1    gnb_prime=${2}    gnb_external=${3}    duration=300s
#    MultiUE.Stop DLUL traffic
#    Wait until keyword succeeds    10 min    20s    Check counter for AE005
#    MultiUE.Stop DLUL traffic
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_AE}    gnb_list=${gnb_list_AE}
#    [Teardown]    run keywords
#    ...    MultiUE.Detach    AND
#    ...    Case recover for AE005    AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_AE}
#
#[1]CB008140-5G-AE_007_Blind_Scell_addition_with_Ignb_CA_2CC_and_multiple_non_GBR_DRB_and_data_trasfer_success
#    [Documentation]
#    ...    This case is check throughput with Ignb CA 2CC by F+T
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    ${expected_tput_dl_F}    ${expected_tput_dl_T}    Get two gnbs theoretical throughput from nrdim
#    ...    scellid=31    pcellid=1    gnb_prime=${0}    gnb_external=${3}
#    MultiUE.Prepare UE
#    Case prepare for AE007
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell3_value=${0}
#    MultiUE.Change APN    APN=@{APN_mdrb}[0]
#    UE attach and collect log    filename=${filename_gnb1_007_attach}    gNB_index=${0}
#    Check multi drb in prime    logname=${filename_gnb1_007_attach}
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F}
#    ...    tput_dl_scell=${expected_tput_dl_T}        tput_ul_pcell=${expected_tput_ul_AE007}
#    ...    gnb_prime=${0}    gnb_external=${3}    APN=@{APN_mdrb}[1]
#    ...    dl_throughput=${Send_Tput_DL_T_T}    ul_throughput=${Send_Tput_UL}    time=300s
#    MultiUE.Stop DLUL traffic    APN=@{APN_mdrb}[1]
#    Enable actOptimizedFlowControl for case
#    Sleep    30s
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F}
#    ...    tput_dl_scell=${expected_tput_dl_T}        tput_ul_pcell=${expected_tput_ul_AE007}
#    ...    gnb_prime=${0}    gnb_external=${3}    APN=@{APN_mdrb}[1]    ul_throughput=${Send_Tput_UL}
#    ...    dl_throughput=${Send_Tput_DL_T_T}    dl_port=${port_mdrb}    time=300s
#    MultiUE.Stop DLUL traffic    APN=@{APN_mdrb}[1]    iperf_port=${port_mdrb}
#    sleep    30s
#    MultiUE.Start DL traffic parallel and check 2CC tput    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F}
#    ...    tput_dl_scell=${expected_tput_dl_T}    dl_port_mdrb=${port_mdrb}
#    ...     gnb_prime=${0}    gnb_external=${3}    APN=@{APN_mdrb}[1]    time=300s
#    MultiUE.Stop DLUL traffic    APN=@{APN_mdrb}[1]    iperf_port_mdrb=${port_mdrb}
#    [Teardown]    run keywords
#    ...    MultiUE.Change APN    APN=${APN_DX}
#    ...    AND    MultiUE.Detach
#    ...    AND    Run Keyword And Ignore Error    Case recover for AE007
#    ...    AND    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list_AE}
#
#
#[1]CB007736_5G_AB_B2_005_SISO_common_reset_with_3CC_config_and_cell_mapping_Inter_core_with3cc_on_2abil
#    [Documentation]
#    ...    This case is to verify 3CC scell addition and check 3CC peak tput after cell lock&unlock and RU reset
#    [Tags]    CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_AB_B2_pre}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_AB_B2_pre}
#    Check only default Fault Present    gnb_list=${gnb_list_7736}
#    ADD cell2 NRREL to cell1&cell11
#    Reset ABIO/ABIL Selenium    gnb_index=${0}    url=${WEBUI_host${gnb_index}}    abil_index=${1}
#    Wait until keyword succeeds    20 min    20s
#    ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename_gnb1_AB_B3_attach}
#    Check wireshark log for 3CC    logname=${filename_gnb1_AB_B3_attach}
#    MultiUE.Detach
#    Lock Unlock cell1&cell11
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename1_gnb1_AB_B3_attach}
#    Check wireshark log for 3CC    logname=${filename1_gnb1_AB_B3_attach}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
#    Sleep    30s
#    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell1=${expected_tput_dl_F}
#    ...    tput_dl_scell2=${expected_tput_dl_F}    scellid1=1    scellid2=11    pcellid=2
#    ...    gnb_prime=${0}    gnb_external=${0}    tput_ul_pcell=NULL    ue_type=${tl.ues[0].capabilities[0]}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${30}
#    RU reset and check scell re-addition    nglogname=${filename2_gnb1_AB_B3_re_addition}
#    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell1=${expected_tput_dl_F}
#    ...    tput_dl_scell2=${expected_tput_dl_F}    scellid1=1    scellid2=11    pcellid=2
#    ...    gnb_prime=${0}    gnb_external=${0}    tput_ul_pcell=NULL    ue_type=${tl.ues[0].capabilities[0]}
#    MultiUE.Stop DLUL traffic
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    MultiUE.Detach    AND
#    ...    Run Keyword And Ignore Error    Modify Parameters for Cases   gnb_index=${0}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_AB_B3}
#
#[1]CB007736_5G_AE_B3_002_CA_relation_update_online_with_webui_and_peakTP_check_from_2CC_to_3CC_mix_Pcell_on_ABIO
#    [Documentation]
#    ...    This case is to verify 3CC scell addition and check 3CC peak tput in mix env
#    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_AB_B2_pre}
#    Check only default Fault Present
#    MultiUE.Prepare UE
#    ADD cell2 NRREL to cell1
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename_gnb1_AB_B3_002_attach}
#    Check wireshark log for 2CC    logname=${filename_gnb1_AB_B3_002_attach}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=1    pcellid=2    tput_dl_pcell=${expected_tput_dl_F}
#    ...    tput_dl_scell=${expected_tput_dl_F}    gnb_prime=${0}    gnb_external=${0}
#    ...    dl_throughput=${Send_Tput_DL_F_F}    tput_ul_pcell=NULL
#    MultiUE.Stop DLUL traffic
#    MultiUE.Detach
#    ADD cell2 NRREL to cell11
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename1_gnb1_AB_B3_002_attach}
#    Check wireshark log for 3CC    logname=${filename1_gnb1_AB_B3_002_attach}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
#    Sleep    30s
#    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell1=${expected_tput_dl_F}
#    ...    tput_dl_scell2=${expected_tput_dl_F}    scellid1=1    scellid2=11    pcellid=2
#    ...    gnb_prime=${0}    gnb_external=${0}    tput_ul_pcell=NULL    ue_type=${tl.ues[0].capabilities[0]}
#    MultiUE.Stop DLUL traffic
#    sleep    30s
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
#    Sleep    30s
#    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell1=${expected_tput_dl_F}
#    ...    tput_dl_scell2=${expected_tput_dl_F}    scellid1=1    scellid2=11    pcellid=2
#    ...    gnb_prime=${0}    gnb_external=${0}    tput_ul_pcell=NULL    ue_type=${tl.ues[0].capabilities[0]}
#    MultiUE.Stop DLUL traffic
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_7736}    gnb_list=${gnb_list_7736}
#     [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    MultiUE.Stop DLUL traffic    AND
#    ...    Run Keyword And Ignore Error    MultiUE.Detach    AND
#    ...    Run Keyword And Ignore Error    Modify Parameters for Cases   gnb_index=${0}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_NRREL_GNB1_AB_B3}
#
#[1]CB007736_5G_AD_B1_003_3CC_config_peakTP_check_with_cellmap_same_L2RT_instance_Interworking_with_Dss_and_PRB_Blanking
#    [Documentation]
#    ...    This case is to verify 3CC scell addition and check 3CC peak tput in dss env
#    [Tags]    CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_DSS}
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_AD_B1_03_pre}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_AB_B2_pre}
#    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=unlocked
#    sleep    120s
#    Check only default Fault Present    gnb_list=${gnb_list_7736}
#    ADD cell2 NRREL to cell1&cell11
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename1_gnb1_AD_B1_attach}
#    Check wireshark log for 3CC    logname=${filename1_gnb1_AD_B1_attach}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
#    Sleep    30s
#    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F_DSS}    tput_dl_scell1=${expected_tput_dl_F}
#    ...    tput_dl_scell2=${expected_tput_dl_F}    scellid1=1    scellid2=11    pcellid=2
#    ...    gnb_prime=${0}    gnb_external=${0}    tput_ul_pcell=NULL    ue_type=${tl.ues[0].capabilities[0]}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    MultiUE.Detach    AND
#    ...    Run Keyword And Ignore Error     Common Case TestLine Setup with singe BTS    gnb_index=${0}
#    ...    is_commission=True    golden_scf_name=${tl_scf_gnb0_7736}
#
#*** Keywords ***
#Common Case TestLine Setup with gnb1 and gnb2 and gnb4
#    @{scf_list}    Create List
#    ${release_info}    Get sagnb release
#    ${scf_gnb0}    Run keyword if    '${release_info}' == '@{branch}[0]'    Set Variable    ${scf_path}${tl_scf_gnb0_7736}
#    ...    ELSE    Set Variable    ${scf_path}${tl_scf_gnb0}
#    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_path}${tl_scf_gnb2}    ${scf_path}${tl_scf_gnb3}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=locked
#    ...    ELSE IF    '${gnb_instance0}' == '@{gnb_id}[1]'       Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=locked
#    ...    ELSE    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-352    parameter=administrativeState     value=locked
#
#Common Case TestLine Setup recover
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=unlocked
#   ...    ELSE IF    '${gnb_instance0}' == '@{gnb_id}[1]'       Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=unlocked
#    ...    ELSE    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-352    parameter=administrativeState     value=unlocked
#
#Case prepare for AE003
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${parameters_to_update_AE_003_pre_GNB3}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${parameters_to_update_AE_003_pre_GNB4}
#    ...    Add_Mo_Online=${parameters_to_update_AE_003}
#
#Case recover for AE003
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${parameters_to_update_AE_003_recover_GNB3}
#    Modify Parameters for Cases   gnb_index=${3}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB4_CELL31}
#    ...    Modify_Para_Online=${parameters_to_update_AE_003_recover_GNB4}
#
#Case prepare for AE005
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${parameters_to_update_AE_005_pre_GNB3}
#    ...    Add_Mo_Online=${parameters_to_update_AE_005}    Add_Para_Online=${LIST_TO_ADD_GNB3_GG001}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${parameters_to_update_AE_005_pre_GNB4}
#    ...    Add_Para_Online=${LIST_TO_ADD_GNB4_GG001}    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB4_GG001}
#
#Case recover for AE005
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${parameters_to_update_AE_005_recover_GNB3}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB3_CELL1}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${parameters_to_update_AE_005_recover_GNB4}
#
#Case prepare for AE007
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_AE_007_pre_GNB1}
#    ...    Add_Mo_Online=${parameters_to_update_AE_007}    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB1_AE007}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${parameters_to_update_AE_007_pre_GNB4}
#
#Enable actOptimizedFlowControl for case
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_actOptimizedFlowControl_GNB1}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${parameters_to_update_actOptimizedFlowControl_GNB4}
#
#Case recover for AE007
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_AE_007_recover_GNB1}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${parameters_to_update_AE_007_recover_GNB4}
#
#ADD cell2 NRREL to cell1&cell11
#    ${release_info}    Get sagnb release
#    Run keyword if    '${release_info}' == '@{branch}[0]'
#    ...    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_UPDATE_AB_B3_005_23R2}
#    ...    ELSE    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_UPDATE_AB_B3_005}
#
#ADD cell2 NRREL to cell1
#    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_UPDATE_AB_B3_002}
#
#ADD cell2 NRREL to cell11
#    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_UPDATE_AB_B3_002_1}
#
#UE attach and collect log
#    [Arguments]    ${filename}    ${gNB_index}=${0}
#    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
#    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
#
#Check multi drb in prime
#    [Arguments]    ${logname}
#    ...    ${message_filter}=ngap.procedureCode == 14 and ngap.fiveQI == 7
#    ...    ${xpath}=.//ngap.fiveQI
#    Log    Check multi drb in prime
#    ${multi_drb}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should contain    ${multi_drb}    7    9
#
#Check counter for AE005
#    get_release_check_result
#    Run Keyword If    '${check_result}' != 'True'    Check counter for AE005 for branch
#    ...    ELSE    Check counter for AE005 for trunk
#
#Check counter for AE005 for branch
#    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_AE005_gNB2}
#    ...    dic_path=${counter_dic_path_AE005_gNB2}    value=${counter_gnb2}
#    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_AE005_gNB2_M55316C05001}
#    ...    dic_path=${counter_dic_path_AE005_gNB2_M55316C05001}    value=${counter_gnb2_M55316C05001}
#    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_AE005_gNB3_M55316C09001}
#    ...    dic_path=${counter_dic_path_AE005_gNB3_M55316C09001}    value=${counter_gnb3_M55316C09001}
#    Check the PM counter should be greater than 1
#    ...    gnb_index=${3}    counter_id=${counter_id_AE005_gNB3}
#    ...    dic_path=${counter_dic_path_AE005_gNB3}    value=${counter_gnb3}
#
#Check counter for AE005 for trunk
#    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_AE005_gNB2}
#    ...    dic_path=${counter_dic_path_AE005_gNB2_trunk}    value=${counter_gnb2}
#    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_AE005_gNB2_M55316C05001}
#    ...    dic_path=${counter_dic_path_AE005_gNB2_M55316C05001_trunk}    value=${counter_gnb2_M55316C05001}
#    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_AE005_gNB3_M55316C09001}
#    ...    dic_path=${counter_dic_path_AE005_gNB3_M55316C09001_trunk}    value=${counter_gnb3_M55316C09001}
#    Check the PM counter should be greater than 1
#    ...    gnb_index=${3}    counter_id=${counter_id_AE005_gNB3}
#    ...    dic_path=${counter_dic_path_AE005_gNB3_trunk}    value=${counter_gnb3}
#
#Check wireshark log for GG001
#    [Arguments]    ${logname}    ${logname1}    ${Primegnb_index}=${2}    ${extgnb_index}=${3}
#    Get cell id multignb    lcrid_pcell=${1}    scell_index_list=${scell_index_list_cell2}
#    ...    PrimegNB_index=${2}    extgnb_index_list=${extgnb_index_gnb4}
#    ${pci_scell}=    get required cell info   required_info=physicalCellId    cell_index=${1}   gnb_index=${extgnb_index}
#    ${xgU_addr_gnb1_ipv6}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host2}    SNSSAI=true
#    ...    xgU_addr=ipV6AddressDN1    filter_param_DN=IPv6 address 1 distinguished name    filter_param_local=Local IPv6 address
#    ...    xgU_addr=ipV6AddressDN1    filter_param_DN=IPv6 address 1 distinguished name    filter_param_local=Local IPv6 address
#    ${xgU_addr_gnb1_ipv4}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host2}    SNSSAI=true
#    ...    xgU_addr=ipV4AddressDN1    filter_param_DN=IPv4 address 1 distinguished name    filter_param_local=Local IPv4 address
#    ${xgU_addr_gnb2_ipv6}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host3}    SNSSAI=true
#    ...    xgU_addr=ipV6AddressDN1    filter_param_DN=IPv6 address 1 distinguished name    filter_param_local=Local IPv6 address
#    ${xgU_addr_gnb2_ipv4}=    Check value of parameter xgUplane address    WEBUI_COAM=${WEBUI_host3}    SNSSAI=true
#    ...    xgU_addr=ipV4AddressDN1    filter_param_DN=IPv4 address 1 distinguished name    filter_param_local=Local IPv4 address
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell2}
#    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_gnb4}
#    Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB    logname=${logname}    xgU_addr=${xgU_addr_gnb1_ipv6}
#    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv6
#    Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB    logname=${logname}    xgU_addr=${xgU_addr_gnb1_ipv4}
#    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv4
#    Check IgNBCAUeContextSetupResponse has transport messages on ExtgNB    logname=${logname1}    xgU_addr=${xgU_addr_gnb2_ipv6}
#    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv6
#    Check IgNBCAUeContextSetupResponse has no transport ip on ExtgNB  logname=${logname1}
#    ...    xpath=.//nokiaf1ap.transportLayerAddressIPv4
#
#Check value of parameter xgUplane address
#    [Arguments]    ${WEBUI_COAM}=${WEBUI_host0}   ${SNSSAI}=true
#    ...    ${xgU_addr}=ipV6AddressDN1    ${filter_param_DN}=IPv6 address 1 distinguished name
#    ...    ${filter_param_local}=Local IPv6 address
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#    ${bts_id}   selenium_coam.get_bts_id
#    Run keyword If    '${SNSSAI}'=='true'
#    ...    Set suite Variable    ${xgUplane_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1    ELSE
#    ...    Set suite Variable    ${xgUplane_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
#    ${xgUplane_address_value}=    selenium_coam.get_parameter_value    dist_name=${xgUplane_distname}
#    ...    filter_param=${filter_param_DN}    abbr=${xgU_addr}
#    ${xgUplane_address}=    selenium_coam.get_parameter_value    dist_name=${xgUplane_address_value}
#    ...    filter_param=${filter_param_local}    abbr=localIpAddr
#    selenium_coam.logout
#    selenium_coam.disable_virtual_display
#    [Return]    ${xgUplane_address}
#
#Check wireshark log for 3CC
#    [Arguments]    ${logname}    ${scell1_index}=${1}    ${scell2_index}=${11}    ${scell_gnb_index}=${0}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == 2
#    ...    ${xpath_filter}=.//nr-rrc.physCellId
#    ${scell_list}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter}
#    ${pci_cclist}    Create List
#    ${scell1_PCI}=    get required cell info   required_info=physicalCellId
#    ...    cell_index=${scell1_index}   gnb_index=${scell_gnb_index}
#    ${scell1_PCI}=    Convert To String    ${scell1_PCI}
#    ${scell2_PCI}=    get required cell info   required_info=physicalCellId
#    ...    cell_index=${scell2_index}   gnb_index=${scell_gnb_index}
#    ${scell2_PCI}=    Convert To String    ${scell2_PCI}
#    Append to list    ${pci_cclist}    ${scell1_PCI}    ${scell2_PCI}
#    List should Contain Sub List    ${scell_list}    ${pci_cclist}
#
#Check wireshark log for 2CC
#    [Arguments]    ${logname}    ${scell_index}=${1}    ${scell_gnb_index}=${0}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == 1
#    ...    ${xpath_filter}=.//nr-rrc.physCellId
#    ${scell}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter}
#    ${scell_PCI}=    get required cell info   required_info=physicalCellId
#    ...    cell_index=${scell_index}   gnb_index=${scell_gnb_index}
#    ${scell_PCI}=    Convert To String    ${scell_PCI}
#    should be equal    ${scell[0]}    ${scell_PCI}
#
#Lock Unlock cell1&cell11
#    cell lock unlock for gnbBts    cell_idx=${1}    cell_group_idx=${1}
#    ...    para_lock=${PARAMETERS_TO_UPDATE_AB_B2_LOCKG1}    para_unlock=${PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG1}
#    cell lock unlock for gnbBts    cell_idx=${11}    cell_group_idx=${11}
#    ...    para_lock=${PARAMETERS_TO_UPDATE_AB_B2_LOCKG2}    para_unlock=${PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG2}
#
#cell lock unlock for gnbBts
#    [Arguments]    ${para_lock}    ${para_unlock}    ${cell_idx}    ${cell_group_idx}
#    Modify NIDD parameter online    parameters_to_update=${para_lock}
#    Connect to gnb coam via ssl
#    Wait Until Keyword Succeeds    180 sec    30 sec    Cell Should Be Locked
#    ...    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
#    Modify NIDD parameter online    parameters_to_update=${para_unlock}
#    Connect to gnb coam via ssl
#    Wait Until Keyword Succeeds    5 min    30 sec     Cell Should Be Unlocked
#    ...    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
#    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
#
#Modify NIDD parameter online
#    [Arguments]    ${parameters_to_update}
#    Connect to gnb coam via ssl
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
#    ...    timeout=300
#    sleep    5
#    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
#
#RU reset and check scell re-addition
#    [Arguments]    ${nglogname}    ${gNB_index}=${0}
#    Perform RU Reset    ru_index=${1}    download_dir=${epc_log_path}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_7736}
#    sleep    5s
#    Start capture gNB log on master    filename=${nglogname}    gNB_index=${gNB_index}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
#    sleep    5s
#    Stop and download the Logs    filename=${nglogname}    gNB_index=${gNB_index}
#    Check wireshark log for 3CC    logname=${nglogname}
#    [Teardown]    Stop and download the Logs    filename=${nglogname}    gNB_index=${gNB_index}
#
