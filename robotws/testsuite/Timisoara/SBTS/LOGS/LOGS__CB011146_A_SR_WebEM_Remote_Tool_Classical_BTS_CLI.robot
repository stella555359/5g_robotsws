*** Settings ***
Documentation    RestApi legacy for CB011146_SR_A
Library     ../../resources/python_resources/admin_cli.py  WITH NAME  hran_admin_cli
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***

${OnAir_LTE_cells_expected_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${OnAir_WCDMA_cells_expected_states}=  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${OnAir_GSM_cells_expected_states}=   administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                               blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${DEGRADED_CELL_REGEX}=               availabilityStatus=regex"(?i)Degraded"

${MSM_IP}                  192.168.255.129
${SSHusername}              toor4nsn
${SSHpassword}              oZPS0POrRieRtu

${flag1}                     0x450040
${flag_with_desired_value1}  0x450040 = 1

${flag2}                     0xA80000
${flag_with_desired_value2}  0xA80000 = 1

${flag3}                     0x450027
${flag_with_desired_value3}  0x450027 = 1
${alias}     default

*** Keywords ***
TC__LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI

    Step 0: Preconditions
    Step 1: Get Cell List
    Step 2: Get Cell Status
    Step 3: Get RMOD Status


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 0: Preconditions    console=${True}
    sleep    4

    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}    ${btsid}
    Prepare SWconfig    ${flag1}    ${flag_with_desired_value1}
    log  \nFlag 0x450040 = 1 was successfully added in the SW config  console=${True}
    Prepare SWconfig    ${flag2}    ${flag_with_desired_value2}
    log  \nFlag 0xA80000 = 1 was successfully added in the SW config  console=${True}
    Prepare SWconfig    ${flag3}    ${flag_with_desired_value3}
    log  \nFlag 0x450027 = 1 was successfully added in the SW config  console=${True}
    log  \nReset ongoing in order to apply changes made in SWconfig  console=${True}
    coam.Reset Site  600
    Wait Until Keyword Succeeds  15m  1m  Check All Modules And All Cells Working States

Step 1: Get Cell List
    [Documentation]
    ...   In this step GNCELL, WNCELL and LNCELL are checked

    Log    \nStep 1: Get Cell List    console=${True}
    sleep    4


    ### 1.LNCELL
    ${cell_LNCEL_list}=    coam.Get Ids For All    LNCEL   timeout=120
    ${list_with_LNCEL_number_id}=    Create list
    FOR  ${lncel_cell}  IN  @{cell_LNCEL_list}
         ${LNCEL_cell_number}    Fetch From Right  ${lncel_cell}  -
         Append To List    ${list_with_LNCEL_number_id}    ${LNCEL_cell_number}
    END

    ${isEmpty}  Get length  ${list_with_LNCEL_number_id}
    Run Keyword If  ${isEmpty}!=0    Log    LNCELL exist
    ...    ELSE  verdicts.Set Test Failed  TC need LTE cells  ${TRUE}


    ### 2.WNCELL
#    ${cell_WNCEL_list}=    coam.Get Ids For All    WNCEL   timeout=120
#    ${list_with_WNCEL_number_id}=    Create list
#    FOR  ${wncel_cell}  IN  @{cell_WNCEL_list}
#         ${WNCEL_cell_number}    Fetch From Right  ${wncel_cell}  -
#         Append To List    ${list_with_WNCEL_number_id}    ${WNCEL_cell_number}
#    END
#
#    ${isEmpty}  Get length  ${list_with_WNCEL_number_id}
#    Run Keyword If  ${isEmpty}!=0    Log    WNCELL exist
#    ...    ELSE  verdicts.Set Test Failed  TC need WCDMA cells  ${TRUE}


    ### 3.GNCEL
    ${cell_GNCEL_list}=    coam.Get Ids For All    GNCEL   timeout=120
    ${list_with_GNCEL_number_id}=    Create list
    FOR  ${gncel_cell}  IN  @{cell_GNCEL_list}
         ${GNCEL_cell_number}    Fetch From Right  ${gncel_cell}  -
         Append To List    ${list_with_GNCEL_number_id}    ${GNCEL_cell_number}
    END

    ${isEmpty}  Get length  ${list_with_GNCEL_number_id}
    Run Keyword If  ${isEmpty}!=0    Log    GNCELL exist
    ...    ELSE  verdicts.Set Test Failed  TC need GSM cells  ${TRUE}


