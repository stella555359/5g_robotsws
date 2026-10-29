*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown   AND    CI_interface.Common Case Teardown

Resource    ./Resources/CB008158_common_keywords.robot
Variables   ./Resources/CB008158_scf_modify.py

Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: MMW3
...    feature : CB008158

Force Tags    CRT_TRUNK



*** Test Cases ***
[1]CB008158-C_14_PDCP_re-ordering_Delay_UL_FR1_TDD_NSA
    CB008158 NSA case Preparation
	${stream}    Get Stream
    #Set test variable    ${PARAMETERS_TO_CB008158_pmqap_add_17}    ${PARAMETERS_TO_CB008158_pmqap_add_17_${stream}}
    #ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_17}
    #Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=ul    ul_tp=60M    iperf_port_ul=43107
    #UE check throughput by syslog    tp_direction=ul    exp_ul_tp=55
    Wait for one counter period     interval_time=5min
    Detach UE
	Set PMQAP related counter path
    Check BTS Counter M55350C00027 and M55350C00028 for NSA

[1]CB008158-C_15_PDCP_re-ordering_Delay_UL_for_PMQAP_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB008158 SA case Preparation
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_7}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_4}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_1}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB008158_actNrpmqapProfiles_enable}
    Reset site SA
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=ul    ul_tp=20M    iperf_port_ul=43107
    UE start traffic    tp_direction=ul    ul_tp=20M    iperf_port_ul=43104
    #UE check throughput by syslog    tp_direction=ul    exp_ul_tp=35
    Wait for one counter period     interval_time=5min
    Detach UE
	Set PMQAP related counter path
    Check BTS PMQAP Counter M55159C00005 and M55159C00006 for SA

