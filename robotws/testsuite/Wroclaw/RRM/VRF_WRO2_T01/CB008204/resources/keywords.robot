*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py


*** Variables ***
${BTS_ID}           ${tl.gnbs[0].instance_id}
${MAIN_SCF_PATH}    MRBTS-${bts_id}/NRBTS-${bts_id}
${fdd_cell_id}    1
${tdd_cell_id}    4

*** Keywords ***
Perform commissioning 8204
    [Arguments]
    ...             ${ulDataPath}=ulOverNr
    ...             ${dlDataSplitMode}=dlOverF1U
    ...             ${miNrPdcpCellNrpmqap}=5min
    ...             ${actIpThpt}=true
    ...             ${rlcMode}=RLC_AM
    ...             ${miNrF1UInterfaceCUpmqap}=5min
    ...             ${miNrX2UInterfacepmqap}=5min
    ...             ${miNrHighRlcCellNrpmqap}=5min
    ...             ${miNrRadBearer}=5min
    ...             ${cfgProfType}=both
    ...             ${ulDataSplitThreshold}=infinity
    ...             ${initialDLTrafficRouting}=initDLoverF1U
    ...             ${dlPreferredPath}=F1-U
    ...             ${sa_mode}=${False}


    log to console     __Adding NRPMQAP object
    Run keyword and ignore error    Add NRPMQAP object  cfgProfType=${cfgProfType}
    Log to console     __Perform commissioning 8204
    Initialise delta store
    Add param to delta        ${MAIN_SCF_PATH}                actIpThpt                 value=${actIpThpt}
    Add param to delta        ${MAIN_SCF_PATH}/NRPMRNL-1      miNrPdcpCellNrpmqap       value=${miNrPdcpCellNrpmqap}
    Add param to delta        ${MAIN_SCF_PATH}/NRPMRNL-1      miNrF1UInterfaceCUpmqap   value=${miNrF1UInterfaceCUpmqap}
    Add param to delta        ${MAIN_SCF_PATH}/NRPMRNL-1      miNrX2UInterfacepmqap     value=${miNrX2UInterfacepmqap}
    Add param to delta        ${MAIN_SCF_PATH}/NRPMRNL-1      miNrHighRlcCellNrpmqap    value=${miNrHighRlcCellNrpmqap}
    Add param to delta        ${MAIN_SCF_PATH}/NRPMRNL-1      miNrRadBearer             value=${miNrRadBearer}
    &{nsaDrbParam_dict}       Create dictionary
    ...     ulDataPath=${ulDataPath}
    ...     dlDataSplitMode=${dlDataSplitMode}
    ...     actPrioritizeX2AfterInactivity=false
    ...     actX2DuplicateTxNSA3x=false
    ...     dlDataSplitBufferBuildUpThreshold=5
    ...     dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
    ...     dlDataSplitGainThreshold=5
    ...     dlNumOfCongOrGainDdds=2
    ...     inactivityThresholdForPrioritizeX2=300
    ...     inactivityThresholdForRestartPrioritizeX2=100
    ...     initialDLTrafficRouting=${initialDLTrafficRouting}
    ...     nsa3xBearerAllowed=true
    ...     prioritizeX2Period=500
    ...     ulDataSplitThreshold=${ulDataSplitThreshold}

    ${sw_name}    common.get_sw_name
    Run Keyword If    '${sw_name}' == 'SBTS23R4'    Set To Dictionary
    ...                                             ${nsaDrbParam_dict}    dlPreferredPath=${dlPreferredPath}

    ${r}  check_release_is_higher_than  SBTS23R4
    run keyword if  ${r} == ${True} and ${sa_mode} == ${False}  set to dictionary
    ...                                                         ${nsaDrbParam_dict}  dlPreferredPath=${dlPreferredPath}

    ${nrdrb_list}       Get list of specific object dist name  class_name=NRDRB_A
    FOR    ${nrdrb}    IN    @{nrdrb_list}
        Add list parameters to delta    ${nrdrb}    nsaDrbParam    &{nsaDrbParam_dict}
        Add param to delta              ${nrdrb}    rlcMode        value=${rlcMode}
    END

    run keyword if
    ...  '${TEST_NAME}' == '[1]CB008204-A#1_17_DL_PDCP_SDU_USDAT_CU_PMQAP_and_DL_PDCP_SDU_DISC_CU_PMQAP_SA_TDD'
    ...  Add param to delta  ${MAIN_SCF_PATH}  actThpDist  value=false

    ${delta}    Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair



