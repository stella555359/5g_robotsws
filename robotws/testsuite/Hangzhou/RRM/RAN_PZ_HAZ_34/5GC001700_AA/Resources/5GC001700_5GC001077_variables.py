# -------- RRC checkpoint for 531 19A------------
# cell id changes form 50 to 710, thus scrambling ID is 710
nzp_CSI_RS_Config_19A = [('nr-rrc.nzp_CSI_RS_ResourceToAddModList', '5', 0),
                         ('nr-rrc.nzp_CSI_RS_ResourceId', '0', 0),
                         ('nr-rrc.frequencyDomainAllocation', '3', 0),
                         ('nr-rrc.other', '04', 0), ('nr-rrc.nrofPorts', '1', 0),
                         ('nr-rrc.cdm_Type', '1', 0),
                         ('nr-rrc.density', '1', 0), ('nr-rrc.startingRB', '0', 0),
                         ('nr-rrc.nrofRBs', '108', 0),
                         ('nr-rrc.scramblingID', '710', 0)]


CSI_IM_Config = [('nr-rrc.csi_IM_ResourceToAddModList', '1', 0),
                 ('nr-rrc.csi_IM_ResourceId', '0', 0), ('nr-rrc.csi_IM_ResourceElementPattern', '1', 0),
                 ('nr-rrc.subcarrierLocation_p1', '1', 0),
                 ('nr-rrc.startingRB', '0', 5), ('nr-rrc.nrofRBs', '108', 5),
                 ('nr-rrc.periodicityAndOffset', '11', 5),

                 ('nr-rrc.csi_IM_ResourceSetToAddModList', '1', 0), ('nr-rrc.csi_IM_ResourceSetId', '0', 0),
                 ('nr-rrc.csi_IM_Resources', '1', 0), ('nr-rrc.CSI_IM_ResourceId', '0', 0)]


CSI_Resource_Config = [
    ('nr-rrc.csi_ResourceConfigId',
     '0',
     0),
    ('nr-rrc.csi_RS_ResourceSetList',
     '0',
     0),
    ('nr-rrc.nzp_CSI_RS_ResourceSetList',
     '1',
     0),
    ('nr-rrc.NZP_CSI_RS_ResourceSetId',
     '0',
     0),
    ('nr-rrc.bwp_Id',
     '1',
     5),
    ('nr-rrc.resourceType',
     '2',
     4)]

CIS_Report_CL_Config = [
    ('nr-rrc.reportConfigId', '0', 0), ('nr-rrc.resourcesForChannelMeasurement', '0', 0),
    ('nr-rrc.csi_IM_ResourcesForInterference', '11', 0), ('nr-rrc.reportConfigType', '0', 0),
    ('nr-rrc.reportSlotConfig', '9', 0),
    ('nr-rrc.pucch_CSI_ResourceList', '1', 0), ('nr-rrc.uplinkBandwidthPartId', '1', 0),
    ('nr-rrc.pucch_Resource', '11', 0), ('nr-rrc.reportQuantity', '1', 0),
    ('nr-rrc.cqi_FormatIndicator', '0', 0), ('nr-rrc.pmi_FormatIndicator', '0', 0),
    ('nr-rrc.csi_ReportingBand', '11', 0), ('nr-rrc.subbands14', 'ff:fc', 0),
    ('nr-rrc.timeRestrictionForChannelMeasurements', '0', 0),
    ('nr-rrc.timeRestrictionForInterferenceMeasurements', '0', 0),
    ('nr-rrc.codebookType', '0', 0), ('nr-rrc.subType', '0', 0),
    ('nr-rrc.nrOfAntennaPorts', '0', 0), ('nr-rrc.twoTX_CodebookSubsetRestriction', 'fc', 0),
    ('nr-rrc.typeI_SinglePanel_ri_Restriction', '03', 0), ('nr-rrc.codebookMode', '1', 0),
    ('nr-rrc.groupBasedBeamReporting', '1', 0), ('nr-rrc.cqi_Table', '0', 0),
    ('nr-rrc.subbandSize', '0', 0)]

