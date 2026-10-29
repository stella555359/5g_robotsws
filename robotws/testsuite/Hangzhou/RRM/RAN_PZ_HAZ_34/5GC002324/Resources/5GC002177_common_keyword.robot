*** Settings ***
Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library    taf.analyzer.pcap     WITH NAME    cap
Variables   5GC002177_TestCase_Parameters.py
Library     taf.gnb.oam.commissioning    WITH NAME    commissioning


*** Variables ***
${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}/5GC002177/DU_SCF.xml
${SCF_Template_path_CU_TL}  ${commissionings_path}/HGZ/${testline_name}/SCF_0.190_CU.xml
${SUITE_LOG_PATH}    /home/ute/Downloads/
${TS_LOG_PATH_BASE}    /home/ute/Downloads/
${gnb_index}    0
${sudo}    sudo
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Keywords ***
Power UE Attach with ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Power UE Detach with ${ue_type}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Start Tcpdump from CPIF
    Connect to VM CPIF
    Start Tcpdump    log_name=${x2_log_name}    interface=x2    sudo=${sudo}    connection=CPIF

Stop Tcpdump and download pcap log from CPIF
    Stop Tcpdump from CPIF    connection=CPIF
	Download Pcap Log from CPIF    log_name=${x2_log_name}    connection=CPIF
	Remove Pcap Log    connection=CPIF

Stop Tcpdump from CPIF

    [Arguments]    ${connection}
    ssh.execute
    ...    command=sudo kill -2 `ps -ef | grep tcpdump | grep -v grep | awk '{print $2}'`
    ...    connection=CPIF

Start Tcpdump

    [Arguments]     ${log_name}    ${connection}    ${sudo}=${empty}    ${interface}=any    ${protocol}=${empty}    ${filter}=${empty}
    ${cmd}=  set variable  ${sudo} tcpdump -i ${interface} ${protocol} -s0 -w /tmp/${log_name} > /dev/null 2>&1 ${filter}&
    ssh.Send Command    ${cmd}    connection=${connection}

Download Pcap Log from CPIF

    [Arguments]        ${log_name}    ${connection}
    ssh.download_file    remote_path=/tmp/${log_name}
    ...                  local_path=${LOG_PATH}/${log_name}
    ...                  connection=${connection}
Remove Pcap Log
    [Arguments]    ${connection}
    ssh.execute    command=sudo rm /tmp/*.pcap   connection=CPIF


CU SCF Modification and Commission

	${output_scf_file_path}    COAM Modify scf file    scf_file_path=${SCF_Template_path_CU}    scf_parameters_list=${TC_scf_parameters}
	CU Rest Login    gnb_index=${gnb_index}
	CU Full Commission    path_of_commission_file=${output_scf_file_path}    plan_name=CU_SCF    gnb_index=${gnb_index}

DU SCF Commission
    Cloud DU connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${SCF_Template_path_DU}    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

Check DU cell on air

    Cloud DU connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air    connection=GNB_OAM
	[Teardown]    COAM Teardown gnb connections

Analysis capture log for RRC Reconfiguration
    [Arguments]      ${log_name}    ${measObject}    ${eventA2}
    cap.read_cap      cap_file=${LOG_PATH}/${log_name}
    cap.Check Expression    condition_expression=x2ap.X2AP_PDU == 1
    ${MeasConfig} =    Catenate    x2ap.X2AP_PDU == 1 && nr-rrc.measObjectToAddModList == 1
    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${MeasConfig}
    should be equal    '${status}'    '${measObject}'
    ${a2_check} =    Catenate    x2ap.X2AP_PDU == 1 && nr-rrc.eventId == 1
    ${status}    ${value} =    run keyword and ignore error    cap.Check Expression    condition_expression=${a2_check}
    should be equal    '${status}'    '${eventA2}'


Testcase teardown
     Run Keyword And Ignore Error    Stop Tcpdump from CPIF    connection=CPIF
	 Run Keyword And Ignore Error    CU Full Commission
	 ...    path_of_commission_file=${SCF_Template_path_CU_TL}     plan_name=CU_SCF    gnb_index=${gnb_index}
     Run Keyword And Ignore Error    DU SCF Commission

