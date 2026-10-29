*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:lei.jia@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008360/Resources/aaslog_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Tool/gnb_logs.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
8360 Suite Setup
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]      ${is_need_to_kill_mcs}=${True}    ${ue_index}=${0}
    ...              ${if_commissioning}=${True}    ${connection}=GNB_OAM
    ...              ${ues_index}=${${0}}    ${scf_tag}=A     ${is_do_ue_prepare}=${True}    ${is_concurrent_enb_poweroff}=${False}
#    Clone Gnblogs Tool
    robot_common_operations.Common Suite Setup
    run keyword and ignore error    clear vm pid before run case
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Get SCF File Path
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable     ${stream}
    Run Keyword If    ${is_concurrent_enb_poweroff}    Power Off eNB
    run keyword if     ${if_commissioning}    Commissioning SCF With Given Path
    ...    scf_file_path=${Golden_SCF_Path}    scf_name=SCF_${stream}_CB008360_${scf_tag}.xml
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${Golden_SCF_Path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    Run keyword if    ${is_need_to_kill_mcs}    Wait Until Keyword Succeeds    3 min    30 sec
    ...    Mcs.Kill mcs process    ue_index=${ue_index}
    Run Keyword If    ${is_do_ue_prepare}    Run Keyword And Ignore Error    Clear Temp File Of ELT For MTK
    Run Keyword If    ${is_do_ue_prepare}    Get Ue Type for UES    ues_index=${ues_index}
    Run Keyword If    ${is_do_ue_prepare}    UE Prepare for UES    ues_index=${ues_index}

Commissioning SCF With Given Path
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${scf_file_path}=${Golden_SCF_Path}    ${scf_name}=None    ${gnb_index}=0    ${wait_gnb_up_timeout}=15 min
    ...             ${is_pdl_checking_needed}=${True}
    ${scf_name_prefix}    Set Variable    ${scf_file_path.split('.xm')[0]}
    ${scf_last_name}    Run Keyword If    '${scf_name}' != 'None'    Set Variable    ${scf_name.split('${stream}_')[-1]}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword If    '${scf_name}' != 'None'    COAM Commission with scf file
    ...                                              scf_file_path=${scf_name_prefix}_${scf_last_name}
    ...                                              connection=${connection}
    ...                                              timeout=${wait_gnb_up_timeout}
    ...                                              is_pdl_checking_needed=${is_pdl_checking_needed}
    ${gnb_status_after_commission}    Run Keyword And Return Status     Wait Gnb Ready And Cell On Air    timeout=${wait_gnb_up_timeout}
    run keyword if    not ${gnb_status_after_commission}    run keywords
    ...    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error    COAM Save snapshot via rest api    log_path=${OUTPUT DIR}/Case_Logs    timeout=${600}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

8360 Suite TearDown
    [Arguments]    ${ues_index}=${${0},${1}}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword If    '${UE${ue_index}_TYPE}'=='mtk'    run keyword and ignore error
        ...    Get UE Airmode status and Turnon Airplane Mode    ue_index=${ue_index}
    END
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections

8360 Case SetUp
    [Documentation]   Author:lei.jia@nokia-sbell.com
    ...                 for 8360-A NSA call, keep all NR cell barred
    [Arguments]    ${pcell_index}=${None}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Connect to Capacity Unit Master
    Connect to Capacity Unit Slave
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Create log directory
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=barred   list_cell_ids=all    timeout=${180}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=notBarred
    Wait Gnb Ready And Cell On Air
    Log To Console    \n***Step0:QC UE: port5/6 θ_h/θ_v:-7/-6 ATT=12, port7/8 θ_h/θ_v:-22/-6 ATT=12
    Log To Console    \n***Step0:MTK UE: port9/10 θ_h/θ_v:7/-6 ATT=0, port11/12 θ_h/θ_v:22/-6 ATT=0, RSRP=-75db
    Mcs.Set Phases And Attenuations For TOPYONG MCS    att_value=12
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=0
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}

8360 Case TearDown
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${ues_index}    is_power_ue_code=${True}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword If Test Failed    Run Keyword And Ignore Error    COAM Save snapshot via rest api    timeout=${600}
    run keyword and continue on failure    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword If    '${UE${ue_index}_TYPE}'=='huawei_sigspark'    Run Keyword And Ignore Error
        ...    power_ue.Stop traffic   ue_type=${UE${ue_index}_TYPE}    direction=ul    ue_index=${ue_index}    apn_address=dxdata1
        Run Keyword If    '${UE${ue_index}_TYPE}'!='huawei_sigspark' and '${UE${ue_index}_TYPE}'!='mtk'
        ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${UE${ue_index}_TYPE}   ue_index=${ue_index}
        Run Keyword If    '${UE${ue_index}_TYPE}'=='mtk'    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}
    END
    robot_common_operations.Common Case Teardown
#    run keyword and continue on failure    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

