*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     File containing keywords used by MultiBW NSA TDD test suites
...               Prerequisite :
...               Scope : keywords for MultiBW NSA TDD
...
...               Test Case Scenario author   : n/a
...               Creation Date               : n/a
...               Modified Date               : 2024-06-25
...               Version   Date      Author                             Notes
...               n/a       n/a       n/a                                Creation
...               n/a       FB2208    vincent.boulet@nokia.com           Update for supporting vRAN2.0 Cloud topology
...               n/a       FB2208    vincent.boulet@nokia.com           Fix error in Set Context_WTS CFG and update for some configurations
...               n/a       FB2210    marie-laurence.le_borgne@nokia.com Remove frequensiDensityThresNrb1 from file cause no more in classical NIDD
...                                                                      NIDD and not supported in AiC
...               n/a       FB2213     vincent.boulet@nokia.com          Update msg1FrequencyStart for VRAN2.0 and alignment of parameters for
...                                                                      NRCELL1 only
...               1.0       FB2304    vincent.boulet@nokia.com           Modification in case VRAN NIC due to new default commiss. on TL SA+NSA
...               1.1       FB2304    vincent.boulet@nokia.com           Correction syntax error with KW Run Keywords
...               1.2       FB2304    vincent.boulet@nokia.com           Introduction of VRAN NIC configuration into &{HF_90_a3ghz_n78_AEQE}
...               1.3       FB2305    richard.duthu@nokia.com            Some cleanup as VRAN2.0 no more exist
...               1.4       FB2322    yann.merlin@nokia.com              Supports of vRAN4.0 Update ue_nr_capabilities_2_isAic for Bw=60MHz
...               1.5       FB2324    laurent.puchelle@nokia.com         Supports of vRAN4.0 RINLINE2 cfg file and update for Bw=80MHz
...               1.6       FB2407    vincent.boulet@nokia.com           Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...                                                                      with configuration moved to RU AZQJ instead of AEQP
...               1.7       FB2408    vincent.boulet@nokia.com           Update HF_60_a3ghz_n78_AEQE parameters supported on Cloud RAN
...               1.8       FB2412    adrien.hervat@nokia.com            Fix attach issue : dedicatedcoreset value for 60,70,90MHz (PR774132)
...                                                                      and get TC SCF for Classical in logs
...               1.9       FB2413    vincent.boulet@nokia.com           Correction to restore the VDU commissioning in case of Cloud RAN topology
# --------------------------------------------------------------------------------------------------------------------------------------------------
Resource          ./TDD_MultiBW_Keywords.robot
Resource          ../../../../resources/SWENG/robot/Restart.robot
Variables         ../python/NrCapa.py


*** Variables ***
${iphy_file_path}           /ffs/run/simmode

&{HF_20_a3ghz_n78_AEQE}             freqBandIndicatorNR=78
...                                 chBw=20MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=12
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636534
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities20}
...                                 ue_nr_capabilities=${ue_nr_capabilities20}
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E46D00158800000000023003C8E08
...                                 dir=DL
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 Downlink_throughput=30
...                                 Uplink_throughput=8
#...                                 frequencyDensityThresNrb1=51
...                                 coresetDedicated_size=48
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcMR&ularfcn=636534&dlarfcn=636534&gscn=7880&type0coresetindex=12

&{HF_40_a3ghz_n78_AEQE}             freqBandIndicatorNR=78
...                                 chBw=40MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=12
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636666
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capa_ute}
...                                 ue_nr_capabilities=${ue_nr_capa_ute_NSA_nr}
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E4CD00158800000000023003C9A08
...                                 dir=DL
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 Downlink_throughput=60
...                                 Uplink_throughput=15
#...                                 frequencyDensityThresNrb1=106
...                                 coresetDedicated_size=96
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcYR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12

# ym #debugging vRAN4.0  5GC001075_TDD_NSA_60MHz
# adding temporary parameters tagged _isAic
&{HF_60_a3ghz_n78_AEQE}             freqBandIndicatorNR=78
...                                 chBw=60MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=10    #vbo#WA 5GC001075#
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636666
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities60}
...                                 ue_nr_capabilities=${ue_nr_capa_ute_NSA_nr}  # ym ${ue_nr_capabilities60} featureSetsDlPerCc_supportedBwDl
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E50D00158800000000023003CA208
...                                 dir=DL
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 Downlink_throughput=90
...                                 Uplink_throughput=25
#...                                frequencyDensityThresNrb1=162
...                                 coresetDedicated_size=162
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcgR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12



