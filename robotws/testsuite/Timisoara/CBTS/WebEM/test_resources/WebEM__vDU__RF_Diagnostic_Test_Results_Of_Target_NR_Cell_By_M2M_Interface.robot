*** Settings ***
Documentation
    ...  This TC sends RF diagnostic test through M2M interface.
    ...  First, one random vDU cell is chosen.
    ...  Then, TC is using POST command to send RF diagnostic test on this cell.
    ...  The operation output is checked to be as expected. It must have the right values
    ...  for cell id, BTS id, BTS name and product name of RMOD linked to the cell.
    ...  Referenced values are obtained using taf vdu library.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/M2M_Interface.robot


*** Keywords ***
TC__WebEM__vDU__RF_Diagnostic_Test_Results_Of_Target_NR_Cell_By_M2M_Interface
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26614
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  18.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26614 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-mihai-adrian.pirjol@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB010545

    Step1: Send RF Diagnostic Test On VDU Cell
    Step2: Check Test Result To Be As Expected


Step1: Send RF Diagnostic Test On VDU Cell
    Log  \nStep1: Send RF diagnostic test on VDU cell  console=true
    ${cells_status}  vdu.Get Vdu Cells Status
    ${cell_params}  Evaluate  random.choice(${cells_status})  random
    ${rf_diagostic_test_params}  Catenate  SEPARATOR=  -d "{\\"targetCellId\\":${cell_params}[id],  \\"actRemoteRfDiag\\":true,
    ...  \\"thresholds\\":{\\"rxAntennaRSSIHighThreshold\\":-30,  \\"rxAntennaRSSILowThreshold\\":-110,  \\"txAntennaVSWRHighThreshold\\":3}}"
    ${post_request}  Run M2M Command  POST  https://10.15.255.186/api/licensed/v1/diagnostic/rf-diagnostic-test  Bearer  ${TOKEN}
    ...  ${rf_diagostic_test_params}
    Should Contain  ${post_request}  "status" : "ongoing"
    Set Test Variable  ${CELL_ID}  ${cell_params}[id]


Step2: Check Test Result To Be As Expected
    Log  \nStep2: Check test result to be as expected  console=true
    ${rf_diagnostic_results}  Run M2M Command  GET  https://${VDU_OAM_IP}/api/licensed/v1/diagnostic/rf-diagnostic-test/results?targetCellId=-1
    ...  Bearer  ${TOKEN}

    ${rf_diagnostic_results}  Remove M2M Output Noise  ${rf_diagnostic_results}
    ${rf_diagnostic_results}  Remove String Using Regexp  ${rf_diagnostic_results}  \\n(\\t)*
    ${rf_diagnostic_results}  Fetch From Left  ${rf_diagnostic_results}  curl
    ${rf_diagnostic_results}  Fetch From Left  ${rf_diagnostic_results}  ${SPACE}${SPACE}:
    ${rf_diagnostic_results}  Evaluate  json.loads('''${rf_diagnostic_results}''')  json

    ${rmod_product_name}  Get RMOD Product Name For Specific Cell  ${CELL_ID}

    Should Be Equal As Integers  ${rf_diagnostic_results}[btsId]  ${VDU_MRBTS_ID}  BTS id is not as expected.
    Should Be Equal As Strings  ${rf_diagnostic_results}[btsName]  ${VDU_MRBTS_NAME}  BTS name is not as expected.
    Should Be Equal As Integers  ${rf_diagnostic_results}[rfDiagnosticTestResults][0][nrCellId]  ${CELL_ID}  Cell id is not as expected.
    Should Be Equal As Strings  ${RESULT}[rfDiagnosticTestResults][0][generalTestInfo][detailedResult][0][productName]  ${rmod_product_name}
    ...  Product name is not as expected.


Get RMOD Product Name For Specific Cell
    [Arguments]  ${cell_id}

    ${rmods_parameters}  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{rmods_parameters}
        ${status_cell}  Run Keyword And Return Status
        ...  List Should Contain Value  ${rmod_params}[cell_ids]  ${cell_id}
        Exit For Loop If  ${status_cell}
    END

    [Return]  ${rmod_params}[product_name]


TC Setup
    Common VDU Setup
    Modify Resource Search Order  WebEM__vDU__RF_Diagnostic_Test_Results_Of_Target_NR_Cell_By_M2M_Interface
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
