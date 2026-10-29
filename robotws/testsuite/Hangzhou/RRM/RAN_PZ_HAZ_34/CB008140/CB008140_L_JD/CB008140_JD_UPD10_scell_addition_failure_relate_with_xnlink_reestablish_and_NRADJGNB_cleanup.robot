#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_L_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-JD
#
#Suite Setup    Run Keywords
#...    Common Suite Setup for COAM    AND
#...    Adjust gNB_RU Attenuation
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM    gnb_list=@{gnb_list_JD}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${filename_JD010_gnb0}    log_name_JD_010_gNB1.pcap
#${filename_JD010_gnb2}    log_name_JD_010_gNB3.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#@{gnb_ips_JD}    ${bts_host0}    ${bts_host2}
#@{scell_index_list_L011}    ${11}
#@{extgnb_index_list_L011}    ${2}
#@{filename_JD010}    filename_JD010_gnb
#@{gnb_list_JD}    ${0}    ${2}
#${Send_Tput_DL_F_F}    1000M
#${expected_tput_dl_F}    390
#
#*** Test Cases ***
#[1]CB008140-JD_UPD010_online_modify_With_NRADJGNB_from_no_related_NRREL_to_related_interGNB_NRREL_and_check_MOC_status
#    [Documentation]    This user scenario describes if NRADJGNB is config with gnbcontroled, and when Xn link failued
#    ...    with xnLinkReestabTmr expiry , the NRADJGNB Will be remove, and when NRADJGNB is related with NRREL of
#    ...    intergnb CA, Then even Xn link failued with xnLinkReestabTmr expiry , the NRADJGNB MOC will not remove
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for UPD010
#    ${NRADJ_gnb3}    GET NRADJGNB Index
#    Online modify NIDD on gnb    gnb_index=${2}    Modify_Para_Online=${Modify_Para_Online_UPD10_lock}
#    sleep    70s
#    Check NRADJGNB List    gnb_index=${0}    Remove_NRADJGNB=OK    need_NRADJ=${NRADJ_gnb3}
#    Online modify NIDD on gnb    gnb_index=${2}    Modify_Para_Online=${Modify_Para_Online_UPD10_Unlock}
#    ${NRADJ_gnb3_unlock1}    GET NRADJGNB Index
#    sleep    70s
#    Check NRADJGNB List    gnb_index=${0}    Remove_NRADJGNB=NOK    need_NRADJ=${NRADJ_gnb3_unlock1}
#    ${Modify_Para_Online_UPD10_1}    Create Online Parameter    NRADJ=${NRADJ_gnb3_unlock1}    value1=${2}    value2=${5}
#    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_UPD10_1}
#    ...    Add_Para_Online=${Add_Para_Online_UPD10}
#    Online modify NIDD on gnb    gnb_index=${2}    Modify_Para_Online=${Modify_Para_Online_UPD10_lock}
#    sleep    70s
#    Check NRADJGNB List    gnb_index=${0}    Remove_NRADJGNB=NOK    need_NRADJ=${NRADJ_gnb3_unlock1}
#    Online modify NIDD on gnb    gnb_index=${2}    Modify_Para_Online=${Modify_Para_Online_UPD10_Unlock}
#    sleep    70s
#    Check NRADJGNB List    gnb_index=${0}    Remove_NRADJGNB=NOK    need_NRADJ=${NRADJ_gnb3_unlock1}
#    Lock/Unlock other cell    lock_unlock=lock
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}
#    MultiUE.Prepare UE
#    Start capture multi gNB log    filename=filename_JD010_gnb    gnb_list=${gnb_list_JD}
#    MultiUE.Attach
#    sleep    5s
#    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb3_cell1_value=${0}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F_F}    duration=1200
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
#    ...    pcellid=1    scellid=11    gnb_prime=${0}    gnb_external=${2}
#    MultiUE.Stop DL Traffic
#    MultiUE.detach
#    Stop capture multi gNB log    filename=filename_JD010_gnb    gnb_list=${gnb_list_JD}
#    Hanging resource test    gnb_ips=@{gnb_ips_JD}    gnb_list=@{gnb_list_JD}
#    [Teardown]    run keywords
#    ...    Lock/Unlock other cell    lock_unlock=Unlock    AND
#    ...    Case Teardown    filename=${filename_JD010}    gnb_list=@{gnb_list_JD}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for UPD010
#    @{scf_list}    Create List
#    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${golden_scf_name_gnb0}    MOsToAdd=${MOS_ADD_GNB1_UPD010}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_UPD010}    ListToAdd=${LIST_TO_ADD_GNB1_UPD010}
#    Append to List    ${scf_list}    ${scf_gnb0}
#    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_UPD010}
#    Append to List    ${scf_list}    ${scf_gnb2}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_JD}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_JD}
#
#Lock/Unlock other cell
#    [Documentation]
#    ...    ${lock_unlock} should be lock or Unlock
#    [Arguments]    ${lock_unlock}=lock
#    Common Case TestLine Setup with singe BTS    gnb_index=${0}    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${Modify_Para_Online_UPD10_Gnb1_${lock_unlock}}
#    Common Case TestLine Setup with singe BTS    gnb_index=${2}    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${Modify_Para_Online_UPD10_Gnb3_${lock_unlock}}
#    sleep    30s
#
#Check NRADJGNB List
#    [Arguments]    ${gnb_index}=${0}    ${Remove_NRADJGNB}=OK    ${need_NRADJ}=NRADJGNB-11
#    Connect to gnb coam via ssl    connection=gNB${gnb_index}    gnb_index=${gnb_index}
#    ${NRADJGNB_List}    coam.get_managed_objects    class_name=NRADJGNB_A    connection=gNB${gnb_index}    timeout=60s
#    @{NRADJGNB_ALL}    Create List
#    FOR    ${index}    IN    @{NRADJGNB_List}
#        ${NRADJGNB}    Get From Dictionary    ${index}    distName
#        ${string}    Split String    ${NRADJGNB}    /
#        ${NRADJ_need}    Remove String    ${string[-1]}    _A
#        Append to List    ${NRADJGNB_ALL}    ${NRADJ_need}
#    END
#    Run keyword If    '${Remove_NRADJGNB}'=='NOK'    Should Contain Any   ${NRADJGNB_ALL}    ${need_NRADJ}
#    ...    Should Not Contain Any   ${NRADJGNB_ALL}    ${need_NRADJ}
#    [Teardown]    coam.teardown    connection=gNB${gnb_index}
#
#GET NRADJGNB Index
#   [Arguments]    ${gnb_index}=${0}    ${NRADJ_BTSID}=${gnb_instance2}
#    Connect to gnb coam via ssl    connection=gNB${gnb_index}    gnb_index=${gnb_index}
#    ${NRADJGNB_List}    coam.get_managed_objects    class_name=NRADJGNB_A    connection=gNB${gnb_index}    timeout=60s
#    FOR    ${NRADJ}    IN    @{NRADJGNB_List}
#        ${parameters}    Get From Dictionary    ${NRADJ}    parameters
#        ${gNodeBId}    Get From Dictionary    ${parameters}    gNodeBId
#        ${NRADJGNB}    Run keyword if    '${gNodeBId}'=='${NRADJ_BTSID}'
#        ...    Get From Dictionary    ${nradj}    distName
#        Exit For Loop if    '${gNodeBId}'=='${NRADJ_BTSID}'
#    END
#    ${string}    Split String    ${NRADJGNB}    /
#    ${NRADJ_need}    Remove String    ${string[-1]}    _A
#    [Teardown]    coam.teardown    connection=gNB${gnb_index}
#    [Return]    ${NRADJ_need}
#
#Create Online Parameter
#    [Arguments]    ${NRADJ}=NRADJGNB-13    ${value1}=${1}    ${value2}=${1}
#    @{Modify_Para_Online}    Create List
#    &{parameter}    Create Dictionary    dist_name=MRBTS-${gnb_instance0}/NRBTS-${gnb_instance0}
#    ...    parameter=weightForIgnbCaSelection    value=${value1}
#    Append To List    ${Modify_Para_Online}    ${parameter}
#    &{parameter1}    Create Dictionary    dist_name=MRBTS-${gnb_instance0}/NRBTS-${gnb_instance0}/${NRADJ}
#    ...    parameter=weightForIgnbCaSelection    value=${value2}
#    Append To List    ${Modify_Para_Online}    ${parameter1}
#    [Return]    ${Modify_Para_Online}
