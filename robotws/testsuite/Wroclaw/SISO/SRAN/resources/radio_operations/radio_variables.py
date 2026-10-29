"""
:modified:02.07.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""

__version__ = '1.27'

AIRSCALE_MODULES = ['ASIA', 'ASIB', 'ASIK', 'ASIL', 'ASIM', 'ASOE', 'ASOF', 'ASOG', 'ASOH']

TELNET_MODULES = {'GAIA': ['FXEE', 'FXED', 'FXDD', 'FHDI', 'FRGY', 'FHEL', 'FRHD', 'FRHG', 'FRMF', 'FRGU', 'FRMC',
                           'FRHC', 'FXEF'],
                  'WMP': ['FXJB', 'FXDJ', 'FHDB', 'FXDB', 'FXEB', 'FRGP', 'FXEA', 'FXJC', 'FRIE', 'FHFB', 'FHDB',
                          'FRMB'],
                  'ALU': ['UHFA', 'UHIE']}

RADIO_MODULES = {
    '5_1_4T4R_1NAHKA_1BAND': ['AHEB', 'AHCF', 'AHIB', 'AHGB', 'AHPB', 'AHFB', 'AHCA', 'AHHB', 'AHEH', 'AHNA'],
    '5_1_6T6R_2NAHKA_1BAND': ['ARDA', 'ARCA', 'ARDB', 'ARGA', 'AREA', 'ARPA'],
    '5_1_4T4R_2NAHKA_2BAND': ['AHPDA', 'AHFIG', 'AHLOA', 'AHPCA', 'AHFIB', 'AHBCC', 'AHEGB', 'AHEGC', 'AHLBA', 'AHBCA',
                              'AHFIC', 'AHFIA', 'AHEGF'],
    '5_1_2T4R_1NAHKA_1BAND': ['AHEC', 'AHED', 'AHDB', 'AHDA', 'AHGA', 'AHPE'],
    '5_1_2T4R_1NAHKA_2BAND': ['AHEGA'],
    '5_1_2T4R_1NAHKA_3BAND': ['AHPCDB'],
    '5_1_4T4R_1NAHKA_3BAND': ['AHPMDA', 'AHPMDB', 'AHPMDD'],
    '5_1_2T2R_1NAHKA_2BAND': ['ANEGA'],
    '5_1_16T16R_4NAHKA_1BAND': ['AAIB', 'AAFB'],
    '6_1_8T8R_2MADE_1BAND': ['AZQP', 'AZHL'],  # Scorpio
    '6_2_4T4R_1MADE_2BAND': ['AHEGG', 'AHFII', 'AHLOB'],  # Zodiac
    '6_2_4T4R_1MADE_3BAND': ['AHPMDG'],  # Zodiac
    '6_2_4T4R_2MADE_2BAND': ['AHPDB'],  # Zodiac
    '6_2_4T4R_2MADE_3BAND': ['AHEGHA', 'AHFIHA', 'AHEGSA'],  # Zodiac
    '6_2_8T8R_2MADE_1BAND': ['AKNB'],  # Maverick
    '6_2_4T4R_1MADE_1BAND': ['AWHQN'],  # Maverick
    '8_4T4R_1RAUTU_3BAND': ['AXEGHA'],
    'FHS': ['MDEA', 'MDCD'],
}

# RADIO_MODULES_6_2_PROGRAMS = {'MAVERICK': ['AWHQN', 'AKNB'],
#                               'ZODIAC': ['AHFII', 'AHLOB', 'AHPMDG', 'AHPDB', 'AHEGHA', 'AHFIHA']}

ANTENNA_MAPPING = {
    '5_1_4T4R_1NAHKA_1BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '5_1_6T6R_2NAHKA_1BAND': {'TX': ([1, 2, 3, 4], [5, 6]), 'RX': ([1, 2, 3, 4], [5, 6])},
    '5_1_4T4R_2NAHKA_2BAND': {'TX': ([1, 2], [3, 4]), 'RX': ([1, 2], [3, 4])},
    '5_1_2T4R_1NAHKA_1BAND': {'TX': [1, 3], 'RX': [1, 2, 3, 4]},
    '5_1_2T4R_1NAHKA_2BAND': {'TX': [1, 3], 'RX': [1, 2, 3, 4]},
    '5_1_2T4R_1NAHKA_3BAND': {'TX': [1, 3], 'RX': [1, 2, 3, 4]},
    '5_1_4T4R_1NAHKA_3BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '5_1_2T2R_1NAHKA_2BAND': {'TX': [1, 2], 'RX': [1, 2]},
    '6_1_8T8R_2MADE_1BAND': {'TX': ([1, 2, 3, 4], [5, 6, 7, 8]), 'RX': ([1, 2, 3, 4], [5, 6, 7, 8])},
    '6_2_4T4R_1MADE_2BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '6_2_4T4R_1MADE_1BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '6_2_4T4R_1MADE_3BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
    '6_2_4T4R_2MADE_2BAND': {'TX': ([1, 2], [3, 4]), 'RX': ([1, 2], [3, 4])},
    '6_2_4T4R_2MADE_3BAND': {'TX': ([1, 2], [3, 4]), 'RX': ([1, 2], [3, 4])},
    '6_2_8T8R_2MADE_1BAND': {'TX': ([1, 2, 3, 4], [5, 6, 7, 8]), 'RX': ([1, 2, 3, 4], [5, 6, 7, 8])},
    '8_4T4R_1RAUTU_3BAND': {'TX': [1, 2, 3, 4], 'RX': [1, 2, 3, 4]},
}

CUSTOM_MAPPING = {
    'AHPMDA': {'TXRX': {'FRMON':
                        {'1NAHKA': {'ant1': [1, 2], 'ant2': [3], 'ant3': [4, 5], 'ant4': [6]}},
                        'DAPD':
                            {'1NAHKA': {'ant1': ['1a', '1b'],
                                        'ant2': ['2a'], 'ant3': ['3a', '3b'], 'ant4': ['4a']}}}},
    'AHPMDB': {'TXRX': {'FRMON':
                        {'1NAHKA': {'ant1': [1, 2, 3], 'ant2': [4, 5, 6], 'ant3': [7, 8, 9], 'ant4': [10, 11, 12]}},
                        'DAPD':
                            {'1NAHKA': {'ant1': ['1a', '1b'],
                                        'ant2': ['2a'], 'ant3': ['3a', '3b'], 'ant4': ['4a']}}}},
    'AHPMDG': {'TXRX': {'FRMON':
                        {'1NAHKA': {'ant1': [1, 2, 3], 'ant2': [4, 5, 6], 'ant3': [7, 8, 9], 'ant4': [10, 11, 12]}},
                        'DAPD':
                            {'1NAHKA': {'ant1': ['1a', '1b'],
                                        'ant2': ['2c'], 'ant3': ['3a', '3b'], 'ant4': ['4c']}}}},
    'AHFIC': {'TXRX': {'FRMON':
                       {'1NAHKA': {'ant1': [1], 'ant2': [2], 'ant5': [5], 'ant6': [6]},
                        '2NAHKA': {'ant3': [3], 'ant4': [4], 'ant7': [7], 'ant8': [8]}},
                       'DAPD':
                           {'1NAHKA': {'ant1': ['1a'], 'ant2': ['2a'], 'ant5': ['5a'], 'ant6': ['6a']},
                            '2NAHKA': {'ant3': ['3a'], 'ant4': ['4a'], 'ant7': ['7a'], 'ant8': ['8a']}}}}}

hostname = '192.168.255.1'
username = 'toor4nsn'
password = 'oZPS0POrRieRtu'

cloud_server_username = 'core'
cloud_server_password = 'system123'

RMOD_PASSWORDS = {
    'AZQP': ['serviceuser', 'wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc='],
    'AZHL': ['serviceuser', 'wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc='],
    'AHEGG': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHFII': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHPMDG': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHLOB': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHEGHA': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHFIHA': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHEGSA': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AHPDB': ['serviceuser', 'WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM='],
    'AEHC': ['serviceuser', '7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g='],
    'AKNB': ['serviceuser', 'oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE='],
    'AWHQN': ['serviceuser', 'oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE='],
    'AAFB': [username, password],
    'AAIB': [username, password],
    'MDEA': ['serviceuser', 'Pl(FzaYj5~c5;q'],
    'MDCD': ['serviceuser', 'Pl(FzaYj5~c5;q'],
    'AXEGHA': ['serviceuser', 'kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og='],
}

RMOD_PASSWORDS_RFSW = {
    'AZQP': ['rfsw', '5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ='],
    'AZHL': ['rfsw', '5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ='],
    'AHFII': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHEGG': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHEGG': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHPMDG': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHLOB': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHEGHA': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHFIHA': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHEGSA': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHEGSA': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AHPDB': ['rfsw', '0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA='],
    'AEHC': ['rfsw', 'bdS%ztWG3v7%SjreCVA79wTPb'],
    'AKNB': ['rfsw', 'KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4='],
    'AWHQN': ['rfsw', 'KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4='],
    'AAFB': [username, password],
    'AAIB': [username, password],
    'MDEA': ['serviceuser', 'Pl(FzaYj5~c5;q'],
    'MDCD': ['serviceuser', 'Pl(FzaYj5~c5;q'],
    'AXEGHA': ['serviceuser', 'kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og='],
}
RMOD_PASSWORDS_ROOT = {
    'AZQP': ['root', 'a2%FgSz3$fHmdusap354xujw7a'],
    'AZHL': ['root', 'a2%FgSz3$fHmdusap354xujw7a'],
    'AHEGG': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHFII': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHPMDG': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHLOB': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHEGHA': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHFIHA': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHEGSA': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AHPDB': ['root', '8uweHREj95NFsJVGwL5Vug+sLk5M2miDbPVNV5O3QZw='],
    'AEHC': ['root', 'a2%FgSz3$fHmdusap354xujw7a'],
    'AKNB': ['root', 'I9LzXPHVEqLorL/x0tAG5ztQ/Y8vVmhmlN9LSkVW4CQ='],
    'AWHQN': ['root', 'I9LzXPHVEqLorL/x0tAG5ztQ/Y8vVmhmlN9LSkVW4CQ='],
    'AAFB': [username, password],
    'AAIB': [username, password],
    'MDEA': ['serviceuser', 'Pl(FzaYj5~c5;q'],
    'MDCD': ['serviceuser', 'Pl(FzaYj5~c5;q'],
    'AXEGHA': ['root', 'k2IGHWN15+AiehVHXQ8XKiHjBbD26Bup8GS7/mQljRw='],
}

SUPPORTED_FAULTS = {'5_1': ['1901', '1910', '1911', '1927', '1932', '1933', '1936', '1937', '1938', '1940',
                            '1981', '2928', '2929', '2931', '4658', '4698', '4699', '4700', '4701'],
                    '6_1': ['1901'],
                    '6_2': ['1901', '1907', '1920', '1911', '1932', '1933', '1936', '1937', '1938', '1940', '1981',
                            '4656', '4658', '4698', '6921'],
                    '8': ['1901', '1907', '1911', '1920', '2929', '2928', '6921', '4656', '4658', '4698', '4699',
                          '4700', '4701', '1933', '1937']}

# Unit sensor for trigger FID 1937, Pipe for FID 1927, 1936 and 1938, Device for FID 1940
TEMPERATURE_SENSORS = {'AHPMDA': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a2a:PA']},
                       'AHPMDD': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:PA', 'antenna2c:PA']},
                       'AHPMDB': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:BOARD', 'antenna3a:BOARD']},
                       'AHEB': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:PA'], 'Device': '/rf/pa1'},
                       'AHCA': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:PA', 'antenna2a:PA'], 'Device': '/rf/pa1'},
                       'AAIB': {'Unit': ['module:BOARD'], 'Pipe': ['antenna1a:BOARD'], 'Device': '/temp/pa1'},
                       'AAFB': {'Unit': ['module:BOARD'], 'Pipe': ['antenna1a:BOARD'], 'Device': '/temp/pa1'},
                       'AHEC': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:BOARD']},
                       'AHGB': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:BOARD']},
                       'AHFB': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:BOARD']},
                       'ARCA': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:PA'], 'Device': '/rf/pa1'},
                       'ARGA': {'Unit': ['module:CORE'], 'Pipe': ['antenna1a:PA'], 'Device': '/rf/pa1'},
                       'AHFIA': {'Pipe': ['antenna1a:BOARD'], 'Device': '/rf/pa1'},    # no support for 1937
                       'AHFIB': {'Pipe': ['antenna1a:PA', 'antenna1b:PA'], 'Device': '/rf/pa1'},  # no support for 1937
                       'AHPCA': {'Pipe': ['antenna1a:PA', 'antenna1b:PA', 'antenna2a:PA', 'antenna2b:PA'],
                                 'Device': '/rf/pa1'},  # no support for 1937
                       'AHFII': {'Unit': ['made1:DPD'], 'Device': '/temp/pa1ch1'},
                       'AHEGG': {'Unit': ['made1:DPD'], 'Device': '/temp/pa1ch1'},
                       'AWHQN': {'Unit': ['module:CORE'], 'Device': '/temp/pa1ch1'},
                       'AHPMDG': {'Unit': ['made1:DPD'], 'Pipe': ['made1:RF1'], 'Device': '/temp/pa1ch1'},
                       'AHEGHA': {'Unit': ['made1:DPD'], 'Pipe': ['antenna1a:PA'], 'Device': '/temp/pa1ch1'},
                       'AHLOB': {'Unit': ['made1:JESD'], 'Device': '/temp/pa1ch1'},
                       'AXEGHA': {'Unit': ['uBMU:Temperature'], 'Unit_1933': ['Rautu:Sensor3'],
                                  'Device': ['/CI/TempSensors']}}  # Need to check path
