*** Settings ***
Documentation    This is for feature CB012810 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG3

Resource       ./CB012810_common_keyword.robot
Library       ./CB012810_common_keyword.py
Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot


*** Keywords ***
# --------------------------------------12810-A2B2005-----------------------------------------#
UE_and_PA_prepare
    [Arguments]
    ...            ${gnb_cell1_value}=${127}     ${gnb_cell3_value}=${127}
    ...            ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}
    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${gnb_cell1_value}    gnb_cell3_value=${gnb_cell3_value}
    ...                                            enb_cell1_value=${enb_cell1_value}    enb_cell2_value=${enb_cell2_value}
    power_ue.Prepare UE    ue_type=${ue_type_0}    ue_index=${0}    reset_sol=none    #only attach to cell1/CELL3
    samsung_UE_prepare    ue_index=${1}    ue_type=${ue_type_samsung}    ui_version=S24UI5.1
    samsung_UE_prepare    ue_index=${2}    ue_type=${ue_type_samsung}    ui_version=S24UI5.1    #PA
    samsung_UE_prepare    ue_index=${3}    ue_type=${ue_type_samsung}    ui_version=S21UI3.1


UE_and_PA_prepare_classical_gnb
    [Arguments]
    ...            ${gnb_cell1_value}=${127}     ${gnb_cell2_value}=${127}
    ...            ${enb_cell1_value}=${127}
    Adjust the HBTE attenuation value for TL233    gnb_cell1_value=${gnb_cell1_value}    gnb_cell2_value=${gnb_cell2_value}
    ...    enb_cell1_value=${enb_cell1_value}
    samsung_UE_prepare    ue_index=${0}    ue_type=${ue_type_samsung}    ui_version=S20UI2.5
    samsung_UE_prepare    ue_index=${1}    ue_type=${ue_type_samsung}    ui_version=S20UI2.5
    samsung_UE_prepare    ue_index=${2}    ue_type=${ue_type_samsung}    ui_version=S20UI2.5
    power_ue.Prepare UE    ue_index=${3}    ue_type=${ue_type_MTP}    reset_sol=none

The 1st normal UE attached success A2B2015
    [Arguments]     ${ue_index}=${0}
    ...             ${gnb_index}=${0}
    ...             ${tcpdump_collector_name}=${A2B2015_wireshark_attach_N1}
    ...             ${sleep_time}=2s
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${throughput}=5M
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    UE attach for QCOM and verify with retry    ue_index=${ue_index}    ue_type=${ue_type_0}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type_0}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

The 1st normal UE attached success A2B2015 classical
    [Arguments]     ${ue_index}=${0}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${A2B2015_wireshark_attach_N1}
    ...             ${sleep_time}=2s
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${throughput}=5M
    ...             ${wireshark_target_dir}=${epc_log_path}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

The 2nd normal UE attached failed then make EMC call A2B2015
    [Arguments]     ${ue_index}=${1}
    ...             ${gnb_index}=${0}
    ...             ${sleep_time}=2s
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${A2B2015_wireshark_attach_N2}    gNB_index=${gnb_index}
    ${attach_status}    Run Keyword And Return Status    UE Attach for failure scenario    ue_index=${ue_index}
    should be true    ${attach_status} == False
    ${attachlog_UE2}    Stop and download the wiresharklog from master    filename=${A2B2015_wireshark_attach_N2}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    sleep    ${sleep_time}    reason=wait for ue attach failure and capture wiresharklog
    Start capture wireshark log on master     filename=${A2B2015_wireshark_attach_EMC}    gNB_index=${gnb_index}
    Make a call dial 911 on UE    ue_index=${ue_index}
    sleep    5s     reason=wait for ue attach success and capture wiresharklog
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${A2B2015_wireshark_attach_EMC}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${attachlog_UE2}    ${cpif_log_path}


The 3rd PA UE attached success A2B2015
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${A2B2015_wireshark_attach_PA}
    ...             ${sleep_time}=10s
    ...             ${throughput}=5M
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

A2B2015 counter check
    [Arguments]      ${counter_id}=${counter_id_A2B2015}
    ...              ${dic_path}=${counter_dic_path_A2B2015}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${16}     #'M55165C00002' drb level
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${32}     #'M55165C00003' cell level
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${300}     #'M55165C00015' Denominator for SR pools resources
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${3}      #'M55165C00020' RRC SR slot20
    run keyword and continue on failure     should be true    ${counter_value[4]} < ${4800}     #'M55165C00031' DRB SR pool free, total:4800
    run keyword and continue on failure     should be true    ${counter_value[5]} < ${9600}     #'M55165C00032' cell SR pool free, total:9600

A2B2015 log check
    [Arguments]    ${attachlog_UE1}    ${attachlog_UE2}    ${EMCcall_UE2}    ${attachlog_UE3}
    ...            ${PA_cause}=establishmentCause: mps-PriorityAccess (8)
    log to console    ue1 log check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE1}
    ${contextsetup_failure}    run keyword and return status
    ...     Get and Check InitialContextSetup in wireshark after attach    file_path=${attachlog_UE1}
    should be true    ${contextsetup_failure} == False
    ${UE1_SR}    Get finally used SR_periodicity    file_path=${attachlog_UE1}
    log to console    ue2 attach check
#    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE2}
    Get and Check InitialContextSetup in wireshark after attach    file_path=${attachlog_UE2}
    log to console    ue2 emc check
    check emc call if setup success    file_path=${EMCcall_UE2}
    ${UE2_SR}    Get finally used SR_periodicity    file_path=${attachlog_UE2}
    log to console    ue3 attach check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE3}
    ...                                                          establishment_cause_target=${PA_cause}
    ${contextsetup_failure}    run keyword and return status
    ...     Get and Check InitialContextSetup in wireshark after attach    file_path=${attachlog_UE3}
    should be true    ${contextsetup_failure} == False
    ${UE3_SR}    Get finally used SR_periodicity    file_path=${attachlog_UE3}

