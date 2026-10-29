*** Settings ***
Documentation     [SUITE PURPOSE]  KWs of CB013244 robustness TCs
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 01-Nov-2025
...               Last Modified by            :
...               Modification:
...                       01-Nov-2025         | Creation


Resource                            ./CB013244_keywords.robot


*** Variables ***
${CB013244_A17_KPIconstraints}    ${CURDIR}/../../config/CB013244_Robustness_A17_KPIconstraints.csv
${CB013244_A18_KPIconstraints}    ${CURDIR}/../../config/CB013244_Robustness_A18_KPIconstraints.csv
${CB013244_A19_KPIconstraints}    ${CURDIR}/../../config/CB013244_Robustness_A19_KPIconstraints.csv
${CB013244_A20_KPIconstraints}    ${CURDIR}/../../config/CB013244_Robustness_A20_KPIconstraints.csv


*** Keywords ***
TC_CB013244_A_17_B2_Robustness_check_case1

    ${TCname}                      Set Variable    A17

    # =========================
    # Configuration
    # =========================
    ${PSswitching_conf}            Copy Dictionary     ${Default_TMO_powerSavingBwpSwitching}
    Set To Dictionary              ${PSswitching_conf}     dlBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdFromPsBwp          350
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdToPsBwp            300
    Set To Dictionary              ${PSswitching_conf}     ulBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRFromPsBwp    100
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRToPsBwp      80

    ${CB013244_actConf}            Copy Dictionary        ${Default_CB013244_act}
    Set To Dictionary              ${CB013244_actConf}    actPreventBWPSwitchInBadConditions    true

    ${SCF_TC}                      CB013244 Full Commissioning
    ...                            PSswitchingParam=${PSswitching_conf}    featAct=${CB013244_actConf}   suffix=${TCname}


    # =========================
    # Create JSONs to perform BWP switches by online change according to the test case
    # =========================
    ${PSswitching_lowRateThreshold}    Copy Dictionary     ${PSswitching_conf}
    Set To Dictionary              ${PSswitching_lowRateThreshold}     dlRateThresholdFromPsBwp          50
    Set To Dictionary              ${PSswitching_lowRateThreshold}     dlRateThresholdToPsBwp            35
    Set To Dictionary              ${PSswitching_lowRateThreshold}     ulRateThresholdNoVoNRFromPsBwp    10
    Set To Dictionary              ${PSswitching_lowRateThreshold}     ulRateThresholdNoVoNRToPsBwp      5

    ${SCF_TCswitch}    ${JSONtoSwitch}    ${JSONtoSwitchBack}    CB013244 Build Power Saving delta JSON
    ...                            SCFsrc=${SCF_TC}    PSswitchingParam=${PSswitching_lowRateThreshold}    suffix=${TCname}_switch


    # Define UEs to use, then WTS setup
    ${SA_UE}                       Copy Dictionary     ${BASIC_UE_SA}

    ${NSA_UE}                      Copy Dictionary     ${NSA_UE_NO_PROFILE}
    Set To Dictionary              ${NSA_UE}     ue    ${FIRST_NSA_UE_ID}

    Dated Log new line             ${trcColor}=== Modify UE capacities of SA UE to support power saving${defColor}
    Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${SA_UE.ue}    ue_nr_capa=${UEcapa_powerSaving_SA_TDD}

    Dated Log new line             ${trcColor}=== Perform NSA WTS setup ${defColor}
    WTS Setup                      shouldUseLua=False    nbCell=8


    IF    ${ttiCapt}
        # TTI capture configuration
        ${TTIdir}                  Get TTI Trace Path    dir_suffix=${TCname}
        ${TTINameTC}               Set Variable    TTI_Trace_${TCname}
        @{TTItraceList}            Create List
        ${internalCellId}          CB013244 Get Internal Cell Id    cell=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
        @{TTIcell}                 Create List    ${internalCellId}
    END


    CB013244 SA Attach             ueSetting=${SA_UE}

    # Launch DL 160Kbps: 1000/40*((800*1)*8) - 15mn data volume in bytes: (15*60)*160000/8=18000000
    Run Keyword And Ignore Error
    ...                            Send UE DL packets    ueSetting=${SA_UE}
    ...                              period_ms=40    size=800    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5

    # Launch UL 50Kbps: 1000/80*((500*1)*8) - 15mn data volume in bytes: (15*60)*50000/8=5625000
    Run Keyword And Ignore Error
    ...                            Send UE UL packets    ueSetting=${SA_UE}
    ...                              period_ms=80    size=500    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5


    CB013244 NSA Attach            ueSetting=${NSA_UE}

    Run Keyword And Ignore Error
    ...                            Traffic UE UL DL    ueSetting=${NSA_UE}
    ...                              dlThroughput=100    ulThroughput=50
    ...                              shouldStopTraffic=False    duration=0    deviation=5


    ${gnb_alias}                   Set Variable        gNB
    sbts_coam.connect_to           name=${gnb_alias}

    CB013244 Wait Next PM period


    ${switchNb}                    Evaluate    0
    # First loop to perform robustness check "robNb" times (default 1 as defined in TC description)
    FOR    ${robId}    IN RANGE    1    ${robNb}+1
       CB013244 Start Syslog gNB
       CB013244 Start Syslog AP
       ${firstSwitchInLoop}        Evaluate    ${switchNb} + 1
       # Second loop to perform "loopNb" swithes to/from PS BWP (default 10 as defined in TC description)
       FOR    ${loopId}    IN RANGE    1    ${loopNb}+1
          Dated Log New Line       ${trcColor}================================== ${defColor}
          Dated Log New Line       ${trcColor}===== LOOP ${robId} / ${robNb} -- switch ${loopId} / ${loopNb} ${defColor}
          Dated Log New Line       ${trcColor}================================== ${defColor}

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Set low UL/DL rate threshold to force switching to large BWP ${defColor}
          coam_parameter.perform_scf_delta_commission
          ...                      delta_file=${JSONtoSwitch}    connection=${gnb_alias}

          IF    ${ttiCapt}
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_PSBWPtoLB   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                   tti_trace_path=${TTIdir}
             ...                   tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
          END

          Traced Sleep             2    msg=traffic in large BWP

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Set high UL/DL rate threshold to switch to power saving BWP ${defColor}
          coam_parameter.perform_scf_delta_commission
          ...                      delta_file=${JSONtoSwitchBack}    connection=${gnb_alias}

          IF    ${ttiCapt}
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_LBtoPSBW   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                   tti_trace_path=${TTIdir}
             ...                   tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
          END

          Traced Sleep             2    msg=traffic in power saving BWP
       END

       ${SYSLOGsuffix}             Format String    ${TCname}_switch_{:02d}_to_{:02d}   ${firstSwitchInLoop}    ${switchNb}
       CB013244 Stop Syslog gNB    suffix=${SYSLOGsuffix}
       CB013244 Stop Syslog AP     suffix=${SYSLOGsuffix}

       CB013244 Wait Next PM period
    END

    Traced Sleep                   60    msg=waiting PM files

    ${pm_latest}                   Collect PM files from BTS    ${LOG_PATH}/PM
    ${KPIstatus}                   CB013244 KPI Evaluate
    ...                            pm_path=${LOG_PATH}/PM/pm_files    constraintsFile=${CB013244_A17_KPIconstraints}    nbPMfileToCheck=${robNb}

    IF    ${ttiCapt}
       CB013244 Convert TTI pcap   pcapList=${TTItraceList}
    END

    Dated Log new line             ${trcColor}--- Detach NSA UE ${NSA_UE.ue} ${defColor}
    UE Detach Enb                  ueSetting=${NSA_UE}

    Should Be True                 ${KPIstatus}


