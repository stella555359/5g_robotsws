import os

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'

PARAMS_TO_MODIFY_FEATURE_TC_A = [
    dict(value='true', dist_name=_NRBTSname, p_name='nullFallback'),
]

ADD_EIF2_OBJECT = [
    dict(class_name='com.nokia.srbts.tnl:ETHLK',
         dist_name='TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2', version='TNL5GC19A_1904_002'),
    dict(class_name='com.nokia.srbts.tnl:BRGPRT',
         dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2',
         version='TNL5GC19A_1904_002'),
]

PARAMS_TO_ADD_EIF2_OBJECT = [
    dict(value='locked', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2',
         p_name='administrativeState'),
    dict(value='EIF2', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2',
         p_name='connectorLabel'),
    dict(value='1000000', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2',
         p_name='l2IngressRate'),
    dict(value='MRBTS-37/EQM-1/APEQM-1/CABINET-1/SMOD-1',
         dist_name='TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2', p_name='modDN'),
    dict(value='AUTODETECT', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2',
         p_name='speedAndDuplex'),
    dict(value='ADMIT_ALL',
         dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2',
         p_name='acceptableFrameTypes'),
    dict(value='MRBTS-37/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2',
         dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2', p_name='ethlkDN'),
    dict(value='false', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2',
         p_name='flushFdbOnLos'),
    dict(value='4096', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2',
         p_name='l2BurstSize'),
    dict(value='1000000', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2',
         p_name='l2ShaperRate'),
    dict(value='1', dist_name='TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2',
         p_name='portDefaultVlanId'),
]

PARAMS_TO_ADD_EIF2 = [
    ADD_EIF2_OBJECT,
    PARAMS_TO_ADD_EIF2_OBJECT
]
