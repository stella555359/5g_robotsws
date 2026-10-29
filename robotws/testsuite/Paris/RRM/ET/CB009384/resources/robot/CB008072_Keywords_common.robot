*** Settings ***
Documentation     [PURPOSE] Set of keywords used for CB008072 feature tests cases
...
...               Automation author           : bernard.hoche@nokia.com
...               Automation contact          : bernard.hoche@nokia.com
...               Creation Date               : 05-June-2019
...               Modified Date               : 22-Apr-2024
...               Last Modified by            : bernard.hoche@nokia.com
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to CB006062
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to CB007782
...               Last Modified by            : martial.hummel@nokia.com marie-laurence.le_borgne@nokia.com: adapt to CB008072
...               Then Modified by            : vincent.boulet@nokia.com
...               Last Modification           : update for supporting vRAN2.0 Cloud topology
...               Modified Date               : 28-April-2022
...               Modified Date               : 13-June-2022 Improvement for BIP decoding issue
...               Last Modified by            : vincent.boulet@nokia.com: Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC


Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot

Library           ../../../resources/python/luashark_tools.py
Library           luashark_tools.analyzer       WITH NAME       analyzer
Library           taf.config.scf                WITH NAME      scf
Library           Collections

# *** Variables ***
#${Destination_port}             5678

*** Keywords ***
#=======================================================================================================================
# KW to perform checks in pcap files
#=======================================================================================================================

Check FDM UL in BIP Msg
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check UL FDM Activation in BIP Msg
    ...                             (BIPvalueDMrsCdmGroupWithoutData=1 when FDM activated else set to 2)
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.numOfDmrsCdmGroupWithoutData
    ...                             value=${value}
    ...                             endPacket=${1}

Check PuschMappingType UL in BIP Msg
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check PuschMappingType in BIP Traces
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.ulDmrsMappingType
    ...                             value=${value}
    ...                             endPacket=${1}

Check dmrs TypeA Position in BIP Msg
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check dmrs TypeA Pos in BIP Msg (BIPvaluedmrsTypeAPosition=2 for Pos2 else 3 for Pos3)
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.ulDmrsTypeAPos
    ...                             value=${value}
    ...                             endPacket=${1}

Check Additional DMRS UL in BIP Msg
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check Additional DMRS UL in BIP Msg
    ...                             (value=1 for 1 additional DMRS else 0 for No Additional DMRS)
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.ulDmrsAddPos
    ...                             value=${value}
    ...                             endPacket=${1}

Check UL PTRS in BIP Msg
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check UL PTRS status in BIP Traces (value=1 for UL PTRS activated else 0 for UL PTRS De-activated)
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.ulPtrsFlag
    ...                             value=${value}
    ...                             endPacket=${1}

Check TransfPrecoder enabled in BIP Msg
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check TransformPrecoder is enabled in BIP Msg
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.puschTransformPrecoderFlag
    ...                             value=${value}
    ...                             endPacket=${1}

Check UL 256QAM in BIP
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Dated log                       Check 256QAM UL mcsTable is used in BIP Traces (value=1 when 256QAM UL mcsTable is used)
    Filter and Check field          ${pcapFile}
    ...                             filterExp=(uldata_puschreceivereq) && (nr_l1ul_l2ps_uldata_puschreceivereqgrant_t)
    ...                             msg=UlData_PuschReceiveReq
    ...                             data=.mcsTable
    ...                             value=${value}
    ...                             endPacket=${1}

Check CRC OK for HarqU in BIP
    [Arguments]                     ${pcapFile}
    ...                             ${crc}=0
    Dated log                       Check CRC OK for PuschReceiveRespHarqU in BIP Msg
    Filter and Check field          ${pcapFile}
    ...                             filterExp=uldata_puschreceiverespharqu
    ...                             msg=UlData_PuschReceiveRespHarqU
    ...                             data=.crc
    ...                             value=${crc}
    ...                             endPacket=${1}

Check NO DTX for HarqU in BIP
    [Arguments]                     ${pcapFile}
    ...                             ${dtx}=0
    Dated log                       Check NO DTX for PuschReceiveRespHarqU in BIP Msg
    Filter and Check field          ${pcapFile}
    ...                             filterExp=uldata_puschreceiverespharqu
    ...                             msg=UlData_PuschReceiveRespHarqU
    ...                             data=.dtx
    ...                             value=${dtx}
    ...                             endPacket=${1}

Filter and Check field
    [Arguments]                     ${pcapfile}
    ...                             ${filterExp}=None               ${msg}=None
    ...                             ${data}=none                    ${value}=None
    ...                             ${startPacket}=${1}             ${endPacket}=${-1}
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${msg}               filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}

    Dated log                       \tIn BIP messages ${msg} [${startPacket}..${endpacket}], check ${data}=${value}
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${data}$
    ...                             value=${value}
    ...                             startPacket=${startPacket}
    ...                             endPacket=${endPacket}

