*** Settings ***
Documentation    TC__RRM__RFS__STATE__Check_Hanging_Resources_Taf_Ue
Variables    tc_variables/RRM__RFS__STATE__Check_Hanging_Resources_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${UEs_CAPABILITIES_LIST}    None     # List of labels used to identify all specific ues defined in yaml config  to be detached;, separrated by space
                                    # (from yaml CAPABILITIES); Default value: None
                                    # (no UE will be detached, only Hanging Resources Check will be performed)

*** Keywords ***
TC__RRM__RFS__STATE__Check_Hanging_Resources_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25048
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing hanging resources check for NR and LTE
    ...
    ...
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  - UEs_CAPABILITIES_LIST ----   List of labels used to identify all specific ues defined in yaml config  to be detached;, separrated by space
    ...                                (from yaml CAPABILITIES); Default value: None
    ...                                (no UE will be detached, only Hanging Resources Check will be performed)
    ...
    ...  ******************
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 05.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25048 - RRM__RFS__STATE__Check_Hanging_Resources_Taf_Ue - test delivery
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27717 - [Cloud][RF5] Update robotws testcases - NRL, NR_NR, NR_SBTS, RRM, PM, LOGS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25048_RRM__RFS__STATE__Check_Hanging_Resources_Taf_Ue.png


    Set Tags    CA-RRM    OWNER-petru.hinsa@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS23R3

    Step 1: Detach All UEs if present
    Step 2: Check Hanging Resources
    Step 3: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Detach All UEs if present
    Log  Step ${index}: Detach All UEs if present  console=True
    Run Keyword If  '${UEs_CAPABILITIES_LIST}'=='None'  Run Keywords
    ...  Log    As UEs_CAPABILITIES_LIST=None, no detach will be performed!  console=True
    ...  AND  Return From Keyword
    ${detached_ue_aliases}=  Taf Ue Detach Multiple UEs  ${UEs_CAPABILITIES_LIST}
    Set Test Variable  ${detached_ue_aliases}
    Log  Waiting 30 seconds after UE detach(es) for the resources to be released...  console=True
    Sleep  30s

Step ${index}: Check Hanging Resources
    Log  Step ${index}: Check Hanging Resources  console=True
    FOR  ${alias}  IN  @{alias_list}
       Check Hanging Resources on ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check Hanging Resources on ${alias}
    ${tech}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH]
    ${hop}=  Set Variable If  'Slave' in '${alias}'  True  False
    Log  Checking Hanging Resources on ${alias} BTS - ${tech}  console=True
    ${status_resources}=  Run Keyword If  '${tech}'=='NR'  Taf Ue Check Hanging Resources  NR  ${hop}  ${alias}
    ...  ELSE IF  '${tech}'=='LTE'  Taf Ue Check Hanging Resources  LTE  ${hop}  ${alias}
    ...  ELSE IF  '${tech}'=='SBTS'  Particular SBTS check Hanging Resources  ${alias}
    Run Keyword If  '${tech}' in ['NR','LTE','SBTS'] and not ${status_resources}   Fail  Hanging Resources have been found!
    ...  ELSE IF  '${tech}' in ['NR','LTE','SBTS']  Log  Hanging Resources Check Passed!  console=True
    ...  ELSE  Log  No NR/LTE/SBTS found on BTS ${alias}, Hanging Resources check was skipped!  console=True

Particular SBTS check Hanging Resources
    [Arguments]  ${alias}=Master
    ${hop}=  Set Variable If  '${alias}'=='Master'  False  True
    ${NR_cells_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_cells_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${status_resources}=  Run Keyword If  ${NR_cells_list} and ${LTE_cells_list}  Taf Ue Check Hanging Resources  NR_LTE  ${hop}  ${alias}
    ...  ELSE IF  ${NR_cells_list} and not ${LTE_cells_list}  Taf Ue Check Hanging Resources  NR  ${hop}  ${alias}
    ...  ELSE IF  not ${NR_cells_list} and ${LTE_cells_list}  Taf Ue Check Hanging Resources  LTE  ${hop}  ${alias}
    ...  ELSE  Log  No NR/LTE found on SBTS, Hanging Resources check was skipped!  console=True
    [Return]  ${status_resources}

Reattach all UEs that were detached during test execution
    Run Keyword If  '${UEs_CAPABILITIES_LIST}'=='None'  Run Keywords
    ...  Log  As UEs_CAPABILITIES_LIST=None, no detach was performed, so no re-attach is necessary!  console=True
    ...  AND  Return From Keyword
    FOR  ${ue_alias}  IN  @{detached_ue_aliases}
        Log  Re-Attaching UE identified by capability ue_alias=${ue_alias}  console=True
        taf.ue.Attach UE  ue_alias=${ue_alias}
    END

Particular teardown
    Run Keyword And Continue On Failure  Reattach all UEs that were detached during test execution

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown