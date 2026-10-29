from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

tl = BuiltIn().get_variable_value('${tl}')
vDU_DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
vDU_DN_NRBTS = vDU_DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
VDU_DN_NRDU1 = vDU_DN_NRBTS + '/NRDU-1'

vCU_DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id)
vCU_DN_NRBTS = vCU_DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].cu.global_bts_id)
VCU_DN_NRDU1 = vCU_DN_NRBTS + '/NRDU-1'

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
SUPERCELLS = BuiltIn().get_variable_value('${SUPERCELLS}')
REMOVE_CELLS = BuiltIn().get_variable_value('${REMOVE_CELLS}')
SUPERCELL_RMODS = BuiltIn().get_variable_value('${SUPERCELL_RMODS}')

# # only 1 Supercell is allowed, need to remove extra supercell in scf
CU_SCF_DELETE_CELLS = []
for cell_id in REMOVE_CELLS:
    DN_CELL = vCU_DN_NRBTS + '/NRCELL-' + str(cell_id)
    DN_CELLGRP = vCU_DN_NRBTS + '/NRCELLGRP-' + str(cell_id)
    SCF_DELETE_CELL = dict(dist_name=DN_CELL)
    SCF_DELETE_CELLGRP = dict(dist_name=DN_CELLGRP)
    CU_SCF_DELETE_CELLS.extend([SCF_DELETE_CELL, SCF_DELETE_CELLGRP])

CU_SCF_DELETE = CU_SCF_DELETE_CELLS + [
    dict(dist_name=VCU_DN_NRDU1,
         list_name='refNrCellGroup'),
    dict(dist_name=vCU_DN_NRBTS + '/NRCELL-1/NRREL-1')
]

CU_SCF_MODIFY = param_modify_lib.generate_data_based_on_template(
    data_template=data_template.CU_SCF_MODIFY_DISABLE_CIPHER,
    cu_nrbts_dist_name=vCU_DN_NRBTS) + [
    dict(
        dist_name=vCU_DN_MRBTS + '/MNL-1/AMGR-1/LUAC-1',
        p_name='jwtExpirationTime',
        value='60'),
]

CU_SCF_ADD = [
    dict(dist_name=VCU_DN_NRDU1,
         list_name='refNrCellGroup',
         elements=ALL_CELLS
         )
]

# # SCF MODIFY FOR VDU
DU_SCF_DELETE_CELL_MAPPING = [
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1')
]

DU_SCF_DELETE_CELLS = []
for cell_id in REMOVE_CELLS:
    DN_CELL = vDU_DN_NRBTS + '/NRCELL-' + str(cell_id)
    DN_CELLMAPPING = vDU_DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + str(cell_id)
    DN_CELLGRP = vDU_DN_NRBTS + '/NRCELLGRP-' + str(cell_id)
    SCF_DELETE_CELL = dict(dist_name=DN_CELL)
    SCF_DELETE_CELLMAPPING = dict(dist_name=DN_CELLMAPPING)
    SCF_DELETE_CELLGRP = dict(dist_name=DN_CELLGRP)
    DU_SCF_DELETE_CELLS.extend([SCF_DELETE_CELL, SCF_DELETE_CELLMAPPING, SCF_DELETE_CELLGRP])

DU_SCF_DELETE = DU_SCF_DELETE_CELL_MAPPING + DU_SCF_DELETE_CELLS + [
    dict(dist_name=VDU_DN_NRDU1,
         list_name='refNrCellGroup')
]

DU_SCF_ADD_CELL_GRP_IN_DU = [
    dict(dist_name=VDU_DN_NRDU1,
         list_name='refNrCellGroup',
         elements=ALL_CELLS
         )
]

DU_SCF_ADD_CHANNEL_CELL1 = param_modify_lib.generate_parameters_for_channel_group_and_channels_for_scf_modify(
    lcr_id=1,
    list_ru_id=SUPERCELL_RMODS,
    number_of_tx_channel=4,
    number_of_rx_channel=4
)

DU_SCF_ADD = DU_SCF_ADD_CHANNEL_CELL1 + DU_SCF_ADD_CELL_GRP_IN_DU

DU_SCF_MODIFY_ALL_CELL = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_MODIFY_CELL, list_cell_id=SUPERCELLS, dist_name=vDU_DN_NRBTS)

DU_SCF_MODIFY = [
    dict(
        dist_name=vDU_DN_NRBTS + '/NRCELLGRP-1',
        p_name='numberOfTransmittedSsBlocks',
        value='1 beam'),
    dict(
        dist_name=vDU_DN_NRBTS,
        p_name='actBbPoolTddFr1',
        value='true'),
    dict(
        dist_name=vDU_DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh',
        value='true'),
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/AMGR-1/LUAC-1',
        p_name='jwtExpirationTime',
        value='60'),
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm',
        value='5min'),
    dict(
        dist_name=vDU_DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrBeamforming',
        value='5min'),
] + DU_SCF_MODIFY_ALL_CELL
