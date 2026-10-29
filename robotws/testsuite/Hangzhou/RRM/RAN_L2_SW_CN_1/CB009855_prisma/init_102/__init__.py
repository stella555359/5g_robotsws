from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Prisma
from taf.config.testline.enb import PrismaEnb
from taf.config.testline.core import PrismaCore
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails

_airmosaic_ssh = SshServiceDetails(
    addr='10.64.55.102', username='mn5gran', password='nokia123@')
_airmosaic_harness = HttpConnectionDetails(addr='10.64.55.102', port=8090)
_lsu_uu_ssh = SshServiceDetails(
    addr='10.64.56.249', username='user', password='user')
_tstm_uu_ssh = SshServiceDetails(
    addr='10.64.56.249', username='user', password='user')

_prisma_ue = Prisma(airmosaic_ssh_connection_details=_airmosaic_ssh,
                    airmosaic_harness_connection_details=_airmosaic_harness,
                    lsu_uu_ssh_connection_details=_lsu_uu_ssh,
                    tstm_uu_ssh_connection_details=_tstm_uu_ssh
                    )

_tstm_x2_ssh = SshServiceDetails(
    addr='10.5.115.89', username='user', password='user')
_prisma_enb = PrismaEnb(tstm_x2_ssh_connection_details=_tstm_x2_ssh)

_lsu_s1_ssh = SshServiceDetails(
    addr='10.64.56.249', username='user', password='user')
_tstm_s1_ssh = SshServiceDetails(
    addr='10.64.56.249', username='user', password='user')

_prisma_core = PrismaCore(lsu_s1_ssh_connection_details=_lsu_s1_ssh,
                          tstm_s1_ssh_connection_details=_tstm_s1_ssh)


tl = TestLine(test_pc=None, gnbs=None, tl_cloud_topology=None,
              core=_prisma_core, enbs=[_prisma_enb], ues=[_prisma_ue])