&{HF_80_a3ghz_n78_AEQE}             freqBandIndicatorNR=78
...                                 chBw=80MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=12
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636666
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capa_ute}
...                                 ue_nr_capabilities=${ue_nr_capa_ute_NSA_nr}
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E52D00158800000000023003CA608
...                                 dir=DL
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 Downlink_throughput=125
...                                 Uplink_throughput=30
#...                                 frequencyDensityThresNrb1=217
...                                 coresetDedicated_size=192
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcoR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12


&{HF_50_a3ghz_n78_AEQE}             freqBandIndicatorNR=78
...                                 chBw=50MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=12
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636666
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capa_ute}
...                                 ue_nr_capabilities=${ue_nr_capa_ute_NSA_nr}
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E4ED00158800000000023003C9E08
...                                 dir=DL_30min
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 Downlink_throughput=75
...                                 Uplink_throughput=20
#...                                 frequencyDensityThresNrb1=133
...                                 coresetDedicated_size=120
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php?code=EYQBesAAAAAEAAAAAAAAAAAA
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JccR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12

&{HF_70_a3ghz_n78_AEQE}             freqBandIndicatorNR=78
...                                 chBw=70 MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=12
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636666
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capa_ute}
...                                 ue_nr_capabilities=${ue_nr_capa_ute_NSA_nr}
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E52D00158800000000023003CA608  # 80MHz
...                                 dir=DL_30min
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 Downlink_throughput=110
...                                 Uplink_throughput=30
#...                                 frequencyDensityThresNrb1=189
...                                 coresetDedicated_size=186
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php?code=EYgBe8AAAAAEAAAAAAAAAAAA
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JckR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12


&{HF_90_a3ghz_n78_AEQE}
...                                 freqBandIndicatorNR=78
...                                 chBw=90MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 type0CoresetConfigurationIndex_isAic=12
...                                 actDl256Qam=false
...                                 dlQam256PowerBackoffSub6=15
...                                 dlQam256PowerBackoffSub6_isAic=1.5
...                                 dllaIniMcs=3
...                                 ullaIniMcs=1
...                                 nrarfcn=636666
...                                 scs=30 KHz
...                                 ssbScs=30 KHz
...                                 ulDlDataSlotRatio=3/7
...                                 frameStructureType_isAic=semiStatic
...                                 guardPeriodLength_isAic=2Symbols
...                                 ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities90}
...                                 ue_nr_capabilities=${ue_nr_capabilities90}
...                                 ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
...                                 ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E4ED00158800000000023003C9E08
...                                 dir=DL_30min
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 productCode=474750A
...                                 prodCodePlanned=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
...                                 secondEndpointLabel=SFP
...                                 Downlink_throughput=140
...                                 Uplink_throughput=35
#...                                 frequencyDensityThresNrb1=245
...                                 coresetDedicated_size=192
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php?code=EYgBemAAAAAEAAAAAAAAAAAA
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcsR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12


*** Keywords ***

Test_BandWith_NSA_TDD
    [Documentation]                 Generic test for several BW

    [Arguments]                     ${param}
    IF                              not ${isAic}
                                    WA Airscale Wait For Ready                          ${GNB_DU}
                                    WA Airscale Wait For Ready                          ${AP_DU}
    END
    Init Sequence                   ${param}
    Run Keyword If    not ${isAic}    Get Data From Gnb TargetBD File                   card_name=${param.RU}
    ...         ELSE
    ...                               Get Data From Gnb TargetBD File                   card_name=${param.RU_isAic}
    Critical Step                   Set MRBTSID and NRBTSID
    Critical Step                   Set Context_AP IPHY                                 depends=Set MRBTSID and NRBTSID
    Critical Step                   Set Context_WTS CFG                                 depends=Set Context_AP IPHY
    Critical Step                   Set SCF context                                     depends=Set Context_WTS CFG

    #Temporary restart TL forced
    Restart TL
    Run Keyword If    not ${isAic}    Wait Testline To Be Ready                         waitF1=${False}
    Critical Step                   WTS Setup                                           depends=Set SCF context
    Critical Step                   UE Cell Setup Check                                 depends=WTS Setup
    Critical Step                   UE Attach BW                                        depends=UE Cell Setup Check
    Critical Step                   UE Attach Check                                     depends=UE Attach BW
    Run Keyword If                  ${isAic}                                            Reduce_Pusch_RX_Power_AND_SINR
    Critical Step                   DL Traffic Feature BW                               depends=UE Attach Check
    Critical Step                   UL Traffic Feature BW                               depends=UE Attach Check

