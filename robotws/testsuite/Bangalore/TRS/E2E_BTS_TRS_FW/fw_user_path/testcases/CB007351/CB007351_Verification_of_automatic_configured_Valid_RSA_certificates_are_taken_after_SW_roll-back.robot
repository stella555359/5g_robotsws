*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's installation of RSA certificate and same certificates should be loaded after roll-back"
...     [Date]                  "15-06-2022"
...     [Author]                "Bibhukinkar Behera"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "CMP"
...     [Domain_Hash_Tags]      "certificate"
...     [Feature_ID]            "CB007351"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7351"
...     [Config_Comments]       "This script requires basic SCF loading with CMP ,CRL server configuration and IPsec configuration"
...     [RunTime Parameters]    "bts_id used is 7351"

variables       ta_e2e_bts_trs_fw
#Resource        /home/ute/fw_user_path/testcases/resources/common_keywords.robot
#Resource        setup/framework.robot
#Resource        ${CURDIR}/../resources/common_IPsec_Operations.robot
Resource        ${CURDIR}/resources/CB007351_common_keywords.robot

#Suite Setup     Run Keywords        Suite Setup Preconditions
#    ...     AND     Setup Oamops
#Suite Teardown     Run Keywords     Suite Teardown Postconditions
#    ...     AND     Teardown Oamops

Suite Setup             Run Keywords    Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Test Cases ***

[1][1.0] CB007351-C-1_Verify with Automatic configured valid RSA certificates are taken after SW roll-back-fallback so that BTS
# can reconnect to via IPSec or TLS
#	Perform Commissioning       scf_file=${config_file_RSA_roolback}   verify_bts_status=False     timeout=400     alias=default
#	Sleep    900
    Flag verification after enabling the feature
    Read IP Parameters
	Remove if any existing certificate
    Verification certificates both in Active and Passive after vendorcert
    Triger CMP RSA IR to install certificates
    Verify Alarm   faultid=61510   should_exist=${False}
#    Enable CRL and verify the LDAP packetes
#	Verify Alarm        faultid=61074     should_exist=${False}
##    Enable Ipsec on Admin
##    Get Ipsec Tunnels Status
    Verification of certificate details in BTS Active partition
	Verification of certificate details in BTS Passive partition
    Adding the additional TA certificate and verify the certs count in Active and Passive partition
    Comparision of details between Active and passive partition
    CMP Key update and details verification
    Disable the flag and delete the TA certificate
    Enable the flag and verify certificate count in partitions
    Verification of certificate details in BTS Active partition Before Roll-Back
    Rollback Software     timeout=120      alias=default
    Sleep    300
    Comparision of certificates details after Roll-Back
    Rollback Software     verify_bts_status=false   timeout=900      alias=default
    Sleep    600

    [Teardown]     Run Keyword And Ignore Error        Certificate Configure    operation=delete_cert   type=${ta_cert}
    ...		subject=${ta_sub}   source=${source}


*** Keywords ***

Flag verification after enabling the feature
    ${flag_enabled} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_enabled}}   ${flag_enable_check}

Read IP Parameters
    ${mplane_IP} =            Get Parameter       rat=common      param_path=${mplane_ip_moc_path}
    Set Suite Variable      ${mplane_IP}
    ${Primary_cmp} =            Get Parameter       rat=common      param_path=${cmp_ip_moc_path}
    Set Suite Variable        ${Primary_cmp}

Remove if any existing certificate
     Certificate Configure     operation=restore_vendor_certificate

Verification certificates both in Active and Passive after vendorcert
       Execute command on gNB     ${BTS_cert_count}
       Should Be Equal   '${stdout}'    '0'

       Execute command on gNB     ${Mount_command}

       Execute command on gNB      ${BTS_cert_count_passive}
       Should Be Equal   '${stdout}'    '0'


Triger CMP IR to install certificates
    Traffic Capture Start    capture_device=bts1   alias=cmp_fp0
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA     timeout=1000
    Sleep    80
	${filename_A}=  Traffic Capture Stop    capture_device=bts1   alias=cmp_fp0
    Set Suite Variable      ${filename_A}
    Verify CMP packets
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop   alias=cmp_fp0

Verify CMP packets
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_cmp_ir       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_cmp_accept      filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_cmp_certconf       filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${filename_A}        analysis=verify_cmp_pkiconf       filter_file_name=${traffic_filter_file_name}