A2B2015_case_recovery
    [Arguments]    ${ue_index}=${1}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${recovery_parameter_A2B2015}
    run keyword and ignore error    End a call on UE with adb    ue_index=${ue_index}
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

A2B2015_case_recovery_classical
    [Arguments]    ${ue_index}=${2}
    ...             ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${recovery_parameter_A2B2015_${MRBTS_ID}}
    run keyword and ignore error    End a call on UE with adb    ue_index=${ue_index}
    run keyword and ignore error    Detach all ues classical
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

# --------------------------------------12810-A3IWK3001-----------------------------------------#
The 1st normal UE attached success A3IWK3001
    [Arguments]     ${ue_index}=${3}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${A3IWK3001_wireshark_attach_N1}
    ...             ${sleep_time}=5s
    ...             ${throughput}=5M
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

The 2nd normal UE attached success A3IWK3001
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${A3IWK3001_wireshark_attach_N2}
    ...             ${sleep_time}=5s
    ...             ${throughput}=5M
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    ${dl_port_02}    Evaluate    ${DL_PORT_UE0}+100
    Set Test Variable    ${dl_port_02}
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port_02}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

The 3rd normal UE preempt the 1st UE A3IWK001
    [Arguments]     ${ue_index}=${1}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${A3IWK3001_wireshark_attach_N3}
    ...             ${sleep_time}=2s
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
#    sleep    2s     reason=wait for ue attach success
#    Make a call dial 911 on UE    ue_index=${ue_index}
    sleep    ${sleep_time}     reason=wait for ue attach access and capture log
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]    ${cpif_log_path}

A3IWK3001 log check
    [Arguments]    ${attachlog_UE1}     ${attachlog_UE2}    ${attachlog_UE3}
    ...            ${establishment_PA_user}=establishmentCause: mps-PriorityAccess (8)
    log to console    ue1 log check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE1}
    ${SR_period_UE1_RRC}    ${SR_offset_UE1_RRC}    ${PUCCH_startPRB_UE1_RRC}    ${initialCyclicshift_UE1_RRC}    ${timeDomainOcc_UE1_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE1}
    run keyword and continue on failure     Should be true    '${SR_period_UE1_RRC}' == 'sl20'
    ${SR_period_UE1_5QI}    ${SR_offset_UE1_5QI}    ${PUCCH_startPRB_UE1_5QI}    ${initialCyclicshift_UE1_5QI}    ${timeDomainOcc_UE1_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${attachlog_UE1}
    run keyword and continue on failure     Should be true    '${SR_period_UE1_5QI}' == 'sl5'
    log to console    ue2 log check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE2}
    ...                                                          establishment_cause_target=${establishment_PA_user}
    ${SR_period_UE2_RRC}    ${SR_offset_UE2_RRC}    ${PUCCH_startPRB_UE2_RRC}    ${initialCyclicshift_UE2_RRC}    ${timeDomainOcc_UE2_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE2}
    run keyword and continue on failure     Should be true    '${SR_period_UE2_RRC}' == 'sl20'
    ${SR_period_UE2_5QI}    ${SR_offset_UE2_5QI}    ${PUCCH_startPRB_UE2_5QI}    ${initialCyclicshift_UE2_5QI}    ${timeDomainOcc_UE2_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${attachlog_UE2}
    run keyword and continue on failure     Should be true    '${SR_period_UE2_5QI}' == 'sl20'
#    log to console    ue3 emc check
#    run keyword and continue on failure     check emc call if setup success    file_path=${EMCcall_UE3}
    comment   UE1 was preempted by UE2
    Get and Check UEContextRelease in wireshark    file_path=${attachlog_UE3}
    ${SR_period_UE3_RRC}    ${SR_offset_UE3_RRC}    ${PUCCH_startPRB_UE3_RRC}    ${initialCyclicshift_UE3_RRC}    ${timeDomainOcc_UE3_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE3}
    run keyword and continue on failure     Should be true    '${SR_period_UE3_RRC}' == 'sl20'
    ${SR_period_UE3_5QI}    ${SR_offset_UE3_5QI}    ${PUCCH_startPRB_UE3_5QI}    ${initialCyclicshift_UE3_5QI}    ${timeDomainOcc_UE3_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI by DUUEID    file_path=${attachlog_UE3}
    ${SR_period_UE4_5QI}    ${SR_offset_UE4_5QI}    ${PUCCH_startPRB_UE4_5QI}    ${initialCyclicshift_UE4_5QI}    ${timeDomainOcc_UE4_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI by DUUEID    file_path=${attachlog_UE3}    ueid_index=${-1}
#    run keyword and continue on failure     Should be true    '${SR_period_UE3_5QI7}' == 'sl10'
    Run Keyword IF    '${SR_period_UE1_5QI}' == '${SR_period_UE2_5QI}' and '${SR_offset_UE1_5QI}' == '${SR_offset_UE2_5QI}'    run keyword
    ...    pucch location should be same    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_5QI}    PUCCH_startPRB_2=${PUCCH_startPRB_UE2_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE1_5QI}    initialCyclicshift_2=${initialCyclicshift_UE2_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_5QI}    timeDomainOcc_2=${timeDomainOcc_UE2_5QI}
    ...    ELSE    run keyword    pucch location should not be same
    ...    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_5QI}     PUCCH_startPRB_2=${PUCCH_startPRB_UE2_5QI}
    ...    initialCyclicshift_1={initialCyclicshift_UE1_5QI7}    initialCyclicshift_2=${initialCyclicshift_UE2_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_5QI}    timeDomainOcc_2=${timeDomainOcc_UE2_5QI}
    Run Keyword IF    '${SR_period_UE1_RRC}' == '${SR_period_UE2_5QI}' and '${SR_offset_UE1_RRC}' == '${SR_offset_UE2_5QI}'    run keyword
    ...    pucch location should be same    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_RRC}    PUCCH_startPRB_2=${PUCCH_startPRB_UE2_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE1_RRC}    initialCyclicshift_2=${initialCyclicshift_UE2_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_RRC}    timeDomainOcc_2=${timeDomainOcc_UE2_5QI}
    ...    ELSE    run keyword    pucch location should not be same
    ...    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_RRC}     PUCCH_startPRB_2=${PUCCH_startPRB_UE2_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE1_RRC}    initialCyclicshift_2=${initialCyclicshift_UE2_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_RRC}    timeDomainOcc_2=${timeDomainOcc_UE2_5QI}
    Run Keyword IF    '${SR_period_UE1_5QI}' == '${SR_period_UE3_5QI}' and '${SR_offset_UE1_5QI}' == '${SR_offset_UE3_5QI}'    run keyword
    ...    pucch location should be same    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_5QI}    PUCCH_startPRB_2=${PUCCH_startPRB_UE3_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE1_5QI}    initialCyclicshift_2=${initialCyclicshift_UE3_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_5QI}    timeDomainOcc_2=${timeDomainOcc_UE3_5QI}
    ...    ELSE    run keyword    pucch location should not be same
    ...    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_5QI}     PUCCH_startPRB_2=${PUCCH_startPRB_UE3_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE1_5QI}    initialCyclicshift_2=${initialCyclicshift_UE3_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_5QI}    timeDomainOcc_2=${timeDomainOcc_UE3_5QI}
    Run Keyword IF    '${SR_period_UE1_RRC}' == '${SR_period_UE2_RRC}' and '${SR_offset_UE1_RRC}' == '${SR_offset_UE2_RRC}'     run keyword
    ...    pucch location should be same    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_RRC}    PUCCH_startPRB_2=${PUCCH_startPRB_UE2_RRC}
    ...    initialCyclicshift_1=${initialCyclicshift_UE1_RRC}    initialCyclicshift_2=${initialCyclicshift_UE2_RRC}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_RRC}    timeDomainOcc_2=${timeDomainOcc_UE2_RRC}
    ...    ELSE    run keyword    pucch location should not be same
    ...    PUCCH_startPRB_1=${PUCCH_startPRB_UE1_5QI}     PUCCH_startPRB_2=${PUCCH_startPRB_UE2_RRC}
    ...    initialCyclicshift_1={initialCyclicshift_UE1_5QI7}    initialCyclicshift_2=${initialCyclicshift_UE2_RRC}
    ...    timeDomainOcc_1=${timeDomainOcc_UE1_5QI}    timeDomainOcc_2=${timeDomainOcc_UE2_RRC}
    Run Keyword IF    '${SR_period_UE2_5QI}' == '${SR_period_UE3_5QI}' and '${SR_offset_UE2_5QI}' == '${SR_offset_UE3_5QI}'    run keyword
    ...    pucch location should be same    PUCCH_startPRB_1=${PUCCH_startPRB_UE2_5QI}    PUCCH_startPRB_2=${PUCCH_startPRB_UE3_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE2_5QI}    initialCyclicshift_2=${initialCyclicshift_UE3_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE2_5QI}    timeDomainOcc_2=${timeDomainOcc_UE3_5QI}
    ...    ELSE    run keyword    pucch location should not be same
    ...    PUCCH_startPRB_1=${PUCCH_startPRB_UE2_5QI}     PUCCH_startPRB_2=${PUCCH_startPRB_UE3_5QI}
    ...    initialCyclicshift_1=${initialCyclicshift_UE2_5QI}    initialCyclicshift_2=${initialCyclicshift_UE3_5QI}
    ...    timeDomainOcc_1=${timeDomainOcc_UE2_5QI}    timeDomainOcc_2=${timeDomainOcc_UE3_5QI}

