"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
import copy
import os
import pprint
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from ta_messaging.message_verifiers import message_verifier
from ta_pcmd import pcmd_verifier
from mesagge_to_record_field_mappers import *
from message_field_getters import *
import logging
from robot.api import logger as robot_logger


FORMAT = '%(asctime)s-[%(levelname)s] (%(threadName)-10s) %(message)s'

logging.basicConfig(level=logging.WARN,
                    format=FORMAT)
try:
    out_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
except RobotNotRunningError:
    out_dir = os.getcwd()
file_handler = logging.FileHandler(os.path.sep.join([out_dir,  'message_verifier_for_pcmd.log']))
file_handler.setFormatter(logging.Formatter(FORMAT))
logging.getLogger('message_verifier_for_pcmd').addHandler(file_handler)


class verifier_msg_for_pcmd(object):
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    PCMD_RECORD_DYNAMIC_FIELDS = {
        'ULRRCMessageTransfer': {'fields': {'GNB-CU-UE-F1AP-ID': 'gnb_cu_f1ap_id',
                                            'GNB-DU-UE-F1AP-ID': 'gnb_du_f1ap_id'}
                                 },
        'InitialULRRCMessageTransfer': {'fields': {'GNB-DU-UE-F1AP-ID': 'gnb-du-ue-f1ap-Id'}},
        'DLRRCMessageTransfer': {'fields': {'GNB-CU-UE-F1AP-ID': 'gnb-cu-ue-f1ap-Id'}},
        'UEContextReleaseCommand': {'fields': {'GNB-CU-UE-F1AP-ID': 'gnb-cu-ue-f1ap-Id'}},
        'UEContextModificationRequest': {'fields': {'GNB-CU-UE-F1AP-ID': 'gnb-cu-ue-f1ap-Id',
                                                    'GNB-DU-UE-F1AP-ID': 'gnb-du-ue-f1ap-Id'}
                                         },
        'UEContextSetupResponse': {'fields': {'GNB-CU-UE-F1AP-ID': 'gnb_cu_f1ap_id',
                                              'GNB-DU-UE-F1AP-ID': 'gnb_du_f1ap_id'}
                                   },
        'UEContextModificationResponse': {'fields': {'RAN-UE-NGAP-ID': 'ran-ue-ngap-Id',
                                                     'AMF-UE-NGAP-ID': 'amf-ue-ngap-Id'}
                                          },
        'InitialContextSetupFailure': {'fields': {'RAN-UE-NGAP-ID': 'ran-ue-ngap-Id',
                                                  'AMF-UE-NGAP-ID': 'amf-ue-ngap-Id'}
                                       },
        'PathSwitchRequestAcknowledge': {'fields': {'RAN-UE-NGAP-ID': 'ran-ue-ngap-Id',
                                                    'AMF-UE-NGAP-ID': 'amf-ue-ngap-Id'}
                                         },
        'InitialContextSetupRequest': {
                                            'fields': {
                                                        'pDUSessionID': 'pduSessionId',
                                                        'sST': 'sst',
                                                        'sD': 'sd',
                                                        'pDUSessionAggregateMaximumBitRateDL': 'dlBitRate',
                                                        'pDUSessionAggregateMaximumBitRateUL': 'ulBitRate',
                                                        'qosFlowIdentifier': 'qfi',
                                                        'fiveQI': 'fiveQi',
                                                        'priorityLevelARP': 'priorityLevel',
                                                        'pre-emptionCapability': 'preemptionCapability',
                                                        'pre-emptionVulnerability': 'preemptionVulnerability'
                                                       },
                                            'mappers': {
                                               'sST': remove_hex_sign,
                                               'sD': remove_hex_sign,
                                               'pre-emptionCapability': premeption_capability,
                                               'pre-emptionVulnerability': premeption_vulnerability,
                                               'pLMNIdentity': remove_hex_sign,
                                               'aMFRegionID': convert_binary_to_decimal,
                                               'aMFSetID': convert_binary_to_decimal,
                                               'aMFPointer': convert_binary_to_decimal
                                            },
                                            'getters': {
                                                'sST': ('PDUSessionResourceSetupListCxtReq', 'sST'),
                                                'sD': ('PDUSessionResourceSetupListCxtReq', 'sD')
                                            }
                                        },
        'DownlinkNASTransport': {'fields': {'RAN-UE-NGAP-ID': 'ran-ue-ngap-Id',
                                            'AMF-UE-NGAP-ID': 'amf-ue-ngap-Id'}
                                 },
        'UplinkNASTransport':   {'fields': {'RAN-UE-NGAP-ID': 'ran-ue-ngap-Id',
                                            'AMF-UE-NGAP-ID': 'amf-ue-ngap-Id'}
                                 },
        'InitialContextSetupResponse': {'fields': {'RAN-UE-NGAP-ID': 'ran-ue-ngap-Id',
                                                   'AMF-UE-NGAP-ID': 'amf-ue-ngap-Id'}
                                        },
        'InitialUEMessage': {'fields': {'RRCEstablishmentCause': 'rrcEstablishmentCause'},
                             'mappers': {
                                         'RRCEstablishmentCause': remove_dash_sign
                                     },
                             },
        'RRCSetupRequest': {'fields': {'establishmentCause': 'rrcEstablishmentCause',
                                       'ng-5G-S-TMSI-Part1': 'ng-5g-s-tmsi-part1'},
                            'mappers': {'establishmentCause': remove_dash_sign},
                            },
        'RRCReestablishmentRequest': {'fields': {'reestablishmentCause': 'reestablishment-cause'},
                                      },
        'RRCSetupComplete': {'fields': {'ng-5G-S-TMSI': 'ng-5g-s-tmsi',
                                        'ng-5G-S-TMSI-Part2': 'ng-5g-s-tmsi-part2'}
                             },
        'PDUSessionResourceReleaseCommand': {'fields': {'pDUSessionID': 'pduSessionId'}},
        'PDUSessionResourceSetupRequest': {
                                            'fields': {
                                                        'pDUSessionID': 'pduSessionId',
                                                        'sST': 'sst',
                                                        'sD': 'sd',
                                                        'pDUSessionAggregateMaximumBitRateDL': 'dlBitRate',
                                                        'pDUSessionAggregateMaximumBitRateUL': 'ulBitRate',
                                                        'qosFlowIdentifier': 'qfi',
                                                        'fiveQI': 'fiveQi',
                                                        'priorityLevelARP': 'priorityLevel',
                                                        'pre-emptionCapability': 'preemptionCapability',
                                                        'pre-emptionVulnerability': 'preemptionVulnerability'
                                                       },
                                            'mappers': {
                                               'sST': remove_hex_sign,
                                               'sD': remove_hex_sign,
                                               'pre-emptionCapability': premeption_capability,
                                               'pre-emptionVulnerability': premeption_vulnerability
                                                }
                                        },
        'HandoverRequest': {
            'fields': {
                'pduSessionId': 'pduSessionId',
                'sst': 'sst',
                'sd': 'sd',
                'downlink-session-AMBR': 'dlBitRate',
                'uplink-session-AMBR': 'ulBitRate',
                'qfi': 'qfi',
                'fiveQI': 'fiveQi',
                'priorityLevel': 'priorityLevel',
                'pre-emption-capability': 'preemptionCapability',
                'pre-emption-vulnerability': 'preemptionVulnerability'
            },
            'mappers': {
                'nr-CI': convert_binary_to_decimal,
                'plmn-id': remove_hex_sign,
                'sst': remove_hex_sign,
                'sd': remove_hex_sign,
                'pre-emption-capability': premeption_capability,
                'pre-emption-vulnerability': premeption_vulnerability
            },
            'getters': {
                'qfi': ('pduSessionResourcesToBeSetup-List', 'qosFlowsToBeSetup-List', 'qfi'),
            }
        },
        'HandoverRequestAcknowledge': {
            'fields': {
                'NG-RANnodeUEXnAPID': 'ng-ran-node-ue-xnap-id'}
        },
        'HandoverRequired': {
            'fields': {
                'macroNgENB-ID': 'macroNgENB-id',
                'enb_pLMNIdentity': 'enb-plmn',
                'gnb_pLMNIdentity': 'gnb-plmn'
            },
            'getters': {
                'macroNgENB-ID': ('globalENB-ID', 'ngENB-ID', 'macroNgENB-ID'),
                'enb_pLMNIdentity': ('globalENB-ID', 'pLMNIdentity'),
                'gnb_pLMNIdentity': ('globalGNB-ID', 'pLMNIdentity')
            },
            'mappers': {
                'macroNgENB-ID': convert_binary_to_decimal,
                'enb_pLMNIdentity': remove_hex_sign,
                'gnb_pLMNIdentity': remove_hex_sign
            }
        },
        'SgNBModificationRequest': {
            'fields': {
                'UE-X2AP-ID': 'ue-x2ap-id',
                'SgNB-UE-X2AP-ID': 'sgnb-ue-x2ap-id'
            }
        },
        'SgNBModificationRequired': {
            'fields': {
                'UE-X2AP-ID': 'ue-x2ap-id',
                'SgNB-UE-X2AP-ID': 'sgnb-ue-x2ap-id'
            }
        },
        'SgNBModificationRequestAcknowledge': {
            'fields': {
                 'UE-X2AP-ID': 'ue-x2ap-id',
                 'SgNB-UE-X2AP-ID': 'sgnb-ue-x2ap-id'
            }
        },
        'SgNBAdditionRequestAcknowledge': {
            'fields': {
                'UE-X2AP-ID': 'ue-x2ap-id',
                'SgNB-UE-X2AP-ID': 'sgnb-ue-x2ap-id'
            }
        },
        'SgNBReleaseConfirm': {
            'fields': {
                'UE-X2AP-ID': 'ue-x2ap-id',
                'SgNB-UE-X2AP-ID': 'sgnb-ue-x2ap-id'
            }
        },
        'PDUSessionResourceModifyRequest': {
                                            'fields': {
                                                        'pDUSessionID': 'pduSessionId',
                                                        'sST': 'sst',
                                                        'sD': 'sd',
                                                        'pDUSessionAggregateMaximumBitRateDL': 'dlBitRate',
                                                        'pDUSessionAggregateMaximumBitRateUL': 'ulBitRate',
                                                        'qosFlowIdentifier': 'qfi',
                                                        'fiveQI': 'fiveQi',
                                                        'priorityLevelARP': 'priorityLevel',
                                                        'pre-emptionCapability': 'preemptionCapability',
                                                        'pre-emptionVulnerability': 'preemptionVulnerability',
                                                        'maximumFlowBitRateDL': 'maximumFlowBitRateDl',
                                                        'maximumFlowBitRateUL': 'maximumFlowBitRateUl',
                                                        'guaranteedFlowBitRateDL': 'guaranteedFlowBitRateDl',
                                                        'guaranteedFlowBitRateUL': 'guaranteedFlowBitRateUl',
                                                       },
                                            'mappers': {
                                               'sST': remove_hex_sign,
                                               'sD': remove_hex_sign,
                                               'pre-emptionCapability': premeption_capability,
                                               'pre-emptionVulnerability': premeption_vulnerability
                                                }
        }
    }
    USED_PCMD_RECORD_DYNAMIC_FIELDS = copy.deepcopy(PCMD_RECORD_DYNAMIC_FIELDS)

    message_values = {}
    # example output:
    # message_values = {'ULRRCMessageTransfer': {'GNB-CU-UE-F1AP-ID': [0], 'GNB-DU-UE-F1AP-ID': [1]}}

    def set_custom_fields(self, *fields_list, **kwargs):
        """
        Allows to set own set of wanted fields in USED_PCMD_RECORD_DYNAMIC_FIELDS structure.
        Given fields must be in format:
        field_name_in_message:field_name_in_pcmd_record
        Note: It overwrites the original structure for given message_name.
        For append/remove of single field use append_custom_fields / remove_custom_fields.
        """
        assert 'message_name' in kwargs, 'message_name must be added as kwarg'
        message_name = kwargs['message_name'].strip()
        assert message_name in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS, \
            'Fields for message: {} not available in structure: {}'\
            .format(message_name, list(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS.keys()))
        verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'] = {}
        print('Removed all fields from USED_PCMD_RECORD_DYNAMIC_FIELDS structure for: {}'.format(message_name))
        for field_name_pcmd_name in fields_list:
            (field_name, pcmd_name) = field_name_pcmd_name.strip().split(':')
            verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'][field_name] = pcmd_name
        print('Added following fields:\n{}\nin USED_PCMD_RECORD_DYNAMIC_FIELDS structure for: {}'
              .format(pprint.pformat(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields']),
                      message_name))

    def restore_basic_fields(self, message_name):
        """
        Set USED_PCMD_RECORD_DYNAMIC_FIELDS fields for given message to generic values from PCMD_RECORD_DYNAMIC_FIELDS
        """
        message_name = message_name.strip()
        assert message_name in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS, \
            'Fields for message: {} not available in structure: {}'\
            .format(message_name, list(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS.keys()))
        verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'] = \
            copy.deepcopy(verifier_msg_for_pcmd.PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'])

    def append_custom_fields(self, *fields_list, **kwargs):
        """
        Allows to append additional fields in USED_PCMD_RECORD_DYNAMIC_FIELDS structure.
        Given fields must be in format:
        field_name_in_message:field_name_in_pcmd_record
        Note: It does not overwrite the original structure for given message_nanme, just adds new fields
        """
        assert 'message_name' in kwargs, 'message_name must be added as kwarg'
        message_name = kwargs['message_name'].strip()
        assert message_name in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS, \
            'Fields for message: {} not available in structure: {}'\
            .format(message_name, list(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS.keys()))
        for field_name_pcmd_name in fields_list:
            (field_name, pcmd_name) = field_name_pcmd_name.strip().split(':')
            assert field_name not in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'], \
                'Field: {} already exists'.format(field_name)
            verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'][field_name] = pcmd_name
        print('All fields after addition:\n{}\n in USED_PCMD_RECORD_DYNAMIC_FIELDS structure for: {}'
              .format(pprint.pformat(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields']),
                      message_name))

    def remove_fields(self, *fields_list, **kwargs):
        """
        Allows to append additional fields in USED_PCMD_RECORD_DYNAMIC_FIELDS structure.
        Given fields must be in format:
        field_name_in_message
        Note: It does not overwrite the original structure for given message_nanme, just removes some fields
        """
        assert 'message_name' in kwargs, 'message_name must be added as kwarg'
        message_name = kwargs['message_name'].strip()
        assert message_name in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS, \
            'Fields for message: {} not available in structure: {}' \
            .format(message_name, list(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS.keys()))
        for field_name in fields_list:
            assert field_name not in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'], \
                'Field: {} does not exist'.format(field_name)
            del verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields'][field_name]
        print('All fields after deletion:\n{}\n in USED_PCMD_RECORD_DYNAMIC_FIELDS structure for: {}'
              .format(pprint.pformat(verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['fields']),
                      message_name))

    def clear_fields_saved_from_messages(self):
        verifier_msg_for_pcmd.message_values = {}

    def get_variable_from_messages_for_single_field(self, messages, field_name, skip_value_removal=True):
        if not isinstance(messages, list):
            messages = [msg.strip() for msg in messages.split(',')]
        values = []
        for m in messages:
            value = self.get_variable_from_single_message_for_single_field(m, field_name, skip_value_removal)
            if isinstance(value, list):
                values.extend(value)
            else:
                values.append(values)
        print('Values of field: {}: {}'.format(field_name, values))
        return values

    def get_variable_from_single_message_for_single_field(self, message_name, field_name, skip_value_removal=True):
        assert message_name in verifier_msg_for_pcmd.message_values, \
            'Message: {} not present in memory, available: {}'\
            .format(message_name, list(verifier_msg_for_pcmd.message_values.keys()))

        assert field_name in verifier_msg_for_pcmd.message_values[message_name], \
            'Field: {} not present in message, available fields: {}'\
            .format(message_name, list(verifier_msg_for_pcmd.message_values[message_name].keys()))

        field_value = verifier_msg_for_pcmd.message_values[message_name][field_name][0]
        if 'mappers' in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name] and \
                field_name in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['mappers']:
            mapper_func = verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message_name]['mappers'][field_name]
        else:
            def mapper_func(field_value):
                return field_value
        if isinstance(field_value, list):
            ret_value = [mapper_func(y_value) for y_value in field_value]
        else:
            ret_value = mapper_func(field_value)
        if skip_value_removal is False:
            print('Removed single message: {} from memory'.format(message_name))
            del verifier_msg_for_pcmd.message_values[message_name]
        return ret_value

    def set_variable_from_single_message_for_single_field_in_yaml(self, yaml_path, message_name, field_name,
                                                                  alias=None,
                                                                  skip_value_removal=False):

        self._set_variable_from_message_for_record_yaml(yaml_path=yaml_path, alias=alias,
                                                        skip_value_removal=skip_value_removal,
                                                        message_name=message_name,
                                                        field_name=field_name)

    def set_variable_from_single_message_for_record_yaml(self, yaml_path, message_name, alias=None,
                                                         skip_value_removal=False):

        self._set_variable_from_message_for_record_yaml(yaml_path=yaml_path, alias=alias,
                                                        skip_value_removal=skip_value_removal,
                                                        message_name=message_name)

    def set_variable_from_message_for_record_yaml(self, yaml_path, alias=None, skip_value_removal=False):
        self._set_variable_from_message_for_record_yaml(yaml_path=yaml_path, alias=alias,
                                                        skip_value_removal=skip_value_removal, message_name=None)

    def _set_variable_from_message_for_record_yaml(self, yaml_path, alias=None, skip_value_removal=False,
                                                   message_name=None,
                                                   field_name=None):
        try:
            ta_pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        except Exception as e:
            robot_logger.warn(
                "ta_pcmd instance not exist, before execute please configure pcmd keywords in robot framework suite"
            )
        print('Messages in memory:\n{}'.format(list(verifier_msg_for_pcmd.message_values.keys())))
        if message_name is not None:
            assert message_name in verifier_msg_for_pcmd.message_values, \
                'Message: {} not present in memory: {}\n'.format(message_name,
                                                                 list(verifier_msg_for_pcmd.message_values.keys()))
            messages_to_process = [message_name]
        else:
            messages_to_process = list(verifier_msg_for_pcmd.message_values.keys())
        for message in messages_to_process:
            print('Save message: {} value for:'.format(message))
            if field_name is not None:
                assert field_name in verifier_msg_for_pcmd.message_values[message], \
                    'Field: {} not present in message: {}. Message fields are: {}\n'\
                    .format(field_name, message_name, list(verifier_msg_for_pcmd.message_values[message].keys()))
                field_to_process = [field_name]
            else:
                field_to_process = list(verifier_msg_for_pcmd.message_values[message].keys())
            for field in field_to_process:
                print(field)
                if len(verifier_msg_for_pcmd.message_values[message][field]) != 0:
                    if skip_value_removal:
                        yaml_value = verifier_msg_for_pcmd.message_values[message][field][0]
                    else:
                        yaml_value = verifier_msg_for_pcmd.message_values[message][field].pop(0)
                    print(yaml_value)
                    if 'mappers' in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message] and \
                            field in verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message]['mappers']:
                        mapper_func = verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message]['mappers'][field]
                        if isinstance(yaml_value, list):
                            yaml_value = [mapper_func(y_value) for y_value in yaml_value]
                        else:
                            yaml_value = mapper_func(yaml_value)
                    print(yaml_value)
                    ta_pcmd_inst.set_variable_for_record_yaml(
                        verifier_msg_for_pcmd.USED_PCMD_RECORD_DYNAMIC_FIELDS[message]['fields'][field],
                        yaml_value,
                        yaml_path,
                        alias
                    )
                else:
                    raise Exception('Please use expect message flow before using keyword')
        if skip_value_removal is False:
            if message_name is not None:
                print('Removed single message: {} from memory'.format(message_name))
                del verifier_msg_for_pcmd.message_values[message_name]
            else:
                print('Removed messages: {} from memory'.format(list(verifier_msg_for_pcmd.message_values.keys())))
                verifier_msg_for_pcmd.message_values = {}
        print("Created temp yaml values: {}".format(pprint.pformat(pcmd_verifier.YAML_VARS_PER_YAML)))


