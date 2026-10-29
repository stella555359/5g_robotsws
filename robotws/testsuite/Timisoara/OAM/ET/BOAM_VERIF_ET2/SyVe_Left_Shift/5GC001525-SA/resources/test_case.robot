*** Settings ***
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh
Library     DateTime
Library     taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli

Resource    ../../../SyVe_Left_Shift/resources/selenium.robot
Resource    ../../../SyVe_Left_Shift/resources/fault_trigger.robot
Resource    ../resources/keyword.robot

Resource    ../resources/5GC001525-SA.robot    # TODO to be removed after migration of all valid keywords

*** Keywords ***
Perform activate service account synchronization to RU devices
   # PREPOST Setup Admin
    ${sw_version}=    ADMIN Get Sw Version
    ${split_build}=    Split string       ${sw_version}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Log To Console   ${version}
    Run Keyword If  '${version}' == '${TRUNK_VERSION}'   admin_cli.perform_parameter_recommissioning
    ...                                            dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            parameter=actSyncToRU
    ...                                            operation=update
    ...                                            value=true
    ...                                            skip_parameter_relation_errors=True
    Run Keyword If  '${version}' == 'SBTS22R2'   admin_cli.perform_parameter_recommissioning
    ...                                            dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            parameter=actSyncToRU
    ...                                            operation=update
    ...                                            value=true
    ...                                            skip_parameter_relation_errors=True
    Run Keyword If  '${version}' == 'SBTS22R3'   admin_cli.perform_parameter_recommissioning
    ...                                            dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            parameter=actSyncToRU
    ...                                            operation=update
    ...                                            value=true
    ...                                            skip_parameter_relation_errors=True

Get Date and Time for Syve
     ${date}=    Get Current Date    UTC    + 1 hours    result_format=%Y%m%d-%H%M
     Set Test Variable    ${date}

SUITE SETUP Feature 1525-SA
    Log To Console    SUITE SETUP Feature 1525-SA
    Suite Preconditions

TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms Setup
    [Documentation]    Feature 5GC001525-SA TC 01a.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms
    [Documentation]    Feature 5GC001525-SA TC 01a.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms
    Perform activate service account synchronization to RU devices
    Trigger Fault 10 - Radio reset
    SELENIUM Go To Active Alarms Tab
    Wait until fault 10 is visible
    ${1}=    Convert To Integer    1
    Get Date and Time for Syve
    Check How Many Times Fault Is In Alarms File    faultId=${fault_id_NoConnectionToUnit}
    ...                                             date_csv=${date}
    ...                                             occurrence=${1}
    ...                                             alarmType=current
    Check If MO Is In Proper Field


TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms Teardown
    [Documentation]    Feature 5GC001525-SA TC 01a.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms Teardown
	ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History Setup
    [Documentation]    Feature 5GC001525-SA TC 01b.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History Setup
    Test Preconditions
    Wait For Onair
    keyword.SELENIUM Setup

TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History
    [Documentation]    Feature 5GC001525-SA TC 01b.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History
    ADMIN Reset Site And Wait For Onair
    Trigger Fault 10 - Radio reset
    SELENIUM Go To Active Alarms Tab
    Wait until fault 10 is visible
    SELENIUM Go To Alarm History Tab
    Wait until fault 10 is visible
    ${1}=    Convert To Integer    1
    Get Date and Time for Syve
    Check How Many Times Fault Is In Alarms File    faultId=${fault_id_NoConnectionToUnit}
    ...                                             date_csv=${date}
    ...                                             occurrence=${1}
    ...                                             alarmType=historical

TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History Teardown
    [Documentation]    Feature 5GC001525-SA TC 01b.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History Teardown
    ${status}    ADMIN Is alarm active    fault_id=10
    Run Keyword If    ${status}    Cancel Fault 10 - PDU Turn On All Rmods
    ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View Setup
    [Documentation]    Feature 5GC001525-SA TC 01c.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View
    [Documentation]    Feature 5GC001525-SA TC 01c.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View
    Trigger Fault 10 - Radio reset
    Check If RMOD State Is Failed
    Check If RMOD State Is Valid

TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View Teardown
    [Documentation]    Feature 5GC001525-SA TC 01c.
    Log To Console    TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View Teardown
    ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Active Alarms Storage - Clear No Active Alarms After Reset Setup
    [Documentation]    Feature 5GC001525-SA TC 03b.
    Test Preconditions
    ADMIN Wait Until BTS OnAir