# SCF Corner #################################################################################################
#vbo#adding dedicated keyword to set SCF context for VCU
Set SCF Context CU
    &{modify_param1}    Create Dictionary
    ...    parameter=freqBandIndicatorNR
    ...    dist_name=${NRCELL_DIST_NAME_CU}
    ...    value=${param.freqBandIndicatorNR}

    &{modify_param2}   Create Dictionary
    ...    parameter=chBw
    ...    dist_name=${NRCELL_DIST_NAME_CU}
    ...    value=${param.chBw}

    &{modify_param9}   Create Dictionary
    ...    parameter=nrarfcn
    ...    dist_name=${NRCELL_DIST_NAME_CU}
    ...    value=${param.nrarfcn}

    ${nrcelch_dist_name_cu} =    Set Variable    MRBTS-${MRBTS_ID_CU}/NRBTS-${NRBTS_ID_CU}/${NRCELL_GRP_CU}
    &{modify_param10}   Create Dictionary
    ...    parameter=scs
    ...    dist_name=${nrcelch_dist_name_cu}
    ...    value=${param.scs}

    @{modify_param_CU}    Create List    ${modify_param1}   ${modify_param2}   ${modify_param9}   ${modify_param10}

    Dated log    Parameters to modify on CU:\n
    Dated log    ${modify_param1}
    Dated log    ${modify_param2}
    Dated log    ${modify_param9}
    Dated log    ${modify_param10}

    OAM Set Params    oam=${GNB_CU.oam}    modify_param=${modify_param_CU}


Set SCF context
    Run Keyword If    not ${isAic}    Backup Scf

    &{modify_param1}    Create Dictionary
    ...    parameter=freqBandIndicatorNR
    ...    dist_name=${dist_name}
    ...    value=${param.freqBandIndicatorNR}

    &{modify_param2}    Create Dictionary
    ...    parameter=chBw
    ...    dist_name=${dist_name}
    ...    value=${param.chBw}

    &{modify_param3}    Create Dictionary
    ...    parameter=${gscnParameterName}
    ...    dist_name=${dist_name}
    ...    value=${param.gscn}

    &{modify_param4}    Run Keyword If    not ${isAic}
    ...                                   Create Dictionary    parameter=type0CoresetConfigurationIndex
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.type0CoresetConfigurationIndex}
    ...                             ELSE
    ...                                   Create Dictionary    parameter=type0CoresetConfigurationIndex
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.type0CoresetConfigurationIndex_isAic}

    &{modify_param5}    Create Dictionary
    ...    parameter=actDl256Qam
    ...    dist_name=${dist_name}
    ...    value=${param.actDl256Qam}

    &{modify_param6}    Run Keyword If    not ${isAic}
    ...                                   Create Dictionary    parameter=dlQam256PowerBackoffSub6
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.dlQam256PowerBackoffSub6}
    ...                             ELSE
    ...                                   Create Dictionary    parameter=dlQam256PowerBackoffSub6
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.dlQam256PowerBackoffSub6_isAic}

    &{modify_param7}    Create Dictionary
    ...    parameter=dllaIniMcs
    ...    dist_name=${dist_name}
    ...    value=${param.dllaIniMcs}

    &{modify_param8}    Create Dictionary
    ...    parameter=ullaIniMcs
    ...    dist_name=${dist_name}
    ...    value=${param.ullaIniMcs}

    &{modify_param9}    Create Dictionary
    ...    parameter=nrarfcn
    ...    dist_name=${dist_name}
    ...    value=${param.nrarfcn}

    &{modify_param10}    Create Dictionary
    ...    parameter=scs
    ...    dist_name=${nrcelch_dist_name}
    ...    value=${param.scs}

    &{modify_param11}    Create Dictionary
    ...    parameter=ssbScs
    ...    dist_name=${dist_name}
    ...    value=${param.ssbScs}

    &{modify_param12}    Run Keyword If    not ${isAic}
    ...                                    Create Dictionary    parameter=prodCodePlanned
    ...                                                         dist_name=${RadioModule_name}
    ...                                                         value=${param.prodCodePlanned}
    ...                              ELSE
    ...                                    Create Dictionary    parameter=prodCodePlanned
    ...                                                         dist_name=${RadioModule_name}
    ...                                                         value=${param.prodCodePlanned_isAic}

