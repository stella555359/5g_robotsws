*** Settings ***
Documentation    CBRS Library adding methods to operate with certificates and Insta Certifier server
...              FOR INTERNAL USE ONLY!


*** Keywords ***

#Setup Google Chrome And Chrome Driver Version
#    ${googleChromeVersion}    Run  google-chrome --version
#    ${googleChromeVersion}    Get Regexp Matches    ${googleChromeVersion}    (Chrome.*\\s{1})(\\d{1,3})(\\..*)    2
#    ${googleChromeVersion}    Convert To Integer    ${googleChromeVersion[0]}
#    ${googleDriverVersion}    Run  chromedriver --version
#    ${googleDriverVersion}    Get Regexp Matches    ${googleDriverVersion}    (Chrome.*\\s{1})(\\d{1,3})(\\..*)    2
#    ${googleDriverVersion}    Convert To Integer    ${googleDriverVersion[0]}
#
#    IF  "${googleChromeVersion}"!="${googleDriverVersion}"
#        Log To Console    Google Driver version incompatible! Installing ver. ${googleChromeVersion}...
#        Run    sudo apt install -y --allow-downgrades ute-chromedriver=${googleChromeVersion}
#    END
#
#    ${googleDriverVersion}    Run  chromedriver --version
#    ${googleDriverVersion}    Get Regexp Matches    ${googleDriverVersion}    (Chrome.*\\s{1})(\\d{1,3})(\\..*)    2
#    ${googleDriverVersion}    Convert To Integer    ${googleDriverVersion[0]}
#
#    IF  "${googleChromeVersion}"!="${googleDriverVersion}"  Fail    Google Driver ${googleChromeVersion} Installation Failed!
#
#    ${chrome_params}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
#    Call Method    ${chrome_params}    add_argument    --no-sandbox
#    Call Method    ${chrome_params}    add_argument    --headless
#    Call Method    ${chrome_params}    add_argument    --disable-extensions
#    Call Method    ${chrome_params}    add_argument    --disable-gpu
#    Call Method    ${chrome_params}    add_argument    --ignore-certificate-errors
#    Create Webdriver    Chrome    chrome_options=${chrome_params}
#
Open Insta Certifier
    [Documentation]  Open InstaCertifier server and login with defined credentials.  ${\n}
    ...  Return: none  ${\n}
    ...  Output: { }  ${\n}
    ...  Author: karol.sadowski@nokia.com  ${\n}
    ...  Maintainer: CBRS Team  ${\n}

    Log To Console  Opening InstaCertifier server ${instaUrl}..${SPACE*2}  no_newline=true

    ${chrome_params}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method  ${chrome_params}  add_argument  --no-sandbox
    Call Method  ${chrome_params}  add_argument  --headless
    Call Method  ${chrome_params}  add_argument  --disable-extensions
    Call Method  ${chrome_params}  add_argument  --disable-gpu
    Call Method  ${chrome_params}  add_argument  --ignore-certificate-errors
    &{pefs}  Create Dictionary  download.default_directory  /home/ute/Downloads
    Call Method  ${chrome_params}  add_experimental_option  prefs  ${pefs}
    Create Webdriver  Chrome  chrome_options=${chrome_params}

    Maximize Browser Window
    Go To  ${instaUrl}

    Capture Page Screenshot  filename=insta_login.png

    ${check}  Run Keyword And Return Status  Page Should Contain  Operator Login
    IF  ${check}
        Input Text  ${instaTxtLogin}  ${instaUsername}
        Input Text  ${instaTxtPass}  ${instaPassword}
        Click Button  ${instaBtnLogin}
    END

    Capture Page Screenshot  filename=insta_main.png
    Log  Logged successful!  console=true


