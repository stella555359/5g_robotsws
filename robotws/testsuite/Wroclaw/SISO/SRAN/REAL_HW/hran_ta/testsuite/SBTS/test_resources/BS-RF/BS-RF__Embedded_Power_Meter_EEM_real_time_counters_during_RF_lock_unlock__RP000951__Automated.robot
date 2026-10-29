*** Settings ***
Documentation
...  The purpose of this Test Case is to check Embedded Power Meter for Energy Efficiency Monitoring during RF lock and unlock.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Energy_Efficiency.robot

*** Variables ***

${RMOD_SN}    L1160506706      # Serial number of RMOD to lock
${RMODS}        4    # How many RMODs in configuration support Embedded Power Meter feature.
${TIME_TO_WAIT}   3   # Waiting time in mimutes between CSV file export

*** Keywords ***
TC__BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14229
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  The purpose of this Test Case is to check Embedded Power Meter for Energy Efficiency Monitoring during RF lock and unlock.
    ...  TC activates feature and first checks if Real-time measurements are collecting once per minute.
    ...  Next TC waits and collects power measurements before lock,after lock and after unlock.
    ...  After RMOD lock, power in watts should be smaller than before lock and after RMOD unlock, power should be similar to before RMOD lock.
    ...  TC requires that the difference in power consumption after lock/unlock RMOD operation is at least 10% of preceding value.
    ...  Taking into account measurements stabilization it is recommended to set minimum time to wait 3 minutes for RMOD < 5.1 and 5 minutes
    ...  for RMOD >= 5.1
    ...  TC save all downloaded by browser CSV files to desired directory. CSV files are saved in Test Files/CSV Measurements in TC logs directory.
    ...
    ...  IMPORTANT:
    ...  For proper operation of Selenium2Library, Chrome Driver version is required to match the Google Chrome version !
    ...  During TC developing used Google Chrome 85.0 and Chrome Driver 85
    ...  Chrome Driver version that matches your version of Google Chrome can be found here: https://chromedriver.chromium.org/downloads
    ...  Path to chromedriver on Linux VM: opt/ute/chromedriver
    ...
    ...  IMPORTANT 2:
    ...  In case of problems with Selenium2Library e.g. ElementNotInteractableException: Message: element not interactable
    ...  first make sure that resolution of your VM machine is 1920x1080 because it's nativ resolution for WebEM.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-14229 - Initial creation
    ...  - 12.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17144 - Screen-lock popup handling and added documentation
    ...  - 23.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17585 - Change directory for CSV measurements logs
    ...  - 01.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17727 - Change method to click element "Performance"
    ...  - 26.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18313 - Fixed issues: ValueError and Invalid token
    ...  - 08.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19634 - Fixed issues: ElementNotVisible on the newest SBTS00 builds
    ...  - 02.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19725 - Fixed issues: Real time measurements don't collect every minute
    ...  but more often
    ...  - 08.10.2020 - https://jira3.int.net.nokia.com/browse/TAT-20214 - Manual CSV file creation insted of "Export to CSV" provided
    ...  by API and other small corrections
    ...  - 22.10.2020 - https://jira3.int.net.nokia.com/browse/TAT-20354 - Added Lock/Unlock RMOD functionality for newer branches
    ...  - 11.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20639 - Adaptation for newer trunk releases ( selenium )
    ...  - 14.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20645 - Fix for "Not Available" power values
    ...  - 17.02.2021 - https://jira3.int.net.nokia.com/browse/TAT-20931 - Added KW "Repair Google Chrome And Chrome Driver Compatibility"
    ...  - 06.05.2021 - https://jira3.int.net.nokia.com/browse/TAT-21297 - Adjust login to admin via Selenium for newer SBTS builds
    ...  - 18.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 14.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22332 - Values "Not supported" and "Not avaialable" changed to 0
    ...  - 11.04.2022 - https://jira3.int.net.nokia.com/browse/TAT-22939 - Bugs fix
    ...  - 19.07.2022 - Changes due to PR645366 - PM unsupported modules has value "-" instead of "0"
    ...  - 28.10.2025 - Fix DST-related parsing issue in CSV measurements
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/BS-RF__Embedded_Power_Meter_for_Energy_Efficiency_Monitoring_
    ...  real_time_counters_during_RF_lock_unlock__RP000951__Automated_TAT-14229.png


    Set Tags    CA-BS-RF    OWNER-mateusz.kawka@nokia.com    AUTHOR-mateusz.kawka@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CIT    SW-SBTS17A    SW-SBTS18
    ...    FEATURE-RP000951    FEATURE-RP001486_2    FEATURE-RP001145_1

    step1: Preconditions
    step2: Activate Embedded Power Meter For Enegry Efficiency Monitoring
    step3: Check If Real-Time Measurements Are Collecting Every Minute
    step4: Lock RMOD And Check Power
    step5: Unlock RMOD and Check Power
    step6: Deactivate Embedded Power Meter For Enegry Efficiency Monitoring
    Restore Reference Configuration

