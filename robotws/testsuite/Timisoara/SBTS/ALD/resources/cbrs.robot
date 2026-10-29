*** Settings ***
Resource  ./common.robot

Documentation
...  AUTHORS:       anna.niedzwiecka@nokia.com, roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  CBRS Library with keywords operating with SAS Simulator- keywords needed to perform tests on TL:101001 (testline with AEQM)
...  ******************
...  History of changes
...  ******************
...  25.06.2024     https://jiradc.ext.net.nokia.com/browse/TAW-588 - adaptation of new configuration for automatic tests (AEQM)
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}=  True
${SHOULD_ACTIVATE}=  True


*** Keywords ***
Prepare And Install Certificates on SASSim
    [Documentation]  Description:           Prepares workspaces, databases and a simple PKI certification chain${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     07-05-2024 made by piotr.lukaszewicz@nokia.com${\n}
    [Arguments]      ${sassim_dir}=/home/ute/SASSimRepo/uri/test/py/tools/SASSim

    Log To Console    ${\n}Starting Certificate installation for SASSim...${SPACE}    no_newline=${True}
    Create Certificate Signing Request For Host
    Sign Certificate Signing Request Using Signing CA    csr_location=${openssl['sassim_cert_files_dir']}    csr_filename=sassim.csr
    ...                                                  cert_location=${openssl['sassim_cert_files_dir']}    cert_filename=sassim.pem
    Apply Generated Certificates To SASSimulator    sassim_dir=${sassim_dir}
    Log To Console    Done!


Create Certificate Signing Request For Host
    [Documentation]  Description:           creates CSR for the hosting machine${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     17-01-2024 made by lukasz.lechowicz@nokia.com${\n}

    ${csr_command}    Catenate    SEPARATOR=${SPACE}
    ...                            openssl req -new -newkey rsa:2048 -nodes
    ...                            -out ${openssl['sassim_cert_files_dir']}/sassim.csr
    ...                            -keyout ${openssl['sassim_cert_files_dir']}/nokia04.key
    ...                            -subj "/C=US/DC=com/DC=Nokia/CN=Test_SASSim_cert"
    ${rc}    ${output}    Run And Return Rc And Output    ${csr_command}


Get SAS Gerrit Repository
    [Documentation]    Download latest version of repository where SASSim is stored
    [Arguments]    ${dir}=/home/ute/SASSimRepo    #Target location to save donwloaded files

    OperatingSystem.Remove Directory    ${dir}    recursive=True
    OperatingSystem.Create Directory    ${dir}

    Run    cd ${dir}; git init 2>&1 | tee prepare_repo.log
    Run    cd ${dir}; git remote add origin ssh://gerrit.ext.net.nokia.com:29418/MN/OAM/APIGW/sysadapt 2>&1 | tee prepare_repo.log
    Run    cd ${dir}; git -c core.sshCommand="ssh -i ~/.ssh/id_rsa -o 'StrictHostKeyChecking no'" pull origin master 2>&1 | tee prepare_repo.log

    OperatingSystem.Wait Until Created    path=${dir}/uri/test/py/tools/SASSim/nokia04.cert
    OperatingSystem.Wait Until Created    path=${dir}/uri/test/py/tools/SASSim/nokia04.key
    OperatingSystem.Wait Until Created    path=${dir}/uri/test/py/tools/SASSim/ca.cert


Sign Certificate Signing Request Using Signing CA
    [Documentation]  Description:           Sign a CSR using SigningCA${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     07-05-2024 made by piotr.lukaszewicz@nokia.com${\n}
    [Arguments]      ${csr_location}=/home/ute/Downloads/
    ...              ${csr_filename}=csr.pem
    ...              ${cert_location}=${openssl['certificate_files_dir']}
    ...              ${cert_filename}=BTS_Vendor.pem
    ...              ${validity_days}=730
    ...              ${signature}=sha512

    ${sign_command}    Catenate    SEPARATOR=${SPACE}
    ...                             openssl ca -config ${openssl['config_files_dir']}/signing-ca.conf
    ...                             -in ${csr_location}/${csr_filename} -out ${cert_location}/${cert_filename}
    ...                             -days ${validity_days} -md ${signature} -extensions server_ext -passin pass:test -batch -notext
    ${rc}    ${output}    Run And Return Rc And Output    ${sign_command}


Apply Generated Certificates To SASSimulator
    [Documentation]  Description:           Copies generated .pem certificate together with TA, CA and key file to apropriate directories${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     17-01-2024 made by lukasz.lechowicz@nokia.com${\n}
    [Arguments]      ${sassim_dir}=/home/ute/SASSim/default

    ${catenate_chain_command}    Catenate    SEPARATOR=${SPACE}
    ...                            cat ${openssl['sassim_cert_files_dir']}/sassim.pem
    ...                            ${openssl['CA_dir']}/signing-ca.pem > ${openssl['sassim_cert_files_dir']}/nokia04.cert;
    ...                            cp ${openssl['CA_dir']}/root-ca.pem ${openssl['sassim_cert_files_dir']}/ca.cert

    ${copy_files_command}    Catenate    SEPARATOR=${SPACE}
    ...                       cp ${openssl['sassim_cert_files_dir']}/nokia04.cert ${sassim_dir};
    ...                       cp ${openssl['sassim_cert_files_dir']}/ca.cert ${sassim_dir};
    ...                       cp ${openssl['sassim_cert_files_dir']}/nokia04.key ${sassim_dir};

    ${rc}    ${output}    Run And Return Rc And Output    ${catenate_chain_command}
    ${rc}    ${output}    Run And Return Rc And Output    ${copy_files_command}


Setup OpenSSL Certifier
    [Documentation]  Description:           Prepares workspaces, databases and a simple PKI certification chain${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     07-05-2024 made by piotr.lukaszewicz@nokia.com${\n}
    [Arguments]      ${target_dir}=/home/ute

    Log To Console    ${\n}OpenSSL workspace preparation in progress...${SPACE}    no_newline=${True}
    ${openSSL}    Create OpenSSL Workspace
    ${is_folder_created}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_dir}/openSSL
    IF   ${is_folder_created}    OperatingSystem.Remove Directory    path=${target_dir}/openSSL    recursive=${True}
    Copy Directory    ${CURDIR}/openSSL    ${target_dir}
    OperatingSystem.Directory Should Exist    ${target_dir}/openSSL
    Log To Console    Done!


Prepare And Install CBRS Certificates on BTS
    [Documentation]  Description:           Prepares workspaces, databases and a simple PKI certification chain${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     07-05-2024 made by piotr.lukaszewicz@nokia.com${\n}
    [Arguments]      ${alias}=RAT_1ST


    Log To Console    ${\n}Certificate Preparation and Installation in progress for ${alias}...${SPACE}    no_newline=${True}
    admin.Generate Csr    cert_file=/home/ute/Downloads/csr_${alias}.pem   timeout=180    connection=${alias}
    Log To Console    Done!
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/
    ...                                                  csr_filename=csr_${alias}.pem
    ...                                                  cert_location=${openssl['certificate_files_dir']}
    ...                                                  cert_filename=BTS_Vendor_${alias}.pem
    Log To Console    Starting Vendor Chain installation on ${alias}...${SPACE}    no_newline=${True}
    Install CBRS Vendor Chain    alias=${alias}
    Log To Console    Done!


Install CBRS Vendor Chain
    [Documentation]  Description:           catenates vendor chain into single file and installs it on BTS
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     07-05-2024 made by piotr.lukaszewicz@nokia.com${\n}
    [Arguments]      ${vendor_cert_name}=BTS_Vendor
    ...              ${signing_ca_name}=signing-ca
    ...              ${root_ca_name}=root-ca
    ...              ${vendor_chain_name}=vendor_chain
    ...              ${alias}=RAT_1ST
    ...              ${continue_on_fail}=${False}    # If true KW won't fail after unsuccessful cert instalation

    ${catenate_chain_command}    Catenate    SEPARATOR=${SPACE}
    ...                       cat ${openssl['certificate_files_dir']}/${vendor_cert_name}_${alias}.pem
    ...                       ${openssl['CA_dir']}/${signing_ca_name}.pem
    ...                       ${openssl['CA_dir']}/${root_ca_name}.pem > ${openssl['certificate_files_dir']}/${vendor_chain_name}_${alias}.pem
    ${rc}    ${output}    Run And Return Rc And Output    ${catenate_chain_command}
    ${output}    Run Keyword And Ignore Error    admin.Install Certificate
    ...                                           cert_file=${openssl['certificate_files_dir']}/${vendor_chain_name}_${alias}.pem
    ...                                           cert_type=CBRSVendorChain
    ...                                           cert_format=PEM
    ...                                           timeout=60
    ...                                           connection=${alias}

    IF  not ${continue_on_fail} and '${output[0]}'=='FAIL'    Fail    msg=Cert chain installation failed!\n${output[1]}

    RETURN  ${output}


Start SAS Process
    [Documentation]  Description:           Prepare and run fresh instance of SAS Simulator      ${\n}
    ...              Return:                Process Id & logs dir                                ${\n}
    ...              Output:                { ${int}, ${string} }                                ${\n}
    ...              Author:                michal.kosicki@nokia.com                             ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    ...              Last Modification:     05-12-2023 made by karol.sadowski@nokia.com          ${\n}
    [Arguments]      ${alias}=default       # SAS alias: by default it will be crated in /home/ute/SASSim/default
    ...              ${port}=4433           # IP port
    ...              ${config}=None         # SASSim.conf file if not provided than default one will be created
    ...              ${version}=2.0         # SAS version 2.0 or 1.2 or 1.0 only
    ...              ${repository}=/home/ute/SASSimRepo    # dir where SAS repo is stored

    Prepare SAS Files    ${alias}    ${port}    ${config}    ${version}    ${repository}
    ${handle}    Start Process    python3    /home/ute/SASSim/${alias}/SAS_Sim.py
    ${pid}    Get Process Id    ${handle}
    ${logs_path}    Set Variable    /home/ute/SASSim/${alias}/SAS_Sim.log

    RETURN    ${pid}    ${logs_path}


Prepare SAS Files
    [Documentation]  Description:           Prepare fresh SAS files with specific configuration.${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                pawel.rokicki@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     17-02-2022 made by karol.sadowski@nokia.com${\n}
    [Arguments]      ${alias}=default       # SAS alias: by default it will be crated in /home/ute/SASSim/default
    ...              ${port}=4433           # IP port
    ...              ${config}=None         # SASSim.conf file if not provided than default one will be created
    ...              ${version}=2.0         # SAS version 2.0 or 1.2 or 1.0 only
    ...              ${repository}=/home/ute/SASSimRepo    # dir where SAS repo is stored

    ${is_repo_present}    Run Keyword And Return Status     OperatingSystem.Directory Should Exist    ${repository}
    IF  not ${is_repo_present}    Get SAS Gerrit Repository

    Run    rm -r /home/ute/SASSim/${alias}
    Run    mkdir /home/ute/SASSim
    Run    cp -r ${repository}/uri/test/py/tools/SASSim/ /home/ute/SASSim/${alias}

    IF  '${config}' == 'None'
        Prepare Default SAS Config    ${alias}    ${port}    ${version}
    ELSE
        Prepare Custom SAS Config    ${alias}    ${port}    ${config}
    END
    ${sas_manager}    OperatingSystem.Get File    /home/ute/SASSim/${alias}/SAS_Manager.py
    ${sas_manager}    Replace String    ${sas_manager}    server_port = 443    server_port = ${port}
    Create File    /home/ute/SASSim/${alias}/SAS_Manager.py    ${sas_manager}
    Unblock SAS In Iptables


Prepare Default SAS Config
    [Arguments]    ${alias}    ${port}    ${version}
    [Documentation]    Author: michal.kosicki@nokia.com
    ...                Maintainer: Michal Kosicki

    ${sas_config}    OperatingSystem.Get File    ${CURDIR}/Configuration/SAS_Sim.conf
    ${sas_config}    Replace String    ${sas_config}    {port}    ${port}
    ${sas_config}    Replace String    ${sas_config}    {alias}    ${alias}
    ${sas_config}    Replace String    ${sas_config}
    ...    ts_version = v2.0
    ...    ts_version = v${version}
    Create File    /home/ute/SASSim/${alias}/SAS_Sim.conf    ${sas_config}


Prepare Custom SAS Config
    [Arguments]    ${alias}    ${port}    ${config}
    [Documentation]    Author: michal.kosicki@nokia.com
    ...                Maintainer: Michal Kosicki

    ${sas_config}    OperatingSystem.Get File    ${config}
    ${sas_config}    Replace String    ${sas_config}    {port}    ${port}
    ${sas_config}    Replace String    ${sas_config}    {alias}    ${alias}
    Create File    /home/ute/SASSim/${alias}/SAS_Sim.conf    ${sas_config}


Unblock SAS In Iptables
    [Documentation]    Author: michal.kosicki@nokia.com
    ...                Maintainer: Michal Kosicki

    Run    sudo iptables -F
    Run    sudo iptables -X
    Run    sudo iptables-save

Create OpenSSL Workspace
    [Documentation]  Description:           Creates set of directories for openSSL usage${\n}
    ...              Return:                none${\n}
    ...              Output:                {}${\n}
    ...              Author:                lukasz.lechowicz@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    ...              Last Modification:     17-01-2024 made by lukasz.lechowicz@nokia.com${\n}
    [Arguments]      ${dir}=/home/ute    #root directory

    ${openssl}    Create Dictionary
    Set To Dictionary    ${openssl}    openSSL_dir=${dir}/openSSL
    Set To Dictionary    ${openssl}    CA_dir=${openssl['openSSL_dir']}/ca
    Set To Dictionary    ${openssl}    rootCA_dir=${openssl['CA_dir']}/root-ca
    Set To Dictionary    ${openssl}    db_rootCA_dir=${openssl['rootCA_dir']}/db
    Set To Dictionary    ${openssl}    private_rootCA_dir=${openssl['rootCA_dir']}/private
    Set To Dictionary    ${openssl}    signingCA_dir=${openssl['CA_dir']}/signing-ca
    Set To Dictionary    ${openssl}    db_signingCA_dir=${openssl['signingCA_dir']}/db
    Set To Dictionary    ${openssl}    private_signingCA_dir=${openssl['signingCA_dir']}/private
    Set To Dictionary    ${openssl}    CRL_dir=${openssl['openSSL_dir']}/crl
    Set To Dictionary    ${openssl}    config_files_dir=${openssl['openSSL_dir']}/config
    Set To Dictionary    ${openssl}    certificate_files_dir=${openssl['openSSL_dir']}/certs
    Set To Dictionary    ${openssl}    sassim_cert_files_dir=${openssl['certificate_files_dir']}/sassim

    Set Suite Variable    ${openssl}

    RETURN    ${openssl}
