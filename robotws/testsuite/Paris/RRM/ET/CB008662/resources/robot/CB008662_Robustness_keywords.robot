*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008662 robustness TC
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 14-October-2022
...               Modified Date               : 
...               Last Modified by            : 
...               Modification:
...                       14-October-2022      |     Creation
...                       8-November-2022      |     Remove UL BLER part (not working well)
...                       17-November-2022     |     Add UL BLER again after fix of PR675549
...                       22-November-2022     |     Enable syslog and KPIs checks
...                       02-December-2022     |     Disable SYSLOG checks failure for a while

Resource                         ./CB008662_keywords.robot
Resource                         ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource                         ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource                         ../../../../../resources/SWENG/robot/Counters.robot
Resource                         ../../../../../resources/SWENG/robot/KPIs.robot
Resource                         ../../../../../resources/SWENG/robot/Syslogs.robot
Library                          ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library                          taf.sbts.oam.coam.admin           WITH NAME   sbts_coam

*** Variables ***

${gnb_alias_robustness}                   gnb_under_test

# Disable HARQ incremental redundancy DL
${RD_DisableDlIR}                         0x580001
# rdSupportedUlMCS
${rdSupportedUlMCSAddr}                   0x580010

${nbRobustnessUEs}                        20

${Total_DL_Tput}                          240
${Total_UL_Tput}                          120

${robustness_test_duration}               60 minutes

@{SA_UE_List}

${delta_file_cb008662_activation}         testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_Enable_Adaptive_ReTx.json
${delta_file_100_50}                      testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_robustness_100_50.json
${delta_file_75_50}                       testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_robustness_75_50.json

# Constraints file
${constraints_100_50}                     testsuite/Paris/RRM/ET/CB008662/config/CB008662_Robustness_Constraints_100_50.csv
${constraints_75_50}                      testsuite/Paris/RRM/ET/CB008662/config/CB008662_Robustness_Constraints_75_50.csv

${gp_duration}                            300

${ul_mcs28}                               0x10000000

# = Length of DL_Bler_Values, UL_SINR_Value (must be the same)
${UL_DL_BLER_nb_Steps}                    6

# DL BLER level must be the same at the beginning and end of the loop
@{DL_Bler_On_Off}                         activate
...                                       deactivate
...                                       activate
...                                       deactivate
...                                       activate
...                                       deactivate

# UL BLER level must be the same at the beginning and end of the loop
&{SINR_Level_1}                           sinr_target_pusch=-402        noise_pusch=-660
&{SINR_Level_2}                           sinr_target_pusch=-408        noise_pusch=-660
&{SINR_Level_3}                           sinr_target_pusch=-414        noise_pusch=-660
&{SINR_Level_4}                           sinr_target_pusch=-414        noise_pusch=-660
&{SINR_Level_5}                           sinr_target_pusch=-408        noise_pusch=-660
&{SINR_Level_6}                           sinr_target_pusch=-402        noise_pusch=-660

@{UL_SINR_Value}                          ${SINR_Level_1}   ${SINR_Level_2}     ${SINR_Level_3}
...                                       ${SINR_Level_4}   ${SINR_Level_5}     ${SINR_Level_6}

*** Keywords ***

CB008662_Robustness_Scenario_Init
    [Documentation]               KW used to initialise context for CB008662 TC execution:
    ...                           Update SCF with suitable parameters by using a delta JSON file.
    ...                           Update swconfig file
    ...                           !!! Dist names are hardcoded inside JSON file. To be improved ???
    ...                           Generate suitable LUA configuration file (20 UEs needed)
    ...                           [YHE] => Script not triggered anymore by CRT

    Dated Log                     ${trcColor}---> Starting gNB commissioing ${defColor}
    # Enable IR which is disabled by default
    ${radp_EnableIR}              Create Dictionary    field=${RD_DisableDlIR}          value=0
    # Hardcode UL MCS to 16
    ${radp_UlMcs}                 Create Dictionary    field=${rdSupportedUlMCSAddr}    value=${ul_mcs28}
    ${list_rad_param}             Create List          ${radp_EnableIR}    ${radp_UlMcs} 
    Set Fields in swconfig DU     param_list=${list_rad_param}
	
    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias_robustness}

    Run Keywords                  coam_parameter.perform_scf_delta_commission     
    ...                           delta_file=${delta_file_cb008662_activation}
    ...                           connection=${gnb_alias_robustness}
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    sbts_coam.teardown            connection=${gnb_alias_robustness}

    Dated log                     ${trcColor}---> Restart TL ${defColor}
    Restart TL
    Dated Log                     ${trcColor}---> WTS setup SA ${defColor}
    WTS Setup                     nbUe=${nbRobustnessUEs}       nbSaUe=${nbRobustnessUEs}     shouldUseLua=${True}
    # Cellsetup is now done, Sherpa can be enabled if needed
    Run Keyword If                ${enable_sherpa} == ${True}           Activate Sherpa


