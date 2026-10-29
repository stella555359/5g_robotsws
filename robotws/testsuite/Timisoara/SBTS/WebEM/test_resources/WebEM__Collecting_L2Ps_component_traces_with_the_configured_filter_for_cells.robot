*** Settings ***
Documentation
    ...  The purpose of this test case is to start collecting L2Ps component traces with filtering traces for cell level and stop collecting
    ...  L2Ps component traces.
    ...  The user navigate to Diagnostic tab->Debug tracing and complete Common configuration with the following: Source IP, DSCP, UPlane Destination
    ...  The user goes to UPlane Component (L2PS) Select all enabled cells and select few profiles from Profile filters.
    ...  Start collecting L2Ps component traces and stop collecting.
    ...  The user goes to UPlane Component (L2PS) Select max 8 cells and select few profiles from Profile filters.
    ...  Start collecting L2Ps component traces and stop collecting.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27555
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27555 - Initial TAT creation
    ...  08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29529 - Navigation Menu has changed with software larger than 25R3
    ...  13.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29714 - Profile filter xpath was changed in trunk
    ...  29.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30092 - Wait for start and stop to be clicked
    ...  24.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30225 - U-Plane xpath modified starting with software 26R2

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CNI-107269

    Step0: Set Common Configuration Paramaters For Debug Tracing
    Step1: Navigate To Debug Tracing And Complete Common Configuration Parameters
    Step2: Start Collecting L2Ps Component Traces With Select all enabled cells
    Step3: Start collecting L2Ps component traces with Select max. 8 cells


Step0: Set Common Configuration Paramaters For Debug Tracing
    Log  \nStep0: Set common configuration paramaters for debug tracing  console=true
    ${status}  Run Keyword And Return Status
    ...  Element Should Not Be Visible  //*[contains(text(),"IP addresses")]
    IF  ${status}  Click Element  //*[contains(@class, 'details-panel-container')]/ui-button/button/i
    ${m_plane_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'details-info-body')]/div/div[3]/div/div/div/ui-table/div/ng-transclude/table/
    ...  tbody[1]/tr/td[2]
    ${m_plane}  Get Text  ${m_plane_xpath}
    Set Test Variable  ${M_PLANE}
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${index_u_plane}  Set Variable  9
    ELSE
        ${index_u_plane}  Set Variable  5
    END
    ${u_plane_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'details-info-body')]/div/div[3]/div/div/div/ui-table/div/ng-transclude/table/
    ...  tbody[${index_u_plane}]/tr/td[2]
    ${u_plane_text}  Get Text  ${u_plane_xpath}
    ${u_plane}  Fetch From Left  ${u_plane_text}  ${SPACE}
    Set Test Variable  ${U_PLANE}


Step1: Navigate To Debug Tracing And Complete Common Configuration Parameters
    Log  \nStep1: Navigate to debug tracing and complete common configuration parameters  console=true
    Open Diagnostic Menu
    Wait Until Element Is Visible  //span[contains(text(),'Debug Tracing')]  timeout=30
    Click Element  //span[contains(text(),'Debug Tracing')]
    IF  '${GUI_VERSION}' == 'new' and '${ENB_BRANCH}' < 'SBTS25R3'  Open/Close Menus Tab
    Complete Common Configuration Parameters


Step${index}: Start Collecting L2Ps Component Traces With ${filter}
    Log  \nStep${index}: Start collecting L2Ps component traces with ${filter}  console=true
    Choose Filter In UPlane Component  ${filter}
    Start Trace And Stop Trace


Complete Common Configuration Parameters
    ${source_ip}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
    ...  div[2]/log-agent-configuration/div/div[2]/div/div/div[1]/div[2]/div[2]/ui-text-input/div/input
    ${dscp}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
    ...  div[2]/log-agent-configuration/div/div[2]/div/div/div[2]/div[2]/div[2]/ui-text-input/div/input
    ${u_plane_destination}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/log-agent-configuration/div/div[2]/div/div/div[3]/div[2]/div[2]/ui-text-input/div/input
    ${port}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
    ...  div[2]/log-agent-configuration/div/div[2]/div/div/div[3]/div[3]/div[2]/ui-text-input/div/input
    Input Text  ${source_ip}  ${M_PLANE}
    Input Text  ${dscp}  0
    Input Text  ${u_plane_destination}  ${U_PLANE}
    Input Text  ${port}  1024


Choose Filter In UPlane Component
    [Arguments]  ${filter}

    ${l2_data_flow}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]/
    ...  div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/div/div[1]/ul/li[3]/div
    Click Element  ${l2_data_flow}
    ${profile_filters}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l2-ps/div/div[1]
    IF  '${ENB_BRANCH}' > 'SBTS25R3'
        Wait Until Element Is Clicked  ${profile_filters}/div[1]/p-multiselect/div/div[2]/div  120
    ELSE
        Wait Until Element Is Clicked  ${profile_filters}/p-multiselect/div/div[2]/div  120
    END
    ${div_number}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    ${count_filter}  SeleniumLibrary.Get Element Count  xpath:/html/body/div[${div_number}]/div[2]/ul/p-multiselectitem
    ${index_filter}  Evaluate  random.randint(1,${count_filter})  random
    Click Element  xpath:/html/body/div[${div_number}]/div[2]/ul/p-multiselectitem[${index_filter}]
    Click Element  ${profile_filters}
    IF  '${filter}'=='Select all enabled cells'
        Click Element  locator=//*[contains(@for, "componentallCells") and contains(text(), ' ${filter} ')]
    ELSE
        Click Element  locator=//*[contains(@for, "componentfilterCells") and contains(text(), ' ${filter} ')]
    END
    ${choose_cell}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l2-ps/div/div[2]/div/
    ...  cells-component/ui-select[1]/div/wf-dropdown/div/button/span[1]
    ${cell_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l2-ps/div/div[2]/div/
    ...  cells-component/ui-select[1]/div/wf-dropdown/div/ul/wf-dropdown-item[2]/li/a
    IF  '${filter}'=='Select max. 8 cells'
        Click Element  ${choose_cell}
        Click Element  ${cell_xpath}
    END


Start Trace And Stop Trace
    ${start_trace_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l2-ps/div/div[3]/p-button[1]
    ...  /button
    Wait Until Element Is Clicked  ${start_trace_xpath}
    Wait Until Element Is Visible  locator=//span[contains(text(),'Start succeeded')]  timeout=30s
    Log  \nStart collecting L2Ps component traces successfully.  console=true
    ${stop_trace_xpath}  Catenate  SEPARATOR=  //*[contains(@class, 'debug-tracing-container')]
    ...  /div[2]/section/div/expansion-panel[2]/div[2]/div/u-plane-component/section/div/tracing-cells-content/div/l2-ps/div/div[3]/p-button[2]
    ...  /button
    Wait Until Element Is Clicked  ${stop_trace_xpath}
    Wait Until Element Is Visible  locator=//span[contains(text(),'Stop succeeded')]  timeout=30s
    Log  \nStop collecting L2Ps component traces successfully.  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
