
***Settings ***
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


Variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../../resources/common_keywords.robot
#Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot


***Keywords***

Flag verification after enabling the feature
    ${flag_enabled} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_enabled}}   ${flag_enable_check}

Read RSA IP Parameters
    ${mplane_IP} =            Get Parameter       rat=common      param_path=${mplane_ip_moc_path}
    Set Suite Variable      ${mplane_IP}
    ${Primary_cmp} =            Get Parameter       rat=common      param_path=${cmp_ip_moc_path}
    Set Suite Variable        ${Primary_cmp}

Read IP Parameters
    ${mplane_IP} =            Get Parameter       rat=common      param_path=${mplane_ip_moc_path}
    Set Suite Variable      ${mplane_IP}
    ${Primary_cmp} =            Get Parameter       rat=common      param_path=${cmpEcdsa_ip_moc_path}
    Set Suite Variable        ${Primary_cmp}

Remove if any existing certificate
     Certificate Configure     operation=restore_vendor_certificate

Verification certificates both in Active and Passive after vendorcert
       Execute command on gNB     ${BTS_cert_count}
       Should Be Equal   '${stdout}'    '0'

       Execute command on gNB     ${Mount_command}

       Execute command on gNB      ${BTS_cert_count_passive}
       Should Be Equal   '${stdout}'    '0'

Triger CMP RSA IR to install certificates
    Traffic Capture Start    capture_device=bts1   alias=cmp_fp0
    Certificate Configure    operation=install_cmp_certificate
    Sleep    80
    ${filename_A}=  Traffic Capture Stop    capture_device=bts1   alias=cmp_fp0
    Set Suite Variable      ${filename_A}
    Verify CMP packets
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop   alias=cmp_fp0


Triger CMP IR to install certificates
    Traffic Capture Start    capture_device=bts1   alias=cmp_fp0
    Certificate Configure    operation=install_cmp_certificate       key_pool_type=ECDSA
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

Enable CRL and verify the LDAP packetes
    Traffic Capture Start    capture_device=bts1   alias=crl_br0
    Certificate Configure    operation=update_certificate_revocation_list    timeout=300
#    Sleep    300
    ${filename_B}=  Traffic Capture Stop    capture_device=bts1   alias=crl_br0
    Set Suite Variable      ${filename_B}
    [Teardown]     Run Keyword And Ignore Error      Traffic capture stop   alias=crl_br0

Adding the additional RSA TA certificate and verify the certs count in Active and Passive partition
    Certificate Configure    operation=install_certificate    cert_file=${ta1pem}     cert_type=${additionalCa}     cert_format=${pem}

    Execute command on gNB     ${Additional_cert_count_active}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB     ${Additional_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'


Adding the additional TA certificate and verify the certs count in Active and Passive partition
    Certificate Configure    operation=install_certificate    cert_file=${ecdsa_ta1.pem}     cert_type=${additionalCa}     cert_format=${pem}

    Execute command on gNB     ${Additional_cert_count_active}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB     ${Additional_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'

Disable the flag and delete the RSA TA certificate
    Perform Recommissioning     type=delta      delta_file=${Modifying_Flag}     timeout=300
    ${flag_disable} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_disable}}   ${flag_disable_check}


    Certificate Configure    operation=delete_cert   type=${ta_cert}    subject=${ta_sub}   source=${source}

    Execute command on gNB     ${Additional_cert_count_active}
    Should Be Equal   '${stdout}'    '0'

    Execute command on gNB     ${Additional_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'

Disable the flag and delete the TA certificate
    Perform Recommissioning     type=delta      delta_file=${Modifying_Flag}     timeout=300
    ${flag_disable} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_disable}}   ${flag_disable_check}
    Certificate Configure    operation=delete_cert   type=${ta_cert}    subject=${EC_ta_sub}   source=${source}

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

Verification of RSA certificate details in BTS Active partition
   Execute command on gNB     ${BTS_cert_count}
   Should Be Equal   '${stdout}'    '1'

   Execute command on gNB    ${BTS_cert_Active}
   Set Suite Variable     ${serial_number_Active}     ${stdout}

   Execute command on gNB    ${BTS__fingerprint_Active}
   Set Suite Variable     ${finger_print_Active}      ${stdout}

