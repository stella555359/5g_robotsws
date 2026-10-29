*** Settings ***
Documentation    TC__Test_line_Recover_BTS
Variables    tc_variables/Test_line__Recover_BTS.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Resource    ../../resources/rfs_recovery_soam.robot

*** Variables ***
${RECOVERY_ACTION}    SITE_RESET   # RECOVERY_ACTION can be 'SITE_RESET' or 'POWER_RESET'. If Reset recovery is failing Power recovery is done.
                                  # Default option is 'SITE_RESET'


*** Keywords ***
TC__Test_line_Recover_BTS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-4155
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test for recovering test line.
    ...
    ...  Following recovery actions are possibe:
    ...  Case 1) Site RESET action is performed as recovery, if reset action or recovery is unsuccessful, Power Off/On recovery action is performed.
    ...  Default Case.
    ...  Parameters: ${RECOVERY_ACTION}=  SITE_RESET
    ...  Case 2) Only Power Off/on action is performed as recovery.
    ...  Parameters: ${RECOVERY_ACTION}=  POWER_RESET
    ...
    ...  Site Reset Recovery action is performed based on TL configuration:
    ...   - TL without Airscale configuration: Reset BTS Master and this will trigger automatically Reset BTS Slave.
    ...   - TL with Airscale configuration: Reset BTS Master followed by Reset BTS Slave
    ...  Success of Reset action is checked on both Master and Slave.
    ...  Power Recovery action is done on both Master and Slave.
    ...  Recovery result is checked on both Master and Slave.
    ...  Recovery test works on RFS NRL, WL, WG, LG, SBTS_GSM and NR_SBTS test lines
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.10.2016 - https://jiradc.ext.net.nokia.com/browse/TAT-4155 - TC creation
    ...  - 24.10.2016 - https://jiradc.ext.net.nokia.com/browse/TAT-4151 - Set preconditions for TC to false
    ...  - 16.11.2016 - https://jiradc.ext.net.nokia.com/browse/TAT-4662 - Changes related with resources refactor
    ...  - 02.03.2016 - https://jiradc.ext.net.nokia.com/browse/TAT-5711 - Enhance for AIRSCALE support
    ...  - 27.07.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-7012 - Refactor RFS TCs and resources to get variable directly from YAML
    ...  - 01.11.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-8204 - Update the precondition for the existing robots of all technologies peer
    ...  - 26.01.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-7841 - Unified test format: Run Cycle, indentation and repeat variable
    ...                                                                   REPEAT_COUNTER
    ...  - 19.03.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-9359 - Collect snapshot after any recovery test performed
    ...  - 03.08.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-11171 - Prefix all Test Cases inside all robots with [1]
    ...                                                                    to match the QC instances names
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...
    ...  - 23.03.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-9446 - [RFS_SOAM] [P1.1 ]New TCs Test Line Recovery for RFS LTE _SOAM architecture
    ...  - 23.04.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-9833 - [RFS_SOAM]TESTLine Recovery for SOAM Keyword name misspelled:
    ...                                                                   Pass "Executio"
    ...  - 18.10.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-12343 - Replace the check of GSM reachability/non-reachability -
    ...                                                                    perform it from GSM Windows PC instead of VM2
    ...  - 26.10.2018 - https://jiradc.ext.net.nokia.com/browse/TAT-12842 - Update recovery test to take into account TAT-12553
    ...  - 09.07.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-16819 - Enhancement for Test_line__Recover_BTS --- Add Unlock all GSM TRXs from
    ...                                                                    BSC
    ...  - 04.09.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-17317 - Update Test_line__Recover_BTS.robot from RFS_SOAM for NR technology
    ...  - 11.12.2019 - https://jiradc.ext.net.nokia.com/browse/TAT-18536 - Update Test_line__Recover_BTS.robot from RFS_SOAM for SBTS configuration
    ...  - 05.04.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20862 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - SBTS_GSM, RRM,
    ...                                                                    Recovery
    ...  - 03.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27196 - [5G] Include SCF validation with hardware check in common test setup
    ...  - 24.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30179 - [Infomodel] Remove infomodel usage in test-cases
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/TAT_4155_Test_line__Recover_BTS.png


    Set Tags    CA-OAM    OWNER-oana.bonchis@nokia.com    AUTHOR-ana.tugui@nokia.com    PHASE-CR1    SW-SBTS18,WBTS18,BTS18
    ...    CABLING-RFS_01_UE

    Trigger Recovery Action RFS SOAM  ${RECOVERY_ACTION}

TC Setup
    Common Test Setup  PrecheckConf=${FALSE}  PrecheckCells=${FALSE}  PrecheckModules=${FALSE}  PrecheckSCF=${FALSE}  infomodelSetup=${FALSE}
    ...  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown


