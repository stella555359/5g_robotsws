# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'

parameter_remote = [dict(dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig',
                         value=[{'remoteSyslogServerIPaddress': '10.57.157.237',
                                 'remoteSyslogServerPortNo': '51000'}])]

keywords_list1 = ['TRBLCADM_A-1']

list_index = [0]