#    &{modify_param13}    Create Dictionary
#    ...    parameter=frequencyDensityThresNrb1
#    ...    dist_name=${dist_name}
#    ...    value=${param.frequencyDensityThresNrb1}

    &{dict_param14}      Create Dictionary    size=${param.coresetDedicated_size}
    &{modify_param14}    Run Keyword If    not ${isAic}
    ...                  Evaluate    {'dist_name': '${PDCCH_configDedicated}','parameter': 'coresetDedicated','value':[&{dict_param14}]}
    ...                              ELSE
    ...                                    Create Dictionary    parameter=coresetDedicated/0/size
    ...                                                         dist_name=${PDCCH_configDedicated}
    ...                                                         value=${param.coresetDedicated_size}

    &{modify_param20}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/frameStructureType
    ...                                       dist_name=${nrcell_dist_name}
    ...                                       value=${param.frameStructureType_isAic}
    &{modify_param21}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/guardPeriodLength
    ...                                       dist_name=${nrcell_dist_name}
    ...                                       value=${param.guardPeriodLength_isAic}
    &{modify_param22}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/ulDlDataSlotRatio
    ...                                       dist_name=${nrcell_dist_name}
    ...                                       value=${param.ulDlDataSlotRatio}
    # remove operations are needed for new topology CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
    &{delete_param23}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/lteToNrFrameShift
    ...                                       dist_name=${nrcell_dist_name}
    ...                                       value=none
    ...                                       operation=remove
    &{delete_param24}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/tdLteUlDlConfig
    ...                                       dist_name=${nrcell_dist_name}
    ...                                       value=none
    ...                                       operation=remove
    &{modify_param25}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=msg1FrequencyStart
    ...                                       dist_name=${nrcell_dist_name}
    ...                                       value=${param.msg1FrequencyStart_isAic}

    @{modify_param}=     Run Keyword If       not ${isAic}
    ...                                                    Create List    ${modify_param1}
    ...                                                    ${modify_param2}
    ...                                                    ${modify_param3}
    ...                                                    ${modify_param4}
    ...                                                    ${modify_param5}
    ...                                                    ${modify_param6}
    ...                                                    ${modify_param7}
    ...                                                    ${modify_param8}
    ...                                                    ${modify_param9}
    ...                                                    ${modify_param10}
    ...                                                    ${modify_param11}
    ...                                                    ${modify_param12}
    ...                                                    ${modify_param14}
    ...                  ELSE
    ...                                                    Create List   ${modify_param1}
    ...                                                    ${modify_param2}
    ...                                                    ${modify_param3}
    ...                                                    ${modify_param4}
    ...                                                    ${modify_param5}
    ...                                                    ${modify_param6}
    ...                                                    ${modify_param7}
    ...                                                    ${modify_param8}
    ...                                                    ${modify_param9}
    ...                                                    ${modify_param10}
    ...                                                    ${modify_param11}
    ...                                                    ${modify_param12}
    ...                                                    ${modify_param14}
    ...                                                    ${modify_param20}
    ...                                                    ${modify_param21}
    ...                                                    ${modify_param22}
    ...                                                    ${delete_param23}
    ...                                                    ${delete_param24}
    ...                                                    ${modify_param25}

    Dated log                         Parameters to modify:\n  #${modify_param}
    Dated log                         ${modify_param1}
    Dated log                         ${modify_param2}
    Dated log                         ${modify_param3}
    Dated log                         ${modify_param4}
    Dated log                         ${modify_param5}
    Dated log                         ${modify_param6}
    Dated log                         ${modify_param7}
    Dated log                         ${modify_param8}
    Dated log                         ${modify_param9}
    Dated log                         ${modify_param10}
    Dated log                         ${modify_param11}
    Dated log                         ${modify_param12}
    Dated log                         ${modify_param14}
    Run Keyword If         ${isAic}
    ...                               Run Keywords
    ...                                   Dated log        ${modify_param20}
    ...    AND                            Dated log        ${modify_param21}
    ...    AND                            Dated log        ${modify_param22}
    ...    AND                            Dated log        ${modify_param25}
    ...    AND                            Dated log        Parameters to delete:\n
    ...    AND                            Dated log        ${delete_param23}
    ...    AND                            Dated log        ${delete_param24}

    OAM Set Params                    ${modify_param}
    Run Keyword If    not ${isAic}    OAM Get SCF File      file=SCF_DU_Updated.xml

    # Wait Testline To Be Ready    waitF1=${True}
    Run Keyword If    ${isAic}    Run Keywords
    ...           Set SCF Context CU
    ...    AND    Wait Vcu And Vdu Available
    ...    AND    OAM Get SCF File    oam=${GNB_DU.oam}    file=SCF_DU_Updated.xml
    ...    AND    OAM Get SCF File    oam=${GNB_CU.oam}    file=SCF_CU_Updated.xml


