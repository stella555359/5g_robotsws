*** Settings ***
Documentation    This file contains 5GC000511 feature keywords

Library           OperatingSystem
Library           ute_wtssim
Library           XML
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/airphone.robot
Resource          ./5GC000511_ConfigManagement_Admin.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Resource          ../Resources/Common_Keywords.robot

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC000511
    Load Inuput Yaml File
    Wait for gNB To Be Ready
    Store Original Prach Parameters in GNB For Revert

Suite Teardown
    Common Suite Teardown Keywords
    Revert Prach Parameter in GNB to original Value
    Reboot GNB and Airphone
    Check GNB Status before WTS Start

Store Original Prach Parameters in GNB For Revert
    ${prach_params_original_values}=    Get List of Prach Parameters From gNB
    Set Suite Variable    ${prach_params_original_values}

Revert Prach Parameter in GNB to original Value
    Update Original Prach Params in gNB    ${prach_params_original_values}

Update PRACH params in WTS xml
    [Arguments]    ${msgFreq}=0    ${RootIndex}=20    ${z}=13    ${preamblesPerSsb}=n64    ${powerRampingStep}=dB2
    ...    ${preambleMax}=n10    ${contention}=sf64    ${ssbThreshold}=11    ${power}=-118
    [Documentation]    Set PRACH configurable parameters in WTS .xml file
    ${cfg_file}    XML.Parse Xml    ${AP_XML_PATH}
    Set Element Text    source=${cfg_file}    text=${msgFreq}    xpath=rachConfigConfig/rachConfig/msg1FrequencyStart
    Set Element Text    source=${cfg_file}    text=${RootIndex}    xpath=rachConfigConfig/rachConfig/firstPrachRootSeqIndex
    Set Element Text    source=${cfg_file}    text=${z}    xpath=rachConfigConfig/rachConfig/prachZeroCorrelationZoneConfig
    Set Element Text    source=${cfg_file}    text=${preamblesPerSsb}    xpath=rachConfigConfig/rachConfig/cbPreamblesPerSsb
    Set Element Text    source=${cfg_file}    text=${powerRampingStep}    xpath=rachConfigConfig/rachConfig/powerRampingStep
    Set Element Text    source=${cfg_file}    text=${preambleMax}    xpath=rachConfigConfig/rachConfig/prachPreambleTransMax
    Set Element Text    source=${cfg_file}    text=${contention}    xpath=rachConfigConfig/rachConfig/macContentionResTimer
    Set Element Text    source=${cfg_file}    text=${ssbThreshold}    xpath=rachConfigConfig/rachConfig/ssbThreshold
    Set Element Text    source=${cfg_file}    text=${power}    xpath=rachConfigConfig/rachConfig/preambleReceivedTargetPower
    Save XML    source=${cfg_file}    path=${AP_XML_PATH}

CleanUp
    Run Keyword and Ignore Error    UE Detach   ${UE_ID}
    Stop Sim
    ute_wtssim.Teardown All Aliases For Wts
