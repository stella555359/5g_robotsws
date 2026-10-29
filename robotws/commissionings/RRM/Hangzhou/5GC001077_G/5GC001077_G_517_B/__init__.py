import os

# from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
#  Common scf modify part quote 5GC001077_G_517_A/__init__.py

#         1077_G_517_B_307 308 309 310 312 205 206 207 208 are the same which contains in MODIFY_SCF_1077_G_517_B_OLLA
#         ulla parameter:
#         ullaDeltaSinrMax = 15
#         ullaBlerTarget (0.1)
#         ullaDeltaSinrMin (-3.0)
#         ullaDeltaSinrStepDown (0.25)
#         ullaIniMcs (0)

#         dlla parameter:
#         dllaDeltaCqiMax = 15
#         dllaBlerTarget (0.1)
#         dllaDeltaCqiMin (-3.0)
#         dllaDeltaCqiStepDown (0.25)
#         dllaIniMcs (0)

#         1116 frame


MODIFY_SCF_1077_G_517_B_OLLA = [
    # 1116 frame structure
    dict(
        value='tdLte',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='97',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='prachConfigurationIndex'),
    # 1077_G_517_B_UL_OLLA
    dict(
        value='150',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaDeltaSinrMax'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaBlerTarget'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaDeltaSinrMin'),
    dict(
        value='500',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaDeltaSinrStepdown'),
    # 1077_G_517_B_DL_OLLA
    dict(
        value='150',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaDeltaCqiMax'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaBlerTarget'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaDeltaCqiMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaDeltaCqiStepdown')
]


MODIFY_SCF_1077_G_517_B_LA = [
    # 1116 frame structure
    dict(
        value='tdLte',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='97',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='prachConfigurationIndex'),
    # 1077_G_517_B_UL_OLLA_enhance_ability_to_decrease_MCS
    dict(
        value='-150',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaDeltaSinrMin'),
    dict(
        value='500',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaDeltaSinrStepdown')
]
