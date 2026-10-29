*** Settings ***

Documentation
...    author: VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: Commissioning for CB013142-AA,-BA, -A and -B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource                    CB013142_Keywords.robot
Resource                    ../resources/SQD65/sqd65_commissioning.robot

*** Variables ***
${TEST_MODE}                    auto

${CARRIER_FREQ_1}               518910
${CARRIER_FREQ_2}               531870
${CARRIER_FREQ_3}               655968
${CARRIER_FREQ_4}               127450
${CARRIER_FREQ_5}               431090
${CARRIER_FREQ_6}               392410

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
@{INDEXES_SA_PROFILES}                                 0                  1                  2                  3                  4            5
@{NRMEASPR_MA_SA_IDs}                                 67                  4                  9                 78                 99           11

@{NRCELL_4_NRMEASPR_MA_SA_Priorities}                  3                  1                  2                  4                  5           99
@{NRCELL_1_NRMEASPR_MA_SA_Priorities}                 22                 56                 11                 37                  1           99
@{NRCELL_5_NRMEASPR_MA_SA_Priorities}                 99                 98                 97                 96                 95            1

@{NRMEASPR_MA_SA_Rfsp_start}                    ${EMPTY}                 12           ${EMPTY}           ${EMPTY}           ${EMPTY}           30
@{NRMEASPR_MA_SA_Rfsp_end}                      ${EMPTY}                 28           ${EMPTY}           ${EMPTY}           ${EMPTY}           40
@{NRMEASPR_MA_SA_plmn}                                 2           ${EMPTY}           ${EMPTY}           ${EMPTY}           ${EMPTY}     ${EMPTY}
@{NRMEASPR_MA_SA_five_qi}                       ${EMPTY}           ${EMPTY}           ${EMPTY}                  1           ${EMPTY}     ${EMPTY}
@{NRMEASPR_MA_SA_snssai}                        ${EMPTY}           ${EMPTY}                  2           ${EMPTY}           ${EMPTY}     ${EMPTY}
@{NRMEASPR_MA_SA_nrCaClass}                     ${EMPTY}           ${EMPTY}           ${EMPTY}           ${EMPTY}                 32     ${EMPTY}

@{IAF_IDs}                                            43                 20                 19                 89                 76           11
@{IAF_a2MeasPCellSwitchSsbRsrp_a2Hysteresis}           2                 10                  6                  8                  4            4
@{IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold}           52                 60                 56                 58                 54           54
@{IAF_a2MeasPCellSwitchSsbRsrp_a2TimeToTrigger}      320               1024                512                640                480          480
@{IAF_a2MeasPCellSwitchSsbRsrp_pCellSwitchOffset}      0                  0                  0                  0                  0            0

@{NRMEASPR_SCELL_DN}                                  12                 67                  1                  2                 29           11
@{NRMEASPR_SCELL_ssbFrequency}         ${CARRIER_FREQ_2}  ${CARRIER_FREQ_1}  ${CARRIER_FREQ_1}  ${CARRIER_FREQ_2}  ${CARRIER_FREQ_1}       392410

@{NRMEASPR_SCELL_default_DN}                          29                  1                 67                 12                  2           11
@{SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis}         8                 10                  4                  6                 14           14
@{SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold}         58                 60                 54                 56                 64           64
@{SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger}    480                512                256                320               1024         1024
@{SCELL_a1MeasPCellSwitchSsbRsrp_pCellSwitchOffset}    0                  0                  0                  0                  0            0
@{SCELL_a2MeasSCellRelSsbRsrq_a2Hysteresis}            8                 10                  4                  6                 14
@{SCELL_a2MeasSCellRelSsbRsrq_a2Threshold}            58                 60                 54                 56                 64
@{SCELL_a2MeasSCellRelSsbRsrq_a2TimeToTrigger}       480                512                256                320               1024

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
@{INDEXES_NSA_PROFILES}                                0                  1                  2
@{NRMEASPR_MA_NSA_IDs}                                 3                 10                 12

@{NRCELL_1_NRMEASPR_MA_NSA_Priorities}                 1                  2                  3
@{NRCELL_4_NRMEASPR_MA_NSA_Priorities}                 3                  1                  2

@{NRMEASPR_MA_NSA_plmn}                                2           ${EMPTY}                  1
@{NRMEASPR_MA_NSA_spid_start}                   ${EMPTY}                 10           ${EMPTY}
@{NRMEASPR_MA_NSA_spid_end}                     ${EMPTY}                 18           ${EMPTY}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
${SCELL_1_a1_hyst}                0
${SCELL_1_a1_thresh}              50
${SCELL_1_a1_time}                128
${SCELL_2_a1_hyst}                2
${SCELL_2_a1_thresh}              52
${SCELL_2_a1_time}                160

*** Keywords ***

Common Commissioning For All Sub-Features
    [Documentation]  Common commissioning based on sub-features AA and BA.
    ...    Primary cell planned for Sub-feature AA is Cell-1 (NR Freq Band 41) and configured with A1 measurement SCell addition for 2CC DL/UL CA
    ...    with Cell-4 as SCell.
    ...    Primary cell planned for Sub-feature BA is Cell-4 (NR Freq Band 71) and configured with A1 measurement SCell addition for 3CC DL CA with
    ...    Cell-1 and Cell-2 (both Cells are NR Freq Band 41) SCells and 2CC UL CA with Cell-1 (NR Freq Band 41) as SCell.
    ${config_dir}=      Get Test Suite Config Directory
    scf.Load Scf        ${P_ORIG_SCF}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actCAMeasInMeasProf                     SA+NSA             #CB013142 Feature Flag
    ...   MRBTS-1/NRBTS-1                                   actMeasurementProfile                   SA+NSA             #CB008127 Feature Flag
    ...   MRBTS-1/NRBTS-1                                   actMeasurementProfReselForCA            deactivated        #CB013392 Feature Flag
    ...   MRBTS-1/NRBTS-1                                   actMeasProfileCa                        SA                 #CB011074 Feature Flag
    ...   MRBTS-1/NRBTS-1                                   actInterFreqHoSA                        true
    ...   MRBTS-1/NRBTS-1                                   actInterFreqIntraGnbMobilityNSA         true
    ...   MRBTS-1/NRBTS-1                                   actRfspIndex                            true
    ...   MRBTS-1/NRBTS-1                                   actSPID                                 true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          measGapSelectionSA                      favourUeThroughput
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          measGapSelectionSA                      favourUeThroughput
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          maxNumOfSCellAlloc                      0
    ...   MRBTS-1/NRBTS-1/NRCELL-3                          maxNumOfSCellAlloc                      0
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          maxNumOfSCellAlloc                      0
    ...   MRBTS-1/NRBTS-1/NRCELL-6                          maxNumOfSCellAlloc                      0
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrMeasProfileIntraFreq                5min
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrMeasProfileMappingNSA               5min
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrMeasProfileMappingSA                5min
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrMeasProfileSCell                    5min
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrMeasProfileInterFreq                5min
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    Apply Configuration For A1 Measurement Based SCell Addition For SA And NSA   cell_id=1  a1MeasSCellAddEnabled=rsrp
    Apply Configuration For A2 Measurement Based PCell Switch At NRCell   cell_id=1  a2_meas_quantity=rsrp
    Apply Additional Configuration For Measurement Profile CB008127
    Add NRHOIF MOC To NRCELL   id=32  a2_pcell_switch_prio=7
    Apply Configuration For Multi Plmn And Slicing
    Apply Configuration For A1 Measurement Based PCell Switch   cell_id=4  a1MeasSCellAddEnabled=rsrp  scell_1=1  scell_2=2
    IF    'CB013142-F' in '${SUITE NAME}'
        Add NRMEASPR IEF To NRMEAS PROFILE-1
    ELSE IF  'CB013142-E' in '${SUITE NAME}'
        Set PM Interval For E Subfeature      pm_reporting_interval=${KPI_PM_INTERVAL}
    END
    scf.Save Scf                    ${config_dir}/CB013142_SCF.xml
    Execute Full Commissioning      ${config_dir}/CB013142_SCF.xml


