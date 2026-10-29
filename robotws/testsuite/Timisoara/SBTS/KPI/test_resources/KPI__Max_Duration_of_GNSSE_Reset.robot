*** Settings ***
Documentation
    ...  The test randomly selects one GNSSE from the SBTS, performs a reset on it,
    ...  and verifies that the GNSSE recovers and reaches operationalState 'enabled' and
    ...  availabilityStatus 'online' (absent from response) within the expected time window.
    ...  After the reset, an admin check is performed to confirm that all required states
    ...  are restored correctly.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${GNSSE_RECOVERY_TIMEOUT}  600s  #Timeout for GNSSE to recover.


*** Keywords ***
TC__KPI__Max_Duration_of_GNSSE_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30621
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30621 - Initial TAT creation

    Set Tags  CA-KPI  OWNER-oana.badea@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  SW-SBTS26  FEATURE-CB014929

    Step1: Set GNSSE Object
    Step2: Perform GNSSE Reset And Check If Cells And GNSSE Are OnAir After Reset


Step1: Set GNSSE Object
    Log  \nStep1: Set GNSSE Object  console=true

    ${gnsses}  coam.Get Gnsses Statuses
    Should Not Be Empty  ${gnsses}  SBTS doesn't have GNSSE![NOK]
    ${gps}  coam.Get Gps Status
    ${random_gnsse}  Evaluate  random.choice($gps['gnsse'])  modules=random
    Set Test Variable  ${GNSSE_DISTNAME}  ${random_gnsse}[id][internal]
    Set Test Variable  ${GNSSE_NAME}  ${random_gnsse}[name]
    Log  Choosen GNSSE is ${GNSSE_NAME} with distname ${GNSSE_DISTNAME}!  console=true


Step2: Perform GNSSE Reset And Check If Cells And GNSSE Are OnAir After Reset
    Log  \nStep2: Perform GNSSE Reset And Check If Cells And GNSSE Are OnAir After Reset  console=true

    Log  Reset GNSSE will be perform...  console=true
    coam.Reset Unit  ${GNSSE_DISTNAME}  timeout=300
    Wait Until Keyword Succeeds  200  5s  Check GNSSE Operational And Availability State  enabled  degraded
    Log  ${GNSSE_NAME} operationalState is enabled and availability status degraded![OK]  console=true
    Wait Until Keyword Succeeds  ${GNSSE_RECOVERY_TIMEOUT}  10s  Check GNSSE Operational And Availability State  enabled  online
    Log  ${GNSSE_NAME} operationalState is enabled and availability status online, reset was done successfuly![OK]  console=true
    Admin Check All Required State


Check GNSSE Operational And Availability State
    [Arguments]  ${expected_operational_state}  ${expected_availability_status}

    ${gnsses}  coam.Get Gnsses Statuses
    ${gnsse_status}  Set Variable  ${gnsses}[${GNSSE_NAME}]
    Should Be Equal As Strings  ${gnsse_status}[operationalState]  ${expected_operational_state}
    ...  msg=${GNSSE_NAME}: operationalState expected '${expected_operational_state}' but got '${gnsse_status}[operationalState]'![NOK]
    ${key_exists}  Run Keyword And Return Status  Dictionary Should Contain Key  ${gnsse_status}  availabilityStatus
    IF  '${expected_availability_status}' == 'online'
        Should Not Be True  ${key_exists}
        ...  msg=${GNSSE_NAME}: availabilityStatus should not be present when online but found in response![NOK]
    ELSE
        Should Be True  ${key_exists}
        ...  msg=${GNSSE_NAME}: availabilityStatus key not found, expected '${expected_availability_status}'![NOK]
        Should Be Equal As Strings  ${gnsse_status}[availabilityStatus]  ${expected_availability_status}
        ...  msg=${GNSSE_NAME}: availabilityStatus expected '${expected_availability_status}' but got '${gnsse_status}[availabilityStatus]'![NOK]
    END


Calculate GNSSE Reset Duration
    ${kpignssereset}  Calculate kpignssereset  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpignssereset}[kpignssereset][-1][delta]  kpignssereset
    Save Delta Results  kpignssereset


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup


TC Teardown
    Common Test Teardown
    Calculate GNSSE Reset Duration
    Set Log Level  TRACE

