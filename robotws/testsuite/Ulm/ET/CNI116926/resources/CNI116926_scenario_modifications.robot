*** Settings ***
Documentation    Scenario specific keywords for CNI-116926 features

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library     Collections
Library     ../../L2/libraries/tools.py
Resource    ../../../resources/Common/wts_ue.robot


*** Keywords ***

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    sleep  1s
    run keyword and continue on failure    Start ue_rrc_reestablish    2
    run keyword and continue on failure    Start ue_rrc_reestablish    4
    sleep  1s


Start ue_rrc_reestablish
    [Arguments]  ${cell_id}
    ${attached_ues_dict}=  Get Attach List per Cell    scenario_name=${scenario_name}    ue_type=all    with_auto_attach=${TRUE}
    FOR  ${ue_id}  IN  @{attached_ues_dict['${cell_id}']}
        wts_ue.Send Egate Command And Verify Output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}
        ...    pass_regexp=rrcReconfigurationComplete
        Log To Console  ue_rrc_reestablish for UE${ue_id} on cell=${cell_id} sucessfully executed
    END


Start ue_ho_nr
    [Arguments]  ${cell_id}
    ${attached_ues_dict}=  Get Attach List per Cell    scenario_name=${scenario_name}    ue_type=all    with_auto_attach=${TRUE}
    FOR  ${ue_id}  IN  @{attached_ues_dict['${cell_id}']}
        log to console    Start: ue_ho_nr id=${ue_id} cell=${cell_id}
        wts_ue . Send Egate Command and verify output   cmd=ue_ho_nr ue_id=${ue_id} meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=636576
        sleep  0.1s
    END


Run Feature specific keywords during traffic before detach
    [Arguments]  @{varargs}
    RETURN


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    scf.load_scf    ${original_gnb_scf}
        Activate CNI116926 Feature
        Change Reporting Interval  interval_duration=${pm_reporting_interval}
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Perform Commissioning On Classical BTS    ${configuration_directory}/SCF_updated.xml


Perform Commissioning on Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect . Setup OAM http session
    admin . Perform Commissioning    scf_file=${scf_file}
    ...                              connection=${oam_alias}
    ...                              skip_parameter_relation_errors=False
    ...                              timeout=300
    connect . Teardown OAM http session


Activate CNI116926 Feature
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRCELLGRP}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    ${distName_PDCP}=       Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRDRB_PDCP-[0-9]+
    sort list    ${distName_NRCELL}
    sort list    ${distName_NRCELLGRP}
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        tools.Set Element    dist_name=${dist_name}    p_name=measGapSelectionSA          value=favourUeThroughput
    END
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 rrcReestabTypeSA                     sameGNB
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
#    Add NRREL    pcell_id=4    scell_id=3    nrrel_id=1
    Add NRHOIF    cell_id=4    nrhoif_id=1


Add NRREL
    [Arguments]  ${pcell_id}  ${scell_id}  ${nrrel_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRREL}=  Set variable  ${distName_NRCELL[${pcell_id}-1]}/NRREL-${nrrel_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                                         ${value}    IN
    ...    cellIndividualSsbRsrpOffset                       0dB
    ...    cellIndividualSsbRsrqOffset                       0dB
    ...    gNbId                                             1
    ...    gNbIdLength                                       22
    ...    handoverAllowedSA                                 allowed
    ...    handoverAllowedSARedCap                           forbidden
    ...    isRplCellForPSCell                                false
    ...    lcrId                                             ${scell_id}
    ...    nrDcAllowed                                       false
    ...    removeNotAllowed                                  false
    ...    sCellAdditionMethod                               blind
    ...    sCellOperationalMode                              dlOnly
        Set Element    dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Add NRHOIF
    [Arguments]  ${cell_id}  ${nrhoif_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRHOIF}=  Set variable  ${distName_NRCELL[${cell_id}-1]}/NRHOIF-${nrhoif_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRHOIF
    ...           dist_name=${distName_NRHOIF}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                                         ${value}    IN
    ...    a1BasedPCellSwitchEnabled                         false
    ...    a2BasedPCellSwitchEnabled                         false
    ...    a3MeasEnabled                                     rsrp
    ...    a4MeasEnDcSteeringEnabled                         none
    ...    a4MeasHigherPrioFreqEnabled                       none
    ...    a4MeasNrDcEnabled                                 none
    ...    a4MeasSCellAddEnabled                             none
    ...    a5MeasEnabled                                     none
    ...    cellDepType                                       SA+NSA
    ...    deriveSsbIndexFromCell                            true
    ...    freqBandIndicatorNR                               71
    ...    ifhoSsbScs                                        15KHz
    ...    ifhoSsbSmtcDuration                               sf1
    ...    ifhoSsbSmtcPeriodicity                            sf5
    ...    numberOfTransmittedSsBlocks                       1 beam
    ...    ssBurstSetPeriod                                  20
    ...    ssbFrequency                                      431070
        Set Element    dist_name=${distName_NRHOIF}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRHOIF}  list_name=a3MeasSsbRsrp
    ${a3MeasSsbRsrp_item}=  create dictionary
    ...    a3HysteresisSsbRsrp           2
    ...    a3OffsetSsbRsrp               3
    ...    a3TimeToTriggerSsbRsrp        ms0
    scf.add_item_to_list    dist_name=${distName_NRHOIF}   list_name=a3MeasSsbRsrp   elements=${a3MeasSsbRsrp_item}


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface  miNrRelReportCu
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


Update Basic Configuration File
    RETURN


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
