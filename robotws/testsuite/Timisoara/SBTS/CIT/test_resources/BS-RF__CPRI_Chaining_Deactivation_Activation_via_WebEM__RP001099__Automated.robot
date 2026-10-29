*** Settings ***
Documentation
    ...  The main goal of this TC is to check if activation/deactivation of RF chaining feature flag -> actRfChaining from WebEm is working on CPRI
    ...  configuration.
    ...  If actRfChaining flag is set to false then faultId 4084: "Feature Activation is missing" should be reported on second and next RMOD(s)
    ...  connected in chain on configuration.
    ...  First RMOD(s) in chaining cannot report any fault and should be operational.
    ...  TC recognizes all chains in configuration and prints them in step one. First RMOD(s) in chain is marked as (M).

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15191
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-15191 - Initial creation
    ...  - 13.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17155 - Enhancement related with change in dictionary returned from Get SFP Links
    ...  - 08.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18102 - Add support for new TRUNK builds (change in KW "Get Cell List" output)
    ...  - 18.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-BS-RF  OWNER-mateusz.kawka@nokia.com  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com  GROUP_IN_CHARGE-WRO_3_Vrf
    ...  PHASE-CIT  SW-SBTS18A  FEATURE-RP001099_1_FD2  FEATURE-RP001099_1_FC2

    Step1: Check RMODs In Chain(s)
    Step2: Deactivate RF Chaining And Check Fault
    Step3: Activate RF Chaining And Check Fault


Step1: Check RMODs In Chain(s)
    Log To Console  ------------------------------
    Log To Console  Step1: Check RMODs In Chain(s)
    Log To Console  ------------------------------${\n}
    ${links_type}  Create List
    ${smod_for_master}  Create List
    ${possible_master}  Create List
    ${master_rmod_in_chain}  Create List
    ${master_distnames}  Create List
    ${bts_id}  Admin Get Bts Id
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${sfp_links}  Get SFP Links
    ${var_status}  Run Keyword And Return Status
    ...  Variable Should Exist  ${sfp_links['connected']}
    Run Keyword If  ${var_status}
    ...  Set Test Variable  ${sfp_links}  ${sfp_links['connected']}
    ...  ELSE
    ...  Set Test Variable  ${sfp_links}  ${sfp_links}
    FOR  ${link}  IN  @{sfp_links}
        Continue For Loop If  'RMOD' not in '${link['data']['linkPorts']['destination']}'
        ${destination}  Set Variable  ${link['data']['linkPorts']['destination']}
        Append To List  ${possible_master}  ${destination}
    END
    Run Keyword If  '${destination}'!='${EMPTY}'
    ...  Log To Console  Chaining was detected in the configuration!${\n}
    ...  ELSE
    ...  Set Test NoRun  No chaining in the configuration, test set Norun !
    ${possible_master_name}  Evaluate  [y for x in ${possible_master} for y in x.split('/')[:-1]]
    Set Test Variable  ${MASTER_RMOD_IN_CHAIN}  ${master_rmod_in_chain}
    Set Test Variable  ${SMOD_FOR_MASTER}  ${smod_for_master}
    Set Test Variable  ${LINKS_TYPE}  ${links_type}
    Set Test Variable  ${MASTER_DISTNAMES}  ${master_distnames}
    FOR  ${master_name}  IN  @{possible_master_name}
        ca_CIT_general.Find A Master RMOD In Chain  ${master_name}
    END
    ${master_rmod_in_chain}  Evaluate  [y for x in ${MASTER_RMOD_IN_CHAIN} for y in x.split('/')[:-1]]
    ${master_rmod_in_chain}  Remove Duplicates  ${master_rmod_in_chain}
    ${master_distnames}  Remove Duplicates  ${MASTER_DISTNAMES}
    ${master_rmods_id}  Evaluate  [y for x in ${master_rmod_in_chain} for y in x.split('(')[:-1]]
    ${dict_of_masters}  Evaluate  ({i:[] for i in ${master_rmod_in_chain}})
    ${smod_for_master}  Evaluate  [y for x in ${SMOD_FOR_MASTER} for y in x.split('/')[-2:-1]]
    ${masters_to_print}  Evaluate  (' and '.join(${master_rmod_in_chain}))
    ${links_type}  Evaluate  [link.replace('RP3_01Link','OBSAI').replace('CPRILink','CPRI') for link in ${LINKS_TYPE}]
    Set Test Variable  ${MASTER_RMOD_IN_CHAIN}
    Set Test Variable  ${MASTER_RMODS_ID}
    Set Test Variable  ${MASTER_DISTNAMES}
    Run Keyword If  'CPRI' in ${links_type}
    ...  Log To Console  At least one CPRI link was found between SMOD and first RMOD in chain !
    ...  ELSE
    ...  Set Test NoRun  Cannot find CPRI link between SMOD and first RMOD in chain, test set Norun !
    Run Keyword If  len(${MASTER_RMOD_IN_CHAIN})!=0
    ...  Log To Console  First RMOD(s) found in configuration: ${masters_to_print}${\n}
    ...  ELSE
    ...  Set Test NoRun  Cannot found first RMOD in configuration, test set  Norun !
    FOR  ${master}  IN  @{dict_of_masters.keys()}
        ${second_rmod_in_chain}  Find A Second RMOD In Chain  ${master}
        Set To Dictionary  ${dict_of_masters}  ${master}  ${second_rmod_in_chain}
    END
    ${count}  Set Variable  ${0}
    Log To Console  Detected chain(s) in configuration:${\n}
    FOR  ${master}  ${next_rmod}  IN ZIP  ${dict_of_masters.keys()}  ${dict_of_masters.values()}
        Find A Next RMOD In Chain  ${next_rmod}
        ${chain}  Evaluate  ('-->'.join(${next_rmod}))
        Log To Console  ${count+1}. |${links_type}[${count}]| ${smod_for_master}[${count}]-->${master}(M)-->${chain}
        ${count}  Set Variable  ${count+1}
    END
    Log To Console  ${\n}RMOD(s) from above chain(s) on which the alarm raise will be checked:${\n}
    ${list_of_rmods_to_check_fault}  Create List
    ${count}  Set Variable  ${0}
    FOR  ${master}  ${next_rmod}  IN ZIP  ${dict_of_masters.keys()}  ${dict_of_masters.values()}
        Continue For Loop If  '${links_type}[${count}]'!='CPRI'
        ${rmod_for_alarm}  Evaluate  (','.join(${next_rmod}))
        Append To List  ${list_of_rmods_to_check_fault}  ${next_rmod}
        Log To Console  ${count+1}. ${rmod_for_alarm}
        ${count}  Set Variable  ${count+1}
    END
    ${list_of_rmods_to_check_fault}  Evaluate  [ item for sublist in ${list_of_rmods_to_check_fault} for item in sublist ]
    ${list_of_rmods_to_check_fault}  Evaluate  [y for x in ${list_of_rmods_to_check_fault} for y in x.split('(')[:-1]]
    Set Test Variable  ${LIST_OF_RMODS_TO_CHECK_FAULT}  ${list_of_rmods_to_check_fault}


