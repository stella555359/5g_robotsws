*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-baijie.zhu    release-5G19
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1/NRCELL-1:preambleTransMax=n10
...    MRBTS-1/NRBTS-1:actCustomBsr=false
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:leftEdgeAngle=60
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:rightEdgeAngle=60
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:beamSet:customBeamSetName
@{param_tc01_PreambleTransMax}    MRBTS-1/NRBTS-1/NRCELL-1:preambleTransMax=n100
@{param_tc01_recover}    MRBTS-1/NRBTS-1/NRCELL-1:preambleTransMax=n10
@{param_tc02_CusBeamSet}
...    MRBTS-1/NRBTS-1:actCustomBsr=true
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:customBeamSetName=BSR_AEQJ_2_H2_ALN45_ARP45_N01_HSPLIT_00387_00001
@{param_tc02_recover}
...    MRBTS-1/NRBTS-1:actCustomBsr=false
...    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:beamSet:customBeamSetName
@{fault4613}    Severity=Critical    fault_id=4613    fault_name=BSR Package missing    alarm_id=7114    alarm_name=CELL SERVICE PROBLEM

*** Test Cases ***
5GC000341_TC01_Online_Modification_Of_PreambleTransMax
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to check the PreambleTransMax online update
    ...    successfully without BTS restarted
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell, NSA
    ...    [Cover Feature]: 5GC000341
    [Tags]    QC_61417
    Attach And Traffic Check
    Update The PreambleTransMax And System Should Not Restart
    Detach And Reattach Ue
    Check RRC Log    ${CURDIR}${/}a2a_01${/}a2a.ini
    [Teardown]    Common Test Teardown And Recover PreambleTransMax

5GSW_CP_EDA_5GC000341_PR587231_Cell_Can_Be_On_Air_After_Disable_CustomBsr
    [Documentation]
    ...    [Purpose]:The purpose of this test case is to check EDA senario:
    ...    5GSW_CP_EDA_5GC000341_PR587231_Cell_Can_Still_Be_Onair_After_Disable_CustomBsr
    ...    1. Set the actCustomBsr to true
    ...    2. Set the name on the customBeamSetName
    ...    3. Activate Plan
    ...    4. Delete the customBeamSetName and Set the actCustomBsr to false
    ...    5. Activate Plan again.
    ...    Expected: NE should be on air and no 4613 alarm.
    ...    Also check the modification of basicBeamSet parameter who is object locking type.
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell, both
    ...    [Cover Feature]: 5GC000341
    [Tags]    QC_125169
    Attach And Traffic Check    ue=32
    Update The CusBeamSet And System Should Not Restart
    Wait Until Keyword Succeeds    2 min    10 sec    Fm Fault Should Be Raised    ${fault4613}
#    Check Cp Rt Log And Search The Relevant Infos
    Delete CusBeamSet Name And ActCustomBsr Recovered
    Wait Until Keyword Succeeds    5 min    10 sec    FM Fault Should Be Cleared    fault_id=4613
    Detach And Reattach Ue    ue=32
    [Teardown]    Common Test Teardown And Recover CusBeamSet

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri

Common Test Teardown And Recover PreambleTransMax
    Delta Commission Parameters    ${param_tc01_recover}
    Sleep    2s    # wait commission complete
    Cells Should Be Onair    cell_id=1
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:preambleTransMax=n10
    Common Test Teardown And Stop Capture Logs

Common Test Teardown And Recover CusBeamSet
    Delete CusBeamSet Name And ActCustomBsr Recovered
    Common Test Teardown And Stop Capture Logs

Delete CusBeamSet Name And ActCustomBsr Recovered
    Delta Commission Parameters    ${param_tc02_recover}
    Sleep    2s    # wait commission complete
    Cells Should Be Onair    cell_id=1
    Object Should Exist    MRBTS-1/NRBTS-1:actCustomBsr=false
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_1
    Object Should Not Exist    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:customBeamSetName=${EMPTY}

Attach And Traffic Check
    [Arguments]    ${ue}=31
    BuiltIn.Log    Begin to attach and traffic check ...    console=${True}
    Execute Egate Command    ue_change_location id=${ue} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue}    UE${ue}: === UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE${ue}: Proxy \\(eNB 2 cell 1\\) reported successful RA
    Traffic Should Be Ok    ue_id=${ue}    bearer_id=2    dl_mbps=5    ul_mbps=1    timeout=10    type=NSA

Update The PreambleTransMax And System Should Not Restart
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:preambleTransMax=n10
    ${bootIdSta}=    Get Boot Id
    Delta Commission Parameters    ${param_tc01_PreambleTransMax}
    Sleep    2s    # wait commission complete
    Cells Should Be Onair    cell_id=1
    Object Should Exist    ${param_tc01_PreambleTransMax}
    ${bootIdCur}=    Get Boot Id
    Should Be Equal    ${bootIdSta}    ${bootIdCur}

Update The CusBeamSet And System Should Not Restart
    Object Should Exist    MRBTS-1/NRBTS-1:actCustomBsr=false
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:basicBeamSet=beamSet_1
    Object Should Not Exist    MRBTS-1/NRBTS-1/NRCELL-1:beamSet:customBeamSetName=${EMPTY}
    ${bootIdSta}=    Get Boot Id
    Delta Commission Parameters    ${param_tc02_CusBeamSet}
    Sleep    2s    # wait commission complete
    Object Should Exist    ${param_tc02_CusBeamSet}
    ${bootIdCur}=    Get Boot Id
    Should Be Equal    ${bootIdSta}    ${bootIdCur}

Get Boot Id
    ${bootNr}=    Execute Command On Enb    journalctl --list-boots | tail -n 1 | awk '{print $1}' | tr -d '\r\n'
    Should Be Equal    ${bootNr}    0
    ${bootId}=    Execute Command On Enb    journalctl --list-boots | tail -n 1 | awk '{print $2}' | tr -d '\r\n'
    [Return]    ${bootId}

Detach And Reattach Ue
    [Arguments]    ${ue}=31
    BuiltIn.Log    Begin to dettach and reattach ...    console=${True}
    Execute Egate Command    ue_detach id=${ue}    UE${ue}: detached
    Sleep    2s    # interval between attach
    Execute Egate Command    ue_attach id=${ue}    UE${ue}: === UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE${ue}: Proxy \\(eNB 2 cell 1\\) reported successful RA
    Traffic Should Be Ok    ue_id=${ue}    bearer_id=2    dl_mbps=5    ul_mbps=1    timeout=10    type=NSA
    Execute Egate Command    ue_detach id=${ue}    UE${ue}: detached

Check Cp Rt Log And Search The Relevant Infos
    Execute Command On Enb    xz -d /ffs/run/logs/CPRT00_aasyslog/startup_cp_rt.log.xz
    ${rows}    Execute Command On Enb    grep "Send CellStatusInd to OAM" /ffs/run/logs/CPRT00_aasyslog/startup_cp_rt.log | wc -l
    ${nums}    Evaluate    int(${rows})
    Should Be True    ${nums} >= 2
    ${rows}    Execute Command On Enb    grep "for cell activation/deactivation procedure" /ffs/run/logs/CPRT00_aasyslog/startup_cp_rt.log | wc -l
    ${nums}    Evaluate    int(${rows})
    Should Be True    ${nums} >= 2
    [Teardown]    Execute Command On Enb    xz -z /ffs/run/logs/CPRT00_aasyslog/startup_cp_rt.log
