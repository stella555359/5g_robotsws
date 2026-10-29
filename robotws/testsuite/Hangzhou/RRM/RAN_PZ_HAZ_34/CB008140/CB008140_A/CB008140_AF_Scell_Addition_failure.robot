#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_A_Variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-AF
#
#Suite Setup    Run Keywords
#...    Common Suite Setup for COAM    AND
#...    Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM   gnb_list=${gnb_list_AF}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${filename_AA002_gnb0}    log1_name_AA_002_gNB1.pcap
#${filename_AA002_gnb2}    log1_name_AA_002_gNB3.pcap
#${filename_AF006_gnb0}    log1_name_AF_006_gNB1.pcap
#${filename_AF006_gnb2}    log1_name_AF_006_gNB3.pcap
#@{expected_value_006_gnb1}    1    1
#@{expected_value_006_gnb3}    1
#@{expected_value_AF_gnb1}    ${1}    ${1}    ${1}
#@{expected_value_AF_gnb3}    ${1}    ${1}    ${1}    ${1}    ${1}
#${PMfile_gnb1}    8140_AF_006_counter_gnb1.xml
#${PMfile_gnb2}    8140_AF_006_counter_gnb2.xml
#@{counter_index_AF006_gnb1}    ${0}    ${0}
#@{counter_index_AF006_gnb2}    ${0}
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${swconfig}    /opt/workspace/swconfig/swconfig_TA.txt
#${swconfig_restore}    /opt/workspace/swconfig/swconfig_restore.txt
#${ue_type}    ${tl.ues[0].capabilities[-1]}
#@{filename_AF006}    filename_AA002_gnb    filename_AF006_gnb
#@{gnb_ips_AF}    ${bts_host0}    ${bts_host2}
#@{gnb_list_AF}    ${0}    ${2}
#
#*** Test Cases ***
##[1]CB008140-5G-AF_001_Scell_Addition_failure_due_to_rejection_with_no_CA_eligible_DRB_found_from_prime_Gnb_DU
##    [Documentation]    This user scenario describes a failed inter-gNB CA SCell addition for a SA UE context having
##    ...                one candidate SCell only in an ext-gNB, due to rejection in preparation phase from prime-gNB-DU
##    [Tags]     classical    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Common Case TestLine Setup    ModifySCF_Beforecommission=True    is_commission_for_second_gnb=True
##    ...    golden_scf_name=${golden_scf_name}    golden_scf_name_gnb2=${golden_scf_name_gnb2}
##    ...    MOsToAdd=${MOS_ADD_GNB1}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_AF001}    ListToAdd=${LIST_TO_ADD_GNB1}
##    Reset the gnb1 and gnb2 and wait them on air
##    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}
##    Record the counter action timer
##    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_001}    gnb2_filename=${filename1_gnb2_001}
##    power_ue.Prepare UE    ue_type=${ue_type}
##    Attach and check power UE    ue_type=${ue_type}
##    sleep    3s
##    power_ue.UE Detach  ue_type=${ue_type}
##    sleep    5s
##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_001}    gnb2_filename=${filename1_gnb2_001}
##
##    comment    check the counter
##    Wait until keyword succeeds    10 min    20s   Check counter for AF001
##    comment    check the wireshark log
##    Check wireshark log for AF 001   logname=${filename1_gnb1_001}
##    Hanging resource test
##    [Teardown]    run keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error    Common Case TestLine Setup    ModifySCF_Aftercommission=True
##    ...    Modify_Para_Online=${PARAMETERS_TO_GNB1_AF001_restore}    AND
##    ...    Run Keyword And Ignore Error    Case Teardown    ModifySCF_Aftercommission=True
##    ...    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}    AND
##    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
##
##[1]CB008140-5G-AF_003_Scell_Addition_failure_due_to_rejection_with_maxNumOfScellAlloc_reach_and_No_Radio_Resources_Available_from_ext_Gnb_CU
##    [Documentation]    This user scenario describes a failed inter-gNB CA SCell addition for a SA UE context having one
##    ...                candidate SCell only in an ext-gNB, due to rejection in execution phase from target ext-gNB-DU.
##    [Tags]     classical    CRT_TRUNK
##    [Timeout]    2 hour
##    [Setup]    robot_common_operations.Common Case Setup
##    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ModifySCF_Beforecommission_GNB2=True
##    ...    golden_scf_name=${golden_scf_name}    MOsToAdd=${MOS_ADD_GNB1}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1}
##    ...    ListToAdd=${LIST_TO_ADD_GNB1}
##    ...    golden_scf_name_gnb2=${golden_scf_name_gnb2}    ParamterToModify_gnb2=${PARAMETERS_TO_MODIFY_GNB2_AF003}
##    Reset the gnb1 and gnb2 and wait them on air
##    ${pci_scell}=    Get physCellId from SCF    golden_scf_name=${golden_scf_name_gnb2}    gnb_index=${1}    cell_index=${1}
##    set suite variable    ${pci_scell}
##    Adjust gNB_RU Attenuation    gnb1_cell1_value=${20}
##    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_003}    gnb2_filename=${filename1_gnb2_003}
##    power_ue.Prepare UE    ue_type=${ue_type}
##    Attach and check power UE    ue_type=${ue_type}
##    sleep    3s
##    power_ue.UE Detach  ue_type=${ue_type}
##    sleep    5s
##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename1_gnb1_003}    gnb2_filename=${filename1_gnb2_003}
##    sleep    5s
##    Common Case TestLine Setup    ModifySCF_Aftercommission_for_GNB2=True    Modify_Para_Online_GNB2=${PARAMETERS_TO_MODIFY_GNB2_AF003_01}
##    Check the cells status on air    bts_host=${bts_host1}    connection=gnb${gnb2_index}
##    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename2_gnb1_003}    gnb2_filename=${filename2_gnb2_003}
##    Attach and check power UE    ue_type=${ue_type}
##    sleep    3s
##    power_ue.UE Detach  ue_type=${ue_type}
##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename2_gnb1_003}    gnb2_filename=${filename2_gnb2_003}
##
##    comment    check the wireshark log
##    Check wireshark log for AF 003   logname=${filename1_gnb1_003}    logname1=${filename1_gnb2_003}
##    Check wireshark log for AF 003 01   logname=${filename2_gnb1_003}    logname1=${filename2_gnb2_003}
##    Hanging resource test
##    [Teardown]    run keywords
##    ...    robot_common_operations.Common Case Teardown    AND
##    ...    Run Keyword And Ignore Error
##    ...    Case Teardown    ModifySCF_Aftercommission=True    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}    AND
##    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-5G-AF_006_Scell_Addition_failure_due_to_incompatible_Xp_Uplane_IP_protocol_version_from_ext_Gnb_DU
#    [Documentation]    This user scenario describes a failed inter-gNB CA SCell addition for a SA UE context having one
#    ...                candidate SCell only in an ext-gNB, due to rejection in execution phase from target ext-gNB-DU.
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    # ADD 8140-AA002
#    Common Case TestLine Setup for AF006
#    wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${0}
#    wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${2}
#    Start capture multi gNB log    filename=filename_AA002_gnb    gnb_list=${gnb_list_AF}
#    wait until keyword succeeds    10 min    20s   Check the MultiBTS cells status on air    gnb_list=${gnb_list_AF}
#    Stop capture multi gNB log    filename=filename_AA002_gnb    gnb_list=${gnb_list_AF}
#    Check wireshark log for 002    logname=${filename_AA002_gnb0}    logname1=${filename_AA002_gnb2}
#    # 8140 AF006
#    Online modify NIDD on gnb    gnb_index=${2}    ParameterToDelete=${PARAMETERS_TO_BE_DELETE_GNB3_AF006}
#    ...    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB3}    Add_Para_Online=${LIST_TO_ADD_GNB3_AF006}
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    Prepare to caculate PM counter    period=start
#    MultiUE.Prepare UE
#    Start capture multi gNB log    filename=filename_AF006_gnb    gnb_list=${gnb_list_AF}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_AF006_gnb    gnb_list=${gnb_list_AF}
#    MultiUE.Detach
#    Prepare to caculate PM counter    period=end
#    Check counter for AF006 webui
#    comment    check the wireshark log
#    Check wireshark log for AF 006   logname=${filename_AF006_gnb0}    logname1=${filename_AF006_gnb2}
#    Hanging resource test    gnb_ips=@{gnb_ips_AF}    gnb_list=@{gnb_list_AF}
#    [Teardown]    run keywords
#    ...    Common Case TestLine Teardown    AND
#    ...    Case Teardown    filename=${filename_AF006}    gnb_list=${gnb_list_AF}    AND
#    ...    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for AF006
#    @{scf_list}    Create List
#    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_AF006}    ListToAdd=${LIST_TO_ADD_GNB1}
#    Append to List    ${scf_list}    ${scf_gnb1}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    MOsToAdd=${MOS_ADD_GNB3_AF}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_AF006}    ListToAdd=${LIST_TO_ADD_GNB3_AA002}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_AF}    scf_list=${scf_list}
#
#Common Case TestLine Teardown
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_GNB1_AF006_restore}
#    Online modify NIDD on gnb    gnb_index=${2}    Add_Para_Online=${PARAMETERS_TO_GNB3_AF006_restore}
#
#Check wireshark log for 002
#    [Arguments]    ${logname}    ${logname1}
#    Get cell id multignb    lcrid_pcell=${1}    scell_index_list=${scell_index_list}
#    ...    PrimegNB_index=${0}    extgnb_index_list=${extgnb_index_list}
#    Check 1st IgNBCASetupRequest    logname=${logname}    iGnbCaXnSetupReqTmr=${60}
#    Check IgNBCASetup on 2gnb    logname=${logname}    PrimegNB=${xnap_gnb1}    ExtgNB=${xnap_gnb3}
#    Check IgNBCAconfig on 2gnb    logname=${logname}
#    Check IgNBCAconfigcellstatus on 2gnb    logname=${logname}
#    Check IgNBCAResourceStatusUpdate time interval on 2gnb    logname=${logname}
#    ${gNb1Id_DEC_list}    Get MultigNBId_DEC with HEX    gnb_list=${gnb_list_AF}
#    Check XP setup procedure    logname=${logname}   prime_gnb_index=${xnap_gnb1}    gnb_ID=${gNb1Id_DEC_list[1]}
#    ...    XP_Status=${1}
#    Check XP setup procedure    logname=${logname1}    prime_gnb_index=${xnap_gnb3}    gnb_ID=${gNb1Id_DEC_list[0]}
#    ...    XP_Status=${1}
#
#Check XP setup procedure
#    [Arguments]    ${logname}    ${prime_gnb_index}    ${gnb_ID}    ${XP_Status}
#    Check IgNBCAXpSetupRequest message    logname=${logname}    gnb_ID=${gnb_ID}
#    Check IgNBCAXpSetupResponse message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
#    Check IgNBCAconfigurationUpdateIndication message    logname=${logname}    soure_ip=${prime_gnb_index}
#
##Check wireshark log for AF 001
##    [Arguments]    ${logname}
##    ### PrimegNB log###
##    Check IgNBCAUEContextModificationFailure on PrimegNB    ${logname}
##
##Check wireshark log for AF 003
##    [Arguments]    ${logname}    ${logname1}
##    ### PrimegNB log###
##    Check 2st IgNBCAUeContextModificationRequest has the cancel CA message on PrimegNB    ${logname}
##    Check IgNBCAUeContextModificationResponse has messages on PrimegNB    ${logname}
##    ### ExtgNB log ###
##    Check IgNBCAAdditionReject message on extgNB    ${logname1}
##
##Check wireshark log for AF 003 01
##    [Arguments]    ${logname}    ${logname1}
##    ### PrimegNB log###
##    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
##    ### ExtgNB log ###
##    Check IgNBCAUeContextModificationResponse message on extgNB    logname=${logname1}
#
#Check wireshark log for AF 006
#    [Arguments]    ${logname}    ${logname1}
#    ### PrimegNB log###
#    Check IgNBCAAdditionReject message on PrimegNB    ${logname}
#    Check 2st IgNBCAUeContextModificationRequest has the cancel CA message on PrimegNB    ${logname}
#    ### extgNB log###
#    Check IgNBCAUeContextSetupFailure message on extgNB    ${logname1}
#
#Check IgNBCAAdditionReject message on PrimegNB
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 2 and nokiaxnap.procedureCode == 140
#    ...    ${xpath}=.//nokiaxnap.transport
#    Log    check IgNBCAAdditionReject message has the cause "trasport-resource-unavailable"
#    ${transport}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${transport[0]}    0
#
#Check 2st IgNBCAUeContextModificationRequest has the cancel CA message on PrimegNB
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.queryPurpose == 1
#    ...    ${xpath}=.//nokiaf1ap.queryPurpose
#    Log    check IgNBCAUeContextModificationRequest has the cancel CA message
#    ${queryPurpose}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${queryPurpose[0]}    1
#
#Check IgNBCAUeContextSetupFailure message on extgNB
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 192 and nokiaf1ap.Nokia_F1AP_PDU == 2
#    ...    ${xpath}=.//nokiaf1ap.transport
#    Log    check IgNBCAAdditionReject message has the cause "trasport-resource-unavailable"
#    ${transport}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${transport[0]}    1
#
#Check counter for AF001
#    Check the PM counter should be value
#    ...    gnb_index=${0}    counter_id=${counter_id_AF001_gNB1}    dic_path=${counter_dic_path_AF001_gNB1}
#    ...    value=${expected_value_AF_gnb1}
#
#Check counter for AF006 webui
#    sleep    40s
#    Check the PM counter should be value
#    ...    gnb_index=${0}    counter_id=${counter_id_AF006_gNB1}    dic_path=${counter_dic_path_AF006_gNB1}
#    ...    value=${expected_value_AF_gnb1}
#    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_AF006_gNB3}    dic_path=${counter_dic_path_AF006_gNB3}
#    ...    value=${expected_value_AF_gnb3}
#