Apply Configuration For A1 Measurement Based SCell Addition For SA And NSA
    [Arguments]    ${cell_id}   ${a1MeasSCellAddEnabled}   ${rel_id_max}=5
    sqd65_commissioning.Set New List                dist_name=MRBTS-1/NRBTS-1      list_name=actMeasBasedSCellAdditionSa
    ${meas_based_scell}=        Create List                    A1-based
    scf.Add Elements To List    dist_name=MRBTS-1/NRBTS-1      list_name=actMeasBasedSCellAdditionSa       elements=${meas_based_scell}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1                       actMeasBasedSCellAdditionNsa    true
    ...   MRBTS-1/NRBTS-1/NRCELL-${cell_id}     a1MeasSCellAddEnabled           ${a1MeasSCellAddEnabled}
          sqd65_commissioning.Set Element       dist_name=${dist_name}          p_name=${p_name}       value=${value}
    END
    Apply Configuration For A1 Measurement Based SCell Addition At NRCell
    ...    cell_id=${cell_id}  a1MeasSCellAddEnabled=${a1MeasSCellAddEnabled}  rel_id_max=${rel_id_max}


Apply Configuration For A1 Measurement Based SCell Addition At NRCell
    [Arguments]    ${cell_id}   ${a1MeasSCellAddEnabled}   ${rel_id_max}
    IF    '${a1MeasSCellAddEnabled}' != 'rsrp'    Configure A1 Measurement Parameters For RSRQ for SCell Addition
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  a1_hyst=0  a1_thresh_fdd=50  a1_thresh_tdd=50  a1_time=320ms
    IF    '${a1MeasSCellAddEnabled}' != 'rsrq'    Configure A1 Measurement Parameters For RSRP for SCell Addition
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  a1_hyst=0  a1_thresh_fdd=50  a1_thresh_tdd=50  a1_time=320ms

    FOR    ${rel_id}    IN RANGE    1    ${${rel_id_max}+1}
        ${dist_name}=    Set Variable      MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRREL-${rel_id}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=sCellAdditionMethod    value=covBasedA1
    END


