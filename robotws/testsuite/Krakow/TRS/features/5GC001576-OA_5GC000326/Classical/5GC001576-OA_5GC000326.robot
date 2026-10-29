*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases 5GC001576-OA_5GC000326

Library    testsuite.Krakow.resources.linux_accounts.python_keywords.Keywords    WITH NAME    keywords
Library    testsuite.Krakow.resources.du_webem.du_webem_keywords.DuWebem    WITH NAME  du_webem
Library    testsuite.Krakow.resources.cu_webem.cu_webem_keywords.CuWebem    WITH NAME  cu_webem
Library    testsuite.Krakow.resources.openssl.Openssl    WITH NAME  openssl
Library    testsuite.Krakow.resources.fsclish.Fsclish    WITH NAME  fsclish
Resource   testsuite/Krakow/resources/RAN_PZ_KRK4/linux_hardening/connections.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6    RAN_5G   RAN_5G_MP
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUD_IPV6__WITH__CRT

Suite Setup       Common Suite Setup With Commissioning
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
${DU_issuer1}       O = Nokia Siemens Networks, CN = Factory Certification Authority
${DU_issuer2}       O = Nokia, CN = emssim.org
${CU_issuer1}       C = FI, O = Nokia, OU = RCP, CN = Default CA Cert
${CU_issuer2}       O = Nokia, CN = emssim.org
${emssimp12_path}   /home/ute/emssim.p12

*** Test Cases ***
5GC001576-OA_5GC000326_DU_Secure_WebEM_Connection
    du_webem.Restore vendor certificates
    openssl.Validate certificates used for https connection on du  ${DU_issuer1}
    openssl.Create certificate file  ${CURDIR}/../emssim.pem  ${emssimp12_path}
    du_webem.Install bts certificate  path=${emssimp12_path}  certificate_password=emssim
    openssl.Validate certificates used for https connection on du  ${DU_issuer2}
    openssl.Delete certificate file  ${emssimp12_path}
