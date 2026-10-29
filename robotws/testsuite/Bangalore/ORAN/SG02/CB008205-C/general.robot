*** Settings ***
Documentation
...    Author: challa.ravali@nokia.com
...    Maintainer: challa.ravali@nokia.com
...    Test Description: This feature is firstly supported in ASIL + APoABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -C is related to O-RAN V5.0 improvements with the use of 3rd party RU.
...    Confluence link: link
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-C/general.robot
...    Review: -
...    AC/REQ: OAM_REQ_RADIO_801, OAM_REQ_RADIO_904, OAM_REQ_RADIO_913, OAM_REQ_RADIO_914, OAM_REQ_RADIO_916,
...    OAM_REQ_RADIO_918, OAM_REQ_RADIO_924, OAM_REQ_RADIO_973, OAM_REQ_WEBEM_1029, OAM_REQ_WEBEM_1032,
...    OAM_REQ_WEBEM_1035, OM_SFS_GEN_FM.3209, OM_SFS_GEN_FM.3255, OAM_REQ_RADIO_801_1, OAM_REQ_RADIO_913_1,
...    OAM_REQ_RADIO_914_1, OAM_REQ_RADIO_916_1, OAM_REQ_RADIO_918_1, OAM_REQ_RADIO_973_1, OAM_REQ_WEBEM_1035_1,
...    OAM_REQ_WEBEM_1029_1, OAM_REQ_WEBEM_1032_1, OAM_REQ_RADIO_904_1, OAM_REQ_RADIO_924_1, OM_GEN_SFS_FM.3209_1,
...    OM_GEN_SFS_FM.3255_1

Resource    ./resources/CB008205-C.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library    Process
Library    String
Library    taf.sw.scout    WITH NAME    scout

Suite Setup       Suite Preconditions
Test Setup        CB008205-C.ORAN Preconditions
Test Teardown     Test Postconditions Without WTSSIM S1
Suite Teardown    Suite Postconditions
Force Tags    CRT  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[1][1.0]_TC_01_Access_group_configuration_during_O-RU_startup}    QC_ID_FL00=QC_470133
&{[1][1.0]_TC_02_SSD_configuration_for_Netconf_radio_WebEM_support}    QC_ID_FL00=QC_470134
&{[1][1.0]_TC_04_Vendor_specific_fault_simulation_on_O-RU}    QC_ID_FL00=QC_470136

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***

[1][1.0]_TC_01_Access_group_configuration_during_O-RU_startup
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC01
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_01_Access_group_configuration_during_O-RU_startup/
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    TC_01_Access group configuration during O-RU startup
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting


[1][1.0]_TC_02_SSD_configuration_for_Netconf_radio_WebEM_support
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC02
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_02_SSD_configuration_for_Netconf_radio_WebEM_support/
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    TC_02_SSD configuration for Netconf radio WebEM support
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_04_Vendor_specific_fault_simulation_on_O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC04
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_04_Vendor_specific_fault_simulation_on_O-RU/
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    TC_04_Vendor_specific_fault_simulation_on_O-RU
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting
