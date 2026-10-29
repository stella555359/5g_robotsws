*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB005999-A feature.

Resource        ../../../common_resources/netact/netact_operations.robot
Resource        ../../../common_resources/connections/connections.robot


*** Variables ***
${CERT_PRESHARED_KEY}   fnAR-zMMi-4pVz-mwrG
${CA_REFERENCE_NUMBER}  5330
&{server_types}         ECDSA=/rom/trs_data/active/keystorage/pskRefEcdsa.txt  RSA=/rom/trs_data/active/keystorage/pskRef.txt
${login}                toor4nsn
${password}             oZPS0POrRieRtu


*** Keywords ***
Check if file contains valid data
    [Arguments]  ${server_type}
    ${connection}=       Connect with SSH    192.168.255.129  ${login}  ${password}  conn
    Log                  Checking file ${server_types}[${server_type}]  console=True
    ${key}=              Execute  head -n 1 ${server_types}[${server_type}]  conn
    ${ref_number}=       Execute  tail -n 1 ${server_types}[${server_type}]  conn
    Log                  ${key}  console=true
    Log                  ${ref_number}  console=true
    Should Match Regexp  ${key}  ${CERT_PRESHARED_KEY}
    Should Match Regexp  ${ref_number}  ${CA_REFERENCE_NUMBER}
    [Teardown]  Disconnect SSH Session  conn