Suite TearDown For 8360_B
    [Documentation]   Auther: lei.jia@nokia-sbell.com
    [Arguments]      ${connection}=GNB_OAM    ${RU_index}=4
    robot_common_operations.Common Suite Teardown
    Log To Console    \n***start to recover gNB and pwoer on eNB***
    Power On eNB
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${scf_file_full_name}    set variable    Configuration_IWK_${stream}.xml
    ${scf_file_full_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    ${recover_scf_file_full_path}    set variable if    'SBTS00' in '${stream}'    ${scf_file_full_path}    ${Golden_SCF_Path}
    COAM Commission with scf file    scf_file_path=${recover_scf_file_full_path}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${RU_index}
    ...    force_radio_reset=${True}    timeout=${900}    connection=${connection}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Run Keyword And Ignore Error    COAM Teardown gnb connections

8360_B Case SetUp
    [Documentation]   Author:lei.jia@nokia-sbell.com
    ...                 for 8360-A NSA call, keep all NR cell barred
    [Arguments]    ${pcell_index}=${None}    ${ues_index}=${${1},${2},${3},${4}}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Connect to Capacity Unit Master
    Connect to Capacity Unit Slave
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Create log directory
    Get Ue Type for UES    ues_index=${ues_index}
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${pcell_index}    timeout=${180}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=notBarred
    Wait Gnb Ready And Cell On Air
    Mcs.Set Phases And Attenuations For TOPYONG MCS    att_value=8
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-50}    second_beam_horizontal_angle=${-45}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${-20}    second_beam_horizontal_angle=${-15}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${15}    second_beam_horizontal_angle=${20}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${45}    second_beam_horizontal_angle=${50}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Set MCS Phase For NSA MultiUE PAIRED
    [Documentation]   Author:lei.jia@nokia-sbell.com
    ...                 for 8360 NSA call, mcs pahse and angles
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-45}    second_beam_horizontal_angle=${-52}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${45}    second_beam_horizontal_angle=${50}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${20}    second_beam_horizontal_angle=${25}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Set MCS Phase For SA MultiUE PAIRED
    [Documentation]   Author:lei.jia@nokia-sbell.com
    ...                 for 8360 SA call, mcs pahse and angles
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-50}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${-20}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${15}    second_beam_horizontal_angle=${20}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${45}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Power Off eNB
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${unit_index}=${0}
    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
    pdu.power_off    port=${enb_pdu_port}    pdu_device=enb_pdu
    BuiltIn.Log    Reset eNB via Power off

