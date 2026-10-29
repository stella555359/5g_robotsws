*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

Resource    ./Resources/CB008158_common_keywords.robot
Variables   ./Resources/CB008158_scf_modify.py

Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: MMW3
...    feature : CB008158

Force Tags    CRT_TRUNK



*** Test Cases ***
[1]CB008158-B_07_DL_PDCP_SDU_delay_FR1_TDD_SA
    CB008158 SA case Preparation
    Reset site SA
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=100M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=100
    Wait for one counter period     interval_time=5min
    Detach UE
	Set PMQAP related counter path
    Check BTS PMQAP Counter M55350C00023 and M55350C00024 for SA


[1]CB008158-B_09_DL_PDCP_SDU_delay_for_PMQAP_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB008158 SA case Preparation
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_7}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_4}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_1}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
    Reset site SA
    UE Prepare
	Attach UE
	Make a VoNR call
	UE start traffic    tp_direction=dl    dl_tp=10M    iperf_port_dl=50224
    UE start traffic    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=1000
    Wait for one counter period     interval_time=5min
    hang up VoNR call
    Detach UE
	Set PMQAP related counter path
    Check BTS PMQAP Counter M55159C0000X for SA
    log to console    no TA for step 4 and 5
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_disable}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_update_4}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
    Reset site SA
    Attach UE
    UE start traffic    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=950
    Wait for one counter period     interval_time=5min
    Detach UE
    Check BTS PMQAP Counter M55159C0000X after pmqap update for SA


[1]CB008158-B_12_GTP_packet_delay_over_F1-U_for_PMQAP_FR1_TDD_SA
    CB008158 SA case Preparation
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_7}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_4}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_2}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
    Reset site SA
    UE Prepare
	Attach UE
	Make a VoNR call
	UE start traffic    tp_direction=dl    dl_tp=10M    iperf_port_dl=50224
    UE start traffic    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=1000
    Wait for one counter period     interval_time=5min
    hang up VoNR call
    Detach UE
	Set PMQAP related counter path
    Check BTS Counter M55310C00002 and M55310C00003 for SA
    Check BTS PMQAP Counter M55350C0002X and M55159C0000X for SA
