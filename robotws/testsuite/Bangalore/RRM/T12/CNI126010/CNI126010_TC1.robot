*** Settings ***
Force Tags    CLOUD_5G_O_E_AP_LOO
...           RAN_5G_TDD   RAN_5G     CONFIGURED
Documentation       :copyright:   Nokia
...                 :author   :   Bhakti Ka patel
...                 :contact  :   bhakti.ka_patel@nokia.com
...                 :Feature  :   This user scenario aims at Monitoring PCMD content related to
...                               DL Radio Bearer RLC Throughput Measurement data for FR1 non-CA UE.
Resource          resources/CNI126010_Keywords.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${TOPOLOGY}     CLOUD_5G_O_E_AP_LOO
${SYSLOG}       syslog_126010
${Pattern}      dataDiscriminator[[:space:]]*:[[:space:]]*19,[[:space:]]*sumOfVolUeTputTot[[:space:]]*:[[:space:]]*(3|4)[1-9][0-9]{4}
${UE14}         14
${UE15}         15
${DL}           100


*** Test Cases ***
[1][1.0] USCNI-126010_B1_1_Verify_Monitoring_PCMD_DL_Radio_Bearer_RLC_Tput_Meas_data_FR1_non-CA_UE
    [Tags]    QC_179165   QCD_MN_RAN    QCP_RAN_VRF
    [Documentation]    This user scenario aims at Monitoring PCMD content related to
    ...                DL Radio Bearer RLC Throughput Measurement data for FR1 non-CA UE.
    [Setup]    Prepare For TC01
    Log To Console    \nStarting the case...
    Start Syslog     log_dir=${log_path}    log_name=${syslog}    add_line_number=${True}    alias=sys1
    FOR    ${UE}    IN RANGE    1    14
        UE Register Should Be Successful For SA    ${UE}
        Start and Validate DL Traffic              ${UE}
    END
    UE Register Should Be Successful For SA    ${UE14}
    Start and Validate DL Traffic              ${UE14}    ${DL}
    UE Register Should Be Successful For SA    ${UE15}
    Start and Validate DL Traffic              ${UE15}    ${DL}
    Sleep    360s
    ${message}    Message Should Exist In Syslog File    regexp=${pattern}    alias=sys1
    Log to Console    \nFound Message: ${message}
    Stop Syslog    alias=sys1
    [Teardown]    Teardown For TC01
