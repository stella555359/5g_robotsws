*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO
...           RAN_5G_TDD_FDD   RAN_5G     CONFIGURED
Documentation       :copyright:   Nokia
...                 :author   :   Bhakti Patel
...                 :contact  :   bhakti.ka_patel@nokia.com
Resource          resources/CB014093_KW.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DL_RT}        10
${UL_RT}        10
@{UE_D}         1    21    31    41
${SYSLOG}       syslog_14093
${FT}           actEnhancedPDSCHSchSplSlot changed from: false to true
${TF}           actEnhancedPDSCHSchSplSlot changed from: true to false


*** Test Cases ***
[1][1.0] CB014093_E_Online_modification_of_actEnhancedPDSCHSchSplSlot_Multiple_UEs
    [Tags]    QC_233529    QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    This user scenario intends to validate the behaviour with online modification of actEnhancedPDSCHSchSplSlot.
    [Setup]    Prepare For CB014093_E
    Wait Coam Site To Be Ready
    Log to Console    \nstarting 14093 case...\n
    Get Alarm By Details

    FOR     ${ueid}     IN    @{UE_D}
        UE Register Should Be Successful For SA    ${ueid}
        log to console    \nStarting Downlink and Uplink Traffic for UE ${ueid}
        DL Traffic Should Be Successful     ${DL_RT}    ${ueid}
        UL Traffic Should Be Successful     ${UL_RT}    ${ueid}
    END
    Log To Console    \nStarting E sub feature...
    Start Syslog     log_dir=${Log_Path}    log_name=${syslog}    add_line_number=${True}    alias=sys1

    FOR    ${i}    IN RANGE    1    5
        ${dist}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${i}
        Change actEnhancedPDSCHSchSplSlot Value Online    ${dist}    true
        ${message}    Message Should Exist In Syslog File    regexp=${FT}    alias=sys1
        Log to Console    \n${i}) Found Message: ${message}
    END

    FOR     ${ueid}     IN    @{UE_D}
        Displays QFI Statistics    ${ueid}    1
    END

    FOR    ${i}    IN RANGE    1    5
        ${dist}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${i}
        Change actEnhancedPDSCHSchSplSlot Value Online    ${dist}    false
        ${message}    Message Should Exist In Syslog File    regexp=${TF}    alias=sys1
        Log to Console    \nFound Message: ${message}
    END
   [Teardown]    Teardown For CB014093_E
