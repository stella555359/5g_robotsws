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
        self.remote_scf_path = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11.xml'

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
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mnl_version = mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].GNSSE[0]['version']
        mrbts.MNL[0].PMCADM[0].reportingIntervalPm.value = "5min"

        try:
            if mrbts.MNL[0].MNLENT[1].targetDNType.value == 'VM':

                mo_clock = mrbts.MNL[0].MNLENT[1].SYNC[0].CLOCK[0]
                self.add_object_with_params(outputConfiguration1Pps='EnabledWithoutBtsInputReference',
                                            outputConfiguration2M048='EnabledWithoutBtsInputReference', mo=mo_clock)

                ntp_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1'
                self.add_object_with_params(distname=ntp_dist_name,
                                            klass="com.nokia.srbts.mnl:NTP", version=mnl_version,
                                            list_name='ntpServerList',
                                            ntpServerIpAddr='10.171.8.4')
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

        du_number = 2
        new_nrdu = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRDU-{}'.format(du_number)
        new_tnl = 'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-{}'.format(du_number+3)
        new_mnlent = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-{}'.format(du_number + 1)
        new_apeqm = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-{}'.format(du_number)
        new_nrcellgrp = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELLGRP-{}'.format(du_number-1)
        new_nrbts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELL-{}'.format(du_number)

        mo_copy = {mrbts.NRBTS[0].NRDU[0]: new_nrdu,
                   mrbts.TNLSVC[0].TNL[3]: new_tnl,
                   mrbts.MNL[0].MNLENT[0]: new_mnlent,
                   mrbts.EQM[0].APEQM[0]: new_apeqm,
                   mrbts.NRBTS[0].NRCELLGRP[0]: new_nrcellgrp,
                   mrbts.NRBTS[0].NRCELL[0]: new_nrbts
                   }

        for copied, new_mo in mo_copy.items():
            copied.clone_tree_to(new_mo)

        mrbts.TNLSVC[0].TNL[du_number + 2].ETHSVC[0].ETHLK[0].modDN.value = \
            'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-{}/CABINET-1/SMOD-1'.format(du_number)
        mrbts.TNLSVC_1.TNL[du_number + 2].ETHSVC[0].ETHIF[0].linkSelectorDN.value = \
            'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-{}/ETHSVC-1/ETHLK-1'.format(du_number + 3)
        mrbts.TNLSVC_1.TNL[du_number + 2].IPNO_1.IPIF_1.interfaceDN.value = \
            'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-{}/ETHSVC-1/ETHIF-1'.format(du_number + 3)
        mrbts.MNL_1.MNLENT[du_number].SYNC_1.CLOCK_1.sModDN.value = \
            'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-{}/CABINET-1/SMOD-1'.format(du_number)
        mrbts.NRBTS_1.NRDU[du_number-1].gNbDuId.value = du_number-1
        mrbts.NRBTS_1.NRDU[du_number-1].targetDN.value = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-{}'.format(du_number)
        mrbts.MNL[0].MNLENT[du_number].targetDN.value = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-{}'.format(du_number)
        mrbts.NRBTS_1.NRDU[du_number-1].f1Cplane[0][0].value = \
            'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-{}/IPNO-1/IPIF-1/IPADDRESSV4-1'.format(du_number + 3)
        mrbts.NRBTS_1.NRDU[du_number-1].f1Mplane[0][0].value = \
            'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-{}/IPNO-1/IPIF-1/IPADDRESSV4-3'.format(du_number + 3)
        mrbts.NRBTS_1.NRDU[du_number-1].f1Uplane[0][0].value = \
            'MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-{}/IPNO-1/IPIF-1/IPADDRESSV4-2'.format(du_number + 3)
        mrbts.TNLSVC[0].TNL[du_number+2].IPNO[0].IPIF[0].IPADDRESSV4_1.localIpAddr.value = \
            '192.168.2.64'
        mrbts.TNLSVC[0].TNL[du_number+2].IPNO[0].IPIF[0].IPADDRESSV4_2.localIpAddr.value = \
            '192.168.2.65'
        mrbts.TNLSVC[0].TNL[du_number+2].IPNO[0].IPIF[0].IPADDRESSV4_3.localIpAddr.value = \
            '192.168.2.63'

        value = 0
        for cell in range(0, 2):
            if cell > 0:
                mrbts.NRBTS[0].NRCELL[cell].physCellId.value += value
                mrbts.NRBTS[0].NRCELL[cell].lcrId.value -= value
            mrbts.NRBTS[0].NRCELL[cell].pMax.value = 210
            value += 1

        mrbts.NRBTS[0].NRDU[du_number-1].refNrCellGroup[0].value = str(du_number-1)
        mrbts.NRBTS[0].NRCELLGRP[du_number-1].nrCellList[0].value = str(du_number)

        nrarfcn_1cell = {mrbts.NRBTS[0].NRCELL[0].nrarfcn: '2059000',
                         mrbts.NRBTS[0].NRCELL[1].nrarfcn: '2060731',
                         }

        for p, p_value in nrarfcn_1cell.items():
            p.value = p_value

        gscn_1cell = {mrbts.NRBTS[0].NRCELL[0].gscn: '22402',
                      mrbts.NRBTS[0].NRCELL[1].gscn: '22408',
                      }

        for p, p_value in gscn_1cell.items():
            p.value = p_value

        for p in mrbts.NRBTS[0]:
            if 'qciTab' in p['name'] or 'fiveQiTab' in p['name']:
                p[0].dlFlowControlAlgo.value = '3gppFlowControl'

        for apeqm in mrbts.EQM[0].APEQM[0:]:
            apeqm.rapProfile.value = "5G19/rap/5g_pid11_2CC_eoc"

        for mnlent in mrbts.MNL[0].MNLENT[0:]:
            mnlent.FEATCADM[0].systemAcctPermEnable.value = "false"
            mnlent.SECADM[0].actServiceAccountSsh.value = "true"
            mnlent.SECADM[0].ethernetPortSecurityEnabled.value = "false"

        mrbts.NRBTS[0].mcc.value = '555'
        mrbts.NRBTS[0].mnc.value = '10'
        mrbts.NRBTS[0].mncLength.value = '2'
        mrbts.NRBTS[0].SERVEDAMF[0].amfIPAddress.value = '10.1.1.21'