Check UserSetupReq
    [Arguments]                     ${pcapFile}                     ${field}                       ${value}
    ${pcapFiltered}                 analyzer.filter_pcap
    ...                             pcapInFile=${pcapFile}
    ...                             filterName=UserSetupReq
    ...                             filterExp=itf_l2_ps_user_usersetupreq
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
    ${msg}=                         Set Variable                    itf_l2_ps_user_UserSetupReq
    Dated log                       In message ${msg}, check ${field}=${value}                     first=True
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${msg}.${field}$
    ...                             value=${value}

Check Additional DMRS UL
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Check RRC Reconfiguration for Additional DMRS       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
    ...                             value=${value}

Check PuschMappingTypeA
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Check RRC Reconfiguration for PuschMappingTypeA       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
    ...                             value=${value}

Check dmrs TypeA Position
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Check RRC Reconfiguration for dmrs TypeA Position       pcapFile=${pcapFile}            prefix=nr-rrc.reconfigurationWithSync_element
    ...                             value=${value}

Check transformPrecoder enabled
    [Arguments]                     ${pcapFile}
    ...                             ${value}
    Check RRC Reconfiguration for TransformPrecoder enabled       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
    ...                             value=${value}

Check RRC Reconfiguration for Additional DMRS
    [Arguments]                     ${pcapFile}
    ...                             ${prefix}
    ...                             ${field}=nr-rrc.dmrs_AdditionalPosition
    ...                             ${value}=value
    ${pcapFiltered}                 analyzer.filter_pcap
    ...                             pcapInFile=${pcapFile}
    ...                             filterName=X2AP
    ...                             filterExp=x2ap
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
    Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
    ...                             first=True
    ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${prefix}/.*/${field}$
    ...                             value=${value}

Check RRC Reconfiguration for PuschMappingTypeA
    [Arguments]                     ${pcapFile}
    ...                             ${prefix}
    ...                             ${field}=nr-rrc.dmrs_UplinkForPUSCH_MappingTypeA
    ...                             ${value}=value
    ${pcapFiltered}                 analyzer.filter_pcap
    ...                             pcapInFile=${pcapFile}
    ...                             filterName=X2AP
    ...                             filterExp=x2ap
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
    Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is st to ${value}
    ...                             first=True
    ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${prefix}/.*/${field}$
    ...                             value=${value}

Check RRC Reconfiguration for dmrs TypeA Position
    [Arguments]                     ${pcapFile}
    ...                             ${prefix}
    ...                             ${field}=nr-rrc.dmrs_TypeA_Position
    ...                             ${value}=value
    ${pcapFiltered}                 analyzer.filter_pcap
    ...                             pcapInFile=${pcapFile}
    ...                             filterName=X2AP
    ...                             filterExp=x2ap
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
    Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is st to ${value}
    ...                             first=True
    ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${prefix}/.*/${field}$
    ...                             value=${value}

Check RRC Reconfiguration for TransformPrecoder enabled
    [Arguments]                     ${pcapFile}
    ...                             ${prefix}
    ...                             ${field}=nr-rrc.transformPrecoder
    ...                             ${value}=value
    ${pcapFiltered}                 analyzer.filter_pcap
    ...                             pcapInFile=${pcapFile}
    ...                             filterName=X2AP
    ...                             filterExp=x2ap
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
    Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is st to ${value}
    ...                             first=True
    ${msg}                          Set Variable                    SgNBModificationRequired
    analyzer.check_list             pdmlFile=${pdmlFile}
    ...                             packetName=${msg}
    ...                             path=${prefix}/.*/${field}$
    ...                             value=${value}

Check FDM UL in BIP Traces
    Check FDM UL in BIP Msg                       pcapFile=${CaptureL1L2.path}
    ...                                           value=${param.BIPvalueDMrsCdmGroupWithoutData}

Check PuschMappingTypeA UL in BIP Traces
    Check PuschMappingType UL in BIP Msg          pcapFile=${CaptureL1L2.path}
    ...                                           value=${puschMappingTypeAFlag}

Check transformPrecoder enabled in BIP Traces
    Check TransfPrecoder enabled in BIP Msg       pcapFile=${CaptureL1L2.path}
    ...                                           value=${TransformPrecoder_enabled_FLAG}

Check PuschMappingTypeB UL in BIP Traces
    Check PuschMappingType UL in BIP Msg          pcapFile=${CaptureL1L2.path}
    ...                                           value=${puschMappingTypeBFlag}

Check dmrs TypeA Position in BIP Traces
    Check dmrs TypeA Position in BIP Msg          pcapFile=${CaptureL1L2.path}
    ...                                           value=${param.BIPvaluedmrsTypeAPosition}

Check Additional DMRS UL in BIP Traces
    Check Additional DMRS UL in BIP Msg           pcapFile=${CaptureL1L2.path}
    ...                                           value=${param.BIPvalueUlDMRSAdditionalPosition}

Check PTRS UL in BIP Traces
    Check UL PTRS in BIP Msg                      pcapFile=${CaptureL1L2.path}
    ...                                           value=${param.BIPvalueEnableulPtrs}

