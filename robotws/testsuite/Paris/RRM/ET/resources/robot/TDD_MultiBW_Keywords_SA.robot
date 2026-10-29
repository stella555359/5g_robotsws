*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     File containing keywords used by MultiBW SA TDD test suites
...               Prerequisite :
...               Scope : keywords for MultiBW SA TDD
...
...               Test Case Scenario author   : n/a
...               Creation Date               : n/a
...               Modified Date               : 2024-06-25
...               Version   Date      Author                             Notes
...               n/a       n/a       n/a                                Creation
...               n/a       FB2209    vincent.boulet@nokia.com           Update for supporting vRAN2.0 Cloud topology
...               n/a       FB2210    marie-laurence.le_borgne@nokia.com Remove frequensiDensityThresNrb1 from file cause no more in classical
...                                                                      NIDD and not supported in AiC
...               n/a       FB2213    vincent.boulet@nokia.com           Modify ${nrcelch_dist_name_cu} definition for vRAN2.0
...               n/a       FB2218    vincent.boulet@nokia.com           Update msg1FrequencyStart for VRAN2.0 and alignment of parameters for
...                                                                      NRCELL1 only
...               1.0       FB2303    vincent.boulet@nokia.com           Introduction of VRAN NIC modifications using condition isRANNIC
...               1.1       FB2304    vincent.boulet@nokia.com           Modification in case VRAN NIC due to new default commissioning on TL
...               1.2       FB2304    vincent.boulet@nokia.com           Modification in case VRAN NIC due to new default commiss. on TL SA+NSA
...               1.3       FB2304    vincent.boulet@nokia.com           Correction syntax error with KW Run Keywords
...               1.4       FB2305    richard.duthu@nokia.com            Some cleanup as VRAN2.0 no more exist
...               1.5       FB2322    yann.merlin@nokia.com              Supports of vRAN4.0
...               1.6       FB2407    vincent.boulet@nokia.com           Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...                                                                      with configuration moved to RU AZQJ instead of AEQP
...               1.7       FB2412    adrien.hervat@nokia.com            Fix attach issue : dedicatedcoreset value for 70,90MHz (PR774132)
...                                                                      and get TC SCF for Classical in logs
...               1.8       FB2413    vincent.boulet@nokia.com           Correction to restore the VDU commissioning in case of Cloud RAN topology
# --------------------------------------------------------------------------------------------------------------------------------------------------
Resource            ./TDD_MultiBW_Keywords.robot
Resource            ../../../../resources/SWENG/robot/CallSetup.robot
Resource            ../../../../resources/SWENG/robot/Restart.robot



*** Variables ***
${iphy_file_path}           /ffs/run/simmode

${prb_50}                   133
${prb_70}                   189
${prb_90}                   245




${ue_nr_capabilities_n78_AEQI_maxTP}
...        01800000010900100F04D058800365000050000000801C4D000000F0000000000000227000000000000027000002004008

${ue_nr_BAD_capabilities_n78_AEQI_maxTP}
...        01800000010900000002801002050001E000000000000044E00000000000004E000004008010

&{HF_50_a3ghz_n78_AEQE}
                                 #SCF Param
...                                 freqBandIndicatorNR=78
...                                 chBw=50MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
...                                 actDl256Qam=false  # airphone limitation to 64Qam
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
#...                                 frequencyDensityThresNrb1=${prb_50}
...                                 prodCodePlanned=474750A
...                                 prodCodePlanned_isAic=475244A
                                 #not used if universal SCF secondEndpointLabel=SFP
                                 #Airphone
...                                 ssBlockPrbOffset=4
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 NsizeBWP=${prb_50}
...                                 ue_nr_capabilities=${ue_nr_capabilities_n78_AEQI_maxTP}
...                                 ue_nr_BAD_capabilities=${ue_nr_BAD_capabilities_n78_AEQI_maxTP}
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 productCode=474750A
...                                 productCode_isAic=475244A
                                 #Other Param