Power On eNB
    [Arguments]    ${unit_index}=${0}
    ...    ${model}=${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}=  set variable  ${tl.enbs[0].airscale.common_units[${unit_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${enb_pdu_ip}    alias=enb_pdu
    pdu.power_on    port=${enb_pdu_port}    pdu_device=enb_pdu

############################################
############8360 new keywords################
Online delete objects via rest api
    [Arguments]    ${objects_to_delete_via_api}    ${timeout}=${180}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM delete objects via rest api    objects_to_delete_via_api=${objects_to_delete_via_api}    timeout=${timeout}
    sleep    5s
    COAM Wait for gnb ready and cell setup
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Update ULMUMIMO Related Paras
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 for ulMuMimoSpectralEffThd, in webui 1 = 10 in scf
    ...                 for ulMuMimoCorrThd, in webui 0.5 = 50 in scf
    [Arguments]    ${cell_index}=1
    ...            ${connection}=GNB_OAM
    ...            ${NRBTS_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...            ${NRULMUMIMO_id}=0
    ...            ${ulMuMimoCorrThd}=50
    ...            ${ulMuMimoSinrThd}=10
    ...            ${ulMuMimoSpectralEffThd}=10
    ...            ${ulMaxMuMimoLayer}=2
    ...            ${ulMinPrbThreshold}=50
    ...            ${ulMuMimoLinkAdaptionSwitch}=MU-SINR estimation
    ...            ${ulMuMimoPrbThresholdAbsolute}=15
    ...            ${actUlMuMimoTapering}=false
    ...            ${ulMuMimoCorrThd2}=15
    ${org_NRULMUMIMO_Params}    Get ULMUMIMO Related Paras    cell_index=${cell_index}    connection=${connection}
    run keyword and ignore error    COAM Teardown gnb connections
#    Connect to gnb coam via ssl    connection=${connection}
    &{update_NRULMUMIMO_Params}    create dictionary
    @{params_need_to_modify}    create list
    ${dict_param_values}     create dictionary    ulMuMimoCorrThd=${ulMuMimoCorrThd}    ulMaxMuMimoLayer=${ulMaxMuMimoLayer}
    ...                                           ulMinPrbThreshold=${ulMinPrbThreshold}    ulMuMimoLinkAdaptionSwitch=${ulMuMimoLinkAdaptionSwitch}
    ...                                           ulMuMimoSinrThd=${ulMuMimoSinrThd}    ulMuMimoSpectralEffThd=${ulMuMimoSpectralEffThd}
    ...                                           ulMuMimoPrbThresholdAbsolute=${ulMuMimoPrbThresholdAbsolute}
    ...                                           actUlMuMimoTapering=${actUlMuMimoTapering}    ulMuMimoCorrThd2=${ulMuMimoCorrThd2}
    FOR    ${key}    IN    @{org_NRULMUMIMO_Params.keys()}
           Run keyword if    '${org_NRULMUMIMO_Params['${key}']}'=='${dict_param_values['${key}']}'
           ...    Log to console    current value is ${org_NRULMUMIMO_Params['${key}']}, no need to update
           ...    ELSE    Set To Dictionary    ${update_NRULMUMIMO_Params}    ${key}=${dict_param_values['${key}']}
    END
    ${dist_name}    set variable    MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRCELL-${cell_index}/NRULMUMIMO-${NRULMUMIMO_id}
    FOR    ${key}    IN    @{update_NRULMUMIMO_Params.keys()}
        ${param_dict}    Create Dictionary                   dist_name=${dist_name}
        ...                                                  parameter=${key}
        ...                                                  value=${update_NRULMUMIMO_Params['${key}']}
        Append To List    ${params_need_to_modify}    ${param_dict}
    END
    ${updata_para_len}    Get Length    ${update_NRULMUMIMO_Params.keys()}
    Run Keyword If 	${updata_para_len} > 0    Update Params Via RestApi    params_need_to_modify=${params_need_to_modify}

Get ULMUMIMO Related Paras
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 for ulMuMimoSpectralEffThd, in webui 1 = 10 in scf
    ...                 for ulMuMimoCorrThd, in webui 0.5 = 50 in scf
    [Arguments]    ${cell_index}=1
    ...            ${connection}=GNB_OAM
    ...            ${NRBTS_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...            ${NRULMUMIMO_id}=0
    ...            ${timeout}=600
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    &{org_NRULMUMIMO_Params}    create dictionary
    @{params_need_to_modify}    create list
    ${dist_name}    set variable    MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRCELL-${cell_index}/NRULMUMIMO-${NRULMUMIMO_id}
    ${params}     create list    ulMuMimoCorrThd    ulMaxMuMimoLayer    ulMinPrbThreshold
    ...                          ulMuMimoSinrThd    ulMuMimoSpectralEffThd    ulMuMimoLinkAdaptionSwitch
    ...                          ulMuMimoPrbThresholdAbsolute    actUlMuMimoTapering    ulMuMimoCorrThd2
    FOR    ${param}    IN    @{params}
           ${cur_para_value}    coam_parameter.get_single_value_from_scf_file    parameter=${param}
           ...                                                                   dist_name=${dist_name}    connection=${connection}
           ...                                                                   timeout=${timeout}
           Set To Dictionary    ${org_NRULMUMIMO_Params}    ${param}=${cur_para_value}
    END
    [Return]    ${org_NRULMUMIMO_Params}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Get UE releated Info From uldata_puschreceivereq with mcshark
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...                This keyword is used to get ue related info  from bip log, filter uldata_puschreceivereq
    ...                rnit, physical cell id, pattern id, antport, startprb, numofprb, pairedue
    [Arguments]    ${file_path}
    ...    ${filter}=uldata_puschreceivereq
    ...    ${ue_id}=0
    Setup Pcap File    file_path=${file_path}
    ...                filter=${filter}
    ${rnti_list}    run keyword and continue on failure    Get Var Value From Pdml
    ...                                              filter_expression=${filter}
    ...                                              field_name=_3gpp.rnti
    ${ue_rnti}    set variable    ${rnti_list[${ue_id}]}
    ${pairedUe}    run keyword and continue on failure    Get Var Value From Pdml
    ...                                              field_name=UlData_puschReceiveReqGrant_t.pairedUe
    ...                                              filter_expression="3gpp.rnti == ${ue_rnti}"
    ${bipdict}=    create dictionary    rnti=${ue_rnti}    pairedUe=${pairedUe[${ue_id}]}
    ${ue_bipdict}    create dictionary    ${ue_id}=${bipdict}
    [Return]    ${ue_bipdict}

Get Var Value From Pdml
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]        ${filter_expression}
    ...                 ${field_name}
    ${bip_list}    Get Field Value From PCAP
    ...                                               filter_expression=${filter_expression}
    ...                                               field_name=${field_name}
    ${bip_list}    Remove Duplicates    ${bip_list}
    [Return]    ${bip_list[0]}

#Get UE releated Info From uldata_puschreceivereq with mcshark
#    [Documentation]    Author: lei.jia@nokia-sbell.com
#    ...                This keyword is used to get ue related info  from bip log, filter uldata_puschreceivereq
#    ...                rnit, physical cell id, pattern id, antport, startprb, numofprb, pairedue
#    [Arguments]    ${file_path}
#    ...    ${filter}=uldata_puschreceivereq
#    ...    ${ue_id}=0
#    Convert CPIF Pcap To Pdml    file_path=${file_path}
#    ...                          filter=${filter}
#    ${index}=  Evaluate  ${ue_id} + 1
#    ${ue_rnti}    run keyword and continue on failure    Get Var Value From Pdml
#    ...                                              filter_expression=${filter}
#    ...                                              xpath=.//_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t[${index}]/_3gpp.rnti
##    ${antPort}    run keyword and continue on failure    Get Var Value From Pdml
##    ...                                               filter_expression="3gpp.rnti == ${ue_rnti}"
##    ...       xpath=.//_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t[${index}]/UlData_puschReceiveReqGrant_t.antPort
#    ${pairedUe}    run keyword and continue on failure    Get Var Value From Pdml
#    ...                                               filter_expression="3gpp.rnti == ${ue_rnti}"
#    ...       xpath=.//_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t[${index}]/UlData_puschReceiveReqGrant_t.pairedUe
#    ${bipdict}=    create dictionary    rnti=${ue_rnti}    pairedUe=${pairedUe}
#    ${ue_bipdict}    create dictionary    ${ue_id}=${bipdict}
#    [Return]    ${ue_bipdict}
#
#Get Var Value From Pdml
#    [Documentation]   Author: lei.jia@nokia-sbell.com
#    [Arguments]        ${filter_expression}
#    ...                 ${xpath}
#    ${bip_list}    Get Field Value From Pdml
#    ...                                               filter_expression=${filter_expression}
#    ...                                               xpath=${xpath}
#    ${bip_list}    Remove Duplicates    ${bip_list}
#    [Return]    ${bip_list[0]}

Two UEs should be paired
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${percent_exp}=0.94
    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${file_path}    exp_staus=paired    percent_exp=${percent_exp}

Two UEs should be unpaired
    [Documentation]   Author: lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${percent_exp}=0.98
    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${file_path}
    ...                                    exp_staus=notPaired
    ...                                    is_ulmustatus_need_to_check=${False}
    ...                                    percent_exp=${percent_exp}

COAM gNB Reset site and Wait Onair
    [Documentation]         Reset site
    [Arguments]    ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    coam.reset_site         connection=${connection}
    sleep    30s
    Wait Gnb Ready And Cell On Air

Start L3 Call With UEs
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Description：this keyword is used to perform ue attach, start ul&dl traffic and calculate throughput with several UEs
    ...               :param ues_index: (list) – (Optional) list of ue ids.
    ...               :param enb_index: anchor enb index
    [Arguments]     ${ues_index}=${${0},${1}}
    ...             ${ue_mode}=NSA
    ...             ${enb_index}=${1}
    ...             ${ul_throughput}=50M
    ...             ${dl_throughput}=800MKbits/sec
    ...             ${start_keep_on_duration}=1200
    ...             ${ue_iperf_path}=/data/local/tmp/iperf
    ...             ${whether_do_ue_prepare}=${False}
    ...             ${apn_address}=dxdata1
    ...             ${duration}=180
    ...             ${target_UL_avg_percent}=0.9
    ...             ${target_DL_avg_percent}=0.9
    ...             ${min_DL_percent}=0.4
    ...             ${min_UL_percent}=0.4
    ...             ${check_pcell_tput}=${True}
    ...             ${whether_start_dl_call}=${True}
    ...             ${whether_start_ul_call}=${True}
    ...             ${dl_process_num}=2
    ${attachinfo_dict}    UE attach for UES    ues_index=${ues_index}   ue_mode=${ue_mode}
    ...    whether_do_ue_prepare=${whether_do_ue_prepare}    enb_index=${enb_index}
    FOR    ${ue_index}    IN    @{ues_index}
        ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
        ...    ${attachinfo_dict['${ue_index}']['enb_wireshark_log_path']}    ${attachinfo_dict['${ue_index}'['cpif_log_path']}
        Procedures.Start Data Transfer    ue_index=${ue_index}
        ...                             cpif_log_path=${attach_wireshark}
        ...                             ue_mode=${ue_mode}
        ...                             ue_index=${ue_index}
        ...                             start_keep_on_duration=${start_keep_on_duration}
        ...                             ul_throughput=${ul_throughput}
        ...                             dl_throughput=${dl_throughput}
        ...                             iperf_path=${ue_iperf_path}
        ...                             ue_type=${UE${ue_index}_TYPE}
        ...                             apn_address=${apn_address}
        ...                             whether_start_ul_call=${whether_start_ul_call}
        ...                             whether_start_dl_call=${whether_start_dl_call}
        ...                             dl_process_num=${dl_process_num}
    END
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${UE0_TYPE}
    ...                                    target_DL_avg_percent=${target_DL_avg_percent}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    check_pcell_tput=${check_pcell_tput}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    ...                                    duration=${duration}
    ...                                    target_UL_avg_percent=${target_UL_avg_percent}
    ...                                    min_DL_percent=${min_DL_percent}
    ...                                    min_UL_percent=${min_UL_percent}
    [Return]    ${attachinfo_dict}

Stop DL Traffic and Capture BIP and TTI for UES
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}
    ...             ${cell_index}=3
    ...             ${bbmod_slots}=1
    MultiUE.Stop DL Traffic    ues_index=${ues_index}
    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    cell_index=${cell_index}
    ${bip_log}    Run Keyword And Continue On Failure    Capture BIP with gnb logs
    ...                                                            cell_index=${cell_index}    bbmod_slots=${bbmod_slots}
#    ${bip_log}    Start And Stop Bip Capture
    [Return]    ${ttitrace_file}    ${bip_log}

MultiUE.Stop UL Traffic
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                            iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword If    '${UE${ue_index}_TYPE}'=='huawei_sigspark'    Run Keyword And Ignore Error
        ...    power_ue.Stop traffic   ue_type=${UE${ue_index}_TYPE}    direction=ul    ue_index=${ue_index}    apn_address=dxdata1
    END

Evaluate Single UE Average Tput For UL With TTI
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}=${None}
    ...            ${expect_tput_value}=${None}
    ...            ${unexpect_bler}=0.05
    ...            ${average_tput_percent}=0.9
    ${ue_tputs}    calculate_ubler_and_ultput_for_ues    file_path=${file_path}
    ${ue_rnti_list}    Get Dictionary Keys    ${ue_tputs}
    ${expect_tput}=    Evaluate    float(${expect_tput_value} * ${average_tput_percent})
    ${unexpect_bler}=    Evaluate    float(${unexpect_bler})
    FOR    ${rnti}    IN    @{ue_rnti_list}
        ${average_tput}    Set Variable    ${ue_tputs['${rnti}']['tput']}
        ${average_bler}    Set Variable    ${ue_tputs['${rnti}']['bler']}
        Run Keyword If    ${expect_tput}>${average_tput}    Fail
        ...               avg ul tput of ue ${rnti} is ${average_tput}, expect result is ${expect_tput}
        Run Keyword If    ${average_bler}>${unexpect_bler}    Fail
        ...               avg ul bler of ue ${rnti} is ${average_bler}, too high!
    END

Get Ue Type for UES
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}
    FOR    ${ue_index}    IN    @{ues_index}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Set Suite Variable    ${UE${ue_index}_TYPE}    ${ue_type}
    END

UE Prepare for UES
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}    ${whether_do_ue_prepare}=${True}    ${get_spark_license}=${False}
    ${attachinfo_dict}    create dictionary
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword If    ${whether_do_ue_prepare}    Procedures.UE Prepare
        ...                                           ue_index=${ue_index}
        ...                                           ue_type=${UE${ue_index}_TYPE}
        ...                                           get_spark_license=${get_spark_license}
    END

UE attach for UES
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}    ${ue_mode}=SA    ${enb_index}=${1}    ${whether_do_ue_prepare}=${False}
    ${attachinfo_dict}    create dictionary
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword If    ${whether_do_ue_prepare}    Procedures.UE Prepare    ue_index=${ue_index}    ue_type=${UE${ue_index}_TYPE}
        ${attach_info}    Procedures.UE Attach     ue_index=${ue_index}
        ...                                        ue_type=${UE${ue_index}_TYPE}
        ...                                        ue_mode=${ue_mode}
        ...                                        enb_index=${enb_index}
        ...                                        is_power_ue_code=${True}
        ${ue_index}    Convert To String    ${ue_index}
        Set To Dictionary    ${attachinfo_dict}    ${ue_index}=${attach_info}
    END
    [Return]    ${attachinfo_dict}

