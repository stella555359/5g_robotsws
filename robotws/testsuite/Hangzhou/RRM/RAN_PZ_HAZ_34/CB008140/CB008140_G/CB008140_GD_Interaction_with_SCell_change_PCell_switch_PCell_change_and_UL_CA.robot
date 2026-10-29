#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_G_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-GD
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Common Case TestLine Setup for GD    AND
#...               Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM   gnb_list=${gnb_list_GD}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${filename_001_gnb0}    log1_name_GD_001_gNB1.pcap
#${filename_001_gnb3}    log1_name_GD_001_gNB4.pcap
#${filename_003_gnb0}    log1_name_GD_003_gNB1.pcap
#${filename_003_gnb3}    log1_name_GD_003_gNB4.pcap
#${filename_009_gnb0}    log1_name_GD_009_gNB1.pcap
#${filename_009_gnb3}    log1_name_GD_009_gNB4.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{gnb_list}    0    1    2
#@{gnb_ips_GD}    ${bts_host0}    ${bts_host3}
#${Send_Tput_DL_F_T}    2000M
#${Send_Tput_UL_F_T}    200M
#${expected_tput_dl_F_15MHz}    390
#${expected_tput_dl_T_20MHz_38711}    140
#${expected_tput_dl_T_20MHz_38611}    180
#${expected_tput_ul_T_20MHz}    0
#${expected_tput_ul_F_15MHz_38711}    86
#${expected_tput_ul_F_15MHz_38611}    100
#@{gnb_list_GD}    ${0}    ${3}
#@{filename_GD001}    filename_001_gnb
#@{filename_GD003}    filename_003_gnb
#@{filename_GD009}    filename_009_gnb
#@{scell_index_list_001_cell}    ${1}
#@{extgnb_index_list_001_gnb}    ${3}
#@{scell_index_list_003_cell}    ${3}
#@{extgnb_index_list_003_gnb}    ${0}
#@{scell_index_list_009_cell_3cc}    ${2}    ${3}
#@{extgnb_index_list_009_gnb_3cc}    ${3}    ${3}
#@{scell_index_list_009_cell_2cc}    ${3}
#@{extgnb_index_list_009_gnb_2cc}    ${3}
#
#*** Test Cases ***
#[1]CB008140-GD_001_IgCA_Event_A2_measurement_for_Pcell_change_is_not_activated_during_extScell_addition
#    [Documentation]    This user scenario describes the successful UE configuration of the Inter-band FDD - TDD FR1 UL
#    ...                CA feature for single UE with 2 aggregated carriers in the inter-gNB CA deployment.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for GD001
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${0}    gnb4_cell1_value=${0}
#    Start capture multi gNB log    filename=filename_001_gnb    gnb_list=${gnb_list_GD}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_001_gnb    gnb_list=${gnb_list_GD}
#    MultiUE.Detach
#    comment    check the wireshark log
#    Check wireshark log for GD001   logname=${filename_001_gnb0}
#    Hanging resource test    gnb_ips=@{gnb_ips_GD}    gnb_list=@{gnb_list_GD}
#    [Teardown]    run keywords
#    ...    Case recover 001    AND
#    ...    Case Teardown    filename=${filename_GD001}   gnb_list=${gnb_list_GD}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-GD_003_Single_UE_connection_setup_with_UL_CA_scell_selection_success_FDD_TDD_IW_CB006137
#    [Documentation]    This user scenario describes the successful UE configuration of the Inter-band FDD - TDD FR1 UL
#    ...                CA feature for single UE with 2 aggregated carriers in the inter-gNB CA deployment.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for GD003
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Start capture multi gNB log    filename=filename_003_gnb    gnb_list=${gnb_list_GD}
#    MultiUE.Attach
#    sleep    3s
#    Stop capture multi gNB log    filename=filename_003_gnb    gnb_list=${gnb_list_GD}
#    MultiUE.Detach
#    comment    check the wireshark log
#    Check wireshark log for GD003   logname=${filename_003_gnb0}
#    Hanging resource test    gnb_ips=@{gnb_ips_GD}    gnb_list=@{gnb_list_GD}
#    [Teardown]    run keywords
#    ...    Case recover 003    AND
#    ...    Case Teardown    filename=${filename_GD003}    gnb_list=${gnb_list_GD}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-GD_009_Event_A1_is_not_configured_for_the_SCell_change_during_stepwise_ext-SCell_release_CB008015_and_CB006138
#    [Documentation]    This user scenario describes scenario where during stepwise ext-SCell release procedure event A1
#    ...    measurement for SCell change is not activated.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for GD009
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell3_value=${0}    gnb4_cell2_value=${0}
#    Start capture multi gNB log    filename=filename_009_gnb    gnb_list=${gnb_list_GD}
#    MultiUE.Attach
#    sleep    5s
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb4_cell2_value=${40}    gnb4_cell3_value=${0}
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_009_gnb    gnb_list=${gnb_list_GD}
#    comment    check the wireshark log
#    Check wireshark log for GD009   logname=${filename_009_gnb0}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_GD}    gnb_list=@{gnb_list_GD}
#    [Teardown]    run keywords
#    ...    Case recover 009    AND
#    ...    Case Teardown    filename=${filename_GD009}    gnb_list=${gnb_list_GD}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for GD
#    @{scf_list}    Create List    ${tl_scf_dir_path}${golden_scf_name_gnb0}    ${tl_scf_dir_path}${golden_scf_name_gnb3}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_GD}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GD}
#
#Case prepare for GD001
#    ${release}    Get sagnb release
#    Run keyword If    '${release}'=='SBTS23R3_ENB_0000'    Online modify NIDD on gnb    gnb_index=${0}
#    ...    Add_Mo_Online=${ADD_MO_Online_GNB1_GD001_SBTS23R3_ENB_0000}   Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_GD001}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD001}
#    ...    ELSE    Online modify NIDD on gnb    gnb_index=${0}
#    ...    Add_Mo_Online=${ADD_MO_Online_GNB1_GD001}   Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_GD001}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD001}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GD001}
#    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB4_GD001}
#
#Case prepare for GD003
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD003_1}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD003}
#    ...    Add_Mo_Online=${PARAMETERS_TO_MODIFY_GNB1_GD003}    Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_GD003}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GD003}
#
#Check wireshark log for GD001
#    [Arguments]    ${logname}
#    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=1    rsrp=66
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${3}    scell_index_list=${scell_index_list_001_cell}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_001_gnb}
#    ...    UEContextModificationResponse_nums=${2}
#
#Case recover 001
#    Online modify NIDD on gnb    gnb_index=${0}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB1_GD001}
#
#attach and check tput
#    Start capture multi gNB log    filename=filename_003_gnb    gnb_list=${gnb_list_GD}
#    MultiUE.Attach
#    sleep    3s
#    Stop capture multi gNB log    filename=filename_003_gnb    gnb_list=${gnb_list_GD}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell3_value=${5}
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=3    pcellid=1    gnb_prime=${0}    gnb_external=${0}
#    ...    tput_dl_pcell=${expected_tput_dl_F_15MHz}    tput_dl_scell=${expected_tput_dl_T_20MHz_${gnb_instance0}}
#    ...    tput_ul_pcell=${expected_tput_ul_F_15MHz_${gnb_instance0}}    tput_ul_scell=${expected_tput_ul_T_20MHz}
#    ...    dl_throughput=${Send_Tput_DL_F_T}    ul_throughput=${Send_Tput_UL_F_T}
#    MultiUE.Stop DLUL traffic
#    Sleep    3s
#    MultiUE.Detach
#
#Check wireshark log for GD003
#    [Arguments]    ${logname}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_003_cell}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_003_gnb}
#    ...    UEContextModificationResponse_nums=${2}
#
#Case recover 003
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_RESTORE_GNB1_GD003}
#    ...    Delete_Mo_Online=${MO_TO_DELETE_GNB1_GD003}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_GD003}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_RESTORE_GNB1_GD003_1}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_RESTORE_GNB4_GD003}
#
#Case prepare for GD009
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD009}
#    ...    Add_Mo_Online=${PARAMETERS_TO_MODIFY_GNB1_GD009}    Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_GD009}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GD009}
#    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB4_GD009}
#
#Check wireshark log for GD009
#    [Arguments]    ${logname}
#    comment    check attach to the 3cc
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_009_cell_3cc}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_009_gnb_3cc}
#    ...    UEContextModificationResponse_nums=${2}
#
#    comment    check has the 3cc meaurement report
#    Check the measurement report with A2 release    logname=${logname}
#
#    comment    check from 3cc to 2cc due to the scell2 trigger A2 release
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_009_cell_2cc}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_009_gnb_2cc}
#    ...    UEContextModificationResponse_nums=${1}
#
#    comment    check the A2 reconfiguration has no the pcell A1change config
#    Check A2 release RRC Reconfiguration message on PrimegNB    logname=${logname}    scell_release_index=2
#
#Case recover 009
#    Online modify NIDD on gnb    gnb_index=${0}   Delete_Mo_Online=${MO_TO_DELETE_GNB1_GD009}
#    ...   ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_GD009}
#    Online modify NIDD on gnb    gnb_index=${3}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB4_GD009}
#
#Check the measurement report with A2 release
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measResultServingMOList == 3
#    ...    ${xpath}=.//nr-rrc.physCellId
#    Log    check has Measurement message
#    ${pci_cclist}    Create List
#    ${pci_pcell}=    get required cell info   required_info=physicalCellId    cell_index=${1}   gnb_index=${0}
#    ${pci_scell2}=    get required cell info   required_info=physicalCellId    cell_index=${2}   gnb_index=${3}
#    ${pci_scell3}=    get required cell info   required_info=physicalCellId    cell_index=${3}   gnb_index=${3}
#    ${pci_pcell}=    Convert To String    ${pci_pcell}
#    ${pci_scell2}=    Convert To String    ${pci_scell2}
#    ${pci_scell3}=    Convert To String    ${pci_scell3}
#    Append to list    ${pci_cclist}    ${pci_pcell}    ${pci_scell2}    ${pci_scell3}
#    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    Lists Should Be Equal    ${physCellId}    ${pci_cclist}
#
#Check A2 release RRC Reconfiguration message on PrimegNB
#    [Arguments]    ${logname}    ${scell_release_index}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 && nr-rrc.sCellToReleaseList == 1
#    ...    ${xpath}=.//nr-rrc.sCellToReleaseList
#    ...    ${xpath1}=.//nr-rrc.SCellIndex
#    ...    ${xpath2}=.//nr-rrc.eventId
#    ...    ${xpath2}=.//nr-rrc.measTriggerQuantity.rsrp
#    ...    ${xpath3}=.//nr-rrc.measTriggerQuantity.rsrq
#    Log    check RRC Reconfiguration message has the scell to release
#    ${scellreleaselist}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${scellreleaselist[0]}    1
#    ${scellreleaseindex}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    should be equal    ${scellreleaseindex}    ${scell_release_index}
#
#    Log    check RRC Reconfiguration message has no eventid and rsrp/rsrq config
#    ${eventId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
#    should be empty    ${eventId}