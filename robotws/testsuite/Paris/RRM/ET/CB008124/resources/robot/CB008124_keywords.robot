*** Settings ***
Documentation     [SUITE PURPOSE]  Generic keywords for 5GC00CB008124
...
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 13-Feb-2023
...               Last Modified by            : vincent.boulet@nokia.com
...               Modification:
...                       17-Oct-2022         | Creation
...                       02-Feb-2022         | Add RRC check related to betaOffset
...                       17-Oct-2022         | Creation
...                       13-Feb-2023         | Add SkipCgActivationDci test mode
...                       03-Mar-2023         | Add CgActivationMacCeNok test mode
...                       07-Mar-2023         | Update to define CG bearer for B09
...                       13-Mar-2023         | Define CG counters
...                       20-Mar-2023         | Add A-CSI activation if requested
...                       29-Apr-2024         | Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC


Library             taf.sbts.oam.coam.admin                       WITH NAME       sbts_coam
Library             taf.wts.runner                                WITH NAME       wtsemu
Library             taf.rfrl.common_resources.python.SWConfig     WITH NAME       swconf
Library             taf.transport.ssh                             WITH NAME       ssh
Library             ../../../resources/python/luashark_tools.py
Library             ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter

Library             ../python/CB008124_checkTTItrace.py
Library             ../python/CB008124_checkBetaOffsetIEs.py
Variables           ../python/Constants.py

Resource            ../../../../../resources/SWENG/robot/CallSetup.robot
Resource            ../../../../../resources/SWENG/robot/Tools.robot
Resource            ../../../../../resources/SWENG/robot/Capture.robot
Resource            ../../../../../resources/SWENG/robot/SetConfig.robot
Resource            ../../../../../resources/SWENG/robot/Traffic.robot
Resource            ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource            ../../../../../resources/SWENG/robot/Restart.robot
Resource            ../../../../../resources/SWENG/robot/Counters.robot
Resource            ../../../../../resources/SWENG/robot/Oam.robot
Resource            ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource            ../../../../../resources/SWENG/robot/Setup.robot
Resource            ../../../../../resources/SWENG/robot/Scf.robot
Resource            ../../../../../resources/SWENG/robot/Sherpa.robot

Variables           ../../../../../resources/SWENG/python/Colors.py


*** Variables ***
${faultID_IncorrectCellConfiguration}    7516

&{ULCG_defaultConf}      ulCgMaxNumPrbs=4
...                      ulCgMaxNumUeUl=1
...                      ulCgPrbStartOffset=0
...                      grantedPacketSize=10
...                      maxNumPrbs=4
...                      periodicity=ms80
...                      p0NominalPusch=-82


# FDD periodicity (req. 5G_CP_ARC_ALG_8432)
&{ULCG_periodicityValue_FDD}
...                      ms1=1
...                      ms2=2
...                      ms5=5
...                      ms10=10
...                      ms20=20
...                      ms40=40
...                      ms80=80

# TDD periodicity (req. 5G_CP_ARC_ALG_8432)
# Note: with ms1 and ms2, periodicity 10 (instead of 5) shall be used for TDD pattern configurations : 1116_0ms and 1116_3ms
&{ULCG_periodicityValue_TDD}
...                      ms1=5
...                      ms2=5
...                      ms5=10
...                      ms10=20
...                      ms20=40
...                      ms40=80
...                      ms80=160

@{Counters_PUSCH_CP_InitialTx}    M55302C00000    M55302C00001    M55302C00002    M55302C00003    M55302C00004    M55302C00005
...                               M55302C00006    M55302C00007    M55302C00008    M55302C00009    M55302C00010    M55302C00011
...                               M55302C00012    M55302C00013    M55302C00014    M55302C00015    M55302C00016    M55302C00017
...                               M55302C00018    M55302C00019    M55302C00020    M55302C00021    M55302C00022    M55302C00023
...                               M55302C00024    M55302C00025    M55302C00026    M55302C00027    M55302C00028    M55302C11000
...                               M55302C11001    M55302C11002    M55302C11003    M55302C11004    M55302C11005    M55302C11006
...                               M55302C11007    M55302C11008    M55302C11009    M55302C11010    M55302C11011    M55302C11012
...                               M55302C11013    M55302C11014    M55302C11015    M55302C11016    M55302C11017    M55302C11018
...                               M55302C11019    M55302C11020    M55302C11021    M55302C11022    M55302C11023    M55302C11024
...                               M55302C11025    M55302C11026    M55302C11027

