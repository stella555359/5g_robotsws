*** Settings ***
Documentation
...    Author: Pavan.3.kumar@nokia.com
...    Test Description: Test cases to configure multiple bands and carriers with O-RAN compliant 5G Radio Unit
...    Confluence link: link
...    Group in charge:
...    References:
...    QualityCenter:
...    Sample execution:  robot -v CONFIGURATION:$(cat /proc/sys/kernel/hostname |sed 's/-/_/g') -V
...                 /home/ute/testline_configuration/$(cat /proc/sys/kernel/hostname |sed 's/-/_/g')/__init__.py
...                 -L TRACE -b debug.log -d/home/ute/logs/
...                 /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG04/CB009130/general.robot
...    AC/REQ:

Resource    ./resources/CB009130-B_BOAM_ET_TC1.robot
Resource    ./resources/CB009130-B_BOAM_ET_TC2.robot
Resource    ./resources/CB009130-B_BOAM_ET_TC3.robot
Resource    ./resources/CB009130-B_BOAM_ET_TC4.robot
Resource    ./resources/CB009130-B_BOAM_ET_TC5.robot

Library    BuiltIn
Library    ute_fsmaccess
Library    SeleniumLibrary
Library    Process
Library    DateTime
Library    Collections
Library    FtpLibrary
Library    OperatingSystem
Library    Screenshot
Library    String
Library    Telnet
Library    taf.sbts.oam.coam.admin
Library    taf.config.scf   WITH NAME  scf
Library    taf.sw.scout    WITH NAME    scout

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Run Keywords            CB009130-B Test Preconditions
				          ...     AND    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}

Test Teardown     Run Keywords    CB009130-B_BOAM_ET_TC1.CB009130-B Test Postconditions
                  ...     AND     QC_Update

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          False
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           False

&{[1][1.0] CB009130_TC_06 O-RU capability to support 5G FDD cell frequencies}
...    QC_ID_FL00=QC_540670


&{[1][1.0] CB009130_TC_02 O-RU capability to support 5G cells using the same TX array}
...    QC_ID_FL00=QC_540667


&{[1][2.0] CB009130_TC_07 O-RU capability to support 5G FDD cell bandwidth}
...    QC_ID_FL00=QC_543206


&{[1][1.0] CB009130_TC_05 O-RU capability to support 5G cell total power of all cell carriers}
...    QC_ID_FL00=QC_540669


&{[1][1.0] CB009130_TC_04 O-RU capability to support 5G NRCELL power of the single cell carrier}
...    QC_ID_FL00=QC_540668

*** Test Cases ***
	
[1][2.0] CB009130_TC_07 O-RU capability to support 5G FDD cell bandwidth
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    CB009130-B-TC_03 O-RU capability to support 5G cells bandwidth
    sleep    130s

[1][1.0] CB009130_TC_05 O-RU capability to support 5G cell total power of all cell carriers
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    CB009130-B-TC_04 O-RU capability to support 5G FDD cells total power of all cell carriers
    sleep    130s

[1][1.0] CB009130_TC_04 O-RU capability to support 5G NRCELL power of the single cell carrier
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    CB009130-B-TC_05 O-RU capability to support 5G NRCELL power of the single cell carrier
    sleep    130s

[1][1.0] CB009130_TC_06 O-RU capability to support 5G FDD cell frequencies
   [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    CB009130-B-TC_01 O-RU capability to support 5G cells frequency
    sleep   130s

[1][1.0] CB009130_TC_02 O-RU capability to support 5G cells using the same TX array
    [Tags]    SBTS00    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    CB009130-B-TC_02 O-RU capability to support 5G cells using the same TX array
    sleep    130s
