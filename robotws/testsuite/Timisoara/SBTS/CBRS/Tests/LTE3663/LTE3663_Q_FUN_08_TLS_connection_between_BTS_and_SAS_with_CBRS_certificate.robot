*** Settings ***
Documentation    Description:...........Check behaviour of BTS while using CBRS certificates${\n}
...              Scenario:              ${\n}
...              .......................1 Prepare Environment${\n}
...              .......................2 Perform SW Update${\n}
...              .......................3 Install CBRS Vendor cert with validity 30days${\n}
...              .......................4 Install CBRS Addidional with validity less than 90days${\n}
...              .......................5 Instal CBRS Vendor certs - with signature below and more than SHA256${\n}
...              Author:................karol.sadowski@nokia.com${\n}
...              Maintainer:............karol.sadowski@nokia.com${\n}

*** Keywords ***
LTE3663_Q_FUN_08_TLS_connection_between_BTS_and_SAS_with_CBRS_certificate
    [Arguments]    ${perform_update}=True

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm_1}   Create Dictionary    fault_id=61625    fault_name=CBRS Vendor Certificate is about to expire or expired    severity=Major
    &{expected_alarm_2}   Create Dictionary    fault_id=61628    fault_name=CBRS Certificate About to Expire or Expired    severity=Major
    &{expected_alarm_3}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    &{expected_alarm_4}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure  severity=Critical

    Log To Console    ${\n}${\n}========== STEP 1. Prepare test Environment ==========${\n}
    @{latestBuild}   Prepare Test Environment Cert
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    ${sas_pid}    ${sas_log}   Start SAS Process    port=4433    config=${CURDIR}/Data/SAS_Sim_Certs.conf
    Log To Console    SAS Simulator has been started - pid: ${sas_pid}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    ${\n}${\n}========== STEP 2. Perform SW update - ${perform_update} ==========${\n}
    IF    '${perform_update}' == 'True'
        Add Fault To Watchdog Ignored List
        ...    fault_id=${expected_alarm_4}[fault_id]
        ...    fault_name=${expected_alarm_4}[fault_name]
        ...    severity=${expected_alarm_4}[severity]
        Update Software    sw_package=/home/ute/Downloads/${latestBuild[0]['name']}_release_BTSSM_downloadable.zip
        ...                should_activate=true    timeout=40min    connection=RAT_1ST
        Wait Until Keyword Succeeds    30x    10s    Check Installed SW Build    targetSW=${latestBuild[0]['name']}
        Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
        Wait For All Cells To Be OnAir     wait_time=5min
        Wait For Watchdog Alarm Deactivation
        ...    fault_id=${expected_alarm_4}[fault_id]
        ...    fault_name=${expected_alarm_4}[fault_name]
        ...    severity=${expected_alarm_4}[severity]
        ...    timeout=60
        Remove Fault From Watchdog Ignored List
        ...    fault_id=${expected_alarm_4}[fault_id]
        ...    fault_name=${expected_alarm_4}[fault_name]
        ...    severity=${expected_alarm_4}[severity]
    END

    Log To Console    ${\n}${\n}========== STEP 3. Install expired CBRS certs ==========${\n}
    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_expired_${alias}.pem    validity_days=${30}
    Add Fault To Watchdog Ignored List
    ...    fault_id=${expected_alarm_1}[fault_id]
    ...    fault_name=${expected_alarm_1}[fault_name]
    ...    severity=${expected_alarm_1}[severity]
    Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_expired
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_expired_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    Wait For Watchdog Alarm Activation
    ...    fault_id=${expected_alarm_1}[fault_id]
    ...    fault_name=${expected_alarm_1}[fault_name]
    ...    severity=${expected_alarm_1}[severity]
    ...    timeout=60
    All Cells Should Be Enabled And Onair

    Create Signing CA    ca_name=CBRS_CA_EXPIRED    validity_days=${30}
    Add Fault To Watchdog Ignored List
    ...    fault_id=${expected_alarm_2}[fault_id]
    ...    fault_name=${expected_alarm_2}[fault_name]
    ...    severity=${expected_alarm_2}[severity]
    Install CBRS Additional CA Certificate    cert=CBRS_CA_EXPIRED
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_expired_${alias}    ca_cert_name=signing-ca
    ...                                         root_ca_name=root-ca    additional_cert_name=CBRS_CA_EXPIRED
    Wait For Watchdog Alarm Activation
    ...    fault_id=${expected_alarm_2}[fault_id]
    ...    fault_name=${expected_alarm_2}[fault_name]
    ...    severity=${expected_alarm_2}[severity]
    ...    timeout=60
    All Cells Should Be Enabled And Onair

    Remove CBRS Additional CA Certificate    cert=CBRS_CA_EXPIRED
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_expired_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    Wait For Watchdog Alarm Deactivation
    ...    fault_id=${expected_alarm_2}[fault_id]
    ...    fault_name=${expected_alarm_2}[fault_name]
    ...    severity=${expected_alarm_2}[severity]
    ...    timeout=60
    Remove Fault From Watchdog Ignored List
    ...    fault_id=${expected_alarm_2}[fault_id]
    ...    fault_name=${expected_alarm_2}[fault_name]
    ...    severity=${expected_alarm_2}[severity]

    Log To Console    ${\n}${\n}========== STEP 4. Try to install invalid CBRS cert chain ==========${\n}
    Create Signing CA    ca_name=CBRS_CA_2
    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_for_step_4_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_for_step_4_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_for_step_4_${alias}.pem
    ${output}   Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_for_invalid_chain    signing_ca_name=CBRS_CA_2
    ...                                        continue_on_fail=${True}    vendor_chain_name=step_4_invalid_chain
    Should Contain Match    list=${output}    pattern=*Invalid trust chain*
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_expired_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    All Cells Should Be Enabled And Onair

    Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_for_step_4    vendor_chain_name=step_4_valid_chain
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_for_step_4_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]
    All Cells Should Be Enabled And Onair

    Log To Console    ${\n}${\n}========== STEP 5. Install CBRS certs with different signature algorithm ==========${\n}
    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_for_sha_1_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_for_sha_1_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_sha_1_${alias}.pem    signature=sha1
    ${output}   Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_sha_1    continue_on_fail=${True}    vendor_chain_name=sha_1_chain
    Should Contain Match    list=${output}    pattern=*Unsupported/weak signature algorithm*
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_for_step_4_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    All Cells Should Be Enabled And Onair

    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_for_sha_224_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_for_sha_224_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_sha_224_${alias}.pem    signature=sha224
    ${output}   Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_sha_224    continue_on_fail=${True}    vendor_chain_name=sha_224_chain
    Should Contain Match    list=${output}    pattern=*Unsupported/weak signature algorithm*
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_for_step_4_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    All Cells Should Be Enabled And Onair

    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_for_sha_256_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_for_sha_256_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_sha_256_${alias}.pem    signature=sha256
    Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_sha_256    vendor_chain_name=sha_256_chain
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_sha_256_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    All Cells Should Be Enabled And Onair

    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_for_sha_384_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_for_sha_384_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_sha_384_${alias}.pem    signature=sha384
    Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_sha_384    vendor_chain_name=sha_384_chain
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_sha_384_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    All Cells Should Be Enabled And Onair

    taf.sbts.oam.coam.admin.Generate Csr    cert_file=/home/ute/Downloads/csr_for_sha_512_${alias}.pem   timeout=180    connection=${alias}
    Sign Certificate Signing Request Using Signing CA    csr_location=/home/ute/Downloads/    csr_filename=csr_for_sha_512_${alias}.pem
    ...                                                  cert_filename=BTS_Vendor_sha_512_${alias}.pem    signature=sha512
    Install CBRS Vendor Chain    vendor_cert_name=BTS_Vendor_sha_512    vendor_chain_name=sha_512_chain
    Check If CBRS Certificates Are Installed    vendor_cert_name=BTS_Vendor_sha_512_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    All Cells Should Be Enabled And Onair

    Get SAS Logs To Logs Dir    name=SAS_Sim_steps_1_to_5     alias=default
    Stop Watchdog Alarm Detection And Check For Failures
    Kill All SAS Processes
    Disable CBRS Feature On eNB

    Log To Console    ${\n}${\n}========== STEP 6. Start SAS with ECDSA cert on tls 1.2 ==========${\n}
    Log To Console    Preparing new SAS instance with ECDSA certificate..
    Prepare And Install Certificates on SASSim    cert_type=ECDSA
    Prepare SAS Files
    Add Fault To Watchdog Ignored List
    ...    fault_id=${expected_alarm_3}[fault_id]
    ...    fault_name=${expected_alarm_3}[fault_name]
    ...    severity=${expected_alarm_3}[severity]
    Start Watchdog Alarm Detection    check_faults=${False}
    Enable CBRS Feature On eNB
    Log To Console    Starting SAS
    Start SAS Sim With Custom Certificates
    Sleep And Display Progress    60    s
    ${SAS_output}   OperatingSystem.Get File    /home/ute/SASSim/default/SAS_Sim.log
    Should Contain    ${SAS_output}    SSL error: [('SSL routines', '', 'no shared cipher')], closing connection
    Log To Console    Logs checked tls1.2 connection with ECDSA certificate not established, OK!

    Log To Console    ${\n}${\n}========== STEP 7. Enabling TLS 1.3 on BTS to connect with SAS with ECDSA cert ==========${\n}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${enb_id}/MNL-1/MNLENT-1/MPLANENW-1
           ...    parameter=actEnableTLSv13
           ...    operation=update
           ...    value=true
           ...    connection=${alias}
    Wait For Watchdog Alarm Deactivation
    ...    fault_id=${expected_alarm_3}[fault_id]
    ...    fault_name=${expected_alarm_3}[fault_name]
    ...    severity=${expected_alarm_3}[severity]
    ...    timeout=60
    Remove Fault From Watchdog Ignored List
    ...    fault_id=${expected_alarm_3}[fault_id]
    ...    fault_name=${expected_alarm_3}[fault_name]
    ...    severity=${expected_alarm_3}[severity]
    Log To Console    Checking if cells go onAir..     no_newline=true
    Wait For All Cells To Be OnAir
    Log To Console    OK!
    Log To Console    Check if cells will be operational for the next 5min
    ${progress}   Set Variable   ${0}
    FOR    ${i}    IN RANGE    1    300
        IF    ${i} % ${10} == 0
            ${progress}   Evaluate   ${progress}+1
            ${separator}   Evaluate   10-${progress}
            ${bar}   Evaluate    "<|" + ${progress}*"#" + ${separator}*"-" + "|>"
            Log To Console    \r${bar}   no_newline=true
        END
        Sleep    3s
        All Cells Should Be Enabled And Onair
    END

    Log To Console    DONE!${\n}

    [Teardown]    Run Keywords
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Get SAS Logs To Logs Dir    name=SAS_Sim_teardown    alias=default    AND
    ...    Log To Console    Cleanup after using ECDSA certificates on SAS...    AND
    ...    Prepare And Install Certificates on SASSim    cert_type=RSA    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${enb_id}/MNL-1/MNLENT-1/MPLANENW-1
           ...    parameter=actEnableTLSv13
           ...    operation=update
           ...    value=false
           ...    connection=${alias}

