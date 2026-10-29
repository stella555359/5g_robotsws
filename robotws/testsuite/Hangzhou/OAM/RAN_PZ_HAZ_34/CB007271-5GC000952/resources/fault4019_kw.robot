*** Settings ***
Library     Collections
Library     String
Library     OperatingSystem
Library   taf.transport.ssh   WITH NAME   csn
Library     taf.sbts.oam.coam.admin   WITH NAME   sbts
Library     counter_ops.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot



*** Variables ***
${coam_alias}    COAM

*** Keywords ***
Trigger fault 4019 BBMOD
    [Arguments]    ${index}=0
    Connect Ssh To Asix
    csn.send command    command=bsh ${${index}+1}:0 "killall /opt/hwr/HWRTimeSExe"     connection=asix
    [Teardown]  Disconnect Ssh From Asix

Fault 4019 cycle BBMOD
    [Arguments]    ${index}=0    ${bbmod_index}=0
    log to console   starting Fault 4019 cycle
    Trigger fault 4019 BBMOD    index=${bbmod_index}
    wait until keyword succeeds   3min    5     Cell Should Be Disabled   cell_idx=${L3CALL_cellid}
    ...   cell_group_idx=${${L3CALL_cellid}-1}   connection=${coam_alias}
    wait until keyword succeeds   3min    5    RU Should Be Power Off  ru_index=${L3CALL_cellid}   connection=${coam_alias}
    wait until keyword succeeds  10min      5    Fault With Alarm Should Be Present      FaultID=4019    AlarmID=7101
    wait until keyword succeeds   5min    5    bbmod Should Be offline   bbmod_index=${${index}+1}    connection=${coam_alias}
    wait until keyword succeeds   25m   30s   COAM Check All Cells Onair
    bbmod Should Be unLocked   bbmod_index=${${index}+1}    connection=${coam_alias}
    wait until keyword succeeds  10min      5    Expect Fault Should Absent   faultId=4019    connection=${coam_alias}
    log to console   Fault 4019 cycle done

Fault 4019 load counter BBMOD
    [Arguments]  ${count}=3    ${bbmod_index}=0
    FOR    ${INDEX}  IN RANGE    0   ${count}
       Fault 4019 cycle BBMOD   index=${bbmod_index}
    END

Fault 4019 counter overload BBMOD
    [Arguments]    ${index}=0   
#   ${STREAM}=    sbts.get_sw_release_name
    Trigger fault 4019 BBMOD    index=${index}
#   run keyword if    '${STREAM}'=='5G20B'  run keywords    Wait For Fault with Alarm to appear      4019    7116    AND
#   ...                                                     COAM Reset Site
#   ...                            ELSE     run keywords    Wait For Fault with Alarm to appear      4019    7101    AND
#   ...                                                     Wait for gNB autonomous reset as a recovery action
    wait until keyword succeeds  10min      5    Fault With Alarm Should Be Present      FaultID=4019    AlarmID=7116
#    COAM Reset Site
