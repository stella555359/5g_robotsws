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
        mrbts_id = mrbts.dist_name.split("-")[-1]
        mnl_ver = mrbts.EQM[0]._tree.attrib["version"]

        if context.tl_config.gnbs[0].dus[0].rus[0].ru_hw_group == "AHCA" and \
                (context.tl_config.tl_cloud_topology == "CLOUD_5G_CLASSICAL_ASIK_ABIL_AHCA_ENB" or
                 context.tl_config.tl_cloud_topology == "CLOUD_5G_CLASSICAL_ASIB_ABIL_AHCA_ENB"):

            # Add CABLINK MO
            cablinks_num = len(mrbts.EQM[0].HWTOP[0].CABLINK)
            eqm_ver = mrbts.EQM[0]._tree.attrib["version"]
            cablink = ManagedObject().create(
                klass="com.nokia.srbts.eqm:CABLINK",
                dist_name="MRBTS-{}/EQM-1/HWTOP-1/CABLINK-{}".format(mrbts_id, cablinks_num + 1),
                version=eqm_ver,
                operation="create"
            )
            cablink.append(P().create(name="firstEndpointDN", value="MRBTS-{}/EQM-1/SMOD_EXT-1".format(mrbts_id)))
            cablink.append(P().create(name="firstEndpointLabel", value="OPT"))
            cablink.append(P().create(name="iqCompression", value="none"))
            cablink.append(P().create(name="linkModeConfiguration", value="false"))
            cablink.append(P().create(name="linkModeDC", value="false"))
            cablink.append(P().create(name="linkModeData", value="false"))
            cablink.append(P().create(name="linkModeSynchronization", value="false"))
            cablink.append(P().create(name="linkSpeed", value="Cpri7"))
            cablink.append(P().create(name="radioProtocolType", value="FDDCPRI"))
            cablink.append(
                P().create(name="secondEndpointDN", value="MRBTS-{}/EQM-1/APEQM-1/RMOD-1".format(mrbts_id, )))
            cablink.append(P().create(name="secondEndpointPortId", value="0"))
            self.scf_handler.raml.cmData.append(cablink)

            # Add SMOD_EXT MO
            smod_ext = ManagedObject().create(
                klass="com.nokia.srbts.eqm:SMOD_EXT",
                dist_name="MRBTS-{}/EQM-1/SMOD_EXT-1".format(mrbts_id),
                version=eqm_ver,
                operation="create"
            )
            smod_ext.append(P().create(name="eutraSupport", value="true"))
            smod_ext.append(P().create(name="eutraTDDSupport", value="false"))
            smod_ext.append(P().create(name="geranSupport", value="false"))
            smod_ext.append(P().create(name="nrSupport", value="false"))
            smod_ext.append(P().create(name="sranSupport", value="false"))
            smod_ext.append(P().create(name="syncMaster", value="false"))
            smod_ext.append(P().create(name="utranSupport", value="false"))
            self.scf_handler.raml.cmData.append(smod_ext)

            # Enable RF sharing
            featcadm = mrbts.MNL[0].MNLENT[0].FEATCADM[0]
            featcadm.rfSharingEnabled.value = "true"

            # Remove beamSet list
            try:
                mrbts.NRBTS[0].NRCELL[0].beamSet.remove()
            except ElementNotFound:
                pass

        # Remove TOPP configuration
        try:
            mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].TOP[0].TOPP[0].remove()
        except ElementNotFound:
            pass

        # Set SYNC object
        try:
            mrbts.MNL[0].MNLENT[0].SYNC[0].actEcpriMasterClock.value = "false"
            mrbts.MNL[0].MNLENT[0].SYNC[0].btsSyncMode.value = "FreqSync"
            try:
                mrbts.MNL[0].MNLENT[0].SYNC[0].manualFrameTimingAdjustment.remove()
            except ElementNotFound:
                pass
        except ElementNotFound:
            sync_obj = ManagedObject().create(
                klass="com.nokia.srbts.mnl:SYNC",
                dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1".format(mrbts_id),
                version=mnl_ver,
                operation="create"
            )
            sync_obj.append(P().create(name="actEcpriMasterClock", value="false"))
            sync_obj.append(P().create(name="btsSyncMode", value="FreqSync"))
            sync_obj.append(P().create(name="profileType", value="RAU"))
            self.scf_handler.raml.cmData.append(sync_obj)

        # Set CLOCK object
        try:
            if len(mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList) > 0:
                is_topf_sync = False
                sync_input_list = mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList
                for sync_input in sync_input_list:
                    if sync_input.syncInputType.value == "TOPF":
                        sync_input.syncInputPrio.value = "1"
                        is_topf_sync = True
                if is_topf_sync is False:
                    item = Item().create()
                    p1 = P().create(name="syncInputPrio", value="1")
                    p2 = P().create(name="syncInputType", value="TOPF")
                    item.append(p1)
                    item.append(p2)
                    mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList.append(item)
                for sync_input in sync_input_list:
                    if sync_input.syncInputType.value == "TOPP":
                        sync_input.remove()
                    elif sync_input.syncInputType.value == "1pps/ToD from external GNSS receiver":
                        sync_input.syncInputPrio.value = "2"
            else:
                item = Item().create()
                p1 = P().create(name="syncInputPrio", value="1")
                p2 = P().create(name="syncInputType", value="TOPF")
                item.append(p1)
                item.append(p2)
                mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList.append(item)
        except ElementNotFound:
            clock_obj = ManagedObject().create(
                klass="com.nokia.srbts.mnl:CLOCK",
                dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1".format(mrbts_id),
                version=mnl_ver,
                operation="create"
            )
            clock_obj.append(P().create(name="holdOverModeUsed", value="false"))
            clock_obj.append(P().create(name="outputConfiguration1PpsFHS", value="Disabled"))
            clock_obj.append(P().create(name="outputConfiguration2M048", value="Disabled"))
            clock_obj.append(P().create(name="outputConfigurationFCLK", value="Disabled"))
            clock_obj.append(P().create(name="syncMaster", value="true"))
            clock_obj.append(P().create(name="sModDN",
                                        value="MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1".format(mrbts_id)))
            new_list = List().create(name="syncInputList")
            item = Item().create()
            p1 = P().create(name="syncInputPrio", value="1")
            p2 = P().create(name="syncInputType", value="TOPF")
            item2 = Item().create()
            p3 = P().create(name="syncInputPrio", value="2")
            p4 = P().create(name="syncInputType", value="1pps/ToD from external GNSS receiver")
            item.append(p1)
            item.append(p2)
            item2.append(p3)
            item2.append(p4)
            new_list.append(item)
            new_list.append(item2)
            clock_obj.append(new_list)
            self.scf_handler.raml.cmData.append(clock_obj)

        # Set TOP object
        try:
            mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].TOP[0].sPlaneDscp.value = "46"
            mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].TOP[0].topDomainNumber.value = "0"
            mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].TOP[0].sPlaneIpAddressDN.value = \
                mrbts.MNL[0].MNLENT[0].MPLANENW[0].mPlaneIpv4AddressDN.value
        except ElementNotFound:
            top_obj = ManagedObject().create(
                klass="com.nokia.srbts.mnl:TOP",
                dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1".format(mrbts_id),
                version=mnl_ver,
                operation="create"
            )
            top_obj.append(P().create(name="sPlaneDscp", value="46"))
            top_obj.append(P().create(name="sPlaneIpAddressDN",
                                      value=mrbts.MNL[0].MNLENT[0].MPLANENW[0].mPlaneIpv4AddressDN.value))
            top_obj.append(P().create(name="topDomainNumber", value="0"))
            self.scf_handler.raml.cmData.append(top_obj)

        # Set TOPF object
        try:
            mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].TOP[0].TOPF[0].remove()
        except ElementNotFound:
            pass
        topf_obj = ManagedObject().create(
            klass="com.nokia.srbts.mnl:TOPF",
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPF-1".format(mrbts_id),
            version=mnl_ver,
            operation="create"
        )
        topf_obj.append(P().create(name="ieeeTelecomProfile", value="IEEE1588"))
        topf_obj.append(P().create(name="syncMessageRate", value="RATE_16"))
        topf_new_list = List().create(name="acceptedClockClass")
        topf_new_list.append(P().create(value="6"))
        topf_new_list.append(P().create(value="7"))
        topf_item = Item().create()
        topf_item.append(P().create(name="masterIpAddr", value="10.42.0.107"))
        topf_new_list2 = List().create(name="topMasterList")
        topf_new_list2.append(topf_item)
        topf_obj.append(topf_new_list)
        topf_obj.append(topf_new_list2)
        self.scf_handler.raml.cmData.append(topf_obj)
