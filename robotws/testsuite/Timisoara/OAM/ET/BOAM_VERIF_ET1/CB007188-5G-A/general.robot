*** Settings ***
Documentation
...    Author: Radu Turcu
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: 5GC007188-A
...    Sample execution:
...  /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...  /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007188-5G-A/general.robot

Resource    ./resources/5GC007188-A.robot
Resource    ./resources/xpath_7188-A.robot

# robot -d results -v BROWSER:edge general.robot
# robot -d results -b debug.log general.robot

Suite Setup     run keyword  Login vDU
Suite Teardown  Run Keyword And Ignore Error  Logout vDU

*** Variables ***
${BROWSER} =  chrome
${FIRST_RU_MODULE} =  RMOD-1/AEQP

*** Test Cases ***
#
#[1.0] 2. Check if the alarms can be filtered by faulty_degraded_affected cells
#    [Tags]         CRT
#    Sleep   350
#    Check initial webem status
#    ${RU_module}    Extract RU Type
#    Generate alarm 7102     ${RU_module}
#    Sleep   10
#    Check fault 7102 is raised
#    Filter Alarm By Faulty Degraded Affected
#    Extract Alarm 7102 fault 1931 Date
#    wait until keyword succeeds    1 min    10 sec    UnLook RU      ${RU_module}
#    Check alarm erased   7102
#    Check final webem status
#    Check first cell Availability status  On line
#    Reset vDU
#    Check final webem status
#
#[1.0] 8. Check if gNB_vDU cOAM updates the impacted cells information of an active alarm
#    [Tags]         CRT
#    Sleep   5
#    ${RU_module}    Extract RU Type
#    Generate alarm 7102    ${RU_module}
#    Sleep   10
#    Check fault 7102 is raised
#    ${curent_DateAndTime}   Get BTS current time
#    Extract Alarm 7102 fault 1931 Date
#    Check alarm timestamp   ${curent_DateAndTime}
#    Wait until keyword succeeds    1 min    10 sec    UnLook RU      ${RU_module}
#    Check alarm erased   7102
#    Check final webem status
#    Check first cell Availability status  On line

[1.0] 17. Check if gNB_vDU cOAM does not subject the alarm it has raised due to fault 4001 EFaultId_BtsResetNeededAl to any alarm filtering rules
    [Tags]         CRT

#    Reset vDU
    Log     Generate fault 4383 3 times, "BTS site autonomous reset as recovery action"

    Log to console  Trigger fault 4383 (1)
    Generate Fault 4383
    Restart Browser
    Check fault  4383  wait=480
    Check if OAMEXT container was restarted


    Log to console  Trigger fault 4383 (2)
    Generate Fault 4383
    Restart Browser
    Check fault  4383  wait=480
    Check if OAMEXT container was restarted

    Log to console  Trigger fault 4383 (3)
    Generate Fault 4383
    Restart Browser
    Check fault  4383  wait=480
    Check if OAMEXT container was restarted

    Log to console    Generate fault 4383 4th time, maximum RU recovery attempts reached
    Generate Fault 4383
    Restart Browser
    Check fault  4383  wait=480
    Check fault  4001  wait=480
    Reset vDU
    Check alarm erased   4001
    Check final webem status

[1.0] 20. Check if vDU setups the affected cells when an unlocked RU changes its operationalState
    [Documentation]  Check Cell status updated after RU oprational state change
    [Tags]         CRT

    Lock first RU module
    Check first RU Administrative status  Locked
    Check first cell Availability status  Failed
    ${NumberRUs}    Extract number of RUs
    Run Keyword If      ${NumberRUs} == 1       wait until page contains    Integrated to RAN       timeout=20s
    Run Keyword If      ${NumberRUs} > 1        wait until page contains    OnAir       timeout=20s
    UnLook RU    ${FIRST_RU_MODULE}
    Check first RU Administrative status  Unlocked
    Check first cell Availability status  On line
    Check final webem status