pucch location should be same
    [Arguments]    ${PUCCH_startPRB_1}    ${PUCCH_startPRB_2}    ${initialCyclicshift_1}    ${initialCyclicshift_2}
    ...            ${timeDomainOcc_1}    ${timeDomainOcc_2}
    ${PUCCH_startPRB_status}    Run Keyword And Return Status     should be true    '${PUCCH_startPRB_1}' == '${PUCCH_startPRB_2}'
    ${initialCyclicshift_status}    Run Keyword And Return Status     should be true    '${initialCyclicshift_1}' == '${initialCyclicshift_2}'
    ${timeDomainOcc_status}    Run Keyword And Return Status     should be true    '${timeDomainOcc_1}' == '${timeDomainOcc_2}'
    ${result}    Evaluate    ${PUCCH_startPRB_status} and ${initialCyclicshift_status} and ${timeDomainOcc_status}
    should be true    ${result} == True

pucch location should not be same
    [Arguments]    ${PUCCH_startPRB_1}    ${PUCCH_startPRB_2}    ${initialCyclicshift_1}    ${initialCyclicshift_2}
    ...            ${timeDomainOcc_1}    ${timeDomainOcc_2}
    ${PUCCH_startPRB_status}    Run Keyword And Return Status     should be true    '${PUCCH_startPRB_1}' == '${PUCCH_startPRB_2}'
    ${initialCyclicshift_status}    Run Keyword And Return Status     should be true    '${initialCyclicshift_1}' == '${initialCyclicshift_2}'
    ${timeDomainOcc_status}    Run Keyword And Return Status     should be true    '${timeDomainOcc_1}' == '${timeDomainOcc_2}'
    ${result}    Evaluate    ${PUCCH_startPRB_status} and ${initialCyclicshift_status} and ${timeDomainOcc_status}
    should be true    ${result} == False


