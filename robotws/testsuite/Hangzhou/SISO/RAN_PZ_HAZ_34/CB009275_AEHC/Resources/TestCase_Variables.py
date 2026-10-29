# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
SOURCE_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)


Case_11039_CheckPoint_OK = [
    {'Check point': 'Online Input Voltage on Radio Module',
     'ID': '10',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'Radio Module Temperature Supervision',
     'ID': '18',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'Radio Module FAN',
     'ID': '26',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'RU SW package and NVM integrity',
     'ID': '40',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'RU Memory usage',
     'ID': '41',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'RU Temperature sensor',
     'ID': '42',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'}
]

Case_11039_CheckPoint10_NOK = [
    {'Check point': 'Online Input Voltage on Radio Module',
     'ID': '10',
     'Last execution result': 'NOK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'Radio Module Temperature Supervision',
     'ID': '18',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'Radio Module FAN',
     'ID': '26',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'RU SW package and NVM integrity',
     'ID': '40',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'RU Memory usage',
     'ID': '41',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'},
    {'Check point': 'RU Temperature sensor',
     'ID': '42',
     'Last execution result': 'OK',
     'Radio module': 'RMOD_R-1',
     'Trigger type': 'WebEM'}
]

radio_checkpoints = {
    "RMOD-1 / RMOD_R-1 (AEHC)": [
        '10 - Online Input Voltage on Radio Module',
        '18 - Radio Module Temperature Supervision',
        '26 - Radio Module FAN',
        '41 - RU Memory usage',
        '42 - RU Temperature sensor'
    ]
}
