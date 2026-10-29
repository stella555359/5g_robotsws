# -*- coding: utf-8 -*-

__maintainer__ = 'Jinbo Yu'
__team__ = 'VDU AIC CI'
__email__ = 'jinbo.yu@nokia-sbell.com'


from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from common_agent_5g import logger
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def _get_ip(self, item):
        if self.context.tl_config.gnbs[0].cu.backhaul_site_oam_ip.v6:
            return item.v6
        else:
            return item.v4

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

    def _create_route_item(self, dest_ip_addr, gateway, destination_ip_prefix_length):
        item = Item().create()
        p = P().create(name='destIpAddr', value=dest_ip_addr)
        item.append(p)
        p = P().create(name='gateway', value=gateway)
        item.append(p)
        p = P().create(name='destinationIpPrefixLength', value=destination_ip_prefix_length)
        item.append(p)
        return item

    def modify_scf(self, context):
        self.context = context
        taf_scf = self.scf_handler
        # here index 0 means first MRBTS object, index is start from 0
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        du_id = int(context.scfc_path.split("/")[-2].split("_")[-1])

        antl_list = []
        channel_list = []
        nrcell_list = []
        nrcellgrp_list = []
        nrdu_list = []
        lcrId_list = []

        mrbts_id = str(context.tl_config.gnbs[0].instance_id)
        nrbts = '/NRBTS-' + str(context.tl_config.gnbs[0].global_bts_id)

        # mondify scf for vdu_0
        if du_id == 0:
            logger.log("@@@@@@@@@ Modify scf on vDU_{} @@@@@@@@@@@@@@@@".format(du_id))

            # change QT ipv6 scf template to ipv4 scf
            # modify actDualStackIpV4V6ForMplane
            mrbts.MNL[0].MNLENT[0].FEATCADM[0].actDualStackIpV4V6ForMplane.value = "false"

            mrbts.MNL[0].MNLENT[0].MPLANENW[0].mPlaneIpv6AddressDN.remove()
            mplaneipv4addressdn_mo = mrbts.MNL[0].MNLENT[0].MPLANENW[0]
            mplaneipv4addressdn_p = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1'
            self.add_object_with_params(mo=mplaneipv4addressdn_mo, mPlaneIpv4AddressDN=mplaneipv4addressdn_p)

            # remove ipv6 and add ipv4 ipV4AddressDN1 for f1Cplane/f1Uplane
            nrdu_f1Cplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'
            mrbts.NRBTS[0].NRDU[0].f1Cplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=nrdu_f1Cplane)
            item.append(p)
            mrbts.NRBTS[0].NRDU[0].f1Cplane.append(item)

            nrdu_f1Uplane = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1'
            mrbts.NRBTS[0].NRDU[0].f1Uplane[0].remove()
            item = Item().create()
            p = P().create(name='ipV4AddressDN1', value=nrdu_f1Uplane)
            item.append(p)
            mrbts.NRBTS[0].NRDU[0].f1Uplane.append(item)

            # remove staticIpv6Routes/IPADDRESSV6
            try:
                for tnl in range(0, 6):
                    mrbts.TNLSVC[0].TNL[tnl].IPNO[0].IPRTV6[0].staticIpv6Routes.remove()
                    mrbts.TNLSVC[0].TNL[tnl].IPNO[0].IPIF[0].IPADDRESSV6[0].remove()
                mrbts.TNLSVC[0].TNL[3].IPNO[0].IPIF[1].IPADDRESSV6[0].remove()
            except Exception as error:
                logger.log_warn('There is an exception warning: {msg}'.format(msg=error))
                pass

            mnl_version_iprt = mrbts.TNLSVC[0].TNL[0]['version']

            # add uniqueIpAddressIdentifier oam certman/F1-C/F1-U on TNL-1 ~ TNL-3
            new_mo_ipv4 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1'
            self.add_object_with_params(distname=new_mo_ipv4,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=mnl_version_iprt,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='oam certman-server')

            new_mo_ipv4 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'
            self.add_object_with_params(distname=new_mo_ipv4,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=mnl_version_iprt,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='F1-C')

            new_mo_ipv4 = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1'
            self.add_object_with_params(distname=new_mo_ipv4,
                                        klass="com.nokia.srbts.tnl:IPADDRESSV4", version=mnl_version_iprt,
                                        ipAddressAllocationMethod='DISCOVERED',
                                        uniqueIpAddressIdentifier='F1-U')

            # add f1c/f1u staticRoutes on TNL-2/TNL-3
            new_list = List().create('staticRoutes')
            item = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].dus[0].f1_c_ip_addr),
                                           context.tl_config.gnbs[0].dus[0].f1_c_ip_addr.routing.gateway,
                                           context.tl_config.gnbs[0].dus[0].f1_c_ip_addr.routing.ip_prefix_length)
            new_list.append(item)
            mrbts.TNLSVC[0].TNL[1].IPNO[0].IPRT[0].append(new_list)

            new_list = List().create('staticRoutes')
            item = self._create_route_item(self._get_ip(context.tl_config.gnbs[0].dus[0].f1_u_ip_addr),
                                           context.tl_config.gnbs[0].dus[0].f1_u_ip_addr.routing.gateway,
                                           context.tl_config.gnbs[0].dus[0].f1_u_ip_addr.routing.ip_prefix_length)
            new_list.append(item)
            mrbts.TNLSVC[0].TNL[2].IPNO[0].IPRT[0].append(new_list)

            # adapt for multi-cell
            # add new mo list: antl/channel/nrcell/nrcellgrp
            if 'ANDROID' in context.tl_config.tl_cloud_topology.upper():
                rf_tag = context.tl_config.tl_cloud_topology.split("_")[-2]
            else:
                rf_tag = context.tl_config.tl_cloud_topology.split("_")[-1]
            rmod_number = int(rf_tag.split("x")[0]) if 'x' in rf_tag else 1
            for rmod in range(2, rmod_number+1):
                antl_list.append('MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-{}'.format(rmod))
                nrcell_list.append('MRBTS-' + str(mrbts_id) + nrbts + '/NRCELL-{}'.format(rmod))
                nrcellgrp_list.append('MRBTS-' + str(mrbts_id) + nrbts + '/NRCELLGRP-{}'.format(rmod-1))
            for rmod in range(1, rmod_number+1):
                # if lcrId is not 1, then will copy related MO; if lcrId is 1, it will not copy related MO, because
                # there is an issue when remove mo of com.nokia.srbts.mnl:CHANNEL
                if context.site_config["CELL_LIST"][rmod-1]["NRCELL_{}".format(rmod)]["lcrId"] != 1:
                    channel_list.append('MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.
                                        format(context.site_config["CELL_LIST"][rmod-1]["NRCELL_{}".
                                               format(rmod)]["lcrId"]))

            mo_copy = {
                mrbts.EQM[0].APEQM[0].RMOD[0]: antl_list,
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0]: channel_list,
                mrbts.NRBTS[0].NRCELL[0]: nrcell_list,
                mrbts.NRBTS[0].NRCELLGRP[0]: nrcellgrp_list
            }

            # copy mo
            for copied, new_mo in mo_copy.items():
                for mo_item in new_mo:
                    logger.log("@@@@@@@@@ Add new mo: {}@@@@@@@@@@@@@@@@".format(mo_item))
                    copied.clone_tree_to(mo_item)

            # if 1 is not in lcrId, it will remove NRCELL_1
            for rmod in range(1, rmod_number + 1):
                lcrId_list.append(context.site_config["CELL_LIST"][rmod-1]["NRCELL_{}".format(rmod)]["lcrId"])
            if 1 not in lcrId_list:
                for channel in range(0, 4):
                    mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[0].remove()
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].remove()
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].remove()
            # modify antDN in CHANNEL mo
            for rmod in range(1, rmod_number+1):
                for channel in range(0, 2):
                    mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[rmod-1].CHANNELGROUP[0].CHANNEL[channel].antlDN.\
                        value = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-{rmod_id}/ANTL-1'.format(rmod_id=rmod)
                for channel in range(2, 4):
                    mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[rmod - 1].CHANNELGROUP[0].CHANNEL[channel].antlDN.\
                        value = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-{rmod_id}/ANTL-2'.format(rmod_id=rmod)
            # This part for modifying the patameters needs to be add the last of the script.
            try:
                for rmod in range(0, rmod_number):
                    mrbts.EQM[0].APEQM[0].RMOD[rmod].serialNumberPlanned.value = \
                        context.tl_config.gnbs[0].dus[0].fhgws[0].rus[rmod].serial_number
                    if context.tl_config.gnbs[0].dus[0].fhgws[0].rus[rmod].product_code is not None:
                        mrbts.EQM[0].APEQM[0].RMOD[rmod].prodCodePlanned.value = \
                            context.tl_config.gnbs[0].dus[0].fhgws[0].rus[rmod].product_code
            except Exception:
                import traceback
                print(traceback.format_exc())

            # add refNrCellGroup value
            for rmod in range(2, rmod_number + 1):
                p = P().create(value=rmod-1)
                mrbts.NRBTS[0].NRDU[0].refNrCellGroup.append(p)
            if hasattr(context, "site_config"):
                logger.log("@@@@@@@@@site_config is {}@@@@@@@@@@@@@@@@".format(context.site_config))
                try:
                    for rmod in range(0, rmod_number):
                        mrbts.NRBTS[0].NRCELL[rmod].lcrId.value = \
                            context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["lcrId"]
                        mrbts.NRBTS[0].NRCELL[rmod].rModDNList[0].value = \
                            'MRBTS-' + str(mrbts_id) + "/EQM-1/APEQM-1/RMOD-{}".format(rmod+1)
                        mrbts.NRBTS[0].NRCELLGRP[rmod].nrCellList[0].value = rmod+1
                        if "actDl256Qam" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                            mrbts.NRBTS[0].NRCELL[rmod].actDl256Qam.value = \
                                context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["actDl256Qam"]
                        if "physCellId" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                            mrbts.NRBTS[0].NRCELL[rmod].physCellId.value = \
                                context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]["physCellId"]
                        if "freqBandIndicatorNR" in context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(rmod+1)]:
                            mrbts.NRBTS[0].NRCELL[rmod].freqBandIndicatorNR.value = \
                                context.site_config["CELL_LIST"][rmod]["NRCELL_{}".format(
                                    rmod+1)]["freqBandIndicatorNR"]
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
                except Exception:
                    import traceback
                    print(traceback.format_exc())

            mrbts.NRBTS[0].gNbCuName.value = "CU-" + str(mrbts_id)
            mrbts.btsName.value = "5gvDU1"
        # modify scf for multi_du
        elif du_id > 0:
            for vdu_id in range(1, du_id+1):
                try:
                    logger.log("@@@@@@@@@ Modify scf on vDU_{} @@@@@@@@@@@@@@@@".format(vdu_id))
                    if context.site_config["CELL_LIST"][du_id]["NRCELL_{}".format(du_id+1)]["lcrId"] != 1:
                        channel_list.append('MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.
                                            format(context.site_config["CELL_LIST"][vdu_id]["NRCELL_{}".
                                                   format(vdu_id + 1)]["lcrId"]))
                    nrcellgrp_list.append('MRBTS-' + str(mrbts_id) + nrbts + '/NRCELLGRP-{}'.format(vdu_id))
                    nrdu_list.append('MRBTS-' + str(mrbts_id) + nrbts + '/NRDU-{}'.format(vdu_id + 1))
                    mo_copy = {
                        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0]: channel_list,
                        mrbts.NRBTS[0].NRCELLGRP[0]: nrcellgrp_list,
                        mrbts.NRBTS[0].NRDU[0]: nrdu_list
                    }

                    # copy mo
                    for copied, new_mo in mo_copy.items():
                        for mo_item in new_mo:
                            logger.log("@@@@@@@@@ Add new mo: {}@@@@@@@@@@@@@@@@".format(mo_item))
                            copied.clone_tree_to(mo_item)

                    # remove LCELNR-1
                    if context.site_config["CELL_LIST"][du_id]["NRCELL_{}".format(du_id+1)]["lcrId"] != 1:
                        for channel in range(0, 4):
                            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[0].remove()
                        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].remove()
                        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].remove()

                    mrbts.NRBTS[0].NRCELLGRP[0].remove()
                    mrbts.NRBTS[0].NRDU[0].remove()

                    mrbts.btsName.value = "5gvDU{}".format(vdu_id + 1)
                    mrbts.EQM[0].APEQM[0].RMOD[0].serialNumberPlanned.value = \
                        context.tl_config.gnbs[0].dus[vdu_id].fhgws[0].rus[0].serial_number
                    if context.tl_config.gnbs[0].dus[vdu_id].fhgws[0].rus[0].product_code is not None:
                        mrbts.EQM[0].APEQM[0].RMOD[0].prodCodePlanned.value = \
                            context.tl_config.gnbs[0].dus[vdu_id].fhgws[0].rus[0].product_code
                    mrbts.NRBTS[0].NRCELL[0].lcrId.value = \
                        context.site_config["CELL_LIST"][vdu_id]["NRCELL_{}".format(vdu_id + 1)]["lcrId"]
                    if "physCellId" in context.site_config["CELL_LIST"][vdu_id]["NRCELL_{}".format(vdu_id + 1)]:
                        mrbts.NRBTS[0].NRCELL[0].physCellId.value = \
                            context.site_config["CELL_LIST"][vdu_id]["NRCELL_{}".format(vdu_id + 1)]["physCellId"]
                    mrbts.NRBTS[0].NRDU[0].gNbDuId.value = vdu_id
                    mrbts.NRBTS[0].NRDU[0].refNrCellGroup[0].value = vdu_id
                    mrbts.TNLSVC[0].TNL[1].IPNO[0].IPRT[0].staticRoutes[0].gateway.value = \
                        context.tl_config.gnbs[0].dus[vdu_id].f1_c_ip_addr.routing.gateway
                    mrbts.TNLSVC[0].TNL[2].IPNO[0].IPRT[0].staticRoutes[0].gateway.value = \
                        context.tl_config.gnbs[0].dus[vdu_id].f1_u_ip_addr.routing.gateway
                except Exception as error:
                    logger.log_warn('There is an exception warning: {msg}'.format(msg=error))
                    pass
