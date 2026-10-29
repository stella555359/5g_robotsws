*** Settings ***
Documentation   Generic Commissioning: 5GC000706 for CCRT
...             independent testline
...             5GC002481-CIAB-SyVe Test Only for 5GC000706 Inter-frequency handover via Xn (SA option 2)
...             Team: 'MN 5G&SC 5G Pz ULM 2 SqdGp63'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com'

Library         taf.sbts.oam.coam.admin            WITH NAME      admin

Resource        ../../resources/syve_commissioning.robot

*** Keywords ***
Create Delta Commission Json For 706_gnb0
    [Arguments]    ${nrbts_id}  ${gnb_id}
    admin.Create_Delta
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}    drbInactivityTimerSA   10
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}    sgnbRelForNoHandoverEnabled   true
    admin.Append_Complex_Item_To_Delta
    ...    MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...    cipherPrefL
    ...    nea0=1
    ...    nea2_128=0
    ...    nea1_128=0
    ...    nea3_128=0
    ${nrcell_id}=   Set Variable  1
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    measGapSelection   balancedChoice
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    measGapSelectionSA   balancedChoice
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    reportInterval   ms1024
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    rsrpThresholdSSB   11
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    dlDMRSAdditionalPosition   One additional DMRS
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    dlMimoMode   4x4 or 4x2 Open Loop Spatial Multiplexing
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrp
    ...    a1HysteresishoSsbRsrp=2
    ...    a1ThresholdhoSsbRsrp=39
    ...    a1TimeToTriggerhoSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrpSA
    ...    a1HysteresishoSsbRsrpSA=0
    ...    a1ThresholdhoSsbRsrpSA=80
    ...    a1TimeToTriggerhoSsbRsrpSA=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrq
    ...    a1HysteresishoSsbRsrq=0
    ...    a1ThresholdhoSsbRsrq=63
    ...    a1TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrp
    ...    a2HysteresisRedirectSsbRsrp=0
    ...    a2ThresholdRedirectSsbRsrp=34
    ...    a2TimeToTriggerRedirectSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrq
    ...    a2HysteresisRedirectSsbRsrq=0
    ...    a2ThresholdRedirectSsbRsrq=49
    ...    a2TimeToTriggerRedirectSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasReleaseSsbRsrp
    ...    a2HysteresisReleaseSsbRsrp=0
    ...    a2ThresholdReleaseSsbRsrp=47
    ...    a2TimeToTriggerReleaseSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrp
    ...    a2HysteresishoSsbRsrp=0
    ...    a2ThresholdhoSsbRsrp=34
    ...    a2TimeToTriggerhoSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrpSA
    ...    a2HysteresishoSsbRsrpSA=0
    ...    a2ThresholdhoSsbRsrpSA=77
    ...    a2TimeToTriggerhoSsbRsrpSA=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrq
    ...    a2HysteresishoSsbRsrq=0
    ...    a2ThresholdhoSsbRsrq=49
    ...    a2TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=3
    ...    a3TimeToTriggerSsbRsrp=ms128
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=1
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms256
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=3
    ...    a3TimeToTriggerSsbRsrp=ms128
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=1
    ...    a5Threshold1SsbRsrp=61
    ...    a5Threshold2SsbRsrp=71
    ...    a5TimeToTriggerSsbRsrp=ms256
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=1
    ...    a3OffsetSsbRsrp=3
    ...    a3TimeToTriggerSsbRsrp=ms128
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=1
    ...    a5Threshold1SsbRsrp=61
    ...    a5Threshold2SsbRsrp=71
    ...    a5TimeToTriggerSsbRsrp=ms256

    FOR  ${nrcell_id}   IN  2  3
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    measGapSelection   balancedChoice
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    measGapSelectionSA   balancedChoice
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    reportInterval   ms1024
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    rsrpThresholdSSB   11
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    dlDMRSAdditionalPosition   One additional DMRS
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    dlMimoMode   4x4 or 4x2 Open Loop Spatial Multiplexing
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a1MeashoSsbRsrp
        ...    a1HysteresishoSsbRsrp=2
        ...    a1ThresholdhoSsbRsrp=39
        ...    a1TimeToTriggerhoSsbRsrp=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a1MeashoSsbRsrpSA
        ...    a1HysteresishoSsbRsrpSA=0
        ...    a1ThresholdhoSsbRsrpSA=80
        ...    a1TimeToTriggerhoSsbRsrpSA=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a1MeashoSsbRsrq
        ...    a1HysteresishoSsbRsrq=0
        ...    a1ThresholdhoSsbRsrq=63
        ...    a1TimeToTriggerhoSsbRsrq=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a2MeasRedirectSsbRsrp
        ...    a2HysteresisRedirectSsbRsrp=0
        ...    a2ThresholdRedirectSsbRsrp=34
        ...    a2TimeToTriggerRedirectSsbRsrp=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a2MeasRedirectSsbRsrq
        ...    a2HysteresisRedirectSsbRsrq=0
        ...    a2ThresholdRedirectSsbRsrq=49
        ...    a2TimeToTriggerRedirectSsbRsrq=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a2MeasReleaseSsbRsrp
        ...    a2HysteresisReleaseSsbRsrp=0
        ...    a2ThresholdReleaseSsbRsrp=47
        ...    a2TimeToTriggerReleaseSsbRsrp=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a2MeashoSsbRsrp
        ...    a2HysteresishoSsbRsrp=0
        ...    a2ThresholdhoSsbRsrp=34
        ...    a2TimeToTriggerhoSsbRsrp=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a2MeashoSsbRsrpSA
        ...    a2HysteresishoSsbRsrpSA=0
        ...    a2ThresholdhoSsbRsrpSA=77
        ...    a2TimeToTriggerhoSsbRsrpSA=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a2MeashoSsbRsrq
        ...    a2HysteresishoSsbRsrq=0
        ...    a2ThresholdhoSsbRsrq=49
        ...    a2TimeToTriggerhoSsbRsrq=ms480
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a3MeasSsbRsrp
        ...    a3HysteresisSsbRsrp=0
        ...    a3OffsetSsbRsrp=3
        ...    a3TimeToTriggerSsbRsrp=ms128
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...    a5MeasSsbRsrp
        ...    a5HysteresisSsbRsrp=1
        ...    a5Threshold1SsbRsrp=77
        ...    a5Threshold2SsbRsrp=79
        ...    a5TimeToTriggerSsbRsrp=ms256
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
        ...    a3MeasSsbRsrp
        ...    a3HysteresisSsbRsrp=0
        ...    a3OffsetSsbRsrp=3
        ...    a3TimeToTriggerSsbRsrp=ms128
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
        ...    a5MeasSsbRsrp
        ...    a5HysteresisSsbRsrp=1
        ...    a5Threshold1SsbRsrp=61
        ...    a5Threshold2SsbRsrp=71
        ...    a5TimeToTriggerSsbRsrp=ms256
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
        ...    a3MeasSsbRsrp
        ...    a3HysteresisSsbRsrp=0
        ...    a3OffsetSsbRsrp=3
        ...    a3TimeToTriggerSsbRsrp=ms128
        admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
        ...    a5MeasSsbRsrp
        ...    a5HysteresisSsbRsrp=1
        ...    a5Threshold1SsbRsrp=61
        ...    a5Threshold2SsbRsrp=71
        ...    a5TimeToTriggerSsbRsrp=ms256
    END

    admin.save_delta   target_file_name=${configSuiteDir}/delta706_gNB${gnb_id}.json
    ${delta}    admin.Get_Delta
    syve_commissioning.Execute commissioning of delta Json file    delta=${delta}  gnb_id=${gnb_id}

