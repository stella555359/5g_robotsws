# #*** Settings ***
# #Resource    ./../Resources/CB008140_common_keywords.robot
# #Variables    ./Resources/CB008140_A_variables_2gnb.py
# #
# #Documentation
# #...   author: xiaodan.li
# #...   contact: xiaodan.li@nokia-sbell.com
# #...   squad group: SG_03
# #...   Feature CB008140-AC
# #
# #Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
# #...               Common Case TestLine Setup    Is_Swconfig=True    Is_Swconfig_for_GNB2=True
# #...               is_commission=True    is_commission_for_second_gnb=True
# #...               swconfig_file=${swconfig}    swconfig_file_gnb2=${swconfig}
# #...               golden_scf_name=${golden_scf_name}    golden_scf_name_gnb2=${golden_scf_name_gnb2}    AND
# #...               Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air
# #
# #Suite Teardown    Run Keywords
# #...               robot_common_operations.Common Suite Teardown    AND
# #...               Run Keyword And Ignore Error    Common Case TestLine Setup    Is_Swconfig=True    Is_Swconfig_for_GNB2=True
# #...               swconfig_file=${swconfig_restore}    swconfig_file_gnb2=${swconfig_restore}    AND
# #...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# #...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# #
# #
# #*** Variables ***
# #${golden_scf_name}    Configuration_scf_GNB1_CB008140.xml
# #${golden_scf_name_gnb2}    Configuration_scf_GNB2_CB008140.xml
# #${filename1_gnb1_001}    log1_name_AC_001_gNB1.pcap
# #${filename1_gnb2_001}    log1_name_AC_001_gNB2.pcap
# #${filename1_gnb1_003}    log1_name_AC_003_gNB1.pcap
# #${filename1_gnb2_003}    log1_name_AC_003_gNB2.pcap
# #${filename1_gnb1_005}    log1_name_AC_005_gNB1.pcap
# #${filename1_gnb2_005}    log1_name_AC_005_gNB2.pcap
# #${filename1_gnb1_007}    log1_name_AC_007_gNB1.pcap
# #${filename1_gnb2_007}    log1_name_AC_007_gNB2.pcap
# #${PMfile_gnb1}    8140_AC_007_counter_gnb1.xml
# #${PMfile_gnb2}    8140_AC_007_counter_gnb2.xml
# #${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
# #${swconfig}    /opt/workspace/swconfig/swconfig_TA.txt
# #${swconfig_restore}    /opt/workspace/swconfig/swconfig_restore.txt
# #@{counter_gnb1_M55118C05507}    ${1}
# #@{expected_value_001_gnb1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}
# #@{expected_value_001_gnb2}    ${1}    ${1}
# #@{expected_value_003_gnb2}    ${1}
# #@{cell_id_007_gnb1}    ${2}    ${2}    ${2}
# #@{cell_id_007_gnb2}    ${1}    ${1}
# #@{expected_value_007_gnb1}    1    1    1
# #@{expected_value_007_gnb2}    ${1}    ${1}
# #${Send_Tput_DL_F_T}    1800M
# #${expected_tput_dl_T_100MHz}    0
# #${expected_tput_dl_F_15MHz}    250
# #
# #*** Test Cases ***
# ##[1]CB008140-5G-AC_001_Blind_Ignb_CA_Scell_addition_for_2CC_Suc_F_4D2U_15Mhz_F_2D2U_10Mhz
# ##    [Documentation]    This user scenario describes the success Blind scell addition procedure with FDD + FDD 2CC
# ##    ...                Inter-gNB Carrier Aggregation
# ##
# ##    [Tags]     classical    CRT_TRUNK
# ##    [Timeout]    1 hour
# ##    [Setup]    robot_common_operations.Common Case Setup
# ##    Prepare UE and detach UE
# ##    Add NRREL online    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_MODIFY_GNB1_AC001}
# ##    Reset the gnb1 and gnb2 and wait them on air
# ##    Get cell id 2gnb    lcrid=${1}    lcrid_gnb2=${1}
# ##    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${1}
# ##    set suite variable    ${pci_scell}
# ##    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}
# ##    Record the counter action timer
# ##    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_001}
# ##    ...    gnb2_filename=${filename1_gnb2_001}
# ##    Attach and check power UE    ue_type=${ue_type}
# ##    sleep    3s
# ##    power_ue.UE Detach  ue_type=${ue_type}
# ##    sleep    5s
# ##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_001}    gnb2_filename=${filename1_gnb2_001}
# ##
# ##    comment    check the counter
# ##    Wait until keyword succeeds    10 min    20s   Check counter for AC001
# ##    comment    check the wireshark log
# ##    Check attach and detach wireshark log    logname=${filename1_gnb1_001}    logname1=${filename1_gnb2_001}
# ##    Hanging resource test
# ##    [Teardown]    run keywords
# ##    ...    robot_common_operations.Common Case Teardown    AND
# ##    ...    Run Keyword And Ignore Error
# ##    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}    AND
# ##    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# #[1]CB008140-5G-AC_003_Blind_Ignb_CA_Scell_addition_for_2CC_Suc_F_2D2U_10Mhz_T_2D2U_100Mhz
# #    [Documentation]    This user scenario describes the success Blind scell addition procedure with FDD 10Mhz
# #    ...                2DL2UL + TDD 100Mhz 2DL2UL 2CC Inter-gNB Carrier Aggregation
# #
# #    [Tags]     classical    CRT_TRUNK
# #    [Timeout]    2 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Prepare UE and detach UE
# #    Add NRREL online    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_MODIFY_GNB1_AC003}
# #    Common Case TestLine Setup    ModifySCF_Aftercommission=True    ModifySCF_Aftercommission_for_GNB2=True
# #    ...    Modify_Para_Online=${PARAMETERS_MODIFY_GNB1_AC003}    Modify_Para_Online_GNB2=${PARAMETERS_MODIFY_GNB2_AC003}
# #    Check the gnb1 and gnb2 ready
# #    Reset the gnb1 and gnb2 and wait them ready
# #    Get cell id 2gnb    lcrid=${1}    lcrid_gnb2=${2}
# #    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${2}
# #    set suite variable    ${pci_scell}
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb2_cell2_value=${50}
# #    Record the counter action timer
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_003}    gnb2_filename=${filename1_gnb2_003}
# #    Attach and check power UE    ue_type=${ue_type}
# #    sleep    3s
# #    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL_F_T}    dl_length=1400B
# #    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F_15MHz}    tput_dl_scell=${expected_tput_dl_T_100MHz}
# #    ...    tput_ul_pcell=NULL    scellid=2    pcellid=1
# #    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    sleep    5s
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_003}    gnb2_filename=${filename1_gnb2_003}
# #
# #    comment    check the counter
# #    Wait until keyword succeeds    10 min    20s   Check counter for AC003
# #    comment    check the wireshark log
# #    Check attach and detach wireshark log    logname=${filename1_gnb1_003}    logname1=${filename1_gnb2_003}
# #    Hanging resource test
# #    [Teardown]    run keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error    Common Case TestLine Setup
# #    ...    ModifySCF_Aftercommission_for_GNB2=True    Modify_Para_Online_GNB2=${PARAMETERS_TO_RESTORE_GNB2_AC003}    AND
# #    ...    Run Keyword And Ignore Error
# #    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}    AND
# #    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# ##[1]CB008140-5G-AC_005_Blind_Ignb_CA_Scell_addition_for_2CC_Suc_T_4D2U_100Mhz_F_2D2U_10Mhz
# ##    [Documentation]    This user scenario describes the success Blind scell addition procedure with TDD 100Mhz
# ##    ...                4DL2UL + FDD 10Mhz 2DL2UL 2CC Inter-gNB Carrier Aggregation
# ##    [Tags]     classical    CRT_TRUNK
# ##    [Timeout]    1 hour
# ##    [Setup]    robot_common_operations.Common Case Setup
# ##    Prepare UE and detach UE
# ##    Add NRREL online    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_MODIFY_GNB1_AC005}
# ##    GNB Cell Lock Or Unlock And Check Status    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB1_CELL31_LOCK}
# ##    ...    is_locked=True    gnb_index=${0}    cell_idx=${31}    cell_group_idx=${31}
# ##    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
# ##    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
# ##    Wait Until Keyword Succeeds    10 min    20 sec    Cell Should Be Lock or Unlock
# ##    ...    is_locked=True    gnb_index=${0}    cell_idx=${31}    cell_group_idx=${31}
# ##    wait until keyword succeeds    10 min    20 sec    Check the cells status on air
# ##    ...                   bts_host=${bts_host1}    connection=gnb1
# ##    Get cell id 2gnb    lcrid=${3}    lcrid_gnb2=${1}
# ##    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${1}
# ##    set suite variable    ${pci_scell}
# ##    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
# ##    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_005}
# ##    ...    gnb2_filename=${filename1_gnb2_005}
# ##    Attach and check power UE    ue_type=${ue_type}
# ##    sleep    3s
# ##    power_ue.UE Detach  ue_type=${ue_type}
# ##    sleep    5s
# ##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_005}    gnb2_filename=${filename1_gnb2_005}
# ##
# ##    comment    check the wireshark log
# ##    Check attach and detach wireshark log    logname=${filename1_gnb1_005}    logname1=${filename1_gnb2_005}
# ##    Hanging resource test
# ##    [Teardown]    run keywords
# ##    ...    robot_common_operations.Common Case Teardown    AND
# ##    ...    Run Keyword And Ignore Error    GNB Cell Lock Or Unlock And Check Status
# ##    ...    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB1_CELL31_UNLOCK}    is_locked=False    gnb_index=${0}
# ##    ...    cell_idx=${31}    cell_group_idx=${31}    AND
# ##    ...    Run Keyword And Ignore Error
# ##    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1_CELL3}    AND
# ##    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# ##[1]CB008140-5G-AC_007_Blind_Ignb_CA_Scell_addition_for_2CC_Suc_T_BF_1116_0_4D2U_40Mhz_T_BF_1208_2D2U_100Mhz
# ##    [Documentation]    This user scenario describes the success Blind scell addition procedure with TDD 40Mhz 4DL2UL and
# ##    ...                beforming enabled with frame structure 1116_3ms + TDD 100Mhz 2DL2UL beamforming enabled with frame
# ##    ...                struture 1208 2CC Inter-gNB Carrier Aggregation
# ##    [Tags]     classical    CRT_TRUNK
# ##    [Timeout]    2 hour
# ##    [Setup]    robot_common_operations.Common Case Setup
# ##    Prepare UE and detach UE
# ##    Add NRREL online    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_MODIFY_GNB1_AC007}
# ##    GNB Cell Lock Or Unlock And Check Status    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB1_CELL3_LOCK}
# ##    ...    is_locked=True    gnb_index=${0}    cell_idx=${3}    cell_group_idx=${2}
# ##    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
# ##    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
# ##    Wait Until Keyword Succeeds    10 min    20 sec    Cell Should Be Lock or Unlock
# ##    ...    is_locked=True    gnb_index=${0}    cell_idx=${3}    cell_group_idx=${2}
# ##    wait until keyword succeeds    10 min    20 sec    Check the cells status on air
# ##    ...                   bts_host=${bts_host1}    connection=gnb1
# ##    Get cell id 2gnb    lcrid=${31}    lcrid_gnb2=${2}
# ##    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${2}
# ##    set suite variable    ${pci_scell}
# ##    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
# ##    Record the counter action timer
# ##    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_007}
# ##    ...    gnb2_filename=${filename1_gnb2_007}
# ##    Attach and check power UE    ue_type=${ue_type}
# ##    sleep    3s
# ##    power_ue.UE Detach  ue_type=${ue_type}
# ##    sleep    5s
# ##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_007}    gnb2_filename=${filename1_gnb2_007}
# ##
# ##    comment    check the counter
# ##    Wait until keyword succeeds    10 min    20s   Check counter for AC007
# ##    comment    check the wireshark log
# ##    Check attach and detach wireshark log    logname=${filename1_gnb1_007}    logname1=${filename1_gnb2_007}
# ##    Hanging resource test
# ##    [Teardown]    run keywords
# ##    ...    robot_common_operations.Common Case Teardown    AND
# ##    ...    Run Keyword And Ignore Error    GNB Cell Lock Or Unlock And Check Status
# ##    ...    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB1_CELL3_UNLOCK}    is_locked=False    gnb_index=${0}    AND
# ##    ...    Run Keyword And Ignore Error
# ##    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1_CELL31}    AND
# ##    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# #*** Keywords ***
# #Check counter for AC001
# #    Check the PM counter should be greater than 1
# #    ...    gnb_index=${0}    counter_id=${counter_id_AC001_gNB1_M55118C05507}
# #    ...    dic_path=${counter_dic_path_AC001_gNB1_M55118C05507}    value=${counter_gnb1_M55118C05507}
# #    Check the PM counter should be value
# #    ...    gnb_index=${0}    counter_id=${counter_id_AC001_gNB1}    dic_path=${counter_dic_path_AC001_gNB1}
# #    ...    value=${expected_value_001_gnb1}
# #    Check the PM counter should be value
# #    ...    gnb_index=${1}    counter_id=${counter_id_AC001_gNB2}    dic_path=${counter_dic_path_AC001_gNB2}
# #    ...    value=${expected_value_001_gnb2}
# #
# #Check counter for AC003
# #    Check the PM counter should be value
# #    ...    gnb_index=${1}    counter_id=${counter_id_AC003_gNB2}    dic_path=${counter_dic_path_AC003_gNB2}
# #    ...    value=${expected_value_003_gnb2}
# #
# #Check counter for AC007
# #    Check the PM counter xml report    PMfile_name=${PMfile_gnb1}
# #    ...    PM_counter=${counter_xml_AC007_gNB1}    value=${expected_value_007_gnb1}
# #    ...    counter_index=${cell_id_007_gnb1}    gnb_index=${0}
# #    Check the PM counter should be value
# #    ...    gnb_index=${1}    counter_id=${counter_id_AC007_gNB2}    dic_path=${counter_dic_path_AC007_gNB2}
# #    ...    value=${expected_value_007_gnb2}
# #
# #
# #
