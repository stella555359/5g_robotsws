*** Settings ***
Documentation    CBRS CRT Certificates - DomainProxy and Certificates functionality
...              Suite designed for common testlines CBRS_1, CBRS_5 or CBRS_6

Resource    ./../Resources/cbrs_common_keywords.robot
Resource    ./../Tests/LTE3663/LTE3663_Q_FUN_08_TLS_connection_between_BTS_and_SAS_with_CBRS_certificate.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    CRT    4G_TDD
...           STATE_CONFIGURED
...           CLOUD_RF_AIR_B4_3628_2CL1_T4_M_98_AZQC_CBRS_6
...           SBTS00

*** Test Cases ***

#Temp. added fid:6450 Diagnostic Files Collected as expected fault !!!
LTE3663-Q_FUN_08_TLS_connection_between_BTS_and_SAS_with_CBRS_certificate
    [Timeout]     90min
    [Setup]       Test Precondition    clean_bts=true
    [Teardown]    Test Postcondition
    [Tags]        LTE3663    SBTS23R4    SBTS00
    LTE3663_Q_FUN_08_TLS_connection_between_BTS_and_SAS_with_CBRS_certificate    perform_update=True


#!! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !!
CBRS_LTE3679_FeVe_01_Domain_Proxy_Activation_and_CBSD_operability_check
    [Tags]    LTE3679    SBTS23R4    SBTS00
    Log To Console    Check if TC Passed and report to QC.

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${LTE3679_FeVe_01_PASSED}
    IF  ${test_executed}==${False}  CBRS_CRT_DomainProxy_Suite

    IF  ${LTE3679_FeVe_01_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_Suite TC.

CBRS_LTE3679_FeVe_02_Domain_Proxy_Alarms_check
    [Tags]    LTE3679    SBTS23R4    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${LTE3679_FeVe_02_PASSED}
    IF  ${test_executed}==${False}    CBRS_CRT_DomainProxy_Suite

    IF  ${LTE3679_FeVe_02_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_Suite TC.

LTE5720_Verify_if_fault_6832_with_reason_NCDP_switchover_failure_is_raised_when_standby_DP_is_not_configured_during_switchover
    [Tags]    LTE3679    SBTS23R4    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${LTE5720_Verify_if_fault_6832_PASSED}
    IF  ${test_executed}==${False}  CBRS_CRT_DomainProxy_Suite

    IF  ${LTE5720_Verify_if_fault_6832_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_Suite TC.

CBRS_LTE3679_FeVe_05_Direct_connection_and_Domain_Proxy_switching
    [Tags]    LTE3679    SBTS23R4    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${LTE3679_FeVe_05_PASSED}
    IF  ${test_executed}==${False}  CBRS_CRT_DomainProxy_Suite

    IF  ${LTE3679_FeVe_05_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_Suite TC.

LTE5720_Verify_if_NCDP_changes_CBSD_status_during_switchover_fallback_to _primary_dp
    [Tags]    LTE3679    SBTS23R4    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${LTE5720_Verify_if_NCDP_PASSED}
    IF  ${test_executed}==${False}  CBRS_CRT_DomainProxy_Suite

    IF  ${LTE5720_Verify_if_NCDP_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_Suite TC.
#!! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !!


*** Keywords ***
CBRS_CRT_DomainProxy_Suite
    [Timeout]    90min

    Test Precondition    clean_bts=true
    CBRS_LTE5720_LTE3679_Verify_SAS_Connection_Via_Domain_Proxy

    [Teardown]   Run Keywords    Test Postcondition    AND
    ...    Apply CBRS Debug Log Flags

CBRS_LTE5720_LTE3679_Verify_SAS_Connection_Via_Domain_Proxy

    &{mandatory_alarm_1}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    ...                                          reason=NCDP switchover failure due to redundant DP is not configured
    &{mandatory_alarm_2}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    ...                                          reason=DP is not able to communicate with SAS
    &{mandatory_alarm_3}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    ...                                          reason=DP is not able to communicate with SAS
    &{mandatory_alarm_4}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    ...                                          reason=Planned NCDP switchover is triggered
    ${mandatory_alarms_list}=    Create List    ${mandatory_alarm_1}    ${mandatory_alarm_2}    ${mandatory_alarm_3}    ${mandatory_alarm_4}
    ${mandatory_alarms_objects}=    Create Watchdog Alarm List    ${mandatory_alarms_list}

    Log To Console    ${\n}${\n}===================== STEP 1. Prepare test Environment =====================${\n}
    Prepare Test Environment DP

    Log To Console    Checking if cells are onAir when connectToSasMode == direct connect to SAS server...${SPACE}    no_newline=${True}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=connectToSasMode
           ...    operation=update
           ...    value=direct connect to SAS server
           ...    connection=RAT_1ST
    All Cells Should Be Enabled And Onair    times=12x
    Log To Console    Done!

    Configure Domain Proxy    domainProxy=primary
    Configure Domain Proxy    domainProxy=secondary

    Log To Console    Checking if cells are onAir when connectToSasMode == connect through Domain proxy...${SPACE}    no_newline=${True}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=connectToSasMode
           ...    operation=update
           ...    value=connect through Domain proxy
           ...    connection=RAT_1ST
    All Cells Should Be Enabled And Onair    times=12x
    Log To Console    Done!

    All Cells Should Be Enabled And Onair
    Start Watchdog Alarm Detection    expected_alarms=${mandatory_alarms_objects}

    Log To Console    ${\n}${\n}================== STEP 2. Check connection with primary DP =================
    Log To Console    CBRS_LTE3679_FeVe_01_Domain_Proxy_Activation_and_CBSD_operability_check${\n}

    Wait Until Keyword Succeeds    3x    5s    Switch SAS Server Mode    mode=DomainProxy
    All Cells Should Be Enabled And Onair

    Set Suite Variable    ${LTE3679_FeVe_01_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}========== STEP 3. Check is alarm raised on ENB called by primary DP =========
    Log To Console    CBRS_LTE3679_FeVe_02_Domain_Proxy_Alarms_check${\n}

    Log To Console    Blocking SAS communication on port 4433...
    Run    sudo iptables -A OUTPUT -p tcp --destination-port 4433 -j DROP
    Run    sudo iptables -A INPUT -p tcp --destination-port 4433 -j DROP
    Run    sudo iptables-save

    Log To Console    ${\n}Looking for mandatory alarm raise on BTS${\n}${mandatory_alarm_2}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_2}[fault_id]    fault_name=${mandatory_alarm_2}[fault_name]
    ...                                   severity=${mandatory_alarm_2}[severity]    reason=${mandatory_alarm_2}[reason]    timeout=120

    Log To Console    ${\n}Looking if alarm cleared on BTS${\n}${mandatory_alarm_2}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_2}[fault_id]    fault_name=${mandatory_alarm_2}[fault_name]
    ...                                     severity=${mandatory_alarm_2}[severity]    reason=${mandatory_alarm_2}[reason]    timeout=240
    Remove Fault From Watchdog Ignored List    fault_id=${mandatory_alarm_2}[fault_id]    fault_name=${mandatory_alarm_2}[fault_name]
    ...                                        severity=${mandatory_alarm_2}[severity]    reason=${mandatory_alarm_2}[reason]

    Log To Console    ${\n}Looking for mandatory alarm raise on BTS${\n}${mandatory_alarm_3}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                   severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]    timeout=60

    Log To Console    ${\n}Re-enabling SAS communication and check cells status...
    Unblock SAS In Iptables

    Log To Console    ${\n}Looking if alarm cleared on BTS${\n}${mandatory_alarm_3}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                     severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]    timeout=120
    Remove Fault From Watchdog Ignored List    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                        severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]
    All Cells Should Be Enabled And Onair
    Set Suite Variable    ${LTE3679_FeVe_02_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}======== STEP 4. Perform swithover to secondary DP while BTS not configured ========
    Log To Console    LTE5720_Verify_if_fault_6832_with_reason_NCDP_switchover_failure_is_raised_when_standby_DP_is_no..${\n}

    ${cbrspr_object_list}=    ute_admin_infomodel.Get Infomodel Object
    ...    /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/CBRSPR_A-*    timeout=60    alias=RAT_1ST
    ${secondary_dp_addr}=    Set Variable    ${cbrspr_object_list['secondaryDomainProxyServer']}
    ${is_secondary_dp_set}=    Run Keyword And Return Status    Should Not Be Empty    ${secondary_dp_addr}
    IF  ${is_secondary_dp_set}  Wait Until Keyword Succeeds  3x  10s  Run Keywords
    ...  Wait Until BTS Is Not Busy    AND
    ...  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
    ...  parameter=secondaryDomainProxyServer
    ...  operation=delete
    ...  value=""
    ...  connection=RAT_1ST
    Log To Console    Secondary Domain Proxy is not set in BTS configuration
    Perform Switchover    targetSwitchoverDP=secondary

    Log To Console    ${\n}Looking for mandatory alarm raise on BTS${\n}${mandatory_alarm_1}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_1}[fault_id]    fault_name=${mandatory_alarm_1}[fault_name]
    ...                                   severity=${mandatory_alarm_1}[severity]    reason=${mandatory_alarm_1}[reason]    timeout=90

    Perform Switchover    targetSwitchoverDP=primary
    Log To Console    ${\n}Looking if alarm cleared on BTS${\n}${mandatory_alarm_1}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_1}[fault_id]    fault_name=${mandatory_alarm_1}[fault_name]
    ...                                     severity=${mandatory_alarm_1}[severity]    reason=${mandatory_alarm_1}[reason]    timeout=90
    Remove Fault From Watchdog Ignored List    fault_id=${mandatory_alarm_1}[fault_id]    fault_name=${mandatory_alarm_1}[fault_name]
    ...                                        severity=${mandatory_alarm_1}[severity]    reason=${mandatory_alarm_1}[reason]
    All Cells Should Be Enabled And Onair

    Set Suite Variable    ${LTE5720_Verify_if_fault_6832_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}========== STEP 5. Perform swithover to secondary DP while BTS configured ==========
    Log To Console    CBRS_LTE3679_FeVe_05_Direct_connection_and_Domain_Proxy_switching${\n}

    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=secondaryDomainProxyServer
           ...    operation=update
           ...    value=10.42.82.40:8443
           ...    connection=RAT_1ST

    Perform Switchover    targetSwitchoverDP=secondary

    Log To Console    Looking for mandatory alarm raise on BTS${\n}${mandatory_alarm_4}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_4}[fault_id]    fault_name=${mandatory_alarm_4}[fault_name]
    ...                                   severity=${mandatory_alarm_4}[severity]    reason=${mandatory_alarm_4}[reason]    timeout=90
    Log To Console    ${\n}Looking if alarm cleared on BTS${\n}${mandatory_alarm_4}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_4}[fault_id]    fault_name=${mandatory_alarm_4}[fault_name]
    ...                                     severity=${mandatory_alarm_4}[severity]    reason=${mandatory_alarm_4}[reason]    timeout=120
    All Cells Should Be Enabled And Onair

    Set Suite Variable    ${LTE3679_FeVe_05_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}===================== STEP 6. Perform fallback to primary DP ======================
    Log To Console    LTE5720_Verify_if_NCDP_changes_CBSD_status_during_switchover_fallback_to _primary_dp${\n}

    Perform Switchover    targetSwitchoverDP=primary

    Log To Console    Looking for mandatory alarm raise on BTS${\n}${mandatory_alarm_4}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_4}[fault_id]    fault_name=${mandatory_alarm_4}[fault_name]
    ...                                   severity=${mandatory_alarm_4}[severity]    reason=${mandatory_alarm_4}[reason]    timeout=90
    Log To Console    ${\n}Looking if alarm cleared on BTS${\n}${mandatory_alarm_4}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_4}[fault_id]    fault_name=${mandatory_alarm_4}[fault_name]
    ...                                     severity=${mandatory_alarm_4}[severity]    reason=${mandatory_alarm_4}[reason]    timeout=120
    Remove Fault From Watchdog Ignored List    fault_id=${mandatory_alarm_4}[fault_id]    fault_name=${mandatory_alarm_4}[fault_name]
    ...                                        severity=${mandatory_alarm_4}[severity]    reason=${mandatory_alarm_4}[reason]
    All Cells Should Be Enabled And Onair

    Log To Console    ${\n}${\n}============= STEP 7. Perform switch in loop between Connection To SAS mode ===============
    @{result}=    Create List
    FOR    ${loop}    IN RANGE    ${10}
        Log To Console    Loop number: ${loop+1}! Recommisioning connectToSasMode=direct connect to SAS server
        Wait Until Keyword Succeeds    3x    5s    Switch SAS Server Mode    mode=SAS
        ${status_1}=    Run Keyword And Return Status    All Cells Should Be Enabled And Onair

        Log To Console    Going back to connectToSasMode=connect through Domain proxy
        Wait Until Keyword Succeeds    3x    5s    Switch SAS Server Mode    mode=DomainProxy
        ${status_2}=    Run Keyword And Return Status    All Cells Should Be Enabled And Onair
        Log To Console    Saving results:${\n}{'loop':${loop+1}, 'SAS':${status_1}, 'DP':${status_2}}
        @{result}=    Append To List    ${result}    {loop:${loop+1}, SAS:${status_1}, DP:${status_2}}
    END

    Set Suite Variable    ${LTE5720_Verify_if_NCDP_PASSED}    ${TRUE}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures

