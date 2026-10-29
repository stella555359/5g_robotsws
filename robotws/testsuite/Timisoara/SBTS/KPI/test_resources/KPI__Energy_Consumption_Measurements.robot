*** Settings ***
Documentation
    ...  This test is created to collect BTS Counters and Real-time measurements to CSV files.
    ...  4 parameters are changed: actPowerMeter to true, mtBtsEnergyMonitoring to 15min, mtSBTSRfmEnergyMonitoring to 15min,
    ...  mtSBTSSmEnergyMonitoring to 15min.
    ...  Site reset is performed to clear all counters.
    ...  Sleep 15 minutes until counters are available.
    ...  Counters collection to CSV files is performed.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  900
@{LIST_RMODS_WITH_EPM}  AEQB  AEQZ  AEQC  AEQI  AEQE  AEQK  AEQP  AEQP_I  AEQQ  AEQV  AEQY  AHBCA  AHBCB  AHBCC  AHCA  AHDB  AHEB  AHEGB  AHFIA
...  AHFIB  AHFIC  AHLOA  AHPB  AHPD  AHPMDA  AHPMDB  AZQR  AHCE  AHHA  AHFB  AHIB  AREA  ARPA  AZHL  AZHM  AZQS  AZQP  AZQW  AZQF  AZHM  AZHN
...  AHPF  AHGB  AHEJ  FHDB  FHDI  FHEB  FHED  FHEF  FHEG  FHEH  FHEJ  FHEL  FHFB  FHKA  FHOA  FHPD  FHPG  FRAA  FRAB  FRAC  FRBE  FRBG  FRBI
...  FRCC  FRCG  FRGA  FRGB  FRGU  FRGX  FRGY  FRHG  FRIJ  FRKA  FRMF  FRSA  FXDD  FXED  FXEE  FXEF  AHEH  AQQL  AQQN  AHEGHA  AWHQN  AZQU
...  AZQI  AVQL  AEQN  AEHC  AHPE  AZQS
&{SPECIAL_RMODS_DICT}  FRHC=A.204  FRHF=A.204  FRMC=A.203  FRME=A.203  FRPA=A.203  FRPB=A.203  FRPD=A.202
@{LIST_BBMODS_WITH_EPM}  ABIP  ABIQ


*** Keywords ***
KPI__Energy_Consumption_Measurements
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23374
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  08.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23374 - Initial TAT creation
    ...  30.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23605 - Correction for real-time measurements to be collected properly
    ...  21.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24142 - Change for FEATCADM object to match new software versions
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26540 - Adapt TC to CB009480
    ...  05.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26673 - Add suport for branch
    ...  05.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27605 - Add verification for BBMODs
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases
    ...  ******************

    Set Tags  CA-KPI  OWNER-mohamand.al_hamwi@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  SW-SBTS22

    Step1: Set Variables
    Step2: Modify Parameters For Energy Consumption Measurement
    Step3: Reset Site
    Step4: Collect BTS Counters To CSV File
    Step5: Collect Real-time Measurements To CSV File


Step1: Set Variables
    Log  \nStep1: Setting variables \nCSV files, BTS id, RMODS ids, SMODS ids.  console=true
    Create File  ${TEST_RESULTS_DIR}/CSVFiles/bts_counters.csv
    Set Test Variable  ${BTS_COUNTERS_CSV}  ${TEST_RESULTS_DIR}/CSVFiles/bts_counters.csv
    Create File  ${TEST_RESULTS_DIR}/CSVFiles/realtime_measurements.csv
    Set Test Variable  ${REAL_TIME_MEASUREMENTS_CSV}  ${TEST_RESULTS_DIR}/CSVFiles/realtime_measurements.csv
    ${bts_id}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    Set Lists Of RMODS And SMODS


Step2: Modify Parameters For Energy Consumption Measurement
    Log  \nStep2: Modify Parameters for Energy Consumption Measurement  console=true
    Change And Get ActPowerMeter Parameter Value  true
    Sleep  120s  Time for actPowerMeter parameter to be changed
    Change And Get Parameter Value  mtBtsEnergyMonitoring  15min
    Sleep  15s  Time for mtBtsEnergyMonitoring parameter to be changed
    Change And Get Parameter Value  mtSBTSRfmEnergyMonitoring  15min
    Sleep  15s  Time for mtSBTSRfmEnergyMonitoring parameter to be changed
    Change And Get Parameter Value  mtSBTSSmEnergyMonitoring  15min
    Sleep  15s  Time for mtSBTSSmEnergyMonitoring parameter to be changed
    Change And Get Parameter Value  mtSBTSBBCAPEnergyMonitoring  15min
    Sleep  15s  Time for mtSBTSBBCAPEnergyMonitoring parameter to be changed