...                                 dir=DL_30min
...                                 PRBwaited=${prb_50}
...                                 Downlink_throughput=75
...                                 Uplink_throughput=20
...                                 coresetDedicated_size=120
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php?code=EogFWsAAAAAEAAAAAAAAAAAA
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JccR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12



${ue_nr_capabilities_n78_AEQZ}
...        058000000300000000002400403F1342800A000620D940001400000020071340000040000000003C00000000000010A80000000000082A000002004008

${ue_nr_BAD_capabilities_n78_AEQZ}
...        058000000300000000002400403F0A02800A000620D940001400000020070A00000040000000003C00000000000010A80000000000082A000002004008

&{HF_70_a3ghz_n78_AEQE}
                                 #SCF Param
...                                 freqBandIndicatorNR=78
...                                 chBw=70 MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
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
#...                                 frequencyDensityThresNrb1=${prb_70}
...                                 prodCodePlanned=474750A
                                 #not used if universal SCF secondEndpointLabel=SFP
                                 #Airphone
...                                 ssBlockPrbOffset=4
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 NsizeBWP=${prb_70}
...                                 ue_nr_capabilities=${ue_nr_capabilities_n78_AEQZ}
...                                 ue_nr_BAD_capabilities=${ue_nr_BAD_capabilities_n78_AEQZ}
# ...                               ue_nr_capabilities_1_isAic=ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFE
# ...                               ue_nr_capabilities_2_isAic=C0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E52D00158800000000023003CA608
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 productCode=474750A
...                                 productCode_isAic=475244A
...                                 prodCodePlanned_isAic=475244A
                                 #Other Param
...                                 dir=DL_30min
...                                 PRBwaited=${prb_70}
...                                 Downlink_throughput=110    # Mbps
...                                 Uplink_throughput=30       # Mbps
...                                 coresetDedicated_size=186
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php?code=EogBW8AAAAAEAAAAAAAAAAAA
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcsR&ularfcn=636666&dlarfcn=636666&gscn=7880&type0coresetindex=12




${ue_nr_capabilities_n78_AEQI}
...        01800000010900100F04D0188365000050000000801C4D000000F000000000000042A0000000000020A8000008010020

${ue_nr_BAD_capabilities_n78_AEQI}
...        01800000010900100F0280188365000050000000801C28000000F000000000000042A0000000000020A8000008010020

&{LF_90_a3ghz_n78_AEQE}
                                 #SCF Param
...                                 freqBandIndicatorNR=78
...                                 chBw=90MHz
...                                 gscn=7880
...                                 type0CoresetConfigurationIndex=12
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
#...                                 frequencyDensityThresNrb1=${prb_90}
...                                 prodCodePlanned=474750A
...                                 prodCodePlanned_isAic=475244A
                                 #not used if universal SCF secondEndpointLabel=SFP
                                 #Airphone
...                                 ssBlockPrbOffset=4
...                                 RU=AEQE_E1
...                                 RU_isAic=AZQJ_E1
...                                 NsizeBWP=${prb_90}
...                                 ue_nr_capabilities=${ue_nr_capabilities_n78_AEQI}
...                                 ue_nr_BAD_capabilities=${ue_nr_BAD_capabilities_n78_AEQI}
...                                 cardName=AEQE
...                                 cardName_isAic=AZQJ
...                                 productCode=474750A
...                                 productCode_isAic=475244A
                                 #Other Param
...                                 dir=DL_30min
...                                 PRBwaited=${prb_90}
...                                 Downlink_throughput=140    # Mbps
...                                 Uplink_throughput=35       # Mbps
...                                 coresetDedicated_size=192
...                                 msg1FrequencyStart_isAic=6
# http://5gtables.eecloud.dynamic.nsn-net.net/nrTput.php?code=EogBWmAAAAAEAAAAAAAAAAAA
# http://5gtables.eecloud.dynamic.nsn-net.net/NRFreq.php?code=JcsR&ularfcn=636666&dlarfcn=636666&gscn=7877&type0coresetindex=10


*** Keywords ***

