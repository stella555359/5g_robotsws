import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'

CNF_5G_4c = {
    'KPI1a': {'KPI1a_AVG': '475', 'KPI1a_MAX': '535'},  # Calculated value=KPI1a+18cells add 2min
    # 'KPI12': {'KPI12_AVG': '665', 'KPI12_MAX': '695'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '840', 'KPI13_MAX': '870'},  # Calculated value= KPI2a/2c+30
    'KPI3': {'KPI3_AVG': '380', 'KPI3_MAX': '410'},
    'KPI5': '270',
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '360',  # base value120s+NSA mode240s
    # 'KPI11': '830',  # Calculated value=KPI#1a+Additional Gap 200s
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'SW_Download_MAX': '2520',  # Calculated value=32min duration+10min via webem=1920+600
    'KPI2a': {'KPI2a_AVG': '600', 'KPI2a_MAX': '630'},  # Calculated value=KPI2a+18cells add 2min
    'KPI2b': {'KPI2b_AVG': '1020', 'KPI2b_MAX': '1050'},  # Calculated value=KPI2b+18cells add 2min
    'KPI2c': {'KPI2c_AVG': '600', 'KPI2c_MAX': '630'},  # Calculated value=KPI2c+18cells add 2min
    'KPI2d': {'KPI2d_AVG': '1020', 'KPI2d_MAX': '1050'},  # Calculated value=KPI2d+18cells add 2min
    # 'KPI4': {'KPI4_AVG': '2610', 'KPI4_MAX': '3132'},
    'KPI4': '2640',  # Calculated value=SW Download Target+KPI#2cTarget+SW Activation Preparation Time=32min+600s+120s
    'Customer': 'True',
}

CNF_5G_6 = {
    'KPI1a': {'KPI1a_AVG': '690', 'KPI1a_MAX': '720'},
    'KPI12': {'KPI12_AVG': '720', 'KPI12_MAX': '750'},  # Calculated value=KPI1a+30
    'KPI3': {'KPI3_AVG': '630', 'KPI3_MAX': '660'},
    'KPI5': '270',
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI10': '860',  # Calculated value
    # 'KPI11': '890',  # Calculated value
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'SW_Download_MAX': '2400',
    'KPI2a': {'KPI2a_AVG': '870', 'KPI2a_MAX': '900'},
    'KPI2b': {'KPI2b_AVG': '1170', 'KPI2b_MAX': '1200'},
    'KPI2c': {'KPI2c_AVG': '870', 'KPI2c_MAX': '900'},
    'KPI2d': {'KPI2d_AVG': '1170', 'KPI2d_MAX': '1200'},
    # 'KPI4': {'KPI4_AVG': '2520', 'KPI4_MAX': '3024'},
    'KPI4': '3090',  # Calculated value=SW Download Target+KPI#2Target+SW Activation Preparation Time=1800+1170+120
    'Customer': 'False',
}

CNF_5G_9b = {
    'KPI1a': {'KPI1a_AVG': '716', 'KPI1a_MAX': '746'},  # Calculated value=KPI1a+2min+180s
    # 'KPI12': {'KPI12_AVG': '695', 'KPI12_MAX': '725'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '870', 'KPI13_MAX': '900'},  # Calculated value= KPI2a2c+30
    'KPI3': {'KPI3_AVG': '367', 'KPI3_MAX': '397'},
    'KPI5': '270',
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '180',  # base value 120s+multi-core 60s
    # 'KPI11': '860',  # Calculated value
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'SW_Download_MAX': '1920',
    'KPI2a': {'KPI2a_AVG': '630', 'KPI2a_MAX': '660'},  # Calculated value=KPI2a+2min
    'KPI2b': {'KPI2b_AVG': '930', 'KPI2b_MAX': '960'},  # Calculated value=KPI2b+2min
    'KPI2c': {'KPI2c_AVG': '630', 'KPI2c_MAX': '660'},  # Calculated value=KPI2c+2min
    'KPI2d': {'KPI2d_AVG': '930', 'KPI2d_MAX': '960'},  # Calculated value=KPI2d+2min
    # 'KPI4': {'KPI4_AVG': '2640', 'KPI4_MAX': '3168'},
    'KPI4': '2370',  # Calculated value=SW Download Target+KPI#2Target+SW Activation Preparation Time=22min+930s+120s
    'Customer': 'False',
}