Generate CSR
    [Documentation]  Generate CSR on BTS and save it to tmp file. Data from file is passed as return form this KW,
    ...              and file is removed.                                                                         ${\n}
    ...              Return:                Certificate Sign Request as string                                    ${\n}
    ...              Output:                { string }                                                            ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${alias}=RAT_1ST  # connection alias

    Log  Generating CSR for node: ${alias}..  console=true
    ${downloads}  Set Variable  /home/ute/Downloads/CSR.tmp
    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Generate Csr  cert_file=${downloads}  timeout=180  connection=${alias}
    ${csr}  OperatingSystem.Get File  ${downloads}
    OperatingSystem.Remove File  ${downloads}

    Log  CSR generated!\n\n${csr}  console=true

    RETURN  ${csr}


Generate Certificate
    [Documentation]  Generate and download certificate from given CSR and settings, file is saved in /Downloads dir.
    ...              As return KW pass cert name.                                                                 ${\n}
    ...              Return:                Certificate name as string                                            ${\n}
    ...              Output:                { string }                                                            ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${csr}                 # Certificate Sign Request
    ...          ${issuer}=CA1.1        # Certificate issuer - CA
    ...          ${validity}=1year      # Validity of new cert: 1month, [2/3/6]months, 1year, [2/3/5/10/15/20]years
    ...          ${signature}=256       # SHA coding: 1, 224, 256, 384, 512

    ${issuer}  Get From Dictionary  ${instaIssuer}  ${issuer}
    ${validity}  Get From Dictionary  ${instaValidity}  ${validity}
    ${signature}  Get From Dictionary  ${instaSignature}  ${signature}

    Open Insta Certifier
    Go To  ${instaUrl}/insert-request.html
    Input Text  ${instaTxtCSR}  ${csr}
    Click Button  ${instaBtnProceed}
    Click Button  ${instaBtnInstert}

    Select From List By Value  ${instaListIssuer}  ${issuer}
    Select From List By Value  ${instaListValidity}  ${validity}
    Click Button  ${instaBtnSet}
    Select From List By Value  ${instaListSignature}  ${signature}
    Click Button  ${instaBtnAccept}
    Go To  ${instaUrl}/find-any.html?search-object-type=certificate&reset=1
    Select Checkbox  ${instaCheckCA}
    Click Button  ${instaBtnSearch}

    Go To  ${INSTA_URL}/objectview.html?index-number=0

    ${link}  SeleniumLibrary.Get Element Attribute    ${instaBtnDownload1}    href
    ${link}  Fetch From Left    ${link}    .pem
    ${name}  Fetch From Right    ${link}    /

    ${check}  Run Keyword And Return Status    OperatingSystem.File Should Not Exist    /home/ute/Downloads/${name}.pem
    IF  ${check} == False  OperatingSystem.Remove File  /home/ute/Downloads/${name}.pem

    Click Link  ${instaBtnDownload1}

    Wait Until Created  /home/ute/Downloads/${name}.pem
    Close Browser

    Log  .pem file created successfuly!  console=true

    RETURN  ${name}


Generate And Save New Certificate With CSR
    [Documentation]  Generate new CSR and prepare certificate with given name and other settings,
    ...              certificate file and csr file are saved in subdirectory Certificates in Logs directory.      ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${name}                # Name of new certificate
    ...          ${issuer}=CA1.1        # Certificate issuer - CA
    ...          ${validity}=1year      # Validity of new cert: 1month, [2/3/6]months, 1year, [2/3/5/10/15/20]years
    ...          ${signature}=256       # SHA coding: 1, 224, 256, 384, 512
    ...          ${alias}=RAT_1ST       # connection alias

    Log  Generating ${name}.pem signatured=${issuer} SHA${signature} validity=${validity}..  console=true

    ${csr}  Generate CSR  alias=${alias}
    ${certificate}  Generate Certificate  ${csr}  ${issuer}  ${validity}  ${signature}

    Log  Saving new certificate ${TEST_LOGS_DIR_PATH}/Certificates/${name}.pem..    console=true

    OperatingSystem.Move File  /home/ute/Downloads/${certificate}.pem    ${TEST_LOGS_DIR_PATH}/Certificates/${name}.pem
    OperatingSystem.Append To File  ${TEST_LOGS_DIR_PATH}/Certificates/${name}.CSR    ${csr}

    Log  ${name}.pem certificate generated!  console=true


