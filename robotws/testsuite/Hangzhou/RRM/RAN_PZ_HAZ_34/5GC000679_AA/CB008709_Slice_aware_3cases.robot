*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB008709         PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008744/Resources/CB008744_C_commen_keywords.robot
Variables         Resources/3CC_modify_para.py

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

${data_transfer_dl}     800Mbits/sec
${data_transfer_ul}     100Mbits/sec
${Expected_Throughput_DL}     200
${Expected_Throughput_UL}     30

@{pm_path}    ${CURDIR}/Resources/NR_case1.txt    ${CURDIR}/Resources/NR_case2.txt

*** Test Cases ***
[1]CB008709_SR_D_13_B2_03_Slice_aware_uplink_scheduler_interacts_pooling_TDD_SA_NSA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case3_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=0
    ...                                     ue_mode=SA
    ...                                     apn_address=dxdata2
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=3
    ...                                     ue_mode=SA
    ...                                     apn_address=dxdata2
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=dxdata2
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=dxdata2

[1]CB008709_SR_E_27_B1_01_Slice_aware_uplink_scheduler_interacts_with_UL_MU-MIMO_SA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case6_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=0
    ...                                     ue_mode=SA
    ...                                     apn_address=dxdata2
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=3
    ...                                     ue_mode=SA
    ...                                     apn_address=dxdata2
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=dxdata2
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=dxdata2

[1]CB008709_SR_B_1_B1_01_Slice_aware_downlink_scheduler_SA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case1_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                      data_transfer_dl=${data_transfer_dl}
    ...                                      data_transfer_ul=${data_transfer_ul}
    ...                                      n=0
    ...                                      ue_mode=SA
    ...                                      apn_address=dxdata2
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error     Check DL UL Tput on GNB
    Run Keyword And Ignore Error     Check PM counter case1
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=dxdata2
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=dxdata2

[1]CB008709_SR_B_3_B1_03_Slice_aware_downlink_scheduler_SA_NSA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case1_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                      data_transfer_dl=${data_transfer_dl}
    ...                                      data_transfer_ul=${data_transfer_ul}
    ...                                      n=0
    ...                                      ue_mode=SA
    ...                                      apn_address=dxdata2
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error     Check DL UL Tput on GNB
    Run Keyword And Ignore Error     Check PM counter case1
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=dxdata2
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=dxdata2

[1]CB008709_SR_L_32_B1_01_Slice aware downlink scheduler_actSliceAwareSchedulerEnh_False_NSA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case2_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=6
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=6
    ...                                     ue_mode=NSA
    ...                                     apn_address=wap1nokiacom
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case2
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1]CB008709_SR_L_33_B1_02_Slice aware downlink scheduler_actSliceAwareSchedulerEnh_False_NSA_SA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case2_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=6
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=6
    ...                                     ue_mode=NSA
    ...                                     apn_address=wap1nokiacom
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case2
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

[1]CB008709_G_16_EC2_01_Slice_aware_uplink_scheduler_with_excessive_GBR_load
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case4_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=1
    ...                                     ue_mode=SA
    ...                                     apn_address=mdrbnokiacom
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=4
    ...                                     ue_mode=SA
    ...                                     apn_address=wap2nokiacom
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case4
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap2nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap2nokiacom

[1]CB008709_F_2_B1_02_Slice_aware_uplink_scheduler_interacts_with_multiple_BWPs_TDD_Multi_UEs
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case5_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=1
    ...                                     ue_mode=SA
    ...                                     apn_address=wap2nokiacom
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=4
    ...                                     ue_mode=SA
    ...                                     apn_address=wap2nokiacom
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case5
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap2nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap2nokiacom

[1]CB008709_SR_D_13_B2_03_Slice_aware_uplink_scheduler_interacts_with_PRB_pooling_TDD_SA_NSA
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case3_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=1
    ...                                     ue_mode=SA
    ...                                     apn_address=mdrbnokiacom
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=4
    ...                                     ue_mode=SA
    ...                                     apn_address=wap2nokiacom
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case3
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap2nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap2nokiacom

[1]CB008709_SR_X_Cancelled_transmissions_during_BWP_switch_to_nominalBWP
    [Tags]    CB008709    trunk
    [Setup]    Case Setup 8709
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8709_case5_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    Connect to Common Unit Master
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error     spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=1
    ...                                     ue_mode=SA
    ...                                     apn_address=wap2nokiacom
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=4
    ...                                     ue_mode=SA
    ...                                     apn_address=wap2nokiacom
    sleep      15min
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    Check PM counter case5
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap2nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap2nokiacom

*** Keywords ***
Case Setup 8709
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932

Check DL UL Tput on GNB
    [Documentation]    check DL&UL tput on gnb
    Check throughput on gNB    direction=dl    throughput=${Expected_Throughput_DL}
    Check throughput on gNB    direction=ul    throughput=${Expected_Throughput_UL}

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

