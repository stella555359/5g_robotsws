*** Settings ***
Suite Setup          Dedicate_Suite_Setup
Suite Teardown       Dedicate_Suite_Teardown
##Test Setup           SISO Coam Test Setup
##Test Teardown        SISO Coam Test Teardown

Documentation     author: Dong Tingting
...               contact: tingting.dong@nokia-sbell.com
...               multi ue x65 EU


Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    ./Resources/L3call_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Library    BuiltIn
Library    Collections
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
#####Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
#####Library     taf.ue.rpc.mtk    WITH NAME    rpc_mtk
#####Library     taf.ul.messaging.mtk      WITH NAME    mtk_msg
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Library    taf.analyzer.pcap     WITH NAME    pcap


*** Variables ***
${if_commissioning}    False
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                    ${tl.ues[1].imsi}
#${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
#${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${Ho_looptimes}    ${2}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${target_dir}    /home/ute/dtt
${display_filter}    uldata_puschreceivereq
${filter_name}    UlData_puschReceiveReqGrant_t.startPrb
#${bip_log_path}    /home/ute/dtt/Genericl1l2bip/tcpdump.pcap
#${tshark_path}        /usr/bin/tshark

${call_loop_num}    10

*** Test Cases ***
[1]Rjio_AQQJ_21_HO_Robust_Test_SA_CA_FDD_TDD_FDD
    [Documentation]
    ...    attenuator
    ...    0 AQQJ_2_attenuator_multi_ue
    ...    1 AHPB_2_attenuator_multi_ue
    ...    2 AHPB_1_attenuator_mtk
    ...    3 AHCA_LTE_attenuator_multi_ue_1
    ...    UE1,UE2
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    SA HO Request    SA HO Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Intra_CELL1_CELL17

[1]Rjio_AQQJ_19_Ping_RTT_Test
    [Documentation]
    ...    RJIO E2E TEST RTT Max avg is 100ms
    ...    UE1,UE2
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    Set_PA_for_Precondition  Scence_PA_Config=${PA_Config['Intra_CELL1_CELL17']}    Value_key=pa_value1
    MultiUE.RTT_TEST   UECFG=${TL166_multi_ue_HO['MultiUECFG']}

[1]Rjio_AQQJ_20_SA RRC setup complete time
    [Documentation]
    ...    RJIO E2E TEST RTT Max avg is 100ms
    ...    UE1,UE2
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    Set_PA_for_Precondition  Scence_PA_Config=${PA_Config['Intra_CELL1_CELL17']}    Value_key=pa_value1
    ${result}    MultiUE.GET_event_msg    UECFG=${TL166_multi_ue_HO['MultiUECFG']}

[1]Rjio_E2E_33_Intra-Frequency_And_Inter-Gnb_Ho_Xn_Based
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    SA HO Request    SA HO Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Inter_CELL16_CELL16
    Sleep    20
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Inter_CELL0_CELL0

[1]Rjio_E2E_34_Intra-Frequency_And_Inter-Gnb_Ho_Ng_Based
    [Setup]    Setup_AQQJ_25
    [Teardown]    Teardown_AQQJ_25
    ${events_name}    Create List    SA HO Request    SA HO Success
    set suite variable    ${events_name}    ${events_name}
    Set_Xn_link    cmd=${Break_Xn_link_cmd}
    sleep    120
    Wait For Expect Fault Present    faultId=${7311}    timeout=600
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Inter_CELL16_CELL16
    Sleep    20
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Inter_CELL0_CELL0
    Set_Xn_link    cmd=${Recover_Xn_link_cmd}

[1]Rjio_E2E_64_Mobility_IRAT_Data_HO_With_N26
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    4G->5G HO Request    4G->5G HO Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${Inter_rat_HO['MultiUECFG']}    PA_Config_key=Inter_rat_CELL1
    Sleep    20
    MultiUE.Ho_test    UECFG=${Inter_rat_HO['MultiUECFG']}    PA_Config_key=Inter_rat_CELL17

[1]Rjio_E2E_66_Mobility_VoNR_To_VoLTE_Handover
    [Documentation]
    ...    UE4
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    Set_PA_for_Precondition  Scence_PA_Config=${PA_Config['Irat_VONR_CELL1']}    Value_key=pa_value1
    MultiUE.VONR_CALL_TEST   UECFG=${Multi_UE_VONR['MultiUECFG']}    PA_Config_key=Irat_VONR_CELL1
    sleep    5s
    Set_PA_for_Precondition  Scence_PA_Config=${PA_Config['Irat_VONR_CELL17']}    Value_key=pa_value1
    MultiUE.VONR_CALL_TEST   UECFG=${Multi_UE_VONR['MultiUECFG']}    PA_Config_key=Irat_VONR_CELL17

[1]Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor
    [Setup]    Dedicate_Case_Setup    scf_suffix=_anr_eutra.xml
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    4G->5G HO Request    4G->5G HO Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${Inter_rat_HO['MultiUECFG']}    PA_Config_key=Inter_rat_CELL1
    Sleep    20
    MultiUE.Ho_test    UECFG=${Inter_rat_HO['MultiUECFG']}    PA_Config_key=Inter_rat_CELL17

[1]Rjio_AQQJ_22_Inter-Frequency_And_Inter-RAT_Redirection
    [Setup]    Dedicate_Case_Setup    scf_suffix=_anr_eutra.xml
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    5G->4G Re-direction Start    5G->4G Re-direction Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${Inter_rat_HO['MultiUECFG']}    PA_Config_key=Inter_rat_CELL1_redirection
    Sleep    20
    MultiUE.Ho_test    UECFG=${Inter_rat_HO['MultiUECFG']}    PA_Config_key=Inter_rat_CELL17_redirection

[1]Rjio_AQQJ_23_Intra-Frequency_And_Intra-Gnb_Ho
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    SA HO Request    SA HO Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Intra_CELL0_CELL1
    Sleep    20
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=Intra_CELL16_CELL17

[1]Rjio_AQQJ_24_Inter-Frequency_And_Inter-Gnb_Ho_Xn_Based
    [Setup]    Dedicate_Case_Setup
    [Teardown]    Dedicate_Case_Teardown
    ${events_name}    Create List    SA HO Request    SA HO Success
    set suite variable    ${events_name}    ${events_name}
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=CELL16_AdjCELL0

[1]Rjio_AQQJ_25_Inter-Frequency_And_Inter-Gnb_Ho_Ng_Based
    [Setup]    Setup_AQQJ_25
    [Teardown]    Teardown_AQQJ_25
    ${events_name}    Create List    SA HO Request    SA HO Success
    set suite variable    ${events_name}    ${events_name}
    Set_Xn_link    cmd=${Break_Xn_link_cmd}
    sleep    120
    Wait For Expect Fault Present    faultId=${7311}    timeout=600
    MultiUE.Ho_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}    PA_Config_key=CELL16_AdjCELL0
    Set_Xn_link    cmd=${Recover_Xn_link_cmd}

#Test_demo1
#    MultiUE.basic_traffic_test    UECFG=${TL166_multi_ue_HO['MultiUECFG']}
#    Pa_test_only
#    Set_PA_Value  value=${126}  attenuator_index=${3}
#    PA_HJ_TEST
#    Set_PA_Value  value=${98}  attenuator_index=${4}
#    log to console    \ntest2:
#    log to console    ${test123}
#    [Teardown]    Teardown_AQQJ_25
#
#[1]Rjio_AQQJ_19_Ping_RTT_Test
#    [Documentation]
#    ...    RJIO E2E TEST RTT Max avg is 100ms
#    MultiUE.RTT_TEST   UECFG=${TL166_multi_ue_RTT['MultiUECFG']}

*** Keywords ***
Setup_AQQJ_25
    Dedicate_Case_Setup
    set suite variable    ${Break_Xn_link_cmd}    iptables -I INPUT -s ${Adj_Gnb} -j DROP
    set suite variable    ${Check_Xn_link_cmd}    iptables -L --line-numbers
    set suite variable    ${Recover_Xn_link_cmd}    iptables -D INPUT -s ${Adj_Gnb} -j DROP

Teardown_AQQJ_25
    Run Keyword If Test Failed    Set_Xn_link    cmd=${Recover_Xn_link_cmd}
    Run Keyword If Test Failed    log to console    \ntest failed
    Run Keyword If Test Passed    log to console    \ntest passed
    Dedicate_Case_Teardown

