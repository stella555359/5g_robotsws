*** Settings ***
Documentation
...   author: Adrian Jakobik, Adam Chamera
...   contact: adrian.jakobik@nokia.com, adam.chamera@nokia.com
...   This is the TESTSUITE file for feature CB008985


Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/keywords_8985.robot


Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline            AND
...              Initialise Attenuator

Test Setup       Run Keywords
...              Nullify attenuation on all ports                 AND
...              BTSLOG Start btslog on local machine

Test Teardown    Run Keywords
...              BTSLOG Collect btslog                            AND
...              Nullify attenuation on all ports


*** Test Cases ***
CB008985_A_02_FeatureActivationDeactivation
    [Documentation]   The purpose of this TC is to verify if the feature can be activated and deactivated.
    CB008985_A_02_FeatureActivationDeactivation

CB008985_A_06_SA_SingleUE_Attach_allSubcells_L3Call
    [Documentation]   The purpose of this TC is to verify if UE in SA mode get attach
    ...               and call can be performed in all sub-cells.
    CB008985_A_06_SA_SingleUE_Attach_allSubcells_L3Call

CB008985_A_07_SA_Subcell_Switch_failure_recovery
    [Documentation]   The purpose of this TC is to verify if UE can recover after subcell switch failure.
    CB008985_A_07_SA_Subcell_Switch_failure_recovery

CB008985_A_12_SA_VoNR_Call
    [Documentation]   The purpose of this TC is to verify if VoNR call can be performed in supercell.
    CB008985_A_12_SA_VoNR_Call

CB008985_B_04_HighSpeedCell_SA_VoNRCall_HSTCB
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell with
    ...               High Speed Cell Feature enabled and if VoNR call is possible to establish.
    [Setup]           Run Keywords
    ...               Nullify attenuation on all ports        AND
    ...               HighSpeed Cell Activation               AND
    ...               BTSLOG Start btslog on local machine
    CB008985_B_04_HighSpeedCell_SA_VoNRCall_HSTCB
    [Teardown]        Run Keywords
    ...               Nullify attenuation on all ports        AND
    ...               HighSpeed Cell Deactivation             AND
    ...               BTSLOG Collect btslog
