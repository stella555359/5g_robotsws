***Settings ***
Documentation
    ...     [Procedure]             "[1]CB008128_The purpose of this testcase is to change control ips with SA+NSA concurrent mode"
    ...     [Date]                  "25-08-2022"
    ...     [Author]                "Dinesh"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB008128"
    ...     [Validation_status]     "Validated and Passed"

Force Tags        CLOUD_R4P_IPSEC       CA_E2ET_BTSTRSPZ        SBTS00        [SBTS22R4]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN
...        QCP_RAN_VRF        CRT

Library			ute_fsmaccess
Library			SSHLibrary
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
#Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
#Resource      /home/ute/fw_user_path/testcases/resources/common_FQDN.robot
#Resource        /home/ute/robotlte/testsuite/WMP/OAM/LTE648_SOAM/resources/Admin_Common_Library.robot
variables       ta_e2e_bts_trs_fw

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

*** Test Cases ***
CB008128 The purpose of this testcase is to change Ng and X2 control ips and check SA and NSA cell status for IPv4 IPv6
#The purpose of this testcase is to change  one or several Ng control ip address  and check SA+NSA (concurrent mode) cell status with IPv6
#The purpose of this testcase is to change  one or sevrals X2 control ip address  and check SA+NSA (Concurrent mode) cell status for IPv4
#The Purpose of this testcase is to change dynamic IP of single tunnel with IPV4 plain configuration with 5G SA+NSA concurrent mode
#The Purpose of this testcase is to change dynamic IP of single tunnel with IPV4 plain configuration with 5G SA+NSA concurrent mode
#The Purpose of this testcase is to change dynamic IP of multiple tunnels with IPV4  VLANs configuration with 5G SA+NSA concurrent mode

#    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Start Syslog   ${CURDIR}   background_syslog.txt
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${dynamic_scf}   verify_bts_status=False
	...     skip_parameter_relation_errors=${True}    timeout=400     alias=default
    Sleep   120s
    Verify tunnels status
#    Check BTS and TRS is commissioned or configured or OnAir
    Verify changing localendpoint IP with different control ips
    Verify by Modify X2C IPs
    Verify by Modify S1U IPs
    Verify by Modify NGC IPs
#    Enable CNI95752 flag
#    Verify by Modify S1U IPs
#    Verify by Modify NGC IPs
#    Disable CNI95752 flag
#    Verify CNI by Modify NGC IPs
#    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog

***keywords***
Verify tunnels status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip1}]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

#    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=${RTEP_ip2}]
#    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
#    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

Verify changing localendpoint IP with different control ips
#    Perform Recommissioning    type=delta      delta_file=${delta_change_x2c}      skip_parameter_relation_errors=${True}
#    Sleep   60
#    Verify tunnels status
#    Verify abnormal Alarms

    Perform Recommissioning    type=delta      delta_file=${delta_change_ngc}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify tunnels status
    Verify abnormal Alarms

    Perform Recommissioning    type=delta      delta_file=${delta_change_s1u}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify tunnels status
    Verify abnormal Alarms

Verify by Modify X2C IPs
    Perform Recommissioning    type=delta      delta_file=${delta_x2c_to_manual}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify abnormal Alarms

    Perform Recommissioning    type=delta      delta_file=${delta_x2c_to_dynamic}      skip_parameter_relation_errors=${True}
    Sleep   60
    Verify tunnels status
    Verify abnormal Alarms

Verify by Modify S1U IPs
    Perform Recommissioning    type=delta      delta_file=${delta_s1u_to_manual}      skip_parameter_relation_errors=${True}    timeout=300
    Sleep   60
    Verify abnormal Alarms

    Perform Recommissioning    type=delta      delta_file=${delta_s1u_to_dynamic}      skip_parameter_relation_errors=${True}   timeout=300
    Sleep   60
    Verify tunnels status
    Verify abnormal Alarms

Verify by Modify NGC IPs
    Perform Recommissioning    type=delta      delta_file=${delta_ngc_to_manual}      skip_parameter_relation_errors=${True}    timeout=300
    Sleep   60
    Verify abnormal Alarms

    Perform Recommissioning    type=delta      delta_file=${delta_ngc_to_dynamic}      skip_parameter_relation_errors=${True}   timeout=300
    Sleep   60
    Verify tunnels status
    Verify abnormal Alarms

Verify abnormal Alarms
#    Download Alarm File from eNB
#    Verify Alarm        faultid=6450    should_exist=${false}   alias=default
    Verify Alarm        faultid=${NG SCTP setup fail}    severity=major     should_exist=${false}     occurrences=1
#    Verify Alarm        faultid=${DPD_Alarm}    severity=major     should_exist=${false}     occurrences=1

Enable CNI95752 flag
    Perform Recommissioning     type=param   param_path=${CNIflag_path}     operation=update    value=${CNIflag_enable}     timeout=300
    Sleep   60

Disable CNI95752 flag
    Perform Recommissioning     type=param   param_path=${CNIflag_path}     operation=update    value=${CNIflag_disable}     timeout=300
    Sleep   60

Verify CNI by Modify NGC IPs
#    Perform Recommissioning    type=delta      delta_file=${delta_ngc_to_manual}      skip_parameter_relation_errors=${True}    timeout=300
    Setup Remote Access    remote_device=bts
    ${stdout}    Remote Command Execute  command=uptime
    ${uptime}=        split string        ${stdout}
#    ${val}=     Set Variable        @{uptime}[0]\\@{uptime}[1]\\@{uptime}[2]
    ${val}=     Set Variable        @{uptime}[2]
    cut -b -3 ${val}
#    Should be True  ${val}>10
    Teardown remote Access
#    Sleep   60
#    Verify abnormal Alarms

#    Perform Recommissioning    type=delta      delta_file=${delta_ngc_to_dynamic}      skip_parameter_relation_errors=${True}   timeout=3006
#    Sleep   60
#    Verify tunnels status
#    Verify abnormal Alarms
