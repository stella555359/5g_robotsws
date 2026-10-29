*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that measurement period change for LTE counters works properly

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${PMRNL_PARAMETER_INTERVAL}  ${EMPTY}
# Provide the list of LTE measurements with target intervals. For example 'mtCellLoad=15min,mtCellAvailability=60min,mtCellThruput=30min'


*** Keywords ***
TC__PM__LTE_measurement_interval_change_from_longer_to_shorter
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  *******************
    ...  History of changes
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-lukasz.targonski@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Should Not Be Equal As Strings  ${PMRNL_PARAMETER_INTERVAL}  ${EMPTY}  msg=Parameter name from PMRNL not provided.
    Step 0: Preconditions
    Step 1: Download PM From BTS
    Step 2: Change Measurements Interval
    Step 3: Check Incomplete Previous PM
    Step 4: Download PM From BTS
    Step 5: Change Back Measurement Interval


Step 0: Preconditions
    Create PMRNL Dictionary
    Verify LTE Cells States

    ${parameters_list}  Get Regexp Matches  ${PMRNL_PARAMETER_INTERVAL}  [a-zA-Z]{4,}
    ${interval_list}  Get Regexp Matches  ${PMRNL_PARAMETER_INTERVAL}  \\d*min
    Set Test Variable  ${PARAMETERS_LIST}
    Set Test Variable  ${INTERVAL_LIST}
    ${measurement_verdict}  Create Dictionary
    Set Test Variable  ${MEASUREMENT_VERDICT}

    Run Keyword If  '${INTERVAL_LIST}[0]'=='15min'
    ...  Change Initial Values If Needed  15min  30min
    ...  ELSE
    ...  Change Initial Values If Needed  30min  60min


Step 1: Download PM From BTS
    Log  Step1: Pm report is being downloaded from BTS, counter(s) presence is being checked  console=true
    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${backup_interval_list}  Create List
    ${current_interval_list}  Create List

    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        ${interval}  Get Scf Parameter  ${parameter}
        Append To List  ${current_interval_list}  ${interval}
        Append To List  ${backup_interval_list}  ${interval}
    END

    Set Test Variable  ${BACKUP_INTERVAL_LIST}
    Set Test Variable  ${CURRENT_INTERVAL_LIST}
    ${previous_interval_list}  Copy List  ${CURRENT_INTERVAL_LIST}
    Set Test Variable  ${PREVIOUS_INTERVAL_LIST}
    ${uptime}  Check BTS Uptime In Minutes
    Wait For Measurement Start Time  ${uptime}  ${CURRENT_INTERVAL_LIST}
    Setup Measurement_Dictionary
    ${hour}  Get Time  hours  UTC
    ${hour}  Convert Time  ${hour}
    ${minutes}  Get Time  minutes
    ${minutes}  Convert Time  ${minutes}
    Set Test Variable  ${PREVIOUS_TIME}  0
    FOR  ${key}  IN  @{MEASUREMENT_DICTIONARY.keys()}
        Run Keyword If  '${MEASUREMENT_DICTIONARY["${key}"]}'=='true'
        ...  Run Keywords
        ...  Wait For BTS Counters  ${key}  ${hour}  ${minutes}
        ...  AND
        ...  Check BTS Counters  ${key}  ${hour}  ${minutes}
    END
    Teardown All Aliases
    FOR  ${key}  IN  @{MEASUREMENT_VERDICT.keys()}
        Run Keyword If  '${MEASUREMENT_VERDICT["${key}"]}'=='true'
        ...  Log  Measurement ${key} found in PM report  console=true
        ...  ELSE
        ...  Set Test Failed  Measurement ${key} not found in PM report.
    END


