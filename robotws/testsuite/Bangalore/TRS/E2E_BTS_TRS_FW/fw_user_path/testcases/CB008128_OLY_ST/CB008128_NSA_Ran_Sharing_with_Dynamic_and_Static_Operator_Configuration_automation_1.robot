**Settings ***
Documentation
    ...     [Procedure]             "CB008128_NSA_Ran_Sharing_with_Dynamic_and_Static_Operator_Configuration_automation"
    ...     [Date]                  "18-01-2023"
    ...     [Author]                "Dinesh"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"

Force Tags        CLOUD_R4P_IPSEC       CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R4]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN
...        QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
#Library         ute_fsmaccess
Library           Collections
Library			SSHLibrary
Library		  OperatingSystem
Library		  String
#Library        ${CURDIR}/../../lib/ute_trs_web/SSH.py
#Library        ${CURDIR}/../../resources/cmp.py
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource        setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource      /home/ute/fw_user_path/testcases/resources/common_FQDN.robot
#Resource        ${CURDIR}/../../resources/common_emssim.robot
#Resource        ${CURDIR}/../../resources/Ethernet_Service_OAM.robot
#Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
#Resource        ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
#Resource       ${CURDIR}/../../../../OAM/LTE648_SOAM/resources/Common_IPSec_Operations.robot
#Resource       ${CURDIR}/../../../../OAM/LTE648_SOAM/resources/Admin_Common_Library.robot

#Suite Setup     Setup Oamops
#Suite Teardown     Teardown Oamops

Suite Setup     Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Variables ***
${RTEP_ip1}     2a00:8a00:a000:1105::a2b:14bd
${RTEP_ip2}     172.16.201.233
${RTEP_ip3}     2a00:8a00:a000:1105::a2b:14b9
${RTEP_ip4}     172.16.201.237

*** Test Cases ***
#CB008128 The Purpose of this testcase is to configure Dynamic SAN and then change to static SAN and verify BTS sanity and viceversa
[1][1.0] CB008128_NSA_Ran_Sharing_with_Dynamic_and_Static_Operator_Configuration_automation

##	taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Start Syslog   ${CURDIR}   background_syslog.txt
##	Check BTS and TRS is commissioned or configured or OnAir
    Verify Bts Status
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${Base_scf}   verify_bts_status=False     timeout=400
	...     alias=default
    Sleep   300
    Verify Bts Status
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${without_ipsec_scf}   verify_bts_status=False     timeout=400
	...     alias=default
    Sleep   120
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Perform Recommissioning    type=delta      delta_file=${dynamic_config_scf}      skip_parameter_relation_errors=False
    Sleep   300
##    Verify tunnels status without certificate
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain     cert_format=P12
	...     password=${Cert_password}
    Sleep   60
#    Verify tunnels status

##    Check BTS and TRS is commissioned or configured or OnAir

#[1][1.0] CB008128_NSA_Ran_Sharing_with_Dynamic_and_Static_Operator_Perform_Certificates_initialisation_post_CB008128_Configurations

#    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${Base_scf}   verify_bts_status=False     timeout=400
	...     alias=default
#    Sleep   300
#    Delete and Install VSR Certificate
#    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${false}     occurrences=1
#    Perform Recommissioning     type=param   param_path=${primary_RTEP1_path}     operation=update    value=${primary_wrong_FQDN_value}
#    Sleep   60
#    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=1
#	Loop reset
#    Perform Recommissioning     type=param   param_path=${primary_RTEP1_path}     operation=update    value=${primary_correct_IPV6_value}
#    Sleep   60
#    Verify tunnels status
#    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${false}     occurrences=1
#    Verify PM Counters via Webem
##    Verify PM Counters via Netact
#    Verify IKE and IPSEC SA Rekeying
##   [Teardown]  taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog

***keywords***
Loop reset
    FOR     ${i}   IN RANGE    2
#    \   taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Start Syslog   ${CURDIR}   background_syslog.txt
#       Trigger site reset
       Reset Bts   wait_for=600    verify_bts=True     should_be_onair=False
       Sleep    120
#       Check BTS and TRS is commissioned or configured or OnAir
#    \   Check BTS is onAir and TRS is commissioned or configured
#	   Verify tunnels status
#       OnAir Uptime
#       Download Alarm File from eNB
       Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${true}     occurrences=1
