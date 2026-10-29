__maintainer__ = 'Krzysztof Kulibab'
__team__ = 'MN 5G RAN I&V 3 Pz OAM 5 SG'
__email__ = 'krzysztof.kulibab@nokia.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11_2CC.xml'

PARAMS_TO_MODIFY = [
    dict(value='5G19/rap/5g_pid11_2CC_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value=210, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value=210, dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMax'),
    dict(value=2059000, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value=2060731, dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrarfcn'),
    dict(value='FBB-2', dist_name='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/BBMOD-2', p_name='fbbRef'),
]


AMOUNT_OF_CELLS = 2
