*** Settings ***
Suite Setup    Setup BTS env and set keyword prority
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   Author:      Mao Cathy
...   Contact:     cathy.mao@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB008015

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G

Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot



*** Variables ***

${EMIL_FLAG}    ${False}

@{PARAMS_IN_SCF}
...    @{ANR_PARAMS}

@{direction_component_list}    UL_L2LO    DL_L2LO

${Loop_times}    1

@{Lock_Cell2}
...    NRCELL-2:administrativeState=Locked

@{UnLock_Cell2}
...    NRCELL-2:administrativeState=Unlocked

@{Lock_Cell3}
...    NRCELL-3:administrativeState=Locked

@{UnLock_Cell3}
...    NRCELL-3:administrativeState=Unlocked


@{bad_fdd_cell1_pa_values}
...    5=${120}
...    6=${120}
...    7=${120}
...    8=${120}


@{attach_cell3_pa_values}
...    1=${70}
...    2=${70}
...    3=${35}
...    4=${35}

@{attach_cell2_pa_values}
...    1=${40}
...    2=${40}
...    3=${70}
...    4=${70}

@{IntraGNB_HO_From_Cell2_To_Cell3_Params}
...    src_cell=2,port=1-2,good=45,bad=65
...    tgr_cell=3,port=3-4,good=45,bad=65

@{IntraGNB_HO_From_Cell3_To_Cell2_Params}
...    src_cell=3,port=3-4,good=40,bad=70
...    tgr_cell=2,port=1-2,good=40,bad=70

@{pscell_23_list}    596978    596979
@{pscell_32_list}    596979    596978

${dl_pt}    50
${ul_pt}    10

@{DELETE_Cell3_NRREL}
...    delete:NRCELL-3/NRREL

@{ANR_PARAMS}
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=55
...    NRSYSINFO_PROFILE-2:systemInformationTargetRate=55
#...    NRBTS:actEnhanceIntraNrIntraFreqAnr=true
...    NRBTS:actSaUeBasedAnrNr=true
...    NRBTS:actSaUeBasedInterFreqAnrNr=true
...    NRBTS:actDedicatedAnrDrxProfile=true
...    NRBTS:actSaIntraFreqAnrDrxProf=true
...    NRANR-1:actAutoEutraNbRemoval=false
...    NRANR-1:actAutoNrNbRemoval=true
...    NRANR-1:consecHoFailThres=0
...    NRANR-1:consecHoFailThresEutra=3
...    NRANR-1:consecXnResolveFailThres=3
...    NRANR-1:gNbIdLengthConfig:gNbIdLength=32
...    NRANR-1:gNbIdLengthConfig:priorityIndex=1
...    NRANR-1:gNbIdLengthConfig:nrPlmnDN=NRPLMN-1
...    NRANR-1:nrAnrId=1
...    NRANRPR-1:anrThresholdSelector=RSRP
...    NRANRPR-1:anrThresRsrpNbCell=-90
...    NRANRPR-1:anrThresRsrqNbCell=-12
...    NRANRPR-1:cellDepMode=SA
...    NRANRPR-1:consecRecheckForNrNbRemoval=5
...    NRANRPR-1:idleTimeForNrNbRemoval=2
...    NRANRPR-1:maxNumAnrNrrelAllowed=50
...    NRANRPR-1:nrAnrPrId=1
...    NRANRPR-2:anrThresRsrpNbCell=-90     #-90 dBm is equal to RSRP value of 67 reported by the UE
...    NRANRPR-2:anrThresRsrqNbCell=-12     #-12 dB is equal to RSRQ value of 63 reported by the UE
...    NRANRPR-2:anrThresholdSelector=RSRP
...    NRANRPR-2:cellDepMode=SA
...    NRANRPR-2:consecRecheckForNrNbRemoval=5
...    NRANRPR-2:idleTimeForNrNbRemoval=2  # hours, value: 2 ~ 192
...    NRANRPR-2:maxNumAnrNrrelAllowed=10
...    NRANRPR-2:nrarfcn=125400
...    NRANRPR-2:ssbFrequency=124350
...    NRCELL:actCDrx=true
...    NRCELL:drxProfileNrAnr:drxControl=any
...    NRCELL:drxProfileNrAnr:drxInactivityTimer=80ms
...    NRCELL:drxProfileNrAnr:drxLongCycle=320ms
...    NRCELL:drxProfileNrAnr:drxOnDurationTimer=20ms
...    NRCELL:drxProfileNrAnr:drxRetransTimerDl=0slot
...    NRCELL:drxProfileNrAnr:drxRetransTimerUl=0slot
...    NRCELL:drxProfileNrAnr:nrDrxDN=NRDRX-3
...    NRDRX-3:drxInactivityTimer=80ms
...    NRDRX-3:drxLongCycle=320ms
...    NRDRX-3:drxOnDurationTimer=20ms
...    NRDRX-3:drxRetransTimerDl=0slot
...    NRDRX-3:drxRetransTimerUl=0slot