Configure A1 Measurement Parameters For RSRP For SCell Addition
    [Arguments]    ${dist_name}   ${a1_hyst}   ${a1_thresh_fdd}   ${a1_thresh_tdd}   ${a1_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp
    ${list_elements}=       Create Dictionary                    a1HysteresisSCellAddSsbRsrp             ${a1_hyst}
    ...                                                          a1ThresholdSCellAddSsbRsrpFDD           ${a1_thresh_fdd}
    ...                                                          a1ThresholdSCellAddSsbRsrpTDD           ${a1_thresh_tdd}
    ...                                                          a1TimeToTriggerSCellAddSsbRsrp          ${a1_time}
    scf.Add Item To List    dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp         elements=${list_elements}


Configure A1 Measurement Parameters For RSRQ For SCell Addition
    [Arguments]    ${dist_name}   ${a1_hyst}   ${a1_thresh_fdd}   ${a1_thresh_tdd}   ${a1_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrq
    ${list_elements}=       Create Dictionary                    a1HysteresisSCellAddSsbRsrq             ${a1_hyst}
    ...                                                          a1ThresholdSCellAddSsbRsrqFDD           ${a1_thresh_fdd}
    ...                                                          a1ThresholdSCellAddSsbRsrqTDD           ${a1_thresh_tdd}
    ...                                                          a1TimeToTriggerSCellAddSsbRsrq          ${a1_time}
    scf.Add Item To List    dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrq         elements=${list_elements}


Apply Configuration For A2 Measurement Based PCell Switch At NRCell
    [Arguments]    ${cell_id}   ${a2_meas_quantity}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-${cell_id}     a2MeasPCellSwitchEnabled        ${a2_meas_quantity}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    IF    '${a2_meas_quantity}' != 'rsrp'    Configure A2 Measurement Parameters For RSRQ For PCell Switch
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  a2_hyst=4  a2_thresh=62  a2_time=160ms
    IF    '${a2_meas_quantity}' != 'rsrq'    Configure A2 Measurement Parameters For RSRP For PCell Switch
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  a2_hyst=4  a2_thresh=62  a2_time=160ms


Configure A2 Measurement Parameters For RSRP For PCell Switch
    [Arguments]    ${dist_name}   ${a2_hyst}   ${a2_thresh}   ${a2_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a2MeasPCellSwitchSsbRsrp
    ${list_elements}=       Create Dictionary                    a2HysteresisPCellSwitchSsbRsrp              ${a2_hyst}
    ...                                                          a2ThresholdPCellSwitchSsbRsrp               ${a2_thresh}
    ...                                                          a2TimeToTriggerPCellSwitchSsbRsrp           ${a2_time}
    ...                                                          pCellSwitchOffsetSsbRsrp                    0
    scf.Add Item To List    dist_name=${dist_name}               list_name=a2MeasPCellSwitchSsbRsrp          elements=${list_elements}


Configure A2 Measurement Parameters For RSRQ For PCell Switch
    [Arguments]    ${dist_name}   ${a2_hyst}   ${a2_thresh}   ${a2_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a2MeasPCellSwitchSsbRsrq
    ${list_elements}=       Create Dictionary                    a2HysteresisPCellSwitchSsbRsrq              ${a2_hyst}
    ...                                                          a2ThresholdPCellSwitchSsbRsrq               ${a2_thresh}
    ...                                                          a2TimeToTriggerPCellSwitchSsbRsrq           ${a2_time}
    ...                                                          pCellSwitchOffsetSsbRsrq                    0
    scf.Add Item To List    dist_name=${dist_name}               list_name=a2MeasPCellSwitchSsbRsrq          elements=${list_elements}


Apply Additional Configuration For Measurement Profile CB008127
    ${dist_name_NRCELL-1}=                   Set Variable                  MRBTS-1/NRBTS-1/NRCELL-1
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRCELL-1}        list_name=measPrMaSAList
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRCELL-1}        list_name=measPrMaNSAList

    ${dist_name_NRCELL-4}=                   Set Variable                  MRBTS-1/NRBTS-1/NRCELL-4
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRCELL-4}        list_name=measPrMaSAList
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRCELL-4}        list_name=measPrMaNSAList

    FOR    ${index}    IN    @{INDEXES_SA_PROFILES}
        ${measPrMaSAList_dict}    Create Dictionary
        ...    measPrPriority    ${NRCELL_1_NRMEASPR_MA_SA_Priorities[${index}]}
        ...    nrMeasPrMaSADN    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_IDs[${index}]}
        scf.Add Item To List            dist_name=${dist_name_NRCELL-1}        list_name=measPrMaSAList       elements=${measPrMaSAList_dict}

        ${measPrMaSAList_dict}    Create Dictionary
        ...    measPrPriority    ${NRCELL_4_NRMEASPR_MA_SA_Priorities[${index}]}
        ...    nrMeasPrMaSADN    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_IDs[${index}]}
        scf.Add Item To List            dist_name=${dist_name_NRCELL-4}        list_name=measPrMaSAList       elements=${measPrMaSAList_dict}
    END
    FOR    ${index}    IN    @{INDEXES_NSA_PROFILES}
        ${measPrMaNSAList_dict}    Create Dictionary
        ...    measPrPriority    ${NRCELL_1_NRMEASPR_MA_NSA_Priorities[${index}]}
        ...    nrMeasPrMaNSADN    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${NRMEASPR_MA_NSA_IDs[${index}]}
        scf.Add Item To List            dist_name=${dist_name_NRCELL-1}        list_name=measPrMaNSAList       elements=${measPrMaNSAList_dict}

        ${measPrMaNSAList_dict}    Create Dictionary
        ...    measPrPriority    ${NRCELL_4_NRMEASPR_MA_NSA_Priorities[${index}]}
        ...    nrMeasPrMaNSADN    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${NRMEASPR_MA_NSA_IDs[${index}]}
        scf.Add Item To List            dist_name=${dist_name_NRCELL-4}        list_name=measPrMaNSAList       elements=${measPrMaNSAList_dict}
    END
    Add NRMEAS PROFILE To NRBTS-1  id=1


Add NRMEAS PROFILE To NRBTS-1
    [Arguments]    ${id}
    Add NRCACLASS To NRMEAS PROFILE-1  id=32  caBand_1=41  caBand_2=71  caBand_3=66  pcell_band_1=41  excluded_band=77

    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-${id}
    Set Object    class_name=NRMEAS_PROFILE    dist_name=${dist_name}   version=${NIDD_VERSION}

    FOR    ${index}    IN    @{INDEXES_SA_PROFILES}
        Add NRMEASPR MA SA To NRMEAS PROFILE-1
        ...    id=${NRMEASPR_MA_SA_IDs[${index}]}
        ...    rfsp=${NRMEASPR_MA_SA_Rfsp_start[${index}]}
        ...    rfsp_last=${NRMEASPR_MA_SA_Rfsp_end[${index}]}
        ...    plmn=${NRMEASPR_MA_SA_plmn[${index}]}
        ...    five_qi=${NRMEASPR_MA_SA_five_qi[${index}]}
        ...    snssai=${NRMEASPR_MA_SA_snssai[${index}]}
        ...    nrCaClass=${NRMEASPR_MA_SA_nrCaClass[${index}]}
        ...    iaf_dn=${IAF_IDs[${index}]}
        ...    scell_default_dn=${NRMEASPR_SCELL_default_DN[${index}]}
        ...    scell_dn=${NRMEASPR_SCELL_DN[${index}]}
        ...    ssbFreq=${NRMEASPR_SCELL_ssbFrequency[${index}]}

        Add NRMEASPR IAF To NRMEAS PROFILE-1
        ...    id=${IAF_IDs[${index}]}
        ...    a2_hyst_rsrp=${IAF_a2MeasPCellSwitchSsbRsrp_a2Hysteresis[${index}]}
        ...    a2_thresh_rsrp=${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}
        ...    a2_time_rsrp=${IAF_a2MeasPCellSwitchSsbRsrp_a2TimeToTrigger[${index}]}ms
        ...    a2_hyst_rsrq=${IAF_a2MeasPCellSwitchSsbRsrp_a2Hysteresis[${index}]}
        ...    a2_thresh_rsrq=${IAF_a2MeasPCellSwitchSsbRsrp_a2Threshold[${index}]}
        ...    a2_time_rsrq=${IAF_a2MeasPCellSwitchSsbRsrp_a2TimeToTrigger[${index}]}ms
    END
    FOR    ${index}    IN    @{INDEXES_NSA_PROFILES}
        Add NRMEASPR MA NSA To NRMEAS PROFILE-1
        ...    id=${NRMEASPR_MA_NSA_IDs[${index}]}
        ...    spid=${NRMEASPR_MA_NSA_spid_start[${index}]}
        ...    spid_last=${NRMEASPR_MA_NSA_spid_end[${index}]}
        ...    plmn=${NRMEASPR_MA_NSA_plmn[${index}]}
        ...    iaf_dn=${IAF_IDs[${index}]}
        ...    scell_default_dn=${NRMEASPR_SCELL_default_DN[${index}]}
        ...    scell_dn=${NRMEASPR_SCELL_DN[${index}]}
        ...    ssbFreq=${NRMEASPR_SCELL_ssbFrequency[${index}]}
    END