Prepare Test Environment DP
    [Arguments]    ${alias}=RAT_1ST

    Run Keyword And Ignore Error    Setup Google Chrome And Chrome Driver Version
    Set Screenshot Directory    ${TEST_LOGS_DIR_PATH}/ScreenShots/

    Kill All SAS Processes
    OperatingSystem.Create Directory    ${TEST_LOGS_DIR_PATH}/Certificates
    ${are_bts_certs_installed}=    Run Keyword And Return Status    Check If CBRS Certificates Are Installed
    ...    vendor_cert_name=BTS_Vendor_${alias}    ca_cert_name=signing-ca    root_ca_name=root-ca
    IF  '${are_bts_certs_installed}'=='${False}'  Prepare And Install CBRS Certificates on BTS

    ${sas_pid}    ${sas_log}=    Start SAS Process
    Enable CBRS Feature On eNB

    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=primaryDomainProxyServer
           ...    operation=update
           ...    value=10.42.82.131:8443
           ...    connection=RAT_1ST

    Log To Console    CBRS certificates installed on BTS! Environment preparation COMPLETE!

Open Domain Proxy
    [Arguments]    ${domainProxy}=primary

    ${chrome_params}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method  ${chrome_params}  add_argument  --headless
    Call Method  ${chrome_params}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_params}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_params}  add_argument  --disable-popup-blocking
    Call Method  ${chrome_params}  add_argument  --disable-backgrounding-occluded-windows
    Call Method  ${chrome_params}  add_argument  --disable-renderer-backgrounding
    Call Method  ${chrome_params}  add_argument  --disable-background-timer-throttling
    Call Method  ${chrome_params}  add_argument  --disable-hang-monitor
    &{pefs}  Create Dictionary  download.default_directory  /home/ute/Downloads
    Call Method  ${chrome_params}  add_experimental_option  prefs  ${pefs}
    Create Webdriver  Chrome  chrome_options=${chrome_params}
    Set Window Size  ${1920}  ${1080}

    IF  '${domainProxy}'=='primary'  Go To  ${primaryDpUrl}
    IF  '${domainProxy}'=='secondary'  Go To  ${secondaryDpUrl}

    Capture Page Screenshot  filename=domainproxy.png

    ${check}  Run Keyword And Return Status  Page Should Contain  Your connection is not private
    IF  ${check}
        Wait until keyword succeeds  30  5  Click Button  ${dpBtnAdvanced}
        Capture Page Screenshot  filename=domainproxy_1.png
        Click Link  ${dpBtnProceed}
    END
    Capture Page Screenshot    filename=domainproxy_login.png

    ${check}  Run Keyword And Return Status  Page Should Contain  Domain Proxy
    IF  ${check}
        Wait until keyword succeeds  30  5  Input Text  ${dpTxtLogin}  ${dpUrlUsername}
        Wait until keyword succeeds  30  5  Input Password  ${dpTxtPass}  ${dpUrlPassword}
        Wait until keyword succeeds  30  5  Click Button  ${dpBtnLogin}
    ELSE
        Fail  DP login error
    END

    ${check}  Run Keyword And Return Status  Wait Until Page Contains  text=Active session found  timeout=15
    IF  ${check}
        Capture Page Screenshot  filename=domainproxy_login_activesession.png
        Wait until keyword succeeds  30  5  Click Button  ${dpBtnLogout}
        Wait Until Page Contains  You've logged out successfully  timeout=60
        Sleep  10s
        Wait until keyword succeeds  60  5  Click Element  ${dpTxtLogin}
        Wait until keyword succeeds  30  5  Input Text  ${dpTxtLogin}  ${dpUrlUsername}
        Wait until keyword succeeds  30  5  Input Password  ${dpTxtPass}  ${dpUrlPassword}
        Wait until keyword succeeds  30  5  Click Button  ${dpBtnLogin}
    END
    ${check}  Run Keyword And Return Status  Wait Until Page Contains  Recent activity  timeout=60
    Capture Page Screenshot  filename=domainproxy_main_recent.png
    IF  ${check}  Click Button  ${dpBtnOK}
    Capture Page Screenshot  filename=domainproxy_main.png

