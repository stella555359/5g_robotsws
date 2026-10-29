*** Settings ***
Documentation   This is a keyword file for CB013511, part commissioning - parameter
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library   String
Library   XML


*** Variables ***

${measurement_period_in_min}    5min


*** Keywords ***

Add And Update Parameters For Common_A_SE_TC02_TC03
    [Documentation]    [PRIVATE]    Add And Update Parameters For Common_A_SE_TC02_TC03
    ...       :Author: Sylvia Schneider
    Add Parameters cfgUECategoryFR1 And cfgUECategoryFR2 To NRPMQAP Objects
    Add Parameters ulSCellAddDeltaSsbRsrp To NRHOIF Objects
    Add Parameters ulSCellConfigLevel And ulSCellConfigLevelNum To NRCELL Objects
    Add NRBTS Parameters

    Update Parameter cellDepType
    Update Parameter maxNumScellsDlFr1 For NRCELL-1
    Update List a2MeasReleaseSsbRsrp For NRCELL-6
    Update Parameter actK1Opt For NRCELL-1
    Update Parameter sCellDeactivationTimerGNB
    Update Parameter a2ThresholdSCellRelSsbRsrp
    Update Counter Period
    Update NRBTS Parameters


Add And Update Parameters For Common_A_SE_TC05
    [Documentation]    [PRIVATE]    Add And Update Parameters For Common_A_SE_TC05
    ...       :Author: Sylvia Schneider
    Update NRBTS Parameters TC05
    Add NRBTS Parameters
    Update Parameter sCellDeactivationTimerGNB
    Add Parameters ulSCellConfigLevel And ulSCellConfigLevelNum To NRCELL Objects
    Update Parameters dlSCellConfigLevel And dlSCellConfigLevelNum For NRCELL-1
    Update Parameter actK1Opt For NRCELL-1
    Update Parameter maxNumScellsDlFr1 For NRCELL-1
    Update Parameter cellDepType
    Add Parameters ulSCellAddDeltaSsbRsrp To NRHOIF Objects
    Update Parameter cellDepType For NRHOIF-1 And 2
    Update Parameter spid
    Update Parameters For Object NRMEASCFG_IF
    Add Parameter a2MeashoEnabledSA For Object NRMOPR_SA-1
    Update Parameter nrDefMoPrNsaDN FOR NRCELL-1 And NRCELL-10
    Update Parameter NRCELL-2
    Update Parameter NRCELL-3
    Update And Add Parameters For NRMOPR_NSA
    Update NRHOIR Parameter b1ThresholdTputIratHoRsrq


Add And Update Parameters For Common_A_SE_TC04
    [Documentation]    [PRIVATE]    Add And Update Parameters For Common_A_SE_TC04
    ...       :Author: Sylvia Schneider
    Update NRBTS Parameters TC04
    Update Parameter actK1Opt For NRCELL-1
    Update Parameters dlSCellConfigLevel And dlSCellConfigLevelNum For NRCELL-1
    Update Parameter maxNumScellsDlFr1 For NRCELL-1
    Update Parameter sCellDeactivationTimerGNB
    Update Parameter a2ThresholdSCellRelSsbRsrp
    Update Parameter cellDepType
    Update Parameter NRCELL-6
    Update NRHOIR Parameter b1ThresholdTputIratHoRsrq


Update Parameter NRCELL-2
    [Documentation]    [PRIVATE]    Update Parameter NRCELL-2
    ...       :Author: Sylvia Schneider
    ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-2"]
    XML.Set Element Text  ${scf_xml}   text=4    xpath=.//${xpath}/p[@name="sCellBadChannelQualityThreshold"]
    XML.Set Element Text  ${scf_xml}   text=14   xpath=.//${xpath}/p[@name="sCellGoodChannelQualityThreshold"]