A3IWK3001 counter check
    [Arguments]      ${counter_id}=${counter_id_A3IWK3001}
    ...              ${dic_path}=${counter_dic_path_A3IWK3001}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${10}     #'M55165C00001' drb level slot5
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${40}     #'M55165C00003' cell level slot20
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${900}     #'M55165C00015' Denominator for SR pools resources
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}      #'M55165C00016' SR pool UE1 DRB slot5 use 1 time
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}      #'M55165C00018' SR pool slot10 use 1 time
    ${M55165C00020_value_list}    Create List    ${2}    ${3}
    run keyword and continue on failure     should contain    ${M55165C00020_value_list}    ${counter_value[5]}   #'M55165C00020' SR pool slot20 2 UE
    run keyword and continue on failure     should be true    ${counter_value[6]} < ${9000}     #'M55165C00030' DRB SR pool free, total:3000
    run keyword and continue on failure     should be true    ${counter_value[7]} < ${36000}     #'M55165C00032' cell SR pool free, total:12000

A3IWK3001 counter check classical
     [Arguments]      ${counter_id}=${counter_id_A3IWK3001_classical}
    ...              ${dic_path}=${counter_dic_path_A3IWK3001_classical}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${10}     #'M55165C00001' drb level slot5
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${40}     #'M55165C00003' cell level slot20
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${900}     #'M55165C00015' Denominator for SR pools resources
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}      #'M55165C00016' SR pool UE1 DRB slot5 use 1 time
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}      #'M55165C00018' SR pool slot10 use 1 time
    ${M55165C00020_value_list}    Create List    ${2}    ${3}
    run keyword and continue on failure     should contain    ${M55165C00020_value_list}    ${counter_value[5]}
#    run keyword and continue on failure     should be true    ${counter_value[5]} == ${2}      #'M55165C00020' SR pool slot20 2 UE
    run keyword and continue on failure     should be true    ${counter_value[6]} < ${9000}     #'M55165C00030' DRB SR pool free, total:9000
    run keyword and continue on failure     should be true    ${counter_value[7]} < ${36000}     #'M55165C00032' cell SR pool free, total:36000

A3IWK3001_case_recovery
    [Arguments]    ${ue_index}=${1}    ${ue_index_1}=${3}    ${ue_index_2}=${2}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${recovery_parameter_A3IWK3001}
    run keyword and ignore error    End a call on UE with adb    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${DL_PORT_UE0}    ue_index=${ue_index_1}    protocol=udp
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${dl_port_02}    ue_index=${ue_index_2}    protocol=udp
    run keyword and ignore error    make WA with Samsung S21    ue_index=${3}
    Android UE SwitchApn    ue_index=${3}    apn_name=${APN_WAP1}    ui_version=one ui 3.1
    power_ue.UE Detach  ue_type=${ue_type_samsung}    ue_index=${3}
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

A3IWK3001_case_recovery_classical
    [Arguments]    ${ue_index}=${2}    ${ue_index_1}=${0}    ${ue_index_2}=${1}
    ...             ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${recovery_parameter_A3IWK3001_${MRBTS_ID}}
    run keyword and ignore error    End a call on UE with adb    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${DL_PORT_UE0}    ue_index=${ue_index_1}    protocol=udp
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${dl_port_02}    ue_index=${ue_index_2}    protocol=udp
    run keyword and ignore error    Android UE SwitchApn    ue_index=${ue_index_1}    apn_name=${APN_WAP1}    ui_version=one ui 5.1
    run keyword and ignore error    Detach all ues classical
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

# --------------------------------------12810-C3B1-----------------------------------------#
The 1st normal UE attached success C3B1
    [Arguments]     ${ue_index}=${0}
    ...             ${gnb_index}=${0}
    ...             ${tcpdump_collector_name}=${C3B1_wireshark_attach_N1}
    ...             ${sleep_time}=2s
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${throughput}=5M
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Continue On Failure    UE attach for QCOM and verify with retry    ue_index=${ue_index}    ue_type=${ue_type_0}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type_0}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

The 1st normal UE attached success C3B1 classical
    [Arguments]     ${ue_index}=${3}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${C3B1_wireshark_attach_N1}
    ...             ${sleep_time}=2s
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${throughput}=5M
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

The 2nd normal UE make EMC call C3B1
    [Arguments]     ${ue_index}=${1}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${C3B1_wireshark_attach_EMC}
    ...             ${sleep_time}=10s
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    Make a call dial 911 on UE    ue_index=${ue_index}
    sleep    ${sleep_time}     reason=wait for ue EMC call success and capture wiresharklog
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]    ${cpif_log_path}

The 3rd normal UE attached failed on FDD C3B1
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${C3B1_wireshark_attach_N3_failed}
    ...             ${sleep_time}=10s
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ${attach_status}    Run Keyword And Return Status    UE Attach for failure scenario    ue_index=${ue_index}
#    should be true    ${attach_status} == False
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    [Return]     ${cpif_log_path}

The 3rd normal UE attached success C3B1
    [Arguments]     ${ue_index}=${2}
    ...             ${gnb_index}=${0}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${tcpdump_collector_name}=${C3B1_wireshark_attach_N3_success}
    ...             ${sleep_time}=10s
    ...             ${throughput}=5M
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    ${dl_port_02}    Evaluate    ${dl_port}+100
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port_02}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

C3B1 counter check cell1
    [Arguments]      ${counter_id}=${counter_id_C3B1_cell1}
    ...              ${dic_path}=${counter_dic_path_C3B1_cell1}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${2}

C3B1 counter check cell3_failed
        [Arguments]      ${counter_id}=${counter_id_C3B1_cell3}
    ...              ${dic_path}=${counter_dic_path_C3B1_cell3}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${2}

C3B1 counter check cell1_handover
    [Arguments]      ${counter_id}=${counter_id_C3B1_cell1_handover}
    ...              ${dic_path}=${counter_dic_path_C3B1_cell1_handover}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}

C3B1_counter_handover_CELL1_CELL3
    [Arguments]      ${counter_id}=${counter_id_C3B1_cell1_cell3}
    ...              ${dic_path}=${counter_dic_path_C3B1_cell1_cell3}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${2}