@{Counters_PUSCH_CP_SuccTx}       M55302C04000    M55302C04001    M55302C04002    M55302C04003    M55302C04004    M55302C04005
...                               M55302C04006    M55302C04007    M55302C04008    M55302C04009    M55302C04010    M55302C04011
...                               M55302C04012    M55302C04013    M55302C04014    M55302C04015    M55302C04016    M55302C04017
...                               M55302C04018    M55302C04019    M55302C04020    M55302C04021    M55302C04022    M55302C04023
...                               M55302C04024    M55302C04025    M55302C04026    M55302C04027    M55302C04028    M55302C13000
...                               M55302C13001    M55302C13002    M55302C13003    M55302C13004    M55302C13005    M55302C13006
...                               M55302C13007    M55302C13008    M55302C13009    M55302C13010    M55302C13011    M55302C13012
...                               M55302C13013    M55302C13014    M55302C13015    M55302C13016    M55302C13017    M55302C13018
...                               M55302C13019    M55302C13020    M55302C13021    M55302C13022    M55302C13023    M55302C13024
...                               M55302C13025    M55302C13026    M55302C13027

${counter_UL_MAC_SDU_VOL_DTCH}    M55309C02001
${Counter_MAX_SCHED_UE_PUSCH}     M55308C18002

# Counters definition for VRAN
&{dictCnt_UL_MAC_SDU_VOL_DTCH}    counter=M55309C02001    obj=NRCELL    objId=1
&{dictCnt_MAX_SCHED_UE_PUSCH}     counter=M55308C18002    obj=NRCELL    objId=1

# CG counters
${CGcounter_UL_CG_ACT_ATT}          M55308C00020
${CGcounter_UL_CG_ACT_ATT_SUCC}     M55308C00021
${CGcounter_UL_CG_DEACT_ATT}        M55308C00022
${CGcounter_UL_CG_DEACT_ATT_SUCC}   M55308C00023
${CGcounter_UL_CG_MOD_ATT}          M55308C00024
${CGcounter_UL_CG_MOD_ATT_SUCC}     M55308C00025
${CGcounter_TOT_CG_ACT_UE}          M55308C00034
${CGcounter_PEAK_CG_ACT_UE}         M55308C00035

# CG counters dictionaries for VRAN
&{dictCGcnt_UL_CG_ACT_ATT}          counter=M55308C00020    obj=NRCELL    objId=1
&{dictCGcnt_UL_CG_ACT_ATT_SUCC}     counter=M55308C00021    obj=NRCELL    objId=1
&{dictCGcnt_UL_CG_DEACT_ATT}        counter=M55308C00022    obj=NRCELL    objId=1
&{dictCGcnt_UL_CG_DEACT_ATT_SUCC}   counter=M55308C00023    obj=NRCELL    objId=1
&{dictCGcnt_UL_CG_MOD_ATT}          counter=M55308C00024    obj=NRCELL    objId=1
&{dictCGcnt_UL_CG_MOD_ATT_SUCC}     counter=M55308C00025    obj=NRCELL    objId=1
&{dictCGcnt_TOT_CG_ACT_UE}          counter=M55308C00034    obj=NRCELL    objId=1
&{dictCGcnt_PEAK_CG_ACT_UE}         counter=M55308C00035    obj=NRCELL    objId=1


# RAD param definition
# rdEnableCGTrafficOverwriting
${RD_EnableCGOW}                    0x5806E0
# rdEnableCgAdjustment
${RD_EnableCGadjusment}             0x580709

${RD_SlowPrbPoolingRangeTddUl}      0x580612


*** Keywords ***
CB008124 Set CG OW Adjustment
    [Arguments]                        ${CGOW}=1    ${CGadjusment}=1
    Dated Log new line                 ${trcColor}=== Configure CW OW/adjustment via RAD param ${defColor}
    ${prd_EnableCGOW}                  Create Dictionary    field=${RD_EnableCGOW}           value=${CGOW}
    ${prd_EnableCGadjusment}           Create Dictionary    field=${RD_EnableCGadjusment}    value=${CGadjusment}
    ${list_rad_param}                  Create List          ${prd_EnableCGOW}    ${prd_EnableCGadjusment}
    Set Fields in swconfig DU          param_list=${list_rad_param}

CB008124 Set CgULGrantType2 UE Capa
    Dated Log new line                 ${trcColor}=== Update UE capa ${defColor}
    ${UEcapa}                          Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                   ${UEcapa_ConfiguredULGrantType2_enhancedSkipUplinkTxConfigured_r16_TDD}
    ...                                                   ${UEcapa_configuredUL_GrantType2_v1650_enhancedSkipUplinkTxConfigured_v1660_FDD}
    Modify Field in WtsEmu Cfg File    field=ue_nr_capabilities    value=${UEcapa}