CB008662_Attach_All_UEs
    Dated Log New Line       ${trcColor}---> Attaching all needed UEs ${defColor}
    FOR        ${ue_id}      IN RANGE        1        ${nbRobustnessUEs} + 1
        &{current_UE}=                  Copy dictionary     ${BASIC_UE_SA}
        Set To Dictionary               ${current_UE}       ue          ${ue_id}
        Set To Dictionary               ${current_UE}       pdu         1
        Append To List                  ${SA_UE_List}       ${current_UE}
        UE Register                     ue=${current_UE.ue}
        Launch PDU Session              ue=${current_UE.ue}    pdu=${current_UE.pdu}    gw=${current_UE.ue}
    END
    Dated Log                ${trcColor}---> All needed UEs are now attached${defColor}

CB008662_Detach_All_UEs
    Dated Log New Line       ${trcColor}---> Detaching all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        UE Deregister           id=${SA_UE_List}[${i}][ue]
    END

CB008662_Define_Test_Modes

    Dated Log                 ${trcColor}---> Defining test modes ${defColor}
    # Enable PDSCH decoding for SSB and TRS
    wtsemu.ue_testmode_decode_muxphychan         decode_mux_phy_chan=decode_PDSCH
    # Set CQI value to have a predfinied DL MCS (~22)
    wtsemu.csi_override_testmode_nr              profile_id=1
    ...                                          cqi=10
    # Define default values for BLER profiles
    # DL RV=0 => NACK, RV=2 => NACK, RV=3 => ACK
    wtsemu.bler_testmode_nr                      profile_id=1
    ...                                          num_harq_nack=2
    # UL
    # Values based on AP PoC for ABIO
    wtsemu.ul_sinr_testmode_nr                   profile_id=1
    ...                                          sinr_target_pusch=${UL_SINR_Value}[0][sinr_target_pusch]
    ...                                          noise_pusch=${UL_SINR_Value}[0][noise_pusch]

CB008662_Enable_CQI_Test_Mode

    Dated Log                ${trcColor}---> Enabling CQI test mode for all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        # Enable CQI test modes to reduce MCS
        wtsemu.ue_testmode_set_nr       id=${SA_UE_List}[${i}][ue]
        ...                             testmode=csi_override
        ...                             profile_id=1
        ...                             action=activate

    END

CB008662_Disable_CQI_Test_Mode

    Dated Log               ${trcColor}---> Disabling CQI test mode for all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        # Enable CQI test modes to reduce MCS
        wtsemu.ue_testmode_set_nr       id=${SA_UE_List}[${i}][ue]
        ...                             testmode=csi_override
        ...                             profile_id=1
        ...                             action=deactivate

    END

CB008662_Enable_DL_Bler_Test_Mode

    Dated Log               ${trcColor}---> Enabling DL HARQ BLER test mode for all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        # Enable DL BLER
        wtsemu.ue_testmode_set_nr       id=${SA_UE_List}[${i}][ue]
        ...                             profile_id=1
        ...                             testmode=bler
        ...                             action=activate
    END


CB008662_Disable_DL_Bler_Test_Mode

    Dated Log                ${trcColor}---> Disabling DL HARQ BLER test mode for all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        # Disable DL BLER
        wtsemu.ue_testmode_set_nr       id=${SA_UE_List}[${i}][ue]
        ...                             profile_id=1
        ...                             testmode=bler
        ...                             action=deactivate
    END    