CNF_5G_10b = {
    'KPI1a': {'KPI1a_AVG': '399', 'KPI1a_MAX': '429'},  # Calculated value=KPI1a+6cells add 1min
    # 'KPI12': {'KPI12_AVG': '695', 'KPI12_MAX': '725'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '870', 'KPI13_MAX': '900'},  # Calculated value= KPI2a2c+30
    'KPI3': {'KPI3_AVG': '328', 'KPI3_MAX': '358'},
    'KPI5': '270',
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '180',  # base value 120s+multi-core 60s
    # 'KPI11': '860',  # Calculated value
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'SW_Download_MAX': '2640',  # Calculated value=34min duration+10min via webem=2040+600
    'KPI2a': {'KPI2a_AVG': '600', 'KPI2a_MAX': '630'},  # Calculated value=KPI2a+6cells add 1min
    'KPI2b': {'KPI2b_AVG': '960', 'KPI2b_MAX': '990'},  # Calculated value=KPI2b+6cells add 1min
    'KPI2c': {'KPI2c_AVG': '600', 'KPI2c_MAX': '630'},  # Calculated value=KPI2c+6cells add 1min
    'KPI2d': {'KPI2d_AVG': '960', 'KPI2d_MAX': '990'},  # Calculated value=KPI2d+6cells add 1min
    # 'KPI4': {'KPI4_AVG': '2640', 'KPI4_MAX': '3168'},
    'KPI4': '2760',  # Calculated value=SW Download Target+KPI#2cTarget+SW Activation Preparation Time=34min+600s+120s
    'Customer': 'False',
}

CNF_5G_15d = {
    'KPI1a': {'KPI1a_AVG': '357', 'KPI1a_MAX': '387'},  # Calculated value=KPI1a+9cells add 1min
    # 'KPI12': {'KPI12_AVG': '485', 'KPI12_MAX': '515'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '660', 'KPI13_MAX': '690'},  # Calculated value= KPI2a2c+30
    'KPI3': {'KPI3_AVG': '279', 'KPI3_MAX': '309'},
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '160',  # base value 120s+temp additional 40s
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'KPI5': '270',
    'SW_Download_MAX': '1800',  # Calculated value=20min duration+10min via webem=1200+600
    'KPI2a': {'KPI2a_AVG': '420', 'KPI2a_MAX': '450'},  # Calculated value=KPI2a+9cells add 1min
    'KPI2b': {'KPI2b_AVG': '720', 'KPI2b_MAX': '750'},  # Calculated value=KPI2b+9cells add 1min
    'KPI2c': {'KPI2c_AVG': '420', 'KPI2c_MAX': '450'},  # Calculated value=KPI2c+9cells add 1min
    'KPI2d': {'KPI2d_AVG': '720', 'KPI2d_MAX': '750'},  # Calculated value=KPI2d+9cells add 1min
    # 'KPI4': {'KPI4_AVG': '2520', 'KPI4_MAX': '3024'},
    'KPI4': '1740',  # Calculated value=SW Download Target+KPI#2cTarget+SW Activation Preparation Time=20min+420s+120s
    'Customer': 'False',
}

CNF_5G_16c = {
    'KPI1a': {'KPI1a_AVG': '352', 'KPI1a_MAX': '364'},  # Calculated value=KPI1a
    # 'KPI12': {'KPI12_AVG': '665', 'KPI12_MAX': '695'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '840', 'KPI13_MAX': '870'},  # Calculated value= KPI2a/2c+30
    'KPI3': {'KPI3_AVG': '392', 'KPI3_MAX': '422'},
    'KPI5': '270',
    'KPI15': '1800',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '120',  # base value120s
    # 'KPI11': '830',  # Calculated value=KPI#1a+Additional Gap 200s
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'SW_Download_MAX': '2520',  # Calculated value=32min duration+10min via webem=1920+600
    'KPI2a': {'KPI2a_AVG': '360', 'KPI2a_MAX': '390'},  # Calculated value=KPI2a
    'KPI2b': {'KPI2b_AVG': '780', 'KPI2b_MAX': '810'},  # Calculated value=KPI2b
    'KPI2c': {'KPI2c_AVG': '360', 'KPI2c_MAX': '390'},  # Calculated value=KPI2c
    'KPI2d': {'KPI2d_AVG': '780', 'KPI2d_MAX': '810'},  # Calculated value=KPI2d
    # 'KPI4': {'KPI4_AVG': '2610', 'KPI4_MAX': '3132'},
    'KPI4': '2400',  # Calculated value=SW Download Target+KPI#2cTarget+SW Activation Preparation Time=32min+360s+120s
    'Customer': 'False',
}