CB008124 Create UECG UEnonCG
    [Arguments]                        ${nbUECG}=1    ${nbUEnonCG}=0

    Dated Log new line                 ${trcColor}=== Define ${nbUECG} UE(s) CG, and ${nbUEnonCG} UE(s) non CG in cfg file ${defColor}
    ${nbUEs}                           Evaluate       ${nbUECG}+${nbUEnonCG}
    Create UEs in Cfg File             nb_sa_ues=${nbUEs}

    ${tgtCell}                         Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                   ${TDD_Cell_list[0].nrCellId}
    ...                                                   ${FDD_Cell_list[0].nrCellId}

    FOR                                ${UEid}    IN RANGE    ${nbUEs}    0    -1
        Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${UEid}    cell_id=${tgtCell}
    END

    ${UEcapa}                          Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                   ${UEcapa_ConfiguredULGrantType2_enhancedSkipUplinkTxConfigured_r16_TDD}
    ...                                                   ${UEcapa_configuredUL_GrantType2_v1650_enhancedSkipUplinkTxConfigured_v1660_FDD}

    # Modify UE capa of UE(s) CG
    FOR                                ${UEid}    IN RANGE    ${nbUECG}    0    -1
        Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${UEid}    ue_nr_capa=${UEcapa}
    END


CB008124 Get SCF File
    OAM Get SCF Files
    ${TC_file_name}                    getFormattedTestName
    ${DU_SCF}                          Set Variable    ${LOG_PATH}/SCF_DU_${TC_file_name}.xml
    ${CU_SCF}                          Set Variable If     ${isAic}    ${LOG_PATH}/SCF_CU_${TC_file_name}.xml    ${EMPTY}

    ${std_output}                      Run         cp ${SCF_SETUP_PATH} ${DU_SCF}
    ${std_output}                      Run         cp ${SCF_CU_SETUP_PATH} ${CU_SCF}
    [Return]                           ${DU_SCF}    ${CU_SCF}


CB008124 SCF config
    [Arguments]                 ${scf_file}    ${actUlCgType2}=true    ${ULCGconfig}=${ULCG_defaultConf}    ${CGbearer}=6    ${ACSI}=false
    Dated Log new line          ${trcColor}=== Start SCF configuration ${defColor}

    ${DU_SCF}                   Set Variable    ${scf_file}[0]
    ${CU_SCF}                   Set Variable    ${scf_file}[1]

    SCF StartSession            scf_file=${DU_SCF}    second_scf_file=${CU_SCF}

    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                         element_name=actInactDetNSAUe
    ...                         element_value=false
    ...                         aicListEntity=vcu
    ...                         scope=Both

    ${cellDistName}             Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
    ...                                             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${FDD_Cell_list[0].nrCellId}

    SCF Set element             dist_name=${cellDistName}
    ...                         element_name=actCDrx
    ...                         element_value=false
    ...                         aicListEntity=vduvcu
    ...                         scope=Both

    SCF Set element             dist_name=${cellDistName}
    ...                         element_name=actUlCgType2
    ...                         element_value=${actUlCgType2}
    ...                         aicListEntity=vdu
    ...                         scope=Both

    Run Keyword If              '${ACSI}'=='true'
    ...                         SCF Set element             dist_name=${cellDistName}
    ...                         element_name=actAperCsi
    ...                         element_value=${ACSI}
    ...                         aicListEntity=vduvcu
    ...                         scope=Both

    Run Keyword If              ${isAic} and '${duplexModeTC}' == 'TDD'
    ...                         SCF Disable BeamForming

    SCF StopSession             scf_file=${DU_SCF}    second_scf_file=${CU_SCF}

    Run Keyword If              '${actUlCgType2}'=='true'
    ...                         CB008124 ULCG config    ${DU_SCF}    ULCGconfig=${ULCGconfig}    CGbearer=${CGbearer}


