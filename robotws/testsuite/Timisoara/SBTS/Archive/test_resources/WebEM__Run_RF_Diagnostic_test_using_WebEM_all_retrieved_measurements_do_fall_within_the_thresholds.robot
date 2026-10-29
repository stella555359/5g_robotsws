*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${bandClass}                      3                    #This value needs to be changed on the 5G band
${rFPowerErrorHighThreshold}      80
${rFPowerErrorLowThreshold}      -80
${rxAntennaRTWPHighThreshold}    -300
${rxAntennaRTWPLowThreshold}     -1100
${txAntennaVSWRHighThreshold}     30
${rxAntennaRSSIHighThreshold}    -300
${rxAntennaRSSILowThreshold}     -1400
${rfTemperatureLowThreshold}     -5
${rfTemperatureHighThreshold}    80


*** Keywords ***
TC__WebEM__Run_RF_Diagnostic_test_using_WebEM_all_retrieved_measurements_do_fall_within_the_thresholds
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21287
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC will Login to SBTS WebEM and activate remote RF diagnostic test by setting MRBTS::actRemoteRfDiag flag to true
	...  Will create TEST object in MRBTS::MNL::MNLENT
    ...  Create object RFTHLD in TEST parameters will be set in json file,otherwise default values will be used
    ...  Create object RFREQ in TEST to start RF diagnostic test
    ...  TC will fail if RF diagnostic test will fail
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21287 - Initial creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 04.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24045 - Replace nrBandRfTestThresholds with bandRfTestThresholds
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 29.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25591 - Parameter actRemoteRfDiag removed from NIDD after release 23R4

    Set Tags    CA-WebEM    OWNER-alexandra.boja@nokia.com    AUTHOR-george.chincea@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com   GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-5G21A

	Step 1:Activate remote RF diagnostic test by setting MRBTS::actRemoteRfDiag flag to true
    Step 2:Create TEST object under MRBTS::MNL::MNLENT and fill testId parameter
    Step 3:Create and set threshold values of RFTHLD managed object
    Step 4:Start test by creating managed object MRBTS::MNL::MNLENT::TEST::RFREQ
    Step 5:Collect RF Diagnostic Measurments


Step 1:Activate remote RF diagnostic test by setting MRBTS::actRemoteRfDiag flag to true
    Log  Step 1: Activate remote RF diagnostic test by setting MRBTS::actRemoteRfDiag flag to true  console=true
    ${bts_cores}  Run Keyword And Return Status  query infomodel  check //BTS_L-1 is [storedRole=Active]
    Run keyword if  ${bts_cores}
    ...  Set Test Variable  ${MASTER_SIDE}  1
    ...  ELSE
    ...  Set Test Variable  ${MASTER_SIDE}  4
    ${BTS_ID}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    ${SW_RELEASE_NAME}  Fetch from left  ${active SW version}  _
    Set test variable  ${SW_RELEASE_NAME}
    Run keyword if  '${SW_RELEASE_NAME}'<'SBTS23R4'  Run Keywords
    ...  Perform Parameter Recommissioning    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actRemoteRfDiag    update    true
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    ...  AND
    ...  Log  Parameter actRemoteRfDiag is on true  console=true

Step 2:Create TEST object under MRBTS::MNL::MNLENT and fill testId parameter
    Log  Step 2:Create TEST object under MRBTS::MNL::MNLENT and fill testId parameter  console=true
    Create Test Object

Step 3:Create and set threshold values of RFTHLD managed object
    Log  Step 3:Create and set threshold values of RFTHLD managed object  console=true
    Create RFTHLD Object

Step 4:Start test by creating managed object MRBTS::MNL::MNLENT::TEST::RFREQ
    Log  Step 4:Start test by creating managed object MRBTS::MNL::MNLENT::TEST::RFREQ  console=true
    Create RFREQ Object

