*** Settings ***
Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_L_variables_2gnb.py

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008140-JD

Suite Setup    Run Keywords
...    Common Suite Setup for COAM    AND
...    Adjust gNB_RU Attenuation for 2gnb    AND
...    Get sagnb release    AND
...    Common Case TestLine Setup for UPD010

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM    gnb_list=@{gnb_list_JD}    AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections



*** Variables ***
${scf_path}    /opt/workspace/SCF/
${golden_scf_name_gnb0}    SCF_GNB1
${golden_scf_name_gnb1}    SCF_GNB2
${filename_JD010_gnb0}    log_name_JD_010_gNB1.pcap
${filename_JD010_gnb1}    log_name_JD_010_gNB2.pcap
${filename1_JD010_gnb0}    log1_name_JD_010_gNB1.pcap
${filename1_JD010_gnb1}    log1_name_JD_010_gNB2.pcap
${filename2_JD010_gnb0}    log2_name_JD_010_gNB1.pcap
${filename2_JD010_gnb1}    log2_name_JD_010_gNB2.pcap
${filename3_JD010_gnb0}    log3_name_JD_010_gNB1.pcap
${filename3_JD010_gnb1}    log3_name_JD_010_gNB2.pcap
${filename4_JD010_gnb0}    log4_name_JD_010_gNB1.pcap
${filename4_JD010_gnb1}    log4_name_JD_010_gNB2.pcap
${filename5_JD010_gnb0}    log5_name_JD_010_gNB1.pcap
${filename5_JD010_gnb1}    log5_name_JD_010_gNB2.pcap
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
@{gnb_ips_JD}    ${bts_host0}    ${bts_host1}
@{scell_index_list_JD}    ${2}
@{extgnb_index_list_JD}    ${1}
@{scell_index_list_JD_gnb1}    ${1}
@{extgnb_index_list_JD_gnb1}    ${0}
@{gnb_list_JD}    ${0}    ${1}
${Send_Tput_DL_F_F}    250M
${expected_tput_dl_F}    390
@{value_M55199C00001}    ${1}
@{value_M55199C00001_update}    ${3}
@{enb_cell1_38711}    372    375    376
@{enb_cell1_38611}    362    365
@{value_none}    ${None}
@{filename_JD010}    filename_JD010_gnb    filename1_JD010_gnb    filename2_JD010_gnb    filename3_JD010_gnb
...    filename4_JD010_gnb    filename5_JD010_gnb

*** Test Cases ***
[1]CB008140-JD_UPD010_online_modify_With_NRADJGNB_from_no_related_NRREL_to_related_interGNB_NRREL_and_check_MOC_status
    [Documentation]    This user scenario describes if NRADJGNB is config with gnbcontroled, and when Xn link failued
    ...    with xnLinkReestabTmr expiry , the NRADJGNB Will be remove, and when NRADJGNB is related with NRREL of
    ...    intergnb CA, Then even Xn link failued with xnLinkReestabTmr expiry , the NRADJGNB MOC will not remove
    [Tags]     classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
#    Start BTSlogs Collection
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Comment    20251225 before run case ,disable 8927 and 14474(result in peak drop 7M)
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_disable8927_14474_GNB1}
    ...    Delete_Para_Online=${parameters_to_delete_disable8927_14474_GNB1}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell2_value=${0}
    MultiUE.Prepare UE
    ###XN OAMControled, XN failure then reestablish, MOC is not deleted, PM object should not be deleted
    Log to console    \n*** step1 XN OAMControled, MOC is not deleted, PM object should not be deleted ***
    Check M55199C00001 should be update    filename=filename_JD010_gnb    value=${value_M55199C00001}
    Lock/Unlock NRADJGNB And check MOC update    update=False
    Check M55199C00001 should be update    filename=filename1_JD010_gnb    value=${value_M55199C00001}
    Check the PM counter should be/not be update
    ...    gnb_index=${1}    counter_id=${counter_id_JD_M55199C00001}    dic_path=${counter_dic_path_JD_M55199C00001}
    ...    value=${value_M55199C00001_update}
