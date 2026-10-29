*** Settings ***
Documentation
    ...  Purpose of this test case is to verify that measurement period change for NR counters works properly.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${NRPMRNL_PARAMETER_INTERVAL}  ${EMPTY}  # Mandatory. Provide the list of NR measurements with target intervals.
# For example 'miNrCellAvailability=15min, miNrNgInterface=30min'.


*** Keywords ***
TC__PM__NR_measurement_interval_change_from_longer_to_shorter
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27569
    ...
    ...  *******************
    ...  History of changes
    ...  - 30.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - Initial TC creation
    ...  - 20.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27692 - Change value type for measurement interval
    ...  - 20.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27759 - Update preconditions
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT

    Step 0: Preconditions
    Step 1: Download PM From BTS
    Step 2: Change Measurements Interval
    Step 3: Check Incomplete Previous PM
    Step 4: Download PM From BTS
    Step 5: Change Back Measurement Interval


Step 0: Preconditions
    Should Not Be Empty  ${NRPMRNL_PARAMETER_INTERVAL}  Parameter name from NRPMRNL is not provided.

    Create NRPMRNL Dictionary

    ${parameters_list}  Get Regexp Matches  ${NRPMRNL_PARAMETER_INTERVAL}  [a-zA-Z]{4,}
    ${interval_list}  Get Regexp Matches  ${NRPMRNL_PARAMETER_INTERVAL}  \\d+min
    Set Test Variable  ${PARAMETERS_LIST}
    Set Test Variable  ${INTERVAL_LIST}
    ${measurement_verdict}  Create Dictionary
    Set Test Variable  ${MEASUREMENT_VERDICT}

    ${length}  Get Length  ${PARAMETERS_LIST}
    FOR  ${index}  IN RANGE  0  ${length}
        Run Keyword If  '${INTERVAL_LIST}[${index}]'=='15min'
        ...  Change Initial Values If Needed  ${PARAMETERS_LIST}[${index}]  15min  30min
        ...  ELSE
        ...  Change Initial Values If Needed  ${PARAMETERS_LIST}[${index}]  30min  60min
    END


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
    Setup Measurement Dictionary
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
    FOR  ${key}  IN  @{MEASUREMENT_VERDICT.keys()}
        Run Keyword If  '${MEASUREMENT_VERDICT["${key}"]}'=='true'
        ...  Log  Measurement ${key} found in PM report.  console=true
        ...  ELSE
        ...  Fail  Measurement ${key} not found in PM report.
    END

    [Teardown]  Teardown Pm


Step 2: Change Measurements Interval
    Log  Step2: Measurement interval is being changed  console=true
    ${nrbts_id}  Admin Get NRBTS ID

    ${wait_before_parameter_mod}  Evaluate  random.randint(60,180)  modules=random
    Log  Going to Sleep for ${wait_before_parameter_mod} seconds  console=true
    Sleep  ${wait_before_parameter_mod}

    ${delta_id}  Set Variable  measurement_change
    coam.Create Delta  ${delta_id}

    ${parameters_list_length}  Get Length  ${PARAMETERS_LIST}
    FOR  ${int}  IN RANGE  0  ${parameters_list_length}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRPMRNL-1  ${PARAMETERS_LIST[${int}]}  ${INTERVAL_LIST[${int}]}
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

    Setup Measurement Dictionary

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
    FOR  ${key}  IN  @{MEASUREMENT_VERDICT.keys()}
        Run Keyword If  '${MEASUREMENT_VERDICT["${key}"]}'=='true'
        ...  Log  Measurement ${key} found in PM report  console=true
        ...  ELSE
        ...  Fail  Measurement ${key} not found in PM report.
    END

    [Teardown]  Teardown Pm


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
    Setup Measurement Dictionary

    ${hour}  Get Time  hours  UTC
    ${hour}  Convert Time  ${hour}
    ${minutes}  Get Time  minutes
    ${minutes}  Convert Time  ${minutes}
    FOR  ${key}  IN  @{MEASUREMENT_DICTIONARY.keys()}
        Run Keyword If  '${MEASUREMENT_DICTIONARY["${key}"]}'=='true' and '${key}' not in ['15min','30min']
        ...  Wait For BTS Counters  ${key}  ${hour}  ${minutes}
        Run Keyword If  '${MEASUREMENT_DICTIONARY["${key}"]}'=='true'
        ...  Check BTS Counters  ${key}  ${hour}  ${minutes}
    END
    FOR  ${key}  IN  @{MEASUREMENT_VERDICT.keys()}
        Run Keyword If  '${MEASUREMENT_VERDICT["${key}"]}'=='true'
        ...  Log  Measurement ${key} found in PM report  console=true
        ...  ELSE
        ...  Fail  Measurement ${key} not found in PM report.
    END

    [Teardown]  Teardown Pm


