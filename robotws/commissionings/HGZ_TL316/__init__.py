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

        distname = 'MRBTS-' + str(mrbts_id) + '/EQM-1/HWTOP-1/CABLINK-3'
        self.add_object_with_params(distname=distname,
                                    klass="com.nokia.srbts.eqm:CABLINK",
                                    version='EQM20B_2006_002',
                                    list_name=None,
                                    mo=None,
                                    firstEndpointDN='MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-1'.format(mrbts_id),
                                    firstEndpointLabel='QSFP',
                                    firstEndpointPortId='1',
                                    radioProtocolType='TDDCPRI',
                                    linkSpeed='Cpri7',
                                    iqCompression='none',
                                    secondEndpointDN='MRBTS-{}/EQM-1/APEQM-1/RMOD-1'.format(mrbts_id),
                                    secondEndpointLabel='SFP',
                                    secondEndpointPortId='2')
        mrbts.EQM[0].APEQM[0].RMOD[0].PHYANT[1].remove()
        mrbts.EQM[0].APEQM[0].RMOD[0].PHYANT[0].remove()
        self.add_object_with_params(distname='MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
                                    klass="com.nokia.srbts.eqm:PHYANT",
                                    version='EQM20B_2006_002',
                                    list_name=None,
                                    mo=None)
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[7].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[6].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[5].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[4].remove()
