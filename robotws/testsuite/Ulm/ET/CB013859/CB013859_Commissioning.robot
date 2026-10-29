*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: Commissioning for CB013859-A and -B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource  ./CB013859_Keywords.robot

*** Keywords ***

Common Commissioning For All Sub-Features
    [Documentation]  Common commissioning based on sub-features A and B.
    ...    Primary cell planned for Sub-features A and B is Cell-1:PCI-51 (NR Freq Band 41) configured with 3 relation SCells for CA: Cell-2:PCI-52
    ...    (NR Freq Band 41), Cell-7:PCI-57 (NR Freq Band 25) and Cell-10:PCI-60 (NR Freq Band 71).
    ${config_dir}=      Get Test Suite Config Directory
    scf.Load Scf        ${P_ORIG_SCF}
    Add NRADJGNB To SCF
    Add NRADJNRCELL To SCF
    Add NRRELs To TDD_PCELL    pcell_id=1
    Add NRRELs To FDD_PCELL    pcell_id=7
    Configure A1 Measurement Parameters For RSRP For SCell Addition   cell_id=1
    Configure A1 Measurement Parameters For RSRP For SCell Addition   cell_id=7
    Configure A2 Measurement Parameters For RSRP For SCell Release
    Configure A6 Measurement Parameters For RSRP For SCell Swap
    Configure A4 Measurement Parameters For RSRP_Combined For SCell Addition
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actBufferBasedSCellAddition    value=disabled
    FOR   ${cell_idx}   IN   2   7   10   4
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_idx}    p_name=weightForSCellSelection    value=50
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_idx}    p_name=actK1Opt                   value=intraAndInter-gNB
    END
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    p_name=actK1Opt    value=intraAndInter-gNB
    sqd65_commissioning.Remove Object  dist_name=MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actSliceAwareScheduler    value=true
    Update SNSSAIs In SCF
    Define TRACKINGAREAs And Add SNSSAIs To Them
    Define TrackingAreaDNs Mapping In Cells
    Define Measurement Interval For NR CA Measurements
    Define PM Measurement Interval
    Add NRRESOURCEGROUP_PROFILE
    Define NrResourceGroupProfileDNs Mapping In Cells
    scf.Save Scf                    ${config_dir}/CB013859_SCF.xml
    commissioning.Execute Full Commissioning      ${config_dir}/CB013859_SCF.xml


Add NRADJGNB To SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRADJGNB-1
    sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:NRADJGNB    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   administrativeState               Unlocked
    ...   gNbIdLength                       22
    ...   gNodeBId                          3
    ...   gNodeBIdCtrl                      oamControlled
    ...   xnLinkRef                         2
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              310
    ...    mnc              260
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${dist_name}   list_name=gnbPlmn   elements=${gnbPlmn_item}
    Create XNLINK-2
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actIntraNrNgHo    value=sourceAndTarget
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=suppCnPartialAdNgHo    value=true


Create XNLINK-2
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/XNLINK-2
    sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:XNLINK    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cPlaneIpAddr                      10.0.1.4
    ...   cPlaneIpAddrCtrl                  oamControlled
    ...   localCuIpAddr                     10.0.1.2
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


Add NRADJNRCELL To SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRADJNRCELL-1
    sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:NRADJNRCELL    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellDepType                       SA
    ...   cellReservedForOperatorUse        notReserved
    ...   fiveGsTac                         1
    ...   freqBandIndicatorNR               41
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   lcrId                             1
    ...   nrarfcn                           528000
    ...   physCellId                        48
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=gnbPlmn
    ${gnbPlmn_item}=  Create Dictionary
    ...    mcc              310
    ...    mnc              260
    ...    mncLength        3
    scf.Add Item To List    dist_name=${dist_name}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Add NRRELs To TDD_PCELL
    [Arguments]  ${pcell_id}
    FOR   ${scell_id}      ${nrrel_id}          IN
    ...   2                1
    ...   7                2
    ...   10               3
    ...   1                4
    ...   4                5
        Add NRREL    pcell_id=${pcell_id}    scell_id=${scell_id}    dir=dlOnly    nrrel_id=${nrrel_id}
    END