Install Certificate CBRS Vendor Chain
    [Documentation]  Install 3 given CBRS certificates as one certificate chain on BTS                            ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${vendor}              # Name of vendor certificate
    ...          ${ta}=CBRS_TEST_TA1    # Name of TA certificate
    ...          ${ca}=CBRS_TEST_CA1.1  # Name of CA certificate
    ...          ${alias}=RAT_1ST       # Connection alias
    ...          ${continue_on_fail}=${False}    # If true KW won't fail after unsuccessful cert instalation
    ...          ${location}=${TEST_LOGS_DIR_PATH}/Certificates    # Localization where all certs are placed

    Log To Console  Installing ${vendor}, ${ca}, ${ta} certificates..  no_newline=true

    ${val}  OperatingSystem.Get File  ${location}/${vendor}.pem
    OperatingSystem.Create File  ${location}/${vendor}_chain.pem  ${val}
    ${val}  OperatingSystem.Get File  ${location}/${ca}.pem
    OperatingSystem.Append To File  ${location}/${vendor}_chain.pem  ${val}
    ${val}  OperatingSystem.Get File  ${location}/${ta}.pem
    OperatingSystem.Append To File  ${location}/${vendor}_chain.pem  ${val}

    Wait Until BTS Is Not Busy
    ${output}  Run Keyword And Ignore Error
    ...  Install Certificate
    ...  cert_file=${location}/${vendor}_chain.pem
    ...  cert_type=CBRSVendorChain
    ...  cert_format=PEM
    ...  timeout=60
    ...  connection=${alias}

    IF  not ${continue_on_fail} and '${output[0]}'=='FAIL'  Fail  msg=Cert chain installation failed!\n${output[1]}

    Log  ${output}  console=true

    RETURN  ${output}


Install Certificate CBRS Additional CA
    [Documentation]  Install given CBRS certificates as additional TA cert.                                       ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${cert}            # Additional CA cert name
    ...          ${alias}=RAT_1ST   # Connection alias
    ...          ${location}=${TEST_LOGS_DIR_PATH}/Certificates    # Localization where cert is placed

    Log To Console  Installing ${cert} certificate..  no_newline=true

    Wait Until BTS Is Not Busy
    ${output}  Install Certificate
    ...  cert_file=${location}/${cert}.pem
    ...  cert_type=CBRSAdditionalCa
    ...  cert_format=PEM
    ...  timeout=60
    ...  connection=${alias}
    Log  ${output}  console=true


#Remove All CBRS Certificates From BTS
#    [Documentation]  Remove all CBRS certificates from BTS, reset BTS and wait for reconnection.                  ${\n}
#    ...              Return:                none                                                                  ${\n}
#    ...              Output:                { }                                                                   ${\n}
#    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
#    ...              Maintainer:            CBRS Team                                                             ${\n}
#    [Arguments]      ${node_IP}=192.168.255.1    # IP to enb ssh connection
#    ...              ${alias}=RAT_1ST            # connection alias
#
#    Log    Removing CBRS certificate chain via SSH connection on ${node_IP}..   console=true
#    Open Connection    ${node_IP}
#    Login    ${credentials.enb_username}    ${credentials.enb_password}
#
#    ${certChainPresent}=    Run Keyword And Return Status
#    ...     SSHLibrary.File Should Exist    /ffs/run/trs_data/active/keystorage/cbrs/vendorcerts/cbrs_vendor_bts_cert.pem
#
#    IF  ${certChainPresent}    Execute Command    rm /ffs/run/trs_data/active/keystorage/cbrs/vendorcerts/*.pem
#
#    Log To Console    Removing CBRS additional certificates on ${alias}..
#    @{installedCertificates}=    Run Keyword And Ignore Error    Get Certificate List
#    ...    cert_type=CBRSAdditional
#    ...    timeout=180
#    ...    connection=${alias}
#
#    FOR    ${i}    IN    @{installedCertificates[1]}
#        Delete Certificate
#        ...    fingerprint=${i['fingerPrint']}
#        ...    domain_type=CBRS
#        ...    timeout=60
#        ...    connection=${alias}
#    END
#
#    IF  ${certChainPresent} or '${installedCertificates[0]}'=='PASS'
#        Log    Resetting site..   console=true
#        Reset Site    connection=${alias}    timeout=5min    wait_for_reconnection=True
#        Log    CBRS certificates removed!   console=true
#    END
#
#    [Teardown]    Close All Connections