Step3: Reset Site
    Log  \nPerforming site reset to clear all counters.  console=true
    coam.Reset Site  ${STARTUP_TIMEOUT}
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60  Admin Check All Required State
    IF  ${status}
        Log  Site reached on air state after performing site reset.  console=true
    ELSE
        Fail  Site didn't manage to reach on air state after site reset.
    END


Step4: Collect BTS Counters To CSV File
    Log  \nStep4: Collect BTS Counters to CSV file  console=true
    Sleep Until New 15 Minutes Cycle
    Sleep  60s
    ${table_header_list}  Create List  COUNTER NAME  COUNTER PATH  RMOD/SMOD  COUNTER VALUES
    Set Table Header  ${BTS_COUNTERS_CSV}  ${table_header_list}
    Create Counters Dictionary And List
    Add PM Counters To CSV File


Step5: Collect Real-time Measurements To CSV File
    Log  \nStep5: Collect Real-time Measurements to CSV file  console=true
    ${table_header_list}  Create List  MEASURED OBJECT  TYPE  UNIT  VALUE
    Set Table Header  ${REAL_TIME_MEASUREMENTS_CSV}  ${table_header_list}
    Collect Real-time Measurements


Set Lists Of RMODS And SMODS
    ${frm_list}  Get Frm
    ${list_of_rmods}  Create List
    FOR  ${rmod}  IN  @{frm_list}
        ${rmod_dist_name}  Set Variable  ${rmod}[id][configuration]
        ${rmod_id}  Fetch From Right  ${rmod_dist_name}  /
        Append To List  ${list_of_rmods}  ${rmod_id}
    END
    Sort List  ${list_of_rmods}
    Set Test Variable  ${LIST_OF_RMODS}

    ${smod_ids}  Get Ids For All  SMOD  timeout=60
    ${list_of_smods}  Create List
    FOR  ${smod_dn}  IN  @{smod_ids}
        ${smod_r_id}  Fetch From Right  ${smod_dn}  /
        ${smod_id}  Remove String Using Regexp  ${smod_r_id}  _R
        Append To List  ${list_of_smods}  ${smod_id}
    END
    Sort List  ${list_of_smods}
    Set Test Variable  ${LIST_OF_SMODS}


Change And Get ActPowerMeter Parameter Value
    [Arguments]  ${value}

    Log  Change parameter actPowerMeter  console=true
    ${initial_value}  Get ActPowerMeter Value From FEATCADM Object  actPowerMeter
    Log  actPowerMeter value is ${initial_value}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActPowerMeter  ${value}  actPowerMeter
    ${parameter_after_change}  Get ActPowerMeter Value From FEATCADM Object  actPowerMeter
    Log  Parameter after change: ${parameter_after_change}  console=true
    IF  ${status}  Should Be Equal  ${parameter_after_change}  ${value}


Get ActPowerMeter Value From FEATCADM Object
    [Documentation]
    ...  This KW is created to check what value has parameter actPowerMeter.
    [Arguments]  ${im_parameter}

    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object}  coam.Get Managed Objects  FEATCADM_CONF_M
    ${parameter_object_value_string}  Convert To String  ${parameter_object}[0][parameters][${parameter_name}]
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    RETURN  ${parameter_object_lower}


Change Parameter ActPowerMeter
    [Arguments]  ${value}  ${parameter_name}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${get_parameter_value}  Get ActPowerMeter Value From FEATCADM Object  ${parameter_name}
    IF  '${get_parameter_value}'!='${value}'
        Perform Parameter Recommissioning  ${dist_name_bts_id}
        ...  ${parameter_name}
        ...  update
        ...  ${value}
        ...  skip_parameter_relation_errors=True
        ...  should_activate=True
        ...  timeout=300
        Log  ${parameter_name} will be changed to ${value}  console=true
    END


Change And Get Parameter Value
    [Arguments]  ${parameter_name}  ${value}

    Log  Change parameter ${parameter_name}  console=true
    ${initial_value}  Get Parameter Value From PMMNL Object  ${parameter_name}
    Log  Initial value is ${initial_value}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change Parameter  ${value}  ${parameter_name}
    ${parameter_after_change}  Get Parameter Value From PMMNL Object  ${parameter_name}
    Log  Parameter after change: ${parameter_after_change}  console=true
    IF  ${status}  Should Be Equal  ${parameter_after_change}  ${value}