TC Active Alarms Storage - Clear No Active Alarms After Reset
    [Documentation]    Feature 5GC001525-SA TC 03b.
#    [Arguments]        ${timeout}=40 min
    [Timeout]   60 min
    Fault 28 Trigger And Should Be Raised
    ADMIN Reset Site And Wait For Onair
    ADMIN Assert Alarm Inactive    parameters=faultId=28
    ...                            timeout=60
    ...                            alias=${admin_alias}


TC Active Alarms Storage - Clear No Active Alarms After Reset Teardown
    [Documentation]    Feature 5GC001525-SA TC 03b.
    Remove downloaded builds
    Test Postconditions

TC Alarm ID Setup
    [Documentation]    Feature 5GC001525-SA TC 04.
    Log To Console    TC Alarm ID Setup
    Test Preconditions
    SELENIUM Setup

TC Alarm ID
    [Documentation]    Feature 5GC001525-SA TC 04.
    Log To Console    TC Alarm ID
    Trigger Fault 10 - Radio reset
    sleep  15s
    SELENIUM Go To Active Alarms Tab
    SELENIUM Check If Alarm Exists    fault_id=${fault_id_NoConnectionToUnit}
    ${first_id_alarm}    Get Alarm ID In WebEM    fault_id=${fault_id_NoConnectionToUnit}
    ADMIN Wait Until BTS OnAir
    ADMIN Reset Site And Wait For Onair
    Trigger Fault 10 - Radio reset
    sleep  15s
    ${second_id_alarm}    Get Alarm ID In WebEM    fault_id=${fault_id_NoConnectionToUnit}
    Should Be Equal    ${first_id_alarm}    ${second_id_alarm}

TC Alarm ID Teardown
    [Documentation]    Feature 5GC001525-SA TC 04.
    Log To Console    TC Alarm ID Teardown
	ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
#    Test Postconditions

TC Fault History Black Box Setup
    [Documentation]    Feature 5GC001525-SA TC 06.
    Test Preconditions
    ADMIN Wait Until BTS OnAir
    Check If Fault Is Not In Black Box History    fauldId=${FAULT_NUMBER}

TC Fault History Black Box
    [Documentation]    Feature 5GC001525-SA TC 06.
    Fault 28 Trigger And Should Be Raised
    ADMIN Reset Site And Wait For Onair
    ADMIN Assert Alarm Inactive    parameters=faultId=28
    ...                            timeout=60
    ...                            alias=${admin_alias}
    Check If Fault Is In Black Box History    faultId=28

TC Fault History Black Box Teardown
    [Documentation]    Feature 5GC001525-SA TC 06.
    Remove downloaded builds
    Test Postconditions

TC Monitor Active Alarms Setup
    [Documentation]    Feature 5GC001525-SA TC 07.
    Log To Console    TC Monitor Active Alarms Setup
    Test Preconditions
    ADMIN Wait Until BTS OnAir

TC Monitor Active Alarms
    [Documentation]    Feature 5GC001525-SA TC 07.
    Log To Console    TC Monitor Active Alarms
    Fault 28 Trigger And Should Be Raised
    Remove downloaded builds
    Fault 28 Cancel And Should Not Be Raised
    Remove downloaded builds
    sleep  120s
    ADMIN Wait Until BTS OnAir
    Trigger Fault 10 - Radio reset
    SELENIUM Setup
    SELENIUM Go To Active Alarms Tab
    wait until keyword succeeds  90s  10s  SELENIUM Check If Alarm Exists    fault_id=${fault_id_NoConnectionToUnit}
    SELENIUM Check If Alarm Not Exists    fault_id=${fault_id_SwPackage}
    Check Alarm Parent Object    fault_id=${fault_id_NoConnectionToUnit}
    ${1}=    Convert To Integer    1
    Get Date and Time for Syve
    Check How Many Times Fault Is In Alarms File    faultId=${fault_id_NoConnectionToUnit}
    ...                                             date_csv=${date}
    ...                                             occurrence=${1}
    ...                                             alarmType=current
#    ${1}=    Convert To Integer    1
#    Get Date and Time for Syve
#    Check How Many Times Fault Is In Alarms File    faultId=${fault_id_NoConnectionToUnit}
#    ...                                             date_csv=${date}
#    ...                                             occurrence=${0}
#    ...                                             alarmType=current