Update Parameter NRCELL-6
    [Documentation]    [PRIVATE]    Update Parameter NRCELL-6
    ...       :Author: Sylvia Schneider
    ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-6"]
    FOR   ${value}    ${list}                        ${param}    IN
    ...   68          a1MeasPCellSwitchSsbRsrp       a1ThresholdPCellSwitchSsbRsrp
    ...   41          a1MeasSCellAddSsbRsrp          a1ThresholdSCellAddSsbRsrpFDD
    ...   41          a1MeasSCellAddSsbRsrp          a1ThresholdSCellAddSsbRsrpTDD
    ...   256ms       a1MeasSCellAddSsbRsrp          a1TimeToTriggerSCellAddSsbRsrp
    ...   50          a1MeashoSsbRsrp                a1ThresholdhoSsbRsrp
    ...   38          a1MeashoSsbRsrq                a1ThresholdhoSsbRsrq
    ...   45          a2MeasRedirectSsbRsrp         a2ThresholdRedirectSsbRsrp
    ...   ms512       a2MeasRedirectSsbRsrp         a2TimeToTriggerRedirectSsbRsrp
    ...   42          a2MeasReleaseSsbRsrp          a2ThresholdReleaseSsbRsrp
    ...   ms512       a2MeasReleaseSsbRsrp          a2TimeToTriggerReleaseSsbRsrp
    ...   62          a2MeasSCellRelSsbRsrp         a2ThresholdSCellRelSsbRsrp
    ...   50          a2MeashoSsbRsrp               a2ThresholdhoSsbRsrp
    ...   10          a3MeasSsbRsrp                 a3OffsetSsbRsrp
    ...   ms512       a3MeasSsbRsrp                 a3TimeToTriggerSsbRsrp
      Log To Console    set param ${param} in list ${list} to value ${value}
      XML.Set Element Text  ${scf_xml}   text=${value}    xpath=.//${xpath}/list[@name="${list}"]/item/p[@name="${param}"]
    END


Update And Add Parameters For NRMOPR_NSA
    [Documentation]    [PRIVATE]    Update And Add Parameters For NRMOPR_NSA
    ...       :Author: Sylvia Schneider
    Log To Console    set param a1MeashoEnabled for object NRMOPR_NSA-1 to value rsrp
    XML.Set Element Text  ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_NSA-1"]/p[@name="a1MeashoEnabled"]
    Log To Console    set param a2MeashoEnabled for object NRMOPR_NSA-1 to value rsrp
    XML.Set Element Text  ${scf_xml}   text=rsrp   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_NSA-1"]/p[@name="a2MeashoEnabled"]
    Log To Console    add "<p name="a2MeashoEnabledSA">none</p>" to object NRMOPR_SA-2
    XML.Add Element   ${scf_xml}  <p name="a2MeashoEnabledSA">none</p>   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-2"]


Update Parameters For Object NRMEASCFG_IF
    [Documentation]    [PRIVATE]    Update Parameters For Object NRMEASCFG_IF
    ...       :Author: Sylvia Schneider
    FOR   ${param}               ${value}   ${object_id}   IN
    ...   a3MeasEnabled          rsrp       1
    ...   a5MeasEnabled          rsrp       1
    ...   ssbFrequency           521310     1
    ...   freqBandIndicatorNR    41         2
    ...   ssbFrequency           509790     2
      Log To Console    set param ${param} for NRMEASCFG_IF-${object_id} to value ${value}
      ${xpath}   Set Variable   managedObject[@distName="${bts_distName}/NRMEASCFG_IF-${object_id}"]
      XML.Set Element Text  ${scf_xml}   text=${value}   xpath=.//${xpath}/p[@name="${param}"]
    END


Add Parameter a2MeashoEnabledSA For Object NRMOPR_SA-1
    [Documentation]    [PRIVATE]    Add Parameter a2MeashoEnabledSA For Object NRMOPR_SA-1
    ...       :Author: Sylvia Schneider
    ${param}   Set Variable   <p name="a2MeashoEnabledSA">none</p>
    Log To Console    add param ${param} to NRMOPR_SA-1
    XML.Add Element    ${scf_xml}   ${param}    xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]