Add NRMEASPR MA SA To NRMEAS PROFILE-1
    [Arguments]   ${id}   ${iaf_dn}   ${scell_dn}   ${scell_default_dn}   ${ssbFreq}   ${snssai}=${EMPTY}   ${rfsp}=${EMPTY}   ${rfsp_last}=${EMPTY}
    ...           ${plmn}=${EMPTY}   ${five_qi}=${EMPTY}   ${nrCaClass}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    Set Object    class_name=NRMEASPR_MA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                            ${value}      IN
    ...   nrMeasPrIafDN                        MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-${iaf_dn}
    ...   nrMeasPrSCellDefaultDN               MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${scell_default_dn}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF  '${rfsp}' != '${EMPTY}'    sqd65_commissioning.Set Element  dist_name=${dist_name}  p_name=rfspIndex  value=${rfsp}
    IF  '${rfsp_last}' != '${EMPTY}'    sqd65_commissioning.Set Element  dist_name=${dist_name}  p_name=rfspIndexLast  value=${rfsp_last}
    IF  '${plmn}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
        ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-${plmn}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=nrPlmnDNList        elements=${nrPlmnDNList_list}
    END
    IF  '${snssai}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=snssaiList
        ${snssaiList_dict}              Create Dictionary           snssaiDN                      MRBTS-1/NRBTS-1/SNSSAI-${snssai}
        scf.Add Item To List            dist_name=${dist_name}      list_name=snssaiList          elements=${snssaiList_dict}
    END
    IF  '${five_qi}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=fiveqiValueList
        ${five_qi_list}=                Create List                 ${five_qi}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=fiveqiValueList     elements=${five_qi_list}
    END
    IF  '${nrCaClass}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrCaClassDNList
        ${nrCaClassDN_list}=            Create List                 NRCACLASS-${nrCaClass}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=nrCaClassDNList     elements=${nrCaClassDN_list}
    END
    sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrMeasPrSCellList
    ${MeasPrSCellList_dict}         Create Dictionary           nrMeasPrSCellDN                   NRMEASPR_SCELL-${scell_dn}
    ...                                                         ssbFrequency01                    ${ssbFreq}
    scf.Add Item To List            dist_name=${dist_name}      list_name=nrMeasPrSCellList       elements=${MeasPrSCellList_dict}


Add NRMEASPR MA NSA To NRMEAS PROFILE-1
    [Arguments]   ${id}   ${iaf_dn}   ${scell_dn}   ${scell_default_dn}   ${ssbFreq}   ${spid}=${EMPTY}   ${spid_last}=${EMPTY}    ${plmn}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${id}
    Set Object    class_name=NRMEASPR_MA_NSA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                            ${value}      IN
    ...   nrMeasPrIafDN                        MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-${iaf_dn}
    ...   nrMeasPrSCellDefaultDN               MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${scell_default_dn}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF  '${spid}' != '${EMPTY}'    sqd65_commissioning.Set Element  dist_name=${dist_name}  p_name=spid  value=${spid}
    IF  '${spid_last}' != '${EMPTY}'    sqd65_commissioning.Set Element  dist_name=${dist_name}  p_name=spidLast  value=${spid_last}
    IF  '${plmn}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
        ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-${plmn}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=nrPlmnDNList        elements=${nrPlmnDNList_list}
    END
    sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrMeasPrSCellList
    ${MeasPrSCellList_dict}         Create Dictionary           nrMeasPrSCellDN                   NRMEASPR_SCELL-${scell_dn}
    ...                                                         ssbFrequency01                    ${ssbFreq}
    scf.Add Item To List            dist_name=${dist_name}      list_name=nrMeasPrSCellList       elements=${MeasPrSCellList_dict}


Add NRCACLASS To NRMEAS PROFILE-1
    [Arguments]    ${id}   ${caBand_1}   ${pcell_band_1}   ${pcell_band_2}=${EMPTY}   ${caBand_2}=${EMPTY}   ${caBand_3}=${EMPTY}
    ...            ${excluded_band}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRCACLASS-${id}
    Set Object    class_name=NRCACLASS    dist_name=${dist_name}   version=${NIDD_VERSION}
    sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=caBandList
    ${caBands_list}=                Create List                 ${caBand_1}
    scf.Add Elements To List        dist_name=${dist_name}      list_name=caBandList        elements=${caBands_list}
    IF    '${caBand_2}' != '${EMPTY}'
        ${caBands_list}=                Create List                 ${caBand_2}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=caBandList        elements=${caBands_list}
    END
    IF    '${caBand_3}' != '${EMPTY}'
        ${caBands_list}=                Create List                 ${caBand_3}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=caBandList        elements=${caBands_list}
    END
    sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=pCellBandList
    ${pCellBand}=                   Create List                 ${pcell_band_1}
    scf.Add Elements To List        dist_name=${dist_name}      list_name=pCellBandList        elements=${pCellBand}
    IF    '${excluded_band}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=excludedBandList
        ${pCellBand}=                   Create List                 ${excluded_band}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=excludedBandList        elements=${pCellBand}
    END
    IF    '${pcell_band_2}' != '${EMPTY}'
        sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=pCellBandList2
        ${pCellBand}=                   Create List                 ${pcell_band_2}
        scf.Add Elements To List        dist_name=${dist_name}      list_name=pCellBandList2        elements=${pCellBand}
    END


Add NRMEASPR IAF To NRMEAS PROFILE-1
    [Arguments]    ${id}   ${a2_hyst_rsrp}   ${a2_thresh_rsrp}   ${a2_time_rsrp}   ${a2_hyst_rsrq}   ${a2_thresh_rsrq}   ${a2_time_rsrq}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}
    Set Object    class_name=NRMEASPR_IAF    dist_name=${dist_name}   version=${NIDD_VERSION}
    IF    '${a2_thresh_rsrp}' != '${EMPTY}'    Configure A2 Measurement Parameters For RSRP For PCell Switch   dist_name=${dist_name}
    ...   a2_hyst=${a2_hyst_rsrp}  a2_thresh=${a2_thresh_rsrp}  a2_time=${a2_time_rsrp}
    IF    '${a2_thresh_rsrq}' != '${EMPTY}'    Configure A2 Measurement Parameters For RSRQ For PCell Switch   dist_name=${dist_name}
    ...   a2_hyst=${a2_hyst_rsrq}  a2_thresh=${a2_thresh_rsrq}  a2_time=${a2_time_rsrq}


Apply Configuration For Multi Plmn And Slicing
    Add New Radio PLMN To NRBTS  id=2
    FOR    ${cell_id}    IN    1    2    4
        Add New Radio PLMN To NRPLMNSET Under NRCell    cell_id=${cell_id}    plmnset_id=1
    END
    Add Tracking Area To NRBTS  id=400
    ${nrPlmnDNList_list}=       Create List         MRBTS-1/NRBTS-1/NRPLMN-2
    FOR  ${slice_id}   IN RANGE  1  3
        scf.Add Elements To List    dist_name=MRBTS-1/NRBTS-1/SNSSAI-${slice_id}      list_name=nrPlmnDNList      elements=${nrPlmnDNList_list}
    END


