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

        for channel in mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[0:]:
            channel.resourceDN.remove()

        for channel in mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[:2]:
            p = P().create(name='antlDN', value='MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-1')
            channel.append(p)

        for channel in mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[2:]:
            p = P().create(name='antlDN', value='MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-2')
            channel.append(p)

        channel = mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0]
        channel.CHANNEL[0].direction.value = 'TX'
        channel.CHANNEL[1].direction.value = 'RX'
        channel.CHANNEL[2].direction.value = 'TX'
        channel.CHANNEL[3].direction.value = 'RX'

        mrbts.EQM[0].APEQM[0].RMOD[0].PHYANT[0].remove()

        mrbts.NRBTS[0].actIncXn.value = 'false'
        mrbts.NRBTS[0].actNgcFlexSaMode.value = 'true'
        mrbts.NRBTS[0].SERVEDAMF[0].amfIPAddress.value = '10.94.232.6'
        mrbts.NRBTS[0].SNSSAI[0].sd.value = '13714341'

        mrbts.NRBTS[0].NRSYSINFO_PROFILE[0].nCellChangeMedium.value = '15'
        mrbts.NRBTS[0].NRSYSINFO_PROFILE[0].NRLIM[0].threshXHigh.value = '2'
        for i in range(8):
            mrbts.NRBTS[0].NRSYSINFO_PROFILE[0].sibSchedulingList[i].sibBroadcastStatus.value = 'broadcasting'

        nrcell_fdd = mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0]
        nrcell_fdd.chBwDl.value = '20MHz'
        nrcell_fdd.chBwUl.value = '20MHz'
        nrcell_fdd.nrarfcnDl.value = '126900'
        nrcell_fdd.nrarfcnUl.value = '136100'

        mrbts.NRBTS[0].ngCplane.remove()

        list_to_add = ['ngCplane', 'ngUplane', 'xnCplane', 'xnUplane']
        for list_name in list_to_add:
            new_list = List().create(list_name)
            item = Item().create()
            p = P().create(name='ipV4AddressDN1',
                           value='MRBTS-' + str(mrbts_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')
            item.append(p)
            new_list.append(item)
            mrbts.NRBTS[0].append(new_list)