Add NRRELs To FDD_PCELL
    [Arguments]  ${pcell_id}
    FOR   ${scell_id}      ${nrrel_id}          IN
    ...   1                1
    ...   2                2
    ...   10               3
        Add NRREL    pcell_id=${pcell_id}    scell_id=${scell_id}    dir=dlOnly    nrrel_id=${nrrel_id}
    END


Add NRREL
    [Arguments]  ${pcell_id}  ${scell_id}  ${dir}  ${nrrel_id}
    ${mo_exist}=    scf.is_object_in_scf    dist_name=NRBTS-1/NRCELL-${pcell_id}
    IF    not ${mo_exist}
        RETURN
    END
    ${distName_NRREL}=    Set Variable    NRBTS-1/NRCELL-${pcell_id}/NRREL-${nrrel_id}
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${distName_NRREL}
    IF    ${mo_exist}
        RETURN
    END
    sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:NRREL    dist_name=${distName_NRREL}   version=${NIDD_VERSION}
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
    ...    removeNotAllowed                                  true
    ...    sCellAdditionMethod                               covBasedA1
    ...    sCellOperationalMode                              ${dir}
        sqd65_commissioning.Set Element    dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    IF    '${pcell_id}' == '1' and '${nrrel_id}' == '4'
        sqd65_commissioning.Set Element         dist_name=${distName_NRREL}    p_name=gNbId                 value=3
        sqd65_commissioning.Set Element         dist_name=${distName_NRREL}    p_name=removeNotAllowed      value=false
        sqd65_commissioning.Remove Element      dist_name=${distName_NRREL}    p_name=sCellAdditionMethod
        sqd65_commissioning.Remove Element      dist_name=${distName_NRREL}    p_name=sCellOperationalMode
    END
    IF         '${pcell_id}' == '1' and '${nrrel_id}' == '1'
        sqd65_commissioning.Set Element    dist_name=${distName_NRREL}    p_name=sCellPrio    value=1
    ELSE IF    '${pcell_id}' == '1' and '${nrrel_id}' == '5'
        sqd65_commissioning.Set Element    dist_name=${distName_NRREL}    p_name=sCellPrio    value=2
    END
    sqd65_commissioning.Set New List       dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  Create Dictionary
    ...    mcc              310
    ...    mnc              260
    ...    mncLength        3
    scf.Add Item To List    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Configure A1 Measurement Parameters For RSRP For SCell Addition
    [Arguments]    ${cell_id}
    sqd65_commissioning.Set New List                dist_name=MRBTS-1/NRBTS-1      list_name=actMeasBasedSCellAdditionSa
    ${meas_based_scell}=        Create List                    A1-based
    scf.Add Elements To List    dist_name=MRBTS-1/NRBTS-1      list_name=actMeasBasedSCellAdditionSa       elements=${meas_based_scell}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    sqd65_commissioning.Set Element       dist_name=${dist_name}          p_name=a1MeasSCellAddEnabled       value=rsrp
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp
    ${list_elements}=       Create Dictionary                    a1HysteresisSCellAddSsbRsrp             0
    ...                                                          a1ThresholdSCellAddSsbRsrpFDD           40
    ...                                                          a1ThresholdSCellAddSsbRsrpTDD           60
    ...                                                          a1TimeToTriggerSCellAddSsbRsrp          320ms
    scf.Add Item To List    dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp         elements=${list_elements}