Prepare Test Environment Cert
    [Documentation]    Prepare and install nescesary certificates for SAS and ENB to establish connection ENB<>SAS.
    ...                As return kw provides list containing newest and second newest build data fetched from cloud-ute.
    [Arguments]    ${alias}=RAT_1ST

    Setup Google Chrome And Chrome Driver Version
    Set Screenshot Directory    ${TEST_LOGS_DIR_PATH}/ScreenShots/

    @{latestBuild}   Get Latest ENB Build
    ${swInfo}   Wait Until Keyword Succeeds    8x    15s     Get Software Info    alias=${alias}
    ${swBuild}   Get From Dictionary    ${swInfo}    Active SW version
    ${trunk}   Replace String Using Regexp    ${swBuild}    SBTS.{2,5}_ENB    SBTS00_ENB
    ${swBuild}   Set Variable If    '${IS_TRUNK}'=='True'    ${trunk}    ${swBuild}

    Log To Console    - Installed Build..........${swBuild}
    Log To Console    - Newest Build.............${latestBuild[0]['name']}
    Log To Console    - Second Newest Build......${latestBuild[1]['name']}

    ${command}   Set Variable
    ...    agent_gve_common init -b ${latestBuild[1]['name']} -l ${testlines.${testline_id}.testline_type} -s configured -o ${TEST_LOGS_DIR_PATH}
    IF  '${latestBuild[0]['name']}' == '${swBuild}'
        Log To Console  ${\n}Newest SW installed on BTS - CAN'T UPGRADE,${\n}starting downgrade to: ${latestBuild[1]['name']}
        Run  pip install agent_gve_common
        Start Process  ${command}  shell=true
    ELSE
        Log To Console  ${\n}Newest SW available - upgrade possible, continue...
    END

    Log To Console    Downloading newest build file - ${latestBuild[0]['name']}.zip
    ${downloadUrl}   Set Variable
    ...    http://files.ute.nsn-rdnet.net/builds/enb/base/${latestBuild[0]['name']}/${latestBuild[0]['name']}_release_BTSSM_downloadable.zip

    ${chrome_params}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method    ${chrome_params}    add_argument    --no-sandbox
    Call Method    ${chrome_params}    add_argument    --headless
    Call Method    ${chrome_params}    add_argument    --disable-extensions
    Call Method    ${chrome_params}    add_argument    --disable-gpu
    Call Method    ${chrome_params}    add_argument    --ignore-certificate-errors
    &{pefs}   Create Dictionary    download.default_directory    /home/ute/Downloads
    Call Method    ${chrome_params}    add_experimental_option    prefs    ${pefs}
    Create Webdriver    Chrome    chrome_options=${chrome_params}

    Maximize Browser Window
    Go To  ${downloadUrl}

    Log To Console    Preparing additional files...
    Kill All SAS Processes

    Wait Until Created    /home/ute/Downloads/${latestBuild[0]['name']}_release_BTSSM_downloadable.zip    timeout=20min
    Close All Browsers
    Log To Console    ${latestBuild[0]['name']}.zip file downloaded!

    ${check}   Run Keyword And Return Status    Is Process Running    #Check if Agent gve is running
    IF  '${check}'=='True'
        Log To Console  Waiting for agent_gve_common init...
        Wait For Process
    END

    Log To Console    Changing parameters in BTS configuration...
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1
           ...    parameter=supportedSpectrumV2
           ...    operation=update
           ...    value=1073741823
           ...    connection=${alias}

    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
           ...    parameter=connectToSasMode
           ...    operation=update
           ...    value=direct connect to SAS server
           ...    connection=${alias}

    Log To Console    Environment preparation COMPLETE!

    RETURN    @{latestBuild}

