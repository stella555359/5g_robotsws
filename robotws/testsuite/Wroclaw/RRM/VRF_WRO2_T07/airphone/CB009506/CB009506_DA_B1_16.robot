*** Settings ***
Force Tags    RAN_5G    RAN_5G_FDD    PY310    CONFIGURED    CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00    SBTS23R4    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Piotr Bebel
...                        Krzysztof Brykman
...                        Malgorzata Grajzer-Szmajda
...              :contact: piotr.bebel@nokia.com
...                        krzysztof.brykman@nokia.com
...                        malgorzata.grajzer-szmajda@nokia.com

Resource    CB009506_Keywords_And_Variables.robot

Suite Setup      Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...              AND             Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/new_iphy.xml
...              AND             Get Scfc File    output_filepath=${CURDIR}/config/backup/initial_commissioning.xml
...              AND             Update Iphy Configuration And Modify Swconfig
...                              iphy_xml_filepath=${CURDIR}/config/iphy_CB009506_DA_B1_16.xml
...              AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB009506_DA_B1_16.json
...              AND             Trigger Site Reset
...              AND             Check Radios Availability
...              AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB009506_DA_B1_16.lua
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown   Run Keywords    Roll Delta Back
...                              initial_scf_filename=${CURDIR}/config/backup/initial_commissioning.xml
...                              delta_scf_filename=delta_CB009506_DA_B1_16.json
...              AND             Update Iphy Configuration And Modify Swconfig
...                              iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
...              AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
CB009506_DA_B1_16_Robustness_For_Band_N13_Bandwidth_5_MHz
    [Documentation]    This testsuite performs robustness testing for an attach of 20 UEs for NR cell FR1-FDD bandwidth
    ...                5Mhz with DL/UL traffic supported in n13 band and Scs equal to 15 kHz
    ...                (CB009506-DA-B1 requirement 5G_RAN_USR_RRM_20094).
    ${UEs_list}=    Init UEs List
    Attach UE And Establish PDU Session For Multiple UEs With Traffic    ${UEs_list}
    Wait For Throughput
    Expected Throughput For List Of UEs Should Be Reached    ues_list=${UEs_list}    throughput=1
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For List Of UEs Should Be Reached    ues_list=${UEs_list}    throughput=1
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15
    Release PDU Session For Multiple UEs     ${UEs_list}
    Deregister Multiple UEs     ${UEs_list}