CB008124 ULCG config
    [Arguments]                 ${scf_file}    ${ULCGconfig}=${ULCG_defaultConf}    ${CGbearer}=6
    Dated Log new line          ${trcColor}=== ULCG configuration ${defColor}

    SCF StartSession            scf_file=${scf_file}

    FOR    ${NRCELLitem}    IN    @{NRCELL_DN_LIST}
        Run Keyword If    '${NRCELLitem}' != '${None}'    Run Keywords
        ...        SCF Set element in List     dist_name=${NRCELLitem}      list_name=ulConfiguredGrantType2
        ...                         element_name=ulCgMaxNumPrbs        element_value=${ULCGconfig.ulCgMaxNumPrbs}
        ...                         aicListEntity=vdu                  scope=Both
        ...        AND
        ...        SCF Set element in List     dist_name=${NRCELLitem}      list_name=ulConfiguredGrantType2
        ...                         element_name=ulCgMaxNumUeUl        element_value=${ULCGconfig.ulCgMaxNumUeUl}
        ...                         aicListEntity=vdu                  scope=Both
        ...        AND
        ...        SCF Set element in List     dist_name=${NRCELLitem}      list_name=ulConfiguredGrantType2
        ...                         element_name=ulCgPrbStartOffset    element_value=${ULCGconfig.ulCgPrbStartOffset}
        ...                         aicListEntity=vdu                  scope=Both
	    ...        AND
        ...        SCF Set element in List     dist_name=${NRCELLitem}      list_name=ulPowerControlCommon
        ...                         element_name=p0NominalPusch    element_value=${ULCGconfig.p0NominalPusch}
        ...                         aicListEntity=vdu                  scope=Both
    END

    #vbo#${NRULCG_PROFILE} dictionary is removed as it is not used#

    ${NRULCG_PROFILE_distName}  Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRULCG_PROFILE-1
    SCF Add object              dist_name=${NRULCG_PROFILE_distName}    class_name=com.nokia.srbts.nrbts:NRULCG_PROFILE
    ...                         version=${None}
    ...                         aicListEntity=vdu    scope=Both
    #vbo#SCF Add element is preferred as SCF Set element because the dist_name is newly added and that this KW not generates error into log#
    SCF Add element             dist_name=${NRULCG_PROFILE_distName}    element_name=grantedPacketSize
    ...                         element_value=${ULCGconfig.grantedPacketSize}
    ...                         aicListEntity=vdu    scope=Both
    SCF Add element             dist_name=${NRULCG_PROFILE_distName}    element_name=maxNumPrbs
    ...                         element_value=${ULCGconfig.maxNumPrbs}
    ...                         aicListEntity=vdu    scope=Both
    SCF Add element             dist_name=${NRULCG_PROFILE_distName}    element_name=periodicity
    ...                         element_value=${ULCGconfig.periodicity}
    ...                         aicListEntity=vdu    scope=Both
    # remove skipUplinkTxConfigured parameter as it does not exist anymore
    #Run Keyword If    not ${isAic}    SCF Set element    dist_name=${NRULCG_PROFILE_distName}    element_name=skipUplinkTxConfigured
    #...                         element_value=false
    #...                         aicListEntity=vdu    scope=Both
    ${NRDRB_distName}           Run Keyword If     not ${isAic}
    ...                         OAM Get nrDrbDN    callType=SA    bearerId=${CGbearer}    oam=${GNB_DU.oam}
    ...          ELSE           OAM Get nrDrbDN    callType=SA    bearerId=${CGbearer}    oam=${GNB_CU.oam}
    Dated Log new line          ${trcColor}##### nrDrbDN: ${NRDRB_distName} ##### ${defColor}
    #vbo#SCF Add element is preferred as SCF Set element because the dist_name is newly added and that this KW not generates error into log#
    SCF Add element             dist_name=${NRDRB_distName}
    ...                         element_name=nrDrbUlCgDN
    ...                         element_value=${NRULCG_PROFILE_distName}
    ...                         aicListEntity=vdu    scope=Both

    # WA for previous SWFH VRAN configuration which didn't include 5QI definition on vDU
    #Run Keyword If              ${isAic}    CB008124 Add 5QI6 for VRAN    dnNRDRB=${NRDRB_distName}

    SCF StopSession             scf_file=${scf_file}


CB008124 Add 5QI6 for VRAN
    [Arguments]                 ${dnNRDRB}
    ${dn5QI6}                   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-1/NRDRB_5QI-2
    ${is5QI6defined}            SCF Is Object Exist    ${dn5QI6}    aicListEntity=vdu    scope=aic

    @{5QIlist}                  Create List    6
    Run Keyword If              not ${is5QI6defined}    Run Keywords
    ...                         SCF Add object              dist_name=${dn5QI6}    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...                                                     version=${None}
    ...                                                     aicListEntity=vdu    scope=aic
    ...        AND              SCF Add list                dist_name=${dn5QI6}    list_name=fiveqiValueList
    ...                                                     aicListEntity=vdu    scope=aic
    ...        AND              SCF Add elements to list    dist_name=${dn5QI6}    list_name=fiveqiValueList    elements=${5QIlist}
    ...                                                     aicListEntity=vdu    scope=aic
    ...        AND              SCF Add element             dist_name=${dn5QI6}    element_name=nrDrbDN    element_value=${dnNRDRB}
    ...                                                     aicListEntity=vdu    scope=aic