Add Parameters cfgUECategoryFR1 And cfgUECategoryFR2 to NRPMQAP Objects
    [Documentation]    [PRIVATE]    Add Parameters cfgUECategoryFR1 And cfgUECategoryFR2 to NRPMQAP Objects
    ...       :Author: Sylvia Schneider
    Log To Console   parameters cfgUECategoryFR1 and cfgUECategoryFR2: add value "All UEs" to all NRPMRNL-1/NRPMQAP objects
    ${cfgUECategoryFR1}   Set Variable   <p name="cfgUECategoryFR1">All UEs</p>
    ${cfgUECategoryFR2}   Set Variable   <p name="cfgUECategoryFR2">All UEs</p>
    FOR   ${id}   IN RANGE  1   20
       XML.Add Element       ${scf_xml}     ${cfgUECategoryFR1}   xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1/NRPMQAP-${id}"]
       XML.Add Element       ${scf_xml}     ${cfgUECategoryFR2}   xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1/NRPMQAP-${id}"]
    END


Get All NRHOIF Instances
    [Documentation]    [PRIVATE]    Get All NRHOIF Instances
    ...       :Author: Sylvia Schneider
    ${file}   Get File   ${resultBaseDir}/SCFC_start.xml
    ${list_nrhoif}     String.Get Regexp Matches   ${file}   ${bts_distName}\/NRCELL-[0-9]*\/NRHOIF-[0-9]*
    RETURN    ${list_nrhoif}


Add Parameters ulSCellAddDeltaSsbRsrp to NRHOIF Objects
    [Documentation]    [PRIVATE]    Add Parameters ulSCellAddDeltaSsbRsrp to NRHOIF Objects
    ...       :Author: Sylvia Schneider
    Log To Console   parameter ulSCellAddDeltaSsbRsrp: add value "0" to all NRHOIF objects
    ${ulSCellAddDeltaSsbRsrp}   Set Variable   <p name="ulSCellAddDeltaSsbRsrp">0</p>
    ${list_nrhoif}   Get All NRHOIF Instances
    FOR  ${dist}   IN   @{list_nrhoif}
       XML.Add Element       ${scf_xml}     ${ulSCellAddDeltaSsbRsrp}   xpath=.//managedObject[@distName="${dist}"]
    END


Add Parameters ulSCellConfigLevel And ulSCellConfigLevelNum to NRCELL Objects
    [Documentation]    [PRIVATE]    Add Parameters ulSCellConfigLevel And ulSCellConfigLevelNum to NRCELL Objects
    ...       :Author: Sylvia Schneider
    Log To Console   add parameters ulSCellConfigLevel (value 10) and ulSCellConfigLevelNum (value 3) to all NRCELL objects
    ${ulSCellConfigLevel}      Set Variable   <p name="ulSCellConfigLevel">10</p>
    ${ulSCellConfigLevelNum}   Set Variable   <p name="ulSCellConfigLevelNum">3</p>
    FOR   ${id}   IN RANGE  1   19
        XML.Add Element       ${scf_xml}     ${ulSCellConfigLevel}      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]
        XML.Add Element       ${scf_xml}     ${ulSCellConfigLevelNum}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]
    END


Update Parameters dlSCellConfigLevel And dlSCellConfigLevelNum For NRCELL-1
    [Documentation]    [PRIVATE]    Update Parameters dlSCellConfigLevel And dlSCellConfigLevelNum For NRCELL-1
    ...       :Author: Sylvia Schneider
    Log To Console   set parameters dlSCellConfigLevel (value 10) and dlSCellConfigLevelNum (value 3) for NRCELL-1
    ${xpath}   Set Variable  managedObject[@distName="${bts_distName}/NRCELL-1"]
    XML.Set Element Text  ${scf_xml}   text=10    xpath=.//${xpath}/p[@name="dlSCellConfigLevel"]
    XML.Set Element Text  ${scf_xml}   text=3     xpath=.//${xpath}/p[@name="dlSCellConfigLevelNum"]


Update Parameter cellDepType
    [Documentation]    [PRIVATE]    Update Parameter cellDepType
    ...       :Author: Sylvia Schneider
    FOR   ${cellId}   IN   10  11  13  14
       Log To Console    set NRCELL-${cellId} param cellDepType to SA+NSA
       XML.Set Element Text  ${scf_xml}   text=SA+NSA   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cellId}"]/p[@name="cellDepType"]
    END


Update Parameter maxNumScellsDlFr1 For NRCELL-1
    [Documentation]    [PRIVATE]    Update Parameter maxNumScellsDlFr1 For NRCELL-1
    ...       :Author: Sylvia Schneider
    Log To Console    set NRCELL-1 param maxNumScellsDlFr1 to 5
    XML.Set Element Text  ${scf_xml}   text=5   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="maxNumScellsDlFr1"]


Update Parameter actK1Opt For NRCELL-1
    [Documentation]    [PRIVATE]    Update Parameter actK1Opt For NRCELL-1
    ...       :Author: Sylvia Schneider
    Log To Console    set NRCELL-1 param actK1Opt to intraAndInter-gNB
    XML.Set Element Text  ${scf_xml}
    ...   text=intraAndInter-gNB   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="actK1Opt"]


Update List a2MeasReleaseSsbRsrp For NRCELL-6
    [Documentation]    [PRIVATE]    Update List a2MeasReleaseSsbRsrp For NRCELL-6
    ...       :Author: Sylvia Schneider

    ${xpath}   Set Variable   managedObject[@distName="${bts_distName}/NRCELL-6"]/list[@name="a2MeasReleaseSsbRsrp"]/item
    Log To Console    set NRCELL-6 list a2MeasReleaseSsbRsrp param a2ThresholdReleaseSsbRsrp to 42
    XML.Set Element Text  ${scf_xml}   text=42     xpath=.//${xpath}/p[@name="a2ThresholdReleaseSsbRsrp"]
    Log To Console    set NRCELL-6 list a2MeasReleaseSsbRsrp param a2TimeToTriggerReleaseSsbRsrp to ms512
    XML.Set Element Text  ${scf_xml}   text=ms512   xpath=.//${xpath}/p[@name="a2TimeToTriggerReleaseSsbRsrp"]


Update Parameter sCellDeactivationTimerGNB
    [Documentation]    [PRIVATE]    Update Parameter sCellDeactivationTimerGNB
    ...       :Author: Sylvia Schneider
    Log To Console    set all NRCELL params sCellDeactivationTimerGNB to infinity
    FOR   ${id}   IN RANGE  1   19
       XML.Set Element Text  ${scf_xml}   text=infinity
       ...   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]/p[@name="sCellDeactivationTimerGNB"]
    END


Update Parameter nrDefMoPrNsaDN FOR NRCELL-1 And NRCELL-10
    [Documentation]    [PRIVATE]    Update Parameter nrDefMoPrNsaDN FOR NRCELL-1 And NRCELL-10
    ...       :Author: Sylvia Schneider
    Log To Console    set NRCELL-1 param nrDefMoPrNsaDN to ${bts_distName}/NRMOPR_NSA-1
    XML.Set Element Text  ${scf_xml}
    ...   text=${bts_distName}/NRMOPR_NSA-1  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="nrDefMoPrNsaDN"]

    FOR   ${id}  IN RANGE  2   19
        Log To Console    set NRCELL-${id} param nrDefMoPrNsaDN to ${bts_distName}/NRMOPR_NSA-3
        XML.Set Element Text  ${scf_xml}
        ...   text=${bts_distName}/NRMOPR_NSA-3  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]/p[@name="nrDefMoPrNsaDN"]
    END


Update Parameter a2ThresholdSCellRelSsbRsrp
    [Documentation]    [PRIVATE]    Update Parameter a2ThresholdSCellRelSsbRsrp
    ...       :Author: Sylvia Schneider
    ${path_list}   Set Variable   list[@name="a2MeasSCellRelSsbRsrp"]/item/p[@name="a2ThresholdSCellRelSsbRsrp"]
    FOR   ${nrcell_id}     ${value}   IN
    ...   1                60
    ...   15               62
       Log To Console    set param a2ThresholdSCellRelSsbRsrp for NRCELL-${nrcell_id} in list a2MeasSCellRelSsbRsrp to value ${value}
       XML.Set Element Text  ${scf_xml}   text=${value}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]/${path_list}
    END