if 'save_pcmd_selected_value' not in globals():

    @message_verifier
    def save_pcmd_selected_value(message):
        """
        Verifier for single occurrence of fields in PCMD messages.
        Use other verifiers for multi-field cases.
        """
        logger = logging.getLogger('message_verifier_for_pcmd')

        try:
            msg_type = message.type
        except Exception:
            try:
                msg_type = list(message.get_all_values_by_key('value')[0].keys())[0]
            except Exception as e:
                logger.warning(f"Could not determine message type: {e}")
                return False

        message.type = msg_type
        logger.warning(f"Got message: {msg_type}")

        config = USED_PCMD_RECORD_DYNAMIC_FIELDS.get(msg_type)
        if not config:
            logger.warning(f"Unknown message type: {msg_type}. Known types: {list(USED_PCMD_RECORD_DYNAMIC_FIELDS)}")
            return True

        for field in config['fields']:
            getter = (
                get_field_from_structure(config['getters'][field], many=False)
                if 'getters' in config and field in config['getters']
                else default_unique_field_getter(field, many=False)
            )

            try:
                value = getter(message)
                logger.warning(f"{msg_type}  {field}: {value}")
            except Exception:
                logger.warning(
                    f"Field '{field}' not found in '{msg_type}'. "
                    f"Check PCMD_RECORD_DYNAMIC_FIELDS configuration."
                )
                continue

            message_values.setdefault(msg_type, {}).setdefault(field, []).append(value)

        return True

    globals()['save_pcmd_selected_value'] = save_pcmd_selected_value