Configure A2 Measurement Parameters For RSRP For SCell Release
    FOR    ${cell_index}    IN    2    7    10
        ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-${cell_index}
        sqd65_commissioning.Set Element         dist_name=${dist_name}    p_name=a2MeasSCellRelEnabled    value=rsrp
        ${list_name}=             Set Variable              a2MeasSCellRelSsbRsrp
        sqd65_commissioning.Set New List                    dist_name=${dist_name}                    list_name=${list_name}
        ${list_elements}=         Create Dictionary         a2HysteresisSCellRelSsbRsrp               0
        ...                                                 a2ThresholdSCellRelSsbRsrp                34
        ...                                                 a2TimeToTriggerSCellRelSsbRsrp            480ms
        scf.Add Item To List    dist_name=${dist_name}    list_name=${list_name}    elements=${list_elements}
    END


Configure A6 Measurement Parameters For RSRP For SCell Swap
    sqd65_commissioning.Set Element         dist_name=MRBTS-1/NRBTS-1    p_name=actSCellSwapFr1    value=a6BasedSa
    FOR    ${cell_index}    IN    2    4
        ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-${cell_index}
        sqd65_commissioning.Set Element         dist_name=${dist_name}    p_name=a6MeasSCellSwapEnabled          value=rsrp
        sqd65_commissioning.Set Element         dist_name=${dist_name}    p_name=thresholdSCellSwapSourceRsrp    value=56
        sqd65_commissioning.Set Element         dist_name=${dist_name}    p_name=reportAmountA6MeasSCellSwap     value=r4
        sqd65_commissioning.Set Element         dist_name=${dist_name}    p_name=reportIntervalA6MeasSCellSwap   value=ms1024
        ${list_name}=             Set Variable              a6MeasSCellSwapSsbRsrp
        sqd65_commissioning.Set New List                    dist_name=${dist_name}                    list_name=${list_name}
        ${list_elements}=         Create Dictionary         a6HysteresisSCellSwapSsbRsrp              0
        ...                                                 a6OffsetSCellSwapSsbRsrp                  0
        ...                                                 a6TimeToTrigSCellSwapSsbRsrp              ms480
        ...                                                 useAllowedCellListRsrp                    false
        scf.Add Item To List    dist_name=${dist_name}    list_name=${list_name}    elements=${list_elements}
    END


Configure A4 Measurement Parameters For RSRP_Combined For SCell Addition
    Configure A4 Periodic Measument Control For SA In PCell
    scf.clone mo with descendant mos    source_mo_dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2   target_mo_dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-3
    FOR   ${nrhoif_index}     ${freq_band}       ${ssb_freq}      ${a4Thresh_rsrp}    ${a4Thresh_rsrq}     IN
    ...   1                   41                 502110           70                  35
    ...   2                   25                 396970           75                  37
    ...   3                   71                 125290           77                  39
        ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-${nrhoif_index}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=a4MeasSCellAddEnabled     value=rsrpCombined
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=freqBandIndicatorNR       value=${freq_band}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=ssbFrequency              value=${ssb_freq}
        ${list_name}=             Set Variable              a4MeasSCellAddSsbRsrp
        sqd65_commissioning.Set New List                    dist_name=${dist_name}                    list_name=${list_name}
        ${list_elements}=         Create Dictionary         a4HysteresisSCellAddSsbRsrp               0
        ...                                                 a4ThresholdSCellAddSsbRsrp                ${a4Thresh_rsrp}
        ...                                                 a4TimeToTriggerSCellAddSsbRsrp            ms40
        scf.Add Item To List    dist_name=${dist_name}    list_name=${list_name}    elements=${list_elements}
        ${list_name}=             Set Variable              a4MeasSCellAddSsbRsrq
        sqd65_commissioning.Set New List                    dist_name=${dist_name}                    list_name=${list_name}
        ${list_elements}=         Create Dictionary         a4HysteresisSCellAddSsbRsrq               0
        ...                                                 a4ThresholdSCellAddSsbRsrq                ${a4Thresh_rsrq}
        ...                                                 a4TimeToTriggerSCellAddSsbRsrq            ms64
        scf.Add Item To List    dist_name=${dist_name}    list_name=${list_name}    elements=${list_elements}
    END


