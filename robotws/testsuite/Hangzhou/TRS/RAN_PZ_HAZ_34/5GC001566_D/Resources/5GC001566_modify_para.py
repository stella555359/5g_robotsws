import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

bfdSrc_IpAddrDN = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1'
bfdSrc_IpAddrDN_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1'
bfd_distname = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPAPP-1/BFD-1'
bfd_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPAPP-1/BFD-1'
IPV6_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1'
TNL_R_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TNL_R-1'
IPAPP_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPAPP-1'
IPRT_distname_8 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'
itemlist = 'itemList'

Trigger_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-1'
Trigger_distname_2 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-2'
IPRT_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'
IPRT_distname_2 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRT-2'
Trigger_distname_8 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-8'
Trigger_distname_1_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-1/TRIGGER_R-1'
Trigger_distname_8_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-8/TRIGGER_R-1'

PARAMS_IPAPP = [
    dict(operation='update', parameterName='ipAppId', value='1'),
]

PARAMS_IPAPP_1 = [
    dict(operation='update', parameterName='ipAppId', value='1'),
]

PARAMS_BFD = [
    dict(operation='update', parameterName='bfdActivation', value='true'),
    dict(operation='update', parameterName='bfdAdminUp', value='true'),
    dict(operation='update', parameterName='bfdDestIpAddr', value='10.57.181.42'),
    dict(operation='update', parameterName='bfdDetectMult', value='3'),
    dict(operation='update', parameterName='bfdDscp', value='48'),
    dict(operation='update', parameterName='bfdId', value='1'),
    dict(operation='update', parameterName='bfdSrcIpAddrDN', value=bfdSrc_IpAddrDN),
    dict(operation='update', parameterName='bfdSrcUdpPort', value='3784'),
    dict(operation='update', parameterName='bfdType', value='singleHopBFD'),
    dict(operation='update', parameterName='desMinTxInt', value='500'),
    dict(operation='update', parameterName='reqMinRxInt', value='500')
]

PARAMS_BFD_1 = [
    dict(operation='update', parameterName='bfdActivation', value='true'),
    dict(operation='update', parameterName='bfdAdminUp', value='true'),
    dict(operation='update', parameterName='bfdDestIpAddr', value='10.101.53.1'),
    dict(operation='update', parameterName='bfdDetectMult', value='3'),
    dict(operation='update', parameterName='bfdDscp', value='48'),
    dict(operation='update', parameterName='bfdId', value='1'),
    dict(operation='update', parameterName='bfdSrcIpAddrDN', value=bfdSrc_IpAddrDN_1),
    dict(operation='update', parameterName='bfdSrcUdpPort', value='3784'),
    dict(operation='update', parameterName='bfdType', value='singleHopBFD'),
    dict(operation='update', parameterName='desMinTxInt', value='500'),
    dict(operation='update', parameterName='reqMinRxInt', value='500')
]

PARAMS_BFD_2 = [
    dict(operation='update', parameterName='bfdActivation', value='true'),
    dict(operation='update', parameterName='bfdAdminUp', value='true'),
    dict(operation='update', parameterName='bfdDestIpAddr', value='10.101.53.1'),
    dict(operation='update', parameterName='bfdDetectMult', value='3'),
    dict(operation='update', parameterName='bfdDscp', value='48'),
    dict(operation='update', parameterName='bfdId', value='1'),
    dict(operation='update', parameterName='bfdSrcIpAddrDN', value=bfdSrc_IpAddrDN_1),
    dict(operation='update', parameterName='bfdSrcUdpPort', value='3784'),
    dict(operation='update', parameterName='bfdType', value='singleHopBFD'),
    dict(operation='update', parameterName='desMinTxInt', value='700'),
    dict(operation='update', parameterName='reqMinRxInt', value='500')
]

PARAMS_BFD_3 = [
    dict(operation='update', parameterName='bfdActivation', value='true'),
    dict(operation='update', parameterName='bfdAdminUp', value='false'),
    dict(operation='update', parameterName='bfdDestIpAddr', value='10.101.53.1'),
    dict(operation='update', parameterName='bfdDetectMult', value='3'),
    dict(operation='update', parameterName='bfdDscp', value='48'),
    dict(operation='update', parameterName='bfdId', value='1'),
    dict(operation='update', parameterName='bfdSrcIpAddrDN', value=bfdSrc_IpAddrDN_1),
    dict(operation='update', parameterName='bfdSrcUdpPort', value='3784'),
    dict(operation='update', parameterName='bfdType', value='singleHopBFD'),
    dict(operation='update', parameterName='desMinTxInt', value='1000'),
    dict(operation='update', parameterName='reqMinRxInt', value='1000')
]

