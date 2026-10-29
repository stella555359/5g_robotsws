# -*- coding: utf-8 -*-
"""
Parameters to change in a default scf file

:copyright: Nokia Networks
:author: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com
:maintainer: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com

"""

__author__ = 'Agnieszka Bylica, Tomasz Krol'
__copyright__ = 'Copyright (C) 2019, Nokia'
__email__ = 'agnieszka.bylica@nokia.com, tomasz.krol@nokia.com'


PARAMS_TO_MODIFY = [
    dict(
        value='5G19/5g_pid14_class_2dl2ul_eoc',
        dist_name='MRBTS-1900/EQM-1/APEQM-1',
        p_name='rapProfile'
    ),
    dict(
        value=5,
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='sCCNumber'
    ),
    dict(
        value=200,
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='pMax'
    ),
    dict(
        value=633334,
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='nrarfcn'
    ),
    dict(
        value=90,
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='prachConfigurationIndex'
    ),
    dict(
        value='sl20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='raResponseWindow'
    ),
    dict(
        value=19,
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='rsrpThresholdSSB'
    ),
    dict(
        value=78,
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='freqBandIndicatorNR'
    ),
    dict(
        value='30 KHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ssbScs'
    ),
    dict(
        value='MRBTS-10/NRBTS-1/TRACKINGAREA-1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='trackingAreaDN'
    ),
    dict(
        value='n25600',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='timingAdvanceOffset'
    ),
    dict(
        value='beamSet_1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='beamSet',
        p_name='basicBeamSet'
    ),
    dict(
        value='30 KHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
        p_name='scs'
    ),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='actAsi'
    ),
    # probably to delete. Should be change by agent5g automatically
    dict(
        value='10.10.40.1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'
    ),
    dict(
        value='10.10.40.1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='localIpAddr'
    ),
    dict(
        value='10.10.40.1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3',
        p_name='localIpAddr'
    ),
    dict(
        value='10.10.40.1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4',
        p_name='localIpAddr'
    )
]

AMOUNT_OF_CELLS = 1