CB008124 Full Commissioning
    [Arguments]                 ${scf_list}
    Dated Log new line          ${trcColor}=== Perform full commissioning ${defColor}
    OAM Perform Full Commissioning    scf_file=${scf_list}[0]
    OAM wait available

    Run Keyword If                  ${isAic}    run keywords
    ...                                         OAM Perform Full Commissioning    scf_file=${scf_list}[1]    oam=${GNB_CU.oam}
    ...                 AND                     F1 Wait Link AIC    timeout=10min
    ...                 AND                     Clean PM on Aic TL


CB008124 cell setup
    Dated Log new line          ${trcColor}=== WTS setup ${defColor}
    CB008124 Start Capture After GNB Ready
    Setup Wtsemu SA             shouldUseLua=False
    CB008124 Capture Stop       cellSetup


CB008124 Attach
    [Arguments]                     ${ueSetting}    ${CPRTcapture}=${False}
    Dated Log new line              ${trcColor}--- SA call UE ${ueSetting.ue} ${defColor}
    Run Keyword If                  ${CPRTcapture} == ${True}
    ...                             CB008124 Start Capture Attach       UEid=${ueSetting.ue}
    UE Register                     ue=${ueSetting.ue}
    Launch PDU Session              ue=${ueSetting.ue}    pdu=${ueSetting.pdu}    gw=${ueSetting.ue}
    Run Keyword If                  ${CPRTcapture} == ${True}
    ...                             CB008124 Capture Stop               Attach


########################  Traces KWs  ########################
CB008124 Start Capture After GNB Ready
    ${CaptureCPRT_setup}            Capture CPRT Set upon config
    ${TestNameWOspace}              getFormattedTestName

    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    # Filter to use when CNI-78299 will be implemented again instead of SCTP:
    #${CaptureCPRT_setup.filter}     Get Filter For TCP
    Capture Init                    ${CaptureCPRT_setup}             withTN=True             suffix=_setup

    ${CaptureCore_setup}            Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_setup}             withTN=True             suffix=_setup

    Capture Start                   ${CaptureCPRT_setup}
    Capture Start                   ${CaptureCore_setup}
    Set Suite Variable              ${CaptureCPRT_setup}
    Set Suite Variable              ${CaptureCore_setup}

CB008124 Start Capture Attach
    [Arguments]                     ${UEid}=1
    ${TestNameWOspace}              getFormattedTestName

    ${CaptureCPRT_attach}           Capture CPRT Set upon config
    ${CaptureCPRT_attach.filter}    Get Filter For SCTP
    # Filter to use when CNI-78299 will be implemented again instead of SCTP:
    #${CaptureCPRT_attach.filter}    Get Filter For TCP
    Capture Init                    ${CaptureCPRT_attach}            withTN=True             suffix=_attach_${UEid}

    ${CaptureCore_attach}           Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_attach}            withTN=True             suffix=_attach_${UEid}

    Capture Start                   ${CaptureCPRT_attach}
    Capture Start                   ${CaptureCore_attach}
    Set Suite Variable              ${CaptureCPRT_attach}
    Set Suite Variable              ${CaptureCore_attach}