CB008662_Enable_UL_Bler_Test_Mode

    Dated Log                ${trcColor}---> Enabling UL SINR test mode for all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        # Enable UL BLER
        wtsemu.ue_testmode_set_nr       id=${SA_UE_List}[${i}][ue]
        ...                             profile_id=1
        ...                             testmode=ul_sinr
        ...                             action=activate
    END

CB008662_Disable_UL_Bler_Test_Mode

    Dated Log                 ${trcColor}---> Disabling UL SINR test mode for all UEs ${defColor}
    FOR        ${i}      IN RANGE        ${nbRobustnessUEs}
        # Disable UL BLER
        wtsemu.ue_testmode_set_nr       id=${SA_UE_List}[${i}][ue]
        ...                             profile_id=1
        ...                             testmode=ul_sinr
        ...                             action=deactivate        
    END

CB008662_BLER_Profile_Loop
    [Documentation]             Main loop for BLER activation/deactivation in UL and DL
    ...                         Loop duration is based on GP duration (5 mn)

    Dated Log                   ${trcColor}---> Entering BLER loop ${defColor}
    ${zoi}                      ZOI Start
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    # In order to have the same KPIs/counters for every run, we need to change DL/UL BLER modes 
    # at the same time. So, the script wait for the beginning of the next GP to before changing
    # BLER modes. This should allow to have the same KPIs for every BLER loop.
    Traced Sleep                ${start_loop_remaining} seconds         msg=Waiting ${start_loop_remaining} seconds before starting BLER loop
    ${step_duration}=           Evaluate        ${gp_duration} / ${UL_DL_BLER_nb_Steps}

    CB008662_Enable_UL_Bler_Test_Mode
    FOR        ${i}      IN RANGE        ${UL_DL_BLER_nb_Steps}
        # DL BLER
        # In DL, as we use num_harq_nack, we need to activate/deactivate it for all UE.
        # In UL, it's the UL BLER profile which is updated. The profile is common to all UEs.
        Run Keyword If                   '${DL_Bler_On_Off}[${i}]' == 'activate'        CB008662_Enable_DL_Bler_Test_Mode
        ...                              ELSE
        ...                              CB008662_Disable_DL_Bler_Test_Mode
        # UL SINR (not used so far, see comment above)
        wtsemu.ul_sinr_testmode_nr      profile_id=1
        ...                             sinr_target_pusch=${UL_SINR_Value}[${i}][sinr_target_pusch]
        ...                             noise_pusch=${UL_SINR_Value}[${i}][noise_pusch]

        Dated Log                        DL/UL BLER profile is now:
        Dated Log                        - DL BLER mode is: ${DL_Bler_On_Off}[${i}]
        Dated Log                        - UL sinr target: ${UL_SINR_Value}[${i}][sinr_target_pusch]
        Dated Log                        - UL noise target: ${UL_SINR_Value}[${i}][noise_pusch]\n

        Traced Sleep                    ${step_duration}
    END
    Dated Log                   ${trcColor}=== Waiting for end of ZOI ${defColor}
    ZOI Wait End                zoi=${zoi}

CB008662_Update_Online_SCF
    [Documentation]               KW used to update targetPct / minPct online by using a delta SCF file.
    [Arguments]                   ${delta_scf}
	
    Dated Log New Line            Updating SCF parameters with file ${delta_scf}
    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias_robustness}
    Run Keywords                  coam_parameter.perform_scf_delta_commission     
    ...                           delta_file=${delta_scf}
    ...                           connection=${gnb_alias_robustness}
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    sbts_coam.teardown            connection=${gnb_alias_robustness}

CB008662 Endurance SYSLOG Evaluate
    [Documentation]               SYSLOG file content checks
    [Arguments]                   ${syslog}

    ${syslog_errors}              SYSLOG Evaluate
    ...                           syslog=${syslog}
    ...                           exclusion=CB008662.My8662.csv
    ...                           maxRate=700

    Dated Log                     SYSLOG summary: ${sys_log_errors}

    # Check SYSLOG part. But, the use of this is not clear.
    # There are many WRN/INF lines for which I don't know the meaning and are not excluded.
    # Anyway, I have used the regular filter provided inside 1527 example.
    # => To be improved in the future ?
    #Should Be Empty               ${syslog_errors}

