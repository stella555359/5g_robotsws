import os

CFG_DIR = os.path.dirname(os.path.abspath(__file__))


PARAMS_TO_MODIFY_886_D01 = [
    dict(
        value='true',
        dist_name='NRBTS-37',
        parameter='actInactDetNSAUe'),
    dict(
        value='5',
        dist_name='NRBTS-37',
        parameter='nsaInactivityTimer'),
    dict(
        value='true',
        dist_name='NRBTS-37',
        parameter='actMultiDrbNSA')
]

PARAMS_TO_MODIFY_886_C03 = [
    dict(
        value='true',
        dist_name='NRBTS-37',
        parameter='actMultiDrbNSA'),
    dict(
        value='70',
        dist_name='NRBTS-37',
        parameter='periodicalDataUsageReportTimer')
]
