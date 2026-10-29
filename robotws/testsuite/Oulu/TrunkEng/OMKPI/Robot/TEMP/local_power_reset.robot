*** Settings ***
Documentation
...   Author:   Heikki Autio
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiStartupTimesInterface  WITH NAME  Startup


Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
${KPI_3_LIMIT}          300    # seconds
${POWER_BREAKER_IP}     10.34.124.158
${PB_MODEL}             pkc
&{SMODS_AND_PORTS}      ASIM1=7
${PB_WAIT}    5    # seconds to wait between power off and on
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was  Failed to execute executable  RecoveryConstraints
                   ...  RecoveryActionController    Executing recovery action
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
${WAIT_CHECKS}          360       # seconds, 0 if no waiting nor printing before post conditions check
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt

*** Test Cases ***
OMKPI Power Reset
    [Documentation]  Resets BTS by setting power off and then on and counts time to OnAir.
    Run Keyword In Loop And Return Pass Rate
        ...    name=Power Reset
        ...    test_case=1
        ...    loops=1
        ...    keywords=Power Reset
        ...    expected_pass_rate=1

*** Keywords ***
Power Reset
    Start Syslog Print Search To Background     ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    Setup Power Breaker Controller        smod  ${PB_MODEL}  ${POWER_BREAKER_IP}  ${SMODS_AND_PORTS}
    Print Step Text                    2  Switch power OFF wait ${PB_WAIT} and switch power ON

    Run Keyword And Continue On Failure   Turn Power Off From Chosen Units  ASIM1
    Run Keyword And Continue On Failure   Turn Power On To Chosen Units   ASIM1
    Ping Ip Until Disconnection Or Reconnection   ip_to_ping=192.168.255.129  disconnection=True    time_to_wait=300
    Ping Ip Until Disconnection Or Reconnection   ip_to_ping=192.168.255.129  time_to_wait=300
    Run Keyword And Continue On Failure   Check If Admin Connection Available   360
    Print Step Text                    3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                    4  Check If spurious reset in Syslog prints
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    5  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}