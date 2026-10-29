*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that LTE measurement disabling mechanism works properly on SBTS

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${PMRNL_PARAMETER}  ${EMPTY}
# Provide the list of LTE measurements with target intervals. For example 'mtCellLoad=15min,mtCellAvailability=60min,mtCellThruput=30min'


*** Keywords ***
TC__PM__LTE_measurements_disabling_with_validation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  *******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30356 - Add faults for watchdog
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-iuliia.taupeka@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Should Not Be Equal As Strings  ${PMRNL_PARAMETER}  ${EMPTY}  msg=Parameter name from PMRNL not provided.
    Step 0: Test Preconditions
    Step 1: Download PM From BTS And Check Counters Presence
    Step 2: Disable LTE Measurements


Step 0: Test Preconditions
    Log  \n----- Step0: Test Preconditions ----- \n  console=true
    Create PMRNL Dictionary
    ${bts_id}  Admin Get BTS ID
    Set Test Variable  ${BTS_ID}
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}

    Log  ReportingInterval will be checked to 15 min if value differs.  console=true
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${reporting_interval_in_seconds}  Get Reporting Interval  # Value is in seconds
    ${reporting_interval}  Evaluate  int(${reporting_interval_in_seconds}/60)  # Convert value to minutes
    Log  Reporting Interval Read from bts= ${reporting_interval}  console=true
    Run Keyword If  ${reporting_interval} != 15
    ...  Change Reporting Interval To Lowest Value

    Log  All tested LTE measurements interval will be set to 15 min.  console=true
    ${parameters_list}  Get Regexp Matches  ${PMRNL_PARAMETER}  [a-zA-Z1-9][^,]*
    Log  Parameters to be disabled list: ${parameters_list}  console=true
    Set Test Variable  ${PARAMETERS_LIST}
    ${interval_list}  Create List
    FOR  ${elem}  IN  @{PARAMETERS_LIST}
        ${interval}  Get Scf Parameter  ${elem}
        Append To List  ${interval_list}  ${interval}
    END

    Set Test Variable  ${INTERVAL_LIST}
    Change Measurement Intervals To The Lowest Value

    ${time_to_wait_for_pm_report}  Calculate Time Till End Of Shortest Reporting Interval
    Log  Waiting till end of reporting interval ${time_to_wait_for_pm_report} minutes  console=true
    Sleep  ${time_to_wait_for_pm_report}m

    [Teardown]  Teardown PM


Step 1: Download PM From BTS And Check Counters Presence
    Log  \n----- Step1: PM report is downloading from BTS, counter(s) presence checking. ----- \n  console=true
    coam.Get Current Scf File  ${BTS_FILES}  scf2.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf2.xml
    Set Test Variable  ${PM_REPORT_NAME_BEFORE_DISABLING}  PM_REPORT_before_counters_disabling.xml
    Read PM File
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/${PM_REPORT_NAME_BEFORE_DISABLING}
    Run Keyword If  ${output}
    ...  Log  PM report is present in ram disk!  console=true
    ...  ELSE
    ...  FAIL  PM Report not present in ram disk
    Check BTS Counters Presence

    [Teardown]  Teardown PM


Step 2: Disable LTE Measurements
    Log  \n----- Step3: Disable LTE Measurements. ----- \n  console=true
    ${wait_before_measurements_disabling}  Evaluate  random.randint(180,600)  modules=random
    Log  Going to sleep for ${wait_before_measurements_disabling} seconds  console=true
    Sleep  ${wait_before_measurements_disabling}
    Disable Measurements
    coam.Get Current Scf File  ${BTS_FILES}  scf_after_disabling.xml  with_auto_configured_parameters=${TRUE}
    Set Test Variable  ${PM_REPORT_NAME_AFTER_DISABLING}  PM_REPORT_after_counters_disabled.xml
    Setup Pm  scf_path=${BTS_FILES}/scf_after_disabling.xml

    ${time_to_wait_for_pm_report}  Calculate Time Till End Of Shortest Reporting Interval
    Log  Waiting till end of reporting interval ${time_to_wait_for_pm_report} minutes  console=true
    Sleep  ${time_to_wait_for_pm_report}m

    Read PM File
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/${PM_REPORT_NAME_AFTER_DISABLING}
    Check BTS Counters Absenсe

    [Teardown]  Teardown PM


Calculate Time Till End Of Shortest Reporting Interval
    ${time_now}  Get Time
    Log  Current time after reconfiguration ${time_now}
    ${minutes_now}  Get Time  minutes
    ${minutes_now}  Convert To Integer  ${minutes_now}
    Log  Timestamp (minutes) of reconfiguration ${minutes_now}  console=true
    ${waiting_time_for_pm_report}  Evaluate  int(15 - ${minutes_now}%15 + 1)
    ${time}  Evaluate  int(15-${minutes_now}%15)

    RETURN  ${waiting_time_for_pm_report}