TC Monitor Active Alarms Teardown
    [Documentation]    Feature 5GC001525-SA TC 07.
    Log To Console    TC Monitor Active Alarms Teardown
	ADMIN Wait Until BTS OnAir
	Remove downloaded builds
    SELENIUM Teardown
#    Test Postconditions

TC Monitor Fault History Setup
    [Documentation]    Feature 5GC001525-SA TC 08.
    Log To Console    TC Monitor Fault History Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Monitor Fault History
    [Documentation]    Feature 5GC001525-SA TC 08.
    Log To Console    TC Monitor Fault History
    Trigger Fault 10 - Radio reset
    wait until keyword succeeds  300s  30s  ADMIN Check If Alarm Is In Historical Alarms    fault_id=10    # ${fault_id_SwPackage}
    ADMIN Reset Site And Wait For Onair
    ADMIN Check If Alarm Is Not In Historical Alarms    fault_id=10    # ${fault_id_SwPackage}
    SELENIUM Login To Web Element Manager
    SELENIUM Go To Alarm History Tab
    ${0}=    Convert To Integer    0
    Get Date and Time for Syve
    Check How Many Times Fault Is In Alarms File    faultId=${fault_id_NoConnectionToUnit}
    ...                                             date_csv=${date}
    ...                                             occurrence=${0}
    ...                                             alarmType=historical
    Trigger Fault 10 - Radio reset
    wait until keyword succeeds  300s  30s  ADMIN Check If Alarm Is In Historical Alarms    fault_id=10    # ${fault_id_SwPackage}

    Wait until fault 10 is visible
    ${1}=    Convert To Integer    1
    Get Date and Time for Syve
    Check How Many Times Fault Is In Alarms File    faultId=${fault_id_NoConnectionToUnit}
    ...                                             date_csv=${date}
    ...                                             occurrence=${1}
    ...                                             alarmType=historical

TC Monitor Fault History Teardown
    [Documentation]    Feature 5GC001525-SA TC 08.
    Log To Console    TC Monitor Fault History Teardown
	SELENIUM Teardown
    Test Postconditions

#TC Monitor Fault History Setup
#    [Documentation]    Feature 5GC001525-SA TC 08.
#    Log To Console    TC Monitor Fault History Setup
#    Test Preconditions
#    keyword.SELENIUM-TAF Connect To
#
#TC Monitor Fault History
#    [Documentation]    Feature 5GC001525-SA TC 08.
#    Log To Console    TC Monitor Fault History
#    Trigger Fault 10 - Radio reset
#    wait until keyword succeeds  300s  30s  ADMIN Check If Alarm Is In Historical Alarms    fault_id=10    # ${fault_id_SwPackage}
#    ADMIN Reset Site And Wait For Onair
#    ADMIN Check If Alarm Is Not In Historical Alarms    fault_id=10    # ${fault_id_SwPackage}
#
#    ${path_full}    keyword.SELENIUM-TAF Alarm History - Download File    dir_sub=1
#    keyword.PC Fault Should Not Be In File Alarm History    fault_id=10    path_full=${path_full}
#    Trigger Fault 10 - Radio reset
#    wait until keyword succeeds  300s  30s  ADMIN Check If Alarm Is In Historical Alarms    fault_id=10    # ${fault_id_SwPackage}
#
#    ${path_full}    keyword.SELENIUM-TAF Alarm History - Download File    dir_sub=2
#    keyword.PC Fault Should Be In File Alarm History    fault_id=10    path_full=${path_full}
#
#TC Monitor Fault History Teardown
#    [Documentation]    Feature 5GC001525-SA TC 08.
#    Log To Console    TC Monitor Fault History Teardown
#	keyword.SELENIUM-TAF Teardown
#    Test Postconditions

TC Fault Update In Real Time Setup
    [Documentation]    Feature 5GC001525-SA TC 09.
    Log To Console    TC Fault Update In Real Time Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Fault Update In Real Time
    [Documentation]    Feature 5GC001525-SA TC 09.
    Log To Console    TC Fault Update In Real Time
    SELENIUM Go To Active Alarms Tab
    SELENIUM Check If Alarm Not Exists    fault_id=${fault_id_NoConnectionToUnit}
    Trigger Fault 10 - Radio reset
    Wait Until Keyword Succeeds    2 min
    ...                            10 sec
    ...                            SELENIUM Check If Alarm Exists
    ...                            fault_id=${fault_id_NoConnectionToUnit}
    SELENIUM Teardown
    Log To Console    SELENIUM Login - 1
    keyword.SELENIUM Setup
    SELENIUM Go To Active Alarms Tab
    SELENIUM Check If Alarm Exists    fault_id=${fault_id_NoConnectionToUnit}
