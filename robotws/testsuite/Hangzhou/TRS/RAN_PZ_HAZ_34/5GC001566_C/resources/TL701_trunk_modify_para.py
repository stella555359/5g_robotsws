import os
from robot.libraries.BuiltIn import BuiltIn


tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

bfd_distname = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPAPP-1/BFD-1'
Trigger_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-1'

PARAMS_staticRoutes_11 = [
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '10.0.0.0',
     "gateway": '10.57.236.225'
     },
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '20.0.0.0',
     "gateway": '10.57.243.65',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500',
     "triggerDN": Trigger_distname_1
     }
]

PARAMS_TRIGGER = [
    dict(operation='update', parameterName='false2TrueDelay', value='1'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='1')
]


sync_1577_info_1 = [[True, 'Available', 'Usable', 1, '1pps/ToD from external GNSS receiver']]

sync_1577_info_2 = [[True, 'Available', 'Usable', 1, 'TOPP']]

sync_2377_info_1 = [[True, 'Available', 'Usable', 1, 'TOPP'],
                    [False, 'Available', 'Usable', 2, '1pps/ToD from external GNSS receiver']]

sync_2377_info_2 = [[True, 'Available', 'Usable', 1, '1pps/ToD from external GNSS receiver'],
                    [False, 'Available', 'Usable', 2, 'TOPP']]
