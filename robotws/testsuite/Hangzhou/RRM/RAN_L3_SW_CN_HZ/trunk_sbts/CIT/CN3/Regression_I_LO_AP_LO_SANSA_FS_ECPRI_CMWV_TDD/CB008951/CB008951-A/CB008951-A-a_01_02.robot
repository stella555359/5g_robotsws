*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-CN3ET    owner-chengmao.sun    release-SBTS23R3    RAN_5G_TDD
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}  # The RD flags for One Occurrence NTS crash "Please contact the owner of 'NTS'"
...    0x500000=1
...    0x10040=1
...    0x1003F=1
...    0x2F0000=1

${GNB1_CONFIG}    fddtdd_sansa_cmwv/3cells_1T2F

@{FAULTS_EXCLUDED_CHECKING}    7308    7107

@{PARAMS_IN_SCF}
...    @{NSA_CONF}
...    @{PowerSaving}
...    @{NRPMRNL}
...    @{CB008745}

@{NSA_CONF}
...    NRBTS:gNbCuType=NSA
...    NRBTS:actSACallProcessingDU=false
...    NRCELL:cellDepType=NSA
...    NRBTS:nsaCellActivationAlarmTimer=300
...    NRBTS/NRDRB_PDCP-2:xxFlowControlProfForCuIdx=1
...    delete:NRCELL:trackingAreaDN
...    delete:NRBTS-2/SNSSAI-1:ngUplane
...    delete:NRBTS-2/NRSYSINFO_PROFILE-1/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-2/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-3/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-4/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-11/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-12/NRLIM-1

@{PowerSaving}
...    NRBTS:actNrLBPowerSaving=true
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-10:lbpsLastCellMinLoad=1
...    NRBTS/NRPGRP-10:lbpsLastCellRTXMinLoad=1
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMaxLoad=2
...    NRBTS/NRPGRP-10:lbpsMinLoad=1
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=60
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=60
...    NRBTS/NRPGRP-10:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-10:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-10:lbpsRTXMaxLoad=2
...    NRBTS/NRPGRP-10:lbpsRTXMinLoad=1
...    NRBTS/NRPGRP-10:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-10:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-10:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed

@{CB008745}
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod

@{NRPMRNL}
...    NRPMRNL-1:miNrF1UU=5min
...    NRPMRNL-1:miNrX2CC=5min
...    NRPMRNL-1:miNrX2CB=5min
...    NRPMRNL-1:miNrCellAvailability=5min

@{suspendPS}
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=suspended

@{case02_prepare_precondition}
...    NRBTS:actCoordinated4g5gPowerSaving=disabled
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=200
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=2
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended

*** Test Cases ***
CB008951-A-a_ET_01_02_MeNB will be informed that NRCELL with NSA is deleted when CB008951 is deactivated
    [Tags]
    Fallback Cells To Onair
    OnlineParamChange    ${case02_prepare_precondition}
    Check currently time and modify parameters under lbpsPeriodList
    Till Cell1 Enter PowerSaving And Check Send Cell1 Deactivated Message To MeNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}    ue_count=1
    Execute Egate Command    sim_trace enb=11 protocol=x2 on  

Check currently time and modify parameters under lbpsPeriodList
    ${date}    execute command on enb     date
    ${day_of_week}    set variable    ${date.split()[0]}
    ${hour}    set variable    ${date.split()[3].split(":")[0]}
    ${minute}    set variable    ${date.split()[3].split(":")[1]}
    @{modify_lbpsPeriodList}    create list
    ...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=${hour}|lbpsDayOfWeek=${day_of_week}
    ...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=${minute}|lbpsDayOfWeek=${day_of_week}
    ...    NRPGRP-10:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=${day_of_week}
    ...    NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=${day_of_week}
    Delta Commission Parameters    ${modify_lbpsPeriodList} 

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

Cell States Check
    [Arguments]    ${cell_number}=1    ${State}=notEnergySaving    ${timeout}=600 
    Object Should Exist    NRCELL-${cell_number}:energySavingState=${State}    timeout=${timeout}  

Till Cell1 Enter PowerSaving And Check Send Cell1 Deactivated Message To MeNB
    [Arguments]    ${State}=energySaving
    Cell States Check    State=${State}
    RRC Should Contain    ServedNRcellsToDeleteENDCConfUpdList
    RRC Should Not Contain    deactivated

Fallback Cells To Onair
    Delta Commission Parameters    ${suspendPS}
    Cells Should Be OnAir    check_sib=${False}