step1: Preconditions

    Log To Console  step1: Preconditions${\n}

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    ${active_sw}  Get Software Release  Active
    Set Test Variable  ${ACTIVE_SW}  ${active_sw}
    Log to console  Active software release is ${ACTIVE_SW}

    ${bts_obj}   admin.Get parameters for all  BTS
    ${bts_name}  Convert to string  ${bts_obj[0].btsName}
    ${bts_id}    Convert to string  ${bts_obj[0].btsId}
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Test Variable  ${BTS_NAME}  ${bts_name}

    Create Directory  ${Test Files}/CSV Measurements

    ${time_to_wait_status}=  Run Keyword And Return Status  Should Not Be Empty  ${TIME_TO_WAIT}
    Run Keyword If  '${time_to_wait_status}'=='False'  Fail  Variable TIME_TO_WAIT cannot be empty !

    Set Test Variable  ${OBJECT_VARIABLE_ACTPOWERMETER}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    ${reference_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=default
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actpowermeter_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${object_variable_actPowerMeter}']/p[@name='actPowerMeter']/text())
    Set To Dictionary  ${reference_dict}  actPowerMeter  ${actpowermeter_scf}
    Set Test Variable    ${REFERENCE_DICT}

    ${rmod_distname}  Get RU DistName For Serial Number  ${RMOD_SN}
    Set Test Variable  ${RMOD_TO_BLOCK}  ${rmod_distname}

    ${rmods_parameters}  admin.Get Frm
    FOR  ${rmod}  IN  @{rmods_parameters}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        Set Test Variable  ${RMOD_PRODUCT_NAME}  ${rmod['productName']}
        ${rmod_real_time_name}  Evaluate  " ".join(['${rmod['id']['internal']}'.rsplit('/', 1)[1], f"(${rmod['productName']})"])
        Set Test Variable  ${RMOD_REAL_TIME_NAME}
    END

    Check Number of RMODS  ${RMODS}
    Verify Serial Number  ${RMOD_SN}
    Log To Console  ${RMOD_PRODUCT_NAME} with SN -> ${RMOD_SN} found in HW Configuration${\n}

    Log to console  Checking Google Chrome and Chrome Driver compatibility !${\n}

    Check And Repair Google Chrome And Chrome Driver Compatibility

step2: Activate Embedded Power Meter For Enegry Efficiency Monitoring

    Log To Console  step2: Activate Embedded Power Meter For Enegry Efficiency Monitoring${\n}

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    Run Keyword If  '${reference_dict['actPowerMeter'].lower()}' == 'false'  Run Keywords
    ...  Log To Console  Energy Efficiency Monitoring feature is not active, activating ongoing..\n
    ...  AND  admin.Perform Parameter Recommissioning
    ...  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  true  skip_parameter_relation_errors=true
    ...  AND  Check If All Cells Are OnAir
    ...  ELSE
    ...  Log To Console  Energy Efficiency Monitoring feature already activated!\n

    Log To Console  ${\n}Now checking if Embedded Power Meter For Enegry Efficiency Monitoring feature was activated successfully...
    Log To Console  ${\n}Waiting up to 10 minutes for Real-time measurements ! Attempt to read every minute !${\n}
    ${EEM_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  10x  1 minute  Check Real Time Measurements  True

    FOR  ${row}  IN  @{LIST_OF_MEASUREMENTS}
      ${keys}  Get Dictionary Keys  ${row}
      ${status}  Run Keyword And Return Status  Should Contain Match  ${keys}  regexp=ENERGY
      Run Keyword If  ${status}==True  Log To Console  ${row}
    END

    Run Keyword If  ${EEM_status}==False  Run Keywords
    ...  Log To Console  Embedded Power Meter For Enegry Efficiency Monitoring feature wasn't enabled or cannot collect all Real-time measurements!
    ...  AND  Log To Console  ${\n} Check given number of RMODS supporting Embedded Power Meter feature!
    ...  AND  Fail  Embedded Power Meter For Enegry Efficiency Monitoring feature wasn't enabled or cannot collect all Real-time measurements!
    ...  ELSE
    ...  Log To Console  ${\n}Real-time measurements has been collected !

step3: Check If Real-Time Measurements Are Collecting Every Minute

    Log To Console  step3: Check If Real-Time Measurements Are Collecting Every Minute${\n}

    Open Real-time Measurements on WebEM
    ${seconds}  Get Time  seconds
    ${seconds}  Convert To Integer  ${seconds}
    ${time_to_sleep}  Evaluate  (75-${seconds})
    Log To Console  Waiting ${time_to_sleep} seconds to export table with Real-time Measurements to CSV ...${\n}
    Sleep  ${time_to_sleep}s
    Export Real-time Measurements to CSV
    Get Latest File From Directory
    Log To Console  Latest exported CSV file -> ${LATEST_FILE}${\n}
    ${first_count}  Count CSV File Rows
    Log To Console  ${LATEST_FILE} has ${first_count} rows !${\n}
    Run Keyword If  ${first_count}==0  Run Keyword And Continue On Failure  Fail  Table with Energy Efficiency Measurements is empty !

    ${seconds}  Get Time  seconds
    ${seconds}  Convert To Integer  ${seconds}
    ${time_to_sleep}  Evaluate  (75-${seconds})
    Log To Console  Waiting ${time_to_sleep} seconds to re-export table with Real-time Measurements to CSV and comparison of the number of rows${\n}
    Sleep  ${time_to_sleep}s

    Export Real-time Measurements to CSV
    Get Latest File From Directory
    Log To Console  Latest exported CSV file -> ${LATEST_FILE}${\n}
    ${second_count}  Count CSV File Rows
    Log To Console  ${LATEST_FILE} has ${second_count} rows !${\n}
    ${result}  Evaluate  (${second_count}-${first_count})

    Run Keyword If  ${result}>1
    ...  Fail  Energy Efficiency Measurements don't collect every minute but more often !
    ...  ELSE IF  ${result}<1
    ...  Fail  Energy Efficiency Measurements don't collect every minute but less frequency !
    ...  ELSE  Log To Console  Real-time measurements are collect every minute, going to next step !${\n}


step4: Lock RMOD And Check Power

    Log To Console  step4: Lock RMOD and Check Power${\n}
    Count Time To Export CSV File
    Log To Console  Waiting ${MINUTES} minutes and ${SECONDS} seconds for export Real-time Measurements before lock !${\n}
    Sleep  ${TIME_TO_SLEEP} seconds

    Export Real-time Measurements to CSV
    Get Latest File From Directory
    Log To Console  Latest exported CSV file -> ${LATEST_FILE}${\n}
    Read CSV to dictionary

    ${rmod_params}  admin.Get Parameters For  RMOD  ${RMOD_TO_BLOCK}
    ${id}  Evaluate  ('${rmod_params.id}'[-8:])
    Set Test Variable  ${RMOD_ID}  ${id}

    ${power}  Get From Dictionary  ${dict_of_measurements}  ${RMOD_ID}
    Log to console  ${\n}For ${RMOD_ID} was collected following values:${\n}${power}

    ${power_without_not_available}  Evaluate  [ x for x in ${power} if x!='Available' ]
    ${power_without_not_available}  Evaluate  ([float(i) for i in ${power_without_not_available}])

    ${len_of_all_power}  Get Length  ${power}
    ${len_of_power_without_not_a}  Get Length  ${power_without_not_available}
    ${half_of_all_meas}  Evaluate  float(${len_of_all_power}/2)

    ${status_of_meas_without_not_a}  Evaluate  ${len_of_power_without_not_a}>=${half_of_all_meas}

    Run Keyword If  '${status_of_meas_without_not_a}'=='False'  Run Keywords
    ...  Log to console  Too few valid power measurement after excluding "Not Available"
    ...  AND  Log To Console  Too few valid power measurement after excluding "Not Available"${\n}
    ...  AND  Log To Console  ${\n}Values with "Not Available": ${len_of_all_power}
    ...  AND  Log To Console  ${\n}Values without "Not Available": ${len_of_power_without_not_a}${\n}
    ...  AND  Fail  Too few valid power measurement after excluding "Not Available"

    Log To Console  ${\n}Values used to calculate the average power
    Log To Console  ${\n}(removed "Not Available" if were):${\n}${RMOD_ID}: ${power_without_not_available}${\n}

    ${average_power_before_block}  Evaluate  (round(sum(i for i in ${power_without_not_available})/len(${power_without_not_available}),2))
    Log To Console  Average power for ${RMOD_PRODUCT_NAME} with ${RMOD_SN} before lock -> ${average_power_before_block} W${\n}

    ${length_before}  Get Length  ${power_without_not_available}

    Run Keyword If  '${ACTIVE_SW}'=='SBTS20C'  RMOD Block/Unblock And Check State  Block
    ...  ELSE  RMOD Lock/Unlock And Check State  Lock

    ${rmod_params}  admin.Get Parameters For  RMOD  ${RMOD_TO_BLOCK}
    Run Keyword If  '${ACTIVE_SW}'=='SBTS20C'
    ...  Log To Console  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} has expected state -> ${rmod_params.blockingState}${\n}
    ...  ELSE  Log To Console  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} has expected state -> ${rmod_params.administrativeState}${\n}

    Count Time To Export CSV File
    Log To Console  Waiting ${MINUTES} minutes and ${SECONDS} seconds for export Real-time Measurements after lock !${\n}
    Sleep  ${TIME_TO_SLEEP} seconds

    Export Real-time Measurements to CSV
    Get Latest File From Directory
    Log To Console  Latest exported CSV file -> ${LATEST_FILE}${\n}
    Read CSV to dictionary

    ${power}  Get From Dictionary  ${dict_of_measurements}  ${RMOD_ID}

    ${power}  Evaluate  [ x for x in ${power} if x!='Available' ]
    ${power}  Evaluate  ([float(i) for i in ${power}])

    ${length_after}  Get Length  ${power}
    ${difference}  Evaluate  (${length_after}-${length_before}-1)

    Log To Console
    ...  ${\n}Values used to calculate the average power (last ${difference} from above dictionary):${\n}${RMOD_ID}: ${power}[:${difference}]${\n}

    ${average_power_after_block}  Evaluate  (round(sum(i for i in ${power}[:${difference}])/len(${power}[:${difference}]),2))
    Log To Console  Average power for ${RMOD_PRODUCT_NAME} with ${RMOD_SN} after lock -> ${average_power_after_block} W.
    Log To Console  ${\n}It was ${average_power_before_block} W${\n}

    ${percentage}  Evaluate  (round(100*(1-(${average_power_after_block}/${average_power_before_block})),2))
    ${summary}  Evaluate  (${percentage}<10)

    Log To Console  After lock power on ${RMOD_PRODUCT_NAME} with ${RMOD_SN} has decreased by ${percentage}% !${\n}

    Run Keyword If  ${summary}==True  Run Keywords
    ...  admin.Unlock  ${RMOD_TO_BLOCK}
    ...  AND  Fail  Power dropped too low, minimum drop is 10% !
    ...  ELSE
    ...  Log To Console  Correct power values after ${RMOD_PRODUCT_NAME} block, going to next step !${\n}

    ${length_before_unblock}  Get Length  ${power}
    Set Test Variable  ${AVERAGE_POWER_AFTER_BLOCK}  ${average_power_after_block}
    Set Test Variable  ${LENGTH_BEFORE_UNBLOCK}  ${length_before_unblock}


