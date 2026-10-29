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

        # add cablink and bbmod
        mrbts.EQM[0].HWTOP[0].CABLINK[0].firstEndpointLabel.remove()
        mrbts.EQM[0].HWTOP[0].CABLINK[0].secondEndpointLabel.remove()
        cablink_mo = mrbts.EQM[0].HWTOP[0].CABLINK[0]
        self.add_object_with_params(mo=cablink_mo, firstEndpointLabel='BACKPLANE', secondEndpointLabel='BACKPLANE',
                                    linkSpeed='eCpri25')

        cablink_dist_name = 'MRBTS-' + str(mrbts_id) + '/EQM-1/HWTOP-1/CABLINK-3'
        cablink_mnl_version = mrbts.EQM[0].HWTOP[0].CABLINK[0]['version']
        self.add_object_with_params(distname=cablink_dist_name,
                                    klass="com.nokia.srbts.eqm:CABLINK", version=cablink_mnl_version,
                                    firstEndpointDN='MRBTS-50301/EQM-1/APEQM-1/CABINET-1/SMOD-1',
                                    firstEndpointLabel='BACKPLANE',
                                    firstEndpointPortId='2',
                                    linkModeConfiguration='false',
                                    linkModeDC='false',
                                    linkModeData='false',
                                    linkModeSynchronization='false',
                                    linkSpeed='eCpri25',
                                    secondEndpointDN='MRBTS-50301/EQM-1/APEQM-1/CABINET-1/BBMOD-2',
                                    secondEndpointLabel='BACKPLANE'
                                    )

        cablink_dist_name = 'MRBTS-' + str(mrbts_id) + '/EQM-1/HWTOP-1/CABLINK-4'
        cablink_mnl_version = mrbts.EQM[0].HWTOP[0].CABLINK[0]['version']
        self.add_object_with_params(distname=cablink_dist_name,
                                    klass="com.nokia.srbts.eqm:CABLINK", version=cablink_mnl_version,
                                    firstEndpointDN='MRBTS-50301/EQM-1/APEQM-1/CABINET-1/BBMOD-2',
                                    firstEndpointLabel='QSFP',
                                    firstEndpointPortId='2',
                                    iqCompression='none',
                                    linkSpeed='Cpri7',
                                    radioProtocolType='TDDCPRI',
                                    secondEndpointPortId='2',
                                    secondEndpointDN='MRBTS-50301/EQM-1/APEQM-1/RMOD-1',
                                    secondEndpointLabel='QSFP'
                                    )

        bbmod_dist_name = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/CABINET-1/BBMOD-2'
        bbmod_mnl_version = mrbts.EQM[0].APEQM[0].CABINET[0].BBMOD[0]['version']
        self.add_object_with_params(distname=bbmod_dist_name,
                                    klass="com.nokia.srbts.eqm:BBMOD", version=bbmod_mnl_version,
                                    administrativeState='Unlocked',
                                    prodCodePlanned='473961A',
                                    useFullCapacity='true'
                                    )
        # modify cell_1
        mrbts.NRBTS_1.NRCELL[0].configuredEpsTac.value = '1'
        mrbts.NRBTS_1.NRCELL[0].gscn.value = '22402'
        mrbts.NRBTS_1.NRCELL[0].dllaIniMcs.value = '0'
        mrbts.NRBTS_1.NRCELL[0].nrarfcn.value = '2059003'
        mrbts.NRBTS_1.NRCELL[0].pMax.value = '210'
        mrbts.NRBTS_1.NRCELL[0].type0SearchSpaceConfigurationIndex.value = '4'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].frameStructureType.value = 'semiStatic'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].guardPeriodLength.value = '2Symbols'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].ulDlDataSlotRatio.value = '1/4'

        # add new cells
        id_cells_to_add = [2, 3, 4]
        for num in id_cells_to_add:
            new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELL-{}'.format(num)
            mrbts.NRBTS_1.NRCELL[0].clone_tree_to(new_nrcell)

        list = mrbts.NRBTS_1.NRCELLGRP[0].nrCellList
        for num in id_cells_to_add:
            p = P().create(value=num)
            list.append(p)

        nrarfcn_4cells = {mrbts.NRBTS_1.NRCELL[0].nrarfcn: '2059003',
                          mrbts.NRBTS_1.NRCELL[1].nrarfcn: '2060703',
                          mrbts.NRBTS_1.NRCELL[2].nrarfcn: '2062123',
                          mrbts.NRBTS_1.NRCELL[3].nrarfcn: '2064083'
                          }
        for p, p_value in nrarfcn_4cells.items():
            p.value = p_value

        gscn_4cells = {mrbts.NRBTS_1.NRCELL[0].gscn: '22402',
                       mrbts.NRBTS_1.NRCELL[1].gscn: '22408',
                       mrbts.NRBTS_1.NRCELL[2].gscn: '22414',
                       mrbts.NRBTS_1.NRCELL[3].gscn: '22420',
                       }
        for p, p_value in gscn_4cells.items():
            p.value = p_value

        for cell in range(1, 4):
            mrbts.NRBTS_1.NRCELL[cell].physCellId.value += cell
            mrbts.NRBTS_1.NRCELL[cell].lcrId.value += cell
            mrbts.NRBTS_1.NRCELL[cell].pMax.value = 210

        id_cells_to_add = [2, 3, 4]
        for num in id_cells_to_add:
            new_lcelnr = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.format(num)
            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].clone_tree_to(new_lcelnr)

        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[1].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[1].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[3].CHANNELGROUP[0].CHANNEL[1].remove()
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[3].CHANNELGROUP[0].CHANNEL[1].remove()
        mrbts.NRBTS[0].NRCELL[1].cellBarred.value = 'barred'
        mrbts.NRBTS[0].NRCELL[3].cellBarred.value = 'barred'
        mrbts.NRBTS[0].NRCELL[1].intraFreqReselection.value = 'notAllowed'
        mrbts.NRBTS[0].NRCELL[3].intraFreqReselection.value = 'notAllowed'
        mrbts.NRBTS[0].NRCELL[1].nrCellType.value = '2DL0UL'
        mrbts.NRBTS[0].NRCELL[3].nrCellType.value = '2DL0UL'

        trblcadm_dist_name = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
        trblcadm_mnl_version = mrbts.MNL[0]['version']
        self.add_object_with_params(distname=trblcadm_dist_name,
                                    klass="com.nokia.srbts.mnl:TRBLCADM", version=trblcadm_mnl_version,
                                    actCoreDumpFileCollection='true',
                                    actInternalTrace='true',
                                    actRemoteSyslogTransmission='false',
                                    snapshotUploadDelayForFault6450='0'
                                    )
