*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Maciej Haladewicz, Patrycja Lis
...  Description:   Coutnters variables naming conception: variable name is corresponding
...                 to tc name where variable is in use. The only exception are variables from
...                 subitem C because all variables are in use in all tc from this subitem and variables
...                 from TC A#1_11 because of different counters locations

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/thresholds_8204.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008204/resources/lib_8204.py    WITH NAME    lib
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/cplane_collector.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.robot

# For optimized TCs
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py  WITH NAME  ch


*** Variables ***
@{UE}              UE_1
${THROUGHPUT}      800Mbits/sec
@{FDD_CELL}        ${5}     ${6}     ${7}     ${8}
@{TDD_SA_CELL}     ${17}    ${18}    ${19}    ${20}
@{TDD_NSA_CELL}    ${1}     ${2}     ${3}     ${4}   # _variable for TLs: SA5 and UTE177
@{LTE}             ${13}    ${14}    ${15}    ${16}
${A#1_06}          M55364C00001,M55364C00002
${A#1_11_1}        M55352C02001,M55352C02002
${A#1_11_2}        M55362C00002,M55362C00001
@{A#1_12}          M55352C02005      M55352C02006
${A#1_17}          M55352C02003,M55352C02004
${a_17_dl}         M55352C02003
${a_17_dl_disc}    M55352C02004
${A#2}             M55352C02007
${B#1_04}          M55353C02001,M55353C02002
@{C_1}             M55146C00002
${C_102}           M55146C00001
${C_2}             M55146C00002
@{C}               M55146C00001    M55146C00002    M55146C00003    M55162C01001
${d3_01_ul}        M55308C36001
${d3_01_dl}        M55308C36002
${cell_size_cfg}   M55307C03001
${E#1_02}          M55363C00001,M55363C00002
@{E#1_03}          M55363C00003      M55363C00004
${F#2_04}          M55353C02003,M55353C02004
${d3_test_cell}    91
${f2_04_cell}      30
${f2_04}           M55353C02003
${f2_04_lost}      M55353C02004
${EDA8204_test_cell}    1
${eda_01_ul}            M55364C00002


*** Keywords ***
[1]EDA8204-A#ST_EDA_for_04588484
    Detach UEs from cell    ${UE}
    lock_all_cells_except  ${EDA8204_test_cell}

    Log to console    __Waiting for counters appearance...
    Sleep    5m

    ${ul_counter}  get counter values  ${eda_01_ul}
    ${last_ul_counter_v}  ch.Get Last Counters Values
    ...  ${ul_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${EDA8204_test_cell}']['NRPMQAP-1']['X2UPQ']}

    ch.check_counters_are_zero    ${last_ul_counter_v}

    Attach UEs to cell    ${UE}
    Start ULDL for UEs    ${UE}    duration=360s    protocol=udp
    sleep    360
    Stop all datatransfers

    ${ul_counter}  get counter values  ${eda_01_ul}

    ${last_ul_counter_v}  ch.Get Last Counters Values
    ...  ${ul_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${EDA8204_test_cell}']['NRPMQAP-1']['X2UPQ']}

    ch.check_counters_are_zero    ${last_ul_counter_v}

    [Teardown]
    ...  unlock_all_cells


[1]CB008204-A#1_06_UL_PDCP_SDU_X2_PMQAP_and_UL_PDCP_SDU_LOST_X2_PMQAP_NSA_FDD
    [Documentation]    M55364C00001 : UL_PDCP_PDU_X2_PMQAP, M55364C00002 : UL_PDCP_PDU_LOST_X2_PMQAP
    ...                If counters does not increment please check parameter on LTE scf site. Should be set:
    ...                     - actGtpUpSeqNumX2UI = enabled
    Perform commissioning 8204    ulDataPath=ulOverLteNr_PrimaryPathOverLte    dlDataSplitMode=dlOverF1UX2U
    Lock FDD/TDD cells            type=TDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    &{counters_before}            Get counters      ${A#1_06}
    &{last_counters}   pu.get last counters values  ${counters_before['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['X2UPQ']}
    pu.check counters are zero    ${last_counters}
    log to console                ${last_counters}
    Attach UEs and start tput     ${UE}    udp    both    360sec
    FOR    ${i}  IN  1  2  3  4
         log to console    __Attenuation ${i} is ongoing...
         Sleep  30s
         Strengthen and weaken attenuation          ${FDD_cell}    ${0}    ${90}
    END
    Wait For Tput Finish And Get Tput Statistics     ${UE}
    &{counters_after}             Get counters      ${A#1_06}
    &{last_counters}   pu.get last counters values  ${counters_after['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['X2UPQ']}
    log to console                ${last_counters}
    pu.check counters are greater than zero         ${last_counters}
    should be true    ${last_counters}[M55364C00001] >= ${last_counters}[M55364C00002]


[1]CB008204-A#1_11_UL_PDCP_SDU_CU_PMQAP_and_UL_PDCP_SDU_LOST_CU_PMQAP_SA_FDD
    [Documentation]    M55352C02001 : UL_PDCP_SDU_CU_PMQAP, M55352C02002 : UL_PDCP_SDU_LOST_CU_PMQAP
    ...                M55362C00002 : UL_PDCP_PDU_LOST_F1_PMQAP, M55364C00002 : UL_PDCP_PDU_LOST_X2_PMQAP
    ...                M55362C00001 : UL_PDCP_PDU_F1_PMQAP, M55364C00001 : UL_PDCP_PDU_X2_PMQAP
    Perform commissioning 8204    ulDataPath=ulOverNr    dlDataSplitMode=dlOverF1U
    Lock FDD/TDD cells            type=TDD
    Bar all eNB cells
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    Get counters and check values before tput for a111     ${A#1_11_1}    ${A#1_11_2}    ${A#1_06}
    Attach UEs and start tput     ${UE}    udp    both    360sec
    Sleep    60s
    Set attenuation and check     ${FDD_cell}     ${att_value}
    Wait For Tput Finish And Get Tput Statistics     ${UE}
    Get counters and check values after tput for a111      ${A#1_11_1}    ${A#1_11_2}    ${A#1_06}
    [Teardown]  Unbar all eNB cells


[1]CB008204-A#1_12_DL_PDCP_SDU_VOL_RCV_PMQAP_and_UL_PDCP_SDU_VOL_SNT_PMQAP_NSA_TDD
    [Documentation]    M55352C02005 : DL_PDCP_SDU_VOL_RCV_PMQAP, M55352C02006 : UL_PDCP_SDU_VOL_SNT_PMQAP
    Perform commissioning 8204    ulDataPath=ulOverNr    dlDataSplitMode=dlOverF1UX2U
    Lock FDD/TDD cells            type=FDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    ${counters_value_before}      get counters value      ${A#1_12}
    check if counters values equal zero      ${counters_value_before}    ${A#1_12}
    Attach UEs and start tput     ${UE}    tcp    both    180sec
    Sleep    60s
    Set attenuation and check     ${TDD_NSA_cell}    ${att_value}
    Wait For Tput Finish And Get Tput Statistics     ${UE}
    Wait for counters
    ${counters_value_after}       get counters value      ${A#1_12}
    Log counters values           ${A#1_12}               ${counters_value_after}


[1]CB008204-A#1_17_DL_PDCP_SDU_USDAT_CU_PMQAP_and_DL_PDCP_SDU_DISC_CU_PMQAP_SA_TDD
    [Documentation]    M55352C02003 : DL_PDCP_SDU_USDAT_CU_PMQAP, M55352C02004 : DL_PDCP_SDU_DISC_CU_PMQAP

    Detach UEs from cell    ${UE}
    perform_rat_block  LTE
    lock_all_cells_except  ${d3_test_cell}
    Change miNrPdcpCellNrpmqap interval

    Log to console    __Waiting for counters appearance...
    Sleep    310s

    ${dl_counter}  get counter values  ${a_17_dl}
    ${dl_disc_counter}  get counter values  ${a_17_dl_disc}
    ${last_dl_counter_v}  ch.Get Last Counters Values
    ...    ${dl_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NRPMQAP-1']['PDCPQ']}
    ${last_dl_disc_counter_v}  ch.Get Last Counters Values
    ...    ${dl_disc_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NRPMQAP-1']['PDCPQ']}

    ch.Check Counters Are Zero    ${last_dl_counter_v}
    ch.Check Counters Are Zero    ${last_dl_disc_counter_v}

    Attach UEs to cell    ${UE}
    Detach UEs from cell    ${UE}
    Attach UEs to cell    ${UE}
    sleep  10s
    Start ULDL for UEs    ${UE}    duration=360s
    Log to console    __Waiting for counters appearance...
    Sleep    300s

    ${dl_counter}  get counter values  ${a_17_dl}
    ${dl_disc_counter}  get counter values  ${a_17_dl_disc}
    ${last_dl_counter_v}  ch.Get Last Counters Values
    ...    ${dl_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NRPMQAP-1']['PDCPQ']}
    ${last_dl_disc_counter_v}  ch.Get Last Counters Values
    ...    ${dl_disc_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NRPMQAP-1']['PDCPQ']}

    should be true    ${last_dl_counter_v['${a_17_dl}']} >= ${last_dl_disc_counter_v['${a_17_dl_disc}']}
    ...  ${last_dl_counter_v} shoudn't be less than ${last_dl_disc_counter_v}

    [Teardown]  run keywords
    ...  unlock_all_cells  AND
    ...  perform_rat_unblock  LTE


[1]CB008204-A#2_02_UL_PDCP_VOL_RCV_X2_LTE_PMQAP_LTENR_FDD
    [Documentation]    M55352C02007 : UL_PDCP_VOL_RCV_X2_LTE_PMQAP
    Perform commissioning 8204    ulDataPath=ulOverLte    dlDataSplitMode=dlOverF1UX2U
    ...                           initialDLTrafficRouting=initDLoverX2U
    Lock FDD/TDD cells            type=TDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    &{counters_before}            Get counters    ${A#2}

    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['PDCPQ']
    ...    ['BTS']['CELLS']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['PDCPQ']

    &{last_counters}   pu.get last counters values  ${counters_before${counter_path}}
    pu.check counters are zero    ${last_counters}
    log to console                ${last_counters}
    Attach UEs to cell    ${UE}
    Detach UEs from cell    ${UE}
    Attach UEs to cell    ${UE}
    Start Ul for UEs    ${UE}    duration=410s
    sleep    400s
    Stop all datatransfers
    &{counters_after}             Get counters    ${A#2}
    &{last_counters}   pu.get last counters values  ${counters_after${counter_path}}
    log to console                ${last_counters}
    pu.check counters are greater than zero         ${last_counters}


[1]CB008204-A#2_04_UL_PDCP_VOL_RCV_X2_LTE_PMQAP_LTE_UL_only_FDD
    [Documentation]    M55352C02007 : UL_PDCP_VOL_RCV_X2_LTE_PMQAP
    Perform commissioning 8204    ulDataPath=ulOverLte                  dlDataSplitMode=dlOverF1UX2U
    ...                           ulDataSplitThreshold=infinity         initialDLTrafficRouting=initDLoverX2U
    Lock FDD/TDD cells            type=TDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    &{counters_before}            Get counters    ${A#2}

    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['PDCPQ']
    ...    ['BTS']['CELLS']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['PDCPQ']

    &{last_counters}   pu.get last counters values  ${counters_before${counter_path}}
    pu.check counters are zero    ${last_counters}
    log to console                ${last_counters}
    Attach UEs to cell    ${UE}
    Start Max ULDL TCP    ue_alias=${UE}[0]    tput_duration=900s
    sleep    360s
    Stop ULDL
    &{counters_after}             Get counters    ${A#2}
    &{last_counters}   pu.get last counters values  ${counters_after${counter_path}}
    log to console                ${last_counters}
    pu.check counters are greater than zero         ${last_counters}


[1]CB008204-B#1_04_DL_RLC_SDU_USDAT_DU_PMQAP_and_DL_RLC_SDU_DISC_DU_PMQAP_SA_FDD
    [Documentation]    M55353C02001 : DL_RLC_SDU_USDAT_DU_PMQAP, M55353C02002 : DL_RLC_SDU_DISC_DU_PMQAP
    ...                Test passes when syslog values (calculated only for counter M55353C02002) checked
    ...                in 'lib.check_disbcb_and_disbcp_values' equals zero or when values from syslog
    ...                are > 0 and counters values from WebEM are > 0.
    Perform commissioning 8204   cfgProfType=SA  sa_mode=${True}
    Set attenuation and check    ${LTE}    ${90}
    Lock FDD/TDD cells           type=TDD
    #
    Start syslog capture    log_name=RlcDlDrbQ.LOG  alias=RlcDlDrbQ
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    &{counters_before}           Get counters    ${B#1_04}

    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['HRLCQ']
    ...    ['BTS']['CELLS']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['HRLCQ']

    &{last_counters}    pu.get last counters values    ${counters_before${counter_path}}
    pu.check counters are zero   ${last_counters}
    log to console               ${last_counters}
    Detach UEs from cell    ${UE}
    Attach UEs to cell    ${UE}
    Detach UEs from cell    ${UE}
    Attach UEs and start tput    ${UE}    udp   both     360sec    res=off
    Sleep  60s
    Set attenuation and check    ${FDD_cell}    ${att_value}
    run keyword and ignore error  Wait For Tput Finish And Get Tput Statistics     ${UE}
    Wait for counters   5min
    &{counters_after}            Get counters    ${B#1_04}
    stop syslog capture  alias=RlcDlDrbQ

    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['HRLCQ']
    ...    ['BTS']['CELLS']['NRCELL-${fdd_cell_id}']['NRPMQAP-1']['HRLCQ']

    &{last_counters}    pu.get last counters values    ${counters_before${counter_path}}
    log to console               ${last_counters}
    pu.check counters are zero      ${last_counters}
    should be true    ${last_counters}[M55353C02001] >= ${last_counters}[M55353C02002]


[1]CB008204-C#1_02_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_LTENR_PrimaryPathOverLTE_FDD
    [Documentation]    Test Case created as a response for EDA https://jiradc.ext.net.nokia.com/browse/MNRCA-61131
    ...                Pronto related with EDA action - PR02904791
    ...                M55146C00001 : ENDC_UL_DATA_TIME_LTE
    Detach Ue   ${UE}[0]
    Log to console  __Perform site reset to clear counters history
    coam.reset site  connection=gNB
    Verify if all cells are onair
    Perform commissioning 8204    ulDataPath=ulOverLte    ulDataSplitThreshold=infinity
    ...                           sa_mode=${True}
    Lock FDD/TDD cells            type=FDD

    Log to console    __Waiting for counters appearance...
    Sleep    315s

    &{counter_before}   Get counters    ${C_102}
    ${counter_path}    Get Counter Path For Release
    ...    SBTS23R4
    ...    ['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-4']['NRBC']
    ...    ['BTS']['CELLS']['NRCELL-4']['NRBC']
    &{last_counter}    pu.get last counters values  ${counter_before${counter_path}}
    pu.check counters are zero   ${last_counter}

    Setup cplane tcpdump collector
    Start cplane logs
    Mute all cells

    attach Ue   ${UE}[0]
    Start UL for UEs    ${UE}    duration=1800s
    Perform NR outage
    Stop cplane logs
    Detach Ue   ${UE}[0]

    Log to console    __Waiting for counters appearance...
    sleep  315s

    &{counter_after}   Get counters    ${C_102}
    &{last_counter_after}    pu.get last counters values
    ...  ${counter_after${counter_path}}
    pu.check counters are greater than zero   ${last_counter_after}
    Log to console    __Counters comparision OK.

    Log to console    __Waiting for unexpected counters appearance...
    sleep  5m
    &{counter_before}   Get counters    ${C_102}
    &{last_counter}    pu.get last counters values
    ...  ${counter_before${counter_path}}
    pu.check counters are zero   ${last_counter}


[1]CB008204-C#1_04_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_LTENR_PrimaryPathOverLTE_TDD_no_NR_outage
    [Documentation]    M55146C00001 : ENDC_UL_DATA_TIME_LTE, M55146C00002 : ENDC_UL_DATA_TIME_NR
    ...                M55146C00003 : ENDC_UL_DATA_TIME_LTENR, M55162C01001 : ENDC_UL_DATA_TIME_LTE_PMQAP
    Perform commissioning 8204    ulDataPath=ulOverLteNr_PrimaryPathOverLte    ulDataSplitThreshold=b102400
    Lock FDD/TDD cells            type=TDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    ${counter_value_before}=    Get counters and check values before tput for c subitem
    Attach Ue   ${UE}[0]
    sleep       10s
    Detach Ue   ${UE}[0]
    Sleep       300sec
    Get counters and check values after tput for c subitem
    &{counter_after}   Get counters    ${C_2}
    &{last_counter}    pu.get last counters values  ${counter_after['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['X2CCQ']}
    pu.check counters are zero   ${last_counter}


[1]CB008204-C#2_03_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_NR_only_FDD_no_NR_outage
    [Documentation]    M55146C00002 : ENDC_UL_DATA_TIME_NR
    Perform commissioning 8204    ulDataPath=ulOverNr  sa_mode=${True}
    Lock FDD/TDD cells            type=TDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    Get counters and check values before tput for c subitem
    Attach Ue   ${UE}[0]
    sleep       10s
    Detach Ue   ${UE}[0]
    Sleep       300sec
    Get counters and check values after tput for c subitem


[1]CB008204-C#3_02_Monitor_time_on_each_leg_for_NSA_UEs_with_UL_data_splitting_Bearer_added_with_UL_on_LTE_only_FDD
    [Documentation]    M55146C00001 : ENDC_UL_DATA_TIME_LTE, M55146C00002 : ENDC_UL_DATA_TIME_NR
    ...                M55146C00003 : ENDC_UL_DATA_TIME_LTENR, M55162C01001 : ENDC_UL_DATA_TIME_LTE_PMQAP
    Perform commissioning 8204    ulDataPath=ulOverLte
    Lock FDD/TDD cells            type=TDD
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    ${counters_values_before}=    Get counters and check values before tput for c subitem
    Attach Ue   ${UE}[0]
    sleep       10s
    Detach Ue   ${UE}[0]
    Sleep       300sec
    Get counters and check values after tput for c subitem
    Should be true               ${counters_values_before}[0] < 60000
    &{counter_after}   Get counters    ${C_2}
    &{last_counter}    pu.get last counters values  ${counter_after['BTS']['CELLS']['NRCELL-${ACTIVE_CELL_ID}']['NRPMQAP-1']['X2CCQ']}
    Should be true     ${counters_values_before}[1][M55162C01001] < ${last_counter}[M55162C01001]
    Should be true     ${last_counter}[M55162C01001] < 60000


[1]CB008204-D#3_01_DL_PRB_UTIL_SLOT_MAX_and_UL_PRB_UTIL_SLOT_MAX_SA_TDD
    [Documentation]    M55308C36001 : DL_PRB_UTIL_SLOT_MAX, M55308C36002 : UL_PRB_UTIL_SLOT_MAX

    Detach UEs from cell    ${UE}
    perform_rat_block  LTE
    lock_all_cells_except  ${d3_test_cell}

    Log to console    __Waiting for counters appearance...
    Sleep    5m

    ${ul_counter}  get counter values  ${d3_01_ul}
    ${dl_counter}  get counter values  ${d3_01_dl}

    ${last_dl_counter_v}  ch.Get Last Counters Values
    ...    ${ul_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NCELA']}
    ${last_dl_counter_v}  ch.Get Last Counters Values
    ...    ${dl_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NCELA']}

    # Less that 20 due to random undetached ues ticks occurences
    ch.Check Counters Are Less Than Number    ${last_dl_counter_v}    500
    ch.Check Counters Are Less Than Number    ${last_dl_counter_v}    500

    attach ues to cell  ${UE}
    Detach UEs from cell    ${UE}
    attach ues to cell  ${UE}
    sleep  10s
    Start ULDL for UEs    ${UE}    duration=360s    protocol=udp
    sleep    360
    Stop all datatransfers

    ${ul_counter}  get counter values  ${d3_01_ul}
    ${dl_counter}  get counter values  ${d3_01_dl}

    ${last_ul_counter_v}  ch.Get Last Counters Values
    ...    ${ul_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NCELA']}
    ${last_dl_counter_v}  ch.Get Last Counters Values
    ...    ${dl_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${d3_test_cell}']['NCELA']}

    ch.Check Counters Are Greater Than Zero    ${last_ul_counter_v}
    ch.Check Counters Are Greater Than Zero    ${last_dl_counter_v}

    # Counters should be less than 100
    ch.Check Counters Are Less Than Number    ${last_ul_counter_v}    100
    ch.Check Counters Are Less Than Number    ${last_dl_counter_v}    100

    Check M55307C03001 Value  ${d3_test_cell}

    [Teardown]  run keywords
    ...  unlock_all_cells  AND
    ...  perform_rat_unblock  LTE


[1]CB008204-E#1_02_DL_PRB_USED_DATA_PMQAP_and_UL_PRB_USED_DATA_PMQAP_SA_FDD
    [Documentation]    M55363C00001 : DL_PRB_USED_DATA_PMQAP, M55363C00002 : UL_PRB_USED_DATA_PMQAP
    Perform commissioning 8204
    Lock FDD/TDD cells    type=TDD
    Bar all eNB cells
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    ${counters_value_before}     get counters value      ${E#1_03}
    Check counters values        15    >=    ${counters_value_before}    ${E#1_03}
    Log counters values          ${E#1_03}   ${counters_value_before}    %
    Attach UEs and start tput    ${UE}    udp   both     360sec
    Wait For Tput Finish And Get Tput Statistics     ${UE}
    Wait for counters   5min
    ${counters_value_after}      get counters value      ${E#1_03}
    Check counters values        90    <=    ${counters_value_after}     ${E#1_03}    check_less_than_100=True
    Log counters values          ${E#1_03}   ${counters_value_after}     %
    [Teardown]  Unbar all eNB cells


[1]CB008204-E#1_03_DL_PRB_UTIL_SLOT_MAX_PMQAP_and_UL_PRB_UTIL_SLOT_MAX_PMQAP_SA_TDD
    [Documentation]    M55363C00003 : DL_PRB_UTIL_SLOT_MAX_PMQAP, M55363C00004 : UL_PRB_UTIL_SLOT_MAX_PMQAP
    Perform commissioning 8204
    Lock FDD/TDD cells    type=FDD
    Bar all eNB cells
    #
    Log to console    __Waiting for counters appearance...
    Sleep    300s
    ${counters_value_before}     get counters value      ${E#1_03}
    Check counters values        15    >=    ${counters_value_before}    ${E#1_03}
    Log counters values          ${E#1_03}   ${counters_value_before}    %
    Attach UEs and start tput    ${UE}    udp   both     360sec
    Wait For Tput Finish And Get Tput Statistics     ${UE}
    Wait for counters   5min
    ${counters_value_after}      get counters value      ${E#1_03}
    Check counters values        90    <=    ${counters_value_after}     ${E#1_03}    check_less_than_100=True
    Log counters values          ${E#1_03}   ${counters_value_after}     %
    [Teardown]  Unbar all eNB cells


[1]CB008204-F#2_04_DL_RLC_SDU_TX_AIR_PMQAP_and_DL_RLC_SDU_LOST_AIR_PMQAP_SA_FDD
    [Documentation]    M55353C02003 : DL_RLC_SDU_TX_AIR_PMQAP, M55353C02004 : DL_RLC_SDU_LOST_AIR_PMQAP

    Detach UEs from cell    ${UE}
    perform_rat_block  LTE
    lock_all_cells_except  ${f2_04_cell}
    Change miNrHighRlcCellNrpmqap interval

    Log to console    __Waiting for counters appearance...
    Sleep    310s

    ${f2_counter}  get counter values  ${f2_04}
    ${f2_lost_counter}  get counter values  ${f2_04_lost}

     &{last_f2_counters}    ch.get last counters values
    ...  ${f2_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${f2_04_cell}']['NRPMQAP-1']['HRLCQ']}

    &{last_f2_lost_counter}    ch.get last counters values
    ...  ${f2_lost_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${f2_04_cell}']['NRPMQAP-1']['HRLCQ']}

    ch.check counters are zero   ${last_f2_counters}
    ch.Check Counters Are Zero    ${last_f2_lost_counter}

    attach ues to cell  ${UE}
    Detach UEs from cell    ${UE}
    attach ues to cell  ${UE}
    sleep  10s
    Start ULDL for UEs    ${UE}    duration=360s
    sleep  300s
    Stop all datatransfers

    ${f2_counter}  get counter values  ${f2_04}
    ${f2_lost_counter}  get counter values  ${f2_04_lost}

     &{last_f2_counters}    ch.get last counters values
    ...  ${f2_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${f2_04_cell}']['NRPMQAP-1']['HRLCQ']}

    &{last_f2_lost_counter}    ch.get last counters values
    ...  ${f2_lost_counter['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${f2_04_cell}']['NRPMQAP-1']['HRLCQ']}

    ch.Check Counters Are Zero    ${last_f2_lost_counter}

    [Teardown]  run keywords
    ...  unlock_all_cells  AND
    ...  perform_rat_unblock  LTE