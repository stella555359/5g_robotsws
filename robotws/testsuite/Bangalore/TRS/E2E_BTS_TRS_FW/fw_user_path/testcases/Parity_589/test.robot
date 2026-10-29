*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "SR000589"
...     [Funtion_Hash_Tags]     "SBTS_Performance_Monitors_per_IP_Interface_Single_IP_Single_VLAN_Without_IPSec_SR000589"
...     [Procedure]             "SBTS_Performance_Monitors_per_IP_Interface_Single_IP_Single_VLAN_Without_IPSec_SR000589"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Variables ***

${counter_analysis_file_name}		rp000589_counters_analysis.json
${mplane_ip_v4}    10.71.249.166
${mplane_ip_v6}	   2a00:8a00:a000:1103::a47:f9a6
${count}            50

*** Test Cases ***

[1]TRS_SBTS_Performance_Monitors_per_IP_Interface_Single_IP_Single_VLAN_Without_IPSec_SR000589

	Perform Commissioning    scf_file=${scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
    Sleep    300
	Setup Remote Access         remote_device=bts
    Remote Command Execute          command=ping ${mplane_ip_v4} -c ${count}
    Sleep    22
    Remote Command Execute  command=ping ${mplane_ip_v6} -c ${count}
    Sleep   20
    Teardown Remote Access
	Verify Single VLAN PM counters

*** keywords ***

Verify Single VLAN PM counters
    PM Counters Start      analysis=verify_ip_counters      counter_analysis_file=${counter_analysis_file_name}
    Verify PM Counters     analysis=verify_ip_counters      counter_analysis_file=${counter_analysis_file_name}