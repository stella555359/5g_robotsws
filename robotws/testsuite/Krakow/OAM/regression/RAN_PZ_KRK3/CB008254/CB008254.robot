*** Settings ***
Documentation    Test suite for ASIR with TLS verificaton of feature CB008254
...              Tests migrated from Nanjing, the orginal author: Wu Yuanyuan yuanyuan.wu@nokia-sbell.com
...              authors: Lukasz Skoczylas, Aleksandra Faliszek
...              contact: lukasz.skoczylas@nokia.com, aleksandra.faliszek@nokia.com

Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/CB008254/resources/CB008254_keywords.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown  Common Suite Teardown

*** Variables ***
${delta_path}=                ${CURDIR}/resources/deltas
${ipsec_path}=                ${CURDIR}/resources/ipsec
${cert_RSA_password}=         fZYV-J5Vq-XbJR-faz6
${cert_RSA_path}=             ${CURDIR}/resources/certs/RSA
${cert_ECDSA256_path}=        ${CURDIR}/resources/certs/ECDSA256
${cert_ECDSA256_password}=    f2Vi-kxEb-UmNn-mmPi
${cert_ECDSA384_path}=        ${CURDIR}/resources/certs/ECDSA384
${cert_ECDSA384_password}=    rKp9-yn95-VdxR-TnLi

*** Test Cases ***
[1][1.0]CB008254-SR-A_01_TLSv1.2 connection establishment with ASiR as TLS client and Netact as TLS Server_ECDSA_256bits key length
    [Documentation]
    ...  This case is developed to validate the usage of ECDSA operator certificate with 256 bits key length
    ...  for TLS authentication between ASiR and Netact

    [Setup]      Common Test Setup And Backup Sbts
    Log To Console  \n===Install RSA cert for IPSec establishment===
    gnb_asir.Disconnect
    Create Certificate pkcs12  ${cert_RSA_path}  ${cert_RSA_password}
    gnbbbu.Install Certificate  cert_file=${cert_RSA_path}/btscert.p12  cert_type=BtsTrustChain
    ...  cert_format=P12  password=${cert_RSA_password}  key_pool_type=RSA
    Log To Console  \n===Enable TLSv1.2 ECDSA and IPSec===
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_ECDSA.json  interface=lmp  force_reconnect=${True}
    Update BTS Mplane Ip and Reset Admin connections  ${IPSEC_OAM_IP}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    Log To Console  \n===Install ECDSA cert for TLSv1.2 establishment===
    Create Certificate pkcs12  ${cert_ECDSA256_path}  ${cert_ECDSA256_password}
    gnbbbu.Install Certificate   cert_file=${cert_ECDSA256_path}/btscert.p12  cert_type=BtsTrustChain
    ...  cert_format=P12  password=${cert_ECDSA256_password}  key_pool_type=ECDSA
    Log To Console  \n===Integrate ASiR to emssim with TLSv1.2===
    ASiR NE integration to EMSsim  ${cert_ECDSA256_path}
    Sleep   60s
    Verify ASiR NE integration to EMSsim
    Log To Console  \n===Integrate ASiR to emssim with TLSv1.2 successfully===
    Log To Console  \n===De-integrate ASiR to emssim===
    ASiR NE de-integration to EMSsim
    Sleep   60s
    Verify ASiR NE de-integration to EMSsim
    Log To Console  \n===De-integrate successfully===
    [Teardown]   Common Test Teardown And Recover Sbts

[1][1.0]CB008254-SR-A_02_TLSv1.2 connection establishment with ASiR as TLS Server and Netact as TLS Client_ECDSA_256bits key length
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

[1][1.0]CB008254-SR-A_03_TLSv1.2 connection establishment with ASiR as TLS client and Netact as TLS Server_ECDSA_384bits key length
    [Documentation]
    ...  This case is developed to validate the usage of ECDSA operator certificate with 384 bits key length
    ...  for TLS authentication between ASiR and Netact

    [Setup]      Common Test Setup And Backup Sbts
    Log To Console  \n===Install RSA cert for IPSec establishment===
    gnb_asir.Disconnect
    Create Certificate pkcs12  ${cert_RSA_path}  ${cert_RSA_password}
    gnbbbu.Install Certificate  cert_file=${cert_RSA_path}/btscert.p12  cert_type=BtsTrustChain
    ...  cert_format=P12  password=${cert_RSA_password}  key_pool_type=RSA
    Log To Console  \n===Enable TLSv1.2 ECDSA and IPSec===
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_ECDSA.json  interface=lmp  force_reconnect=${True}
    Update BTS Mplane Ip and Reset Admin connections   ${IPSEC_OAM_IP}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    Verify Status of all ASIR cells is Operational
    Log To Console  \n===Install ECDSA cert===
    Create Certificate pkcs12  ${cert_ECDSA384_path}  ${cert_ECDSA384_password}
    gnbbbu.Install Certificate   cert_file=${cert_ECDSA384_path}/btscert.p12  cert_type=BtsTrustChain
    ...  cert_format=P12  password=${cert_ECDSA384_password}  key_pool_type=ECDSA
    Log To Console  \n===Integrate ASiR to emssim with TLSv1.2===
    ASiR NE integration to EMSsim  ${cert_ECDSA384_path}
    Sleep   60s
    Verify ASiR NE integration to EMSsim
    Log To Console  \n===Integrate ASiR to emssim with TLSv1.2 successfully===
    Log To Console  \n===De-integrate ASiR to emssim===
    ASiR NE de-integration to EMSsim
    Sleep   60s
    Verify ASiR NE de-integration to EMSsim
    Log To Console  \n===De-integrate successfully===
    [Teardown]   Common Test Teardown And Recover Sbts

[1][1.0]CB008254-SR-A_04_TLSv1.2 connection establishment with ASiR as TLS Server and Netact as TLS Client_ECDSA_384bits key length
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS
