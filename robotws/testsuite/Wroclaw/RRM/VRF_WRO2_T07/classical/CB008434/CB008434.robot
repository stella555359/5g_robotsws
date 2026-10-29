*** Settings ***
Documentation
...   author: Adrian Jakobik, Adam Chamera
...   contact: adrian.jakobik@nokia.com, adam.chamera@nokia.com
...   This is the TESTSUITE file for feature CB008434


Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008434/resources/keywords_8434.robot


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
CB008434_A_01_SuperCellSetup_HalfABIO_1x3subcells_AZHM
    [Documentation]   The purpose of this TC is to check if one NR FR1 TDD super cell (up to 3 subcells)
    ...               can be set up for Half ABIO configuration.
    CB008434_A_01_SuperCellSetup_HalfABIO_1x3subcells_AZHM

CB008434_B_01_SuperCellSetup_FullABIO_6Subcells_AZHM
    [Documentation]   The purpose of this TC is to check if one NR FR1 TDD super cell
    ...               (up to 6 subcells) can be set up for Full ABIO configuration.
    CB008434_B_01_SuperCellSetup_FullABIO_6Subcells_AZHM