Get Parameter Value From PMMNL Object
    [Documentation]
    ...  This KW is created to check what value have the given parameter:
    ...  mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring
    [Arguments]  ${im_parameter}

    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object}  coam.Get Managed Objects  PMMNL_A
    ${parameter_object_value_string}  Convert To String  ${parameter_object}[0][parameters][${parameter_name}]
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    RETURN  ${parameter_object_lower}


Change Parameter
    [Documentation]
    ...  This KW is created to check what value have the given parameter:
    ...  mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring
    [Arguments]  ${value}  ${parameter_name}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${get_parameter_value}  Get Parameter Value From PMMNL Object  ${parameter_name}
    IF  '${get_parameter_value}'!='${value}'
        Perform Parameter Recommissioning  ${dist_name_bts_id}
        ...  ${parameter_name}
        ...  update
        ...  ${value}
        ...  skip_parameter_relation_errors=True
        ...  should_activate=True
        ...  timeout=300
        Log  ${parameter_name} will be changed to ${value}  console=true
    END


Set Table Header
    [Arguments]  ${file_type}  ${table_header_list}

    ${date_time}  Get Current Date
    ${date_list_format}  Create List
    Append To List  ${date_list_format}  COLLECTION DATE AND TIME  '${date_time}'
    Append To Csv File  ${file_type}  ${date_list_format}
    Append To Csv File  ${file_type}  ${table_header_list}


Create Counters Dictionary And List
    &{counters_dict}  Create Dictionary  M40002C0=ENERGY_CONSUMPTION_IN_SM  M40002C1=ENERGY_CONSUMPTION_IN_RF  M40002C2=ENERGY_CONSUMPTION_IN_BTS
    ...  M40003C0=MIN_INPUT_VOLTAGE_IN_RF  M40003C1=MAX_INPUT_VOLTAGE_IN_RF  M40003C2=RU_ENERGY_CONSUMPTION  M40003C3=RU_MIN_PWR_USAGE
    ...  M40003C4=RU_AVG_PWR_USAGE  M40003C5=RU_MAX_PWR_USAGE  M40004C0=SM_ENERGY_CONSUMPTION  M40004C1=SM_MIN_PWR_USAGE  M40004C2=SM_AVG_PWR_USAGE
    ...  M40004C3=SM_MAX_PWR_USAGE  M40004C4=MIN_INPUT_VOLTAGE_IN_SM  M40004C5=MAX_INPUT_VOLTAGE_IN_SM
    Set Test Variable  ${COUNTERS_DICT}  ${counters_dict}
    ${counters_list}  Create List  M40002C0  M40002C1  M40002C2  M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5  M40004C0  M40004C1
    ...  M40004C2  M40004C3  M40004C4  M40004C5
    Set Test Variable  ${COUNTERS_LIST}  ${counters_list}


Add PM Counters To CSV File
    FOR  ${counter_id}  IN  @{COUNTERS_LIST}
        ${current_counter_dict}  coam.Get Pm Counters  counter_ids=${counter_id}
        ${status_m40002}  Run Keyword And Return Status
        ...  Should Contain  ${counter_id}  40002
        ${status_m40003}  Run Keyword And Return Status
        ...  Should Contain  ${counter_id}  40003
        IF  ${status_m40002}
            Add M40002 Counter Values To CSV  ${counter_id}  ${current_counter_dict}
        ELSE IF  ${status_m40003}
            Add M40003/M40004 Counter Values To CSV  ${counter_id}  ${current_counter_dict}  ${LIST_OF_RMODS}
        ELSE
            Add M40003/M40004 Counter Values To CSV  ${counter_id}  ${current_counter_dict}  ${LIST_OF_SMODS}
        END
    END


Add M40002 Counter Values To CSV
    [Arguments]  ${counter_id}  ${current_counter_dict}

    ${counter_full_info}  Create List
    ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  ${current_counter_dict}[BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][${counter_id}]
    ...  ${current_counter_dict}[BTS][BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][${counter_id}]
    ${counter_values}  Get Dictionary Values  ${dict}
    ${full_path}  Set Variable  [SBTS${BTS_ID}]BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption/${COUNTERS_DICT}[${counter_id}]
    Append To List  ${counter_full_info}  ${counter_id}  ${full_path}  ${SPACE}  @{counter_values}
    Append To Csv File  ${BTS_COUNTERS_CSV}  ${counter_full_info}


