__maintainer__ = 'Pawel Rokicki'
__team__ = '5G_IV7_WRO_6'
__email__ = 'I_MN_5GSC_PZ_5G_IV7_WRO_6@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def add_object_with_params(self, distname=None, klass=None, version=None, list_name=None, mo=None, **kwargs):

        if distname is not None:
            mo = ManagedObject().create(klass=klass, dist_name=distname, version=version, operation="create")

        if kwargs:
            if list_name is not None:
                for name, value in kwargs.items():
                    new_list = List().create(list_name)
                    item = Item().create()
                    p = P().create(name=name, value=value)
                    item.append(p)
                    new_list.append(item)
                    mo.append(new_list)

            else:
                for name, value in kwargs.items():
                    p = P().create(name=name, value=value)
                    mo.append(p)

        self.scf_handler.raml.cmData.append(mo)

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts_id = context.mrbts
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        x2c = context.tl_config.gnbs[0].cu.x2c.v6
        x2u = context.tl_config.gnbs[0].cu.x2u.v6
        s1u = context.tl_config.gnbs[0].cu.s1u.v6
        backhaul_site_oam_ip = context.tl_config.gnbs[0].cu.backhaul_site_oam_ip.v6

        mrbts.EQM[0].HWTOP[0].CABLINK[0].firstEndpointLabel.value = "BACKPLANE"
        mrbts.EQM[0].HWTOP[0].CABLINK[0].secondEndpointLabel.value = "BACKPLANE"

        pmmnl_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/PMMNL-1'
        pmmnl_mnl_version = mrbts.MNL[0]['version']
        self.add_object_with_params(distname=pmmnl_dist_name,
                                    klass="com.nokia.srbts.mnl:PMMNL", version=pmmnl_mnl_version,
                                    eCpriMasterStatisticsInterval='5min',
                                    mtBtsEnergyMonitoring='15min',
                                    mtSfp='15min',
                                    pmMnlId='1')

        mrbts.MNL[0].MNLENT[0].FEATCADM[0].actDualStackIpV4V6ForMplane.remove()

        mrbts.NRBTS[0].mPlane[0].remove()
        mrbts.NRBTS[0].x2Cplane[0].remove()
        mrbts.NRBTS[0].x2Uplane[0].remove()
        mrbts.NRBTS[0].s1Uplane[0].remove()

        dualstack = mrbts.MNL[0].MNLENT[0].FEATCADM[0]
        self.add_object_with_params(mo=dualstack, actDualStackIpV4V6ForMplane='true')

        ecpri = mrbts.MNL[0].MNLENT[0].SYNC[0]
        self.add_object_with_params(mo=ecpri, actEcpriMasterClock='false', profileType='RAU')

        mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList.remove()

        new_list = List().create("syncInputList")
        item = Item().create()
        p = P().create(name='syncInputPrio', value='1')
        item.append(p)
        p = P().create(name='syncInputType', value='1pps/ToD from external GNSS receiver')
        item.append(p)
        p = P().create(name='syncMaster', value='true')
        item.append(p)
        p = P().create(name='totalDelayFromSHM', value='true')
        item.append(p)
        new_list.append(item)
        mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].append(new_list)

        trblcadm_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
        trblcadm_mnl_version = mrbts.MNL[0].MNLENT[0]['version']
        self.add_object_with_params(distname=trblcadm_dist_name,
                                    klass="com.nokia.srbts.mnl:TRBLCADM", version=trblcadm_mnl_version,
                                    actCoreDumpFileCollection='false',
                                    actInternalTrace='false',
                                    actRemoteSyslogTransmission='false',
                                    snapshotUploadDelayForFault6450='99')

        mrbts.MNL[0].MNLENT[0].MPLANENW[0].mPlaneIpv4AddressDN.remove()
        mplaneipv4addressdn_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'
        mplaneipv4addressdn_mo = mrbts.MNL[0].MNLENT[0].MPLANENW[0]
        self.add_object_with_params(mo=mplaneipv4addressdn_mo, mPlaneIpv6AddressDN=mplaneipv4addressdn_p)

        mplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=mplane)
        item.append(p)
        mrbts.NRBTS[0].mPlane.append(item)

        x2cplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=x2cplane)
        item.append(p)
        mrbts.NRBTS[0].x2Cplane.append(item)

        x2uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=x2uplane)
        item.append(p)
        mrbts.NRBTS[0].x2Uplane.append(item)

        s1uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-4/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=s1uplane)
        item.append(p)
        mrbts.NRBTS[0].s1Uplane.append(item)

        mnl_version_iprt = mrbts.TNLSVC[0].TNL[0]['version']
        new_mo_ipv6 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddr=backhaul_site_oam_ip,
                                    localIpPrefixLength='120')

        new_mo_ipv6 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddr=x2c,
                                    localIpPrefixLength='120')

        new_mo_ipv6 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddr=x2u,
                                    localIpPrefixLength='120')

        new_mo_ipv6 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-4/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddr=s1u,
                                    localIpPrefixLength='120')

        iprt_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1'
        self.add_object_with_params(distname=iprt_dist_name,
                                    klass="com.nokia.srbts.tnl:IPRTV6", version=mnl_version_iprt,
                                    )
