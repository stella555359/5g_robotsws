*** Settings ***
Documentation     | maxCrSibDl=26, bandwidth=5Mhz ==> max TB size (1736, 1608,1736)bit |
...               | maxCrSibDl=5, bandwidth=5Mhz ==> max TB size (336, 296,328)bit |
...               | TB size/maxNrSymPdcch(3) ==> data |
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT
...               CLOUD_R4P    release-RL60    owner-yin.zhang    DevHZ5_SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${SOS_REPORT_FLAG}    pass:False,fail:False

${UTE_WIRESHARK_FLAG}  ${True}
${pagingNb}       oneT
${defPagCyc}      32rf
${modPeriodCoeff}    8

@{PARAMS_IN_SCF}
...  LNBTS:actCMAS=false
...  LNBTS:actETWS=true
...  LNBTS:actRIMforGSM=false
...  LNBTS:actRIMforUTRAN=false
...  LNCEL:pagingNb=${pagingNb}
...  LNCEL:defPagCyc=${defPagCyc}
...  LNCEL/SIB-0:modPeriodCoeff=${modPeriodCoeff}
...  LNCEL/SIB-0:siWindowLen=20ms
...  LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=160ms|siMessageSibType=SIB10
...  LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=1 |siMessageSibType=SIB10
...  LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=160ms|siMessageSibType=SIB11
...  LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=1 |siMessageSibType=SIB11
...  LNBTS:etwsPrimNotifBcDur=60
...  @{SIB_SEGMENTED_SIZE}
...  @{PLMN_AND_TAC}

#fix validation error
...  delete:LNCEL-1/MBSFNCEL-0

@{SIB_SEGMENTED_SIZE}
...  LNCEL:dlsDciCch=DCI format 1C
...  LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...  LNCEL/LNCEL_FDD-0:dlMimoMode=Dynamic Open Loop MIMO
...  LNCEL/LNCEL_FDD-0:dlChBw=5 MHz
...  LNCEL/LNCEL_FDD-0:ulChBw=5 MHz
...  LNCEL:redBwRbUlConfig:redBwMaxRbUl=25
...  LNCEL:redBwRbUlConfig:redBwMinRbUl=1
...  LNCEL:maxCrSibDl=26

@{PLMN_AND_TAC}
...  LNCEL-1:tac=31
...  LNCEL-2:tac=32
...  LNCEL-3:tac=33
...  LNBTS:mcc=262
...  LNBTS:mnc=3
...  LNBTS:mncLength=2
...  delete:LNCEL-1:furtherPlmnIdL
...  delete:LNCEL-3:furtherPlmnIdL
...  LNCEL-2:furtherPlmnIdL:mcc=261
...  LNCEL-2:furtherPlmnIdL:mnc=2
...  LNCEL-2:furtherPlmnIdL:mncLength=2


# if gap between SIB10/SIB11 duration and next BCCH period less than this setting (unit:rf), wait one more BCCH period
# default is 50, change it to 10 to not wait one more BCCH period
${TCellcRadActivationTimeOffset}    0x000F00AD
@{PARAMS_IN_SWCONFIG}
...    ${TCellcRadActivationTimeOffset}=10

${BCCH_MOD_PERIOD}    ${${defPagCyc[:-2]}*${modPeriodCoeff}}    # unit: rf

${MAX_SEGMENT}    20    #250byte CMAS message, maxCrSibDl=5, bandwidth=5Mhz
${MIN_SEGMENT}    12    #250byte CMAS message, maxCrSibDl=5, bandwidth=5Mhz

#for case of testing tac as warning area list.
${SMALL_WARN}     84
${LARGE_WARN}     250
${LARGE_REPETITION}    15s
${SMALL_REPETITION}    2s
${EARTHQUAKE_MSGID}    4352
${TSUNAMI_MSGID}    4353
${EARTH_AND_TSUNAMI_MSGID}    4354
${TEST_MSGID}     4355
${OTHER_EMERGENCY_MSGID}    4356
${FUTURE_EXT_MSGID}    4357    # 4357,4358,4359

${cellid}
...    cellID-Broadcast contains (
...      cell-ID eq '0b0000000000000000000100000001',
...      cell-ID eq '0b0000000000000000000100000010',
...      cell-ID eq '0b0000000000000000000100000011'
...    )

${sib1}
#...    systemInformationBlockType1 contains (
...      schedulingInfoList contains (
...        (si-Periodicity eq 'rf8') and
...        sib-MappingInfo contains ('sibType10')
...      )
#...      ) and
#...      systemInfoValueTag eq ${systemInfoValueTag}
#...    )


