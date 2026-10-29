*** Settings ***
Documentation
...  author:        Piotr Szlegel
...  contact:       piotr.szlegel@nokia.com
...  maintainer:    piotr.szlegel@nokia.com
...  description:   Test Cases for 5GC002052 feature: The user scenario intends to validate the EIRP control reducing
...                 the PDSCH frequency domain allocation to respect the EIRP threshold to a cell configured
...                 with a sector beam and passive external antennas connected to RU.

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002300/resources/keywordsC.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.robot


*** Variables ***
${timer_2052}                31 min


*** Keywords ***
[1]5GC002052-E_02_EIRP_control_no_FDM_PRF_-6dB_sliding_window_5min_20B_MP/21A
     [Documentation]
     ...     Description: The user scenario intends to validate the EIRP control reducing the
     ...     PDSCH frequency domain allocation to respect the EIRP threshold to a cell configured
     ...     with a sector beam and passive external antennas connected to RU

     Log to console      __Perforom delta commissioning
     Perform commissioning 5GC002300H for 20B_MP/21A
    ...                  actEirpControl=true
    ...                  pMax=448
    ...                  ssPbchBlockPower=15
    ...                  chBwDl=15MHz
    ...                  chBwUl=15MHz
    ...                  miNrEirp=5min
    ...                  ssBurstSetPeriod=20
    ...                  csirsTrackingPeriod=20ms
    ...                  eirpControlTimeAveragingWindow=5
    ...                  eirpControlPowerReductionFactorList=-60
    ...                  actFdmScheduling=true
    ...                  actFdmEnhancedScheduling=true
    ...                  targetTotalLoad=100
    ...                  type0CoresetConfigurationIndex=6
    ...                  minGuaranteedBudgetRatio=50
    ...                  eirpControlTimeAveragingWindowStepSize=100

    Wait for counters    ${timer_2052}
    Collect counters
    @{counters}  Create list  M55324C00000  M55324C00400  M55324C00301  M55308C00001  M55308C00007
    Get pm counters values  @{counters}
    Check M55324C00301/3000=32   bottom=0   top=80
    Check M55324C00400/M55324C00000[dBm]   44.8
    Check M55308C00001=M55308C00007

[1]5GC002052-E_02_EIRP_control_no_FDM_PRF_-6dB_sliding_window_5min_21B/trunk
     [Documentation]
     ...     Description: The user scenario intends to validate the EIRP control reducing the
     ...     PDSCH frequency domain allocation to respect the EIRP threshold to a cell configured
     ...     with a sector beam and passive external antennas connected to RU

     Log to console      __Perforom delta commissioning
     Perform commissioning 5GC002300H for 21B/trunk
    ...                  actEirpControl=true
    ...                  pMax=448
    ...                  ssPbchBlockPower=15
    ...                  chBwDl=15MHz
    ...                  chBwUl=15MHz
    ...                  miNrEirp=5min
    ...                  ssBurstSetPeriod=20
    ...                  csirsTrackingPeriod=20ms
    ...                  eirpControlTimeAveragingWindow=5
    ...                  eirpControlPowerReductionFactorList=-60
    ...                  actFdmScheduling=true
    ...                  actFdmEnhancedScheduling=true
    ...                  targetTotalLoad=100
    ...                  type0CoresetConfigurationIndex=6
    ...                  minGuaranteedBudgetRatio=50
    ...                  eirpControlTimeAveragingWindowStepSize=100

    Wait for counters    ${timer_2052}
    Collect counters
    @{counters}  Create list  M55324C00000  M55324C00400  M55324C00301  M55308C00001  M55308C00007
    Get pm counters values  @{counters}
    Check M55324C00301/3000=32   bottom=0   top=80
    Check M55324C00400/M55324C00000[dBm]   44.8
    Check M55308C00001=M55308C00007
