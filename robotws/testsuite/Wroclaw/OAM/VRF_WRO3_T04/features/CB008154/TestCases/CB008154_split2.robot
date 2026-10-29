*** Settings ***
Documentation
...     description:    Test cases for the CB008154 feature.

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/netact/netact_operations.robot
Resource    ../../../common_resources/certificates/certificates.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../Resources/Split2/CB008154_split2_resources.robot
Resource    ../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../Resources/CB008154_split3_keywords.robot
Library     SSHLibrary

*** Variables ***
${logs_dest}=                   ${OUTPUT_DIR}/ATL_logs.xml
${csr_file}=                    ${EXECDIR}/csr_key.txt
${ca_subject_name}=             C=PL, O=Common, CN=IPSEC
${wrong_ca_subject_name}=       C=PL, O=Wrong, CN=Wrong123
${due_to_expired_ca_subject_name}=       CN=8154_short_validity
${too_long_ca_subject_name}=       CN=8154_too_long
${cert_expired}=    ${CURDIR}/../Resources/Split2/certificate_expired.pem
${cert_subject_missing}=    ${CURDIR}/../Resources/Split2/subject_name_missing_or_invalid.pem
${cert_PEM_or_DER_format}=    ${CURDIR}/../Resources/Split2/PEM_or_DER_format.pem
${cert_max_size}=    ${CURDIR}/../Resources/Split2/Certificate_exceeding_maximum_size.pem
${cert_EERACATA}=    ${CURDIR}/../Resources/Split2/EERACATA.pem

*** Keywords ***
CB008154_NE_Cert_Storage_newAlarm
    Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1   caCertificateUpdateTime    4000
    Install Certificate On BTS                  cert_file=${CURDIR}/../Resources/Split2/8154.pem
    ...                                         cert_type=AdditionalCa
    ...                                         cert_format=PEM
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=61618
    ${output}=    Run Keyword And Ignore Error  Install Certificate On BTS    cert_file=${CURDIR}/../Resources/Split2/8154.pem
    ...                                         cert_type=AdditionalCa
    ...                                         cert_format=PEM
    ${error}=    Convert To String   ${output}
    Should Contain   ${error}    Failed: Duplicate certificate found
    [Teardown]  Clear Certificates

CB008154_NE_Cert_Storage
    Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1   caCertificateUpdateTime    30
    Install Certificate On BTS                  cert_file=${CURDIR}/../Resources/Split2/8154.pem
    ...                                         cert_type=AdditionalCa
    ...                                         cert_format=PEM
    ${output}=    Run Keyword And Ignore Error    Install Certificate On BTS
    ...                                           cert_file=${CURDIR}/../Resources/Split2/Certificate_exceeding_maximum_size.pem
    ...                                           cert_type=AdditionalCa
    ...                                           cert_format=PEM
    ${error}=    Convert To String   ${output}
    Should Contain   ${error}    Failed: Certificate exceeding maximum size.
    Configure CMP             bts_id=${BTS_ID}
    ...                       ca_subject_name=${too_long_ca_subject_name}
    Run Keyword And Ignore Error    Initialize Certificates
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=61510
    ${output}=    Run Keyword And Ignore Error    Install Certificate On BTS    cert_file=${CURDIR}/../Resources/Split2/8154.pem
    ...                                           cert_type=AdditionalCa
    ...                                           cert_format=PEM
    ${error}=    Convert To String   ${output}
    Should Contain   ${error}    Failed: Duplicate certificate found
    [Teardown]  Run Keywords        Configure CMP    bts_id=${BTS_ID}    ca_subject_name=${ca_subject_name}
    ...         AND    Initialize Certificates
    ...         AND    Clear Certificates

CB008154_CMP_kur_failure
    Configure CMP             bts_id=${BTS_ID}
    ...                       ca_subject_name=${ca_subject_name}
    Initialize Certificates
    Configure CMP             bts_id=${BTS_ID}
    ...                       ca_subject_name=${wrong_ca_subject_name}
    Run Keyword And Ignore Error    Update CMP Key
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=61510
    [Teardown]  Run Keywords        Configure CMP    bts_id=${BTS_ID}    ca_subject_name=${ca_subject_name}
    ...         AND    Initialize Certificates
    ...         AND    Clear Certificates