PARAMS_BFD_Addr = [
    dict(operation='update', parameterName='bfdDestIpAddr', value='10.101.53.1')
]

PARAMS_BFD_Addr_1 = [
    dict(operation='update', parameterName='bfdDestIpAddr', value='10.57.243.65')
]

PARAMS_TRIGGER_1 = [
    dict(operation='update', parameterName='false2TrueDelay', value='10'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='1')
]

PARAMS_TRIGGER_2 = [
    dict(operation='update', parameterName='false2TrueDelay', value='20'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='2')
]

PARAMS_TRIGGER_8 = [
    dict(operation='update', parameterName='false2TrueDelay', value='1'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname_1}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='8')
]

PARAMS_TRIGGER_9 = [
    dict(operation='update', parameterName='false2TrueDelay', value='1'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='9')
]

PARAMS_staticRoutes_1 = [
    {"destinationIpPrefixLength": '0',
     "destIpAddr": '0.0.0.0',
     "gateway": '10.57.228.97'
     },
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '20.0.0.0',
     "gateway": '10.57.243.129',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500',
     "triggerDN": Trigger_distname_1
     }
]

PARAMS_staticIpv6Routes_1 = [
    {
        "destinationIpv6PrefixLength": "0",
        "destIpv6Addr": "::",
        "gatewayIpv6Addr": "2A00:8A00:6000:607c::5B01",
        "preference": "1",
        "preSrcIpv6Addr": "::",
        "routeIpMtu": "1500",
        "triggerDN": Trigger_distname_8
     }
]

PARAMS_staticRoutes_2 = [
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '20.0.0.0',
     "gateway": '10.101.53.1',
     "preference": '1',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500',
     "triggerDN": Trigger_distname_2
     },
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '20.0.0.0',
     "gateway": '10.101.53.9',
     "preference": '2',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500'
     }
]

PARAMS_staticRoutes_3 = [
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '10.0.0.0',
     "gateway": '10.57.228.97'
     },
    {"destinationIpPrefixLength": '0',
     "destIpAddr": '0.0.0.0',
     "gateway": '10.57.243.129',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500',
     "triggerDN": Trigger_distname_1
     }
]

PARAMS_staticRoutes_8 = [
    dict(destinationIpPrefixLength='8', destIpAddr='10.0.0.0', gateway='10.101.48.65'),
    dict(destinationIpPrefixLength='32', destIpAddr='20.0.0.0', gateway='10.101.53.1',
         preSrcIpv4Addr='0.0.0.0', routeIpMtu='1500', triggerDN=Trigger_distname_8)
]

PARAMS_staticRoutes_8_8 = [
    dict(destinationIpPrefixLength='8', destIpAddr='10.0.0.0', gateway='10.101.48.65'),
    dict(destinationIpPrefixLength='32', destIpAddr='20.0.0.0', gateway='10.101.53.1',
         preSrcIpv4Addr='0.0.0.0', routeIpMtu='1500')
]

PARAMS_recover_staticRoutes_1 = [
    {"destinationIpPrefixLength": '0',
     "destIpAddr": '0.0.0.0',
     "gateway": '10.57.228.97'
     },
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '20.0.0.0',
     "gateway": '10.57.243.129',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500'
     }
]

PARAMS_IPRT_1 = [
    dict(operation='update', parameterName='ipRtId', value='1'),
    dict(operation='update', parameterName='staticRoutes', value=PARAMS_staticRoutes_1)
]

PARAMS_IPRT_2 = [
    dict(operation='update', parameterName='ipRtId', value='2'),
    dict(operation='update', parameterName='staticRoutes', value=PARAMS_staticRoutes_2)
]

PARAMS_IPRT_ROUTE3 = [
    dict(operation='update', parameterName='ipRtId', value='1'),
    dict(operation='update', parameterName='staticRoutes', value=PARAMS_staticRoutes_3)
]

PARAMS_TRIGGER = [
    dict(operation='update', parameterName='false2TrueDelay', value='1'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='1')
]

PARAMS_IPRT_8 = [
    dict(operation='update', parameterName='ipRtId', value='1'),
    dict(operation='update', parameterName='staticRoutes', value=PARAMS_staticRoutes_8)
]
