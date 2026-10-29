import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

ENB_BRANCH = BuiltIn().get_variable_value("${ENB_BRANCH}")

CB011039_CheckPoint = [
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
                       {'Check point': 'Radio Module ethernet link',
                        'ID': '21',
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
                        'Trigger type': 'WebEM'},
                       {'Check point': 'Extended RU DDR tests',
                        'ID': '43',
                        'Last execution result': 'NotExecuted',
                        'Radio module': 'RMOD_R-1',
                        'Trigger type': 'WebEM'}
                      ]

CB011039_CheckPoint10_NOK = [
                             {'Check point': 'Online Input Voltage on Radio Module',
                              'ID': '10',
                              'Last execution result': 'NOK',
                              'Radio module': 'RMOD_R-1',
                              'Trigger type': 'WebEM'}
                            ]