CB008154_CMP_init_failure
    Set Cert Update Time Param      ${neCertificateUpdateTime_default}
    Configure CMP             bts_id=${BTS_ID}
    ...                       ca_subject_name=${due_to_expired_ca_subject_name}
    Initialize Certificates
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=61618
    Configure CMP             bts_id=${BTS_ID}
    ...                       ca_subject_name=${wrong_ca_subject_name}
    Run Keyword And Ignore Error    Update CMP Key
    Wait Until Keyword Succeeds  5min  60sec    Alarm Should be Active In BTS               fault_id=61510
    [Teardown]  Run Keywords        Configure CMP    bts_id=${BTS_ID}    ca_subject_name=${ca_subject_name}
    ...         AND    Initialize Certificates
    ...         AND    Clear Certificates

CB008154_CBRS_Vendor_certificate_installation_failed
    Generate CSR    ${csr_file}      domain_type=CBRS
    ${output}=    Run Keyword And Ignore Error                  Install Certificate On BTS
    ...                                                         cert_file=${CURDIR}/../Resources/Split2/cbrs_expired.pem
    ...                                                         cert_type=CBRSVendorChain
    ...                                                         cert_format=PEM
    ${error}=    Convert To String   ${output}
    Should Contain   ${error}    Certificate validation - Certificate expired


CB008154_NE_Cert_Storage_CBRS
    Generate CSR    ${csr_file}      domain_type=CBRS
    ${output}=    Run Keyword And Ignore Error                  Install Certificate On BTS
    ...                                                         cert_file=${CURDIR}/../Resources/Split2/cbrs_cert_too_long.pem
    ...                                                         cert_type=CBRSAdditionalCa
    ...                                                         cert_format=PEM
    ${error}=    Convert To String   ${output}
    Should Contain   ${error}    Certificate exceeding maximum size


Manual_install_Cacert_NetAct
    [Arguments]      ${cert}
    Start Tcpdump
    Sleep    120    Wait for new package
    Install Certificates Using NetAct    cert_path=${cert}
    Sleep    240    Wait for cert package


CB008154_Manual_install_Cacert_NetAct
    Run Keyword And Ignore Error    Manual_install_Cacert_NetAct    ${cert_expired}
    ${PCAP_NAME}=    Stop Tcpdump And Download Pcap
    Sleep    120    Wait for PCAP message
    PCAP Should Contain Message
    ...                            tshark_filter=xml.cdata == "Certificate validation - Certificate expired"
    ...                            pcap_file=${PCAP_NAME}

     Run Keyword And Ignore Error    Manual_install_Cacert_NetAct   ${cert_subject_missing}
     ${PCAP_NAME}=    Stop Tcpdump And Download Pcap
     Sleep    120    Wait for PCAP message
     PCAP Should Contain Message
     ...                           tshark_filter=xml.cdata == "Certificate validation - subject name missing or invalid"
     ...                           pcap_file=${PCAP_NAME}

     Run Keyword And Ignore Error    Manual_install_Cacert_NetAct    ${cert_max_size}
     ${PCAP_NAME}=    Stop Tcpdump And Download Pcap
     Sleep    120    Wait for PCAP message
     PCAP Should Contain Message
     ...                           tshark_filter=xml.cdata == xml.cdata == "Certificate exceeding maximum size"
     ...                           pcap_file=${PCAP_NAME}

    Run Keyword And Ignore Error    Manual_install_Cacert_NetAct    ${cert_EERACATA}
    ${PCAP_NAME}=    Stop Tcpdump And Download Pcap
     Sleep    120    Wait for PCAP message
     PCAP Should Contain Message
     ...    tshark_filter=xml.cdata == "Profile validation failure - EE/RA/CA/TA CERT profile validation like basic constraints, key usage"
     ...    pcap_file=${PCAP_NAME}

    ${output}    Run Keyword And Ignore Error  Install Certificates Using NetAct    cert_path=${cert_PEM_or_DER_format}
    ${error}=    Convert To String   ${output}
    Should Contain   ${error}
    ...    ValueError: Valid PEM but no BEGIN CERTIFICATE/END CERTIFICATE delimiters. Are you sure this is a certificate?

    [Teardown]    Run Keyword And Ignore Error  Stop Tcpdump And Download Pcap


CB008154_NE_Cert_Storage_newAlarm_CBRS
    Install Certificate On BTS                                  cert_file=${CURDIR}/../Resources/Split2/8154.pem
    ...                                                         cert_type=CBRSAdditionalCa
    ...                                                         cert_format=PEM
    ${output}=    Run Keyword And Ignore Error                  Install Certificate On BTS
    ...                                                         cert_file=${CURDIR}/../Resources/Split2/8154.pem
    ...                                                         cert_type=CBRSAdditionalCa
    ...                                                         cert_format=PEM

    ${error}=    Convert To String   ${output}
    Should Contain   ${error}    Failed: Duplicate certificate found
