*** Settings ***
Documentation     [SUITE PURPOSE]  Common Keywords of CB013098
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : philippe.daroux@nokia.com
...               Creation Date               : 14-08-2025
...               Modified Date               : 16-09-2025
...               Last Modified by            : philippe.daroux@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2507    philippe.daroux@nokia.com             Creation

Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim           WITH NAME    wts
Library           taf.wts.runner                         WITH NAME    wtsemu
Library           taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME   coam_parameter

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
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot





*** Keywords ***

TC CB013098-TC-Cell-Setup
    [Documentation]
    ...     Conditions:     CB013098_SR_A activation
    ...     Actions:        Cell setup & call setup
    ...     Checks:         ...
    ...     Verdict:        ...
    [Arguments]             ${param}


    Init Sequence           ${param}
    Dated Log New Line      =====  Params : ${param}
    # Critical Step           Perform Recommissionning if need
    #Critical Step           Restart TL
    Step                    Multi Cells Setup CB013098               argument=${param.nbCell}
#	Step					Oam.OAM Get Snapshot



Suite Setup CB013098
    [Documentation]
    ...     Conditions:     it needs no conditions
    ...     Actions:        it performs the generic suite setup and backup the configurations files
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        suite setup is passed
    [Arguments]             ${yaml_file_path}

    Setup.Suite Setup From Scratch    keepAllUeDataInCfgFile=${False}
    ...     automaticTeardown=${True}
    ...     yamlPathname=${yaml_file_path}
    Backup Files
    ${scf_suite_setup_backup}         OAM Get SCF File    file=SCF_Suite_Setup_Backup.xml
    Set Suite Variable      ${scf_suite_setup_backup}
    Dated Log               SCF backup file = ${scf_suite_setup_backup}


Multi Cells Setup CB013098
    [Arguments]       ${nbCell}
    ${msgStr}=    Catenate  Test ${nbCell} Cells Setup
    Dated Log   ${msgStr}
    Setup Wtsemu SA
    sleep    60s
    WTS Set X2 Link
    sleep    5s
    #wtsemu.ue_testmode_decode_muxphychan    decode_mux_phy_chan=decode_PDSCH
    #sleep    2s

CB013098 define UEs
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



CB013098 attach SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach SA UE : ${UEitem} ====
        ${RNTI}                 UE Register         ue=${UEitem.ue}
        Launch PDU Session      ue=${UEitem.ue}     pdu=${UEitem.pdu}    gw=${UEitem.ue}
        Set To Dictionary       ${UEitem}    c_rnti    ${RNTI}
    END

CB013098 attach SA UE4
    ${RNTI}                 UE Register         ue=4
    Launch PDU Session_failure      ue=4     pdu=4    gw=4

Launch PDU Session_failure
    [Arguments]    ${ue}=4    ${pdu}=4    ${nwslice}=1    ${gw}=4    ${timeout}=30
    wtsemu.ue_pdu_session_setup
    ...               pdu=${pdu}                ue=${ue}
    ...               nwslice=${nwslice}        gw=${gw}
    ${output}         wtsemu.Read Wtsemu Output Until Re
    ...               expected=Initial Context Setup Failure
    ...               timeout=${timeout}
   # ${output}         StringTool.getStringFromCmdReturn    ${output}
   # ${pattern}=       Catenate                  Allocated PduSessionFsm with PDU session ID:${pdu} .*
   # ...               UE IP address:([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})
   # ${ue_ip}=         Get Regexp Matches        ${output}
   # ...               ${pattern}                1
   # [Return]      ${ue_ip[0]}


CB013098 attach NSA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach NSA UE : ${UEitem} ====
        SgNB Addition to ENB    ueSetting=${UEitem}
    END

CB013098 Unregister NSA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        UE Detach Enb    ueSetting=${UEitem}
    END

CB013098 UE Deregister SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        UE Deregister    id=${UEitem.ue}
    END

CB013098 start traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE DL           ueSetting=${UEitem}    throughput=${UEitem.dlthroughput}    deviation=35
        ...                     duration=10s            shouldBeStop=${False}
    END

CB013098 stop traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=dl
    END

CB013098 start traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE UL           ueSetting=${UEitem}    throughput=${UEitem.ulthroughput}    deviation=50
        ...                     duration=10s            shouldBeStop=${False}
    END

CB013098 stop traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=ul
    END

CB013098 start TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # TTI capture configuration
    ${TTIdir}              Get TTI Trace Path    dir_suffix=${suffix}
    set Suite Variable     ${TTIdir}

    # Start TTI capture
    Dated Log New Line     ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

CB013098 stop TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # Stop TTI capture
    Dated Log New Line     ===> stop TTI traces capture
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTI_${suffix}
    set Suite Variable     ${TTIpcap}


End Of TC
   [Documentation]        At the end of each TC :
   ...                      - show the Diagnosis of the TC steps
   ...                      - collect the gnb Snapshot
   ...                      - if TC failed, collect also AP sosReport

   Dated Log              End Of TC : start ... produce scout data ...
   # Oam.OAM Get Snapshot
   # Run Keyword If Test Failed     Setup.Get Sos Report
   # GenericTest.Display Diagnosis
   # Dated Log              End of TC : end
   # Dated Log              start Teardown ... restore files
   # Restore Files          listFileDesc=${FD_ALL}
   # OAM Restore Files
   Produce Scout Data
