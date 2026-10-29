*** Settings ***
Documentation    Test suite for ASIR with TLS verification of feature CB010265
...              Additional robustness tests for EDA MNRCA-70857
...              authors: Lukasz Skoczylas, Aleksandra Faliszek
...              contact: lukasz.skoczylas@nokia.com, aleksandra.faliszek@nokia.com

Resource     testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/CB010265/resources/CB010265_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown  Common Suite Teardown

*** Variables ***
${delta_path}=                ${CURDIR}/resources/deltas
${cert_RSA_password}=         fZYV-J5Vq-XbJR-faz6
${cert_RSA_path}=             ${CURDIR}/resources/certs/RSA
${cert_SHA1_password}=        rKp9-yn95-VdxR-TnLi
${cert_SHA1_path}=            ${CURDIR}/resources/certs/SHA1

*** Test Cases ***
[1][2.0]CB010265-EDA_01_ASIR_NetAct_Integration_cert_install_in_loop
    [Documentation]
    ...  EDA MNRCA-70857 - Validate robustness on multiple installation RSA operator certificate with 4k bits key length
    ...  for TLS authentication between ASiR and Netact.
    [Setup]      Common Test Setup And Backup Sbts
    Log To Console  \n===Enable TLSv1.2 RSA===
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_RSA.json  interface=lmp  force_reconnect=${True}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    Create Certificate pkcs12  ${cert_RSA_path}  ${cert_RSA_password}
    FOR    ${cert_iteration}    IN RANGE    100
        Log To Console  \n===Install cert iteration: ${cert_iteration}   ===
        Log To Console  \n===Install RSA cert===
        gnbbbu.Install Certificate  cert_file=${cert_RSA_path}/btscert.p12  cert_type=BtsTrustChain
        ...  cert_format=P12  password=${cert_RSA_password}  key_pool_type=RSA
        Log To Console  \n===Integrate ASiR to emssim with TLSv1.2===
        ASiR NE integration to EMSsim  ${cert_RSA_path}
        Sleep   60s
        ${res} =     Verify ASiR NE integration to EMSsim
        Should Be True    ${res} >= ${1}
        Log To Console  \n===Integrate ASiR to emssim with TLSv1.2 successfully===
        EMSsim get alarm from ASiR
        Log To Console  \n===De-integrate ASiR to emssim===
        ASiR NE de-integration to EMSsim
        Sleep   10s
        Log To Console  \n===Uninstall Install RSA cert===
        gnbbbu.Restore Vendor Certificate
        Sleep   10s
    END
    [Teardown]   Common Test Teardown And Recover Sbts
