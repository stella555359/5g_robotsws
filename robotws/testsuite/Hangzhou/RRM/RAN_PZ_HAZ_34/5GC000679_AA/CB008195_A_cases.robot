*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB008195         PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          Resources/5GC000679_common_keyword_Dingli.robot
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008744/Resources/CB008744_C_commen_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}              /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T218

${data_transfer_dl}     800Mbits/sec
${data_transfer_ul}     80Mbits/sec
${Expected_Throughput_DL}     200
${Expected_Throughput_UL}     40

*** Test Cases ***
[1]CB008195_A_B1_Activation_of_Slice_Aware_Admission_Control_without_active_users
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case1.xml
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_SR_I_1_B1_1_disabled_reservations_of_multi_cell_pooled_resources_UE_context_SA_RAC_success
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_SR_I_TMO.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    attach UE457 and check counter
    Modify parameter to new value online 8195    value=cell_and_multicell_level
    Run Keyword And Ignore Error    spark send CMD detach all UE
    sleep      100s
    Run Keyword And Ignore Error    attach UE457 and check counter
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1]CB008195_SR_HA_14_UPD001_2_Start_broadcasting_automatic_UAC_parameters_in_SIB1_due_to_pool_utilization_when_there_are_unused_reserved_resources
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_SR_HA_TMO.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD detach all UE
    Run Keyword And Ignore Error    check counter value
    Run Keyword And Ignore Error    attach UE4 and check counter
    Run Keyword And Ignore Error    attach UE5 and check counter
    Run Keyword And Ignore Error    spark send CMD detach all UE
    Run Keyword And Ignore Error    check counter value
    Modify parameter online 8195    dist_name=MRBTS-20218/NRBTS-20218/NRRESOURCEGROUP_PROFILE-1
    ...                             parameter=applyCellRacForPrivilegedUE    value=0001
    #Modify parameter online 8195    dist_name=MRBTS-20218/NRBTS-20218/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-2
    #...                             parameter=racParams.minQuota    value=50
    Run Keyword And Ignore Error    attach UE4 and check counter
    Run Keyword And Ignore Error    attach UE5 and check counter
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_SR_HA_11_B4_1_Emergency_GBR_DRB_admission_with_RG_limits_multi_cell_pooled
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_SR_HA_TMO.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD detach all UE
    Run Keyword And Ignore Error    check counter value
    Run Keyword And Ignore Error    attach UE4 and check counter
    Run Keyword And Ignore Error    attach UE5 and check counter
    Run Keyword And Ignore Error    spark send CMD detach all UE
    Run Keyword And Ignore Error    check counter value
    Modify parameter online 8195    dist_name=MRBTS-20218/NRBTS-20218/NRRESOURCEGROUP_PROFILE-1
    ...                             parameter=applyCellRacForPrivilegedUE    value=0001
    Run Keyword And Ignore Error    attach UE4 and check counter
    Run Keyword And Ignore Error    attach UE5 and check counter
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_A_B4_2_non-GBR_DRB_admission_for_DRBs_added_or_modified_during_PDU_Session_modification_procedure_SA_maxNumOfNonGBRBearersSA
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case2.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=0
    Run Keyword And Ignore Error    spark send CMD detach all UE
    sleep      100s
    Run Keyword And Ignore Error    spark UE attach    n=0
    sleep      100s
    Run Keyword And Ignore Error    8195 counter check
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_A_B3_2_UE_Context_admission_SA_maxNumOfUsersPerNRCell_Common_Pool
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case3.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=0
    Run Keyword And Ignore Error    spark send CMD detach all UE
    sleep      100s
    Run Keyword And Ignore Error    spark UE attach    n=0
    sleep      100s
    Run Keyword And Ignore Error    8195 counter check
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_A_B5_2_UE_Context_admission_dynamic_cell_limits_SA_success_maxNumOfRrcConUEsPerDU
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case4.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD on UE1256
    sleep      100s
    Run Keyword And Ignore Error    8195 counter check
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_A_B7_2_admission_for_incoming_intra-gNB_HO_static_cell_limits_SA_success
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case5.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=0
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=7
    Run Keyword And Ignore Error    spark send CMD detach all UE
    sleep      100s
    Run Keyword And Ignore Error    spark UE attach    n=0
    Run Keyword And Ignore Error    spark UE attach    n=7
    sleep      100s
    Run Keyword And Ignore Error    8195 counter check
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_D_B1_1_RRC_and_UE_Context_admission_control_SA_NSA_mixmode
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case6.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=0
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=7
    Run Keyword And Ignore Error    spark send CMD detach all UE
    sleep      100s
    Run Keyword And Ignore Error    spark UE attach    n=0
    Run Keyword And Ignore Error    spark UE attach    n=7
    sleep      100s
    Run Keyword And Ignore Error    8195 counter check
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

