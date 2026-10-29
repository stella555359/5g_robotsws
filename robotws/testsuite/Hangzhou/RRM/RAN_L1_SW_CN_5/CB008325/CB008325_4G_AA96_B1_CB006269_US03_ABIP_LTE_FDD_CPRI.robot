*** Settings ***
Documentation
...    Author:  Huang Shujun
...    Contact: shujun.j.huang@nokia-sbell.com
...    Feature: CB008325_4G_AA96_B1_CB006269_US03_ABIP_LTE_FDD_CPRI
...    Release: 23R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file}    CB008325_AA96_ABIP_AHCA_LTE_FDD_CPRI_5LNCEL_4T4R_TM4.xml


*** Test Cases ***
CB008325_4G_AA96_B1_CB006269_US03_ABIP_LTE_FDD_CPRI_trunk
    [Tags]    CB008325    QL3    QC_417392    Trunk
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008325${/}${scfc_file}
    #Adjust HBTE attenuation values    10.108.228.28    9:20; 10:20; 11:20; 12:20
    Perform 4G Cell block 1,3,6,9 via AdminCLI
    SMAwave 6269slimcarrier L3 call    2    90M    40M    45%    4G    5
    #ttitrace
    Perform 4G Cell unblock 1,3,6,9 via AdminCLI
    SMAwave Stop Data And Detach


CB008325_4G_AA96_B1_CB006269_US03_ABIP_LTE_FDD_CPRI_branch
    [Tags]    CB008325    QL3    QC_538347    Branch
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008325${/}${scfc_file}
    #Adjust HBTE attenuation values    10.108.228.28    9:20; 10:20; 11:20; 12:20
    Perform 4G Cell block 1,3,6,9 via AdminCLI
    SMAwave 6269slimcarrier L3 call    2    90M    40M    45%    4G    5
    #ttitrace
    Perform 4G Cell unblock 1,3,6,9 via AdminCLI
    SMAwave Stop Data And Detach


*** Keywords ***
SMAwave 6269slimcarrier L3 call
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}
