*** Settings ***
Documentation
...  Resource for 4G RRM carrier aggregation

Library           String
Library           Collections
Library           ute_admin_infomodel
Library           ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Resource          ca_siso_general.robot

*** Variables ***

${STATES_ONAIR_LG}  administrativeState=regex"(?i)Unlocked", blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled"
${STATES_ONAIR_WCDMA}  blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled"
${STATES_ONAIR_TRX}  [administrativeState=regex"(?i)Unlocked", blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Enabled"]
${STATES_ON_BLOCK_TRX}  [administrativeState=regex"(?i)Unlocked", availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Blocked",
...                      operationalState=regex"(?i)Disabled"]
${STATES_ON_BLOCK_LG}  administrativeState=regex"(?i)Unlocked", availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Blocked",
...                    operationalState=regex"(?i)Disabled"
${STATES_ON_BLOCK_WCDMA}  availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Blocked", operationalState=regex"(?i)Disabled"
${STATES_ON_LOCK_LG}  administrativeState=regex"(?i)Locked", availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Unblocked",
...                   operationalState=regex"(?i)Disabled"
${STATES_ON_LOCK_WCDMA}  availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Disabled"
${STATES_ON_LOCK_BLOCK_LG}  administrativeState=regex"(?i)Locked", availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Blocked",
...                         operationalState=regex"(?i)Disabled"
${STATES_ON_LOCK_BLOCK_WCDMA}  availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Blocked", operationalState=regex"(?i)Disabled"
${STATES_ON_LOCK_TRX}  [administrativeState=regex"(?i)Locked", availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Unblocked",
...                     operationalState=regex"(?i)Disabled"]
${STATES_ONAIR_SMOD}  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${STATES_ONAIR_RMOD}  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${STATES_ON_LOCK_LNMME}  administrativeState=regex"(?i)Unlocked", availabilityStatus=regex"(?i)Off\\s?line", blockingState=regex"(?i)Unblocked",
...                      operationalState=regex"(?i)Disabled"
${STATES_ON_FAIL_LG}  administrativeState=regex"(?i)Unlocked", blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Disabled",
...                   availabilityStatus=regex"(?i)Failed"
${STATES_ON_FAIL_WCDMA}  blockingState=regex"(?i)Unblocked", operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)Failed"
${DEGRADED_CELL_REGEX}  availabilityStatus=regex"(?i)Degraded"
${DEGRADED_TRX_REGEX}  [availabilityStatus=regex"(?i)Degraded"]

*** Keywords ***



Admin Check All Required States And Alarms
    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...    Assert Every    LNCEL    ${STATES_ONAIR_LG}    search_for_iot_cells=${True}
    ...    AND
	...    Assert No  LNCEL  ${DEGRADED_CELL_REGEX}    search_for_iot_cells=${True}
	...    AND
    ...    Siso Admin Check Cells Number TAF    LNCEL    ${SCF_COUNT_LTE}
    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...    Assert Every    GNCEL    ${STATES_ONAIR_LG}
    ...    AND
	...    Assert No  GNCEL  ${DEGRADED_CELL_REGEX}
	...    AND
    ...    Siso Admin Check Cells Number TAF   GNCEL    ${SCF_COUNT_GSM}
    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...    Assert Every    WNCEL    ${STATES_ONAIR_WCDMA}
    ...    AND
	...    Assert No  WNCEL  ${DEGRADED_CELL_REGEX}
	...    AND
    ...    Siso Admin Check Cells Number TAF    WNCEL    ${SCF_COUNT_WCDMA}
    Assert Every             RMOD    ${STATES_ONAIR_RMOD}
    Assert Every             SMOD    ${STATES_ONAIR_SMOD}
	Assert Alarm Inactive    severity=Critical
	Assert Alarm Inactive    severity=Major

Recovery Action
    [Arguments]  ${bts_host}=192.168.255.129  ${connection_name}=default

    ${release}  radio.Get Active Software Release From ENB
    Wait Until Keyword Succeeds  3m  15s   admin.Setup Admin  bts_host=${bts_host}  name=${connection_name}  release=${release}
    ${status}=  Run Keyword And Return Status   Admin Check All Required States And Alarms
    Run Keyword If  not ${status}  Run Keywords
    ...  Log  Recovery action is needed because alarms and states check failed. Recovery site reset is started    console=${TRUE}
    ...  AND  admin.Reset Site    600
    ...  AND  Wait Until Keyword Succeeds  10m  20s  Admin Check All Required States And Alarms
    Teardown Admin