Get Certificate Fingerprint
    [Documentation]  Read fingerprint (unique number) of given cert file from subdirectory Certificates in Logs directory.    ${\n}
    ...              Return:                Fingerprint of given certificate                                      ${\n}
    ...              Output:                { string }                                                            ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${cert}    # Certificate name
    ...          ${location}=${TEST_LOGS_DIR_PATH}/Certificates    # Localization where cert is placed

    ${fingerprint}  Run  openssl x509 -noout -fingerprint -sha1 -inform pem -in ${location}/${cert}.pem | cut -d "=" -f 2

    RETURN  ${fingerprint}


Check If CBRS Certificate Is Installed
    [Documentation]  Check if given certificate is installed on ENB as CBRS cert,
    ...              you can pass: 1, 2, 3 or 4 certs to check (vendor/CA/TA - all types).                        ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${certificate_1}           # 1ST certificate to check name - mandatory
    ...          ${certificate_2}=${EMPTY}  # 2ND certificate to check name - optional
    ...          ${certificate_3}=${EMPTY}  # 3RD certificate to check name - optional
    ...          ${certificate_4}=${EMPTY}  # 4TH certificate to check name - optional
    ...          ${location}=${TEST_LOGS_DIR_PATH}/Certificates    # Localization where cert is placed
    ...          ${alias}=RAT_1ST   # Connection alias

    @{certificates}    Create List    ${certificate_1}
    IF  '${certificate_2}' != '${EMPTY}'  Append to list  ${certificates}  ${certificate_2}
    IF  '${certificate_3}' != '${EMPTY}'  Append to list  ${certificates}  ${certificate_3}
    IF  '${certificate_4}' != '${EMPTY}'  Append to list  ${certificates}  ${certificate_4}

    @{installedCertificates}  Get Certificate List  cert_type=CBRSAll  timeout=300  connection=${alias}
    @{installedCertificatesFingerprints}  Create List
    FOR  ${i}  IN  @{installedCertificates}
        Append To List  ${installedCertificatesFingerprints}  ${i['fingerPrint']}
    END

    FOR  ${i}  IN  @{certificates}
        ${fingerPrint}  Get Certificate Fingerprint  cert=${i}  location=${location}
        ${check}  Run Keyword And Return Status
        ...    List Should Contain Value  ${InstalledCertificatesFingerprints}  ${fingerPrint}
        IF  ${check} == True
            Log  ${i} certificate is insalled on BTS!  console=true
        ELSE
            Fail  ${i} is not installed!
        END
    END