Check 256QAM UL in BIP Traces
    Check UL 256QAM in BIP                        pcapFile=${CaptureL1L2.path}
    ...                                           value=${UlmcsTable256QAMFlag}

Check CRC OK for HarqU in UL BIP Traces
    Check CRC OK for HarqU in BIP                 pcapFile=${CaptureL1L2.path}
    ...                                           crc=0

Check NO DTX for HarqU in UL BIP Traces
    Check NO DTX for HarqU in BIP                 pcapFile=${CaptureL1L2.path}
    ...                                           dtx=0

Check Additional DMRS UL in RRC Msg
    Check Additional DMRS UL                      pcapFile=${CaptureCORE.path}
    ...                                           value=${param.RRCvalueUlAdditionalDmrs}

Check PuschMappingTypeA in RRC Msg
    Check PuschMappingTypeA                       pcapFile=${CaptureCORE.path}
    ...                                           value=${UplinkForPUSCH_MappingTypeA_1}

Check dmrs TypeA Position in RRC Msg
    Check dmrs TypeA Position                     pcapFile=${CaptureCORE.path}
    ...                                           value=${param.RRCvaluedmrsTypeAPosition}

Check transformPrecoder enabled in RRC Msg
    Check transformPrecoder enabled               pcapFile=${CaptureCORE.path}
    ...                                           value=${TransformPrecoder_enabled}

#=======================================================================================================================
# KW to set some parameters in SCF
#=======================================================================================================================

Restore Default Context 8072
    Set Freq and TDD Frame struct
    Set UE capa on EPCSim               ue_nr_capa_value=${ue_nr_capa_defValue}

Suite Setup 8072
    Setup.Suite Setup From Scratch      automaticTeardown=${True}
    Backup Files

Suite Teardown 8072
    Restore Files
    Setup.Suite Teardown


Restart
    [Tags]                          RESTART
    Restart TL

Captures Init
    ${CaptureL1L2}                  Capture L1L2 Set Upon Config            airscale=${GNB_DU}
    ${CaptureCORE}    Run Keyword If    not ${isAic}    Capture CORE Set Upon Config    airscale=${GNB_DU}
    ...               ELSE
    ...                                                 Capture CORE Set Upon Config    airscale=${GNB_CU}
    ${CaptureCPRT}                  Capture CPRT Set Upon Config            airscale=${GNB_DU}
    Capture Init                    ${CaptureL1L2}                          withTN=True
    Capture Init                    ${CaptureCORE}                          withTN=True
    Capture Init                    ${CaptureCPRT}                          withTN=True
    Set Suite Variable              ${CaptureL1L2}
    Set Suite Variable              ${CaptureCORE}
    Set Suite Variable              ${CaptureCPRT}

Capture BIP Start
    Capture Start                   capture=${CaptureL1L2}

Capture BIP Stop
    Capture Stop                    capture=${CaptureL1L2}

Captures Start
    Capture Start                   capture=${CaptureCORE}
    Capture Start                   capture=${CaptureCPRT}

Captures Stop
    Capture Stop                    capture=${CaptureCORE}
    Capture Stop                    capture=${CaptureCPRT}

Test WTS Setup
    WTS Setup

Test Verify Cell Setup
    UE Cell Setup Check

SgNB Addition PRACH
    SgNB Addition to ENB            ueSetting=${UE_SIMPLE}
    ...                             captureCallback=None
    ...                             capture=None

Attach_FR1
    UE Attach Check

UL Traffic
    Traffic UE UL                   throughput=2
    ...                             captureCallback=Callback Capture L1L2
    ...                             capture=${CaptureL1L2}
    ...                             deviation=20

DL Traffic
    Traffic UE DL                   throughput=2
    ...                             captureCallback=Callback Capture L1L2
    ...                             capture=${CaptureL1L2}
    ...                             deviation=20

UL_DL Traffic
    Traffic UE UL DL                throughput=2
    ...                             captureCallback=Callback Capture L1L2
    ...                             capture=${CaptureL1L2}
    ...                             deviation=20

UL Traffic SA
    Traffic UE UL           ueSetting=${BASIC_UE_SA}
    ...                             throughput=2
    ...                             captureCallback=Callback Capture L1L2
    ...                             capture=${CaptureL1L2}
    ...                             deviation=20

UL_DL Traffic SA
    Traffic UE UL DL         ueSetting=${BASIC_UE_SA}
    ...                              throughput=2
    ...                              captureCallback=Callback Capture L1L2
    ...                              capture=${CaptureL1L2}
    ...                              deviation=20

#==========================================
#Customised rename of sherpa logs
#==========================================
Rename Of Sherpa Logs
    ${TestName}                     getFormattedName
    Copy File                       ${LOG_PATH}/l2stream3/tcpdump/tcpdump.pcap        ${LOG_PATH}/l2stream3/tcpdump/${TestName}.pcap