TC_CB013244_A_18_B2_Robustness_check_case2

    ${TCname}                      Set Variable    A18

    # =========================
    # Configuration
    # =========================
    ${PSswitching_conf}            Copy Dictionary     ${Default_TMO_powerSavingBwpSwitching}
    Set To Dictionary              ${PSswitching_conf}     avgCQIToForceBWPSwitchFromPsBwp   7
    Set To Dictionary              ${PSswitching_conf}     avgCQIToPreventBWPSwitchToPsBwp   10
    Set To Dictionary              ${PSswitching_conf}     dlBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdFromPsBwp          350
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdToPsBwp            300
    Set To Dictionary              ${PSswitching_conf}     ulBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRFromPsBwp    100
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRToPsBwp      80

    ${CB013244_actConf}            Copy Dictionary        ${Default_CB013244_act}
    Set To Dictionary              ${CB013244_actConf}    actPreventBWPSwitchInBadConditions    true

    ${SCF_TC}                      CB013244 Full Commissioning
    ...                            PSswitchingParam=${PSswitching_conf}    featAct=${CB013244_actConf}   suffix=${TCname}


    # Define UEs to use, then WTS setup
    ${SA_UE}                       Copy Dictionary     ${BASIC_UE_SA}

    ${NSA_UE}                      Copy Dictionary     ${NSA_UE_NO_PROFILE}
    Set To Dictionary              ${NSA_UE}     ue    ${FIRST_NSA_UE_ID}

    Dated Log new line             ${trcColor}=== Modify UE capacities of SA UE to support power saving${defColor}
    Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${SA_UE.ue}    ue_nr_capa=${UEcapa_powerSaving_SA_TDD}

    Dated Log new line             ${trcColor}=== Perform NSA WTS setup ${defColor}
    WTS Setup                      shouldUseLua=False    nbCell=8


    IF    ${ttiCapt}
        # TTI capture configuration
        ${TTIdir}                  Get TTI Trace Path    dir_suffix=${TCname}
        ${TTINameTC}               Set Variable    TTI_Trace_${TCname}
        @{TTItraceList}            Create List
        ${internalCellId}          CB013244 Get Internal Cell Id    cell=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
        @{TTIcell}                 Create List    ${internalCellId}
    END


    CB013244 SA Attach             ueSetting=${SA_UE}

    # Launch DL 80Kbps: 1000/20*((200*1)*8) - 15mn data volume in bytes: (15*60)*160000/8=9000000
    Run Keyword And Ignore Error
    ...                            Send UE DL packets    ueSetting=${SA_UE}
    ...                              period_ms=20    size=200    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5

    # Launch UL 40Kbps: 1000/100*((500*1)*8) - 15mn data volume in bytes: (15*60)*40000/8=4500000
    Run Keyword And Ignore Error
    ...                            Send UE UL packets    ueSetting=${SA_UE}
    ...                              period_ms=100    size=500    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5


    CB013244 NSA Attach            ueSetting=${NSA_UE}

    Run Keyword And Ignore Error
    ...                            Traffic UE UL DL    ueSetting=${NSA_UE}
    ...                              dlThroughput=100    ulThroughput=50
    ...                              shouldStopTraffic=False    duration=0    deviation=5


    # Define CQI test mode profile to switch to/from power saving BWP CQI in loop
    wtsemu.csi_override_testmode_nr    profile_id=2    cqi=4  cqi_mode=fixed
    wtsemu.csi_override_testmode_nr    profile_id=3    cqi=12 cqi_mode=fixed

    CB013244 Wait Next PM period

    ${switchNb}                    Evaluate    0
    # First loop to perform robustness check "robNb" times (default 1 as defined in TC description)
    FOR    ${robId}    IN RANGE    1    ${robNb}+1
       CB013244 Start Syslog gNB
       CB013244 Start Syslog AP
       ${firstSwitchInLoop}        Evaluate    ${switchNb} + 1
       # Second loop to perform "loopNb" switches to/from PS BWP (default 10 as defined in TC description)
       FOR    ${loopId}    IN RANGE    1    ${loopNb}+1
          Dated Log New Line       ${trcColor}================================== ${defColor}
          Dated Log New Line       ${trcColor}===== LOOP ${robId} / ${robNb} -- switch ${loopId} / ${loopNb} ${defColor}
          Dated Log New Line       ${trcColor}================================== ${defColor}

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Decrease CQI to switch to large BWP ${defColor}
          wtsemu.ue_testmode_set_nr    id=${SA_UE.ue}    testmode=csi_override    profile_id=2    action=activate    scell=0

          IF    ${ttiCapt}
             Traced Sleep          5    msg=switch to large BWP
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_PSBWPtoLB   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                     tti_trace_path=${TTIdir}
             ...                     tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
             Traced Sleep          5    msg=traffic in large BWP
          ELSE
             Traced Sleep          30    msg=traffic in large BWP
          END

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Increase CQI to switch to power saving BWP ${defColor}
          wtsemu.ue_testmode_set_nr    id=${SA_UE.ue}    testmode=csi_override    profile_id=3    action=activate    scell=0

          IF    ${ttiCapt}
             Traced Sleep          5    msg=switch to power saving BWP
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_LBtoPSBW   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                     tti_trace_path=${TTIdir}
             ...                     tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
             Traced Sleep          5    msg=traffic in power saving BWP
          ELSE
             Traced Sleep          30    msg=traffic in power saving BWP
          END
       END

       ${SYSLOGsuffix}             Format String    ${TCname}_switch_{:02d}_to_{:02d}   ${firstSwitchInLoop}    ${switchNb}
       CB013244 Stop Syslog gNB    suffix=${SYSLOGsuffix}
       CB013244 Stop Syslog AP     suffix=${SYSLOGsuffix}

       CB013244 Wait Next PM period
    END

    Traced Sleep                   60    msg=waiting PM files

    ${pm_latest}                   Collect PM files from BTS    ${LOG_PATH}/PM
    ${KPIstatus}                   CB013244 KPI Evaluate
    ...                              pm_path=${LOG_PATH}/PM/pm_files    constraintsFile=${CB013244_A18_KPIconstraints}    nbPMfileToCheck=${robNb}

    IF    ${ttiCapt}
       CB013244 Convert TTI pcap   pcapList=${TTItraceList}
    END

    Dated Log new line             ${trcColor}--- Detach SA UE ${SA_UE.ue} ${defColor}
    UE Deregister                  id=${SA_UE.ue}
    Sleep                          5s

    Dated Log new line             ${trcColor}--- Detach NSA UE ${NSA_UE.ue} ${defColor}
    UE Detach Enb                  ueSetting=${NSA_UE}

    Should Be True                 ${KPIstatus}