#    Stop Btslogs Collection

    ### XN OAMControled, NRADJGNB MOC is deleted, PM object should be deleted
    Log to console    \n*** step2 XN OAMControled, NRADJGNB MOC is deleted, PM object should be deleted ***
    ${NRADJ_gnb2_before_delete}    GET NRADJGNB Index    gnb_index=${1}    NRADJ_BTSID=${gnb_instance0}
    Online modify NIDD on gnb    gnb_index=${1}    Delete_Mo_Online=${Delete_Mo_Online_UPD10}
    sleep    20s
    Online modify NIDD on gnb    gnb_index=${1}    Add_Mo_Online=${Add_Mo_Online_UPD10_NRADJGNB}
    ${NRADJ_gnb2_after_delete}    Wait Until Keyword Succeeds    10min    10s
    ...    GET NRADJGNB Index    gnb_index=${1}    NRADJ_BTSID=${gnb_instance0}
    Should not be Equal    ${NRADJ_gnb2_after_delete}    ${NRADJ_gnb2_before_delete}
    ${counter_dic_Auto1}    Create counter dict    NRADJ=${NRADJ_gnb2_after_delete}    gnb_instance=${gnb_instance1}
    ${date}    Check M55199C00001 should be update    filename=filename3_JD010_gnb    value=${value_M55199C00001}
    ...    dic_path=${counter_dic_Auto1}
    Check the PM counter should be None
    ...    gnb_index=${1}    counter_id=${counter_id_JD_M55199C00001}    dic_path=${counter_dic_path_JD_M55199C00001}
    ...    date=${date[0]}/${date[1]}/${date[2]}/${date[3]}/${date[4]}/00

    ### XN GNBControled, XN Lock/unlock, MOC is deleted, PM object should be deleted
    Log to console    \n*** step3 XN GNBControled, XN Lock/unlock, MOC is deleted, PM object should be deleted ***
    ${NRADJ_gnb2_unlock1_Auto2}    Lock/Unlock NRADJGNB And check MOC update    update=True
    ...    gnb_index_lock=${0}    gnb_index_check_NRADJ=${1}
    ...    lock_remove=OK    unlock_remove=NOK    NRADJ_BTSID=${gnb_instance0}
    ...    Modify_Para_Online_lock=${Modify_Para_Online_UPD10_lock_gnb1}
    ...    Modify_Para_Online_unlock=${Modify_Para_Online_UPD10_Unlock_gnb1}
    ${counter_dic_Auto2}    Create counter dict    NRADJ=${NRADJ_gnb2_unlock1_Auto2}    gnb_instance=${gnb_instance1}
    ${date}    Check M55199C00001 should be update    filename=filename4_JD010_gnb    value=${value_M55199C00001}
    ...    dic_path=${counter_dic_Auto2}
    Check the PM counter should be None
    ...    gnb_index=${1}    counter_id=${counter_id_JD_M55199C00001}    dic_path=${counter_dic_path_JD_M55199C00001}
    ...    date=${date[0]}/${date[1]}/${date[2]}/${date[3]}/${date[4]}/00
    Check the PM counter should be None
    ...    gnb_index=${1}    counter_id=${counter_id_JD_M55199C00001}    dic_path=${counter_dic_Auto1}
    ...    date=${date[0]}/${date[1]}/${date[2]}/${date[3]}/${date[4]}/00

    ### XN GNBControled, and has NRREL as primergnb, exter-gnb XN Lock/unlock, MOC is not deleted, PM object should not be deleted
    Log to console    \n*** step4 XN GNBControled, and has NRREL as primergnb, XN Lock/unlock, MOC is not deleted ***
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${Modify_Para_Online_UPD10_3}
    Online modify NIDD on gnb    gnb_index=${1}
    ...    Modify_Para_Online=${Modify_Para_Online_UPD10_3_gnb2}    Add_Mo_Online=${Add_Mo_Online_UPD10_NRREL_gnb2}
    ${NRADJ_gnb2_unlock1_Auto3}    Lock/Unlock NRADJGNB And check MOC update    update=True
    ...    gnb_index_lock=${0}    gnb_index_check_NRADJ=${1}
    ...    lock_remove=OK    unlock_remove=NOK    NRADJ_BTSID=${gnb_instance0}
    ...    Modify_Para_Online_lock=${Modify_Para_Online_UPD10_lock_gnb1}
    ...    Modify_Para_Online_unlock=${Modify_Para_Online_UPD10_Unlock_gnb1}
    ${Modify_Para_Online_UPD10_1}    Create Online Parameter    NRADJ=${NRADJ_gnb2_unlock1_Auto3}    value1=${2}    value2=${5}
    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Para_Online_UPD10_1}
    ...    Add_Para_Online=${Add_Para_Online_UPD10}
    Lock/Unlock NRADJGNB And check MOC update    update=False
    ...    gnb_index_lock=${0}    gnb_index_check_NRADJ=${1}
    ...    lock_remove=NOK    unlock_remove=NOK    NRADJ_BTSID=${gnb_instance0}
    ...    Modify_Para_Online_lock=${Modify_Para_Online_UPD10_lock_gnb1}
    ...    Modify_Para_Online_unlock=${Modify_Para_Online_UPD10_Unlock_gnb1}
    Check M55199C00001 should be update    filename=filename5_JD010_gnb    value=${value_M55199C00001}
    ...    dic_path=${counter_dic_path_JD_M55199C00001_gnb1}
    ...    pcellid=2    scellid=1    gnb_prime=${1}    gnb_external=${0}
    ...    extgnb_index_list=${extgnb_index_list_JD_gnb1}    scell_index_list=${scell_index_list_JD_gnb1}
