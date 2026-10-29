*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013527
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-03-2025
...               Modified Date               : 19-03-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2506    ying.yw.wu@nokia.com              Creation
...               0.2       FB2507    ying.yw.wu@nokia.com              Add TCs and BLER check
...               0.3       FB2515    ying.yw.wu@nokia.com              CB013527 activated by default, no need to set rad param 0x4200B1
...               0.4       FB2519    axel.gouilly-Frossar@nokia.com    Adaptation to new Sweng
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim           WITH NAME    wts
Library           taf.wts.runner    WITH NAME    wtsemu
Library           taf.config.scf    WITH NAME    scf
Library           taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME   coam_parameter
Library           ../../../../../resources/SWENG/python/ScfVendorOperations.py
Library           taf.ccs.aashell

Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource          ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource          ../../../../../resources/SWENG/robot/PacketSearch.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot


*** Variables ***

# RAD parameters definition frrom CB012605
${rdBbPoolTddFr1Ecpri72e}                  0x42009D
${rdFakeUeSchedulingEnable}                0x5801CB
${enabledNewCeFrameworkFlagInDu}           0x8000A6
${rdCprtDebugLog}                          0x590072
${rdL2psFeatureDebugLevel}                 0x58057A
${rdPoolingDebugLog}                       0x58057C
# To add : RAD param for CB013527
${rdTputPoolingEcpri72eAllowed}            0x4200B1
# FB2522 : add RAD param CB015330 for testing which will be activated by default in 26R1
${rdTputPoolingUlEnhance}                  0x58061B

#Common custom config settings
# Fronthaul interface resolution for PUSCH IQ data in eCPRI 7-2e UL split
${xEc_val}                            14
# Fronthaul interface resolution for PUSCH Normalization Factor in eCPRI 7-2e UL split
${betaEc_val}                         13

@{Custom_Vendor_For_Airphone}
...                     NRBTS.xEc=${xEc_val}
...                     NRBTS.betaEc=${betaEc_val}

@{Custom_Vendor_For_Airphone-TputLimit}
...                     NRBTS.xEc=${xEc_val}
...                     NRBTS.betaEc=${betaEc_val}
...                     NRBTS.bbPoolCapacity.maxPdschTpSlotL1Pool=2516
...                     NRBTS.bbPoolCapacity.maxPdschTpSlotL2Pool=2516

@{Rad_Param_CB013527}
...                     ${rdBbPoolTddFr1Ecpri72e}=31
...                     ${rdFakeUeSchedulingEnable}=0
...                     ${enabledNewCeFrameworkFlagInDu}=0
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
# ...                     ${rdTputPoolingEcpri72eAllowed}=1
...                     ${rdTputPoolingUlEnhance}=1

@{Rad_Param_CB013527_Deact}
...                     ${rdBbPoolTddFr1Ecpri72e}=31
...                     ${rdFakeUeSchedulingEnable}=0
...                     ${enabledNewCeFrameworkFlagInDu}=0
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdTputPoolingEcpri72eAllowed}=0

*** Keywords ***

CB013527 Setup With Custom Config
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...                  vendorParam: list of vendor parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}    ${IPHY}=${EMPTY}
    ...                      ${rdParam}=${EMPTY}    ${vendorParam}=${EMPTY}

    Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    ...      iphy=${IPHY}
    ...      rad_params=@{rdParam}
    ...      vendor_params=@{vendorParam}

CB013527 Cell Setup With Syslogs
    [Documentation]
    ...         Actions : collect syslog during cell setup
    ...         Params :  none
    ...         Return :  syslog file
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}    name=cellSetup
    Setup Wtsemu SA          shouldUseLua=False
    sleep    10s
    WTS Set X2 Link
    sleep    5s
    ${syslogFile}            SYSLOG Stop     syslog=${syslog}
    RETURN                   ${syslogFile}


CB013527 json recommissioning
    [Arguments]               ${jsonFile}

    ${gnb_alias}              Set Variable    gnb_under_test
    sbts_coam.connect_to      name=${gnb_alias}

    Dated Log New Line        ===> Perform SCF delta commissioning
    coam_parameter.perform_scf_delta_commission
    ...                       delta_file=${jsonFile}
    ...                       connection=${gnb_alias}
    ...                       timeout=600

    sbts_coam.teardown        connection=${gnb_alias}

    Dated Log New Line        ===> OAM wait available
    ...                       OAM wait available