UE Deattach for UEs
    [Documentation]    Author: le.jia@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}    ${is_power_ue_code}=${False}
    FOR    ${ue_index}    IN    @{ues_index}
        ${ue_type}    set variable    ${UE${ue_index}_TYPE}
        Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'    Run Keyword And Ignore Error
        ...    Spark_common_keywords.Start UE Detach    ue_index=${ue_index}
        Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${True}'    Run Keyword And Ignore Error
        ...   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
        Run Keyword If    '${ue_type}'!='huawei_sigspark' and '${ue_type}'!='mtk'    Run Keyword And Ignore Error
        ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
        Run Keyword If    '${ue_type}'=='mtk'    MTK_common_keywords.Do UE Detach    ue_index=${ue_index}
        Run Keyword If    '${ue_type}'=='huawei_sigspark' and '${is_power_ue_code}'=='${False}'    Run Keyword And Ignore Error
        ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}
    END

Start And Stop Bip Capture
    [Documentation]    author:lei.jia@nokis-sbell.com
    [Arguments]        ${sleep_interval}=4 sec
    ...                 ${asib_interface}=eths3
    Start Bip Capture
    Sleep    ${sleep_interval}
    ${bip_log_list}    Stop Bip Capture   asib_interface=${asib_interface}
    ${bip_log_path}    Set Variable    ${bip_log_list[0]}
    [Return]    ${bip_log_path}

