*** Settings ***
Documentation
...   author: yahong.liu
...   contact: yahong.liu@nokia-sbell.com
...   this is a robot case about CB007035-A_Alternative#3
...   Some cases have its own cfg file and scf file
Resource           ../Resources/common_resource.robot
Suite Setup            Suite Setup For CUS    ${SCF_XML}    ${SWCONFIG}    ${CUS_YAML}
Test Setup            Common MultiBTS Test Setup For CUS
Test Teardown     Run Keywords    Case Teardown For CUS    AND
...               Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown         Suite Teardown For CUS

Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_4G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]
Test Timeout    60 minutes

*** Variables ***
${INSTALL_BUILD}         NO
${DEBUG_MODE}            NO
${USE_AIRPHONE}          Y
${CLEAN_LOG_SIZE}        500
${parameter_CB007742}    actHOtoNR
${parameter_LTE4193}     actDynTrigLteNrDualConnectivity
${parameter_CB008218}    actPeriodicB1NRMeas
${parameter_CB007035}    actNrServBasedHoQciX
${SCF_XML}     ${CURDIR}/CUS/SCFC_CB007035A_R4A.xml
${CUS_YAML}    ${CURDIR}/CUS/CUS_CB007035A_R4A.yaml
${SWCONFIG}    ${CURDIR}/CUS/swconfig_CB007035A_R4A.txt
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}

*** Test Cases ***
CB007035-SR-A-03 RRC Reestablishment start periodical NR SBHO B1-NR measurement activation after volteBearerProtectTimer expires
    [Documentation]    author:yahong.liu
    ...    case1
    ...    1. CB007742 enable, LTE4193-B disable, CB008218 enable, CB007035 enable
    ...    2. UE attach without volte Bearer,with QCIx bearer for NR SBHO
    ...    3. Trigger Reestablishment
    ...    4. Check Initiate VoLTE bearer setup protection in RRC Reestablishment
    ...    5. Check start periodical NR SBHO B1-NR measurement activation after volteBearerProtectTimer expires
    #Start tcpdump in SBTS by command
    sleep    5min
    Start Multi Bts Log
    UE1 Attach ENB1 Cell1 With Default Bearer QCI9
    Log To Console      ${\n}============= UE1 attach successfully. =============${\n}
    Log To Console      ${\n}============= volteBearerProtectTimer=8s. =============${\n}
    sleep    60s
    Trigger UE1 Reestablishment
    #Trigger UE1 to send B1NR measurement
    Log To Console      ${\n}============= UE1 Reestablishment successfully. =============${\n}
    sleep    60s
    Check test result for case03
    Stop All BTSLog And Download to Local
    #stop tcpdump in sbts by command

# CB007035-SR-A-06 VoLTE bearer is setup on cells
#     [Documentation]    author:yahong.liu
#     ...    case06
#     ...    This user scenario describes VoLTE bearer setup within ICS/RRC Reestablishment
#     Start Capture Emil Log
#     Start Multi Bts Log
#     UE2 Attach ENB1 Cell1 With Default Bearer QCI9 and QCI1
#     Log To Console      ${\n}============= UE2 attach successfully. =============${\n}
#     sleep    20s
#     Bearer QCI1 Delete For UE2
#     sleep    20s
#     Bearer QCI1 Added For UE2
#     Trigger UE2 Reestablishment
#     Check test result for case06
#     Stop All BTSLog And Download to Local
#     Stop_and_download Capture Emil Log

CB007035-SR-A-11 Deactivate and activate NR SBHO B1-NR measurements with normal call
    [Documentation]    author:yahong.liu
    ...    case11
    ...    This user scenario describes Deactivate and activate NR SBHO B1-NR measurements with QCI-65/66/67
    #Start Capture Emil Log
    sleep    5min
    Start Multi Bts Log
    UE1 Attach ENB1 Cell1 With Default Bearer QCI9
    Log To Console      ${\n}============= UE2 attach successfully. =============${\n}
    sleep    20s
    Run Keyword And Ignore Error   Run Uex Command    bearer_add ue=1 qci=65 mbr_ul=64 mbr_dl=64 gbr_ul=64 gbr_dl=64
    sleep    20s
    Run Keyword And Ignore Error   Run Uex Command    bearer_del ue=1 eps_id=6
    sleep    20s
    Run Keyword And Ignore Error   Run Uex Command    bearer_add ue=1 qci=66 mbr_ul=64 mbr_dl=64 gbr_ul=64 gbr_dl=64
    sleep    20s
    Run Keyword And Ignore Error   Run Uex Command    bearer_del ue=1 eps_id=6
    sleep    20s
    Run Keyword And Ignore Error   Run Uex Command    bearer_add ue=1 qci=67 mbr_ul=64 mbr_dl=64 gbr_ul=64 gbr_dl=64
    sleep    20s
    Run Keyword And Ignore Error   Run Uex Command    bearer_del ue=1 eps_id=6
    sleep    20s
    Check test result for case11
    Stop All BTSLog And Download to Local
    #Stop_and_download Capture Emil Log