CIS_Report_OL_Config = [
    ('nr-rrc.reportConfigId', '0', 0), ('nr-rrc.resourcesForChannelMeasurement', '0', 0),
    ('nr-rrc.csi_IM_ResourcesForInterference', '11', 0), ('nr-rrc.reportConfigType', '0', 0),
    ('nr-rrc.reportSlotConfig', '9', 0),
    ('nr-rrc.pucch_CSI_ResourceList', '1', 0), ('nr-rrc.uplinkBandwidthPartId', '1', 0),
    ('nr-rrc.pucch_Resource', '11', 0), ('nr-rrc.reportQuantity', '4', 0),
    ('nr-rrc.cqi_FormatIndicator', '0', 0), ('nr-rrc.pmi_FormatIndicator', '0', 0),
    ('nr-rrc.csi_ReportingBand', '11', 0), ('nr-rrc.subbands14', 'ff:fc', 0),
    ('nr-rrc.timeRestrictionForChannelMeasurements', '0', 0),
    ('nr-rrc.timeRestrictionForInterferenceMeasurements', '0', 0),
    ('nr-rrc.codebookType', '0', 0), ('nr-rrc.subType', '0', 0),
    ('nr-rrc.nrOfAntennaPorts', '0', 0), ('nr-rrc.twoTX_CodebookSubsetRestriction', 'fc', 0),
    ('nr-rrc.typeI_SinglePanel_ri_Restriction', '03', 0), ('nr-rrc.codebookMode', '1', 0),
    ('nr-rrc.groupBasedBeamReporting', '1', 0), ('nr-rrc.cqi_Table', '0', 0),
    ('nr-rrc.subbandSize', '0', 0), ('nr-rrc.non_PMI_PortIndication', '1', 0),
    ('nr-rrc.PortIndexFor8Ranks', '2', 0), ('nr-rrc.rank1_2', '0', 0),
    ('nr-rrc.rank2_2', '2', 0), ('nr-rrc.PortIndex2', '0', 0), ('nr-rrc.PortIndex2', '1', 1)]

# ------------ BIP checkpoint for 531 19A------------------
CsiRsSendReq = 'DlData_CsiRsSendReq.csiRsResources_item_11.density == 0x01 and ' \
               'DlData_CsiRsSendReq.csiRsResources_item_11.densityDot5PrbLocation == 0x00 and ' \
               'DlData_CsiRsSendReq.csiRsResources_item_11.startPrb == 0x0000 and ' \
               'DlData_CsiRsSendReq.csiRsResources_item_11.numOfPrb == 0x006a and ' \
               'DlData_CsiRsSendReq.csiRsResources_item_11.csiRsConfig == 0x03 and ' \
               'DlData_CsiRsSendReq.csiRsResources_item_11.antennaStream == 0x03'


PucchReceiveRespPs = 'UlData_PucchReceiveRespPs.pucchResources_item_15.pucchFormat == 0x02 and ' \
                     'UlData_PucchReceiveRespPs.pucchResources_item_15.harqProcessIndex == 0x00 and ' \
                     'UlData_PucchReceiveRespPs.pucchResources_item_15.dtx == 0x00'


# got from x2 wireshark, dmrs-AdditionalPosition is pos1 (1)
Closeloop_PdschSendReq_rank2_mcs28_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01  and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.antPort == 0xc000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcs == 0x1c and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Closeloop_PdschSendReq_rank1_mcs11_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.antPort == 0x8000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcs == 0x0b and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Openloop_PdschSendReq_rank1_mcs20_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.antPort == 0x8000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcs == 0x14 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x03 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Closeloop_PdschSendReq_rank2_mcs11_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01  and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.antPort == 0xc000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcs == 0x0b and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Closeloop_PdschSendReq_rank1_mcs11_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.antPort == 0x8000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcs == 0x0b and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Openloop_PdschSendReq_rank2_mcs27_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.antPort == 0xc000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcs == 0x1b and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x03 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Openloop_PdschSendReq_adaptive_mcs20_19A = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and  ' \
                                       'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.dlDmrsTypeAPos == 0x02 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.mcs == 0x14 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x03 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                       'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

# startPrb got form X2 wireshark with para startingPRB: 80(changes from 50 to 80)
# numOfBitsOfUciInformation changes from 7 bits to 8 bits due to SR added
PucchReceiveReq = 'UlData_PucchReceiveReq.pucchResources_item_15.pucchFormat == 0x02 and ' \
                            'UlData_PucchReceiveReq.pucchResources_item_15.startPrb == 0x0050 and  ' \
                            'UlData_PucchReceiveReq.pucchResources_item_15.numOfPrb == 0x10 and ' \
                            'UlData_PucchReceiveReq.pucchResources_item_15.numOfBitsOfUciInformation == 0x08 and ' \
                            'UlData_PucchReceiveReq.pucchResources_item_15.numOfSymbols == 0x01 and ' \
                            'UlData_PucchReceiveReq.pucchResources_item_15.firstSymbol == 0x0d'

# ------------ BIP checkpoint for 531 19B------------------
Openloop_PdschSendReq_rank1_mcs20_19B = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.antPort == 0x8000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcs == 0x14 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x03 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Openloop_PdschSendReq_rank2_mcs27_19B = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.antPort == 0xc000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcs == 0x1b and ' \
                                    'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x03 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                    'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Closeloop_PdschSendReq_rank2_mcs28_19B = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01  and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.antPort == 0xc000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcs == 0x1c and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'

