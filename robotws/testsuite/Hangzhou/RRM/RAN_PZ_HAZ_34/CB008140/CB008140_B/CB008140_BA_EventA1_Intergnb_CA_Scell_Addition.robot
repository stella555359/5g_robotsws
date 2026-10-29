# #*** Settings ***
# #Resource    ./../Resources/CB008140_common_keywords.robot
# #Variables    ./Resources/CB008140_B_variables.py
# #
# #Documentation
# #...   author: xiaodan.li
# #...   contact: xiaodan.li@nokia-sbell.com
# #...   squad group: SG_03
# #...   Feature CB008140-BA
# #
# #Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
# #...               Common Case TestLine Setup    Is_Swconfig=True    Is_Swconfig_for_GNB2=True
# #...               is_commission=True    is_commission_for_second_gnb=True
# #...               swconfig_file=${swconfig}    swconfig_file_gnb2=${swconfig}
# #...               golden_scf_name=${golden_scf_name}    golden_scf_name_gnb2=${golden_scf_name_gnb2}    AND
# #...               Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air    AND
# #...               Adjust gNB_RU Attenuation
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
# #${filename1_gnb1_002}    log1_name_BA_002_gNB1.pcap
# #${filename1_gnb2_002}    log1_name_BA_002_gNB2.pcap
# #${filename2_gnb1_002}    log2_name_BA_002_gNB1.pcap
# #${filename2_gnb2_002}    log2_name_BA_002_gNB2.pcap
# #${filename1_gnb1_005}    log1_name_BA_005_gNB1.pcap
# #${filename1_gnb2_005}    log1_name_BA_005_gNB2.pcap
# #${filename2_gnb1_005}    log2_name_BA_005_gNB1.pcap
# #${filename2_gnb2_005}    log2_name_BA_005_gNB2.pcap
# #${filename1_gnb1_011}    log1_name_BA_011_gNB1.pcap
# #${filename1_gnb2_011}    log1_name_BA_011_gNB2.pcap
# #${PMfile_gnb1}    8140_BA_002_counter_gnb1.xml
# #${PMfile_gnb2}    8140_BA_002_counter_gnb2.xml
# #
# #${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
# #${swconfig}    /opt/workspace/swconfig/swconfig_TA.txt
# #${swconfig_restore}    /opt/workspace/swconfig/swconfig_restore.txt
# #@{counter_gnb1_M55118C05507}    ${1}
# #@{cell_id_002_gnb1}    ${0}    ${0}
# #@{expected_xml_value_002_gnb1}    1    1
# #@{expected_value_002_gnb1}    ${1}    ${1}
# #@{expected_value_002_gnb2}    ${1}    ${1}    ${1}    ${1}
# #${Send_Tput_DL_T_F}    1000M
# #${Send_Tput_DL_F_F}    1000M
# #${expected_tput_dl_T_40MHz}    540
# #${expected_tput_dl_F_10MHz}    90
# #${expected_tput_dl_F_15MHz}    250
# #
# #
# #
# #*** Test Cases ***
# #[1]CB008140-5G-BA_002_EventA1_Intergnb_CA_Scell_addition_for_2CC_Suc_F_4D2U_15Mhz_F_2D2U_10Mhz_RSRP&RSRQ
# #    [Documentation]    This user scenario describes the successful event A1 measurement based inter-gNB CA SCell addition
# #    ...                for a SA UE context having one cell only in an external gNB as candidate SCell for CA, without
# #    ...                event A2 measurement for SCell release configuration.
# #    [Tags]     classical    CRT_TRUNK
# #    [Timeout]    2 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Prepare UE and detach UE
# #    Common Case TestLine Setup
# #    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_BA002}
# #    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_BA002}
# #    Add NRREL online    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_MODIFY_GNB1_BA002}
# #    Reset the gnb1 and gnb2 and wait them on air
# #    Get cell id 2gnb    lcrid=${1}    lcrid_gnb2=${1}
# #    ${pci_pcell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name}    gnb_index=${0}    cell_index=${1}
# #    set suite variable    ${pci_pcell}
# #    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${1}
# #    set suite variable    ${pci_scell}
# #    ###trigger with rsrp
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${40}
# #    Record the counter action timer
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_002}    gnb2_filename=${filename1_gnb2_002}
# #    Attach and check power UE    ue_type=${ue_type}
# #    sleep    3s
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb2_cell1_value=${20}
# #    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL_F_F}    dl_length=1400B
# #    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F_15MHz}    tput_dl_scell=${expected_tput_dl_F_10MHz}
# #    ...    tput_ul_pcell=NULL    scellid=1    pcellid=1
# #    power_ue.UE Detach    ue_type=${ue_type}
# #    sleep    5s
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_002}    gnb2_filename=${filename1_gnb2_002}
# #
# #    comment    check the counter
# #    Wait until keyword succeeds    10 min    20s   Check counter for BA002
# #    comment    check the wireshark log
# #    Check wireshark log for BA   logname=${filename1_gnb1_002}    logname1=${filename1_gnb2_002}    rsrp=110    rsrq=64
# #    Hanging resource test
# #    Stop UL DL data transfer
# #
# #    ###trigger with rsrq
# #    Common Case TestLine Setup
# #    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_BA002_1}
# #    Reset the gnb1 and gnb2 and wait them on air
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}
# #    Record the counter action timer
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename2_gnb1_002}    gnb2_filename=${filename2_gnb2_002}
# #    Attach and check power UE    ue_type=${ue_type}
# #    sleep    3s
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}    gnb2_cell1_value=${20}
# #    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL_F_F}    dl_length=1400B
# #    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F_15MHz}    tput_dl_scell=${expected_tput_dl_F_10MHz}
# #    ...    tput_ul_pcell=NULL    scellid=1    pcellid=1
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    sleep    5s
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename2_gnb1_002}    gnb2_filename=${filename2_gnb2_002}
# #
# #    comment    check the counter
# #    Wait until keyword succeeds    10 min    20s   Check counter for BA002
# #    comment    check the wireshark log
# #    Check wireshark log for BA   logname=${filename2_gnb1_002}    logname1=${filename2_gnb2_002}    rsrp=90    rsrq=70
# #    Hanging resource test
# #    Stop UL DL data transfer
# #
# #    [Teardown]    run keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error
# #    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}    AND
# #    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# #[1]CB008140-5G-BA_005_EventA1_Intergnb_CA_Scell_addition_for_2CC_Suc_T_2D2U_40Mhz_F_2D2U_10Mhz_rsrqCombined
# #    [Documentation]    This user scenario describes the successful event A1 measurement based inter-gNB CA SCell addition
# #    ...                for a SA UE context having one cell only in an external gNB as candidate SCell for CA, without event
# #    ...                A2 measurement for SCell release configuration.
# #
# #    [Tags]     classical    CRT_TRUNK
# #    [Timeout]    2 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Prepare UE and detach UE
# #    Common Case TestLine Setup
# #    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_BA005}
# #    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_BA005}
# #    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Add_Mo_Online=${PARAMETERS_TO_MODIFY_GNB1_BA005}
# #    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
# #    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
# #    Wait Until Keyword Succeeds    10 min    20 sec    Cell Should Be Lock or Unlock
# #    ...    is_locked=True    gnb_index=${0}    cell_idx=${3}    cell_group_idx=${2}
# #    wait until keyword succeeds    10 min    20 sec    Check the cells status on air    bts_host=${bts_host1}    connection=gnb1
# #    Get cell id 2gnb    lcrid=${31}    lcrid_gnb2=${1}
# #    ${pci_pcell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name}    gnb_index=${0}    cell_index=${31}
# #    set suite variable    ${pci_pcell}
# #    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${1}
# #    set suite variable    ${pci_scell}
# #    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_005}    gnb2_filename=${filename1_gnb2_005}
# #    Attach and check power UE    ue_type=${ue_type}
# #    sleep    3s
# #    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}    gnb2_cell1_value=${20}
# #    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL_T_F}    dl_length=1400B
# #    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_T_40MHz}    tput_dl_scell=${expected_tput_dl_F_10MHz}
# #    ...    tput_ul_pcell=NULL    scellid=1    pcellid=31
# #    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
# #    power_ue.UE Detach  ue_type=${ue_type}
# #    sleep    5s
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_005}    gnb2_filename=${filename1_gnb2_005}
# #    Hanging resource test
# #    ###adujst PA not trigger A1 ###
# #    Adjust gNB_RU Attenuation    gnb1_cell2_value=${45}
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename2_gnb1_005}    gnb2_filename=${filename2_gnb2_005}
# #    Attach and check power UE    ue_type=${ue_type}
# #    sleep    3s
# #    power_ue.UE Detach    ue_type=${ue_type}
# #    sleep    5s
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename2_gnb1_005}    gnb2_filename=${filename2_gnb2_005}
# #
# #    comment    check the wireshark log
# #    Check wireshark log for BA   logname=${filename1_gnb1_005}    logname1=${filename1_gnb2_005}    rsrq=64
# #    Check wireshark log for BA Not addition   logname=${filename2_gnb1_005}
# #    Hanging resource test
# #    [Teardown]    run keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error    GNB Cell Lock Or Unlock And Check Status
# #    ...    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB1_CELL3_UNLOCK}    is_locked=False    gnb_index=${0}    AND
# #    ...    Run Keyword And Ignore Error
# #    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1_CELl31}    AND
# #    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# #[1]CB008140-5G-BA_011_EventA1_Intergnb_CA_Scell_addition_for_2CC_UnSuc_F_2D2U_10Mhz_T_2D2U_40Mhz_modify_a1MeasSCellAddSsbRsrp
# #    [Documentation]    This user scenario describes the unsuccessful event A1 measurement based inter-gNB CA SCell
# #    ...                addition for a SA UE context having one cell only in an external gNB as candidate SCell for CA,
# #    ...                due to no suitable candidate SCell.
# #    [Tags]     classical    CRT_TRUNK
# #    [Timeout]    2 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Prepare UE and detach UE
# #    Common Case TestLine Setup
# #    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_BA011}
# #    Add NRREL online    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_MODIFY_GNB1_BA002}
# #    Reset the gnb1 and gnb2 and wait them on air
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_011}    gnb2_filename=${filename1_gnb2_011}
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${60}
# #    Attach and check power UE    ue_type=${ue_type}
# #    Common Case TestLine Setup
# #    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_BA011_1}
# #    Adjust gNB_RU Attenuation    gnb1_cell1_value=${25}
# #    sleep    10s
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_011}    gnb2_filename=${filename1_gnb2_011}
# #    Check wireshark log for BA011    logname=${filename1_gnb1_011}
# #    Hanging resource test
# #    [Teardown]    run keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error
# #    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}    AND
# #    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
# #
# #
# #*** Keywords ***
# #Check counter for BA002
# #    Check the PM counter should be greater than 1
# #    ...    gnb_index=${0}    counter_id=${counter_id_BA002_gNB1_M55118C05507}
# #    ...    dic_path=${counter_dic_path_BA002_gNB1_M55118C05507}    value=${counter_gnb1_M55118C05507}
# #    Check the PM counter should be value
# #    ...    gnb_index=${0}    counter_id=${counter_id_BA002_gNB1}    dic_path=${counter_dic_path_BA002_gNB1}
# #    ...    value=${expected_value_002_gnb1}
# #    Check the PM counter should be value
# #    ...    gnb_index=${1}    counter_id=${counter_id_BA002_gNB2}    dic_path=${counter_dic_path_BA002_gNB2}
# #    ...    value=${expected_value_002_gnb2}
# #
# #Check xml counter for BA002
# #    Check the PM counter xml report    PMfile_name=${PMfile_gnb1}
# #    ...    PM_counter=${counter_xml_BA002_gNB1}    value=${expected_xml_value_002_gnb1}
# #    ...    counter_index=${cell_id_002_gnb1}    gnb_index=${0}
# #
# #Check wireshark log for BA
# #    [Arguments]    ${logname}    ${logname1}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL    ${pci_id}=${pci_pcell}
# #    Check wireshark log for Measurement EventA1/A2    logname=${logname}    event=${event}
# #    ...    rsrp=${rsrp}    rsrq=${rsrq}    pci_id=${pci_id}
# #    Check IgNBCAAdditionRequest message has scellAdditionMethodIndicator    logname=${logname}    MethodIndicator=0
# #    Check attach and detach wireshark log    logname=${logname}    logname1=${logname1}
# #
# #Check wireshark log for BA Not addition
# #    [Arguments]    ${logname}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL
# #    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=${event}    rsrp=${rsrp}    rsrq=${rsrq}
# #    Check Measurement message on PrimegNB    logname=${logname}    pci_id=${pci_pcell}
# #    Check has no IgnbCAUeContextModificationRequest and IgNBCAAdditionRequest message    logname=${logname}
# #
# #Check wireshark log for BA011
# #    [Arguments]    ${logname}
# #    ${pci_pcell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name}    gnb_index=${0}    cell_index=${1}
# #    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=0    rsrp=90
# #    Check Measurement message on PrimegNB    logname=${logname}    pci_id=${pci_pcell}
# #    Check has no IgnbCAUeContextModificationRequest and IgNBCAAdditionRequest message    logname=${logname}
# #