Step2: Deactivate RF Chaining And Check Fault
    Log To Console  ${\n}---------------------------------------------
    Log To Console  Step2: Deactivate RF Chaining And Check Fault
    Log To Console  ----------------------------------------------${\n}
    Perform ActRfChaining Recommissioning  false
    ${len_of_rmods_to_check_fault}  Evaluate  len(${LIST_OF_RMODS_TO_CHECK_FAULT})
    Log To Console  Checking the occurence of ${len_of_rmods_to_check_fault} fault(s) 4084 !${\n}
    Sleep  15s
    Verify Number Of FaultId 4084  true  ${len_of_rmods_to_check_fault}
    FOR  ${master_distname}  ${master_name}  ${master_rmod_id}  IN ZIP  ${MASTER_DISTNAMES}  ${MASTER_RMOD_IN_CHAIN}  ${MASTER_RMODS_ID}
        Check If Cells On First RMOD Are OnAir  ${master_distname}  ${master_name}  ${master_rmod_id}
    END


Step3: Activate RF Chaining And Check Fault
    Log To Console  ${\n}--------------------------------------------
    Log To Console  Step3: Activate RF Chaining And Check Fault
    Log To Console  --------------------------------------------${\n}
    Perform ActRfChaining Recommissioning  true
    Sleep  15s
    Verify Number Of FaultId 4084  false  0
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  60x  5s
    ...  Check If All Cells Are OnAir
    Run Keyword If  '${status}'=='False'
    ...  Fail  At least one cell is NOT onAir after recommissioning actRfChaining to true! Set test failed !
    ...  ELSE
    ...  Log To Console  All cells are onAir, TC passed !${\n}


TC Setup
    Common Test Setup  tc_name=BS_RF__CPRI_Chaining_Deactivation_Activation_via_WebEM


TC Teardown
    Common Test Teardown
