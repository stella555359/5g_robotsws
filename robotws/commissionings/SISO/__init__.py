__maintainer__ = 'Dawid Urbanski'
__team__ = 'SISO team'
__email__ = 'dawid.1.urbanski@nokia.com'

# path to SCF file on gNb to be modified and commissioned
PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11_abil_l2rt.xml'

# parameters with new values
PARAMS_TO_MODIFY = [
    dict(value='5G19/5g_pid11_abil_l2rt_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='38', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
]

# Managed Objects to delete
PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1')
]


AMOUNT_OF_CELLS = 1