Adding the additional TA certificate and verify the certs count in Active and Passive partition
    Certificate Configure    operation=install_certificate    cert_file=${ta1pem}     cert_type=${additionalCa}     cert_format=${pem}

    Execute command on gNB     ${Additional_cert_count_active}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB     ${Additional_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'

Trigger CRL update in BTS

           Traffic Capture Start    capture_device=bts1   alias=crl_br0
           Certificate Configure    operation=update_certificate_revocation_list
           Sleep    300
           ${filename_D}=  Traffic Capture Stop    capture_device=bts1   alias=crl_br0
           Set Suite Variable      ${filename_D}
           Verify LDAP packets
           [Teardown]     Run Keyword And Ignore Error      Traffic capture stop   alias=crl_br0

Verify LDAP packets

          Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_bind_req      filter_file_name=${traffic_filter_file_name}
          Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_bind_res      filter_file_name=${traffic_filter_file_name}
          Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_search_req      filter_file_name=${traffic_filter_file_name}
          Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_search_resentry      filter_file_name=${traffic_filter_file_name}
          Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_res_done      filter_file_name=${traffic_filter_file_name}
          Analyse Pcap        pcap_filename=${filename_D}        analysis=verify_unbind_req      filter_file_name=${traffic_filter_file_name}


Verification of certificate details in BTS Active partition
   Execute command on gNB     ${BTS_cert_count}
   Should Be Equal   '${stdout}'    '1'

   Execute command on gNB    ${BTS_cert_Active}
   Set Suite Variable     ${serial_number_Active}     ${stdout}

   Execute command on gNB    ${BTS__fingerprint_Active}
   Set Suite Variable     ${finger_print_Active}      ${stdout}

Verification of certificate details in BTS Passive partition
    Execute command on gNB     ${Mount_command}

    Execute command on gNB      ${BTS_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB    ${BTS_cert_passive}
    Set Suite Variable     ${serial_number_Passive}   ${stdout}

    Execute command on gNB    ${BTS__fingerprint_passive}
    Set Suite Variable     ${finger_print_Passive}    ${stdout}

Comparision of details between Active and passive partition
    Should Be Equal    ${serial_number_Active}   ${serial_number_Passive}
    Should Be Equal    ${finger_print_Active}    ${finger_print_Passive}

    ${crl_pem_verification}=    Execute command on gNB   ${crlpem_active_passive}
#    Should Be Equal    ${crl_pem_verification}  ${None}

    ${crl_info_verification}=    Execute command on gNB   ${crlinfo_active_passive}
#    Should Be Equal    ${crl_info_verification}  ${None}

CMP Key update and details verification
    Certificate Configure     operation=cmp_update_key         timeout=120

    Sleep  120

    Execute command on gNB    ${BTS_cert_Active}
    Set Suite Variable     ${serial_number_Active_key}    ${stdout}

    Execute command on gNB    ${BTS_cert_passive}
    Set Suite Variable     ${serial_number_Passive_key}   ${stdout}

    Should Not Be Equal    ${serial_number_Active_key}   ${serial_number_Active}
    Should Not Be Equal    ${serial_number_Passive_key}   ${serial_number_Passive}

    ${psk_info_verification}=     Execute command on gNB  ${Pskinfo_active_passive}
#    Should Be Equal  ${psk_info_verification}  ${None}


Disable the flag and delete the TA certificate
    Perform Recommissioning     type=delta      delta_file=${Modifying_Flag}     timeout=300
    ${flag_disable} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_disable}}   ${flag_disable_check}

    Certificate Configure    operation=delete_cert   type=${ta_cert}    subject=${ta_sub}   source=${source}

    Execute command on gNB     ${Additional_cert_count_active}
    Should Be Equal   '${stdout}'    '0'

    Execute command on gNB     ${Additional_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'

Enable the flag and verify certificate count in partitions
    Perform Recommissioning     type=delta      delta_file=${Modifying_Flag_enable}     timeout=300
    ${flag_enabled} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_enabled}}   ${flag_enable_check}

    Execute command on gNB     ${Additional_cert_count_active}
    Should Be Equal   '${stdout}'    '0'

    Execute command on gNB     ${Additional_cert_count_passive}
    Should Be Equal   '${stdout}'    '0'

Verification of certificate details in BTS Active partition Before Roll-Back

    Execute command on gNB     ${BTS_cert_count}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB    ${RSA_ta_cert}
    Set Suite Variable     ${serial_number_Active1}   ${stdout}

    Execute command on gNB    ${RSA_ta_fingerprint}
    Set Suite Variable     ${finger_print_Active1}    ${stdout}

Comparision of certificates details after Roll-Back
   Execute command on gNB     ${BTS_cert_count}
   Should Be Equal   '${stdout}'    '1'

   Execute command on gNB     ${RSA_ta_cert}
   Set Suite Variable     ${serial_number_Active2}     ${stdout}

   Execute command on gNB    ${RSA_ta_fingerprint}
   Set Suite Variable     ${finger_print_Active2}      ${stdout}

   Should Be Equal    ${serial_number_Active2}   ${serial_number_Active1}
   Should Be Equal    ${finger_print_Active2}    ${finger_print_Active1}