CB013527 Full Recommissioning
    [Arguments]                 ${scf}
    OAM Perform Full Commissioning    scf_file=${scf}
    OAM wait available

Multi Cells Setup CB013527
    [Arguments]       ${nbCell}
    ${msgStr}=    Catenate  Test ${nbCell} Cells Setup
    Dated Log   ${msgStr}
    Setup Wtsemu SA
    sleep    60s
    WTS Set X2 Link
    sleep    5s
    #wtsemu.ue_testmode_decode_muxphychan    decode_mux_phy_chan=decode_PDSCH
    #sleep    2s

CB013527 define SA UEs
    [Arguments]               ${UEdefList}

    ${nbUEs}                  Get Length    ${UEdefList}

    Dated Log New Line     ===> Define ${nbUEs} SA UEs in CFG
    Create UEs in Cfg File    nb_sa_ues=${nbUEs}

    ${SA_UE_id}               Set Variable    1
    ${UEs_SA_list}            Create List

    FOR    ${UEitem}    IN     @{UEdefList}
        # Copy UE dictionary from SWENG according to call type
        ${UEdef}              Copy Dictionary     ${BASIC_UE_SA}

        # Set UE id according to call type and target cell
        Set To Dictionary     ${UEdef}     ue    ${SA_UE_id}

        ${tgtCellId}          Set Variable      ${TDD_Cell_list[${UEitem.targetCell}-1].nrCellId}
        Set To Dictionary     ${UEdef}     target_cells      ${tgtCellId}
        Set To Dictionary     ${UEdef}     dlthroughput      ${UEitem.dltput}
        Set To Dictionary     ${UEdef}     ulthroughput      ${UEitem.ultput}
        Set To Dictionary     ${UEdef}     pdu               ${SA_UE_id}
        Set To Dictionary     ${UEdef}     ue_srs_beam_pos_profile      ${UEitem.pos_profile}

        Modify UE Data in Cfg File    sa_or_nsa=SA    ue_id=${SA_UE_id}   cell_id=${tgtCellId}

        Dated Log new line    ==== ${UEdef} ====

        Append To List        ${UEs_SA_list}     ${UEdef}
        ${SA_UE_id}           Evaluate           ${SA_UE_id}+1
    END

    Set Suite Variable        ${UEs_SA_list}

CB013527 Workaround 6 cells
    [Arguments]            ${UEitem}
    Dated Log New Line      ====deregister SA UE : ${UEitem} ====
    UE Deregister    id=${UEitem.ue}

    Dated Log New Line      ====attach SA UE : ${UEitem} ====
    ${RNTI}                 UE Register         ue=${UEitem.ue}
    Launch PDU Session      ue=${UEitem.ue}     pdu=${UEitem.pdu}    gw=${UEitem.ue}
    Set To Dictionary       ${UEitem}    c_rnti    ${RNTI}


CB013527 attach SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach SA UE : ${UEitem} ====
        ${RNTI}                 UE Register         ue=${UEitem.ue}
        Launch PDU Session      ue=${UEitem.ue}     pdu=${UEitem.pdu}    gw=${UEitem.ue}
        Set To Dictionary       ${UEitem}    c_rnti    ${RNTI}
    END

CB013527 UE Deregister SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        UE Deregister    id=${UEitem.ue}
    END

CB013527 attach NSA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach NSA UE : ${UEitem} ====
        SgNB Addition to ENB    ueSetting=${UEitem}
    END


CB013527 start traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        # IF   ${UEitem.ue} >= 4
        #     CB013527 Workaround 6 cells     ${UEitem}
        # END
        # Dated Log New Line      ==== Apply Workaround for ue4 ====
        Traffic UE DL           ueSetting=${UEitem}    throughput=${UEitem.dlthroughput}    deviation=35
        ...                     duration=20s            shouldBeStop=${False}
        ...                     use_uestatsnr=${True}   NSA_UE=${False}
    END


