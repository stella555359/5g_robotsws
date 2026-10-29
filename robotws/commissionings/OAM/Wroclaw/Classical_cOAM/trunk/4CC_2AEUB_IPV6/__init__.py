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
        gateway = context.tl_config.gnbs[0].cu.backhaul_site_oam_ip.routing.gateway

        mrbts.EQM[0].HWTOP[0].CABLINK[0].firstEndpointLabel.value = "BACKPLANE"
        mrbts.EQM[0].HWTOP[0].CABLINK[0].secondEndpointLabel.value = "BACKPLANE"

        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].staticRoutes.remove()
        mrbts.TNLSVC[0].TNL[0].IPNO[0].RTPOL[0].routingPolicies.remove()
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRTV6[0].remove()
        mrbts.TNLSVC[0].TNL[0].IPNO[0].RTPOL[0].remove()
        mrbts.MNL[0].MNLENT[0].FEATCADM[0].actDualStackIpV4V6ForMplane.remove()

        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[0].IPADDRESSV4_1.remove()
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[1].IPADDRESSV4_1.remove()
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[2].IPADDRESSV4_1.remove()
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[3].IPADDRESSV4_1.remove()

        mrbts.NRBTS[0].mPlane[0].remove()
        mrbts.NRBTS[0].x2Cplane[0].remove()
        mrbts.NRBTS[0].x2Uplane[0].remove()
        mrbts.NRBTS[0].s1Uplane[0].remove()

        dualstack = mrbts.MNL[0].MNLENT[0].FEATCADM[0]
        self.add_object_with_params(mo=dualstack, actDualStackIpV4V6ForMplane='true')

        ecpri = mrbts.MNL[0].MNLENT[0].SYNC[0]
        self.add_object_with_params(mo=ecpri, actEcpriMasterClock='true', profileType='RAU')

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
        new_list = List().create('staticIpv6Routes')
        item = Item().create()
        p = P().create(name='destIpv6Addr', value='0000:0000:0000:0000:0000:0000:0000:0000')
        item.append(p)
        p = P().create(name='destinationIpv6PrefixLength', value='0')
        item.append(p)
        p = P().create(name='gatewayIpv6Addr', value=gateway)
        item.append(p)
        p = P().create(name='preSrcIpv6Addr', value=backhaul_site_oam_ip)
        item.append(p)
        p = P().create(name='preference', value='1')
        item.append(p)
        p = P().create(name='routeIpMtu', value='1450')
        item.append(p)
        new_list.append(item)
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRTV6_1.append(new_list)

        rtpol_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1'
        self.add_object_with_params(distname=rtpol_dist_name,
                                    klass="com.nokia.srbts.tnl:RTPOL", version=mnl_version_iprt,
                                    )
        new_list = List().create('routingPolicies')
        item = Item().create()
        p = P().create(name='orderNumber', value='1')
        item.append(p)
        p = P().create(name='routingTableDN', value=iprt_dist_name)
        item.append(p)
        p = P().create(name='srcIpAddress', value='0000:0000:0000:0000:0000:0000:0000:0000')
        item.append(p)
        p = P().create(name='srcIpPrefixLength', value='64')
        item.append(p)
        new_list.append(item)
        mrbts.TNLSVC[0].TNL[0].IPNO[0].RTPOL_1.append(new_list)

        # add second ABIL and RU
        mnl_version_bbmod = mrbts.EQM[0].APEQM[0].CABINET[0].BBMOD[0]['version']
        new_mo_bbmod = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/CABINET-1/BBMOD-2'
        self.add_object_with_params(distname=new_mo_bbmod,
                                    klass="com.nokia.srbts.eqm:BBMOD", version=mnl_version_bbmod,
                                    administrativeState='Unlocked',
                                    prodCodePlanned='474020A',
                                    useFullCapacity='true')

        mnl_version_rmod = mrbts.EQM[0].APEQM[0].RMOD[0]['version']
        new_mo_rmod = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-2'
        self.add_object_with_params(distname=new_mo_rmod,
                                    klass="com.nokia.srbts.eqm:RMOD", version=mnl_version_rmod,
                                    actPimCancellation='false',
                                    actSnapshotCollection='false',
                                    administrativeState='Unlocked',
                                    climateControlProfiling='Optimized Cooling',
                                    linkSpeed='Auto',
                                    pimCancellingEnabled='false',
                                    prodCodePlanned='474608A',
                                    ptpSyncRepPrd='60')

        new_mo_phyant = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-2/PHYANT-1'
        self.add_object_with_params(distname=new_mo_phyant,
                                    klass="com.nokia.srbts.eqm:PHYANT", version=mnl_version_rmod)

        cablink_dist_name = 'MRBTS-' + str(mrbts_id) + '/EQM-1/HWTOP-1/CABLINK-3'
        cablink_mnl_version = mrbts.EQM[0].HWTOP[0].CABLINK[0]['version']
        self.add_object_with_params(distname=cablink_dist_name,
                                    klass="com.nokia.srbts.eqm:CABLINK", version=cablink_mnl_version,
                                    firstEndpointDN='MRBTS-50307/EQM-1/APEQM-1/CABINET-1/SMOD-1',
                                    firstEndpointLabel='BACKPLANE',
                                    firstEndpointPortId='2',
                                    linkModeConfiguration='false',
                                    linkModeDC='false',
                                    linkModeData='false',
                                    linkModeSynchronization='false',
                                    linkSpeed='Cpri7',
                                    secondEndpointDN='MRBTS-50307/EQM-1/APEQM-1/CABINET-1/BBMOD-2',
                                    secondEndpointLabel='BACKPLANE'
                                    )

        cablink_dist_name = 'MRBTS-' + str(mrbts_id) + '/EQM-1/HWTOP-1/CABLINK-4'
        cablink_mnl_version = mrbts.EQM[0].HWTOP[0].CABLINK[0]['version']
        self.add_object_with_params(distname=cablink_dist_name,
                                    klass="com.nokia.srbts.eqm:CABLINK", version=cablink_mnl_version,
                                    firstEndpointDN='MRBTS-50307/EQM-1/APEQM-1/CABINET-1/BBMOD-2',
                                    firstEndpointLabel='SFP',
                                    firstEndpointPortId='1',
                                    iqCompression='none',
                                    linkSpeed='eCpri25',
                                    radioProtocolType='25eCPRI',
                                    secondEndpointDN='MRBTS-50307/EQM-1/APEQM-1/RMOD-2',
                                    secondEndpointLabel='SFP',
                                    secondEndpointPortId='1'
                                    )

        # modify cell_1
        mrbts.NRBTS_1.NRCELL[0].configuredEpsTac.value = '0'
        mrbts.NRBTS_1.NRCELL[0].gscn.value = '22458'
        mrbts.NRBTS_1.NRCELL[0].dllaIniMcs.value = '8'
        mrbts.NRBTS_1.NRCELL[0].nrarfcn.value = '2071675'
        mrbts.NRBTS_1.NRCELL[0].pMax.value = '190'
        mrbts.NRBTS_1.NRCELL[0].type0SearchSpaceConfigurationIndex.value = '0'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].frameStructureType.value = 'semiStatic'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].guardPeriodLength.value = '2Symbols'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].ulDlDataSlotRatio.value = '1/4'

        # add new cells
        id_cells_to_add = [2, 3, 4]
        for num in id_cells_to_add:
            new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELL-{}'.format(num)
            mrbts.NRBTS_1.NRCELL[0].clone_tree_to(new_nrcell)

        list = mrbts.NRBTS_1.NRCELLGRP[0].nrCellList
        p = P().create(value=2)
        list.append(p)

        nrarfcn_4cells = {mrbts.NRBTS_1.NRCELL[0].nrarfcn: '2071675',
                          mrbts.NRBTS_1.NRCELL[1].nrarfcn: '2073339',
                          mrbts.NRBTS_1.NRCELL[2].nrarfcn: '2075003',
                          mrbts.NRBTS_1.NRCELL[3].nrarfcn: '2076667'
                          }
        for p, p_value in nrarfcn_4cells.items():
            p.value = p_value

        gscn_4cells = {mrbts.NRBTS_1.NRCELL[0].gscn: '22446',
                       mrbts.NRBTS_1.NRCELL[1].gscn: '22452',
                       mrbts.NRBTS_1.NRCELL[2].gscn: '22458',
                       mrbts.NRBTS_1.NRCELL[3].gscn: '22464',
                       }
        for p, p_value in gscn_4cells.items():
            p.value = p_value

        for cell in range(1, 4):
            mrbts.NRBTS_1.NRCELL[cell].physCellId.value += cell
            mrbts.NRBTS_1.NRCELL[cell].lcrId.value += cell

        id_cells_to_add = [2, 3, 4]
        for num in id_cells_to_add:
            new_lcelnr = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.format(num)
            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].clone_tree_to(new_lcelnr)
        # MRBTS - 50307 / MNL - 1 / MNLENT - 1 / CELLMAPPING - 1 / LCELNR - 2 / CHANNELGROUP - 1
        # MRBTS - 50307 / MNL - 1 / MNLENT - 1 / CELLMAPPING - 1 / LCELNR - 2 / CHANNELGROUP - 1 / CHANNEL - 1

        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[1].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[2].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[3].CHANNELGROUP[0].CHANNEL[1].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[3].CHANNELGROUP[0].CHANNEL[2].remove()
        mrbts.NRBTS[0].NRCELL[0].cellBarred.value = 'notBarred'
        mrbts.NRBTS[0].NRCELL[1].cellBarred.value = 'barred'
        mrbts.NRBTS[0].NRCELL[2].cellBarred.value = 'barred'
        mrbts.NRBTS[0].NRCELL[3].cellBarred.value = 'barred'
        mrbts.NRBTS[0].NRCELL[0].intraFreqReselection.value = 'allowed'
        mrbts.NRBTS[0].NRCELL[1].intraFreqReselection.value = 'notAllowed'
        mrbts.NRBTS[0].NRCELL[2].intraFreqReselection.value = 'notAllowed'
        mrbts.NRBTS[0].NRCELL[3].intraFreqReselection.value = 'notAllowed'
        mrbts.NRBTS[0].NRCELL[0].nrCellType.value = '2DL2UL'
        mrbts.NRBTS[0].NRCELL[1].nrCellType.value = '2DL0UL'
        mrbts.NRBTS[0].NRCELL[2].nrCellType.value = '2DL0UL'
        mrbts.NRBTS[0].NRCELL[3].nrCellType.value = '2DL0UL'

        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[2].CHANNELGROUP[0].CHANNEL[0].resourceDN.value = \
            'MRBTS-50307/EQM-1/APEQM-1/RMOD-2/PHYANT-1'
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[2].CHANNELGROUP[0].CHANNEL[1].resourceDN.value = \
            'MRBTS-50307/EQM-1/APEQM-1/RMOD-2/PHYANT-1'
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[2].CHANNELGROUP[0].CHANNEL[2].resourceDN.value = \
            'MRBTS-50307/EQM-1/APEQM-1/RMOD-2/PHYANT-1'
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[2].CHANNELGROUP[0].CHANNEL[3].resourceDN.value = \
            'MRBTS-50307/EQM-1/APEQM-1/RMOD-2/PHYANT-1'
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[3].CHANNELGROUP[0].CHANNEL[0].resourceDN.value = \
            'MRBTS-50307/EQM-1/APEQM-1/RMOD-2/PHYANT-1'
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[3].CHANNELGROUP[0].CHANNEL[1].resourceDN.value = \
            'MRBTS-50307/EQM-1/APEQM-1/RMOD-2/PHYANT-1'

        new_nrcellgrp = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELLGRP-1'
        mrbts.NRBTS_1.NRCELLGRP[0].clone_tree_to(new_nrcellgrp)

        mrbts.NRBTS_1.NRCELLGRP[1].nrCellList.remove()
        # list = mrbts.NRBTS_1.NRCELLGRP[1].nrCellList
        # p = P().create(value=3)
        # list.append(p)
        # p = P().create(value=4)
        # list.append(p)
        # mrbts.NRBTS_1.NRCELLGRP[1].append(list)

        new_list = List().create("nrCellList")
        p = P().create(value=3)
        new_list.append(p)
        p = P().create(value=4)
        new_list.append(p)
        mrbts.NRBTS_1.NRCELLGRP[1].append(new_list)

        p = P().create(value=1)
        mrbts.NRBTS_1.NRDU[0].refNrCellGroup.append(p)

        dualstack = mrbts.MNL[0].MNLENT[0].FEATCADM[0]
        self.add_object_with_params(mo=dualstack, actDualStackIpV4V6ForMplane='true')

        mrbts.MNL[0].MNLENT[0].SYNC[1].CLOCK[0].syncMaster.value = 'true'

        new_list = List().create("syncInputList")
        item = Item().create()
        p = P().create(name='syncInputPrio', value=1)
        item.append(p)
        p = P().create(name='syncInputType', value='TOPP')
        item.append(p)
        new_list.append(item)
        mrbts.MNL[0].MNLENT[0].SYNC[1].CLOCK[0].append(new_list)

        mrbts.MNL[0].MNLENT[0].SYNC[1].CLOCK[0].NTP[0].remove()

        sync_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/SYNC-3'
        sync_mnl_version = mrbts.MNL[0].MNLENT[0].SYNC[1]['version']
        self.add_object_with_params(distname=sync_dist_name,
                                    klass="com.nokia.srbts.mnl:SYNC", version=sync_mnl_version,
                                    profileType='RU')
        new_list = List().create("targetDNList")
        p = P().create(value='MRBTS-50307/EQM-1/APEQM-1/RMOD-2')
        new_list.append(p)
        mrbts.MNL[0].MNLENT[0].SYNC[2].append(new_list)

        sync_clock_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/SYNC-3/CLOCK-1'
        self.add_object_with_params(distname=sync_clock_dist_name,
                                    klass="com.nokia.srbts.mnl:CLOCK", version=sync_mnl_version,
                                    holdOverModeUsed='false',
                                    syncMaster='true')
        new_list = List().create("syncInputList")
        item = Item().create()
        p = P().create(name='syncInputPrio', value='1')
        item.append(p)
        p = P().create(name='syncInputType', value='TOPP')
        item.append(p)
        new_list.append(item)
        mrbts.MNL[0].MNLENT[0].SYNC[2].CLOCK[0].append(new_list)

        sync_clock_top_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/TOP-1'
        self.add_object_with_params(distname=sync_clock_top_dist_name,
                                    klass="com.nokia.srbts.mnl:TOP", version=sync_mnl_version,
                                    topDomainNumber='24')

        sync_clock_top_topp_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/SYNC-3/CLOCK-1/TOP-1/TOPP-1'
        self.add_object_with_params(distname=sync_clock_top_topp_dist_name,
                                    klass="com.nokia.srbts.mnl:TOPP", version=sync_mnl_version,
                                    topEthMulticastAddress='01-80-C2-00-00-0E',
                                    topStandardProfile='G.8275.1')
        new_list = List().create("acceptedClockClass")
        p = P().create(value='6')
        new_list.append(p)
        p = P().create(value='7')
        new_list.append(p)
        mrbts.MNL[0].MNLENT[0].SYNC[2].CLOCK[0].TOP[0].TOPP[0].append(new_list)

        new_list = List().create("topMasterList")
        item = Item().create()
        p = P().create(name='phaseErrorComp', value='0')
        item.append(p)
        p = P().create(name='topMasterId', value='1')
        item.append(p)
        new_list.append(item)
        mrbts.MNL[0].MNLENT[0].SYNC[2].CLOCK[0].TOP[0].TOPP[0].append(new_list)

        sync_clock_top_topp_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/SYNC-3/TIME-1'
        self.add_object_with_params(distname=sync_clock_top_topp_dist_name,
                                    klass="com.nokia.srbts.mnl:TIME", version=sync_mnl_version,
                                    timeZone='(GMT+2) Europe/Helsinki')