Add New Radio PLMN To NRBTS
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPLMN-${id}
    Set Object    class_name=NRPLMN    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}             ${value}      IN
    ...   mcc                   311
    ...   mnc                   488
    ...   mncLength             3
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END


Add New Radio PLMN To NRPLMNSET Under NRCell
    [Arguments]       ${cell_id}   ${plmnset_id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRPLMNSET_SA-${plmnset_id}
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-2
    scf.Add Elements To List        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=trackingAreaDN    value=MRBTS-1/NRBTS-1/TRACKINGAREA-400

    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRPLMNSET_NSA-${plmnset_id}
    scf.Add Elements To List        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}


Add Tracking Area To NRBTS
    [Arguments]       ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/TRACKINGAREA-${id}
    Set Object    class_name=TRACKINGAREA    dist_name=${dist_name}   version=${NIDD_VERSION}
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=fiveGsTac    value=${id}
    sqd65_commissioning.Set New List                    dist_name=${dist_name}          list_name=snssaiList
    FOR  ${slice_id}   IN RANGE  1  3
        ${snssaiList_dict}              Create Dictionary               snssaiDN                    MRBTS-1/NRBTS-1/SNSSAI-${slice_id}
        scf.Add Item To List            dist_name=${dist_name}          list_name=snssaiList        elements=${snssaiList_dict}
    END


Add NRHOIF MOC To NRCELL
    [Arguments]    ${id}   ${a2_pcell_switch}=true   ${a1_pcell_switch}=false   ${freq_band}=71   ${ssb_Scs}=15KHz   ${scs}=15 KHz
    ...            ${ssb_freq}=127450   ${cell_id}=1  ${a2_pcell_switch_prio}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRHOIF-${id}
    Set Object    class_name=NRHOIF    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                            ${value}      IN
    ...   a1BasedPCellSwitchEnabled            ${a1_pcell_switch}
    ...   a2BasedPCellSwitchEnabled            ${a2_pcell_switch}
    ...   a3MeasEnabled                        none
    ...   a4MeasEnDcSteeringEnabled            none
    ...   a4MeasHigherPrioFreqEnabled          none
    ...   a4MeasNrDcEnabled                    none
    ...   a4MeasSCellAddEnabled                none
    ...   a5MeasEnabled                        none
    ...   cellDepType                          SA+NSA
    ...   deriveSsbIndexFromCell               true
    ...   freqBandIndicatorNR                  ${freq_band}
    ...   ifhoSsbScs                           ${ssb_Scs}
    ...   ifhoSsbSmtcDuration                  sf1
    ...   ifhoSsbSmtcPeriodicity               sf20
    ...   numberOfTransmittedSsBlocks          1 beam
    ...   scs                                  ${scs}
    ...   ssBurstSetPeriod                     20
    ...   ssbFrequency                         ${ssb_freq}
    ...   thresholdPCellSwitchTargetRsrp       40
    ...   thresholdPCellSwitchTargetRsrq       40
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF  '${a2_pcell_switch_prio}' != '${EMPTY}'    sqd65_commissioning.Set Element  dist_name=${dist_name}  p_name=a2BasedPCellSwitchPriority
    ...    value=${a2_pcell_switch_prio}


Apply Configuration For A1 Measurement Based PCell Switch
    [Documentation]    Here we also add A3 meas event to align the measurement IDs at UEs when it registers to Cell-1 and Cell-4
    [Arguments]    ${cell_id}   ${a1MeasSCellAddEnabled}   ${scell_1}   ${scell_2}=${EMPTY}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-${cell_id}     a1MeasSCellAddEnabled           ${a1MeasSCellAddEnabled}
    ...   MRBTS-1/NRBTS-1/NRCELL-${cell_id}     a3MeasEnabled                   rsrp
          sqd65_commissioning.Set Element       dist_name=${dist_name}          p_name=${p_name}       value=${value}
    END
    IF    'CB013142-B' in '${SUITE NAME}'
        sqd65_commissioning.Set Element       dist_name=MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1    p_name=sCellOperationalMode    value=dlAndUl
        sqd65_commissioning.Set Element       dist_name=MRBTS-1/NRBTS-1/NRCELL-2            p_name=maxNumOfSCellAlloc      value=250
    END
    Add NRHOIF MOC To NRCELL   id=3  a2_pcell_switch=false  a1_pcell_switch=true  freq_band=41  ssb_Scs=30 KHz  scs=30 KHz
    ...    ssb_freq=${CARRIER_FREQ_1}    cell_id=${cell_id}
    Add NRHOIF MOC To NRCELL   id=7  a2_pcell_switch=false  a1_pcell_switch=true  freq_band=41  ssb_Scs=30 KHz  scs=30 KHz
    ...    ssb_freq=${CARRIER_FREQ_2}    cell_id=${cell_id}
    Apply Configuration For A1 Measurement Based SCell Addition At NRCell
    ...    cell_id=${cell_id}  a1MeasSCellAddEnabled=${a1MeasSCellAddEnabled}  rel_id_max=4
    Apply Configuration For A1 Measurement Based PCell Switch At NRCell
    ...    cell_id=${scell_1}  a1_meas_quantity=rsrp  a1_hyst=${SCELL_1_a1_hyst}  a1_thresh=${SCELL_1_a1_thresh}  a1_time=${SCELL_1_a1_time}ms
    IF    '${scell_2}' != '${EMPTY}'    Apply Configuration For A1 Measurement Based PCell Switch at NRCell
    ...    cell_id=${scell_2}  a1_meas_quantity=rsrpCombined  a1_hyst=${SCELL_2_a1_hyst}    a1_thresh=${SCELL_2_a1_thresh}
    ...    a1_time=${SCELL_2_a1_time}ms
    Add Multiple NRMEASPR SCELL MOCs To NRMEAS PROFILE


Apply Configuration For A1 Measurement Based PCell Switch At NRCell
    [Arguments]    ${cell_id}   ${a1_meas_quantity}   ${a1_hyst}   ${a1_thresh}   ${a1_time}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-${cell_id}     a1MeasPCellSwitchEnabled        ${a1_meas_quantity}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    IF    '${a1_meas_quantity}' != 'rsrp'    Configure A1 Measurement Parameters For RSRQ For PCell Switch
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  a1_hyst=${a1_hyst}  a1_thresh=${a1_thresh}  a1_time=${a1_time}
    IF    '${a1_meas_quantity}' != 'rsrq'    Configure A1 Measurement Parameters For RSRP For PCell Switch
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}  a1_hyst=${a1_hyst}  a1_thresh=${a1_thresh}  a1_time=${a1_time}


