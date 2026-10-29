*** Settings ***
Documentation   Test case for security area for certificates
Resource        ../Resources/resources.robot



*** Keywords ***
TLS_operations
    RUN    mkdir ${TEST_OUTPUT_DIR}
    Run keyword and Continue on Failure    Clear Certificates

    Log    ***STEP 1***Check if vednor certificate is present on BTS***    console=true
    Run keyword and Continue on Failure    Check If Vendor Certificate is Present

    Log    ***Preparing certificates***    console=true
    Generate Binary File From HEX String    hex_string_file=${P12_ECDSA}
    ...                                     binary_file_name=${TEST_OUTPUT_DIR}/ECDSA.p12
    Generate Binary File From HEX String    hex_string_file=${P12_RSA}
    ...                                     binary_file_name=${TEST_OUTPUT_DIR}/RSA.p12

    Log    ***STEP 2*** Manual install ECDSA and RSA certificates***    console=true
    Run keyword and Continue on Failure    Manual install ECDSA and RSA certificate

    Log    ***STEP 3*** Check certificates on BTS***    console=true
    Run keyword and Continue on Failure    Check certificates on BTS

    Log    ***Restore vendor certificates***    console=true
    Clear certificates

    Log    ***Set subjectaltname***    console=true
    Run keyword and Continue on Failure    Set Subject Alternative Name    server_type=RSA
#
    Log    ***STEP 4*** Connecting with emssim with TLS1.2 and RSA certificate and verify pcap messages***    console=true
    Run keyword and Continue on Failure    Connect to BTS with provided certificate and TLS version    RSA    1_2
#
    Log    ***\tVerify PCAP messages***    console=true
    Run keyword and Continue on Failure    Verify PCAP messages    RSA    1_2
#
    Log    ***Reboot BTS***    console=true
    Reboot BTS and wait until available

    Log    ***STEP 5*** Verify connection to port 443***    console=true
    Wait Until Keyword Succeeds  20x  30s  Wait until BTS reach Configured or OnAir state
    Run keyword and Continue on Failure    Verify connection to port 443    RSA  1_2

    Log    ***Set subjectaltname***    console=true
    Run keyword and Continue on Failure    Set Subject Alternative Name    server_type=ECDSA

    Log    ***Reboot BTS***    console=true
    Reboot BTS and wait until available

    Log    ***STEP 7*** Verify connection to port 443***    console=true
    Wait Until Keyword Succeeds  20x  30s  Wait until BTS reach Configured or OnAir state
    Run keyword and Continue on Failure    Verify connection to port 443    ECDSA  1_2

    Log    ***Reboot BTS***    console=true
    Reboot BTS and wait until available

    Log    ***STEP 9*** Verify connection to port 443***    console=true
    Wait Until Keyword Succeeds  20x  30s  Wait until BTS reach Configured or OnAir state
    Run keyword and Continue on Failure    Verify connection to port 443    RSA  1_3

    Log    ***Reboot BTS***    console=true
    Reboot BTS and wait until available
    Wait Until Keyword Succeeds  20x  30s  Wait until BTS reach Configured or OnAir state
    Log    ***STEP 10*** Connecting with emssim with TLS1.3 and ECDSA certificate***    console=true
    Run keyword and Continue on Failure    Connect to BTS with provided certificate and TLS version    ECDSA    1_3

    Log    ***\tVerify PCAP messages***    console=true
    Run keyword and Continue on Failure    Verify PCAP messages    ECDSA    1_3

    Log    ***STEP 11*** Verify connection to port 443***    console=true
    Run keyword and Continue on Failure    Verify connection to port 443    ECDSA  1_3

    Log    ***STEP 12*** Connecting with TLS 1.1***    console=true
    Run keyword and Continue on Failure    Connecting with TLS1.1

#    Log    ***STEP 13*** Check if certificates are synchronised***    console=true
#    Run keyword and Continue on Failure     resources.Check Synchronization By Ssh

    Log    ***STEP 14*** Change keylength value for RSA and ECDSA certificates***    console=true
    Change Parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1     keyLength  384
    Change Parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1     keyLength  4096

    Log    ***STEP 15*** Reconfigure CMP for ECDSA certificate by NetAct***    console=true
    Run keyword and Continue on Failure    Reconfigure CMP for ECDSA certificate by NetAct

    Log    ***STEP 16*** Check if proper certificates are present on BTS***    console=true
    Run keyword and Continue on Failure    Check if proper certificates are present on BTS    384    ECDSA    CB005999_test

    Log    ***STEP 17*** Reconfigure CMP for RSA certificate by WebEM***    console=true
    Run keyword and Continue on Failure    Reconfigure CMP for RSA certificate by WebEM

    Log    ***STEP 18*** Check if proper certificates are present on BTS***    console=true
    Run keyword and Continue on Failure    Check if proper certificates are present on BTS    4096    RSA    ${SECOND_SUBJECT_NAME}[RSA]

    Log    ***STEP 19*** Reset BTS***    console=true
    Reboot BTS and wait until available

    Log    ***STEP 20*** Check if proper certificates are present on BTS***    console=true
    Run keyword and Continue on Failure    Check if proper certificates are present on BTS    4096  RSA    ${SECOND_SUBJECT_NAME}[RSA]

    Log    ***STEP 21*** Check if proper certificates are present on BTS***    console=true
    Run keyword and Continue on Failure    Check if proper certificates are present on BTS    384   ECDSA      CB005999_test

    Log    ***STEP 22*** Install certificate with short expiration time and expect alarm***    console=true
    Trust Anchor Certificate with expiry alarm

    Log    ***STEP 23*** Check if CMP IR messages are visible in PCAP***   console=true
    Verify CMP Messages In PCAP    RSA
    Verify CMP Messages In PCAP    ECDSA
    [Teardown]    Run keywords    Log    ***TEARDOWN*** Restore vendore certificates***
    ...    AND                    Clear Certificates
