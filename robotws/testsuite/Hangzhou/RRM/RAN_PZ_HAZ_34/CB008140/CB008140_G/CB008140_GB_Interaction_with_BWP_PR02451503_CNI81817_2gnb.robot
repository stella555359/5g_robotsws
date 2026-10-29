*** Settings ***
Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_G_variables_2gnb.py

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008140-GB

Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
...               Adjust gNB_RU Attenuation for 2gnb    AND
...               Get sagnb release    AND
...               get_release_check_result

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   gnb_list=${gnb_list_GB}    AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${golden_scf_name_gnb0}    SCF_GNB1
${golden_scf_name_gnb1}    SCF_GNB2
${filename_006_gnb0}    log_name_GB_006_gNB1.pcap
${filename_006_gnb1}    log_name_GB_006_gNB2.pcap
${filename_007_gnb0}    log_name_GB_007_gNB1.pcap
${filename_007_gnb1}    log_name_GB_007_gNB2.pcap
${filename_012_gnb3}    log_name_GB_012_gNB4.pcap
${filename_012_gnb2}    log_name_GB_012_gNB3.pcap
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${scf_path}    /opt/workspace/SCF/
@{gnb_ips_GB}    ${bts_host0}    ${bts_host1}
${counter_gnb2_M55167C00001}    ${1}
@{expected_value_GB007_gnb2}    ${1}    ${1}    ${1}    ${1}
@{gnb_list_GB}    ${0}    ${1}
@{filename_006}    filename_006_gnb    filename_007_gnb
@{filename_007}    filename_007_gnb
@{filename_012}    filename_012_gnb
@{extgnb_index_list_L006}    ${1}
@{scell_index_list_L006}    ${11}
@{extgnb_index_list_L007}    ${0}
@{scell_index_list_L007}    ${11}
@{extgnb_index_list_L012}    ${2}
@{scell_index_list_L012}    ${1}

*** Test Cases ***
[1]CB008140-5G-GB_006_IW_IgCA_Scell_addition_not_trigger_with_CB007552&8543_enabled_but_fre_intraband_continues
    [Documentation]    This user scenario describes the success SCell selection for inter-gNB CA in case the UE support
    ...    both large BWP and small BWP of ex-Scell. ext-SCell largeBWP is excluded because intra-band contiguous between
    ...    PCell and ext-SCell is not supported in CB008140 scope. but ext_scell small BWP s not continues with pscell,
    ...    so still can success triger scell selection.
    [Tags]     classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    Common Case TestLine Setup for GB
    ## add GB006 checkpoint
    MultiUE.Prepare UE
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}
    Start capture multi gNB log    filename=filename_006_gnb    gnb_list=${gnb_list_GB}
    MultiUE.Attach
    sleep    5s
    Stop capture multi gNB log    filename=filename_006_gnb    gnb_list=${gnb_list_GB}
    MultiUE.Detach
    comment    check the wireshark log
    Check wireshark log for attach failed    logname=${filename_006_gnb0}    scell_index_list=${scell_index_list_L006}
    ...    extgnb_index_list=${extgnb_index_list_L006}    pcell_index=${11}    Primegnb_index=${0}
    ## GB007 checkpoint
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    Start capture multi gNB log    filename=filename_007_gnb    gnb_list=${gnb_list_GB}
    MultiUE.Attach
    sleep    5s
    Stop capture multi gNB log    filename=filename_007_gnb    gnb_list=${gnb_list_GB}
    MultiUE.Detach
    Prepare with PM counter time to caculate    period=end
    Check counter for GB007
    comment    check the wireshark log
    Check wireshark log for GB007   logname=${filename_007_gnb1}
    Hanging resource test    gnb_ips=@{gnb_ips_GB}    gnb_list=@{gnb_list_GB}
    [Teardown]    run keywords
    ...    Case Teardown    filename=${filename_006}    gnb_list=@{gnb_list_GB}    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

