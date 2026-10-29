# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id) + '/LNCEL-1'
MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME5 = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id) + '/NRBTS-1/NRCELL-1'
test_pc = str(tl.test_pc.default_ssh_connection_details.addr)
test_pc_recover = str(tl.gnbs[0].cu.f1m.v4)

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='defaultLnRelGnbCellId', value='0')]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc})]

PARAMS_TO_MODIFY_DomainNumber2 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc})]

PARAMS_TO_MODIFY_DomainNumber3 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc_recover})]

PARAMS_TO_MODIFY_DomainNumber6 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc_recover})]

PARAMS_TO_MODIFY_DomainNumber7 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51001'})]

PARAMS_TO_MODIFY_DomainNumber8 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51000'})]

CELL_1_A5_RSRP_RSRQ = {
    MR_NR_BTS_NAME5: {'a5MeasEnabled': 'rsrpAndRsrq', 'a3MeasEnabled': 'none'}
}

CELL_1_A3_RSRP_RSRQ = {
    MR_NR_BTS_NAME5: {'a3MeasEnabled': 'rsrpAndRsrq', 'a5MeasEnabled': 'none'}
}

CELL_1_A3_RSRP = {
    MR_NR_BTS_NAME5: {'a3MeasEnabled': 'rsrp', 'a5MeasEnabled': 'none'}
}

keywords_list1 = ['TRBLCADM_A-1']