Step5:Collect RF Diagnostic Measurments
    Log  Step5:Collect RF Diagnostic Measurments  console=true
    ${Results_list}  Query Infomodel  get list //RFRES_R-*
    FOR  ${RF_results}  IN  @{results_list}
    ${status}  Run Keyword and return status  should not be equal  '${RF_results}[testOutcome]'  'Failed'
    Run Keyword unless  ${status}
    ...  Set test failed  RF diagnostic test is failed.
    END

Create Test Object
    Log  Delta will be created...  console=${TRUE}
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1  create  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=${TRUE}
    ${COMMISSIONING_STATE}=  Run Keyword And Return Status  Perform Delta Recommissioning  ${BTS Files}/delta.json
    ...  skip_parameter_relation_errors=True
    Set Test Variable  ${COMMISSIONING_STATE}
    Remove Delta  ${delta_id}

Create RFTHLD Object
	Log  Delta will be created...  console=${TRUE}
	${delta_id}  Set Variable  2
	Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rFPowerErrorHighThreshold
    ...  ${rFPowerErrorHighThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rFPowerErrorLowThreshold
    ...  ${rFPowerErrorLowThreshold}   ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rxAntennaRTWPHighThreshold
    ...  ${rxAntennaRTWPHighThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rxAntennaRTWPLowThreshold
    ...  ${rxAntennaRTWPLowThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  txAntennaVSWRHighThreshold
    ...  ${txAntennaVSWRHighThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rxAntennaRSSIHighThreshold
    ...  ${rxAntennaRSSIHighThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rxAntennaRSSILowThreshold
    ...  ${rxAntennaRSSILowThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rfTemperatureLowThreshold
    ...  ${rfTemperatureLowThreshold}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  rfTemperatureHighThreshold
    ...  ${rfTemperatureHighThreshold}  ${delta_id}
    ${Structure1}  Create Dictionary
    Set To Dictionary  ${Structure1}  bandClass  3
    Set To Dictionary  ${Structure1}  totalRFPowerHighThreshold  1200
    Set To Dictionary  ${Structure1}  totalRFPowerLowThreshold  1
    Append Complex Item To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1  list_name=bandRfTestThresholds  &{Structure1}  delta_id=${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta_RFTHLD.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=${TRUE}
    ${COMMISSIONING_STATE}  Run Keyword And Return Status  Perform Delta Recommissioning  ${BTS Files}/delta_RFTHLD.json
    ...  skip_parameter_relation_errors=True
    Set Test Variable  ${COMMISSIONING_STATE}
    Remove Delta  ${delta_id}

Create RFREQ Object
    Log  Delta will be created...  console=${TRUE}
    ${delta_id}  Set Variable  2
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ  create  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1/RFREQ  targetCellType  NR  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=${TRUE}
    ${COMMISSIONING_STATE}  Run Keyword And Return Status  Perform Delta Recommissioning  ${BTS Files}/delta.json
    ...  skip_parameter_relation_errors=True
    Set Test Variable  ${COMMISSIONING_STATE}
    Remove Delta  ${delta_id}

Clean configuration after test
    Log  Clean configuration after test console=true
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TEST-1  delete  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS Files}/delta.json  delta_id=${delta_id}
    Log  Performing delta recommissioning...  console=${TRUE}
    ${COMMISSIONING_STATE}  Run Keyword And Return Status  Perform Delta Recommissioning  ${BTS Files}/delta.json
    ...  skip_parameter_relation_errors=True
    Set Test Variable  ${COMMISSIONING_STATE}
    Remove Delta  ${delta_id}
    Run keyword if  '${SW_RELEASE_NAME}'<'SBTS23R4'  Run Keywords
    ...  Perform Parameter Recommissioning    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actRemoteRfDiag    update    false
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    ...  AND
    ...  Log  Parameter actRemoteRfDiag is on false  console=true

TC Setup
    Common Test Setup

TC Teardown
    Clean configuration after test
    Common Test Teardown
