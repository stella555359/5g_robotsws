*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB015330
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 29-07-2025
...               Modified Date               : 29-07-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2516    ying.yw.wu@nokia.com              Creation
...               0.2       FB2519    ying.yw.wu@nokia.com              adding new KWs, update CB015330 RAD 0x58061B

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
Resource          ../../../resources/robot/KeyWordMarket.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot


*** Variables ***
${rdCprtDebugLog}                          0x590072
${rdL2psFeatureDebugLevel}                 0x58057A
${rdPoolingDebugLog}                       0x58057C
${rdTddInstTputPoolingUlEnhEnable}         0x58061B
${rdMcsLimit}                              0x580367


@{Rad_Param_CB015330}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdTddInstTputPoolingUlEnhEnable}=1

@{Rad_Param_CB015330_OFF}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdTddInstTputPoolingUlEnhEnable}=0

# 0xFFFF # MCS limited to 15
@{Rad_Param_CB015330_TC008}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdTddInstTputPoolingUlEnhEnable}=1
...                     ${rdMcsLimit}=0xFFFF

@{Rad_Param_CB015330_OFF_TC008}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdTddInstTputPoolingUlEnhEnable}=0
...                     ${rdMcsLimit}=0xFFFF

*** Keywords ***

CB015330 Setup With Custom Config
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...                  vendorParam: list of vendor parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}    ${IPHY}=${EMPTY}
    ...                      ${rdParam}=${EMPTY}
#	...						 ${vendorParam}=${EMPTY}

    Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    ...      iphy=${IPHY}
    ...      rad_params=@{rdParam}
    # ...    vendor_params=@{vendorParam}

CB015330 Cell Setup With Syslogs
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

CB015330 Set SINR Pathloss On UE
    [Documentation]         test mode 'ul_sinr_testmode_nr'
    [Arguments]             ${UElist}
    # Define pathloss profile
    wtsemu.ul_sinr_testmode_nr     profile_id=1
    ...                            pathloss=70
    # Activate pathloss profile on UE
    FOR    ${UEitem}    IN     @{UElist}
        wtsemu.ue_testmode_set_nr         id=${UEitem.ue}
        # ...                               scell=1
        ...                               testmode=ul_sinr
        ...                               action=activate
        ...                               profile_id=1
    END

CB015330 Set Mumimo UEs position
    [Documentation]          In Mumimo testing, test mode 'ul_mimo_srs_beam_pos_nr' in egate is used to position the UE
    ...                      in a Pre-defined Quadrant/sub-Quadrant position relative to the RU geometry
    [Arguments]             ${UElist}

    # Define UE position profiles
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=1    mode=fixed    init_quad_pos=0    init_sub_quad_pos=0
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=2    mode=fixed    init_quad_pos=1    init_sub_quad_pos=0
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=3    mode=fixed    init_quad_pos=2    init_sub_quad_pos=0
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=4    mode=fixed    init_quad_pos=3    init_sub_quad_pos=0

    FOR    ${UEitem}    IN     @{UElist}
        wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        ...                          testmode=ul_mimo_srs_beam_pos
        ...                          action=activate
        ...                          profile_id=${UEitem.ue_srs_beam_pos_profile}
    END

CB015330 Build Multi UE List From CFG
    [Arguments]               ${UEdefList}
    ${nbUEs}                  Get Length    ${UEdefList}
    Dated Log New Line     ===> In total : ${nbUEs} Defined
    ${UE_id}                  Set Variable    1
    ${Multi_UE_list}          Create List
    FOR    ${UEitem}    IN     @{UEdefList}
        # Copy UE dictionary from SWENG according to call type
        ${UEdef}              Copy Dictionary     ${BASIC_UE_SA}
        # Set UE id according to call type and target cell
        Set To Dictionary     ${UEdef}     ue    ${UE_id}

        ${tgtCellId}          Set Variable      ${TDD_Cell_list[${UEitem.targetCell}-1].nrCellId}
        Set To Dictionary     ${UEdef}     target_cells      ${tgtCellId}
        Set To Dictionary     ${UEdef}     dlthroughput      ${UEitem.dltput}
        Set To Dictionary     ${UEdef}     ulthroughput      ${UEitem.ultput}
        Set To Dictionary     ${UEdef}     pdu               ${UE_id}
        Set To Dictionary     ${UEdef}     ue_srs_beam_pos_profile      ${UEitem.pos_profile}
        Dated Log new line    ==== ${UEdef} ====
        Append To List        ${Multi_UE_list}     ${UEdef}
        ${UE_id}              Evaluate             ${UE_id}+1
    END
    Set Suite Variable        ${Multi_UE_list}

CB015330 define SA UEs
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



CB015330 attach SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach SA UE : ${UEitem} ====
        ${RNTI}                 UE Register         ue=${UEitem.ue}
        Launch PDU Session      ue=${UEitem.ue}     pdu=${UEitem.pdu}    gw=${UEitem.ue}
        Set To Dictionary       ${UEitem}    c_rnti    ${RNTI}
    END

CB015330 UE Deregister SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        UE Deregister    id=${UEitem.ue}
    END

CB015330 attach NSA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach NSA UE : ${UEitem} ====
        SgNB Addition to ENB    ueSetting=${UEitem}
    END


CB015330 start traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE DL           ueSetting=${UEitem}    throughput=${UEitem.dlthroughput}    deviation=75
        ...                     duration=10s            shouldBeStop=${False}
    END

CB015330 stop traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=dl
    END

CB015330 start traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE UL           ueSetting=${UEitem}    throughput=${UEitem.ulthroughput}    deviation=100
        # ...                     duration=10s            shouldBeStop=${False}               shouldBeCheck=${False}
        ...                     duration=10s            shouldBeStop=${False}
    END

CB015330 stop traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=ul
    END

CB015330 start TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # TTI capture configuration
    ${TTIdir}              Get TTI Trace Path    dir_suffix=${suffix}
    set Suite Variable     ${TTIdir}

    # Start TTI capture
    Dated Log New Line     ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

CB015330 stop TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # Stop TTI capture
    Dated Log New Line     ===> stop TTI traces capture
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTI_${suffix}
    set Suite Variable     ${TTIpcap}


CB015330 End Of TC
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

