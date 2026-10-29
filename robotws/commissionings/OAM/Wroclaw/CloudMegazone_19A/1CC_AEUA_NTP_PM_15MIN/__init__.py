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
        mrbts.MNL[0].PMCADM[0].reportingIntervalPm.value = "15min"

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

        for apeqm in mrbts.EQM[0].APEQM[0:]:
            apeqm.rapProfile.value = "5G19/rap/5g_pid11_eoc"

        for mnlent in mrbts.MNL[0].MNLENT[0:]:
            mnlent.FEATCADM[0].systemAcctPermEnable.value = "false"
            mnlent.SECADM[0].actServiceAccountSsh.value = "true"
            mnlent.SECADM[0].ethernetPortSecurityEnabled.value = "false"

        for cellgrp in mrbts.NRBTS[0].NRCELLGRP[1:]:
            cellgrp.remove()

        for cell in mrbts.NRBTS[0].NRCELL[1:]:
            cell.remove_tree()

        for cell in mrbts.NRBTS_1.NRCELLGRP[0].nrCellList[1:]:
            cell.remove()
