*** Settings ***
Documentation       Test suite for CM__CB009829_001-004 NFTA
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${RECOVERY_FLAG}      ${False}

*** Keywords ***
CM__CB009829_001-004_Modification_Parameter_Trigger_Rat_Reset
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.12.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Perform RatReset Parameter
    Step 2: Check LTE RatReset
    #Step 2: Check NR RatReset
    #Step 2: Check LTE_NR RatReset
    Step 3: Parameter Is Modified

Step ${index}: Perform RatReset Parameter
    Log To Console    Step ${index}: Perform RatReset Parameter
    @{para_list}    Create List    actDualStackIpV4V6ForS1X2    #actFdmUeSkippingOlc      #maxTimeSctpSetup
    @{mo_list}    Create List    MRBTS-37376/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1     #MRBTS-37376/LNBTS-37376/SCTP-1
    @{value_list}    Create List    true     #200    #true    true
    Set Test Variable    ${para_list}
    Set Test Variable    ${mo_list}
    Set Test Variable    ${value_list}
    ${origin_value}    Parameter Operation    operation=parameter_value_check    product_type=enb
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    #${origin_value}    Set Variable    ${origin_value["${mo_list[0]}"]["${para_list[0]}"]}
    Set Test Variable    ${origin_value}
    ${out}    Parameter Operation    operation=parameter_update    product_type=enb
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    Wait Until Keyword Succeeds    10 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check ${Rat} RatReset
    Log To Console    Step ${index}: Check ${Rat} RatReset
    Run Keyword If    '${Rat}'=='LTE'
    ...    Verify RATs State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_rat_reset.ims2    LTE
    ...    ELSE IF    '${Rat}'=='NR'
    ...    Verify RATs State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_rat_reset.ims2    NR
    ...    ELSE IF    '${Rat}'=='LTE_NR'
    ...    Verify RATs State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_rat_reset.ims2    LTE    NR
    Set Test Variable    ${Rat}

Step ${index}: Parameter Is Modified
    Log To Console    Step ${index}: Parameter Is Modified
    ${current_value}    Get Parameter Value From WebEM    ${mo_list[0]}    ${para_list[0]}
    Should Be Equal As Strings    ${current_value}    ${value_list[0]}
    Return From Keyword If    '${Rat}'!='LTE_NR'
    ${current_value}    Get Parameter Value From WebEM    ${mo_list[1]}    ${para_list[1]}
    Should Be Equal As Strings    ${current_value}    ${value_list[1]}


SetUp
    Log To Console    SetUp
    Common Test Setup SBTS

TearDown
    Log To Console    TearDown
    coam.perform_parameter_recommissioning    ${mo_list[0]}    ${para_list[0]}    update    ${origin_value["${mo_list[0]}"]["${para_list[0]}"]}
    Run Keyword If    '${Rat}'=='LTE_NR'    coam.perform_parameter_recommissioning
    ...    ${mo_list[1]}    ${para_list[1]}    update    ${origin_value["${mo_list[1]}"]["${para_list[1]}"]}
    Common Test Teardown SBTS


