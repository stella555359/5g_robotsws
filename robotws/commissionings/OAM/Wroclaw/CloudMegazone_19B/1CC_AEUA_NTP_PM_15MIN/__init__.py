__maintainer__ = 'Bartlomiej Lebda'
__team__ = 'I_5GSC_5G_PZ1_WRO_6_GMS'
__email__ = 'I_5GSC_5G_PZ1_WRO_6@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):
    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19A/SBTS5G19A_5g_414_9_AEUA.xml'

    def add_object_with_params(self, distname=None, klass=None, version=None, list_name=None, mo=None, **kwargs):

        if klass is not None:
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
        nrbts_id = context.nrbts
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mnl_version = mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].GNSSE[0]['version']
        mrbts.MNL[0].PMCADM[0].reportingIntervalPm.value = "15min"

        try:
            if mrbts.MNL[0].MNLENT[1].targetDNType.value == 'VM':

                mo_clock = mrbts.MNL[0].MNLENT[1].SYNC[0].CLOCK[0]
                self.add_object_with_params(outputConfiguration1Pps='EnabledWithoutBtsInputReference',
                                            outputConfiguration2M048='EnabledWithoutBtsInputReference', mo=mo_clock)

                ntp_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1'
                self.add_object_with_params(distname=ntp_dist_name,
                                            klass="com.nokia.srbts.mnl:NTP", version=mnl_version,
                                            list_name='ntpServerList',
                                            ntpServerIpAddr='2a00:8a00:6000:6001::4')
            else:
                pass

        except IndexError:
            mnlent2_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-2'
            self.add_object_with_params(distname=mnlent2_dist_name,
                                        klass="com.nokia.srbts.mnl:MNLENT", version=mnl_version, targetDNType='VM',
                                        redundancyRole='standalone',
                                        activityMode='active')

            sync_distname = mnlent2_dist_name + '/SYNC-1'
            self.add_object_with_params(distname=sync_distname,
                                        klass="com.nokia.srbts.mnl:SYNC", version=mnl_version, btsSyncMode='PhaseSync',
                                        profileType='RAC')

            mo_clock_distname = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-2/SYNC-1/CLOCK-1'
            self.add_object_with_params(distname=mo_clock_distname,
                                        klass="com.nokia.srbts.mnl:CLOCK", version=mnl_version,
                                        outputConfiguration1Pps='EnabledWithoutBtsInputReference',
                                        outputConfiguration2M048='EnabledWithoutBtsInputReference')

            mo_time_distname = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-2/SYNC-1/TIME-1'
            self.add_object_with_params(distname=mo_time_distname,
                                        klass="com.nokia.srbts.mnl:TIME", version=mnl_version,
                                        timeZone='(GMT+2) Europe/Helsinki')

            fmcadm_distname = mnlent2_dist_name + '/FMCADM-1'
            self.add_object_with_params(distname=fmcadm_distname,
                                        klass="com.nokia.srbts.mnl:FMCADM", version=mnl_version)

            secadm_distname = mnlent2_dist_name + '/SECADM-1'
            self.add_object_with_params(distname=secadm_distname,
                                        klass="com.nokia.srbts.mnl:SECADM", version=mnl_version,
                                        actServiceAccountSsh='false',
                                        actServicePortState='false',
                                        ethernetPortSecurityEnabled='false',
                                        sshClientAliveTimer='45',
                                        sshSessionLoginDelayTimer='10',
                                        keyContinuation='false')

            featcadm_distname = mnlent2_dist_name + '/FEATCADM-1'
            self.add_object_with_params(distname=featcadm_distname,
                                        klass="com.nokia.srbts.mnl:FEATCADM", version=mnl_version,
                                        rfSharingEnabled='false',
                                        systemAcctPermEnable='false',
                                        actAsi='false')

            certhent_distname = mnlent2_dist_name + '/CERTHENT-1'
            self.add_object_with_params(distname=certhent_distname,
                                        klass="com.nokia.srbts.mnl:CERTHENT", version=mnl_version)

            cmps_distname = mnlent2_dist_name + '/CERTHENT-1' + '/CMPS-1'
            self.add_object_with_params(distname=cmps_distname,
                                        klass="com.nokia.srbts.mnl:CMPS", version=mnl_version)

            crlhs_distname = mnlent2_dist_name + '/CERTHENT-1' + '/CRLHS-1'
            self.add_object_with_params(distname=crlhs_distname,
                                        klass="com.nokia.srbts.mnl:CRLHS", version=mnl_version)

            necert_distname = mnlent2_dist_name + '/CERTHENT-1' + '/NECERT-1'
            self.add_object_with_params(distname=necert_distname,
                                        klass="com.nokia.srbts.mnl:NECERT", version=mnl_version)

            crlinfo_distname = mnlent2_dist_name + '/CERTHENT-1' + '/CRLINFO-1'
            self.add_object_with_params(distname=crlinfo_distname,
                                        klass="com.nokia.srbts.mnl:CRLINFO", version=mnl_version)

            cacert_distname = mnlent2_dist_name + '/CERTHENT-1' + '/CACERT-1'
            self.add_object_with_params(distname=cacert_distname,
                                        klass="com.nokia.srbts.mnl:CACERT", version=mnl_version)

            ntp_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1'
            self.add_object_with_params(distname=ntp_dist_name,
                                        klass="com.nokia.srbts.mnl:NTP", version=mnl_version,
                                        list_name='ntpServerList',
                                        ntpServerIpAddr='10.171.8.4')

        for cellgrp in mrbts.NRBTS[0].NRCELLGRP[1:]:
            cellgrp.remove()

        for cell in mrbts.NRBTS[0].NRCELL[1:]:
            cell.remove_tree()

        for cell in mrbts.NRBTS_1.NRCELLGRP[0].nrCellList[1:]:
            cell.remove()

        mrbts.NRBTS[0].f1Cplane[0].remove()

        nrbts_f1Cplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrbts_f1Cplane)
        item.append(p)
        mrbts.NRBTS[0].f1Cplane.append(item)

        mrbts.NRBTS[0].f1Uplane[0].remove()
        nrbts_f1Uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrbts_f1Uplane)
        item.append(p)
        mrbts.NRBTS[0].f1Uplane.append(item)

        mrbts.NRBTS[0].f1Mplane[0].remove()
        nrbts_f1Mplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrbts_f1Mplane)
        item.append(p)
        mrbts.NRBTS[0].f1Mplane.append(item)

        mrbts.NRBTS[0].s1Uplane[0].remove()
        nrbts_s1Uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrbts_s1Uplane)
        item.append(p)
        mrbts.NRBTS[0].s1Uplane.append(item)

        mrbts.NRBTS[0].x2Cplane[0].remove()
        nrbts_x2Cplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrbts_x2Cplane)
        item.append(p)
        mrbts.NRBTS[0].x2Cplane.append(item)

        mrbts.NRBTS[0].x2Uplane[0].remove()
        nrbts_x2Uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1'
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrbts_x2Uplane)
        item.append(p)
        mrbts.NRBTS[0].x2Uplane.append(item)

        nrdu_f1Cplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1'
        mrbts.NRBTS[0].NRDU[0].f1Cplane[0].remove()
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrdu_f1Cplane)
        item.append(p)
        mrbts.NRBTS[0].NRDU[0].f1Cplane.append(item)

        nrdu_f1Mplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2'
        mrbts.NRBTS[0].NRDU[0].f1Mplane[0].remove()
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrdu_f1Mplane)
        item.append(p)
        mrbts.NRBTS[0].NRDU[0].f1Mplane.append(item)

        nrdu_f1Uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3'
        mrbts.NRBTS[0].NRDU[0].f1Uplane[0].remove()
        item = Item().create()
        p = P().create(name='ipV6AddressDN1', value=nrdu_f1Uplane)
        item.append(p)
        mrbts.NRBTS[0].NRDU[0].f1Uplane.append(item)

        mnl_version_iprt = mrbts.TNLSVC[0].TNL[0]['version']
        iprt_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1'
        self.add_object_with_params(distname=iprt_dist_name,
                                    klass="com.nokia.srbts.tnl:IPRTV6", version=mnl_version_iprt,
                                    )

        new_list = List().create('staticIpv6Routes')
        item = Item().create()
        p = P().create(name='destIpv6Addr', value='2A00:8A00:6000:607c::1:4600')
        item.append(p)
        p = P().create(name='destinationIpv6PrefixLength', value='120')
        item.append(p)
        p = P().create(name='gatewayIpv6Addr', value='2A00:8A00:6000:607c::1:4001')
        item.append(p)
        p = P().create(name='preference', value='1')
        item.append(p)
        new_list.append(item)
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRTV6_1.append(new_list)

        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[0].IPADDRESSV4_1.remove()

        new_mo_ipv6_f1m = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6_f1m,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='DISCOVERED',
                                    uniqueIpAddressIdentifier='F1-M',
                                    )

        mrbts.TNLSVC[0].TNL[1].IPNO[0].IPIF[0].IPADDRESSV4_1.remove()

        new_mo_ipv6_x2c = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6_x2c,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='DISCOVERED',
                                    uniqueIpAddressIdentifier='X2-C',
                                    )

        mrbts.TNLSVC[0].TNL[1].IPNO[0].IPIF[1].IPADDRESSV4_1.remove()
        new_mo_ipv6_f1c = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6_f1c,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='DISCOVERED',
                                    uniqueIpAddressIdentifier='F1-C',
                                    )

        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPIF[0].IPADDRESSV4_1.remove()
        new_mo_ipv6_x2u_s1_u = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6_x2u_s1_u,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='DISCOVERED',
                                    uniqueIpAddressIdentifier='X2-U S1-U',
                                    )

        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPIF[1].IPADDRESSV4_1.remove()
        new_mo_ipv6_f1_u = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mo_ipv6_f1_u,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    ipAddressAllocationMethod='DISCOVERED',
                                    uniqueIpAddressIdentifier='F1-U',
                                    )

        iprt_tnl3_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPRTV6-1'
        self.add_object_with_params(distname=iprt_tnl3_dist_name,
                                    klass="com.nokia.srbts.tnl:IPRTV6", version=mnl_version_iprt
                                    )

        mrbts.TNLSVC[0].TNL[1].IPNO[0].IPIF[0].remove()
        new_mo_ipif1_tnl2 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1'
        interfaceDN = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1'
        self.add_object_with_params(distname=new_mo_ipif1_tnl2,
                                    klass="com.nokia.srbts.tnl:IPIF", version=mnl_version_iprt,
                                    linkLocalIpV6Address='fe80::f816:3eff:fe00:2bf4',
                                    ipMtu='1500',
                                    interfaceDN=interfaceDN
                                    )

        mrbts.TNLSVC[0].TNL[1].IPNO[0].IPIF[1].remove()
        new_mo_ipif2 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-2'
        interfaceDN = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2'
        self.add_object_with_params(distname=new_mo_ipif2,
                                    klass="com.nokia.srbts.tnl:IPIF", version=mnl_version_iprt,
                                    linkLocalIpV6Address='fe80::f816:3eff:fecb:2cdd',
                                    ipMtu='1500',
                                    interfaceDN=interfaceDN
                                    )

        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPIF[0].remove()
        new_mo_ipif1 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1'
        interfaceDN = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-1'
        self.add_object_with_params(distname=new_mo_ipif1,
                                    klass="com.nokia.srbts.tnl:IPIF", version=mnl_version_iprt,
                                    linkLocalIpV6Address='fe80::f816:3eff:fe8d:49d8',
                                    ipMtu='1500',
                                    interfaceDN=interfaceDN
                                    )

        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPIF[1].remove()
        new_mo_ipif2_tnl3 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-2'
        interfaceDN = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-2'
        self.add_object_with_params(distname=new_mo_ipif2_tnl3,
                                    klass="com.nokia.srbts.tnl:IPIF", version=mnl_version_iprt,
                                    linkLocalIpV6Address='fe80::f816:3eff:fe4d:e878',
                                    ipMtu='1500',
                                    interfaceDN=interfaceDN
                                    )

        new_list = List().create('staticIpv6Routes')
        item = Item().create()
        p = P().create(name='destIpv6Addr', value='2A00:8A00:6000:607c::1:4800')
        item.append(p)
        p = P().create(name='destinationIpv6PrefixLength', value='120')
        item.append(p)
        p = P().create(name='gatewayIpv6Addr', value='2A00:8A00:6000:607c::1:4301')
        item.append(p)
        p = P().create(name='preference', value='1')
        item.append(p)
        new_list.append(item)
        item = Item().create()
        p = P().create(name='destIpv6Addr', value='2A00:8A00:6000:607c::1:4609')
        item.append(p)
        p = P().create(name='destinationIpv6PrefixLength', value='120')
        item.append(p)
        p = P().create(name='gatewayIpv6Addr', value='2A00:8A00:6000:607c::1:4401')
        item.append(p)
        p = P().create(name='preference', value='1')
        item.append(p)
        new_list.append(item)
        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPRTV6_1.append(new_list)

        mrbts.TNLSVC[0].TNL[3].IPNO[0].IPIF[0].IPADDRESSV4_1.remove()

        new_mrbts_ipv6_1 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1'
        self.add_object_with_params(distname=new_mrbts_ipv6_1,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    localIpAddr='2A00:8A00:6000:607c::1:4010',
                                    localIpPrefixLength='120',
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddrAllocated='2A00:8A00:6000:607c::1:4010'
                                    )

        mrbts.TNLSVC[0].TNL[3].IPNO[0].IPIF[0].IPADDRESSV4_3.remove()
        new_mrbts_ipv6_3 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3'
        self.add_object_with_params(distname=new_mrbts_ipv6_3,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    localIpAddr='2A00:8A00:6000:607c::1:4011',
                                    localIpPrefixLength='120',
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddrAllocated='2A00:8A00:6000:607c::1:4011'
                                    )

        mrbts.TNLSVC[0].TNL[3].IPNO[0].IPIF[0].IPADDRESSV4_2.remove()
        new_mrbts_ipv6_2 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2'
        self.add_object_with_params(distname=new_mrbts_ipv6_2,
                                    klass="com.nokia.srbts.tnl:IPADDRESSV6", version=mnl_version_iprt,
                                    localIpAddr='2A00:8A00:6000:607c::1:4012',
                                    localIpPrefixLength='120',
                                    ipAddressAllocationMethod='MANUAL',
                                    localIpAddrAllocated='2A00:8A00:6000:607c::1:4012'
                                    )

        mrbts.MNL[0].actPdlRuleValidation.value = 'false'

        mo_nrcell_1 = mrbts.NRBTS[0].NRCELL[0]
        self.add_object_with_params(mo=mo_nrcell_1,
                                    configuredEpsTac='0'
                                    )

        mrbts.NRBTS[0].NRCELL[0].pMax.value = 210
        mrbts.NRBTS[0].NRCELL[0].nrarfcn.value = 2059000
        mrbts.NRBTS[0].NRCELL[0].gscn.value = 22402

        for mnlent in mrbts.MNL[0].MNLENT[0:]:
            mnlent.FEATCADM[0].systemAcctPermEnable.value = "false"
            mnlent.SECADM[0].actServiceAccountSsh.value = "true"
            mnlent.SECADM[0].ethernetPortSecurityEnabled.value = "false"

        mrbts.NRBTS[0].mcc.value = '555'
        mrbts.NRBTS[0].mnc.value = '10'
        mrbts.NRBTS[0].mncLength.value = '2'

        for apeqm in mrbts.EQM[0].APEQM[0:]:
            apeqm.rapProfile.value = ""
