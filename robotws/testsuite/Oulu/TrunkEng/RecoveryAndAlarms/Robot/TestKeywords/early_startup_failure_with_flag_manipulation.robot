*** Settings ***
Documentation
...   Author:   Jere Jacklin
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications  WITH NAME  APPLICATIONS
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.OmkpiCommonInterface
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FMRecoCommon
Library     Collections

*** Variables ***
${WAIT_FOR_CELLS_UP}    600
${WAIT_CHECKS}          5
${WAIT_TIME_AFTER_SITE_RESET}   300
@{ALLOWED_SMODS}  ASIL  ASIM
${BUILD_T}              ${EMPTY}


*** Keywords ***
Perform SWDL
    [Documentation]    Get BTS software package to test PC and upload it to BTS. SWDL is performed to T1 package by default
    [Arguments]        ${STEP_NBR}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        ${ACTIVE_SW}=  BTS.Get Active Sw Of Bts
        Print Text To Eventlog                    Active sw of BTS is: ${ACTIVE_SW}
        ${T2_BUILD}=                              Get Variable Value     ${TEST_PACKAGE_2}   ${False}
        ${NORMAL_BUILD}=                          Get Variable Value     ${NORMAL_PACKAGE}   ${False}
        ${SPECIAL_METHOD}=                        Get Variable Value     ${SPECIAL_SWDL_METHOD}   ${False}
        IF  ${T2_BUILD}
            Print Text To Eventlog                Download the T2 build for SWDL (step ${STEP_NBR})
            ${b_t}=                               Get Build That Is Currently Active On BTS  testpackage=T2
        ELSE IF  ${NORMAL_BUILD}
            Print Text To Eventlog                Download the Normal build for SWDL (step ${STEP_NBR})
            ${b_t}=                               Get Build That Is Currently Active On BTS
        ELSE
            Print Text To Eventlog                Download the T1 build for SWDL (step ${STEP_NBR})
            ${b_t}=                               Get Build That Is Currently Active On BTS  testpackage=T1
        END
        Set Suite Variable                        ${BUILD_T}  ${b_t}
#        Print Step Text          ${STEP_NBR}.2    Request software update to ${BUILD_T}   automatic=${True}
        Print Text To Eventlog                    Request software update to ${BUILD_T} (step ${STEP_NBR})
        Run Keyword And Continue On Failure       Teardown Suite Admin
        Print Text To Eventlog                    Stop Real time alarm listener
        Run Keyword and Continue On Failure       Stop RT Alarm Listener
        Run Keyword and Continue On Failure       Reset Admin Connection
        Run Keyword And Continue On Failure       Stop Background Syslog Print Search
        ${swdl_start}=                            Get Start Time
        IF  ${SPECIAL_METHOD}
            Run Keyword And Continue On Failure       Update Software Expect Fallback  ${BUILD_T}
            Print Text To Eventlog                    Software update request done
            Run Keyword and Continue On Failure       Calculate Duration  ${SWDL_START}
        ELSE
            Run Keyword And Continue On Failure       Update Software On Bts  ${BUILD_T}  timeout=${18000}  admin_connection=log_admin
            Print Text To Eventlog                    Software update request done
            Run Keyword and Continue On Failure       Calculate Duration  ${SWDL_START}