Update Parameter cellDepType For NRHOIF-1 And 2
    [Documentation]    [PRIVATE]    Update Parameter cellDepType for NRHOIF-1 And 2
    ...       :Author: Sylvia Schneider
    Log To Console    set param cellDepType to value SA+NSA for NRCELL-1/NRHOIF-1 and NRCELL-1/NRHOIF-2
    XML.Set Element Text  ${scf_xml}   text=SA+NSA   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]/p[@name="cellDepType"]
    XML.Set Element Text  ${scf_xml}   text=SA+NSA   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-2"]/p[@name="cellDepType"]


Update Parameter spid
    [Documentation]    [PRIVATE]    Update Parameter spid
    ...       :Author: Sylvia Schneider
    Log To Console    set param spid to value 99
    XML.Set Element Text  ${scf_xml}   text=99   xpath=.//managedObject[@distName="${bts_distName}/NRSPID_PROFILE-1"]/p[@name="spid"]


Update Parameter NRCELL-3
    [Documentation]    [PRIVATE]    Update Parameter NRCELL-3
    ...       :Author: Sylvia Schneider
    FOR   ${list}                    ${param}                         ${value}   IN
    ...   a1MeasSCellAddSsbRsrp      a1ThresholdSCellAddSsbRsrpFDD    39
    ...   a1MeasSCellAddSsbRsrp      a1ThresholdSCellAddSsbRsrpTDD    39
    ...   a1MeasSCellAddSsbRsrp      a1TimeToTriggerSCellAddSsbRsrp   256ms
    ...   a2MeasRedirectSsbRsrp      a2ThresholdRedirectSsbRsrp       45
    ...   a2MeasRedirectSsbRsrp      a2TimeToTriggerRedirectSsbRsrp   ms256
    ...   a2MeasReleaseSsbRsrp       a2ThresholdReleaseSsbRsrp        42
    ...   a2MeasReleaseSsbRsrp       a2TimeToTriggerReleaseSsbRsrp    ms512
    ...   a2MeasSCellRelSsbRsrp      a2ThresholdSCellRelSsbRsrp       2
    ...   a2MeasSCellRelSsbRsrp      a2TimeToTriggerSCellRelSsbRsrp   256ms
    ...   a2MeashoSsbRsrp            a2ThresholdhoSsbRsrp             47
    ...   a2MeashoSsbRsrp            a2TimeToTriggerhoSsbRsrp         ms256
    ...   a3MeasSsbRsrp              a3OffsetSsbRsrp                  9
    ...   a3MeasSsbRsrp              a3TimeToTriggerSsbRsrp           ms512
    ...   a5MeasSsbRsrp              a5Threshold1SsbRsrp              67
    ...   a5MeasSsbRsrp              a5Threshold2SsbRsrp              62
    ...   a5MeasSsbRsrp              a5TimeToTriggerSsbRsrp           ms256
       Log To Console    NRCELL-3 list ${list} set param ${param} to value ${value}
       XML.Set Element Text  ${scf_xml}   text=${value}
       ...   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]/list[@name="${list}"]/item/p[@name="${param}"]
    END


Get All NRHOIR Instances
    [Documentation]    [PRIVATE]    Get All NRHOIR Instances
    ...       :Author: Sylvia Schneider
    XML.Save XML    ${scf_xml}    ${resultBaseDir}/CB013511_temp.xml
    ${file}   Get File   ${resultBaseDir}/CB013511_temp.xml
    ${list_nrhoir}     String.Get Regexp Matches   ${file}   distName="${bts_distName}\/NRHOIR-[0-9]*
    RETURN    ${list_nrhoir}


Update NRHOIR Parameter b1ThresholdTputIratHoRsrq
    [Documentation]    [PRIVATE]    Update NRHOIR Parameter b1ThresholdTputIratHoRsrq
    ...       :Author: Sylvia Schneider
    ${list_nrhoir}   Get All NRHOIR Instances
    FOR  ${dist_nrhoir}   IN   @{list_nrhoir}
       Log To Console    update b1MeasTputIratHoRsrq with value 18 of ${dist_nrhoir}
       XML.Set Element Text  ${scf_xml}   text=18
       ...   xpath=.//managedObject[@${dist_nrhoir}"]/list[@name="b1MeasTputIratHoRsrq"]/item/p[@name="b1ThresholdTputIratHoRsrq"]
    END