#    Cancel Fault 10 - PDU Turn On All Rmods
    Wait Until Keyword Succeeds    300 sec
    ...                            30 sec
    ...                            SELENIUM Check If Alarm Not Exists
    ...                            fault_id=${fault_id_NoConnectionToUnit}
    SeleniumLibrary.Close Browser
        Log To Console    SELENIUM Login - 2
    SELENIUM Login To Web Element Manager
    SELENIUM Go To Active Alarms Tab
    SELENIUM Check If Alarm Not Exists    fault_id=${fault_id_NoConnectionToUnit}

TC Fault Update In Real Time Teardown
    [Documentation]    Feature 5GC001525-SA TC 09.
    Log To Console    TC Fault Update In Real Time Teardown
    ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions


TC Local Time Faults Display And Day Saving Time Setup
    [Documentation]    Feature 5GC001525-SA TC 10.
    Log To Console    TC Local Time Faults Display And Day Saving Time Setup
    Test Preconditions
    ${status}    Run Keyword And Return Status    ADMIN Check If Alarm Is Active    fault_id=61652
    Run Keyword If    ${status}    Cancel Fault 61652
    ADMIN Assert Alarm Inactive    parameters=faultId=61652
    Time Zone Change    timezone=(GMT+1) Europe/Warsaw
    keyword.SELENIUM Setup

TC Local Time Faults Display And Day Saving Time
    [Documentation]    Feature 5GC001525-SA TC 10.
    Log To Console    TC Local Time Faults Display And Day Saving Time
    Ensure That gNB Will Have Time To Perform Reset Before Hour Change
    Trigger Fault 61652
    SELENIUM Go To Active Alarms Tab
    Wait Until Keyword Succeeds    1 min
    ...                            5 sec
    ...                            SELENIUM Check If Alarm Exists
    ...                            fault_id=61652
    ${first_time_alarm}    Get Time Of Alarm In WebEM    fault_id=61652
    Cancel Fault 61652
    Time Zone Change    timezone=(GMT+12) Asia/Anadyr
    ADMIN Wait Until BTS OnAir
    Trigger Fault 61652
    Wait Until Keyword Succeeds    1 min
    ...                            5 sec
    ...                            SELENIUM Check If Alarm Exists
    ...                            fault_id=61652
    ${second_time_alarm}    Get Time Of Alarm In WebEM    fault_id=61652
    Compare Times Of Alarms    ${first_time_alarm}    ${second_time_alarm}
    Cancel Fault 61652

TC Local Time Faults Display And Day Saving Time Teardown
    [Documentation]    Feature 5GC001525-SA TC 10.
    Log To Console    TC Local Time Faults Display And Day Saving Time Teardown
    Time Zone Change    timezone=(GMT+1) Europe/Warsaw
    ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Filter In WebEM Alarm View - Configuration Object Setup
    [Documentation]    Feature 5GC001525-SA TC 12d.
    Log To Console    TC Filter In WebEM Alarm View - Configuration Object Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Filter In WebEM Alarm View - Configuration Object
    [Documentation]    Feature 5GC001525-SA TC 12d.
    Log To Console    TC Filter In WebEM Alarm View - Configuration Object
    ${status}    ADMIN Is alarm active    fault_id=61652
    Run Keyword Unless    ${status}    Trigger Fault 61652
    Trigger Fault 10 - Radio reset
    SELENIUM Go To Active Alarms Tab
    Wait Until Keyword Succeeds    20 sec
    ...                            5 sec
    ...                            Check Alarms Filtering For No Selected Configuration Object
    Wait Until Keyword Succeeds    20 sec
    ...                            5 sec
    ...                            Check Alarms Filtering For BBMOD Configuration Object Selected
    Wait Until Keyword Succeeds    20 sec
    ...                            5 sec
    ...                            Check Alarms Filtering For SMOD Configuration Object Selected
    Wait Until Keyword Succeeds    20 sec
    ...                            5 sec
    ...                            Check Alarms Filtering For RMOD Configuration Object Selected
    Wait Until Keyword Succeeds    20 sec
    ...                            5 sec
    ...                            Check Alarms Filtering For APEQM Configuration Object Selected

