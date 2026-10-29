*** Settings ***
Resource    cbrs_common_keywords.robot
Documentation    CBRS Library adding methods to operate with certificates and Insta Certifier server
...              FOR INTERNAL USE ONLY!


*** Keywords ***
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


Prepare And Install Certificates on SASSim
    [Documentation]  Description:           Prepares workspaces, databases and a simple PKI certification chain${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${sassim_dir}=/home/ute/SASSimRepo/uri/test/py/tools/SASSim  ${cert_type}=RSA

    Log To Console  ${\n}Starting Certificate installation for SASSim...${SPACE}  no_newline=${True}
    Create Certificate Signing Request For Host  cert_type=${cert_type}
    Sign Certificate Signing Request Using Signing CA  csr_location=${openssl['sassim_cert_files_dir']}  csr_filename=sassim.csr
    ...                                                cert_location=${openssl['sassim_cert_files_dir']}  cert_filename=sassim.pem
    Apply Generated Certificates To SASSimulator  sassim_dir=${sassim_dir}
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


Create Signing CA
    [Documentation]  Description:           creates signing CA for openSSL workspace purposes${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${ca_name}=signing-ca  ${validity_days}=730

    ${csr_command}  Catenate  SEPARATOR=${SPACE}
    ...  openssl req -new -config ${openssl['config_files_dir']}/signing-ca.conf
    ...  -out ${openssl['CA_dir']}/${ca_name}.csr
    ...  -keyout ${openssl['private_signingCA_dir']}/${ca_name}.key -nodes
    ${rc}  ${output}  Run And Return Rc And Output  ${csr_command}

    ${self_sign_command}  Catenate  SEPARATOR=${SPACE}
    ...  openssl ca -config ${openssl['config_files_dir']}/root-ca.conf -in ${openssl['CA_dir']}/${ca_name}.csr
    ...  -out ${openssl['CA_dir']}/${ca_name}.pem -days ${validity_days} -extensions signing_ca_ext
    ...  -passin pass:test -batch -notext
    ${rc}  ${output}  Run And Return Rc And Output  ${self_sign_command}


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


Create Certificate Signing Request For Host
    [Documentation]  Description:           creates CSR for the hosting machine${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${cert_type}=RSA

    ${csr_command_RSA}  Catenate  SEPARATOR=${SPACE}
    ...  openssl req -new -newkey rsa:2048 -nodes
    ...  -out ${openssl['sassim_cert_files_dir']}/sassim.csr
    ...  -keyout ${openssl['sassim_cert_files_dir']}/nokia04.key
    ...  -subj "/C=US/DC=com/DC=Nokia/CN=Test_SASSim_cert"
    ${csr_command_ECDSA}  Catenate  SEPARATOR=${SPACE}
    ...  openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes
    ...  -out ${openssl['sassim_cert_files_dir']}/sassim.csr
    ...  -keyout ${openssl['sassim_cert_files_dir']}/nokia04.key
    ...  -subj "/C=US/DC=com/DC=Nokia/CN=Test_SASSim_cert"

    IF  '${cert_type}'=='RSA'
        ${rc}  ${output}  Run And Return Rc And Output  ${csr_command_RSA}
    ELSE IF  '${cert_type}'=='ECDSA'
        ${rc}  ${output}  Run And Return Rc And Output  ${csr_command_ECDSA}
    ELSE
        Fail  msg=Wrong cert type! - ${cert_type} is not RSA or ECDSA
    END


Apply Generated Certificates To SASSimulator
    [Documentation]  Description:           Copies generated .pem certificate together with TA, CA and key file to apropriate directories${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]  ${sassim_dir}=/home/ute/SASSim/default

    ${catenate_chain_command}  Catenate  SEPARATOR=${SPACE}
    ...  cat ${openssl['sassim_cert_files_dir']}/sassim.pem
    ...  ${openssl['CA_dir']}/signing-ca.pem > ${openssl['sassim_cert_files_dir']}/nokia04.cert;
    ...  cp ${openssl['CA_dir']}/root-ca.pem ${openssl['sassim_cert_files_dir']}/ca.cert

    ${copy_files_command}  Catenate  SEPARATOR=${SPACE}
    ...  cp ${openssl['sassim_cert_files_dir']}/nokia04.cert ${sassim_dir};
    ...  cp ${openssl['sassim_cert_files_dir']}/ca.cert ${sassim_dir};
    ...  cp ${openssl['sassim_cert_files_dir']}/nokia04.key ${sassim_dir};

    ${rc}  ${output}  Run And Return Rc And Output  ${catenate_chain_command}
    ${rc}  ${output}  Run And Return Rc And Output  ${copy_files_command}


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


Copy OpenSSL Workspace To Suite Logs Directory
    [Documentation]  Description:           Copies OpenSSL Workspace to common logs directory
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                lukasz.lechowicz@nokia.com                           ${\n}
    ...              Maintainer:            lukasz.lechowicz@nokia.com
    [Arguments]  ${openssl_workspace}=${openssl['openSSL_dir']}

    Copy Directory  ${openssl_workspace}  ${SUITE_LOGS_DIR_PATH}
    Log to console  Copied OpenSSL Workspace from: ${openssl_workspace} ${\n}into: ${SUITE_LOGS_DIR_PATH}


Get Fingerprints For All Certificates On Bts
    [Documentation]  Read fingerprint (unique number) from all certificates on BTS.
    ...              you can pass: 1, 2, 3 or 4 certs to check (vendor/CA/TA - all types).                        ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${alias}=RAT_1ST   # Connection alias

    @{installedCertificates}  Get Certificate List  cert_type=CBRSAll  timeout=300  connection=${alias}
    @{installedCertificatesFingerprints}  Create List
    FOR  ${i}  IN  @{installedCertificates}
        Append To List  ${installedCertificatesFingerprints}  ${i['fingerPrint']}
    END

    RETURN  ${installedCertificatesFingerprints}


Get Fingerprint From Certificate File
    [Documentation]  Read fingerprint (unique number) of given cert file.                                         ${\n}
    ...              Return:                Fingerprint of given certificate                                      ${\n}
    ...              Output:                { string }                                                            ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${cert}    # Certificate name
    ...          ${location}    # Localization where cert is placed

    ${fingerprint}  Run  openssl x509 -noout -fingerprint -sha1 -inform pem -in ${location}/${cert}.pem | cut -d "=" -f 2

    RETURN  ${fingerprint}


Install CBRS Additional CA Certificate
    [Documentation]  Install given CBRS certificates as additional CA cert.                                       ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${cert}            # Additional CA cert name
    ...          ${alias}=RAT_1ST   # Connection alias

    Log To Console  Installing ${cert} certificate..  no_newline=true

    Wait Until BTS Is Not Busy
    ${output}  Install Certificate  cert_file=${openssl['CA_dir']}/${cert}.pem  cert_type=CBRSAdditionalCa  cert_format=PEM
    ...  timeout=60  connection=${alias}

    Log  ${output}  console=true


Remove CBRS Additional CA Certificate
    [Documentation]  Remove given CBRS certificate istalled on BTS as additional CA cert.                         ${\n}
    ...              Return:                none                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
     [Arguments]  ${cert}            # Additional CA cert name
    ...           ${alias}=RAT_1ST   # Connection alias

    Log To Console  Removing ${cert} certificate..${SPACE*2}  no_newline=true

    ${fingerprint}  Get Fingerprint From Certificate File  cert=${cert}  location=${openssl['CA_dir']}
    Wait Until BTS Is Not Busy
    ${output}  Delete Certificate  fingerprint=${fingerprint}  domain_type=CBRS  timeout=60  connection=${alias}

    Log  ${output}  console=true


Check If CBRS Certificates Are Installed
    [Documentation]  Check if given certificates are installed on BTS as CBRS cert. You can pass: 1, 2, 3 or 4 certs
    ...              to be checked (Vendor, CA, TA and additional cert - all types).                              ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${vendor_cert_name}                 # Vendor certificate name to be checked - mandatory
    ...          ${ca_cert_name}=${EMPTY}            # CA certificate name to be checked - optional
    ...          ${root_ca_name}=${EMPTY}            # TA certificate name to be checked - optional
    ...          ${additional_cert_name}=${EMPTY}    # additional certificate name to be checked - optional

    &{vendor_cert}  Create Dictionary  name=${vendor_cert_name}  location=${openssl['certificate_files_dir']}
    &{ca_cert}  Create Dictionary  name=${ca_cert_name}  location=${openssl['CA_dir']}
    &{root_ca}  Create Dictionary  name=${root_ca_name}  location=${openssl['CA_dir']}
    &{additional_cert}  Create Dictionary  name=${additional_cert_name}  location=${openssl['CA_dir']}
    @{certificates}  Create List  ${vendor_cert}
    IF  '${ca_cert_name}' != '${EMPTY}'  Append to list  ${certificates}  ${ca_cert}
    IF  '${root_ca_name}' != '${EMPTY}'  Append to list  ${certificates}  ${root_ca}
    IF  '${additional_cert_name}' != '${EMPTY}'  Append to list  ${certificates}  ${additional_cert}

    @{installedCertificates}  Get Fingerprints For All Certificates On Bts

    FOR  ${i}  IN  @{certificates}
        ${fingerPrint}  Get Fingerprint From Certificate File  cert=${i}[name]  location=${i}[location]
        ${check}  Run Keyword And Return Status
        ...  List Should Contain Value  ${installedCertificates}  ${fingerPrint}
        IF  ${check} == True
            Log  ${i} certificate is installed on BTS!  console=true
        ELSE
            Fail  ${i} is not installed!
        END
    END


Remove All CBRS Certificates From BTS
    [Documentation]  Remove all CBRS certificates from BTS, reset BTS and wait for reconnection.                  ${\n}
    ...              Return:                none                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${node_IP}=192.168.255.1    # IP to enb ssh connection
    ...          ${alias}=RAT_1ST            # connection alias

    Log To Console  Removing CBRS certificate chain via SSH connection on ${node_IP}..
    Log To Console  ${\n}*******************************************************************
    Log To Console  * Warning this KW may cause fid:6450 Diagnostic Files Collected!! *
    Log To Console  *******************************************************************
    Open Connection  ${node_IP}
    Login  ${credentials.enb_username}  ${credentials.enb_password}

    ${certChainPresent}  Run Keyword And Return Status
    ...  SSHLibrary.File Should Exist  /ffs/run/trs_data/active/keystorage/cbrs/vendorcerts/cbrs_vendor_bts_cert.pem

    IF  ${certChainPresent}  Execute Command  rm /ffs/run/trs_data/active/keystorage/cbrs/vendorcerts/*.pem

    Log To Console  Removing CBRS additional certificates on ${alias}..
    @{installedCertificates}  Run Keyword And Ignore Error  Get Certificate List
    ...  cert_type=CBRSAdditional  timeout=180  connection=${alias}

    FOR  ${i}  IN  @{installedCertificates[1]}
        Delete Certificate  fingerprint=${i['fingerPrint']}  domain_type=CBRS  timeout=60  connection=${alias}
    END

    IF  ${certChainPresent} or '${installedCertificates[0]}'=='PASS'
        Log  Resetting site..  console=true
        Reset Site  connection=${alias}  timeout=5min  wait_for_reconnection=True
        Log  CBRS certificates removed!  console=true
    END

    [Teardown]  Close All Connections
