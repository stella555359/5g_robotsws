import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# attach pci
attached_pci_86 = [
    dict(xpath='UEContextModificationResponse/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '86'}, n='1')]

attached_pci_87 = [
    dict(xpath='UEContextModificationResponse/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '87'}, n='1')]

attached_pci_88 = [
    dict(xpath='UEContextModificationResponse/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '88'}, n='1')]

# switched pci
switched_pci_86 = [
    dict(xpath='rrcReconfiguration/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '86'}, n='1')]

switched_pci_87 = [
    dict(xpath='rrcReconfiguration/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '87'}, n='1')]

switched_pci_88 = [
    dict(xpath='rrcReconfiguration/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '88'}, n='1')]

# flow message
gnb_source_message_flow = dict(order_list=['measurementreport',
                                           'rrcReconfiguration'],
                               should_not_include=['PDUSessionResourceModifyRequest'])

gnb_target_message_flow = dict(order_list=['PathSwitchRequest',
                                           'PathSwitchRequestAcknowledge',
                                           'UEContextModificationResponse'],
                               should_not_include=['PDUSessionResourceModifyRequest'])

gnb_same_message_flow = dict(order_list=['measurementreport',
                                         'rrcReconfiguration',
                                         'rrcReconfigurationComplete',
                                         'UEContextModificationResponse'])

vonr_setup_message_flow = dict(order_list=['PDUSessionResourceModifyRequest',
                                           'rrcReconfiguration',
                                           'rrcReconfigurationComplete',
                                           'PDUSessionResourceModifyResponse'])

vonr_fiveQI_1 = [
    dict(xpath='PDUSessionResourceModifyRequest/PDUSessionResourceModifyRequestTransfer',
         expected_value={'fiveQI': '1'}, n='1')]