C3B1 log check
    [Arguments]    ${attachlog_UE1}    ${EMCcall_UE2}    ${attachlog_UE3_success}    ${attachlog_UE3_HO}    ${attachlog_UE3_fail}
    ...            ${target_pci}=${nrcell1_pci}
    log to console    ue1 log check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE1}
    ${SR_period_UE1_RRC}    ${SR_offset_UE1_RRC}    ${PUCCH_startPRB_UE1_RRC}    ${initialCyclicshift_UE1_RRC}    ${timeDomainOcc_UE1_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE1}
    run keyword and continue on failure     Should be true    '${SR_period_UE1_RRC}' == 'sl20'
    ${SR_period_UE1_5QI7}    ${SR_offset_UE1_5QI7}     ${PUCCH_startPRB_UE1_5QI7}    ${initialCyclicshift_UE1_5QI7}    ${timeDomainOcc_UE1_5QI7}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${attachlog_UE1}
    run keyword and continue on failure     Should be true    '${SR_period_UE1_5QI7}' == 'sl10'
    log to console    ue2 check
    ${SR_period_UE2_RRC}    ${SR_offset_UE2_RRC}    ${PUCCH_startPRB_UE2_RRC}    ${initialCyclicshift_UE2_RRC}    ${timeDomainOcc_UE2_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${EMCcall_UE2}
    run keyword and continue on failure     Should be true    '${SR_period_UE2_RRC}' == 'sl20'
    ${SR_period_UE2_5QI}    ${SR_offset_UE2_5QI}     ${PUCCH_startPRB_UE2_5QI}    ${initialCyclicshift_UE2_5QI}    ${timeDomainOcc_UE2_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${EMCcall_UE2}
    run keyword and continue on failure     Should be true    '${SR_period_UE2_5QI}' == 'sl20'
#    log to console    ue2 check
#    Get and Check EstablishmentCase_emc in wireshark after attach    file_path=${EMCcall_UE2}
    log to console    ue3 attach check
    ${contextsetup_failure}    run keyword and return status
    ...     Get and Check InitialContextSetup in wireshark after attach    file_path=${attachlog_UE3_fail}
    run keyword and continue on failure    should be true    ${contextsetup_failure} == True
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE3_success}
    ...                                                          establishment_cause_target=establishmentCause: mo-Signalling (3)
    ${SR_period_UE3_RRC}    ${SR_offset_UE3_RRC}    ${PUCCH_startPRB_UE3_RRC}    ${initialCyclicshift_UE3_RRC}    ${timeDomainOcc_UE3_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE3_success}
    run keyword and continue on failure     Should be true    '${SR_period_UE3_RRC}' == 'sl20'
    ${SR_period_UE3_5QI}    ${SR_offset_UE3_5QI}     ${PUCCH_startPRB_UE3_5QI}    ${initialCyclicshift_UE3_5QI}    ${timeDomainOcc_UE3_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${attachlog_UE3_success}
    run keyword and continue on failure     Should be true    '${SR_period_UE3_5QI}' == 'sl20'
    comment     check handover success
    Check intra-F intra-gNB HO procedure    file_path=${attachlog_UE3_HO}    target_cell=${target_pci}

C3B1 log check classical
    [Arguments]    ${attachlog_UE1}    ${attachlog_UE3_success}    ${attachlog_UE3_HO}
    ...            ${target_pci}=${nrcell1_pci}
    log to console    ue1 log check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE1}
    ${SR_period_UE1_RRC}    ${SR_offset_UE1_RRC}    ${PUCCH_startPRB_UE1_RRC}    ${initialCyclicshift_UE1_RRC}    ${timeDomainOcc_UE1_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE1}
    Should be true    '${SR_period_UE1_RRC}' == 'sl20'
    ${SR_period_UE1_5QI}    ${SR_offset_UE1_5QI}     ${PUCCH_startPRB_UE1_5QI}    ${initialCyclicshift_UE1_5QI}    ${timeDomainOcc_UE1_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${attachlog_UE1}
    Should be true    '${SR_period_UE1_5QI}' == 'sl10'
#    log to console    ue2 check
#    Get and Check EstablishmentCase_emc in wireshark after attach    file_path=${EMCcall_UE2}
    log to console    ue3 attach check
    Get and Check EstablishmentCase in wireshark after attach    file_path=${attachlog_UE3_success}
    ...                                                          establishment_cause_target=establishmentCause: highPriorityAccess (1)
   ${SR_period_UE3_RRC}    ${SR_offset_UE3_RRC}    ${PUCCH_startPRB_UE3_RRC}    ${initialCyclicshift_UE3_RRC}    ${timeDomainOcc_UE3_RRC}
    ...    Get SR_periodicity and pucch_info in RRC_setup    file_path=${attachlog_UE3_success}
    run keyword and continue on failure     Should be true    '${SR_period_UE3_RRC}' == 'sl20'
    ${SR_period_UE3_5QI}    ${SR_offset_UE3_5QI}     ${PUCCH_startPRB_UE3_5QI}    ${initialCyclicshift_UE3_5QI}    ${timeDomainOcc_UE3_5QI}
    ...    Get SR_periodicity in DRB_level for 5QI        file_path=${attachlog_UE3_success}
    run keyword and continue on failure     Should be true    '${SR_period_UE3_5QI}' == 'sl20'
    comment     check handover success
    Check intra-F intra-gNB HO procedure    file_path=${attachlog_UE3_HO}    target_cell=${target_pci}

C3B1_case_recovery
    [Arguments]    ${ue_index}=${1}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${Online_Recovery_C3B1}
    run keyword and ignore error    End a call on UE with adb    ue_index=${ue_index}
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

C3B1_case_recovery_classical
    [Arguments]    ${ue_index}=${2}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${Online_Recovery_C3B1_${MRBTS_ID}}
    run keyword and ignore error    End a call on UE with adb    ue_index=${ue_index}
    run keyword and ignore error    Detach all ues classical
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

# --------------------------------------12810-C4B1-----------------------------------------#
SamsungS24 UE attached success C4B1
    [Arguments]     ${ue_index}=${1}
    ...             ${gnb_index}=${0}
    ...             ${tcpdump_collector_name}=${C4B1_wireshark_attach}
    ...             ${ue_type}=${ue_type_samsung}
    ...             ${sleep_time}=2s
    ...             ${dl_port}=${DL_PORT_UE0}
    ...             ${throughput}=20M
    ...             ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    Run Keyword And Continue On Failure    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    ${sleep_time}    reason=wait for ue attach success and capture wiresharklog
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${dl_port}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type}
    [Teardown]     Run Keyword
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    [Return]     ${cpif_log_path}

C4B1 counter check cell3
    [Arguments]      ${counter_id}=${counter_id_C4B1_cell3}
    ...              ${dic_path}=${counter_dic_path_C4B1_cell3}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${2}    #M55910C00029 5QI5,and 5QI7 all dropped from 4 to2.


C4B1 counter check cell1
    [Arguments]      ${counter_id}=${counter_id_C4B1_cell1}
    ...              ${dic_path}=${counter_dic_path_C4B1_cell1}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}    #M55910C00029