Update Counter Period
    [Documentation]    [PRIVATE]    Update Counter Period
    ...       :Author: Sylvia Schneider
    Log To Console     for counter verification set actCarAgPmCount to true
    XML.Set Element Text   ${scf_xml}    text=true    xpath=.//p[@name="actCarAgPmCount"]
    FOR   ${param}   IN
    ...   reportingIntervalPm
    ...   miNrMeasProfileInterFreq
    ...   miNrMeasProfileInterRat
    ...   miNrMeasProfileIntraFreq
    ...   miNrMeasProfileMappingNSA
    ...   miNrMeasProfileSCell
    ...   miNrCaCu
    ...   miNrCaDu
       Log To Console     for counter verification set ${param} to ${measurement_period_in_min}
       XML.Set Element Text   ${scf_xml}    text=${measurement_period_in_min}    xpath=.//p[@name="${param}"]
    END


Update NRBTS Parameters
    [Documentation]    [PRIVATE]    Update NRBTS Parameters
    ...       :Author: Sylvia Schneider
    FOR   ${param}                       ${value}   IN
    ...   actCAMeasInMeasProf            SA+NSA
    ...   actFlexSCellSelectFr1          true
    ...   actMeasProfileCa               SA+NSA
    ...   actMeasurementProfile          SA+NSA
    ...   maxNumScellsDl                 5
    ...   sCellDeactivationBadRlqCount   5
    ...   sCellExcludelistTimerFr1       60
       Log To Console    set in NRBTS single parameter "${param}" to value "${value}"
       XML.Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="${param}"]
    END


Update NRBTS Parameters TC05
    [Documentation]    [PRIVATE]    Update NRBTS Parameters TC05
    ...       :Author: Sylvia Schneider
    FOR   ${param}                       ${value}   IN
    ...   actCAMeasInMeasProf            NSA
    ...   actFlexSCellSelectFr1          true
    ...   actMeasProfileCa               NSA
    ...   actMeasurementProfile          NSA
    ...   maxNumScellsDl                 5
    ...   sCellDeactivationBadRlqCount   5
    ...   sCellExcludelistTimerFr1       60
    ...   actBufferBasedSCellAddition    oneShot_stepWise_Dl_Fr1
    ...   actCarrierAggregation          true
    ...   actMobilityProfile             true
    ...   actSPID                        true
    ...   caConfigurationSupport         2CCDL_2CCUL
    ...   sCellActivationMethod          blind
       Log To Console    set in NRBTS single parameter "${param}" to value "${value}"
       XML.Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="${param}"]
    END


Update NRBTS Parameters TC04
    [Documentation]    [PRIVATE]    Update NRBTS Parameters TC04
    ...       :Author: Sylvia Schneider
    FOR   ${param}                       ${value}   IN
    ...   actCAMeasInMeasProf            SA+NSA
    ...   actFlexSCellSelectFr1          true
    ...   actMeasProfileCa               SA+NSA
    ...   actMeasurementProfile          SA+NSA
    ...   maxNumScellsDl                 5
    ...   sCellDeactivationBadRlqCount   5
    ...   sCellExcludelistTimerFr1       60
       Log To Console    set in NRBTS single parameter "${param}" to value "${value}"
       XML.Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="${param}"]
    END


Add NRBTS Parameters
    [Documentation]    [PRIVATE]    Add NRBTS Parameters
    ...       :Author: Sylvia Schneider
    ${nrDcMode}   Set Variable  <p name="nrDcMode">all UEs</p>
    ${bulkSCellReleaseDelay}   Set Variable  <p name="bulkSCellReleaseDelay">10</p>
    FOR    ${param}   IN
    ...   nrDcMode
    ...   bulkSCellReleaseDelay
        Log To Console    add NRBTS parameter "${${param}}"
        XML.Add Element       ${scf_xml}     ${${param}}   xpath=.//managedObject[@distName="${bts_distName}"]
    END
