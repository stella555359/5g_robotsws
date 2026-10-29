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
...    STATE_CONFIGURED    CRT    QCD_MN_RAN    QCP_RAN_ST
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN    SBTS00    FL00
...    CA_BTS_OAM_PDZ    QCD_MN_RAN    QCP_RAN_ST


*** Variables ***

&{[1][1.0] TC_02_Retrieval of O-RU YANG optional features and modules}    QC_ID_FL00=QC_466900
&{[1][1.0] TC_03_Faults handling during retrieval of endpoint-types, static-low-level-tx-endpoints and static-low-level-rx-endpoints}    
...    QC_ID_FL00=QC_466901
&{[1][1.0] TC_04_Faults handling during configuration of TX RX array carriers and low-level-tx rx-endpoints}    QC_ID_FL00=QC_466902
&{[1][1.0] TC_05_Faults handling during configuration of static PRACH patterns to O-RU}    QC_ID_FL00=QC_466903
&{[1][1.0] TC_06_Capabilities mismatch detection}    QC_ID_FL00=QC_473014
&{[1][1.0] TC_07_O-RU out of range frequency detection}    QC_ID_FL00=QC_466905
&{[1][1.0] TC_08_O-RU out of range bandwidth detection}    QC_ID_FL00=QC_473015
&{[1][1.0] TC_09_LTE cell number support in O-RU}    QC_ID_FL00=QC_473016
&{[1][1.0] TC_10_LTE cell power configuration support in O-RU}    QC_ID_FL00=QC_473017
&{[1][1.0] TC_11_Activation, deactivation and interval change of O-RU LTE eCPRI Monitoring}    QC_ID_FL00=QC_473018
&{[1][1.0] TC_12_O-RU LTE eCPRI Monitoring – failure and timeout scenarios}    QC_ID_FL00=QC_466906

${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            False
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
[1][1.0] TC_02_Retrieval of O-RU YANG optional features and modules
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC02
    ${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
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

[1][1.0] TC_03_Faults handling during retrieval of endpoint-types, static-low-level-tx-endpoints and static-low-level-rx-endpoints
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC03
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_03_Faults handling during retrieval of endpoint-types, static-low-level-tx-endpoints and static-low-level-rx-endpoints
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_04_Faults handling during configuration of TX RX array carriers and low-level-tx rx-endpoints
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC04
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_04_Faults handling during configuration of TX RX array carriers and low-level-tx rx-endpoints
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_05_Faults handling during configuration of static PRACH patterns to O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC05
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_05_Faults handling during configuration of static PRACH patterns to O-RU
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
    ...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_06_Capabilities mismatch detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC06
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_06_Capabilities mismatch detection
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_07_O-RU out of range frequency detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC07
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_07_O-RU Out Of Range Frequency Detection
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_08_O-RU out of range bandwidth detection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC08
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_08_O-RU Out Of Range Bandwidth Detection
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_09_LTE cell number support in O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC09
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_09_LTE cell number support in O-RU
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_10_LTE cell power configuration support in O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC10
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_10_LTE Cell Power Configuration Support In O-RU
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_11_Activation, deactivation and interval change of O-RU LTE eCPRI Monitoring
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC11
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_11_Activation, Deactivation And Interval Change Of O-RU LTE eCPRI Monitoring
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] TC_12_O-RU LTE eCPRI Monitoring – failure and timeout scenarios
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC12
	${output}    set variable
    ...    ${OUTPUT_DIR}/TC_02_Retrieval Of O-RU YANG Optional Features And Modules
    set test variable    ${output}
    TC_12_O-RU_LTE eCPRI Monitoring Failure And Timeout Scenarios
    reportingportal_Keywords.RP Settings
    CB008205-A.FSM Access Close Connection
    [Teardown]    run keywords
    ...    reportingportal_Keywords.Set QC_Tag
    ...    Test Postconditions Without WTSSIM S1
	...    CB008205-A.Test Teardown
    ...    CB008205-A.Link SCOUT SCF to Configuration ID for Reporting
