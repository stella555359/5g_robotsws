# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id) + '/LNCEL-1'
MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME4 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-1'
MR_NR_BTS_NAME5 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-3'
MR_NR_BTS_NAME6 = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id) + '/NRBTS-1/NRCELL-1'

test_pc = str(tl.test_pc.default_ssh_connection_details.addr)
test_pc_recover = str(tl.gnbs[0].cu.f1m.v4)

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='defaultLnRelGnbCellId', value='0')]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc})]

PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='cbraPreamblesPerSsb', value='n48')]

PARAMS_TO_MODIFY_DomainNumber3 = [dict(dist_name=MR_NR_BTS_NAME5, parameter='cbraPreamblesPerSsb', value='n48')]

PARAMS_TO_MODIFY_DomainNumber4 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='cbraPreamblesPerSsb', value='n64')]

PARAMS_TO_MODIFY_DomainNumber5 = [dict(dist_name=MR_NR_BTS_NAME5, parameter='cbraPreamblesPerSsb', value='n64')]

PARAMS_TO_MODIFY_DomainNumber6 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc_recover})]

PARAMS_TO_MODIFY_DomainNumber7 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51001'})]

rsrp_combined_1 = {
    MR_NR_BTS_NAME6: {'a5MeasEnabled': 'rsrpCombined', 'a3MeasEnabled': 'none'}
}

a3OffsetSsbRsrp = {
    MR_NR_BTS_NAME6: {'a3MeasEnabled': 'rsrpAndRsrq', 'a5MeasEnabled': 'none',
                      'a3MeasSsbRsrp': [{'a3OffsetSsbRsrp': '4'}]}
}

keywords_list1 = ['TRBLCADM_A-1']
