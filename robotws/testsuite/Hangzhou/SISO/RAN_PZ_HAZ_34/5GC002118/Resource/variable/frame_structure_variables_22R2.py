dist_name = ''
list_name = 'tddFrameStructure'
Expect_Rate = 0.7
Duration = 30

PARAMS_TO_MODIFY_SCF_20_1208_GP1_A1 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='20MHz'),
        dict(
            dist_name=dist_name,
            p_name='frequencyDensityThresNrb1',
            value='277'),
        dict(
            dist_name=dist_name,
            p_name='type0CoresetConfigurationIndex',
            value='10'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_20_1208_GP1_A1 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_20_1208_GP1_A1,
                            'Peak_Tput_DL': '270M',  # support M or G
                            'Peak_Tput_UL': '11.8M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_20_1070_GP1_A3 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='20MHz'),
        dict(
            dist_name=dist_name,
            p_name='frequencyDensityThresNrb1',
            value='277'),
        dict(
            dist_name=dist_name,
            p_name='type0CoresetConfigurationIndex',
            value='10'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='3/7',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_20_1070_GP1_A3 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_20_1070_GP1_A3,
                            'Peak_Tput_DL': '226M',  # support M or G
                            'Peak_Tput_UL': '18.5M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_20_1116_3ms_GP1_A5 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='20MHz'),
        dict(
            dist_name=dist_name,
            p_name='frequencyDensityThresNrb1',
            value='277'),
        dict(
            dist_name=dist_name,
            p_name='type0CoresetConfigurationIndex',
            value='10'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='30')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='4Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='3ms'))]}
Band_Tput_20_1116_3ms_GP1_A5 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_20_1116_3ms_GP1_A5,
                                'Peak_Tput_DL': '262M',  # support M or G
                                'Peak_Tput_UL': '11.8M',  # support M or G
                                'Expect_Rate': Expect_Rate,
                                'Duration': Duration}

PARAMS_TO_MODIFY_SCF_40_1208_GP1_A1 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='40MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_40_1208_GP1_A1 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_40_1208_GP1_A1,
                            'Peak_Tput_DL': '562M',  # support M or G
                            'Peak_Tput_UL': '24M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_40_1070_GP1_A3 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='40MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='3/7',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_40_1070_GP1_A3 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_40_1070_GP1_A3,
                            'Peak_Tput_DL': '471M',  # support M or G
                            'Peak_Tput_UL': '38.3M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_40_1116_3ms_GP1_A5 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='40MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='30')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='4Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='3ms'))]}
Band_Tput_40_1116_3ms_GP1_A5 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_40_1116_3ms_GP1_A5,
                                'Peak_Tput_DL': '546M',  # support M or G
                                'Peak_Tput_UL': '24.4M',  # support M or G
                                'Expect_Rate': Expect_Rate,
                                'Duration': Duration}

PARAMS_TO_MODIFY_SCF_60_1208_GP1_A1 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='60MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_60_1208_GP1_A1 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_60_1208_GP1_A1,
                            'Peak_Tput_DL': '960M',  # support M or G
                            'Peak_Tput_UL': '38M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_60_1070_GP1_A3 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='60MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='3/7',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_60_1070_GP1_A3 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_60_1070_GP1_A3,
                            'Peak_Tput_DL': '720M',  # support M or G
                            'Peak_Tput_UL': '60M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_60_1116_3ms_GP1_A5 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='60MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='30')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='4Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='3ms'))]}
Band_Tput_60_1116_3ms_GP1_A5 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_60_1116_3ms_GP1_A5,
                                'Peak_Tput_DL': '834M',  # support M or G
                                'Peak_Tput_UL': '38M',  # support M or G
                                'Expect_Rate': Expect_Rate,
                                'Duration': Duration}

PARAMS_TO_MODIFY_SCF_60_1116_0ms_GP2_A7 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='60MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='97'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='0')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='6Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='0ms'))]}
Band_Tput_60_1116_0ms_GP2_A7 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_60_1116_0ms_GP2_A7,
                                'Peak_Tput_DL': '834M',  # support M or G
                                'Peak_Tput_UL': '32.5M',  # support M or G
                                'Expect_Rate': Expect_Rate,
                                'Duration': Duration}