Step 2: Change Measurements Interval
    Log  Step2: Measurement interval is being changed  console=true
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID

    ${wait_before_parameter_mod}  Evaluate  random.randint(60,180)  modules=random
    Log  Going to Sleep for ${wait_before_parameter_mod} seconds  console=true
    Sleep  ${wait_before_parameter_mod}

    ${delta_id}  Set Variable  measurement_change
    coam.Create Delta  ${delta_id}

    ${parameters_list_length}  Get Length  ${PARAMETERS_LIST}
    FOR  ${int}  IN RANGE  0  ${parameters_list_length}
        coam.Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/PMRNL-1  ${PARAMETERS_LIST[${int}]}  ${INTERVAL_LIST[${int}]}
        ...  ${delta_id}
        Log  Value of parameter ${PARAMETERS_LIST[${int}]} will be changed to ${INTERVAL_LIST[${int}]}  console=true
    END
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_1.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_1.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Step 3: Check Incomplete Previous PM
    Log  Step3: Check incomplete previous PM report  console=true
    coam.Get Current Scf File  ${BTS_FILES}  scf_mod.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/scf_mod.xml
    ${current_interval_list}  Create List
    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        ${interval}  Get Scf Parameter  ${parameter}
        Append To List  ${current_interval_list}  ${interval}
    END
    Set Test Variable  ${PREVIOUS_TIME}  0
    Set Test Variable  ${CURRENT_INTERVAL_LIST}

    Setup Measurement_Dictionary

    ${hour}  Get Time  hours  UTC
    ${hour}  Convert Time  ${hour}
    ${minutes}  Get Time  minutes
    ${minutes}  Convert Time  ${minutes}

    FOR  ${key}  IN  @{MEASUREMENT_DICTIONARY.keys()}
        Run Keyword If  '${MEASUREMENT_DICTIONARY["${key}"]}'=='true'
        ...  Run Keywords
        ...  Wait For BTS Counters  ${key}  ${hour}  ${minutes}
        ...  AND
        ...  Check BTS Counters  ${key}  ${hour}  ${minutes}
    END
    Teardown All Aliases
    FOR  ${key}  IN  @{MEASUREMENT_VERDICT.keys()}
        Run Keyword If  '${MEASUREMENT_VERDICT["${key}"]}'=='true'
        ...  Log  Measurement ${key} found in PM report  console=true
        ...  ELSE
        ...  Set Test Failed  Measurement ${key} not found in PM report.
    END


Step 4: Download PM From BTS
    Log  Step4: Pm file is being downloaded from BTS, counter(s) presence is being checked  console=true
    coam.Get Current Scf File  ${BTS_FILES}  scf_mod.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/scf_mod.xml
    ${current_interval_list}  Create List
    FOR  ${parameter}  IN  @{PARAMETERS_LIST}
        ${interval}  Get Scf Parameter  ${parameter}
        Append To List  ${current_interval_list}  ${interval}
    END
    Set Test Variable  ${PREVIOUS_TIME}  0
    Set Test Variable  ${CURRENT_INTERVAL_LIST}
    ${previous_interval_list}  Copy List  ${CURRENT_INTERVAL_LIST}
    Set Test Variable  ${PREVIOUS_INTERVAL_LIST}
    Setup Measurement_Dictionary

    ${hour}  Get Time  hours  UTC
    ${hour}  Convert Time  ${hour}
    ${minutes}  Get Time  minutes
    ${minutes}  Convert Time  ${minutes}
    FOR  ${key}  IN  @{MEASUREMENT_DICTIONARY.keys()}
        Run Keyword If  '${MEASUREMENT_DICTIONARY["${key}"]}'=='true' and '${key}'!='15min' and '${key}'!='30min'
        ...  Wait For BTS Counters  ${key}  ${hour}  ${minutes}
        Run Keyword If  '${MEASUREMENT_DICTIONARY["${key}"]}'=='true'
        ...  Check BTS Counters  ${key}  ${hour}  ${minutes}
    END
    Teardown All Aliases
    FOR  ${key}  IN  @{MEASUREMENT_VERDICT.keys()}
        Run Keyword If  '${MEASUREMENT_VERDICT["${key}"]}'=='true'
        ...  Log  Measurement ${key} found in PM report  console=true
        ...  ELSE
        ...  Set Test Failed  Measurement ${key} not found in PM report.
    END


