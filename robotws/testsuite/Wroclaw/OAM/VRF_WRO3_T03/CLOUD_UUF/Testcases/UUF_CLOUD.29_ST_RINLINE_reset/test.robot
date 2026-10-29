*** Settings ***
# 1. Robot Framework built-in libraries
Library         Collections

# 2. TAF libraries
Library         taf.gnb.oam.coam.cu         WITH NAME    vcu_admin
Library         taf.gnb.oam.coam.vdu        WITH NAME    vdu_admin
Library         taf.ul.vdu.helm.interface.helm    WITH NAME    helm

# 3. RFRL Resource files
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot

# 4. Local Resource files
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/resets/resets.robot

Documentation
...  TEST NAME:     UUF_CLOUD.29_ST_RINLINE_reset
...  AUTHORS:       marek.starzyk@gmail.com
...  MAINTAINER:    VRF_WRO3_T03
...  *****************
...  Basic information
...  *****************
...  This test verifies RINLINE reset operation on vDU system in cloud environment.
...  The test performs reset on a randomly selected R-NIC and checks
...  that the system recovers correctly, with all cells returning to ON-AIR state
...  and no unexpected alarms present.
...  Expected duration: ~15 minutes (including 10min wait for cells)
...  *****************
...  Scope and Preconditions
...  *****************
...  Scope:
...  - vDU systems in cloud environment
...  Preconditions:
...  - vDU system must be in ON-AIR state
...  - At least one R-NIC distribution must be available
...  - Admin connection to system must be established
...  - All cells must be operational before test start
...  *****************
...  RAN PZ3 WRO3 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  15.01.2026 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-33968 - TC Creation

*** Variables ***
${HW_TYPE}                             vDU
${CELLS_ON_AIR_TIMEOUT}                10min
${CELLS_ON_AIR_INTERVAL}               30s
# vDU allowed alarms during R-NIC reset operation:
# 4405 - No usable time reference available
# 4298 - ToP reference missing
# 16   - Unit synchronization failed
@{vDU_TEST_SPECIFIC_ALLOWED_ALARMS}    4405    4298    16
# vCU allowed alarms during R-NIC reset operation:
# 7104 - Matching ServedCell not found over F1-C
@{vCU_TEST_SPECIFIC_ALLOWED_ALARMS}    7104

*** Keywords ***
UUF_CLOUD.29_ST_RINLINE_reset
    [Documentation]    Main orchestration keyword for UUF_CLOUD.29 test.
    ...
    ...                Executes complete R-NIC reset test scenario:
    ...                - Prepares test environment with allowed alarms
    ...                - Performs R-NIC reset on random distribution
    ...                - Verifies system recovery and alarm state
    ...
    ...                Expected duration: ~15 minutes (including 10min wait for cells)
    UUF_CLOUD.29_ST_RINLINE_reset:0 Test Preparation
    UUF_CLOUD.29_ST_RINLINE_reset:1 Perform R-NIC Reset
    UUF_CLOUD.29_ST_RINLINE_reset:2 Check after reset

UUF_CLOUD.29_ST_RINLINE_reset:0 Test Preparation
    common.Decorate Print    Step: 0 Test Preparation
    Add Alarms To Watchdog
    ...    alarms_list=${vDU_TEST_SPECIFIC_ALLOWED_ALARMS}
    ...    hw_type=${HW_TYPE}
    Add Alarms To Watchdog
    ...    alarms_list=${vCU_TEST_SPECIFIC_ALLOWED_ALARMS}
    ...    hw_type=vCU

UUF_CLOUD.29_ST_RINLINE_reset:1 Perform R-NIC Reset
    [Documentation]
    ...    Performs R-NIC reset on randomly selected distribution.
    ...    Steps:
    ...    1. Selects random R-NIC distribution name
    ...    2. Executes reset operation
    ...    3. Verifies reset completed successfully

    common.Decorate Print    Step: 1 Perform R-NIC Reset
    ${rnic_dist_name}=       common.Get Random RNIC Dist Name
    common.Perform RNIC Reset and Verify Success    rnic_dist_name=${rnic_dist_name}

UUF_CLOUD.29_ST_RINLINE_reset:2 Check after reset
    [Documentation]    Verifies system state after R-NIC reset.
    ...    Steps:
    ...    1. Waits for all cells to come back ON-AIR (max 10min)
    ...    2. Removes temporary allowed alarms from watchdog
    ...    3. Verifies no unexpected alarms are present
    ...
    ...    Timeout: ${CELLS_ON_AIR_TIMEOUT} (10 minutes)
    ...    Check interval: ${CELLS_ON_AIR_INTERVAL} (30 seconds)

    common.Decorate Print    Step: 2 Check after reset
    Wait Until Keyword Succeeds
    ...    ${CELLS_ON_AIR_TIMEOUT}
    ...    ${CELLS_ON_AIR_INTERVAL}
    ...    common.Check If All Cells On Air
    ...    hw_type=${HW_TYPE}
    ...    connection=${admin_connection}
    Delete Alarms From Watchdog
    ...    alarms_list=${vDU_TEST_SPECIFIC_ALLOWED_ALARMS}
    ...    hw_type=${HW_TYPE}
    Delete Alarms From Watchdog
    ...    alarms_list=${vCU_TEST_SPECIFIC_ALLOWED_ALARMS}
    ...    hw_type=vCU
    common.Check Alarm List On vCU/vDU
    ...    hw_type=${HW_TYPE}