Change Reporting Interval To Lowest Value
    Log  \n----- Reporting Interval Is Changed to 15 min ----- \n  console=true
    coam.Perform Parameter Recommissioning  MRBTS-${BTSID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  update  15min
    ...  skip_parameter_relation_errors=True


Change Measurement Intervals To The Lowest Value
    ${num_of_measurements}  Get Length  ${PARAMETERS_LIST}
    ${delta_id}  Set Variable  shortest_int
    coam.Create Delta  ${delta_id}
    ${recommissioning_needed}  Set Variable  0

    FOR  ${int}  IN RANGE  0  ${num_of_measurements}
        Run Keyword If  '${INTERVAL_LIST[${int}]}'!='15min'
        ...  Run Keywords
        ...  coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/PMRNL-1  ${PARAMETERS_LIST[${int}]}  15min  ${delta_id}
        ...  AND
        ...  Change Reconfiguration Needed Parameter  ${recommissioning_needed}
        ...  AND
        ...  Log  Parameter ${PARAMETERS_LIST[${int}]} will be changed from ${INTERVAL_LIST[${int}]} to 15min.  console=true
        ...  ELSE
        ...  Log  Parameter ${PARAMETERS_LIST[${int}]} = ${INTERVAL_LIST[${int}]} remains unchanged.  console=true
    END

    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_shortest.json  ${delta_id}
    Run Keyword If  ${recommissioning_needed}>0
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_shortest.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Change Reconfiguration Needed Parameter
    [Arguments]  ${recommissioning_needed}

    ${recommissioning_needed}  Evaluate  ${recommissioning_needed} + 1
    Set Suite Variable  ${RECOMMISSIONING_NEEDED}


Disable Measurements
    ${num_of_measurements}  Get Length  ${PARAMETERS_LIST}
    ${delta_id}  Set Variable  disable_meas
    coam.Create Delta  ${delta_id}

    FOR  ${int}  IN RANGE  0  ${num_of_measurements}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/PMRNL-1  ${PARAMETERS_LIST[${int}]}  disabled  ${delta_id}
        Log  Parameter ${PARAMETERS_LIST[${int}]} will be changed to disabled  console=true
    END

    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_disable_meas.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_disable_meas.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Check BTS Counters Presence
    ${int}  Set Variable  0
    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        Loop Over Parameters LTE15min  ${parameter}  ${int}
        ${int}  Evaluate  ${int}+1
    END


Check BTS Counters Absenсe
    ${int}  Set Variable  0
    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        Loop Over Parameters For Disabled  ${parameter}
        ${int}  Evaluate  ${int}+1
    END


Create PMRNL Dictionary
    ${pmrnl_dictionary}  Create Dictionary  mtActUsersLatencyPMQAPProfile=LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    ...  mtBBPooling=LTE_Baseband_Pool_Monitoring  mtBroadcast=LTE_Broadcast  mtCatmAccessibility=Cat_M_Accessibility  mtCatmMobility=Cat_M_Mobility
    ...  mtCatmRetainability=Cat_M_Retainability  mtCellAvailability=LTE_Cell_Avail  mtCellLoad=LTE_Cell_Load  mtCellRes=LTE_Cell_Resource
    ...  mtCellSpare=LTE_Cell_Spare_Counters  mtCellThruput=LTE_Cell_Throughput  mtDacWordStatistics=LTE_DAC_Word_Statistics
    ...  mtDataVolThrPMQAPProfile=LTE_Data_Volume_and_Throughput_Statistics_per_PMQAP_Profile  mtEPSBearer=LTE_EPS_Bearer
    ...  mtERABPMQAPProfile=LTE_ERAB_Statistics_per_PMQAP_Profile  mtEutraFrequency=LTE_EUTRA_carrier_frequency  mtFZAPGNSS=LTE_FZAP_GNSS
    ...  mtGNSS=LTE_GNSS  mtHoRlf=LTE_HO_RLF_trigger  mtInterHomeeNBHo=LTE_Inter_Home_eNB_Handover  mtInterSiteX2=Inter_site_X2
    ...  mtInterSysHo=LTE_Inter_Sys_HO  mtInterSysHoEhrpdBc=LTE_HO_eHRPD_per_eHRPD_BClass  mtInterSysHoGsmNb=LTE_ISYS_HO_GSM_NB
    ...  mtInterSysHoUtranNb=LTE_ISYS_HO_UTRAN_NB  mtIntereNBHo=LTE_Inter_eNB_HO  mtIntereNBS1Ho=LTE_Inter_eNB_via_S1_Handover
    ...  mtIntereNBX2Ho=LTE_Inter_eNB_via_X2_Handover  mtIntraeNBHo=LTE_Intra_eNB_HO  mtIntraeNBHoExt=LTE_Intra_eNB_Handover_Extension
    ...  mtLTEHo=LTE_Handover  mtLTEM=LTE_M_per_LNCEL  mtLTEMbmsLNBTS=LTE_MBMS_per_LNBTS  mtLTEMbmsMbsfnArea=LTE_MBMS_per_MBSFN_Area
    ...  mtLTEMperLNBTS=LTE_M_per_LNBTS  mtLaaResource=LTE_LAA_Resource  mtLteULaaResources=LTE_LTEU_LAA_Resource
    ...  mtM3SctpStatistics=LTE_M3_SCTP_Statistics  mtMAC=LTE_MAC  mtMBMS=LTE_MBMS  mtMobilityEvents=LTE_Mobility_Events
    ...  mtMroUtranFrequency=LTE_MRO_UTRAN_frequency_related  mtNBIoT=LTE_NB_IoT  mtNetwSharing=LTE_Network_Sharing
    ...  mtPIMCancellation=PIM_Cancellation  mtPowQualDL=LTE_Pwr_and_Qual_DL  mtPowQualUL=LTE_Pwr_and_Qual_UL  mtProSe=LTE_Proximity_Services
    ...  mtQoS=LTE_QoS  mtRIP=LTE_Received_Interference_Power  mtRLFPMQAPProfile=LTE_RLF_Statistics_per_PMQAP_Profile  mtRRC=LTE_RRC
    ...  mtRSRPRSRQHist=LTE_RSRP_and_RSRQ_Histogram  mtRadBearer=LTE_Radio_Bearer  mtRanSharing=LTE_RAN_Sharing  mtS1AP=LTE_S1AP
    ...  mtS1SctpStatistics=LTE_S1_SCTP_Statistics  mtSIMonitoring=LTE_Sales_Item_Monitoring  mtSINR=LTE_SINR  mtSfp=LTE_SFP
    ...  mtTranspLoad=LTE_Transport_Load  mtUEQuantity=LTE_UE_Quantity  mtUEandServiceDiff=LTE_UE_and_ServDiff  mtUEstate=LTE_UE_State
    ...  mtVoLTEBLERHist=LTE_VoLTE_BLER_Histogram  mtVoLTEVoiceBPerioHist=LTE_VoLTE_Voice_Break_Period_Histogram  mtX2AP=LTE_X2AP
    ...  mtX2SctpStatistics=LTE_X2_SCTP_Statistics  mtX2gNB=LTE_X2_gNB  mtX2gNBperCell=LTE_X2_gNB_per_LNCEL  mteNBSpare=LTE_eNB_Spare_Counters
    ...  mteNBload=LTE_eNB_Load  mtintraLTEHoNb=LTE_Neighb_Cell_HO
    Set Test Variable  ${PMRNL_DICTIONARY}


Loop Over Parameters LTE15min
    [Arguments]  ${parameter}  ${int}

    ${measurement_type}  Get From Dictionary  ${PMRNL_DICTIONARY}  ${parameter}
    Log  Value of parameter ${parameter} is set to ${INTERVAL_LIST[${int}]}  console=true
    ${measurement_type}  Get From Dictionary  ${PMRNL_DICTIONARY}  ${parameter}
    ${grep}  OperatingSystem.Grep File  ${BTS_FILES}/${PM_REPORT_NAME_BEFORE_DISABLING}  ${measurement_type}
    ${grep}  Run Keyword And Ignore Error
    ...  Should Not Be Empty  ${grep}
    Run Keyword If  '${INTERVAL_LIST[${int}]}'=='15min' and '${grep[0]}'=='FAIL'
    ...  FAIL  measurementType= "${measurement_type}" is not present in PM report
    Run Keyword If  '${INTERVAL_LIST[${int}]}'=='15min' and '${grep[0]}'=='PASS'
    ...  Log  measurementType= "${measurement_type}" is present in PM report  console=true


Loop Over Parameters For Disabled
    [Arguments]  ${parameter}

    ${measurement_type}  Get From Dictionary  ${PMRNL_DICTIONARY}  ${parameter}
    Log  Checking that ${parameter} is disabled.  console=true
    ${grep}  OperatingSystem.Grep File  ${BTS_FILES}/${PM_REPORT_NAME_AFTER_DISABLING}  ${measurement_type}
    ${grep}  Run Keyword And Ignore Error
    ...  Should Not Be Empty  ${grep}
    Run Keyword If  '${grep[0]}'=='FAIL'
    ...  Log  measurementType= "${measurement_type}" is not present in PM report(expected)  console=true
    Run Keyword If  '${grep[0]}'=='PASS'
    ...  FAIL  measurementType= "${measurement_type}" is present in PM report


TC Setup
    Common Test Setup  tc_name=PM__LTE_measurements_disabling_with_validation


TC Teardown
    Common Test Teardown