Test_BandWith_SA_TDD
    [Documentation]                 Generic test for several BW

    [Arguments]                     ${param}

    Init Sequence                   ${param}
    Run Keyword If    not ${isAic}    Get Data From Gnb TargetBD File                   card_name=${param.RU}
    ...         ELSE
    ...                               Get Data From Gnb TargetBD File                   card_name=${param.RU_isAic}
    Critical Step                   Set MRBTSID and NRBTSID
    Critical Step                   Set Context_AP IPHY                                 depends=Set MRBTSID and NRBTSID
    Critical Step                   Set Context_WTS CFG                                 depends=Set Context_AP IPHY
    Critical Step                   Set SCF Context                                     depends=Set Context_WTS CFG

    #Temporary restart TL forced
    Restart TL
    Run Keyword If    not ${isAic}    Wait Testline To Be Ready                         waitF1=${False}
    Critical Step                   CallSetup.Setup Wtsemu SA
    Critical Step                   UE Attach BW SA                                     depends=CallSetup.Setup Wtsemu SA
    Run Keyword If                  ${isAic}                                            Reduce_Pusch_RX_Power_AND_SINR
    Critical Step                   DL Traffic Feature BW                               depends=UE Attach BW SA
    Critical Step                   UL Traffic Feature BW                               depends=UE Attach BW SA

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

    &{modify_param11}   Create Dictionary
    ...    parameter=nrarfcn
    ...    dist_name=${NRCELL_DIST_NAME_CU}
    ...    value=${param.nrarfcn}

    ${nrcelch_dist_name_cu} =    Set Variable    MRBTS-${MRBTS_ID_CU}/NRBTS-${NRBTS_ID_CU}/${NRCELL_GRP_CU}
    &{modify_param13}   Create Dictionary
    ...    parameter=scs
    ...    dist_name=${nrcelch_dist_name_cu}
    ...    value=${param.scs}

    @{modify_param_CU}    Create List    ${modify_param1}   ${modify_param2}   ${modify_param11}   ${modify_param13}

    Dated log    Parameters to modify on CU:\n
    Dated log    ${modify_param1}
    Dated log    ${modify_param2}
    Dated log    ${modify_param11}
    Dated log    ${modify_param13}

    OAM Set Params    oam=${GNB_CU.oam}    modify_param=${modify_param_CU}


Set SCF Context
    Run Keyword If    not ${isAic}    Backup Scf

    &{modify_param1}    Create Dictionary
    ...    parameter=freqBandIndicatorNR
    ...    dist_name=${dist_name}
    ...    value=${param.freqBandIndicatorNR}

    &{modify_param2}   Create Dictionary
    ...    parameter=chBw
    ...    dist_name=${dist_name}
    ...    value=${param.chBw}

    &{modify_param3}   Create Dictionary
    ...    parameter=${gscnParameterName}
    ...    dist_name=${dist_name}
    ...    value=${param.gscn}

    &{modify_param4}   Create Dictionary
    ...    parameter=type0CoresetConfigurationIndex
    ...    dist_name=${dist_name}
    ...    value=${param.type0CoresetConfigurationIndex}

    &{modify_param5}   Create Dictionary
    ...    parameter=actDl256Qam
    ...    dist_name=${dist_name}
    ...    value=${param.actDl256Qam}