Perform actRrcInactiveState: ON
    [Documentation]
    ...             For 23R2 some params from KW 'Perform actRrcInactiveState: ON' are not available anymore.
    ...             This KW must be commented [tested: 24.01.23, SBTS00_ENB_9999_230123_000008]
    ...             Also for 23R1 TC is OK w/o this KW [tested: 25.01.23, SBTS23R1_ENB_0000_000701_000000]
    [Arguments]
    ...             ${inactivityTimerSA}=5
    ...             ${actRrcInactiveState}=true
    ...             ${srbInactivityTimerSA}=60
    ...             ${drbInactivityTimerSA}=10
    ...             ${periodicRNAUTimer}=1min
    ...             ${timerMaxUeInactTime}=2
    ...             ${ranAC}=255
    ...             ${ranAreaConfigList}=255
    Log to console     __Perform actRrcInactiveState: ON
    Initialise delta store
    Add param to delta        ${MAIN_SCF_PATH}      inactivityTimerSA         value=${inactivityTimerSA}
    Add param to delta        ${MAIN_SCF_PATH}      actRrcInactiveState       value=${actRrcInactiveState}
    Add param to delta        ${MAIN_SCF_PATH}      srbInactivityTimerSA      value=${srbInactivityTimerSA}
    Add param to delta        ${MAIN_SCF_PATH}      drbInactivityTimerSA      value=${drbInactivityTimerSA}
    Add param to delta        ${MAIN_SCF_PATH}      periodicRNAUTimer         value=${periodicRNAUTimer}
    Add param to delta        ${MAIN_SCF_PATH}      timerMaxUeInactTime       value=${timerMaxUeInactTime}
    ${cell_ids}    Get cell ids
    ${ranAreaConfigList}    Create list    ${ranAreaConfigList}
    FOR    ${cell_id}    IN     @{cell_ids}
           Add param to delta  ${MAIN_SCF_PATH}/NRCELL-${cell_id}    ranAC                value=${ranAC}
           Add param to delta  ${MAIN_SCF_PATH}/NRCELL-${cell_id}    ranAreaConfigList    value=${ranAreaConfigList}
    END
    ${delta}    Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair


Add NRPMQAP object
    [Arguments]
    ...                 ${actNrpmqapProfiles}=true
    ...                 ${cfgProfType}=both
    ${nrbts_dist}    Get list of specific object dist name    class_name=NRBTS_A
    ${nrbts_path}    Get from list    ${nrbts_dist}    0
    Initialise delta store
    ${mnp_dict}    Create Dictionary    cfgProfType=${cfgProfType}
    add managed object and parameter to delta    dist_name=${nrbts_path}/NRPMRNL-1/NRPMQAP-1    &{mnp_dict}
    Add param to delta     ${nrbts_path}         actNrpmqapProfiles             value=${actNrpmqapProfiles}
    ${delta}       Collect delta store
    Recommission with delta from admin  ${delta}


Check counters values
    [Documentation]
    ...             Kw takes args:
    ...             value - single value
    ...             expression - e.g. <, <=
    ...             counters_values - list of counters values
    ...             counters_names - list of counters names
    ...             check_less_than_100 - bool value
    [Arguments]
    ...             ${value}
    ...             ${expression}
    ...             ${counters_values}
    ...             ${counters_names}
    ...             ${check_less_than_100}=False

    ${length}       get length    ${counters_names}
    FOR    ${i}   IN RANGE  ${length}
        Should be true      ${value} ${expression} ${counters_values[${i}]}
        ...                 ${value} ${expression} ${counters_values[${i}]} (${counters_names[${i}]}) is not true
    END
    Run keyword if  ${check_less_than_100}   Check if counters are less than 100  ${counters_values}  ${counters_names}


Check if counters are less than 100
    [Documentation]
    ...             Kw takes args:
    ...             counters_values - list of counters values
    ...             counters_names - list of counters names
    [Arguments]
    ...             ${counters_values}
    ...             ${counters_names}

    ${length}       get length    ${counters_names}
    FOR    ${i}   IN RANGE  ${length}
        Should be true      100 >= ${counters_values[${i}]}
        ...                 100 >= ${counters_values[${i}]} (${counters_names[${i}]}) is not true
    END


Log counters values
    [Arguments]
    ...             ${names}
    ...             ${values}
    ...             ${unit}=
    ${length}       Get length  ${names}
    FOR    ${i}    IN RANGE    ${length}
        log to console      ${names[${i}]} = ${values[${i}]}${unit}
    END


Get counters and check values before tput for c subitem
    [Documentation]    KW gets counters values and check if all of them equals zero

    &{counters_before}           Get counters    ${C_2}
    &{last_counter}   pu.get last counters values
    ...  ${counters_before['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${fdd_cell_id}']['NRBC']}

    pu.check counters are zero   ${last_counter}
    Log to console    __Initial counters values OK

Get counters and check values after tput for c subitem
    [Documentation]
    ...              KW passes if all values except the one indicated by index from
    ...              counters_value_before are equal to zero. The one indicated value
    ...              have to be less than new counter value

    &{counters_after}           Get counters    ${C_2}
    &{last_counter}   pu.get last counters values
    ...  ${counters_after['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${fdd_cell_id}']['NRBC']}

    pu.check counters are greater than zero   ${last_counter}
    Log to console    __Counters values OK