step5: Unlock RMOD and Check Power

    Log To Console  step5: Unlock RMOD and Check Power${\n}

    Run Keyword If  '${ACTIVE_SW}'=='SBTS20C'  RMOD Block/Unblock And Check State  Unblock
    ...  ELSE  RMOD Lock/Unlock And Check State  Unlock

    ${rmod_params}  admin.Get Parameters For  RMOD  ${RMOD_TO_BLOCK}
    Run Keyword If  '${ACTIVE_SW}'=='SBTS20C'
    ...  Log To Console  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} has expected state -> ${rmod_params.blockingState}${\n}
    ...  ELSE  Log To Console  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} has expected state -> ${rmod_params.administrativeState}${\n}

    ${status}  Run Keyword And Return Status  Check If All Cells Are OnAir  timeout=240
    Run Keyword If  '${status}'=='False'
    ...  Fail  At least one cell is NOT onAir after recommissioning! Feature deactivated and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    Count Time To Export CSV File
    Log To Console  ${\n}Waiting ${MINUTES} minutes and ${SECONDS} seconds for export Real-time Measurements after unlock !${\n}
    Sleep  ${TIME_TO_SLEEP} seconds

    Export Real-time Measurements to CSV
    Get Latest File From Directory
    Log To Console  Latest exported CSV file -> ${LATEST_FILE}${\n}
    Read CSV to dictionary

    ${power}  Get From Dictionary  ${dict_of_measurements}  ${RMOD_ID}
    ${power}  Evaluate  [ x for x in ${power} if x!='Available' ]
    ${power}  Evaluate  ([float(i) for i in ${power}])

    ${length_after_unblock}  Get Length  ${power}
    ${difference}  Evaluate  (${length_after_unblock}-${LENGTH_BEFORE_UNBLOCK}-1)

    Log To Console
    ...  ${\n}Values used to calculate the average power (last ${difference} from above dictionary):${\n}${RMOD_ID}: ${power}[:${difference}]${\n}

    ${average_power_after_unblock}  Evaluate  (round(sum(i for i in ${power}[:${difference}])/len(${power}[:${difference}]),2))
    Log To Console  Average power for ${RMOD_PRODUCT_NAME} with ${RMOD_SN} after unblock -> ${average_power_after_unblock} W.
    Log To Console  ${\n}It was ${AVERAGE_POWER_AFTER_BLOCK} W

    ${percentage}  Evaluate  (round(100*((${average_power_after_unblock}/${average_power_after_block})-1),2))
    ${summary}  Evaluate  (${percentage}<10)

    Log To Console  After unlock power on ${RMOD_PRODUCT_NAME} with ${RMOD_SN} has increased by ${percentage}% !${\n}

    Run Keyword If  ${summary}==True
    ...  Fail  Power increased too low, minimum increase is 10% !
    ...  ELSE  Log To Console  Correct power values after RMOD unlock, going to next step !${\n}