Update Prameter ulMuMimoSpectralEffThd
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${cell_index}
    ...            ${update_value}=0
    ...            ${gnb_id}=0
    Log To Console    \n***start to update ulMuMimoSpectralEffThd***
    ${update_param}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0', 'parameter':'ulMuMimoSpectralEffThd',
    ...    'value':'${update_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_id}

Update Prameter ulSinrDiffThreshold
    [Documentation]   Auther:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_index}
    ...            ${update_value}=-10
    ...            ${gnb_id}=0
    Log To Console    \n***start to update ulMuMimoSpectralEffThd***
    ${update_param}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0', 'parameter':'ulSinrDiffThreshold',
    ...    'value':'${update_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_id}

Update Prameter tmpParam5
    [Documentation]   Auther:lei.jia@nokia-sbell.com
    ...               for NRCELL-tmpParam5 in 23R1, when value in webui set to 20, actual value is -10 indeed
    [Arguments]       ${cell_index}
    ...               ${update_value}=-10
    ...               ${gnb_id}=0
    Log To Console    \n***start to update ulMuMimoSpectralEffThd, ***
    ${update_value}    Evaluate    int(${update_value}) + 30
    ${update_param}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', 'parameter':'tmpParam5',
    ...    'value':'${update_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_id}

Update Prameter ulMinPrbThreshold And ulMuMimoPrbThresholdAbsolute
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${cell_index}
    ...            ${ulMinPrbThreshold}=100
    ...            ${ulMuMimoPrbThresholdAbsolute}=30
    ...            ${gnb_id}=0
    Log To Console    \n***start to update ulMinPrbThreshold And ulMuMimoPrbThresholdAbsolute***
    ${update_param}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...    'parameter':'ulMuMimoPrbThresholdAbsolute','value':'${ulMuMimoPrbThresholdAbsolute}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...    'parameter':'ulMinPrbThreshold','value':'${ulMinPrbThreshold}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_id}

