*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008124 step -CA
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 15-May-2023
...               Last Modified by            : Yann HERVE
...               Modification:
...                       15-May-2022         | Creation

Resource                         ./CB008124_keywords.robot
Resource                         ../../../../../resources/SWENG/robot/KPIs.robot
Resource                         ../../../../../resources/SWENG/robot/Counters.robot


*** Variables ***
${delta_file_cb008124_CA_linkAdapt}             testsuite/Paris/RRM/ET/CB008124/config/Delta_Configuration_scf_CA_linkAdaptation.json
${cb008124_CA_link_adapt_constraints}           testsuite/Paris/RRM/ET/CB008124/config/CB008124_CA_linkAdapt_constraints.csv

${gnb_alias}                                    gnb_under_test

# UL throughput in kbps. It's a bit higher than grantedPacketSize*8/ULCG period
# => 1200*8*1000/10 = 960 kbps
${UL_throughput}                                1
# GP duration in seconds (hardcoded)
${gp_duration}                                  300
${TputVolMargin}                                5

${rdEnableCGTrafficOverwriting}                 0x5806E0
${rdEnableCGLinkAdaptation}                     0x5806E8
${rdEnableCgAdjustment}                         0x580709

${cell_noise_level}                             -710
${sinr_initial_target}                          -50
${sinr_step}                                    10
${sinr_nb_steps}                                20
${sinr_step_duration}                           4

${ULCG_modification_attempts}                   M55308C00024
${ULCG_modification_success}                    M55308C00025
${NRCELL_ID}                                    1

*** Keywords ***

