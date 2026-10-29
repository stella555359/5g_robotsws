*** Settings ***
Force Tags      RAN_5G    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD_ORAN    STATE_CONFIGURED

Documentation
...            Integration of eCPRI FDD with APoABIO (O-RAN compliant)
...            authors:       Wojciech Gicala,    wojciech.gicala@nokia.com
...                           Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainers:   Wojciech Gicala,    wojciech.gicala@nokia.com
...                           Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com

Resource    ./resources/5GC002271-keywords-oran.robot

Suite Setup    Testline Setup
Suite Teardown    Testline Teardown

*** Variables ***
${default_configs}      /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/SANSA_FS_ECPRI_CMWV_FDD_ORAN
${default_scf}          ${default_configs}/scfc.xml
${default_swconfig}     ${default_configs}/swconfig_gnb.txt
${default_wts_cfg}      ${default_configs}/basic.cfg
${cell_1_local_moid}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
&{TTI_TRACE_STREAM}     nr_phy_cell_ids=50   up_sw=L2Ps    trace_type=Component
@{tti_traces}    ${TTI_TRACE_STREAM}

# A-5
${delta_A5}        ${CURDIR}/resources/Delta-A_5.json
&{logs_A-5}        tcpdump_gnb=yes    bip_gnb=yes    syslog_gnb=yes
&{TC_CONFIG_A5}    delta=${delta_A5}
&{swconfig_A-5}    0x590072=1    # CP-RT log level 1 = debug

&{A-5_cnt_1}    id=M55165C00015    name=DENOM_SR_POOLS_RES    mo_id=${cell_1_local_moid}    value=300
&{A-5_cnt_2}    id=M55165C00024    name=MAX_USED_RES_SLOT80    mo_id=${cell_1_local_moid}    value=3
&{A-5_cnt_3}    id=M55165C00025    name=SUM_USED_RES_SLOT80    mo_id=${cell_1_local_moid}    value=900
@{A-5_exact_value_counters}    &{A-5_cnt_1}    &{A-5_cnt_2}    &{A-5_cnt_3}

# A-b-9
${delta_A-b-9}    ${CURDIR}/resources/Delta-A-b_9.json
&{swconfig_A-b-9}    0x59015b=2    # rdSrLoadThresholdFactor
...                  0x59015e=0    # rdSrLoadThresholdDownHysteresis
...                  0x590072=1    # CP-RT log level 1 = debug

&{logs_A-b-9}    syslog_gnb=yes    tcpdump_gnb=yes    sherpa=${tti_traces}
&{TC_CONFIG_A-b-9}       delta=${delta_A-b-9}    logs=${logs_A-b-9}

&{A-b-9_CNT_1}    id=M55165C00003     name=SR_SLOT20_POOL_SIZE          mo_id=${cell_1_local_moid}      value=160
&{A-b-9_CNT_2}    id=M55165C00004     name=SR_SLOT40_POOL_SIZE          mo_id=${cell_1_local_moid}      value=320
&{A-b-9_CNT_3}    id=M55165C00009     name=SR_SLOT20_POOL_AS_MAIN       mo_id=${cell_1_local_moid}      value=300
&{A-b-9_CNT_4}    id=M55165C00007     name=SR_SLOT5_POOL_AS_MAIN        mo_id=${cell_1_local_moid}      value=0
&{A-b-9_CNT_5}    id=M55165C00008     name=SR_SLOT10_POOL_AS_MAIN       mo_id=${cell_1_local_moid}      value=0
&{A-b-9_CNT_6}    id=M55165C00011     name=SR_SLOT80_POOL_AS_MAIN       mo_id=${cell_1_local_moid}      value=0
&{A-b-9_CNT_7}    id=M55165C00012     name=SR_SLOT160_POOL_AS_MAIN      mo_id=${cell_1_local_moid}      value=0
&{A-b-9_CNT_8}    id=M55165C00013     name=MAIN_POOL_CHANGED_TO_LONGER      mo_id=${cell_1_local_moid}      value=1
&{A-b-9_CNT_9}    id=M55165C00014     name=MAIN_POOL_CHANGED_TO_SHORTER      mo_id=${cell_1_local_moid}      value=1