Get Latest ENB Build
    [Documentation]    Fetch newest and second newest build data from cloud-ute. KW uses external python script.

    Run    pip3 install ute_cloud_manager_api
    ${dir}   Set Variable    ${TEST_LOGS_DIR_PATH}/AdditionalFiles
    Create Directory    ${dir}

    ${content}   OperatingSystem.Get File    ${CURDIR}/../../Resources/Scripts/GetLatestBuildsFromCloud.py
    Create File    ${dir}/script.py    ${content}
    Run    chmod +x ${dir}/script.py

    ${token}   Set Variable    b544df0b1ec8264cbde2f0a57e80984cf0e91f0f

    ${branch}   Set Variable If    ${IS_TRUNK} == True    SBTS00    ${SOFTWARE_VERSION}

    ${output}   Run    python3 ${dir}/script.py ${token} ${branch} 2
    ${builds}   Get Regexp Matches    ${output}    (\\[output_start]\\\n)(.*)(\\\n\\[output_end])    2

    ${build_name}   Get Regexp Matches
    ...    ${builds[0]}    (SBTS.{2,4}_ENB_\\d+_\\d+_\\d+)
    ${buildAddDate}   Get Regexp Matches
    ...    ${builds[0]}    (\\d{4}-\\d{2}-\\d{2})(.)(\\d{2}:\\d{2}:\\d{2})    1
    ${buildAddTime}   Get Regexp Matches
    ...    ${builds[0]}    (\\d{4}-\\d{2}-\\d{2})(.)(\\d{2}:\\d{2}:\\d{2})    3
    ${buildHardware}   Get Regexp Matches
    ...    ${builds[0]}    ('supported_hardware')(.{1,3})(\\[.*?])    3
    ${buildActivate}   Get Regexp Matches
    ...    ${builds[0]}    ('active')(.{1,3})(')(.{4,5})(')    4
    ${buildPromotion}   Get Regexp Matches
    ...    ${builds[0]}    ('promotion')(..)(.*?(?=}))    3

    ${index}   Set Variable    0
    @{latestBuildList}   Create List
    FOR    ${i}    IN    @{build_name}
        &{dict}   Create Dictionary
        ...    name=${buildName[${index}]}
        ...    addDate=${buildAddDate[${index}]}
        ...    addTime=${buildAddTime[${index}]}
        ...    hardware=${buildHardware[${index}]}
        ...    activate=${buildActivate[${index}]}
        ...    promotion=${buildPromotion[${index}]}

        Append To List    ${latestBuildList}    ${dict}
        ${index}   Evaluate    ${index} + 1
    END

    RETURN    @{latestBuildList}
