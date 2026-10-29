from robot.libraries.BuiltIn import BuiltIn
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical

tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
TDD_cell = BuiltIn().get_variable_value('${TDD_CELL_ID}')
nrCellGrpId = BuiltIn().get_variable_value('${nrCellGrpId}')

NR_CELL_ID_MAPPING = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids()
# to get all the cells under same RU with TDD_CELLS[0], and get their dist names.
# this is for the modification of frame structure, there is limitation that the frame structure of all the cells
# on same RU must be the same.
LIST_TDD_CELL = coam_gnb_classical.get_all_the_cells_on_same_RU_with_specific_cell(
    source_cell_id=TDD_cell, gnb_relation_mapping=NR_CELL_ID_MAPPING)
LIST_DN_TDD_CELL = []
for cell_id in LIST_TDD_CELL:
    DN_TDD_CELL = MR_NR_BTS_NAME + '/NRCELL-%s' % cell_id
    LIST_DN_TDD_CELL.append(DN_TDD_CELL)

# online modify parameters
MODIFY_PRACH_INDEX_0 = [
    dict(
        value='0',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_1 = [
    dict(
        value='1',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_2 = [
    dict(
        value='2',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_3 = [
    dict(
        value='3',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_4 = [
    dict(
        value='4',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_5 = [
    dict(
        value='5',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_6 = [
    dict(
        value='6',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_7 = [
    dict(
        value='7',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_12 = [
    dict(
        value='12',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_14 = [
    dict(
        value='14',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_17 = [
    dict(
        value='17',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_19 = [
    dict(
        value='19',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_98 = [
    dict(
        value='98',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_9 = [
    dict(
        value='9',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_GNB_1348 = [
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='actPrachMultiplexing')
]

MODIFY_GNB_BEAMSET_4 = [
    dict(
        value=[dict(basicBeamSet='beamSet_4')],
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='beamSet'),
    dict(
        value='4 beams',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-' + str(nrCellGrpId),
        parameter='numberOfTransmittedSsBlocks'),
    dict(
        value='2',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_GNB_BEAMSET_2 = [
    dict(
        value=[dict(basicBeamSet='beamSet_2')],
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='beamSet'),
    dict(
        value='2 beams',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-' + str(nrCellGrpId),
        parameter='numberOfTransmittedSsBlocks'),
    dict(
        value='1',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_GNB_BEAMSET_1 = [
    dict(
        value=[dict(basicBeamSet='beamSet_1')],
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='beamSet'),
    dict(
        value='1 beam',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-' + str(nrCellGrpId),
        parameter='numberOfTransmittedSsBlocks'),
    dict(
        value='0',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

MODIFY_PRACH_INDEX_97 = [
    dict(
        value='97',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(TDD_cell),
        parameter='prachConfigurationIndex')
]

# SCF parameters
MODIFY_1070 = []
for cell_dist_name in LIST_DN_TDD_CELL:
    SCF_FRAME_STRUCTURE_1070_NRCELL_i = [
        dict(
            value='true',
            dist_name=cell_dist_name,
            p_name='actBeamforming'),
        dict(
            value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' +
                  str(tl.gnbs[0].global_bts_id) + '/BWP_PROFILE-6',
            dist_name=cell_dist_name,
            p_name='bwpDN',
            index='0'),
        dict(
            value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' +
                  str(tl.gnbs[0].global_bts_id) + '/BWP_PROFILE-61',
            dist_name=cell_dist_name,
            p_name='bwpDN',
            index='1'),
        dict(
            value='semiStatic',
            dist_name=cell_dist_name,
            p_name='frameStructureType'),
        dict(
            value='2Symbols',
            dist_name=cell_dist_name,
            p_name='guardPeriodLength'),
        dict(
            value='3/7',
            dist_name=cell_dist_name,
            p_name='ulDlDataSlotRatio'),
        dict(
            value='',
            dist_name=cell_dist_name,
            p_name='lteToNrFrameShift'),
        dict(
            value='',
            dist_name=cell_dist_name,
            p_name='tdLteUlDlConfig'),
        dict(
            value='0',
            dist_name=cell_dist_name,
            p_name='lteToNrTimeOffset'),
        dict(
            value='3',
            dist_name=cell_dist_name,
            p_name='prachConfigurationIndex')
    ]
    MODIFY_1070.extend(SCF_FRAME_STRUCTURE_1070_NRCELL_i)

MODIFY_1116_3 = []
for cell_dist_name in LIST_DN_TDD_CELL:
    SCF_FRAME_STRUCTURE_1116_3_NRCELL_i = [
        dict(
            value='true',
            dist_name=cell_dist_name,
            p_name='actBeamforming'),
        dict(
            value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' +
                  str(tl.gnbs[0].global_bts_id) + '/BWP_PROFILE-8',
            dist_name=cell_dist_name,
            p_name='bwpDN',
            index='0'),
        dict(
            value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' +
                  str(tl.gnbs[0].global_bts_id) + '/BWP_PROFILE-81',
            dist_name=cell_dist_name,
            p_name='bwpDN',
            index='1'),
        dict(
            value='tdLte',
            dist_name=cell_dist_name,
            p_name='frameStructureType'),
        dict(
            value='4Symbols',
            dist_name=cell_dist_name,
            p_name='guardPeriodLength'),
        dict(
            value='3ms',
            dist_name=cell_dist_name,
            p_name='lteToNrFrameShift'),
        dict(
            value='30',
            dist_name=cell_dist_name,
            p_name='lteToNrTimeOffset'),
        dict(
            value='3',
            dist_name=cell_dist_name,
            p_name='prachConfigurationIndex')
    ]
    MODIFY_1116_3.extend(SCF_FRAME_STRUCTURE_1116_3_NRCELL_i)


MODIFY_1116_0 = []
for cell_dist_name in LIST_DN_TDD_CELL:
    SCF_FRAME_STRUCTURE_1116_0_NRCELL_i = [
        dict(
            value='true',
            dist_name=cell_dist_name,
            p_name='actBeamforming'),
        dict(
            value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' +
                  str(tl.gnbs[0].global_bts_id) + '/BWP_PROFILE-7',
            dist_name=cell_dist_name,
            p_name='bwpDN',
            index='0'),
        dict(
            value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' +
                  str(tl.gnbs[0].global_bts_id) + '/BWP_PROFILE-71',
            dist_name=cell_dist_name,
            p_name='bwpDN',
            index='1'),
        dict(
            value='tdLte',
            dist_name=cell_dist_name,
            p_name='frameStructureType'),
        dict(
            value='4Symbols',
            dist_name=cell_dist_name,
            p_name='guardPeriodLength'),
        dict(
            value='0ms',
            dist_name=cell_dist_name,
            p_name='lteToNrFrameShift'),
        dict(
            value='0',
            dist_name=cell_dist_name,
            p_name='lteToNrTimeOffset')
    ]
    MODIFY_1116_0.extend(SCF_FRAME_STRUCTURE_1116_0_NRCELL_i)