@{A-b-9_COUNTERS_1}  &{A-b-9_CNT_1}  &{A-b-9_CNT_2}  &{A-b-9_CNT_3}  &{A-b-9_CNT_4}  &{A-b-9_CNT_5}  &{A-b-9_CNT_6}  &{A-b-9_CNT_7}
@{A-b-9_COUNTERS_2}  &{A-b-9_CNT_4}  &{A-b-9_CNT_5}  &{A-b-9_CNT_6}  &{A-b-9_CNT_7}  &{A-b-9_CNT_8}
@{A-b-9_COUNTERS_3}  &{A-b-9_CNT_4}  &{A-b-9_CNT_5}  &{A-b-9_CNT_6}  &{A-b-9_CNT_7}  &{A-b-9_CNT_9}

# A-e-45
${delta_A-e-45}         ${CURDIR}/resources/Delta-A-e_45.json
&{swconfig_A-e-45}    0x59015b=6       # rdSrLoadThresholdFactor
...                   0x590169=3000    # rdSrPoolCleanUpTimer
...                   0x590072=1       # CP-RT log level 1 = debug

&{logs_A-e-45}    tcpdump_gnb=yes    bip_gnb=yes    syslog_gnb=yes
&{TC_CONFIG_A-e-45}     delta=${delta_A-e-45}

# A-f-40
${delta_A-f-40}    ${CURDIR}/resources/Delta_A-f-40.json
&{logs_A-f-40}    syslog_gnb=yes    tcpdump_gnb=yes
&{TC_CONFIG_A-f-40}       delta=${delta_A-f-40}

&{swconfig_A-f-40}    0x59015b=65     # rdSrLoadThresholdFactor
...                   0x59015c=500    # rdSrReconfigurationsInterval
...                   0x59015d=1      # rdSrReconfigurationsNumber
...                   0x59015e=20     # rdSrLoadThresholdDownHysteresis
...                   0x590072=1      # CP-RT log level 1 = debug

# B-b-10
${delta_B-b-10}    ${CURDIR}/resources/Delta_B-b-10.json
&{logs_B-b-10}    syslog_gnb=yes    tcpdump_gnb=yes    bip_gnb=yes    sherpa=${tti_traces}
&{TC_CONFIG_B-b-10}       delta=${delta_B-b-10}    logs=${logs_B-b-10}
&{swconfig_B-b-10}    0x590072=1       # CP-RT log level 1 = debug
${disable_noise_from_AP}    confmgmtbrowser write NrUeUlPhy rdDontScheduleNrUePuxchNoiseInjection 1

&{B-b-10_cnt_2}    id=M55308C30004    name=ULPROGRANT_SKIP_SEQ_EXP    mo_id=${cell_1_local_moid}    value=1
@{B-b-10_exact_value_counters}    ${B-b-10_cnt_2}

&{B-b-10_cnt_3}    id=M55308C31003    name=MAX_ULPROGRANT_SKIP_SEQ_DUR    mo_id=${cell_1_local_moid}
&{B-b-10_cnt_4}    id=M55308C31004    name=AVG_ULPROGRANT_SKIP_SEQ_DUR    mo_id=${cell_1_local_moid}
@{B-b-10_nonzero_counters}    ${B-b-10_cnt_3}    ${B-b-10_cnt_4}

