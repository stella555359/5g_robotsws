*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-CN3ET    owner-chengmao.sun    release-SBTS23R3
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
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
...    delete:NRBTS-2/TRACKINGAREA-200:snssaiList
...    delete:NRCELL:ranAC
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

@{counter10}
...    ${F1_CSI_CELL_SWITCH_OFF}=1
...    ${X2_ENDC_CELL_SWITCH_OFF_SENT}=1
...    ${F1_CSI_CELL_SWITCH_ON}=0
...    ${X2_ENDC_CELL_SWITCH_ON_SENT}=0

@{counter10_2}
...    ${F1_CSI_CELL_SWITCH_OFF}=1
...    ${X2_ENDC_CELL_SWITCH_OFF_SENT}=1
...    ${F1_CSI_CELL_SWITCH_ON}=1
...    ${X2_ENDC_CELL_SWITCH_ON_SENT}=1

${F1_CSI_CELL_SWITCH_OFF}    M55150C00048
${X2_ENDC_CELL_SWITCH_OFF_SENT}    M55110C00036
${F1_CSI_CELL_SWITCH_ON}    M55150C00047
${X2_ENDC_CELL_SWITCH_ON_SENT}    M55110C00035

@{disable8951}
...    NRBTS:actCoordinated4g5gPowerSaving=disabled
@{suspendPS}
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=suspended

@{caseA_12}
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=2

@{case02_prepare_precondition}
...    NRBTS:actCoordinated4g5gPowerSaving=disabled
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=200
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=2
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended

@{case07_prepare_precondition}
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactivation
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=200
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=120
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    delete:NRPGRP-10:lbpsCellList:lbpsCellSOOrder=70|nrCellId=2
...    NRBTS/NRPGRP-10:lbpsPeriodList:lbpsSuspended=notSuspended

*** Test Cases ***
CB008951-A-a_ET_01_10_MeNB is informed that the NR switched-off cell with NSA is activated when online disable CB008951 and switch on the cell
    [Tags]
    Wait NRcell enter pwsaving and check counters
    Disabled 8951 to make cell change to energySaving
    SuspendPS to make cell change to notEnergySaving
    Check Counters    ${counter10_2}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008951-A_10${/}a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::2

CB008951-A-a_ET_01_12_MeNB is informed that the NR switched-off cell with NSA is added when online enabled CB008951 and switch on the cell
    [Tags]
    Delta Commission Parameters    ${disable8951}
    Set the time to the current time and check states
    Active 8951 and set two cells in psgroup
    UE Attach and establish EN-DC    target_cell=2
    Send And Verify Throughput
    Cell States Check    State=notEnergySaving
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008951-A_12${/}a2a.ini    wait_string=ENDCConfigurationUpdateAcknowledge::4

CB008951-A-a_ET_01_02_MeNB will be informed that NRCELL with NSA is deleted when CB008951 is deactivated
    [Tags]
    Fallback Cells To Onair
    OnlineParamChange    ${case02_prepare_precondition}
    Check currently time and modify parameters under lbpsPeriodList
    Till Cell1 Enter PowerSaving And Check Send Cell1 Deactivated Message To MeNB

CB008951-A-a_ET_01_07_Fault7101 will not occur at power saving cell1 when peer X2 link is down
    [Tags]
    Fallback Cells To Onair
    Check currently time and modify parameters under lbpsPeriodList
    OnlineParamChange    ${case07_prepare_precondition}
    Till Cell1 Enter PowerSaving
    Make The Peer X2 Link Down
    Cell2 And Cell3 Have Fault7107 But Cell1 Has Not

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

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=11    ${target_cell}=1
    Start RRC Log    establish_EN-DC
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE    
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    reported successful RA
    Get RRC Log

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}

Disabled 8951 to make cell change to energySaving
    Delta Commission Parameters    ${disable8951}
    Cell States Check    State=energySaving
	
SuspendPS to make cell change to notEnergySaving
    Delta Commission Parameters    ${suspendPS}
    Cell States Check    State=notEnergySaving

Active 8951 and set two cells in psgroup
    Delta Commission Parameters    ${caseA_12}

Cell States Check
    [Arguments]    ${cell_number}=1    ${State}=notEnergySaving    ${timeout}=600 
    Object Should Exist    NRCELL-${cell_number}:energySavingState=${State}    timeout=${timeout}  

Wait NRcell enter pwsaving and check counters
    Clear Counter files
    Set the time to the current time and check states
    Check Counters    ${counter10}
  
Till Cell1 Enter PowerSaving
    [Arguments]    ${State}=energySaving
    Cell States Check    State=${State}  

Till Cell1 Enter PowerSaving And Check Send Cell1 Deactivated Message To MeNB
    [Arguments]    ${State}=energySaving
    Cell States Check    State=${State}
    RRC Should Contain    ServedNRcellsToDeleteENDCConfUpdList
    RRC Should Not Contain    deactivated

Make The Peer X2 Link Down
    Execute Egate Command    link_lock link=x2 at=enb:1 to=enb:2    pass_regexp=Gnb X2AP Link with ENB-2 \\(10.0.1.2:36422\\[0\\]\\) is locked

Fallback Cells To Onair
    Delta Commission Parameters    ${suspendPS}
    Cells Should Be OnAir    check_sib=${False}

Cell2 Has fault7107   
    ${fault7107}    create list    fault_id=7107    alarming_object=NRCELL-2
    fm_fault_should_be_raised    ${fault7107}

Cell3 Has fault7107   
    ${fault7107}    create list    fault_id=7107    alarming_object=NRCELL-3
    fm_fault_should_be_raised    ${fault7107}

Cell1 Has Not fault7107   
    ${fault7107}    create list    fault_id=7107    alarming_object=NRCELL-1
    fm_fault_should_not_exist    ${fault7107}

Cell2 And Cell3 Have Fault7107 But Cell1 Has Not
    Cell2 Has fault7107
    Cell3 Has fault7107
    Cell1 Has Not fault7107    

Set the time to the current time and check states
    Check currently time and modify parameters under lbpsPeriodList
    Cell States Check    State=energySaving

Send And Verify Throughput
    [Arguments]    ${ue_id}=11
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=50 trf_id=1    UE ${ue_id}: UDP DL
    Verify Throughput    sleep_time=10s

Verify Throughput
    [Arguments]    ${sleep_time}=10s    ${ue_id}=11
    sleep    ${sleep_time}
    ${dl_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_Throughput}/1000>20