Configure A1 Measurement Parameters For RSRP For PCell Switch
    [Arguments]    ${dist_name}   ${a1_hyst}   ${a1_thresh}   ${a1_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a1MeasPCellSwitchSsbRsrp
    ${list_elements}=       Create Dictionary                    a1HysteresisPCellSwitchSsbRsrp              ${a1_hyst}
    ...                                                          a1ThresholdPCellSwitchSsbRsrp               ${a1_thresh}
    ...                                                          a1TimeToTriggerPCellSwitchSsbRsrp           ${a1_time}
    scf.Add Item To List    dist_name=${dist_name}               list_name=a1MeasPCellSwitchSsbRsrp          elements=${list_elements}


Configure A1 Measurement Parameters For RSRQ For PCell Switch
    [Arguments]    ${dist_name}   ${a1_hyst}   ${a1_thresh}   ${a1_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a1MeasPCellSwitchSsbRsrq
    ${list_elements}=       Create Dictionary                    a1HysteresisPCellSwitchSsbRsrq              ${a1_hyst}
    ...                                                          a1ThresholdPCellSwitchSsbRsrq               ${a1_thresh}
    ...                                                          a1TimeToTriggerPCellSwitchSsbRsrq           ${a1_time}
    scf.Add Item To List    dist_name=${dist_name}               list_name=a1MeasPCellSwitchSsbRsrq          elements=${list_elements}


Add Multiple NRMEASPR SCELL MOCs To NRMEAS PROFILE
    FOR    ${index}    IN    @{INDEXES_SA_PROFILES}
        Add NRMEASPR SCELL MOC To NRMEAS PROFILE
        ...    id=${NRMEASPR_SCELL_default_DN[${index}]}
        ...    a1_hyst=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Hysteresis[${index}]}
        ...    a1_thresh=${SCELL_a1MeasPCellSwitchSsbRsrp_a1Threshold[${index}]}
        ...    a1_time=${SCELL_a1MeasPCellSwitchSsbRsrp_a1TimeToTrigger[${index}]}ms
    END


Add NRMEASPR SCELL MOC To NRMEAS PROFILE
    [Arguments]    ${id}   ${a1_hyst}   ${a1_thresh}   ${a1_time}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}
    Set Object    class_name=NRMEASPR_SCELL    dist_name=${dist_name}   version=${NIDD_VERSION}
    Configure A1 Measurement Parameters For RSRP For PCell Switch   dist_name=${dist_name}  a1_hyst=${a1_hyst}  a1_thresh=${a1_thresh}
    ...   a1_time=${a1_time}
    Configure A1 Measurement Parameters For RSRQ For PCell Switch   dist_name=${dist_name}  a1_hyst=${a1_hyst}  a1_thresh=${a1_thresh}
    ...   a1_time=${a1_time}


Add Multiple NRMEASPR SCELL MOCs To NRMEAS PROFILE For SCell Release
    FOR    ${index}    IN    @{INDEXES_NSA_PROFILES}
        Add NRMEASPR SCELL MOC To NRMEAS PROFILE For SCELL Release
        ...    id=${NRMEASPR_SCELL_default_DN[${index}]}
        ...    a2_hyst=${SCELL_a2MeasSCellRelSsbRsrq_a2Hysteresis[${index}]}
        ...    a2_thresh=${SCELL_a2MeasSCellRelSsbRsrq_a2Threshold[${index}]}
        ...    a2_time=${SCELL_a2MeasSCellRelSsbRsrq_a2TimeToTrigger[${index}]}ms
    END


Add NRMEASPR SCELL MOC To NRMEAS PROFILE For SCELL Release
    [Arguments]    ${id}   ${a2_hyst}   ${a2_thresh}   ${a2_time}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}
    Set Object    class_name=NRMEASPR_SCELL    dist_name=${dist_name}   version=${NIDD_VERSION}
    Configure A2 Measurement Parameters For RSRP For SCELL Release   dist_name=${dist_name}  a2_hyst=${a2_hyst}  a2_thresh=${a2_thresh}
    ...   a2_time=${a2_time}
    Configure A2 Measurement Parameters For RSRQ For SCELL Release   dist_name=${dist_name}  a2_hyst=${a2_hyst}  a2_thresh=${a2_thresh}
    ...   a2_time=${a2_time}