*** Test Cases ***
[1][3.0] 5GC002271-A-e_45_Reservations for low latency verification on FDD setup
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...   Reservations for low latency verification on FDD setup with blocking pool minimization=0.
    ...   Test with R&D flag rdSrLowLatencyFactor and low latency NIDD parameter not configured. 4 pools are configured.
    ...   If there are more pools that have free LL resources, then the pool with the smallest ID shall be chosen.
    ...
    ...  PRECONDITIONS:
    ...
    ...  pucchModeSelect = "longPucch"
    ...  srPeriodicity = "slots40"
    ...  srPeriodicityMin = "slots5"
    ...  actAdaptiveSr = "TRUE"
    ...  miNrResourceUtilizationPerCell = "5"(min)
    ...  adaptiveSrLoadThresholdUp = "60"(percent)
    ...  adaptiveSrLoadThresholdDown = "40"(percent)
    ...  R&D flag rdSrLoadThresholdFactor (percent) is set so that (set to 3 in swconfig)
    ...  loadThrUp_pool#1 = 1,
    ...  loadThrUp_pool#2 = 2,
    ...  loadThrUp_pool#3 = 5,
    ...  loadThrDown_pool#4 = 7
    ...  lowLatencyReservation = 3
    ...  reservation_for_low_latency_pool#1 = 2,
    ...  reservation_for_low_latency_pool#2 = 4,
    ...  reservation_for_low_latency_pool#3 = 8
    ...  adaptiveSrBlockingMinimization = 0
    ...  vonrReservation = 0
    ...  actProactUlScheduling = false
    ...  actUlTxSkip = false
    ...  reqMinNumPuschPrb = "19"
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   TA24395-B20X
    ...
    ...  REQUIRED LOGS:        Snapshot, RD.BTS log, CPRT log
    ...
    ...
    ...  CONTACTS:   OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
    ...  AUTHOR:     Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
    ...
    ...  REFERENCES:   5GC002271 CFAM
    ...
    [Setup]    Run keywords
    ...           ta5g_enb.Put swconfig file    input_filepath=${default_swconfig}
    ...   AND     Add RnD Flags to GNB Swconfig     &{swconfig_A-e-45}
    ...   AND     Fix and Upload SCF    scf=${default_scf}
    ...   AND     Prepare WTS config files for Multiple UEs SA
    ...   AND     Wait for All Cells to be Configured    timeout=300
    ...   AND     Test Case Setup    config=${TC_CONFIG_A-e-45}    logs=${logs_A-e-45}    reach_on_air=yes    radio_res=yes    log_dir=A-e_45

    Wait for Next PM Counters Interval
    sleep    70s    reason=Increase pmcounter value to extend margin of error
    Start GNB L1L2 BIP Trace Collection
    ${timestamp0}    Set timestamp0 for proper counters counting
    ${localtime1}     Set localtime1 for pool verification
    Start SA L3 Call    ue_id=3    dl_tput=100kbps    ul_tput=100kbps
    ${timestamp1}    Set timestamp1 for proper counters counting
    Start SA L3 Call    ue_id=4    dl_tput=100kbps    ul_tput=100kbps
    ${timestamp2}    Set timestamp2 for proper counters counting
    ${localtime2}     Set localtime2 for pool verification
    Start SA L3 Call    ue_id=5    dl_tput=100kbps    ul_tput=100kbps

    Count time between timestamps    time0=${timestamp0}    time1=${timestamp1}    time2=${timestamp2}

    Start SA L3 Call    ue_id=6    dl_tput=100kbps    ul_tput=100kbps
    Start SA L3 Call    ue_id=7    dl_tput=100kbps    ul_tput=100kbps
    Verify SA UE Traffic Using Bearer Stats    ue_id=3    dl_tput=100kbps    ul_tput=100kbps
    Stop SA L3 Call    ue_id=3
    Start SA L3 Call    ue_id=8    dl_tput=100kbps    ul_tput=100kbps
    Verify SA UE Traffic Using Bearer Stats    ue_id=4    dl_tput=100kbps    ul_tput=100kbps
    Stop SA L3 Call    ue_id=4
    Start SA L3 Call    ue_id=9    dl_tput=100kbps    ul_tput=100kbps
    Stop GNB L1L2 BIP Trace Collection

    ${sr_pools_counter_1}    Get Next XML PM Counters File

    Verify SA UE Traffic Using Bearer Stats    ue_id=6    dl_tput=100kbps    ul_tput=100kbps
    Verify SA UE Traffic Using Bearer Stats    ue_id=7    dl_tput=100kbps    ul_tput=100kbps
    Verify SA UE Traffic Using Bearer Stats    ue_id=8    dl_tput=100kbps    ul_tput=100kbps
    Verify SA UE Traffic Using Bearer Stats    ue_id=9    dl_tput=100kbps    ul_tput=100kbps

    Detach All UEs

    Verify SR_SLOT_POOL_AS_MAIN for pool 5 10 20 and 40 is correct
    ...    pm_counter_path=${sr_pools_counter_1}
    ...    localtime1=${localtime1}
    ...    localtime2=${localtime2}
    Verify that 3 UEs are being allocated with the SR period set to srPeriodicityMin equal to sl5
    Verify that 1 UEs are being allocated with the SR period set to srPeriodicityMin equal to sl20
    Verify that 3 UEs are being allocated with the SR period set to srPeriodicityMin equal to sl40

    [Teardown]    Test Case Teardown    oam_logs=yes    teardown_wts=yes    check_radio_res=yes