TC_CB013244_A_19_B2_Robustness_check_case3

    ${TCname}                      Set Variable    A19

    # =========================
    # Configuration
    # =========================
    ${PSswitching_conf}            Copy Dictionary     ${Default_TMO_powerSavingBwpSwitching}
    Set To Dictionary              ${PSswitching_conf}     avgCQIToForceBWPSwitchFromPsBwp   8
    Set To Dictionary              ${PSswitching_conf}     avgCQIToPreventBWPSwitchToPsBwp   10
    Set To Dictionary              ${PSswitching_conf}     dlBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdFromPsBwp          350
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdToPsBwp            300
    Set To Dictionary              ${PSswitching_conf}     ulBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRFromPsBwp    100
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRToPsBwp      90

    ${CB013244_actConf}            Copy Dictionary     ${Default_CB013244_act}
    Set To Dictionary              ${CB013244_actConf}    actPreventBWPSwitchInBadConditions    true

    ${SCF_TC}                      CB013244 Full Commissioning
    ...                            PSswitchingParam=${PSswitching_conf}    featAct=${CB013244_actConf}   suffix=${TCname}


    # =========================
    # Create JSONs to perform BWP switches by online change according to the test case
    # =========================
    ${CB013244_CQI_deact}          Copy Dictionary     ${CB013244_actConf}
    Set To Dictionary              ${CB013244_CQI_deact}     actPreventBWPSwitchInBadConditions    false

    ${SCF_TCswitch}    ${JSONtoDeactCQI}    ${JSONtoActCQI}    CB013244 Build Power Saving delta JSON
    ...                            SCFsrc=${SCF_TC}    featAct=${CB013244_CQI_deact}    suffix=${TCname}_switch


    # Define UEs to use, then WTS setup
    ${SA_UE}                       Copy Dictionary     ${BASIC_UE_SA}

    ${NSA_UE}                      Copy Dictionary     ${NSA_UE_NO_PROFILE}
    Set To Dictionary              ${NSA_UE}     ue    ${FIRST_NSA_UE_ID}

    Dated Log new line             ${trcColor}=== Modify UE capacities of SA UE to support power saving${defColor}
    Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${SA_UE.ue}    ue_nr_capa=${UEcapa_powerSaving_SA_TDD}

    Dated Log new line             ${trcColor}=== Perform NSA WTS setup ${defColor}
    WTS Setup                      shouldUseLua=False    nbCell=8


    IF    ${ttiCapt}
        # TTI capture configuration
        ${TTIdir}                  Get TTI Trace Path    dir_suffix=${TCname}
        ${TTINameTC}               Set Variable    TTI_Trace_${TCname}
        @{TTItraceList}            Create List
        ${internalCellId}          CB013244 Get Internal Cell Id    cell=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
        @{TTIcell}                 Create List    ${internalCellId}
    END


    CB013244 SA Attach             ueSetting=${SA_UE}

    # Set CQI to 4 (lower than avgCQIToForceBWPSwitchFromPsBwp) to force large BWP
    wtsemu.csi_override_testmode_nr    profile_id=2    cqi=4    cqi_mode=fixed
    wtsemu.ue_testmode_set_nr          id=${SA_UE.ue}    testmode=csi_override    profile_id=2    action=activate    scell=0

    # Launch DL 80Kbps: 1000/20*((200*1)*8) - 15mn data volume in bytes: (15*60)*160000/8=9000000
    Run Keyword And Ignore Error
    ...                            Send UE DL packets    ueSetting=${SA_UE}
    ...                              period_ms=20    size=200    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5

    # Launch UL 40Kbps: 1000/100*((500*1)*8) - 15mn data volume in bytes: (15*60)*40000/8=4500000
    Run Keyword And Ignore Error
    ...                            Send UE UL packets    ueSetting=${SA_UE}
    ...                              period_ms=100    size=500    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5


    CB013244 NSA Attach            ueSetting=${NSA_UE}

    Run Keyword And Ignore Error
    ...                            Traffic UE UL DL    ueSetting=${NSA_UE}
    ...                              dlThroughput=100    ulThroughput=50
    ...                              shouldStopTraffic=False    duration=0    deviation=5


    ${gnb_alias}                   Set Variable        gNB
    sbts_coam.connect_to           name=${gnb_alias}

    CB013244 Wait Next PM period

    ${switchNb}                    Evaluate    0
    # First loop to perform robustness check "robNb" times (default 1 as defined in TC description)
    FOR    ${robId}    IN RANGE    1    ${robNb}+1
       CB013244 Start Syslog gNB
       CB013244 Start Syslog AP
       ${firstSwitchInLoop}        Evaluate    ${switchNb} + 1
       # Second loop to perform "loopNb" swithes to/from PS BWP (default 10 as defined in TC description)
       FOR    ${loopId}    IN RANGE    1    ${loopNb}+1
          Dated Log New Line       ${trcColor}================================== ${defColor}
          Dated Log New Line       ${trcColor}===== LOOP ${robId} / ${robNb} -- switch ${loopId} / ${loopNb} ${defColor}
          Dated Log New Line       ${trcColor}================================== ${defColor}

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Set actPreventBWPSwitchInBadConditions to false: switch to power saving BWP ${defColor}
          coam_parameter.perform_scf_delta_commission
          ...                      delta_file=${JSONtoDeactCQI}    connection=${gnb_alias}

          IF    ${ttiCapt}
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_LBtoPSBWP   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                   tti_trace_path=${TTIdir}
             ...                   tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
          END

          Traced Sleep             2    msg=traffic in power saving BWP

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Set actPreventBWPSwitchInBadConditions to true: switch to large BWP ${defColor}
          coam_parameter.perform_scf_delta_commission
          ...                      delta_file=${JSONtoActCQI}    connection=${gnb_alias}

          IF    ${ttiCapt}
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_PSBWPtoLB   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                   tti_trace_path=${TTIdir}
             ...                   tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
          END

          Traced Sleep             2    msg=traffic in large BWP
       END

       ${SYSLOGsuffix}             Format String    ${TCname}_switch_{:02d}_to_{:02d}   ${firstSwitchInLoop}    ${switchNb}
       CB013244 Stop Syslog gNB    suffix=${SYSLOGsuffix}
       CB013244 Stop Syslog AP     suffix=${SYSLOGsuffix}

       CB013244 Wait Next PM period
    END

    Traced Sleep                   60    msg=waiting PM files

    ${pm_latest}                   Collect PM files from BTS    ${LOG_PATH}/PM
    ${KPIstatus}                   CB013244 KPI Evaluate
    ...                              pm_path=${LOG_PATH}/PM/pm_files    constraintsFile=${CB013244_A19_KPIconstraints}    nbPMfileToCheck=${robNb}

    IF    ${ttiCapt}
       CB013244 Convert TTI pcap   pcapList=${TTItraceList}
    END

    Dated Log new line             ${trcColor}--- Detach SA UE ${SA_UE.ue} ${defColor}
    UE Deregister                  id=${SA_UE.ue}
    Sleep                          5s

    Dated Log new line             ${trcColor}--- Detach NSA UE ${NSA_UE.ue} ${defColor}
    UE Detach Enb                  ueSetting=${NSA_UE}

    Should Be True                 ${KPIstatus}