#    &{modify_param6}   Create Dictionary
#    ...    parameter=frequencyDensityThresNrb1
#    ...    dist_name=${dist_name}
#    ...    value=${param.frequencyDensityThresNrb1}

    &{frame_structure}    Create Dictionary    ulDlDataSlotRatio=3/7
    &{modify_param7}    Run Keyword If    not ${isAic}
    ...                  Evaluate    {'dist_name': '${dist_name}','parameter': 'tddFrameStructure','value':[&{frame_structure}]}
    ...                             ELSE
    ...                                   Create Dictionary    parameter=tddFrameStructure/0/ulDlDataSlotRatio
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.ulDlDataSlotRatio}

    &{modify_param8}    Run Keyword If    not ${isAic}
    ...                                   Create Dictionary    parameter=dlQam256PowerBackoffSub6
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.dlQam256PowerBackoffSub6}
    ...                             ELSE
    ...                                   Create Dictionary    parameter=dlQam256PowerBackoffSub6
    ...                                                        dist_name=${dist_name}
    ...                                                        value=${param.dlQam256PowerBackoffSub6_isAic}

    &{modify_param9}   Create Dictionary
    ...    parameter=dllaIniMcs
    ...    dist_name=${dist_name}
    ...    value=${param.dllaIniMcs}

    &{modify_param10}    Create Dictionary
    ...    parameter=ullaIniMcs
    ...    dist_name=${dist_name}
    ...    value=${param.ullaIniMcs}

    &{modify_param11}   Create Dictionary
    ...    parameter=nrarfcn
    ...    dist_name=${dist_name}
    ...    value=${param.nrarfcn}

    &{modify_param12}   Create Dictionary
    ...    parameter=ssbScs
    ...    dist_name=${dist_name}
    ...    value=${param.ssbScs}

    &{modify_param13}   Create Dictionary
    ...    parameter=scs
    ...    dist_name=${nrcelch_dist_name}
    ...    value=${param.scs}

    &{modify_param14}   Create Dictionary
    ...    parameter=freqBandIndicatorNR
    ...    dist_name=${nrsysinfo_dist_name}
    ...    value=${param.freqBandIndicatorNR}

    &{modify_param15}   Create Dictionary
    ...    parameter=ssbScs
    ...    dist_name=${nrsysinfo_dist_name}
    ...    value=${param.ssbScs}

    &{modify_param16}    Run Keyword If    not ${isAic}
    ...                                    Create Dictionary    parameter=prodCodePlanned
    ...                                                         dist_name=${RadioModule_name}
    ...                                                         value=${param.prodCodePlanned}
    ...                              ELSE
    ...                                    Create Dictionary    parameter=prodCodePlanned
    ...                                                         dist_name=${RadioModule_name}
    ...                                                         value=${param.prodCodePlanned_isAic}

    &{dict_param17}      Create Dictionary    size=${param.coresetDedicated_size}
    &{modify_param17}    Run Keyword If    not ${isAic}
    ...                  Evaluate    {'dist_name': '${PDCCH_configDedicated}','parameter': 'coresetDedicated','value':[&{dict_param17}]}
    ...                              ELSE
    ...                                    Create Dictionary    parameter=coresetDedicated/0/size
    ...                                                         dist_name=${PDCCH_configDedicated}
    ...                                                         value=${param.coresetDedicated_size}

    &{modify_param20}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/frameStructureType
    ...                                       dist_name=${dist_name}
    ...                                       value=${param.frameStructureType_isAic}
    &{modify_param21}    Run Keyword If    ${isAic}
    ...                  Create Dictionary    parameter=tddFrameStructure/0/guardPeriodLength
    ...                                       dist_name=${dist_name}
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
    ...                                       dist_name=${dist_name}
    ...                                       value=${param.msg1FrequencyStart_isAic}

    @{modify_param}=     Run Keyword If       not ${isAic}
    ...                                                    Create List    ${modify_param1}
    ...                                                    ${modify_param2}
    ...                                                    ${modify_param3}
    ...                                                    ${modify_param4}
    ...                                                    ${modify_param5}
    #${modify_param6}
    # 04/06/2024: use default ulDlDataSlotRatio
    #...                                                    ${modify_param7}
    ...                                                    ${modify_param8}
    ...                                                    ${modify_param9}
    ...                                                    ${modify_param10}
    ...                                                    ${modify_param11}
    ...                                                    ${modify_param12}
    ...                                                    ${modify_param13}
    # 04/06/2024: use default NRIRFIM object
    #...                                                    ${modify_param14}
    #...                                                    ${modify_param15}
    ...                                                    ${modify_param16}
    ...                                                    ${modify_param17}
    ...                  ELSE
    ...                                                    Create List   ${modify_param1}
    ...                                                    ${modify_param2}
    ...                                                    ${modify_param3}
    ...                                                    ${modify_param4}
    ...                                                    ${modify_param5}
    #${modify_param6}
    ...                                                    ${modify_param7}
    #${modify_param8}
    ...                                                    ${modify_param9}
    ...                                                    ${modify_param10}
    ...                                                    ${modify_param11}
    ...                                                    ${modify_param12}
    ...                                                    ${modify_param13}
    #${modify_param14}
    #${modify_param15}
    ...                                                    ${modify_param16}
    ...                                                    ${modify_param17}
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
    Dated log                         ${modify_param7}
    Dated log                         ${modify_param9}
    Dated log                         ${modify_param10}
    Dated log                         ${modify_param11}
    Dated log                         ${modify_param12}
    Dated log                         ${modify_param13}
    Dated log                         ${modify_param16}
    Dated log                         ${modify_param17}
    Run Keyword If    not ${isAic}    Run Keywords
    ...           Dated log              ${modify_param8}
    ...    AND    Dated log              ${modify_param14}
    ...    AND    Dated log              ${modify_param15}
    ...         ELSE
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
#vbo# # add an UE configuration at the end of basic.cfg file (as the test needs a 2nd UE and
#vbo# # it's not sure that it is already present)
#vbo#
#vbo# ${ue_data}=    catenate  SEPARATOR=
#vbo# ...            \# ADDITIONAL UE CONFIGURATION
#vbo# ...            \n\#---------------------------------------------------------------------------------------------------
#vbo# ...            \nset_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
#vbo# ...            ${SPACE} nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 enb=2 cell=1 mode=nr
#vbo# ...            \nue_param id=2 ue_nr_capabilities=01800000010900100F0280188365000050000000801C28000000F000000000000042A0000000000020A8000008
#vbo# ...            010020
#vbo# ...            \nset_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP
#vbo# ...            \n\n\#---------------------------------------------------------------------------------------------------
#vbo#
#vbo# # ADT - add UE 2 config before "COMMON CONFIGURATION" section
#vbo## ${line_to_search}    Set Variable    ^\#COMMON CONFIGURATION
#vbo## WtsCfgConfig.AddStringBeforeLine    ${ue_data}    ${line_to_search}
#vbo#
#vbo# # ADT - update nwslice param
#vbo## ${oldValue}          getParam    prefix=set_nwslice    param=ue    ignore_comments=True
#vbo## ${oldValue}          Set Variable    ue=${oldValue}
#vbo## ${newValue}          Set Variable    ue=all
#vbo## replaceValue         prefix=set_nwslice
#vbo## ...                  param=ue
#vbo## ...                  oldValue=${oldValue}
#vbo## ...                  newValue=${newValue}
#vbo## ...                  ignore_comments=True
#vbo## Dated log            Basic file arfcn value changed from ${oldValue} --> ${param.nrarfcn}

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
    ...    AND    Dated log    Basic file gscn value changed for set_cell id 1 from ${oldValue} --> ${param.gscn}