CB008124 Capture Stop
    [Arguments]                     ${step}
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...                             AND
    ...                             Capture Stop                     ${CaptureCPRT_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...                             AND
    ...                             Capture Stop                     ${CaptureCPRT_attach}


#########################  Test Mode KWs  #########################
CB008124 CG TM Skip activation DCI
    [Arguments]                     ${UEid}=1    ${skipNb}=1

    wtsemu.cg_testmode_nr           profile_id=${UEid}
    ...                             SkipCgActivationDci=${skipNb}

    wtsemu.ue_testmode_set_nr       id=${UEid}
    ...                             testmode=configured_grant
    ...                             profile_id=${UEid}
    ...                             scell=1
    ...                             action=activate

CB008124 CG TM activation no MACCE
    [Arguments]                     ${UEid}=1    ${skipNb}=1

    wtsemu.cg_testmode_nr           profile_id=${UEid}
    ...                             CgActivationMacCeNok=${skipNb}

    wtsemu.ue_testmode_set_nr       id=${UEid}
    ...                             testmode=configured_grant
    ...                             profile_id=${UEid}
    ...                             scell=1
    ...                             action=activate

CB008238 deactivate CG TM
    [Documentation]                 Deactivate CG test mode for an UE
    [Arguments]                     ${UEid}=1

    wtsemu.ue_testmode_set_nr       id=${UEid}
    ...                             testmode=configured_grant
    ...                             profile_id=${UEid}
    ...                             scell=1
    ...                             action=deactivate


#########################  Check KWs  #########################
CB008124 get PM files
    # Use new KW SWENG "Wait PM availability" to wait PM files avaibility
    #CB008124 Get Reporting Interval PM
    #Traced Sleep                    ${reportingIntervalPm}[0]    msg=waiting PM counter generation
    Wait PM availability
    ${pm_path}                      Set Variable                 ${LOG_PATH}/pm_files
    ${pm_latest}                    Run Keyword if    not ${isAic}
    ...                             Collect PM files from BTS     ${pm_path}
    ...       ELSE                  Perform Collect PM for AiC    ${pm_path}
    Set Suite Variable              ${pm_path}
    Set Suite Variable              ${pm_latest}

CB008124 Get Reporting Interval PM
    SCF StartSession                scf_file=${SCF_SETUP_PATH}
    ${dist_name}                    Set Variable                 MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    ${reportingIntervalPm}          SCF Get Single Value         ${dist_name}           reportingIntervalPm
    ...                                                          aicListEntity=vdu      scope=Both
    SCF StopSession                 scf_file=${SCF_SETUP_PATH}
    Dated Log new line              ${trcColor}- ReportingIntervalPm is: ${reportingIntervalPm} ${defColor}
    Set Suite Variable              ${reportingIntervalPm}


CB008124 check CellSetup
    [Arguments]                     ${ULCGenabled}=${True}    ${ULCGconfig}=${ULCG_defaultConf}
    Dated Log new line              ${trcColor}=== Check cell setup ${defColor}

    ${pdmlFile}                     analyzer.pcap_to_pdml         ${CaptureCPRT_setup.path}

    Run Keyword if                  ${ULCGenabled} == ${True}
    ...                             CB008124 check CellSetup ULCG enabled    pdmlFile=${pdmlFile}    ULCGconfig=${ULCGconfig}
    ...                             ELSE
    ...                             CB008124 check CellSetup ULCG disabled   pdmlFile=${pdmlFile}

CB008124 check CellSetup ULCG disabled
    [Arguments]                     ${pdmlFile}
    ${actUlCgType2Path}             Set Variable    itf_l2_ps_cell_CellSetupReq_t.actUlCgType2
    ${ulCgMaxNumPrbsPath}           Set Variable    itf_UlCgResourceType2.ulCgMaxNumPrbs
    ${ulCgPrbStartOffsetPath}       Set Variable    itf_UlCgResourceType2.ulCgPrbStartOffset
    ${ulCgMaxNumUeUlPath}           Set Variable    itf_l2_ps_cell_CellSetupReq_t.ulCgMaxNumUeUl_item

    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_cellsetupreq
    ...                             path=${actUlCgType2Path}
    ...                             value=0

    ${count}                        analyzer.count_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_cellsetupreq
    ...                             path=${ulCgMaxNumPrbsPath}
    should be true                  '${count}'=='0'

    ${count}                        analyzer.count_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_cellsetupreq
    ...                             path=${ulCgPrbStartOffsetPath}
    should be true                  '${count}'=='0'

    ${count}                        analyzer.count_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=itf_l2_ps_cell_cellsetupreq
    ...                             path=${ulCgMaxNumUeUlPath}
    should be true                  '${count}'=='0'

    ${present}                      OAM Is Fault Present     faultId=${faultID_IncorrectCellConfiguration}
    should be true                  ${present}


CB008124 check CellSetup ULCG enabled
    [Arguments]                     ${pdmlFile}    ${ULCGconfig}=${ULCG_defaultConf}
    ${actUlCgType2Path}             Set Variable    itf_l2_ps_cell_CellSetupReq_t.actUlCgType2
    ${ulCgMaxNumPrbsPath}           Set Variable    itf_UlCgResourceType2.ulCgMaxNumPrbs
    ${ulCgPrbStartOffsetPath}       Set Variable    itf_UlCgResourceType2.ulCgPrbStartOffset
    ${ulCgMaxNumUeUlPath}           Set Variable    itf_l2_ps_cell_CellSetupReq_t.ulCgMaxNumUeUl_item

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_cell_cellsetupreq
    ...                            path=${actUlCgType2Path}
    ...                            value=1

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_cell_cellsetupreq
    ...                            path=${ulCgMaxNumPrbsPath}
    ...                            value=${ULCGconfig.ulCgMaxNumPrbs}

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_cell_cellsetupreq
    ...                            path=${ulCgPrbStartOffsetPath}
    ...                            value=${ULCGconfig.ulCgPrbStartOffset}

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_cell_cellsetupreq
    ...                            path=${ulCgMaxNumUeUlPath}
    ...                            value=${ULCGconfig.ulCgMaxNumUeUl}

CB008124 check Attach
    # [Arguments]                     ${ULCGenabled}=${True}    ${ULCGconfig}=${ULCG_defaultConf}
    [Arguments]                     ${ULCGconfig}=${ULCG_defaultConf}
    Dated Log new line              ${trcColor}=== Check attach ${defColor}
    ${UlCgProfilePeriodicityPath}            Set Variable    itf_UlCgProfile.periodicity
    ${UlCgProfileGrantedPacketSizePath}      Set Variable    itf_UlCgProfile.grantedPacketSize
    ${UlCgProfileMaxNumPrbsPath}             Set Variable    itf_UlCgProfile.maxNumPrbs

    ${UlCgConfResultPath}                    Set Variable    itf_UlCgConfDeconfInd.result

    ${enhancedSkipULTxConfiguredPath}        Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                         nr-rrc.enhancedSkipUplinkTxConfigured_r16
    ...                                                         nr-rrc.enhancedSkipUplinkTxConfigured_v1660

    ${configuredUL_GrantType2Path}           Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                         nr-rrc.configuredUL_GrantType2
    ...                                                         nr-rrc.configuredUL_GrantType2_v1650

    ${ULCG_periodicityValue}                 Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                         ${ULCG_periodicityValue_TDD}
    ...                                                         ${ULCG_periodicityValue_FDD}

    ${pdmlFile}                     analyzer.pcap_to_pdml         ${CaptureCPRT_attach.path}

    analyzer.check_exists_once     pdmlFile=${pdmlFile}


    ...                            packetName=itf_l2_ps_user_usermodifyreq
    ...                            path=${UlCgProfilePeriodicityPath}
    ...                            value=${ULCG_periodicityValue.${ULCGconfig.periodicity}}

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_user_usermodifyreq
    ...                            path=${UlCgProfileGrantedPacketSizePath}
    ...                            value=${ULCGconfig.grantedPacketSize}

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_user_usermodifyreq
    ...                            path=${UlCgProfileMaxNumPrbsPath}
    ...                            value=${ULCGconfig.maxNumPrbs}
    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=itf_l2_ps_user_rrcreconfcompletedreq
    ...                            path=${UlCgConfResultPath}
    ...                            value=1
    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=UEContextSetupRequest
    ...                            path=${enhancedSkipULTxConfiguredPath}
    ...                            value=0
    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=UEContextSetupRequest
    ...                            path=${configuredUL_GrantType2Path}
    ...                            value=0

    analyzer.check_exists_once     pdmlFile=${pdmlFile}
    ...                            packetName=UEContextSetupResponse
    ...                            path=nr-rrc.enhancedSkipUplinkTxConfigured_r16
    ...                            value=0

    ${count}                        analyzer.count_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=UEContextSetupResponse
    ...                             path=nr-rrc.cs_RNTI
    should be true                  '${count}'!='0'

    ${count}                        analyzer.count_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=UEContextSetupResponse
    ...                             path=nr-rrc.configuredGrantConfig
    should be true                  '${count}'!='0'

    # Check betaOffset IEs inside RrcReconfiguration. It's better to do this on WTS side as RRC layer
    # as the real message is received by UE.
    # Flush egate buffer
    Empty Buffer For Egate
    ${BetaOffsetStatus}             checkCGuciOnPUSCHIEs            egate_console_path=${tl.core.dir_path}/egate_console.log
    should be true                  '${BetaOffsetStatus}'=='True'

CB008124 check UL Data Volume
    [Arguments]                 ${expectedDataVolBytes}    ${cellId}=1
    Dated Log new line          ${trcColor}=== Check UL data volume counter on cell ${cellId} ${defColor}

    ${data_volume}              Run Keyword if    not ${isAic}
    ...                         Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                            ${pm_path}    NRCELL    ${counter_UL_MAC_SDU_VOL_DTCH}    object_id=${cellId}
    ...              ELSE       Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                            &{dictCnt_UL_MAC_SDU_VOL_DTCH}

    Dated Log new line          ${trcColor}- ${counter_UL_MAC_SDU_VOL_DTCH} : ${data_volume} (expected min ${expectedDataVolBytes}) ${defColor}
    ${Status}                   Set Variable If    ${data_volume} > ${expectedDataVolBytes}    ${True}    ${False}
    [Return]                    ${Status}

CB008124 check UL BLER
    [Arguments]                 ${maxBLER}=10    ${cellId}=1
    Dated Log new line          ${trcColor}=== Check UL BLER on cell ${cellId} ${defColor}

    ${InialTxNb}                Set Variable      0
    &{dictCntVran}              Create Dictionary    counter=counterIDtoSet    obj=NRCELL    objId=${cellId}
    FOR   ${counter}   IN   @{Counters_PUSCH_CP_InitialTx}
        Set To Dictionary       ${dictCntVran}    counter    ${counter}
        ${value}                Run Keyword if    not ${isAic}
        ...                     Retrieve Counter Sum of Values From Pm Files For Object With Name
        ...                          ${pm_path}    NRCELL    ${counter}    object_id=${cellId}
        ...          ELSE       Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
        ...                            &{dictCntVran}

        ${InialTxNb}            Evaluate          ${InialTxNb}+${value}
    END

    ${successfulTxNb}           Set Variable      0
    FOR   ${counter}   IN   @{Counters_PUSCH_CP_SuccTx}
        Set To Dictionary       ${dictCntVran}    counter    ${counter}
        ${value}                Run Keyword if    not ${isAic}
        ...                     Retrieve Counter Sum of Values From Pm Files For Object With Name
        ...                          ${pm_path}    NRCELL    ${counter}    object_id=${cellId}
        ...          ELSE       Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
        ...                            &{dictCntVran}

        ${successfulTxNb}       Evaluate          ${successfulTxNb}+${value}
    END

    ${BLERlevel}                Run Keyword If  ${InialTxNb}!=0
    ...                         Evaluate     (${InialTxNb}-${successfulTxNb})*100/${InialTxNb}
    ...                         ELSE
    ...                         Set Variable    100

    Dated Log new line          ${trcColor}- UL initial BLER: ${bler_level}% (expected max ${maxBLER}%) ${defColor}
    ${Status}                   Set Variable If    ${bler_level}<=${maxBLER}    ${True}    ${False}
    [Return]                    ${Status}

CB008124 Connect To AP
    [Documentation]
    ...     setup ssh connection to Airphone Airscale (ASXX) and returns connection handle/alias
    ...
    ...     | ue_id      | Id of UE [0.. ] |
    ...     | ue_comu_id | Id of AP Common Unit [0..1] |
    ...     | alias      | connection alias, should not be used !! |
    ...     | force      | session reconnection if needed (either True or False) |
    ...
    ...     *Example*
    ...
    ...     | ${ap_alias}   connect.Connect to Airphone Common Unit    ue_id=0  ue_comu_id=0
    ...     | ssh.execute     command=uptime  connection=${ap_alias}
    ...
    ...     *Returns*     alias for ssh connection to Common Unit
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}   ${alias}=ssh-ap-${ue_id}-${ue_comu_id}   ${force}=${False}
    ssh.Connect To   hostname=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.addr}
    ...              username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...              password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...              alias=${alias}
    Run Keyword If   ${force}   ssh.Force Reconnect    ${alias}
    [Return]   ${alias}