Configure A4 Periodic Measument Control For SA In PCell
    FOR    ${cell_index}    IN    1    7
        ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-${cell_index}
        ${list_name}=             Set Variable              a4PeriodicMeasControlSA
        sqd65_commissioning.Set New List                    dist_name=${dist_name}                    list_name=${list_name}
        ${list_elements}=         Create Dictionary         a4Fr1SupervisionTimer                     10000
        ...                                                 a4Fr2SupervisionTimer                     6000
        ...                                                 a4MeasActBlockTimer                       0
        ...                                                 a4MeasMaxNumber                           0
        ...                                                 a4RetryTimer                              1
        ...                                                 a4RetryTimerMultCa                        1
        scf.Add Item To List    dist_name=${dist_name}    list_name=${list_name}    elements=${list_elements}
    END


Update SNSSAIs In SCF
    FOR    ${snssai_id}     ${sd}       ${sst}       ${userLabel}       IN
    ...    1                1           1            eMBB
    ...    2                0           129          PNd
    ...    3                1           129          PNc
        Update SNSSAI In SCF    snssai_id=${snssai_id}    sd=${sd}    sst=${sst}    applicationType=singleSliceUE    userLabel=${userLabel}
    END
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actAdditionalSliceSupport   value=true
    Update SNSSAI-4 TO SNSSAI-28 In SCF


Update SNSSAI In SCF
    [Arguments]    ${snssai_id}    ${sd}    ${sst}    ${applicationType}    ${userLabel}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/SNSSAI-${snssai_id}
    FOR   ${p_name}                         ${value}      IN
    ...   sd                                ${sd}
    ...   sst                               ${sst}
    ...   applicationType                   ${applicationType}
    ...   drbInactivityTimerSA              10
    ...   drbRrcInactInactivityTimerSA      10
    ...   userLabel                         ${userLabel}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


Update SNSSAI-4 TO SNSSAI-28 In SCF
    FOR   ${slice_id}    IN RANGE    4    29
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/SNSSAI-${slice_id}    p_name=applicationType   value=disabled
    END


Define TRACKINGAREAs And Add SNSSAIs To Them
    FOR    ${trackingArea_id}    IN    1    2    7    10
        ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/TRACKINGAREA-${trackingArea_id}
        ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
        IF    ${mo_exist}
            RETURN
        END
        sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:TRACKINGAREA    dist_name=${dist_name}    version=${NIDD_VERSION}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=fiveGsTac    value=${trackingArea_id}
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=snssaiList

        IF    '${trackingArea_id}' == '1'
            FOR    ${snssai_id}    IN    1    2    3    5
                Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=${snssai_id}    list_name=snssaiList
            END
        ELSE IF    '${trackingArea_id}' == '2'
            FOR    ${snssai_id}    IN    1    2    3    4
                Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=${snssai_id}    list_name=snssaiList
            END
        ELSE IF    '${trackingArea_id}' == '7'
            FOR    ${snssai_id}    IN    1    2    5
                Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=${snssai_id}    list_name=snssaiList
            END
        ELSE IF    '${trackingArea_id}' == '10'
            FOR    ${snssai_id}    IN    1    2    3
                Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=${snssai_id}    list_name=snssaiList
            END
        END
    END


Add SNSSAI To TRACKINGAREA
    [Arguments]    ${dist_name}    ${snssai_id}    ${list_name}
    ${snssaiList_dict}=    Create Dictionary    snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-${snssai_id}
    scf.Add Item To List    dist_name=${dist_name}    list_name=${list_name}    elements=${snssaiList_dict}


Define TrackingAreaDNs Mapping In Cells
    FOR    ${cell_index}    IN    1    2    7    10
        Set TrackingAreaDN In Cell    cell_id=${cell_index}    trackingArea_id=${cell_index}
    END
    Set TrackingAreaDN In Cell    cell_id=4    trackingArea_id=2


Set TrackingAreaDN In Cell
    [Arguments]    ${cell_id}    ${trackingArea_id}
    sqd65_commissioning.Set Element
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRPLMNSET_SA-1
    ...   p_name=trackingAreaDN
    ...   value=MRBTS-1/NRBTS-1/TRACKINGAREA-${trackingArea_id}