[1][1.0] CB008195_SR_H_08_B3_2_Emergency_non-GBR_DRB_admission_with_resource_group_limits_for_static_cell_applyCellRacForPrivilegedUE_set
    [Tags]    CB008195    CRT_TRUNK
    [Setup]    Case Setup 8195
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8195_case7.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=0
    Run Keyword And Ignore Error    spark send CMD on UE    ue_index=7
    Run Keyword And Ignore Error    spark send CMD detach all UE
    sleep      100s
    Run Keyword And Ignore Error    spark UE attach    n=0
    Run Keyword And Ignore Error    spark UE attach    n=7
    sleep      100s
    Run Keyword And Ignore Error    8195 counter check
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=0    apn_address=wap1nokiacom

*** Keywords ***
Case Setup 8195
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932
    ERR_WRN_Check.Stop BTSLogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable     ${execution_env_type}       DEBUG

Check 8195 DL UL Tput on GNB
    [Documentation]    check 3CC DL&UL tput on gnb
    ${DL_tput_cell1}    Check throughput on gNB    direction=dl    throughput=80    cellid=331251722
    ${DL_tput_cell2}    Check throughput on gNB    direction=dl    throughput=0    cellid=331252213
    ${DL_tput_cell3}    Check throughput on gNB    direction=dl    throughput=0    cellid=331251714
    ${1CC_DL_tput}    Evaluate    ${DL_tput_cell1}+${DL_tput_cell2}+${DL_tput_cell3}
    Should be true    ${1CC_DL_tput}>=80
    ${UL_tput_cell1}    Check throughput on gNB    direction=ul    throughput=18    cellid=331251722

spark send CMD on UE1256
    [Documentation]    send CMD for UE1256 by spark
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",42,127470,15,71       ue_alias=UE_0
    spark.send_at_command_on_ue    command=AT+CFUN=0     ue_alias=UE_0
    spark.send_at_command_on_ue    command=AT+CFUN=1     ue_alias=UE_0
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,509070,30,41       ue_alias=UE_1
    spark.send_at_command_on_ue    command=AT+CFUN=0     ue_alias=UE_1
    spark.send_at_command_on_ue    command=AT+CFUN=1     ue_alias=UE_1
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,509070,30,41       ue_alias=UE_4
    spark.send_at_command_on_ue    command=AT+CFUN=0     ue_alias=UE_4
    spark.send_at_command_on_ue    command=AT+CFUN=1     ue_alias=UE_4
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,509070,30,41       ue_alias=UE_5
    spark.send_at_command_on_ue    command=AT+CFUN=0     ue_alias=UE_5
    spark.send_at_command_on_ue    command=AT+CFUN=1     ue_alias=UE_5

spark send CMD on UE
    [Arguments]    ${ue_index}    ${ue_alias}=UE_${ue_index}
    [Documentation]    send CMD for UE by spark
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=False
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",AUTO          ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="nr5g_disable_mode",0     ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G          ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,503310,30,41     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s


spark send CMD detach all UE
    [Documentation]    dettach all UE
    log to console      "detach_ues"
    FOR    ${i}    IN RANGE    8
        power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${i}    get_spark_license=False
        spark.send_at_command_on_ue    command=AT+CFUN=0        ue_alias=UE_${i}
    END

spark UE attach
    [Arguments]    ${n}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Ignore Error    spark.send_at_command_on_ue    command=AT+CFUN=1    ue_alias=UE_${n}

attach UE4 and check counter
    spark send CMD on UE    ue_index=4
    sleep      30s
    ${M55910C00012}      Get BTS Counters from webUI    counter_id=M55910C00012
    ${M55910C00021}      Get BTS Counters from webUI    counter_id=M55910C00021
    ${M55910C00022}      Get BTS Counters from webUI    counter_id=M55910C00022
    Should be true    ${M55910C00012}=1
    Should be true    ${M55910C00021}=1
    Should be true    ${M55910C00022}=1

attach UE5 and check counter
    spark send CMD on UE    ue_index=5
    sleep      30s
    ${M55910C00012}      Get BTS Counters from webUI    counter_id=M55910C00012
    ${M55910C00021}      Get BTS Counters from webUI    counter_id=M55910C00021
    ${M55910C00022}      Get BTS Counters from webUI    counter_id=M55910C00022
    Should be true    ${M55910C00012}=2
    Should be true    ${M55910C00021}=1
    Should be true    ${M55910C00022}=1

