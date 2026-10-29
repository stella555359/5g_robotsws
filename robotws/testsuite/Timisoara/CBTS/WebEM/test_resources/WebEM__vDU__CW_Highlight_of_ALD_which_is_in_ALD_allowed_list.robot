*** Settings ***
Documentation
    ...  This TC is created to do two operations.
    ...  First, it selects Radio Module and changes it's type.
    ...  Second, selects ALD subunit to verify if Radio Module is highlighted
    ...  and then selects ALD to verify if ALD subunit is highlighted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RMOD_TYPE}  AWHHH (475212A)  # Mandatory.Must be set with product code. E.g. AWHHH (475212A)


*** Keywords ***
TC__WebEM__vDU__CW_Highlight_of_ALD_which_is_in_ALD_allowed_list
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26636
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26636 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-C

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Select First Radio Module And Modify Type
    Step4: Highlight ALDs


Step0: TC Preconditions
    Log  \nStep0: TC preconditions.  console=true
    Set Nr Cell Id And Nrcell Group Id Depends On First RMOD
    ${alds_dns}  ${subunits_dns}  Find ALDs And Subunits Mapped On Given RMOD  ${RMOD_ID}
    ${ald_subunit_dn}  Evaluate  random.choice(${subunits_dns})  random
    Set Test Variable  ${ALD_SUBUNIT_DN}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Select First Radio Module And Modify Type
    Log  \nStep3: Select first Radio Module and modify type.  console=true
    ${configuration_button}  Catenate  SEPARATOR=  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}"]/ot-card/p-card
    ...  /div/div/div/div/div[1]/div[1]/div[2]/p-button[1]/button/span[1]
    Element Should Be Visible  ${configuration_button}  Configuration button not visible for RMOD-${RMOD_ID}. [NOK]
    Click Element  ${configuration_button}
    Element Should Be Visible  //*[contains(@class, 'mdi mdi-file-document-edit p-button-icon ng-star-inserted')]
    ...  Change button not visible for RMOD-${RMOD_ID}. [NOK]
    Wait Until Element Is Clicked  //*[contains(@class, 'mdi mdi-file-document-edit p-button-icon ng-star-inserted')]  10  2
    Scroll Element Into View  //span[contains(text(), "${RMOD_TYPE}")]
    Wait Until Element Is Clicked  //span[contains(text(), "${RMOD_TYPE}")]  10  2
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span  10  2
    ${type_button}  Catenate  SEPARATOR=  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}"]/ot-card/p-card
    ...  /div/div/div/div/div[1]/div[1]/div[2]/p-button[1]/button/span[1]
    Wait Until Keyword Succeeds  10s  2s
    ...  Element Should Be Visible  ${type_button}
    Log  Radio Module selected correctly. [OK]  console=true


Step4: Highlight ALDs
    Log  \nStep4: Highlight ALDs.  console=true
    Click Element  //*[@id="${ALD_SUBUNIT_DN}"]/div/div[5]
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID}"]/ot-card  class
    Wait Until Keyword Succeeds  30s  5s
    ...  Should Contain  ${rmod_class}
    ...  highlighted
    ...  RMOD-${RMOD_ID} was not highlighted after subunit with dist name: ${ALD_SUBUNIT_DN} was selected from site view!
    Click Element  //*[@id="${ALD_SUBUNIT_DN}"]/div/div[4]/span
    ${ret_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-1/RETU-1"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${ret_class}
    ...  highlighted
    ...  Subunit with dist name: ${ALD_SUBUNIT_DN} was not highlighted after ALD was selected from site view!


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Highlight_of_ALD_which_is_in_ALD_allowed_list


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