#            Print Step Text          ${STEP_NBR}.3    Verify disconnection and reconnection due to SWDL
            Print Text To Eventlog                    Verify disconnection and reconnection due to SWDL (step ${STEP_NBR})
            Run Keyword And Continue On Failure       Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
            ...                                       disconnection=True  time_to_wait=1800
            Run Keyword And Continue On Failure       Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
            ...                                       time_to_wait=600
        END

    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Secondary Core Early Startup Failure
    [Documentation]  Keyword for UC2. Set flag 0x2019d=2 to swconfig and perform SWDL to T1 package. Expect BTS to get stuck
    ...              for around 15 minutes, after which the bts performs a recovery site reset and BTS goes OnAir.
    [Arguments]  ${FLAG_VALUE}
    Run Keyword And Continue On Failure          Check Build And Perform SWDL If Needed  1
    Print Step Text                           2  Check Preconditions   automatic=${True}
    Run Keyword And Continue On Failure          Common Preconditions
    Print Step Text                           3  Adding ${FLAG_VALUE} to swconfig.txt
    Run Keyword And Continue On Failure          Add And remove Flags With Swconfig   ${FLAG_VALUE}   add_flag=${True}
    Print Step Text                           4  Reset site to activate modified swconfig.txt and wait for cells up
    Run Keyword And Continue On Failure          ADMIN.Reset Site    detailed_output=True  timeout=900  wait_for_reconnection=True
    Run Keyword And Continue On Failure          Wait For All Cells Up   time_limit=600
    Print Step Text                           5  Perform SWDL
    Run Keyword And Continue On Failure          Perform SWDL  6
    Print Step Text                           7  Reset admin connection   automatic=${True}
    Run Keyword And Continue On Failure          Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword and Continue On Failure          Wait Admin Connection  connect_always=${True}
    Run Keyword and Continue On Failure          Connect Suite Admin
    Print Text To Eventlog                       Start Real time alarm listener
    Run Keyword and Continue On Failure          Start RT Alarm Listener
    Run Keyword And Continue On Failure          Wait For All Cells Up    time_limit=1800
    Print Step Text                           8  Post test cleaning steps
    Run Keyword And Continue On Failure          Test Cleanup Steps  flag_to_clear=${FLAG_VALUE}
    Run Keyword And Continue On Failure          Wait For All Cells Up    time_limit=900
    Print Step Text                           9  Check Postconditions
    Run Keyword And Continue On Failure          Common Postconditions
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Primary Core Early Startup Failure
    [Documentation]  Keyword for UC3. Set flag 0x2019d=3 to swconfig and perform SWDL to T1 package. Instantly after SWDL,
    ...              kill a critical application during startup. This should trigger an extra site reset, after which the BTS
    ...              recovers and goes OnAir.
    [Arguments]    ${WAIT_AFTER_SWDL}  ${FLAG_VALUE}  ${APPLICATION_TO_KILL}
    Run Keyword And Continue On Failure          Check Build And Perform SWDL If Needed  1
    Print Step Text                           2  Check Preconditions   automatic=${True}
    Run Keyword And Continue On Failure          Common Preconditions
    Print Step Text                           3  Adding ${FLAG_VALUE} to swconfig.txt
    Run Keyword And Continue On Failure          Add And remove Flags With Swconfig   ${FLAG_VALUE}   add_flag=${True}
    Run Keyword And Continue On Failure          Perform SWDL  4
    Print Step Text                           5  Kill application during T1 SWDL
    Run Keyword And Continue On Failure          Kill Application During T1 Swdl  ${APPLICATION_TO_KILL}
    # Killing an application during startup should cause an extra disconnection and reconnection
    Print Step Text                           6  Check for disconnection and reconnection after killing ${APPLICATION_TO_KILL}
    Run Keyword And Continue On Failure          Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                          disconnection=True  time_to_wait=900
    Run Keyword And Continue On Failure          Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                          time_to_wait=300
    Print Step Text                           7  Reset admin connection   automatic=${True}
    Run Keyword And Continue On Failure          Check If Admin Connection Reset Can Be Done  always_reset=${True}
    Run Keyword and Continue On Failure          Wait Admin Connection  connect_always=${True}
    Run Keyword and Continue On Failure          Connect Suite Admin
    Print Text To Eventlog                       Start Real time alarm listener
    Run Keyword and Continue On Failure          Start RT Alarm Listener
    Run Keyword And Continue On Failure          Wait For All Cells Up    time_limit=${WAIT_AFTER_SWDL}
    Print Step Text                           8  Post test cleaning steps
    Run Keyword And Continue On Failure          Test Cleanup Steps  flag_to_clear=${FLAG_VALUE}
    Run Keyword And Continue On Failure          Wait For All Cells Up    time_limit=900
    Print Step Text                           9  Check Postconditions
    Run Keyword And Continue On Failure          Common Postconditions
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

