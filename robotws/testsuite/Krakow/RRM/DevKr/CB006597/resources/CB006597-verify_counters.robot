*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta5g_pm_counters

*** Variables ***


*** Keywords ***

Check counters: UAI_PREF_IDLE_REP ${uai_i}, UAI_PREF_INACT_REP ${uai_in}, UAI_PREF_OUTCONN_REP ${uai_o}, UAI_PREF_CONN_REP ${uai_c}
    Verify any counters in file
    ...    M55124C08502     ${uai_i}    UAI_PREF_IDLE_REP
    ...    M55124C08503     ${uai_in}    UAI_PREF_INACT_REP
    ...    M55124C08505     ${uai_o}    UAI_PREF_OUTCONN_REP
    ...    M55124C08504     ${uai_c}    UAI_PREF_CONN_REP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

Check VRAN counters: UAI_PREF_IDLE_REP ${uai_i}, UAI_PREF_INACT_REP ${uai_in}, UAI_PREF_OUTCONN_REP ${uai_o}, UAI_PREF_CONN_REP ${uai_c}
    Verify CU counter value on NRCELL-1 for M55124C08502 - UAI_PREF_IDLE_REP equals ${uai_i}
    Verify CU counter value on NRCELL-1 for M55124C08503 - UAI_PREF_INACT_REP equals ${uai_in}
    Verify CU counter value on NRCELL-1 for M55124C08505 - UAI_PREF_OUTCONN_REP equals ${uai_o}
    Verify CU counter value on NRCELL-1 for M55124C08504 - UAI_PREF_CONN_REP equals ${uai_c}

Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range ${lower} - ${higher}
    verify_if_any_pm_counter_is_in_range_of_given_values
    ...    M55124C08501     ${lower}    ${higher}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS}

Check VRAN counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range ${lower} - ${higher}
    Verify CU counter value on NRCELL-1 for M55124C08501 - ACC_UAI_RRC_REL_PREF_CONF_UES is in range ${lower} - ${higher}

Check counter: ACC_UAI_RRC_REL_PREF_CONF_UES eq ${uai_acc}
    Verify any counters in file
    ...    M55124C08501     ${uai_acc}    ACC_UAI_RRC_REL_PREF_CONF_UES
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

Check counters: UAI_RRC_REL_IDLE_PREF_IDLE ${i}, UAI_RRC_REL_IDLE_PREF_INACT ${in}, UAI_RRC_REL_IDLE_PREF_OUTCON ${o}, UAI_INTIME_RES_PREF_CONN ${c}
    Verify any counters in file
    ...    M55124C08506     ${i}    UAI_RRC_REL_IDLE_PREF_IDLE
    ...    M55124C08507     ${in}    UAI_RRC_REL_IDLE_PREF_INACT
    ...    M55124C08508     ${o}    UAI_RRC_REL_IDLE_PREF_OUTCON
    ...    M55124C08509     ${c}    UAI_INTIME_RES_PREF_CONN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

Check VRAN counters:UAI_RRC_REL_IDLE_PREF_IDLE ${i},UAI_RRC_REL_IDLE_PREF_INACT ${in},UAI_RRC_REL_IDLE_PREF_OUTCON ${o},UAI_INTIME_RES_PREF_CONN ${c}
    Verify CU counter value on NRCELL-1 for M55124C08506 - UAI_RRC_REL_IDLE_PREF_IDLE equals ${i}
    Verify CU counter value on NRCELL-1 for M55124C08507 - UAI_RRC_REL_IDLE_PREF_INACT equals ${in}
    Verify CU counter value on NRCELL-1 for M55124C08508 - UAI_RRC_REL_IDLE_PREF_OUTCON equals ${o}
    Verify CU counter value on NRCELL-1 for M55124C08509 - UAI_INTIME_RES_PREF_CONN equals ${c}

Check counters: SA_UE_CTX_REL_UAI ${normal}, NG_FLOW_REL_GNB_UAI ${Qos_F}, NG_FLOW_REL_GNB_UAI_5QI1 ${5QI_1}
    Verify any counters in file
    ...    M55125C12001     ${normal}    SA_UE_CTX_REL_UAI
    ...    M55125C12004     ${Qos_F}    NG_FLOW_REL_GNB_UAI
    ...    M55125C12005     ${5QI_1}    NG_FLOW_REL_GNB_UAI_5QI1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

Check VRAN counters: SA_UE_CTX_REL_UAI ${normal}, NG_FLOW_REL_GNB_UAI ${Qos_F}, NG_FLOW_REL_GNB_UAI_5QI1 ${5QI_1}
    Verify CU counter value on NRCELL-1 for M55125C12001 - SA_UE_CTX_REL_UAI equals ${normal}
    Verify CU counter value on NRCELL-1 for M55125C12004 - NG_FLOW_REL_GNB_UAI equals ${Qos_F}
    Verify CU counter value on NRCELL-1 for M55125C12005 - NG_FLOW_REL_GNB_UAI_5QI1 equals ${5QI_1}

Check counters NRPMQAP-${pmqap_id}: NG_FLOW_REL_GNB_UAI_PMQAP ${suc}
    Verify any counters in file
    ...    M55163C02502     ${suc}    NG_FLOW_REL_GNB_UAI_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-${pmqap_id}
    ...    file_path=${PM_COUNTERS}

Check VRAN counters NRPMQAP-${pmqap_id}: NG_FLOW_REL_GNB_UAI_PMQAP ${suc}
    Verify CU counter value on NRCELL-1/NRPMQAP-${pmqap_id} for M55163C02502 - NG_FLOW_REL_GNB_UAI_PMQAP equals ${suc}

Check counter: NG_FLOW_REL_ABNORMAL_5QI1 ${rel}
    Verify any counters in file
    ...    M55125C09515     ${rel}    NG_FLOW_REL_ABNORMAL_5QI1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}