step6: Deactivate Embedded Power Meter For Enegry Efficiency Monitoring

    Log To Console  step6: Deactivate Embedded Power Meter For Enegry Efficiency Monitoring${\n}

    Log To Console  Updating actPowerMeter parameter to false ...${\n}
    admin.Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true

    Log To Console  Checking if all cells are still onAir after recommissioning
    ${status}  Run Keyword And Return Status  Check If All Cells Are OnAir
    Run Keyword If  '${status}'=='False'
    ...  Fail  At least one cell is NOT onAir after recommissioning! Feature deactivated and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    Log To Console  ${\n}Now checking if Embedded Power Meter For Enegry Efficiency Monitoring was deactivated successful...
    Log To Console  ${\n}Waiting max. 5 minutes for Real-time measurements ! Attempt to read every minute !${\n}
    ${EEM_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  1 minute  Check Real Time Measurements  False

    Run Keyword If  ${EEM_status}!=True
    ...  Fail  Embedded Power Meter For Enegry Efficiency Monitoring feature wasn't disabled or Admin reset wasn't perform !
    ...  ELSE
    ...  Log To Console  Real-time measurements isn't generated --> Embedded Power Meter For Enegry Efficiency Monitoring feature deactivated OK !

Restore Reference Configuration

    Log To Console  Restore Reference Configuration...\n

    ${actual_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=default
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actpowermeter_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${OBJECT_VARIABLE_ACTPOWERMETER}']/p[@name='actPowerMeter']/text())
    Set To Dictionary  ${actual_dict}  actPowerMeter  ${actpowermeter_scf}

    Run Keyword If  '${REFERENCE_DICT['actPowerMeter'].lower()}' != '${actual_dict['actPowerMeter'].lower()}'  Run Keywords
    ...  Log To Console  Energy Efficiency Monitoring feature have to be restored to reference state, please wait !
    ...  AND  admin.Perform Parameter Recommissioning
    ...  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  ${REFERENCE_DICT['actPowerMeter']}
    ...  AND  Log To Console  Energy Efficiency Monitoring feature restored to actPowerMeter -> ${REFERENCE_DICT['actPowerMeter']}
    ...  ELSE
    ...  Log To Console  Energy Efficiency Monitoring feature already in reference state, no more actions needed!

RMOD Block/Unblock And Check State
    [Documentation]
    ...  KW for Block/Unblock RMOD and check state.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW blocks or unblocks RMOD.
    ...  | After block/unblock checks if blocking state is correct.
    ...  | If isn't -> parameters restoring and setting test failed

    [Arguments]  ${operation}

    Run Keyword If  '${operation}'=='Block'  Run Keywords  Log To Console  Blocking ${RMOD_PRODUCT_NAME} with ${RMOD_SN}, please wait ! ${\n}
    ...  AND  Block  ${RMOD_TO_BLOCK}
    ...  ELSE IF  '${operation}'=='Unblock'  Run Keywords  Log To Console  Unblocking ${RMOD_PRODUCT_NAME} with ${RMOD_SN}, please wait !${\n}
    ...  AND  Unblock  ${RMOD_TO_BLOCK}

    ${rmod_params}  admin.Get Parameters For  RMOD  ${RMOD_TO_BLOCK}
    Run Keyword If  '${rmod_params.blockingState}'=='Unblocked' and '${operation}'=='Block'  Run Keywords  Perform Parameter Recommissioning
    ...  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND  Fail
    ...  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} was not blocked correctly, blockingState is ${rmod_params.blockingState}, should be Blocked !${\n}
    ...  ELSE IF  '${rmod_params.blockingState}'=='Blocked' and '${operation}'=='Unblock'  Run Keywords  Perform Parameter Recommissioning
    ...  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND  Fail  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} was not unblocked correctly, blockingState is Blocked, should be Unblocked !${\n}