Closeloop_PdschSendReq_rank1_mcs11_19B = 'DlData_PdschSendReq.PdschSendReq.dlDmrsConfigType == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsLen == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsMappingType == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.dlDmrsAddPos == 0x01 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.antPort == 0x8000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcs == 0x0b and ' \
                                     'DlData_PdschSendReq.PdschSendReq.mcsTable == 0x00 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.spatialMode == 0x02 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.startPrb == 0x0000 and ' \
                                     'DlData_PdschSendReq.PdschSendReq.numOfPrb == 0x006a'
# ------------ swconfig for 531 19A------------------
SWCONFIG_PARA_531_003_QC_19A = [
    '0x580011=0',
    '0x580013=0',
    '0x580012=0',
    '0x580014=0',
    '0x580113=7'
]


SWCONFIG_PARA_531_013_QC_19A = [
    '0x580011=0',
    '0x580013=0',
    '0x580012=0',
    '0x580014=0',
    '0x580113=13'
]

SWCONFIG_PARA_531_019_QC_19A = [
    '0x580011=0',
    '0x580013=0',
    '0x580012=0',
    '0x580014=0',
    '0x580113=7'
]

SWCONFIG_PARA_531_027_QC_19A = [
    '0x580011=0',
    '0x580013=0',
    '0x580012=0',
    '0x580014=0',
    '0x580113=1'
]

# ------ 532 19A X2 CheckPoint--------
srs_Config_SingleTx_19A = [('nr-rrc.srs_ResourceSetId', '0', 0), ('nr-rrc.SRS_ResourceId', '0', 0),
                           ('nr-rrc.resourceType', '0', 0),
                           ('nr-rrc.aperiodicSRS_ResourceTrigger', '1', 0), ('nr-rrc.slotOffset', '2', 0),
                           ('nr-rrc.usage', '1', 0), ('nr-rrc.alpha', '7', 1), ('nr-rrc.p0', '-80', 1),
                           ('nr-rrc.srs_ResourceId', '0', 0),
                           ('nr-rrc.nrofSRS_Ports', '0', 0),
                           ('nr-rrc.transmissionComb', '0', 0), ('nr-rrc.combOffset_n2', '0', 0),
                           ('nr-rrc.cyclicShift_n2', '0', 0),
                           ('nr-rrc.startPosition', '2', 0), ('nr-rrc.nrofSymbols', '0', 6),
                           ('nr-rrc.repetitionFactor', '0', 0), ('nr-rrc.freqDomainPosition', '0', 0),
                           ('nr-rrc.freqDomainShift', '0', 0), ('nr-rrc.c_SRS', '25', 0), ('nr-rrc.b_SRS', '0', 0),
                           ('nr-rrc.b_hop', '0', 0),
                           ('nr-rrc.groupOrSequenceHopping', '0', 0), ('nr-rrc.sequenceId', '710', 0),
                           ('nr-rrc.csi_RS_Index', '0', 0)]

pusch_timeDomain_Config = [('nr-rrc.k2', '2', 2), ('nr-rrc.mappingType', '1', 8),
                           ('nr-rrc.startSymbolAndLength', '55', 8), ('nr-rrc.k2', '2', 3),
                           ('nr-rrc.mappingType', '1', 9), ('nr-rrc.startSymbolAndLength', '69', 9)]

pusch_freqDomain_Config_SingleTx_19A = [('nr-rrc.txConfig', '0', 0),
                                        ('nr-rrc.dmrs_AdditionalPosition', '1', 1),
                                        ('nr-rrc.resourceAllocation', '1', 2),
                                        ('nr-rrc.transformPrecoder', '1', 0),
                                        ('nr-rrc.maxRank', '1', 0)]

# ------ 532 19A BIP CheckPoint--------

pusch_ReceiveReq_SingleTx_mcs27_19A = 'UlData_PuschReceiveReq.grants_item_7.tbSize_bits == 0x00010800 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.ulDmrsConfigType == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.ulDmrsLen == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.startSymbol == 0x00 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols == 0x0c and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.startPrb == 0x0000 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.numOfPrb == 0x006a and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.mcs == 0x1b and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.mcsTable == 0x00 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.antPort == 0x8000 and ' \
                                  'UlData_PuschReceiveReq.grants_item_7.spatialMode == 0x00'

# 531 parameters to modify
MR_NR_CELL_NAME = 'NRCELL-1'
MODIFY_PARA_531_03 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='28'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_531_13 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='11'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_531_17 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='11'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_531_19 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='27'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Open Loop Spatial Multiplexing')
]

