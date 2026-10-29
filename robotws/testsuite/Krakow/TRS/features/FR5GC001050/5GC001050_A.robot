*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001050

Library    SSHKeywords.py
Library    testsuite.Krakow.resources.linux_accounts.python_keywords.Keywords    WITH NAME    keywords
Library    testsuite.Krakow.resources.syve_security.syve_security.SyVeSecurity    WITH NAME  security
Library    testsuite.Krakow.resources.openssl.Openssl    WITH NAME  openssl
Resource   taf/rfrl/bts/robot/gnb.robot
Library    testsuite.Krakow.resources.du_webem.du_webem_keywords.DuWebem    WITH NAME  du_webem
Resource   testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    tls_keywords.py

Test Timeout  24 hours

Force Tags    STATE_SW_UPLOADED    RAN_5G    CRT
...   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6


Suite Setup         Common Suite Setup With Commissioning
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
@{additional_allowed_alarms}  Automatic BTS Operator Certificate retrieval unsuccessful

@{tls_1_2_cipher_suites_SLI}  TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    ...    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256    TLS_DHE_RSA_WITH_AES_256_CBC_SHA    TLS_RSA_WITH_AES_256_GCM_SHA384
    ...    TLS_RSA_WITH_AES_256_CBC_SHA256    TLS_RSA_WITH_AES_256_CBC_SHA    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
    ...    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256    TLS_DHE_RSA_WITH_AES_128_CBC_SHA    TLS_RSA_WITH_AES_128_GCM_SHA256
    ...    TLS_RSA_WITH_AES_128_CBC_SHA256    TLS_RSA_WITH_AES_128_CBC_SHA   TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA

@{tls_1_2_cipher_suites_SLII}  TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    ...    TLS_DHE_RSA_WITH_AES_256_CBC_SHA256   TLS_RSA_WITH_AES_256_GCM_SHA384    TLS_RSA_WITH_AES_256_CBC_SHA256
    ...    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256    TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
    ...    TLS_RSA_WITH_AES_128_GCM_SHA256    TLS_RSA_WITH_AES_128_CBC_SHA256

@{tls_1_2_cipher_suites_SLV}    TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384    TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
    ...    TLS_DHE_RSA_WITH_AES_128_GCM_SHA256


*** Test Cases ***
5GC001050-A-05_01_cOAM BTS shall consider TLS1.2 when TLS1.1 supported is enabled
    Prepare SLI Configuration
    Check Cipher suites  TLSv1.2  ${tls_1_2_cipher_suites_SLI}

5GC001050-A-05_05_Check the TLS ciphers suit when TLS security level II
    Prepare SLII Configuration
    Check Cipher suites  TLSv1.2  ${tls_1_2_cipher_suites_SLII}

5GC001050-A-05_08_Check the TLS ciphers suit when TLS security level V
    Prepare SLV Configuration
    Check Cipher suites  TLSv1.2  ${tls_1_2_cipher_suites_SLV}

*** Keywords ***
Prepare SLI Configuration
    DU change MPLANENW parameter  parameter=oamTls  value=forced
    DU change MPLANENW parameter  parameter=tls11Enabled  value=true
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=false

Prepare SLII Configuration
    DU change MPLANENW parameter  parameter=oamTls  value=forced
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=false

Prepare SLV Configuration
    DU change MPLANENW parameter  parameter=oamTls  value=forced
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=true
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=true