Set Context_WTS CFG
    WtsCfgConfig.startSession

    # ADT - add param "ignore_comments=True" to "getParam"
    ${oldValue}          getParam           prefix=set_cell id=1    param=nr_arfcn    ignore_comments=True
    replaceValue         prefix=set_cell id=1
    ...                  param=nr_arfcn
    ...                  oldValue=${oldValue}
    ...                  newValue=${param.nrarfcn}:${param.nrarfcn}    #UL:DL
    ...                  ignore_comments=True
    Dated log            Basic file arfcn value changed from ${oldValue} --> ${param.nrarfcn}:${param.nrarfcn}

    #update gscn GNB CONFIGURATION for set_cell id 1 only
    ${oldValue}          getParam           prefix=set_cell id=1    param=gscn    ignore_comments=True
    Run Keyword If    ${isAic}    Run Keywords
    ...                       replaceValue               prefix=set_cell id=1
    ...                                                  param=gscn
    ...                                                  oldValue=${oldValue}
    ...                                                  newValue=${param.gscn}
    ...                                                  ignore_comments=True
    ...    AND    Dated log     Basic file gscn value changed for set_cell id 1 from ${oldValue} --> ${param.gscn}

# RDH: New LO_AP_LO Variant
# Issue: with new basic_setup.cfg, the NR_CAPA are defined through a variable.
#        Then, to change the NR_Capabilities, the actual process is no more possible...
#        Then while the old variant is defined for Bandwidth tests (1000,1075, 1076, ...), the following "old" code is the one to be run.
#        But, as soon the new LO_AP_LO variant is defined for Bandwidth tests, please put in comment the "old" code and activate the "new" code
# RDH: Beginning of "old" code:
# LP:  "old" code concerns only the "not ${isAic}" cases in following lines
#      Only VRAN CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH is now available: "ELSE" cases are right for this current VRAN topology
#      Note that "ELSE" cases could work with all topology, but need to be be checked with all BW tests
    # ADT - add param "ignore_comments=True" to "getParam"

    ${oldValue}         Run Keyword If    not ${isAic}
    ...                                         getParam        prefix=ue_param id=${FIRST_NSA_UE_ID}
    ...                                                         param=ue_nr_capabilities
    ...                                                         ignore_comments=True
    ...    ELSE
    ...                                         getParam        prefix=ue_param id=${FIRST_NSA_UE_ID}
    ...                                                         param=ue_nr_capabilities
    ...                                                         ignore_comments=True

    Run Keyword If    not ${isAic}
    ...                                         replaceValue    prefix=ue_param id=${FIRST_NSA_UE_ID}
    ...                                                         occurrence=${-1}
    ...                                                         param=ue_nr_capabilities
    ...                                                         oldValue=${oldValue}
    ...                                                         newValue=${param.ue_nr_capabilities}
    ...                                                         ignore_comments=True
    ...    ELSE
    ...                                         replaceValue    prefix=ue_param id=${FIRST_NSA_UE_ID}
    ...                                                         occurrence=${-1}
    ...                                                         param=ue_nr_capabilities
    ...                                                         oldValue=${oldValue}
    ...                                                         newValue=${param.ue_nr_capabilities_1_isAic}${param.ue_nr_capabilities_2_isAic}
    ...                                                         ignore_comments=True

# RDH: End of "old" code

# RDH - New LO_AP_LO Variant - the following code should be reactivated with the new LO_AP_LO variant
# RDH: Beginning of "new" code:
#    ${oldValue}         Run Keyword If  not ${isAic}
#    ...                                         getParam        prefix=set
#    ...                                                         param=NSA_UE_CAPABILITIES_TDD
#    ...                                                         ignore_comments=True
#    Run Keyword If      not ${isAic}            ReplaceValue    prefix=set
#    ...                                                         occurrence=${-1}
#    ...                                                         param=NSA_UE_CAPABILITIES_TDD
#    ...                                                         oldValue=${oldValue}
#    ...                                                         newValue=${param.ue_nr_capabilities}
#    ...                                                         ignore_comments=True
#    Run Keyword If    not ${isAic}      Run keywords
#    ...                                         Dated log       Basic file nr_capabilities value changed from:
#    ...                                 AND     Dated log       ${oldValue}
#    ...                                 AND     Dated log       To :
#    ...                                 AND     Dated Log       ${param.ue_nr_capabilities}
#    ...         ELSE                    Run keywords
#    ...                                         Dated log       Basic file nr_capabilities value changed from:
#    ...                                 AND     Dated log       ${oldValue}
#    ...                                 AND     Dated log       To :
#    ...                                 AND     Dated Log       ${param.ue_nr_capabilities_1_isAic}${param.ue_nr_capabilities_2_isAic}
# RDH: end of "new" code