*** Test Cases ***
LTE843_02 ENB wide broadcast of primary ETWS warning
    [Tags]
    Set Parameters For Case 02
    MME Send Primary ETWS Notification
    Wait Primary ETWS Procedure Finished
    Check BCCH_MOD_PERIOD<=Paging_ETWS<=2BCCH_MOD_PERIOD
    Check SIB10 Broadcast
    Check Paging SI Modification >= BCCH_MOD_PERIOD
    MME Send ETWS Primary WRWRequest With CMAS message id and SIB10 Should be Broadcast

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    Create CELL alias    alias=CELL_3    cell_id=3    cell_type=cus
    Execute Egate Command    sim_trace mme=1 protocol=s1 on
#    Get SystemInfoValueTag Value

#Get SystemInfoValueTag Value
#    ${out}    Execute Cmd On Pc    grep systemInfoValueTag ${WTS_DIR}/egate_console.log
#    Set Suite Variable    ${systemInfoValueTag}    ${out.splitlines()[0].split()[-1].replace(",", "")}
#    Log To Console    systemInfoValueTag is ${systemInfoValueTag}

Set Parameters For Case 02
    [Documentation]    maxCrSibDl=26, bandwidth=5Mhz ==> max TB size (1736, 1608,1736)
    Set Test Variable    ${SIB10_Periodicity}    80ms
    Set Test Variable    ${SIB10_Repetition}    1
    Set Test Variable    ${SIB11_Periodicity}    80ms
    Set Test Variable    ${SIB11_Repetition}    1
    Set Test Variable    ${etwsPrimNotifBcDur}    15
    ${delta_params}  Create List  LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=${SIB10_Periodicity}|siMessageSibType=SIB10
    ...  LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=${SIB10_Repetition} |siMessageSibType=SIB10
    ...  LNCEL/SIB-0:sibSchedulingList:siMessagePeriodicity=${SIB11_Periodicity}|siMessageSibType=SIB11
    ...  LNCEL/SIB-0:sibSchedulingList:siMessageRepetition=${SIB11_Repetition} |siMessageSibType=SIB11
    ...  LNBTS:etwsPrimNotifBcDur=${etwsPrimNotifBcDur}
    ...    LNCEL:maxCrSibDl=26
    Delta Commission Parameters And Wait Cells Onair    ${delta_params}

MME Send Primary ETWS Notification
    [Arguments]    ${msg_id}=${EARTHQUAKE_MSGID}    ${update_number}=1
    Expect Message Flow
    ...    MME_1:S1AP_WriteReplaceWarningRequest (WarningType eq '0x0180')
    ...    MME_1:S1AP_WriteReplaceWarningResponse (${cellid})
    ...    CELL_1:RRC_SystemInformationBlockType1 (${sib1})
    ...    CELL_2:RRC_SystemInformationBlockType1 (${sib1})
    ...    CELL_3:RRC_SystemInformationBlockType1 (${sib1})
    ...    CELL_1:RRC_SystemInformationBlockType10 (warningType eq '0x0180')
    ...    CELL_2:RRC_SystemInformationBlockType10 (warningType eq '0x0180')
    ...    CELL_3:RRC_SystemInformationBlockType10 (warningType eq '0x0180')
    ...    CELL_1:RRC_Paging (etws-Indication eq 'true')
    ...    CELL_2:RRC_Paging (etws-Indication eq 'true')
    ...    CELL_3:RRC_Paging (etws-Indication eq 'true')
    ...    alias=ETWS_MSG_Send    overall_timeout=30
    Send Etws Primary Request    msg_id=${msg_id}    update_number=${update_number}    warning_type=earthquake
    Set Test Variable    ${cells_count}    3
    Flow Occurred As Expected    alias=ETWS_MSG_Send

