*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Nagesh K V
...              :contact: nagesh.k_v@nokia.com
...         The aim of the CB007873-E feature is to verify the Behaviour of CA during the
...         Cell Lock without Graceful Cell Shutdown
...         is performed on the TDD cell which is the PSCell for UEs configured for EN-DC and Carrier Aggregation.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB007873_E_Keywords.robot
Library          python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with ScellActivation_blind.json
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}


Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/CB007873_basic.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_NONCA_FDD}     14
${UE_NONCA_TDD}     13
${UE1_CA_FDD}       11
${UE2_CA_FDD}       12
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}      1
${TRF_ID}      1
${TRF_ID2}     2
${TRF_ID3}     3
${TRF_ID4}     4
${a3meas_id}   1
${a1meas_id}   2
${epc_log_path}    /tmp/
${Lock}         Bearer-type change from SCG-split to MCG
${UnLock}       MasterInformationBlock-NR Updated
${Scell_addition}       SCellIndex 9
${Timeout}       60
*** Test Cases ***
[1][1.0] CB007873_E_B7_15_Cell_Unlock_of_TDD_Cell_with_Scell_Blind_Addition_Blind_Activation_Mixed_Mode
    [Documentation]  Verifying TDD Lock during blind based Scell Activation
    [Tags]     QC_201740    QC_85391     QCD_MN_RAN    QCP_RAN_ET
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Perform SCF Delta Commissioning with delta_TDD_lock.json
    sleep     10s
    Attach CA FDD    ${UE1_CA_FDD}
    Verify Counters CB007873
    Perform SCF Delta Commissioning with delta_TDD_Unlock.json
    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${UnLock}    ${Timeout}
    Attach CA FDD and check Scell Addition for blind Scell Activation      ${UE2_CA_FDD}
    Attach NONCA TDD      ${UE_NONCA_TDD}
    Verify Counters CB007873
    sleep    5s
    UE Detach should be Successful      ${UE1_CA_FDD}
    sleep    3s
    UE Detach should be Successful      ${UE2_CA_FDD}
    sleep    3s
    UE Detach should be Successful      ${UE_NONCA_TDD}
    sleep   5s

#
#[1][1.0] CB007873_E_B5_11_Cell_Lock_of_TDD_Cell_without_Graceful_Cell_Shutdown_with_Scell_Blind_based_Addition_Buffer_Based_Activation_Mixed_Mode
#    [Documentation]  Verifying TDD Unlock during buffer based Scell Activation
#    [Tags]     QC_201739    QC_85388     QCD_MN_RAN    QCP_RAN_ET
#    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable      ${LOG_PATH}
#    X2AP Link Should be UP
#    Perform SCF Delta Commissioning with ScellActivation_bufferBased.json
#    Attach CA FDD and check Scell Addition for bufferbased Scell Activation    ${UE1_CA_FDD}
#    Attach NONCA FDD    ${UE_NONCA_FDD}
#    Attach NONCA TDD    ${UE_NONCA_TDD}
#    Verify Counters CB007873
#    Perform SCF Delta Commissioning with delta_TDD_lock.json
#    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Lock}    ${Timeout}
#    Verify Counters CB007873
#    sleep    5s
#    UE Detach should be Successful      ${UE1_CA_FDD}
#    sleep    3s
#    UE Detach should be Successful      ${UE_NONCA_FDD}
#    sleep    3s
#    UE Detach should be Successful      ${UE_NONCA_TDD}
#
#

*** Keywords ***
Delta to LockUnlock the cell
    [Arguments]    ${LockUnlock_file}
    [Documentation]    This keyword is to get the couter value list from Admin
    ${scf_file_type}    Get File Type    ${LockUnlock_file}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${LockUnlock_file}
    #validation for FDD Cell Lock

Attach CA FDD and check Scell Addition for bufferbased Scell Activation
    [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.UE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${1}
#    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Scell_addition}    ${10}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${2}
#    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Scell_addition}    ${10}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${3}
#    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Scell_addition}    ${10}
    CB007873_E_Keywords.Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=50       trf_id=${4}

Attach CA FDD and check Scell Addition for blind Scell Activation
    [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.UE Attach should be Successful    ${UE_ID}
    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Scell_addition}    ${10}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${1}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${2}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${3}
    CB007873_E_Keywords.Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=50       trf_id=${4}

Attach NONCA FDD
    [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.UE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${1}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${2}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${3}
    CB007873_E_Keywords.Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=50       trf_id=${4}

Attach NONCA TDD
    [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.TDD UE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${1}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${2}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${3}
    CB007873_E_Keywords.Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=50       trf_id=${4}

Attach CA FDD
    [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.UE Attach should be Successful    ${UE_ID}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${1}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${2}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${3}
    CB007873_E_Keywords.Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=50       trf_id=${4}
