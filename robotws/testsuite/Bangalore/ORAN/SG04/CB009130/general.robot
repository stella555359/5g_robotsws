*** Settings ***
Documentation
...    Author: karthik.j@nokia.com
...    Maintainer:
...    Test Description: Test cases to configure multiple bands and carriers with O-RAN compliant LTE Radio Unit
...    Confluence link: link
...    Group in charge:
...    References:
...    QualityCenter:
...    Sample execution:  robot -v CONFIGURATION:$(cat /proc/sys/kernel/hostname |sed 's/-/_/g') -V
...              /home/ute/testline_configuration/$(cat /proc/sys/kernel/hostname |sed 's/-/_/g')/__init__.py
...          -L TRACE -b debug.log -d/home/ute/logs/ /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/general.robot
...    AC/REQ:

Resource    ./resources/CB009130-A_BOAM_ET.robot

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions

Test Setup        Run Keywords    CB009130-A Test Preconditions
                  ...     AND     ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}

Test Teardown     Run Keywords    CB009130-A_BOAM_ET.Test Postconditions
                  ...     AND     QC_Update

*** Variables ***

${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          False
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           False

*** Test Cases ***
[1][3.0]_TC_01_O-RU_capability_to_support_LTE_cells_frequency
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
    CB009130-A-TC_01_O-RU_capability_to_support_LTE_cells_frequency

[1][3.0]_TC_03_O-RU_capability_to_support_LTE_cells_bandwidth
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
    CB009130-A-TC_03_O-RU_capability_to_support_LTE_cells_bandwidth

[1][3.0]_TC_04_O-RU_capability_to_support_LTE_cell_power_of_the_single_cell_carrier
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
  CB009130-A-TC_04_O-RU_capability_to_support_cell_power_of_the_single_cell_carrier
   
[1][3.0]_TC_02_O-RU_capability_to_support_LTE_cells_using_the_same_TX_array
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
    CB009130-A-TC_02_O-RU_capability_to_support_LTE_cells_using_the_same_TX_array

[1][3.0]_TC_05_O-RU_capability_to_support_LTE_cell_total_gain_of_all_cell_carriers
   [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
   CB009130-A-TC_05_O-RU_capability_to_support_LTE_cell_total_gain_of_all_cell_carriers
