*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    ./Resources/CB008158_common_keywords.robot
Variables   ./Resources/CB008158_scf_modify.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Library    taf.transport.ssh    WITH NAME    csn
Library    OperatingSystem
Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: MMW3
...    feature : CB008158

Force Tags    CRT_TRUNK

*** Variables ***

${5QI_value}    7

${file_path}    /home/ute/KPI/kpi_report_releated_parameters.yml
${report_name}     kpi_report_releated_parameters_report
${excel_kpi_path}    /home/ute/KPI/
${tl_id}    ${tl.gnbs[0].global_bts_id}
${phone_number_2077}    +8613032996558
${phone_number_933}     13031398566
${phone_number_937}     +8613032993586
*** Test Cases ***

[1]CB008158_CB012119_Upgrade_KPI_Testing_TDD

    UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE start traffic    tp_direction=both    dl_tp=1400M   ul_tp=50M    iperf_port_dl=43607    iperf_port_ul=43507  ##5QI-7
	UE start traffic    tp_direction=both    dl_tp=30M    ul_tp=100K   iperf_port_dl=43604    iperf_port_ul=43504   #5QI-4
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
	UE start traffic    tp_direction=both    dl_tp=500k    ul_tp=100K    iperf_port_dl=43408    iperf_port_ul=43308   ue_index=${1}   ##5QI-8
    Make a VoNR call     ue_index=${0}    phone_number=${phone_number_${tl_id}}
	answer VoNR call    ue_index=${1}
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
	Get record time    label=start
    Wait for one counter period     interval_time=15min
	Get record time    label=end
	power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43607
	power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43604
	power_ue.Stop traffic   direction=dl    ue_index=${1}    ue_type=${UE_TYPE}   iperf_port=43408
	Detach UE     ue_index=${0}
	Detach UE     ue_index=${1}
    sleep    15min
	Get bts package version
    generate new report and get report id    file_path=${file_path}   report_name=${package_version}_${report_name}    tl_id=${tl_id}
    ...    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
	Detach UE     ue_index=${0}
	Detach UE     ue_index=${1}
    [Teardown]    Run Keywords    Detach UE     ue_index=${0}    AND    Detach UE     ue_index=${1}
	...   AND    CB008158 case recover to golden SCF

[1]CB008158_CB012119_Upgrade_KPI_Testing_FDD
    Lock LTE Cell to avoid UE attached to 4G
    UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
	UE start traffic    tp_direction=both    dl_tp=190M   ul_tp=50M    iperf_port_dl=43207    iperf_port_ul=43107  ue_index=${1}    ##5QI-7
	UE start traffic    tp_direction=both    dl_tp=5M    ul_tp=100K   iperf_port_dl=43204    iperf_port_ul=43104   ue_index=${1}    #5QI-4
	UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE start traffic    tp_direction=both    dl_tp=500k    ul_tp=100K    iperf_port_dl=50228    iperf_port_ul=43108   ue_index=${0}   ##5QI-8
    Make a VoNR call     ue_index=${0}    phone_number=${phone_number_${tl_id}}
	answer VoNR call    ue_index=${1}
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
	Get record time    label=start
    Wait for one counter period     interval_time=15min
	Get record time    label=end
	power_ue.Stop traffic   direction=dl    ue_index=${1}    ue_type=${UE_TYPE}   iperf_port=43207
	power_ue.Stop traffic   direction=dl    ue_index=${1}    ue_type=${UE_TYPE}   iperf_port=43204
	power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50228
	Detach UE     ue_index=${0}
	Detach UE     ue_index=${1}
    sleep    15min
	Get bts package version
    generate new report and get report id    file_path=${file_path}   report_name=${package_version}_${report_name}    tl_id=${tl_id}
    ...    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
	Detach UE     ue_index=${0}
	Detach UE     ue_index=${1}

    [Teardown]    Run Keywords    Detach UE     ue_index=${0}    AND    Detach UE     ue_index=${1}
	...   AND   Unlock LTE Cell to Normal

[1]CB008158_CB012119_Upgrade_KPI_Testing_TDD_TL937
    #Lock NRCell-24
    UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE start traffic    tp_direction=both    dl_tp=1100M   ul_tp=60M    iperf_port_dl=43707    iperf_port_ul=43507  ##5QI-9
	UE start traffic    tp_direction=both    dl_tp=30M    ul_tp=100K   iperf_port_dl=50004    iperf_port_ul=5004   #5QI-4
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
	UE start traffic    tp_direction=both    dl_tp=500k    ul_tp=100K    iperf_port_dl=43408    iperf_port_ul=43308   ue_index=${1}   ##5QI-7
    Make a VoNR call     ue_index=${0}    phone_number=${phone_number_${tl_id}}
	answer VoNR call    ue_index=${1}
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
	Get record time    label=start
    Wait for one counter period     interval_time=15min
	Get record time    label=end
	power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43707
	power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50004
	power_ue.Stop traffic   direction=dl    ue_index=${1}    ue_type=${UE_TYPE}   iperf_port=43408
	Detach UE     ue_index=${0}
	Detach UE     ue_index=${1}
    sleep    15min
	Get bts package version
    generate new report and get report id    file_path=${file_path}   report_name=${package_version}_${report_name}    tl_id=${tl_id}
    ...    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}

	Detach UE     ue_index=${0}
	Detach UE     ue_index=${1}
	#UnLock NRCell-24
    [Teardown]    Run Keywords    Detach UE     ue_index=${0}    AND    Detach UE     ue_index=${1}




*** Keywords ***

Lock LTE Cell to avoid UE attached to 4G
    Modify NIDD parameter on gnb   parameters_to_update=${Lock_LNCEL11}
	Sleep    10

Unlock LTE Cell to Normal
    Modify NIDD parameter on gnb   parameters_to_update=${UnLock_LNCEL11}
	Sleep    10

Lock NRCell-24
    Modify NIDD parameter on gnb   parameters_to_update=${Lock_NRCELL}
UnLock NRCell-24
    Modify NIDD parameter on gnb   parameters_to_update=${Unlock_NRCELL}