Create Delta Commission Json For 706_gnb1
    [Arguments]    ${nrbts_id}  ${gnb_id}
    admin.Create_Delta
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}    drbInactivityTimerSA   10
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}    sgnbRelForNoHandoverEnabled   true
    admin.Append_Complex_Item_To_Delta
    ...    MRBTS-${nrbts_id}/NRBTS-${nrbts_id}
    ...    cipherPrefL
    ...    nea0=1
    ...    nea2_128=0
    ...    nea1_128=0
    ...    nea3_128=0
    ${nrcell_id}=   Set Variable  1
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    a2MeasReleaseEnabled   none
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    rsrpThresholdSSB   11
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    voiceFBMode   redirection
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    reportInterval   ms120
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrp
    ...    a1HysteresishoSsbRsrp=0
    ...    a1ThresholdhoSsbRsrp=80
    ...    a1TimeToTriggerhoSsbRsrp=ms80
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrpSA
    ...    a1HysteresishoSsbRsrpSA=0
    ...    a1ThresholdhoSsbRsrpSA=80
    ...    a1TimeToTriggerhoSsbRsrpSA=ms64
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrq
    ...    a1HysteresishoSsbRsrq=0
    ...    a1ThresholdhoSsbRsrq=63
    ...    a1TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrp
    ...    a2HysteresisRedirectSsbRsrp=0
    ...    a2ThresholdRedirectSsbRsrp=34
    ...    a2TimeToTriggerRedirectSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrq
    ...    a2HysteresisRedirectSsbRsrq=0
    ...    a2ThresholdRedirectSsbRsrq=49
    ...    a2TimeToTriggerRedirectSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasReleaseSsbRsrp
    ...    a2HysteresisReleaseSsbRsrp=0
    ...    a2ThresholdReleaseSsbRsrp=47
    ...    a2TimeToTriggerReleaseSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrp
    ...    a2HysteresishoSsbRsrp=0
    ...    a2ThresholdhoSsbRsrp=65
    ...    a2TimeToTriggerhoSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrpSA
    ...    a2HysteresishoSsbRsrpSA=0
    ...    a2ThresholdhoSsbRsrpSA=77
    ...    a2TimeToTriggerhoSsbRsrpSA=ms160
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrq
    ...    a2HysteresishoSsbRsrq=0
    ...    a2ThresholdhoSsbRsrq=31
    ...    a2TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=3
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=60
    ...    a5Threshold2SsbRsrp=70
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=5
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=5
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512

    ${nrcell_id}=   Set Variable  2
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    a2MeasReleaseEnabled   none
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    rsrpThresholdSSB   11
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    voiceFBMode   redirection
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    reportInterval   ms120
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrp
    ...    a1HysteresishoSsbRsrp=0
    ...    a1ThresholdhoSsbRsrp=80
    ...    a1TimeToTriggerhoSsbRsrp=ms80
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrpSA
    ...    a1HysteresishoSsbRsrpSA=0
    ...    a1ThresholdhoSsbRsrpSA=80
    ...    a1TimeToTriggerhoSsbRsrpSA=ms80
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrq
    ...    a1HysteresishoSsbRsrq=0
    ...    a1ThresholdhoSsbRsrq=63
    ...    a1TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrp
    ...    a2HysteresisRedirectSsbRsrp=0
    ...    a2ThresholdRedirectSsbRsrp=34
    ...    a2TimeToTriggerRedirectSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrq
    ...    a2HysteresisRedirectSsbRsrq=0
    ...    a2ThresholdRedirectSsbRsrq=49
    ...    a2TimeToTriggerRedirectSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasReleaseSsbRsrp
    ...    a2HysteresisReleaseSsbRsrp=0
    ...    a2ThresholdReleaseSsbRsrp=47
    ...    a2TimeToTriggerReleaseSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrp
    ...    a2HysteresishoSsbRsrp=0
    ...    a2ThresholdhoSsbRsrp=66
    ...    a2TimeToTriggerhoSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrpSA
    ...    a2HysteresishoSsbRsrpSA=0
    ...    a2ThresholdhoSsbRsrpSA=77
    ...    a2TimeToTriggerhoSsbRsrpSA=ms160
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrq
    ...    a2HysteresishoSsbRsrq=0
    ...    a2ThresholdhoSsbRsrq=31
    ...    a2TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=3
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=61
    ...    a5Threshold2SsbRsrp=72
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=5
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=78
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=5
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512

    ${nrcell_id}=   Set Variable  3
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    a2MeasReleaseEnabled   none
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    rsrpThresholdSSB   11
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    voiceFBMode   redirection
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}    reportInterval   ms120
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrp
    ...    a1HysteresishoSsbRsrp=0
    ...    a1ThresholdhoSsbRsrp=80
    ...    a1TimeToTriggerhoSsbRsrp=ms80
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrpSA
    ...    a1HysteresishoSsbRsrpSA=0
    ...    a1ThresholdhoSsbRsrpSA=80
    ...    a1TimeToTriggerhoSsbRsrpSA=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a1MeashoSsbRsrq
    ...    a1HysteresishoSsbRsrq=0
    ...    a1ThresholdhoSsbRsrq=63
    ...    a1TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrp
    ...    a2HysteresisRedirectSsbRsrp=0
    ...    a2ThresholdRedirectSsbRsrp=34
    ...    a2TimeToTriggerRedirectSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasRedirectSsbRsrq
    ...    a2HysteresisRedirectSsbRsrq=0
    ...    a2ThresholdRedirectSsbRsrq=49
    ...    a2TimeToTriggerRedirectSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeasReleaseSsbRsrp
    ...    a2HysteresisReleaseSsbRsrp=0
    ...    a2ThresholdReleaseSsbRsrp=47
    ...    a2TimeToTriggerReleaseSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrp
    ...    a2HysteresishoSsbRsrp=0
    ...    a2ThresholdhoSsbRsrp=67
    ...    a2TimeToTriggerhoSsbRsrp=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrpSA
    ...    a2HysteresishoSsbRsrpSA=0
    ...    a2ThresholdhoSsbRsrpSA=77
    ...    a2TimeToTriggerhoSsbRsrpSA=ms160
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a2MeashoSsbRsrq
    ...    a2HysteresishoSsbRsrq=0
    ...    a2ThresholdhoSsbRsrq=31
    ...    a2TimeToTriggerhoSsbRsrq=ms480
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=3
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=60
    ...    a5Threshold2SsbRsrp=70
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=5
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0
    ...    a3OffsetSsbRsrp=5
    ...    a3TimeToTriggerSsbRsrp=ms100
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512


    admin.save_delta   target_file_name=${configSuiteDir}/delta706_gNB${gnb_id}.json
    ${delta}    admin.Get_Delta
    syve_commissioning.Execute commissioning of delta Json file    delta=${delta}   gnb_id=${gnb_id}