Download TA & CA Core Certificates
    [Documentation]  Download all core certificates used in tests, save them in subdirectory Certificates in Logs directory.  ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  @{list}  # list of certificates to download from selenium file

    @{list}  Convert To List  ${list}
    Open Insta Certifier

    #TODO: Extend valitidy for CBRS_TEST_TA_EXPIRE

    FOR  ${element}  IN  @{list}
        Log To Console  Downloading ${element} certificate..  no_newline=true
        Go to  ${instaUrl}/ca_view.html
        Capture Page Screenshot  filename=insta_${element}.png
        Click Link  ${element}
        Click Button  ${instaGoToCert}
        ${check}  Run Keyword And Return Status  Page Should Contain  Approved by
        ${instaButton}  Set Variable If  ${check} == True  ${instaBtnDownload1}  ${instaBtnDownload2}
        ${link}  SeleniumLibrary.Get Element Attribute  ${instaButton}  href
        ${link}  Fetch From Left  ${link}  .pem
        ${name}  Fetch From Right  ${link}  /
        Sleep  1s
        Click Link  ${instaButton}
        Capture Page Screenshot  filename=insta_download_${element}.png
        ${check}  Run Keyword And Return Status  Wait Until Created  /home/ute/Downloads/${name}.pem
        IF  ${check} == False
            Log  ${SPACE*2}FAILED!  console=true
            Log To Console  Retrying to download ${element} certificate..  no_newline=true
            Click Link  ${instaButton}
            Wait Until Created  /home/ute/Downloads/${name}.pem
        END
        OperatingSystem.Move File  /home/ute/Downloads/${name}.pem  ${TEST_LOGS_DIR_PATH}/Certificates/${element}.pem
        Log  ${SPACE*2}Done!  console=true
    END

    [Teardown]  Close Browser


Generate SAS TA Certificate
    [Documentation]  Generate SAS certificates                                                                    ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]  ${alias}=default   # SAS alias /home/ute/SaSSim/{alias}/<SAS files>

    OperatingSystem.Create Directory  ${TEST_LOGS_DIR_PATH}/Certificates

    ${command}  Catenate  SEPARATOR=${SPACE}
    ...  openssl req -new -newkey rsa:2048 -nodes -out ${TEST_LOGS_DIR_PATH}/Certificates/SASSim.csr
    ...  -keyout ${TEST_LOGS_DIR_PATH}/Certificates/nokia04.key -subj "/DC=com/DC=CRL/CN=SASSim_$(echo $UTE_CONFIGURATION | cut -d. -f2)"
    Run  ${command}
    Log To Console  Veryfying SAS certificate...${SPACE}  no_newline=true
    Run  openssl req -text -in ${TEST_LOGS_DIR_PATH}/Certificates/SASSim.csr -noout -verify | grep -E "verify|Subject:|Algorithm"
    ${csr}  Run  cat ${TEST_LOGS_DIR_PATH}/Certificates/SASSim.csr
    ${certificateName}  Generate Certificate  ${csr}  CA1

    OperatingSystem.Copy File  ${TEST_LOGS_DIR_PATH}/Certificates/nokia04.key  /home/ute/SASSim/${alias}/nokia04.key

    ${val}  OperatingSystem.Get File  /home/ute/Downloads/${certificateName}.pem
    OperatingSystem.Append To File  ${TEST_LOGS_DIR_PATH}/Certificates/nokia04.cert    ${val}
    ${val}  OperatingSystem.Get File  ${TEST_LOGS_DIR_PATH}/Certificates/CBRS_CA1.pem
    OperatingSystem.Append To File  ${TEST_LOGS_DIR_PATH}/Certificates/nokia04.cert    ${val}
    OperatingSystem.Copy File  ${TEST_LOGS_DIR_PATH}/Certificates/nokia04.cert    /home/ute/SASSim/${alias}/nokia04.cert
    OperatingSystem.Move File  /home/ute/Downloads/${certificateName}.pem  ${TEST_LOGS_DIR_PATH}/Certificates/SASSim.pem
    ${val}  OperatingSystem.Get File  ${TEST_LOGS_DIR_PATH}/Certificates/CBRS_TA1.pem
    OperatingSystem.Append To File  ${TEST_LOGS_DIR_PATH}/Certificates/ca.cert  ${val}
    OperatingSystem.Copy File  ${TEST_LOGS_DIR_PATH}/Certificates/ca.cert  /home/ute/SASSim/${alias}/ca.cert