#multi_UE_spark_2UE_traffic_test
##    [Documentation]
##    ...    basic traffic test

#    MultiUE.basic_traffic_test    UECFG=${TL166_multi_ue_Config['MultiUECFG']}

#PA_HJ_TEST
#    ssh.Connect to    10.71.205.60    admin    admin    alias=HJ_PA
#    sleep  2
#    ${output}  ssh.execute  ATT 1 125;2 125  connection=HJ_PA  timeout=${10}
#    ssh.Disconnect  connection=HJ_PA

Set_Xn_link
    [Arguments]  ${cmd}=iptables -L --line-numbers
    sleep  2
    ssh.Connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=SAgnb
    sleep  2
    ${output}  ssh.execute  ${Check_Xn_link_cmd}  connection=SAgnb  timeout=${10}
    log to console  \nCheck before cmd:${output}
    sleep  2
    ${output}  ssh.execute  ${cmd}  connection=SAgnb  timeout=${10}
    log to console  ${output}
    sleep  2
    ${output}  ssh.execute  ${Check_Xn_link_cmd}  connection=SAgnb  timeout=${10}
    log to console  \nCheck after cmd:${output}
    ssh.Disconnect  connection=SAgnb

commission_scf_with_suffix
    [Arguments]    ${scf_suffix}=${.xml}
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    .xml    ${scf_suffix}
    Commissioning SCF And Check On Air    scf_path=${SCF_new}
    sleep    10s
#    [Teardown]    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}

Set_PA_for_Precondition
    [Arguments]    ${Scence_PA_Config}  ${Value_key}=pa_value0
    FOR    ${pa_index}    IN    @{Scence_PA_Config['pa_index_for_120']}
    sleep    2
        Set_PA_Value  value=${120}  attenuator_index=${pa_index}  max_attenuation=${120}
    END
    FOR    ${pa_index}    IN    @{Scence_PA_Config['pa_index_for_127']}
    sleep    2
        Set_PA_Value  value=${127}  attenuator_index=${pa_index}  max_attenuation=${127}
    END
    FOR    ${index}    IN    @{Scence_PA_Config['pa_for_test']}
    sleep    2
        Set_PA_Value  value=${Scence_PA_Config['${index}']['${Value_key}']}  attenuator_index=${Scence_PA_Config['${index}']['pa_index']}
    ...      max_attenuation=${Scence_PA_Config['${index}']['pa_max']}
    END

Set_PA_for_Scence
    [Arguments]    ${Scence_PA_Config}    ${Value_key}
    FOR    ${index}    IN    @{Scence_PA_Config['pa_for_test']}
        Set_PA_Value  value=${Scence_PA_Config['${index}']['${Value_key}']}  attenuator_index=${Scence_PA_Config['${index}']['pa_index']}
    ...      max_attenuation=${Scence_PA_Config['${index}']['pa_max']}
    END

Set_PA_Value
    [Documentation]    ****max_attenuation:
    ...   TOPYOUNG 120, RadioRack 127, HBTE 127
    [Arguments]  ${value}  ${attenuator_index}=${0}  ${min_attenuation}=${0}  ${max_attenuation}=${127}
    ${ports_info}    set variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ports}    Get Dictionary Keys    ${ports_info}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=PA_alias
    ...    min_attenuation=${min_attenuation}    max_attenuation=${max_attenuation}
    FOR    ${port}    IN    @{ports}
    sleep    2
        attenuator.set_attenuation    port=${port}    value=${value}    confirm=True    attenuator_device=${PA}
    END

Dedicate_Suite_Setup
    [Arguments]    ${scf_suffix}=_ho.xml
    Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
    Log to console    \nSISO Coam Suite Setup
    SISO Coam Suite Setup
    commission_scf_with_suffix    scf_suffix=${scf_suffix}

Dedicate_Suite_Teardown
    Log to console    \nSISO Coam Suite Teardown
    SISO Coam Suite Teardown

Dedicate_Case_Setup
    [Arguments]    ${scf_suffix}=Null
    Log to console    \nSISO Coam Test Setup
    SISO Coam Test Setup
    Run keyword If    '${scf_suffix}' != 'Null'
    ...    commission_scf_with_suffix    scf_suffix=${scf_suffix}

