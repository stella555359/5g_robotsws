*** Settings ***
Documentation
...  Manipulate the 4082 sw consistent fallback by reboot the site 4 times.
...  Example of execution:
...  pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results testsuite/WMP/SOAM3/SWM/SRAN_SWM/Trunk_Rel4/CRT/
...         ASIL_Automated__SW_Management__BTS_SW_Fallback_Consistent_4082_Trunk_Trunk.robot
...
...  "Author: Lisa.m.li@nokia.com"


*** Variables ***
${fault_id}						 4082


*** Keywords ***
Automated__SW_Management__BTS_SW_Fallback_Consistent_4082_Trunk_Trunk
    [Documentation]    Short description.
    Step1: prepre package and BTS
    Step2: trigger 4082 fallback
    Step3: Fault 4082 verification
    Step4: Reset Bts and '${fault_id}' did not disappeared
    Step5: fault 4082 cancled by upload new SWbuild
    Step6: Recovery BTS

Step1: prepre package and BTS
    [Documentation]    Short description.
    run_keyword_and_ignore_error    Disable fault 6450 auto trigger snapshot
    Get SW load and Type
    ${active_build_path}=   prepare different build
    Check which T type it should be
    taf.sbts.oam.coam.admin.Update Software    ${active_build_path}  timeout=2000

