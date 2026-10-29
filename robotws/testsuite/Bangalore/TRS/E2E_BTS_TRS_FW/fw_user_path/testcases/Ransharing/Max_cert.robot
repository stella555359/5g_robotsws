*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010762"
...     [Funtion_Hash_Tags]     "Certificate Installation"
...     [Procedure]             "Verification of maximum certificate installation"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CB010762_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***


[1]TRS_CB010762B_B1_Verification_of_Manual_Installation_and_certs_expiry_alarm_for_Max_Num_of_BTS_trust_chain_certs_supported_by_10_operator

    Setup Oamops            bts_host=192.168.255.129            alias=default
    PreCondition
    Perform Commissioning    scf_file=${Multihoming_V4}    skip_parameter_relation_errors=${True}   verify_bts_status=${False}     timeout=900
    sleep   120
     Install Maximum Additional CA Certificates
    Run Keyword and Expect Error    *Chain length of EE/RA certificates or max number of additional CA/TA certificate exceeds*
    ...  Install 1 Additional CA Certificate
    Verification_of_Operator_certificate_Expiry_Alarm
    Verification_of_EndEntity_certificate_Expiry_Alarm
    Verification_of_EndEntity_certificate_Expiry_Alarm_ECDSA
    Setup Oamops            bts_host=192.168.255.129            alias=default
    PreCondition
    Install Maximum Additional TA Certificates
    Run Keyword and Expect Error        *Chain length of EE/RA certificates or max number of additional CA/TA certificate exceeds*
    ...    Install 1 Additional TA Certificate
    PreCondition

*** keywords ***


Verification_of_Operator_certificate_Expiry_Alarm
    Perform Recommissioning      type=param     param_path=${Operator_Alarm_trigger_path}    operation=update        value=4999      timeout=300
    sleep    60
    Verify Alarm        faultid=${Operator_fault}        should_exist=${True}    timeout=200       occurrences=71
    Perform Recommissioning      type=param     param_path=${Operator_Alarm_trigger_path}     operation=update        value=1      timeout=300
    sleep     60
    Verify Alarm        faultid=${Operator_fault}        should_exist=${False}    timeout=200

Verification_of_EndEntity_certificate_Expiry_Alarm
    Perform Recommissioning      type=param     param_path=${EE_Alarm_trigger_path}    operation=update        value=4999      timeout=300
    sleep     60
    Verify Alarm        faultid=${EE_fault}        should_exist=${True}    timeout=200      occurrences=1
    Perform Recommissioning      type=param     param_path=${EE_Alarm_trigger_path}     operation=update        value=1      timeout=300
    sleep     60
    Verify Alarm        faultid=${EE_fault}        should_exist=${False}    timeout=200

Verification_of_EndEntity_certificate_Expiry_Alarm_ECDSA
    Perform Recommissioning      type=param     param_path=${EE_Alarm_trigger_path_ECDSA}    operation=update        value=4999      timeout=300
    sleep      60
    Verify Alarm        faultid=${EE_fault}        should_exist=${True}    timeout=200      occurrences=1
    Perform Recommissioning      type=param     param_path=${EE_Alarm_trigger_path_ECDSA}     operation=update        value=1      timeout=300
    sleep     60
    Verify Alarm        faultid=${EE_fault}        should_exist=${False}    timeout=200


PreCondition
    Log    Certificate Deleted Successfully
      Run Keyword And Ignore Error     certificate configure        operation=delete_cert       all_certs=${True}
Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default

Install 1 Additional CA Certificate
    FOR     ${index}    IN RANGE    85   86
        Certificate Configure     operation=install_certificate     cert_file=${CA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
        Sleep   5
    END

Install 1 Additional TA Certificate
    FOR     ${index}    IN RANGE    21   22
        Certificate Configure     operation=install_certificate     cert_file=${TA_name}_${index}.pem    cert_type=AdditionalCa     cert_format=PEM
        Sleep   5
    END