C4B1 counter check
    [Arguments]      ${counter_id}=${counter_id_C4B1_classical}
    ...              ${dic_path}=${counter_dic_path_C4B1_classical}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${2}    #M55910C00029,FDDCELL=2
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}    #M55910C00029,TDDCELL=1

C4B1 counter check cell2 classical
    [Arguments]      ${counter_id}=${counter_id_C4B1_classical}
    ...              ${dic_path}=${counter_dic_path_C4B1_cell2}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${2}    #M55910C00029,FDDCELL=2

C4B1 counter check classical
    [Arguments]      ${counter_id}=${counter_id_C4B1_classical}
    ...              ${dic_path}=${counter_dic_path_C4B1_classical}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}    #M55910C00029,TDDCELL=1

C4B1 log check
    [Arguments]    ${C4B1_attachlog_UE1}    ${C4B1_HO_UE1}    ${nrcell_pci}=${nrcell1_pci}
    comment    check scelltoaddmodlist
    Get and check physicalcellid from scelltoaddmodlist    file_path=${C4B1_attachlog_UE1}    target_cell=${nrcell_pci}
    ${SR_periodicity_cell3}    Get finally used SR_periodicity    file_path=${C4B1_attachlog_UE1}
    run keyword and continue on failure     should be true    '${SR_periodicity_cell3}' == 'sl10'
    comment     check handover success
    Check intra-F intra-gNB HO procedure    file_path=${C4B1_HO_UE1}    target_cell=${nrcell_pci}
    ${SR_periodicity_cell1}    Get finally used SR_periodicity    file_path=${C4B1_HO_UE1}
    run keyword and continue on failure     should be true    '${SR_periodicity_cell3}' == 'sl10'

C4B1_case_recovery
    [Arguments]    ${ue_index}=${1}
    ...            ${online_ModifySCF}=True
    ...            ${Delete_Para_Online}=${Delete_recovery_C4B1}
    ...            ${Modify_Para_Online}=${Online_Recovery_C4B1}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${DL_PORT_UE0}    ue_index=${ue_index}    protocol=udp
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Delete_Para_Online=${Delete_Para_Online}
    ...                            Modify_Para_Online=${Modify_Para_Online}

C4B1_case_recovery_classical
    [Arguments]    ${ue_index}=${0}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${Online_Recovery_C4B1_${MRBTS_ID}}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${DL_PORT_UE0}    ue_index=${ue_index}    protocol=udp
    run keyword and ignore error    Detach all ues classical
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

# --------------------------------------12810-B_IWK2_015-----------------------------------------#
UE attach and make vonr call BIWK2015
    [Arguments]    ${filename}
    ...            ${wireshark_target_dir}=${TS_CASE_LOG_PATH}
    ...            ${ue_type}=${ue_type_samsung}
    ...            ${ue_index}=${1}
    ...            ${gnb_index}=${0}
    Start capture wireshark log on master     filename=${filename}    gNB_index=${gnb_index}
    run keyword and continue on failure     Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    2s    reason=wait for ue attach success and then make vonr call
    run keyword and continue on failure     samsung Make Vonr Call With Command    ue_index=${ue_index}
    sleep    5s    reason=wait for vonr call setup and capture wireshark
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master    filename=${filename}    gNB_index=${gnb_index}
    ...                                                      target_dir=${wireshark_target_dir}
    ...    AND    samsung hangup VoNR call    ue_index=${ue_index}
    ...    AND    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    [Return]     ${cpif_log_path}

BIWK2015_log_check
    [Arguments]    ${BIWK2015_wireshark_01}    ${BIWK2015_wireshark_02}
    ${drx_ondurationtimer_true}    ${drx_LongCycleStartOffset_true}    ${drx_Longcycle_true}
    ...    Get drx-config    file_path=${BIWK2015_wireshark_01}
    ${drx_ondurationtimer_false}    ${drx_LongCycleStartOffset_false}    ${drx_Longcycle_false}
    ...    Get drx-config    file_path=${BIWK2015_wireshark_02}
    ${sr_offset_true}    Get SR_periodicity and offset    file_path=${BIWK2015_wireshark_01}
    run keyword and continue on failure     should be true    ${sr_offset_true} == ${drx_LongCycleStartOffset_true}
    ${sr_offset_false}    Get SR_periodicity and offset    file_path=${BIWK2015_wireshark_02}
    ${mid_resource_false}    Evaluate    (${drx_ondurationtimer_false}/2)+${drx_LongCycleStartOffset_false}
    ${mid_resource_false}    Convert To Integer    ${mid_resource_false}
    ${mid_resource_false_new}    second_half_value_get    mid_resource=${mid_resource_false}    drx_Longcycle=${drx_Longcycle_false}
    Run Keyword If    ${mid_resource_false} <= ${drx_Longcycle_false}    Set Test Variable    ${second_half_value}    ${mid_resource_false}
    ...    ELSE    Set Test Variable    ${second_half_value}    ${mid_resource_false_new}
    run keyword and continue on failure     should be true    ${sr_offset_false} == ${second_half_value}


