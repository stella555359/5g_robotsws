import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'

PARAMS_TO_MODIFY_2037_A6 = [
    dict(value='5GC002037_A6_TA', dist_name='MRBTS-5', p_name='btsName'),
    dict(value='true', dist_name='MRBTS-5/NRBTS-5', p_name='actMultVlan'),

    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-3', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-4', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-5', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-6', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-7', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-8', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-9', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-10', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-11', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-12', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-13', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-14', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-15', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-16', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-17', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-18', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-19', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-20', p_name='nrPlmnDN'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpAddr'),
    dict(value='29', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.5', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-6',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.6', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-6', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-6', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-7',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.7', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-7', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-7', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-8',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.8', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-8', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-8', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-9',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.9', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-9', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-9', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-10',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.10', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-10', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-10', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-11',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.11', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-11', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-11', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-12',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.12', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-12', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-12', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-13',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.13', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-13', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-13', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-14',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.14', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-14', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-14', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-15',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.15', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-15', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-15', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-16',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.16', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-16', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-16', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-17',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.17', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-17', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-17', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-18',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.18', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-18', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-18', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-19',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.19', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-19', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-19', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-20',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.8.8.20', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-20', p_name='localIpAddr'),
    dict(value='27', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-20', p_name='localIpPrefixLength'),


    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.57.131.218', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='29', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2', p_name='localIpPrefixLength'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-3',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.57.131.222', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-3', p_name='localIpAddr'),
    dict(value='29', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-3', p_name='localIpPrefixLength'),

    dict(value='21', dist_name='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-21', p_name='vlanId'),
    dict(value='22', dist_name='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-22', p_name='vlanId'),

    dict(value='2000', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1', p_name='ipMtu'),
    dict(value='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-21', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2',
         p_name='interfaceDN'),
    dict(value='1500', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2', p_name='ipMtu'),
    dict(value='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-22',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3', p_name='interfaceDN'),
    dict(value='1500', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3', p_name='ipMtu'),

]

PARAMS_TO_DELETE_2037_A6 = [
]

ADD_MOs_2037_A6 = [
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-3',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-4',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-5',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-6',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-7',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-8',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-9',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-10',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-11',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-12',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-13',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-14',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-15',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-16',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-17',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-18',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-19',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-20',
         version='NRBTSCL5G20B_2010_100'),


    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-3',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-6',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-7',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-8',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-9',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-10',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-11',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-12',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-13',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-14',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-15',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-16',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-17',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-18',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-19',
         version='NRBTSCL5G20B_2008_200'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-20',
         version='NRBTSCL5G20B_2008_200'),

    dict(class_name='com.nokia.srbts.tnl:VLANIF',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-21',
         version='TNL5GC20B_2009_001'),
    dict(class_name='com.nokia.srbts.tnl:VLANIF',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-22',
         version='TNL5GC20B_2009_001'),

    dict(class_name='com.nokia.srbts.tnl:IPIF',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2',
         version='TNL5GC20B_2009_001'),
    dict(class_name='com.nokia.srbts.tnl:IPIF',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3',
         version='TNL5GC20B_2009_001'),

    dict(class_name='com.nokia.srbts.tnl:IPRT',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-2',
         version='TNL5GC20B_2009_001'),
    dict(class_name='com.nokia.srbts.tnl:IPRT',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-3',
         version='TNL5GC20B_2009_001'),

]

ADD_TO_List_2037_A6 = [
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='operatorSpecificQCIList', elements=['128']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2', list_name='operatorSpecificQCIList', elements=['129']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-3', list_name='operatorSpecificQCIList', elements=['130']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-3', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-3')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-4', list_name='operatorSpecificQCIList', elements=['131']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-4', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-5', list_name='operatorSpecificQCIList', elements=['132']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-5', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-6', list_name='operatorSpecificQCIList', elements=['133']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-6', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-6')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-7', list_name='operatorSpecificQCIList', elements=['134']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-7', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-7')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-8', list_name='operatorSpecificQCIList', elements=['135']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-8', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-8')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-9', list_name='operatorSpecificQCIList', elements=['136']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-9', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-9')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-10', list_name='operatorSpecificQCIList', elements=['137']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-10', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-10')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-11', list_name='operatorSpecificQCIList', elements=['138']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-11', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-11')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-12', list_name='operatorSpecificQCIList', elements=['139']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-12', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-12')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-13', list_name='operatorSpecificQCIList', elements=['140']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-13', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-13')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-14', list_name='operatorSpecificQCIList', elements=['141']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-14', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-14')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-15', list_name='operatorSpecificQCIList', elements=['142']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-15', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-15')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-16', list_name='operatorSpecificQCIList', elements=['143']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-16', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-16')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-17', list_name='operatorSpecificQCIList', elements=['144']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-17', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-17')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-18', list_name='operatorSpecificQCIList', elements=['145']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-18', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-18')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-19', list_name='operatorSpecificQCIList', elements=['146']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-19', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-19')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-20', list_name='operatorSpecificQCIList', elements=['147']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-20', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-20')),

    dict(dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-2', list_name='staticRoutes',
         elements=dict(destinationIpPrefixLength='32', destIpAddr='10.57.153.66', gateway='10.57.131.217',
                       routeIpMtu='1450')),
    dict(dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-3', list_name='staticRoutes',
         elements=dict(destinationIpPrefixLength='32', destIpAddr='10.57.153.98', gateway='10.57.131.221',
                       routeIpMtu='1450')),

    dict(dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1', list_name='routingPolicies',
         elements=dict(orderNumber='2', routingTableDN='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-2',
                       srcIpAddress='10.57.131.217',
                       srcIpPrefixLength='32')),
    dict(dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1', list_name='routingPolicies',
         elements=dict(orderNumber='3', routingTableDN='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-3',
                       srcIpAddress='10.57.131.221',
                       srcIpPrefixLength='32')),

]

