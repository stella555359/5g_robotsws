# # #*** Settings ***
# # #Documentation
# # #...    author: Shi Ming
# # #...    contact: ming.shi@nokia-sbell.com
# # #...    squal group: SG03
# # #...    feature: CB008200-D
# # #
# # #Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
# # #...         STATE_SW_UPLOADED    PY36
# # #Suite Setup    Run Keywords    Setup Env for test    AND
# # #...                            Common Suite Setup for COAM    AND
# # #...                            Common UE parameter setup
# # #
# # #Suite Teardown
# # #
# # #
# # #Resource     Resources/CB008200_common_keywords.robot
# # #Variables    Resources/CB008200_variables.py
# # #
# # #
# # #*** Variables ***
# # #${log_name_D_001}    log_name_D_001.pcap
# # #${enb_log_name_D_001}    enb_log_name_D_001.pcap
# # #${log_name_D_003}    log_name_D_003.pcap
# # #
# # #${ue_type}    samsung
# # #
# # #${enb_instance}     ${tl.enbs[0].instance_id}
# # #@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-3
# # #@{enb_para}    administrativeState
# # #@{enb_value}    unlocked    locked
# # #
# # #
# # #*** Test Cases ***
# # #[1]CB008200_5G_D_F_SA_Retainability_counter_001_QosFlow_Release_due_to_Redirection
# # #    [Documentation]    PM Counter update for VoNR Wideband CQI per cell for cloud and classical gNB.
# # #    [Tags]    CB008200-D
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Online modify parmeters    parameters_to_update=${PARAM_8200_D_001}
# # #    set enb cell    value=@{enb_value}[1]
# # #    ####set gnb1 cell1 PA to 0
# # #    Recover HBTE attenuation to trigger RLF
# # #    Step1: UE attach    ue_type=${ue_type}
# # #    set enb cell
# # #    Step2: UE setup VoNR call
# # #    sleep    20s
# # #    check voice call status    status=${2}
# # #    Prepare with PM counter time to caculate    period=start
# # #    Start capture gNB log on slave    filename=${log_name_D_001}
# # #    Start to collect the log on eNB    log_name=${enb_log_name_D_001}    interface=br1
# # #    ####set gnb1 cell1 PA to target value
# # #    Set HBTE attenuation    target_value=${60}
# # #    sleep    30s
# # #    Stop and download the Logs on slave    filename=${log_name_D_001}
# # #    Stop and download Logs on eNB    log_name=${enb_log_name_D_001}
# # #    Prepare with PM counter time to caculate    period=end
# # #    Check wireshark log for 001
# # #    Check counter for 001
# # #    [Teardown]    Run Keywords    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
# # #    ...    Step4: Detach UE    ue_type=${ue_type}    AND
# # #    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_D_001}    AND
# # #    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_D_001}    AND
# # #    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_D_001}    AND
# # #    ...    set enb cell    AND
# # #    ...    Recover HBTE attenuation to trigger RLF    AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #[1]CB008200_5G_D_F_SA_Retainability_counter_003_QosFlow_Release_due_to_Radio_Link_Failure
# # #    [Documentation]    This User Scenario is to provide the counters used for measuring SA retainability.
# # #    ...    The User scenario creates a counter to measure the number of QosFlows that were released
# # #    ...    due to Radio Link Failure where the release is initiated by gNB.
# # #    ...    The User scenario is a rerun of 5G_RAN_USR_RRM_1789 for release due to gNB detected RLF.
# # #    [Tags]    CB008200-D
# # #    [Timeout]    1 hour
# # #    [Setup]
# # ##    Online modify parmeters    parameters_to_update=${PARAM_8200_D_003}
# # #    ####set gnb1 cell1 PA to 0
# # #    Recover HBTE attenuation to trigger RLF
# # #    set enb cell    value=@{enb_value}[1]
# # #    Step1: UE attach    ue_type=${ue_type}
# # #    Step2: UE setup VoNR call
# # #    sleep    20s
# # #    check voice call status    status=${2}
# # #    Prepare with PM counter time to caculate    period=start
# # #    Start capture gNB log on slave    filename=${log_name_D_003}
# # #    ####set gnb1 cell1 PA to target value
# # #    Set HBTE attenuation to trigger RLF
# # #    sleep    30s
# # #    Stop and download the Logs on slave    filename=${log_name_D_003}
# # #    Prepare with PM counter time to caculate    period=end
# # #    Check wireshark log for 003
# # #    Check counter for 003
# # #    [Teardown]    Run Keywords    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
# # #    ...    Step4: Detach UE    ue_type=${ue_type}    AND
# # #    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_D_003}    AND
# # ##    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_D_003}    AND
# # #    ...    set enb cell    AND
# # #    ...    Recover HBTE attenuation to trigger RLF    AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #
# # #*** Keywords ***
# # ####check wireshar log
# # #Check wireshark log for 001
# # #    Check QosFlow Release message with redirection    logname=${log_name_D_001}
# # #    Check QosFlow Release message with redirection on enb    logname=${enb_log_name_D_001}
# # #
# # #Check wireshark log for 003
# # #    Check VoNR call failed message with unspecified    logname=${log_name_D_003}
# # #
# # #####check counter on WEBUI
# # #Check counter for 001
# # #    sleep    40s
# # #    Check gnb counter as expected_value
# # #    ...    counter_id=${NG_FLOW_REL_GNB_REDIRECT['counter_id']}
# # #    ...    dic_path=${NG_FLOW_REL_GNB_REDIRECT['dic_path']}
# # #    ...    expected_value=${3}
# # #    ...    gnb_id=${NG_FLOW_REL_GNB_REDIRECT['gnb_id']}
# # #    Check gnb counter as expected_value
# # #    ...    counter_id=${NG_FLOW_REL_GNB_REDIRECT_5QI1['counter_id']}
# # #    ...    dic_path=${NG_FLOW_REL_GNB_REDIRECT_5QI1['dic_path']}
# # #    ...    expected_value=${1}
# # #    ...    gnb_id=${NG_FLOW_REL_GNB_REDIRECT_5QI1['gnb_id']}
# # #    Check gnb counter as expected_value
# # #    ...    counter_id=${NG_FLOW_REL_GNB_REDIRECT_PMQAP['counter_id']}
# # #    ...    dic_path=${NG_FLOW_REL_GNB_REDIRECT_PMQAP['dic_path']}
# # #    ...    expected_value=${3}
# # #    ...    gnb_id=${NG_FLOW_REL_GNB_REDIRECT_PMQAP['gnb_id']}
# # #
# # #Check counter for 003
# # #    sleep    40s
# # #    Check gnb counter as expected_value
# # #    ...    counter_id=${NG_FLOW_REL_GNB_RLF['counter_id']}
# # #    ...    dic_path=${NG_FLOW_REL_GNB_RLF['dic_path']}
# # #    ...    expected_value=${3}
# # #    ...    gnb_id=${NG_FLOW_REL_GNB_RLF['gnb_id']}
# # #    Check gnb counter as expected_value
# # #    ...    counter_id=${NG_FLOW_REL_GNB_RLF_5QI1['counter_id']}
# # #    ...    dic_path=${NG_FLOW_REL_GNB_RLF_5QI1['dic_path']}
# # #    ...    expected_value=${1}
# # #    ...    gnb_id=${NG_FLOW_REL_GNB_RLF_5QI1['gnb_id']}
# # #    Check gnb counter as expected_value
# # #    ...    counter_id=${NG_FLOW_REL_GNB_RLF_PMQAP['counter_id']}
# # #    ...    dic_path=${NG_FLOW_REL_GNB_RLF_PMQAP['dic_path']}
# # #    ...    expected_value=${3}
# # #    ...    gnb_id=${NG_FLOW_REL_GNB_RLF_PMQAP['gnb_id']}