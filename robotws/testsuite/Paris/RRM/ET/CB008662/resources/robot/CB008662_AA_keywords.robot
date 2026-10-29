*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008662 step AA
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 02-August-2022
...               Modified Date               : 
...               Last Modified by            : 
...               Modification:
...                       02-August-2022      |     Creation
...                       29-September-2022   |     Report rank2 to enable check for M55301C01031
...                                           |     + add TTI trace conditional activation in case Sherpa is required
...                       03-October-2022     |     Remove counter checks (moved to CB008662_AB test case)
...                       04-November-2022    |     Add loop over test for robustness and check ressource between
...                                           |     beginning and end of the loop
...                       08-November-2022    |     Add call to new SWENG KW for resources checks

Resource                         ./CB008662_keywords.robot
Resource                         ../../../resources/common/TtiTrace/ttitrace.robot
Resource                         ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource                         ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource                         ../../../../../resources/SWENG/robot/Hardening.robot
Library                          ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library                          taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library                          ../python/CB008662_CheckTTITraceDL.py


*** Variables ***
${DL_trace_duration_for_TTI_trace_AA_13}            10
${DL_trace_duration_endurance_step_AA_13}           120


# 40 Mbps to use all slots but not max throughput to have a various number of PRB
# Because there are 3 retransmissions systematically, throughput is divided by 4.
# Moreover MCS is set by CQI to ~22 => Max throughput if ~400 / 4 = 100 Mbps
${DL_troughput_AA_13}                               175
${DL_troughput_endurance_step_AA_13}                80

${gnb_alias_AA_13}                                  gnb_under_test
${ps_bwp_delta_file_AA_13}                          testsuite/Paris/RRM/ET/CB008662/config/Delta_Configuration_scf_Enable_Adaptive_ReTx.json

# Disable HARQ incremental redundancy DL
${RD_DisableDlIR_AA_13}                             0x580001

# Defines the maximum number of NACKs received at gNB for a HARQ process,
# after which the next retransmission shall use the PRB/MCS of initial transmission
# In case of 0, reserved MCS may be used for all retransmissions
${RD_AdaptiveReTxNackCountAddr_AA_13}               0x580678
${RD_AdaptiveReTxNackDisableValue_AA_13}            6

${MaxAdaptiveReTxErrorRatio_AA_13}                  3

${AA_13_Num_Of_Loops}                               20

${CB008662_tolerance_file}                          testsuite/Paris/RRM/ET/CB008662/config/CB008662_tolerance_file.csv

*** Keywords ***

CB008662 CellSetup
    [Documentation]               Dedicated KW to add adaptive retransmission configuration
    ...                           by using a delta JSON file.
    ...                           !!! Dist names are hardcoded inside JSON file. To be improved ???

    # Enable IR which is disabled by default
    ${radp_EnableIR}                Create Dictionary    field=${RD_DisableDlIR_AA_13}    value=0

    # Disable NACK count,RD_AdaptiveReTxNackDisableValue_AA_13, which is byde fault set to 2
    ${radp_AdaptiveReTxNackCount}   Create Dictionary       field=${RD_AdaptiveReTxNackCountAddr_AA_13}
    ...                                                     value=${RD_AdaptiveReTxNackDisableValue_AA_13}

    ${list_rad_param}               Create List          ${radp_EnableIR}    ${radp_AdaptiveReTxNackCount} 
    Set Fields in swconfig DU       param_list=${list_rad_param}
	
    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias_AA_13}

    Run Keywords                  coam_parameter.perform_scf_delta_commission     
    ...                           delta_file=${ps_bwp_delta_file_AA_13}
    ...                           connection=${gnb_alias_AA_13}
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    sbts_coam.teardown            connection=${gnb_alias_AA_13}

    Dated Log new line            ${trcColor}--- Restart TL ${defColor}
    Restart TL
    Dated Log new line            ${trcColor}--- WTS setup SA ${defColor}
    Setup Wtsemu SA               nbUe=1       nbSaUe=1     shouldUseLua=${True}


