*** Settings ***

Documentation    Script for CB012087_Airphone_NR+LTE_OFEGSA
...   author: Naresh.S@nokia.com
...   Description: CB012087 4G and 5G Cell Locking based on Timer of Day and Voltage 25R3-SR
...   Exe cmd:robot  --outputdir /home/ute/results -L TRACE -b debug.log -d ~/logs/CB012087_$(date +%y%m%d) CB012087.robot


Resource          CB012087_resource.robot

Suite setup        Suite Setup
Suite Teardown     Suite Teardown

*** Variables ***
${a}=    4
*** Test Cases ***

CB012087_B_Verification of Scheduled 5G and 4G Cell Switch Off and Switch ON Based on Low Voltage interacting with ORU sleep state using WebEM

    [Tags]    VRF_BLR1    VRF_ORAN    QC_252475    CRT
    [Documentation]
    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw
    ...    cell1    FDD    n1    20    16385    20MHz
    ${out}    set variable
    ...    ${SUITE_PATH}CB012087TESTSUITE/CB012087_Energysaving_Feature_Based_on_Low_Voltage/
    set test variable    ${out}
    create directory     ${out}
	L3 Call
    SA 5G Detach
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    ADMIN Assert BTS is onAir    timeout=900
	sleep    60s
    Log to console    \n--delete NRFSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS NR
    Log to console    \n--delete FSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS LTE
    Log to console    \n--Create NRFSOPGRP--\n
    Configure the Energysaving parameters based on the low voltage for NR
    Log to console    \n--Create FSOPGRP--\n
    Configure the Energysaving parameters based on the low voltage for LTE
    Log to console    \n--Configured the CB012087 parameters --\n
    Feature_Enable_Disable_CB012087     ${distname3}    ${parameter3}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname1}    ${parameter1}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname2}    ${parameter1}    ${epevalue1}
	Feature_Enable_Disable_CB012087     ${distname1}    ${parameter1}    ${epevalue1}
	Feature_Enable_Disable_CB012087     ${distname5}    ${parameter4}    ${epevalue1}
	Feature_Enable_Disable_CB012087     ${distname6}    ${parameter4}    ${epevalue1}
	Feature_Enable_Disable_CB012087     ${distname11}    ${parameter10}    ${epevalue9}
    Feature_Enable_Disable_CB012087     ${distname12}    ${parameter11}     ${epevalue12}
    sleep    10s
    Log to console    \n--NRCELL Energysaving status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[0]
    Log to console    \n--FSOPGRP Energysaving state --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[0]
    Log to console    \n--OFEGSA Radio Energysaving update --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate   ${ORUState}[0]
    sleep    300s
	Update the Energysaving parameters based on the low voltage NR
    sleep    30s
    Update the Energysaving parameters based on the low voltage LTE
    sleep    10s
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[1]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[1]
    Log to console    \n--OFEGSA Radio notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate    ${ORUState}[1]
    sleep    60s
    L3 Call
    SA 5G Detach

