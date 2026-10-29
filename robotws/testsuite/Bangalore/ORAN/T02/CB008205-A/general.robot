*** Settings ***
Documentation
...    Author: challa.ravali@nokia.com; usha.m_m@nokia.com
...    Maintainer: challa.ravali@nokia.com
...    Test Description: This feature is firstly supported in ASIM/ASIL + ABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -A is related to LTE FDD technology.
...    Confluence link: link
...    Group in charge:I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD_GMS <I_MN_RAN_RD_VRF_BLR1_T02_FRONTLINERS_SQD@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-A/general.robot
...    Review: -
...    AC/REQ: OAM_REQ_RADIO_815; OAM_REQ_RADIO_816; OAM_REQ_RADIO_817; OAM_REQ_RADIO_818; OAM_REQ_RADIO_863;
...    OAM_REQ_RADIO_864; OAM_REQ_RADIO_866; OAM_REQ_RADIO_869; OAM_REQ_RADIO_879; OAM_REQ_RADIO_871; OAM_REQ_RADIO_876;
...    OAM_REQ_RADIO_877; OAM_REQ_RADIO_961; OAM_REQ_RADIO_968; OAM_REQ_RADIO_969; OAM_REQ_RADIO_970;OAM_REQ_RADIO_971;
...    OAM_REQ_RADIO_881; OAM_REQ_RADIO_972; OAM_REQ_RAT_933; OAM_REQ_RAT_934;

Resource    ./resources/CB008205-A.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library    Process
Library    String
Library    taf.sw.scout    WITH NAME    scout

Suite Setup       Suite Preconditions
Test Setup        ORAN Preconditions
Test Teardown     Test Postconditions Without WTSSIM S1
Suite Teardown    Suite Postconditions
Force Tags
...    STATE_CONFIGURED    CRT    QCD_MN_RAN    QCP_RAN_VRF
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN    SBTS00    FL00
...    CA_BTS_OAM_PDZ    QCD_MN_RAN    QCP_RAN_VRF


*** Variables ***

&{[1][1.0]_TC_02_Retrieval_of_O-RU_YANG_optional_features_and_modules}    QC_ID_FL00=QC_31088
&{[1][1.0]_TC_03_Faults_handling_during_retrieval_of_endpoint-types,_static-low-level-tx-endpoints_and_static-low-level-rx-endpoints}
...    QC_ID_FL00=QC_31094
&{[1][1.0]_TC_04_Faults_handling_during_configuration_of_TX_RX_array_carriers_and_low-level-tx_rx-endpoints}    QC_ID_FL00=QC_31085
&{[1][1.0]_TC_05_Faults_handling_during_configuration_of_static_PRACH_patterns_to_O-RU}    QC_ID_FL00=QC_31093
&{[1][1.0]_TC_06_Capabilities_mismatch_detection}    QC_ID_FL00=31092

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
[1][1.0]_TC_02_Retrieval_of_O-RU_YANG_optional_features_and_modules
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
    ${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval_of_O-RU_YANG_optional_features_and_modules
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_03_Faults_handling_during_retrieval_of_endpoint-types,_static-low-level-tx-endpoints_and_static-low-level-rx-endpoints
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    ${output}    set variable
    ...    ${OUTPUT_DIR}/TC_03_Faults_handling_during_retrieval_of_endpoint-types,_static-low-level-tx-endpoints_and_static-low-level-rx-endpoints
    set test variable    ${output}
    TC_03_Faults handling during retrieval of endpoint-types, static-low-level-tx-endpoints and static-low-level-rx-endpoints
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_04_Faults_handling_during_configuration_of_TX_RX_array_carriers_and_low-level-tx_rx-endpoints
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC04
	${output}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_04_Faults_handling_during_configuration_of_TX_RX_array_carriers_and_low-level-tx_rx-endpoints
    set test variable    ${output}
    TC_04_Faults handling during configuration of TX RX array carriers and low-level-tx rx-endpoints
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_05_Faults_handling_during_configuration_of_static_PRACH_patterns_to_O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC05
	${output}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_05_Faults_handling_during_configuration_of_static_PRACH_patterns_to_O-RU
    set test variable    ${output}
    TC_05_Faults handling during configuration of static PRACH patterns to O-RU
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_06_Capabilities_mismatch_detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC06
	${output}    set variable
    ...    ${OUTPUT_DIR}/[1][1.0]_TC_06_Capabilities_mismatch_detection
    set test variable    ${output}
    TC_06_Capabilities mismatch detection
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

#Note : Testcases TC_07 to TC_12 of CB008205-A suite is moved to CB008205-C/general.robot.