Step 5: Change Back Measurement Interval
    Log  Step5: Measurement interval values are changed back to previous values  console=true
    ${nrbts_id}  Admin Get NRBTS ID

    ${delta_id}  Set Variable  measurement_back
    coam.Create Delta  ${delta_id}

    ${parameters_list_length}  Get Length  ${PARAMETERS_LIST}
    FOR  ${int}  IN RANGE  0  ${parameters_list_length}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRPMRNL-1  ${PARAMETERS_LIST[${int}]}
        ...  ${BACKUP_INTERVAL_LIST[${int}]}  ${delta_id}
        Log  Value of parameter ${PARAMETERS_LIST[${int}]} will be changed back to ${BACKUP_INTERVAL_LIST[${int}]}  console=true
    END
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta_2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_2.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}


Change Initial Values If Needed
    [Arguments]  ${parameter_name}  ${ref_value}  ${new_initial_value}

    coam.Get Current Scf File  ${BTS_FILES}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=30
    Setup Pm  scf_path=${BTS_FILES}/scf.xml
    ${nrbts_id}  Admin Get NRBTS ID
    ${status}  ${parameter_initial_val}  Run Keyword And Ignore Error
    ...  Get Scf Parameter  ${parameter_name}
    ${parameter_initial_val}  Set Variable If  '${status}'=='FAIL' or '${parameter_initial_val}'=='disabled'  0min  ${parameter_initial_val}

    ${initial_val_no_min}  Remove String  ${parameter_initial_val}  min
    ${initial_val_integer}  Convert To Integer  ${initial_val_no_min}
    ${ref_val_no_min}  Remove String  ${ref_value}  min
    ${ref_val_integer}  Convert To Integer  ${ref_val_no_min}

    ${condition}  Set Variable  ${initial_val_integer}<=${ref_val_integer}
    Run Keyword If  ${condition}
    ...  coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRPMRNL-1
    ...  ${parameter_name}
    ...  update
    ...  ${new_initial_value}
    ...  skip_parameter_relation_errors=True

    ${parameter_new_initial_val}  Set Variable If  ${condition}  ${new_initial_value}  ${parameter_initial_val}
    Return From Keyword If  not ${condition}
    Sleep Until New Cycle  minutes_for_cycle=${new_initial_value}  additional_condition=${True}

    [Teardown]  Teardown Pm


Wait For BTS Counters
    [Arguments]  ${measurement_interval}  ${hour}  ${minutes}

    ${meas_interval_simplified}  Set Variable If  '${measurement_interval}'=='15min'  1  '${measurement_interval}'=='30min'  1
    ...  '${measurement_interval}'=='60min'  1  '${measurement_interval}'=='360min'  6  '${measurement_interval}'=='720min'  12
    ...  '${measurement_interval}'=='1440min'  24

    Run Keyword If  '${measurement_interval}' not in ['15min','30min','60min','360min','720min','1440min']
    ...  Fail  Incorrect interval value: ${measurement_interval}.

    ${measurement_availability_hour}  Evaluate  (int(${hour}/${meas_interval_simplified})+1)*${meas_interval_simplified}
    ${time}  Evaluate  int(60*(61-${minutes})+3600*(${measurement_availability_hour}-${hour}-1))
    ${time_diff}  Evaluate  ${time}-${PREVIOUS_TIME}
    ${current_date}  Get Current Date  UTC
    ${measurement_availability_time}  Add Time To Date  ${current_date}  ${time_diff}

    Run Keyword If  ${time_diff}>0
    ...  Run Keywords
    ...  Set Test Variable  ${PREVIOUS_TIME}  ${time}
    ...  AND
    ...  Log  Wait until ${measurement_availability_time} UTC for NR measurement to appear on ram  console=true
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