CNF_5G_23 = {
    'KPI1a': {'KPI1a_AVG': '289', 'KPI1a_MAX': '319'},
    # 'KPI12': {'KPI12_AVG': '485', 'KPI12_MAX': '515'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '450', 'KPI13_MAX': '480'},  # Calculated value= KPI2a2c+30
    'KPI3': {'KPI3_AVG': '283', 'KPI3_MAX': '313'},
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '120',  # base value
    # 'KPI11': '650',  # Calculated value=KPI1a+200
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'KPI5': '270',
    'SW_Download_MAX': '1800',  # Calculated value=20min duration+10min via webem=1200+600
    'KPI2a': {'KPI2a_AVG': '330', 'KPI2a_MAX': '360'},
    'KPI2b': {'KPI2b_AVG': '630', 'KPI2b_MAX': '660'},
    'KPI2c': {'KPI2c_AVG': '330', 'KPI2c_MAX': '360'},
    'KPI2d': {'KPI2d_AVG': '630', 'KPI2d_MAX': '660'},
    # 'KPI4': {'KPI4_AVG': '2520', 'KPI4_MAX': '3024'},
    'KPI4': '1650',  # Calculated value=SW Download Target+KPI#2cTarget+SW Activation Preparation Time=20min+330s+120s
    'Customer': 'False',
}

CNF_5G_26 = {
    'KPI1a': {'KPI1a_AVG': '400', 'KPI1a_MAX': '430'},  # Calculated value=KPI1a+18cells add 2min
    # 'KPI12': {'KPI12_AVG': '665', 'KPI12_MAX': '695'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '840', 'KPI13_MAX': '870'},  # Calculated value= KPI2a/2c+30
    'KPI3': {'KPI3_AVG': '400', 'KPI3_MAX': '430'},
    'KPI5': '300',
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '160',  # base value120s
    # 'KPI11': '830',  # Calculated value=KPI#1a+Additional Gap 200s
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '290',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '290',
    'SW_Download_MAX': '2520',  # Calculated value=32min duration+10min via webem=1920+600
    'KPI2a': {'KPI2a_AVG': '1000', 'KPI2a_MAX': '1000'},  # Calculated value=KPI2a+18cells add 2min
    'KPI2b': {'KPI2b_AVG': '1000', 'KPI2b_MAX': '1000'},  # Calculated value=KPI2b+18cells add 2min
    'KPI2c': {'KPI2c_AVG': '1000', 'KPI2c_MAX': '1000'},  # Calculated value=KPI2c+18cells add 2min
    'KPI2d': {'KPI2d_AVG': '1000', 'KPI2d_MAX': '1000'},  # Calculated value=KPI2d+18cells add 2min
    # 'KPI4': {'KPI4_AVG': '2610', 'KPI4_MAX': '3132'},
    'KPI4': '6000',  # Calculated value=SW Download Target+KPI#2Target+SW Activation Preparation Time=32min+1200s+120s
    'Customer': 'True',
}

CNF_5G_27 = {
    'KPI1a': {'KPI1a_AVG': '800', 'KPI1a_MAX': '800'},
    # 'KPI12': {'KPI12_AVG': '485', 'KPI12_MAX': '515'},  # Calculated value=KPI1a+35
    # 'KPI13': {'KPI13_AVG': '450', 'KPI13_MAX': '480'},  # Calculated value= KPI2a2c+30
    'KPI3': {'KPI3_AVG': '800', 'KPI3_MAX': '800'},
    'KPI15': '40',
    'KPI16a': '40',
    'KPI16b': '40',
    'KPI17a': '10',
    'KPI17b': '10',
    'KPI19': '20',
    'KPI10a': '120',  # base value
    # 'KPI11': '650',  # Calculated value=KPI1a+200
    # 'KPI51a': {'KPI51a_AVG': '240', 'KPI51a_MAX': '288'},
    'KPI51a': '240',
    # 'KPI54a': {'KPI54a_AVG': '240', 'KPI54a_MAX': '288'},
    'KPI54a': '240',
    'KPI5': '270',
    'SW_Download_MAX': '1920',  # Calculated value=22min duration+10min via webem=1320+600
    'KPI2a': {'KPI2a_AVG': '1000', 'KPI2a_MAX': '1000'},
    'KPI2b': {'KPI2b_AVG': '1000', 'KPI2b_MAX': '1000'},
    'KPI2c': {'KPI2c_AVG': '1000', 'KPI2c_MAX': '1000'},
    'KPI2d': {'KPI2d_AVG': '1000', 'KPI2d_MAX': '1000'},
    # 'KPI4': {'KPI4_AVG': '2520', 'KPI4_MAX': '3024'},
    'KPI4': '2000',  # Calculated value=SW Download Target+KPI#2Target+SW Activation Preparation Time=20min+630s+120s
    'Customer': 'True',
}