Update Prameter ulMaxMuMimoLayer
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${cell_index}
    ...            ${update_value}=2
    ...            ${gnb_id}=0
    Log To Console    \n***start to update ulMaxMuMimoLayer to ${update_value}***
    ${update_param}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0', 'parameter':'ulMaxMuMimoLayer',
    ...    'value':'${update_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_id}

Update Prameter actUlMuMimo
    [Documentation]   Author:lei.jia@nokia-sbell.com
    [Arguments]    ${cell_index}
    ...            ${update_value}=true
    ...            ${gnb_id}=0
    Log To Console    \n***start to update actUlMuMimo to ${update_value}***
    ${update_param}    catenate   {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${cell_index}', 'parameter':'actUlMuMimo',
    ...    'value':'${update_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=${gnb_id}


MultiUE.Stop DL Traffic
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver
        ...    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    END

MultiUE.Stop Traffic
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1}}
    FOR    ${ue_index}    IN    @{ues_index}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}
        ...                                                                      iperf_port=${tl.ues[${ue_index}].iperf_details.port}
        Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
        Run Keyword If    '${UE${ue_index}_TYPE}'=='huawei_sigspark'    Run Keyword And Ignore Error
        ...    power_ue.Stop traffic   ue_type=${UE${ue_index}_TYPE}    direction=ul    ue_index=${ue_index}    apn_address=dxdata1
    END

MultiUE.Start Data Transfer
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${attachinfo_dict}
    ...             ${ues_index}=${${0},${1}}
    ...             ${ue_mode}=NSA
    ...             ${ul_throughput}=50M
    ...             ${dl_throughput}=800MKbits/sec
    ...             ${start_keep_on_duration}=3600
    ...             ${ue_iperf_path}=/data/local/tmp/iperf
    ...             ${whether_start_dl_call}=${True}
    ...             ${whether_start_ul_call}=${True}
    ...             ${apn_address}=dxdata1
    ...             ${is_power_ue_code}=${False}
    ...            ${dl_process_num}=2
     FOR    ${ue_index}    IN    @{ues_index}
          ${attach_wireshark}    Set Variable If    '${ue_mode}'=='NSA'
          ...    ${attachinfo_dict['${ue_index}']['enb_wireshark_log_path']}    ${attachinfo_dict['${ue_index}']['cpif_log_path']}
          Run Keyword And Continue On Failure    Procedures.Start Data Transfer    ue_index=${ue_index}
          ...                                    cpif_log_path=${attach_wireshark}
          ...                                    ue_mode=${ue_mode}
          ...                                    ue_index=${ue_index}
          ...                                    start_keep_on_duration=${start_keep_on_duration}
          ...                                    ul_throughput=${ul_throughput}
          ...                                    dl_throughput=${dl_throughput}
          ...                                    iperf_path=${ue_iperf_path}
          ...                                    ue_type=${UE${ue_index}_TYPE}
          ...                                    apn_address=${apn_address}
          ...                                    whether_start_dl_call=${whether_start_dl_call}
          ...                                    whether_start_ul_call=${whether_start_ul_call}
          ...                                    is_power_ue_code=${is_power_ue_code}
          ...                                    dl_process_num=${dl_process_num}
    END

Check UE Paried Status Via TTITrace
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
    ...             ${exp_staus}=paried
    ...             ${is_ulmustatus_need_to_check}=${True}
    ...             ${ulmustatus}=MUPAIRED_NO_TAPERING
    ...             ${percent_exp}=0.94
    ...             ${checked_pair_ue_rnti}=${None}
    ...             ${is_ulmugroup_status_need_to_check}=${False}
    ...             ${group_paird_percent_exp}=0.1
    check_ul_ue_paried_status_for_ues     file_path=${ttitrace_filt_path}
    ...                                   expect_pair_status=${exp_staus}
    ...                                   is_ulmustatus_need_to_check=${is_ulmustatus_need_to_check}
    ...                                   ulmustatus=${ulmustatus}
    ...                                   percent_exp=${percent_exp}
    ...                                   checked_pair_ue_rnti=${checked_pair_ue_rnti}
    ...                                   is_ulmugroup_status_need_to_check=${is_ulmugroup_status_need_to_check}
    ...                                   group_paird_percent_exp=${group_paird_percent_exp}

Check UE Paried Status With Varied Reqprb
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_file}
    ...             ${ulMinPrbThreshold}=100
    ...             ${ulMuMimoPrbThresholdAbsolute}=30
    ${root_ue_rnti}    ${candidate_ue_rnti}    verify_Ues_paired_status_with_varied_reqprb
    ...                                        file_path=${ttitrace_file}
    ...                                        ulMinPrbThreshold=${ulMinPrbThreshold}
    ...                                        ulMuMimoPrbThresholdAbsolute=${ulMuMimoPrbThresholdAbsolute}
    [Return]    ${root_ue_rnti}    ${candidate_ue_rnti}


