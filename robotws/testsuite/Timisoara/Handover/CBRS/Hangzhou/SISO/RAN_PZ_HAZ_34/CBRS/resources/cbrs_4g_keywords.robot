*** Settings ***
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin

Documentation    This resource contains KW copied from 4G CBRS.


*** Keywords ***
Get SAS Gerrit Repository
    [Documentation]  Download latest version of repository where SASSim is stored
    [Arguments]  ${dir}=/home/ute/SASSimRepo    #Target location to save donwloaded files

    OperatingSystem.Remove Directory  ${dir}  recursive=True
    OperatingSystem.Create Directory  ${dir}

    Run  cd ${dir}; git init 2>&1 | tee prepare_repo.log
    Run  cd ${dir}; git remote add origin ssh://gerrit.ext.net.nokia.com:29418/MN/OAM/APIGW/sysadapt 2>&1 | tee prepare_repo.log
    Run  cd ${dir}; git -c core.sshCommand="ssh -i ~/.ssh/id_rsa -o 'StrictHostKeyChecking no'" pull origin master 2>&1 | tee prepare_repo.log

    OperatingSystem.Wait Until Created  path=${dir}/uri/test/py/tools/SASSim/nokia04.cert
    OperatingSystem.Wait Until Created  path=${dir}/uri/test/py/tools/SASSim/nokia04.key
    OperatingSystem.Wait Until Created  path=${dir}/uri/test/py/tools/SASSim/ca.cert


Setup OpenSSL Certifier
    [Documentation]  Description:           Prepares workspaces, databases and a simple PKI certification chain${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${target_dir}=/home/ute

    Log To Console  ${\n}OpenSSL workspace preparation in progress...${SPACE}  no_newline=${True}
    ${openSSL}  Create OpenSSL Workspace
    ${is_folder_created}  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${target_dir}/openSSL
    IF  ${is_folder_created}  OperatingSystem.Remove Directory  path=${target_dir}/openSSL  recursive=${True}
    Copy Directory  ${CURDIR}/openSSL  ${target_dir}
    OperatingSystem.Directory Should Exist  ${target_dir}/openSSL
    Log To Console  Done!


Create OpenSSL Workspace
    [Documentation]  Description:           Creates set of directories for openSSL usage${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${dir}=/home/ute    #root directory

    ${openssl}  Create Dictionary
    Set To Dictionary  ${openssl}  openSSL_dir=${dir}/openSSL
    Set To Dictionary  ${openssl}  CA_dir=${openssl['openSSL_dir']}/ca
    Set To Dictionary  ${openssl}  rootCA_dir=${openssl['CA_dir']}/root-ca
    Set To Dictionary  ${openssl}  db_rootCA_dir=${openssl['rootCA_dir']}/db
    Set To Dictionary  ${openssl}  private_rootCA_dir=${openssl['rootCA_dir']}/private
    Set To Dictionary  ${openssl}  signingCA_dir=${openssl['CA_dir']}/signing-ca
    Set To Dictionary  ${openssl}  db_signingCA_dir=${openssl['signingCA_dir']}/db
    Set To Dictionary  ${openssl}  private_signingCA_dir=${openssl['signingCA_dir']}/private
    Set To Dictionary  ${openssl}  CRL_dir=${openssl['openSSL_dir']}/crl
    Set To Dictionary  ${openssl}  config_files_dir=${openssl['openSSL_dir']}/config
    Set To Dictionary  ${openssl}  certificate_files_dir=${openssl['openSSL_dir']}/certs
    Set To Dictionary  ${openssl}  sassim_cert_files_dir=${openssl['certificate_files_dir']}/sassim

    Set Suite Variable  ${openssl}

    RETURN  ${openssl}


Prepare And Install CBRS Certificates on BTS
    [Documentation]  Description:           Prepares workspaces, databases and a simple PKI certification chain${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${alias}=RAT_1ST


    Log To Console  ${\n}Certificate Preparation and Installation in progress for ${alias}...${SPACE}  no_newline=${True}
    taf.sbts.oam.coam.admin.Generate Csr  cert_file=/home/ute/Downloads/csr_${alias}.pem  timeout=180  connection=${alias}
    Log To Console  Done!
    Sign Certificate Signing Request Using Signing CA  csr_location=/home/ute/Downloads/
    ...                                                csr_filename=csr_${alias}.pem
    ...                                                cert_location=${openssl['certificate_files_dir']}
    ...                                                cert_filename=BTS_Vendor_${alias}.pem
    Log To Console  Starting Vendor Chain installation on ${alias}...${SPACE}  no_newline=${True}
    Install CBRS Vendor Chain  alias=${alias}
    Log To Console  Done!


Sign Certificate Signing Request Using Signing CA
    [Documentation]  Description:           Sign a CSR using SigningCA${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${csr_location}=/home/ute/Downloads/
    ...          ${csr_filename}=csr.pem
    ...          ${cert_location}=${openssl['certificate_files_dir']}
    ...          ${cert_filename}=BTS_Vendor.pem
    ...          ${validity_days}=730
    ...          ${signature}=sha512

    ${sign_command}  Catenate  SEPARATOR=${SPACE}
    ...  openssl ca -config ${openssl['config_files_dir']}/signing-ca.conf
    ...  -in ${csr_location}/${csr_filename} -out ${cert_location}/${cert_filename}
    ...  -days ${validity_days} -md ${signature} -extensions server_ext -passin pass:test -batch -notext
    ${rc}  ${output}  Run And Return Rc And Output  ${sign_command}


Install CBRS Vendor Chain
    [Documentation]  Description:           catenates vendor chain into single file and installs it on BTS
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${vendor_cert_name}=BTS_Vendor
    ...          ${signing_ca_name}=signing-ca
    ...          ${root_ca_name}=root-ca
    ...          ${vendor_chain_name}=vendor_chain
    ...          ${alias}=RAT_1ST
    ...          ${continue_on_fail}=${False}    # If true KW won't fail after unsuccessful cert instalation

    ${catenate_chain_command}  Catenate  SEPARATOR=${SPACE}
    ...  cat ${openssl['certificate_files_dir']}/${vendor_cert_name}_${alias}.pem
    ...  ${openssl['CA_dir']}/${signing_ca_name}.pem
    ...  ${openssl['CA_dir']}/${root_ca_name}.pem > ${openssl['certificate_files_dir']}/${vendor_chain_name}_${alias}.pem
    ${rc}  ${output}  Run And Return Rc And Output  ${catenate_chain_command}
    ${output}  Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Install Certificate
    ...  cert_file=${openssl['certificate_files_dir']}/${vendor_chain_name}_${alias}.pem
    ...  cert_type=CBRSVendorChain
    ...  cert_format=PEM
    ...  timeout=60
    ...  connection=${alias}

    IF  not ${continue_on_fail} and '${output[0]}'=='FAIL'  Fail  msg=Cert chain installation failed!\n${output[1]}

    RETURN  ${output}