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

Force Tags    STATE_SW_UPLOADED    RAN_5G_MP    CRT
...  RAN_5G_MP__WITH__21A_classicalbts__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUB

Suite Setup         Preconditions
Suite Teardown      Postconditions
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Test Cases ***
[1][1.0] 5GC001050-A_46_1226_TC1_TLSconnection1suite_SL2
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=AES256-GCM-SHA384
    ...  expected_cipher=AES256-GCM-SHA384

[1][1.0] 5GC001050-A_47_1226_TC2_TLSconnection3suites_SL2
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443
    ...  ciphers=AES256-GCM-SHA384,DHE-RSA-AES256-SHA256,AES128-GCM-SHA256  expected_cipher=DHE-RSA-AES256-SHA256

[1][1.0] 5GC001050-A_48_1226_TC3_TLSreject2suites_SL2
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443
    ...  ciphers=DHE-RSA-AES128-SHA,ECDH-ECDSA-AES128-SHA256,AES128-SHA  expected_cipher=0000

[1][1.0] 5GC001050-A_49_1226_TC4_TLS10reject_SL2
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=NULL-MD5  expected_cipher=0000

[1][1.0] 5GC001050-A_50_1227_TC1_TLS11enabledConnect1suite_SL1
    DU change MPLANENW parameter  parameter=tls11Enabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=AES256-SHA  expected_cipher=AES256-SHA

[1][1.0] 5GC001050-A_52_1228_TC1_CBCcipherDisabledTLSconnect1suite_SL4
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=DHE-RSA-AES128-GCM-SHA256
    ...  expected_cipher=DHE-RSA-AES128-GCM-SHA256

[1][1.0] 5GC001050-A_53_1228_TC2_CBCcipherDisabledTLSreject2suites_SL4
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=DHE-RSA-AES128-SHA,DHE-RSA-AES256-SHA
    ...  expected_cipher=0000

[1][1.0] 5GC001050-A_54_1229_TC1_RSAKExDisabledTLSconnect1suite_SL3
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=DHE-RSA-AES128-SHA256
    ...  expected_cipher=DHE-RSA-AES128-SHA256

[1][1.0] 5GC001050-A_55_1229_TC2_RSAKExDisabledCBCcipherDisabledTLSconnect1suite_SL5
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=DHE-RSA-AES128-GCM-SHA256
    ...  expected_cipher=DHE-RSA-AES128-GCM-SHA256

[1][1.0] 5GC001050-A_56_1229_TC3_RSAKExDisabledTLSreject1suite_SL3
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=true

    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=AES128-GCM-SHA256
    ...  expected_cipher=0000

[1][1.0] 5GC001050-A_57_1229_TC4_RSAKExDisabledCBCcipherDisabledTLSreject1suite_SL5
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=true

    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443  ciphers=AES128-GCM-SHA256
    ...  expected_cipher=0000

[1][1.0] 5GC001050-A_58_1230_TC1_TLSconnectHighestPrioSuite_SL2
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=false
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443
    ...  ciphers=AES256-GCM-SHA384,DHE-RSA-AES256-SHA256,AES128-GCM-SHA256  expected_cipher=DHE-RSA-AES256-SHA256

[1][1.0] 5GC001050-A_59-1230_TC2_CBCcipherDisabledTLSconnectHighestPrioSuite_SL4
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443
    ...  ciphers=DHE-RSA-AES128-GCM-SHA256,AES128-GCM-SHA256,DHE-RSA-AES256-SHA256
    ...  expected_cipher=DHE-RSA-AES128-GCM-SHA256

[1][1.0] 5GC001050-A_60-1230_TC3_RSAKExDisabledTLSconnectHighestPrioSuite_SL3
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=true
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443
    ...  ciphers=AES256-GCM-SHA384,DHE-RSA-AES128-GCM-SHA256,DHE-RSA-AES128-SHA256
    ...  expected_cipher=DHE-RSA-AES128-GCM-SHA256

[1][1.0] 5GC001050-A_61_1230_TC4_RSAKExDisabledCBCcipherDisabledTLSconnectHighestPrioSuite_SL5
    du_establish_and_verify_tls_1_2_connection_with_openssl  port=443
    ...  ciphers=DHE-RSA-AES128-GCM-SHA256,AES256-GCM-SHA384,DHE-RSA-AES256-GCM-SHA384
    ...  expected_cipher=DHE-RSA-AES256-GCM-SHA384

[1][1.0] 5GC001050-A_38_SSH_authentication_password_based
    remove_ssh_keys  skip_parameter_relation_errors=True
    perform_ssh_connection  options=-vvv -c aes192-ctr -m hmac-sha1   fail_expected=True  expected_output=0
    perform_ssh_connection  options=-vvv -c chacha20-poly1305@openssh.com -m hmac-sha1  expected_output=1

[1][1.0] 5GC001050-A_39_SSH_authentication_key_based
    generate_toor4nsn_ssh_public_key
    Change webem keys  update  toor4nsn
    edit_ssh_config_file
    perform_ssh_connection  options=-vv -oKexAlgorithms=diffie-hellman-group14-sha1  fail_expected=True
    ...  expected_output=2
    perform_ssh_connection  options=-vv -oHostKeyAlgorithms=ecdsa-sha2-nistp521  fail_expected=True
    ...  expected_output=3
    perform_ssh_connection  options=-vv -oKexAlgorithms=ecdh-sha2-nistp256 -oHostKeyAlgorithms=ssh-ed25519
    ...  expected_output=4
    [Teardown]  Run Keywords   restore_ssh_config_file
    ...  AND  keywords.Delete delta file
    ...  AND  delete_toor4nsn_key
    ...  AND  remove_ssh_keys  skip_parameter_relation_errors=True


*** Keywords ***
Preconditions
    Common Suite Setup With Commissioning
    DU change MPLANENW parameter  parameter=tls11Enabled  value=false
    DU change MPLANENW parameter  parameter=tls12CbcCipherDisabled  value=false
    DU change MPLANENW parameter  parameter=tls12RsaKExDisabled  value=false

Postconditions
    Wait For Site To Be Onair
    Common Suite Teardown