Step 5: Change Back Measurement Interval
    Log  Step5: Measurement interval values are changed back to previous values  console=true
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID

    ${delta_id}  Set Variable  measurement_back
    coam.Create Delta  ${delta_id}

    ${parameters_list_length}  Get Length  ${PARAMETERS_LIST}
    FOR  ${int}  IN RANGE  0  ${parameters_list_length}
        coam.Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${lnbts_id}/PMRNL-1  ${PARAMETERS_LIST[${int}]}  ${BACKUP_INTERVAL_LIST[${int}]}
        ...  ${delta_id}
        Log  Value of parameter ${PARAMETERS_LIST[${int}]} will be changed back to ${BACKUP_INTERVAL_LIST[${int}]}  console=true
    END
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_2.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Change Initial Values If Needed
    [Arguments]  ${ref_value}  ${new_initial_value}

    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    ${status}  ${cell_avail_initial_val}  Run Keyword And Ignore Error
    ...  Get Scf Parameter  mtCellAvailability
    ${cell_avail_initial_val}  Set Variable If  '${status}'=='FAIL' or '${cell_avail_initial_val}'=='disabled'  0min  ${cell_avail_initial_val}
    ${condition}  Set Variable  '${cell_avail_initial_val}'<='${ref_value}'
    Run Keyword If  ${condition}
    ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/LNBTS-${lnbts_id}/PMRNL-1
    ...  mtCellAvailability
    ...  update
    ...  ${new_initial_value}
    ...  skip_parameter_relation_errors=True

    ${cell_avail_new_initial_val}  Set Variable If  ${condition}  ${new_initial_value}  ${cell_avail_initial_val}
    ${status}  ${cell_thruput_initial_val}  Run Keyword And Ignore Error
    ...  Get Scf Parameter  mtCellThruput
    Run Keyword If  '${status}'=='FAIL' or '${cell_thruput_initial_val}'!='${cell_avail_new_initial_val}'
    ...  coam.Perform Parameter Recommissioning  MRBTS-${bts_id}/LNBTS-${lnbts_id}/PMRNL-1
    ...  mtCellThruput
    ...  update
    ...  ${cell_avail_new_initial_val}
    ...  skip_parameter_relation_errors=True
    Return From Keyword If  not ${condition}
    Sleep Until New Cycle  minutes_for_cycle=${cell_avail_initial_val}
    Sleep Until New Cycle  minutes_for_cycle=${new_initial_value}  additional_condition=${True}

    [Teardown]  Teardown Pm


Wait For BTS Counters
    [Arguments]  ${measurement_interval}  ${hour}  ${minutes}

    ${measurement_interval}  Set Variable If  '${measurement_interval}'=='15min'  1  '${measurement_interval}'=='30min'  1
    ...  '${measurement_interval}'=='60min'  1  '${measurement_interval}'=='360min'  6  '${measurement_interval}'=='720min'  12
    ...  '${measurement_interval}'=='1440min'  24
    Run Keyword If
    ...  '${measurement_interval}'=='1' or '${measurement_interval}'!='6' or '${measurement_interval}'!='12' or '${measurement_interval}'!='24'
    ...  Log  Correct interval value: ${measurement_interval}  console=true
    ...  ELSE
    ...  Set Test Failed  Incorrect interval value: ${measurement_interval}

    ${measurement_availability_hour}  Evaluate  (int(${hour}/${measurement_interval})+1)*${measurement_interval}
    ${time}  Evaluate  int(60*(61-${minutes})+3600*(${measurement_availability_hour}-${hour}-1))
    ${time_diff}  Evaluate  ${time}-${PREVIOUS_TIME}
    ${current_date}  Get Current Date  UTC
    ${measurement_availability_time}  Add Time To Date  ${current_date}  ${time_diff}

    Run Keyword If  ${time_diff}>0
    ...  Run Keywords
    ...  Set Test Variable  ${PREVIOUS_TIME}  ${time}
    ...  AND
    ...  Log  Wait until ${measurement_availability_time} UTC for LTE measurement to appear on ram  console=true
    ...  AND
    ...  Sleep  ${time_diff}


Check BTS Counters
    [Arguments]  ${interval}  ${hour}  ${minutes}

    ${parameters_list_range}  Get Length  ${PARAMETERS_LIST}
    FOR  ${int}  IN RANGE  0  ${parameters_list_range}
        Run Keyword If  '${CURRENT_INTERVAL_LIST[${int}]}'=='${interval}'
        ...  Run Keywords
        ...  Set To Dictionary  ${MEASUREMENT_VERDICT}  ${PARAMETERS_LIST[${int}]}  false
        ...  AND
        ...  Calculate Target Interval  ${int}  ${hour}  ${minutes}
        ...  AND
        ...  Loop Over Parameters  ${PARAMETERS_LIST[${int}]}
    END


Calculate Target Interval
    [Arguments]  ${int}  ${hour}  ${minutes}

    ${previous_interval}  Get Regexp Matches  ${PREVIOUS_INTERVAL_LIST[${int}]}  \\d{2,}
    ${current_interval}  Get Regexp Matches  ${CURRENT_INTERVAL_LIST[${int}]}  \\d{2,}

    ${current_time_in_minutes}  Evaluate  ${hour}*60+${minutes}
    ${current_measurement_availability_time}  Evaluate
    ...  int((${current_time_in_minutes}+${current_interval[0]})/${current_interval[0]})*${current_interval[0]}
    ${previous_measurement_availability_time}  Evaluate
    ...  int((${current_time_in_minutes}+${previous_interval[0]})/${previous_interval[0]})*${previous_interval[0]}

    ${calculated_interval}  Evaluate  ${previous_interval[0]}-(${previous_measurement_availability_time}-${current_measurement_availability_time})
    Set Test Variable  ${CALCULATED_INTERVAL}  ${calculated_interval}min


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


Loop Over Parameters
    [Documentation]
    ...  This keyword checks if measurement interval is correctly reported in downloaded PM report xml file for each measurement name
    ...  provided by the user as the test case input.
    [Arguments]  ${parameter}

    Read PM File
    ${time}  Get Current Date
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/PM_REPORT_${parameter}_${CALCULATED_INTERVAL}_${time}.xml
    Run Keyword If  ${output}
    ...  Log  PM Report is present in ram disk!  console=true
    ...  ELSE
    ...  FAIL  PM Report not present in ram disk
    ${interval}  Get Regexp Matches  ${CALCULATED_INTERVAL}  \\d{2,}
    Log  Value of parameter ${parameter} is set to ${CALCULATED_INTERVAL}  console=true
    ${measurement_type}  Get From Dictionary  ${PMRNL_DICTIONARY}  ${parameter}
    ${o_me_s}  Parse XML  ${BTS_FILES}/PM_REPORT_${parameter}_${CALCULATED_INTERVAL}_${time}.xml
    ${xpath_result}  Evaluate Xpath  ${o_me_s}
    ...  //PMSetup[@interval="${interval[0]}"]/PMMOResult/NE-WBTS_1.0[@measurementType="${PMRNL_DICTIONARY["${parameter}"]}"]
    Run Keyword If  '${xpath_result}'!='[]'
    ...  Set To Dictionary  ${MEASUREMENT_VERDICT}  ${parameter}  true


Setup Measurement_Dictionary
    ${measurement_dictionary}  Create Dictionary  15min=false  30min=false  60min=false  360min=false  720min=false  1440min=false
    Set Test Variable  ${MEASUREMENT_DICTIONARY}
    FOR  ${interval}  IN  @{CURRENT_INTERVAL_LIST}
        Run Keyword If  '${interval}'=='15min'
        ...  Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
        Run Keyword If  '${interval}'=='30min'
        ...  Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
        Run Keyword If  '${interval}'=='60min'
        ...  Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
        Run Keyword If  '${interval}'=='360min'
        ...  Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
        Run Keyword If  '${interval}'=='720min'
        ...  Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
        Run Keyword If  '${interval}'=='1440min'
        ...  Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
    END


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown  collect_snapshot=never
