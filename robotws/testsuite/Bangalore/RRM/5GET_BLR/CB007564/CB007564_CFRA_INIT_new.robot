*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1   CONFIGURED

Documentation
...
...     INTRODUCTION:  This feature provides new Performance Measurement counters that are used for Network Performance
...     measurement and the creation of new or improvement of existing KPIs.
...     The Feature introduces PM counters related to :
...     Stand Alone Architecture: (CB007564 A & B)
...         Accessibility counters:
...             These counters are used to measure the accessibility or successful setup of QoS Flow.
...         Retainability counter:
...             These counters are used to measure the issues causing QOS Flow releases in the network
...             These counters are used to measure the issues causing DRB to be released in the gNB
...     Non-Stand Alone Architecture: ( CB007564-C )
...         RACH counters
...             These counters are used to measure the success of the RACH procedure for both
...             CFRA (Contention Free Random Access ), CBRA (Contention Based Random Access)
...
...     TEST SET NAME:  CB007564-C
...
...     TESTING SCOPE: Prerequisite : GNB and Airphone should be installed
...     Scope : CB007564-C to check the Rach counters for CBRA_INIT, CFRA_INIT, CBRA_HO and CFRA_HO
...
...     TEST INSTANCE SPECIFIC NOTES:
...        Case 1:
...           CB007564-C_TC3_CFRA_procedure_Counter_M55306C09000_Number_of_time_dedicated_preamble_was_used_in_MSG1
...        TEST CASE NAME:
...           CB007564-C_TC3_CFRA_procedure_Counter_M55306C09000_Number_of_time_dedicated_preamble_was_used_in_MSG1
...        Purpose: The purpose of this test is to verify PM counter to count the number of time a dedicated preamble
...        assigned to Ue by the gNB is used by Ue during Mesg1 for Initial Ue access
...        The purpose of this test is to verify the Number of times CF RA setup is successful and the Ue responds in First UL tx that CRC is OK
...        The purpose of this test is to verify PM counter for counting the number of times dedicated preamble is sent to the Ue from gNB
...
...     CONTACTS:
...     CFAM Approver (Moderator)  : Tatarczyk, Krzysztof
...     Product Line Management:   : LMazur, Piotr (Nokia - PL/Krakow) <piotr.mazur@nokia.com>
...     CFAM Leader                : Chandla, Mayank (Nokia - FI/Espoo) <mayank.chandla@nokia.com>
...     SFS Author or Authors      : Chandla, Mayank (Nokia - FI/Espoo) <mayank.chandla@nokia.com>
...     BTS Feature Owner          : Flaum, Maciej (Nokia - PL/Krakow) <maciej.flaum@nokia.com>
...
...     Other CFAM Authors:
...     L2 PS:
...         Polanska, Joanna (Nokia - PL/Krakow) <joanna.polanska@nokia.com>
...         Wos, Przemyslaw (Nokia - PL/Krakow) <przemyslaw.wos@nokia.com>
...     L3:
...         Kleszcz, Piotr (Nokia - PL/Krakow) <piotr.kleszcz@nokia.com>
...     Entity Testing:
...         L2 ET:
...             D, Mehul (Nokia - IN/Bangalore) <mehul.d@nokia.com>
...         L3 ET:
...             Zwierz, Karolina (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...             Matusik, Mateusz (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
...     System Testing:
...          SyVe FDD:
...             Nowacki, Rafal (Nokia - PL/Wroclaw) <rafal.nowacki@nokia.com>
...
...     SyVe TDD FR1:
...         Yin, Elva (NSB - CN/Hangzhou) <elva.yin@nokia-sbell.com>
...
...     SyVe TDD FR2:
...         Yi, Hao (NSB - CN/Hangzhou) <hao.yi@nokia-sbell.com>
...     CuDo:
...         Gajowska, Katarzyna (Nokia - PL/Wroclaw) <katarzyna.gajowska@nokia.com>
...
...     Test tools:
...         AirPhone(only for 5G):
...             Kumar, Ajay B. (Nokia - IN/Bangalore) <ajay.b.kumar@nokia.com>
...   		CFAM leader :
... 			Chandla, Mayank (Nokia - FI/Espoo) <mayank.chandla@nokia.com>
...     Other CFAM contributor:
... 			Tatarczyk, Krzysztof (Nokia - PL/Wroclaw) <krzysztof.tatarczyk@nokia.com>
...		Lead Specification Engineer:
... 			7564-A and 7564-B:
... 				Kowalczyk, Krzysztof 2. (Nokia - PL/Krakow) <krzysztof.2.kowalczyk@nokia.com>
... 			7564-C:
... 				Holowicki, Maksymilian (Nokia - PL/Krakow) <maksymilian.holowicki@nokia.com>
...		CP3/EFS Author
...			L2 (7564-C):
...				Holowicki, Maksymilian (Nokia - PL/Krakow) <maksymilian.holowicki@nokia.com>
...			L3 (7564-A and 7564-B):
...				Kowalczyk, Krzysztof 2. (Nokia - PL/Krakow) <krzysztof.2.kowalczyk@nokia.com>
...
...		Test tools
...			AirPhone(only for 5G):
...				Kumar, Ajay B. (Nokia - IN/Bangalore) <ajay.b.kumar@nokia.com>
...
... 	Feature Test Lead
...			7564-A and 7564-B:
...				Matusik, Mateusz (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
...         7564-C:
...				Waiting for Assignment
...
...  	ET owner (LPO/APO)
... 		L2 ET:
...				D, Mehul (Nokia - IN/Bangalore) <mehul.d@nokia.com>
...         L3 ET:
...				Zwierz, Karolina (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...		SyVe owner (LPO/APO)
...			ST TDD:
...				Qian, Xj (NSB - CN/Hangzhou) <xj.qian@nokia-sbell.com>
...			ST FDD:
...              Jonczyk, Damian (Nokia - PL/Wroclaw) <damian.jonczyk@nokia.com>
...
...     FOT site containing all main information about feature on FOT Confluence:
...             https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB007564+NR+Additional+PM+Counters+-+I
...
...     Focal point Link:
...            https://focalpoint-prod.int.net.nokia.com/fp/workspace/1314/view/12098/tree/23363
...
...     JIRA Backlogs Link:
...             FFB-23397
...
...     Test Cases Review (Collaborator Details):
...         Test Plan               :  https://collab.ext.net.nokia.com/ui#review:id=844749
...         Testability Requirement :  https://collab.ext.net.nokia.com/ui#review:id=843927
...         Robot scripts Review    :  https://collab.ext.net.nokia.com/ui#review:id=849955
...         Feature Test Strategy   :  https://collab.ext.net.nokia.com/ui#review:id=847285
...         Et Confluence page Link :  https://confluence.ext.net.nokia.com/display/ETB/CB007564-C
...
...     REFERENCES:  CFAM CB00756-C
...
...     TERMS AND ABBREVIATIONS:  -
...
...     HISTORY:  History, current status and TC description is available in repository:
...                [20.12.2021] - Created TCs
...                [18.01.2021] - Updates to Test suite documentation update and Keywords done
...                [18.01.2022] - Test suite documentation update.
...
...               Test Case Scenario author   : Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Test Case Scenario contact  : Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Test Case automation author : Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Test Case automation contact: Nagesh.k_v@nokia.com,vandana.b@nokia.com
...               Creation Date               : 1-December-2021
...               Modified Date               : 27-January-2022
...               Last Modified by            : Nagesh.k_v@nokia.com,vandana.b@nokia.com

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB007564_Keywords.robot
Resource         resources/CB007564_Keywords_suitesetup.robot
Resource         resources/CB007564_Resource_suitesetup.robot
Library          python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
Library           ./resources/Lib/induce_delay.py
Resource         ../resources/robot/common_log_collection.robot

Suite Setup        Run keywords     Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with delta_cfra_init_2Cells.json
...                 AND     CB007564_Resource_suitesetup.Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     CB007564_Keywords_suitesetup.Check gNB Bulid

Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${SCFC}=            ${CURDIR}/config/scf_CB007564_default.xml
${AP_XML}=          ${CURDIR}/config/iphy_CB007564_default.xml
${wts_cfg_file}     ${CURDIR}/config/sansa_ASIL_ABIO_TDD_CFRA_INIT.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE}               11
${UE_NONCA_TDD}     15
${UE1_CA_FDD}       16
${UE2_CA_FDD}       17
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
${Scell_addition}       SCellIndex 9 act
${Timeout}       60
${TEST_NAME}     CFRA_INIT
*** Test Cases ***
[1]CB007564-C_TC3_CFRA_Init_procedure_Counter_M55306C09000_Number_of_time_dedicated_preamble_was_used_in_MSG1
    [Documentation]  Verifying TDD Lock during blind based Scell Activation
    [Tags]     QC_201792    QC_155991     QCD_MN_RAN    QCP_RAN_ET
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    sleep     10s
    Link SCOUT SCF to Configuration ID for Reporting
##############################################
    ${start_time1}=     DateTime.Get Current Date   result_format=%M
    log to console      ${start_time1}
    ${sleeptime}    induce_delay_tc_start    ${start_time1}
    log to console      ${sleeptime}
    sleep     ${sleeptime}s
    ${start_time}=      DateTime.Get Current Date    result_format=%H:%M:%S
    log to console        /***************The current time is ${start_time} ****************/
    #Attach/Detach NSA UE and start traffic multiple times for couter to get update
    Attach Data Transfer and Detach UE      ${UE}
    sleep    1
    Attach Data Transfer and Detach UE      ${UE}
    sleep    1
    Attach Data Transfer and Detach UE      ${UE}
    Sleep    1
    ${start_time2}=     DateTime.Get Current Date   result_format=%M
    log to console      /***************PM counter fetching time is  ${start_time2} ****************/
#    ${sleeptime}    induce_delay_pm_start    ${start_time2}
#    log to console      ${sleeptime}
#    sleep     ${sleeptime}s
    Verify Counters CB007564 CFRA INIT


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
    Run Keyword and Ignore Error     Read WTS Output For Pattern And Print matching Lines    ${Scell_addition}    ${10}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${2}
    CB007873_E_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${3}
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

Attach Data Transfer and Detach UE
    [Arguments]    ${UE_ID}
    LTE Attach should be Successful    ${UE_ID}
    CB007564_Keywords.UE Attach should be Successful    ${UE_ID}
    sleep    2s
#    CB007564_Keywords.Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${1}
    UE Detach should be Successful      ${UE_ID}
    sleep    2s