Configurations = {
    '1ASIL_3ABIO_TDD': CNF_5G_4c,
    '1ASIB_3ABIL_TDD': CNF_5G_6,
    '2ASIB_2ABIO_4ABIL': CNF_5G_10b,
    '1ASOE_TDD': CNF_5G_15d,
    '1ASILL_1ABIOL_TDD': CNF_5G_16c,
    '1ASOF_3AWHQN_TDD': CNF_5G_23,
    '1ASIL_3ABIO_TDD_AZQL': CNF_5G_26,
    '1ASIK_1ABIL_FDD': CNF_5G_27,
}

RUs = {
    'AEQN': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AEQV': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AEQZ': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AEQQ': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AEQY': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AEHC': {'AdjValues': '240', 'AdjValueResetSite': '180', 'AdjValueResetBBMOD': '480',
             'AdjValueCellBlockUnblock': '40', 'AdjValueCellLockUnlock': '40', 'AdjValueCellReset': '40',
             'AdjValueCellLocking': '20', 'AdjValueSWActivation': '180'},
    'AEQP': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AENB': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AZQG': {'AdjValues': '60', 'AdjValueResetSite': '60', 'AdjValueResetBBMOD': '60',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '15',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '60'},
    'AZQL': {'AdjValues': '60', 'AdjValueResetSite': '60', 'AdjValueResetBBMOD': '60',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '15',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '60'},
    'AZQI': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AZQP': {'AdjValues': '240', 'AdjValueResetSite': '150', 'AdjValueResetBBMOD': '240',
             'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '10', 'AdjValueCellReset': '10',
             'AdjValueCellLocking': '10', 'AdjValueSWActivation': '150'},
    'AQQL': {'AdjValues': '120', 'AdjValueResetSite': '120', 'AdjValueResetBBMOD': '120',
             'AdjValueCellBlockUnblock': '20', 'AdjValueCellLockUnlock': '0', 'AdjValueCellReset': '20',
             'AdjValueCellLocking': '30', 'AdjValueSWActivation': '120'},
    'AQQJ': {'AdjValues': '120', 'AdjValueResetSite': '120', 'AdjValueResetBBMOD': '120',
             'AdjValueCellBlockUnblock': '20', 'AdjValueCellLockUnlock': '0', 'AdjValueCellReset': '20',
             'AdjValueCellLocking': '30', 'AdjValueSWActivation': '120'},
    'AWHQN': {'AdjValues': '35', 'AdjValueResetSite': '0', 'AdjValueResetBBMOD': '70',
              'AdjValueCellBlockUnblock': '10', 'AdjValueCellLockUnlock': '0', 'AdjValueCellReset': '10',
              'AdjValueCellLocking': '15', 'AdjValueSWActivation': '0'},
    'AQQQ': {'AdjValues': '120', 'AdjValueResetSite': '120', 'AdjValueResetBBMOD': '120',
             'AdjValueCellBlockUnblock': '20', 'AdjValueCellLockUnlock': '0', 'AdjValueCellReset': '20',
             'AdjValueCellLocking': '30', 'AdjValueSWActivation': '120'},
    'AHPB': {'AdjValues': '120', 'AdjValueResetSite': '120', 'AdjValueResetBBMOD': '120',
             'AdjValueCellBlockUnblock': '20', 'AdjValueCellLockUnlock': '0', 'AdjValueCellReset': '20',
             'AdjValueCellLocking': '30', 'AdjValueSWActivation': '120'},
    'AHPJ': {'AdjValues': '120', 'AdjValueResetSite': '120', 'AdjValueResetBBMOD': '120',
             'AdjValueCellBlockUnblock': '20', 'AdjValueCellLockUnlock': '0', 'AdjValueCellReset': '20',
             'AdjValueCellLocking': '30', 'AdjValueSWActivation': '120'},
}