#[1]CB008140-5G-GB_007_IW_IgCA_Scell_addition_trigger_with_CB007552&8543_enabled_not_continues_with_scell_SB_but_continues_with_scell_LB
#    [Documentation]    This user scenario describes the failed SCell selection for inter-gNB CA in case the UE support
#    ...    both large BWP and small BWP of ex-Scell. ext-SCell is excluded because intra-band contiguous between PCell
#    ...    and ext-SCell is not supported in CB008140 scope.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    MultiUE.Prepare UE
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GB007}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${0}
#    Prepare with PM counter time to caculate    period=start
#    Start capture multi gNB log    filename=filename_007_gnb    gnb_list=${gnb_list_GB}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_007_gnb    gnb_list=${gnb_list_GB}
#    MultiUE.Detach
#    Prepare with PM counter time to caculate    period=end
#    Check counter for GB007
#    comment    check the wireshark log
#    Check wireshark log for GB007   logname=${filename_007_gnb3}
#    Hanging resource test    gnb_ips=@{gnb_ips_GB}    gnb_list=@{gnb_list_GB}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_007}    gnb_list=@{gnb_list_GB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-GB_012_IW_IgCA_Scell_Addition_not_attempted_due_to_UE_supporting_only_the_alternative_band_of_the_candidate_extSCell
#    [Documentation]    This user scenario describes the case when inter-gNB CA SCell Addition is not attempted because
#    ...    5G-UE supports the alternative frequency band of the candidate ext-SCell.
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify NIDD on gnb    gnb_index=${3}    Add_Mo_Online=${MO_TO_ONLINE_ADD_GNB4_GB012}
#    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GB012}    Delete_Mo_Online=${PARAMETERS_TO_ONLINE_RECOVERY_GNB4_GB007}
#    MultiUE.Prepare UE
#    MultiUE.band restriction GB    band=2:41:66:77
#    Adjust gNB_RU Attenuation    gnb4_cell1_value=${0}
#    Start capture multi gNB log    filename=filename_012_gnb    gnb_list=${gnb_list_GB}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_012_gnb    gnb_list=${gnb_list_GB}
#    MultiUE.Detach
#    comment    check the wireshark log
#    Check wireshark log for attach failed    logname=${filename_012_gnb3}     scell_index_list=${scell_index_list_L012}
#    ...    extgnb_index_list=${extgnb_index_list_L012}    pcell_index=${1}    Primegnb_index=${3}
#    Hanging resource test    gnb_ips=@{gnb_ips_GB}    gnb_list=@{gnb_list_GB}
#    [Teardown]    run keywords
#    ...    MultiUE.band restriction GB    band=25:2:41:66:77    AND
#    ...    Case Teardown    filename=${filename_012}    gnb_list=@{gnb_list_GB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation



*** Keywords ***
Common Case TestLine Setup for GB
    @{scf_list}    Create List
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${golden_scf_name_gnb0}_${release_info}.xml    MOsToAdd=${MOS_ADD_GNB1_GB006}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GB006}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_GB006}
    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB1_GB006}    ListToAdd=${LIST_TO_ADD_GNB1_GB006}
    Append to List    ${scf_list}    ${scf_gnb1}
    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${1}
    ...    golden_scf_name=${golden_scf_name_gnb1}_${release_info}.xml    MOsToAdd=${MOS_ADD_GNB2_GB006}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_GB006}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB2_GB006}
    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB2_GB006}    ListToAdd=${LIST_TO_ADD_GNB2_GB006}
    Append to List    ${scf_list}    ${scf_gnb2}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_GB}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list_GB}

Check wireshark log for attach failed
    [Arguments]    ${logname}    ${scell_num}=1    ${scell_index_list}=${scell_index_list_L006}
    ...    ${extgnb_index_list}=${extgnb_index_list_L006}    ${pcell_index}=${31}    ${Primegnb_index}=${0}
    ${scell_gnb2}=    COAM Get nrcellid with lcrid    lcrid=${scell_index_list[0]}    gnb_index=${extgnb_index_list[0]}
    @{scell_gnb2}    Create List    ${scell_gnb2}
    Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB    logname=${logname}    scell_nums=${scell_num}
    ...    scell=${scell_gnb2}    xnap_gnb=${xnap_gnb${${extgnb_index_list[0]}+${1}}}
        ### check attach not to pcell1-1 and scell2-1
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}    CA_OK=False
    ...    UEContextModificationResponse_nums=${2}

Check wireshark log for GB007
    [Arguments]    ${logname}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${11}    scell_index_list=${scell_index_list_L007}
    ...    Primegnb_index=${1}    extgnb_index_list=${extgnb_index_list_L007}    CA_OK=True
    ...    UEContextModificationResponse_nums=${3}
    Check UEContextModificationResponse carrierBandwidth on PrimegNB    logname=${logname}

Check counter for GB007
    sleep    40s
    ${counter_list}=    RUN KEYWORD IF    '${check_result}' == 'True'    Get the PM counter
    ...    gnb_index=${1}    counter_id=${counter_id_GB007_gNB2_KPI}
    ...    dic_path=${counter_dic_path_GB007_gNB2_KPI_Trunk}
    ...    ELSE    Get the PM counter
    ...    gnb_index=${1}    counter_id=${counter_id_GB007_gNB2_KPI}
    ...    dic_path=${counter_dic_path_GB007_gNB2_KPI}
    ${counter_KPI}    Evaluate    ${counter_list[1]}/${counter_list[0]}
    should be true    0<${counter_KPI}<=1
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_GB007_gnb2}    dic_path=${counter_dic_path_GB007_gnb2_Trunk}
    ...    value=${expected_value_GB007_gnb2}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_GB002_gnb2}    dic_path=${counter_dic_path_GB002_gnb2}
    ...    value=${expected_value_GB002_gnb2}

Check UEContextModificationResponse carrierBandwidth on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList
    ...    ${xpath}=.//nr-rrc.carrierBandwidth
    Log    check carrierBandwidth message
    ${carrierBandwidth}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${carrierBandwidth[-1]}    79

MultiUE.band restriction GB
    [Arguments]    ${band}=2:25:41:66    ${ue_index}=${ue_index_${gnb_instance0}}
    Spark.send AT command CPE     param=at+QNWPREFCFG="nr5g_band",${band};     ue_alias=UE_${ue_index}
    Sleep    20s