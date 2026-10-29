*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown   AND   CI_interface.Common Case Teardown

Resource    ./Resources/CB008158_common_keywords.robot
Variables   ./Resources/CB008158_scf_modify.py

Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: MMW3
...    feature : CB008158

Force Tags    CRT_TRUNK



*** Test Cases ***

[1]CB008158-A_01_DL_Air-Interface_delay_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB008158 SA case Preparation
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_7}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_4}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_2}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
	UE Prepare
	Attach UE
	Make a VoNR call
    UE start traffic    tp_direction=dl    dl_tp=10M    iperf_port_dl=50224
    UE start traffic    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=930
    Wait for one counter period     interval_time=5min
    hang up VoNR call
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50224
    Detach UE
	Set PMQAP related counter path
    Check BTS Counter M55310C00002 and M55310C00003 for SA


[1]CB008158-A_03_DL_Air-Interface_delay_for_PMQAP_FR1_TDD_NSA
    CB008158 NSA case Preparation
	${stream}    Get Stream
    Set test variable    ${PARAMETERS_TO_CB008158_pmqap_add_17}    ${PARAMETERS_TO_CB008158_pmqap_add_17_${stream}}
    #ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_17}
    #Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=600M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=550
    Wait for one counter period     interval_time=5min
    Detach UE
	Set PMQAP related counter path
    Check BTS Counter M55158C00001 and M55158C00002 for NSA


[1]CB008158-A_04_DL_Air-Interface_delay_Percentile_FR1_TDD_SA
    CB008158 SA case Preparation
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_7}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_8}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=600M    iperf_port_dl=50228
    UE start traffic    tp_direction=dl    dl_tp=600M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=1000
    Wait for one counter period     interval_time=5min
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50228
    Detach UE
	Set PMQAP related counter path
    Check BTS Counter M55158C00003 for threshold 2000
    Modify NIDD parameter on gnb  ${PARAMETERS_TO_CB008158_rlcAmSduDlDelayThresh_modify}
    Wait for one counter period     interval_time=5min
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=100K    iperf_port_dl=50228
    UE start traffic    tp_direction=dl    dl_tp=600M    iperf_port_dl=50227
    #UE check throughput by syslog    tp_direction=dl    exp_dl_tp=1000
    Wait for one counter period     interval_time=5min
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50228
    Detach UE
	Set PMQAP related counter path
    Check BTS Counter M55158C00003 for threshold min and max

