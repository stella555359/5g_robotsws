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
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CB008205-C/general.robot
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
Force Tags    CRT  FL00    SBTS25R2    SBTS25R3    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
&{[1][1.0]_TC_01_Access_group_configuration_during_O-RU_startup}    QC_ID_FL00=QC_31104
&{[1][1.0]_TC_02_SSD_configuration_for_Netconf_radio_WebEM_support}    QC_ID_FL00=QC_31105
&{[1][1.0]_TC_03_O-RU_SSH_public_key_change_detection_on_O-DU}    QC_ID_FL00=31102    QC_ID_SBTS25R2=QC_140381
...    QC_ID_SBTS26R2=QC_302791     QC_ID_SBTS26R1=247043
&{[1][1.0]_TC_04_Vendor_specific_fault_simulation_on_O-RU}    QC_ID_FL00=QC_31103    QC_ID_SBTS26R2=QC_302790
&{[1][1.0]_TC_07_O-RU_out_of_range_frequency_detection}    QC_ID_FL00=QC_31089
&{[1][1.0]_TC_08_O-RU_out_of_range_bandwidth_detection}    QC_ID_FL00=QC_31090
&{[1][1.0]_TC_09_LTE_cell_number_support_in_O-RU}    QC_ID_FL00=QC_31091
&{[1][1.0]_TC_10_LTE_cell_power_configuration_support_in_O-RU}    QC_ID_FL00=QC_31084
&{[1][1.0]_TC_11_Activation,_deactivation_and_interval_change_of_O-RU_LTE_eCPRI_Monitoring}    QC_ID_FL00=QC_31086
&{[1][1.0]_TC_12_O-RU_LTE_eCPRI_Monitoring_–_failure_and_timeout_scenarios}    QC_ID_FL00=QC_31087

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***

[1][1.0]_TC_01_Access_group_configuration_during_O-RU_startup
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC01
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
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
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

[1][1.0]_TC_03_O-RU_SSH_public_key_change_detection_on_O-DU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_03_O-RU_SSH_public_key_change_detection_on_O-DU/
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    TC_03_O-RU_SSH_public_key_change_detection_on_O-DU
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting


[1][1.0]_TC_04_Vendor_specific_fault_simulation_on_O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC04
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

[1][1.0]_TC_07_O-RU_out_of_range_frequency_detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC07
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_07_O-RU_out_of_range_frequency_detection/
    set test variable    ${out}
    TC_07_O-RU Out Of Range Frequency Detection
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_08_O-RU_out_of_range_bandwidth_detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC08
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_08_O-RU_out_of_range_bandwidth_detection/
    set test variable    ${out}
    TC_08_O-RU Out Of Range Bandwidth Detection
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_09_LTE_cell_number_support_in_O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC09
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_09_LTE_cell_number_support_in_O-RU/
    set test variable    ${out}
    TC_09_LTE cell number support in O-RU
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_10_LTE_cell_power_configuration_support_in_O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC10
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_10_LTE_cell_power_configuration_support_in_O-RU/
    set test variable    ${out}
    TC_10_LTE Cell Power Configuration Support In O-RU
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_11_Activation,_deactivation_and_interval_change_of_O-RU_LTE_eCPRI_Monitoring
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC11
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_11_Activation,_deactivation_and_interval_change_of_O-RU_LTE_eCPRI_Monitoring/
    set test variable    ${out}
    TC_11_Activation, Deactivation And Interval Change Of O-RU LTE eCPRI Monitoring
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_12_O-RU_LTE_eCPRI_Monitoring_–_failure_and_timeout_scenarios
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC12
    ${out}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_12_O-RU_LTE_eCPRI_Monitoring_–_failure_and_timeout_scenarios/
    set test variable    ${out}
    TC_12_O-RU_LTE eCPRI Monitoring Failure And Timeout Scenarios
    reportingportal_Keywords.RP Settings
    CB008205-C.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-C.Test Teardown
    ...    CB008205-C.Link SCOUT SCF to Configuration ID for Reporting