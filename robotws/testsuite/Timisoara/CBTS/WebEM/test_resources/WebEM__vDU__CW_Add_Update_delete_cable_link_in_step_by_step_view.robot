*** Settings ***
Documentation
    ...  This TC is created to verify addition and deletion of a cable link.
    ...  Commissioning Wizard is opened.
    ...  Delta plan is created.
    ...  Module link settings page is opened.
    ...  Cable link is added and all parameters are set.
    ...  Cable link is deleted.
    ...  Commissioning plan is saved.
    ...  Delta Plan is deleted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Add_Update_delete_cable_link_in_step_by_step_view
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26718
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26718 - Initial TAT creation
    ...  29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29026 - Some xpaths were changed
    ...  ******************
    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-B

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Add And Delete Cable Link In Step By Step View


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    ${rnic_info}  Get Rnic Info From Plan  ${VDU_MRBTS_ID}
    ${rnic_r_dn}  Set Variable  ${rnic_info}[0][r_nic_mod_dist_name]
    ${rnic_r}  Fetch From Right  ${rnic_r_dn}  /
    ${rnic_dn}  Remove String Using Regexp  ${rnic_r_dn}  _R
    ${rnic}  Fetch From Right  ${rnic_dn}  /
    ${rmods_status}  vdu.Get Rmods Status
    ${product_name}  Set Variable  ${rmods_status}[0][product_name]
    ${rmod_dn}  Set Variable  ${rmods_status}[0][dist_names][runtime]
    ${rmod_r}  Fetch From Right  ${rmod_dn}  /
    ${rmod}  Remove String Using Regexp  ${rmod_r}  _R
    ${rmod_full_name}  Catenate  ${product_name}  ${rmod}
    Set Test Variable  ${RNIC_DN}
    Set Test Variable  ${RNIC_R}
    Set Test Variable  ${RNIC}
    Set Test Variable  ${RMOD_FULL_NAME}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard
    Wait Until Keyword Succeeds  120  5
    ...  Create Duplicate Plan For CBTS


Step2: Add And Delete Cable Link In Step By Step View
    Log  \nStep2: Add and delete cable link in step by step view.  console=true
    ${rnic_type}  Get Text  //*[@id="${RNIC_DN}"]/cem-common-widget/ot-card/p-card/div/div/div/div/div/div[2]
    ${rnic_full_name}  Catenate  ${rnic_type}  ${RNIC}
    Click Element  //*[contains(text(),'Module Link Settings')]
    Wait Until Element Is Clicked  //*[contains(text(),'${rnic_full_name}')]  10  2
    ${no_of_cablinks}  Get Element Count  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr
    ${tr}  Evaluate  ${no_of_cablinks} + 1
    Wait Until Element Is Clicked  //*[contains(@class,'mdi mdi-plus-thick p-button-icon ng-star-inserted')]  10  2
    Modify Parameters For Cablink  ${tr}  Q-RF1  QSFP  1  ${RMOD_FULL_NAME}  OPT-IF1  QSFP  CPRI  Cpri7  none
    ${delete_button_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]
    ...  /tbody/tr[${tr}]/td[11]/p-button/button/span[1]
    Click Element  ${delete_button_locator}


Modify Parameters For Cablink
    [Arguments]
    ...  ${tr}
    ...  ${first_endpoint_port}
    ...  ${first_endpoint_port_label}
    ...  ${first_endpoint_id}
    ...  ${second_endpoint_rmods}
    ...  ${second_endpoint_port}
    ...  ${second_endpoint_label}
    ...  ${radio_protocol_type}
    ...  ${link_speed}
    ...  ${iq_compression}

    ${first_endpoint_port_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]
    ...  /tbody/tr[${tr}]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${first_endpoint_port_locator}
    Wait Until Element Is Clicked  //*[contains(text(),'${first_endpoint_port}')]  10  2
    ${first_endpoint_port_label_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[3]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${first_endpoint_port_label_locator}
    Wait Until Keyword Succeeds  10  2
    ...  Scroll Element Into View  //*[contains(@aria-label,'${first_endpoint_port_label}')]
    Wait Until Element Is Clicked  //*[contains(@aria-label,'${first_endpoint_port_label}')]  10  2
    ${first_endpoint_id_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[4]
    ...  /cem-parameter-input/cem-number-input/ot-field/div/ot-input-number/span/input
    Input Text  ${first_endpoint_id_locator}  ${first_endpoint_id}
    ${second_endpoint_rmods_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[5]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${second_endpoint_rmods_locator}
    Wait Until Element Is Clicked  //*[contains(text(),'${second_endpoint_rmods}')]  10  2
    ${second_endpoint_port_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[6]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${second_endpoint_port_locator}
    Wait Until Element Is Clicked  //*[contains(text(),'${second_endpoint_port}')]  10  2
    ${second_endpoint_label_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[7]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${second_endpoint_label_locator}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'${second_endpoint_label}')]  10  2
    ${radio_protocol_type_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[8]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${radio_protocol_type_locator}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'${radio_protocol_type}')]  10  2
    ${link_speed_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[9]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${link_speed_locator}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'${link_speed}')]  10  2
    ${iq_compression_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-datatable-table ng-star-inserted')]/tbody/tr[${tr}]/td[10]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${iq_compression_locator}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'${iq_compression}')]  10  2
    Log  All parameters for cablink are set. [OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Add_Update_delete_cable_link_in_step_by_step_view


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
