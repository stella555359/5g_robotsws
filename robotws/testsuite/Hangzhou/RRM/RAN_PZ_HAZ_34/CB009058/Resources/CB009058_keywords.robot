*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiaoxia.hao@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008015/Resources/CB008015_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007737/Resources/CB007737_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
@{swconfig_enable_cprt_log}    0x590072=1    0x41001b=1    0x5901C4=1    0x420068=2
@{cell_ld_list}    3    14    15

*** Keywords ***
Suite Setup For CB009058
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}=Configuration_CB009058    ${asik_alais}=ASIK Master
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${asik_alais}
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    Power Off eNB
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Log To Console    \n***add CPRT log flag on swconfig and load scf file***
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}_${stream}.xml
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Log To Console    ${scf_file_path}
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${swconfig_enable_cprt_log}
    COAM Commission with scf file    scf_file_path=${scf_file_path}
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Suite TearDown For CB009058
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM
    Log To Console    \n***start to recover gNB and pwoer on eNB***
    Log To Console    ${timeout}
    Log    ${Golden_SCF_Path}
    robot_common_operations.Common Suite Teardown
    Power On eNB
    Get SCF File Path
    Log To Console    \n***Move CPRT log flag on swconfig***
    Connect to gnb coam via ssl    connection=${connection}
    Connect to Common Unit Master
    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    robot_common_operations.Common Suite Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections

Case SetUp For CB009058
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${asik_alais}=ASIK Master
    robot_common_operations.Common Case Setup
    Generate Test Case Log Path
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    Create Directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}


Recommission With Backup SCF File
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${backup_scf_file}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.

Case TearDown For CB009058
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    run keyword and continue on failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Ignore Error   Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    CI_interface.Common Case Teardown

#Get SCF File Path
#    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
#    ${scf_full_path}    Get Variable Value    ${scf_full_path}
#    return from keyword if    '${scf_full_path}' != 'None'
#    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
#    ${testline_name}  Get Variable Value    ${testline_name}
#    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
#    ${pattern}   Set Variable    7_5(.*)
#    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
#    ${testlinename}   Set Variable    7_5@{TLNAME}[0]
#    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename}

Check L2SP Infor From CPIF Log
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    ${l2ps_cell_infor_list}    Get L2SP Infor From On Snapshot
#    ${defalut_l2PoolI_infor}    get variable value  ${l2ps_cell_infor_list[0]}
#    ${defalut_l2PoolId}    set Variable    ${defalut_l2PoolI_infor['l2PoolId']}
     FOR    ${cell_infor}    IN     @{l2ps_cell_infor_list}
         ${dict_value}    Get Dictionary Values    ${cell_infor}
#         Should Be True    '${cell_infor['l2PoolId']}'=='${defalut_l2PoolId}'
#         Should Be True    '${cell_infor['l2PoolId']}'=='${18}'
         Should Be True    '${cell_infor['l2RtNumCellSlots']}'=='${12}'
#         ${l2Subpool_num}    Evaluate    int(${cell_infor['l2RtFirstCellSlotId']}/${24})
#         Should Be True    '${l2Subpool_num}'=='${cell_infor['l2SubpoolId']}'
     END

#Update PA Value For Tput
#    [Documentation]   Author:lei.jia@nokia-sbell.com
#    [Arguments]    ${PA_value}=0    ${AEHC_PA_value}=20
#    Run Keyword If    '${stream}'=='SBTS00'
#    ...                Adjust Attenuation To Trigger Peak Tput    PA1_value=${AEHC_PA_value}
#    ...       ELSE     Modify All Attenuation Ports Value For All RU   value=${PA_value}
#
#Adjust Attenuation To Trigger Peak Tput
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    [Arguments]       ${PA0_value}=0   ${PA1_value}=10
#    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=0
#    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=1
#    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA0_value}   RU_id=2
#    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=3
#    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA1_value}   RU_id=4
#    Sleep  2sec
#
#Modify All Attenuation Ports Value For All RU
#    [Documentation]   lei.jia@nokia-sbell.com
#    ...           Modify all atteuation ports for all RUs defined in init.py
#    ...           :param ${value}: <list> or <string>, it can be several values or only one.
#    ...           for example:
#    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
#    ...           if ${value} = 10, it will set all ports under RU to value 10.
#    [Arguments]    ${value}
#    run keyword and ignore error    COAM Teardown gnb connections
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    ${ru_index_list}  Get All RU Index
#    FOR  ${ru_index}  IN  @{ru_index_list}
#       ${RU_id}    evaluate    ${ru_index} - 1
#       gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
#        ...    value=${value}   RU_id=${RU_id}
#    END
#
#Get gNb Cu Type Value
#    [Arguments]    ${connection}=GNB_OAM
#    ${gNbCuType}    Get Variable Value    ${gNbCuType}
#    return from keyword if    '${gNbCuType}' != 'None'
#    ${gNb_CuType}   Get gNB CU type    connection=${connection}
#    Set Suite Variable    ${gNbCuType}
#
#Power Off eNB
#    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
#    [Arguments]    ${unit_index}=${0}
#    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
#    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
#    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
#    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
#    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
#    BuiltIn.Log    Reset eNB via Power off
#
#Power On eNB
#    [Arguments]    ${unit_index}=${0}
#    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
#    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
#    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
#    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
#    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
#    pdu.power_on    port=${enb_pdu_port}    pdu_device=enb_pdu

