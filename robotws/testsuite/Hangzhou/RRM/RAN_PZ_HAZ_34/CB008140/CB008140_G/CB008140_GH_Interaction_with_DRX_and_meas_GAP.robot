#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_G_variables.py
#
#Documentation
#...   author: qingqing.zhang
#...   contact: qingqing.zhang@nokia-sbell.com xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-GH+CB008140-HI
#
#Suite Setup    Run Keywords
#...               robot_common_operations.Common Suite Setup
#...               AND    Common Suite Setup for COAM
#...               AND    Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               robot_common_operations.Common Suite Teardown    AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${scf_path}    /opt/workspace/SCF/
#${filename_003_attach_gnb0}    log_name_GH_003_gNB1_attach.pcap
#${filename1_003_HO_gnb0}    log_name1_GH_003_gNB1_source.pcap
#${filename1_003_HO_gnb2}    log_name1_GH_003_gNB3_target.pcap
#${filename2_003_HO_gnb0}    log_name2_GH_003_gNB1_target.pcap
#${filename2_003_HO_gnb2}    log_name2_GH_003_gNB3_source.pcap
#@{filename_GH003}    filename1_003_HO_gnb    filename2_003_HO_gnb
#${filename_006_attach_gnb0}    log_name_GH_006_gNB1_attach.pcap
#${filename_006_gnb0}    log_name_GH_006_gNB1_pcell_VONR.pcap
#${filename_006_gnb2}    log_name_GH_006_gNB3_scell_VONR.pcap
#${filename1_006_gnb0}    log_name_GH_006_gNB1_pcell_release_VONR.pcap
#${filename1_006_gnb2}    log_name_GH_006_gNB3_scell_release_VONR.pcap
#${filename_HI005_attach_gnb0}    log_name_HI_005_gNB1_attach.pcap
#${filename_HI005_gnb0}    log_name_HI_005_gNB1_pcell_VONR.pcap
#${filename_HI005_gnb2}    log_name_HI_005_gNB3_scell_VONR.pcap
#${filename1_HI005_gnb0}    log_name_HI_005_gNB1_pcell_release_VONR.pcap
#${filename1_HI005_gnb2}    log_name_HI_005_gNB3_scell_release_VONR.pcap
#${filename_0011_attach_gnb0}    log_name_GH_0011_gNB1_attach.pcap
#${filename_0011_intra_HO_gnb0}    log_name_GH_0011_gNB1_intra_HO_Pcell.pcap
#${filename_0011_intra_HO_gnb2}    log_name_GH_0011_gNB1_intra_HO_Scell.pcap
#@{filename_GH0011}    filename_0011_intra_HO_gnb
#${filename_0013_attach_gnb0}    log_name_GH_0013_gNB1_attach.pcap
#${filename_0013_A2_gnb0}    log_name_GH_0013_gNB1_A2.pcap
#${filename_0013_A1_gnb0}    log_name_GH_0013_gNB1_A1.pcap
#@{filename_GH0013}    filename_0013_A2_gnb    filename_0013_A1_gnb
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#
#${Send_Tput_DL_T_T}    2000
#${expected_tput_dl_T}    1100
#${expected_tput_dl_F}    390
#${ue_type}    ${tl.ues[0].capabilities[-1]}
#${OndurationTimer_defaut}    ${10}
#${OndurationTimer_VONR}    ${6}
#${drxLongCycle_default}    ms160
#@{DRX_ANR}    8    14    11
#@{DRX_default}    7    14    9
#@{DRX_VONR}    5    4    3
#${drxLongCycle_vonr}    ms40
#${OndurationTimer_defaut_HI005}    ${10}
#${OndurationTimer_VONR_HI005}    ${10}
#@{DRX_default_HI005}    7    3     3
#@{DRX_VONR_HI005}    7    3    1
#${drxLongCycle_default_HI005}    ms40
#${drxLongCycle_vonr_HI005}    ms20
#
#@{gnb_list}    ${0}    ${2}
#@{gnb_ips}    ${bts_host0}    ${bts_host2}
#@{gnb_list_GH0013}    ${0}
#@{scell_index_list_cell1}    ${1}
#@{extgnb_index_gnb1}    ${0}
#@{scell_index_list_cell31}    ${31}
#@{extgnb_index_gnb3}    ${2}
#
#${UEContextModificationResponse_nums_38711}    ${2}
#${UEContextModificationResponse_nums_38611}    ${2}
#
#@{branch}    SBTS23R3_ENB_0000    SBTS23R4_ENB_0000    SBTS24R1_ENB_0000    SBTS24R2_ENB_9999
#*** Test Cases ***
#[1]CB008140-5G-GH_003_Inter-gNB_Handover_over_NG_of_a_UE_connection_in_IgNB_CA_mode_inte_Freaquency
#    [Documentation]    This user scenario describes the inter-gNB handover over NG of a UE context in IgNB-CA mode.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup with NRREl for GH003
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    UE attach and collect log     filename=${filename_003_attach_gnb0}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200
#    ####trigger inter NGHO
#    Start capture multi gNB log    filename=filename1_003_HO_gnb    gnb_list=${gnb_list}
#    Sleep    2s
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}
#    Sleep    2s
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${30}    gnb3_cell2_value=${0}
#    Sleep    3s
#    Stop capture multi gNB log    filename=filename1_003_HO_gnb    gnb_list=${gnb_list}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell2_value=${0}
#    sleep    3s
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
#    ...    scellid=1    pcellid=2    gnb_prime=${2}    gnb_external=${0}    ue_type=${tl.ues[0].capabilities[0]}
#    Comment    check the wireshark log
#    Check wireshark log for GH003   logname=${filename1_003_HO_gnb0}    logname1=${filename1_003_HO_gnb2}
#    ###trigger inter NGHO
#    Start capture multi gNB log    filename=filename2_003_HO_gnb    gnb_list=${gnb_list}
#    Adjust gNB_RU Attenuation    gnb3_cell2_value=${20}    gnb1_cell1_value=${20}
#    sleep    3s
#    Adjust gNB_RU Attenuation    gnb3_cell2_value=${30}    gnb1_cell1_value=${0}
#    Sleep    3s
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell3_value=${5}
#    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell3_value=${32}
#    Sleep    3s
#    Stop capture multi gNB log    filename=filename2_003_HO_gnb    gnb_list=${gnb_list}
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_T}
#        ...    scellid=31    pcellid=1    gnb_prime=${0}    gnb_external=${2}    ue_type=${tl.ues[0].capabilities[0]}
#    Comment    check the wireshark log
#    Check wireshark log for GH003_02   logname=${filename2_003_HO_gnb0}    logname1=${filename2_003_HO_gnb2}
#    MultiUE.Stop DL Traffic
#    MultiUE.Detach
#    Run Keyword And Ignore Error    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case recover for GH003    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation    AND
#    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GH003}    gnb_list=${gnb_list}
#
#
#[1]CB008140-5G-GH_006_Scell_addition_after_DRX_setup_5QI1_and_5QI7
#    [Documentation]    This user scenario verifies the case that UE is configured with DRX while SCell addition is triggered.
#    ...    In this case, DRX configuration impacts SCell’s resource allocation procedure
#    ...    add [1] CB008140-5G-HI_005_DRX_state synchronization_for_UE configured_with_IGCA_VONR_drxLongCycle_20ms checkpoint
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup with NRREl for GH006
#    Attach and start-end vonr call and grab all log    filename_attach=${filename_006_attach_gnb0}
#    ...    filename_vonr=filename_006_gnb    filename_vonrend=filename1_006_gnb
#    Comment    ADD 8140-HI check point
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_HI}
#    Attach and start-end vonr call and grab all log    filename_attach=${filename_HI005_attach_gnb0}
#    ...    filename_vonr=filename_HI005_gnb   filename_vonrend=filename1_HI005_gnb
#    Comment    check the wireshark log with GH006
#    Check wireshark log for GH006   logname=${filename_006_attach_gnb0}   logname1=${filename_006_gnb0}
#    ...    logname2=${filename_006_gnb2}    logname3=${filename1_006_gnb0}
#    Comment    check the wireshark log with HI005
#    Check wireshark log for GH006   logname=${filename_HI005_attach_gnb0}    logname1=${filename_HI005_gnb0}
#    ...    logname2=${filename_HI005_gnb2}    logname3=${filename1_HI005_gnb0}
#    ...    DRX_default=${DRX_default_HI005}    OndurationTimer_defaut=${OndurationTimer_defaut_HI005}
#    ...    DRX_VONR=${DRX_VONR_HI005}    OndurationTimer_VONR=${OndurationTimer_VONR_HI005}
#    ...    drxLongCycle_default=${drxLongCycle_default_HI005}    drxLongCycle_vonr=${drxLongCycle_vonr_HI005}
#    ...    cycle_attach=40    cycle_VONR=20
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
#    [Teardown]    run keywords
#    ...    MultiUE.Detach    AND
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation    AND
#    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GH006}    gnb_list=${gnb_list}
#
#[1]CB008140-5G-GH_011_ANR_specific_DRX_profile_configuration
#    [Documentation]    This user scenario verifies the case that ANR specific DRX setup is triggered after SCell addition,
#     ...    ANR specific DRX profile should be applied to all serving cells
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup with NRREl for GH0011
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename_0011_attach_gnb0}
#    ###trigger ANR###
#    Start capture multi gNB log    filename=filename_0011_intra_HO_gnb    gnb_list=${gnb_list}
#    Run keyword if    '${gnb_instance0}' == '@{gnb_id}[2]'
#    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${20}
#    ...    ELSE    Run keywords    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb1_cell2_value=${20}
#    ...    AND     sleep    2s
#    ...    AND    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb1_cell2_value=${35}
#    Sleep    5s
#    Stop capture multi gNB log    filename=filename_0011_intra_HO_gnb    gnb_list=${gnb_list}
#    Check wireshark log for GH0011    logname1=${filename_0011_attach_gnb0}    logname2=${filename_0011_intra_HO_gnb0}
#    ...    logname3=${filename_0011_intra_HO_gnb2}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
#    [Teardown]    run keywords
#    ...    MultiUE.Detach    AND
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation    AND
#    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GH0011}    gnb_list=${gnb_list}
#
#[1]CB008140-5G-GH_013_MG_release_after_Scell_addition
#    [Documentation]    This user scenario verifies the case that MG setup is triggered after SCell addition, MG
#    ...    configuration should be applied to all serving cells
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup with NRREl for GH0013
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    UE attach and collect log    filename=${filename_0013_attach_gnb0}
#    ###trigger A2###
#    Start capture gNB log on master    filename=${filename_0013_A2_gnb0}   gNB_index=${0}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${30}
#    Sleep    5s
#    Stop and download the Logs    filename=${filename_0013_A2_gnb0}     gNB_index=${0}
#     ###trigger A1###
#    Start capture gNB log on master    filename=${filename_0013_A1_gnb0}   gNB_index=${0}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Sleep    5s
#    Stop and download the Logs    filename=${filename_0013_A1_gnb0}     gNB_index=${0}
#    Check wireshark log for GH0013    logname1=${filename_0013_attach_gnb0}    logname2=${filename_0013_A2_gnb0}
#    ...    logname3=${filename_0013_A1_gnb0}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation    AND
#    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GH0013}    gnb_list=${gnb_list_GH0013}
#
#*** Keywords ***
#Common Case TestLine Setup with NRREl for GH003
#    @{scf_list}    Create List
#    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_GH003}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GH003}    ListToAdd=${LIST_TO_ADD_GNB1_GH003}
#    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}     MOsToAdd=${MOS_ADD_GNB3_GH003}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_GH003}    ListToAdd=${LIST_TO_ADD_GNB3_GH003}
#    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb2}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    ##NG inter Frequency HO Preparation###
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH003_inter_HO}
#    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_GH003_inter_HO}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB3_GH003_inter_HO}
#
#Case recover for GH003
#        Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_recover_GNB3_GH003}
#
#Common Case TestLine Setup with NRREl for GH006
#    @{scf_list}    Create List
#    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_GH006}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GH006}    ListToAdd=${LIST_TO_ADD_GNB1_GH006}
#    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParameterToDelete=${Parameter_Delete_GNB3_GH006}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_GH006}    ListToAdd=${LIST_TO_ADD_GNB3_GH006}
#    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb2}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    #DRX Preparation###
#    ${release_info}    Get sagnb release
#    Run keyword if    '${release_info}' == '@{branch}[0]' or '${release_info}' == '@{branch}[1]'
#    ...    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_GH006_DRX}    ELSE
#    ...    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX}
#    ...    Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_GH006_DRX_trunk}
#
#Common Case TestLine Setup with NRREl for GH0011
#    @{scf_list}    Create List
#    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_GH0011}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GH0011}    ListToAdd=${LIST_TO_ADD_GNB1_GH0011}
#    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_path}${golden_scf_name_gnb2}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    ##add ANR configuration###
#    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_ONLINE_ADD_MO_GNB1_GH0011}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GH0011}    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_GH0011}
#
#Common Case TestLine Setup with NRREl for GH0013
#    @{scf_list}    Create List
#    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_GH0011}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GH0013}    ListToAdd=${LIST_TO_ADD_GNB1_GH0011}
#    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_path}${golden_scf_name_gnb2}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_ONLINE_ADD_MO_GNB1_GH0013}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GH0013}    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_GH0013}
#
#
#UE detech and collect log
#    [Arguments]    ${ue_index}    ${filename}    ${gNB_index}=${0}
#    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
#    power_ue.UE Detach
#    ...   ue_type=${tl.ues[1].capabilities[-1]}    ue_index=${ue_index}    power_reset=True
#    sleep    10s
#    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
#
#UE attach and collect log
#    [Arguments]     ${filename}    ${gNB_index}=${0}
#    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
#    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
#
#Check wireshark log for GH003
#    [Arguments]    ${logname}    ${logname1}
#    Check intergNB NGHO process on source gNB    logname=${logname}
#    Check intergNB NGHO process on target gNB    logname=${logname1}
#    ###check target CA setup succuss
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_gnb1}
#    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums_${gnb_instance0}}
#    ###check source CA release
#    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}
#
#Check wireshark log for GH003_02
#    [Arguments]    ${logname}    ${logname1}
#    Check intergNB NGHO process on source gNB    logname=${logname1}
#    Check intergNB NGHO process on target gNB    logname=${logname}
#    ###check target CA setup succuss
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell31}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb3}
#    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums_${gnb_instance0}}
#    ###check source CA release
#    Check pscell and scell release wireshark log    logname=${logname1}    logname1=${logname}
#
#Check wireshark log for GH006
#    [Arguments]    ${logname}    ${logname1}    ${logname2}    ${logname3}    ${cycle_attach}=160    ${cycle_VONR}=40
#    ...    ${DRX_default}=${DRX_default}    ${OndurationTimer_defaut}=${OndurationTimer_defaut}
#    ...    ${DRX_VONR}=${DRX_VONR}    ${OndurationTimer_VONR}=${OndurationTimer_VONR}
#    ...    ${drxLongCycle_default}=${drxLongCycle_default}    ${drxLongCycle_vonr}=${drxLongCycle_vonr}
#    ###check DRX when attach
#    Check DRX enable on PrimegNB or Externgnb    logname=${logname}
#    ...    milliSeconds=${DRX_default[0]}    InactivityTimer=${DRX_default[1]}    StartOffset=${DRX_default[2]}
#    Check CSIRS and CSI-reporting in onduration in UEContextModificationResponse    logname=${logname}
#    ...    xpath2=.//nr-rrc.${drxLongCycle_default}    cycle=${cycle_attach}
##    Check 2200 enable with Scell when attach    logname=${logname}    xpath=.//nr-rrc.${drxLongCycle_default}
#    ###check DRX when make VONR in pcell
#    Check UEContextModificationRequest message has Drx release on PrimegNB    logname=${logname1}
#    Check IgNBCAModificationRequest message has Drx release on PrimegNB    logname=${logname1}
#    Check VONR DRX enable on PrimegNB    logname=${logname1}        milliSeconds2=@{DRX_default}[0]
#    ...    milliSeconds1=${DRX_VONR[0]}    InactivityTimer=${DRX_VONR[1]}    StartOffset=${DRX_VONR[2]}
#    Check CSIRS and CSI-reporting in onduration in UEContextModificationResponse    logname=${logname1}
#    ...    xpath2=.//nr-rrc.${drxLongCycle_vonr}    cycle=${cycle_VONR}
#    ###check DRX when make VONR in scell
#    Check DRX enable on PrimegNB or Externgnb    logname=${logname2}    milliSeconds=${DRX_VONR[0]}
#    ...    milliSeconds2=@{DRX_default}[0]   InactivityTimer=${DRX_VONR[1]}    StartOffset=${DRX_VONR[2]}
#    ###check DRX after VONR release in pcell
#    Check UEContextModificationRequest message has Drx release on PrimegNB    logname=${logname3}
#    Check IgNBCAModificationRequest message has Drx release on PrimegNB    logname=${logname3}
#    Check DRX recover as attach on PrimegNB    logname=${logname3}
#    ...    milliSeconds=${DRX_default[0]}    InactivityTimer=${DRX_default[1]}    StartOffset=${DRX_default[2]}
#
#Check wireshark log for GH0011
#    [Arguments]    ${logname1}    ${logname2}   ${logname3}
#    Check DRX enable on PrimegNB or Externgnb    logname=${logname1}
#    Check UEContextModificationRequest message has Drx release on PrimegNB    logname=${logname2}
#    Check IgNBCAModificationRequest message has Drx release on PrimegNB    logname=${logname2}
#    Check ANR DRX enable on PrimegNB    logname=${logname2}    milliSeconds=@{DRX_ANR}[0]
#    ...    InactivityTimer=@{DRX_ANR}[1]     StartOffset=@{DRX_ANR}[2]
#    Check DRX enable on PrimegNB or Externgnb    logname=${logname3}    milliSeconds=@{DRX_ANR}[0]
#    ...    InactivityTimer=@{DRX_ANR}[1]     StartOffset=@{DRX_ANR}[2]
#    Check intra-F intra-gNB HO procedure    logname=${logname2}    target_cell=${11}
#
#Check wireshark log for GH0013
#    [Arguments]    ${logname1}    ${logname2}    ${logname3}
#    Check DRX enable on PrimegNB or Externgnb    logname=${logname1}
#    Check UEContextModificationRequest message has Drx release on PrimegNB    logname=${logname2}
#    Check IgNBCAModificationRequest message has Drx release on PrimegNB    logname=${logname2}
#    Check DRX recover as attach on PrimegNB    logname=${logname3}
#
#Attach and start-end vonr call and grab all log
#    [Arguments]    ${filename_attach}    ${filename_vonr}
#    ...    ${filename_vonrend}    ${ue_index}=${ue_index_${gnb_instance0}}
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    UE attach and collect log    filename=${filename_attach}
#    ###trigger VONR
#    Start capture multi gNB log    filename=${filename_vonr}   gnb_list=${gnb_list}
#    spark.send AT command CPE     param=ATD006688;     ue_alias=UE_${ue_index}
#    Sleep    30s
#    Stop capture multi gNB log    filename=${filename_vonr}   gnb_list=${gnb_list}
#    Start capture multi gNB log    filename=${filename_vonrend}   gnb_list=${gnb_list}
#    Sleep    3s
#    wait until keyword succeeds    10 min    20s    spark.send AT command CPE     param=ATH     ue_alias=UE_${ue_index}
#    Sleep    10s
#    Stop capture multi gNB log    filename=${filename_vonrend}   gnb_list=${gnb_list}
#
