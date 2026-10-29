***Settings ***
Documentation
    ...     [Procedure]             "[1]CB008128_The purpose of this testcase is to perform online modification of MRBTS parameters"
    ...     [Date]                  "25-08-2022"
    ...     [Author]                "Dinesh"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"

Force Tags        CLOUD_R4P_IPSEC       CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R4]     RAN_4G    RAN_4G_FDD           QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Library         ute_fsmaccess
Library			SSHLibrary
#Library        ${CURDIR}/../../lib/ute_trs_web/SSH.py
#Library        ${CURDIR}/../../resources/cmp.py
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource        setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource      /home/ute/fw_user_path/testcases/resources/common_FQDN.robot
#Resource        ${CURDIR}/../resources/common_emssim.robot
#Resource        ${CURDIR}/../resources/Ethernet_Service_OAM.robot
#Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
#Resource       ${CURDIR}/../../../../OAM/LTE648_SOAM/resources/Common_IPSec_Operations.robot
#Resource       ${CURDIR}/../../../../OAM/LTE648_SOAM/resources/Admin_Common_Library.robot

#Suite Setup     Setup Oamops
#Suite Teardown     Teardown Oamops

Suite Setup     Run Keywords    Pre-conditions for testsuite
Suite Teardown      Run Keywords    Post-conditions for testteardown

*** Variables ***
${RTEP_ip1}     2a00:8a00:a000:1105::a2b:14bd
${RTEP_ip2}     172.16.201.233
${RTEP_ip3}   	2a00:8a00:a000:1105::a2b:14b9
${RTEP_ip4}     172.16.201.237

*** Test Cases ***
CB008128 The purpose of this testcase is to verify SW upgrade from Netact and perform online modification of MRBTS parameters with IPv4 and IPv6
#The purpose of this testcase is to perform online modification of MRBTS parametrs when site configuration changes in U plane with IPv6 and
#verify continuous BTS reset and OnAir status

#    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Start Syslog   ${CURDIR}   background_syslog.txt
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${dynamic_scf}   verify_bts_status=False
	...   skip_parameter_relation_errors=${True}     timeout=400     alias=default
    Sleep   360
#    Check BTS and TRS is commissioned or configured or OnAir
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Verify tunnels status
    Perform Sofware build upgrade
    Modify IPV4 Dynamic to Manual
#    Reset BTS1
    Reset Bts   wait_for=600    verify_bts=True     should_be_onair=False
    Sleep   600
    Modify IPV4 Manual to Dynamic
    Modify IPV6 Dynamic to Manual
#    Reset BTS
#    Modify IPV6 Manual to Dynamic
##    Perform SW rollback
#    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog

***keywords***
Verify tunnels status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

Perform Sofware build upgrade
    Setup Oamops    dut=bts    bts_port=443     use_ssl=True
    Perform Software Download And Update    package=/home/ute/Downloads/SBTS00_ENB_9999_251014_000005_release_BTSSM_downloadable_A54.zip
	...	  activate_sw=True  update_timeout=1800
    Sleep   600
#    Check BTS and TRS is commissioned or configured or OnAir
#    Verify Bts Status   req_rat=nr       should_be_onair=${True}
    Verify Alarm    faultid=4082    should_exist=${false}    alias=default
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
#    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${No X2 link available}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${Cell problem due to associated X2 links}    severity=major     should_exist=${false}     occurrences=1
    Verify tunnels status

Modify IPV4 Dynamic to Manual
    Perform Recommissioning    type=delta      delta_file=${delta_ipv4_dynamic_to_manual}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Verify tunnels status

Modify IPV4 Manual to Dynamic
    Perform Recommissioning    type=delta      delta_file=${delta_ipv4_manual_to_dynamic}      skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Verify tunnels status

Modify IPV6 Dynamic to Manual
    Perform Recommissioning    type=delta      delta_file=${delta_ipv6_dynamic_to_manual}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Verify tunnels status

Modify IPV6 Manual to Dynamic
    Perform Recommissioning    type=delta      delta_file=${delta_ipv6_manual_to_dynamic}      skip_parameter_relation_errors=${True}
    Sleep   120
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Verify tunnels status

Reset BTS1
#    Trigger site reset
    Reset Bts   wait_for=600    verify_bts=True     should_be_onair=False
#    Check BTS and TRS is commissioned or configured or OnAir
#    Download Alarm File from eNB
    Verify Alarm 	    faultid=6450  	should_exist=${false} 	alias=default
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${false}     occurrences=1
#    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${NG SCTP setup fail}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}     occurrences=1

Perform SW rollback
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Rollback Software   timeout=300
    Sleep   600
    Check BTS and TRS is commissioned or configured or OnAir
#    Verify Bts Status   req_rat=nr       should_be_onair=${True}
    Verify Alarm    faultid=4082    should_exist=${false}    alias=default
    Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${IPsec FQDN failure}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${No X2 link available}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${Cell problem due to associated X2 links}    severity=major     should_exist=${false}     occurrences=1
    Verify tunnels status
