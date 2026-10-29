*** Settings ***
Force Tags      RAN_5G    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD_ORAN    STATE_CONFIGURED    SBTS00    CRT

Documentation
...             author:                 Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...             maintainer:             Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...
...             INTRODUCTION:   5GC002271
...             TEST SET NAME:  5GC002271-A-d Verify that prefferedVoNRSrPeriod is used during HO and validate correct reconfiguration
...             TESTING SPLIT:  See 5GC002271 testplan
...             CONTACTS:       OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
...             REFERENCES:     5GC002271 CFAM
...                             5GC002271 Test Plan
...

Resource        resources/5GC002271-keywords.robot
Library         ta5g_ue_mobility
Library         ta5g_throughput
Library         ta5g_pm_counters

Suite Setup      Run keywords
...              Configure UTE interfaces
...              Load gnb swconfig using ${CURDIR}/resources/swconfig_A_d_32.txt
...              Perform scf comissioning using ${CURDIR}/resources/scf-5GC002271-A-d_32.xml
...              Reach Onair In 3 Attempts using ${CURDIR}/resources/wts_config_a_d_tc32.cfg

*** Variables ***
${local_moid}    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

*** Test Cases ***
[1]5GC002271-A-d_32_Verify that prefferedVoNRSrPeriod is used during HO and reconfig after call is finished on FDD cell
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...   Verify that pool defined by prefferedVoNRSrPeriod is used for VoNR incoming handovers.
    ...   Default preferred VoNR pool on FDD cell. After 5QI-1 bearer release, reconfiguration is done to the shorter pool.
    ...
    ...  PRECONDITIONS:
    ...
    ...  pucchModeSelect = "longPucch"
    ...  actAdaptiveSr = TRUE
    ...  srPeriodicity = "slots80"
    ...  srPeriodicityMin = "slots20"
    ...  adaptiveSrLoadThresholdUp = 60 [percent]
    ...  adaptiveSrLoadThresholdDown = 40 [percent]
    ...  actVoNR = TRUE
    ...  actEnhancedVoNR = TRUE
    ...  preferredVoNrSrPeriod = "slots40"
    ...  vonrReservation = 0 (nothing is reserved for VoNR)
    ...  adaptiveSrBlockingMinimization = 0
    ...  lowLatencyReservation = 0
    ...  rdSrLoadThresholdFactor = 3 (adjust according to pool size)
    ...  rdSrReconfigurationsInterval = 50
    ...  rdSrReconfigurationsNumber = 10
    ...  rdSrLoadThresholdDownHysteresis = 10
    ...  miNrResourceUtilizationPerCell="5"(min)
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   ORAN RU OFGESA
    ...
    ...  REQUIRED LOGS:        Snapshot, RD.BTS log, CPRT log
    ...
    ...
    ...  CONTACTS:   OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
    ...  AUTHOR:     Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
    ...
    ...  REFERENCES:   5GC002271 CFAM
    ...

     Setup.Produce Scout Data
     pmcounter.Wait For Next Full Pm Interval
     ${timestamp0}     Set timestamp0 for proper counters counting
     Register ue3 and expect assignment to pool sl20
     Establish pdu session using ue-3
     ${timestamp1}     Set timestamp1 for proper counters counting
     Register ue4 and expect assignment to pool sl20
     Establish pdu session using ue-4
     sleep    3s     reason=Increase pmcounter value to extend margin of error
     ${timestamp2}     Set timestamp2 for proper counters counting
     Modify pdu session    ue_id=3    qos_to_add=2
     sleep    80s     reason=Increase pmcounter value to extend margin of error
     ${timestamp3}     Set timestamp3 for proper counters counting
     Modify pdu session    ue_id=4    qos_to_add=2
     sleep    2s     reason=Increase pmcounter value to extend margin of error
     Start vonr throughput for ue3
     Start vonr throughput for ue4
     ${timestamp4}     Set timestamp4 for proper counters counting
     Perform handover to simulated gnb for ue3
     ${timestamp5}     Set timestamp5 for proper counters counting
     Perform handover to simulated gnb for ue4
     sleep    3s     reason=Increase pmcounter value to extend margin of error
     ${timestamp6}     Set timestamp6 for proper counters counting
     Register ue5 and expect assignment to pool sl20
     Establish pdu session using ue-5

     ${timestamp7}     Set timestamp7 for proper counters counting
     Perform handover to real gnb for ue3 and expect assignment to pool sl40
     ${timestamp8}     Set timestamp8 for proper counters counting
     Perform handover to real gnb for ue4 and expect assignment to pool sl40
     sleep    3s     reason=Increase pmcounter value to extend margin of error
     ${timestamp9}     Set timestamp9 for proper counters counting
     Remove 5qi-1 bearer for ue3 and expect reconfiguration to pool sl20
     ${timestamp10}     Set timestamp10 for proper counters counting
     Remove 5qi-1 bearer for ue4 and expect reconfiguration to pool sl20
     sleep    3s     reason=Increase pmcounter value to extend margin of error
     ${timestamp11}     Set timestamp11 for proper counters counting
     Deregister ue    ue_id=3
     ${timestamp12}     Set timestamp12 for proper counters counting
     Deregister ue    ue_id=4
     ${timestamp13}     Set timestamp13 for proper counters counting
     Deregister ue    ue_id=5
     ${sr_pools_counter}    pmcounter.get_next_unpacked_full_pm_counters_file
     PM counters verification    pmcounters_path=${sr_pools_counter}
     Verify that SR Pools AS MAIN for slot 20 and 40 are correctly pegged     timestamp0=${timestamp0}    timestamp1=${timestamp1}
     ...     timestamp2=${timestamp2}     timestamp3=${timestamp3}     timestamp4=${timestamp4}     timestamp5=${timestamp5}
     ...     timestamp6=${timestamp6}     timestamp7=${timestamp7}     timestamp8=${timestamp8}     timestamp9=${timestamp9}
     ...     timestamp10=${timestamp10}     timestamp11=${timestamp11}     timestamp12=${timestamp12}     timestamp13=${timestamp13}
     ...     pm_counter_path=${sr_pools_counter}