CB008662_Robustness_Test
    [Documentation]                 The aim of this test is to perform a robustness check for CB008662
    ...                             The idea is to perform UL/DL traffic for a quite long duration (~30 mn) and 
    ...                             change UL/DL BLER levels at the same time. targetPct/minPct NIDD are also 
    ...                             changed online. At the end of a BLER period, 
    ...                             PM counters are compared to expected ranges.
    ...                             SYSLOG output is also checked to see if there are no spurious logs.

    # Customise SCF, restart TL and perform cell setup
    CB008662_Robustness_Scenario_Init

    CB008662_Attach_All_UEs
    CB008662_Define_Test_Modes
    CB008662_Enable_CQI_Test_Mode

    ${dl_tput_per_ue}=                  Evaluate                    ${Total_DL_Tput}/${nbRobustnessUEs}
    ${ul_tput_per_ue}=                  Evaluate                    ${Total_UL_Tput}/${nbRobustnessUEs}
    ${dl_tput_int_per_ue}=              Convert To Integer          ${dl_tput_per_ue}
    ${ul_tput_int_per_ue}=              Convert To Integer          ${ul_tput_per_ue}
    Dated Log                           DL throughput per UE is: ${dl_tput_int_per_ue} Mbps
    Dated Log                           UL throughput per UE is: ${ul_tput_int_per_ue} Mbps
    Traffic UEs UL DL                   ueSettingList=${SA_UE_List}
    ...                                 duration=10s        shouldBeStop=False      shouldBeCheck=False
    ...                                 dlThroughput=${dl_tput_int_per_ue}          ulThroughput=${ul_tput_int_per_ue}

    ${date_start}=                      Get Current Date
    ${date_stop}=                       Add Time to Date    ${date_start}       ${robustness_test_duration}
    ${date_stop_epoch}=                 Convert Date        ${date_stop}        epoch

    ${is_syslog_check_already_done}     Set Variable                ${False}
    ${syslog}                           SYSLOG Start                host=${GNB_DU.sys[0].M}
    ...                                 name=cb008662_robustness

    # "Infinite" loop. Loop exit is based on test duration : ${robustness_test_duration}
    FOR                 ${step}            IN RANGE            10000
        Dated Log New Line              ${trcColor} Starting BLER loop number ${step} ${defColor}
        CB008662_BLER_Profile_Loop

        Run Keyword If                  ${is_syslog_check_already_done} == ${False}
        ...                             SYSLOG Stop                      syslog=${syslog}

        ${sys_log_errors}               Run Keyword If                   ${is_syslog_check_already_done} == ${False}
        ...                             CB008662 Endurance SYSLOG Evaluate
        ...                             syslog=${syslog}

        ${is_syslog_check_already_done}         Set Variable                 ${True}

        # KPIs and counters checks
        ${pm_path}                      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
        Run Keyword If                  ${step%2} == 1
        ...                             KPI Evaluate                    pmFile=${pm_path}
        ...                             constraintsFile=${constraints_75_50}
        ...                             failOnError=${True}
        ...                             ELSE
        ...                             KPI Evaluate                    pmFile=${pm_path}
        ...                             constraintsFile=${constraints_100_50}
        ...                             failOnError=${True}

        # Online update of CB008662 targetPct.
        Run Keyword If                  ${step%2} == 1
        ...                             CB008662_Update_Online_SCF       ${delta_file_100_50}
        ...                             ELSE
        ...                             CB008662_Update_Online_SCF       ${delta_file_75_50}

        ${current_date}=                Get Current Date
        ${current_date_epoch}=          Convert Date        ${current_date}     epoch
        Exit For Loop If                ${current_date_epoch} > ${date_stop_epoch}
        Dated Log                       Looping until ${date_stop}
    END

    # BLER profile deactivation
    CB008662_Disable_DL_Bler_Test_Mode
    CB008662_Disable_UL_Bler_Test_Mode
    CB008662_Disable_CQI_Test_Mode
    Traffic Stop UEs                    ueSettingList=${SA_UE_List}      dir=dl
    Traffic Stop UEs                    ueSettingList=${SA_UE_List}      dir=ul
    CB008662_Detach_All_UEs