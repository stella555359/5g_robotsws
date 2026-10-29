*** Settings ***
Resource   Common.robot

*** Variables ***
${vault_ip}   10.93.130.149
${vault_username}   root
${vault_password}   Salasana1!
${cert_password}   123456
${CERT_CHAIN_ISSUING_CA_FILE}   ${CURDIR}/../Certificate/raw_cert_chain_issuing_ca.txt

*** Keywords ***
# Generate Certificate In Vault Machine
#     csn.Connect To   hostname=${vault_ip}   username=${vault_username}   password=${vault_password}   alias=VaultMachine
#     csn.Execute
#     ...   command=cd /root/SYVE_VAULT; vault write pki/issue/ne-syve common_name="${MO_NAME}" ip_sans="${WEBUI_ADDR}" > ne_${BTS_ID}_raw_cert_chain
#     ...   connection=VaultMachine
#     csn.Send Command   command=cd /root/SYVE_VAULT; ./convert_to_p12.sh ne_${BTS_ID}_raw_cert_chain   connection=VaultMachine
#     Sleep   3s
#     csn.Write Input   data=${cert_password}\n   connection=VaultMachine
#     Sleep   3s
#     csn.Write Input   data=${cert_password}\n   connection=VaultMachine
#     Sleep   3s
#     csn.Download File
#     ...   remote_path=/root/SYVE_VAULT/ne_${BTS_ID}_raw_cert_chain_issuing_ca.txt
#     ...   local_path=${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain_issuing_ca.txt
#     ...   connection=VaultMachine
#     csn.Download File
#     ...   remote_path=/root/SYVE_VAULT/ne_${BTS_ID}_raw_cert_chain.p12
#     ...   local_path=${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain.p12
#     ...   connection=VaultMachine
#     Set Suite Variable   ${CERT_CHAIN_FILE}   ${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain.p12
#     Set Suite Variable   ${CERT_CHAIN_ISSUING_CA_FILE}   ${OUTPUT_DIR}/ne_${BTS_ID}_raw_cert_chain_issuing_ca.txt
#     Set Suite Variable   ${AdditionalCA_FILE}   ${CURDIR}/../Certificate/${NOM_NAME}.pem
#     OperatingSystem.File Should Not Be Empty   path=${CERT_CHAIN_FILE}
#     OperatingSystem.File Should Not Be Empty   path=${CERT_CHAIN_ISSUING_CA_FILE}
#     OperatingSystem.File Should Not Be Empty   path=${AdditionalCA_FILE}
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=VaultMachine

# Install Certificates In WEBEM
#     COAM Install Certificate   cert_file=${CERT_CHAIN_FILE}
#     Run Keyword And Ignore Error   COAM Logout
#     Sleep   10s
#     Wait Until Keyword Succeeds   30s   10s   COAM Login
#     COAM Install Certificate   cert_file=${AdditionalCA_FILE}
#     Run Keyword And Ignore Error   COAM Logout
#     Sleep   10s
#     Wait Until Keyword Succeeds   30s   10s   COAM Login

Generate Certificate In Vault Machine
    # Set Suite Variable   ${CERT_CHAIN_ISSUING_CA_FILE}   ${CURDIR}/../Certificate/${NOM_NAME}.crt
    Set Suite Variable   ${AdditionalCA_FILE}   ${CURDIR}/../Certificate/${NOM_NAME}_issuing_ca.pem
    # OperatingSystem.File Should Not Be Empty   path=${CERT_CHAIN_ISSUING_CA_FILE}
    OperatingSystem.File Should Not Be Empty   path=${AdditionalCA_FILE}

Install Certificates In WEBEM
    COAM Install Certificate   cert_file=${AdditionalCA_FILE}
    Run Keyword And Ignore Error   COAM Logout
    Sleep   10s
    Wait Until Keyword Succeeds   30s   10s   COAM Login