Repare standby partition for T1 software update
    [Documentation]    Short description.
        Execute Command On Enb  mount -o rw,remount /ffs/stb/
        Start Command On Enb  mv /ffs/stb/tmp/* /ffs/stb/
        Execute Command On Enb  rmdir /ffs/stb/tmp
        Sleep  5

Step2: trigger 4082 fallback
    [Documentation]    Short description.
    Log step header    Step2: trigger 4082 fallback
    Run keyword and ignore error    Teardown Infomodel
    ${Rid}    _Get Runtime ID By Infomodel
    Set Test Variable    ${Rid}
    Run keyword and ignore error    Start Infomodel
    ${SMOD2_exists}    run keyword if  ${SCF_COUNT_SMOD}==2     set variable  True   ELSE     set variable  False
    ${sm_variant}=     Get SM variant
    Set test variable    ${sm_variant}
    run keyword if    ${SMOD2_exists}    Software Fallback secondary  ${sm_variant[1]}
    Software fallback    ${sm_variant[0]}

    Log step header  Wait till two cores are stable
    wait for ping stable after reset

Step3: Fault 4082 verification__old
    [Documentation]    Short description.
    Log step header  Step 3: Fault 4082 verification
    ${EXPECTED_ALARM1}=     Create Dictionary  faultName=SW fallback  faultId=4082  severity=Major
    ...  notifier=[BTS${BTS_INFO.ID}] MRBTS-${BTS_INFO.ID}/EQM_R-${Rid}/APEQM_R-1/CABINET_R-1/SMOD_R-1  number=7111
    ${EXPECTED_ALARM2}=     Create Dictionary  faultName=SW fallback  faultId=4082  severity=Major
    ...  notifier=[BTS${BTS_INFO.ID}] MRBTS-${BTS_INFO.ID}/EQM_R-${Rid}/APEQM_R-1/CABINET_R-1/SMOD_R-2  number=7111
    ${EXPECTED1}=            Create List  ${EXPECTED_ALARM1}  ${EXPECTED_ALARM2}
    ${EXPECTED2}=            Create List  ${EXPECTED_ALARM1}
    ${EXPECTED}    run keyword if    ${SMOD2_exists}    set variable  ${EXPECTED1}   ELSE     set variable  ${EXPECTED2}
    ${CRITICAL_ALARM1}=     Create Dictionary  severity=Major|Critical
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ${admin_working_state}  Run keyword and return status  hran_admin.Admin and Infomodel connections reset  reset_req=${TRUE}
    Run keyword if    not ${admin_working_state}    run keywords
    ...    sleep    300s    AND    hran_admin.Admin and Infomodel connections reset    reset_req=${TRUE}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error  Admin Check Active Alarms
    ...  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  No Fault 4082 with Major severity found or other Major|Critical occured
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Fault 4082 active on BTS with severity=Major, but some minor faults found: ${alarms_msg}
    ...  ELSE
    ...  Log  Alarm with Fault 4082 active on BTS with severity=Major. No other active alarms.  console=${TRUE}

Step3: Fault 4082 verification
    [Documentation]    Short description.
     Wait Until Keyword Succeeds    5 min    10 sec    Check if fault absent    4082

Step4: Reset Bts and '${fault_id}' did not disappeared
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${fault_id}: <description>
    Log step header  Step 4: Reset Bts and '${fault_id}' did not disappeared
    taf.sbts.oam.coam.admin.Reset Site  timeout=300
    wait for ping stable after reset
    Step3: Fault 4082 verification

Step5: fault 4082 cancled by upload new SWbuild
    [Documentation]    Short description.
    Log step header    Step5: fault 4082 cancled by upload new SWbuild
    Get SW load and Type
    ${active_build_path}=   prepare different build
    Log to console    Upload the correct sw: ${active_build_path}
    taf.sbts.oam.coam.admin.Update Software    ${active_build_path}  timeout=2000
    Wait for eNB configure and RF swCheckDone status

Step6: Recovery BTS
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Rollback Software             #  return to original software
    Wait for eNB configure and RF swCheckDone status

Check alarm 4082 disappeared
    [Documentation]    Short description.
    {EXPECTED_ALARM1}=     Create Dictionary  faultName=SW fallback  faultId=4082  severity=Major
    ...  notifier=[BTS${BTS_INFO.ID}] MRBTS-${BTS_INFO.ID}/EQM_R-${Rid}/APEQM_R-1/CABINET_R-1/SMOD_R-1  number=7111
    ${EXPECTED_ALARM2}=     Create Dictionary  faultName=SW fallback  faultId=4082  severity=Major
    ...  notifier=[BTS${BTS_INFO.ID}] MRBTS-${BTS_INFO.ID}/EQM_R-${Rid}/APEQM_R-1/CABINET_R-1/SMOD_R-2  number=7111
    ${EXPECTED_ALARM3}=     Create Dictionary  faultName=SW fallback  faultId=4082  severity=Major
    ...  notifier=[BTS${BTS_INFO.ID}] MRBTS-${BTS_INFO.ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1  number=7111
    #${EXPECTED_ALARM1}=     Create Dictionary  faultId=4082  severity=Major  configObjectName=[BTS6474] MRBTS-6474/EQM-1/APEQM-1/CABINET-1/SMOD-1
    #${EXPECTED_ALARM2}=     Create Dictionary  faultId=4082  severity=Major  configObjectName=[BTS6474] MRBTS-6474/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ${EXPECTED1}=            Create List  ${EXPECTED_ALARM1}  ${EXPECTED_ALARM2}
    ${EXPECTED2}=            Create List  ${EXPECTED_ALARM3}
    ${EXPECTED}    run keyword if    ${SMOD2_exists}    set variable  ${EXPECTED1}   ELSE     set variable  ${EXPECTED2}
    ${CRITICAL_ALARM1}=     Create Dictionary  severity=Major|Critical
    ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error  Admin Check Active Alarms  expected_patterns=${EXPECTED}
    ...  critical_patterns=${CRITICAL}
    Run Keyword If  '${alarms_status}'=='PASS'
    ...  Fail  Fault 4082 with Major severity found or other Major|Critical occured
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Fault 4082 active on BTS with severity=Major, but some minor faults found: ${alarms_msg}
    ...  ELSE
    ...  Log  Alarm with Fault 4082 disappeared on BTS with severity=Major. No other active alarms.  console=${TRUE}

wait for ping stable after reset
    [Documentation]    Short description.
    Log  Waiting for ping return  console=${TRUE}
    sleep   300s
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=600
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    run keyword if    ${SMOD2_exists}    wait for sendcondcore ping stable after reset

wait for sendcondcore ping stable after reset
    [Documentation]    Short description.
    Log  Waiting for ping return  console=${TRUE}
    sleep   300s
    ${ping_status}=  Check If Target Is Stable  192.168.255.119    min_uptime=200    max_downtime=360    remote_host=192.168.255.129
    ...    remote_host_username=toor4nsn   remote_host_password=oZPS0POrRieRtu    timeout=1400
    Run keyword if    not ${ping_status}  Log  Secondary core lost ping after fallback.

Custom TC Teardown
    [Documentation]    Short description.
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    ${build_type}=  Should Match Regexp  ${ACTIVE_SW_BEFORE}  .{2}$
    run keyword if    '${build_type}'=='T1'     taf.sbts.oam.coam.admin.Rollback Software
    TC Teardown
