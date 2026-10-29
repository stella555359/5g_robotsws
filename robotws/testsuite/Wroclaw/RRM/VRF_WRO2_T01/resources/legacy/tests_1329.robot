*** Settings ***
Documentation
...  author:        Marcin Skop
...  contact:       marcin.skop@nokia.com
...  maintainer:    marcin.skop@nokia.com
...  Description:   Test Cases for 5GC001329A/D feature: Sector beam EIRP monitoring on common channels in cmW
...                 The feature allows the operator to measure and control the equivalent isotropic radiated power
...                 (EIRP) over the cell. It is allowed to define a segment grid considering the local environment
...                 constraints of the cell. In each of the defined cell segment the EIRP is approximated based on
...                 the allocated power per scheduled beam. For FDD mode no beamforming is considered.

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/tests_1329.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot


*** Variables ***
${timer_1329}            17 min
@{counters_1329}         M55324C00000  M55324C00400


*** Keywords ***
[1]5GC001329-A_01_EIRP_pmax_min-sspbchpower_min-bw_min-csi-ssb_max
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=370
    ...             ssPbchBlockPower=15
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_01_EIRP_pmax_min-sspbchpower_min-bw_min-csi-ssb_max Trunk
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329 Trunk
    ...             actEirpControl=true
    ...             pMax=370
    ...             ssPbchBlockPower=15
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_02_EIRP_pmax_max-sspbchpower_max-bw_min-csi-ssb_max
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=470
    ...             ssPbchBlockPower=19
    ...             chBwDl=10MHz
    ...             chBwUl=10MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_03_EIRP_pmax_min-sspbchpower_min-bw_max-csi-ssb_min
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=370
    ...             ssPbchBlockPower=4
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=10
    ...             csirsTrackingPeriod=20ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_04_EIRP_pmax_min-sspbchpower_min-bw_max-csi-ssb_max
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=370
    ...             ssPbchBlockPower=4
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_05_EIRP_pmax_max-sspbchpower_max-bw_max-csi-ssb_min
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=448
    ...             ssPbchBlockPower=15
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=20ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_06_EIRP_pmax_max-sspbchpower_max-bw_max-csi-ssb_max
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=470
    ...             ssPbchBlockPower=17
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=10
    ...             csirsTrackingPeriod=20ms
    ...             rbAllocation=BWP
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}


[1]5GC001329-A_07_EIRP_Act_Snapshot_DeAct
    [Documentation]
    ...     Description: Test Case for 5GC001329A subfeature.

    Perform commissioning 1329     # feature disabled
    ...             actEirpControl=false
    ...             pMax=470
    ...             ssPbchBlockPower=17
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Wait for counters  6 min
    Collect counters
    Check if eirp counter value equals zero
    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=470
    ...             ssPbchBlockPower=17
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Wait for counters  6 min
    Collect counters
    Check if eirp counter value equals zero
    Lock nrcell
    Unlock nrcell
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}
    Collect snapshot
    Lock nrcell
    Perform commissioning 1329
    ...             cells_on_air_verification=${FALSE}
    ...             actEirpControl=false
    ...             pMax=470
    ...             ssPbchBlockPower=17
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    Sleep  6 min
    Unlock nrcell
    Wait for counters  6 min
    Collect counters
    Check if eirp counter value equals zero


[1]5GC001329-D_01_EIRP_csi-ssb-max_cce-min
    [Documentation]
    ...     Description: Test Case for 5GC001329D subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=448
    ...             ssPbchBlockPower=15
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    ...             targetTotalLoad=100
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}

[1]5GC001329-D_01_EIRP_csi-ssb-min_cce-min
    [Documentation]
    ...     Description: Test Case for 5GC001329D subfeature.

    Perform commissioning 1329
    ...             actEirpControl=true
    ...             pMax=448
    ...             ssPbchBlockPower=15
    ...             chBwDl=15MHz
    ...             chBwUl=15MHz
    ...             type0CoresetConfigurationIndex=6
    ...             ssBurstSetPeriod=20
    ...             csirsTrackingPeriod=80ms
    ...             rbAllocation=BWP
    ...             targetTotalLoad=100
    Wait for counters  ${timer_1329}
    Collect counters
    Check if pm counter EIRP cell power has incremented  @{counters_1329}
