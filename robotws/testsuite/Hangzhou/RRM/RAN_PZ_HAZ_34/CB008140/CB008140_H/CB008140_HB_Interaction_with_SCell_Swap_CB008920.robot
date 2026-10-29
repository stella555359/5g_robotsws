#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_H_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-HB
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Common Case TestLine Setup for HB    AND
#...               Adjust gNB_RU Attenuation    AND
#...               Get sagnb release
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM    gnb_list=${gnb_list_HB}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${filename_HB001_gnb0}    log_name_HB_001_gNB1.pcap
#${filename_HB001_gnb3}    log_name_HB_001_gNB4.pcap
#${filename_HB002_gnb0}    log_name_HB_002_gNB1.pcap
#${filename_HB002_gnb3}    log_name_HB_002_gNB4.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{gnb_ips_HB}    ${bts_host0}    ${bts_host3}
#@{gnb_list_HB}    ${0}    ${3}
#@{scell_index_list_HB002}    ${11}
#@{extgnb_index_list_HB002}    ${0}
#@{scell_index_list_HB001}    ${1}
#@{extgnb_index_list_HB001}    ${3}
#@{expected_value_HB002_gnb4}    ${0}    ${0}
#@{filename_HB001}    filename_HB001_gnb
#@{filename_HB002}    filename_HB002_gnb    filename1_HB002_gnb
#
#*** Test Cases ***
#[1]CB008140-HB_001_CA_setup_without_event_A6_for_SCell_swap_activation_when_the_configured_SCells_are_in_a_different_gNB
#    [Documentation]    This user scenario describes the not-activation of the event A6 measurement on a UE configured with ext-SCell.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    MultiUE.Prepare UE
#    Start capture multi gNB log    filename=filename_HB001_gnb    gnb_list=${gnb_list_HB}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Detach
#    Stop capture multi gNB log    filename=filename_HB001_gnb    gnb_list=${gnb_list_HB}
#    comment    check the wireshark log
#    Check wireshark log for HB001   logname=${filename_HB001_gnb0}    logname1=${filename_HB001_gnb3}
#    Hanging resource test    gnb_ips=@{gnb_ips_HB}    gnb_list=@{gnb_list_HB}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_HB001}    gnb_list=${gnb_list_HB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#
#[1]CB008140-HB_002_CA_setup_without_SCell_swap_when_the_UE_reports_a_candidate_SCell_belonging_to_a_different_gNB_than_the_configured_SCell_to_swap
#    [Documentation]    This user scenario describes the not-execution of the SCell swap, when the UE sends the event A6
#    ...    measurement report with measurement results for a candidate SCell which belongs to a different gNB than the
#    ...    configured SCell to swap
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_HB001}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    MultiUE.Prepare UE
#    Prepare to caculate PM counter    period=start
#    Start capture multi gNB log    filename=filename_HB002_gnb    gnb_list=${gnb_list_HB}
#    MultiUE.Attach
#    sleep    5s
#    #### triger scell scell1 A6 swap monitor, and triger swap scell2 to reaching scell1's A6 threshold
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${40}    gnb4_cell1_value=${20}
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_HB002_gnb    gnb_list=${gnb_list_HB}
#    MultiUE.Detach
#    Prepare to caculate PM counter    period=end
#    Check counter for HB002
#    comment    check the wireshark log
#    Check wireshark log for HB002   logname=${filename_HB002_gnb0}
#    Hanging resource test    gnb_ips=@{gnb_ips_HB}    gnb_list=@{gnb_list_HB}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_HB002}    gnb_list=${gnb_list_HB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#
#*** Keywords ***
#Common Case TestLine Setup for HB
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_HB}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_HB}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_HB}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB1_HB}    ListToAdd=${LIST_TO_ADD_GNB1}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_HB}    ListToAdd=${LIST_TO_ADD_GNB4}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_HB}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_HB}
#
#Check wireshark log for HB001
#    [Arguments]    ${logname}    ${logname1}
#    Check attach wireshark log    logname=${logname}    logname1=${logname1}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_HB001}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_HB001}
#    ...    UEContextModificationResponse_nums=${2}
#    Check RRC Reconfiguratuon message with eventId    logname=${logname}    eventId=5    event_result=no
#
#Check wireshark log for HB002
#    [Arguments]    ${logname}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_HB002}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_HB002}
#    Check RRC Reconfiguratuon message with eventId    logname=${logname}    eventId=5
#    Check Measurement message on PrimegNB    logname=${logname}    cell_index=${1}    gnb_index=${3}
#    ...    event_id=5    meas_lengths=${4}
#
#Check counter for HB002
#    sleep    40s
#    Run keyword if    '${release_info}' == '@{branch}[0]'    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_HB002_gNB4}    dic_path=${counter_dic_path_HB002_gNB4_Trunk}
#    ...    value=${expected_value_HB002_gnb4}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_HB002_gNB4}    dic_path=${counter_dic_path_HB002_gNB4}
#    ...    value=${expected_value_HB002_gnb4}