CB007035-SR-A-16 Deactivate NR SBHO B1-NR measurements with activating higher priority measurements
    [Documentation]    author:yahong.liu
    ...    case16
    ...    1. CB007742 enable, LTE4193-B disable, CB008218 enable, CB007035 enable
    ...    2. UE attach without volte Bearer,with QCIx bearer for NR SBHO
    ...    3. Check that start periodical NR SBHO B1-NR measurement activation after volteBearerProtectTimer expires
    ...    4. Higher priority measurements are triggered
    ...    5. High priority measurements are activated on UE
    ...    6. No NR SBHO B1-NR measurements activated on UE,B1-NR retryTimer is running on eNB
    #Start tcpdump in SBTS by command
    sleep    5min
    Start Multi Bts Log
    #Start Capture Emil Log
    UE1 Attach ENB1 Cell1 With Default Bearer QCI9
    Log To Console      ${\n}============= UE1 attach successfully. =============${\n}
    Log To Console      ${\n}============= volteBearerProtectTimer=8s. =============${\n}
    sleep    60s
    #To check NR SBHO B1-NR measurement activation
    Trigger UE1 to send B1NR then A2 measurement
    Log To Console      ${\n}=============Trigger B1NR then A2 measurement successfully. =============${\n}
    sleep    10s
    Trigger UE1 to send A3 measurement
    Log To Console      ${\n}=============Trigger A3 measurement successfully. =============${\n}
    sleep    60s
    Check test result for case16
    Stop All BTSLog And Download to Local
    #Stop_and_download Capture Emil Log
    #stop tcpdump in sbts by command

# CB007035-SR-A-17 NR SBHO B1-NR measurement report is received after high priority measurements activated
#     [Documentation]    author:yahong.liu
#     ...    case17
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     UE1 Attach ENB1 Cell1 With Default Bearer QCI9
#     Log To Console      ${\n}============= UE1 attach successfully. =============${\n}
#     Log To Console      ${\n}============= volteBearerProtectTimer=8s. =============${\n}
#     sleep    60s
#     #To check NR SBHO B1-NR measurement activation
#     Trigger UE1 to send A2 then B1NR measurement
#     Log To Console      ${\n}=============Trigger A2 then B1NR measurement successfully. =============${\n}
#     sleep    10s
#     Trigger UE1 to send A3 measurement
#     Log To Console      ${\n}=============Trigger A3 measurement successfully. =============${\n}
#     sleep    60s
#     Check test result for case17
#     Stop All BTSLog And Download to Local
#     stop tcpdump in sbts by command

*** Keywords ***
Suite Setup For CUS
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    [Arguments]    ${scf_file}    ${swconfig}    ${cus}
    #Common Suite Setup For Pet
    Common MultiBTS Suite Setup For RRM
    Setup For Ap  swconfig=${swconfig}  scf_file=${scf_file}  cus_yaml=${cus}
    Create Alias

Suite Teardown For CUS
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    #Common Suite Teardown For Pet
    Common MutliBTS Suite Teardown For RRM
    Run Keyword And Ignore Error  admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error  ute_fsmaccess.Teardown All Aliases For Enb Fsmaccess
    Run Keyword And Ignore Error  ute_fsmaccess.Teardown All Aliases For Wts Fsmaccess

Case Teardown For CUS
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Run Keyword And Ignore Error    Run Uex Command    ue_detach id=1
    Run Keyword And Ignore Error    stop tcpdump in sbts by command
    Run Keyword And Ignore Error    Stop All BTSLog And Download to Local
    Common MultiBTS Test Teardown For CUS

Create BTS Alias
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_2    enb_id=2    id_type=wts