#    Hanging resource test    gnb_ips=@{gnb_ips_JD}    gnb_list=@{gnb_list_JD}
    [Teardown]    run keywords
    ...    MultiUE.Detach    AND
    ...    Lock/Unlock other cell    lock_unlock=Unlock    AND
    ...    Case Teardown    filename=${filename_JD010}    gnb_list=@{gnb_list_JD}    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

*** Keywords ***
Common Case TestLine Setup for UPD010
    @{scf_list}    Create List
    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${golden_scf_name_gnb0}_${release_info}.xml    MOsToAdd=${MOS_ADD_GNB1_UPD010}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_UPD010}    ListToAdd=${LIST_TO_ADD_GNB1_UPD010}
    Append to List    ${scf_list}    ${scf_gnb0}
    Append to List    ${scf_list}    ${scf_path}${golden_scf_name_gnb1}_${release_info}.xml
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_JD}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list_JD}
    FOR    ${cell}    IN    @{enb_cell1_${gnb_instance0}}
        Connect and Modify the parameter on enblte
        ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${cell}
        ...    parameter=administrativeState     value=locked
    END

Lock/Unlock other cell
    [Documentation]
    ...    ${lock_unlock} should be lock or Unlock
    [Arguments]    ${lock_unlock}=lock
    Common Case TestLine Setup with singe BTS    gnb_index=${0}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online_UPD10_Gnb1_${lock_unlock}}
    sleep    30s

Check NRADJGNB List
    [Arguments]    ${gnb_index}=${0}    ${Remove_NRADJGNB}=OK    ${need_NRADJ}=NRADJGNB-11
    Connect to gnb coam via ssl    connection=gNB${gnb_index}    gnb_index=${gnb_index}
    ${NRADJGNB_List}    coam.get_managed_objects    class_name=NRADJGNB_A    connection=gNB${gnb_index}    timeout=60s
    @{NRADJGNB_ALL}    Create List
    FOR    ${index}    IN    @{NRADJGNB_List}
        ${NRADJGNB}    Get From Dictionary    ${index}    distName
        ${string}    Split String    ${NRADJGNB}    /
        ${NRADJ_need}    Remove String    ${string[-1]}    _A
        Append to List    ${NRADJGNB_ALL}    ${NRADJ_need}
    END
    Run keyword If    '${Remove_NRADJGNB}'=='NOK'    Should Contain Any   ${NRADJGNB_ALL}    ${need_NRADJ}
    ...    Should Not Contain Any   ${NRADJGNB_ALL}    ${need_NRADJ}
    [Teardown]    coam.teardown    connection=gNB${gnb_index}

