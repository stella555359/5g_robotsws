#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_D_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-DB
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM   gnb_list=${gnb_list_DB}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${filename_001_gnb0}    log1_name_DB_001_gNB1.pcap
#${filename1_001_gnb0}    log_name_DB_001_gNB1_UE.pcap
#${filename_004_gnb0}    log1_name_DB_004_gNB1.pcap
#${filename1_004_gnb0}    log_name_DB_004_gNB1_UE.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{cell_id_001_gnb1}    ${0}
#@{gnb2_ip}    ${bts_host1}
#@{numberOfActiveUEs_gnb3}    0
#@{numberOfActiveUEs_gnb4}    0
#@{numberOfActiveUlUEs_gnb3}    0
#@{numberOfActiveUlUEs_gnb4}    0
#@{lcrid_list_DB001}    2    31
#@{numberOfActiveUEs_gnb4_004}    0    0
#@{numberOfActiveUlUEs_gnb4_004}    0    0
#@{numberOfActiveUEs_gnb3_004}    0    0    0
#@{numberOfActiveUlUEs_gnb3_004}    0    0    0
#@{numberOfActiveUEs_UE0_gnb3}    1    1
#@{numberOfActiveUlUEs_UE0_gnb3}    0    0
#@{gnb_ips_DB}    ${bts_host0}    ${bts_host2}    ${bts_host3}
#
#@{gnb_list_DB}    ${0}    ${2}    ${3}
#@{gnb_list_DB001_intergnb}    ${2}    ${3}
#@{filename_DB001}    filename_001_gnb    filename1_001_gnb
#@{filename_DB004}    filename_004_gnb    filename1_004_gnb
#@{scell_index_list_DB001}    ${2}
#@{extgnb_index_list_DB001}    ${2}
#@{scell_index_list_DB004}    ${1}    ${2}
#@{extgnb_index_list_DB004}    ${2}    ${2}
#
#*** Test Cases ***
#[1]CB008140-5G-DB_001_Blind_intergNB_CA_Scell_addition_candidate extSCells_hosted_by_4_gNBs
#    [Documentation]    In this user scenario different SA UE contexts are configured with different SCells due to
#    ...                changing load conditions in candidate SCells.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for DB001
#    MultiUE.Prepare UE
#    ### check xn setup ####
#    Start capture gNB log on master    filename=${filename_001_gnb0}   gNB_index=${0}
#    sleep    20s
#    Stop and download the Logs    filename=${filename_001_gnb0}    gNB_index=${0}
#    #### UE02 attach, scell selection ####
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${0}
#    Start capture gNB log on master    filename=${filename1_001_gnb0}   gNB_index=${0}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename1_001_gnb0}    gNB_index=${0}
#    MultiUE.Detach
#    Check wireshark log for DB001    logname=${filename_001_gnb0}    logname1=${filename1_001_gnb0}
#    Hanging resource test    gnb_ips=@{gnb_ips_DB}    gnb_list=@{gnb_list_DB}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_DB001}    gnb_list=${gnb_list_DB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-DB_004_Blind_intergNB_CA_Scell_addition_candidate extSCells_hosted_by_2_gNBs_weightForSCellSelection_and_bandwith_different
#    [Documentation]    In this user scenario different SA UE contexts are configured with different SCells due to
#    ...                changing load conditions in candidate SCells.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for DB004
#    MultiUE.Prepare UE
#    ### check xn setup ####
#    Start capture gNB log on master    filename=${filename_004_gnb0}   gNB_index=${0}
#    sleep    2min
#    Stop and download the Logs    filename=${filename_004_gnb0}    gNB_index=${0}
#    #### UE02 attach, scell selection ####
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${0}
#    Start capture gNB log on master    filename=${filename1_004_gnb0}   gNB_index=${0}
#    MultiUE.Attach
#    sleep    5s
#    Stop and download the Logs    filename=${filename1_004_gnb0}    gNB_index=${0}
#    MultiUE.Detach
#    Check wireshark log for DB004    logname=${filename_004_gnb0}    logname1=${filename1_004_gnb0}
#    Hanging resource test    gnb_ips=@{gnb_ips_DB}    gnb_list=@{gnb_list_DB}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_DB004}    gnb_list=${gnb_list_DB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for DB001
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_DB001}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_DB001}    ListToAdd=${LIST_TO_ADD_GNB1_DB001}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_DB001}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_DB001}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_DB}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_DB}
#
#
#Common Case TestLine Setup for DB004
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_DB004}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_DB004}    ListToAdd=${LIST_TO_ADD_GNB1_DB004}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_DB004}
#    ...    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB3_DB004}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB4_DB004}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_DB004}    ListToAdd=${LIST_TO_ADD_GNB4_DB004}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_DB}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_DB}
#
#Check wireshark log for DB001
#    [Arguments]    ${logname}    ${logname1}
#    Check IgNBCAResourceStatusUpdate has 1 nrcellid with nany gnbs    logname=${logname}
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${3}    scell_index_list=${scell_index_list_DB001}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_DB001}
#    ...    UEContextModificationResponse_nums=${3}
#
#Check wireshark log for DB004
#    [Arguments]    ${logname}    ${logname1}
#    ${scell1_gnb4}=    COAM Get nrcellid with lcrid    lcrid=3    gnb_index=3
#    ${scell2_gnb4}=    COAM Get nrcellid with lcrid    lcrid=31    gnb_index=3
#    @{scell_gnb4}    Create List    ${scell1_gnb4}    ${scell2_gnb4}
#    Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB    logname=${logname}    scell_nums=2
#    ...    scell=${scell_gnb4}    xnap_gnb=${xnap_gnb4}
#    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}
#    ...    numberOfActiveUEs_value=${numberOfActiveUEs_gnb4_004}    numberOfActiveUlUEs_value=${numberOfActiveUlUEs_gnb4_004}
#    ...    xnap_gnb=${xnap_gnb4}
#
#    ${scell1_gnb3}=    COAM Get nrcellid with lcrid    lcrid=1    gnb_index=2
#    ${scell2_gnb3}=    COAM Get nrcellid with lcrid    lcrid=2    gnb_index=2
#    ${scell3_gnb3}=    COAM Get nrcellid with lcrid    lcrid=11    gnb_index=2
#    @{scell_gnb3}    Create List    ${scell1_gnb3}    ${scell2_gnb3}    ${scell3_gnb3}
#    Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB    logname=${logname}    scell_nums=3
#    ...    scell=${scell_gnb3}    xnap_gnb=${xnap_gnb3}
#    Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}
#    ...    numberOfActiveUEs_value=${numberOfActiveUEs_gnb3_004}    numberOfActiveUlUEs_value=${numberOfActiveUlUEs_gnb3_004}
#    ...    xnap_gnb=${xnap_gnb3}
#
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${3}    scell_index_list=${scell_index_list_DB004}
#    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_DB004}
#    ...    UEContextModificationResponse_nums=${3}
#
#
#Check IgNBCAResourceStatusUpdate has 1 nrcellid with nany gnbs
#    [Arguments]    ${logname}    ${lcrid_list}=${lcrid_list_DB001}    ${gnb_list}=${gnb_list_DB001_intergnb}
#    FOR   ${lcrid}    ${gnb_index}   IN ZIP   ${lcrid_list}    ${gnb_list}
#       ${scell_gnb}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${gnb_index}
#       @{scell_gnb}    Create List    ${scell_gnb}
#       Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB    logname=${logname}    scell_nums=1
#       ...    scell=${scell_gnb}    xnap_gnb=${xnap_gnb${${gnb_index}+${1}}}
#       Check numberOfActiveUEs and numberOfActiveUlUEs    logname=${logname}
#       ...    numberOfActiveUEs_value=${numberOfActiveUEs_gnb${${gnb_index}+${1}}}
#       ...    numberOfActiveUlUEs_value=${numberOfActiveUlUEs_gnb${${gnb_index}+${1}}}
#       ...    xnap_gnb=${xnap_gnb${${gnb_index}+${1}}}
#    END
#