#       Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
       Verify Alarm        faultid=${NG SCTP setup fail}    severity=major     should_exist=${false}     occurrences=1
       Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}     occurrences=1
#       Verify Alarm        faultid=${No X2 link available}    severity=major     should_exist=${false}     occurrences=1
#       Verify Alarm        faultid=${Cell problem due to associated X2 links}    severity=major     should_exist=${false}
#	...     occurrences=1  chiru commented
       Verify Alarm        faultid=${Core_dump}    severity=major     should_exist=${false}     occurrences=1
    END

Verify tunnels status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

#Verify tunnels status without certificate
#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     NO_STATE

#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

OnAir Uptime
    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog
	Sleep	10s
	Read Syslog
	${onair_interval}=	Read Syslog
#	Pass Execution If	${onair_interval}<420	Normal BTS reset time

Read Syslog
	${result}=	Run Process	python3	onair_time.py
	log	${result.stdout}
	[return]	${result.stdout}

Verify IKE and IPSEC SA Rekeying
    Perform Recommissioning    type=delta      delta_file=${delta_config_IKE_rekeying}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify tunnels status
#    ${ESP}=       Execute command on ENodeB       ipsec status | grep "ESP SPIs" | awk '{ print $1 }''{ print $7 }''{ print $8 }'
    ${IKE_Association1}=       Execute command on gNB       ipsec status | grep "ESTABLISHED"
    Set Suite Variable    ${IKE_Association1}      ${stdout}
    ${Association_info1}=       Execute command on gNB       ipsec status | grep "ESP SPIs"
    Set Suite Variable    ${Association_info1}      ${stdout}
    Sleep   1800
    Verify tunnels status
    ${Association_info2}=       Execute command on gNB       ipsec status | grep "ESP SPIs"
    Set Suite Variable    ${Association_info2}      ${stdout}
    Should Not Be Equal     ${Association_info1}    ${Association_info2}
    Sleep   2000
    Verify tunnels status
    ${IKE_Association2}=       Execute command on gNB       ipsec status | grep "ESTABLISHED"
    Set Suite Variable    ${IKE_Association2}      ${stdout}
    Should Not Be Equal     ${IKE_Association1}     ${IKE_Association2}

Verify PM Counters via Webem
    PM Counters Start           analysis=verify_IPSEC_counters      counter_analysis_file=${counter_analysis_file}
    Verify PM Counters          analysis=verify_IPSEC_counters      counter_analysis_file=${counter_analysis_file}
#    PM Counters Start           analysis=verify_TCP_UDP_counters      counter_analysis_file=${counter_analysis_file}
#    Verify PM Counters          analysis=verify_TCP_UDP_counters      counter_analysis_file=${counter_analysis_file}

Verify PM Counters via Netact
    Setup Ems  config_device=netact2   alias=lab2006
    Configuration Manage  config_device=netact2    config=${disable_ipsec_nms}      plan_name=fw_plan   delete_plan=${True}     alias=lab2006
	...   operation=edit
    Sleep   60
    Configuration Manage  config_device=netact2    config=${enable_ipsec_nms}      plan_name=fw_plan   delete_plan=${True}     alias=lab2006
	...   operation=edit
    Sleep   60
    Verify Alarm   faultid=${IPsec FQDN failure}  severity=major  should_exist=${false}   occurrences=1
    Configuration Manage  config_device=netact2    config=${new_fqdn_nms}      plan_name=fw_plan   delete_plan=${True}     alias=lab2006
	...   operation=edit
    Sleep   60
    Cm Upload   config_device=netact2   alias=lab2006
    Start Netact Pm Counters        config_device=netact2       pm_interval=15       alias=lab2006
    Sleep   90
    Verify Netact Pm Counters       config_device=netact2       pm_interval=15         analysis=verify_TCP_UDP_counters_netact
	...            counter_analysis_file=${counter_analysis_file}          alias=lab2006
#    Verify Netact Pm Counters       config_device=netact2       pm_interval=15         analysis=verify_IPsec_counters_netact
	...            counter_analysis_file=${counter_analysis_file1}          alias=lab2006
    Teardown Ems  config_device=netact2   alias=lab2006

Delete and Install VSR Certificate
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain     cert_format=P12
	...     password=${Cert_password}
    Sleep   60
    Verify tunnels status
