from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
DICT_Cell_IDS_TECH = BuiltIn().get_variable_value('${DICT_Cell_IDS_TECH}')
DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

# get FDD cell index
FDD_CELLS = DICT_Cell_IDS_TECH['FDD']
FDD_CELL_ID = FDD_CELLS[0]
DN_FDDCELL = DN_NRBTS + '/NRCELL-%s' % FDD_CELLS[0]
# DN_CA_REL = DN_FDDCELL + '/NRREL-1'
if 'TDD' in DICT_Cell_IDS_TECH:
    TDD_CELL_ID = None
else:
    TDD_CELL_ID = DICT_Cell_IDS_TECH['TDD']


MODIFY_SCF_7271_BASE = [
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actEnhancedLinkAdaptation'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actFdmScheduling'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actCarrierAggregation'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=DN_FDDCELL,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=DN_FDDCELL,
        p_name='actPdschAtSsbSlots'),
    dict(
        value='longPucch',
        dist_name=DN_FDDCELL,
        p_name='pucchModeSelect'),
    dict(
        value='false',
        dist_name=DN_FDDCELL,
        p_name='actBeamforming'),
    dict(
        value='false',
        dist_name=DN_FDDCELL,
        p_name='actDlMuMimo'),
    dict(
        value='false',
        dist_name=DN_FDDCELL,
        p_name='actUlMuMimo'),
    dict(
        value='96',
        dist_name=DN_FDDCELL,
        p_name='reqMinNumPuschPrb'),
    dict(
        value='true',
        dist_name=DN_FDDCELL,
        p_name='actPrachMultiplexing'),
    dict(
        value='7',
        dist_name=DN_FDDCELL,
        p_name='msg1FrequencyStart'),
    dict(
        value='qpsk_4psk',
        dist_name=DN_FDDCELL,
        p_name='pucchF3ModulationScheme'),
    dict(
        value='zeroDot15',
        dist_name=DN_FDDCELL,
        p_name='pucchF3MaxCodeRate'),
    dict(
        value='slots80',
        dist_name=DN_FDDCELL,
        p_name='srPeriodicity'),
    dict(
        value='slots160',
        dist_name=DN_FDDCELL,
        p_name='csiReportPeriodicity',
        list_name='periodicCsiAcquisition'),
    dict(
        value='-100',
        dist_name=DN_FDDCELL,
        p_name='p0NominalPucchF1F3',
        list_name='ulPowerControlCommon'),
    dict(
        value='0',
        dist_name=DN_FDDCELL,
        p_name='pucchF3DeltaF',
        list_name='ulPowerControlCommon'),
    dict(
        value='-10',
        dist_name=DN_FDDCELL,
        p_name='pucchF1DeltaF',
        list_name='ulPowerControlCommon'),
    dict(
        value='20MHz',
        dist_name=DN_FDDCELL + '/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='20MHz',
        dist_name=DN_FDDCELL + '/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-13',
        dist_name=DN_FDDCELL,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-25',
        dist_name=DN_FDDCELL,
        p_name='bwpDN',
        index='1'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea0',
        value='9'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea1_128',
        value='0'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea2_128',
        value='0'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea3_128',
        value='0'),
    dict(
        value='false',
        dist_name=DN_FDDCELL,
        p_name='actAperCsi'),
    dict(
        value='5min',
        dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCellUtilization'),
]


RESTAPI_DISABLE_2534 = [
    dict(
        dist_name=DN_FDDCELL,
        parameter='actPdschAtSsbSlots',
        value='false'),
    dict(
        dist_name=DN_FDDCELL,
        parameter='actPdschRmCsirsForTracking',
        value='false'),
]

RESTAPI_ENABLE_2534 = [
    dict(
        dist_name=DN_FDDCELL,
        parameter='actPdschAtSsbSlots',
        value='true'),
    dict(
        dist_name=DN_FDDCELL,
        parameter='actPdschRmCsirsForTracking',
        value='true'),
]
