__maintainer__ = 'Chen Xiaqing'
__team__ = 'I_CLOUD_AGENT_AIC'
__email__ = 'I_CLOUD_AGENT_AIC@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from cloud5g.commissioning.scf_handler import ElementNotFound
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P
from common_agent_5g import logger


class CustomCommissioning(CustomCommissioningBase):
    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''
        self.context = ''
        self.taf_scf = self.scf_handler

    def _get_ip(self, item):
        if self.context.tl_config.gnbs[0].cu.backhaul_site_oam_ip.v6:
            return item.v6
        else:
            return item.v4

    def _remove_tree(self, itemlist):
        try:
            item_trees = itemlist[0:]
        except ElementNotFound as error:
            logger.log_warn('There is an ElementNotFound warning : {msg}'.format(msg=error))
            return
        for item in item_trees:
            item.remove_tree()

    def _create_route_item(self, dest_ip_addr, gateway, destination_ip_prefix_length):
        item = Item().create()
        p = P().create(name='destIpAddr', value=dest_ip_addr)
        item.append(p)
        p = P().create(name='gateway', value=gateway)
        item.append(p)
        p = P().create(name='destinationIpPrefixLength', value=destination_ip_prefix_length)
        item.append(p)
        return item

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

    # main function of scf modification
    # first argument include following parameters:
    #    mrbts
    #    nrbts
    #    tl_config (you can refer to testline configuration __init__.py)
    #    tl_name (test line name)
    #    number_of_cells
    def modify_scf(self, context):
        taf_scf = self.scf_handler
        self.context = context
        mrbts_id = context.mrbts
        nrbts_id = context.nrbts
        x2u_s1u_same_net = context.x2u_s1u_same_net
        dns_forwarders = context.dns_forwarders
        logger.log("-----x2u_s1u_same_net is {}-----".format(context.x2u_s1u_same_net))

        # here index 0 means first MRBTS object, index is start from 0
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        nrbts_mo = mrbts.NRBTS[0]
        try:
            mrbts.NRBTS[0].actInterRatHoFromEutraToSA.value = "false"
        except Exception:
            self.add_object_with_params(mo=nrbts_mo, actInterRatHoFromEutraToSA='false')

        try:
            mrbts.NRBTS[0].actLocationReportingSA.value = "false"
        except Exception:
            self.add_object_with_params(mo=nrbts_mo, actLocationReportingSA='false')

        for tnl in range(0, 6):
            try:
                mrbts.TNLSVC[0].TNL[tnl].IPNO[0].IPRTV6[0].staticIpv6Routes.remove()
            except Exception as error:
                logger.log_warn('There is an exception warning on TNL-{tnl}: {msg}'.format(tnl=tnl+1, msg=error))
                pass
        # remove TNLSVC-1/TNL-3/IPNO-1/IPIF-1..3
        # remove TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-1..3
        # remove TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1..3
        try:
            self._remove_tree(mrbts.TNLSVC[0].TNL[2].ETHSVC[0].ETHIF)
            self._remove_tree(mrbts.TNLSVC[0].TNL[2].ETHSVC[0].ETHLK)
            self._remove_tree(mrbts.TNLSVC[0].TNL[2].IPNO[0].IPIF)
            logger.log("-----removed TNL2..3 staticRoutes and TNL3 ETHIF,ETHLK,IPIF------")
        except Exception as error:
            logger.log_warn('There is an exception warning: {msg}'.format(msg=error))
            pass

        # ToDo: will modify it to adapt to v6 address if testline
        # ToDo: required
        logger.log("-----will add TNL2 staticRoutes -----")
        mnl_version_iprt = mrbts.TNLSVC[0].TNL[0]['version']
        new_mo_iprt = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPRT-1'
        mrbts.TNLSVC[0].TNL[1].IPNO[0].IPRT[0].remove()
        self.add_object_with_params(distname=new_mo_iprt,
                                    klass="com.nokia.srbts.tnl:IPRT", version=mnl_version_iprt)
        new_list = List().create('staticRoutes')
        item1 = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].cu.x2c),
                                        context.tl_config.gnbs[0].cu.x2c.routing.gateway,
                                        context.tl_config.gnbs[0].cu.x2c.routing.ip_prefix_length)
        item2 = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].cu.f1c),
                                        context.tl_config.gnbs[0].cu.f1c.routing.gateway,
                                        context.tl_config.gnbs[0].cu.f1c.routing.ip_prefix_length)
        new_list.append(item1)
        new_list.append(item2)
        mrbts.TNLSVC[0].TNL[1].IPNO[0].IPRT[0].append(new_list)
        logger.log("-----add TNL2 staticRoutes done-----")

        logger.log("-----will add TNL3 staticRoutes -----")
        new_mo_iprt = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPRT-1'
        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPRT[0].remove()
        self.add_object_with_params(distname=new_mo_iprt,
                                    klass="com.nokia.srbts.tnl:IPRT", version=mnl_version_iprt)
        new_list = List().create('staticRoutes')
        item1 = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].cu.f1u),
                                        context.tl_config.gnbs[0].cu.f1u.routing.gateway,
                                        context.tl_config.gnbs[0].cu.f1u.routing.ip_prefix_length)
        if context.tl_config.gnbs[0].cu.s1u:
            item2 = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].cu.s1u),
                                            context.tl_config.gnbs[0].cu.s1u.routing.gateway,
                                            context.tl_config.gnbs[0].cu.s1u.routing.ip_prefix_length)
        else:
            raise RuntimeError("-----s1u_ip not configured in testline_configuration/__init__.py -----")
        new_list.append(item1)
        new_list.append(item2)

        if not x2u_s1u_same_net:
            if context.tl_config.gnbs[0].cu.x2u:
                item3 = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].cu.x2u),
                                                context.tl_config.gnbs[0].cu.x2u.routing.gateway,
                                                context.tl_config.gnbs[0].cu.x2u.routing.ip_prefix_length)
                new_list.append(item3)
            else:
                raise RuntimeError("-----x2u_ip not configured in testline_configuration/__init__.py -----")

        mrbts.TNLSVC[0].TNL[2].IPNO[0].IPRT[0].append(new_list)
        logger.log("-----add TNL3 staticRoutes done-----")

        logger.log("-----will add TNL3 ETHIF,ETHLK,IPIF  -----")
        try:
            tnl_version = mrbts.TNLSVC[0]['version']
            mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[0].IPADDRESSV6[0].remove()
            ethlk1_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1'
            self.add_object_with_params(distname=ethlk1_dist_name,
                                        klass="com.nokia.srbts.tnl:ETHLK", version=tnl_version,
                                        administrativeState='unlocked',
                                        underLyingInterface='backhaul')

            ethlk2_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2'
            self.add_object_with_params(distname=ethlk2_dist_name,
                                        klass="com.nokia.srbts.tnl:ETHLK", version=tnl_version,
                                        administrativeState='unlocked',
                                        underLyingInterface='fronthaul')

            ethif1_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-1'
            self.add_object_with_params(distname=ethif1_dist_name,
                                        klass="com.nokia.srbts.tnl:ETHIF", version=tnl_version,
                                        linkSelectorDN=ethlk1_dist_name)

            ethif2_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-2'
            self.add_object_with_params(distname=ethif2_dist_name,
                                        klass="com.nokia.srbts.tnl:ETHIF", version=tnl_version,
                                        linkSelectorDN=ethlk2_dist_name)

            ipif1_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1'
            self.add_object_with_params(distname=ipif1_dist_name,
                                        klass="com.nokia.srbts.tnl:IPIF", version=tnl_version,
                                        interfaceDN=ethif1_dist_name,
                                        ipMtu='1500')

            ipif2_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-2'
            self.add_object_with_params(distname=ipif2_dist_name,
                                        klass="com.nokia.srbts.tnl:IPIF", version=tnl_version,
                                        interfaceDN=ethif2_dist_name,
                                        ipMtu='1500')

            ipaddress2v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1'
            self.add_object_with_params(distname=ipaddress2v4_dist_name,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='F1-U')

            if x2u_s1u_same_net:
                ipaddress1v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1'
                self.add_object_with_params(distname=ipaddress1v4_dist_name,
                                            klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                            ipAddressAllocationMethod='DISCOVERED',
                                            uniqueIpAddressIdentifier='S1-U X2-U')
                # mrbts.NRBTS[0].s1Uplane[0].ipV4AddressDN1.value = ipaddress1v4_dist_name
                # mrbts.NRBTS[0].x2Uplane[0].ipV4AddressDN1.value = ipaddress1v4_dist_name

                mrbts.NRBTS[0].s1Uplane[0].remove()
                item = Item().create()
                p = P().create(name='ipV4AddressDN1', value=ipaddress1v4_dist_name)
                item.append(p)
                mrbts.NRBTS[0].s1Uplane.append(item)

                mrbts.NRBTS[0].x2Uplane[0].remove()
                item = Item().create()
                p = P().create(name='ipV4AddressDN1', value=ipaddress1v4_dist_name)
                item.append(p)
                mrbts.NRBTS[0].x2Uplane.append(item)

            else:
                ethlk3_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-3'
                self.add_object_with_params(distname=ethlk3_dist_name,
                                            klass="com.nokia.srbts.tnl:ETHLK", version=tnl_version,
                                            administrativeState='unlocked',
                                            underLyingInterface='x2')

                ethif3_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-3'
                self.add_object_with_params(distname=ethif3_dist_name,
                                            klass="com.nokia.srbts.tnl:ETHIF", version=tnl_version,
                                            linkSelectorDN=ethlk3_dist_name)

                ipaddress1v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1'
                self.add_object_with_params(distname=ipaddress1v4_dist_name,
                                            klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                            ipAddressAllocationMethod='DISCOVERED',
                                            uniqueIpAddressIdentifier='S1-U')

                ipif3_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-3'
                self.add_object_with_params(distname=ipif3_dist_name,
                                            klass="com.nokia.srbts.tnl:IPIF", version=tnl_version,
                                            interfaceDN=ethif3_dist_name,
                                            ipMtu='1500')

                ipaddress3v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-3/IPADDRESSV4-1'
                self.add_object_with_params(distname=ipaddress3v4_dist_name,
                                            klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                            ipAddressAllocationMethod='DISCOVERED',
                                            uniqueIpAddressIdentifier='X2-U')

                # mrbts.NRBTS[0].s1Uplane[0].ipV4AddressDN1.value = ipaddress1v4_dist_name
                # mrbts.NRBTS[0].x2Uplane[0].ipV4AddressDN1.value = ipaddress3v4_dist_name

                mrbts.NRBTS[0].s1Uplane[0].remove()
                item = Item().create()
                p = P().create(name='ipV4AddressDN1', value=ipaddress1v4_dist_name)
                item.append(p)
                mrbts.NRBTS[0].s1Uplane.append(item)

                mrbts.NRBTS[0].x2Uplane[0].remove()
                item = Item().create()
                p = P().create(name='ipV4AddressDN1', value=ipaddress3v4_dist_name)
                item.append(p)
                mrbts.NRBTS[0].x2Uplane.append(item)
                # logger.log("-----add TNL3 ETHIF,ETHLK,IPIF done -----")

            mrbts.MNL[0].MNLENT[0].MPLANENW[0].mPlaneIpv6AddressDN.remove()
            mplaneipv4addressdn_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'
            mplaneipv4addressdn_mo = mrbts.MNL[0].MNLENT[0].MPLANENW[0]
            self.add_object_with_params(mo=mplaneipv4addressdn_mo, mPlaneIpv4AddressDN=mplaneipv4addressdn_p)

            # change ipV6AddressDN1 to ipV4AddressDN1
            f1Cplane_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1'
            mrbts.NRBTS[0].f1Cplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=f1Cplane_p)
            item.append(p)
            mrbts.NRBTS[0].f1Cplane.append(item)

            f1Uplane_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1'
            mrbts.NRBTS[0].f1Uplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=f1Uplane_p)
            item.append(p)
            mrbts.NRBTS[0].f1Uplane.append(item)

            ngCplane_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1'
            mrbts.NRBTS[0].ngCplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=ngCplane_p)
            item.append(p)
            mrbts.NRBTS[0].ngCplane.append(item)

            x2Cplane_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'
            mrbts.NRBTS[0].x2Cplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=x2Cplane_p)
            item.append(p)
            mrbts.NRBTS[0].x2Cplane.append(item)

            xnCplane_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'
            mrbts.NRBTS[0].xnCplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=xnCplane_p)
            item.append(p)
            mrbts.NRBTS[0].xnCplane.append(item)

            mrbts.TNLSVC[0].TNL[1].IPNO[0].IPIF[0].IPADDRESSV6[0].remove()
            tnl2_ipif1_v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'
            self.add_object_with_params(distname=tnl2_ipif1_v4_dist_name,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='X2-C')

            mrbts.TNLSVC[0].TNL[1].IPNO[0].IPIF[1].IPADDRESSV6[0].remove()
            tnl2_ipif2_v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1'
            self.add_object_with_params(distname=tnl2_ipif2_v4_dist_name,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='F1-C')

            mrbts.MNL[0].MNLENT[0].DNS[0].serverIpAddressPrimary.value = dns_forwarders
            mrbts.MNL[0].TCEADM[0].TCE[0].tceIpAddress.value = '10.10.10.10'

            tnl1_ipif1_v4_dist_name = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'
            self.add_object_with_params(distname=tnl1_ipif1_v4_dist_name,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=tnl_version,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='oam ssh')
        except Exception:
            import traceback
            print(traceback.format_exc())

        # adapt for multi-cell
        if 'ANDROID' in context.tl_config.tl_cloud_topology.upper():
            rf_tag = context.tl_config.tl_cloud_topology.split("_")[-2]
        else:
            rf_tag = context.tl_config.tl_cloud_topology.split("_")[-1]
        rmod_number = int(rf_tag.split("x")[0]) if 'x' in rf_tag else 1
        nrbts = '/NRBTS-' + str(context.tl_config.gnbs[0].global_bts_id)

        nrcell_list = []
        nrcellgrp_list = []
        for rmod in range(2, rmod_number+1):
            nrcell_list.append('MRBTS-' + str(mrbts_id) + nrbts + '/NRCELL-{}'.format(rmod))
            nrcellgrp_list.append('MRBTS-' + str(mrbts_id) + nrbts + '/NRCELLGRP-{}'.format(rmod-1))

        mo_copy = {
            mrbts.NRBTS[0].NRCELL[0]: nrcell_list,
            mrbts.NRBTS[0].NRCELLGRP[0]: nrcellgrp_list
        }

        # copy mo
        for copied, new_mo in mo_copy.items():
            for mo_item in new_mo:
                logger.log("@@@@@@@@@ Add new mo: {}@@@@@@@@@@@@@@@@".format(mo_item))
                copied.clone_tree_to(mo_item)

        # add refNrCellGroup value
        for rmod in range(2, rmod_number + 1):
            p = P().create(value=rmod-1)
            mrbts.NRBTS[0].NRDU[0].refNrCellGroup.append(p)

        if hasattr(context, "site_config"):
            logger.log("@@@@@@@@@site_config is {}@@@@@@@@@@@@@@@@".format(context.site_config))
            for rmod in range(0, rmod_number):
                mrbts.NRBTS[0].NRCELL[rmod].lcrId.value = \
                    context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["lcrId"]
                mrbts.NRBTS[0].NRCELLGRP[rmod].nrCellList[0].value = rmod + 1
                if "physCellId" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].physCellId.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["physCellId"]
                if "chBwDl" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].NRCELL_FDD[0].chBwDl.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["chBwDl"]
                if "chBwUl" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].NRCELL_FDD[0].chBwUl.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["chBwUl"]
                if "nrarfcnDl" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].NRCELL_FDD[0].nrarfcnDl.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["nrarfcnDl"]
                if "nrarfcnUl" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].NRCELL_FDD[0].nrarfcnUl.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["nrarfcnUl"]
                if "freqBandIndicatorNR" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].freqBandIndicatorNR.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["freqBandIndicatorNR"]
                if "cellTechnology" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod + 1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].cellTechnology.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod + 1)]["cellTechnology"]
                if "preferredSCellTechnology" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod + 1)]:
                    mrbts.NRBTS[0].NRCELL[rmod].preferredSCellTechnology.value = \
                        context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod + 1)]
                    ["preferredSCellTechnology"]

        mrbts.NRBTS[0].NRCELLGRP[0].scs.value = '15 KHz'
        mrbts.NRBTS[0].NRSYSINFO_PROFILE[0].NRIRFIM[0].freqBandIndicatorNR.value = '5'
        mrbts.NRBTS[0].NRSYSINFO_PROFILE[0].NRIRFIM[0].ssbScs.value = '30 KHz'

        mrbts.NRBTS[0].mcc.value = '262'
        mrbts.NRBTS[0].mnc.value = '3'
        mrbts.NRBTS[0].mncLength.value = '2'

        mrbts.NRBTS[0].NRCTRLTS[0].NRMTRACECU[0].nrRanTraceReference[0].mcc.value = '262'
        mrbts.NRBTS[0].NRCTRLTS[0].NRMTRACECU[0].nrRanTraceReference[0].mnc.value = '3'
        mrbts.NRBTS[0].NRCTRLTS[0].NRMTRACECU[0].nrRanTraceReference[0].mncLength.value = '2'

        mrbts.NRBTS[0].NRPLMN[0].mcc.value = '262'
        mrbts.NRBTS[0].NRPLMN[0].mnc.value = '3'
        mrbts.NRBTS[0].NRPLMN[0].mncLength.value = '2'
        mrbts.TNLSVC[0].TNL[1].ETHSVC[0].ETHLK[0].underLyingInterface.value = 'x2'

        mrbts.NRBTS[0].gNbCuName.value = 'CU_' + str(context.tl_config.gnbs[0].instance_id)
        mrbts.btsName.value = 'CU_' + str(context.tl_config.gnbs[0].instance_id)