CB008662_TC_AA_13_Check_DL_8662_With_TTI_Trace
    UE Register                     ue=${BASIC_UE_SA.ue}
    Launch PDU Session              ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.ue}    gw=${BASIC_UE_SA.ue}

    # TTI capture configuration
    ${TTIdir}                       Get TTI Trace Path      dir_suffix=AA_13

    # Enable PDSCH decoding for SSB and TRS
    wtsemu.ue_testmode_decode_muxphychan                    decode_mux_phy_chan=decode_PDSCH

    # BLER profile to have systematic NACK for RV=0, 2, 3 and ACK for RV=1
    wtsemu.bler_testmode_nr         profile_id=1
    ...                             num_harq_nack=3

    # Set CQI value to have a predfined MCS (~22) and RANK2 for counter check
    wtsemu.csi_override_testmode_nr                         profile_id=1
    ...                                                     cqi=10
    ...                                                     ri=1

    ${timeStartTraffic}             Get Current Date
    Dated Log New Line              ${trcColor}---> Start packets sending at ${timeStartTraffic} ${defColor}
    Traffic UE DL                   ueSetting=${BASIC_UE_SA}
    ...                             throughput=${DL_troughput_AA_13}
    ...                             shouldBeStop=False
    ...                             shouldBeCheck=False
    ...                             duration=20s
    ...                             deviation=5

    # Enable DL BLER and CQI test modes
    wtsemu.ue_testmode_set_nr       id=${BASIC_UE_SA.ue}
    ...                             testmode=csi_override
    ...                             profile_id=1
    ...                             action=activate
    
    wtsemu.ue_testmode_set_nr       id=${BASIC_UE_SA.ue}
    ...                             testmode=bler
    ...                             profile_id=1
    ...                             action=activate

    Traced Sleep                    5 seconds

    # start TTI capture
    Dated Log New Line              ${trcColor}---> Start TTI traces capture if not already done ${defColor}

    Run Keyword If                  ${enable_sherpa} == ${False}
    ...                             Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    Traced Sleep                    ${DL_trace_duration_for_TTI_trace_AA_13}        msg=DL traffic capture for TTI trace

    # stop TTI capture
    ${TTIpcap}                      Run Keyword If                  ${enable_sherpa} == ${False}
    ...                             Stop TTI Traces in Streaming mode
    ...                                                             tti_trace_path=${TTIdir}
    ...                                                             tti_trace_filename=TTITrace_AA_13

    Dated Log New Line              ${trcColor}---> Convert TTItrace to json and csv${defColor}
    ${TTIjson}                      Run Keyword If                  ${enable_sherpa} == ${False}
    ...                             Convert TTItrace from pcap to others            input_file_path=${TTIpcap}

    # Call retransmission checks script if TTI capture has been done (${enable_sherpa} != ${False})
    Dated Log New Line              ${trcColor}---> Check retransmission PRB and adaptive MCS in TTI trace${defColor}
    ${checksResults}                Run Keyword If                  ${enable_sherpa} == ${False}
    ...                             checkAdaptiveTDDDL              jsonPathName=${TTIjson}
    ...                                                             rdAdaptiveReTxNackCount=${RD_AdaptiveReTxNackDisableValue_AA_13}
    ...                             ELSE
    ...                             Create Dictionary               ErrorRatio=0
    ...                                                             reservedMcsDetected=0
    ...                                                             unexpectedMcsDetected=0
    ...                                                             unexpectedPRBDetected=0
    ...                                                             unexpectedRBGDetected=0
    ...                                                             moreResourceChecks=0
    ...                                                             lessResourceChecks=0
    ...                                                             sameResourceChecks=0

    ${timeStopTraffic}              Get Current Date
    Dated Log New Line              ${trcColor}=== Stop packets sending and detach UE at ${timeStopTraffic} ${defColor}
    Traffic Stop                    ueSetting=${UE_SIMPLE}             dir=dl

    UE Deregister                   id=${BASIC_UE_SA.ue}
    Traced Sleep                    20 s                     msg=Sleep for end of deregistration

    # Max 3 % error
    Dated Log New Line            Error percentage is ${checksResults}[ErrorRatio] % < ${MaxAdaptiveReTxErrorRatio_AA_13}

    Dated log                     Reserved MCS detected: ${checksResults}[reservedMcsDetected]
    Dated Log                     Unexpected MCS detected: ${checksResults}[unexpectedMcsDetected]
    Dated Log                     Unexpected PRB detected: ${checksResults}[unexpectedPRBDetected]
    Dated Log                     Unexpected RBG detected: ${checksResults}[unexpectedRBGDetected]

    Dated Log                     Number of checks with more ressources: ${checksResults}[moreResourceChecks]
    Dated Log                     Number of checks with less ressources: ${checksResults}[lessResourceChecks]
    Dated Log                     Number of checks with same ressources: ${checksResults}[sameResourceChecks]

    Should Be True                ${checksResults}[ErrorRatio] < ${MaxAdaptiveReTxErrorRatio_AA_13}

