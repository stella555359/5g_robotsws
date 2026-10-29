from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
DICT_Cell_IDS_TECH = BuiltIn().get_variable_value('${DICT_Cell_IDS_TECH}')
DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
DN_MRBTS_GNB1 = 'MRBTS-' + str(tl.gnbs[1].instance_id)
DN_NRBTS_GNB1 = DN_MRBTS_GNB1 + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)

# get TDD cell index
# TDD_CELLS = DICT_Cell_IDS_TECH['TDD']
TDD_CELL_ID = 1
TDD_CELL_ID_GNB1 = 1
DN_TDDCELL = DN_NRBTS + '/NRCELL-%s' % TDD_CELL_ID
DN_TDDCELL_GNB1 = DN_NRBTS_GNB1 + '/NRCELL-%s' % TDD_CELL_ID_GNB1

MODIFY_SCF_8249_COMMON = [
    dict(
        value='RI detection and mitigation',
        dist_name=DN_TDDCELL,
        p_name='actNrRim'),
    dict(
        value='13',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRiMonitorDownhillEndSymbol'),
    dict(
        value='0',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRiMonitorDownhillStartSymbol'),
    dict(
        value='5',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRiMonitorWindow'),
    dict(
        value='dB6',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRimPowerRampingStep'),
    dict(
        value='8dB',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRimRarTpcCommand'),
    dict(
        value='-100',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRiThresBase'),
    dict(
        value='3',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRiThresDropHeight'),
    dict(
        value='50',
        dist_name=DN_TDDCELL + '/NRRIM_PROFILE-1',
        p_name='nrRiThresDurationRatio'),
]

MODIFY_SCF_FRAME_STRUCTURE_1116_3MS = [
    dict(
        value='tdLte',
        dist_name=DN_TDDCELL,
        p_name='frameStructureType'),
    dict(
        value='3ms',
        dist_name=DN_TDDCELL,
        p_name='lteToNrFrameShift'),
    dict(
        value='6Symbols',
        dist_name=DN_TDDCELL,
        p_name='guardPeriodLength'),
    dict(
        value='tdLteConfig2',
        dist_name=DN_TDDCELL,
        p_name='tdLteUlDlConfig'),
    dict(
        value='2/8',
        dist_name=DN_TDDCELL,
        p_name='ulDlDataSlotRatio'),
]

MODIFY_BWP_100M_1116_3MS = [
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-7',
        dist_name=DN_TDDCELL,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-77',
        dist_name=DN_TDDCELL,
        p_name='bwpDN',
        index='1'),
]

MODIFY_SCF_DEFAULT = MODIFY_SCF_8249_COMMON + MODIFY_SCF_FRAME_STRUCTURE_1116_3MS + MODIFY_BWP_100M_1116_3MS

RESTAPI_ENABLE_8249 = [
    dict(
        dist_name=DN_TDDCELL,
        parameter='actNrRim',
        value='RI detection and mitigation'),
]

RESTAPI_DISABLE_8249 = [
    dict(
        dist_name=DN_TDDCELL,
        parameter='actNrRim',
        value='disabled'),
]

MODIFY_SCF_DEFAULT_GNB1 = [
    dict(value=0, dist_name=DN_TDDCELL_GNB1, p_name="targetTotalLoad"),
    dict(value=0, dist_name=DN_TDDCELL_GNB1, p_name="targetTotalLoadSectorBeam"),
    dict(value='PDSCH+PDCCH+TRS+SSB', dist_name=DN_TDDCELL_GNB1, p_name="actConfDlInterferenceGen"),
    dict(value=28, dist_name=DN_TDDCELL_GNB1, p_name="mcsIndexForArtificialLoad"),
    dict(value='enhanced', dist_name=DN_TDDCELL_GNB1, p_name="actDlRbgRandomization"),
]

RESTAPI_MODIFY_TARGET_TOTAL_LOAD = [
    dict(
        value=0,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoad",
    ),
    dict(
        value=100,
        dist_name=DN_TDDCELL_GNB1,
        parameter="targetTotalLoadSectorBeam",
    ),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='actConfDlInterferenceGen',
        value='PDSCH+PDCCH+TRS+SSB'),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='mcsIndexForArtificialLoad',
        value=28),
    dict(
        dist_name=DN_TDDCELL_GNB1,
        parameter='actDlRbgRandomization',
        value='enhanced'),
]
