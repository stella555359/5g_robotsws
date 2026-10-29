__maintainer__ = 'Ashok Santhanam'
__team__ = 'MN_5G_Eng_BLR_1_SG'
__email__ = 'ashok.santhanam@nokia.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf import SCF as taf_scf
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P
from taf.internal.scf.managed_object import ManagedObject


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.scf_handler = taf_scf(self.scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        # MRBTS Values
        mrbts_id = context.mrbts
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts.btsName.value = 'cOAM_SA_AEQN_TL4_test'

        # NRBTS Values
        NRBTS_1 = mrbts.NRBTS[0]
        NRBTS_1.mnc.value = '99'
        NRBTS_1.mcc.value = '404'
        NRBTS_1.mncLength.value = '2'
        NRBTS_1.TRACKINGAREA[0].fiveGsTac.value = '593'
        NRBTS_1.SERVEDAMF[0].amfIPAddress.value = '10.103.123.10'
        NRBTS_1.gNbCuType.value = 'SA'

        # NRCELL Values
        NRCELL_1 = mrbts.NRBTS[0].NRCELL[0]
        NRCELL_1.gscn.value = '7810'
        NRCELL_1.nrarfcn.value = '629856'
        NRCELL_1.physCellId.value = '501'

        # Remove existing Static Routes
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].staticRoutes.remove()

        # Add new Static Routes
        new_list = List().create('staticRoutes')
        item = Item().create()
        p = P().create(name='destIpAddr', value='0.0.0.0')
        item.append(p)
        p = P().create(name='destinationIpPrefixLength', value='0')
        item.append(p)
        p = P().create(name='gateway', value='10.53.190.17')
        item.append(p)
        p = P().create(name='preference', value='1')
        item.append(p)
        p = P().create(name='routeIpMtu', value='1450')
        item.append(p)
        new_list.append(item)
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].append(new_list)

        # Update the localIPAddr Value
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[0].IPADDRESSV4[0].localIpAddr.value = '10.53.190.21'
        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPIF[0].IPADDRESSV4[0].localIpPrefixLength.value = '28'

        # ciphering
        NRBTS_1.cipherPrefL[0].nea0.value = '1'
        NRBTS_1.cipherPrefL[0].nea1_128.value = '0'
        NRBTS_1.cipherPrefL[0].nea2_128.value = '0'
        NRBTS_1.cipherPrefL[0].nea3_128.value = '0'