Create Delta Commission Json For 706-FD05
    [Arguments]    ${nrbts_id}  ${gnb_id}
    admin.Create_Delta
    ${nrcell_id}=   Set Variable  1
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=60
    ...    a5Threshold2SsbRsrp=70
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1   a3MeasEnabled   none
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2   a3MeasEnabled   none
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512

    ${nrcell_id}=   Set Variable  2
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=61
    ...    a5Threshold2SsbRsrp=72
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1   a3MeasEnabled   none
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=60
    ...    a5Threshold2SsbRsrp=70
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2   a3MeasEnabled   none
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512

    ${nrcell_id}=   Set Variable  3
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=60
    ...    a5Threshold2SsbRsrp=70
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1   a3MeasEnabled   none
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-1
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512
    admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2   a3MeasEnabled   none
    admin.Append_Complex_Item_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}/NRHOIF-2
    ...    a5MeasSsbRsrp
    ...    a5HysteresisSsbRsrp=0
    ...    a5Threshold1SsbRsrp=77
    ...    a5Threshold2SsbRsrp=79
    ...    a5TimeToTriggerSsbRsrp=ms512

    FOR  ${NRMEASCFG_IF}   IN  1  2  3
        admin.Append_Parameter_Update_To_Delta  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRMEASCFG_IF-${NRMEASCFG_IF}  a3MeasEnabled  none
    END

    admin.save_delta   target_file_name=${configSuiteDir}/delta706-FD05_gNB${gnb_id}.json
    ${delta}    admin.Get_Delta
    syve_commissioning.Execute commissioning of delta Json file    delta=${delta}  gnb_id=${gnb_id}