GET NRADJGNB Index
   [Arguments]    ${gnb_index}=${0}    ${NRADJ_BTSID}=${gnb_instance1}
    Connect to gnb coam via ssl    connection=gNB${gnb_index}    gnb_index=${gnb_index}
    ${NRADJGNB_List}    coam.get_managed_objects    class_name=NRADJGNB_A    connection=gNB${gnb_index}    timeout=60s
    FOR    ${NRADJ}    IN    @{NRADJGNB_List}
        ${parameters}    Get From Dictionary    ${NRADJ}    parameters
        ${gNodeBId}    Get From Dictionary    ${parameters}    gNodeBId
        ${NRADJGNB}    Run keyword if    '${gNodeBId}'=='${NRADJ_BTSID}'
        ...    Get From Dictionary    ${nradj}    distName
        Exit For Loop if    '${gNodeBId}'=='${NRADJ_BTSID}'
    END
    ${string}    Split String    ${NRADJGNB}    /
    ${NRADJ_need}    Remove String    ${string[-1]}    _A
    [Teardown]    coam.teardown    connection=gNB${gnb_index}
    [Return]    ${NRADJ_need}

Create Online Parameter
    [Arguments]    ${NRADJ}=NRADJGNB-13    ${value1}=${1}    ${value2}=${1}
    @{Modify_Para_Online}    Create List
    &{parameter}    Create Dictionary    dist_name=MRBTS-${gnb_instance1}/NRBTS-${gnb_instance1}
    ...    parameter=weightForIgnbCaSelection    value=${value1}
    Append To List    ${Modify_Para_Online}    ${parameter}
    &{parameter1}    Create Dictionary    dist_name=MRBTS-${gnb_instance1}/NRBTS-${gnb_instance1}/${NRADJ}
    ...    parameter=weightForIgnbCaSelection    value=${value2}
    Append To List    ${Modify_Para_Online}    ${parameter1}
    [Return]    ${Modify_Para_Online}

Create counter dict
    [Arguments]    ${NRADJ}=NRADJGNB-13    ${gnb_instance}=${gnb_instance1}    ${global2_id}=${tl.gnbs[1].global_bts_id}
    ${NRADJ_ID}     set variable    ${NRADJ.split('-')[1]}
    @{counter_dic}    Create List    BTS/MRBTS-${global2_id}/NRBTS-${gnb_instance}/NRADJ-${NRADJ_ID}/MCC-310/MNC-260/AGNBM
    [Return]    ${counter_dic}

Check M55199C00001 should be update
    [Arguments]    ${filename}    ${CA_OK}=True    ${value}=${value_M55199C00001}
    ...    ${dic_path}=${counter_dic_path_JD_M55199C00001}
    ...    ${pcellid}=1    ${scellid}=2    ${gnb_prime}=${0}    ${gnb_external}=${1}
    ...    ${extgnb_index_list}=${extgnb_index_list_JD}    ${scell_index_list}=${scell_index_list_JD}
    Lock/Unlock other cell    lock_unlock=lock
    Prepare with PM counter time to caculate    period=start
    ${date}=    Get Time    year month day hour min
    Attach and start traffic and check CA addition    filename=${filename}     CA_OK=${CA_OK}
    ...    pcellid=${pcellid}    scellid=${scellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}
    ...    extgnb_index_list=${extgnb_index_list}    scell_index_list=${scell_index_list}
    Prepare with PM counter time to caculate    period=end
    sleep    40s
    Check the PM counter should be value
    ...    gnb_index=${gnb_external}    counter_id=${counter_id_JD_M55199C00001}    dic_path=${dic_path}
    ...    value=${value}
    [Teardown]    Lock/Unlock other cell    lock_unlock=Unlock
    [Return]    ${date}

