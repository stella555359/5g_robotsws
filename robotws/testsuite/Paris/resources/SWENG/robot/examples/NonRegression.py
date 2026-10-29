# from testsuite.Paris.resources.SWENG.python.PacketSpec import PacketSpec, GenPacketSpec
class PacketSpec():
    def __init__(self, packetName, path, value=None, kind="show"):
        self.packetName = packetName
        self.path = path
        self.value = value
        self.kind = kind

    @staticmethod
    def getInstaller():
        # 02-Aug-2022: As LUA_SHARK is definitly removed, MC_SHARK becomes the default tool
        # sharkTool = BuiltIn().get_variable_value("${SharkTool}")
        # testSharkTool = BuiltIn().get_variable_value("${TestSharkTool}")
        # if testSharkTool is None:
        #     return sharkTool
        # return testSharkTool
        return "MC_SHARK"


class GenPacketSpec2():
    def __init__(self, lua, mc):
        self.lua = lua
        self.mc = mc
        if PacketSpec.getInstaller() == "MC_SHARK":
            self.packetName = mc.packetName
            self.path = mc.path
            self.value = mc.value
            self.kind = mc.kind
        else:
            self.packetName = lua.packetName
            self.path = lua.path
            self.value = lua.value
            self.kind = lua.kind


PS_MC_loadMesInd = PacketSpec(packetName="itf_l2_hi_du_meas_loadmeasurementrepind",
                              path=".*itf_l2_hi_du_meas_LoadMeasurementRepInd_t.l2NrtPoolId$",
                              value="3")

PS_LUA_loadMesInd = PacketSpec(packetName="itf_l2_hi_du_meas_loadmeasurementrepind",
                               path=".*itf_l2_hi_du_meas_LoadMeasurementRepInd.LoadMeasurementRepInd.l2NrtPoolId$",
                               value="0x00000003")

PS_loadMesInd = GenPacketSpec2(mc=PS_MC_loadMesInd, lua=PS_LUA_loadMesInd)

# ===== UlData_PrachReceiveReq : MsgCountCtrl
# 2022.05.24 - JIRA_38391: 0x000000ff is replaced by 0xff
# PS_LUA_PrachReceiveReq_MsgCountCtrl = PacketSpec(packetName="uldata_prachreceivereq",
#                                                  path=".*/UlData_PrachReceiveReq.subcells_item_0.msgCountCtrl$",
#                                                  value="0x000000ff")
PS_LUA_PrachReceiveReq_MsgCountCtrl = PacketSpec(packetName="uldata_prachreceivereq",
                                                 path=".*/UlData_PrachReceiveReq.subcells_item_0.msgCountCtrl$",
                                                 value="0xff")

# update to use new fied as in .pcap captured content changed for UlData_prachReceiveReqSubcell_t.msgCountCtrl
# PS_MC_PrachReceiveReq_MsgCountCtrl = PacketSpec(packetName="uldata_prachreceivereq",
#                                                 path=".*UlData_prachReceiveReqSubcell_t.msgCountCtrl$",
#                                                 value="255")
PS_MC_PrachReceiveReq_MsgCountCtrl = PacketSpec(packetName="uldata_prachreceivereq",
                                                path=".*UlData_prachReceiveReqSubcell_t.processInRealTime$",
                                                value="1")

PS_PrachReceiveReq_MsgCountCtrl = GenPacketSpec2(lua=PS_LUA_PrachReceiveReq_MsgCountCtrl,
                                                 mc=PS_MC_PrachReceiveReq_MsgCountCtrl)