CB008124 Update AP SWConfig
    [Documentation]
    ...    This KW connects to the ``comu_id`` of the Airphone given by ``ue_id`` and
    ...    sets the RND params given by ``param_list`` in the swconfig.txt.
    ...    The `param_list` is a list of key:value pairs, e.g. ["0x4600BA=6", "0x460002=6"].
    ...
    ...    | param_list | list the update content   |
    ...    | ue_id      | Id of ue                  |
    ...    | ue_comu_id | Id of Common Unit         |
    ...
    [Arguments]   ${param_list}   ${ue_id}=${0}   ${ue_comu_id}=${0}
    ${ap_alias}   CB008124 Connect To AP   ue_id=${ue_id}   ue_comu_id=${ue_comu_id}
    swconf.download_swConfig_file_from_asik_to_test_pc   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${ap_alias}
    swconf.modify_swConfig_file   parametersList=${param_list}   filePath=/tmp/swconfig_tmp.txt
    swconf.upload_swConfig_file_to_asik_and_crasign   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${ap_alias}

CB008124 Add RD Parameter in AP SWCconfig
    [Documentation]    Additional AP RD flags
    @{ap_params}=  create list  0x706A0=8   # Used internal by Airphone L2LO module to schedule ul data
    CB008124 Update AP SWConfig    param_list=${ap_params}

####################  Setup/Teardown KWs  ####################
CB008124 Test Setup
    [Documentation]             Perform needed actions at the begining of a test case
    Init Trace color

CB008124 Test Teardown
    [Documentation]             Perform needed actions at the end of a test case
    Restore Files               listFileDesc=${FD_ALL}
    # "Test Teardown" KW from Setup.robot
    Test Teardown

CB008124 Test Teardown_V2
    [Documentation]             Perform needed actions at the end of a test case
    Restore Files               listFileDesc=${FD_ALL}
    # "Test Teardown" KW from Setup.robot
    Test Teardown_V2

Init Trace color
    ${trcColor}                 Evaluate    "${CYAN}"
    ${defColor}                 Evaluate    "${NORMAL}"
    ${OkColor}                  Evaluate    "${GREEN}"
    Set Suite Variable          ${trcColor}
    Set Suite Variable          ${defColor}
    Set Suite Variable          ${OkColor}
