*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB008898

Resource      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008247/Resources/CB008247_case_steps_SG3.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/spark_multiUE.robot

*** Variables ***
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${dl_throughput}    300M
@{beamSetType}    DFTNORMAL    DFTNORMAL
${NSA_attach_mode}          5G_NSA
${SA_attach_mode}           5G_SA
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${frequency_364}    2600_0.25_ALL | 0DB~90DB
@{gnb_id}    10175    11006
${APN_36411}    ${tl.ues[0].pdn}
${APN_10175}    ${tl.ues[0].pdn}
${ue_mode_36411}    yiyuan
${ue_mode_10175}    NULL
${process_num_10175}    ${4}
${process_num_36411}    ${3}
${PCI_filter_trunk}    DlData_PdschGrantL1sw.pdschScramblingSeqInit
${PCI_filter_ntrunk}    DlData_PdschGrant.pdschScramblingSeqInit
${xpath_trunk}    DlData_PdschGrantL1sw
${xpath_ntrunk}    DlData_PdschGrant
${filter_trunk}    dldata_pdschsendreql1sw
${filter_ntrunk}    dldata_pdschsendreq



*** Keywords ***
Common_suite_Setup_12192
    Common Suite Setup for COAM
    ${release_info}    Get gnb_release title for SCF
    set suite variable    ${release_info}

Get gnb_release title for SCF
    [Documentation]    the keyword return realse format : SBTS24R3_ENB_9999
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${gnb_release}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    set suite variable    ${gnb_release}
    [Return]    ${gnb_release}
    [Teardown]   csn.Disconnect   connection=release_info

Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${ParameterToDelete}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    Delete_Para_Online=${ParameterToDelete}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

prepare UE and MCS
    [Arguments]
    Log to console    \n*** prepare MCS ***
    MCS SETUP AND SET ATT
    Prepare MultiUE with client

prepare MultilUE and MCS
    [Arguments]    ${att_value}=${90}    ${vertical}=${96}    ${horizontal}=${15}
    ...            ${UE_mode}=5G_SA
    Log to console    step2 prepare UE and MCS
    Prepare and setup MCS
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${vertical}    horizontal=${horizontal}
    run keyword if    '${gnb_instance0}' == '10175'
    ...            spark_MultiUE.Prepare UE
    ...    ELSE    Prepare pioneer_MultiUE new version    UE_mode=${UE_mode}
#    Prepare MultiUE with client

Prepare and setup MCS
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='topyoung'
    ...    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${frequency_364}

MCS SET ATT AND PHASE
    [Arguments]
    ...    ${att_value}=${90}    ${vertical}=${96}    ${horizontal}=${15}
    Log to console    Set MCS PA
    Run keyword if    '${mcs_type}'=='haojin'
    ...    HAOJIN MCS SETUP AND SET ATT for UE0    mcs_type=${mcs_type}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${vertical}       horizontal_1=${horizontal}
    ...    P3_out=${15}    P4_out=${16}    horizontal_2=${${horizontal}+${5}}    vertical_2=${vertical}
    ...    att_value=${att_value}
    Run keyword if    '${mcs_type}'=='hbte'
    ...    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${vertical}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${horizontal}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${horizontal}


MCS SETUP AND SET ATT
    [Arguments]
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    att_value_1=${25}     att_value_2=${25}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    att_value1=${10}    att_value2=${15}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}
    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    frequency=None    att_value1=${0}    att_value2=${0}    vertical_angle=${-6}
    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${-5}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${-15}

Start multi UE traffic
    [Arguments]    ${UE_NUM}=${1}    ${dl_port}=${DL_PORT}    ${dl_throughput}=${dl_throughput}
    ...    ${process_num}=${process_num_${gnb_instance0}}
    FOR    ${index}    IN RANGE   ${UE_NUM}
        Start MUE dltraffic with appserver      ue_addr=${${uegroup}[${index}]_IP}    dl_port=${dl_port}
        ...    dl_throughput=${dl_throughput}    process_num=${process_num}
        ${dl_port}    Evaluate    ${dl_port}+100
    END

Detech and stop UL traffic
    [Arguments]    ${ues_index}=${0}
    Run Keyword And Ignore Error    Stop UL Data Transfer with pioneer client for one UE    ues_index=${ues_index}
    Run Keyword And Ignore Error    Detach MultiUE    ue=${uegroup}[${ues_index}]

Stop UL Data Transfer with pioneer client for one UE
    [Arguments]    ${ues_index}=${0}
    Run Keyword And Continue On Failure    client.stopultraffic    until_timeout=${300}    ue=${uegroup}[${ues_index}]

Check the PM counter update
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
#    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
#    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
#    ...    ${timeout}=120
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${value}[0]
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${value}[1]
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${value}[2]
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${value}[3]
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${value}[4]
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${value}[5]
#    ${counter_lenth}    Get Length    ${counter_id}
#    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
#    FOR    ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#         ...    dic_path=${dic_path[${index}]}    date=${date}    timeout=${timeout}
#        Should be equal    ${counter_value[0]}    ${value[${index}]}
#    END
#    [Teardown]    COAM Teardown gnb connections

Check UL_tput for spark_multiUE
    [Arguments]    ${ue_index}    ${tput_target}    ${tput_direction}=MACUL
    ${UL_traffic}    Spark_multiUE.get traffic from ue side    ue_index=${ue_index}    tput_direction=${tput_direction}
    should be true     ${UL_traffic} > ${tput_target}


stop and detach spark ue
    [Arguments]    ${ue_index}=${0}
    Spark_multiUE.stop UL traffic    ue_index=${ue_index}
    Spark_multiUE.detach UE    ue_index=${ue_index}