Dedicate_Case_Teardown
    log to console    \nSISO Coam Test Teardown
    SISO Coam Test Teardown

MultiUE.Ho_test
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
    ...    attenuator info
    ...    0 AQQJ_2_attenuator_multi_ue
    ...    1 AHPB_2_attenuator_multi_ue
    ...    2 AHPB_1_attenuator_mtk
    ...    3 AHCA_LTE_attenuator_multi_ue_1
    [Arguments]    ${UECFG}    ${PA_Config_key}    ${default_ue_index}=0
    log to console    \n start test for ${PA_Config_key}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
#    Set_PA_for_Scence  Scence_PA_Config=${PA_Config['${PA_Config_key}']}  Value_key=pa_value1
    FOR  ${i}    IN RANGE    ${maxloop}
        log to console    \n***loop in range maxloop
# step1
        Set_PA_for_Precondition  Scence_PA_Config=${PA_Config['${PA_Config_key}']}
        sleep    5s
        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
        MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}    get_spark_license=false
        sleep    8s
        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    20
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    20
#        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        sleep    5
#        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    2s
        Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    2s
#        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
# step2
        sleep    5s
#        ${looptimes}    set variable    ${40}
        HO_loop    PA_Config_key=${PA_Config_key}    times=${Ho_looptimes}
# step3-4
        sleep    20s
        MultiUE.Ho_test_check  UECFG=${UECFG}  default_ue_index=${default_ue_index}  timeout=300  holoops=${Ho_looptimes}
# step5
#        sleep    5s
#        Set_PA_Value    value=${120}    attenuator_index=${0}
#        Set_PA_Value    value=${22}    attenuator_index=${1}
#        Set_PA_Value    value=${120}    attenuator_index=${3}
#        sleep    5s
#        Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        #MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    15s
        Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5s
#        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #log     ${default_ue_index}
    END
    log     ${default_ue_index}
    [teardown]    MultiUE.forceteardown    UECFG=${UECFG}    default_ue_index=${default_ue_index}

HO_loop
    [Arguments]    ${PA_Config_key}    ${times}=${10}
    log to console    \nStart HO_loop
    FOR  ${j}    IN RANGE    ${times}
        log to console    \n***loop in range ho times ${j}
# step3
        sleep    5s
        Set_PA_for_Scence  Scence_PA_Config=${PA_Config['${PA_Config_key}']}  Value_key=pa_value2
        log to console    \n*********pa_value1 to pa_value2 HO
# step4
        sleep    5s
        Set_PA_for_Scence  Scence_PA_Config=${PA_Config['${PA_Config_key}']}  Value_key=pa_value1
        log to console    \n*********pa_value2 to pa_value1 HO
    END

MultiUE.forceteardown
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    run keyword and ignore error    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    run keyword and ignore error    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
#    run keyword and ignore error    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}

MultiUE.basic_traffic_test
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    ...    ${power_reset}=false    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=1
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true    ${protocol}=udp
    ${UECFG}=    run keyword if     "${UECFG}"=="NULL"   MultiUE._L3CallBuildParameters
    ...    power_reset=${power_reset}    ue_mode=${ue_mode}    apn=${apn}    iperf_port=${iperf_port}
    ...    multidrb_QoS_dest=${multidrb_QoS_dest}   check_tput_on_ue=${check_tput_on_ue}    target_avg_percent=${target_avg_percent}
    ...    target_min_percent=${target_min_percent}    check_throughput_duration=${check_throughput_duration}    call_loop=${call_loop}
    ...    cell_index_list=${cell_index_list}    dl_target_throughput=${dl_target_throughput}    ul_target_throughput=${ul_target_throughput}
    ...    ue_index=${ue_index}    detach_request=${detach_request}    protocol=${protocol}
    ...    ELSE    set variable    ${UECFG}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
    FOR  ${i}    IN RANGE    ${maxloop}
#        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}    get_spark_license=false
        sleep    5
        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    20
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #log     ${default_ue_index}
    END
    log     ${default_ue_index}
#    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    [teardown]    MultiUE.forceteardown    UECFG=${UECFG}    default_ue_index=${default_ue_index}