Create UES Alias
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Log To Console    Create UES Alias
    FOR    ${ue_id}    IN RANGE    1    7
       Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Create Alias
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Create UES Alias
    Create BTS Alias
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Capture Bts Snapshot
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Log To Console     Capture Bts Snapshot
    coam.Collect Snapshot    target_file_name=${CASE_DIRE}/snapshot.zip    connection=master    timeout=1800

Start Capture CUS Btslog
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Set Suite Variable    ${BTSLOG_FILENAME}   ${CASE_DIRE}/btslog/btslog.log
    ${collector}=    Pet Create Btslog Collector    host=127.0.0.1    port=51000    password=uteUTE!
    ...              filename=${BTSLOG_FILENAME}
    Set Suite Variable          ${COLLECTOR_CUS}    ${collector}
    Pet Start Capture Btslog    ${COLLECTOR_CUS}

Stop Capture CUS Btslog
    [Documentation]
    ...    ...    author: yahong.liu@nokia-sbell
    Log To Console     Stop Capture CUS Btslog
    Pet Stop Capture Btslog    ${COLLECTOR_CUS}

Check NR SBHO B1-NR activated For BTS${i}
    Log To Console    Check NR SBHO B1-NR activated.
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a activating 5G SB HO B1NR meas due to timer expiration | grep -av grep
    Should Contain    ${ret}    activating 5G SB HO B1NR meas due to timer expiration

UE1 Attach ENB1 Cell1 With Default Bearer QCI9
    [Documentation]
    ...    author: yahong.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    20.11.2024,yahong.liu@nokia-sbell.com,case template draft
    Log To Console    UE1 Attach ENB1 Cell1 With Default Bearer QCI9
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( E-RABToBeSetupListCtxtSUReq contains ( e-RAB-ID eq 5 and qCI eq 9 ))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_1_attach    overall_timeout=30
    Run Uex Command    ue_attach id=1 enb=1 cell=1
    #Run Uex Command  trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps=60 duration=1200
    Flow Occurred As Expected    alias=UE_1_attach

UE2 Attach ENB1 Cell1 With Default Bearer QCI9 and QCI1
    [Documentation]
    ...    author: yahong.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    20.11.2024,yahong.liu@nokia-sbell.com,case template draft
    Log To Console    UE2 Attach ENB1 Cell1 With Default Bearer QCI9 and QCI1
    ${QCI9_QCI1}=    Catenate
    ...    E-RABToBeSetupListCtxtSUReq contains (
    ...    e-RAB-ID eq 5 and qCI eq 9,
    ...    e-RAB-ID eq 6 and qCI eq 1)
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest ( ${QCI9_QCI1})
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_2:RRC_RRCConnectionReconfiguration
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_2_attach    overall_timeout=30
    Run Uex Command    ue_attach id=2 enb=1 cell=1
    #Run Uex Command  trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps=60 duration=1200
    Flow Occurred As Expected    alias=UE_2_attach

Bearer QCI${qci_no} Added For UE${i}
    [Documentation]
    ...    author: yahong.liu@nokia-sbell.com
    Log To Console    Bearer QCI${qci_no} Added For UE${i}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest ( E-RABToBeSetupListBearerSUReq contains ( e-RAB-ID eq 6 and qCI eq ${qci_no} ))
    ...    alias=UE_${i}_QCI${qci_no}    overall_timeout=30
    Run Keyword And Ignore Error   Run Uex Command    bearer_add ue=${i} qci=${qci_no} mbr_ul=64 mbr_dl=64 gbr_ul=64 gbr_dl=64
    Flow Occurred As Expected    UE_${i}_QCI${qci_no}

Bearer QCI${qci_no} Delete For UE${i}
    [Documentation]
    ...    author: yahong.liu@nokia-sbell
    Log To Console    Bearer QCI${qci_no} Delete For UE${i}
    Run Keyword And Ignore Error   Run Uex Command    bearer_del ue=${i} eps_id=6

Trigger UE1 Reestablishment
    [Documentation]
    ...    author: yahong.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    20.11.2024,yahong.liu@nokia-sbell.com,case template draft
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReestablishmentRequest
    ...    UE_1:RRC_RRCConnectionReestablishment
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_1_RRCReestablish    overall_timeout=30
    Run Uex Command    ue_rrc_reestablish id=1 enb=1 cell=1 cause=otherFailure
    Flow Occurred As Expected    UE_1_RRCReestablish

