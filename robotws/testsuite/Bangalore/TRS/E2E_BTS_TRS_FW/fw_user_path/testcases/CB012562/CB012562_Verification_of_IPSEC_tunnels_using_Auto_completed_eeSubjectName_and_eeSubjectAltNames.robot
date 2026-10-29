*** Settings ***
Documentation
...     [Procedure]     "CB012562 Verification of IPSEC tunnels using Auto_completed eeSubjectName and eeSubjectAltNames"
...     [Author]        "Ankita P"
...     [Maintenance]   "TRS_VRF"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Function_Hash_Tags]    "CMP"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASOE"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
variables               ta_e2e_bts_trs_fw
Library                 ute_fsmaccess
#Resource                setup/framework.robot
Resource         ${CURDIR}/../resources/common_keywords.robot
Resource             ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource             ${CURDIR}/../resources/Admin_Common_Library.robot
#Variables       config

#Suite Setup       Setup Oamops
#Suite Teardown    Teardown Oamops

#Suite Setup       Pre-conditions for testsuite
#Suite Teardown    Post-conditions for test teardown

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
#Suite Teardown     Run Keywords        Suite Teardown Postconditions
#...        AND     Teardown Oamops

***Test Cases***
[1]CB012562 Verification of IPSEC tunnels using Auto_completed eeSubjectName and eeSubjectAltNames

    Perform Commissioning       scf_file=${Base_scf}   verify_bts_status=False     timeout=400     alias=default
    sleep   300
    Restore all Certificate
    sleep   30
    Traffic Capture Start    capture_device=vm_eth3_interface     alias=ecdsa_pcap
    Perform Recommissioning    type=delta    delta_file=${CB012562_ECDSA}   timeout=100
    sleep   180
    ${ecdsa}=     Traffic Capture Stop        alias=ecdsa_pcap
    Check wireshark for cmp messages    ${ecdsa}
    Verify wireshark of subjectname with serial number      ${ecdsa}
    Perform Commissioning       scf_file=${Base_scf}   verify_bts_status=False     timeout=400     alias=default
    sleep   300
    Restore all Certificate
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=rsa_pcap
    Perform Recommissioning    type=delta    delta_file=${CB012562_RSA}   timeout=100
    sleep   180
    Perform Recommissioning    type=delta    delta_file=${CB012562_IPSEC}   timeout=100
    IPSEC Configuration for Strongswan
    sleep   200
   Verify Ipsec Tunnels Status
    ${rsa}=     Traffic Capture Stop        alias=rsa_pcap
    Check wireshark for cmp messages    ${rsa}
   Verify wireshark of subjectname with serial number      ${rsa}

**Keywords***

Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}   key_pool_type=ECDSA
	Sleep     10

Check wireshark for cmp messages
    [Arguments]     ${Wireshark_file}

     Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=body_ir     filter_file_name=${pcap_file}
     Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=body_ip     filter_file_name=${pcap_file}
     Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=body_certConf     filter_file_name=${pcap_file}
     Analyse Pcap        pcap_filename=${Wireshark_file}     analysis=body_pkiconf     filter_file_name=${pcap_file}

Verify wireshark of subjectname with serial number
    [Arguments]     ${Wireshark_filter}
    ${SAN}=      Run     tshark -n -r ${Wireshark_filter} -Y "((((cmp) && (ip.src == 10.0.1.2)) && (ip.dst == 10.58.143.250))
...&& (cmp.body == 0)) && (x509sat.uTF8String)" -T fields -e x509ce.dNSName
    Should Not Be Empty   ${SAN}
    Log     ${SAN}
    ${output_san} =     Get Substring      ${SAN}   0  87
    ${CN}=      Run     tshark -n -r ${Wireshark_filter} -Y "((((cmp) && (ip.src == 10.0.1.2)) &&
...(ip.dst == 10.58.143.250)) && (x509sat.DirectoryString))" -T fields -e x509sat.uTF8String
    Should Not Be Empty   ${CN}
    Log     ${CN}
    ${pcap_cert} =   Get Substring   ${CN}   86  103

    Get Operator Certificates       ${pcap_cert}    ${output_san}
#    ${SAN}=      Run     tshark -n -r ${CURDIR}/cmp.pcapng -Y "((((cmp) && (ip.src == 10.0.1.2)) && (ip.dst == 10.58.143.250)) &&
#...(cmp.body == 0)) && (x509sat.uTF8String)" -T fields -e x509ce.dNSName
#    Should Not Be Empty   ${SAN}
#    Log     ${SAN}
#    Get Operator Certificates       ${pcap_cert}
Get Operator Certificates
    [Arguments]     ${pcap_cert}	${output_san}
	${Certificate_list}=     certificate configure    operation=get_certificate_details      type=EndEntity      source=Operator
	Log     ${Certificate_list}
    @{operator_certs}=     Create List
	FOR   ${Certificate}  IN   @{Certificate_list}
	      Log        ${Certificate}
          ${vendor}=     Get From Dictionary     ${Certificate}        source
          ${cert_name}=    Get From Dictionary      ${Certificate}     issuedTo
          ${san_name}=     Get From Dictionary      ${Certificate}     subjectAlternateName
          ${output1}=       Get Substring            ${san_name}    4   25
          ${output2}=      Get Substring               ${san_name}   30    51
          ${output3}=      Get Substring               ${san_name}   56    77
          ${output4}=      Get Substring               ${san_name}   82    103
          ${Result}=    Remove String    ${cert_name}    ${SPACE}
    END
#    \      Run Keyword If   '${cert_name}' == 'Operator'    Append To List    ${operator_certs}    ${Result}
    Set Suite Variable      ${operator_certs}        ${cert_name}
    Should Contain      ${cert_name}        ${pcap_cert}
    Should Contain      ${output_san}        ${output1}
    Should Contain      ${output_san}        ${output2}
    Should Contain      ${output_san}        ${output3}
    Should Contain      ${output_san}        ${output4}

IPSEC Configuration for Strongswan
    Run         sudo cp /etc/ipsec.conf /etc/ipsec_bkup.conf
    Run         sudo cp ${IPSEC_CB012562_conf} /etc/ipsec.conf
    Run         sudo ipsec restart
    sleep       120

Verify Ipsec Tunnels Status
        @{parent_tunnel_moc_list} =     Query Admin Infomodel           query=get list ${ike_sa_l_moc_path}
        FOR    ${ike_tunnel}   IN      @{parent_tunnel_moc_list}
               ${parent_tunnel_stateInfo}=     Get From Dictionary             dictionary=${ike_tunnel}
        ...         key=stateInfo
               ${parent_tunnel_proceduralState}=       Get From Dictionary
        ...         dictionary=${parent_tunnel_stateInfo}           key=proceduralState
               Should Be True  '${parent_tunnel_proceduralState}'=='Established'
        END
        @{child_tunnel_moc_list} =      Query Admin Infomodel           query=get list ${ipsec_sa_l_moc_path}
        FOR    ${child_tunnel}     IN      @{child_tunnel_moc_list}
               ${child_tunnel_stateInfo}=      Get From Dictionary             dictionary=${child_tunnel}
        ...         key=stateInfo
               ${child_tunnel_proceduralState}=        Get From Dictionary
        ...         dictionary=${child_tunnel_stateInfo}            key=proceduralState
               Should Be True  '${child_tunnel_proceduralState}'=='Installed'
        END
