*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__RMOD_Beamforming_Calibration_Check.robot

*** Test Cases ***
[1]NRL__STATE__RMOD_Beamforming_Calibration_Check
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__RMOD_Beamforming_Calibration_Check
