attached_pci_4 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '4'}, n='1')]

attached_pci_100 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '100'}, n='1')]

HO_attached_pci_70 = [
    dict(xpath='SgNBModificationRequired/rrcReconfiguration/spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '70'}, n='1')]

HO_NOT_attached_pci_70 = [
    dict(xpath='SgNBModificationRequired/spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '70'}, n='1', result_reverse=True)]

nrRestrictionInEPS = [
    dict(xpath='InitialContextSetupRequest/HandoverRestrictionList',
         expected_value={'NRrestrictioninEPSasSecondaryRAT': 'nRrestrictedinEPSasSecondaryRAT (0)'}, n='1')]

inter_freq_intra_gnb_message_flow = dict(order_list=['measurementReport',
                                                     'SgNBModificationRequired',
                                                     'SgNBModificationRequest',
                                                     'SgNBModificationRequestAcknowledge',
                                                     'SgNBModificationConfirm',
                                                     'measurementReport',
                                                     'SgNBModificationRequired',
                                                     'SgNBModificationConfirm',
                                                     'SgNBModificationRequired',
                                                     'SgNBModificationRequest',
                                                     'SgNBModificationRequestAcknowledge',
                                                     'SgNBModificationConfirm'])