Check M55199C00001 should not be update
    [Arguments]
    Lock/Unlock other cell    lock_unlock=lock
    Prepare with PM counter time to caculate    period=start
    ${date}=    Get Time    year month day hour min
    ${NRADJ_gnb2_before_delete}    GET NRADJGNB Index    gnb_index=${1}    NRADJ_BTSID=${gnb_instance0}
    Online modify NIDD on gnb    gnb_index=${1}    Delete_Mo_Online=${Delete_Mo_Online_UPD10}
    sleep    70s
    ${NRADJ_gnb2_after_delete}    GET NRADJGNB Index    gnb_index=${1}    NRADJ_BTSID=${gnb_instance0}
    Should not be Equal    ${NRADJ_gnb2_after_delete}    ${NRADJ_gnb2_before_delete}
    [Teardown]    Lock/Unlock other cell    lock_unlock=Unlock
    [Return]    ${NRADJ_gnb2_after_delete}

Attach and start traffic and check CA addition
    [Arguments]    ${filename}    ${CA_OK}=True
    ...    ${tput_dl_pcell}=${expected_tput_dl_F}    ${tput_dl_scell}=${expected_tput_dl_F}
    ...    ${pcellid}=1    ${scellid}=2    ${gnb_prime}=${0}    ${gnb_external}=${1}
    ...    ${extgnb_index_list}=${extgnb_index_list_JD}    ${scell_index_list}=${scell_index_list_JD}
    ...    ${logname}=${${filename}${gnb_prime}}
    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_JD}
    MultiUE.Attach
    sleep    5s
    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F_F}    duration=1200    process_num=${5}
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}
    ...    pcellid=${pcellid}    scellid=${scellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}
    MultiUE.Stop DL Traffic
    MultiUE.Detach
    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_JD}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${pcellid}    scell_index_list=${scell_index_list}
    ...    Primegnb_index=${gnb_prime}    extgnb_index_list=${extgnb_index_list}
    ...    UEContextModificationResponse_nums=${3}    CA_OK=${CA_OK}

Lock/Unlock NRADJGNB And check MOC update
    [Arguments]    ${update}=True    ${gnb_index_lock}=${1}    ${gnb_index_check_NRADJ}=${0}
    ...    ${lock_remove}=NOK    ${unlock_remove}=NOK    ${NRADJ_BTSID}=${gnb_instance1}
    ...    ${Modify_Para_Online_lock}=${Modify_Para_Online_UPD10_lock}
    ...    ${Modify_Para_Online_unlock}=${Modify_Para_Online_UPD10_Unlock}
    ${NRADJ_gnb2}    GET NRADJGNB Index    gnb_index=${gnb_index_check_NRADJ}    NRADJ_BTSID=${NRADJ_BTSID}
    Online modify NIDD on gnb    gnb_index=${gnb_index_lock}    Modify_Para_Online=${Modify_Para_Online_lock}
    sleep    70s
    Check NRADJGNB List    gnb_index=${gnb_index_check_NRADJ}    Remove_NRADJGNB=${lock_remove}    need_NRADJ=${NRADJ_gnb2}
    Online modify NIDD on gnb    gnb_index=${gnb_index_lock}    Modify_Para_Online=${Modify_Para_Online_unlock}
    sleep    70s
    ${NRADJ_gnb2_unlock1}    GET NRADJGNB Index    gnb_index=${gnb_index_check_NRADJ}    NRADJ_BTSID=${NRADJ_BTSID}
    Check NRADJGNB List    gnb_index=${gnb_index_check_NRADJ}    Remove_NRADJGNB=${unlock_remove}    need_NRADJ=${NRADJ_gnb2_unlock1}
    Run keyword If    ${update}==True    Should Not Be Equal    ${NRADJ_gnb2}    ${NRADJ_gnb2_unlock1}
    ...    ELSE    Should Be Equal    ${NRADJ_gnb2}    ${NRADJ_gnb2_unlock1}
    [Return]    ${NRADJ_gnb2_unlock1}

Check the PM counter should be/not be update
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
        ...    dic_path=${dic_path[${index}]}
        ${sum}    Evaluate    sum(${counter_value})    modules=builtins
        should be equal as numbers    ${sum}    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter should be None
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${date}=all
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    date=${date}
        Should Be Equal As Strings    ${counter_value}    ${None}
    END
    [Teardown]    COAM Teardown gnb connections
