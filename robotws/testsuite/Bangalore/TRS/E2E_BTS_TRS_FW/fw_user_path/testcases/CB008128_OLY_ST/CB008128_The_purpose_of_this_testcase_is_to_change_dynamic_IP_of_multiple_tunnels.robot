***Settings ***
Documentation
    ...     [Procedure]             "[1]CB008128_The purpose of this testcase is to change dynamic IP of multiple tunnels"
    ...     [Date]                  "25-08-2022"
    ...     [Author]                "Dinesh"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"

Force Tags        CLOUD_R4P_IPSEC       CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R4]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN
...        QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Library         ute_fsmaccess
Library			SSHLibrary
#Library        ${CURDIR}/../../lib/ute_trs_web/SSH.py
#Library        ${CURDIR}/../../resources/cmp.py
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
#Resource        setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource      /home/ute/fw_user_path/testcases/resources/common_FQDN.robot
#Resource        ${CURDIR}/../../resources/common_emssim.robot
#Resource        ${CURDIR}/../../resources/Ethernet_Service_OAM.robot
#Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
#Resource       ${CURDIR}/../../../../OAM/LTE648_SOAM/resources/Common_IPSec_Operations.robot
#Resource       ${CURDIR}/../../../../OAM/LTE648_SOAM/resources/Admin_Common_Library.robot

#Suite Setup     Setup Oamops
#Suite Teardown     Teardown Oamops

Suite Setup     Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown


*** Variables ***
${scf}          /home/ute/Mitesh/CB008128_B5/8128_B2_5G_4G_GSM_onair_4_tunnels_up_IPV6.xml
${RTEP_ip1}     2a00:8a00:a000:1105::a2b:14bd
${RTEP_ip2}     172.16.201.233
${RTEP_ip3}     2a00:8a00:a000:1105::a2b:14b9
${RTEP_ip4}     172.16.201.237
${RTEP_ip5}     2a00:8a00:a000:1105::ac10:cd05
${RTEP_ip6}     2a00:8a00:a000:1105::ac10:cc51

*** Test Cases ***
CB008128 The purpose of this testcase is to change dynamic IP of multiple tunnels with IPv4 and IPv6 configuration with SA and NSA modes
#The Purpose of this testcase is to change dynamic IP of multiple tunnels with IPV4 VLANs configuration with with SRAN and 5G concurrent
#The Purpose of this testcase is to change dynamic IP of multiple tunnels with IPV4  VLANs configuration with 5G SA+NSA concurrent mode
#The Purpose of this testcase is to disable dynamic IP of multiple tunnels with IPV6 plain configuration with 5G SA+NSA concurrent mode
#The purpose of this testcase is to enabling of dynamic IP for multiple tunnels in public backhaul deployment as part of initial
#commissioning of BTS for 5g NSA with IPv6 TLS
#The purpose of this testcase is to enabling of dynamic IP for multiple tunnels in public backhaul deployment as part of initial
#commissioning of BTS for LTE with IPv6 TLS

#    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Start Syslog   ${CURDIR}   background_syslog.txt
	taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${without_ipsec_scf}   verify_bts_status=False
	...     timeout=400     alias=default
    Sleep   120s
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Perform Recommissioning    type=delta      delta_file=${dynamic_config_scf}      skip_parameter_relation_errors=True
    Sleep   300
#    Verify tunnels status without certificate
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain     cert_format=P12
	...     password=${Cert_password}
	Sleep	60
    Verify tunnels status
#    Check BTS and TRS is commissioned or configured or OnAir
    Modify Dynamic IP of multiple tunnels
    Disable Dynamic IP of multiple tunnels
    Enable Dynamic IP of multiple tunnels
    Verify Dynamic IP by enabling TLs
#    Enable CNI95752 flag
#    Modify Dynamic IP of multiple tunnels
#    Disable Dynamic IP of multiple tunnels
#    Enable Dynamic IP of multiple tunnels
#    Disable CNI95752 flag
#    Verify CMP certificate reinitialization
#    Teardown testcase

***keywords***
Verify tunnels status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED
#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

Verify tunnels status without certificate
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

Verify failure tunnels status
#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     CONNECTING
#
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     CONNECTING

Get Initial Dynamic IP
    ${dict}=       Query Admin Infomodel    query=get list //IPADDRESSV4_R-1
    ${localip}=     Get From Dictionary     dictionary=${dict}      key=10.43.168*

Modify Dynamic IP of multiple tunnels
#    Get Initial Dynamic IP
    Perform Recommissioning    type=delta      delta_file=${delta_modify_dynamic}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify tunnels status

Disable Dynamic IP of multiple tunnels
    Perform Recommissioning    type=delta      delta_file=${delta_disable_dynamic}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify failure tunnels status

Enable Dynamic IP of multiple tunnels
    Perform Recommissioning    type=delta      delta_file=${delta_enable_dynamic}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify tunnels status

Verify Dynamic IP by enabling TLs
    Perform Recommissioning     type=param      param_path=MPLANENW-1:oamTls    operation=update    value=forced      timeout=300
    Sleep   60
    Verify tunnels status
    Perform Recommissioning     type=param      param_path=MPLANENW-1:oamTls    operation=update    value=off      timeout=300
    Sleep   60
    Verify tunnels status

Enable CNI95752 flag
    Perform Recommissioning     type=param   param_path=${CNIflag_path}     operation=update    value=${CNIflag_enable}     timeout=300
    Sleep   60

Disable CNI95752 flag
    Perform Recommissioning     type=param   param_path=${CNIflag_path}     operation=update    value=${CNIflag_disable}     timeout=300
    Sleep   60

Verify CMP certificate reinitialization
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${CMP_cert}   verify_bts_status=False     timeout=400
	...     alias=default
    Sleep   120
    Certificate Configure    operation=install_cmp_certificate
    Sleep   60
    Check BTS and TRS is commissioned or configured or OnAir
    Verify CMP 2K tunnels status
    Verify Alarm      faultid=${IPsec FQDN failure}  severity=major  should_exist=${false}   occurrences=1
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${auto_cert_renew_fail}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}     occurrences=1
    Perform Recommissioning     type=param      param_path=${primary_RTEP1_path}  operation=update    value=${4k_RTEP_fqdn_value}
    Sleep   60
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${true}     occurrences=1
    Sleep   300
    Perform Recommissioning     type=param      param_path=CMP-1:caSubjectName  operation=update    value=CN=CA2_8639_Ipsec_4K
    Sleep   10
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure    operation=install_cmp_certificate
    Sleep   60
    Verify CMP 4K tunnels status
    Verify Alarm      faultid=${IPsec FQDN failure}  severity=major  should_exist=${false}   occurrences=1
    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${auto_cert_renew_fail}    severity=major     should_exist=${false}     occurrences=1
    Verify Alarm        faultid=${Auth_failure}    severity=major     should_exist=${false}     occurrences=1

Verify CMP 2K tunnels status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip5}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

Verify CMP 4K tunnels status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip6}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

Teardown testcase
    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog
    Certificate Configure    operation=restore_vendor_certificate
    Sleep   60
    Certificate Configure   operation=install_certificate   cert_file=${Cert_file}    cert_type=BtsTrustChain     cert_format=P12
	...     password=${Cert_password}
    Sleep   60
