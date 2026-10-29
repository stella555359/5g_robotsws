#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_G_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-GF
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM   gnb_list=${gnb_list_GF}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${golden_scf_name_005_gnb0}    Configuration_scf_GNB1_CB008140_GF_005.xml
#${golden_scf_name_005_gnb3}    Configuration_scf_GNB4_CB008140_GF_005.xml
#${filename_003_gnb0}    log_name_GF_003_gNB1.pcap
#${filename_003_gnb3}    log_name_GF_003_gNB4.pcap
#${filename1_003_gnb0}    log1_name_GF_003_gNB1.pcap
#${filename1_003_gnb3}    log1_name_GF_003_gNB4.pcap
#${filename2_003_gnb0}    log2_name_GF_003_gNB1.pcap
#${filename2_003_gnb3}    log2_name_GF_003_gNB4.pcap
#${filename3_003_gnb0}    log3_name_GF_003_gNB1.pcap
#${filename3_003_gnb3}    log3_name_GF_003_gNB4.pcap
#${filename_005_gnb0}    log_name_GF_005_gNB1.pcap
#${filename_005_gnb3}    log1_name_GF_005_gNB4.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${swconfig}    /opt/workspace/swconfig/swconfig_TA.txt
#${swconfig_restore}    /opt/workspace/swconfig/swconfig_restore.txt
#@{gnb_ips_GF}    ${bts_host0}    ${bts_host3}
#@{scell_index_list_GF005}    ${11}
#@{extgnb_index_list_GF005}    ${0}
#@{filename_GF003}    filename_003_gnb    filename1_003_gnb    filename2_003_gnb
#@{filename_GF005}    filename_005_gnb
#@{gnb_list_GF}    ${0}    ${3}
#
#*** Test Cases ***
#[1]CB008140-5G-GF_003_Common_Preconditions_on_BC_and_BCS_check_for_IgNB-CA_addition
#    [Documentation]    This user scenario describes the band combination and bandwidth combination set check
#    ...     for IgNB-CA addition.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for GF003
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    ###    1、	Prime-gNB actBcsCheck=disabled
#    Online modify and attach detach UE    filename=filename_003_gnb
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_1}
#    ####    2、	Prime-gNB actBcsCheck=enabled_FR1
#    Online modify and attach detach UE    filename=filename1_003_gnb
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_2}
#    ####    3、	Prime-gNB actBcsCheck=enabled_FR1
#    Online modify and attach detach UE    filename=filename2_003_gnb
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_3}
#    ####    4、	Prime-gNB actBcsCheck=enabled_FR1
#    Online modify and attach detach UE    filename=filename3_003_gnb
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_4}
#    comment    check the wireshark log
#    Check wireshark log for GF003
#    Hanging resource test    gnb_ips=@{gnb_ips_GF}    gnb_list=@{gnb_list_GF}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_GF003}    gnb_list=${gnb_list_GF}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#
#[1]CB008140-5G-GF_005_BC_and_BCS_check_for_IgNB-CA_addition_mixed_intra-band_contiguous_and_non-contiguous
#    [Documentation]    This user scenario describes the band combination and bandwidth combination
#    ...    set check for IgNB-CA addition.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for GF005
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb4_cell1_value=${0}
#    Start capture multi gNB log    filename=filename_005_gnb    gnb_list=${gnb_list_GF}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Detach
#    Stop capture multi gNB log    filename=filename_005_gnb    gnb_list=${gnb_list_GF}
#    Check wireshark log for GF005
#    Hanging resource test    gnb_ips=@{gnb_ips_GF}    gnb_list=@{gnb_list_GF}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_GF003}    gnb_list=${gnb_list_GF}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for GF003
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_GF003}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GF003}    ListToAdd=${LIST_TO_ADD_GNB1_GF003}
#    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_GF003}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_GF003}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_GF}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GF}
#
#Common Case TestLine Setup for GF005
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GF005}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}     MOsToAdd=${MOS_ADD_GNB4_GF005}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_GF005}    ListToAdd=${LIST_TO_ADD_GNB4_GF005}
#    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB4_GF005}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_GF}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GF}
#
#Online modify and attach detach UE
#    [Arguments]    ${filename}    ${Modify_Para_Online}    ${gnb_index}=${0}
#    Online modify NIDD on gnb    gnb_index=${gnb_index}    Modify_Para_Online=${Modify_Para_Online}
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_GF}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Detach
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_GF}
#
#Check wireshark log for GF003
#    Check IgNBCAAdditionRequest message has no the BCS IE on PrimegNB    logname=${filename_003_gnb0}
#    Check IgNBCAUEContextSetupRequest message has no the BCS IE on extgNB    logname=${filename_003_gnb3}
#    Check IgNBCAAdditionRequest message has the BCS IE on PrimegNB    logname=${filename1_003_gnb0}
#    Check IgNBCAUEContextSetupRequest message has the BCS IE on extgNB    logname=${filename1_003_gnb3}
#    Check IgNBCAAdditionRequest message has no the BCS IE on PrimegNB    logname=${filename2_003_gnb0}
#    Check IgNBCAUEContextSetupRequest message has no the BCS IE on extgNB    logname=${filename2_003_gnb3}
#    Check IgNBCAAdditionRequest message has the BCS IE on PrimegNB    logname=${filename3_003_gnb0}
#    Check IgNBCAUEContextSetupRequest message has the BCS IE on extgNB    logname=${filename3_003_gnb3}
#
#Check wireshark log for GF005
#    ### check attach scell1-11
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${filename_005_gnb3}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_GF005}
#    ...    Primegnb_index=${3}    extgnb_index_list=${extgnb_index_list_GF005}
#    ...    UEContextModificationResponse_nums=${3}
#    Check IgNBCAAdditionRequest message has the BCS IE on PrimegNB    logname=${filename_005_gnb3}    rejectBcs=0
#    Check IgNBCAUEContextSetupRequest message has the BCS IE on extgNB    logname=${filename_005_gnb0}    rejectBcs=0