TC Filter In WebEM Alarm View - Configuration Object Teardown
    [Documentation]    Feature 5GC001525-SA TC 12d.
    Log To Console    TC Filter In WebEM Alarm View - Configuration Object Teardown
	ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Highlight Faulty Object In HW Service Status View - Faulty Cell Setup
    [Documentation]    Feature 5GC001525-SA TC 13a.
    Log To Console    TC Highlight Faulty Object In HW Service Status View - Faulty Cell Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Highlight Faulty Object In HW Service Status View - Faulty Cell
    [Documentation]    Feature 5GC001525-SA TC 13a.
    Log To Console    TC Highlight Faulty Object In HW Service Status View - Faulty Cell
    Trigger Fault 10 - Radio reset
    Check Failed State Of Cell

TC Highlight Faulty Object In HW Service Status View - Faulty Cell Teardown
    [Documentation]    Feature 5GC001525-SA TC 13a.
    Log To Console    TC Highlight Faulty Object In HW Service Status View - Faulty Cell Teardown
    ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Highlight Faulty Object In HW Service Status View - No Affected Cells Setup
    [Documentation]    Feature 5GC001525-SA TC 13c.
    Log To Console    TC Highlight Faulty Object In HW Service Status View - No Affected Cells Setup
    Test Preconditions
    keyword.SELENIUM Setup

TC Highlight Faulty Object In HW Service Status View - No Affected Cells
    [Documentation]    Feature 5GC001525-SA TC 13c.
    Log To Console    TC Highlight Faulty Object In HW Service Status View - No Affected Cells
    Trigger Fault 4405
    ...    syncInputType=TOPF
    Check OnAir State Of Cell

TC Highlight Faulty Object In HW Service Status View - No Affected Cells Teardown
    [Documentation]    Feature 5GC001525-SA TC 13c.
    Log To Console    TC Highlight Faulty Object In HW Service Status View - No Affected Cells Teardown
    Cancel Fault 4405
    ADMIN Wait Until BTS OnAir
    SELENIUM Teardown
    Test Postconditions

TC Recovery Actions Mechanism Verification Setup
    [Documentation]    Feature 5GC001525-SA TC 16.
    Log To Console    TC Recovery Actions Mechanism Verification Setup
    Test Preconditions

TC Recovery Actions Mechanism Verification
    [Documentation]    Feature 5GC001525-SA TC 16.
    Log To Console    TC Recovery Actions Mechanism Verification
    ADMIN Assert Alarm Inactive    parameters=faultId=${4383}
    Fault 4383 Trigger And Should Have Been Raised

TC Recovery Actions Mechanism Verification Teardown
    [Documentation]    Feature 5GC001525-SA TC 16.
    Log To Console    TC Recovery Actions Mechanism Verification Teardown
    ADMIN Assert Alarm Inactive    parameters=faultId=${4383}
    ADMIN Wait Until BTS OnAir
    Test Postconditions

TC WebEM Alarms Correlation Setup
    [Documentation]    Feature 5GC001525-SA TC 15.
    Log To Console    TC WebEM Alarms Correlation Setup
    Test Preconditions
#    SUITE SETUP Set Variable mrbts_id
#    SUITE SETUP Set Variable nrbts_id
#    SUITE SETUP Set Variable cell_path

TC WebEM Alarms Correlation
    [Documentation]    Feature 5GC001525-SA TC 15.
    Log To Console    TC WebEM Alarms Correlation
    Trigger Fault 1400
    wait until keyword succeeds  300s  10s  ADMIN Check If Alarm Is Active    fault_id=1400
    Trigger Fault 10 - Radio reset
     wait until keyword succeeds  300s  10s  ADMIN Assert Alarm Inactive    parameters=faultId=1400
     wait until keyword succeeds  180s  30s  ADMIN Check If Alarm Is Active    fault_id=10
     wait until keyword succeeds  300s  30s  ADMIN Assert Alarm Inactive    parameters=faultId=10
     wait until keyword succeeds  300s  30s  ADMIN Check If Alarm Is Active    fault_id=1400


TC WebEM Alarms Correlation Teardown
    [Documentation]    Feature 5GC001525-SA TC 15.
    Log To Console    TC WebEM Alarms Correlation Teardown
    ${status}    Run Keyword And Return Status    ADMIN Check If Alarm Is Active    fault_id=1400
    Run Keyword If    ${status}    Cancel Fault 1400
    wait until keyword succeeds  300s  10s  ADMIN Assert Alarm Inactive    parameters=faultId=1400
    ADMIN Wait Until BTS OnAir
    Test Postconditions