*** Test Cases ***
L3Call And ANR_HO Lock CA
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=qualcomm    ue_index=${0}
    Prepare PA To Register Cell3
    SA Attach UE And Verify    cell_id=${pscell_32_list[0]}
#    UE Attach To Cell3 And Send Traffic    cell_id=${pscell_32_list[0]}
    Run Keyword And Ignore Error    Delta Commission Parameters     ${DELETE_Cell3_NRREL}
    Lock Cell2    ${Lock_Cell2}
    Loop HO And Lock
    [Teardown]    Case TearDown


*** Keywords ***
UE Attach To Cell3 And Send Traffic
    [Arguments]    ${cell_id}    ${dl_tput}=${dl_pt}    ${ul_tput}=${ul_pt}    ${tput_ratio}=0.95
    SA Attach UE And Verify    cell_id=${cell_id}
    Start L3 Call With Power UE    ue_index=${0}    ul_data_transfer=${ul_tput}M    dl_data_transfer=${dl_tput}M
    ...    duration=1800
    Check CA ULDL Throughput    PSCell_List=${pscell_32_list}    CC_num=2
    ...    dl_tput=${dl_tput}    ul_tput=${ul_tput}
#    Check 2CC CA    PSCell_List=${pscell_32_list}    dl_tput=${dl_tput}    ul_tput=${ul_tput}

Loop HO And Lock
    FOR    ${index}    IN RANGE    0    ${Loop_times}
        UnLock Cell    ${UnLock_Cell2}
        IntraGNB HO From FDD Cell3 To Cell2
        Run Keyword If    ${index}==0    Object Should Exist    NRCELL-3/NRREL:lcrId=2
        Run Keyword If    ${index}==0    Start L3 Call With Power UE    ue_index=${0}    ul_data_transfer=${ul_pt}M
        ...    dl_data_transfer=${dl_pt}M    duration=1800
        Lock Cell3    ${Lock_Cell3}
        UnLock Cell    ${UnLock_Cell3}
        Check CA ULDL Throughput    PSCell_List=${pscell_32_list}    CC_num=2
        ...    dl_tput=${dl_pt}    ul_tput=${ul_pt}
        IntraGNB HO From FDD Cell2 To Cell3
        Lock Cell2    ${Lock_Cell2}
    END


Case TearDown
    Stop Traffic With Power UE     ue_index=${0}    is_detach=True
    Run Keyword And Ignore Error    UnLock Cell    ${UnLock_Cell3}
    Run Keyword And Ignore Error    UnLock Cell    ${UnLock_Cell2}
    Common Test Teardown And Stop Capture Logs

Prepare PA To Register Cell3
    set_pa_values    ${bad_fdd_cell1_pa_values}
    sleep    10s
    set_pa_values    ${attach_cell3_pa_values}

IntraGNB HO From FDD Cell2 To Cell3
    intragnb_intercell_ho    ${IntraGNB_HO_From_Cell2_To_Cell3_Params}
    sleep    10s
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${0}    cell_id=596979

IntraGNB HO From FDD Cell3 To Cell2
    intragnb_intercell_ho    ${IntraGNB_HO_From_Cell3_To_Cell2_Params}
    sleep    10s
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${0}    cell_id=596978

Lock Cell2
    [Arguments]    ${params}
    Delta Commission Parameters    ${params}
    Cells Should Be OnAir    cell_id=1
    Cells Should Be OnAir    cell_id=3

Lock Cell3
    [Arguments]    ${params}
    Delta Commission Parameters    ${params}
    Cells Should Be OnAir    cell_id=1
    Cells Should Be OnAir    cell_id=2

UnLock Cell
    [Arguments]    ${params}
    Delta Commission Parameters    ${params}
    Cells Should Be OnAir


Check 2CC CA
    [Arguments]    ${PSCell_List}    ${dl_tput}    ${ul_tput}    ${CC_num}=2    ${tput_ratio}=0.95
    ${ul_expect}    Set Variable    ${${ul_tput}*${tput_ratio}}
    ${dl_expect}    Set Variable    ${${dl_tput}*${tput_ratio}}
    #kw:Check Tput With Power UE, not correct for CA tput check
    Run Keyword And Ignore Error    Check Tput With Power UE    expect_ul_tput=${ul_expect}
    ...    expect_dl_tput=${dl_expect}    duration=30
    ...    direction_component_list=@{direction_component_list}    cellid=2    check_source=aasyslog
    Run Keyword And Ignore Error    Check Tput With Power UE    expect_ul_tput=${ul_expect}
    ...    expect_dl_tput=${dl_expect}    duration=30
    ...    direction_component_list=@{direction_component_list}    cellid=3    check_source=aasyslog
    Check CA ULDL Throughput    PSCell_List=${PSCell_List}    CC_num=${CC_num}
    ...    dl_tput=${dl_pt}    ul_tput=${ul_pt}