CB008124_TC_CA_103_B1_CG_deactivation_bad_radio_conditions
    ${duplexModeTC}               Set Variable       FDD
    set Suite Variable            ${duplexModeTC}

    CB008124 Create UECG UEnonCG      nbUECG=1

    Dated Log                     ${trcColor}---> Starting gNB commissioning ${defColor}
    # Set -CA -CB and cgAdjustement RAD param. At the end it should be enabled by default
    # Once it's the case, this part may be removed.
    ${radp_linkAdapt}             Create Dictionary    field=${rdEnableCGLinkAdaptation}              value=1
    ${radp_cgOW}                  Create Dictionary    field=${rdEnableCGTrafficOverwriting}          value=1
    ${radp_cgAdjust}              Create Dictionary    field=${rdEnableCgAdjustment}                  value=1
    ${list_rad_param}             Create List          ${radp_linkAdapt}    ${radp_cgOW}    ${radp_cgAdjust}
    Set Fields in swconfig DU     param_list=${list_rad_param}

    CB008124 Add RD Parameter in AP SWCconfig

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias}

    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${delta_file_cb008124_CA_linkAdapt}
    ...                           connection=${gnb_alias}
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    sbts_coam.teardown            connection=${gnb_alias}
    Dated log                     ${trcColor}---> Restart TL ${defColor}
    Restart TL

    CB008124 cell setup
    # Cellsetup is now done, Sherpa can be enabled if needed
    Run Keyword If                ${enable_sherpa} == ${True}           Activate Sherpa

    ${zoi}                      ZOI Start
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    # In order to have a complete GP, the script waits for the beginning of the next GP
    # before starting the scenario.
    Traced Sleep                  ${start_loop_remaining} seconds
    ...                           msg=Waiting ${start_loop_remaining} seconds before starting scenario

    CB008124 Attach               ueSetting=${BASIC_UE_SA}

    Dated Log New Line            ${trcColor}=== Start UL traffic ===${defColor}
    Traffic UE UL                 ueSetting=${BASIC_UE_SA}
    ...                           throughput=${UL_throughput}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    # Degrade radio conditions to trigger ULCG modifications and MCS/PRB changes
    # up to ULCG deactivation when it's no more possible to find a suitable MCS/PRB:

    # Add background cell noise:
    wtsemu.ul_cell_noise_testmode_nr      profile_id=1
    ...                                   noise_pusch=${cell_noise_level}

    wtsemu.cell_testmode_set_nr           cell_id=${FDD_Cell_list[0].nrCellId}
    ...                                   gnb=2
    ...                                   testmode=ul_cell_noise
    ...                                   profile_id=1
    ...                                   action=activate

    # Define and activate UL SINR profile
    wtsemu.ul_sinr_testmode_nr            profile_id=1
    ...                                   sinr_target_pusch=${sinr_initial_target}

    wtsemu.ue_testmode_set_nr             id=${BASIC_UE_SA.ue}
    ...                                   testmode=ul_sinr
    ...                                   profile_id=1
    ...                                   action=activate

    Dated Log                             ${trcColor}=== Starting UL SINR decrease ===${defColor}
    ${sinr_target}                        Evaluate      ${sinr_initial_target}
    FOR        ${i}      IN RANGE         ${sinr_nb_steps}

        wtsemu.ul_sinr_testmode_nr       profile_id=1
        ...                              sinr_target_pusch=${sinr_target}

        Dated Log                        UL SINR target is now:
        Dated Log                        sinr_target_pusch : ${sinr_target}
        Dated Log                        noise_pusch: ${cell_noise_level}

        Traced Sleep                     ${sinr_step_duration}

        ${sinr_target}                   Evaluate    ${sinr_target} - ${sinr_step}

    END

    Traced Sleep                        10

    Dated Log                            ${trcColor}=== Starting UL SINR increase ===${defColor}
    FOR        ${i}      IN RANGE         ${sinr_nb_steps}

        wtsemu.ul_sinr_testmode_nr       profile_id=1
        ...                              sinr_target_pusch=${sinr_target}

        Dated Log                        UL SINR target is now:
        Dated Log                        --> sinr_target_pusch : ${sinr_target}
        Dated Log                        --> noise_pusch: ${cell_noise_level}

        Traced Sleep                     ${sinr_step_duration}

        ${sinr_target}                   Evaluate    ${sinr_target} + ${sinr_step}

    END

    Traced Sleep                        10

    Dated Log New Line                  ${trcColor}=== Stop traffic ===${defColor}
    Traffic Stop                        ueSetting=${BASIC_UE_SA}             dir=ul

    # Disable AP tests mode
    wtsemu.ue_testmode_set_nr           id=${BASIC_UE_SA.ue}
    ...                                 testmode=ul_sinr
    ...                                 profile_id=1
    ...                                 action=deactivate

    wtsemu.cell_testmode_set_nr         cell_id=${FDD_Cell_list[0].nrCellId}
    ...                                 gnb=2
    ...                                 testmode=ul_cell_noise
    ...                                 profile_id=1
    ...                                 action=deactivate

    Dated Log New Line            ${trcColor}=== Detach UE ===${defColor}
    UE Deregister                 id=${BASIC_UE_SA.ue}

    Dated log New Line            ${trcColor}=== Starting collecting PM ===${defColor}
    ZOI Wait End                  zoi=${zoi}
    ${pm_path}                    Counters.Collect PM files from BTS    ${LOG_PATH}/PM

    # KPIs and counters checks
    ${pm_path}                    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    KPI Evaluate                  pmFile=${pm_path}
    ...                           constraintsFile=${cb008124_CA_link_adapt_constraints}
    ...                           failOnError=${True}

    #
    # Also check that :
    # M55308C00024	No of UL CG modification attempts
    #                       =
    # M55308C00025	No of successful UL CG modification attempts
    # to verify that ULCG modification works fine
    # Code copied/pasted from 5GC001227-Counters_keywords.robot
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    BuiltIn.Log                     The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${log_path_pm}
    BuiltIn.Log                     Latest pm counters file : ${pm_latest}

    ${Value_modifications_attempts}=            Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                         ${pm_latest}       ${ULCG_modification_attempts}      ${NRCELL_ID}

    ${Value_modifications_success}=             Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                         ${pm_latest}       ${ULCG_modification_success}       ${NRCELL_ID}

    Dated Log New Line              Number of modification attempts: ${Value_modifications_attempts}
    Dated Log                       Number of modification success: ${Value_modifications_success}
    Should Be True                  '${Value_modifications_attempts}' == '${Value_modifications_success}'