Get L2SP Infor From On Snapshot
    [Arguments]   ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM    ${mr_bts_id}=${tl.gnbs[0].instance_id}    ${timeout}=1800
    ${abio_runtime_path}    set variable if    'SBTS00' in '${stream}'    1011    2011
    ${cprt_runtime_path}    set variable if    'SBTS00' in '${stream}'    1515    2511
    ${nrCellIdentity_id_list}    Get nrCellIdentity form BTS by NRCELL id
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    COAM Save snapshot via rest api    connection=${connection}    timeout=${timeout}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    FOR    ${index}    IN RANGE    1    10
        ${zip_flie_name}    set variable    BTS${mr_bts_id}_${abio_runtime_path}_part_${index}.zip
        extract zip file    ${snapshot_unzip_file_path}/${zip_flie_name}  ${snapshot_unzip_file_path}
        ${status}    Run Keyword And Return Status
        ...          extract zip file    ${snapshot_unzip_file_path}/BTS${mr_bts_id}_${cprt_runtime_path}_runtime.zip  ${snapshot_path}
        Exit For Loop If    ${status}
    END
    @{l2ps_cell_infor_list}    create list
    ${cmd}     Catenate
    ...    rm -rf ${snapshot_unzip_file_path};cd ${snapshot_path};xzcat runtime_cp_rt.log.xz |
    ...    grep -i 'Received from CM cprt::cm.*CellMappingList.*fhMode.*ECPRI'
    ${scellmaping_output}    Run     command=${cmd}
    ${cellsmaping_infor}    get regexp matches    ${scellmaping_output}   CellMappingList.*dlSubcellType
    FOR    ${cellmaping_infor}    IN    @{cellsmaping_infor}
        ${cellmaping_infor_new}    replace string using regexp    ${cellmaping_infor}    "    ${EMPTY}
        ${nrCellIdentity_value}    get regexp matches    ${cellmaping_infor_new}    nrCellIdentity\\W\\d+
        ${nrCellIdentity_id}    Split String    ${nrCellIdentity_value}[0]    :
        ${status}    run keyword and return status    List Should Contain Value   ${nrCellIdentity_id_list}    ${nrCellIdentity_id}[-1]
        Continue For Loop If    not ${status}
        ${l2Subpool_value}    get regexp matches    ${cellmaping_infor_new}    l2SubpoolId\\W\\d+
        ${l2Pool_value}    get regexp matches    ${cellmaping_infor_new}    l2PoolId\\W\\d+
        ${l2RtFirstCellSlot_value}    get regexp matches    ${cellmaping_infor_new}    l2RtFirstCellSlotId\\W\\d+
        ${l2RtNumCellSlots_value}    get regexp matches    ${cellmaping_infor_new}    l2RtNumCellSlots\\W\\d+
        ${l2Subpool_id}     Split String    ${l2Subpool_value}[0]    :
        ${l2Pool_id}     Split String    ${l2Pool_value}[0]    :
        ${l2RtFirstCellSlot_id}     Split String    ${l2RtFirstCellSlot_value}[0]    :
        ${l2RtNumCellSlots_id}     Split String    ${l2RtNumCellSlots_value}[0]    :
        ${l2ps_cell_infor_dict}     Create Dictionary
        Set To Dictionary    ${l2ps_cell_infor_dict}    nrCellIdentity    ${nrCellIdentity_id}[-1]
        Set To Dictionary    ${l2ps_cell_infor_dict}    l2SubpoolId    ${l2Subpool_id}[-1]
        Set To Dictionary    ${l2ps_cell_infor_dict}    l2PoolId    ${l2Pool_id}[-1]
        Set To Dictionary    ${l2ps_cell_infor_dict}    l2RtFirstCellSlotId    ${l2RtFirstCellSlot_id}[-1]
        Set To Dictionary    ${l2ps_cell_infor_dict}    l2RtNumCellSlots    ${l2RtNumCellSlots_id}[-1]
        append to list    ${l2ps_cell_infor_list}    ${l2ps_cell_infor_dict}
    END
    [Return]    ${l2ps_cell_infor_list}

Get nrCellIdentity form BTS by NRCELL id
    [Arguments]     ${cell_list}=${cell_ld_list}
    @{nrCellIdentity_id_list}    create list
    Connect to gnb coam via ssl    connection=GNB_OAM
    ${subcells_info}    coam.get_subcells_info    connection=GNB_OAM
    FOR    ${cell_id}  IN    @{cell_list}
        ${nrcell_dict}    set variable    ${subcells_info['NRCELLGRP-${cell_id}']}
        ${nrcell_id_list}    get dictionary keys    ${nrcell_dict}
        ${nrCellIdentity_value}    set variable    ${nrcell_dict['${nrcell_id_list}[0]']['NRCELL_R']['parameters']['nrCellIdentity']}
        ${nrCellIdentity_value_new}    Convert To String    ${nrCellIdentity_value}
        append to list    ${nrCellIdentity_id_list}    ${nrCellIdentity_value_new}
    END
    [Return]     ${nrCellIdentity_id_list}