SSBL Bootloader early startup failure
    [Documentation]    Keyword for UC5. The test is performed from T1 package to T2 package. Before starting the actual test
    ...                perform SWDL to T1 package. After that, give some uboot_env commands, perform SWDL to T2 package,
    ...                perform SSBL Bootloader procedure and expect SW fallback to passive build (T1). After SW fallback,
    ...                clear the environment and check that the BTS is OnAir.
    [Arguments]  ${WAIT_FOR_CELLS_UP}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        ${SYSLOG_LIST}=   Get Variable Value   ${SYSLOG_LIST}  @{EMPTY}
        Run Keyword And Continue On Failure      Start Syslog Print Search To Background  ${SYSLOG_LIST}
        &{FW_UPGRADE_FLAG}=                         Create Dictionary  0x20076=1
        Run Keyword And Continue On Failure         Check Build And Perform SWDL If Needed  1
        Print Step Text                          1  Check Preconditions   automatic=${True}
        Run Keyword And Continue On Failure         Common Preconditions
        Run Keyword And Continue On Failure         Print Text To Eventlog
        ...                                         Make sure that no netboot. Give uboot command to delete it if it exists
        Run Keyword And Continue On Failure         Send Command To Smod By Ssh  uboot_env del netboot
        Print Step Text                          2  SWDL before starting the test so passive partition also has known SW   automatic=${True}
        Run Keyword And Continue On Failure         Perform SWDL  2
#        Print Step Text                            Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure         Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Run Keyword And Continue On Failure         Check That Sw Has Been Updated    ${BUILD_T}   kpi_print=${False}
        ${active_partition_before}=                 Get Active Partition
        Print Step Text                          3  Perform ssbl bootlader procedure   automatic=${True}
        Run Keyword And Continue On Failure         Add And remove Flags With Swconfig   ${FW_UPGRADE_FLAG}   add_flag=${True}
        Run Keyword And Continue On Failure         Ssbl Bootloader Procedure
# here is sw fallback and partition changes and software changes T1 -> normal
        Print Step Text                          4  Check expected alarm for SW fallback and verify partition change  automatic=${True}
        Run Keyword And Continue On Failure         ALARMS.Add Expected Alarm
        ...                                         alarm_id=7111  fault_id=4082  fault_name=SW fallback  severity=Critical
        Run Keyword And Continue On Failure         Check Expected Alarms  wait_active_timeout=600
        ${active_partition_after}=                  Get Active Partition
        Run Keyword And Continue On Failure         Verify Partition Change    ${active_partition_after}    ${active_partition_before}
        Run Keyword And Continue On Failure         Wait Time And Reason    sleep_time=${WAIT_AFTER_BOOTLOADER}
        ...                                         wait_reason=after SSBL bootloader procedure
        # Set variable to True to perform SWDL to T2 build instead of T1
        Print Step Text                          5  SWDL after SW fallback caused by Ssbl Bootloader Procedure    automatic=${True}
        ${force_normal}=                            Get Variable Value     ${FORCE_NORMAL_BUILD}   ${False}
        IF  ${force_normal}
            Set Suite Variable                      ${NORMAL_PACKAGE}       ${True}
        ELSE
            Set Suite Variable                      ${TEST_PACKAGE_2}       ${True}
            Set Suite Variable                      ${SPECIAL_SWDL_METHOD}  ${True}
        END
        Run Keyword And Continue On Failure         Perform SWDL  5
#        Print Step Text                          6  Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure         Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        Sleep                                       10s
        Print Step Text                          6  Check alarms after SWDL    automatic=${True}
        Run Keyword And Continue On Failure         ALARMS.Add Expected Alarm To Allowed
        Run Keyword And Continue On Failure         ALARMS.Remove Expected Alarms
        Run Keyword And Continue On Failure         Check Alarm History