Trigger UE2 Reestablishment
    [Documentation]
    ...    author: yahong.liu@nokia-sbell.com
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReestablishmentRequest
    ...    UE_2:RRC_RRCConnectionReestablishment
    ...    UE_2:RRC_RRCConnectionReconfiguration
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_2_RRCReestablish    overall_timeout=30
    Run Uex Command    ue_rrc_reestablish id=2 enb=1 cell=1 cause=otherFailure
    Flow Occurred As Expected    UE_2_RRCReestablish

Trigger UE1 to send A2 measurement with RSRP below threshold2NR
    Expect Message Flow
    ...    UE_1:RRC_MeasurementReport
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=measA2_UE1   overall_timeout=30
    Run Uex Command    ue_measurement_send id=1 event=A2 srsrp=30 srsrq=34
    Log To Console    UE_1 sends A2 srsrp=34
    Flow Occurred As Expected    measA2_UE1

Trigger UE1 to send A3 measurement
    Expect Message Flow
    ...    UE_1:RRC_MeasurementReport
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=measA3_UE1   overall_timeout=30
    Run Uex Command    ue_measurement_send id=1 event=A3 srsrp=20 srsrq=34 phycell_id=3 nrsrp=35 nrsrq=27
    Log To Console    UE_1 sends A3 srsrp=20 nrsrp=35
    Flow Occurred As Expected    measA3_UE1

Trigger UE1 to send B1NR measurement
    Expect Message Flow
    ...    UE_1:RRC_MeasurementReport
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=measB1NR_UE1   overall_timeout=30
    Run Uex Command    ue_measurement_send id=1 event=B1_NR phycell_id=2 narfcn=435850 nrsrp=97 nsinr=20 amount=1
    Log To Console    UE_1 sends B1_NR narfcn=435850 nrsrp=97
    Flow Occurred As Expected    measB1NR_UE1

Trigger UE1 to send B1NR then A2 measurement
    Expect Message Flow
    ...    UE_1:RRC_MeasurementReport
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=measB1NR_A2_UE1   overall_timeout=30
    Run Uex Command    ue_measurement_send id=1 event=B1_NR phycell_id=2 narfcn=435850 nrsrp=97 nsinr=20 amount=1
    Run Uex Command    ue_measurement_send id=1 event=A2 srsrp=30 srsrq=34
    Log To Console    UE_1 sends A2 srsrp=34
    Log To Console    UE_1 sends B1_NR narfcn=435850 nrsrp=97
    Flow Occurred As Expected    measB1NR_A2_UE1

Trigger UE1 to send A2 then B1NR measurement
    Expect Message Flow
    ...    UE_1:RRC_MeasurementReport
    ...    UE_1:RRC_RRCConnectionReconfiguration
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=measA2_B1NR_UE1   overall_timeout=30
    Run Uex Command    ue_measurement_send id=1 event=A2 srsrp=30 srsrq=34
    Run Uex Command    ue_measurement_send id=1 event=B1_NR phycell_id=2 narfcn=435850 nrsrp=97 nsinr=20 amount=1
    Log To Console    UE_1 sends A2 srsrp=34
    Log To Console    UE_1 sends B1_NR narfcn=435850 nrsrp=97
    Flow Occurred As Expected    measA2_B1NR_UE1

Set previous_timestamp
    [Arguments]     ${timestamp}    ${previous_timestamp}
    ${time_difference}   Subtract Date From Date   ${timestamp}   ${previous_timestamp}
    Should Be True    9<${time_difference}<10.5

Check test result for case03
    ${deactivating_B1NR_meas}    Set Variable    deactivating B1NR meas due to NrSbHo supervisionTimer expiration
    ${NEW_FILE}=    Write lines containing CB007035 to new file from log BTS0
    ${line_count_start_timer}=    Count Lines Containing String    ${NEW_FILE}    Starting voLteBearerProtectTimer
    ${line_count_timer_expired}=    Count Lines Containing String    ${NEW_FILE}    VoLteBearerProtectTimer expired - setting up measurements
    ${line_count_activating}=    Count Lines Containing String    ${NEW_FILE}    try to activate 5G SB HO B1NR meas due to timer expiration
    ${line_count_deactivating}=    Count Lines Containing String    ${NEW_FILE}    ${deactivating_B1NR_meas}
    Should Be True    ${line_count_start_timer} == 2    Expected 2 lines for Starting voLteBearerProtectTimer
    Should Be True    ${line_count_timer_expired} == 2    Expected 2 lines for VoLteBearerProtectTimer expired - setting up measurements
    Should Be True    ${line_count_activating} > 9    Expected more than 9 lines for try to activate 5G SB HO B1NR meas due to timer expiration
    Should Be True    ${line_count_deactivating} > 7    Expected more than 7 lines for ${deactivating_B1NR_meas}

