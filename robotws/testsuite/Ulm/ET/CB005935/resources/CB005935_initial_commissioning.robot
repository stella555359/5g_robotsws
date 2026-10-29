*** Settings ***
Documentation    Scenario specific keywords for CB005935 of feature "Inter band FDD UL CA 2CCs"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality
    ...                                 miNrDlHarq  miNrUlHarq
    ...                                 miNrDlHarqLowSEMCS  miNrUlHarqLowSEMCS  miNrSignalQualityLowSEMCS
    ...                                 miNrPdcch  miNrResourceUtilizationPerCell  miNrPdcch2
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate CB009267
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Element    dist_name=${distName_NRBTS[0]}     p_name=actCarAgPmCount              value=true


Cfg FDD Cells with 4DL4UL
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRREL_PCell}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-[0-9]+
    sort list    ${distName_NRCELL}
    sort list    ${distName_NRREL_PCell}
    Remove Values From List    ${distName_NRCELL}    NRBTS-1/NRCELL-3    NRBTS-1/NRCELL-5    NRBTS-1/NRCELL-6
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for 4DL4UL     ${NRCELL}
        ${cellNumber}=    get substring    ${NRCELL}    -1
        Modify CHANNELGROUP-1 for 4DL4UL   ${cellNumber}   ${cellNumber}
    END
    Configure each Cell for 4DL4UL     MRBTS-1/NRBTS-1/NRCELL-5
    Modify CHANNELGROUP-1 for 4DL4UL    5   2


Configure each Cell for 4DL4UL
    [Arguments]  ${distName}
    FOR    ${p_name}    ${value}    IN
    ...    dlMimoMode                            4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    nrCellType                            4DL4UL
        Set Element   dist_name=${distName}    p_name=${p_name}    value=${value}
    END


Modify CHANNELGROUP-1 for 4DL4UL
    [Arguments]  ${cellNumber}  ${rmodNumber}
    FOR  ${channelId}  IN RANGE  1   5
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=NRBTSCL23R3_2305_100
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=TX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=antlDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmodNumber}/ANTL-${channelId}
    END
    FOR  ${channelId}  IN RANGE  5   9
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=NRBTSCL23R3_2305_100
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=RX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=antlDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${rmodNumber}/ANTL-${channelId-4}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Adding NRREL
    [Arguments]  ${pcell_id}  ${scell_id}  ${dir}  ${nrrel_id}  ${sCellAdditionMethod}
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${distName_NRREL}=  set variable  ${distName_NRCELL[${pcell_id}-1]}/NRREL-${nrrel_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}                                         ${value}    IN
    ...    cellIndividualSsbRsrpOffset         0dB
    ...    cellIndividualSsbRsrqOffset         0dB
    ...    gNbId                               1
    ...    gNbIdLength                         22
    ...    handoverAllowedSA                   allowed
    ...    handoverAllowedSARedCap             forbidden
    ...    isRplCellForPSCell                  false
    ...    lcrId                               ${scell_id}
    ...    nrDcAllowed                         false
    ...    removeNotAllowed                    false
    ...    sCellAdditionMethod                 ${sCellAdditionMethod}
    ...    sCellOperationalMode                ${dir}
        Set Element    dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Adding NRHOIF
    [Arguments]  ${pcell_id}  ${freqBandIndicatorNR}  ${ssbFrequency}  ${nrhoif_id}
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${distName_NRHOIF}=  set variable  ${distName_NRCELL[${pcell_id}-1]}/NRHOIF-${nrhoif_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRHOIF
    ...           dist_name=${distName_NRHOIF}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}                                         ${value}    IN
    ...    a1BasedPCellSwitchEnabled         false
    ...    a2BasedPCellSwitchEnabled         false
    ...    a3MeasEnabled                     rsrp
    ...    a4MeasEnDcSteeringEnabled         none
    ...    a4MeasHigherPrioFreqEnabled       none
    ...    a4MeasNrDcEnabled                 none
    ...    a4MeasSCellAddEnabled             none
    ...    a5MeasEnabled                     none
    ...    cellDepType                       SA
    ...    deriveSsbIndexFromCell            true
    ...    freqBandIndicatorNR               ${freqBandIndicatorNR}
    ...    ifhoSsbScs                        15KHz
    ...    ifhoSsbSmtcDuration               sf1
    ...    ifhoSsbSmtcPeriodicity            sf5
    ...    numberOfTransmittedSsBlocks       1 beam
    ...    ssBurstSetPeriod                  20
    ...    ssbFrequency                      ${ssbFrequency}
        Set Element    dist_name=${distName_NRHOIF}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRHOIF}  list_name=a3MeasSsbRsrp
    ${a3MeasSsbRsrp_item}=  create dictionary
    ...    a3HysteresisSsbRsrp               2
    ...    a3OffsetSsbRsrp                   3
    ...    a3TimeToTriggerSsbRsrp            ms0
    scf.add_item_to_list    dist_name=${distName_NRHOIF}   list_name=a3MeasSsbRsrp   elements=${a3MeasSsbRsrp_item}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
