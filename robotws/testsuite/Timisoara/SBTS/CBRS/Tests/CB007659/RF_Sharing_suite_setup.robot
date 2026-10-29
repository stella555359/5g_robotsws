*** Settings ***
Documentation
...    = Author =
...    aleksandra.chudzik@nokia.com
...    = Maintainer =
...    aleksandra.chudzik@nokia.com

*** Keywords ***
RF_Sharing_suite_setup

    [Documentation]    Purpose: environment setup for RF sharing test cases (LTE-5G concurrent mode). Original CBRS
    ...                certificates are added to both nodes and SAS Simulator. To be run at the beginning of
    ...                CBRS_CRT_LTE_5G_concurrent suite. After setup cells should be on air on both nodes.
    [Timeout]    30min

    Log    ${\n}${\n}========== STEP 1. Prepare test Environment on eNB ==========${\n}    console=true
    Prepare Test Environment For eNB
    Check If CBRS Certificate Is Installed    BTS    CBRS_CA1    CBRS_TA1    CBRS_TEST_TA1
    Check Cells And Verify ENB Alarms

    Log    ${\n}${\n}========== STEP 2. Prepare test Environment on gNB ==========${\n}    console=true
    Kill All SAS Processes
    Prepare Test Environment For gNB
    Check Cells And Verify ENB Alarms    alias=RAT_2ND

    Log    ${\n}RF Sharing suite setup finished!    console=true


*** Keywords ***
Prepare Test Environment For eNB
    Kill All SAS Processes
    Run Keyword And Ignore Error    Remove Certificates From BTS
    OperatingSystem.Create Directory    ${TEST_LOGS_DIR_PATH}/Certificates

    Generate And Save New Certificate With CSR    BTS    issuer=CA1
    Download CBRS TA & CA Certificates
    Prepare SAS Files
    Generate SAS TA Certificate

    Start SAS Sim With Custom Certificates
    ...    config=/home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/CBRS/CNI_NIDD/Tests/CB007659/Data/SAS_Sim.conf

    Install Certificate CBRS Vendor Chain    BTS    CBRS_CA1    CBRS_TA1
    Install Certificate CBRS Additional CA    CBRS_TEST_TA1

    Enable CBRS Feature On eNB
    Log    ${\n}CBRS certificates installed on eNB! Environment preparation COMPLETE!    console=true

Prepare Test Environment For gNB
    ${gnb_id}   Set Variable    ${testlines.${testline_id}.node2.enb_id}

    Run Keyword And Ignore Error    Remove Certificates From BTS   node_IP=${testlines.${testline_id}.node2.mplane_ip_addr}    alias=RAT_2ND

    Generate And Save New Certificate With CSR    BTS2    issuer=CA1    alias=RAT_2ND
    Install Certificate CBRS Vendor Chain    BTS2    CBRS_CA1    CBRS_TA1    alias=RAT_2ND
    Install Certificate CBRS Additional CA    CBRS_TEST_TA1    alias=RAT_2ND

    Enable CBRS Feature On gNB    alias=RAT_2ND    target_gnb=${gnb_id}
    Start SAS Sim With Custom Certificates
    ...    config=/home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/CBRS/CNI_NIDD/Tests/CB007659/Data/SAS_Sim.conf
    Wait For 5G Cells To Be OnAir    alias=RAT_2ND

    Log    ${\n}CBRS certificates installed on gNB! Environment preparation COMPLETE!    console=true


Remove Certificates From BTS
    [Documentation]  Remove all CBRS certificates from BTS, reset BTS and wait for reconnection.                  ${\n}
    ...              Return:                none                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]      ${node_IP}=192.168.255.1    # IP to enb ssh connection
    ...              ${alias}=RAT_1ST            # connection alias

    Open Connection    ${node_IP}
    Login              ${credentials.enb_username}    ${credentials.enb_password}
    Execute Command    rm /rom/etc/sas/cbrsRootCACertificate.pem
    Execute Command    rm /rom/etc/sas/cbrsVendorCertChain.pem

    #TODO: Add exception - no certs on BTS
    @{installedCertificates}   taf.sbts.oam.coam.admin.Get Certificate List
    ...                          cert_type=CBRSAdditional
    ...                          timeout=300
    ...                          connection=${alias}
    FOR    ${i}    IN    @{installedCertificates}
        taf.sbts.oam.coam.admin.delete_certificate
        ...                     fingerprint=${i['fingerPrint']}
        ...                     domain_type=CBRS
        ...                     timeout=60
        ...                     connection=${alias}
    END

    [Teardown]    Close All Connections

Download CBRS TA & CA Certificates
    [Documentation]  Download all core certificates used in tests, save them in subdirectory Certificates in Logs directory.  ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}

    Open Insta Certifier
    FOR    ${i}    IN    @{instaCommonCertificates2}
        Go To    ${instaUrl}/ca_view.html
        Click Link    ${i}
        Click Button    ${instaGoToCert}

        ${check}   Run Keyword And Return Status    Page Should Contain    Approved by
        ${instaButton}   Set Variable If    ${check} == True    ${instaBtnDownload1}    ${instaBtnDownload2}

        ${link}   Get Element Attribute    ${instaButton}    href
        ${link}   Fetch From Left    ${link}    .pem
        ${name}   Fetch From Right    ${link}    /

        Sleep    1s
        Click Link    ${instaButton}

        ${check}   Run Keyword And Return Status    Wait Until Created    /home/ute/Downloads/${name}.pem
        IF  ${check} == False
            Click Link  ${instaButton}
            Wait Until Created  /home/ute/Downloads/${name}.pem
        END
        OperatingSystem.Move File    /home/ute/Downloads/${name}.pem    ${TEST_LOGS_DIR_PATH}/Certificates/${i}.pem
    END

    [Teardown]    Close Browser


Check Cells And Verify ENB Alarms
    [Documentation]  Check if cells are on air and no unexpected alarms apeared.                                  ${\n}
    ...              Return:                None                                                                  ${\n}
    ...              Output:                { }                                                                   ${\n}
    ...              Author:                karol.sadowski@nokia.com                                              ${\n}
    ...              Maintainer:            CBRS Team                                                             ${\n}
    [Arguments]      ${mandatory}=@{EMPTY}  # list of mandatory alarms
    ...              ${alias}=RAT_1ST       # connections alias

    Log    ${\n}Check if cells are onAir    console=true
    All Cells Should Be Enabled And Onair

    Log    ${\n}Check active alarms    console=true
    FOR    ${i}    IN    ${mandatory}
        Log    ${\n}Mandatory alarm = ${i}    console=true
    END

    Wait Until Keyword Succeeds    60x    2s    Admin Alarms Get And Check    alias=${alias}
    ...    allowed=${enb_allowed_alarms}
    ...    mandatory=@{mandatory}
