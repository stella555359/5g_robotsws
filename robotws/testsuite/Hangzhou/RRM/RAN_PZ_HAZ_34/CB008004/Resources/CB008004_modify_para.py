# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NECELL1_DistName_GNB = MR_NR_BTS_NAME + '/NRCELL-1'

dist_remoteSyslog = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
uteIP = str(tl.test_pc.default_ssh_connection_details.addr)


structure_para = [
     dict(dist_name=dist_remoteSyslog, parameter='remoteSyslogConfig',
          value=[{"remoteSyslogServerHost": uteIP,
                  "remoteSyslogServerPortNo": '51000',
                  "remoteSyslogDSCP": '34',
                  "remoteSyslogFormat": 'RFC5424',
                  "remoteSyslogTransmitDuration": '240',
                  "remoteSyslogTransportProtocol": 'UDP'}])]