# ########################################### modify 2037_A8 SCF ##############################################
PARAMS_TO_MODIFY_2037_A8 = [
    dict(value='5GC002037_A8_TA', dist_name='MRBTS-5', p_name='btsName'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', p_name='nrPlmnDN'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-2', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2', p_name='nrPlmnDN'),

    dict(value='262', dist_name='MRBTS-5/NRBTS-5/NRPLMN-2', p_name='mcc'),
    dict(value='3', dist_name='MRBTS-5/NRBTS-5/NRPLMN-2', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-5/NRBTS-5/NRPLMN-2', p_name='mncLength'),

]

PARAMS_TO_DELETE_2037_A8 = [
]

ADD_MOs_2037_A8 = [
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.nrbts:NRPLMN', dist_name='MRBTS-5/NRBTS-5/NRPLMN-2',
         version='NRBTSCL5G20B_2010_100'),
]

ADD_TO_List_2037_A8 = [
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='operatorSpecificQCIList', elements=['128']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')),

    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2', list_name='operatorSpecificQCIList', elements=['129']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-2', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')),

]

# ########################################### modify 2037_A12 SCF ##############################################
PARAMS_TO_MODIFY_2037_A12 = [
    dict(value='5GC002037_A12_TA', dist_name='MRBTS-5', p_name='btsName'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', p_name='nrPlmnDN'),
    dict(value='true', dist_name='MRBTS-5/NRBTS-5', p_name='actNsaSlice'),
    dict(value='100', dist_name='MRBTS-5/NRBTS-5', p_name='nsaInactivityTimer'),

]

PARAMS_TO_DELETE_2037_A12 = [
]

ADD_MOs_2037_A12 = [
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1',
         version='NRBTSCL5G20B_2010_100'),

]

ADD_TO_List_2037_A12 = [
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='operatorSpecificQCIList', elements=['129']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')),

]

# ########################################### modify 2037_A27 SCF ##############################################
PARAMS_TO_MODIFY_2037_A27 = [
    dict(value='5GC002037_A27_TA', dist_name='MRBTS-5', p_name='btsName'),
    dict(value='MRBTS-5/NRBTS-5/NRPLMN-1', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', p_name='nrPlmnDN'),
    dict(value='true', dist_name='MRBTS-5/NRBTS-5', p_name='actNsaSlice'),
    dict(value='100', dist_name='MRBTS-5/NRBTS-5', p_name='nsaInactivityTimer'),

    dict(value='MANUAL', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2',
         p_name='ipAddressAllocationMethod'),
    dict(value='10.57.131.218', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='29', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2', p_name='localIpPrefixLength'),

    # dict(value='21', dist_name='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-21', p_name='vlanId'),
    dict(value='2000', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-1', p_name='ipMtu'),
    dict(value='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-21',
         dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2', p_name='interfaceDN'),
    dict(value='1500', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2', p_name='ipMtu'),
    dict(value='5min', dist_name='MRBTS-5/TNLSVC-1/TNL-1/PMTNL-1', p_name='vlanStatisticsInterval'),
    dict(value='true', dist_name='MRBTS-5/NRBTS-5', p_name='actMultVlan'),
]

PARAMS_TO_DELETE_2037_A27 = [
]

ADD_MOs_2037_A27 = [
    dict(class_name='com.nokia.srbts.nrbts:NRNWSLICE_NSA', dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1',
         version='NRBTSCL5G20B_2010_100'),
    dict(class_name='com.nokia.srbts.tnl:IPADDRESSV4', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2',
         version='NRBTSCL5G20B_2008_200'),
    # dict(class_name='com.nokia.srbts.tnl:VLANIF', dist_name='MRBTS-5/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-21',
    #      version='TNL5GC20B_2009_001'),
    dict(class_name='com.nokia.srbts.tnl:IPIF', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2',
         version='TNL5GC20B_2009_001'),
    dict(class_name='com.nokia.srbts.tnl:IPRT', dist_name='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPRT-2',
         version='TNL5GC20B_2009_001'),

]

ADD_TO_List_2037_A27 = [
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='operatorSpecificQCIList', elements=['129']),
    dict(dist_name='MRBTS-5/NRBTS-5/NRNWSLICE_NSA-1', list_name='s1Uplane',
         elements=dict(ipV4AddressDN1='MRBTS-5/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-2')),

    dict(dist_name='MRBTS-1414/TNLSVC-1/TNL-1/IPNO-1/IPRT-2', list_name='staticRoutes',
         elements=dict(destinationIpPrefixLength='32', destIpAddr='10.57.185.212', gateway='10.57.131.217',
                       routeIpMtu='1500')),
    dict(dist_name='MRBTS-1414/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1', list_name='routingPolicies',
         elements=dict(orderNumber='2', routingTableDN='MRBTS-1414/TNLSVC-1/TNL-1/IPNO-1/IPRT-2',
                       srcIpAddress='10.57.131.218', srcIpPrefixLength='32')),

]
