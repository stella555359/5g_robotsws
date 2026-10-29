from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import P
from taf.internal.scf.list import Item
from taf.internal.scf.list import List
from taf.internal.scf.exceptions import ElementNotFound


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        scf = self.scf_handler
        mrbts = scf.raml.cmData.MRBTS[0]
        mrbts_id = context.tl_config.gnbs[0].global_bts_id
        mnl_ver = mrbts.MNL[0]._tree.attrib["version"]
        tnlsvc_ver = mrbts.TNLSVC[0]._tree.attrib["version"]
        nrbts_ver = mrbts.NRBTS[0]._tree.attrib["version"]
        virtual_ip_addr_ngu = "8.8.8.8"  # !!!!!!!!!!
        virtual_ip_addr_xnu = "6.6.6.6"  # !!!!!!!!!!
        IPSEC_endpoint_1 = "3.3.3.3"  # !!!!!!!!!!
        IPSEC_endpoint_2 = "4.4.4.4"  # !!!!!!!!!!
        backhaul_oam_ip = context.tl_config.gnbs[0].cu.backhaul_site_oam_ip.v4
        backhaul_oam_ip_gateway = context.tl_config.gnbs[0].cu.backhaul_site_oam_ip.routing_v4.gateway
        x2c_ip = context.tl_config.gnbs[0].cu.x2c.v4
        x2c_ip_gateway = context.tl_config.gnbs[0].cu.x2c.routing_v4.gateway
        x2u_ip = context.tl_config.gnbs[0].cu.x2u.v4
        x2u_ip_gateway = context.tl_config.gnbs[0].cu.x2u.routing_v4.gateway
        s1u_ip = context.tl_config.gnbs[0].cu.s1u.v4
        s1u_ip_gateway = context.tl_config.gnbs[0].cu.s1u.routing_v4.gateway
        xnc_ip = context.tl_config.gnbs[0].cu.xnc.v4
        xnc_ip_gateway = context.tl_config.gnbs[0].cu.xnc.routing_v4.gateway
        xnu_ip = context.tl_config.gnbs[0].cu.xnu.v4
        xnu_ip_gateway = context.tl_config.gnbs[0].cu.xnu.routing_v4.gateway
        ngc_ip = context.tl_config.gnbs[0].cu.ngc.v4
        ngc_ip_gateway = context.tl_config.gnbs[0].cu.ngc.routing_v4.gateway
        ngu_ip = context.tl_config.gnbs[0].cu.ngu.v4
        ngu_ip_gateway = context.tl_config.gnbs[0].cu.ngu.routing_v4.gateway
        sd_1 = "13714341"
        sd_2 = "11259375"
        TAC = context.tl_config.core.five_g.tac
        UPF_ip_addr1 = "10.35.111.240"
        UPF_ip_addr2 = "10.35.111.242"
        amf_ip = context.tl_config.core.five_g.amf.n2.v4

        # configure nGU
        NRBTS = mrbts.NRBTS[0]
        NRBTS.ngUplane[0].remove()

        new_list_ngu = List().create(name="ngUplane")
        item_ngu1 = Item().create()
        png1 = P().create(name="ipV4AddressDN1",
                          value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9/IPADDRESSV4-1".format(mrbts_id))
        item_ngu1.append(png1)
        mrbts.NRBTS[0].ngUplane.append(item_ngu1)
        item_ngu2 = Item().create()
        png2 = P().create(name="ipV4AddressDN1",
                          value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9/IPADDRESSV4-2".format(mrbts_id))
        item_ngu2.append(png2)
        new_list_ngu.append(item_ngu1)
        new_list_ngu.append(item_ngu2)
        NRBTS.append(new_list_ngu)
        self.scf_handler.raml.cmData.append(NRBTS)

        try:
            NRBTS.gNbCuType.value = 'SA'
            NRBTS.NRCELL[0].cellDepType.value = 'SA'
            NRBTS.x2LinkSupervisionTmr.value = '0'
            NRBTS.NRCELL[0].configuredEpsTac.remove()
        except ElementNotFound:
            pass

        # configure SERVEDAMF-1 object
        try:
            mrbts.NRBTS[0].SERVEDAMF[0].remove()
        except ElementNotFound:
            pass
        servedamf_obj1 = ManagedObject().create(
            klass="com.nokia.srbts.nrbts:SERVEDAMF",
            dist_name="MRBTS-{}/NRBTS-{}/SERVEDAMF-1".format(mrbts_id, mrbts_id),
            version=nrbts_ver,
            operation="create"
        )
        servedamf_obj1.append(P().create(name="administrativeState", value="Unlocked"))
        servedamf_obj1.append(P().create(name="amfIPAddress", value=amf_ip))
        servedamf_obj1.append(P().create(name="defaultAMF", value="true"))
        self.scf_handler.raml.cmData.append(servedamf_obj1)

        # Configure IPRT-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].remove()
        except ElementNotFound:
            pass
        iprt_obj1 = ManagedObject().create(
            klass="com.nokia.srbts.tnl:IPRT",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        new_list_iprt1 = List().create(name="staticRoutes")

        item_i1 = Item().create()
        pi11 = P().create(name="destinationIpPrefixLength", value="0")
        pi12 = P().create(name="destIpAddr", value="0.0.0.0")
        pi13 = P().create(name="gateway", value=backhaul_oam_ip_gateway)
        pi14 = P().create(name="preference", value="1")
        pi15 = P().create(name="routeIpMTU", value="1500")
        item_i1.append(pi11)
        item_i1.append(pi12)
        item_i1.append(pi13)
        item_i1.append(pi14)
        item_i1.append(pi15)
        new_list_iprt1.append(item_i1)

        item_i2 = Item().create()
        pi21 = P().create(name="destinationIpPrefixLength", value="0")
        pi22 = P().create(name="destIpAddr", value="0.0.0.0")
        pi23 = P().create(name="gateway", value=x2c_ip_gateway)
        pi24 = P().create(name="preference", value="2")
        pi25 = P().create(name="routeIpMTU", value="1500")
        item_i2.append(pi21)
        item_i2.append(pi22)
        item_i2.append(pi23)
        item_i2.append(pi24)
        item_i2.append(pi25)
        new_list_iprt1.append(item_i2)

        item_i3 = Item().create()
        pi31 = P().create(name="destinationIpPrefixLength", value="0")
        pi32 = P().create(name="destIpAddr", value="0.0.0.0")
        pi33 = P().create(name="gateway", value=x2u_ip_gateway)
        pi34 = P().create(name="preference", value="3")
        pi35 = P().create(name="routeIpMTU", value="1500")
        item_i3.append(pi31)
        item_i3.append(pi32)
        item_i3.append(pi33)
        item_i3.append(pi34)
        item_i3.append(pi35)
        new_list_iprt1.append(item_i3)

        item_i4 = Item().create()
        pi41 = P().create(name="destinationIpPrefixLength", value="0")
        pi42 = P().create(name="destIpAddr", value="0.0.0.0")
        pi43 = P().create(name="gateway", value=s1u_ip_gateway)
        pi44 = P().create(name="preference", value="4")
        pi45 = P().create(name="routeIpMTU", value="1500")
        item_i4.append(pi41)
        item_i4.append(pi42)
        item_i4.append(pi43)
        item_i4.append(pi44)
        item_i4.append(pi45)
        new_list_iprt1.append(item_i4)

        item_i5 = Item().create()
        pi51 = P().create(name="destinationIpPrefixLength", value="0")
        pi52 = P().create(name="destIpAddr", value="0.0.0.0")
        pi53 = P().create(name="gateway", value=xnc_ip_gateway)
        pi54 = P().create(name="preference", value="5")
        pi55 = P().create(name="routeIpMTU", value="1500")
        item_i5.append(pi51)
        item_i5.append(pi52)
        item_i5.append(pi53)
        item_i5.append(pi54)
        item_i5.append(pi55)
        new_list_iprt1.append(item_i5)

        item_i7 = Item().create()
        pi71 = P().create(name="destinationIpPrefixLength", value="0")
        pi72 = P().create(name="destIpAddr", value="0.0.0.0")
        pi73 = P().create(name="gateway", value=ngc_ip_gateway)
        pi74 = P().create(name="preference", value="7")
        pi75 = P().create(name="routeIpMTU", value="1500")
        item_i7.append(pi71)
        item_i7.append(pi72)
        item_i7.append(pi73)
        item_i7.append(pi74)
        item_i7.append(pi75)
        new_list_iprt1.append(item_i7)

        iprt_obj1.append(new_list_iprt1)
        self.scf_handler.raml.cmData.append(iprt_obj1)

        # Configure IPRT-2 object
        iprt_num1 = len(mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT)
        if iprt_num1 > 0:
            iprt_obj2 = ManagedObject().create(
                klass="com.nokia.srbts.tnl:IPRT",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPRT-2".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            new_list_iprt2 = List().create(name="staticRoutes")
            item_i8 = Item().create()
            pi81 = P().create(name="destinationIpPrefixLength", value="0")
            pi82 = P().create(name="destIpAddr", value=UPF_ip_addr1)
            pi83 = P().create(name="gateway", value=ngu_ip_gateway)
            pi84 = P().create(name="preference", value="6")
            pi85 = P().create(name="routeIpMTU", value="1500")
            pi86 = P().create(name="preSrcIpv4Addr", value=ngu_ip)
            item_i8.append(pi81)
            item_i8.append(pi82)
            item_i8.append(pi83)
            item_i8.append(pi84)
            item_i8.append(pi85)
            item_i8.append(pi86)
            new_list_iprt2.append(item_i8)
            iprt_obj2.append(new_list_iprt2)
            self.scf_handler.raml.cmData.append(iprt_obj2)

        # Configure IPRT-3 object
        iprt_num1 = len(mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT)
        if iprt_num1 > 1:
            iprt_obj3 = ManagedObject().create(
                klass="com.nokia.srbts.tnl:IPRT",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPRT-3".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            new_list_iprt3 = List().create(name="staticRoutes")
            item_i6 = Item().create()
            pi61 = P().create(name="destinationIpPrefixLength", value="0")
            pi62 = P().create(name="destIpAddr", value=UPF_ip_addr2)
            pi63 = P().create(name="gateway", value=xnu_ip_gateway)
            pi64 = P().create(name="preference", value="8")
            pi65 = P().create(name="routeIpMTU", value="1500")
            pi66 = P().create(name="preSrcIpv4Addr", value=xnu_ip)
            item_i6.append(pi61)
            item_i6.append(pi62)
            item_i6.append(pi63)
            item_i6.append(pi64)
            item_i6.append(pi65)
            item_i6.append(pi66)
            new_list_iprt3.append(item_i6)
            iprt_obj3.append(new_list_iprt3)
            self.scf_handler.raml.cmData.append(iprt_obj3)

        # Configure RTPOL-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPNO[0].RTPOL[0].remove()
        except ElementNotFound:
            pass
        rtpol_obj1 = ManagedObject().create(
            klass="com.nokia.srbts.tnl:RTPOL",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        new_list_rtpol1 = List().create(name="routingPolicies")

        item_r1 = Item().create()
        pr11 = P().create(name="orderNumber", value="1")
        pr12 = P().create(name="routingTableDN", value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1".format(mrbts_id))
        pr13 = P().create(name="srcIpAddress", value="0.0.0.0")
        pr14 = P().create(name="srcIpPrefixLength", value="24")
        item_r1.append(pr11)
        item_r1.append(pr12)
        item_r1.append(pr13)
        item_r1.append(pr14)
        new_list_rtpol1.append(item_r1)

        item_r2 = Item().create()
        pr21 = P().create(name="orderNumber", value="2")
        pr22 = P().create(name="routingTableDN", value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPRT-2".format(mrbts_id))
        pr23 = P().create(name="srcIpAddress", value=virtual_ip_addr_ngu)
        pr24 = P().create(name="srcIpPrefixLength", value="32")
        item_r2.append(pr21)
        item_r2.append(pr22)
        item_r2.append(pr23)
        item_r2.append(pr24)
        new_list_rtpol1.append(item_r2)

        item_r3 = Item().create()
        pr31 = P().create(name="orderNumber", value="3")
        pr32 = P().create(name="routingTableDN", value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPRT-3".format(mrbts_id))
        pr33 = P().create(name="srcIpAddress", value=virtual_ip_addr_xnu)
        pr34 = P().create(name="srcIpPrefixLength", value="32")
        item_r3.append(pr31)
        item_r3.append(pr32)
        item_r3.append(pr33)
        item_r3.append(pr34)
        new_list_rtpol1.append(item_r3)

        rtpol_obj1.append(new_list_rtpol1)
        self.scf_handler.raml.cmData.append(rtpol_obj1)

        # Configure SNSSAI-1 object
        try:
            mrbts.NRBTS[0].SNSSAI[0].remove()
        except ElementNotFound:
            pass
        snssai_obj1 = ManagedObject().create(
            klass="com.nokia.srbts.nrbts:SNSSAI",
            dist_name="MRBTS-{}/NRBTS-{}/SNSSAI-1".format(mrbts_id, mrbts_id),
            version=nrbts_ver,
            operation="create"
        )
        new_list_s11 = List().create(name="ngUplane")
        item_s11 = Item().create()
        ps11 = P().create(name="ipV4AddressDN1",
                          value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9/IPADDRESSV4-1".format(mrbts_id))
        item_s11.append(ps11)
        new_list_s11.append(item_s11)
        snssai_obj1.append(new_list_s11)

        new_list_s12 = List().create(name="nrPlmnDNList")
        # item_s12 = Item().create()
        # ps12 = P().create(name=None,
        #                   value="MRBTS-{}/NRBTS-{}/NRPLMN-1".format(mrbts_id, mrbts_id))
        # item_s12.append(ps12)
        # new_list_s12.append(item_s12)
        new_list_s12.append(P().create(value="MRBTS-{}/NRBTS-{}/NRPLMN-1".format(mrbts_id, mrbts_id)))
        snssai_obj1.append(new_list_s12)

        snssai_obj1.append(P().create(name="administrativeState", value="Unlocked"))
        snssai_obj1.append(P().create(name="sd", value=sd_1))
        snssai_obj1.append(P().create(name="sst", value="1"))
        self.scf_handler.raml.cmData.append(snssai_obj1)

        # Configure SNSSAI-2 object
        snssai_num2 = len(mrbts.NRBTS[0].SNSSAI)
        if snssai_num2 > 0:
            snssai_obj2 = ManagedObject().create(
                klass="com.nokia.srbts.nrbts:SNSSAI",
                dist_name="MRBTS-{}/NRBTS-{}/SNSSAI-2".format(mrbts_id, mrbts_id),
                version=nrbts_ver,
                operation="create"
            )
            new_list_s21 = List().create(name="ngUplane")
            item_s21 = Item().create()
            ps21 = P().create(name="ipV4AddressDN1",
                              value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9/IPADDRESSV4-2".format(mrbts_id))
            item_s21.append(ps21)
            new_list_s21.append(item_s21)
            snssai_obj2.append(new_list_s21)

            new_list_s22 = List().create(name="nrPlmnDNList")
            # item_s22 = Item().create()
            # ps22 = P().create(name=None,
            #                   value="MRBTS-{}/NRBTS-{}/NRPLMN-1".format(mrbts_id, mrbts_id))
            # item_s22.append(ps22)
            # new_list_s22.append(item_s22)
            new_list_s22.append(P().create(value="MRBTS-{}/NRBTS-{}/NRPLMN-1".format(mrbts_id, mrbts_id)))
            snssai_obj2.append(new_list_s22)

            snssai_obj2.append(P().create(name="administrativeState", value="Unlocked"))
            snssai_obj2.append(P().create(name="sd", value=sd_2))
            snssai_obj2.append(P().create(name="sst", value="1"))
            self.scf_handler.raml.cmData.append(snssai_obj2)

        # Configure TRACKINGAREA object
        try:
            mrbts.NRBTS[0].TRACKINGAREA[0].remove()
        except ElementNotFound:
            pass
        tac_obj1 = ManagedObject().create(
            klass="com.nokia.srbts.nrbts:TRACKINGAREA",
            dist_name="MRBTS-{}/NRBTS-{}/TRACKINGAREA-0".format(mrbts_id, mrbts_id),
            version=nrbts_ver,
            operation="create"
        )
        new_list_tac = List().create(name="snssaiDNList")
        # new_list_tac = List().create(name="snssaiDNList")
        # item_t1 = Item().create()
        # pt1 = P().create(name=None, value="MRBTS-{}/NRBTS-{}/SNSSAI-1".format(mrbts_id, mrbts_id))
        # pt2 = P().create(name=None, value="MRBTS-{}/NRBTS-{}/SNSSAI-2".format(mrbts_id, mrbts_id))
        # item_t1.append(pt1)
        # item_t1.append(pt2)
        # new_list_tac.append(item_t1)
        new_list_tac.append(P().create(value="MRBTS-{}/NRBTS-{}/SNSSAI-1".format(mrbts_id, mrbts_id)))
        new_list_tac.append(P().create(value="MRBTS-{}/NRBTS-{}/SNSSAI-2".format(mrbts_id, mrbts_id)))

        tac_obj1.append(new_list_tac)
        tac_obj1.append(P().create(name="fiveGsTac", value=TAC))
        self.scf_handler.raml.cmData.append(tac_obj1)

        # Configure IPIF-9 object
        ipif9_num = len(mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF)
        if ipif9_num > 7:
            ipif9_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:IPIF",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            ipif9_obj.append(P().create(name="ipMtu", value="1500"))
            ipif9_obj.append(P().create(name="userLabel", value="VIRTUAL IP"))
            self.scf_handler.raml.cmData.append(ipif9_obj)

        # Configure IPADDRESSV4-1 object
        ipaddressv4_obj = ManagedObject().create(
            klass="com.nokia.srbts.tnl:IPADDRESSV4",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9/IPADDRESSV4-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        ipaddressv4_obj.append(P().create(name="ipAddressAllocationMethod", value="MANUAL"))
        ipaddressv4_obj.append(P().create(name="localIpAddr", value=virtual_ip_addr_ngu))
        self.scf_handler.raml.cmData.append(ipaddressv4_obj)

        # Configure IPADDRESSV4-2 object
        ipaddressv4_num2 = len(mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF)
        if ipaddressv4_num2 > 0:
            ipaddressv4_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:IPADDRESSV4",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-9/IPADDRESSV4-2".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            ipaddressv4_obj.append(P().create(name="ipAddressAllocationMethod", value="MANUAL"))
            ipaddressv4_obj.append(P().create(name="localIpAddr", value=virtual_ip_addr_xnu))
            self.scf_handler.raml.cmData.append(ipaddressv4_obj)

        # Configure IPAPP-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPAPP[0].remove()
        except ElementNotFound:
            pass
        ipapp_obj = ManagedObject().create(
            klass="com.nokia.srbts.tnl:IPAPP",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        ipapp_obj.append(P().create(name="twampSenderMessageRate", value="RATE_10"))
        self.scf_handler.raml.cmData.append(ipapp_obj)

        # Configure IPSECC-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].remove()
        except ElementNotFound:
            pass
        ipsecc_obj = ManagedObject().create(
            klass="com.nokia.srbts.tnl:IPSECC",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        ipsecc_obj.append(P().create(name="authenticationScheme", value="CERTIFICATE"))
        ipsecc_obj.append(P().create(name="ikeDpdBackoff", value="18"))
        ipsecc_obj.append(P().create(name="ikeDpdRetransmits", value="2"))
        ipsecc_obj.append(P().create(name="ikeDpdTimeout", value="4"))
        ipsecc_obj.append(P().create(name="ikeDscp", value="46"))
        ipsecc_obj.append(P().create(name="ipFragmentationAlgorithm", value="Pre-fragmentation"))
        ipsecc_obj.append(P().create(name="ipSecEnabled", value="true"))
        self.scf_handler.raml.cmData.append(ipsecc_obj)

        # Configure IKEP-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].IKEP[0].remove()
        except ElementNotFound:
            pass
        ikep_obj = ManagedObject().create(
            klass="com.nokia.srbts.tnl:IKEP",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        ikep_obj.append(P().create(name="connectionEstablishmentMode", value="INITIATOR_AND_RESPONDER"))
        ikep_obj.append(P().create(name="dpdDelay", value="10"))
        ikep_obj.append(P().create(name="ikeAuthenticationMethod", value="AUTH_HMAC_SHA1_96"))
        ikep_obj.append(P().create(name="ikeDiffHellGrp", value="DH14"))
        ikep_obj.append(P().create(name="ikeEncryptionMethod", value="ENC_AES_128_CBC"))
        ikep_obj.append(P().create(name="ikeMaxLifeTime", value="86400"))
        ikep_obj.append(P().create(name="ipsecPerfForwSecEnabled", value="false"))
        ikep_obj.append(P().create(
            name="localTunnelEndpointDN",
            value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-8/IPADDRESSV4-1".format(mrbts_id)))
        ikep_obj.append(P().create(name="remoteTunnelEndpoint", value=IPSEC_endpoint_1))
        self.scf_handler.raml.cmData.append(ikep_obj)

        # Configure IKEP-2 object
        ikep_num2 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].IKEP)
        if ikep_num2 > 0:
            ikep_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:IKEP",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-2".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            ikep_obj.append(P().create(name="connectionEstablishmentMode", value="INITIATOR_AND_RESPONDER"))
            ikep_obj.append(P().create(name="dpdDelay", value="10"))
            ikep_obj.append(P().create(name="ikeAuthenticationMethod", value="AUTH_HMAC_SHA1_96"))
            ikep_obj.append(P().create(name="ikeDiffHellGrp", value="DH14"))
            ikep_obj.append(P().create(name="ikeEncryptionMethod", value="ENC_AES_128_CBC"))
            ikep_obj.append(P().create(name="ikeMaxLifeTime", value="86400"))
            ikep_obj.append(P().create(name="ipsecPerfForwSecEnabled", value="false"))
            ikep_obj.append(P().create(
                name="localTunnelEndpointDN",
                value="MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-6/IPADDRESSV4-1".format(mrbts_id)))
            ikep_obj.append(P().create(name="remoteTunnelEndpoint", value=IPSEC_endpoint_2))
            self.scf_handler.raml.cmData.append(ikep_obj)

        # Configure IPSECP-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].IPSECP[0].remove()
        except ElementNotFound:
            pass
        ipsecp_obj = ManagedObject().create(
            klass="com.nokia.srbts.tnl:IPSECP",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IPSECP-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        ipsecp_obj.append(P().create(name="antiReplayEnabled", value="true"))
        ipsecp_obj.append(P().create(name="antiReplayWindowSize", value="SIZE_256"))
        ipsecp_obj.append(P().create(name="authenticationMethod", value="AUTH_HMAC_SHA1_96"))
        ipsecp_obj.append(P().create(name="encryptionMethod", value="ENC_AES_128_CBC"))
        ipsecp_obj.append(P().create(name="extendedSequenceNumberMode", value="NORMAL_SEQUENCE"))
        ipsecp_obj.append(P().create(name="pfsDiffHellGrp", value="DH14"))
        ipsecp_obj.append(P().create(name="saMaxLifeTime", value="86400"))
        self.scf_handler.raml.cmData.append(ipsecp_obj)

        # Configure IPSECP-2 object
        ipsecp_num2 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC)
        if ipsecp_num2 > 0:
            ipsecp_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:IPSECP",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IPSECP-2".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            ipsecp_obj.append(P().create(name="antiReplayEnabled", value="true"))
            ipsecp_obj.append(P().create(name="antiReplayWindowSize", value="SIZE_256"))
            ipsecp_obj.append(P().create(name="authenticationMethod", value="AUTH_HMAC_SHA1_96"))
            ipsecp_obj.append(P().create(name="encryptionMethod", value="ENC_AES_128_CBC"))
            ipsecp_obj.append(P().create(name="extendedSequenceNumberMode", value="NORMAL_SEQUENCE"))
            ipsecp_obj.append(P().create(name="pfsDiffHellGrp", value="DH14"))
            ipsecp_obj.append(P().create(name="saMaxLifeTime", value="86400"))
            self.scf_handler.raml.cmData.append(ipsecp_obj)

        # Configure SECPOL-1 object
        try:
            mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL[0].remove()
        except ElementNotFound:
            pass
        secpol1_obj = ManagedObject().create(
            klass="com.nokia.srbts.tnl:SECPOL",
            dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-1".format(mrbts_id),
            version=tnlsvc_ver,
            operation="create"
        )
        secpol1_obj.append(P().create(name="ipSecAction", value="BYPASS"))
        secpol1_obj.append(P().create(name="policyOrderNumber", value="1001"))
        new_list1 = List().create(name="trafficSelectorList")
        item1 = Item().create()
        p11 = P().create(name="localIpAddress", value=backhaul_oam_ip)
        p12 = P().create(name="localIpPort", value="-1")
        p13 = P().create(name="localIpPrefixLength", value="32")
        p14 = P().create(name="protocol", value="-1")
        p15 = P().create(name="remoteIpAddress", value="0.0.0.0")
        p16 = P().create(name="remoteIpPort", value="-1")
        p17 = P().create(name="remoteIpPrefixLength", value="0")
        item1.append(p11)
        item1.append(p12)
        item1.append(p13)
        item1.append(p14)
        item1.append(p15)
        item1.append(p16)
        item1.append(p17)
        new_list1.append(item1)
        secpol1_obj.append(new_list1)
        self.scf_handler.raml.cmData.append(secpol1_obj)

        # Configure SECPOL-2 object
        secpol_num2 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num2 > 0:
            secpol2_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-2".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol2_obj.append(P().create(name="ipSecAction", value="BYPASS"))
            secpol2_obj.append(P().create(name="policyOrderNumber", value="1002"))
            new_list2 = List().create(name="trafficSelectorList")
            item2 = Item().create()
            p21 = P().create(name="localIpAddress", value=x2c_ip)
            p22 = P().create(name="localIpPort", value="-1")
            p23 = P().create(name="localIpPrefixLength", value="32")
            p24 = P().create(name="protocol", value="-1")
            p25 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p26 = P().create(name="remoteIpPort", value="-1")
            p27 = P().create(name="remoteIpPrefixLength", value="0")
            item2.append(p21)
            item2.append(p22)
            item2.append(p23)
            item2.append(p24)
            item2.append(p25)
            item2.append(p26)
            item2.append(p27)
            new_list2.append(item2)
            secpol2_obj.append(new_list2)
            self.scf_handler.raml.cmData.append(secpol2_obj)

        # Configure SECPOL-3 object
        secpol_num3 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num3 > 1:
            secpol3_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-3".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol3_obj.append(P().create(name="ipSecAction", value="BYPASS"))
            secpol3_obj.append(P().create(name="policyOrderNumber", value="1003"))
            new_list3 = List().create(name="trafficSelectorList")
            item3 = Item().create()
            p31 = P().create(name="localIpAddress", value=x2u_ip)
            p32 = P().create(name="localIpPort", value="-1")
            p33 = P().create(name="localIpPrefixLength", value="32")
            p34 = P().create(name="protocol", value="-1")
            p35 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p36 = P().create(name="remoteIpPort", value="-1")
            p37 = P().create(name="remoteIpPrefixLength", value="0")
            item3.append(p31)
            item3.append(p32)
            item3.append(p33)
            item3.append(p34)
            item3.append(p35)
            item3.append(p36)
            item3.append(p37)
            new_list3.append(item3)
            secpol3_obj.append(new_list3)
            self.scf_handler.raml.cmData.append(secpol3_obj)

        # Configure SECPOL-4 object
        secpol_num4 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num4 > 2:
            secpol4_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-4".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol4_obj.append(P().create(name="ipSecAction", value="BYPASS"))
            secpol4_obj.append(P().create(name="policyOrderNumber", value="1004"))
            new_list4 = List().create(name="trafficSelectorList")
            item4 = Item().create()
            p41 = P().create(name="localIpAddress", value=s1u_ip)
            p42 = P().create(name="localIpPort", value="-1")
            p43 = P().create(name="localIpPrefixLength", value="32")
            p44 = P().create(name="protocol", value="-1")
            p45 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p46 = P().create(name="remoteIpPort", value="-1")
            p47 = P().create(name="remoteIpPrefixLength", value="0")
            item4.append(p41)
            item4.append(p42)
            item4.append(p43)
            item4.append(p44)
            item4.append(p45)
            item4.append(p46)
            item4.append(p47)
            new_list4.append(item4)
            secpol4_obj.append(new_list4)
            self.scf_handler.raml.cmData.append(secpol4_obj)

        # Configure SECPOL-5 object
        secpol_num5 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num5 > 3:
            secpol5_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-5".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol5_obj.append(P().create(name="ipSecAction", value="BYPASS"))
            secpol5_obj.append(P().create(name="policyOrderNumber", value="1005"))
            new_list5 = List().create(name="trafficSelectorList")
            item5 = Item().create()
            p51 = P().create(name="localIpAddress", value=xnc_ip)
            p52 = P().create(name="localIpPort", value="-1")
            p53 = P().create(name="localIpPrefixLength", value="32")
            p54 = P().create(name="protocol", value="-1")
            p55 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p56 = P().create(name="remoteIpPort", value="-1")
            p57 = P().create(name="remoteIpPrefixLength", value="0")
            item5.append(p51)
            item5.append(p52)
            item5.append(p53)
            item5.append(p54)
            item5.append(p55)
            item5.append(p56)
            item5.append(p57)
            new_list5.append(item5)
            secpol5_obj.append(new_list5)
            self.scf_handler.raml.cmData.append(secpol5_obj)

        # Configure SECPOL-6 object
        secpol_num6 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num6 > 4:
            secpol6_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-6".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol6_obj.append(P().create(
                name="ikePDN",
                value="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-2".format(mrbts_id)))
            secpol6_obj.append(P().create(name="ipSecAction", value="PROTECT"))
            secpol6_obj.append(P().create(
                name="ipSecPDN",
                value="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IPSECP-2".format(mrbts_id)))
            secpol6_obj.append(P().create(name="policyOrderNumber", value="3006"))
            new_list6 = List().create(name="trafficSelectorList")
            item6 = Item().create()
            p61 = P().create(name="localIpAddress", value=virtual_ip_addr_xnu)
            p62 = P().create(name="localIpPort", value="-1")
            p63 = P().create(name="localIpPrefixLength", value="32")
            p64 = P().create(name="protocol", value="-1")
            p65 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p66 = P().create(name="remoteIpPort", value="-1")
            p67 = P().create(name="remoteIpPrefixLength", value="0")
            item6.append(p61)
            item6.append(p62)
            item6.append(p63)
            item6.append(p64)
            item6.append(p65)
            item6.append(p66)
            item6.append(p67)
            new_list6.append(item6)
            secpol6_obj.append(new_list6)
            self.scf_handler.raml.cmData.append(secpol6_obj)

        # Configure SECPOL-7 object
        secpol_num7 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num7 > 5:
            secpol7_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-7".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol7_obj.append(P().create(name="ipSecAction", value="BYPASS"))
            secpol7_obj.append(P().create(name="policyOrderNumber", value="1007"))
            new_list7 = List().create(name="trafficSelectorList")
            item7 = Item().create()
            p71 = P().create(name="localIpAddress", value=ngc_ip)
            p72 = P().create(name="localIpPort", value="-1")
            p73 = P().create(name="localIpPrefixLength", value="32")
            p74 = P().create(name="protocol", value="-1")
            p75 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p76 = P().create(name="remoteIpPort", value="-1")
            p77 = P().create(name="remoteIpPrefixLength", value="0")
            item7.append(p71)
            item7.append(p72)
            item7.append(p73)
            item7.append(p74)
            item7.append(p75)
            item7.append(p76)
            item7.append(p77)
            new_list7.append(item7)
            secpol7_obj.append(new_list7)
            self.scf_handler.raml.cmData.append(secpol7_obj)

        # Configure SECPOL-8 object
        secpol_num8 = len(mrbts.TNLSVC[0].TNL[0].IPAPP[0].IPSECC[0].SECPOL)
        if secpol_num8 > 6:
            secpol8_obj = ManagedObject().create(
                klass="com.nokia.srbts.tnl:SECPOL",
                dist_name="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/SECPOL-8".format(mrbts_id),
                version=tnlsvc_ver,
                operation="create"
            )
            secpol8_obj.append(P().create(
                name="ikePDN",
                value="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1".format(mrbts_id)))
            secpol8_obj.append(P().create(name="ipSecAction", value="PROTECT"))
            secpol8_obj.append(P().create(
                name="ipSecPDN",
                value="MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IPSECP-1".format(mrbts_id)))
            secpol8_obj.append(P().create(name="policyOrderNumber", value="3008"))
            new_list8 = List().create(name="trafficSelectorList")
            item8 = Item().create()
            p81 = P().create(name="localIpAddress", value=virtual_ip_addr_ngu)
            p82 = P().create(name="localIpPort", value="-1")
            p83 = P().create(name="localIpPrefixLength", value="32")
            p84 = P().create(name="protocol", value="-1")
            p85 = P().create(name="remoteIpAddress", value="0.0.0.0")
            p86 = P().create(name="remoteIpPort", value="-1")
            p87 = P().create(name="remoteIpPrefixLength", value="0")
            item8.append(p81)
            item8.append(p82)
            item8.append(p83)
            item8.append(p84)
            item8.append(p85)
            item8.append(p86)
            item8.append(p87)
            new_list8.append(item8)
            secpol8_obj.append(new_list8)
            self.scf_handler.raml.cmData.append(secpol8_obj)
#
# if __name__ == '__main__':
#     from cloud5g.commissioning import Context
#     import sys
#     import importlib
#     sys.path.append('/home/ute/Downloads/SCFC24.xml')
#     tl_config = importlib.import_module('2_11_UTESRAN024')
#     custom = CustomCommissioning('/home/ute/Downloads/SCFC24.xml')
#     context = Context(tl_config, '', False)
#     with custom as custom_commissioning:
#         custom_commissioning.modify_scf(context)