Define Measurement Interval For NR CA Measurements
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPMRNL-1
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=miNrCaCu    value=5min


Define PM Measurement Interval
    ${dist_name}=    Set Variable      MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=reportingIntervalPm    value=5min


Apply Configuration For CB013859-A-B1
    Modifying TRACKINGAREAs And Add SNSSAIs To Them For CB013859-A-B1
    Define TrackingAreaDNs Mapping In Cells For CB013859-A-B1


Modifying TRACKINGAREAs And Add SNSSAIs To Them For CB013859-A-B1
    FOR    ${trackingArea_id}    IN    1    2
        ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/TRACKINGAREA-${trackingArea_id}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=fiveGsTac    value=${trackingArea_id}
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=snssaiList

        IF    '${trackingArea_id}' == '1'
            FOR    ${snssai_id}    IN    1    2
                Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=${snssai_id}    list_name=snssaiList
            END
        ELSE IF    '${trackingArea_id}' == '2'
                Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=1    list_name=snssaiList
        END
    END


Define TrackingAreaDNs Mapping In Cells For CB013859-A-B1
    FOR    ${cell_index}    IN    2    7    10    4
        Set TrackingAreaDN In Cell    cell_id=${cell_index}    trackingArea_id=2
    END
    Set TrackingAreaDN In Cell    cell_id=1    trackingArea_id=1


Add NRRESOURCEGROUP_PROFILE
    FOR    ${nrresgrp_profile_id}    IN    1    2
        ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-${nrresgrp_profile_id}
        sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:NRRESOURCEGROUP_PROFILE   dist_name=${dist_name}   version=${NIDD_VERSION}
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=defaultRgSaList
        ${list_elements}=         Create Dictionary         nrPlmnDN                      NRPLMN-1
        ...                                                 nrResourceGroupId             6
        scf.Add Item To List      dist_name=${dist_name}    list_name=defaultRgSaList     elements=${list_elements}
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=defaultRgNsaList
        ${list_elements}=         Create Dictionary         nrPlmnDN                      NRPLMN-1
        ...                                                 nrResourceGroupId             6
        scf.Add Item To List      dist_name=${dist_name}    list_name=defaultRgNsaList    elements=${list_elements}
        ${list_elements}=         Create Dictionary         nrPlmnDN                      NRPLMN-2
        ...                                                 nrResourceGroupId             6
        scf.Add Item To List      dist_name=${dist_name}    list_name=defaultRgNsaList    elements=${list_elements}
        Add NRRESOURCEGROUPs in NRRESOURCEGROUP_PROFILE    dist_name_initial=${dist_name}
    END


Add NRRESOURCEGROUPs in NRRESOURCEGROUP_PROFILE
    [Arguments]    ${dist_name_initial}
    FOR   ${nrresgrp_id}      ${resourceDN}      ${maxQuota}      ${minQuota}      IN
    ...   1                   SNSSAI-1           100              20
    ...   2                   SNSSAI-2           100              20
    ...   3                   SNSSAI-3           100              20
    ...   4                   SNSSAI-4           100              20
    ...   5                   SNSSAI-5           100              15
    ...   6                   NRPLMN-1           100              5
        ${dist_name}=    Set Variable    ${dist_name_initial}/NRRESOURCEGROUP-${nrresgrp_id}
        sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:NRRESOURCEGROUP   dist_name=${dist_name}   version=${NIDD_VERSION}
        sqd65_commissioning.Set Element     dist_name=${dist_name}    p_name=allowRegularSrAboveMaxQuota    value=false
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=nrResourceList
        ${list_elements}=         Create Dictionary         resourceDN                    ${resourceDN}
        scf.Add Item To List      dist_name=${dist_name}    list_name=nrResourceList      elements=${list_elements}
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=schedulerParams
        ${list_elements}=         Create Dictionary         maxQuota                      ${maxQuota}
        ...                                                 minQuota                      ${minQuota}
        scf.Add Item To List      dist_name=${dist_name}    list_name=schedulerParams     elements=${list_elements}
    END


