# -*- coding: utf-8 -*-

__maintainer__ = 'Kamil Pielka'
__team__ = 'MN 5G&SC'
__email__ = 'kamil.pielka@nokia.com'


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

        # RMOD
        antl2_distname = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-2'
        mrbts.EQM[0].APEQM[0].RMOD[0].ANTL[0].clone_tree_to(antl2_distname)
        mrbts.EQM[0].APEQM[0].RMOD[0].ANTL[1].antPortId.value = 2

        new_radioMasterDN = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1'
        p = P().create(name='radioMasterDN', value=new_radioMasterDN)
        mrbts.EQM[0].APEQM[0].RMOD[0].append(p)

        prodcode_AHLOA = '474331A'
        mrbts.EQM[0].APEQM[0].RMOD[0].prodCodePlanned.value = prodcode_AHLOA

        id_rmod_to_add = [2, 3]
        for num in id_rmod_to_add:
            new_rmod = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-{}'.format(num)
            mrbts.EQM[0].APEQM[0].RMOD[0].clone_tree_to(new_rmod)

        # NRCEL
        id_cells_to_add = [2, 3]
        for num in id_cells_to_add:
            new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELL-{}'.format(num)
            mrbts.NRBTS[0].NRCELL[0].clone_tree_to(new_nrcell)

        # gscn
        gscn_3cells = {mrbts.NRBTS[0].NRCELL[0].gscn: '0',
                       mrbts.NRBTS[0].NRCELL[1].gscn: '1586',
                       mrbts.NRBTS[0].NRCELL[2].gscn: '0'}

        for p, p_value in gscn_3cells.items():
            p.value = p_value

        # nrarfcn
        nrarfcndl_3cells = {mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].nrarfcnDl: '125900',
                            mrbts.NRBTS[0].NRCELL[1].NRCELL_FDD[0].nrarfcnDl: '126900',
                            mrbts.NRBTS[0].NRCELL[2].NRCELL_FDD[0].nrarfcnDl: '125900'}

        for p, p_value in nrarfcndl_3cells.items():
            p.value = p_value

        nrarfcnul_3cells = {mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].nrarfcnUl: '135100',
                            mrbts.NRBTS[0].NRCELL[1].NRCELL_FDD[0].nrarfcnUl: '136100',
                            mrbts.NRBTS[0].NRCELL[2].NRCELL_FDD[0].nrarfcnUl: '135100'}

        for p, p_value in nrarfcnul_3cells.items():
            p.value = p_value

        # another parameters
        value = 0
        for cell in range(0, 3):
            mrbts.NRBTS[0].NRCELL[cell].physCellId.value += value
            mrbts.NRBTS[0].NRCELL[cell].lcrId.value += value
            mrbts.NRBTS[0].NRCELL[cell].prachConfigurationIndex.value += value
            mrbts.NRBTS[0].NRCELL[cell].type0CoresetConfigurationIndex.value = 0
            mrbts.NRBTS[0].NRCELL[cell].freqBandIndicatorNR.value = 71
            value += 1

        # NRCELLGRP parameters
        id_nrcellgrp_to_add = [1, 2]
        for num in id_nrcellgrp_to_add:
            new_nrcellgrp = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELLGRP-{}'.format(num)
            mrbts.NRBTS[0].NRCELLGRP[0].clone_tree_to(new_nrcellgrp)
            mrbts.NRBTS[0].NRCELLGRP[num].nrCellList[0].value += num

            p = P().create(value=num)
            mrbts.NRBTS[0].NRDU[0].refNrCellGroup.append(p)

        for num in id_rmod_to_add:
            rmod_id = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-{}'.format(num)
            mrbts.NRBTS[0].NRCELL[num-1].rModDNList[0].value = rmod_id

        # CABLINK
        endpoint_smod = 'MRBTS-' + str(mrbts_id) + '/EQM-1/SMOD_EXT-1'
        rmod_2 = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-2'
        rmod_3 = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-3'

        id_cablink_to_add = [3, 4, 5, 6, 7]
        for num in id_cablink_to_add:
            new_cablink = 'MRBTS-' + str(mrbts_id) + '/EQM-1/HWTOP-1/CABLINK-{}'.format(num)
            mrbts.EQM[0].HWTOP[0].CABLINK[1].clone_tree_to(new_cablink)

        for num in [4, 5, 6]:
            p = P().create(name='linkModeSynchronization', value='false')
            mrbts.EQM[0].HWTOP[0].CABLINK[num].append(p)
            mrbts.EQM[0].HWTOP[0].CABLINK[num].firstEndpointPortId.remove()
            mrbts.EQM[0].HWTOP[0].CABLINK[num].secondEndpointLabel.remove()
            mrbts.EQM[0].HWTOP[0].CABLINK[num].firstEndpointDN.value = endpoint_smod
            mrbts.EQM[0].HWTOP[0].CABLINK[num].firstEndpointLabel.value = 'OPT'
            mrbts.EQM[0].HWTOP[0].CABLINK[num].secondEndpointPortId.value = 0
            p = P().create(name='linkModeConfiguration', value='false')
            mrbts.EQM[0].HWTOP[0].CABLINK[num].append(p)
            p = P().create(name='linkModeDC', value='false')
            mrbts.EQM[0].HWTOP[0].CABLINK[num].append(p)
            p = P().create(name='linkModeData', value='false')
            mrbts.EQM[0].HWTOP[0].CABLINK[num].append(p)
            p = P().create(name='linkModeSynchronization', value='false')
            mrbts.EQM[0].HWTOP[0].CABLINK[num].append(p)

        for num in [2, 5]:
            mrbts.EQM[0].HWTOP[0].CABLINK[num].secondEndpointDN.value = rmod_2

        for num in [3, 6]:
            mrbts.EQM[0].HWTOP[0].CABLINK[num].secondEndpointDN.value = rmod_3

        for num in [3, 6]:
            mrbts.EQM[0].HWTOP[0].CABLINK[num].secondEndpointDN.value = rmod_3

        mrbts.EQM[0].HWTOP[0].CABLINK[1].firstEndpointPortId.value = 1

        for num in [2, 3]:
            mrbts.EQM[0].HWTOP[0].CABLINK[num].firstEndpointPortId.value = 2

        mrbts.EQM[0].HWTOP[0].CABLINK[1].firstEndpointLabel.value = 'SFP'
        mrbts.EQM[0].HWTOP[0].CABLINK[2].firstEndpointLabel.value = 'SFP'
        mrbts.EQM[0].HWTOP[0].CABLINK[3].firstEndpointLabel.value = 'QSFP'

        # SMOD EXT
        smodext_distname = 'MRBTS-' + str(mrbts_id) + '/EQM-1/SMOD_EXT-1'
        self.add_object_with_params(distname=smodext_distname,
                                    klass="com.nokia.srbts.eqm:SMOD_EXT", version=eqm_version,
                                    eutraSupport='true',
                                    eutraTDDSupport='false',
                                    geranSupport='false',
                                    nrSupport='false',
                                    sranSupport='false',
                                    syncMaster='false',
                                    utranSupport='false')

        # MNLENT
        antlDN_new = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-2'
        for num in [2, 3]:
            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].CHANNELGROUP[0].CHANNEL[num].antlDN.value = antlDN_new

        id_lcelnr_to_add = [2, 3]
        for num in id_lcelnr_to_add:
            new_lcelnr = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.format(num)
            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].clone_tree_to(new_lcelnr)
            for chan_id in [1, 2, 3, 4]:
                antlDN_obj = \
                    mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[num-1].CHANNELGROUP[0].CHANNEL[chan_id-1].antlDN
                antlDN_obj.value = antlDN_obj.value[0:30] + str(num) + antlDN_obj.value[-7:]

        # TRBLCADM
        trblcadm_distname = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
        self.add_object_with_params(distname=trblcadm_distname,
                                    klass="com.nokia.srbts.mnl:TRBLCADM", version=mnl_version,
                                    actCoreDumpFileCollection='true',
                                    actInternalTrace='true',
                                    actRemoteSyslogTransmission='false',
                                    snapshotUploadDelayForFault6450=1)

        mrbts.TNLSVC[0].TNL[0].ETHSVC[0].L2SWI[0].l2SwitchingEnabled.value = 'false'
        mrbts.TNLSVC[0].TNL[0].ETHSVC[0].L2SWI[0].l2QoSEnabled.value = 'false'

        fiveGsTac_value = mrbts.NRBTS[0].NRCELL[0].fiveGsTac.value
        mrbts.NRBTS[0].TRACKINGAREA[0].fiveGsTac.value = fiveGsTac_value

        # Configuration QCI6
        mrbts.NRBTS[0].qciTab6Nsa3x[0].dlDataSplitMode.value = 'dlOverF1U'
        mrbts.NRBTS[0].qciTab6Nsa3x[0].dlFlowControlAlgo.value = '3gppFlowControl'
        mrbts.NRBTS[0].qciTab6Nsa3x[0].initialDLTrafficRouting.value = 'initDLoverF1U'
        mrbts.NRBTS[0].qciTab6Nsa3x[0].schedulWeight.value = '1'
        mrbts.NRBTS[0].qciTab6Nsa3x[0].ulDataPath.value = 'ulOverNr'
        mrbts.NRBTS[0].qciTab6Nsa3x[0].ulDataSplitThreshold.value = 'infinity'
