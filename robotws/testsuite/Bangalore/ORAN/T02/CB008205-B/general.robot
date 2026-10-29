*** Settings ***
Documentation
...    Author: anagha.chenniga@nokia.com
...    Maintainer: anagha.chenniga@nokia.com
...    Test Description: This feature is firstly supported in ASIL + ABIO to introduce the general Nokia
...    world market O-RAN compliant O-CDU with FDD eCPRI interface (CAT-A) for FDD NR or FDD LTE.
...    Subitem -B is related to NR FDD technology.
...    Confluence link: link
...    Group in charge: I_MN_RAN_RD_VRF_BLR1_T02_GMS <I_MN_RAN_RD_VRF_BLR1_T02@internal.nsn.com>
...    References: ToDo
...    QualityCenter: ToDo
...    Sample execution: robot -d /home/ute/logs/ -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-B/general.robot
...    Review: -
...    AC/REQ: OAM_REQ_RADIO_815; OAM_REQ_RADIO_816; OAM_REQ_RADIO_817; OAM_REQ_RADIO_818; OAM_REQ_RADIO_863;
...    OAM_REQ_RADIO_864; OAM_REQ_RADIO_866; OAM_REQ_RADIO_869; OAM_REQ_RADIO_879; OAM_REQ_RADIO_871; OAM_REQ_RADIO_876;
...    OAM_REQ_RADIO_877; OAM_REQ_RADIO_961; OAM_REQ_RADIO_968; OAM_REQ_RADIO_969; OAM_REQ_RADIO_970;OAM_REQ_RADIO_971;
...    OAM_REQ_RADIO_881; OAM_REQ_RADIO_972; OAM_REQ_RAT_933; OAM_REQ_RAT_934;

Resource    ./resources/CB008205-B.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library    Process
Library    String
Library    taf.sw.scout    WITH NAME    scout

Suite Setup       Suite Preconditions
Test Setup        CB008205-B.ORAN Preconditions
Test Teardown     Test Postconditions Without WTSSIM S1
Suite Teardown    Suite Postconditions
Force Tags    CRT  FL00    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
&{[1][1.0]_TC_02_Retrieval_of_O-RU_YANG_optional_features_and_modules}    QC_ID_FL00=QC_31100
&{[1][1.0]_TC_03_Faults_handling_during_retrieval_of_endpoint-types,_static-low-level-tx-endpoints_and_static-low-level-rx-endpoints}
...    QC_ID_FL00=QC_31101
&{[1][1.0]_TC_04_Faults_handling_during_configuration_of_TX_RX_array_carriers_and_low-level-tx_rx-endpoints}
...    QC_ID_FL00=QC_31097
&{[1][1.0]_TC_05_Faults_handling_during_configuration_of_static_PRACH_patterns_to_O-RU}    QC_ID_FL00=QC_31096
&{[1][1.0]_TC_06_Capabilities_mismatch_detection}    QC_ID_FL00=QC_31095
&{[1][1.0]_TC_07_O-RU_out_of_range_frequency_detection}    QC_ID_FL00=QC_31099
&{[1][1.0]_TC_08_O-RU_out_of_range_bandwidth_detection}    QC_ID_FL00=QC_31098

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
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
	...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_03_Faults_handling_during_retrieval_of_endpoint-types,_static-low-level-tx-endpoints_and_static-low-level-rx-endpoints
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_03_Faults_handling_during_retrieval_of_endpoint-types,_static-low-level-tx-endpoints_and_static-low-level-rx-endpoints
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_03_Faults Handling During Retrieval Of endpoint-types static-low-level-tx-endpoints And static-low-level-rx-endpoints
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
	...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_04_Faults_handling_during_configuration_of_TX_RX_array_carriers_and_low-level-tx_rx-endpoints
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC04
    ${output}    set variable
    ...    ${OUTPUT_DIR}/TC_04_Faults_handling_during_configuration_of_TX_RX_array_carriers_and_low-level-tx_rx-endpoints
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_04_Faults Handling During Configuration Of TX RX Array Carriers And low-level-tx rx-endpoints
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_05_Faults_handling_during_configuration_of_static_PRACH_patterns_to_O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC05
    ${output}    set variable
    ...    ${OUTPUT_DIR}/TC_05_Faults_handling_during_configuration_of_static_PRACH_patterns_to_O-RU
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_05_Faults Handling During Configuration Of Static PRACH Patterns To O-RU
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
	...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_06_Capabilities_mismatch_detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC06
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_06_Capabilities_mismatch_detection
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_06_Capabilities Mismatch Detection
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
	...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_07_O-RU_out_of_range_frequency_detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC07
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_07_O-RU_out_of_range_frequency_detection
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_07_O-RU Out Of Range Frequency Detection
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
	...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_TC_08_O-RU_out_of_range_bandwidth_detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC08
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_08_O-RU_out_of_range_bandwidth_detection
    set test variable    ${output}
    OperatingSystem.create directory     ${output}
    TC_08_O-RU Out Of Range Bandwidth Detection
    RP Settings
    FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
	...    CB008205-B.Test Teardown
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-B.Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
FSM Access Close Connection
    [Arguments]    ${alias}=fsm_access
    Teardown Enb Fsm Access    alias=${alias}

