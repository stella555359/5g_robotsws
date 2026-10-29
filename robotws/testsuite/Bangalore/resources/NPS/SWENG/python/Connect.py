import enum
import StringTool
import Archi
import Topology
from ReadConfig import TLConfig
import Oam
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)


# ======================================================================================
# DEFINITION OF HOSTS
# ======================================================================================
tl = TLConfig.getTL()

HOST_GNB_SYS0_M = Archi.Host(alias="GNB_SYS0_M",
                             sshConnection=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection,
                             boardType="ASIK",
                             ip=None,
                             sshId="fct-0a",
                             nodeId="0x1011",
                             slot=0,
                             proc=0)

HOST_GNB_SYS0_S = Archi.Host(alias="GNB_SYS0_S",
                             sshConnection=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection,
                             boardType="ASIK",
                             ip="192.168.253.17",
                             sshId="fct-0b",
                             slot=0,
                             proc=1,
                             proxy=HOST_GNB_SYS0_M)

HOST_GNB_BB0_M = Archi.Host(alias="GNB_BB0_M",
                            sshConnection=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection,
                            boardType="ABIL",
                            ip="192.168.253.20",
                            sshId="fsp-1a",
                            slot=1,
                            proc=0,
                            proxy=HOST_GNB_SYS0_M)

HOST_GNB_BB0_S = Archi.Host(alias="GNB_BB0_S",
                            sshConnection=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection,
                            boardType="ABIL",
                            ip="192.168.253.21",
                            sshId="fsp-1b",
                            slot=1,
                            proc=1,
                            proxy=HOST_GNB_SYS0_M)

HOST_GNB_BB0_L1 = Archi.Host(alias="GNB_BB0_L1",
                             sshConnection=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection,
                             boardType="ABIL",
                             ip="192.168.253.22",
                             sshId="fsp-1c",
                             slot=1,
                             proc=2,
                             proxy=HOST_GNB_SYS0_M)

HOST_AP_SYS0_M = Archi.Host(alias="AP_SYS0_M",
                            sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                            boardType="ASIK",
                            ip=None,
                            sshId="fct-0a",
                            nodeId="0x5011",
                            slot=0,
                            proc=0)

HOST_AP_SYS0_S = Archi.Host(alias="AP_SYS0_S",
                            sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                            boardType="ASIK",
                            ip="192.168.253.81",
                            sshId="fct-0b",
                            slot=0,
                            proc=1,
                            proxy=HOST_AP_SYS0_M)

HOST_AP_BB0_M = Archi.Host(alias="AP_BB0_M",
                           sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                           boardType="ABIL",
                           ip="192.168.253.84",
                           sshId="fsp-5-1a",
                           slot=1,
                           proc=0,
                           proxy=HOST_AP_SYS0_M)

HOST_AP_BB0_S = Archi.Host(alias="AP_BB0_S",
                           sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                           boardType="ABIL",
                           ip="192.168.253.85",
                           sshId="fsp-5-1b",
                           slot=1,
                           proc=1,
                           proxy=HOST_AP_SYS0_M)

HOST_AP_BB0_L1 = Archi.Host(alias="AP_BB0_L1",
                            sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                            boardType="ABIL",
                            ip="192.168.253.86",
                            sshId="fsp-5-1c",
                            slot=1,
                            proc=2,
                            proxy=HOST_AP_SYS0_M)


# ======================================================================================
# DEFINITION OF OAM and HOSTS depending from OAM cloud
# ======================================================================================
httpConnection = HttpConnectionDetails(
    addr=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr,
    username=tl.gnbs[0].cu.oam_http_connection_details.username,
    password=tl.gnbs[0].cu.oam_http_connection_details.password,
    port=tl.gnbs[0].cu.oam_http_connection_details.port)

HOST_GNB_OAM_DU = Oam.getOam(hw=Archi.HW.GNB, unit=Archi.Unit.DU,
                             sshConnection=tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection,
                             httpConnection=httpConnection)

HOST_GNB_OAM_CU = Oam.getOam(hw=Archi.HW.GNB, unit=Archi.Unit.CU,
                             sshConnection=tl.gnbs[0].cu.oam_ssh_connection_details,
                             httpConnection=tl.gnbs[0].cu.oam_http_connection_details)

HOST_AP_OAM_DU = Oam.getOam(hw=Archi.HW.AP, unit=Archi.Unit.DU,
                            sshConnection=TLConfig.ues[0].oam_ssh_connection_details,
                            httpConnection=TLConfig.ues[0].oam_http_connection_details)

HOST_GNB_CPIF = Archi.Host(alias="GNB_CPIF", proxy=HOST_GNB_OAM_CU,
                           sshConnection=tl.gnbs[0].cu.oam_ssh_connection_details,
                           sshId="cpif-0.local")
HOST_GNB_CPCL = Archi.Host(alias="GNB_CPCL", proxy=HOST_GNB_OAM_CU,
                           sshConnection=tl.gnbs[0].cu.oam_ssh_connection_details,
                           sshId="cpcl-0.local")
HOST_GNB_CPNB = Archi.Host(alias="GNB_CPNB", proxy=HOST_GNB_OAM_CU,
                           sshConnection=tl.gnbs[0].cu.oam_ssh_connection_details,
                           sshId="cpnb-0.local")
HOST_GNB_CPUE = Archi.Host(alias="GNB_CPUE", proxy=HOST_GNB_OAM_CU,
                           sshConnection=tl.gnbs[0].cu.oam_ssh_connection_details,
                           sshId="cpue-0.local")
HOST_GNB_UPUE = Archi.Host(alias="GNB_UPUE", proxy=HOST_GNB_OAM_CU,
                           sshConnection=tl.gnbs[0].cu.oam_ssh_connection_details,
                           sshId="upue-0.local")

# ======================================================================================
# MISC OTHER DEFINITIONS
# ======================================================================================
HOST_EPCSIM = Archi.Host(alias="EPCSIM", sshConnection=None)

HOST_SUDO_REQUIRED = [HOST_GNB_CPIF.alias, HOST_GNB_CPCL.alias, HOST_GNB_CPNB.alias,
                      HOST_GNB_CPUE.alias, HOST_GNB_UPUE.alias, HOST_EPCSIM.alias,
                      HOST_GNB_OAM_DU.alias]

if HOST_GNB_OAM_CU is not None:
    HOST_SUDO_REQUIRED.append(HOST_GNB_OAM_CU.alias)


# ======================================================================================
# DEFINITION OF ENTITIES
# ======================================================================================
def getEntity(archi, hw, unit):
    # AP case
    if hw == Archi.HW.AP:
        if unit == Archi.Unit.DU:
            return Archi.Airscale(hw=hw, unit=unit, oam=HOST_AP_OAM_DU,
                                  sysCardList=[Archi.Card(master=HOST_AP_SYS0_M, slave=HOST_AP_SYS0_S)],
                                  bbCardList=[Archi.Card(master=HOST_AP_BB0_M, slave=HOST_AP_BB0_S,
                                                         loner=HOST_AP_BB0_L1)])
        return None
    # GNB case
    if archi == Topology.Archi.CLASSICAL:
        if unit == Archi.Unit.DU:
            return Archi.Airscale(hw=hw, unit=unit, oam=HOST_GNB_OAM_DU,
                                  sysCardList=[Archi.Card(master=HOST_GNB_SYS0_M, slave=HOST_GNB_SYS0_S)],
                                  bbCardList=[Archi.Card(master=HOST_GNB_BB0_M, slave=HOST_GNB_BB0_S,
                                                         loner=HOST_GNB_BB0_L1)])
        return None
    if archi == Topology.Archi.CLOUD_BTS:
        if unit == Archi.Unit.DU:
            return Archi.Airscale(hw=hw, unit=unit, oam=HOST_GNB_OAM_DU,
                                  sysCardList=[Archi.Card(master=HOST_GNB_SYS0_M, slave=HOST_GNB_SYS0_S)],
                                  bbCardList=[Archi.Card(master=HOST_GNB_BB0_M, slave=HOST_GNB_BB0_S,
                                                         loner=HOST_GNB_BB0_L1)])
        if unit == Archi.Unit.CU:
            return Archi.AirframeOpenStack(hw=hw, unit=unit, oam=HOST_GNB_OAM_CU)
    if archi == Topology.Archi.AIC_BTS:
        if unit == Archi.Unit.DU:
            return Archi.AirframeKubernetes(hw=hw, unit=unit, oam=HOST_GNB_OAM_DU)
        if unit == Archi.Unit.CU:
            return Archi.AirframeOpenStack(hw=hw, unit=unit, oam=HOST_GNB_OAM_CU)
    return None


GNB_CU = getEntity(TLConfig.archi, Archi.HW.GNB, Archi.Unit.CU)
GNB_DU = getEntity(TLConfig.archi, Archi.HW.GNB, Archi.Unit.DU)
AP_CU = getEntity(TLConfig.archi, Archi.HW.AP, Archi.Unit.CU)
AP_DU = getEntity(TLConfig.archi, Archi.HW.AP, Archi.Unit.DU)

# For backward compatibility
HOST_GNB_OAM = HOST_GNB_OAM_DU
HOST_AP_OAM = HOST_AP_OAM_DU
AIRSCALE_GNB = GNB_DU
AIRSCALE_AP = AP_DU