Configure A2 Measurement Parameters For RSRP For SCELL Release
    [Arguments]    ${dist_name}   ${a2_hyst}   ${a2_thresh}   ${a2_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a2MeasSCellRelSsbRsrp
    ${list_elements}=       Create Dictionary                    a2HysteresisSCellRelSsbRsrp                 ${a2_hyst}
    ...                                                          a2ThresholdSCellRelSsbRsrp                  ${a2_thresh}
    ...                                                          a2TimeToTriggerSCellRelSsbRsrp	             ${a2_time}
    scf.Add Item To List    dist_name=${dist_name}               list_name=a2MeasSCellRelSsbRsrp          elements=${list_elements}


Configure A2 Measurement Parameters For RSRQ For SCELL Release
    [Arguments]    ${dist_name}   ${a2_hyst}   ${a2_thresh}   ${a2_time}
    sqd65_commissioning.Set New List            dist_name=${dist_name}               list_name=a2MeasSCellRelSsbRsrq
    ${list_elements}=       Create Dictionary                    a2HysteresisSCellRelSsbRsrq                 ${a2_hyst}
    ...                                                          a2ThresholdSCellRelSsbRsrq                  ${a2_thresh}
    ...                                                          a2TimeToTriggerSCellRelSsbRsrq              ${a2_time}
    scf.Add Item To List    dist_name=${dist_name}               list_name=a2MeasSCellRelSsbRsrq          elements=${list_elements}


Apply Configuration For CB013142-J
    [Arguments]    ${cell_index}=1
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-${cell_index}
    Set Element               dist_name=${dist_name}    p_name=a2MeasSCellRelEnabled              value=rsrpCombined
    ${list_name}=             Set Variable                a2MeasSCellRelSsbRsrp
    sqd65_commissioning.Set New List              dist_name=${dist_name}    list_name=${list_name}
    ${list_elements}=         Create Dictionary           a2HysteresisSCellRelSsbRsrp               2
    ...                                                   a2ThresholdSCellRelSsbRsrp                52
    ...                                                   a2TimeToTriggerSCellRelSsbRsrp            2560ms
    scf.Add Item To List      dist_name=${dist_name}    list_name=${list_name}                    elements=${list_elements}

    ${list_name}=             Set Variable                a2MeasSCellRelSsbRsrq
    sqd65_commissioning.Set New List              dist_name=${dist_name}    list_name=${list_name}
    ${list_elements}=         Create Dictionary           a2HysteresisSCellRelSsbRsrq               2
    ...                                                   a2ThresholdSCellRelSsbRsrq                52
    ...                                                   a2TimeToTriggerSCellRelSsbRsrq            2560ms
    scf.Add Item To List      dist_name=${dist_name}    list_name=${list_name}                    elements=${list_elements}

    Add Multiple NRMEASPR SCELL MOCs To NRMEAS PROFILE For SCell Release
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actBufferBasedSCellAddition             disabled        #CB008311 Feature Flag
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


Apply Configuration For CB013142-A
    [Arguments]    ${a2_meas_quantity}=${EMPTY}
    Activate Power Class Configuration For A2 Based PCELL Change With 3CC CA    a2_meas_quantity=${a2_meas_quantity}
    ${dist_name_NRMEASPR_MA_SA}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA
    Log To Console    remove list "snssaiList" from object "${dist_name_NRMEASPR_MA_SA}-9"
    scf.Remove List From Scf       dist_name=${dist_name_NRMEASPR_MA_SA}-9        list_name=snssaiList

    Log To Console    Add list "pcCapabilityList" to object "${dist_name_NRMEASPR_MA_SA}-9"
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRMEASPR_MA_SA}-9      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create Dictionary           uePowerClass                      ue-PowerClass3
    ...                                                         freqBandIndicatorNR               41
    scf.Add Item To List      dist_name=${dist_name_NRMEASPR_MA_SA}-9      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}

    scf.Remove Element From Scf    dist_name=${dist_name_NRMEASPR_MA_SA}-4       p_name=rfspIndex
    scf.Remove Element From Scf    dist_name=${dist_name_NRMEASPR_MA_SA}-4       p_name=rfspIndexLast

    Log To Console    Add list "pcCapabilityList" to object "${dist_name_NRMEASPR_MA_SA}-4"
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRMEASPR_MA_SA}-4      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create Dictionary           uePowerClass                      ue-PowerClass2
    ...                                                         freqBandIndicatorNR               41
    scf.Add Item To List      dist_name=${dist_name_NRMEASPR_MA_SA}-4      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}


Apply Configuration For CB013142-C
    [Arguments]    ${a2_meas_quantity}=${EMPTY}
    sqd65_commissioning.Set New List            dist_name=MRBTS-1/NRBTS-1/NRDU-1             list_name=carrierAggregationSupportList
    ${param_list}=    Create List    ca_Fdd_Any_Sa    ca_Fr1Tdd_Any_Sa    ca_Fr1Tdd_Fdd_Sa    ca_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Sa
    ...    ca_Fdd_Fdd    ca_Fdd_Fr1Tdd_Sa_WithUl    ca_Fr1Tdd_Fdd_Sa_WithUl    ca_Fdd_Fr1Tdd_Nsa    ca_Fr1Tdd_Fdd_Nsa
    scf.Add Elements To List        dist_name=MRBTS-1/NRBTS-1/NRDU-1      list_name=carrierAggregationSupportList   elements=${param_list}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actMeasProfPowerCoordNSA                activated        #CB013392 Feature Flag
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          pMaxNROwnCell                           29
    ...   MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3                  sCellOperationalMode                    dlOnly
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    IF    '${a2_meas_quantity}' != '${EMPTY}'    Apply Configuration For A2 Measurement Based PCell Switch At NRCell    cell_id=1
    ...  a2_meas_quantity=${a2_meas_quantity}

    ${dist_name_NRMEASPR_MA_NSA}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA
    Log To Console    remove list "nrPlmnDNList" from object "${dist_name_NRMEASPR_MA_NSA}-12"
    scf.Remove List From Scf       dist_name=${dist_name_NRMEASPR_MA_NSA}-12        list_name=nrPlmnDNList

    Log To Console    Add list "pcCapabilityList" to object "${dist_name_NRMEASPR_MA_NSA}-12"
    sqd65_commissioning.Set New List                    dist_name=${dist_name_NRMEASPR_MA_NSA}-12      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create Dictionary           uePowerClass                      ue-PowerClass2
    ...                                                         freqBandIndicatorNR               41
    scf.Add Item To List      dist_name=${dist_name_NRMEASPR_MA_NSA}-12      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}


Apply Configuration For CB013142-E
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    p_name=a1MeasPCellSwitchEnabled   value=rsrpCombined
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    p_name=actFullPwrMode             value=true
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    p_name=pMaxNROwnCell              value=26
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    p_name=maxNumOfSCellAlloc         value=0
    Configure A1 Measurement Parameters For RSRQ For PCell Switch
    ...   dist_name=MRBTS-1/NRBTS-1/NRCELL-1  a1_hyst=0  a1_thresh=50  a1_time=480ms
    ${dist_name}=     Set Variable   MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-9
    sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrMeasPrSCellList
    ${MeasPrSCellList_dict}         Create Dictionary           nrMeasPrSCellDN                   NRMEASPR_SCELL-1
    ...                                                         ssbFrequency01                    518910
    scf.Add Item To List            dist_name=${dist_name}      list_name=nrMeasPrSCellList       elements=${MeasPrSCellList_dict}
    ${MeasPrSCellList_dict}         Create Dictionary           nrMeasPrSCellDN                   NRMEASPR_SCELL-67
    ...                                                         ssbFrequency01                    531870
    scf.Add Item To List            dist_name=${dist_name}      list_name=nrMeasPrSCellList       elements=${MeasPrSCellList_dict}

    # required for miNrCABMCCP="5min"
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPMRNL-1/NRCABMCCP-1

    Set Object    class_name=NRCABMCCP    dist_name=${dist_name}    version=${NIDD_VERSION}
    sqd65_commissioning.Set Element       dist_name=${dist_name}    p_name=ueConType           value=SA or NSA

    sqd65_commissioning.Set New List    dist_name=${dist_name}      list_name=freqBandNr
    ${mccp_dict}                        Create Dictionary           caBandwidthClassDlNr       A
    ...                                                             caBandwidthClassUlNr       A
    ...                                                             freqBandIndicatorNr        41
    scf.Add Item To List                dist_name=${dist_name}      list_name=freqBandNr       elements=${mccp_dict}

    sqd65_commissioning.Set New List    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11
    ...                                 list_name=a1MeashoPrefNRLayerSsbRsrp
    ${a1MeashoPrefNRLayerSsbRsrp_dict_1}    Create Dictionary           a1HysteresisSsbRsrp                1
    ...                                                                 a1ThresholdhoSsbRsrp               45
    ...                                                                 a1TimeToTriggerhoSsbRsrp           ms40
    scf.Add Item To List    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-11    list_name=a1MeashoPrefNRLayerSsbRsrp
    ...                     elements=${a1MeashoPrefNRLayerSsbRsrp_dict_1}



