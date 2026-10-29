__maintainer__ = 'barbier jean-Michel'
__team__ = 'MN 5G RAN I&V 1 Pz 1 SG'
__email__ = 'I_UTE_NPS_5G@internal.nsn.com'
__owner_email__ = 'jean-michel.barbier@nokia.com'


PATH_TO_SCF = ''

# comment
PARAMS_TO_MODIFY = [
    dict(value='5G19/rap/5g_pid11_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='5G19/rap/5g_pid11_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-2', p_name='rapProfile'),
    dict(value='(GMT+1) Europe/Paris', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='(GMT+1) Europe/Paris', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1', p_name='timeZone'),
    dict(
        value='192.168.2.41',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'
    ),
    dict(
        value='192.168.2.42',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='localIpAddr'
    ),
    dict(
        value='192.168.2.60',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3',
        p_name='localIpAddr'
    ),
    dict(
        value='192.168.2.72',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'
    ),
    dict(
        value='192.168.2.71',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='localIpAddr'
    ),
    dict(
        value='192.168.2.70',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-3',
        p_name='localIpAddr'
    ),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRDU-2', p_name='gNbDuId'),
    dict(
        value='NPS CV51 RAP1',
        dist_name='MRBTS-1900/EQM-1/APEQM-1',
        p_name='location'
    ),
    dict(
        value='NPS CV51 RAP2',
        dist_name='MRBTS-1900/EQM-1/APEQM-2',
        p_name='location'
    ),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2',
        p_name='targetDN'
    ),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1',
        p_name='sModDN'
    ),
    dict(value='(GMT+1) Europe/Paris', dist_name='MRBTS-1900/MNL-1/MNLENT-3/SYNC-1/TIME-1', p_name='timeZone'),
    dict(
        value='1pps/ToD from Sync Hub Master',
        dist_name='MRBTS-1900/MNL-1/MNLENT-3/SYNC-1/CLOCK-1',
        p_name='syncInputType'
    ),
    dict(
        value='15min',
        dist_name='MRBTS-1900/MNL-1/PMCADM-1',
        p_name='reportingIntervalPm'
    ),
    dict(
        value='60',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='physCellId'
    ),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-1', p_name='nrCellList', index='0'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', p_name='nrCellList', index='0'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-2',
        dist_name='MRBTS-1900/MNL-1/MNLENT-3',
        p_name='targetDN'
    )
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-1', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-1', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-1', list_name='nrCellList', index=1)
]

PARAMS_TO_ADD = [
    dict(
        value='7',
        dist_name='MRBTS-1900/MNL-1/MNLENT-3/SYNC-1/CLOCK-1',
        p_name='totalDelayFromSHM'
    ),
    dict(
        value='EnabledWithBtsInputReference',
        dist_name='MRBTS-1900/MNL-1/MNLENT-3/SYNC-1/CLOCK-1',
        p_name='outputConfiguration1Pps'
    ),
    dict(
        value='EnabledWithBtsInputReference',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1',
        p_name='outputConfiguration1Pps'
    )
]

AMOUNT_OF_CELLS = 1