Add M40003/M40004 Counter Values To CSV
    [Arguments]  ${counter_id}  ${current_counter_dict}  ${rmods/smods_list}

    ${cnt}  Set Variable  0
    FOR  ${module}  IN  @{rmods/smods_list}
        ${counter_full_info}  Create List
        ${status_module}  Run Keyword And Return Status
        ...  Should Contain  ${module}  RMOD
        IF  ${status_module}
            ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
            ...  ${current_counter_dict}[BTS][MRBTS-${BTS_ID}][EQM-1][APEQM-1][${module}][SBTS_RFM_Energy_Monitoring][${counter_id}]
            ...  ${current_counter_dict}[BTS][BTS][MRBTS-${BTS_ID}][${module}][SBTS_RFM_Energy_Monitoring][${counter_id}]
        ELSE
            ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
            ...  ${current_counter_dict}[BTS][MRBTS-${BTS_ID}][EQM-1][APEQM-1][CABINET-1][${module}][SBTS_SM_Energy_Monitoring][${counter_id}]
            ...  ${current_counter_dict}[BTS][SMOD][${module}][CABINET-1][SBTS_SM_Energy_Monitoring][${counter_id}]
        END
        ${counter_values}  Get Dictionary Values  ${dict}
        IF  ${status_module}
            ${full_path}  Set Variable  [${BTS_ID}]BTS/MRBTS-${BTS_ID}/${module}/SBTS_RFM_Energy_Monitoring/${COUNTERS_DICT}[${counter_id}]
        ELSE
            ${full_path}  Set Variable  SMOD/SMOD-1/CABINET-1/SBTS_SM_Energy_Monitoring/${COUNTERS_DICT}[${counter_id}]
        END
        IF  ${cnt} == 0
            Append To List  ${counter_full_info}  ${counter_id}  ${full_path}  ${module}  @{counter_values}
        ELSE
            Append To List  ${counter_full_info}  ${SPACE}  ${SPACE}  ${module}  @{counter_values}
        END
        Append To Csv File  ${BTS_COUNTERS_CSV}  ${counter_full_info}
        ${cnt}  Evaluate  ${cnt} + 1
    END


Collect Real-time Measurements
    ${measurements}  Get Measurements
    FOR  ${measure}  IN  @{measurements}
        ${index}  Get Index From List  ${measurements}  ${measure}
        ${key}  Get Dictionary Keys  ${measure}
        ${rmod_smod_key}  Set Variable  ${key}[0]
        ${status_energy}  Run Keyword And Return Status
        ...  Should Contain  ${rmod_smod_key}  ENERGY_EFFICIENCY
        IF  ${status_energy}  Write Values Of Measurements  ${rmod_smod_key}  ${index}
    END


Write Values Of Measurements
    [Arguments]  ${rmod_smod_key}  ${index}

    ${status_rmod}  Run Keyword And Return Status
    ...  Should Contain  ${rmod_smod_key}  RMOD
    ${status_smod}  Run Keyword And Return Status
    ...  Should Contain  ${rmod_smod_key}  SMOD
    IF  ${status_rmod}
        Write Values Of Measurements For RMODS  ${rmod_smod_key}  ${index}
    ELSE IF  ${status_smod}
        Write Values Of Measurements For SMODS  ${rmod_smod_key}  ${index}
    ELSE
        Write Values Of Measurements For BBMODS  ${rmod_smod_key}  ${index}
    END


Write Values Of Measurements For RMODS
    [Arguments]  ${rmod_smod_key}  ${index}

    ${rmod_r_id}  Fetch From Right  ${rmod_smod_key}  /RMOD/
    ${list_rmod}  Get Frm
    FOR  ${rmod}  IN  @{list_rmod}
        ${rmod_r_dist_name}  Set Variable  ${rmod}[id][runtime]
        ${rmod_found_in_frm}  Run Keyword And Return Status
        ...  Should Contain  ${rmod_r_dist_name}  ${rmod_r_id}
        IF  ${rmod_found_in_frm}
            ${rmod_product_name}  Set Variable  ${rmod}[productName]
        ELSE
            CONTINUE
        END
        IF  ${rmod_found_in_frm}
            ${rmod_product_code}  Set Variable  ${rmod}[productCode]
        END
        ${rmod_version}  Get Regexp Matches  ${rmod_product_code}  [A-Z].\\d+
        ${rmod_version}  Set Variable  ${rmod_version}[0]
        IF  '${rmod_product_name}' != 'None' and '${rmod_version}' != 'None'  BREAK
    END
    ${status_contain}  Run Keyword And Return Status
    ...  Should Contain  ${LIST_RMODS_WITH_EPM}  ${rmod_product_name}
    ${status_dictionary}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${SPECIAL_RMODS_DICT}  ${rmod_product_name}
    IF  ${status_dictionary}
        ${status_contain_version}  Verify RMOD ProductCode  ${rmod_product_name}  ${rmod_version}
    ELSE
        ${status_contain_version}  Set Variable  ${FALSE}
    END
    ${status_values}  Set Variable  ${None}
    IF  ${status_contain} or ${status_contain_version}
        ${status_values}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  180  60
        ...  Write Power And Voltage Values To Csv  ${rmod_smod_key}  ${index}
    END
    IF  ${status_values} == ${FALSE}  Fail  No real-time measurements found for ${rmod_smod_key}.