check counter value
    [Documentation]    check related PM counter value
    ${M55910C00012}      Get BTS Counters from webUI    counter_id=M55910C00012
    ${M55910C00021}      Get BTS Counters from webUI    counter_id=M55910C00021
    ${M55910C00022}      Get BTS Counters from webUI    counter_id=M55910C00022
    Should be true    ${M55910C00012}=0
    Should be true    ${M55910C00021}=0
    Should be true    ${M55910C00022}=0

attach UE457 and check counter
    spark send CMD on UE    ue_index=4
    sleep      100s
    8195 counter check
    spark send CMD on UE    ue_index=5
    sleep      100s
    8195 counter1 check
    spark send CMD on UE    ue_index=7
    sleep      100s
    8195 counter check

Modify parameter online 8195
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    &{param}    Create Dictionary    dist_name=${dist_name}    parameter=${parameter}    value=${value}
    @{modify_param}    Create List    ${param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=600

Modify parameter to new value online 8195
    [Arguments]    ${value}
    [Documentation]   Modify parameter online
    ...          :value     new value which to change
    Modify parameter online 8195    dist_name=MRBTS-20218/NRBTS-20218    parameter=rgMinQuotaReservationLevel
    ...                             value=${value}
    sleep    1min

8195 counter1 check
    [Documentation]    check related PM counter value
    ...          :M55910C00017:    AVG_NUM_UE_NOM_NRG  > 0
    ...          :M55910C00007:    AVE_NUM_NGBR_NOM_NRG > 0
    ...          :M55910C00010:    PEAK_NUM_UE_NRG+1
    ...          :M55910C00011:    PEAK_NUM_NGBR_NRG+1
    ...          :M55910C00017:    NUM_ADM_REQ_NGBR_NRG+1
    ...          :M55910C00018:    NUM_ADM_SUC_NGBR_NRG+1
    ...          :M55910C00023:    NUM_ADM_REQ_UE_NRG+1
    ...          :M55910C00024:    NUM_ADM_SUC_UE_NRG+1
    ${AVG_NUM_UE_NOM_NRG}        Get BTS Counters from webUI    counter_id=M55910C00005
    ${DNOM_SAMPLES_NRG}          Get BTS Counters from webUI    counter_id=M55910C00006
    ${AVE_NUM_NGBR_NOM_NRG}      Get BTS Counters from webUI    counter_id=M55910C00007
    ${PEAK_NUM_UE_NRG}           Get BTS Counters from webUI    counter_id=M55910C00010
    ${PEAK_NUM_NGBR_NRG}         Get BTS Counters from webUI    counter_id=M55910C00011
    ${NUM_ADM_REQ_NGBR_NRG}      Get BTS Counters from webUI    counter_id=M55910C00017
    ${NUM_ADM_SUC_NGBR_NRG}      Get BTS Counters from webUI    counter_id=M55910C00018
    ${NUM_ADM_REQ_UE_NRG}        Get BTS Counters from webUI    counter_id=M55910C00023
    ${NUM_ADM_SUC_UE_NRG}        Get BTS Counters from webUI    counter_id=M55910C00024
    Should be true    ${AVG_NUM_UE_NOM_NRG}>0
    Should be true    ${AVE_NUM_NGBR_NOM_NRG}>0
    Should be true    ${PEAK_NUM_UE_NRG}=1
    Should be true    ${PEAK_NUM_NGBR_NRG}=2
    Should be true    ${NUM_ADM_REQ_NGBR_NRG}=2
    Should be true    ${NUM_ADM_SUC_NGBR_NRG}=2
    Should be true    ${NUM_ADM_REQ_UE_NRG}=1
    Should be true    ${NUM_ADM_SUC_UE_NRG}=1

8195 counter check
    [Documentation]    check related PM counter value
    ...          :M55910C00017:    AVG_NUM_UE_NOM_NRG  > 0
    ...          :M55910C00006:    DNOM_SAMPLES_NRG=300
    ...          :M55910C00007:    AVE_NUM_NGBR_NOM_NRG > 0
    ...          :M55910C00010:    PEAK_NUM_UE_NRG+1
    ...          :M55910C00011:    PEAK_NUM_NGBR_NRG+2
    ...          :M55910C00017:    NUM_ADM_REQ_NGBR_NRG+2
    ...          :M55910C00018:    NUM_ADM_SUC_NGBR_NRG+2
    ...          :M55910C00023:    NUM_ADM_REQ_UE_NRG+1
    ...          :M55910C00024:    NUM_ADM_SUC_UE_NRG+1
    ${AVG_NUM_UE_NOM_NRG}        Get BTS Counters from webUI    counter_id=M55910C00005
    ${DNOM_SAMPLES_NRG}          Get BTS Counters from webUI    counter_id=M55910C00006
    ${AVE_NUM_NGBR_NOM_NRG}      Get BTS Counters from webUI    counter_id=M55910C00007
    ${PEAK_NUM_UE_NRG}           Get BTS Counters from webUI    counter_id=M55910C00010
    ${PEAK_NUM_NGBR_NRG}         Get BTS Counters from webUI    counter_id=M55910C00011
    ${NUM_ADM_REQ_NGBR_NRG}      Get BTS Counters from webUI    counter_id=M55910C00017
    ${NUM_ADM_SUC_NGBR_NRG}      Get BTS Counters from webUI    counter_id=M55910C00018
    ${NUM_ADM_REQ_UE_NRG}        Get BTS Counters from webUI    counter_id=M55910C00023
    ${NUM_ADM_SUC_UE_NRG}        Get BTS Counters from webUI    counter_id=M55910C00024
    Should be true    ${AVG_NUM_UE_NOM_NRG}>0
    Should be true    ${DNOM_SAMPLES_NRG}=300
    Should be true    ${AVE_NUM_NGBR_NOM_NRG}>0
    Should be true    ${PEAK_NUM_UE_NRG}=1
    Should be true    ${PEAK_NUM_NGBR_NRG}=2
    Should be true    ${NUM_ADM_REQ_NGBR_NRG}=2
    Should be true    ${NUM_ADM_SUC_NGBR_NRG}=2
    Should be true    ${NUM_ADM_REQ_UE_NRG}=1
    Should be true    ${NUM_ADM_SUC_UE_NRG}=1

Download pm file From ASIK To TestPC
    [Arguments]    ${path}    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master
    @{pm_names1}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=PM.*.*0000.ANY.xml.gz
    @{pm_names2}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=PM.*.*1500.ANY.xml.gz
    @{pm_names3}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=PM.*.*3000.ANY.xml.gz
    @{pm_names4}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=PM.*.*4500.ANY.xml.gz
    @{list_log_names}    Create list    @{pm_names1}    @{pm_names2}    @{pm_names3}    @{pm_names4}
	Sort List    ${list_log_names}
    log    ${list_log_names}
    @{list_log_path_local}    Create list
    @{list_size}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    Sort List    ${list_log_path_local}
    ${result}    String.split string    string=${list_log_names}[-1]    separator=.gz
    [Return]    ${list_log_path_local}[-1]    ${result}[0]

Download PM File
    [Arguments]    ${path}=/ffs/run/uri/PERFMON_FILES
    Connect to Common Unit Master
    run    rm -r ${TS_CASE_LOG_PATH}/*
    ${pm_file}    ${PM_name}    Download pm file From ASIK To TestPC    path=${path}
    should not be empty    ${pm_file}
    Run    gzip -d ${pm_file}
    #run    rm -r ${TS_CASE_LOG_PATH}/PM.*.gz
    [Return]    ${TS_CASE_LOG_PATH}/${PM_name}

Calcu kpi from pm
    [Arguments]    ${pm_path}
    ${pm_file_path}    Download PM File
    @{values}    Create list
    Set Test Variable    ${values}    ${values}
    FOR   ${pm}   IN   @{pm_path}
	    ${value}    calcu_kpi_from_pmfile    file_name=${pm_file_path}    pm_name=${pm}
        Append to list    ${values}    ${value}
    END
    Set test variable    @{kpi_counter}    @{values}
    [Return]    @{values}

spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${apn_address}    ${ue_mode}    ${attach_mode}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    Run Keyword And Continue On Failure    Spark UE attach    n=${n}    attach_mode=${attach_mode}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

All spark UEs attach and start DLUL traffic
    [Arguments]     ${apn_address}=${apn1}    ${ue_mode}=NSA    ${attach_mode}=5G_NSA
    FOR    ${i}    IN RANGE    8
        spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
        ...                                     data_transfer_ul=${data_transfer_ul}
        ...                                     n=${i}
        ...                                     ue_mode=${ue_mode}
        ...                                     attach_mode=${attach_mode}
        ...                                     apn_address=${apn_address}
    END
