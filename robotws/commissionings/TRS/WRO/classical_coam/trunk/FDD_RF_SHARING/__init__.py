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
        if context.tl_config.gnbs[0].dus[0].rus[0].ru_hw_group == "AHCA" and \
                (context.tl_config.tl_cloud_topology == "CLOUD_5G_CLASSICAL_ASIK_ABIL_AHCA_ENB" or
                 context.tl_config.tl_cloud_topology == "CLOUD_5G_CLASSICAL_ASIB_ABIL_AHCA_ENB"):
            scf = self.scf_handler
            mrbts = scf.raml.cmData.MRBTS[0]
            mrbts_id = mrbts.dist_name.split("-")[-1]

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
            try:
                featcadm = mrbts.MNL[0].MNLENT[0].FEATCADM[0]
                featcadm.rfSharingEnabled.value = "true"
            except ElementNotFound:
                pass

            # Remove beamSet list
            try:
                mrbts.NRBTS[0].NRCELL[0].beamSet.remove()
            except ElementNotFound:
                pass

            # Add Radio master DN
            try:
                rmod = mrbts.EQM[0].APEQM[0].RMOD[0]
                bbmod = mrbts.EQM[0].APEQM[0].CABINET[0].BBMOD[0]
                try:
                    rmod.radioMasterDN.value = bbmod.dist_name
                except ElementNotFound:
                    rmod.append(P().create(name="radioMasterDN", value=bbmod.dist_name))
            except ElementNotFound:
                pass

            # Set actFDMScheduling parameter (only in 20B branch)
            if "20B" in mrbts._tree.attrib["version"]:
                try:
                    nrbts = mrbts.NRBTS[0]
                    try:
                        nrbts.actFdmScheduling.value = "true"
                    except ElementNotFound:
                        pass
                except ElementNotFound:
                    pass
            # Set actNgcFlexSaMode parameter
            try:
                nrbts = mrbts.NRBTS[0]
                try:
                    nrbts.actNgcFlexSaMode.value = "true"
                except ElementNotFound:
                    pass
            except ElementNotFound:
                pass

            # PDDCH configuration
            try:
                bwp_profile = mrbts.NRBTS[0].BWP_PROFILE[0]
                try:
                    bwp_profile.locationAndBandwidthUl[0].cRbSizeUl.value = "sameAsDl"
                    bwp_profile.locationAndBandwidthUl[0].cRbStartUl.value = "sameAsDl"
                except ElementNotFound:
                    pass
            except ElementNotFound:
                pass

            try:
                # Configure first BWP_PROFILE
                bwp_profile = mrbts.NRBTS[0].BWP_PROFILE[0]
                pddch_config_common = mrbts.NRBTS[0].BWP_PROFILE[0].PDCCH[0].PDCCH_CONFIG_COMMON[0]
                try:
                    pddch_list = List().create(name="searchSpaceCommon")
                    item1 = Item().create()
                    p1 = P().create(name="coresetId", value="0")
                    p2 = P().create(name="dciFormat", value="formats0-0-And-1-0")
                    p3 = P().create(name="duration", value="1")
                    p4 = P().create(name="monitoringSymbolWithinSlot", value="symbol_0")
                    p5 = P().create(name="numOfPdcchCandidatesInAL16", value="n1")
                    p6 = P().create(name="numOfPdcchCandidatesInAL2", value="n0")
                    p7 = P().create(name="numOfPdcchCandidatesInAL4", value="n4")
                    p8 = P().create(name="numOfPdcchCandidatesInAL8", value="n2")
                    p9 = P().create(name="periodicity", value="sl1")
                    p10 = P().create(name="searchSpaceId", value="1")
                    p11 = P().create(name="searchSpaceType", value="Type0A")
                    p12 = P().create(name="slotOffset", value="0")
                    item1.append(p1)
                    item1.append(p2)
                    item1.append(p3)
                    item1.append(p4)
                    item1.append(p5)
                    item1.append(p6)
                    item1.append(p7)
                    item1.append(p8)
                    item1.append(p9)
                    item1.append(p10)
                    item1.append(p11)
                    item1.append(p12)
                    pddch_list.append(item1)
                    item2 = Item().create()
                    p1 = P().create(name="coresetId", value="0")
                    p2 = P().create(name="dciFormat", value="formats0-0-And-1-0")
                    p3 = P().create(name="duration", value="1")
                    p4 = P().create(name="monitoringSymbolWithinSlot", value="symbol_0_1")
                    p5 = P().create(name="numOfPdcchCandidatesInAL16", value="n0")
                    p6 = P().create(name="numOfPdcchCandidatesInAL2", value="n0")
                    p7 = P().create(name="numOfPdcchCandidatesInAL4", value="n4")
                    p8 = P().create(name="numOfPdcchCandidatesInAL8", value="n0")
                    p9 = P().create(name="periodicity", value="sl1")
                    p10 = P().create(name="searchSpaceId", value="2")
                    p11 = P().create(name="searchSpaceType", value="Type1")
                    p12 = P().create(name="slotOffset", value="0")
                    item2.append(p1)
                    item2.append(p2)
                    item2.append(p3)
                    item2.append(p4)
                    item2.append(p5)
                    item2.append(p6)
                    item2.append(p7)
                    item2.append(p8)
                    item2.append(p9)
                    item2.append(p10)
                    item2.append(p11)
                    item2.append(p12)
                    pddch_list.append(item2)
                    item3 = Item().create()
                    p1 = P().create(name="coresetId", value="0")
                    p2 = P().create(name="dciFormat", value="formats0-0-And-1-0")
                    p3 = P().create(name="duration", value="1")
                    p4 = P().create(name="monitoringSymbolWithinSlot", value="symbol_0")
                    p5 = P().create(name="numOfPdcchCandidatesInAL16", value="n1")
                    p6 = P().create(name="numOfPdcchCandidatesInAL2", value="n0")
                    p7 = P().create(name="numOfPdcchCandidatesInAL4", value="n4")
                    p8 = P().create(name="numOfPdcchCandidatesInAL8", value="n2")
                    p9 = P().create(name="periodicity", value="sl1")
                    p10 = P().create(name="searchSpaceId", value="3")
                    p11 = P().create(name="searchSpaceType", value="Type2")
                    p12 = P().create(name="slotOffset", value="0")
                    item3.append(p1)
                    item3.append(p2)
                    item3.append(p3)
                    item3.append(p4)
                    item3.append(p5)
                    item3.append(p6)
                    item3.append(p7)
                    item3.append(p8)
                    item3.append(p9)
                    item3.append(p10)
                    item3.append(p11)
                    item3.append(p12)
                    pddch_list.append(item3)
                    pddch_config_common.append(pddch_list)
                    self.scf_handler.raml.cmData.append(pddch_config_common)
                except ElementNotFound:
                    pass
            except ElementNotFound:
                pass
            try:
                # Configure second BWP_PROFILE
                pddch_config_common_2 = mrbts.NRBTS[0].BWP_PROFILE[1].PDCCH[0].PDCCH_CONFIG_COMMON[0]
                pddch_config_common_2.searchSpaceCommon.remove()
                pddch_list = List().create(name="searchSpaceCommon")
                item1 = Item().create()
                p1 = P().create(name="coresetId", value="0")
                p2 = P().create(name="dciFormat", value="formats0-0-And-1-0")
                p3 = P().create(name="duration", value="1")
                p4 = P().create(name="monitoringSymbolWithinSlot", value="symbol_0")
                p5 = P().create(name="numOfPdcchCandidatesInAL16", value="n1")
                p6 = P().create(name="numOfPdcchCandidatesInAL2", value="n0")
                p7 = P().create(name="numOfPdcchCandidatesInAL4", value="n4")
                p8 = P().create(name="numOfPdcchCandidatesInAL8", value="n2")
                p9 = P().create(name="periodicity", value="sl1")
                p10 = P().create(name="searchSpaceId", value="4")
                p11 = P().create(name="searchSpaceType", value="Type0A")
                p12 = P().create(name="slotOffset", value="0")
                item1.append(p1)
                item1.append(p2)
                item1.append(p3)
                item1.append(p4)
                item1.append(p5)
                item1.append(p6)
                item1.append(p7)
                item1.append(p8)
                item1.append(p9)
                item1.append(p10)
                item1.append(p11)
                item1.append(p12)
                pddch_list.append(item1)

                item2 = Item().create()
                p1 = P().create(name="coresetId", value="0")
                p2 = P().create(name="dciFormat", value="formats0-0-And-1-0")
                p3 = P().create(name="duration", value="1")
                p4 = P().create(name="monitoringSymbolWithinSlot", value="symbol_0_1")
                p5 = P().create(name="numOfPdcchCandidatesInAL16", value="n0")
                p6 = P().create(name="numOfPdcchCandidatesInAL2", value="n0")
                p7 = P().create(name="numOfPdcchCandidatesInAL4", value="n4")
                p8 = P().create(name="numOfPdcchCandidatesInAL8", value="n0")
                p9 = P().create(name="periodicity", value="sl1")
                p10 = P().create(name="searchSpaceId", value="5")
                p11 = P().create(name="searchSpaceType", value="Type1")
                p12 = P().create(name="slotOffset", value="0")
                item2.append(p1)
                item2.append(p2)
                item2.append(p3)
                item2.append(p4)
                item2.append(p5)
                item2.append(p6)
                item2.append(p7)
                item2.append(p8)
                item2.append(p9)
                item2.append(p10)
                item2.append(p11)
                item2.append(p12)
                pddch_list.append(item2)

                item3 = Item().create()
                p1 = P().create(name="coresetId", value="0")
                p2 = P().create(name="dciFormat", value="formats0-0-And-1-0")
                p3 = P().create(name="duration", value="1")
                p4 = P().create(name="monitoringSymbolWithinSlot", value="symbol_0")
                p5 = P().create(name="numOfPdcchCandidatesInAL16", value="n1")
                p6 = P().create(name="numOfPdcchCandidatesInAL2", value="n0")
                p7 = P().create(name="numOfPdcchCandidatesInAL4", value="n4")
                p8 = P().create(name="numOfPdcchCandidatesInAL8", value="n2")
                p9 = P().create(name="periodicity", value="sl1")
                p10 = P().create(name="searchSpaceId", value="6")
                p11 = P().create(name="searchSpaceType", value="Type2")
                p12 = P().create(name="slotOffset", value="0")
                item3.append(p1)
                item3.append(p2)
                item3.append(p3)
                item3.append(p4)
                item3.append(p5)
                item3.append(p6)
                item3.append(p7)
                item3.append(p8)
                item3.append(p9)
                item3.append(p10)
                item3.append(p11)
                item3.append(p12)
                pddch_list.append(item3)
                pddch_config_common_2.append(pddch_list)
            except ElementNotFound:
                pass

            try:
                pdcch_config_dedicated = mrbts.NRBTS[0].BWP_PROFILE[1].PDCCH[0].PDCCH_CONFIG_DEDICATED[0]
                pdcch_config_dedicated.searchSpaceDedicated[0].searchSpaceId.value = "7"
                pdcch_config_dedicated.searchSpaceDedicated[1].searchSpaceId.value = "8"
            except ElementNotFound:
                pass
