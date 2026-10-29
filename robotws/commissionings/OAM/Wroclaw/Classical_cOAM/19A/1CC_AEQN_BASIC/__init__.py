__maintainer__ = 'Pawel Rokicki'
__team__ = '5G_IV7_WRO_6'
__email__ = 'I_MN_5GSC_PZ_5G_IV7_WRO_6@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def add_object_with_params(self, distname=None, klass=None, version=None, list_name=None, mo=None, **kwargs):

        if distname is not None:
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

        mrbts.EQM[0].HWTOP[0].CABLINK[0].firstEndpointLabel.value = "BACKPLANE"
        mrbts.EQM[0].HWTOP[0].CABLINK[0].secondEndpointLabel.value = "BACKPLANE"
        mrbts.EQM[0].HWTOP[0].CABLINK[2].remove
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].staticRoutes[0].gateway.value = "10.44.76.1"
        mrbts.TNLSVC[0].TNL[0].PMTNL[0].firstLevelSchedulerStatisticsInterval.value = 'disabled'
        mrbts.TNLSVC[0].TNL[0].PMTNL[0].secondLevelSchedulerStatisticsInterval.value = 'disabled'
        sync_mo = mrbts.MNL[0].MNLENT[0].SYNC[0]
        self.add_object_with_params(mo=sync_mo,
                                    profileType='RAU',
                                    actEcpriMasterClock='true')

        trblcadm_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
        trblcadm_mnl_version = mrbts.MNL[0]['version']
        self.add_object_with_params(distname=trblcadm_dist_name,
                                    klass="com.nokia.srbts.mnl:TRBLCADM", version=trblcadm_mnl_version,
                                    actCoreDumpFileCollection='true',
                                    actInternalTrace='true',
                                    actRemoteSyslogTransmission='false',
                                    snapshotUploadDelayForFault6450='0')

        pmmnl_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/PMMNL-1'
        self.add_object_with_params(distname=pmmnl_dist_name,
                                    klass="com.nokia.srbts.mnl:PMMNL", version=trblcadm_mnl_version,
                                    eCpriMasterStatisticsInterval='5min',
                                    mtBtsEnergyMonitoring='15min',
                                    mtSfp='15min',
                                    pmMnlId='1')