TC_CB013244_A_20_B2_Robustness_check_case4

    ${TCname}                      Set Variable    A20

    # =========================
    # Configuration
    # =========================
    ${PSswitching_conf}            Copy Dictionary     ${Default_TMO_powerSavingBwpSwitching}
    Set To Dictionary              ${PSswitching_conf}     avgCQIToForceBWPSwitchFromPsBwp   8
    Set To Dictionary              ${PSswitching_conf}     avgCQIToPreventBWPSwitchToPsBwp   10
    Set To Dictionary              ${PSswitching_conf}     dlBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdFromPsBwp          350
    Set To Dictionary              ${PSswitching_conf}     dlRateThresholdToPsBwp            300
    Set To Dictionary              ${PSswitching_conf}     ulBufferEmptyRatioToPsBwp         70
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRFromPsBwp    100
    Set To Dictionary              ${PSswitching_conf}     ulRateThresholdNoVoNRToPsBwp      80

    ${CB013244_CQI_act}            Copy Dictionary     ${Default_CB013244_act}
    Set To Dictionary              ${CB013244_CQI_act}     actPreventBWPSwitchInBadConditions    true

    ${SCF_TC}                      CB013244 Full Commissioning
    ...                            PSswitchingParam=${PSswitching_conf}    featAct=${CB013244_CQI_act}   suffix=${TCname}


    # =========================
    # Create JSONs to perform BWP switches by online change according to the test case
    # =========================
    ${PSswitching_lowCQIThreshold}      Copy Dictionary     ${PSswitching_conf}
    Set To Dictionary              ${PSswitching_lowCQIThreshold}     avgCQIToForceBWPSwitchFromPsBwp    1
    Set To Dictionary              ${PSswitching_lowCQIThreshold}     avgCQIToPreventBWPSwitchToPsBwp    2

    ${SCF_TCswitch}    ${JSONtoSwitch}    ${JSONtoSwitchBack}    CB013244 Build Power Saving delta JSON
    ...                            SCFsrc=${SCF_TC}    PSswitchingParam=${PSswitching_lowCQIThreshold}    suffix=${TCname}_switch


    # Define UEs to use, then WTS setup
    ${SA_UE}                       Copy Dictionary     ${BASIC_UE_SA}

    ${NSA_UE}                      Copy Dictionary     ${NSA_UE_NO_PROFILE}
    Set To Dictionary              ${NSA_UE}     ue    ${FIRST_NSA_UE_ID}

    Dated Log new line             ${trcColor}=== Modify UE capacities of SA UE to support power saving${defColor}
    Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${SA_UE.ue}    ue_nr_capa=${UEcapa_powerSaving_SA_TDD}

    Dated Log new line             ${trcColor}=== Perform NSA WTS setup ${defColor}
    WTS Setup                      shouldUseLua=False    nbCell=8


    IF    ${ttiCapt}
        # TTI capture configuration
        ${TTIdir}                  Get TTI Trace Path    dir_suffix=${TCname}
        ${TTINameTC}               Set Variable    TTI_Trace_${TCname}
        @{TTItraceList}            Create List
        ${internalCellId}          CB013244 Get Internal Cell Id    cell=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
        @{TTIcell}                 Create List    ${internalCellId}
    END


    CB013244 SA Attach             ueSetting=${SA_UE}

    # Set CQI to 4 (lower than avgCQIToForceBWPSwitchFromPsBwp) to force large BWP
    wtsemu.csi_override_testmode_nr    profile_id=2    cqi=4    cqi_mode=fixed
    wtsemu.ue_testmode_set_nr          id=${SA_UE.ue}    testmode=csi_override    profile_id=2    action=activate    scell=0

    # Launch DL 80Kbps: 1000/20*((200*1)*8) - 15mn data volume in bytes: (15*60)*160000/8=9000000
    Run Keyword And Ignore Error
    ...                            Send UE DL packets    ueSetting=${SA_UE}
    ...                              period_ms=20    size=200    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5

    # Launch UL 40Kbps: 1000/50*((250*1)*8) - 15mn data volume in bytes: (15*60)*40000/8=4500000
    Run Keyword And Ignore Error
    ...                            Send UE UL packets    ueSetting=${SA_UE}
    ...                              period_ms=50    size=250    burst=1
    ...                              shouldBeStop=False    duration=0    deviation=5


    CB013244 NSA Attach            ueSetting=${NSA_UE}

    Run Keyword And Ignore Error
    ...                            Traffic UE UL DL    ueSetting=${NSA_UE}
    ...                              dlThroughput=100    ulThroughput=50
    ...                              shouldStopTraffic=False    duration=0    deviation=5


    ${gnb_alias}                   Set Variable        gNB
    sbts_coam.connect_to           name=${gnb_alias}

    CB013244 Wait Next PM period

    ${switchNb}                    Evaluate    0
    # First loop to perform robustness check "robNb" times (default 1 as defined in TC description)
    FOR    ${robId}    IN RANGE    1    ${robNb}+1
       CB013244 Start Syslog gNB
       CB013244 Start Syslog AP
       ${firstSwitchInLoop}        Evaluate    ${switchNb} + 1
       # Second loop to perform "loopNb" swithes to/from PS BWP (default 10 as defined in TC description)
       FOR    ${loopId}    IN RANGE    1    ${loopNb}+1
          Dated Log New Line       ${trcColor}================================== ${defColor}
          Dated Log New Line       ${trcColor}===== LOOP ${robId} / ${robNb} -- switch ${loopId} / ${loopNb} ${defColor}
          Dated Log New Line       ${trcColor}================================== ${defColor}

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Set low CQI threshold to switch to power saving BWP ${defColor}
          coam_parameter.perform_scf_delta_commission
          ...                      delta_file=${JSONtoSwitch}    connection=${gnb_alias}

          IF    ${ttiCapt}
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_LBtoPSBWP   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                   tti_trace_path=${TTIdir}
             ...                   tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
          END

          Traced Sleep             2    msg=traffic in power saving BWP

          IF    ${ttiCapt}
             Dated Log new line    ${trcColor}Start TTI trace ${defColor}
             Start TTI Traces in Streaming mode    cell_distid=${TTIcell}    src_ip=10.0.1.2
          END

          ${switchNb}              Evaluate    ${switchNb} + 1
          Dated Log New Line       ${trcColor}Set high CQI threshold to force switching to large BW ${defColor}
          coam_parameter.perform_scf_delta_commission
          ...                      delta_file=${JSONtoSwitchBack}    connection=${gnb_alias}

          IF    ${ttiCapt}
             Dated Log New Line    ${trcColor}Stop TTI trace ${defColor}
             ${TTIloopName}        Format String     ${TTINameTC}_switch_{:02d}_PSBWPtoLB   ${switchNb}
             ${TTIpcap}            Stop TTI Traces in Streaming mode
             ...                   tti_trace_path=${TTIdir}
             ...                   tti_trace_filename=${TTIloopName}
             Append To List        ${TTItraceList}    ${TTIpcap}
          END

          Traced Sleep             2    msg=traffic in large BWP
       END

       ${SYSLOGsuffix}             Format String    ${TCname}_switch_{:02d}_to_{:02d}   ${firstSwitchInLoop}    ${switchNb}
       CB013244 Stop Syslog gNB    suffix=${SYSLOGsuffix}
       CB013244 Stop Syslog AP     suffix=${SYSLOGsuffix}

       CB013244 Wait Next PM period
    END

    Traced Sleep                   60    msg=waiting PM files

    ${pm_latest}                   Collect PM files from BTS    ${LOG_PATH}/PM
    ${KPIstatus}                   CB013244 KPI Evaluate
    ...                            pm_path=${LOG_PATH}/PM/pm_files    constraintsFile=${CB013244_A20_KPIconstraints}    nbPMfileToCheck=${robNb}

    IF    ${ttiCapt}
       CB013244 Convert TTI pcap   pcapList=${TTItraceList}
    END

    Dated Log new line             ${trcColor}--- Detach SA UE ${SA_UE.ue} ${defColor}
    UE Deregister                  id=${SA_UE.ue}
    Sleep                          5s

    Dated Log new line             ${trcColor}--- Detach NSA UE ${NSA_UE.ue} ${defColor}
    UE Detach Enb                  ueSetting=${NSA_UE}

    Should Be True                 ${KPIstatus}
