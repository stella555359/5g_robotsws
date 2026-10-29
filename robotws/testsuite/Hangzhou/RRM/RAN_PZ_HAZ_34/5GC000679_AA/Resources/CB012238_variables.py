import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime


tl = BuiltIn().get_variable_value('${tl}')
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

spark_ip = tl.ues[0].ssh_connection_details.addr
spark_port = 30999
appserver = tl.ues[0].iperf_details.network_interface_address
appserver_username = tl.ues[0].iperf_details.ssh_connection_details.username
appserver_password = tl.ues[0].iperf_details.ssh_connection_details.password

ENB_BRANCH = BuiltIn().get_variable_value("${target_version.split('_', )[0]}")

COUNTERS = ['M55910C00001', 'M55910C00002', 'M55910C00003', 'M55910C00004', 'M55308C10013', 'M55308C10012']
UNIQUE_PATH = [
    ('NRCELL-10', 'NRRESOURCEGROUP-1', 'NCUPNRG', 'M55910C00001'),
    ('NRCELL-10', 'NRRESOURCEGROUP-1', 'NCUPNRG', 'M55910C00002'),
    ('NRCELL-10', 'NRRESOURCEGROUP-1', 'NCUPNRG', 'M55910C00003'),
    ('NRCELL-10', 'NRRESOURCEGROUP-1', 'NCUPNRG', 'M55910C00004'),
    ('NRCELL-10', 'NRRESOURCEGROUP-2', 'NCUPNRG', 'M55910C00001'),
    ('NRCELL-10', 'NRRESOURCEGROUP-2', 'NCUPNRG', 'M55910C00002'),
    ('NRCELL-10', 'NRRESOURCEGROUP-2', 'NCUPNRG', 'M55910C00003'),
    ('NRCELL-10', 'NRRESOURCEGROUP-2', 'NCUPNRG', 'M55910C00004'),
    ('NRCELL-10', 'NCELA', 'M55308C10013'),
    ('NRCELL-10', 'NCELA', 'M55308C10012'),
]
CB008600_COUNTERS = ['M55138C00075', 'M55138C00076', 'M55139C00034', 'M55139C00035', 'M55138C01001', 'M55138C01002',
                     'M55139C00501', 'M55139C00502', 'M55138C01003', 'M55138C00077', 'M55139C00503', 'M55139C00036',
                     'M55139C00504', 'M55139C00037']
CB008600_PATH = [
    ('NRCELL-10', 'RSACU', 'M55138C00075'),
    ('NRCELL-10', 'RSACU', 'M55138C00076'),
    ('NRCELL-10', 'RSACU', 'M55138C00077'),
    ('NRCELL-10', 'RSACU', 'M55138C01001'),
    ('NRCELL-10', 'RSACU', 'M55138C01002'),
    ('NRCELL-10', 'RSACU', 'M55138C01003'),
    ('NRCELL-10', 'RSADU', 'M55139C00034'),
    ('NRCELL-10', 'RSADU', 'M55139C00035'),
    ('NRCELL-10', 'RSADU', 'M55139C00036'),
    ('NRCELL-10', 'RSADU', 'M55139C00037'),
    ('NRCELL-10', 'RSADU', 'M55139C00501'),
    ('NRCELL-10', 'RSADU', 'M55139C00502'),
    ('NRCELL-10', 'RSADU', 'M55139C00503'),
    ('NRCELL-10', 'RSADU', 'M55139C00504'),
]
CB008118_COUNTERS = ['M55138C01001', 'M55138C01002', 'M55139C00501', 'M55139C00502']
CB008118_PATH = [
    ('NRCELL-10', 'RSACU', 'M55138C01001'),
    ('NRCELL-10', 'RSACU', 'M55138C01002'),
    ('NRCELL-10', 'RSADU', 'M55139C00501'),
    ('NRCELL-10', 'RSADU', 'M55139C00502'),
]
CNI140147_COUNTERS = ['M55138C00025', 'M55138C00026']
CNI140147_PATH = [
    ('NRCELL-2', 'RSACU', 'M55138C00025'),
    ('NRCELL-2', 'RSACU', 'M55138C00026')
]