# RDH: New LO_AP_LO Variant
# Issue: with new basic_setup.cfg, the NR_CAPA are defined through a variable.
#        Then, to change the NR_Capabilities, the actual process is no more possible...
#        Then while the old variant is defined for Bandwidth tests (1000,1075, 1076, ...), the following "old" code is the one to be run.
#        But, as soon the new LO_AP_LO variant is defined for Bandwidth tests, please put in comment the "old" code and activate the "new" code
# RDH: Beginning of "old" code:
    # ADT - add param "ignore_comments=True" to "getParam"

    ${oldValue}    Run Keyword If    not ${isAic}
    ...                                         getParam        prefix=ue_param id=${FIRST_NSA_UE_ID}
    ...                                                         param=ue_eutra_nr_capabilities
    ...                                                         ignore_comments=True

    Run Keyword If    not ${isAic}
    ...                                         replaceValue    prefix=ue_param id=${FIRST_NSA_UE_ID}
    ...                                                         occurrence=${-1}
    ...                                                         param=ue_eutra_nr_capabilities
    ...                                                         oldValue=${oldValue}
    ...                                                         newValue=${param.ue_eutra_nr_capabilities}
    ...                                                         ignore_comments=True

# RDH: End of "old" code
# RDH - New LO_AP_LO Variant - the following "new" code should be reactivated with the new LO_AP_LO variant
# RDH: Beginning of "new" code:
#    ${oldValue}         Run Keyword If  not ${isAic}
#    ...                                         getParam        prefix=set
#    ...                                                         param=NR_EUTRA_CAPABILITIES_TDD
#    ...                                                         ignore_comments=True
#    Run Keyword If      not ${isAic}    Run keywords
#    ...                                         replaceValue    prefix=set
#    ...                                                         occurrence=${-1}
#    ...                                                         param=NR_EUTRA_CAPABILITIES_TDD
#    ...                                                         oldValue=${oldValue}
#    ...                                                         newValue=${param.ue_eutra_nr_capabilities}
#    ...                                                         ignore_comments=True
#    ...                                 AND     Dated log       Basic file nr_eutra_capabilities value changed from:
#    ...                                 AND     Dated log       ${oldValue}
#    ...                                 AND     Dated log       To :
#    ...                                 AND     Dated Log       ${param.ue_eutra_nr_capabilities}
# RDH: end of "new" code

    WtsCfgConfig.stopSession    rename=modified


# Attach Traffic corner #######################################################################################

UE Attach BW
    ${UE_NSA}                       Set Variable    ${UE_SIMPLE}
    ${UE_NSA.ue}                    Set Variable    ${FIRST_NSA_UE_ID}
    Set Suite Variable              ${UE_NSA}
    SgNB Addition to ENB            ueSetting=${UE_NSA}

UL Traffic Feature BW
    Dated log                       Starting UL Traffic procedure
    Traffic UE UL                   ueSetting=${UE_NSA}    throughput=${param.Uplink_throughput}    duration=30s    deviation=25

DL Traffic Feature BW
    Dated log                       Starting DL Traffic procedure
    Traffic UE DL                   ueSetting=${UE_NSA}    throughput=${param.Downlink_throughput}    duration=30s    deviation=25

UL_DL Traffic Feature BW
    Dated log                       Starting UL DL Traffic procedure
    Traffic UE UL DL                ueSetting=${UE_NSA}    throughput=2    duration=300s

UL_DL_Stability Traffic Feature BW
    Dated log                       Starting UL_DL_Stability Traffic procedure
    Traffic UE UL DL                ueSetting=${UE_NSA}    throughput=2    duration=7200s

DL_30min Traffic Feature BW
    Dated log                       Starting DL_30min Traffic procedure
    Traffic UE DL                   ueSetting=${UE_NSA}    throughput=2    duration=1800s