CB012087_A_Verification of Scheduled 5G and 4G Cell Switch Off and Switch ON Based on Time of Day interacting with ORU sleep state using WebEM
    ${out}    set variable
    ...    ${SUITE_PATH}CB012087TESTSUITE/CB012087_Energysaving_Feature_Based_on_Time_of_Day/
    set test variable    ${out}
    create directory     ${out}
    Log to console    \n--delete NRFSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS NR
    Log to console    \n--delete FSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS LTE

    Log to console    \n--Create NRFSOPGRP--\n
    Configure the Energysaving parameters based on time of day NR
    Log to console    \n--Create FSOPGRP--\n
    Configure the Energysaving parameters based on time of day LTE
    Feature_Enable_Disable_CB012087     ${distname1}    ${parameter1}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname2}    ${parameter1}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname5}    ${parameter4}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname3}    ${parameter3}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname11}    ${parameter10}    ${epevalue9}
    Feature_Enable_Disable_CB012087     ${distname12}    ${parameter11}    ${epevalue12}
    sleep     100s
    Log to console    \n--NRCELL Energysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[0]
    Log to console    \n--LNCELL Energysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[0]
    Log to console    \n--OFEGSA Energysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate        ${ORUState}[0]
    sleep     900s
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[1]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[1]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate        ${ORUState}[1]
    Counter Verification NR
	Counter Verification LTE
	EPE counters collection and validation
    L3 Call
    SA 5G Detach

	Log   Robustness test steps

	Log to console    \n--delete NRFSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS NR
    Log to console    \n--delete FSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS LTE

    Log to console    \n--Create NRFSOPGRP--\n
    Configure the Energysaving parameters based on time of day NR
    Log to console    \n--Create FSOPGRP--\n
    Configure the Energysaving parameters based on time of day LTE
    sleep     60s
    Log to console    \n--NRCELL Energysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[0]
    Log to console    \n--LNCELL Energysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[0]
    Log to console    \n--OFEGSA Energysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate    ${ORUState}[0]

    Feature_Enable_Disable_CB012087     ${distname1}    ${parameter1}    ${epevalue11}
    Feature_Enable_Disable_CB012087     ${distname2}    ${parameter1}    ${epevalue11}
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s      Check Energy saving State NR     ${CellState_NR}[1]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State LTE    ${CellState_NR}[1]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check RU Powerstate       ${ORUState}[1]
    L3 Call
    SA 5G Detach

    Log to console    \n--delete NRFSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS NR
    Log to console    \n--delete FSOPGRP--\n
    Run Keyword And Ignore Error    Delete the objective from the BTS LTE
    Log to console    \n--Create NRFSOPGRP--\n
    Configure the Energysaving parameters based on time of day NR_Exp
    Log to console    \n--Create FSOPGRP--\n
    Configure the Energysaving parameters based on time of day LTE_Exp
    Feature_Enable_Disable_CB012087     ${distname1}    ${parameter1}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname2}    ${parameter1}    ${epevalue1}
    Feature_Enable_Disable_CB012087     ${distname5}    ${parameter4}    ${epevalue1}
    sleep     80s
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State NR     ${CellState_NR}[0]
    Log to console    \n--LNCELL Energysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State LTE    ${CellState_NR}[0]
    Log to console    \n--OFEGSA Energysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check RU Powerstate       ${ORUState}[0]

    E2E RMOD Reset
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[1]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[1]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate   ${ORUState}[1]
	ADMIN Assert All NRCells Are In Enabled State
    sleep    10s
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[2]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[2]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    sleep    120s
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate     ${ORUState}[0]

    E2E Cell block and unblock
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s     Check Energy saving State NR     ${CellState_NR}[2]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check Energy saving State LTE    ${CellState_NR}[2]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s     Check RU Powerstate        ${ORUState}[1]
    ADMIN Assert All NRCells Are In Enabled State
    sleep    60s
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s      Check Energy saving State NR     ${CellState_NR}[0]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State LTE    ${CellState_NR}[0]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check RU Powerstate       ${ORUState}[0]

    E2E radio lock and unlock
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s      Check Energy saving State NR     ${CellState_NR}[2]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State LTE    ${CellState_NR}[2]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check RU Powerstate        ${ORUState}[1]
    ADMIN Assert All NRCells Are In Enabled State
    sleep    60s
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s      Check Energy saving State NR     ${CellState_NR}[0]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State LTE    ${CellState_NR}[0]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check RU Powerstate        ${ORUState}[0]
    Feature_Enable_Disable_CB012087     ${distname1}    ${parameter1}    ${epevalue11}
    Feature_Enable_Disable_CB012087     ${distname2}    ${parameter1}    ${epevalue11}
    sleep     30s
    Log to console    \n--NRCELL notEnergysacing status --\n
	Wait Until Keyword Succeeds    15min    10s      Check Energy saving State NR     ${CellState_NR}[1]
    Log to console    \n--LNCELL notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check Energy saving State LTE    ${CellState_NR}[1]
    Log to console    \n--OFEGSA notEnergysacing status --\n
    Wait Until Keyword Succeeds    15min    10s      Check RU Powerstate       ${ORUState}[1]


***Keywords***
Check Cells are ON-Air
    ADMIN Assert All NRCells Are In Enabled State    timeout=900
    ADMIN Assert BTS is onAir    timeout=900
    Log to console    \n--Test Completed--\n