CB013527 start traffic DL GBR
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${current_ue_setting} ${current_trf_id}
    ...     Actions:        it manages the DL traffic GBR on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed
    [Arguments]             ${UElist}
    ...                     ${current_trf_id}=20


    FOR    ${UEitem}    IN     @{UElist}
        ${oldtrfif}             set variable    ${UEitem.trf_id}
        CallSetup.UE PDU Session Modify    ue=${UEitem.ue}
            ...                            pdu=${UEitem.pdu}
            ...                            qfta=2
            ...                            by=amf

        CallSetup.UE PDU Session Modify    ue=${UEitem.ue}
            ...                            pdu=${UEitem.pdu}
            ...                            qfta=3
            ...                            by=amf

        # Step 1 on qfi=2 with protocol tcp
        Set To Dictionary      ${UEitem}    trf_id    ${current_trf_id}
        Set To Dictionary      ${UEitem}    qfi    2
        Traffic UE DL           ueSetting=${UEitem}    throughput=${GBRdlthroughput}    deviation=35
        ...                     duration=20s            shouldBeStop=${False}   protocol=tcp
        ...                     use_uestatsnr=${True}   NSA_UE=${False}

    # Step 2 on qfi=3 with protocol udp
        ${current_trf_id}=      Evaluate    ${current_trf_id} + 1
        Set To Dictionary       ${UEitem}    trf_id    ${current_trf_id}
        Set To Dictionary       ${UEitem}    qfi    3
        Traffic UE DL           ueSetting=${UEitem}    throughput=${GBRdlthroughput}    deviation=35
        ...                     duration=20s            shouldBeStop=${False}   protocol=udp
        ...                     use_uestatsnr=${True}   NSA_UE=${False}
        Set To Dictionary       ${UEitem}    trf_id    ${oldtrfif}
        Set To Dictionary       ${UEitem}    qfi    1

    END



CB013527 stop traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=dl
    END

CB013527 start traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE UL           ueSetting=${UEitem}    throughput=${UEitem.ulthroughput}    deviation=99
        ...                     duration=20s            shouldBeStop=${False}    use_uestatsnr=${True}
        ...                     use_uestatsnr=${True}   NSA_UE=${False}
    END

CB013527 stop traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=ul
    END

CB013527 start TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # TTI capture configuration
    ${TTIdir}              Get TTI Trace Path    dir_suffix=${suffix}
    set Suite Variable     ${TTIdir}

    # Start TTI capture
    Dated Log New Line     ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

CB013527 stop TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # Stop TTI capture
    Dated Log New Line     ===> stop TTI traces capture
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTI_${suffix}
    set Suite Variable     ${TTIpcap}

CB013527 Add Dummy Pdsch On All UEs
    [Documentation]
    ...       Activate CNI-101738 dummy pdsch load via aaShell command
    ...       LcrIdMask: LCR Id mask of the target cell(s) (0xFFFF: activated on all cells)
    ...       RntiMask: RNTI mask of the targeted UE(s) (0xFFFF: activated for all UEs)
    [Arguments]            ${LcrIdMask}=0xFFFF    ${RntiMask}=0xFFFF
    Dated Log new line                 ====> Activate dummy load on all UEs
    ${rdEnableDummyLoadDl}              Set Variable         0x58017A
    ${rdDummyLoadDlLcrIdAndRnti}        Set Variable         0x58017B
    ${rdDummyLoadDlBsr}                 Set Variable         0x58017C
    ${LcrIdAndRnti}                     Evaluate             ${LcrIdMask}*65536+${RntiMask}
    Set Rad Parameter Using Aashell    rad_param_value=1000000            rad_param=${rdDummyLoadDlBsr}
    Set Rad Parameter Using Aashell    rad_param_value=${LcrIdAndRnti}    rad_param=${rdDummyLoadDlLcrIdAndRnti}
    Set Rad Parameter Using Aashell    rad_param_value=1                  rad_param=${rdEnableDummyLoadDl}

CB013527 Remove Dummy Pdsch Load
    [Documentation]
    ...     Deactivate dummy load via aaShell command
    Dated Log new line                 ====> Deactivate dummy load
    Set Rad Parameter Using Aashell    rad_param_value=0             rad_param=${rdEnableDummyLoadDl}


CB013527 End Of TC
   [Documentation]        At the end of each TC :
   ...                      - show the Diagnosis of the TC steps
   ...                      - collect the gnb Snapshot
   ...                      - if TC failed, collect also AP sosReport

   Dated Log              End Of TC :  add produce scout data ...
   # Oam.OAM Get Snapshot
   # Run Keyword If Test Failed     Setup.Get Sos Report
   GenericTest.Display Diagnosis
   # Dated Log              End of TC : end
   # Dated Log              start Teardown ... restore files
   # Restore Files          listFileDesc=${FD_ALL}
   # OAM Restore Files
   Setup.Produce Scout Data