second_half_value_get
    [Arguments]    ${mid_resource}    ${drx_Longcycle}
    ${mid_resource_range}    Evaluate    ${mid_resource}%${drx_Longcycle}
    [Return]    ${mid_resource_range}


BIWK2015_case_recovery
    [Arguments]    ${ue_index}=${1}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${Online_Recovery_BIWK2015}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${DL_PORT_UE0}    ue_index=${ue_index}    protocol=udp
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

BIWK2015_case_recovery_classical
    [Arguments]    ${ue_index}=${1}
    ...            ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${Online_Recovery_BIWK2015_${MRBTS_ID}}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_samsung}    direction=dl
    ...    iperf_port=${DL_PORT_UE0}    ue_index=${ue_index}    protocol=udp
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}




# --------------------------------------12810-ZQQ-----------------------------------------#
Make a VoNR call and collect log
    [Arguments]     ${tcpdump_filename}    ${is_need_TTI}=False
    ...             ${gnb_index}=${0}
    ...             ${called_ue_index}=${2}    ${phone_number}=${tl.ues[${called_ue_index}].sec_key}
    ...             ${ue_index}=${1}
    ...             ${sleep_time_VONR}=40s
    ...             ${nr_phy_cell_ids}=51
    ...             ${target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_filename}    gNB_index=${gnb_index}
    samsung Make Vonr Call With Command    ue_index=${ue_index}    phone_number=+86${phone_number}
    samsung answer VoNR call    ue_index=${called_ue_index}
    sleep    ${sleep_time_VONR}    reason=call 30s
    Run Keyword If    ${is_need_TTI}     Capture Ttitrace With Admin Mode and Convert format    names=TTI_VONR_called
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${target_dir}
    ...    l2_profileId=1    l2_profileName=All events
    samsung hangup VoNR call    ue_index=${ue_index}
    Run Keyword If    ${is_need_TTI}     Capture Ttitrace With Admin Mode and Convert format    names=TTI_VONR_release
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${target_dir}
    ...    l2_profileId=1    l2_profileName=All events
    ${calllog_UEs}    Stop and download the wiresharklog from master    filename=${tcpdump_filename}    gNB_index=${gnb_index}
    ...    target_dir=${target_dir}
    Check VONR setup from wireshark log    file_path=${calllog_UEs}
    Check VONR hangup from wireshark log    file_path=${calllog_UEs}
    Check timer differ    logname=${calllog_UEs}   message_filter=ngap.fiveQI == 1 and frame.time
    ...    message_filter1=ngap.nas == 0 and ngap.procedureCode == 26 and frame.time
    ...          index00=${0}     index01=${0}    value=${28}
    ### check no drbpug when VONR setup. drbpug recover after VONR release
    Run Keyword If    ${is_need_TTI}    Run keywords
    ...   Analysis tti for ulFdSchedData.ulProGrantType    names=TTI_VONR_called    target_dir=${target_dir}
    ...   AND    Analysis tti for ulFdSchedData.ulProGrantType    names=TTI_VONR_release    VONR_called=False    target_dir=${target_dir}
    ...   AND    Analysis tti for ulFdSchedData.rrmBufferedDataUlTotal    names=TTI_VONR_release    target_dir=${target_dir}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_filename}    gNB_index=${gnb_index}
    ...    target_dir=${target_dir}
    ...    AND    Run Keyword And Ignore Error    samsung hangup VoNR call    ue_index=${ue_index}

Multi UE attach and collect log
    [Arguments]     ${tcpdump_filename}    ${gnb_index}=${0}    ${S22}=False    ${S23}=False    ${MTP}=False
    ...    ${MTP_TL233}=False    ${target_dir}=${TS_CASE_LOG_PATH}    ${S21}=False
    Start capture wireshark log on master     filename=${tcpdump_filename}    gNB_index=${gnb_index}
    Run Keyword If    ${S23}    samsung_UE_attach_and_verify    ue_index=${1}    ue_type=${ue_type_samsung}
    Run Keyword If    ${S22}    samsung_UE_attach_and_verify    ue_index=${2}    ue_type=${ue_type_samsung}
    Run Keyword If    ${S21}    samsung_UE_attach_and_verify    ue_index=${3}    ue_type=${ue_type_samsung}
    Run Keyword If    ${MTP}    UE attach for QCOM and verify with retry    ue_index=${0}    ue_type=${ue_type_0}
    Run Keyword If    ${MTP_TL233}    UE attach for QCOM and verify with retry    ue_index=${3}    ue_type=${ue_type_MTP}
    [Teardown]    Stop and download the wiresharklog from master    filename=${tcpdump_filename}    gNB_index=${gnb_index}
    ...    target_dir=${target_dir}

UE NSA attach and collect log
    [Arguments]     ${tcpdump_filename}    ${tcpdump_filename_enb}    ${gnb_index}=${0}    ${target_dir}=${TS_CASE_LOG_PATH}
    ...    ${ue_index}=${1}
    Start capture wireshark log on master     filename=${tcpdump_filename}    gNB_index=${gnb_index}
    Start to collect the log on eNB    log_name=${tcpdump_filename_enb}
    Attach and check power UE    ue_index=${ue_index}    ue_type=${ue_type_samsung}    gnb_index=${gnb_index}    4G_check=True
    [Teardown]    Run keywords    Stop and download the wiresharklog from master    filename=${tcpdump_filename}    gNB_index=${gnb_index}
    ...    target_dir=${target_dir}
    ...     AND    Stop and download Logs on eNB    log_name=${tcpdump_filename_enb}    epc_log_path=${target_dir}