Verification of RSA certificate details in BTS Passive partition
    Execute command on gNB     ${Mount_command}

    Execute command on gNB      ${BTS_cert_count_passive}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB    ${BTS_cert_passive}
    Set Suite Variable     ${serial_number_Passive}   ${stdout}

    Execute command on gNB    ${BTS__fingerprint_passive}
    Set Suite Variable     ${finger_print_Passive}    ${stdout}


Verification of certificate details in BTS Active partition
   Execute command on gNB     ${BTS_EC_cert_Count_active}
   Should Be Equal   '${stdout}'    '1'

   Execute command on gNB    ${BTS_EC_cert_active}
   Set Suite Variable     ${serial_number_active}     ${stdout}

   Execute command on gNB    ${BTS_EC_fingerprint_active}
   Set Suite Variable     ${finger_print_active}      ${stdout}

Verification of certificate details in BTS Passive partition
    Execute command on gNB     ${Mount_command}

    Execute command on gNB     ${BTS_EC_cert_Count_passive}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB    ${BTS_EC_cert_passive}
    Set Suite Variable     ${serial_number_passive}   ${stdout}

    Execute command on gNB    ${BTS_EC_fingerprint_passive}
    Set Suite Variable     ${finger_print_passive}    ${stdout}

Comparision of details between Active and passive partition
    Should Be Equal    ${serial_number_active}   ${serial_number_passive}
    Should Be Equal    ${finger_print_active}    ${finger_print_passive}

    ${crl_pem_verification}=    Execute command on gNB   ${crlpem_active_passive}
#    Should Be Equal    ${crl_pem_verification}  ${None}

    ${crl_info_verification}=    Execute command on gNB   ${crlinfo_active_passive}
#    Should Be Equal    ${crl_info_verification}  ${None}

RSA CMP Key update and details verification
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




CMP Key update and details verification
    Certificate Configure     operation=cmp_update_key         key_pool_type=ECDSA      timeout=120

    Sleep  120

    Execute command on gNB    ${BTS_EC_cert_active}
    Set Suite Variable     ${serial_number_active_CRL}    ${stdout}

    Execute command on gNB    ${BTS_EC_cert_passive}
    Set Suite Variable     ${serial_number_passive_CRL}   ${stdout}

    Should Not Be Equal    ${serial_number_active_CRL}   ${serial_number_active}
    Should Not Be Equal    ${serial_number_passive_CRL}   ${serial_number_passive}

    ${psk_info_verification}=     Execute command on gNB  ${Pskinfo_active_passive}
#    Should Be Equal  ${psk_info_verification}  ${None}


Verification of RSA certificate details in BTS Active partition Before Roll-Back

    Execute command on gNB     ${BTS_cert_count}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB    ${RSA_ta_cert}
    Set Suite Variable     ${serial_number_Active1}   ${stdout}

    Execute command on gNB    ${RSA_ta_fingerprint}
    Set Suite Variable     ${finger_print_Active1}    ${stdout}


Verification of certificate details in BTS Active partition Before Roll-Back

    Execute command on gNB     ${BTS_EC_cert_Count_active}
    Should Be Equal   '${stdout}'    '1'

    Execute command on gNB   ${EC_ta_cert}
    Set Suite Variable     ${serial_number_Active1}   ${stdout}

    Execute command on gNB   ${EC_ta_fingerprint}
    Set Suite Variable     ${finger_print_Active1}    ${stdout}


Comparision of RSA certificates details after Roll-Back
   Execute command on gNB     ${BTS_cert_count}
   Should Be Equal   '${stdout}'    '1'

   Execute command on gNB     ${RSA_ta_cert}
   Set Suite Variable     ${serial_number_Active2}     ${stdout}

   Execute command on gNB    ${RSA_ta_fingerprint}
   Set Suite Variable     ${finger_print_Active2}      ${stdout}

   Should Be Equal    ${serial_number_Active2}   ${serial_number_Active1}
   Should Be Equal    ${finger_print_Active2}    ${finger_print_Active1}


Comparision of certificates details after Roll-Back
   Execute command on gNB     ${BTS_EC_cert_Count_active}
   Should Be Equal   '${stdout}'    '1'

   Execute command on gNB    ${EC_ta_cert}
   Set Suite Variable     ${serial_number_Active2}     ${stdout}

   Execute command on gNB    ${EC_ta_fingerprint}
   Set Suite Variable     ${finger_print_Active2}      ${stdout}

   Should Be Equal    ${serial_number_Active2}   ${serial_number_Active1}
   Should Be Equal    ${finger_print_Active2}    ${finger_print_Active1}