Verify RMOD ProductCode
    [Arguments]  ${rmod_product_name}  ${rmod_version}

    IF  '${rmod_version}' >= '${SPECIAL_RMODS_DICT}[${rmod_product_name}]'
        RETURN  ${TRUE}
    ELSE
        RETURN  ${FALSE}
    END


Write Values Of Measurements For SMODS
    [Arguments]  ${rmod_smod_key}  ${index}

    ${status_values}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  180  60
    ...  Write Power And Voltage Values To Csv  ${rmod_smod_key}  ${index}
    IF  ${status_values}==${FALSE}
    ...  Fail  No real-time measurements found for ${rmod_smod_key}  ELSE  Log  Real-time measurements written to CSV for ${rmod_smod_key}


Write Values Of Measurements For BBMODS
    [Arguments]  ${bbmod_key}  ${index}

    ${bbmod_r_id}  Fetch From Right  ${bbmod_key}  /
    ${bbmods_list}  Get Fbb Info
    FOR  ${bbmod}  IN  @{bbmods_list}
        ${bbmod_r_dn}  Set Variable  ${bbmod}[id][runtime]
        ${founded_bbmod}  Run Keyword And Return Status
        ...  Should Contain  ${bbmod_r_dn}  ${bbmod_r_id}
        IF  ${founded_bbmod}
            ${bbmod_product_name}  Set Variable  ${bbmod}[productName]
        ELSE
            CONTINUE
        END
        IF  '${bbmod_product_name}' != 'None'  BREAK
    END
    ${bbmod_product_name}  Fetch From Left  ${bbmod_product_name}  ${SPACE}
    ${status_contain}  Run Keyword And Return Status
    ...  Should Contain  ${LIST_BBMODS_WITH_EPM}  ${bbmod_product_name}
    ${status_values}  Set Variable  ${None}
    IF  ${status_contain}
        ${status_values}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  180  60
        ...  Write Power Value To Csv  ${bbmod_key}  ${index}
    END
    IF  ${status_values} == ${FALSE}  Fail  No real-time measurements found for ${bbmod_key}.


Write Power And Voltage Values To Csv
    [Arguments]  ${rmod_smod_key}  ${index}

    ${measurements}  Get Measurements
    ${power}  Set Variable  ${measurements}[${index}][${rmod_smod_key}][power]
    ${voltage}  Set Variable  ${measurements}[${index}][${rmod_smod_key}][voltage]
    IF  '${power}' == '-' or '${voltage}' == '-'
        Fail  No power and voltage values found.
    ELSE
        Write To CSV  ${rmod_smod_key}  ${power}  ${voltage}
    END


Write Power Value To Csv
    [Arguments]  ${rmod_smod_key}  ${index}

    ${measurements}  Get Measurements
    ${power}  Set Variable  ${measurements}[${index}][${rmod_smod_key}][power]
    ${voltage}  Set Variable  -
    IF  '${power}' == '-'
        Fail  No power value found.
    ELSE
        Write To CSV  ${rmod_smod_key}  ${power}  ${voltage}
    END


Write To CSV
    [Arguments]  ${rmod_smod_key}  ${power}  ${voltage}

    ${power_info}  Create List
    ${voltage_info}  Create List
    Append To List  ${power_info}  ${rmod_smod_key}  Power  W  ${power}
    Append To Csv File  ${REAL_TIME_MEASUREMENTS_CSV}  ${power_info}
    Append To List  ${voltage_info}  ${SPACE}  Voltage  V  ${voltage}
    Append To Csv File  ${REAL_TIME_MEASUREMENTS_CSV}  ${voltage_info}


Modify Parameters Back To Initial Values
    Log  \nModifying Parameters back to initial values  console=true
    Change And Get ActPowerMeter Parameter Value  false
    Sleep  120s  Time for actPowerMeter parameter to be changed
    Change And Get Parameter Value  mtSBTSRfmEnergyMonitoring  disabled
    Sleep  15s  Time for mtSBTSRfmEnergyMonitoring parameter to be changed
    Change And Get Parameter Value  mtSBTSSmEnergyMonitoring  disabled
    Sleep  15s  Time for mtSBTSSmEnergyMonitoring parameter to be changed


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Modify Parameters Back To Initial Values
    Common Test Teardown
    Set Log Level  TRACE