if 'save_pcmd_many_selected_values' not in globals():

    @message_verifier
    def save_pcmd_many_selected_values(message):
        """
        Verifier for PCMD messages where multiple values of the same field may occur.
        """
        logger = logging.getLogger('message_verifier_for_pcmd')

        # Determine message type
        try:
            msg_type = message.type
        except Exception:
            try:
                msg_type = list(message.get_all_values_by_key('value')[0].keys())[0]
            except Exception as e:
                logger.warning(f"Could not determine message type: {e}")
                return False

        message.type = msg_type
        logger.warning(f"Got message: {msg_type}")

        config = USED_PCMD_RECORD_DYNAMIC_FIELDS.get(msg_type)
        if not config:
            logger.warning(
                f"Message type '{msg_type}' is not in USED_PCMD_RECORD_DYNAMIC_FIELDS. "
                f"Known types:\n{list(USED_PCMD_RECORD_DYNAMIC_FIELDS)}"
            )
            return True

        for field in config['fields']:
            # Select appropriate field getter
            if 'getters' in config and field in config['getters']:
                getter = get_field_from_structure(config['getters'][field], many=True)
            else:
                getter = default_unique_field_getter(field, many=True)

            try:
                values = getter(message)
                logger.warning(f"{msg_type}  {field}: {values}")
            except Exception:
                logger.warning(
                    f"\nMESSAGE_VERIFIER: Field '{field}' not found in message type '{msg_type}'. "
                    f"Check your PCMD_RECORD_DYNAMIC_FIELDS configuration."
                )
                continue

            # Store the extracted values in the global message_values dictionary
            msg_fields = message_values.setdefault(msg_type, {})
            field_values = msg_fields.setdefault(field, [])
            field_values.append(values)

            logger.warning(f"Accumulated values for {msg_type}: {message_values[msg_type]}")

        return True

    # Register the function globally to prevent redeclaration
    globals()['save_pcmd_many_selected_values'] = save_pcmd_many_selected_values