Step 2: Get Cell Status
    [Documentation]
    ...   In this step Get Cell Status for each cell is checked

    Log    \nStep 2: Get Cell Status    console=${True}
    sleep    4

    Wait Until Keyword Succeeds  20m  30s  Check All Cells Working States


Step 3: Get RMOD Status
    [Documentation]
    ...  In this step test check if supported radio from list are in available state

    Log     \nStep 3: Get RMOD Status  console=${True}
    sleep    4

    ${list_of_rmods}    coam.Get Parameters For All    RMOD

    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${serial_number}    Get From Dictionary    ${radio_module}    serialNumber
        ${product_name}    Get From Dictionary    ${radio_module}    productName
        ${rmod_id}    Get From Dictionary   ${radio_module}    id
        Wait Until Keyword Succeeds    30 min    10 s    pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled
        Log    \n${product_name} with SN ${serial_number} is available    console=${TRUE}
    END


Check All Cells Working States
    [Documentation]
    ...  This keyword checks that all cells (2G, 3G and 4G) reached working status

    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...    coam.Assert Every    LNCEL    ${OnAir_LTE_cells_expected_states}
    ...    AND
    ...    coam.Assert No  LNCEL  ${DEGRADED_CELL_REGEX}

    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...    coam.Assert Every    GNCEL    ${OnAir_GSM_cells_expected_states}
    ...    AND
    ...    coam.Assert No  GNCEL  ${DEGRADED_CELL_REGEX}

    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...    coam.Assert Every    WNCEL    ${OnAir_WCDMA_cells_expected_states}
    ...    AND
    ...    coam.Assert No  WNCEL  ${DEGRADED_CELL_REGEX}

Prepare SWconfig
    [Arguments]  ${flag}    ${flag_with_desired_value}
    [Documentation]
    ...  This KW is checking if ${flag} exist in SWconfig on  MSM . If yes, it is changed to ${flag_with_desired_value} value.
    ...  If ${flag} doesn't exist in SWconfig, it is being added.

    SSH Connection
    ###Prepare SWconfig file for MSM
    ${swconfig_MSM}=  ssh.Execute  grep ${flag} /ffs/run/swconfig.txt  connection=${alias}
    ${swconfig_MSM}=  Strip String  ${swconfig_MSM}
    ${flag_exist}=  Evaluate  "${flag}" in """${swconfig_MSM}"""
    Run Keyword If  ${flag_exist}  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}
    ...  AND  Change Flag  ${alias}    ${flag}    ${flag_with_desired_value}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}  ""
    ...  AND  Add Flag  ${alias}   ${flag_with_desired_value}

#    log  Reset ongoing in order to apply changes made in SWconfig  console=${True}
#    coam.Reset_site
#    Wait Until Keyword Succeeds  15m  1m  Check All Modules And All Cells Working States
    ssh.Disconnect  ${alias}


Add Flag
    [Documentation]
    ...  This KW is adding ${flag_with_desired_value} to SWconfig file
    [Arguments]  ${SMOD_Connection}    ${flag_with_desired_value}
    ssh.Execute  command=echo ${flag_with_desired_value} >> /ffs/run/swconfig.txt  connection=${SMOD_Connection}

Change Flag
    [Documentation]
    ...  This KW is checking on which line is ${flag} in SWconfig and replaces that line with ${flag_with_desired_value}
    [Arguments]  ${SMOD_Connection}    ${flag}    ${flag_with_desired_value}
    ${flag_line_nr}=  ssh.Execute  grep -n '${flag}' /ffs/run/swconfig.txt | awk -F: '{print $1}'  connection=${SMOD_Connection}
    ${flag_line_nr}=  Strip String  ${flag_line_nr}
    ssh.Execute  command=sed -i '${flag_line_nr}s/.*/${flag_with_desired_value}/' /ffs/run/swconfig.txt  connection=${SMOD_Connection}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