Create NRPMRNL Dictionary
    ${nrpmrnl_dictionary}  Create Dictionary  miNrCellAvailability=NCAV  miNrNgInterface=NNGCB  miNrX2CB=NX2CB  miNrX2CC=NX2CC  miNrF1CC=NF1CC
    ...  miNrRacCu=RACCU  miNrRacDu=RACDU  miNrRSADU=RSADU  miNrUeState=NNSAUE  miNrF1CD=NF1CD  miNrCaCu=NCAC  miNrPsCellChange=NINFC
    ...  miNrE1InterfaceBts=NE1CB  miNrE1InterfaceCuUp=NE1CU  miNrRRCC=NRRCC  miNrNGCC=NNGCC  miNrXnInterface=NXNCB  miNrRRCD=NRRCD
    ...  miNrLteMobilityReport=LTEMO  miNrRlfPerCell=NRLFC  miNrSrb3C=SRB3C  miNrNTRAF=NTRAF  miNrE1InterfaceCuUpNsa=NE1UN
    ...  miNrE1InterfaceCuUpSa=NE1US  miNrE1InterfaceCuCpNsa=NE1CN  miNrE1InterfaceCuCpSa=NE1CS  miNrLteMgPerCell=LTEMG  miNrRSACU=RSACU
    ...  miNrRSADU=RSADU  miNrSrb3D=SRB3D  miNrMobilityReport=NRMO  miNrXnCCInterface=NXNCC  miNrRANS=NRANS  miNrRadBearer=NRBC
    ...  miNrMobilityReportCu=NMOCU  miNrMobilityReportDu=NMODU  miNrF1UU=NF1UU  miNrIfPsCellChange=NIFC  miNrMgPerCell=NRMG  miNrDlHarq=NDLHQ
    ...  miNrDlSignalQuality=NDLSQ  miNrUlHarq=NULHQ  miNrUlSignalQuality=NULSQ  miNrMacPduTput=NMPDU  miNrRachUsage=NRACH  miNrTimingAdvance=NRTA
    ...  miNrCellUtilization=NCELA  miNrMacSduReport=NMSDU  miNrLowRlcReport=NLRLC  miNrHighRlcReport=NHRLC  miNrX2UInterface=NX2UB
    ...  miNrF1UDInterface=NF1UD  miNrS1UInterface=NS1UB  miNrCaDu=NCADU  miNrPDCP1Report=PDCP1  miNrPDCP2Report=PDCP2  miNrF1UCInterface=NF1UB
    ...  miNrEirp=NREIRP  miNrRSUP=NRASU  miNrNgUReport=NRNGU  miNrPaging=NRPAG  miNrEnDssPerCell=ENDSS  miNrBeamforming=NRBF  miNrBeamforming2=NRBF2
    ...  miNrHighRlcCell=NHRRC  miNrGnss=NGNS

    Set Test Variable  ${NRPMRNL_DICTIONARY}


Loop Over Parameters
    [Documentation]
    ...  This keyword checks if measurement interval is correctly reported in downloaded PM report xml file for each measurement name
    ...  provided by the user as the test case input.
    [Arguments]  ${parameter}

    Read PM File
    ${time}  Get Current Date
    ${output}  Run Keyword And Ignore Error
    ...  Dump PM Report  ${BTS_FILES}/PM_REPORT_${parameter}_${CALCULATED_INTERVAL}_${time}.xml
    Run Keyword If  not ${output}
    ...  FAIL  PM Report not present in ram disk.
    ${interval}  Get Regexp Matches  ${CALCULATED_INTERVAL}  \\d{2,}
    Log  Value of parameter ${parameter} is set to ${CALCULATED_INTERVAL}  console=true
    ${o_me_s}  Parse XML  ${BTS_FILES}/PM_REPORT_${parameter}_${CALCULATED_INTERVAL}_${time}.xml
    ${xpath_result}  Evaluate Xpath  ${o_me_s}
    ...  //PMSetup[@interval="${interval[0]}"]/PMMOResult/NE-WBTS_1.0[@measurementType="${NRPMRNL_DICTIONARY["${parameter}"]}"]
    Run Keyword If  '${xpath_result}'!='[]'
    ...  Set To Dictionary  ${MEASUREMENT_VERDICT}  ${parameter}  true


Setup Measurement Dictionary
    ${measurement_dictionary}  Create Dictionary  15min=false  30min=false  60min=false  360min=false  720min=false  1440min=false
    Set Test Variable  ${MEASUREMENT_DICTIONARY}
    FOR  ${interval}  IN  @{CURRENT_INTERVAL_LIST}
        Set To Dictionary  ${MEASUREMENT_DICTIONARY}  ${interval}  true
    END


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