Pa_test_only
    [Documentation]
    ...    attenuator
    ...    0 AQQJ_2_attenuator_multi_ue
    ...    1 AHPB_2_attenuator_multi_ue
    ...    2 AHPB_1_attenuator_mtk
    ...    3 AHCA_LTE_attenuator_multi_ue_1
    [Arguments]    ${PA_Config_key}=CELL16_AdjCELL0
    log to console    \npa_value0
    Set_PA_for_Scence  Scence_PA_Config=${PA_Config['${PA_Config_key}']}  Value_key=pa_value0
#    sleep    10s
#    log to console    \npa_value1
#    Set_PA_for_Scence  Scence_PA_Config=${PA_Config['${PA_Config_key}']}  Value_key=pa_value1
#    sleep    10s
#    log to console    \npa_value2
#    Set_PA_for_Scence  Scence_PA_Config=${PA_Config['${PA_Config_key}']}  Value_key=pa_value2

MultiUE.VONR_CALL_TEST
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
     [Arguments]    ${UECFG}    ${PA_Config_key}    ${default_ue_index}=0
    log to console    \n start test for ${PA_Config_key}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
    FOR  ${i}    IN RANGE    ${maxloop}
        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5s
        MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}    get_spark_license=false
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        Run Keyword And Continue On Failure
        ...    MultiUE.VONR_CALL    PA_Config_key=${PA_Config_key}    UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #log     ttt${default_ue_index}
    END
    log     ${default_ue_index}
    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    [teardown]    MultiUE.forceteardown    UECFG=${UECFG}    default_ue_index=${default_ue_index}

MultiUE.VONR_CALL
    [Arguments]  ${PA_Config_key}  ${UECFG}=NULL  ${default_ue_index}=0  ${timeout}=300  ${holoops}=${1}  ${call_duration}=45
    log to console   \n***VONR_CALL start ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    ${UEnum}    Get Length    ${UECFG['ue_index_for_call']}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        sleep    2s
        spark.Update_test_plan  ue_alias=UE_${ue_index}    service_name=CallMO1    Duration=${call_duration}
        sleep    5s
        spark.Start_test_plan  ue_alias=UE_${ue_index}    task_name=CallMO1
        ${wait_time}    Evaluate    ${call_duration}+${5}
        HO_loop    PA_Config_key=${PA_Config_key}    times=${1}
        sleep    ${wait_time}s
        ${events_name}    Create List    SIP MO Call Established    5G->4G HO Request    5G->4G HO Success    SIP MO Call End
        ${VONR_Established}    ${irat_HO_Request}    ${irat_HO_Success}    ${VONR_End}    spark.get_event_count_on_ue
        ...    index=${ue_index}  event_name=${events_name}  ue_alias=UE_${ue_index}  timeout=${timeout}
        log to console    \n VONR_Established:${VONR_Established}, VONR_End:${VONR_End}
        log to console    \n 5G->4G HO Request:${irat_HO_Request}, 5G->4G HO Success:${irat_HO_Success}
        Should Be Equal As Integers    first=${VONR_Established}    second=${VONR_End}
        Should Be True    ${VONR_Established}>0
        Should Be True    ${irat_HO_Success}>0
    END

MultiUE.RTT_TEST
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    ...    ${power_reset}=false    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=1
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true    ${protocol}=udp
    ${UECFG}=    run keyword if     "${UECFG}"=="NULL"   MultiUE._L3CallBuildParameters
    ...    power_reset=${power_reset}    ue_mode=${ue_mode}    apn=${apn}    iperf_port=${iperf_port}
    ...    multidrb_QoS_dest=${multidrb_QoS_dest}   check_tput_on_ue=${check_tput_on_ue}    target_avg_percent=${target_avg_percent}
    ...    target_min_percent=${target_min_percent}    check_throughput_duration=${check_throughput_duration}    call_loop=${call_loop}
    ...    cell_index_list=${cell_index_list}    dl_target_throughput=${dl_target_throughput}    ul_target_throughput=${ul_target_throughput}
    ...    ue_index=${ue_index}    detach_request=${detach_request}    protocol=${protocol}
    ...    ELSE    set variable    ${UECFG}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
    FOR  ${i}    IN RANGE    ${maxloop}