# SWDL should fail here, causing SW fallback to T1
#        Print Step Text                          7  Add and check expected alarm
#        Run Keyword And Continue On Failure         ALARMS.Add Expected Alarm
#        ...                                         alarm_id=7111  fault_id=4082  fault_name=SW fallback  severity=Critical
#        Run Keyword And Continue On Failure         Check Expected Alarms  wait_active_timeout=600

# Set variable to False to not interfere with other tests in the environment if they're run in succession
        Set Suite Variable                          ${TEST_PACKAGE_2}       ${False}
        Set Suite Variable                          ${SPECIAL_SWDL_METHOD}  ${False}
        Set Suite Variable                          ${NORMAL_PACKAGE}       ${False}
# cleanup
        Print Step Text                          7  Run Post Test Cleaning Steps    automatic=${True}
        Run Keyword And Continue On Failure         Test Cleanup Steps  flag_to_clear=${FW_UPGRADE_FLAG}  bootloader_case=${True}
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Print Step Text                          8  Check Postconditions    automatic=${True}
        Run Keyword And Continue On Failure         Common Postconditions
        Run Keyword And Continue On Failure      Stop Background Syslog Print Search
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

FSBL Bootloader early startup failure
    [Documentation]    Keyword for UC4. The test is performed from T1 package to T2 package. Before starting the actual test
    ...                perform SWDL to T1 package. After that, perform the FSBL bootloader procedure, perform SWDL to T2 package,
    ...                and expect SW fallback to passive build (T1). After SW fallback, clear the environment and clear
    ...                the environment and check that the BTS is OnAir.
    [Arguments]  ${WAIT_FOR_CELLS_UP}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        &{FW_UPGRADE_FLAG}=                         Create Dictionary  0x20076=1
        Run Keyword And Continue On Failure         Check Build And Perform SWDL If Needed  1
        Print Step Text                          1  Check Preconditions   automatic=${True}
        Run Keyword And Continue On Failure         Common Preconditions
        Print Step Text                          2  SWDL to T1 package before starting the test
        Run Keyword And Continue On Failure         Perform SWDL  2
        Print Step Text                          3  Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure         Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        # Save T1 build SW as a variable for comparison after SW fallback
        ${ACTIVE_SW_BEFORE_FALLBACK}=  BTS.Get Active Sw Of Bts
        Print Step Text                          4  Start FSBL Bootloader procedure and set 0x20076=1   automatic=${True}
        Run Keyword And Continue On Failure         Add And remove Flags With Swconfig   ${FW_UPGRADE_FLAG}   add_flag=${True}
        Run Keyword And Continue On Failure         Fsbl Bootloader Procedure
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        # Set variable to True to perform SWDL to T2 build instead of T1
        Set Suite Variable                          ${TEST_PACKAGE_2}  ${True}
        Run Keyword And Continue On Failure         Perform SWDL  4
        Print Step Text                          4  Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure         Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        # Check here that the current build is still the T1 build due to fallback
        Print Step Text                          5  Check that SW build is T1 due to fallback   automatic=${True}
        Run Keyword And Continue On Failure         Get Active Sw And Compare It  ${ACTIVE_SW_BEFORE_FALLBACK}
        # Set variable to False to not interfere with other tests in the environment if they're run in succession
        Set Suite Variable                          ${TEST_PACKAGE_2}  ${False}
        Print Step Text                          6  Run Post Test Cleaning Steps
        Run Keyword And Continue On Failure         Test Cleanup Steps  flag_to_clear=${FW_UPGRADE_FLAG}  bootloader_case=${True}
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Print Step Text                          7  Check BTS status
        # Check BTS status directly instead of postconditions due to alarm checks
        Run Keyword And Continue On Failure         Check BTS Status
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Stop watchdog in SW activation
    [Documentation]    Keyword for UC6. Perform SWDL to T1 package and as soon as SMOD is available, give command to stop watchdog.
    ...                This should trigger an extra reset and BTS should recover from this.
    [Arguments]    ${WAIT_FOR_CELLS_UP}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        Run Keyword And Continue On Failure         Check Build And Perform SWDL If Needed  1
        Print Step Text                          1  Check Preconditions   automatic=${True}
        Run Keyword And Continue On Failure         Common Preconditions
        Print Step Text                          2  SWDL to T1 package
        Run Keyword And Continue On Failure         Perform SWDL  2
        # Give ssh command echo stop > /dev/watchdog
        Print Step Text                          5  Start Systemd startup procedure   automatic=${True}
        Run Keyword And Continue On Failure         Systemd Startup Procedure
        # Should cause reset
        Run Keyword And Continue On Failure         Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
        ...                                         disconnection=True  time_to_wait=${300}
        Run Keyword And Continue On Failure         BTS.Teardown Selected Admin Connection       selected_admin=log_admin
        Run Keyword And Continue On Failure         Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
        Run Keyword and Continue On Failure         Wait Admin Connection   connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        Print Step Text                          6  Wait for all cells up   automatic=${True}
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Print Step Text                          7  Run Post Test Cleaning Steps
        Run Keyword And Continue On Failure         Test Cleanup Steps
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Print Step Text                          7  Check Postconditions
        Run Keyword And Continue On Failure         Common Postconditions
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Systemd fails to start service
    [Documentation]    Keyword for UC7, UC8 and UC9. Set uboot_env bootargs for service, perform T1 SWDL, expect extra reset
    ...                due to bootargs, BTS should recover and go OnAir
    [Arguments]    ${SERVICE}  ${WAIT_AFTER_SWDL}  ${SYSLOG_PRINT}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        Run Keyword And Continue On Failure         Check Build And Perform SWDL If Needed  1
        Print Step Text                          1  Check Preconditions   automatic=${True}
        Run Keyword And Continue On Failure         Common Preconditions
        IF  '${SERVICE}' == 'CNI-139728=hpd.service'
            Print Step Text                          2  Store ${SERVICE} name in uboot environment   automatic=${True}
            Run Keyword And Continue On Failure         Save Service Name In Uboot Environment  service=${SERVICE}

            Print Step Text                          3  Perform T1 SWDL  automatic=${True}
            Run Keyword And Continue On Failure         Perform SWDL  3
            Run Keyword And Continue On Failure         Wait Cells Disabled Collect Ims   wait_cells_disabled=180
        ELSE
            Print Step Text                          2  Perform T1 SWDL  automatic=${True}
            Run Keyword And Continue On Failure         Perform SWDL  3
            Run Keyword And Continue On Failure         Wait Cells Disabled Collect Ims   wait_cells_disabled=180
            Run Keyword and Continue On Failure         Wait Admin Connection   connect_always=${True}
            Run Keyword and Continue On Failure         Connect Suite Admin
            Print Step Text                          4  Store ${SERVICE} name in uboot environment   automatic=${True}
            Run Keyword And Continue On Failure         Save Service Name In Uboot Environment  service=${SERVICE}
            Print Step Text                          5  Reset site to activate modified bootargs_opt  automatic=${True}
            Run Keyword And Continue On Failure         ADMIN.Reset Site    detailed_output=True  timeout=900
            ...                                         wait_for_reconnection=True
            IF  '${SERVICE}' != 'CNI-139728=soam-btsomexe.service'
                Run Keyword And Continue On Failure         Teardown Suite Admin
            END
            Run Keyword And Continue On Failure         Wait Cells Disabled Collect Ims   wait_cells_disabled=180
        END
        IF  '${SERVICE}' != 'CNI-139728=soam-btsomexe.service'
            Print Step Text                          4  Check for extra reset due to uboot_env bootargs  automatic=${True}
            Run Keyword And Continue On Failure         Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
            ...                                         disconnection=True  time_to_wait=${900}
            Run Keyword And Continue On Failure         BTS.Teardown Selected Admin Connection       selected_admin=log_admin
            Run Keyword And Continue On Failure         Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
            Run Keyword and Continue On Failure         Wait Admin Connection   connect_always=${True}
            Run Keyword and Continue On Failure         Connect Suite Admin
            Print Text To Eventlog                      Start Real time alarm listener
            Run Keyword and Continue On Failure         Start RT Alarm Listener
        END
        Print Step Text                          5  Wait for all cells up   automatic=${True}
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_AFTER_SWDL}
        Print Step Text                          6  Run Post Test Cleaning Steps  automatic=${True}
        Run Keyword And Continue On Failure         Test Cleanup Steps  service_to_clear=${SERVICE}
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        IF  '${SERVICE}' == 'CNI-139728=soam-btsomexe.service'
            Print Step Text                  7  Check for expected syslog prints due critical OAM service fail in startup  automatic=${True}
            ${SYSLOG_LIST}=    Create List          PceErrorHandler    Detected most recent reset type was
            Run Keyword And Continue On Failure     Check If Syslog Print Is Found  ${SYSLOG_PRINT}   fail_if_not_found=${True}
            Run Keyword And Continue On Failure     Check If Syslog Print Is Found  ${SYSLOG_LIST}    fail_if_not_found=${False}
        ELSE
            Run Keyword And Continue On Failure     Check If Syslog Print Is Found  ${SYSLOG_PRINT}
        END
        Print Step Text                          7  Check Postconditions  automatic=${True}
        Run Keyword And Continue On Failure         Common Postconditions
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Secondary detection failure
    [Documentation]  Keyword for UC11. Set flag to either 0x2019e=1 or 0x2019e=2, perform SWDL to T1 package and
    ...              wait 80 minutes for recovery to occur.
    [Arguments]  ${FLAG_VALUE}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        Run Keyword And Continue On Failure         Check Build And Perform SWDL If Needed  1
        Print Step Text                          1  Check Preconditions      automatic=${True}
        Run Keyword And Continue On Failure         Common Preconditions
        Print Step Text                          2  Add ${FLAG_VALUE} flag to swconfig
        Run Keyword And Continue On Failure         Add And remove Flags With Swconfig   ${FLAG_VALUE}   add_flag=${True}
        Run Keyword And Continue On Failure         Perform SWDL  3
        Print Step Text                          4  Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure         Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        Run Keyword And Continue On Failure         ALARMS.Add Expected Alarm
        ...                                         alarm_id=7116  fault_id=4352
        ...                                         fault_name=No Connection between primary and BTS extension system module
        ...                                         severity=Critical
        Run Keyword And Continue On Failure         Check Expected Alarms  wait_active_timeout=360
        Wait Time And Reason                        4800  Wait 80 minutes for recovery
        Run Keyword And Continue On Failure         Wait For All Cells Up   time_limit=${WAIT_FOR_CELLS_UP}
        # TODO --> need to check test structure after pronto is closed
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

