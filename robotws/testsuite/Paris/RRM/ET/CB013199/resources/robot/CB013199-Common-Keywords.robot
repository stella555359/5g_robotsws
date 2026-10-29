*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013199-A
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-06-2024
...               Modified Date               : 19-06-2024
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2419    ying.yw.wu@nokia.com              Creation
...               0.2       FB2420    ying.yw.wu@nokia.com              Adding .json and BSR download for DL mumimo config
...				  0.3       FB2424    ying.yw.wu@nokia.com              Adding rad param of CB013199 activation flag
...               0.4       FB2426    ying.yw.wu@nokia.com              Adding keywords for SA ue setup, dl, ul traffic
...               0.5       FB2505    ying.yw.wu@nokia.com              Remove the rad param 0x420062, now by default active
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim           WITH NAME    wts
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

TC CB013199-TC-Cell-Setup
    [Documentation]
    ...     Conditions:     CB013199-A activation
    ...     Actions:        Cell setup & call setup
    ...     Checks:         ...
    ...     Verdict:        ...
    [Arguments]             ${param}


    Init Sequence           ${param}
    Step                    Set RAD Params Of CB013199
    # Step                    Deploy Vendor File Config
    Dated Log New Line      =====  Params : ${param}
    # Critical Step           Perform Recommissionning if need
    Critical Step           Restart TL
    Step                    Multi Cells Setup CB013199               argument=${param.nbCell}
	Step					Oam.OAM Get Snapshot

CB013199 json recommissioning
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

CB013199 Full Recommissioning
    [Arguments]                 ${scf}
    OAM Perform Full Commissioning    scf_file=${scf}
    OAM wait available



Suite Setup CB013199
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



Set RAD Params Of CB013199
    [Documentation]     Add or Modify the RAD params of 8940 To Activate the feature
    ...                 will be replaced later by NIDD params
    ...                 0x590072=1 : CPRT debug log
    ...                 0x58057A=4 : L2 feature log DBG level
    ...                 0x58057C=0x3800 : rdFeatureFlagBitmap1 (bit 11 - PRB_POOLING.BASIC,
    ...                 bit 12 - PRB_POOLING.DL, bit 13 - PRB_POOLING.UL ==> binary 0011 1000 0000 0000)
	...					0x420062=1 : CB013199 Tput pooling activation flag
    ...	                0x58061B=1 : CB015330 activated by default in 26R1 testing
    Dated Log New Line   Add RAD params of CB013199 A ......
    ${rad_param_1}=      create dictionary       field=0x590072    value=1
    ${rad_param_2}=      create dictionary       field=0x58057A    value=4
    ${rad_param_3}=      create dictionary       field=0x58057C    value=0x3800
	# ${rad_param_4}=      create dictionary       field=0x420062	   value=1
    ${rad_param_4}=      create dictionary       field=0x58061B	   value=1
    ${rad_param_list}=       Create List         ${rad_param_1}
    ...                                          ${rad_param_2}
    ...                                          ${rad_param_3}
    ...                                          ${rad_param_4}
    Dated Log New Line    RAD params :  ${rad_param_list}
    SetConfig.Set Fields in swconfig DU       param_list=${rad_param_list}
    Dated Log New Line   RAD params of CB013199 update completed


Multi Cells Setup CB013199
    [Arguments]       ${nbCell}
    ${msgStr}=    Catenate  Test ${nbCell} Cells Setup
    Dated Log   ${msgStr}
    Setup Wtsemu SA
    sleep    60s
    WTS Set X2 Link
    sleep    5s
    #wtsemu.ue_testmode_decode_muxphychan    decode_mux_phy_chan=decode_PDSCH
    #sleep    2s

CB013199 define SA UEs
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



CB013199 attach SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach SA UE : ${UEitem} ====
        ${RNTI}                 UE Register         ue=${UEitem.ue}
        Launch PDU Session      ue=${UEitem.ue}     pdu=${UEitem.pdu}    gw=${UEitem.ue}
        Set To Dictionary       ${UEitem}    c_rnti    ${RNTI}
    END

CB013199 UE Deregister SA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        UE Deregister    id=${UEitem.ue}
    END

CB013199 attach NSA UEs
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Dated Log New Line      ====attach NSA UE : ${UEitem} ====
        SgNB Addition to ENB    ueSetting=${UEitem}
    END


CB013199 start traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE DL           ueSetting=${UEitem}    throughput=${UEitem.dlthroughput}    deviation=35
        ...                     duration=10s            shouldBeStop=${False}
    END

CB013199 stop traffic DL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=dl
    END

CB013199 start traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic UE UL           ueSetting=${UEitem}    throughput=${UEitem.ulthroughput}    deviation=50
        ...                     duration=10s            shouldBeStop=${False}
    END

CB013199 stop traffic UL
    [Arguments]            ${UElist}
    FOR    ${UEitem}    IN     @{UElist}
        Traffic Stop            ueSetting=${UEitem}    dir=ul
    END

CB013199 start TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # TTI capture configuration
    ${TTIdir}              Get TTI Trace Path    dir_suffix=${suffix}
    set Suite Variable     ${TTIdir}

    # Start TTI capture
    Dated Log New Line     ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

CB013199 stop TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # Stop TTI capture
    Dated Log New Line     ===> stop TTI traces capture
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTI_${suffix}
    set Suite Variable     ${TTIpcap}

CB013199 Add Dummy Pdsch On All UEs
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

CB013199 Remove Dummy Pdsch Load
    [Documentation]
    ...     Deactivate dummy load via aaShell command
    Dated Log new line                 ====> Deactivate dummy load
    Set Rad Parameter Using Aashell    rad_param_value=0             rad_param=${rdEnableDummyLoadDl}


CB013199 End Of TC
   [Documentation]        At the end of each TC :
   ...                      - show the Diagnosis of the TC steps
   ...                      - collect the gnb Snapshot
   ...                      - if TC failed, collect also AP sosReport

   Dated Log              End Of TC : start ... produce scout data ...
   GenericTest.Display Diagnosis
   Setup.Produce Scout Data