PARAMS_TO_MODIFY_SCF_80_1208_GP1_A1 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='80MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_80_1208_GP1_A1 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_80_1208_GP1_A1,
                            'Peak_Tput_DL': '1.148G',  # support M or G
                            'Peak_Tput_UL': '50M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_80_1070_GP1_A3 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='80MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='3/7',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_80_1070_GP1_A3 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_80_1070_GP1_A3,
                            'Peak_Tput_DL': '960M',  # support M or G
                            'Peak_Tput_UL': '79M',  # support M or G
                            'Expect_Rate': Expect_Rate,
                            'Duration': Duration}

PARAMS_TO_MODIFY_SCF_80_1116_3ms_GP1_A5 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='100MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='30')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='4Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='3ms'))]}
Band_Tput_80_1116_3ms_GP1_A5 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_80_1116_3ms_GP1_A5,
                                'Peak_Tput_DL': '1.114G',  # support M or G
                                'Peak_Tput_UL': '43M',  # support M or G
                                'Expect_Rate': Expect_Rate,
                                'Duration': Duration}

PARAMS_TO_MODIFY_SCF_80_1116_0ms_GP2_A7 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='80MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='97'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='0')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='6Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='0ms'))]}
Band_Tput_80_1116_0ms_GP2_A7 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_80_1116_0ms_GP2_A7,
                                'Peak_Tput_DL': '1.114G',  # support M or G
                                'Peak_Tput_UL': '43M',  # support M or G
                                'Expect_Rate': Expect_Rate,
                                'Duration': Duration}

PARAMS_TO_MODIFY_SCF_100_1208_GP1_A1 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='100MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_100_1208_GP1_A1 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_80_1208_GP1_A1,
                             'Peak_Tput_DL': '1460M',  # support M or G
                             'Peak_Tput_UL': '63M',  # support M or G
                             'Expect_Rate': Expect_Rate,
                             'Duration': Duration}

PARAMS_TO_MODIFY_SCF_100_1070_GP1_A3 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='100MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='semiStatic',
                ulDlDataSlotRatio='3/7',
                guardPeriodLength='2Symbols',
                tdLteUlDlConfig='tdLteConfig2'))]}
Band_Tput_100_1070_GP1_A3 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_100_1070_GP1_A3,
                             'Peak_Tput_DL': '1.22G',  # support M or G
                             'Peak_Tput_UL': '99M',  # support M or G
                             'Expect_Rate': Expect_Rate,
                             'Duration': Duration}

PARAMS_TO_MODIFY_SCF_100_1116_3ms_GP1_A5 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='100MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='98'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='30')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='4Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='3ms'))]}
Band_Tput_100_1116_3ms_GP1_A5 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_100_1116_3ms_GP1_A5,
                                 'Peak_Tput_DL': '1.412G',  # support M or G
                                 'Peak_Tput_UL': '63M',  # support M or G
                                 'Expect_Rate': Expect_Rate,
                                 'Duration': Duration}

PARAMS_TO_MODIFY_SCF_100_1116_0ms_GP2_A7 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='100MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='97'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='0')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='6Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='0ms'))]}
Band_Tput_100_1116_0ms_GP2_A7 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_100_1116_0ms_GP2_A7,
                                 'Peak_Tput_DL': '1.412G',  # support M or G
                                 'Peak_Tput_UL': '54M',  # support M or G
                                 'Expect_Rate': Expect_Rate,
                                 'Duration': Duration}
PARAMS_TO_MODIFY_SCF_100_1116_0ms_GP1_A8 = {
    "p_under": [
        dict(
            dist_name=dist_name,
            p_name='chBw',
            value='100MHz'),
        dict(
            dist_name=dist_name,
            p_name='timingAdvanceOffset',
            value='n25600'),
        dict(
            dist_name=dist_name,
            p_name='prachConfigurationIndex',
            value='194'),
        dict(
            dist_name=dist_name,
            p_name='lteToNrTimeOffset',
            value='0')],
    "list_under": [
        dict(
            dist_name=dist_name,
            list_name=list_name,
            elements=dict(
                frameStructureType='tdLte',
                ulDlDataSlotRatio='1/4',
                guardPeriodLength='4Symbols',
                tdLteUlDlConfig='tdLteConfig2',
                lteToNrFrameShift='0ms'))]}
Band_Tput_100_1116_0ms_GP1_A8 = {'Modify_Params': PARAMS_TO_MODIFY_SCF_100_1116_0ms_GP1_A8,
                                 'Peak_Tput_DL': '1.357G',  # support M or G
                                 'Peak_Tput_UL': '63.1M',  # support M or G
                                 'Expect_Rate': Expect_Rate,
                                 'Duration': Duration}