Evaluate Single UE Average Tput Via TTITrace Based On Rnti
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${rnti}
    ...            ${ttitrace_file}
    ...            ${expect_tput_value}
    ...            ${unexpect_bler}=0.05
    ...            ${average_tput_percent}=0.9
    ${ue_tputs}    calculate_ubler_and_ultput_for_ues    file_path=${ttitrace_file}
    ${expect_tput}    Evaluate    float(${expect_tput_value} * ${average_tput_percent})
    ${unexpect_bler}    Evaluate    float(${unexpect_bler})
    ${average_tput}    Set Variable    ${ue_tputs['${rnti}']['tput']}
    ${average_bler}    Set Variable    ${ue_tputs['${rnti}']['bler']}
    Run Keyword If    ${expect_tput}>${average_tput}    Fail
    ...               avg ul tput of ue ${rnti} is ${average_tput}, expect result is ${expect_tput}
    Run Keyword If    ${average_bler}>${unexpect_bler}    Fail
    ...               avg ul bler of ue ${rnti} is ${average_bler}, too high!

Check AntPort For Subcells
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_file}
    ...             ${cell_index}
    ...             ${expect_subcell0_port}=${None}
    ...             ${expect_subcell1_port}=${None}
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ${all_subcells_dict}    Get Subcell Ids    gnb_index=${gnb_index}    du_index=${du_index}
    ${expect_cell_subcells}    Set Variable    ${all_subcells_dict['${cell_index}']}
    ${subcell0_id}    Set Variable    ${expect_cell_subcells.get('subcell0_id')}
    ${subcell1_id}    Set Variable    ${expect_cell_subcells.get('subcell1_id')}
    check_antPort_info_for_two_subcells    file_path=${ttitrace_file}
    ...                                    subcell0_id=${subcell0_id}
    ...                                    subcell1_id=${subcell1_id}
    ...                                    expect_subcell0_port=${expect_subcell0_port}
    ...                                    expect_subcell1_port=${expect_subcell1_port}
    check_subcell_is_same_for_retransmission_data    file_path=${ttitrace_file}

Check Subcell Allocation Same For Retransmission Data
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_file}
    check_subcell_is_same_for_retransmission_data    file_path=${ttitrace_file}

Check Retransmission UEs Mustatus
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_file}
    ${retrans_pair_status}    ${simple_pair}    ${normal_pair}    check_retransmission_data_mustatus
    ...    file_path=${ttitrace_file}
    [Return]    ${retrans_pair_status}    ${simple_pair}    ${normal_pair}

Check Ues Subcells Allocation And ulMuStaus
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_file}
    ...             ${exp_staus}=paried
    ...             ${ulMuStatus}=MUPAIRED_NO_TAPERING
    ...             ${is_ulmustatus_need_to_check}=${True}
    ...             ${percent_exp}=0.98
#    ${all_subcells_dict}    Get Subcell Ids    gnb_index=${gnb_index}    du_index=${du_index}
#    ${expect_cell_subcells}    Set Variable    ${all_subcells_dict['${cell_index}']}
#    ${subcell0_id}    Set Variable    ${expect_cell_subcells.get('subcell0_id')}
#    ${subcell1_id}    Set Variable    ${expect_cell_subcells.get('subcell1_id')}
#    Run Keyword And Continue On Failure    check_rnti_subcell_mapping    file_path=${ttitrace_file}
#    ...                                                                  rnti_number=${ue_number}
#    ...                                                                  subcell0_id=${subcell0_id}
#    ...                                                                  subcell1_id=${subcell1_id}
#    ...                                                                  subcell0_rnti_number=${subcell0_rnti_number}
#    ...                                                                  subcell1_rnti_number=${subcell1_rnti_number}
    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file}    ulmustatus=${ulMuStatus}    exp_staus=${exp_staus}
    ...                                    is_ulmustatus_need_to_check=${is_ulmustatus_need_to_check}    percent_exp=${percent_exp}

Disable AutoConnect For 8UE Module
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    ...    cmd: AT+GTACT =14,,,5041, used to lock frequency to band41
    [Arguments]    ${ues_index}=${${2},${3},${4},${5}}
    FOR    ${ue_index}    IN    @{ues_index}
        run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=at+cfun=0
        Sleep    3s
        run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=at+cfun=1
        Sleep    20s
        run keyword and ignore error    spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+GTACT =14,,,5041
        Sleep    3s
        spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+GTAUTOCONNECT=0
        Sleep    3s
        spark.send_AT_command_CPE     ue_alias=UE_${ue_index}   param=AT+CGATT=0
        Sleep    3s
    END

Deployment SA And NSA Mode For 8UE Module
    [Documentation]    Author: lei.jia@nokia-sbell.com
    ...    para:${ue_mode}  value can be "NSA or SA"
    ...    please note, for SA mode, select ${nettpye}=SA+NSA; for NSA mode, select ${nettpye}=NSA
    [Arguments]    ${ue_mode}=SA      ${ues_index}=${${1},${2},${3},${4}}
    FOR    ${ue_index}    IN    @{ues_index}
        ${nettpye}    Set Variable If    '${ue_mode}'=='NSA'     NSA    SA+NSA
        Log To Console    \nStart to deployment UE${ue_index} to ${ue_mode} Mode.
        spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${ue_index}
    END

#Check VirtualUes Number For 4UES Per Slot
#    [Documentation]   Auther:stella.lin@nokia-sbell.com
#    [Arguments]     ${ttitrace_file}
#    ...             ${expect_virtualue_number}=2
#    check_virtualUe_number_for_4ues_per_slot    file_path=${ttitrace_file}    expect_virtualue_number=${expect_virtualue_number}


