#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords.robot
#Variables    ./Resources/CB008140_G_variables.py
#
#Documentation
#...   author: qingqing.zhang
#...   contact: qingqing.zhang@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-GJ
#
#Suite Setup    Run Keywords
#...               robot_common_operations.Common Suite Setup    AND
#...               Common Suite Setup for COAM    AND
#...               Adjust gNB_RU Attenuation
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
#${filename_gnb1_001_attach_UE0}    log_name_GJ_001_gNB1_UE0.pcap
#${filename_gnb1_001_attach_UE1}    log_name_GJ_001_gNB1_UE1.pcap
#${filename_gnb1_001_UE0_detach}    log_name_GJ_001_gNB1_UE0_detach.pcap
#${filename_gnb1_001_A2_release}    log_name_GJ_001_gNB1_UE1_A2_release.pcap
#${filename_gnb1_001_UE1_detach}    log_name_GJ_001_gNB1_UE1_detach.pcap
#
#
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{gnb_ips}    ${bts_host0}    ${bts_host1}    ${bts_host2}
#
#*** Test Cases ***
#[1]CB008140-5G-GJ_001_Dynamic_outgoing_CA_relation_maintenance
#    [Documentation]    This user scenario verifies the number of outgoing CA relation can not exceed the specified
#    ...                 maximum number of outgoing CA relation per cell
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup with NRREl
#    Prepare and detech UE
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${10}    gnb3_cell3_value=${30}
#    ### UE0 UE1 attach, scell selection ####
#    FOR   ${ue_index}   IN    ${0}    ${1}
#        Start capture gNB log on master    filename=${filename_gnb1_001_attach_UE${ue_index}}   gNB_index=${0}
#        MultiUE.Attach    ue_index=${ue_index}
#        sleep    5s
#        Stop and download the Logs    filename=${filename_gnb1_001_attach_UE${ue_index}}    gNB_index=${0}
#    END
#    #### UE0 detach ####
#    UE detech and collect log    ue_index=${0}    filename=${filename_gnb1_001_UE0_detach}
#    #### trigger gnb3 scell3 A2 release ####
#    Start capture gNB log on master    filename=${filename_gnb1_001_A2_release}   gNB_index=${0}
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${30}    gnb3_cell3_value=${120}
#    Sleep    10s
#    Stop and download the Logs    filename=${filename_gnb1_001_A2_release}    gNB_index=${0}
#    #### UE1 detach ####
#    UE detech and collect log    ue_index=${1}    filename=${filename_gnb1_001_UE1_detach}
#    Check wireshark log for GJ001
##    Hanging resource test    gnb_ips=@{gnb_ips}    ue_index=${8}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    MultiUE.Prepare UE    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation    AND
#    ...    Run Keyword And Ignore Error    Tear down the connections
#
#*** Keywords ***
#Common Case TestLine Setup with NRREl
#    Common Case TestLine Setup with singe BTS    gnb_index=${0}    ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_GJ001}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GJ001}    ListToAdd=${LIST_TO_ADD_GNB1_GJ001}
#    Common Case TestLine Setup with singe BTS
#    ...    gnb_index=${2}    is_commission=True    golden_scf_name=${golden_scf_name_gnb2}
##    Reset the gnb1 and gnb2 and wait them on air    gnb_index_prime=${0}    gnb_index_Ext=${2}
#    ###gnb3 cell3 A2release###
#    Modify Parameters for Cases   gnb_index=${2}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB3_GJ001}    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB3_GJ001}
#
#Prepare and detech UE
#    MultiUE.Prepare UE    ue_num=${2}
#    FOR   ${ue_index}   IN    ${0}    ${1}
#            power_ue.UE Detach
#    ...   ue_type=${tl.ues[1].capabilities[-1]}    ue_index=${ue_index}    power_reset=True
#        sleep    5s
#    END
#
#UE detech and collect log
#    [Arguments]    ${ue_index}    ${filename}    ${gNB_index}=${0}
#    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
#    power_ue.UE Detach
#    ...   ue_type=${tl.ues[1].capabilities[-1]}    ue_index=${ue_index}    power_reset=True
#    sleep    10s
#    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
#
#Check wireshark log for GJ001
#    ${scell1_PCI}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${2}    cell_index=${1}
#    ${scell2_PCI}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${2}    cell_index=${2}
#    ${scell3_PCI}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${2}    cell_index=${3}
#    ${scell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}    gnb_index=${2}
#    ${scell2_id}=    COAM Get nrcellid with lcrid    lcrid=${2}    gnb_index=${2}
#    ${scell3_id}=    COAM Get nrcellid with lcrid    lcrid=${3}    gnb_index=${2}
#    @{scell_UE0}=    Create List    ${scell1_PCI}    ${scell2_PCI}
#    @{scell_UE1}=    Create List    ${scell1_PCI}    ${scell3_PCI}
#    Check UEContextModificationResponse has scellid on PrimegNB    logname=${filename_gnb1_001_attach_UE0}
#    ...    pci_scell=@{scell_UE0}    scell_num=2
#    Check UEContextModificationResponse has scellid on PrimegNB    logname=${filename_gnb1_001_attach_UE1}
#    ...    pci_scell=@{scell_UE1}    scell_num=2
#    Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB
#    ...    logname=${filename_gnb1_001_UE0_detach}    scell_id_release=${scell2_id}
#    Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB
#    ...    logname=${filename_gnb1_001_UE1_detach}    scell_id_release=${scell1_id}
#    Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB
#    ...    logname=${filename_gnb1_001_A2_release}    scell_id_release=${scell3_id}
