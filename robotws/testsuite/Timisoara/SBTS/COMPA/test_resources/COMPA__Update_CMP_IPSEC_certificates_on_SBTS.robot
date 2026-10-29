*** Settings ***
Documentation
    ...  Main purpose of TC is update CMP-IPSEC certificates on SBTS.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${REFERENCE_NUMBER}  ${EMPTY}  # Mandatory. Reference number for set certificate.
${PRESHARED_KEY}  ${EMPTY}  # Mandatory. Pre-shared key for set certificate.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to be reported in WebEM.


*** Keywords ***
TC__COMPA__Update_CMP_IPSEC_certificates_on_SBTS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29435
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  03.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29435 - Initial TAT creation
    ...  25.07.2027 - https://jiradc.ext.net.nokia.com/browse/TAT-29575 - Add alarm timeout variable

    Set Tags  CA-COMPA  OWNER-daniel.cozma@nokia.com  MAINTAINER-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS25

    Step1: Perform IPSec Certificates Installation


Step1: Perform IPSec Certificates Installation
    Log  Step1: Perform IPSec certificates installation  console=true
    ${fault_status}  Run Keyword And Return Status  Assert Alarm Active  parameters=alarmId=7220, faultId=61510,
    ...  alarmName="BASE STATION SECURITY PROBLEM", faultName="Automatic BTS Operator Certificate retrieval unsuccessful"  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status}
        Log  Fault 61510 is active![OK]  console=true
    ELSE
        Log  Fault 61510 is not active.This TC will be skipped!  console=true
        RETURN
    END
    Should Not Be Empty  ${REFERENCE_NUMBER}  Reference number must be specified, please provide it and retest.
    Should Not Be Empty  ${PRESHARED_KEY}  Pre-shared key must be specified, please provide it and retest.
    coam.Set Certificate Automatic Managment  reference_number=${REFERENCE_NUMBER}  preshared_key=${PRESHARED_KEY}  timeout=60
    Assert Alarm Inactive  parameters=alarmId=7220, faultId=61510, alarmName="BASE STATION SECURITY PROBLEM",
    ...  faultName="Automatic BTS Operator Certificate retrieval unsuccessful"  timeout=${ALARM_TIMEOUT}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup


TC Teardown
    Common Test Teardown