###########mcs setting used for perform testing
Set Topypoung θ poll for horizontal
    [Documentation]    used for topyoung mcs to run performance testing.
    ...                  port5/6 θ_h: [-60, 50], θ_v:-6  ATT=18 for good, ATT=32 for medium, ATT=42 for Worse
    ...                  port7/8 θ_h: [-50, 60], θ_v:-6  ATT=18 for good, ATT=32 for medium, ATT=42 for Worse
    ...                  stay 2s at each step.
    [Arguments]    ${att_value}=18
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    ...    ${begin_θ_h}=-60    ${end_θ_h}=50    ${θ_h_increment}=10
    ...    ${vertical_angle}=${-6}    ${sleep_time}=2s    ${range_step}=2
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}
    ...    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...    ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=${att_value}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}
    ...    second_beam_end_output_port=${second_beam_end_output_port}
    mcs_common.Set θ Poll For Horizontal Angle    mcs_type=${mcs_type}
    ...    B1_port=${first_beam_begin_output_port}    B2_port=${first_beam_end_output_port}
    ...    B3_port=${second_beam_begin_output_port}    B4_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    θ_h_increment=${θ_h_increment}
    ...    vertical_angle=${vertical_angle}    sleep_time=${sleep_time}    range_step=${range_step}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}

Capturing Aasyslog through all the performance testing
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                Author: lei.jia
    [Arguments]    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt    ${Teardown_after_finished}=${True}
    ...    ${att_value}=18
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    ...    ${begin_θ_h}=-60    ${end_θ_h}=50    ${θ_h_increment}=10
    ...    ${begin_input_port}=${1}    ${end_input_port}=${32}
    ...    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...    ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    ...    ${vertical_angle}=${-6}    ${sleep_time}=1s
    Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress
    Set Topypoung θ poll for horizontal    att_value=${att_value}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    begin_input_port=${begin_input_port}    end_input_port=${end_input_port}
    ...    begin_θ_h=${begin_θ_h}    end_θ_h=${end_θ_h}    θ_h_increment=${θ_h_increment}
    ...    vertical_angle=${vertical_angle}    sleep_time=${sleep_time}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'    Teardown the Aasyslog save progress

Check Tput For all the performance testing
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                Descrition: Verify throughput for performance testing during all the process, collect tput before.
    [Arguments]    ${tput_log}
    ...            ${expect_ul_tput}=${None}
    ...            ${cellid}=1
    ...            ${connection}=GNB_OAM
    ...            ${target_avg_percent}=0.8
    ...            ${min_percent}=0
    ...            ${actCarrierAggregation}=${False}
    ...            ${list_all_cell_ids}=${False}
    ...            ${check_source}=spark
    ${list_nrcell_ids}    check_android_ue_l3_call_process.Get NRCELLID based on CELLID
    ...    cellid=${cellid}    connection=${connection}    list_all_cell_ids=${list_all_cell_ids}
    ${UL_TPUT}    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${tput_log}    cells=${list_nrcell_ids}
    ...                                                           target_throughput=${expect_ul_tput}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    [Return]    ${UL_TPUT}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections


Check Two Subcells Allocation
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=GNB_${gnb_index}
    ${output}    ssh.execute    command=cat /ram/NrCellMappingInfo.txt    connection=GNB_${gnb_index}
    @{valid_lines}    Split To Lines    ${output}
    ${L1_allocation_result}    Create List
    FOR    ${line}    IN    @{valid_lines}
        ${line}    Set Variable    ${line.strip()}
        ${L1}    Set Variable    ${line.split('0x')[-1]}
        append to list    ${L1_allocation_result}    ${L1}
    END
    ${status}    ${ret}    Run Keyword And Ignore Error    Should Be Equal    ${L1_allocation_result[-2]}     ${L1_allocation_result[-1]}
    [Return]    ${status}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=GNB_${gnb_index}

Get SCF File Path
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    ${scf_full_path}    Get Variable Value    ${scf_full_path}
    return from keyword if    '${scf_full_path}' != 'None'
    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename}

UPdate All ATT Value
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}     att_value=33
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    att_value=29
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    att_value=27
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports
    ...    mcs_type=${mcs_type}    att_value=33
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Check MUGroup Paried Status Via TTITrace
    [Documentation]   Auther:xiaoxia.hao@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
    ...             ${group_paird_percent_exp}=0.1
    calculate_ul_ulmugroup_status     file_path=${ttitrace_filt_path}
    ...                                   group_paird_percent_exp=${group_paird_percent_exp}

Update_actUlMuMimoGroupPairing_Values
    [Documentation]     actUlMuMimoGroupPairing: true
    [Arguments]    ${cell_index}=1
    ...            ${connection}=GNB_OAM
    ...            ${NRBTS_id}=${tl.gnbs[0].global_bts_id}
    ...            ${MRBTS_id}=${tl.gnbs[0].instance_id}
    ...            ${NRULMUMIMO_id}=0
    Log To Console    \n***start to nrcelltype and numberOfRxBeamforming***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=0
    ${update_param}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRCELL-${cell_index}/NRULMUMIMO-${NRULMUMIMO_id}',
    ...                 'parameter':'actUlMuMimoGroupPairing','value':'true'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0