# RDH: New LO_AP_LO Variant
# Issue: with new basic_setup.cfg, the NR_CAPA are defined through a variable.
#        Then, to change the NR_Capabilities, the actual process is no more possible...
#        Then while the old variant is defined for Bandwidth tests (1000,1075, 1076, ...), the following "old" code is the one to be run.
#        But, as soon the new LO_AP_LO variant is defined for Bandwidth tests, please put in comment the "old" code and activate the "new" code
# RDH: Beginning of "old" code:
    # ADT - add param "ignore_comments=True" to "getParam"
    ${UESAid_1stCellTDD}     Get First SA UE Id          cell=NRCELL-${TDD_Cell_list[0].nrCellId}
    ${oldValue}    Run Keyword If    not ${isAic}
    ...                                         getParam        prefix=ue_param id=${UESAid_1stCellTDD}
    ...                                                         param=ue_nr_capabilities
    ...                                                         ignore_comments=True

    Run Keyword If    not ${isAic}    Run Keywords
    ...                                         replaceValue    prefix=ue_param id=${UESAid_1stCellTDD}
    ...                                                         param=ue_nr_capabilities
    ...                                                         oldValue=${oldValue}
    ...                                                         newValue=${param.ue_nr_capabilities}
    ...                                                         ignore_comments=True
    ...    AND    Dated log    Basic file nr_capabilities value changed from ${oldValue} --> ${param.ue_nr_capabilities}