SFPCooledTransceiver = {
    'true': {'AdjValues': '90'},
}

gNBCuType = {
    'NSA': {'AdjValues': '90'},
    'SA+NSA': {'AdjValues': '90'},
}

AA_01 = {
    'Duration_SCFLoad': '20',
    'Duration_ValidationError': '270',
    'Duration_Validation': '140',
    'Duration_Activation': '600',
}
AA_02 = {
    'Duration_DeltaValidation_succ': '45',
    'Duration_DeltaValidation_error': '75',
    'Duration_Delta_Activation': '45',  # update a parameter in all cells
}
AA_03 = {'SCF_backup_duration': '30'}
AA_04 = {'Duration_DeltaActivation': '600'}
AA_05 = {'Delta_Plan_Provision_Durtion': '110'}
AA_06 = {'Full_Plan_Provision_Durtion': '660'}
AA_07 = {
    'Delta_Plan_PreProvision_Durtion': '60',
    'Delta_Plan_validation_err_Durtion': '70',
    'Delta_Plan_validation_suc_Durtion': '40',
    'Delta_Plan_download_Duration': '20',
}
AA_08 = {'Import_Delta_Plan_Durtion': '20'}
AA_09 = {'Delta_Plan_Provision_Durtion_Reboot': '660'}
AA_10 = {'CMUplod_Durtion': '30'}
AA_11 = {'Duration_ChangeNoti': '27'}
AA_12 = {'Duration_DeltaActivationWithRATReset': '80'}
AA_13 = {'Durtion_Delta_Plan_Provision_With_RAT_Reset': '160'}
BA_01 = {'PM_File_Creation_Time': '60'}
BA_02 = {'Duration_PM_Kept': '180'}
BA_03 = {'PM_MAX_Size': '272.7'}
BA_04 = {'CPU_Jitter': '4 '}
CA_01 = {'alarm_report_time': '60'}
CA_02 = {'Alarm_Upload_Durtion': '120'}
DA_01 = {'snapshot_save_time': '420'}  # 7min=420 for avgerage size,16min=960 for big size
DA_02 = {'FilePresentTime': '420'}  # 7min for avgerage size,16min for big size
DA_03 = {'StartAndStopLtency': '5'}
FA_01 = {'MaxFileSize': '2147483648'}
FA_02 = {'MaxSession': '10'}
FA_03 = {'Duration_Loading_WebEM': '5'}
FA_04 = {'Login_duration_time': '25'}
FA_05 = {'StartupView_Login_duration_time': '30'}
FA_06 = {'RMToolSessionCount': '5'}
FA_07 = {'RMToolRequestLatency': '30'}
FA_08 = {'RMToolConnectionLatency': '30'}
FA_09 = {'RMToolRequestLatencyServerMode': '5'}
SWM_15 = {'DurationOfSwrollback': '540'}
SWM_16 = {'DurationOfSwConfigUpload': '15'}
SWM_12 = {'DurationOfSwPrecheck': '45'}
SWM_13 = {'DurationOfSwPostcheck': '30'}
SWM_17 = {'DurationOfSwCancel': '180'}
SWM_18 = {'DurationOfSwCopyManual': '480'}
SM_01 = {'Max_Duration_of_RAT_Reset': '200'}
SM_02 = {'Max_Duration_of_RU_Reset': '320'}
SM_03 = {'Max_Duration_of_BBMOD_Reset': '180'}
SM_04 = {'Max_Duration_of_Remote_Power_Reset': '360'}
SM_05 = {'Max_Duration_of_ALD_Reset': '120'}
SM_06 = {'Max_Duration_of_Site_Reset': '360'}
SM_07 = {'Max_Duration_of_Cell_Reset': '150'}
SM_08 = {'Max_Duration_of_BBMOD_Power_Reset': '360'}
SM_09 = {'Max_Duration_of_GNSSE_Reset': '120'}

CASE_RESULT_FLIE_PATH = '/home/ute/'

