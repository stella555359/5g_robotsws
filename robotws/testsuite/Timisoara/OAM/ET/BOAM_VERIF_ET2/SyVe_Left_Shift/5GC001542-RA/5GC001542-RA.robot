*** Settings ***
Documentation
...    Author:
...    Maintainer:
...    Description: Trigger snapshot collection after fault
...    Team in charge:
...    QualityCenter:
...    Sample execution: robot --variable CONFIGURATION:$SUITE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/SyVe_Left_Shift/5GC001542-RA/5GC001542-RA.robot

Resource    ./resources/Keywords.robot
Resource    ../resources/admin.robot
Resource    ./resources/PreTest.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN             master_classicalbts_all
#...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   #CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM    #SBTS21B  SBTS22R1


Suite Setup       1542-RA Suite Preconditions
Suite Teardown    1542-RA Suite Postconditions
Test Setup        1542-RA Test Preconditions
Test Teardown     1542-RA Test Postconditions


*** Variables ***
${lssServerIPv4}=    10.5.25.105
${lssServerIPv6}=    2a00:8a00:6000:607c::5611
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True

*** Test Cases ***
#5GC001542_RA_9_Snapshot_collection_triggered_by_multiple_faults_and_next_trigger_different_fault
#    #[Tags]   CRT    SBTS00   SBTS22R4   #SBTS22R3
#    [Documentation]  There is no need to disable Fault 10 (No Connection To Unit), as it will disappear automatically
#	[Setup]    run keywords
#	    ...    1542-RA Test Preconditions  AND
#		...    Set snapshot destination to LSS server    lssIPaddress=${lssServerIPv4}      AND
#		...    Remove Snapshot from LSS server    AND
#        ...    ADMIN Change R&D Port Status    False
#    Configure LSS in WebEM
#    Commission snapshot triggering faults    ${61652}    ${4078}
#    Trigger 5 times fault 61652 and verify snapshot on LSS
#
#    Trigger the 6th time fault 61652 and check if there is no snapshot on LSS
#
#    log to console  trigger fault 4078
#    Trigger fault 4078 and wait for snapshot to be collected on LSS
#
#    [Teardown]    run keywords    Remove Snapshot from LSS server    AND
#    ...    Clear fault trigger list                 AND
#    ...    ADMIN Change R&D Port Status    False   AND
#    ...    disable_fault_4078    AND
#    ...    sleep  30                AND
#    ...    Reset and on configured      AND
#    ...    1542-RA Test Postconditions


5GC001542_RA_1_NIDD_Parameters_Check
    [Tags]   CIT   CIT__WITH__SBTS00    SBTS00    SBTS22R3   SBTS22R4   SBTS23R1
    ${SW_Version}     ADMIN Get Sw Version
    ${is_Branch_Build}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      SBTS23R1
    ${is_Trunk_Build}=    Run Keyword and Return Status    Should Contain      ${SW_Version}      SBTS23R2

    run keyword if    ${is_Trunk_Build}==${True}
    ...         Run Keywords
    ...                 Add 37 Fault Triggers
    ...                 Check There Are 37 Fault Triggers
    ...                 Adding 38 Fault Triggers Should Fail
    ...      ELSE IF     ${is_Branch_Build}==${True}
    ...          Run Keywords
    ...                  Add 37 Fault Triggers
    ...                  Check There Are 37 Fault Triggers
    ...                  Adding 38 Fault Triggers Should Fail


#5GC001542_RA_2_NIDD_Parameters_Configuration_For_Snapshot_Clear

# TC removed due to regression optimisaion Dec 2022

#    [Tags]   CIT   CIT__WITH__SBTS00    SBTS22R1   SBTS22R2    SBTS00   SBTS22R3   SBTS22R4   SBTS23R1
#    [Setup]    run keywords
#        ...    1542-RA Test Preconditions  AND
#        ...    Set snapshot destination to LSS server    lssIPaddress=${lssServerIPv4}    AND
#        ...    Remove Snapshot from LSS server    AND
#        ...    ADMIN Change R&D Port Status    False
#    Clear Triggers List
#    Check There Are No Fault Triggers
#    ADMIN Change R&D Port Status    True
#    Check if Snapshot is not collected on LSS
#    [Teardown]    run keywords
#    ...    Remove Snapshot from LSS server  AND
#    ...    Reset and on configured    AND
#    ...    1542-RA Test Postconditions

#5GC001542_RA_3_NIDD_Parameters_Configuration_For_Snapshot_add_null
#    [Tags]   CRT
#    [Setup]    run keywords
#       ...    1542-RA Test Preconditions  AND
#       ...    Set snapshot destination to LSS server    lssIPaddress=${lssServerIPv4}     AND
#       ...    Clear Triggers List
#    Check There Are No Fault Triggers
#	Check if Snapshot is not collected on LSS

#5GC001542_RA_4_NIDD_Parameters_Configuration_For_Snapshot_add_add
#    [Tags]   CRT     #SBTS22R3
##regression optimization
#    [Setup]     run keywords
#    ...    1542-RA Test Preconditions  AND
#    ...    Clear Triggers List
#	Add 2 Fault Triggers
#	Check There Are 2 Fault Triggers
#	Add 4 Fault Triggers
#	Check There Are 4 Fault Triggers
#
#5GC001542_RA_5_NIDD_Parameters_Configuration_For_Snapshot_add_remove
#    [Tags]   CRT    SBTS00   SBTS22R4   SBTS23R1   #SBTS22R3
#    [Setup]     run keywords
#        ...     1542-RA Test Preconditions  AND
#        ...     Set snapshot destination to LSS server    lssIPaddress=${lssServerIPv4}   AND
#        ...     Clear Triggers List
#    Add 1 Fault Triggers
#    Check There Are 1 Fault Triggers
#    Clear Triggers List
#    Check There Are No Fault Triggers
#
#5GC001542_RA_6_Snapshot_Trigger_To_External_Server_LSS_IPv4
#    #[Tags]   CRT    SBTS00   SBTS22R4   #SBTS22R3
#    [Setup]    run keywords
#        ...    1542-RA Test Preconditions  AND
#        ...    Set snapshot destination to LSS server    lssIPaddress=${lssServerIPv4}    AND
#        ...    Remove Snapshot from LSS server  AND
#        ...    ADMIN Change R&D Port Status    False
#    Configure LSS in WebEM
#    Commission snapshot triggering faults    ${61652}
##    Raise Fault 4080 To Trigger Snapshot Collect
#    ADMIN Change R&D Port Status    True
#    Sleep  120
#    Check if Snapshot is collected on LSS
#    Wait until BTS_metadata.txt exists
#    Check if Snapshot is collected on LSS
#    [Teardown]    Run Keywords
##        ...    Disable Fault 4080                                         AND
#        ...    Clear fault trigger list           AND
#        ...    Remove Snapshot from LSS server     AND
#        ...    Reset and on configured    AND
#        ...    1542-RA Test Postconditions
#