# Check test result for case06
#     ${NEW_FILE}=    Write lines containing CB007035 to new file from log BTS0
#     ${not_activated}=    Set Variable    B1 will not be activated as active VoLTE/Mission Critical Video bearer is present
#     ${no_configure}=    Set Variable    no NRSBHO B1NR measurements to configure, triggering just the periodic retry
#     ${Activating_B1Nr}=    Set Variable    VoLTE/Mission Critical Video Bearer release detected. Activating B1Nr
#     ${Deactivating_B1Nr}=    Set Variable    VoLTE/Emergency/Mission Critical Video Bearer setup detected. Deactivating B1Nr
#     ${line_count_volte_bearer}=    Count Lines Containing String    ${NEW_FILE}    UE already has VoLTE/Mission Critical Video bearer
#     ${line_count_activating}=    Count Lines Containing String    ${NEW_FILE}    activating 5G SB HO B1NR meas due to timer expiration
#     ${line_count_not_activated}=    Count Lines Containing String    ${NEW_FILE}    ${not_activated}
#     ${line_count_no_configure}=    Count Lines Containing String    ${NEW_FILE}    ${no_configure}
#     ${line_count_Activating_B1Nr}=    Count Lines Containing String    ${NEW_FILE}    ${Activating_B1Nr}
#     ${line_count_Deactivating_B1Nr}=    Count Lines Containing String    ${NEW_FILE}     ${Deactivating_B1Nr}
#     Should Be True    ${line_count_volte_bearer} == 1    Expected 1 lines for UE already has VoLTE/Mission Critical Video bearer
#     Should Be True    ${line_count_activating} == 2     Expected 2 lines for activating 5G SB HO B1NR meas due to timer expiration
#     Should Be True    ${line_count_not_activated} == 1    Expected 1 lines for ${not_activated}
#     Should Be True    ${line_count_no_configure} == 1    Expected 1 lines for ${no_configure}
#     Should Be True    ${line_count_Activating_B1Nr} == 1    Expected 1 lines for ${Activating_B1Nr}
#     Should Be True    ${line_count_Deactivating_B1Nr} == 1    Expected 1 lines for ${Deactivating_B1Nr}

Check test result for case11
    ${NEW_FILE}=    Write lines containing CB007035 to new file from log BTS0
    ${activating}=    Set Variable    try to activate 5G SB HO B1NR meas due to timer expiration
    ${not_activated}=    Set Variable    B1 will not be activated as active VoLTE/Mission Critical Video bearer is present
    ${no_configure}=    Set Variable    no NRSBHO B1NR measurements to configure, triggering just the periodic retry
    ${Activating_B1Nr}=    Set Variable    Attempting B1-NR SBHO activation
    ${Bearer_setup}=    Set Variable    VoLTE/Emergency/Mission Critical Video Bearer setup detected
    ${Deactivating_B1Nr}=    Set Variable    Deactivating B1-NR SBHO measurements
    ${line_count_activating}=    Count Lines Containing String    ${NEW_FILE}    try to activate 5G SB HO B1NR meas due to timer expiration
    ${line_count_not_activated}=    Count Lines Containing String    ${NEW_FILE}    ${not_activated}
    ${line_count_no_configure}=    Count Lines Containing String    ${NEW_FILE}    ${no_configure}
    ${line_count_Activating_B1Nr}=    Count Lines Containing String    ${NEW_FILE}    ${Activating_B1Nr}
    ${line_count_Bearer_setup}=    Count Lines Containing String    ${NEW_FILE}    ${Bearer_setup}
    ${line_count_Deactivating_B1Nr}=    Count Lines Containing String    ${NEW_FILE}     ${Deactivating_B1Nr}
    Should Be True    ${line_count_activating} == 10     Expected 2 lines for ${activating}
    Should Be True    ${line_count_not_activated} == 5    Expected 1 lines for ${not_activated}
    Should Be True    ${line_count_no_configure} == 5    Expected 1 lines for ${no_configure}
    Should Be True    ${line_count_Activating_B1Nr} == 3    Expected 1 lines for ${Activating_B1Nr}
    Should Be True    ${line_count_Bearer_setup} == 3    Expected 1 lines for ${Bearer_setup}
    Should Be True    ${line_count_Deactivating_B1Nr} == 3    Expected 1 lines for ${Deactivating_B1Nr}