Generate and save DP certificate with CSR
    [Arguments]    ${domainProxy}=primary    ${issuer}=CA1.1    ${validity}=1year    ${signature}=256    ${alias}=RAT_1ST

    IF  '${domainProxy}'=='primary'  Open Connection  ${primaryDpSSH}  alias=ssh
    IF  '${domainProxy}'=='secondary'  Open Connection  ${secondaryDpSSH}  alias=ssh

	Log To Console    DP Cert issuer is ${issuer} with validity ${validity} and signature ${signature}.

    Login    ${dpSSHUsername}    ${dpSSHPassword}
    Execute Command    rm -r /mnt/home/NokiaDP/customer/*.csr

    IF  '${domainProxy}'=='primary'  Open Connection  ${primaryDpSSH}  alias=oms
    IF  '${domainProxy}'=='secondary'  Open Connection  ${secondaryDpSSH}  alias=oms

    ${output}=    Login    ${dpOMSUsername}    ${dpOMSPassword}

    Should Not Contain    ${output}    You are required to change your password immediately
    ...    msg='Password change required! Procedure described in OneNote, under DomainProxy tab'

    Execute Command    generate CSR Access
    Execute Command    generate CSR Core

    Switch Connection    ssh
    ${accessFile} =  Execute Command    ls /mnt/home/NokiaDP/customer/*.csr | grep Access
    ${accessCSR} =  Execute Command    cat ${accessFile}
    OperatingSystem.Create File    ${TEST_LOGS_DIR_PATH}/Certificates/${domainProxy}Access.pem    ${accessCSR}
    Sign Certificate Signing Request Using Signing CA    csr_location=${TEST_LOGS_DIR_PATH}/Certificates/
    ...                                                  csr_filename=${domainProxy}Access.pem
    ...                                                  cert_filename=${domainProxy}_access_cert_${alias}.pem

    ${coreFile} =  Execute Command    ls /mnt/home/NokiaDP/customer/*.csr | grep Core
    ${coreCSR} =  Execute Command    cat ${coreFile}
    OperatingSystem.Create File    ${TEST_LOGS_DIR_PATH}/Certificates/${domainProxy}Core.pem    ${coreCSR}
    Sign Certificate Signing Request Using Signing CA    csr_location=${TEST_LOGS_DIR_PATH}/Certificates/
    ...                                                  csr_filename=${domainProxy}Core.pem
    ...                                                  cert_filename=${domainProxy}_core_cert_${alias}.pem

    [Teardown]    Close All Connections

Configure Domain Proxy
    [Arguments]    ${domainProxy}=primary
    ...            ${openssl_dir}=${openSSL}
    ...            ${alias}=RAT_1ST

	Log To Console    OpenSSL_dir is  ${openssl_dir}

    IF  '${domainProxy}'=='primary'
        Generate and save DP certificate with CSR  domainProxy=primary
        Open Domain Proxy  domainProxy=primary
        Go To  ${primaryDpCbrsUrl}
    END
    IF  '${domainProxy}'=='secondary'
        Generate and save DP certificate with CSR  domainProxy=secondary
        Open Domain Proxy  domainProxy=secondary
        Go To  ${secondaryDpCbrsUrl}
    END

    ${sasIP}=    Run    hostname -I | awk '{print $1}'
    Sleep    3s
    Input Text    ${dpSASip}    https://${sasIP}:4433
    Choose File    ${dpSASImport}    ${openssl['CA_dir']}/signing-ca.pem

    Click Element    ${dpTabCBSD}    action_chain=True
    Choose File    ${dpImportCBSD1}    ${openssl['CA_dir']}/root-ca.pem

    Click Button    ${dpBtnUpdate}

    IF  '${domainProxy}'=='primary'  Go To  ${primaryDpCertificateUrl}
    IF  '${domainProxy}'=='secondary'  Go To  ${secondaryDpCertificateUrl}

    Click Button    ${dpCoreImport}
    Choose File    ${dpCertificate}    ${openssl['certificate_files_dir']}/${domainProxy}_core_cert_${alias}.pem
    Choose File    ${dpTrustChain}    ${openssl['CA_dir']}/signing-ca.pem
    Click Button    ${dpBtnImport}

    Wait Until Element Is Not Visible    certManagementForm    timeout=60

    Click Button    ${dpAccessImport}
    Choose File    ${dpCertificate}    ${openssl['certificate_files_dir']}/${domainProxy}_access_cert_${alias}.pem
    Choose File    ${dpTrustChain}    ${openssl['CA_dir']}/signing-ca.pem
    Click Button    ${dpBtnImport}

    IF  '${domainProxy}'=='primary'  Go To  ${primaryDpSettingsUrl}
    IF  '${domainProxy}'=='secondary'  Go To  ${secondaryDpSettingsUrl}

    Sleep    1s

    Run Keywords
    ...    Click Element    ${dpTabSwMain}    action_chain=True    AND
    ...    Select From List By Label    ${dpSwitchoverList}    ${dpDisabledListVal}    AND
    ...    Click Button    ${dpBtnUpdate}
    Close Browser

Switch SAS Server Mode
    [Arguments]    ${mode}=SAS

    ${enb_id} =  Set Variable    ${testlines.${testline_id}.enb_id}

    IF  '${mode}'=='DomainProxy' or '${mode}'=='DP'
        Wait Until BTS Is Not Busy
        taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
        ...  dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
        ...  parameter=connectToSasMode
        ...  operation=update
        ...  value=connect through Domain proxy
        ...  connection=RAT_1ST
    END
    IF  '${mode}'=='SAS' or '${mode}'=='sas'
        Wait Until BTS Is Not Busy
        taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
        ...  dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBRSPR-1
        ...  parameter=connectToSasMode
        ...  operation=update
        ...  value=direct connect to SAS server
        ...  connection=RAT_1ST
    END

Perform Switchover
    [Arguments]    ${targetSwitchoverDP}=secondary

    Log To Console    Called switchover! Switching to CBDS <> ${targetSwitchoverDP}DP <> SAS

    IF  '${targetSwitchoverDP}'=='secondary'
        Open Domain Proxy  domainProxy=secondary
        Go To  ${secondaryDpSettingsUrl}
        Capture Page Screenshot  filename=secondarydp_settings.png
        Click Element  ${dpTabSwMain}  action_chain=True
        Select From List By Label  ${dpSwitchoverList}  ${dpDisabledListVal}
        Capture Page Screenshot  filename=secondarydp_switchover.png
        Click Button  ${dpBtnUpdate}
        Close Browser
        Open Domain Proxy  domainProxy=primary
        Go To  ${primaryDpSettingsUrl}
        Capture Page Screenshot  filename=primarydp_settings.png
        Click Element  ${dpTabSwMain}  action_chain=True
        Select From List By Label  ${dpSwitchoverList}  ${dpRedundantListVal}
        Capture Page Screenshot  filename=primarydp_switchover.png
        Click Button  ${dpBtnUpdate}
        Close Browser
    END

    IF  '${targetSwitchoverDP}'=='primary'
        Open Domain Proxy  domainProxy=primary
        Go To  ${primaryDpSettingsUrl}
        Click Element  ${dpTabSwMain}  action_chain=True
        Select From List By Label  ${dpSwitchoverList}  ${dpDisabledListVal}
        Click Button  ${dpBtnUpdate}
        Close Browser
        Open Domain Proxy  domainProxy=secondary
        Go To  ${secondaryDpSettingsUrl}
        Click Element  ${dpTabSwMain}  action_chain=True
        Select From List By Label  ${dpSwitchoverList}  ${dpPrimaryListVal}
        Click Button  ${dpBtnUpdate}
        Close Browser
    END
