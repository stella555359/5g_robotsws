*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB010802: Deep Sleep Mode Support for RF6.1 TDD RRH

Resource            CommonKeywords.robot


*** Keywords ***
CB010802 Setup
    Log To Console    CB010802 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

# 10802 TC_01

RU enters deep sleep mode
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_10802}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Get RMOD value of AZQO (like ${RMODX})
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AZQO

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${energy_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${gnb_mrbts}/${RMODX}/SBTS_RFM_Energy_Monitoring
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/SBTS_RFM_Energy_Monitoring

    ${param1}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/PMMNL-1    mtSBTSRfmEnergyMonitoring    15min
    ${param2}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actPowerMeter    true
    ${params}=    Create List    ${param1}    ${param2}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # STEP 1

    # We need to wait for a new full counter period
    Sleep    30 minutes

    ${RU_power_normal}=    COAM Get PM counter    ${bts_addr}    BTS    ${energy_counter_path}    M40003C2

    Log To Console    RU consumption not in sleep mode:
    Log To Console    ${RU_power_normal}

    # STEP 2

    ${param1}=    Create List    ${gnb_mrbts}/${gnb_nrbts}    actNrLBPowerSaving    true

    # NRPGRP object update
    &{cell_1}=    Create Dictionary
    ...    nrCellId=${TDDCELL_1}    lbpsCellSOOrder=100    lbpsUseExtConfig=false
    &{cell_2}=    Create Dictionary
    ...    nrCellId=${TDDCELL_2}    lbpsCellSOOrder=100    lbpsUseExtConfig=false
    ${cell_list}=    create list    ${cell_1}    ${cell_2}
    ${mon}=    Create Dictionary
    ...    lbpsDayOfWeek=Mon
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${tue}=    Create Dictionary
    ...    lbpsDayOfWeek=Tue
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${wed}=    Create Dictionary
    ...    lbpsDayOfWeek=Wed
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${thu}=    Create Dictionary
    ...    lbpsDayOfWeek=Thu
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${fri}=    Create Dictionary
    ...    lbpsDayOfWeek=Fri
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${sat}=    Create Dictionary
    ...    lbpsDayOfWeek=Sat
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${sun}=    Create Dictionary
    ...    lbpsDayOfWeek=Sun
    ...    lbpsDuration=1440
    ...    lbpsStartTimeHour=0
    ...    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended
    ${lbpsPeriodList}=    create list    ${mon}    ${tue}    ${wed}    ${thu}    ${fri}    ${sat}    ${sun}
    ${param2}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/NRPGRP-1    lbpsCellList    ${cell_list}
    ${param3}=    Create List    ${gnb_mrbts}/${gnb_nrbts}/NRPGRP-1    lbpsPeriodList    ${lbpsPeriodList}
    ${params}=    Create List    ${param1}    ${param2}    ${param3}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir without restart
    Wait Until Keyword Succeeds    5 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # STEP 3
    ${nb_of_energy_saving_cell}=    Get Number Of energySaving Cells    ${bts_addr}
    # NR cells are not yet in energy saving mode
    Should be Equal As Integers    ${nb_of_energy_saving_cell}    0

    ${AZQO_powerState}=    Get AZQO PowerState    ${bts_addr}
    # RU is nt yet in SLEEP mode
    Should Not Be Equal    ${AZQO_powerState}    SLEEP

    # STEP 4

    # Just now cells are not yet in energySaving state
    ${nb_of_energy_saving_cell}=    Get Number Of energySaving Cells    ${bts_addr}
    Should be Equal As Integers    ${nb_of_energy_saving_cell}    0
    ${AZQO_powerState}=    Get AZQO PowerState    ${bts_addr}
    Should Not Be Equal    ${AZQO_powerState}    SLEEP

    Sleep    5 minutes

    # After 5 minutes cells are in energySaving state but RU is not in SLEEP mode
    ${nb_of_energy_saving_cell}=    Get Number Of energySaving Cells    ${bts_addr}
    Should be Equal As Integers    ${nb_of_energy_saving_cell}    2
    ${AZQO_powerState}=    Get AZQO PowerState    ${bts_addr}
    Should Not Be Equal    ${AZQO_powerState}    SLEEP

    # We need to wait for a new full counter period
    Sleep    30 minutes

    # Get energy counter with Cell in energySaving state and RU in normal mode
    ${RU_power_energysaving}=    COAM Get PM counter    ${bts_addr}    BTS    ${energy_counter_path}    M40003C2

    # Activate the deep sleep mode for RU
    ${param}=    Create List    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}    energySavingMode    DEEPSLEEP
    ${params}=    Create List    ${param}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    Sleep    10 minutes

    # After 10 minutes cells are in energySaving state and RU is in SLEEP mode
    ${nb_of_energy_saving_cell}=    Get Number Of energySaving Cells    ${bts_addr}
    Should be Equal As Integers    ${nb_of_energy_saving_cell}    2
    ${AZQO_powerState}=    Get AZQO PowerState    ${bts_addr}
    Should Be Equal    ${AZQO_powerState}    SLEEP

    # STEP 5

    # We need to wait for a new full counter period
    Sleep    30 minutes

    ${RU_power_sleep}=    COAM Get PM counter    ${bts_addr}    BTS    ${energy_counter_path}    M40003C2

    Log To Console    RU consumption in sleep mode:
    Log To Console    ${RU_power_sleep}

    ${RU_power_normal}=    Convert To Number    ${RU_power_normal}
    ${RU_power_energysaving}=    Convert To Number    ${RU_power_energysaving}
    ${RU_power_sleep}=    Convert To Number    ${RU_power_sleep}

    ${energySaving_success}=    Evaluate    ${RU_power_sleep}/${RU_power_normal} < 0.75
    Should be True    ${energySaving_success}

    ${energySaving_success}=    Evaluate    ${RU_power_sleep}/${RU_power_energysaving} < 1
    Should be True    ${energySaving_success}

Test Debug
    ${a}=    Set Variable    3800
    ${b}=    Set Variable    4000
    ${a}=    Convert To Number    ${a}
    ${b}=    Convert To Number    ${b}

    ${status}=    Evaluate    ${a}/${b} < 0.75

    Should be True    ${status}