REQUIREMENT_ID = {
    '[1]CB014929_SR_A_01_CM_Delta_Plan_Download_Activation_Operations_No_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2776',
    '[1]CB014929_SR_A_02_CM_Duration_Of_Full_Plan_Download_Validation_Activation': ['OM_GEN_SFS_PERF_CAP.6758',
                                                                                    'OM_GEN_SFS_PERF_CAP.5326',
                                                                                    'OM_GEN_SFS_PERF_CAP.5325',
                                                                                    'OM_GEN_SFS_PERF_CAP.5327'],
    '[1]CB014929_SR_A_03_CM_Delta_Plan_Activation_Operations_Site_Level_Service_Outage': 'OM_GEN_SFS_PERF_CAP.6724',
    '[1]CB014929_SR_A_04_CM_Configuration_File_Backup': 'OM_GEN_SFS_PERF_CAP.6819',
    '[1]CB014929_SR_A_05_CM_Delta_Plan_Validation': ['OM_GEN_SFS_PERF_CAP.2768',
                                                     'OM_GEN_SFS_PERF_CAP.2772',
                                                     'OM_GEN_SFS_PERF_CAP.2774'],
    '[1]CB014929_SR_A_06_CM_Delta_Plan_Pre-Activate_Successful': 'OM_GEN_SFS_PERF_CAP.2770',
    '[1]CB014929_SR_A_07_CM_Delta_Plan_Provision_Operation_No_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2780',
    '[1]CB014929_SR_A_08_CM_Delta_Plan_Provision_Operation_Site_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2786',
    '[1]CB014929_SR_A_09_CM_Full_Config_Plan_Provision': 'OM_GEN_SFS_PERF_CAP.2787',
    '[1]CB014929_SR_A_10_CM_Upload_CM_Configuration': 'OM_GEN_SFS_PERF_CAP.2790',
    '[1]CB014929_SR_A_11_CM_Duration_of_CM_Change_Notification': 'OM_GEN_SFS_PERF_CAP.2792',
    '[1]CB014929_SR_A_43_CM_Duration_of_CM_Activation_Operation_RAT_Level_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2778',
    '[1]CB014929_SR_A_44_CM_Delta_Plan_Provision_Operation_RAT_Level_Service_Outage': 'OM_GEN_SFS_PERF_CAP.2783',

    '[1]CB014929_SR_A_28_Troubleshooting_duration_of_snapshot_collection_manually_trggered': 'OM_GEN_SFS_PERF_CAP.2836',
    '[1]CB014929_SR_A_29_Troubleshooting_duration_of_snapshot_collection_automatically_trggered': [
        'OM_GEN_SFS_PERF_CAP.8574'],
    '[1]CB014929_SR_A_31_Troubleshooting_Maximum_number_of_simultaneous_DCC_user_sessions_in_the_BTS': [
        'OM_GEN_SFS_PERF_CAP.4890'],
    '[1]CB014929_SR_A_32_Troubleshooting_Remote_Syslog_Session_Start_and_Stop_Latency': 'OM_GEN_SFS_PERF_CAP.6847',
    '[1]CB014929_SR_A_33_Troubleshooting_IP_connectivity_test': 'OM_GEN_SFS_PERF_CAP.6964',
    '[1]CB014929_SR_A_34_Troubleshooting_System_Module_Sanity_Checker': 'OM_GEN_SFS_PERF_CAP.10677',

    '[1]CB014929_SR_A_12_SWM_Duration_of_Fully_PreCheck': 'OM_GEN_SFS_PERF_CAP.4674',
    '[1]CB014929_SR_A_13_SWM_Duration_of_PostCheck': 'OM_GEN_SFS_PERF_CAP.12955',
    '[1]CB014929_SR_A_15_SWM_Duration_of_SW_Rollback': 'OM_GEN_SFS_PERF_CAP.2813',
    '[1]CB014929_SR_A_16_SWM_Duration_of_Upload_SW_Configuration': 'OM_GEN_SFS_PERF_CAP.2816',
    '[1]CB014929_SR_A_17_SWM_Duration_of_ Cancel_SW_Management': 'OM_GEN_SFS_PERF_CAP.2864',
    '[1]CB014929_SR_A_18_SWM_Duration_of_Copy_SW_from_Active_to_Passive_Partition_Manually_Triggered': [
        'OM_GEN_SFS_PERF_CAP.18654'],

    '[1]CB014929_SR_A_41_Radio_Network_Integration_Duration_of_Configuration_Reset': 'OM_GEN_SFS_PERF_CAP.13130',
}