Wait Primary ETWS Procedure Finished
    [Arguments]    ${tag}=${EMPTY}
    Sleep    ${${BCCH_MOD_PERIOD}*10*2}ms    #max time for etws paging
    Expect Message Flow
    ...    CELL_1:RRC_Paging (systemInfoModification eq 'true')
    ...    CELL_2:RRC_Paging (systemInfoModification eq 'true')
    ...    CELL_3:RRC_Paging (systemInfoModification eq 'true')
    ...    alias=SIM_Send    overall_timeout=30
    Sleep    ${etwsPrimNotifBcDur}s
    Sleep    ${${BCCH_MOD_PERIOD}*10}ms    #max gap to next bcch modification period boundary
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType1 (${sib1})
    ...    alias=CELL1_SIB10_INS_Cancel    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_2:RRC_SystemInformationBlockType1 (${sib1})
    ...    alias=CELL2_SIB10_INS_Cancel    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_3:RRC_SystemInformationBlockType1 (${sib1})
    ...    alias=CELL3_SIB10_INS_Cancel    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType10 (warningType eq '0x0180')
    ...    alias=CELL1_SIB10_MSG_Cancel    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_2:RRC_SystemInformationBlockType10 (warningType eq '0x0180')
    ...    alias=CELL2_SIB10_MSG_Cancel    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_3:RRC_SystemInformationBlockType10 (warningType eq '0x0180')
    ...    alias=CELL3_SIB10_MSG_Cancel    overall_timeout=30
    Sleep    ${${BCCH_MOD_PERIOD}*10}ms    SI modifcation procedure for SIB12
    Set Test Variable    ${sib10_min_time}    ${${BCCH_MOD_PERIOD}*10+${etwsPrimNotifBcDur}*1000+${BCCH_MOD_PERIOD}*10}
    Set Test Variable    ${sib10_max_time}    ${${BCCH_MOD_PERIOD}*2*10+${etwsPrimNotifBcDur}*1000+${BCCH_MOD_PERIOD}*10*2}
    Flow Occurred As Expected    alias=SIM_Send
    Flow Not Occurred For Message    alias=CELL1_SIB10_INS_Cancel
    Flow Not Occurred For Message    alias=CELL2_SIB10_INS_Cancel
    Flow Not Occurred For Message    alias=CELL3_SIB10_INS_Cancel
    Flow Not Occurred For Message    alias=CELL1_SIB10_MSG_Cancel
    Flow Not Occurred For Message    alias=CELL2_SIB10_MSG_Cancel
    Flow Not Occurred For Message    alias=CELL3_SIB10_MSG_Cancel

Check BCCH_MOD_PERIOD<=Paging_ETWS<=2BCCH_MOD_PERIOD
    Execute Cmd On Pc    tshark -r ${SAVE LOG DIRECTORY}/ute_wireshark.pcap -V > ${SAVE LOG DIRECTORY}/uec_wireshark.txt    timeout=60
    ${paging_etws_count}    Get Message Count Per Cell    ${SAVE LOG DIRECTORY}/uec_wireshark.txt    etws-Indication: true
    Should Be True    ${BCCH_MOD_PERIOD}<=${paging_etws_count}<=${2*${BCCH_MOD_PERIOD}}    #pagingNb=oneT, i.e.paging period is 1rf


Check SIB10 Broadcast
    ${sib10_count}    Get Message Count Per Cell    ${SAVE LOG DIRECTORY}/uec_wireshark.txt    sib-TypeAndInfo item: sib10
    ${sib10_min}    Set Variable    ${${sib10_min_time}/${SIB10_Periodicity[:-2]}*(1+${SIB10_Repetition})}
    ${sib10_max}    Set Variable    ${${sib10_max_time}/${SIB10_Periodicity[:-2]}*(1+${SIB10_Repetition})}
    Should Be True    ${sib10_min}<=${sib10_count}<=${sib10_max}

Check Paging SI Modification >= BCCH_MOD_PERIOD
    ${paging_sim_count}    Get Message Count Per Cell    ${SAVE LOG DIRECTORY}/uec_wireshark.txt    systemInfoModification: true
    Should Be True    ${paging_sim_count}>=${BCCH_MOD_PERIOD}    #pagingNb=oneT, i.e.paging period is 1rf

MME Send ETWS Primary WRWRequest With CMAS message id and SIB10 Should be Broadcast
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType12-r9
    ...    alias=CELL1_NO_SIB12_MSG    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType12-r9
    ...    alias=CELL2_NO_SIB12_MSG    overall_timeout=30
    Expect Message Will Not Occur
    ...    CELL_1:RRC_SystemInformationBlockType12-r9
    ...    alias=CELL3_NO_SIB12_MSG    overall_timeout=30
    Send Etws Primary Request    msg_id=4372
    Wait Primary ETWS Procedure Finished
    Flow Not Occurred For Message    alias=CELL1_NO_SIB12_MSG
    Flow Not Occurred For Message    alias=CELL2_NO_SIB12_MSG
    Flow Not Occurred For Message    alias=CELL3_NO_SIB12_MSG

Get Message Count Per Cell
    [Arguments]    ${check_file}    ${check_string}
    ${result}    Grep File    ${check_file}    ${check_string}
    ${total_count}    Get Line Count    ${result}
    ${count_per_cell}    Set Variable    ${${${total_count}}/${cells_count}}
    [Return]    ${count_per_cell}