Get counters and check values before tput for a111
    [Documentation]    KW gets counters values and check if all of them equals zero
    [Arguments]
    ...            ${counters_1}
    ...            ${counters_2}
    ...            ${counters_3}
    Log to console                __Getting counters values
    &{counters_before_1}          Get counters        ${counters_1}
    &{last_counters_1}   pu.get last counters values  ${counters_before_1['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['PDCPQ']}
    pu.check counters are zero    ${last_counters_1}
    log to console                ${last_counters_1}

    &{counters_before_2}          Get counters        ${counters_2}
    &{last_counters_2}   pu.get last counters values  ${counters_before_2['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['F1UPQ']}
    pu.check counters are zero    ${last_counters_2}
    log to console                ${last_counters_2}

    &{counters_before_3}          Get counters        ${counters_3}
    &{last_counters_3}   pu.get last counters values  ${counters_before_3['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['X2UPQ']}
    pu.check counters are zero    ${last_counters_3}
    log to console                ${last_counters_3}
    Log to console                __Initial counters values OK


Get counters and check values after tput for a111
    [Documentation]    KW gets all counters values and pass if all needed conditions ale True
    [Arguments]
    ...            ${counters_1}
    ...            ${counters_2}
    ...            ${counters_3}
    Log to console                __Getting counters values
    &{counters_after_1}           Get counters        ${counters_1}
    &{last_counters_1}   pu.get last counters values  ${counters_after_1['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['PDCPQ']}
    log to console                ${last_counters_1}
    pu.check counters are greater than zero       ${last_counters_1}

    &{counters_after_2}           Get counters        ${counters_2}
    &{last_counters_2}   pu.get last counters values  ${counters_after_2['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['F1UPQ']}
    log to console                ${last_counters_2}

    &{counters_after_3}           Get counters        ${counters_3}
    &{last_counters_3}   pu.get last counters values  ${counters_after_3['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['X2UPQ']}
    log to console                ${last_counters_3}

    should be true    ${last_counters_1}[M55352C02001] >= ${last_counters_1}[M55352C02002]
    should be true    ${last_counters_1}[M55352C02002] >= (${last_counters_2}[M55362C00002] + ${last_counters_3}[M55364C00002])
    should be true    ${last_counters_1}[M55352C02001] >= (${last_counters_2}[M55362C00001] + ${last_counters_3}[M55364C00001])
    Log to console                __Counters values OK


Check M55307C03001 Value
    [Documentation]    02941450: [NPI 23R1 RJIO PD4.0][FIELD][5G][ASOE][CB008204] EXP_CELL_SIZE value is 0
    ...    Be sure that NRBTS.NRPMRNL.NRPMCCP.cfgTAcounters = 0 (Bin ranges based on SCS)
    ...    24/h counter M55307C03001 == 99, if not then FAIL
    [Arguments]  ${cell_to_check}

    Log To Console    __Check M55307C03001 value
    &{counter_value}            Get counters    M55307C03001

    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${cell_to_check}']['NRTA']
    ...    ['BTS']['CELLS']['NRCELL-${cell_to_check}']['NRTA']

    &{last_counter_value}   pu.get last counters values
    ...  ${counter_value${counter_path}}
    log to console      M55307C03001 == ${last_counter_value['M55307C03001']}
    Should Be Equal    ${last_counter_value['M55307C03001']}    ${99}    Counter value M55307C03001 IS NOT 99


Slowly attenuate for UL_RLO
    sleep  1m
    FOR  ${i}  IN RANGE  6  90  8
        set attenuation and check  ${FDD_CELL}  value=${i}
        sleep  10s
    END
    sleep  10s

Perform NR outage
    set attenuation and check  ${FDD_CELL}  value=60
    set attenuation and check  ${TDD_SA_CELL}  value=50
    sleep    4s
    set attenuation and check  ${TDD_SA_CELL}  value=10
    sleep    4s
    set attenuation and check  ${TDD_SA_CELL}  value=30
    set attenuation and check  ${FDD_CELL}  value=57
    sleep    4s
    set attenuation and check  ${TDD_SA_CELL}  value=50
    sleep    3s
    set attenuation and check  ${TDD_SA_CELL}  value=60
    sleep    3s
    set attenuation and check  ${TDD_SA_CELL}  value=70
    sleep    3s
    set attenuation and check  ${TDD_SA_CELL}  value=90
    sleep    3s
    set attenuation and check  ${FDD_CELL}  value=65
    sleep    3s
    set attenuation and check  ${TDD_SA_CELL}  value=0
    sleep    3s
    set attenuation and check  ${FDD_CELL}  value=90
    sleep    3s

Mute all cells
    set attenuation and check  ${FDD_CELL}  value=90
    set attenuation and check  ${TDD_SA_CELL}  value=90

Change miNrPdcpCellNrpmqap interval
    log to console  __Setting miNrPdcpCellNrpmqap to 5min
    coam.create delta

    coam.append parameter update to delta
    ...  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPMRNL-1
    ...  miNrPdcpCellNrpmqap
    ...  5min

    ${delta}  coam.get delta
    activate_delta_recommissioning  ${delta}


Change miNrHighRlcCellNrpmqap interval
    log to console  __Setting miNrHighRlcCellNrpmqap to 5min
    coam.create delta

    coam.append parameter update to delta
    ...  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPMRNL-1
    ...  miNrHighRlcCellNrpmqap
    ...  5min

    ${delta}  coam.get delta
    activate_delta_recommissioning  ${delta}