UE attach and collect TTI
    [Arguments]     ${tcpdump_filename}    ${TTI_name}    ${nr_phy_cell_ids}=51    ${MTP_TL233}=False
    ...     ${S22}=False    ${MTP}=False    ${target_dir}=${TS_CASE_LOG_PATH}
    Multi UE attach and collect log    S22=${S22}    MTP=${MTP}    MTP_TL233=${MTP_TL233}
    ...    tcpdump_filename=${tcpdump_filename}    target_dir=${target_dir}
    Run Keyword If    ${MTP}    Sleep    10s
    Capture Ttitrace With Admin Mode and Convert format    names=${TTI_name}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${target_dir}
    ...    l2_profileId=1    l2_profileName=All events

Turn mobile data on and collect TTI
    [Arguments]     ${TTI_name}    ${nr_phy_cell_ids}=51
    turn mobile data on    alias=UE_${0}
    Power UE Start UL traffic    ue_type=${ue_type_0}
    ...    ul_throughput=${Send_Tput_UL}    ue_index=${0}
    Capture Ttitrace With Admin Mode and Convert format    names=${TTI_name}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${TS_CASE_LOG_PATH}
    ...    l2_profileId=1    l2_profileName=All events

IWK3_001_case_recovery
    [Arguments]    ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${recovery_parameter_WK3_001}
    run keyword and ignore error    Detach all ues
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}

Trigger HO and collect log
    [Arguments]     ${tcpdump_filename}    ${TTI_name}    ${gnb_cell1_value_HO}=${25}    ${gnb_cell3_value_HO}=${0}
    ...             ${gnb_index}=${0}    ${nr_phy_cell_ids}=51    ${target_dir}=${TS_CASE_LOG_PATH}
    Start capture wireshark log on master     filename=${tcpdump_filename}    gNB_index=${gnb_index}
    Run Keyword If    '${MRBTS_ID}' == '${gnb_id}[0]'    Adjust the HBTE attenuation value for TL233    gnb_cell1_value=${0}
    ...    gnb_cell2_value=${0}    ELSE
    ...    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${0}    gnb_cell3_value=${0}
    Sleep    3s
    Run Keyword If    '${MRBTS_ID}' == '${gnb_id}[0]'    Adjust the HBTE attenuation value for TL233
    ...    gnb_cell1_value=${gnb_cell1_value_HO}    gnb_cell2_value=${gnb_cell3_value_HO}    ELSE
    ...    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${gnb_cell1_value_HO}    gnb_cell3_value=${gnb_cell3_value_HO}
    Sleep    10s
    ${HO_log}    Stop and download the wiresharklog from master    filename=${tcpdump_filename}    gNB_index=${gnb_index}
    ...    target_dir=${target_dir}
    Capture Ttitrace With Admin Mode and Convert format    names=${TTI_name}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${target_dir}
    ...    l2_profileId=1    l2_profileName=All events
    Check intra-F intra-gNB HO procedure    file_path=${HO_log}    target_cell=${nr_phy_cell_ids}
    [Teardown]    Run Keyword And Ignore Error
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_filename}    gNB_index=${gnb_index}
    ...    target_dir=${target_dir}

Samsung Start DLUL and collect TTI
    [Arguments]     ${TTI_name}    ${nr_phy_cell_ids}=31    ${ue_index}=${1}    ${duration}=900s    ${target_dir}=${TS_CASE_LOG_PATH}
    Power UE Start DL traffic    dl_throughput=${Send_Tput_DL}    duration=${duration}    ue_index=${ue_index}    ue_type=${ue_type_samsung}
    Power UE Start UL traffic    ue_type=${ue_type_samsung}
    ...    ul_throughput=${Send_Tput_UL}    ue_index=${ue_index}
    Capture Ttitrace With Admin Mode and Convert format    names=${TTI_name}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${target_dir}
    ...    l2_profileId=1    l2_profileName=All events

Trigger UL split and collect TTI
    [Arguments]      ${TTI_name}    ${nr_phy_cell_ids}=31    ${target_dir}=${TS_CASE_LOG_PATH}
    Run Keyword If    '${MRBTS_ID}' == '${gnb_id}[0]'    Adjust the HBTE attenuation value for TL233    gnb_cell1_value=${32}
    ...    enb_cell1_value=${0}    ELSE
    ...    Adjust the HBTE attenuation value for 12810    gnb_cell1_value=${48}    enb_cell1_value=${0}
    Check DLUL for Samsung
    Capture Ttitrace With Admin Mode and Convert format    names=${TTI_name}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=3s    target_dir=${target_dir}
    ...    l2_profileId=1    l2_profileName=All events

Check Counter for DRBPUG
    [Arguments]      ${DRBPUG}=True
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_drbpug}    dic_path=${counter_dic_path_drbpug}
    ${M55302C15112_UL_GRANTS}    Set Variable    ${counter_value_list}[0]
    ${M55302C15113_UL_GRANTS_DATA}    Set Variable    ${counter_value_list}[1]
    Run Keyword If    ${DRBPUG}    Run keywords    Should Be True    0 < ${M55302C15112_UL_GRANTS} < 20000
    ...    AND    Should Be True    0 < ${M55302C15113_UL_GRANTS_DATA} < 20000
    ...    AND    Should Be True    ${M55302C15113_UL_GRANTS_DATA} <= ${M55302C15112_UL_GRANTS}
    ...    ELSE    Run keywords    Should Be True    ${M55302C15112_UL_GRANTS} == 0
    ...    AND    Should Be True    ${M55302C15113_UL_GRANTS_DATA} == 0

IWK2_002_case_recovery
    [Arguments]    ${online_ModifySCF}=True
    ...            ${Modify_Para_Online}=${Online_Modify_IWK2_002_recover}
    ...            ${ue_index}=${1}
    Samsung stop DLUL and detech    ue_index=${ue_index}
    Common Case TestLine Setup
    ...                            ModifySCF_Aftercommission=${online_ModifySCF}
    ...                            Modify_Para_Online=${Modify_Para_Online}