Check PM counter case1
    [Documentation]    check related PM counter value
    ${counter_PRB_AVAIL_PDSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10013
    ${counter_DL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00001
    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00002
    ${kpi_counter}    Evaluate    ${counter_DL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PDSCH_SLICES}
    Should be true    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}>=70
    Should be true    ${kpi_counter}>0.6
    Should be true    ${kpi_counter}<=0.75

Check PM counter case2
    [Documentation]    check related PM counter value
    ${counter_PRB_AVAIL_PDSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10013
    ${counter_DL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00001
    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00002
    ${kpi_counter}    Evaluate    ${counter_DL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PDSCH_SLICES}
    Should be true    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}>=90
    Should be true    ${kpi_counter}>0.6
    Should be true    ${kpi_counter}<=0.95

Check PM counter case3
    [Documentation]    check related PM counter value
    Run Keyword And Ignore Error    Calcu kpi from pm    pm_path=${pm_path}
    Run Keyword And Ignore Error    ${counter5_info}    Get PM Counter Latest Value From Admin    M55308C10013    CELLS/NRCELL-2/NCELA
    Run Keyword And Ignore Error    ${counter6_info}    Get PM Counter Latest Value From Admin    M55308C10013    CELLS/NRCELL-4/NCELA
    ${cell1_slice1_value}    Evaluate    float(${counter5_info})/float(${counter6_info})
    Should Be True    ${cell1_slice1_value}>0.41
    ${counter_PRB_AVAIL_PDSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10013
    ${counter_DL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00001
    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00002
    ${counter_PRB_AVAIL_PUSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10012
    ${counter_UL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00003
    ${counter_UL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00004
    ${kpi_counter1}    Evaluate    ${counter_DL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PDSCH_SLICES}
    Should be true    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}>=64
    Should be true    ${kpi_counter1}>0.6
    Should be true    ${kpi_counter1}<=0.65
    ${kpi_counter2}    Evaluate    ${counter_UL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PUSCH_SLICES}
    Should be true    ${counter_UL_PRB_UTIL_SLOT_MAX_NRG}>=64
    Should be true    ${kpi_counter2}>0.6
    Should be true    ${kpi_counter2}<=0.65

Check PM counter case4
    [Documentation]    check related PM counter value
    ${counter_PRB_AVAIL_PDSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10013
    ${counter_DL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00001
    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00002
    ${counter_PRB_AVAIL_PUSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10012
    ${counter_UL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00003
    ${counter_UL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00004
    ${kpi_counter1}    Evaluate    ${counter_DL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PDSCH_SLICES}
    Should be true    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}>0
    Should be true    ${kpi_counter1}>0
    Should be true    ${kpi_counter1}<0.05
    ${kpi_counter2}    Evaluate    ${counter_UL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PUSCH_SLICES}
    Should be true    ${counter_UL_PRB_UTIL_SLOT_MAX_NRG}>0
    Should be true    ${kpi_counter2}>0
    Should be true    ${kpi_counter2}<0.2

Check PM counter case5
    [Documentation]    check related PM counter value
    ${counter_PRB_AVAIL_PDSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10013
    ${counter_DL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00001
    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00002
    ${counter_PRB_AVAIL_PUSCH_SLICES}        Get BTS Counters from webUI    counter_id=M55308C10012
    ${counter_UL_PRB_USED_DATA_NRG}          Get BTS Counters from webUI    counter_id=M55910C00003
    ${counter_UL_PRB_UTIL_SLOT_MAX_NRG}      Get BTS Counters from webUI    counter_id=M55910C00004
    ${kpi_counter1}    Evaluate    ${counter_DL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PDSCH_SLICES}
    Should be true    ${counter_DL_PRB_UTIL_SLOT_MAX_NRG}>0
    Should be true    ${kpi_counter1}>0.45
    Should be true    ${kpi_counter1}<0.55
    ${kpi_counter2}    Evaluate    ${counter_UL_PRB_USED_DATA_NRG}/${counter_PRB_AVAIL_PUSCH_SLICES}
    Should be true    ${counter_UL_PRB_UTIL_SLOT_MAX_NRG}>0
    Should be true    ${kpi_counter2}>0.3
    Should be true    ${kpi_counter2}<0.5

spark send CMD on UE
    [Arguments]    ${i}
    Run keyword if    ${i}==0    spark send CMD on UE1
    ...    ELSE IF    ${i}==6    spark send CMD on UE7
    ...    ELSE IF    ${i}==1    spark send CMD on UE2
    ...    ELSE IF    ${i}==4    spark send CMD on UE5
    ...    ELSE                  spark send CMD on UE4

spark send CMD on UE1
    [Arguments]    ${ue_alias}=UE_0
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",AUTO    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="nr5g_disable_mode",0  ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G     ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,503310,30,41     ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+cgdcont=1,"IPV4V6","dxdata2"     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s

spark send CMD on UE4
    [Arguments]    ${ue_alias}=UE_3
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",AUTO    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="nr5g_disable_mode",0  ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G     ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,503310,30,41     ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+cgdcont=1,"IPV4V6","dxdata2"     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s

spark send CMD on UE7
    [Arguments]    ${ue_alias}=UE_6
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",AUTO    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="nr5g_disable_mode",1    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",LTE:NR5G     ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+cgdcont=1,"IPV4V6","wap1.nokia.com"     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s

spark send CMD on UE2
    [Arguments]    ${ue_alias}=UE_1
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,503310,30,41    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+cgdcont=1,"IPV4V6","wap2.nokia.com"     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s

spark send CMD on UE5
    [Arguments]    ${ue_alias}=UE_4
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,503310,30,41    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+cgdcont=1,"IPV4V6","wap2.nokia.com"     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      15s

Spark UE attach
    [Arguments]    ${n}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Continue On Failure    spark send CMD on UE    i=${n}

spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${apn_address}    ${ue_mode}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    Run Keyword And Continue On Failure    Spark UE attach    n=${n}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
