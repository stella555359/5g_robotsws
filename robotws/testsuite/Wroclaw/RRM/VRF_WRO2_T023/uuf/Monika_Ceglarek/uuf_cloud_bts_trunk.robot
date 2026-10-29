*** Settings ***
Documentation
...   contact: Monika Ceglarek


Resource       ../../feature_resources/UUF/vDU_reset.robot


*** Variables ***
${ITERATIONS_NUMBER}        100             # Number of iterations
${CU_OAM_VERSION_VCU}       cuoam_25r2      # vCU version
${CU_OAM_VERSION_VDU}       cuoam_25r2      # vDU version

@{ALLOWED_ALARMS_VCU}                       # List of allowed alarms for vCU
@{ALLOWED_ALARMS_VDU}                       # List of allowed alarms for vDU
@{CRITICAL_ALARMS_VCU}                      # List of disallowed alarms for vCU
@{CRITICAL_ALARMS_VDU}                      # List of disallowed alarms for vDU

${ALARM_TIMEOUT}                   120      # Time in seconds for waiting for unexpected alarms after vDU reset
${REACH_ONAIR_TIMEOUT}             450      # Time in seconds for waiting for BTS to go on air after vDU reset
${LOSE_OF_CONNECTION_TIMEOUT}      150      # Time in seconds for waiting for BTS to lose connection after vDU reset

${STOP_AFTER_CONSECUTIVE_FAILS}    True     # Stop execution after 3 consecutive fails. The counter goes back to 0 if iteration passes.
${CELL_GRACEFUL_SHUTDOWN}          False    # Perform graceful shutdown for cells during vDU reset operation. Default value: False.

*** Test Cases ***
VDU Reset Test
    [Timeout]  100h
    [Setup]  TC Setup
    ...  iterations_number=${ITERATIONS_NUMBER}
    ...  allowed_alarms_vcu=${ALLOWED_ALARMS_VCU}
    ...  allowed_alarms_vdu=${ALLOWED_ALARMS_VDU}
    ...  critical_alarms_vcu=${CRITICAL_ALARMS_VCU}
    ...  critical_alarms_vdu=${CRITICAL_ALARMS_VDU}
    ...  cu_oam_version_vcu=${CU_OAM_VERSION_VCU}
    ...  cu_oam_version_vdu=${CU_OAM_VERSION_VDU}
    ...  reach_onair_timeout=${REACH_ONAIR_TIMEOUT}
    ...  alarm_timeout=${ALARM_TIMEOUT}
    ...  lose_of_connection_timeout=${LOSE_OF_CONNECTION_TIMEOUT}
    ...  stop_after_consecutive_fails=${STOP_AFTER_CONSECUTIVE_FAILS}
    ...  cell_graceful_shutdown=${CELL_GRACEFUL_SHUTDOWN}
    VDU Reset Test
    [Teardown]  TC Teardown