Define NrResourceGroupProfileDNs Mapping In Cells
    Set NrResourceGroupProfileDN In Cell    cell_id=1    nrresgrp_profile_id=1
    FOR    ${cell_index}    IN    2    7    10    4
        Set NrResourceGroupProfileDN In Cell    cell_id=${cell_index}    nrresgrp_profile_id=2
    END


Set NrResourceGroupProfileDN In Cell
    [Arguments]    ${cell_id}    ${nrresgrp_profile_id}
    sqd65_commissioning.Set Element
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...   p_name=nrResourceGroupProfileDN
    ...   value=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-${nrresgrp_profile_id}


Update Application Type Of SNSSAI
    [Arguments]    ${snssai_id}    ${applicationType}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/SNSSAI-${snssai_id}
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=applicationType    value=${applicationType}


Apply Configs For A_B3
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3    p_name=sCellOperationalMode    value=dlAndUl
    sqd65_keywords.Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf


Apply Configs For A_B6
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3    p_name=sCellOperationalMode    value=dlAndUl
    Update Application Type Of SNSSAI    snssai_id=3    applicationType=disabled
    sqd65_keywords.Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf


Apply Configs For B_IWK7
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1
    FOR    ${p_name}                                    ${value}            IN
    ...    actBufferBasedSCellAddition                  oneShot_Dl_Fr1
    ...    actMeasBasedSCellAdditionNsa                 false
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=actMeasBasedSCellAdditionSa
    ${actMeasBasedSCellAdditionSa_list}=  Create List               A1-based
    ...                                                             A4-based
    scf.add_elements_to_list    dist_name=${dist_name}   list_name=actMeasBasedSCellAdditionSa   elements=${actMeasBasedSCellAdditionSa_list}
    FOR    ${dist_name}                             IN
    ...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    ...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-5
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=sCellAdditionMethod    value=covBasedA4
    END
    sqd65_keywords.Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf


Apply Delta Config for B_IWK9
    [Arguments]    ${test_instance}   ${action}=${EMPTY}
    ${scf_file}=       Load current SCF
    IF          '${action}' == '_Slice-1_applicationType_enabled'
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3    p_name=sCellOperationalMode    value=dlAndUl
        Update Application Type Of SNSSAI    snssai_id=3    applicationType=disabled
    ELSE IF     '${action}' == '_Slice-1_applicationType_disabled'
        Update Application Type Of SNSSAI    snssai_id=1    applicationType=disabled
    END
    sqd65_keywords.Apply Delta SCF    ${scf_file}  ${test_instance}_modified_scf${action}


Apply Configs For D_IWK1
    [Arguments]         ${test_instance}
    ${scf_file}=        Load Current SCF
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3    p_name=sCellOperationalMode    value=dlAndUl
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actSliceSwitchToDefault    value=true
    Define TRACKINGAREAs For CB013859-D And Add SNSSAIs To Them
    sqd65_keywords.Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf


Define TRACKINGAREAs For CB013859-D And Add SNSSAIs To Them
    &{trackingAreaDict}    Evaluate    {2: ['2', '3', '4'], 10: ['2', '3']}
    FOR    ${trackingArea_id}    ${snssaiList}    IN    &{trackingAreaDict}
        ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/TRACKINGAREA-${trackingArea_id}
        sqd65_commissioning.Set Object    class_name=com.nokia.srbts.nrbts:TRACKINGAREA    dist_name=${dist_name}    version=${NIDD_VERSION}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=fiveGsTac    value=${trackingArea_id}
        sqd65_commissioning.Set New List    dist_name=${dist_name}    list_name=snssaiList
        FOR    ${snssai_id}    IN    @{snssaiList}
            Add SNSSAI To TRACKINGAREA    dist_name=${dist_name}    snssai_id=${snssai_id}    list_name=snssaiList
        END
    END