RMOD Lock/Unlock And Check State
    [Documentation]
    ...  KW for Lock/Unlock RMOD and check state.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW locks or unlocks RMOD.
    ...  | After lock/unlock checks if locking state is correct.
    ...  | If isn't -> parameters restoring and setting test failed
    ...  | Lock/unlock functionality is working from SBTS00 after 19.10.2020

    [Arguments]  ${operation}

    Run Keyword If  '${operation}'=='Lock'  Run Keywords  Log To Console  Locking ${RMOD_PRODUCT_NAME} with ${RMOD_SN}, please wait ! ${\n}
    ...  AND  admin.Lock  ${RMOD_TO_BLOCK}  timeout=180
    ...  ELSE IF  '${operation}'=='Unlock'  Run Keywords  Log To Console  Unlocking ${RMOD_PRODUCT_NAME} with ${RMOD_SN}, please wait !${\n}
    ...  AND  admin.Unlock  ${RMOD_TO_BLOCK}  timeout=180

    ${rmod_params}  admin.Get Parameters For  RMOD  ${RMOD_TO_BLOCK}
    Run Keyword If  '${rmod_params.administrativeState}'=='Unlocked' and '${operation}'=='Lock'  Run Keywords  Perform Parameter Recommissioning
    ...  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND  Fail
    ...  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} wasnt locked correctly, administrativeState ${rmod_params.administrativeState}, should be Locked${\n}
    ...  ELSE IF  '${rmod_params.administrativeState}'=='Locked' and '${operation}'=='Unlock'  Run Keywords  Perform Parameter Recommissioning
    ...  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND  Fail  ${RMOD_PRODUCT_NAME} with ${RMOD_SN} was not unlocked correctly, administrativeState is Locked, should be Unlocked !${\n}