#vbo## ADT - add param "ignore_comments=True" to "getParam"
#vbo#${oldValue}    Run Keyword If    not ${isAic}
#vbo#...                                      getParam    prefix=ue_param
#vbo#...                                                  param=ue_nr_capabilities
#vbo#...                                                  occurrence=${2}
#vbo#...                                                  ignore_comments=True
#vbo#Run Keyword If    not ${isAic}    Run Keywords
#vbo#...               replaceValue    prefix=ue_param    occurrence=${2}
#vbo#...                  param=ue_nr_capabilities
#vbo#...                  oldValue=${oldValue}
#vbo#...                  newValue=${param.ue_nr_BAD_capabilities}
#vbo#...                  ignore_comments=True
#vbo#...    AND        Dated log    Basic file nr_capabilities value changed from ${oldValue} --> ${param.ue_nr_BAD_capabilities}


    ${oldValue}    Run Keyword If    ${isAic}
    ...                                         getParam        prefix=set
    ...                                                         param=SA_UE_CAPABILITIES
    ...                                                         ignore_comments=True

    Run Keyword If    ${isAic}    Run Keywords
    ...                                         replaceValue    prefix=set
    ...                                                         param=SA_UE_CAPABILITIES
    ...                                                         oldValue=${oldValue}
    ...                                                         newValue=${param.ue_nr_capabilities}
    ...                                                         ignore_comments=True
    ...    AND    Dated log    Basic file nr_capabilities value changed from ${oldValue} --> ${param.ue_nr_capabilities}

# RDH: End of "old" code
# RDH - New LO_AP_LO Variant - the following code should be reactivated with the new LO_AP_LO variant
# RDH: Beginning of "new" code:
#    ${oldValue}          getParam    prefix=set
#    ...                              param=SA_UE_CAPABILITIES_TDD
#    ...                              ignore_comments=True
#    replaceValue         prefix=set
#    ...                  occurrence=${1}
#    ...                  param=SA_UE_CAPABILITIES_TDD
#    ...                  oldValue=${oldValue}
#    ...                  newValue=${param.ue_nr_capabilities}
#    ...                  ignore_comments=True
#    Dated log            Basic file nr_capabilities value changed from ${oldValue} --> ${param.ue_nr_capabilities}
# RDH: End of "new" code

    WtsCfgConfig.stopSession    rename=modified


# Attach Traffic corner #######################################################################################
UE Attach BW SA
    ${UE_SA}                        Set Variable    ${BASIC_UE_SA}
    ${UE_NSA.ue}                    Get First SA UE Id    cell=NRCELL-${TDD_Cell_list[0].nrCellId}
    Set Suite Variable              ${UE_SA}
    CallSetup.UE Register           ue=${UE_SA.ue}
    CallSetup.Launch PDU Session    ue=${UE_SA.ue}


Launch PDU Session SA_and_Check_RELEASED
    [Arguments]            ${arg}=1
    CallSetup.Launch PDU Session        ue=${arg}    pdu=${arg}    gw=${arg}
    wtsemu.Read Wtsemu Output Until     expected=Received Initial Context Setup Failure       timeout=40
    BuiltIn.Log                         \nReceived Initial Context Setup Failure     console=yes
    sleep    10s


UL Traffic Feature BW
    Traffic UE UL     ueSetting=${UE_SA}    throughput=${param.Uplink_throughput}    duration=30    deviation=25


DL Traffic Feature BW
    Traffic UE DL     ueSetting=${UE_SA}    throughput=${param.Downlink_throughput}   duration=30    deviation=25