BBMOD detection failure
    [Documentation]    BTS SW activation scenario in which BBMOD detection failure. Verifying how BOAM is initiating recovery
    ...                Default flag value is 0. Set flag 0x20019f to 2 = FSP is detected but FSP CPUs are not (UNIT ready and CPUs timeout)
    ...                Set flag back to 0. Set flag 0x20019f to 3 = FSP is not detected (UNIT timeout). Set flag back to 0.
    ...                ERadHwapi_AdetFspDetectionTimerValue 0x200c7 should be x. ERadHwapi_AdetFctDetectionTimerValue 0x2019c should be 1.
    [Arguments]  ${FLAG_VALUE}
    ${SMOD_TYPE}=                           Check If Smod Type In Environment  ${ALLOWED_SMODS}
    IF  ${SMOD_TYPE}
        Run Keyword And Continue On Failure         Check Build And Perform SWDL If Needed  1
        Print Step Text                          2  Check Preconditions      automatic=${True}
        Run Keyword And Continue On Failure         Common Preconditions
        Print Step Text                          3  Add flag to swconfig
        Run Keyword And Continue On Failure         Add And remove Flags With Swconfig   ${FLAG_VALUE}   add_flag=${True}
        Print Step Text                          4  Perform T1 SWDL   automatic=${True}
        Run Keyword And Continue On Failure         Perform SWDL  5
        Print Step Text                          6  Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure         Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure         Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure         Connect Suite Admin
        Print Text To Eventlog                      Start Real time alarm listener
        Run Keyword and Continue On Failure         Start RT Alarm Listener
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Print Step Text                          7  Run Post Test Cleaning Steps
        Run Keyword And Continue On Failure         Test Cleanup Steps  flag_to_clear=${FLAG_VALUE}
        Run Keyword And Continue On Failure         Wait For All Cells Up    time_limit=${WAIT_FOR_CELLS_UP}
        Print Step Text                          8  Check Postconditions
        Run Keyword And Continue On Failure         Common Postconditions
        # TODO --> need to manually retest and figure our which alarms to expect and when, and when to remove flag
        # and do recovery actions since the flag is permanently causing the faults
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Check Build And Perform SWDL If Needed
    [Documentation]    Check currently active build on BTS and perform SWDL to either the normal build depending on the test case.
    ...                For UC4 and UC5, there is no need to check this because the tests are run from
    ...                T1 package to T2 packages so the T1 SWDL is performed in the cases themselves. This keyword is run
    ...                before the actual testcases themselves to enable running multiple tests in succession
    [Arguments]        ${STEP_NBR}
    ${ACTIVE_SW}=  BTS.Get Active Sw Of Bts
    IF  'T1' in '${ACTIVE_SW}' or 'T2' in '${ACTIVE_SW}'
        Print Text To Eventlog                   T1/T2 found from active sw: ${ACTIVE_SW}, performing SWDL to normal build.
        ${b_t}=                                  Get Build That Is Currently Active On BTS
        Set Suite Variable                       ${BUILD_T}  ${b_t}
        Print Step Text          ${STEP_NBR}.2   Request software update to ${BUILD_T}   automatic=${True}
        Run Keyword And Continue On Failure      Teardown Suite Admin
        Print Text To Eventlog                   Stop Real time alarm listener
        Run Keyword and Continue On Failure      Stop RT Alarm Listener
        Run Keyword and Continue On Failure      Reset Admin Connection
        Run Keyword And Continue On Failure      Stop Background Syslog Print Search
        ${SWDL_START}=                           Get Start Time
        Run Keyword And Continue On Failure      Update Software On Bts  ${BUILD_T}  timeout=${18000}  admin_connection=log_admin
        Print Text To Eventlog                   Software update request done
        Run Keyword and Continue On Failure      Calculate Duration  ${SWDL_START}
        Run Keyword And Continue On Failure      Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
        ...                                      disconnection=True  time_to_wait=900
        Run Keyword And Continue On Failure      Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
        ...                                      time_to_wait=300
        Print Step Text          ${STEP_NBR}.3   Reset admin connection   automatic=${True}
        Run Keyword And Continue On Failure      Check If Admin Connection Reset Can Be Done  always_reset=${True}
        Run Keyword and Continue On Failure      Wait Admin Connection  connect_always=${True}
        Run Keyword and Continue On Failure      Connect Suite Admin
        Print Text To Eventlog                   Start Real time alarm listener
        Run Keyword and Continue On Failure      Start RT Alarm Listener
        Print Step Text          ${STEP_NBR}.4   Wait for all cells up, then check syslog prints   automatic=${True}
        Run Keyword And Continue On Failure      Wait For All Cells Up   time_limit=480
        Print Step Text          ${STEP_NBR}.5   Check Postconditions   automatic=${True}
        Run Keyword And Continue On Failure      Common Postconditions
    ELSE
        Print Text To Eventlog  Active build is already the normal package: ${ACTIVE_SW}, no need to perform SWDL to it.
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
