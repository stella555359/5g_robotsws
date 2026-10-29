# -*- coding: utf-8 -*-

__maintainer__ = 'Piotr Dziedzic'
__team__ = 'MN 5G&SC'
__email__ = 'piotr.dziedzic@nokia.com'


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
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts_id = context.mrbts
        mnl_version = mrbts.MNL[0]['version']
        eqm_version = mrbts.EQM[0]['version']

        # 1) / MRBTS - 288 / NRBTS - 1 / NRCELL - 1 / NRCELL_FDD - 1 / nrarfcnDL -> 175000
        p = P().create(name='nrarfcnDl', value='175000')
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].append(p)
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].nrarfcnDl.value = '175000'

        # 2) / MRBTS - 288 / NRBTS - 1 / NRCELL - 1 / NRCELL_FDD - 1 / nrarfcnUL -> 166000
        p = P().create(name='nrarfcnUl', value='166000')
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].append(p)
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].nrarfcnUl.value = '166000'