CB008662_TC_AA_13_Adaptive_Retrans_targetPct_100_minPct_50
    [Documentation]                 The aim of this test is to check that reserved MCS is used
    ...                             for retransmission if the number of available resources in slot is below
    ...                             or above resrouces in initial transmission
    ...                             On the contraty, initial MCS should be used in case the same REs
    ...                             are available inside retransmission slot.
    
    # Customise SCF, restart TL and perform cell setup
    CB008662_AA_keywords.CB008662 CellSetup

    # Cellsetup is now done, Sherpa can be enabled if needed
    Run Keyword If                     ${enable_sherpa} == ${True}     Activate Sherpa

    # 8662 DL unitary test
    # As a first step we check PRB computation by checking content of TTI traces
    # As a second step, an endurance test will be run in loop with the same scenario. But, TTI trace is no more checked.
    # However, resource consumption are checked
    CB008662_AA_keywords.CB008662_TC_AA_13_Check_DL_8662_With_TTI_Trace

    # Get ressources before starting loop
    ${initial_resources}                Get Resources
    #Dated Log                           Initial resources: ${initial_resources}

    # Starting endurance test loop. BLER and CQI test modes are already enabled. Because of PR675549, I think it's better
    # to not disable/enable them in loop. Anyway, the BLER remains enabled after detach, so it's not a concern.
    FOR          ${n}           IN RANGE        ${AA_13_Num_Of_Loops}
        Dated Log New Line              ${trcColor}---> Starting loop number ${n} ${defColor}
        UE Register                     ue=${BASIC_UE_SA.ue}
        Launch PDU Session              ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.ue}    gw=${BASIC_UE_SA.ue}

        ${timeStartTraffic}             Get Current Date
        Dated Log New Line              ${trcColor}---> Start packets sending at ${timeStartTraffic} ${defColor}
        Traffic UE DL                   ueSetting=${BASIC_UE_SA}
        ...                             throughput=${DL_troughput_endurance_step_AA_13}
        ...                             shouldBeStop=False
        ...                             shouldBeCheck=False
        ...                             duration=20s
        ...                             deviation=5

        Traced Sleep                    ${DL_trace_duration_endurance_step_AA_13}         msg=DL traffic (no TTI trace capture)

        ${timeStopTraffic}              Get Current Date
        Dated Log New Line              ${trcColor}=== Stop packets sending and detach UE at ${timeStopTraffic} ${defColor}
        Traffic Stop                    ueSetting=${UE_SIMPLE}             dir=dl

        UE Deregister                   id=${BASIC_UE_SA.ue}
        Traced Sleep                    20 s                     msg=Sleep for end of deregistration
    END

    # BLER profile deactivation
    # Deactivate BLER by steps
    wtsemu.bler_testmode_nr         profile_id=1
    ...                             num_harq_nack=2
    Traced Sleep                    2 seconds

    wtsemu.bler_testmode_nr         profile_id=1
    ...                             num_harq_nack=1
    Traced Sleep                    2 seconds

    wtsemu.ue_testmode_set_nr       id=${BASIC_UE_SA.ue}
    ...                             testmode=bler
    ...                             profile_id=1
    ...                             action=deactivate

    # CQI test mode deactivation
    wtsemu.ue_testmode_set_nr       id=${BASIC_UE_SA.ue}
    ...                             testmode=csi_override
    ...                             profile_id=1
    ...                             action=deactivate

    # Compare CPRT/CPNRT resources between the beginning and end of the loop to see if there is no
    # resource lacking
    ${final_resources}              Get Resources
    #Dated Log                       Final resources: ${final_resources}

    ${resources_comparison}         Compare Resources With Tolerance        ${initial_resources}
    ...                                                                     ${final_resources}
    ...                                                                     ${CB008662_tolerance_file}

    Should Be Empty                 ${resources_comparison}
    
    Dated Log                       Resources comparison: ${resources_comparison}