Set PM Interval For E Subfeature
    [Arguments]   ${pm_reporting_interval}
    ${dist_name}=    Set Variable      MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
    sqd65_commissioning.Set Element    dist_name=${dist_name}                 p_name=reportingIntervalPm    value=${pm_reporting_interval}
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1    p_name=miNrNgcFlexInterface   value=disabled
    FOR    ${p_name}    IN    @{E_B1_MI_NR_PARAM_LIST}
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1    p_name=${p_name}   value=${pm_reporting_interval}
    END


Update SCell Allocation
    [Arguments]   ${test_instance}=E_B1    ${scell_count}=250
    ${scf_file}=      Load Current SCF
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    p_name=maxNumOfSCellAlloc         value=${scell_count}
    Apply Delta SCF   ${scf_file}    scf_${test_instance}_scell_alloc


Disable Feature For E Subfeature
    [Arguments]    ${tc_identifier}   ${test_instance}=E_B1
    IF    '${tc_identifier}' == '_feat_OFF'
        ${scf_file}=      Load Current SCF
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actCAMeasInMeasProf         value=deactivated
        Apply Delta SCF   ${scf_file}    scf_${test_instance}_${tc_identifier}
    ELSE IF    '${tc_identifier}' == '_feat_ON'
        ${scf_file}=      Load Current SCF
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actCAMeasInMeasProf         value=SA+NSA
        Apply Delta SCF   ${scf_file}    scf_${test_instance}_${tc_identifier}
    END


Activate Power Class Configuration For A2 Based PCELL Change With 3CC CA
    [Arguments]    ${a2_meas_quantity}=${EMPTY}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actMeasurementProfReselForCA            pcInSaUlCaSupported        #CB013392 Feature Flag
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          actFullPwrMode                          true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          pMaxNROwnCell                           26
    ...   MRBTS-1/NRBTS-1/NRCELL-4                          pMaxNROwnCell                           26
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          pMaxNROwnCell                           26
    ...   MRBTS-1/NRBTS-1/NRCELL-5                          maxNumOfSCellAlloc                      250
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    Add NRHOIF MOC To NRCELL   id=5  freq_band=66  ssb_freq=${CARRIER_FREQ_5}  a2_pcell_switch_prio=10
    IF    '${a2_meas_quantity}' != '${EMPTY}'    Apply Configuration For A2 Measurement Based PCell Switch At NRCell    cell_id=1
    ...    a2_meas_quantity=${a2_meas_quantity}


Activate A2 Measurement Based SCell Release
    [Arguments]   ${test_instance}=BA_B6
    ${scf_file}=      Load Current SCF
    FOR    ${cell_index}    IN RANGE    1    3
          ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-${cell_index}
          Set Element               dist_name=${dist_name}    p_name=a2MeasSCellRelEnabled              value=rsrp
          ${list_name}=             Set Variable              a2MeasSCellRelSsbRsrp
          sqd65_commissioning.Set New List              dist_name=${dist_name}    list_name=${list_name}
          ${list_elements}=         Create Dictionary         a2HysteresisSCellRelSsbRsrp               0
          ...                                                 a2ThresholdSCellRelSsbRsrp                34
          ...                                                 a2TimeToTriggerSCellRelSsbRsrp            2560ms
          scf.Add Item To List      dist_name=${dist_name}    list_name=${list_name}                    elements=${list_elements}
    END
    Apply Delta SCF   ${scf_file}    Scf_${test_instance}_A2_Scell_Rel


Apply Online Modification By Creating New NRMEASPR SCELL MOCs And Mapping It To NRMEASPR MA SA
    [Arguments]   ${test_instance}=BA_B6   ${ssbFreq01}=${CARRIER_FREQ_2}   ${ssbFreq02}=${CARRIER_FREQ_1}
    ${scf_file}=      Load Current SCF
    Add NRMEASPR SCELL MOC To NRMEAS PROFILE   id=77  a1_hyst=12  a1_thresh=62  a1_time=640ms
    Add NRMEASPR SCELL MOC To NRMEAS PROFILE   id=96  a1_hyst=30  a1_thresh=80  a1_time=5120ms
    ${dist_name}=     Set Variable   MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4
    sqd65_commissioning.Set New List                    dist_name=${dist_name}      list_name=nrMeasPrSCellList
    ${MeasPrSCellList_dict}         Create Dictionary           nrMeasPrSCellDN                   NRMEASPR_SCELL-77
    ...                                                         ssbFrequency01                    1
    ...                                                         ssbFrequency02                    2
    ...                                                         ssbFrequency03                    ${ssbFreq01}
    scf.Add Item To List            dist_name=${dist_name}      list_name=nrMeasPrSCellList       elements=${MeasPrSCellList_dict}
    ${MeasPrSCellList_dict}         Create Dictionary           nrMeasPrSCellDN                   NRMEASPR_SCELL-96
    ...                                                         ssbFrequency01                    11
    ...                                                         ssbFrequency02                    12
    ...                                                         ssbFrequency03                    13
    ...                                                         ssbFrequency04                    14
    ...                                                         ssbFrequency05                    15
    ...                                                         ssbFrequency06                    ${ssbFreq02}
    scf.Add Item To List            dist_name=${dist_name}      list_name=nrMeasPrSCellList       elements=${MeasPrSCellList_dict}
    Apply Delta SCF   ${scf_file}    Scf_${test_instance}_Create_Prof


Apply Online Modification To Activate Or Deactivate CB013142
    [Arguments]   ${faf}   ${test_instance}=BA_B6
    ${scf_file}=      Load Current SCF
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=actCAMeasInMeasProf    value=${faf}
    Apply Delta SCF   ${scf_file}    Scf_${test_instance}_CB013142_${faf}

Add NRMEASPR IEF To NRMEAS PROFILE-1
    [Arguments]    ${id}=11
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-${id}
    Set Object    class_name=NRMEASPR_IEF    dist_name=${dist_name}   version=${NIDD_VERSION}
