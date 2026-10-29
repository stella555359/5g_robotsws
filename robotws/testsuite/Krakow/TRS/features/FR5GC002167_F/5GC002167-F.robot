*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases 5GC002167-F

Library    testsuite.Krakow.resources.linux_accounts.python_keywords.Keywords    WITH NAME    keywords
Library    testsuite.Krakow.resources.syve_security.syve_security.SyVeSecurity    WITH NAME  security
Library    testsuite.Krakow.resources.openssl.Openssl    WITH NAME  openssl
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/bts/robot/logs_collecting.robot
Library    testsuite.Krakow.resources.du_webem.du_webem_keywords.DuWebem    WITH NAME  du_webem

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASIKL_ABILB1_AEUD_ENB

Suite Setup         Preconditions
Suite Teardown      Postconditions
Test Setup          Run Keyword And Ignore Error     Collect logs during test
Test Teardown       Run Keyword And Ignore Error     Collect logs after test finished

*** Variables ***
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Radio Diagnostic Files collected
...                  Diagnostic Files collected
...                  Service account root access is enabled
...                  Sanity Check Error
${emssimp12_path}   /home/ute/emssim.p12
${tls_script_path}  ${CURDIR}/tls_cipher_check.sh

*** Test Cases ***
5GC002167_FA_5GC002359_001_DU_TLS_connection_establishment_NE_as_TLS_server_TLSv1.1_rejected
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    ${output} =  DU establish tls 1 1 connection with openssl  port=443
    Verify tls connection is not established  ${output}
    ${output} =  DU establish tls 1 1 connection with openssl  port=8443
    Verify tls connection is not established  ${output}
    DU change MPLANENW parameter  parameter=tls11Enabled  value=true
    ${output} =  DU establish tls 1 1 connection with openssl  port=443
    Verify tls connection is established  ${output}

5GC002167_FA_5GC002359_002_DU_TLS_connection_establishment_NE_as_TLS_server_TLSv1.2_CBC_ciphers_rejected
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=true
    ${output} =  DU Establish TLS 1 2 connection with openssl  port=443
    Verify tls connection is not established  ${output}
    ${output} =  DU Establish TLS 1 2 connection with openssl  port=8443
    Verify tls connection is not established  ${output}
    ${output} =  DU Establish TLS 1 2 connection with openssl using not CBC cipher  port=443
    Verify tls connection is established  ${output}
    ${output} =  DU Establish TLS 1 2 connection with openssl using not CBC cipher  port=8443
    Verify tls connection is established  ${output}
    Check supported by DU TLS server cipher suites  port=443
    run_tls_cipher_check_script  port=8443  script_path=${tls_script_path}

5GC002167_FA_5GC002359_006_DU_Operator_configures_TLS12CBCCipherDisabled_parameter_from_NE_WebEM
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    Save gNB uptime
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    Verify no gNB reboot since last saved uptime
    ${output} =  DU Establish TLS 1 2 connection with openssl  port=443
    Verify tls connection is established  ${output}
    Reset gNB
    Verify param  param=tls11Enabled   expected=false
    Verify param  param=tls12CbcCipherDisabled  expected=false

5GC002167_FA_5GC002359_010_CU_TLS_connection_establishment_NE_as_TLS_server_TLSv1.1_rejected
    ${output} =  CU establish tls 1 1 connection with openssl  port=443
    Verify tls connection is not established  ${output}
    ${output} =  CU establish tls 1 1 connection with openssl  port=8443
    Verify tls connection is not established  ${output}

5GC002167_FA_5GC002359_011_CU_TLS_connection_establishment_NE_as_TLS_server_TLSv1.2_CBC_ciphers_rejected
    ${output} =  CU Establish TLS 1 2 connection with openssl  port=443
    Verify tls connection is not established  ${output}
    ${output} =  CU Establish TLS 1 2 connection with openssl  port=8443
    Verify tls connection is not established  ${output}
    Check supported by CU TLS server cipher suites  port=443
    Check supported by CU TLS server cipher suites  port=8443

5GC002167_FB_5GC002359_008_DU_Operator_configures_sshMaxAuthAttempts_parameter_from_NE_WebEM
    Wait For Site To Be Onair
    Change ssh max auth attempts parameter  2
    Toor4nsn one step authorization with invalid password repeatedly  should_fail=True
    Serviceuser one step authorization with invalid password repeatedly  should_fail=True
    Change ssh max auth attempts parameter  100
    Toor4nsn one step password authorization
    Serviceuser one step password authorization
    Check maxauthtries  100
    Change ssh max auth attempts parameter  1  should_fail=True
    Change ssh max auth attempts parameter  101  should_fail=True
    Check maxauthtries  100

5GC002167_FB_5GC002359_013_CU_Operator_configures_sshMaxAuthAttempts_parameter_from_NE_WebEM
    CU change ssh max auth attempts parameter  2
    CU serviceuser one step authorization with invalid password repeatedly  should_fail=True
    CU change ssh max auth attempts parameter  100
    CU serviceuser one step password authorization
    CU check maxauthtries  100
    CU change ssh max auth attempts parameter  1  should_fail=True
    CU change ssh max auth attempts parameter  101  should_fail=True
    CU check maxauthtries  100

*** Keywords ***
Preconditions
    Perform commissioning on gNB to onAir state    prefix_tag=MPLANE
    DU change MPLANENW parameter  parameter=oamTls  value=forced
    du_webem.Restore vendor certificates
    openssl.Create certificate file  ${CURDIR}/../5GC001576-OA_5GC000326/emssim.pem  ${emssimp12_path}
    du_webem.Install bts certificate  path=${emssimp12_path}  certificate_password=emssim

Postconditions
    Wait For Site To Be Onair
    Teardown Logs Collectors