#        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        log to console    \n* Set_PA_Value for test
#        Set_PA_Value    value=${120}    attenuator_index=${0}
#        Set_PA_Value    value=${22}    attenuator_index=${1}
#        Set_PA_Value    value=${120}    attenuator_index=${3}
        sleep    5s
        MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}    get_spark_license=false
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.PingTest       UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        #MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
#        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #log     ttt${default_ue_index}
    END
    log     ${default_ue_index}
#    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    [teardown]    MultiUE.forceteardown    UECFG=${UECFG}    default_ue_index=${default_ue_index}

MultiUE.PingTest
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    log to console   \n***PingTest start ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    ${UEnum}    Get Length    ${UECFG['ue_index_for_call']}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
#        Run Keyword And Continue On Failure    Do_RTT_PING_Test    ue_index=${ue_index}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if  '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'   Continue For Loop
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for UL}    Set Variable if  ${tl.ues[${ue_index}].capabilities[-1].count('lte')}==0
        ...   ${UECFG['${ue_index}']['ul']['target_throughput']}Mbps/sec   ${UECFG['${ue_index}']['ul']['target_throughput']}
        Run Keyword And Continue On Failure   Do_RTT_PING_Test    ue_index=${ue_index}    UECFG=${UECFG}
    END

Do_RTT_PING_Test
    [Arguments]    ${ue_index}    ${UECFG}=NULL    ${ping_count}=100    ${interval}=0.2    ${packetsize}=64    ${timeout}=35 s    ${avg_ping_max}=100
    ${alias}    set variable    appser_${ue_index}
    ${appserver_ip}    set variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${appserver_username}    set variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ${appserver_password}    set variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ${gnb_addr}    set variable    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ssh.Connect to    ${appserver_ip}    ${appserver_username}    ${appserver_password}    alias=${alias}
    ${ue_ip}=    spark.get_ue_ip_on_ue  ue_alias=UE_${ue_index}  apnaddress=${UECFG['${ue_index}']['apn']}
    ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
    ${cmd_ping_to_ue}  Set variable  ping -c ${ping_count} -i ${interval} -s ${packetsize} ${ue_ip}
    ${output_ping_to_ue}  ssh.execute  ${cmd_ping_to_ue}  connection=${alias}  timeout=${timeout}
    bip capture and check startPRB
    ${avg_ping_to_ue}=    Get_Ping_avg    input_str=${output_ping_to_ue}
    ${output_ping_to_gnb}  ssh.execute  ping -c ${ping_count} -i ${interval} -s ${packetsize} ${gnb_addr}  connection=${alias}  timeout=${timeout}
    ${avg_ping_to_gnb}=    Get_Ping_avg    input_str=${output_ping_to_gnb}
    ${avg_ping}=    Evaluate    ${avg_ping_to_ue}-${avg_ping_to_gnb}
    log to console    \n\${avg_ping}:${avg_ping}
    Should Be True    ${avg_ping} < ${avg_ping_max}    \${avg_ping}:${avg_ping} exceeds \${avg_ping_max}:${avg_ping_max}

Get_Ping_avg
    [Arguments]    ${input_str}
    @{output1}    Get Regexp Matches    ${input_str}    rtt.*
#    log to console    ${output1}
    ${splits}    Split String    string=${output1}[0]
#    log to console    ${splits}
    ${splits1}    Split String    string=${splits}[3]    separator=/
#    log to console    ${splits1}
#    log to console    ${splits1}[1]
    [Return]    ${splits1}[1]


MultiUE.Ho_test_check
    [Documentation]    \n***Should set suite variable    ${events_name} before use
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0    ${timeout}=300    ${holoops}=${1}
    log to console   Ho_test_check start ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    ${UEnum}    Get Length    ${UECFG['ue_index_for_call']}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if  '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'   Continue For Loop
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for UL}    Set Variable if  ${tl.ues[${ue_index}].capabilities[-1].count('lte')}==0
        ...   ${UECFG['${ue_index}']['ul']['target_throughput']}Mbps/sec   ${UECFG['${ue_index}']['ul']['target_throughput']}
        sleep    5s
#        ${events_name}    Create List    SA HO Request    SA HO Success
#        ${events_name}    Create List    4G->5G HO Request    4G->5G SA HO Success
#        ${events_name}    Create List    4G->5G HO Request    4G->5G SA HO Success    5G->4G HO Request    5G->4G SA HO Success
        ${resul_Request}    ${result_Success}    spark.get_event_count_on_ue
        ...    index=${ue_index}  event_name=${events_name}  ue_alias=UE_${ue_index}  timeout=${timeout}
        sleep    2s
        log to console    \n***resul_Request: ${resul_Request}, result_Success: ${result_Success}
        Should Be Equal As Integers    first=${resul_Request}    second=${result_Success}
        should be true    ${result_Success} > ${0}
#        ${result_Success}=  spark.get_event_count_on_ue  index=${ue_index}  event_name=SA HO Success  ue_alias=UE_${ue_index}  timeout=${timeout}
#        Should Be Equal As Integers    first=${resul_Request}    second=${result_Success}
#        ${ho_expect_times}    Evaluate    ${holoops}*2
#        log to console    \n***ho_expect_times: ${ho_expect_times}, result_Success: ${result_Success}
#        Should Not Be True    ${ho_expect_times}<${result_Success}

    END

bip capture and check startPRB
    [Arguments]

    Collect Interface Mirroring Bip Collector
    sleep    2s
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector
#    Mcshark preparation for bip analysis
#    ${Parser}    cap.setup    infile=${full_log_path}[0]    display_filter=${display_filter}
#    ...    tshark_path=${tshark_path}    alias="Parser"
#    ${startPRBlist}    cap.get_field_value_by_name    field_name=${filter_name}    attribute_name=show    pcap_parser="Parser"
    pcap.setup    infile=${full_log_path}[0]    display_filter=${display_filter}    alias=test0
    ${startPRBlist}    pcap.get_field_value    field_name=${filter_name}    pcap_parser=test0
    FOR    ${value}    IN    @{startPRBlist}
        ${status}    set Variable if    ${value}!=${startPRBlist}[1]    True    False
        Exit For Loop If     ${status}==True
    END
    run keyword and continue on failure    Should Be Equal    ${status}    True

MultiUE.GET_event_msg
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0    ${power_reset}=false
    ...    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=${call_loop_num}
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true    ${protocol}=udp
    ${UECFG}=    run keyword if     "${UECFG}"=="NULL"   MultiUE._L3CallBuildParameters
    ...    power_reset=${power_reset}    ue_mode=${ue_mode}    apn=${apn}    iperf_port=${iperf_port}
    ...    multidrb_QoS_dest=${multidrb_QoS_dest}   check_tput_on_ue=${check_tput_on_ue}    target_avg_percent=${target_avg_percent}
    ...    target_min_percent=${target_min_percent}    check_throughput_duration=${check_throughput_duration}    call_loop=${call_loop}
    ...    cell_index_list=${cell_index_list}    dl_target_throughput=${dl_target_throughput}    ul_target_throughput=${ul_target_throughput}
    ...    ue_index=${ue_index}    detach_request=${detach_request}    protocol=${protocol}
    ...    ELSE    set variable    ${UECFG}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
    ${complete_time}    set variable    0
    ${complete_time1}    Convert To Integer    ${complete_time}
    FOR  ${i}    IN RANGE    ${maxloop}
#        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}    get_spark_license=false
        sleep    8s
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        ${event_detail}    Run Keyword And Continue On Failure    MultiUE.Get SA RRC Setup Complete Time    UECFG=${UECFG}
        ...    default_ue_index=${default_ue_index}
        log to console    ${event_detail}
        log to console    ***********
        ${complete_time1}    Evaluate    ${complete_time1}+${event_detail}
#        Run Keyword And Continue On Failure    MultiUE.Detach    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    END
    ${complete_time1}    Evaluate    ${complete_time1}/${call_loop}
    Should Be True    ${complete_time1}<100
    log     ${default_ue_index}
    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    [Return]    ${complete_time1}

MultiUE.Get SA RRC Setup Complete Time
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        ${complete_time}    Run Keyword And Continue On Failure    spark.get_SA_RRC_setup_complete_time_on_ue
        ...    index=${ue_index}    ue_alias=UE_${ue_index}
    END
    [Return]    ${complete_time}