MODIFY_PARA_531_27 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Open Loop Spatial Multiplexing')
]

MODIFY_PARA_531_35 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Open Loop Spatial Multiplexing')
]

MODIFY_PARA_532_29 = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL transmission',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission',
        new_value='27'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='actDl256Qam',
        filter_param='Activate 256QAM in DL',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        abbr='dlMimoMode',
        filter_param='Downlink MIMO Mode',
        new_value='2x2 Closed Loop Spatial Multiplexing')
]

# ------ 532 19B X2 CheckPoint--------
srs_Config_SingleTx_19B = [('nr-rrc.srs_ResourceSetId', '0', 0), ('nr-rrc.SRS_ResourceId', '0', 0),
                           ('nr-rrc.resourceType', '0', 0),
                           ('nr-rrc.aperiodicSRS_ResourceTrigger', '1', 0), ('nr-rrc.slotOffset', '2', 0),
                           ('nr-rrc.usage', '1', 0), ('nr-rrc.alpha', '7', 1), ('nr-rrc.p0', '-80', 1),
                           ('nr-rrc.srs_ResourceId', '0', 0),
                           ('nr-rrc.nrofSRS_Ports', '0', 0),
                           ('nr-rrc.transmissionComb', '0', 0), ('nr-rrc.combOffset_n2', '0', 0),
                           ('nr-rrc.cyclicShift_n2', '0', 0),
                           ('nr-rrc.startPosition', '2', 0),
                           ('nr-rrc.repetitionFactor', '0', 0), ('nr-rrc.freqDomainPosition', '0', 0),
                           ('nr-rrc.freqDomainShift', '0', 0), ('nr-rrc.c_SRS', '25', 0), ('nr-rrc.b_SRS', '0', 0),
                           ('nr-rrc.b_hop', '0', 0),
                           ('nr-rrc.groupOrSequenceHopping', '0', 0), ('nr-rrc.sequenceId', '1', 0),
                           ('nr-rrc.csi_RS_Index', '0', 0)]

pusch_freqDomain_Config_SingleTx_19B = [('nr-rrc.txConfig', '0', 0),
                                        ('nr-rrc.dmrs_AdditionalPosition', '1', 1),
                                        ('nr-rrc.resourceAllocation', '1', 1),
                                        ('nr-rrc.transformPrecoder', '1', 0),
                                        ('nr-rrc.maxRank', '1', 0)]

# ------ 532 19B BIP CheckPoint--------
pusch_ReceiveReq_SingleTx_mcs27_19B = 'UlData_PuschReceiveReq.grants_item_15.tbSize_bits == 0x00010800 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.ulDmrsConfigType == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.ulDmrsLen == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.ulDmrsMappingType == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.ulDmrsAddPos == 0x01 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.startSymbol == 0x00 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.numOfPuschSymbols == 0x0c and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.startPrb == 0x0000 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.numOfPrb == 0x006a and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.mcs == 0x1b and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.mcsTable == 0x00 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.antPort == 0x8000 and ' \
                                  'UlData_PuschReceiveReq.grants_item_15.spatialMode == 0x00'

# -------- RRC checkpoint for 531 19B------------
# cell id is 1, thus scrambling ID is 1
nzp_CSI_RS_Config_19B = [('nr-rrc.nzp_CSI_RS_ResourceToAddModList', '5', 0),
                         ('nr-rrc.nzp_CSI_RS_ResourceId', '0', 0),
                         ('nr-rrc.frequencyDomainAllocation', '3', 0),
                         ('nr-rrc.other', '04', 0), ('nr-rrc.nrofPorts', '1', 0),
                         ('nr-rrc.cdm_Type', '1', 0),
                         ('nr-rrc.density', '1', 0), ('nr-rrc.startingRB', '0', 0),
                         ('nr-rrc.nrofRBs', '108', 0),
                         ('nr-rrc.scramblingID', '1', 0)]

# ------------ BIP checkpoint for 531 19A------------------
CsiRsSendReq_19B = 'DlData_CsiRsSendReq.csiRsResources_item_19.density == 0x01 and ' \
                   'DlData_CsiRsSendReq.csiRsResources_item_19.densityDot5PrbLocation == 0x00 and ' \
                   'DlData_CsiRsSendReq.csiRsResources_item_19.startPrb == 0x0000 and ' \
                   'DlData_CsiRsSendReq.csiRsResources_item_19.numOfPrb == 0x006a and ' \
                   'DlData_CsiRsSendReq.csiRsResources_item_19.csiRsConfig == 0x03 and ' \
                   'DlData_CsiRsSendReq.csiRsResources_item_19.antennaStream == 0x03'