Open Real-time Measurements on WebEM
    [Documentation]  KW opens Google Chrome and goes to "Real-Time measurements" bookmark
    ...  The goal of KW is to display a measurement table and button "Export to CSV"
    ${beginning}=  Set Variable  //*[@id="main-view"]/div/div[1]
    IF  '${ACTIVE_SW}'=='SBTS26R3'
      Set Test Variable   ${XPATH_TO_TABLE}
      ...  ${beginning}/div/div/div[1]/ng-view/wf-panel/wf-panel-section/div/div/div/div/div/div/div[3]/div/div[1]/im-counters-main/div
      Login To WebEM Via Selenium New GUI
    ELSE IF  '${ACTIVE_SW}'=='SBTS26R1' or '${ACTIVE_SW}'=='SBTS26R2'
      Set Test Variable   ${XPATH_TO_TABLE}
      ...  ${beginning}/div[1]/div/div/ng-view/wf-panel/wf-panel-section/div/div/div/div/div/div/div[3]/div/div[1]/im-counters-main/div
      Login To WebEM Via Selenium New GUI
    ELSE IF  '${ACTIVE_SW}'=='SBTS25R1' or '${ACTIVE_SW}'=='SBTS25R2' or '${ACTIVE_SW}'=='SBTS25R3'
      Set Test Variable   ${XPATH_TO_TABLE}
      ...  ${beginning}/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/div/div/div/div/div[3]/div/div[1]/im-counters-main/div
      Login To WebEM Via Selenium New GUI
    ELSE
      Set Test Variable   ${XPATH_TO_TABLE}
      ...  ${beginning}/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div/div/div/div[3]/div/div[1]/im-counters-main/div
      Login To WebEM Via Selenium
    END

    Go To  https://192.168.255.129/#/performance/real-time-counters
    Sleep  1s
    Wait Until Keyword Succeeds  20x  15s  Double Click Element  //*[contains(text(),'ENERGY EFFICIENCY')]
    Wait Until Keyword Succeeds  20x  15s  Click Element  //span[@value="ENERGY_EFFICIENCY*-*RMOD"]

