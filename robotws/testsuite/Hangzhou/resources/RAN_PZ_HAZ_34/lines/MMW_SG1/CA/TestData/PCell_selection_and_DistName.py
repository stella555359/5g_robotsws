from robot.libraries.BuiltIn import BuiltIn
import logging

tl = BuiltIn().get_variable_value('${tl}')

# define in commission/<testline>/__init__.py
ca_group_list = BuiltIn().get_variable_value('${ca_group_list}')
F_T_ALLOCATION = BuiltIn().get_variable_value('${F_T_ALLOCATION}')

if type(ca_group_list) is dict:
    CA_GROUP_TYPE = BuiltIn().get_variable_value('${CA_GROUP_TYPE}')
    if CA_GROUP_TYPE is None:
        CA_GROUP_TYPE = 'F+T'
    else:
        CA_GROUP_TYPE = CA_GROUP_TYPE
    ca_group_list = ca_group_list[CA_GROUP_TYPE]
else:
    CA_GROUP_TYPE = 'F+T'

ca_group_num = len(ca_group_list)
DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
PCELL_LIST = []
SCELL_LIST = []
DN_PCELL_LIST = []
DN_SCELL_LIST = []
DN_PCELL_GRP_LIST = []
DN_SCELL_GRP_LIST = []
for i in range(ca_group_num):
    PCELL = ca_group_list[i]['pcell']
    SCELL = ca_group_list[i]['scell']
    DN_PCELL = DN_NRBTS + '/NRCELL-%s' % PCELL['nrCellId']
    DN_SCELL = DN_NRBTS + '/NRCELL-%s' % SCELL['nrCellId']
    DN_PCELL_GRP = DN_NRBTS + '/NRCELLGRP-%s' % PCELL['nrCellGrpId']
    DN_SCELL_GRP = DN_NRBTS + '/NRCELLGRP-%s' % SCELL['nrCellGrpId']
    PCELL_LIST.append(PCELL)
    SCELL_LIST.append(SCELL)
    DN_PCELL_LIST.append(DN_PCELL)
    DN_SCELL_LIST.append(DN_SCELL)
    DN_PCELL_GRP_LIST.append(DN_PCELL_GRP)
    DN_SCELL_GRP_LIST.append(DN_SCELL_GRP)

# define in test suite
CA_GROUP_INDEX = BuiltIn().get_variable_value('${CA_GROUP_INDEX}')
if CA_GROUP_INDEX is None:
    CA_GROUP_INDEX = 0
else:
    CA_GROUP_INDEX = int(CA_GROUP_INDEX)
PCELL_ID = PCELL_LIST[CA_GROUP_INDEX]['nrCellId']
SCELL_ID = SCELL_LIST[CA_GROUP_INDEX]['nrCellId']
PCELLNRCELLGRPID = ca_group_list[CA_GROUP_INDEX]['pcell']['nrCellGrpId']
SCELLNRCELLGRPID = ca_group_list[CA_GROUP_INDEX]['scell']['nrCellGrpId']
DN_PCELL = DN_NRBTS + '/NRCELL-%s' % PCELL_ID
DN_SCELL = DN_NRBTS + '/NRCELL-%s' % SCELL_ID
DN_PCELL_GRP = DN_NRBTS + '/NRCELLGRP-%s' % PCELLNRCELLGRPID
DN_SCELL_GRP = DN_NRBTS + '/NRCELLGRP-%s' % SCELLNRCELLGRPID
DN_PCELL_HOIF = DN_PCELL + '/NRHOIF-1'
DN_CA_REL = DN_PCELL + '/NRREL-1'

TDD_CELLS = F_T_ALLOCATION['TDD']
FDD_CELLS = F_T_ALLOCATION['FDD']
DN_TDDCELLS = DN_NRBTS + '/NRCELL-%s' % TDD_CELLS[0]['nrCellId']
DN_FDDCELLS = DN_NRBTS + '/NRCELL-%s' % FDD_CELLS[0]['nrCellId']
DN_TDDCELLS_GRP = DN_NRBTS + '/NRCELLGRP-%s' % TDD_CELLS[0]['nrCellGrpId']
DN_FDDCELLS_GRP = DN_NRBTS + '/NRCELLGRP-%s' % FDD_CELLS[0]['nrCellGrpId']
DN_FDDCELL_HOIF = DN_FDDCELLS + '/NRHOIF-1'
DN_TDDCELL_HOIF = DN_TDDCELLS + '/NRHOIF-1'
DN_FDD_CA_REL = DN_FDDCELLS + '/NRREL-1'
DN_TDD_CA_REL = DN_TDDCELLS + '/NRREL-1'