Check test result for case16
    ${No_B1NR_Measurement}    Set Variable    no NRSBHO B1NR measurements to configure, triggering just the periodic retry
    ${deactivating_B1NR_meas}    Set Variable    deactivating B1NR meas due to NrSbHo supervisionTimer expiration
    ${NEW_FILE}=    Write lines containing CB007035 to new file from log BTS0
    ${Store_Measurement_report}=    Count Lines Containing String    ${NEW_FILE}    Store Measurement report measId
    ${wait_highest_priority_report}=    Count Lines Containing String    ${NEW_FILE}    not highest priority frequency measurement report received
    ${Removing_measId_A2}=    Count Lines Containing String    ${NEW_FILE}    Removing measId: 7 from storage
    ${line_count_measurements}=    Count Lines Containing String    ${NEW_FILE}    B1 will not be activated due to mobility measurements
    ${line_count_periodic_retry}=    Count Lines Containing String    ${NEW_FILE}    ${No_B1NR_Measurement}
    ${line_count_start_timer}=    Count Lines Containing String    ${NEW_FILE}    Starting voLteBearerProtectTimer
    ${line_count_timer_expired}=    Count Lines Containing String    ${NEW_FILE}    VoLteBearerProtectTimer expired - setting up measurements
    ${line_count_activating}=    Count Lines Containing String    ${NEW_FILE}    try to activate 5G SB HO B1NR meas due to timer expiration
    ${line_count_deactivating}=    Count Lines Containing String    ${NEW_FILE}    ${deactivating_B1NR_meas}
    Should Be True    ${Store_Measurement_report} == 1    Expected 1 lines for Store Measurement report measId
    Should Be True    ${wait_highest_priority_report} == 1    Expected 1 lines for not highest priority frequency measurement report received
    Should Be True    ${Removing_measId_A2} == 2    Expected 1 lines for Removing measId: 7 from storage
    Should Be True    ${line_count_measurements} == 1    Expected 1 lines for B1 will not be activated due to mobility measurements
    Should Be True    ${line_count_periodic_retry} == 1    Expected 1 lines for ${No_B1NR_Measurement}
    Should Be True    ${line_count_start_timer} == 2    Expected 2 lines for Starting voLteBearerProtectTimer
    Should Be True    ${line_count_timer_expired} == 2    Expected 2 lines for VoLteBearerProtectTimer expired - setting up measurements
    Should Be True    ${line_count_activating} == 11    Expected more than 9 lines for try to activate 5G SB HO B1NR meas due to timer expiration
    Should Be True    ${line_count_deactivating} == 8    Expected more than 7 lines for ${deactivating_B1NR_meas}

# Check test result for case17
#     ${No_B1NR_Measurement}    Set Variable    no NRSBHO B1NR measurements to configure, triggering just the periodic retry
#     ${NEW_FILE}=    Write lines containing CB007035 to new file from log BTS0
#     ${Removing_measId_A2}=    Count Lines Containing String    ${NEW_FILE}    Removing measId: 7 from storage
#     ${line_count_measurements}=    Count Lines Containing String    ${NEW_FILE}    B1 will not be activated due to mobility measurements
#     ${line_count_periodic_retry}=    Count Lines Containing String    ${NEW_FILE}    ${No_B1NR_Measurement}
#     ${line_count_start_timer}=    Count Lines Containing String    ${NEW_FILE}    Starting voLteBearerProtectTimer
#     ${line_count_timer_expired}=    Count Lines Containing String    ${NEW_FILE}    VoLteBearerProtectTimer expired - setting up measurements
#     ${line_count_activating}=    Count Lines Containing String    ${NEW_FILE}    activating 5G SB HO B1NR meas due to timer expiration
#     ${line_count_deactivating}=    Count Lines Containing String    ${NEW_FILE}    deactivating B1NR meas due to supervisionTimerB1NR expiration
#     Should Be True    ${Removing_measId_A2} == 2    Expected 1 lines for Removing measId: 7 from storage
#     Should Be True    ${line_count_measurements} == 1    Expected 1 lines for B1 will not be activated due to mobility measurements
#     Should Be True    ${line_count_periodic_retry} == 1    Expected 1 lines for ${No_B1NR_Measurement}
#     Should Be True    ${line_count_start_timer} == 2    Expected 2 lines for Starting voLteBearerProtectTimer
#     Should Be True    ${line_count_timer_expired} == 2    Expected 2 lines for VoLteBearerProtectTimer expired - setting up measurements
#     Should Be True    ${line_count_activating} == 11    Expected 11 lines for activating 5G SB HO B1NR meas due to timer expiration
#     Should Be True    ${line_count_deactivating} == 8    Expected 8 lines for deactivating B1NR meas due to supervisionTimerB1NR expiration