Export Real-time Measurements to CSV
    [Documentation]  KW for export Real-Time measurements table to CSV file.
    ...  To avoid screenlock countdown, mouse over move is simulating.

    ${date} =	Get Current Date	result_format=%m%d%Y-%H%M
    ${file_name}  Set Variable  PM_${bts_name}_RTM_${date}.csv

    ${table_status}  Run Keyword And Return Status  Append Measurements Table To File  ${file_name}
    Run Keyword If  ${table_status}==False  Run Keywords
    ...  Log to console  Cannot export Real-time measurements to CSV file, probably table is not visible in WebEM ! Set Test Fail !${\n}
    ...  AND  Perform Parameter Recommissioning  ${OBJECT_VARIABLE_ACTPOWERMETER}  actPowerMeter  update  false  skip_parameter_relation_errors=true
    ...  AND  Fail  Cannot export Real-time measurements to CSV file !
    Sleep  10s

    Mouse Over  ${XPATH_TO_TABLE}

Append Measurements Table To File
    [Arguments]  ${file_name}
    [Documentation]  KW checks if table with Real-time measurements is visible in Admin.
    ...  If is visible -> gets table and append to file (create file)
    ...  If isn't visible -> prints information for user and return from keyword

    ${table_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5x  5 s  Element Should Be Visible  ${XPATH_TO_TABLE}
    Run Keyword If  ${table_status}==False  Run Keywords
    ...  Log to console  Real-Measurements Table is not visible in WebEM !${\n}
    ...  AND  Return From Keyword

    ${raw_table}  Get Text  ${XPATH_TO_TABLE}
    ${table}  Replace String  ${raw_table}  ${SPACE}  ,
    Append to file  ${Test Files}/CSV Measurements/${file_name}  ${table}


Read CSV to dictionary
    [Documentation]  KW returns dictionary containing the name of RMOD(s)
    ...  and the corresponding power values in watts.
    ...  Dictionary is created from a CSV file.
    ...  Form of dictionary: [rmod_name: [list_of_power_values_in_watt], rmod_name: [list_of_power_values_in_watt]]

    ${csv}=  OperatingSystem.Get File  ${Test Files}/CSV Measurements/${LATEST_FILE}
    @{csv_to_lines}  Split To Lines  ${csv}
    ${header}  Evaluate  ('${csv_to_lines}[0]'.split(','))
    ${list_of_measurements}  Create List
    ${header}  Evaluate  (set(${header}[2:]))
    ${header}  Evaluate  [int(i.split('-', -1)[1]) for i in ${header}]
    ${header}  Evaluate  (sorted(${header}))
    @{ee_rmods}  Create List

    FOR  ${column}  IN  @{header}
      Append to list  ${ee_rmods}  RMOD_R-${column}
    END

    Set Test Variable  ${EE_RMODS}  ${ee_rmods}

    ${measurements}  Evaluate  (${csv_to_lines}[3:])
    ${dict_of_measurements}  Evaluate  ({i:[] for i in ${EE_RMODS}})
    Set Test Variable  ${DICT_OF_MEASUREMENTS}  ${dict_of_measurements}

    FOR  ${line}  IN  @{measurements}
      ${values}  Split String  ${line}  ,
      ${contains_dst}  Run Keyword And Return Status  List Should Contain Value  ${values}  DST
      IF  ${contains_dst}
          ${power_values}  Evaluate  (${values}[4::2])
      ELSE
          ${power_values}  Evaluate  (${values}[3::2])
      END
      Loop Over Dictionary Keys  ${power_values}
    END

    Log To Console  Current dictionary structure:${\n}
    FOR  ${key}  ${values}  IN ZIP  ${DICT_OF_MEASUREMENTS.keys()}  ${DICT_OF_MEASUREMENTS.values()}
      Log To Console  ${key} ${values}
    END

Loop Over Dictionary Keys

    [Arguments]  ${value}
    FOR  ${key}  IN  @{DICT_OF_MEASUREMENTS.keys()}
       ${index}  Index of RMODs List  ${key}
       ${value_of_index}  Get From List  ${EE_RMODS}  ${index}
       Run Keyword If  '${key}'=='${value_of_index}'  Append to list  ${DICT_OF_MEASUREMENTS}[${key}]  ${value}[${index}]
       ...  ELSE  Continue For Loop
    END

Index of RMODs List
        [Arguments]  ${key}
        ${index}  Get Index From List  ${EE_RMODS}  ${key}
        [Return]  ${index}

Get Latest File From Directory
    [Documentation]  KW gets the latest file that start with PM (Performance Management).
    ...  This is a file exported using KW "Export Real-time measurements to CSV"
    ...  Path to download CSV file is a variable defined by user and must be the same as in browser settings !

    ${filelist}=  OperatingSystem.List Files in Directory  ${Test Files}/CSV Measurements
    ${pm_files}  Evaluate  [ i for i in ${filelist} if i.startswith('PM')]
    ${latest_file}  Evaluate  (sorted(${pm_files},reverse=True)[0])
    Set Test Variable  ${LATEST_FILE}  ${latest_file}

Count CSV File Rows
    [Documentation]  KW counts CSV file lines with exclusion the first three lines that they not contain values in Watts.

    ${csv}=  OperatingSystem.Get File  ${Test Files}/CSV Measurements/${LATEST_FILE}
    @{csv_to_lines}  Split to lines  ${csv}
    ${count_of_rows}  Get length  ${csv_to_lines}
    [Return]  ${count_of_rows-3}

Count Time To Export CSV File

    ${actual_seconds}  Get Time  seconds
    ${actual_seconds}  Convert To Integer  ${actual_seconds}
    ${time_to_sleep}  Evaluate  ((${TIME_TO_WAIT}*60)-${actual_seconds}+10)
    ${seconds_from_modulo}  Evaluate  (${time_to_sleep}%60)
    ${minutes}  Evaluate  ((${time_to_sleep}-${seconds_from_modulo})/60)
    Set Test Variable  ${TIME_TO_SLEEP}  ${time_to_sleep}
    Set Test Variable  ${SECONDS}  ${seconds_from_modulo}
    Set Test Variable  ${MINUTES}  ${minutes}

TC Setup
    hran_frame_sbts_siso.Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}  Restore Reference Configuration
    hran_frame_sbts_siso.Common Test Teardown
    SeleniumLibrary.Close Browser
