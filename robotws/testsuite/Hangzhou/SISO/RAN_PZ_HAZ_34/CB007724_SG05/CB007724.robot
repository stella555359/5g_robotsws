*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ../common/siso_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

Documentation
...    Author:yue liu
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature SRAN in 22R4 program

*** Variables ***

*** Test Cases ***

[1]CB007724_5G_A_02_preparation_BSR_for_external_antenna_Scorpio_from_WebUI_with_MRI_files_as_input
    [Tags]    CRT_TRUNK
    "Step1" Enable feature 1866
    Generate_BSR_Package_with_MRI
[1]CB007724_5G_A_01_preparation_BSR_for_external_antenna_Scorpio_from_WebUI_without_MRI_files_as_input
    [Tags]    CRT_TRUNK
    "Step1" Enable feature 1866
    Generate_BSR_Package_without_MRI
*** Keywords ***
Generate_BSR_Package_with_MRI
    Run   rm -rf /tmp/*BSR*
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=ASIK Master
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}   download_dir=/tmp
    ${BSR_file_path}=    selenium_coam.generate_bsr_package
    ...    sw_file=/home/ute/TA/BSR/AZQJ-475244A_BFWeights_2.zip
    ...    ru_variant=AZQJ    bsr_id=1
    ...    custom_beam_name=AZQJ_beamset6
    Should not be empty    ${BSR_file_path}
    @{result}    string.split string    ${BSR_file_path}    separator=/
    ${BSR_File}    convert to string     ${result}[2]
    @{result2}    string.split string    ${BSR_File}    separator=.
    ${BSR_File_Name}    convert to string     ${result2}[0]
    sleep    5s
    selenium_coam.load_software_package_from_local_drive    file_path=${BSR_file_path}
    sleep    5s
    selenium_coam.software_update    is_activate=${True}
    sleep    5s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
    sleep    2s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=Basic Beam Set   new_value=beamSet_1
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=External antenna type   new_value=4_column_0_7_lambda
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...   filter_param=Custom Beam Set Name   new_value=${BSR_File_Name}
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=6 beams
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}    timeout=${300}
    sleep    5s
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run   rm -rf ${BSR_file_path}
    #${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    #...  filter_param=Beam set installed    node_index=${1}
    #Should Be Equal    ${beamSetInstall}    ${BSR_File_Name}	
    Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-1    beamSetName=${BSR_File_Name}
    [Teardown]  Run Keyword And Ignore Error    Selenium Logout And Close Browser
Check Used Beamset
    [Arguments]    ${cellName}    ${beamSetName}
    Run Keyword And Ignore Error    selenium_coam.refresh_page
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${beamSetInused}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/${cellName}
    ...   filter_param=Beam Set in Use
    Should Be Equal    ${beamSetInused}    ${beamSetName}
    Run Keyword And Ignore Error    COAM Teardown gnb connections
"${Step}" Enable feature 1866
    Log To Console    "${Step}" Enable feature 1866
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=ASIK Master
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}   download_dir=/tmp
    ${status}    Run Keyword And Return Status    selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...   filter_param=Activate Beamforming   new_value=true
    Run Keyword If    ${status}==${False}    Run Keywords    selenium_coam.refresh_page    AND
    ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...    filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}    timeout=${300}
    [Teardown]  Run Keyword And Ignore Error    Selenium Logout And Close Browser
Generate_BSR_Package_without_MRI
    Run   rm -rf /tmp/*BSR*
    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
    Run Keyword And Ignore Error    ssh.Disconnect    connection=ASIK Master
    Selenium Login And Disable Screen Lock    version=${SBTS_verion}    download_dir=/tmp
    ${BSR_file_path}=    selenium_coam.generate_bsr_package
    ...    sw_file=/home/ute/TA/BSR/Nokia8trRadioExtAntPanel_WeightsTemplate_final_beamset_4_90_4_column_0_7_lambda.zip
    ...    ru_variant=AZQJ    bsr_id=1
    ...    custom_beam_name=AZQJ_beamset2
    Should not be empty    ${BSR_file_path}
    @{result}    string.split string    ${BSR_file_path}    separator=/
    ${BSR_File}    convert to string     ${result}[2]
    @{result2}    string.split string    ${BSR_File}    separator=.
    ${BSR_File_Name}    convert to string     ${result2}[0]
    sleep    5s
    selenium_coam.load_software_package_from_local_drive    file_path=${BSR_file_path}
    sleep    5s
    selenium_coam.software_update    is_activate=${True}
    sleep    5s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=Activate Beamforming   new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    ...  filter_param=Activate custom beam set realization    new_value=true
    sleep    2s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=Basic Beam Set   new_value=beamSet_1
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=External antenna type   new_value=Commscope_2to5deg
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...   filter_param=Custom Beam Set Name   new_value=${BSR_File_Name}
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks   new_value=4 beams
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}    timeout=${300}
    sleep    5s
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run   rm -rf ${BSR_file_path}
    #${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    #...  filter_param=Beam set installed    node_index=${1}
    #Should Be Equal    ${beamSetInstall}    ${BSR_File_Name}
    Wait Until Keyword Succeeds    5min    1min    Check Used Beamset    cellName=NRCELL-1    beamSetName=${BSR_File_Name}
    [Teardown]  Run Keyword And Ignore Error    Selenium Logout And Close Browser
