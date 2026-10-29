__maintainer__ = 'Bartlomiej Lebda'
__team__ = 'I_5GSC_5G_PZ1_WRO_6_GMS'
__email__ = 'I_5GSC_5G_PZ1_WRO_6@internal.nsn.com'


PATH_TO_SCF = '/tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf' \
              '/5G19/5gClassicalBTS/SBTS5G19_5g_pid12_classical.xml'


PARAMS_TO_MODIFY = [
    dict(value='5G19/5g_pid12_class_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='623333', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn')
]

AMOUNT_OF_CELLS = 1