Write lines containing CB007035 to new file from log BTS${i}
    ${NEW_FILE}=    Set Variable    ${TEST_LOG_DIRECTORY}/newfile.txt
    Create File    ${NEW_FILE}    This is the content of the new file.
    #${command}=    Set Variable    cat ${BTS${i}_LOG_PATH} | grep -a "CB007035" | grep -av grep > ${NEW_FILE}
    ${kw1}=    Set Variable    Store Measurement
    ${kw2}=    Set Variable    Removing measId
    ${kw3}=    Set Variable    deactivateMeasurementsByType
    ${kw4}=    Set Variable    UecErabMeasurementReconfiguratorB1NrSbHo
    ${command}=    Set Variable    cat ${BTS${i}_LOG_PATH} | grep -a -E "CB007035|${kw1}|${kw2}|${kw3}|${kw4}" | grep -av grep > ${NEW_FILE}
    ${result}=     Run Process     ${command}    shell=True
    [Return]    ${NEW_FILE}

Count Lines Containing String
    [Arguments]    ${NEW_FILE}    ${SEARCH_STRING}
    ${command}=    Set Variable    grep -c "${SEARCH_STRING}" ${NEW_FILE}
    ${result}=     Run Process     ${command}    shell=True    stdout=stdout
    ${line_count}=    Set Variable    ${result.stdout.strip()}
    Log    Number of lines: ${line_count}
    [Return]    ${line_count}

Check voLteBearerProtectTimer
    [Arguments]    ${Starting_voLteBearerProtectTimer_timestamp}  ${activating_timestamp}
    Log To Console    voLteBearerProtectTimer expired
    ${time_difference}    Subtract Date From Date    ${activating_timestamp}    ${Starting_voLteBearerProtectTimer_timestamp}
    Should Be True    8<${time_difference}<9.2

Check Supervisiontimer
    [Arguments]    ${deactivating_timestamp}  ${activating_timestamp}
    Log To Console    voLteBearerProtectTimer expired
    ${time_difference}    Subtract Date From Date   ${deactivating_timestamp}   ${activating_timestamp}
    Should Be True   2<${time_difference}<3.3

Check retrytimer
    [Arguments]     ${ret}
    Log To Console    retrytimer
    @{activating_line}    Evaluate    re.findall(r'.*activating 5G SB HO B1NR.*', '''${ret}''')    re
    ${lineNum}=    Split String      ${ret}    activating 5G SB HO B1NR
    ${lennum}=    Get length    ${lineNum}
    Should Be True  ${lennum}>3
    ${index}    Set Variable    ${0}
    ${previous_timestamp}     Set Variable    ${None}
    FOR    ${line}    IN    @{activating_line}
        ${timestamp}    Evaluate    str(re.search(r'<(.*?)>', '''${line}''').group(1))    re
        ${index}    Set Variable     ${index+1}
        ${previous_timestamp}   Set Variable if   ${index}==1   ${timestamp}
        ...    ${previous_timestamp}
        Continue For Loop If    ${index}==1
        Set previous_timestamp   ${timestamp}    ${previous_timestamp}
        ${previous_timestamp}    Set Variable     ${timestamp}
    END

Start Capture Emil Log
    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil    product_type=enb    bts_index=${0}    dict_argument=${dict_argument}

Stop_and_download Capture Emil Log
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=enb    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}
