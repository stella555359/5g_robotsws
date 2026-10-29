#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_D_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-DC
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM   gnb_list=${gnb_list_DC}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${filename_001_gnb0}    log1_name_DC_001_gNB1.pcap
#${filename_001_UE0_gnb0}    log_name_DC_001_gNB1_UE0.pcap
#${filename_001_UE1_gnb0}    log_name_DC_001_gNB1_UE1.pcap
#${filename_001_UE1_detach_gnb0}    log_name_DC_001_gNB1_UE1_detach.pcap
#${filename_001_UE2_gnb0}    log_name_DC_001_gNB1_UE2.pcap
#${filename_001_UE3_gnb0}    log_name_DC_001_gNB1_UE3.pcap
#${filename_001_UE4_gnb0}    log_name_DC_001_gNB1_UE4.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${swconfig}    /opt/workspace/swconfig/swconfig_TA.txt
#${swconfig_restore}    /opt/workspace/swconfig/swconfig_restore.txt
#@{cell_id_001_gnb1}    ${0}
#@{gnb_list_DC}    ${0}    ${2}    ${3}
#@{gnb_ips_DC}    ${bts_host0}    ${bts_host2}    ${bts_host3}
#@{expected_value_001_xml_gnb1}    1
#@{gnb2_ip}    ${bts_host1}
#@{numberOfActiveUEs_00}    0    0
#@{numberOfActiveUEs_UE0_11}    1    1
#@{numberOfActiveUEs_UE4_22}    2    2
#@{gnb_ips}    ${bts_host0}    ${bts_host2}    ${bts_host3}
#@{gnb_list_DC}    ${0}    ${2}    ${3}
#@{ue_index_MTU_38711}    ${1}    ${2}    ${3}    ${4}    ${8}
#@{ue_index_MTU_38611}    ${1}    ${2}    ${3}    ${4}
#@{filename_DC001}    filename_001_gnb0    filename_001_UE0_gnb0    filename_001_UE1_gnb0    filename_001_UE1_detach_gnb0
#...    filename_001_UE2_gnb0    filename_001_UE3_gnb0    filename_001_UE4_gnb0
#@{scell_index_list_DC_gnb3}    ${11}    ${3}
#@{extgnb_index_list_DC_gnb3}    ${2}    ${2}
#@{scell_index_list_DC_gnb4}    ${2}    ${3}
#@{extgnb_index_list_DC_gnb4}    ${3}    ${3}
#@{scell_index_list_DC_gnb1}    ${11}
#@{extgnb_index_list_DC_gnb1}    ${0}
#
#*** Test Cases ***
#[1]CB008140-5G-DC_001_A1_intergNB_CA_Scell_addition_3_ gNBs_Scells_selection_based_on_Scell_candidates_load
#    [Documentation]    In this user scenario different SA UE contexts are configured with different SCells due to
#    ...                changing load conditions in candidate SCells.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for DC001
#    ## check xn setup ####
#    Start capture gNB log on master    filename=${filename_001_gnb0}   gNB_index=${0}
#    sleep    5s
#    Stop and download the Logs    filename=${filename_001_gnb0}    gNB_index=${0}
#    Multi MTU power and prepare ue
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    # UE0 UE1 UE2 attach, scell selection ####
#    FOR   ${ue_index}   IN RANGE    ${0}    ${3}
#        Start capture gNB log on master    filename=${filename_001_UE${ue_index}_gnb0}   gNB_index=${0}
#        MultiUE.Attach    ue_index=${ue_index}
#        sleep    10s
#        Stop and download the Logs    filename=${filename_001_UE${ue_index}_gnb0}    gNB_index=${0}
#    END
#    ## UE1 detach ####
#    Start capture gNB log on master    filename=${filename_001_UE1_detach_gnb0}   gNB_index=${0}
#    MultiUE.Detach    ue_index=${1}
#    sleep    10s
#    Stop and download the Logs    filename=${filename_001_UE1_detach_gnb0}    gNB_index=${0}
#    ## UE3 and UE4 attach ####
#    Start capture gNB log on master    filename=${filename_001_UE3_gnb0}   gNB_index=${0}
#    MultiUE.Attach    ue_index=${3}
#    Stop and download the Logs    filename=${filename_001_UE3_gnb0}    gNB_index=${0}
#    Check wireshark log for DC001    logname=${filename_001_gnb0}    logname1=${filename_001_UE0_gnb0}
#    ...    logname2=${filename_001_UE1_gnb0}    logname3=${filename_001_UE2_gnb0}
#    ...    logname4=${filename_001_UE1_detach_gnb0}    logname5=${filename_001_UE3_gnb0}
#    ### UE0-UE4 detach ####
#    FOR   ${ue_index}   IN RANGE    ${0}    ${4}
#       MultiUE.Detach    ue_index=${ue_index}
#    END
#    Hanging resource test    gnb_ips=@{gnb_ips_DC}    gnb_list=@{gnb_list_DC}
#    [Teardown]    run keywords
#    ...    Multi MTU power and recovery ue    AND
#    ...    Common Case Teardown for COAM    gnb_list=${gnb_list_DC}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for DC001
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_DC001}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_DC001}    ListToAdd=${LIST_TO_ADD_GNB1_DC001}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_DC001}
#    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB3_DC001}    ListToAdd=${LIST_TO_ADD_GNB3_DC001}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_DC001}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_DC}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_DC}
#
#Check wireshark log for DC001
#     [Arguments]    ${logname}    ${logname1}    ${logname2}    ${logname3}    ${logname4}    ${logname5}
#    ## check xn IgNBCAResourceStatusUpdate
#    Check IgNBCAResourceStatusUpdate has 2 nrcellid    logname=${logname}
#    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}
#     ...    numberOfActiveUEs_value=${numberOfActiveUEs_00}    numberOfActiveUlUEs_value=${numberOfActiveUEs_00}
#     ...    xnap_gnb=${xnap_gnb3}
#    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}
#     ...    numberOfActiveUEs_value=${numberOfActiveUEs_00}    numberOfActiveUlUEs_value=${numberOfActiveUEs_00}
#     ...    xnap_gnb=${xnap_gnb4}
#    ## check ue0 attach cell1-2,add cell4-2 and cell4-3
#    Check gNBs Scells selection    logname=${logname1}
#    ...    numberOfActiveUEs_value=${numberOfActiveUEs_00}    numberOfActiveUlUEs_value=${numberOfActiveUEs_00}
#    ...    extgnb_index_list=${extgnb_index_list_DC_gnb4}    scell_index_list=${scell_index_list_DC_gnb4}
#    ## check ue1 attach cell1-2,add cell3-11 and cell3-3
#    Check gNBs Scells selection    logname=${logname2}
#    ...    numberOfActiveUEs_value=${numberOfActiveUEs_00}    numberOfActiveUlUEs_value=${numberOfActiveUEs_00}
#    ...    extgnb_index_list=${extgnb_index_list_DC_gnb3}    scell_index_list=${scell_index_list_DC_gnb3}
#    ## check ue2 attach cell1-2,add cell1-11
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname3}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list_DC_gnb1}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_DC_gnb1}
#    ...    UEContextModificationResponse_nums=${3}
#    ## check detach ue the numberOfActiveUEs and numberOfActiveUlUEs are 0 0
#    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname4}
#    ...    numberOfActiveUEs_value=${numberOfActiveUEs_00}
#    ...    numberOfActiveUlUEs_value=${numberOfActiveUEs_00}    xnap_gnb=${xnap_gnb3}
#    ## check ue3 attach cell1-2,add cell1-11
#    Check gNBs Scells selection    logname=${logname5}
#    ...    numberOfActiveUEs_value=${numberOfActiveUEs_00}    numberOfActiveUlUEs_value=${numberOfActiveUEs_00}
#    ...    extgnb_index_list=${extgnb_index_list_DC_gnb3}    scell_index_list=${scell_index_list_DC_gnb3}
#
#Check gNBs Scells selection
#    [Arguments]    ${logname}    ${numberOfActiveUEs_value}    ${numberOfActiveUlUEs_value}
#    ...    ${extgnb_index_list}    ${scell_index_list}
#    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}    numberOfActiveUEs_value=${numberOfActiveUEs_value}
#    ...    numberOfActiveUlUEs_value=${numberOfActiveUlUEs_value}    xnap_gnb=${xnap_gnb${${extgnb_index_list[0]}+${1}}}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
#    ...    pcell_index=${2}    scell_index_list=${scell_index_list}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list}
#    ...    UEContextModificationResponse_nums=${3}
#
#Check IgNBCAResourceStatusUpdate has 2 nrcellid
#    [Arguments]    ${logname}
#    ${scell1_gnb3}=    COAM Get nrcellid with lcrid    lcrid=${3}    gnb_index=${2}
#    ${scell2_gnb3}=    COAM Get nrcellid with lcrid    lcrid=${11}    gnb_index=${2}
#    @{scell_gnb3}    Create List    ${scell1_gnb3}    ${scell2_gnb3}
#    ${scell1_gnb4}=    COAM Get nrcellid with lcrid    lcrid=${2}    gnb_index=${3}
#    ${scell2_gnb4}=    COAM Get nrcellid with lcrid    lcrid=${3}    gnb_index=${3}
#    @{scell_gnb4}    Create List    ${scell1_gnb4}    ${scell2_gnb4}
#    Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB    logname=${logname}    scell_nums=2
#    ...    scell=${scell_gnb3}    xnap_gnb=${xnap_gnb3}
#    Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB    logname=${logname}    scell_nums=2
#    ...    scell=${scell_gnb4}    xnap_gnb=${xnap_gnb4}
#
