from robot.libraries.BuiltIn import BuiltIn
from .PCell_selection_and_DistName import *
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical

program = BuiltIn().get_variable_value('${PROGRAM}')
tl = BuiltIn().get_variable_value('${tl}')

NR_CELL_ID_MAPPING = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids()
# to get all the cells under same RU with TDD_CELLS[0], and get their dist names.
# this is for the modification of frame structure, there is limitation that the frame structure of all the cells
# on same RU must be the same.
TDD_CELL_IN_CASE = TDD_CELLS[0]['nrCellId']
LIST_TDD_CELL = coam_gnb_classical.get_all_the_cells_on_same_RU_with_specific_cell(
    source_cell_id=TDD_CELL_IN_CASE, gnb_relation_mapping=NR_CELL_ID_MAPPING)
LIST_DN_TDD_CELL = []
for cell_id in LIST_TDD_CELL:
    DN_TDD_CELL = DN_NRBTS + '/NRCELL-%s' % cell_id
    LIST_DN_TDD_CELL.append(DN_TDD_CELL)

MODIFY_SCF_DEFAULT_BASE = [
    dict(
        value='true',
        dist_name=DN_NRBTS + '/NRDU-1',
        p_name='actInterNumerologyCa'),
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaDu'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrLowRlcReport'),
    dict(
        value='longPucch',
        dist_name=DN_PCELL,
        p_name='pucchModeSelect'),
    dict(
        value='1',
        dist_name=DN_NRBTS,
        p_name='maxNumScellsDl'),
    dict(
        value='0',
        dist_name=DN_NRBTS,
        p_name='maxNumScellsUl'),
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actProactUlScheduling'),
    dict(dist_name=DN_PCELL,
         list_name='periodicCsiAcquisition',
         p_name='csiReportPeriodicity',
         value='slots320'),
    dict(
        dist_name=DN_PCELL,
        p_name='actCDrx',
        value='true'),
    dict(
        dist_name=DN_NRBTS,
        p_name='srbInactivityTimerSA',
        value='600'),
    dict(
        dist_name=DN_NRBTS,
        p_name='drbInactivityTimerSA',
        value='900'),
    dict(
        dist_name=DN_NRBTS + '/SERVEDAMF-1',
        p_name='amfIPAddress',
        value=tl.core.five_g.amf.n2.v4),
    dict(
        dist_name=DN_NRBTS,
        p_name='actHighestEstNrTputBcSel',  # CNI-81817, see detail in REX-14875
        value='true'),
]

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_DEFAULT_BASE = MODIFY_SCF_DEFAULT_BASE + [
        dict(value='disabled', dist_name=DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_DEFAULT_BASE = MODIFY_SCF_DEFAULT_BASE + [
        dict(value='false', dist_name=DN_NRBTS, p_name='actMeasBasedSCellAddition')]

if program == '22R4' or program == '23R1':
    MODIFY_SCF_DEFAULT_BASE = MODIFY_SCF_DEFAULT_BASE + [
        dict(
            dist_name=DN_NRBTS,
            p_name='inactivityTimerSA',
            value='900')]

MODIFY_SCF_NRREL = [
    dict(
        value='blind',
        dist_name=DN_CA_REL,
        p_name='sCellAdditionMethod'),
]

SCF_ENABLE_BF = [
    dict(
        value='true',
        dist_name=DN_TDDCELLS,
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name=DN_TDDCELLS,
        p_name='basicBeamSet',
        list_name='beamSet'),
    dict(
        value='false',
        dist_name=DN_TDDCELLS,
        p_name='nrBtsBeamRefinementP2',
        list_name='beamSet'),
    dict(
        value='2 beams',
        dist_name=DN_TDDCELLS_GRP,
        p_name='numberOfTransmittedSsBlocks')
]

SCF_BLIND_ACT_SCELL = [
    dict(
        value='blind',
        dist_name=DN_NRBTS,
        p_name='sCellActivationMethod'),
    dict(
        value='infinity',
        dist_name=DN_PCELL,
        p_name='sCellDeactivationTimerGNB'),
    dict(
        value='infinity',
        dist_name=DN_SCELL,
        p_name='sCellDeactivationTimerGNB'),

]

SCF_BUFFER_ACT_SCELL = [
    dict(
        value='bufferBased',
        dist_name=DN_NRBTS,
        p_name='sCellActivationMethod'),
    dict(
        value='ms1280',
        dist_name=DN_PCELL,
        p_name='sCellDeactivationTimerGNB'),
    dict(
        value='ms1280',
        dist_name=DN_SCELL,
        p_name='sCellDeactivationTimerGNB'),
]

SCF_DISABLE_CIPHER = [
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
        value='0')
]

SCF_ENABLE_CIPHER = [
    dict(
        dist_name=DN_NRBTS,
        p_name='nea0',
        value='1'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea1_128',
        value='3'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea2_128',
        value='4'),
    dict(
        dist_name=DN_NRBTS,
        p_name='nea3_128',
        value='2')
]

DEL_CA_LIST_SCF = [
    dict(
        dist_name=DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList',
        index='-1'),
]

DEACTIVE_5GC002255_5GC001390_SCF = [
    dict(
        value='false',
        dist_name=DN_NRBTS + '/NRDU-1',
        p_name='actInterNumerologyCa'),
    dict(
        value='none',
        dist_name=DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList',
        index=0)
]

SCF_CSI_PERIOD = [
    dict(
        value='slots80',
        dist_name=DN_PCELL,
        list_name='periodicCsiAcquisition'),
]

SCF_FRAME_STRUCTURE_1208 = []
for cell_dist_name in LIST_DN_TDD_CELL:
    SCF_FRAME_STRUCTURE_1208_NRCELL_i = [
        dict(
            value='semiStatic',
            dist_name=cell_dist_name,
            p_name='frameStructureType'),
        dict(
            value='2Symbols',
            dist_name=cell_dist_name,
            p_name='guardPeriodLength'),
        dict(
            value='',
            dist_name=cell_dist_name,
            p_name='lteToNrFrameShift'),
        dict(
            value='tdLteConfig2',
            dist_name=cell_dist_name,
            p_name='tdLteUlDlConfig'),
        dict(
            value='1/4',
            dist_name=cell_dist_name,
            p_name='ulDlDataSlotRatio'),
        dict(
            value='98',
            dist_name=cell_dist_name,
            p_name='prachConfigurationIndex'),
    ]
    SCF_FRAME_STRUCTURE_1208.extend(SCF_FRAME_STRUCTURE_1208_NRCELL_i)

SCF_FRAME_STRUCTURE_1116_0 = []
for cell_dist_name in LIST_DN_TDD_CELL:
    SCF_FRAME_STRUCTURE_1116_0_NRCELL_i = [
        dict(
            value='tdLte',
            dist_name=cell_dist_name,
            p_name='frameStructureType'),
        dict(
            value='6Symbols',
            dist_name=cell_dist_name,
            p_name='guardPeriodLength'),
        dict(
            value='0ms',
            dist_name=cell_dist_name,
            p_name='lteToNrFrameShift'),
        dict(
            value='tdLteConfig2',
            dist_name=cell_dist_name,
            p_name='tdLteUlDlConfig'),
        dict(
            value='2/8',
            dist_name=cell_dist_name,
            p_name='ulDlDataSlotRatio'),
        dict(
            value='97',
            dist_name=cell_dist_name,
            p_name='prachConfigurationIndex'),
    ]
    SCF_FRAME_STRUCTURE_1116_0.extend(SCF_FRAME_STRUCTURE_1116_0_NRCELL_i)

SCF_FRAME_STRUCTURE_1116_3 = []
for cell_dist_name in LIST_DN_TDD_CELL:
    SCF_FRAME_STRUCTURE_1116_3_NRCELL_i = [
        dict(
            value='tdLte',
            dist_name=cell_dist_name,
            p_name='frameStructureType'),
        dict(
            value='6Symbols',
            dist_name=cell_dist_name,
            p_name='guardPeriodLength'),
        dict(
            value='3ms',
            dist_name=cell_dist_name,
            p_name='lteToNrFrameShift'),
        dict(
            value='tdLteConfig2',
            dist_name=cell_dist_name,
            p_name='tdLteUlDlConfig'),
        dict(
            value='2/8',
            dist_name=cell_dist_name,
            p_name='ulDlDataSlotRatio'),
        dict(
            value='160',
            dist_name=cell_dist_name,
            p_name='prachConfigurationIndex'),
    ]
    SCF_FRAME_STRUCTURE_1116_3.extend(SCF_FRAME_STRUCTURE_1116_3_NRCELL_i)

SCF_CHBW_F10M_T60M = [
    dict(
        value='10MHz',
        dist_name=DN_FDDCELLS + '/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='13',
        dist_name=DN_FDDCELLS,
        p_name='msg1FrequencyStart'),
    dict(
        value='10MHz',
        dist_name=DN_FDDCELLS + '/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='60MHz',
        dist_name=DN_TDDCELLS,
        p_name='chBw'),
    dict(
        value='0',
        dist_name=DN_TDDCELLS,
        p_name='msg1FrequencyStart'),
]

SCF_CHBW_F20M_T100M = [
    dict(
        value='20MHz',
        dist_name=DN_FDDCELLS + '/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='20MHz',
        dist_name=DN_FDDCELLS + '/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='100MHz',
        dist_name=DN_TDDCELLS,
        p_name='chBw'),
    dict(
        value='13',
        dist_name=DN_FDDCELLS,
        p_name='msg1FrequencyStart'),
    dict(
        value='17',
        dist_name=DN_TDDCELLS,
        p_name='msg1FrequencyStart'),
]
