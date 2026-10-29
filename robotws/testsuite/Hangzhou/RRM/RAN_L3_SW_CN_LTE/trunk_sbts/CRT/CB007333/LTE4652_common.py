from ta_messaging.message_flows import get_flow
from ta_messaging import interface
from ta_messaging import message_flows as flow
from robot.libraries.BuiltIn import BuiltIn
from ta_emss import ta_emss
import re
from ta_messaging import ta_messaging
import pprint
import time


# ta_messaging = BuiltIn().get_library_instance('ta_messaging')


# Connected en-gNB to be Added List should contain gnb-id the same as gnb-id in X2SetupResponse
# Connected en-gNB to be Added List should contain Configure TAC and PLMN Identity the same as in X2SetupResponse

class LTE4652_common(object):
    def __init__(self):
        super(LTE4652_common, self).__init__()
        self.msg_content_s1ConfigUpdate = ''

    def verify_if_gnb_id_from_two_messages_is_the_same(self, message_source, flow_source, message_verified,
                                                       flow_verified):
        msg_content_1 = get_flow(flow_source).get_message(message_source)
        msg_content_2 = get_flow(flow_verified).get_message(message_verified)
        gnb_id_the_same_1 = msg_content_1.get_value_by_unique_key('en-gnb_ToBeAddedList')
        gnb_id_the_same_2 = msg_content_2.get_value_by_unique_key('en-gnb_ToBeAddedList')
        assert gnb_id_the_same_1 == gnb_id_the_same_2, \
            'gnb_id in X2SetupResponse {} is different than in S1ConfigurationUpdate {}'.format(msg_content_1,
                                                                                                msg_content_2)

    def change_mmes_status(self, mme_id, status):
        ta_emss().create_new_plan
        for id in mme_id:
            ta_emss().edit_object_attributes('lnmme-{}'.format(id), 'administrativeState={}'.format(status))
        ta_emss().apply_planned_changes

    def change_gnbs_status(self, gnb_id, status):
        ta_emss().create_new_plan
        for id in gnb_id:
            ta_emss().edit_object_attributes('lnadjgnb-{}'.format(id), 'administrativeState={}'.format(status))
        ta_emss().apply_planned_changes

    def get_device_from_object_name(self, sent_object):
        if re.search('LNADJGNB*', sent_object):
            object_dict = {'object_type': 'gnb',
                           'object_id': sent_object.split("-")[1],
                           'object_alias': 'gNB' + sent_object.split("-")[1]}
        elif re.search('LNMME*', sent_object):
            object_dict = {'object_type': 'mme',
                           'object_id': sent_object.split("-")[1],
                           'object_alias': 'MME' + sent_object.split("-")[1]}
        else:
            object_dict = None
        return object_dict

    def get_value_from_flow_msg(self, flow_source, message_source, key):
        msg = get_flow(flow_source).get_message(message_source)
        value = msg.get_all_values_by_key(key)
        return value

    def store_details_about_connected_gnb(self, flow_source, message_source, gnb_id):
        msg = get_flow(flow_source).get_message(message_source)
        gnb_global_id = msg.get_all_values_by_key('GlobalGNB-ID')
        gnb_global_id = gnb_global_id[0]
        if 'configured-TAC' in msg:
            tac = msg.get_all_values_by_key('configured-TAC')
            tac = tac[0]
        else:
            tac = ta_emss().get_enb_parameter_value('lncel-1', 'tac', bts_id=1)
            tac = '0x00' + hex(int(tac))[2:].upper()
        print(gnb_global_id)
        gnb_details = {
            gnb_id: {
                'id': gnb_global_id['gNB-ID']['gNB-ID'],
                'tac': tac,
                'plmn': gnb_global_id['pLMN-Identity'],
            },
        }
        return gnb_details

    def verify_correct_content_of_s1_message(self, flow_source, message_source, gnb_id_list, gnb_details,
                                             container_to_check='id-ConnectedengNBToAddList'):

        container_dict = {'id-ConnectedengNBToAddList': '292', 'id-ConnectedengNBToRemoveList': '293'}
        msg = get_flow(flow_source).get_message(message_source)
        message_type = message_source.split("_")

        if message_type[2] == 'Configuration':
            protocol_ies = msg.get_value_by_unique_key('protocolIEs')
            container = 'None'
            for item in protocol_ies:
                if str(item['id']) == str(container_dict[container_to_check]):
                    container = item
        elif message_type[2] == 'Setup':
            container = msg
        else:
            container = 'None'

        connected_engnb_list = container.get_all_values_by_key('ConnectedengNBList')[0]
        # print(connected_engnb_list)
        gnb_list = gnb_id_list.split(" ")

        new_from_msg = [{'plmn': dic['supportedTAs'][0]['broadcastPLMNs'][0], 'tac': dic['supportedTAs'][0]['tAC'],
                         'id': dic['en-gNB-ID']} for dic in connected_engnb_list]

        for gnb in gnb_list:
            assert gnb_details[gnb] in new_from_msg, \
                '{} info in S1 {} {} {} is different than in X2 Setup Response {}'.format(gnb,
                                                                                          message_type[1],
                                                                                          message_type[2],
                                                                                          new_from_msg,
                                                                                          gnb_details[gnb])

    def save_son_message_content(self, flow_source, message_source):
        # todo add lack of IP-Sec Transport Layer Address check verifier
        msg = get_flow(flow_source).get_message(message_source)
        son_container = msg.get_all_values_by_key('EN-DCSONConfigurationTransfer')[0]
        print(son_container)
        son_type = list(son_container['transfertype'].keys())[0]
        if son_type == 'request':
            son_details = {'transferType': son_type,
                           'sonInformation': son_container['sONInformation']['sONInformationRequest'],
                           'sourceEnbId': son_container['transfertype'][son_type]['sourceeNB']['globaleNBID']
                           ['eNB-ID']['macroENB-ID'],
                           'sourceEnbIdPLMN': son_container['transfertype'][son_type]['sourceeNB']['globaleNBID']
                           ['pLMNidentity'],
                           'sourceEnbIdTAITac': son_container['transfertype'][son_type]['sourceeNB']['selectedTAI']
                           ['tAC'],
                           'sourceEnbIdTAIPLMN': son_container['transfertype'][son_type]['sourceeNB']['selectedTAI']
                           ['pLMNidentity'],
                           'targetGnbId': son_container['transfertype'][son_type]['targetengNB']['globalengNBID']
                           ['en-gNB-ID'],
                           'targetGnbIdPLMN': son_container['transfertype'][son_type]['targetengNB']['globalengNBID']
                           ['pLMNidentity'],
                           'targetGnbIdTAITac': son_container['transfertype'][son_type]['targetengNB']['selectedTAI']
                           ['tAC'],
                           'targetGnbIdTAIPLMN': son_container['transfertype'][son_type]['targetengNB']['selectedTAI']
                           ['pLMNidentity'],
                           'eNBX2TransportAddress': self.ip_from_bin_to_dec(son_container['x2TNLConfigInfo']
                                                                            ['eNBX2TransportLayerAddresses'][0]),
                           'eNBX2TransportAddress_dual_stack': son_container['x2TNLConfigInfo']
                           ['eNBX2TransportLayerAddresses'],
                           'eNBX2ExtendedTransportAddress': self.ip_from_bin_to_dec(son_container['x2TNLConfigInfo']
                                                                                    ['iE-Extensions'][0]
                                                                                    ['extensionValue']
                                                                                    ['ENBX2ExtTLAs'][0]['gTPTLAa'][0])
                           }
        else:
            son_details = {'transferType': son_type,
                           'sonInformation': list(son_container['sONInformation'].keys())[0],
                           'targetEnbId': son_container['transfertype'][son_type]['targeteNB']
                           ['globaleNBID']['eNB-ID']['macroENB-ID'],
                           'sourceGnbId': son_container['transfertype'][son_type]
                           ['sourceengNB']['globalengNBID']['en-gNB-ID'],
                           'gNBX2TransportAddress': self.ip_from_bin_to_dec(son_container['sONInformation']
                                                                            ['sONInformationReply']
                                                                            ['x2TNLConfigurationInfo']
                                                                            ['eNBX2TransportLayerAddresses'][0]),
                           }
        print(son_details)
        # if son_type == 'request':
        #     son_details2 = {'transferType': son_type,
        #                     'sonInformation': son_container.get_value_by_unique_key('sONInformationRequest'),
        #                     'sourceEnbId': son_container.get_value_by_unique_key('macroENB-ID'),
        #                     'sourceEnbIdPLMN': son_container.get_value_by_unique_key('globaleNBID')
        #                     ['pLMNidentity'],
        #                     'sourceEnbIdTAITac': son_container.get_value_by_unique_key('sourceeNB')
        #                     ['selectedTAI']['tAC'],
        #                     'sourceEnbIdTAIPLMN': son_container.get_value_by_unique_key('sourceeNB')
        #                     ['selectedTAI']['pLMNidentity'],
        #                     'targetGnbId': son_container.get_value_by_unique_key('en-gNB-ID'),
        #                     'targetGnbIdPLMN': son_container.get_value_by_unique_key('targetengNB')
        #                     ['globalengNBID']['pLMNidentity'],
        #                     'targetGnbIdTAITac': son_container.get_value_by_unique_key('targetengNB')
        #                     ['selectedTAI']['tAC'],
        #                     'targetGnbIdTAIPLMN': son_container.get_value_by_unique_key('targetengNB')
        #                     ['selectedTAI']['pLMNidentity'],
        #                     'eNBX2TransportAddress': self.ip_from_bin_to_dec(son_container['x2TNLConfigInfo']
        #                     ['eNBX2TransportLayerAddresses'][0]),
        #                     'eNBX2ExtendedTransportAddress': self.ip_from_bin_to_dec(
        #                     son_container.get_value_by_unique_key('gTPTLAa')[0])
        #                     }
        # else:
        #     son_details2 = {'transferType': son_type,
        #                     'sonInformation': son_container['sONInformation'].keys()[0],
        #                     'targetEnbId': son_container.get_value_by_unique_key('macroENB-ID'),
        #                     'sourceGnbId': son_container.get_value_by_unique_key('en-gNB-ID'),
        #                     'gNBX2TransportAddress':
        #                     self.ip_from_bin_to_dec(son_container.get_value_by_unique_key(
        #                     'eNBX2TransportLayerAddresses')),
        #                     }
        # print(son_details2)
        return son_details

    def verify_correct_content_of_son_message(self, gnb_to_check, request_flow, reply_flow=None,
                                              replaced_cplane_ip=None,
                                              enb_dual_stack=False):
        request_message = 'ETC_request'
        # todo add lack of IP-Sec Transport Layer Address check verifier
        gnb_data = self.pull_info_about_gnb_from_emss(gnb_to_check)
        enb_details = self.pull_info_about_enb_from_emss()
        request_content = self.save_son_message_content(request_flow, request_message)
        assert request_content['transferType'] == 'request', \
            'Transfer type in request message is not set to request'
        assert request_content['sonInformation'] == 'x2TNL-Configuration-Info', \
            'SON Information in request message is not set to x2TNL-Configuration-Info'

        assert request_content['sourceEnbId'] == enb_details['id'], \
            'eNB ID: {} in request message is not set to expected eNB ID: {}'.format(
                request_content['sourceEnbId'], enb_details['id'])
        assert request_content['sourceEnbIdPLMN'] == enb_details['plmn'], \
            'eNB PLMN Identity: {} in request message is not set to expected eNB PLMN Identity: {}'.format(
                request_content['sourceEnbIdPLMN'], enb_details['plmn'])

        assert request_content['sourceEnbIdTAIPLMN'].lower() == enb_details['plmn'].lower(), \
            'eNB TAI PLMN Identity: {} in request message is not set to expected eNB TAI PLMN Identity: {}'.format(
                request_content['sourceEnbIdTAIPLMN'].lower(), enb_details['plmn'].lower())
        assert request_content['sourceEnbIdTAITac'].lower() == enb_details['tac'].lower(), \
            'eNB TAI TAC: {} in request message is not set to expected eNB TAI TAC: {}'.format(
                request_content['sourceEnbIdTAITac'].lower(), enb_details['tac'].lower())

        assert request_content['targetGnbId'] == gnb_data['id'], \
            'gNB ID: {} in request message is not set to expected gNB ID: {}'.format(
                request_content['targetGnbId'], gnb_data['id'])
        assert request_content['targetGnbIdPLMN'].lower() == gnb_data['plmn'].lower(), \
            'gNB PLMN Identity: {} in request message is not set to expected gNB PLMN Identity: {}'.format(
                request_content['targetGnbIdPLMN'].lower(), gnb_data['plmn'].lower())

        if not enb_dual_stack:
            assert request_content['eNBX2TransportAddress'] == enb_details['cplane_ipv4_dn1'], \
                'eNB Transport Address: {} in request message is not set to expected value: {}'.format(
                    request_content['eNBX2TransportAddress'], enb_details['cplane_ipv4_dn1'])
            assert request_content['eNBX2ExtendedTransportAddress'] == enb_details['uplane_ipv4_dn1'], \
                'eNB Extended Transport Address: {} in request message is not set to expected value: {}'.format(
                    request_content['eNBX2ExtendedTransportAddress'], enb_details['uplane_ipv4_dn1'])
        else:
            ipv4_ipv6_details = self.pull_info_about_enb_dual_stack_transport_addresses_from_emss()
            first_enb_transport_address = self.ip_from_bin_to_dec(request_content[
                                                                      'eNBX2TransportAddress_dual_stack'][0])
            second_enb_transport_address = self.ip_from_bin_to_dec(request_content[
                                                                       'eNBX2TransportAddress_dual_stack'][1])
            assert first_enb_transport_address == {ipv4_ipv6_details['cplane_ipv4_dn1'],
                                                   ipv4_ipv6_details['cplane_ipv6_dn1']}, \
                '1st eNB Transport Address: {} in request message is not set to expected value: {}'.format(
                    request_content['eNBX2TransportAddress'], {ipv4_ipv6_details['cplane_ipv4_dn1'],
                                                               ipv4_ipv6_details['cplane_ipv6_dn1']})
            assert second_enb_transport_address == {ipv4_ipv6_details['cplane_ipv4_dn2'],
                                                    ipv4_ipv6_details['cplane_ipv6_dn2']}, \
                '2nd eNB Transport Address: {} in request message is not set to expected value: {}'.format(
                    request_content['eNBX2TransportAddress'], {ipv4_ipv6_details['cplane_ipv4_dn2'],
                                                               ipv4_ipv6_details['cplane_ipv6_dn2']})
            assert request_content['eNBX2ExtendedTransportAddress'] == {ipv4_ipv6_details['uplane_ipv4_dn1'],
                                                                        ipv4_ipv6_details['uplane_ipv6_dn1']}, \
                'eNB Extended Transport Address: {} in request message is not set to expected value: {}'.format(
                    request_content['eNBX2ExtendedTransportAddress'], {ipv4_ipv6_details['uplane_ipv4_dn1'],
                                                                       ipv4_ipv6_details['uplane_ipv6_dn1']})

        if reply_flow:
            reply_message = 'ETC_reply'
            reply_content = self.save_son_message_content(reply_flow, reply_message)

            assert reply_content['transferType'] == 'reply', \
                'Transfer type in reply message is not set to reply'

            assert reply_content['sourceGnbId'] == request_content['targetGnbId'], \
                'gNB ID: {} from transfer reply is different than gNB ID: {} from transfer request'.format(
                    reply_content['sourceGnbId'], request_content['targetGnbId'])
            assert reply_content['targetEnbId'] == request_content['sourceEnbId'], \
                'eNB ID: {} from transfer reply is different than eNB ID: {} from transfer request'.format(
                    reply_content['targetEnbId'], request_content['sourceEnbId'])

            assert reply_content['sonInformation'] == 'sONInformationReply', \
                'SON Information in reply message is not set to sONInformationReply'
            print(gnb_data['ip'])
            if gnb_data['ip'] and gnb_data['ip'] != "None":
                if replaced_cplane_ip is not None:
                    ip_list = replaced_cplane_ip.split(",")
                    assert all([i in reply_content['gNBX2TransportAddress'] for i in ip_list]), \
                        'gNB IP: {} from transfer reply is different than expected gNB IP: {}'.format(
                            str(reply_content['gNBX2TransportAddress']), replaced_cplane_ip)
                else:
                    assert reply_content['gNBX2TransportAddress'] == gnb_data['ip'], \
                        'gNB IP: {} from transfer reply is different than expected gNB IP: {}'.format(
                            reply_content['gNBX2TransportAddress'], gnb_data['ip'])
            else:
                print('There was no IP in emss to verify with')
        else:
            print('Reply message was not verified')

    def verify_correct_content_of_part_of_son_message(self, flow_alias, message_alias, gnb, moc_type):
        son_content = self.save_son_message_content(flow_alias, message_alias)
        params_to_check = self.get_stored_gnb_params_to_verify(gnb, moc_type)
        print(params_to_check)
        for key, value in params_to_check.items():
            assert son_content[key] == value, \
                '{}: {} from Configuration Transfer is different than expected {}: {}'.format(
                    key, son_content[key], key, value)

    def get_stored_gnb_params_to_verify(self, gnb, moc_type):
        gnb_tmp_storage = {'gNB_2': {'Request': {
                                                 'targetGnbIdPLMN': self.encode_plmn(250, 555),
                                                 'targetGnbId': str(self.convert_id_to_binary(18, 22))
                                                 },
                                     'Reply': {
                                               'gNBX2TransportAddress': '10.0.1.202'
                                               }
                                     },
                           'gNB_3': {'Request': {
                                                 'targetGnbIdPLMN': self.encode_plmn(250, 550),
                                                 'targetGnbId': str(self.convert_id_to_binary(19, 22))
                                                 }
                                     }
                           }
        return gnb_tmp_storage[gnb][moc_type]

    def pull_info_about_enb_from_emss(self):
        enb_id = self.convert_id_to_binary(1, 20)
        mcc = str(ta_emss().get_enb_parameter_value('lnbts-1', 'mcc', bts_id=1))
        mnc = str(ta_emss().get_enb_parameter_value('lnbts-1', 'mnc', bts_id=1))
        plmn = self.encode_plmn(mcc, mnc)
        existing_trsnw = str(ta_emss().get_existing_objects_of_given_type('trsnw', bts_id=1)[0])
        object_with_ip = ta_emss().get_object_attributes(existing_trsnw, bts_id=1)
        cplane_ipv4_dn1_moc = self.get_moc_from_path(object_with_ip['cplane.ipv4addressdn1[0]'])
        cplane_ipv4_dn1 = str(ta_emss().get_enb_parameter_value(cplane_ipv4_dn1_moc, 'localIpAddr', bts_id=1))
        uplane_ipv4_dn1_moc = self.get_moc_from_path(object_with_ip['uplane.ipv4addressdn1[0]'])
        uplane_ipv4_dn1 = str(ta_emss().get_enb_parameter_value(uplane_ipv4_dn1_moc, 'localIpAddr', bts_id=1))
        tac = str(ta_emss().get_enb_parameter_value('lncel-1', 'tac', bts_id=1))
        tac = self.convert_tac_to_hex(tac)

        enb_details = {'id': enb_id,
                       'plmn': plmn,
                       'cplane_ipv4_dn1': cplane_ipv4_dn1,
                       'uplane_ipv4_dn1': uplane_ipv4_dn1,
                       'tac': tac
                       }
        return enb_details

    def pull_info_about_gnb_from_emss(self, gnb_id):
        moc = 'LNADJGNB-' + gnb_id
        gnb_moc = ta_emss().get_object_attributes(moc, bts_id=1)
        print(gnb_moc)
        if 'cplaneipaddr' not in gnb_moc.keys():
            gnb_moc['cplaneipaddr'] = None

        gnb_data = {'id': str(self.convert_id_to_binary(gnb_moc['adjgnbid'], int(gnb_moc['adjgnbidlength']))),
                    'plmn': str(self.encode_plmn(gnb_moc['plmnid.mcc[0]'], gnb_moc['plmnid.mnc[0]'])),
                    'ip': str(gnb_moc['cplaneipaddr']),
                    'cPlaneIpAddrCtrl': str(gnb_moc['cplaneipaddrctrl']),
                    'adjGnbIdLength': str(gnb_moc['adjgnbidlength'])
                    }

        return gnb_data

    def verify_object_values_in_emsss(self, moc, expected_values):
        gnb_moc = ta_emss().get_object_attributes(moc, bts_id=1)
        print(gnb_moc)
        for key, value in expected_values.items():
            assert gnb_moc[key] == value, \
                '{}: {} from emss is different than expected {}: {}'.format(
                    key, gnb_moc[key], key, value)

    def ip_from_bin_to_dec(self, binary_ip):
        ip = binary_ip[2:]
        if len(ip) == 32:
            converted_ip = self.ip_from_bin_to_dec_ipv4(ip)
        elif len(ip) == 128:
            converted_ip = self.ip_from_bin_to_dec_ipv6(ip)
        else:
            converted_ipv4 = self.ip_from_bin_to_dec_ipv4(ip[0:32])
            converted_ipv6 = self.ip_from_bin_to_dec_ipv6(ip[32:])
            converted_ip = {converted_ipv4, converted_ipv6}
        return converted_ip

    def ip_from_bin_to_dec_ipv4(self, ip):
        converted_ip = ''
        ip = re.findall('........', ip)
        for octet in ip:
            tmp = int(octet, base=2)
            converted_ip = converted_ip + str(tmp) + '.'
        converted_ip = converted_ip[:-1]

        return converted_ip

    def ip_from_bin_to_dec_ipv6(self, ip):
        converted_ip = ''
        ip = re.findall('................', ip)
        for two_octets in ip:
            tmp = hex(int(two_octets, base=2))
            converted_ip = converted_ip + str(tmp)[2:] + ':'
        converted_ip = converted_ip[:-1]

        return converted_ip

    def get_moc_from_path(self, path):
        tmp = path.split('/')
        # moc = tmp[-1] + '-' + tmp[-2][-1] + '-' + tmp[-3][-1] + '-' + tmp[-4][-1] + '-' + tmp[-5][-1]
        moc = tmp[-1].split('-')
        moc = str(moc[0]) + '-1-1-1-1-' + str(moc[1])
        return moc

    def convert_id_to_binary(self, id, bits=22):
        id = int(id)
        binary_id = bin(id)
        fill = bits - len(binary_id) + len('0b')
        binary_id = binary_id[:2] + '0' * fill + binary_id[2:]

        return binary_id

    def convert_tac_to_hex(self, tac):
        tac = int(tac)
        hex_tac = hex(tac)
        fill = 6 - len(hex_tac)
        hex_tac = hex_tac[:2] + '0' * fill + hex_tac[2:]

        return hex_tac

    def encode_plmn(self, mcc, mnc):
        mcc = str(mcc)
        mnc = str(mnc)
        print("Encoding mcc {} and mnc {} into plmn".format(mcc, mnc))
        if len(mnc) == 2:
            plmn = mcc[1] + mcc[0] + 'F' + mcc[2] + mnc[1] + mnc[0]
        elif len(mnc) == 1:
            plmn = mcc[1] + mcc[0] + 'F' + mcc[2] + mnc[0] + '0'
        else:
            plmn = mcc[1] + mcc[0] + mnc[0] + mcc[2] + mnc[2] + mnc[1]

        return '0x' + plmn

    def decode_plmn(self, plmn):
        plmn = str(plmn)
        mcc = plmn[1] + plmn[0] + plmn[3]
        if plmn[2].lower() == 'f':
            mnc = plmn[5] + plmn[4]
        else:
            mnc = plmn[2] + plmn[5] + plmn[4]

        return mcc, mnc

    def verify_lack_of_connected_en_gnb_list_in_s1(self, flow_source, message_source):
        msg = get_flow(flow_source).get_message(message_source)
        mme = flow_source.split("_")[0]
        assert not ("ConnectedengNBList" in msg), \
            'S1 Setup Request from {} contains ConnectedengNBList container'.format(mme)

    def create_s1_configuration_update_flow(self, mme_list, gnb_list, timeout=100):
        gnb_list = '_'.join(gnb_list)
        for mme in mme_list:
            ta_messaging().expect_message_flow('{}:S1AP_ENBConfigurationUpdate as \
                                                {}_Configuration_Update'.format(mme, mme),
                                               '{}:S1AP_ENBConfigurationUpdateAcknowledge as \
                                                {}_Configuration_Update_Acknowledge'.format(mme, mme),
                                               alias='{}_Configuration_Update_with_{}'.format(mme, gnb_list),
                                               overall_timeout=timeout)

    def create_multiple_aliases_for_device(self, device, first_device_id, last_device_id):
        for device_id in range(int(first_device_id), int(last_device_id) + 1):
            if str(device).lower() == 'mme':
                alias = str(device) + str(device_id)
                ta_messaging().create_mme_alias(alias, device_id, 'wts')
            else:
                alias = str(device) + str(device_id)
                ta_messaging().create_enb_alias(alias, device_id, 'wts')

    def prepare_alias_suffix(self, gnb_list, second_list='None'):
        if second_list == 'None':
            suffix = '_'.join(gnb_list.split(" "))
        else:
            suffix = '_'.join(gnb_list.split(" ")) + '_' + '_'.join(second_list.split(" "))
        return suffix

    def verify_that_TAC_IE_setting_is_based_on_eNB_configuration(self, flow_alias, message_alias):
        msg_content = get_flow(flow_alias).get_message(message_alias)
        tac_from_message = msg_content.get_value_by_unique_key('tAC')
        print(tac_from_message)
        tac_from_eNB_settings = ta_emss().get_enb_parameter_value('lncel-1', 'tac', bts_id=1)
        assert int(tac_from_message, 0) == int(tac_from_eNB_settings), 'TAC is not correctly set !'

    def validate_that_alarm_is_related_to_proper_mme(self, alarm, mme):
        device_from_alarm = alarm['-DEVICE_NAME']
        expected_mme = '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1/LNMME_R-' + mme[-1]
        assert str(device_from_alarm) == str(expected_mme), 'ALARM not raised for proper MME!'

    def verify_MOC_setting_is_aligned_with_gNB_response(self, param, gnb_id, gnb_details):
        moc_data = self.pull_info_about_gnb_from_emss(gnb_id)
        print(moc_data)
        gnb = 'gNB_' + gnb_id
        print(gnb_details[gnb])
        if param == 'PLMN':
            print('Checking PLMN')
            assert moc_data['plmn'] == gnb_details[gnb]['plmn'], 'PLMN is not correct in LNADJGNB!'
        elif param == 'adjGNBid':
            print('Checking adjGNB')
            assert moc_data['id'] == gnb_details[gnb]['id'], 'adjGNBid is not correct in LNADJGNB!'
        elif param == 'adjGnbIdLength':
            print('adjGNB')
            print(moc_data['adjGnbIdLength'])
            print(str(len(gnb_details[gnb]['id'])))
            assert moc_data['adjGnbIdLength'] == str(len(gnb_details[gnb]['id'][2:])), 'adjGnbIdLength is not correct !'

    def check_if_recieved_IP_is_different_than_configured_in_precondition(self, configured_IP,
                                                                          flow_alias,
                                                                          message_alias):
        msg_content = get_flow(flow_alias).get_message(message_alias)
        IP_from_message = msg_content.get_value_by_unique_key('eNBX2TransportLayerAddresses')[0]
        print(IP_from_message)
        IP_converted = self.ip_from_bin_to_dec(IP_from_message)
        print(IP_converted)
        print(configured_IP)
        assert str(configured_IP) != str(IP_converted), 'IP address recieved is not different ! Check preconditions !'

    def check_if_IP_in_MOC_is_based_on_SON_Reply(self, gnb_id, flow_alias, message_alias):
        msg_content = get_flow(flow_alias).get_message(message_alias)
        IP_from_message = msg_content.get_value_by_unique_key('eNBX2TransportLayerAddresses')[0]
        IP_converted = self.ip_from_bin_to_dec(IP_from_message)
        print(IP_converted)
        moc_data = self.pull_info_about_gnb_from_emss(gnb_id)
        print(moc_data['ip'])
        assert str(IP_converted) == str(moc_data['ip']), 'IP set to unexpected value'

    def verify_time_difference_between_two_messages(self, first_flow, first_message, second_flow,
                                                    second_message, expected_time_diff):
        first_timestamp = get_flow(first_flow).get_message(first_message).occurrence_time
        second_timestamp = get_flow(second_flow).get_message(second_message).occurrence_time
        time_diff = float(second_timestamp) - float(first_timestamp)
        print(time_diff)
        low_bound = 0.9 * float(expected_time_diff)
        high_bound = 1.1 * float(expected_time_diff)
        assert low_bound < time_diff < high_bound, 'Timer not in expected margin'

    def verify_two_messages_send_nearly_at_the_same_time(self, first_flow, first_message, second_flow,
                                                         second_message, expected_time_diff):
        first_timestamp = get_flow(first_flow).get_message(first_message).occurrence_time
        second_timestamp = get_flow(second_flow).get_message(second_message).occurrence_time
        time_diff = float(second_timestamp) - float(first_timestamp)
        print(time_diff)
        assert time_diff < float(expected_time_diff), 'Time difference not in expected range'

    def get_time_of_anrnr_guard_timer(self, message, filepath):
        with open(filepath, 'r') as logfile:
            regexp = '^.*' + str(message) + '.*$'
            print(regexp)
            logfile_content = logfile.read()
            findings = re.findall(regexp, logfile_content, re.MULTILINE)
        print(findings)
        assert len(findings) > 0, "No \"{}\" message has been found in syslog".format(message)
        time = re.search('T([-:.0-9]+)Z>', findings[-1]).group(1)
        print(time)
        time = time[6:-3]
        print(time)
        return time

    def wait_until_lnadjgnb_removal_is_expected(self, guardtimer_from_syslog=21.24):
        guardtimer = float(guardtimer_from_syslog)
        timestamp = time.time() - 2  # because after UE_1 raported PCI 393 was sleep 2s
        print("Time when removal of LNADJGNB-127 was started {}".format(timestamp))
        rest = int(timestamp) % 60 + timestamp % 1
        print("Time when removal of LNADJGNB-127 was started (only seconds) {}".format(rest))
        # sprawdzamy czy bylismy tuz po, czy tuz przed guard checkiem
        if rest < guardtimer:
            wait_for_removal = guardtimer - rest + 60
        else:
            wait_for_removal = guardtimer - rest + 120
        print(wait_for_removal)

        sleeep = wait_for_removal - 7.2  # tyle mniej wiecej trzeba odjac zeby sie wbic przy obecnej wersji skryptu
        print(sleeep)
        time.sleep(sleeep)

    def count_time(self, time_before):
        time_now = time.time()
        difference = time_now - float(time_before)
        print(difference)
        assert difference < 150, "ECU was triggered after {} seconds".format(difference)

    def verify_plmn_in_endcx2setupresponse(self, message_alias, flow_alias, gnb_id, plmn_list):
        msg = get_flow(flow_alias).get_message(message_alias)
        plmn_list = plmn_list.split(" ")
        aggregated_plmn_list = []
        for cell in range(3):
            servedNRcellsENDCX2ManagementList = msg.get_value_by_unique_key('ServedNRcellsENDCX2ManagementList')[cell]
            broadcast_plmns = servedNRcellsENDCX2ManagementList.get_value_by_unique_key('broadcastPLMNs')
            for plmn in broadcast_plmns:
                aggregated_plmn_list.append(plmn)
        assert plmn_list == aggregated_plmn_list, \
            'PLMNs in ENDC_X2_SETUP_RESPONSE from gNB-{} are not as expected'.format(
                gnb_id)

    def verify_plmn_in_s1_message(self, message_alias, flow_alias, mme_id, plmn_list, tac_list):
        msg = get_flow(flow_alias).get_message(message_alias)
        print(msg)
        plmn_list = plmn_list.split(" ")
        tac_list = tac_list.split(" ")
        supported_tac = []
        broadcast_plmns = []
        for gnb in range(3):
            connectedengNBList = msg.get_value_by_unique_key('ConnectedengNBList')[gnb]
            for j in range(2):
                supported_tas = connectedengNBList.get_value_by_unique_key('supportedTAs')[j]
                tac = supported_tas.get_value_by_unique_key('tAC')
                supported_tac.append(tac)
                plmns = supported_tas.get_value_by_unique_key('broadcastPLMNs')
                for plmn in plmns:
                    broadcast_plmns.append(plmn)
        assert supported_tac == tac_list, 'TACs in S1_SETUP_REQUEST to MME{} are not as expected'.format(mme_id)
        assert broadcast_plmns == plmn_list, 'Broadcast PLMNs in S1_SETUP_REQUEST to MME{} are not as expected'.format(
            mme_id)

    # class Timestamp(object):
    #
    #     def __init__(self):
    #         super(Timestamp, self).__init__()
    #
    #     def get_timestamp(self):
    #         self.timestamp = time.time()
    #         print("Time is {}".format(timestamp))
    #         return timestamp
    #
    #     def count_time(self):
    #         time_now = time.time()
    #         time_before = self.timestamp
    #         difference = time_now-time_before
    #         if difference < 300:
    #             print("Passed time: {}s".format(difference))
    #         else:
    #             print("Time is too long")

    def verify_gnbx2transportaddress_in_son_message_with_lnadjgnb(self, gnb_to_check,
                                                                  reply_flow,
                                                                  ip_address=None,
                                                                  ip_address_v6=None):
        if (gnb_to_check == 'None'):
            if (type(ip_address) is dict):
                expected_ip = ip_address['cplaneipaddr']
            else:
                expected_ip = ip_address
            if (ip_address_v6 is not None):
                expected_ip = {ip_address, ip_address_v6}
        else:
            moc = 'LNADJGNB-' + gnb_to_check
            lnadjgnb_ip = ta_emss().get_object_attributes(moc, 'cPlaneIpAddr', bts_id=1)
            expected_ip = lnadjgnb_ip['cplaneipaddr']

        reply_message = 'ETC_reply'
        reply_content = self.save_son_message_content(reply_flow, reply_message)

        assert reply_content['gNBX2TransportAddress'] == expected_ip, \
            'gNB IP: {} from transfer reply is different than expected gNB IP: {}'.format(
                reply_content['gNBX2TransportAddress'], expected_ip)

    def pull_info_about_enb_dual_stack_transport_addresses_from_emss(self):
        enb_id = self.convert_id_to_binary(1, 20)
        mcc = str(ta_emss().get_enb_parameter_value('lnbts-1', 'mcc', bts_id=1))
        mnc = str(ta_emss().get_enb_parameter_value('lnbts-1', 'mnc', bts_id=1))
        plmn = self.encode_plmn(mcc, mnc)
        existing_trsnw = str(ta_emss().get_existing_objects_of_given_type('trsnw', bts_id=1)[0])
        object_with_ip = ta_emss().get_object_attributes(existing_trsnw, bts_id=1)
        cplane_ipv4_dn1_moc = self.get_moc_from_path(object_with_ip['cplane.ipv4addressdn1[0]'])
        cplane_ipv4_dn1 = str(ta_emss().get_enb_parameter_value(cplane_ipv4_dn1_moc, 'localIpAddr', bts_id=1))
        cplane_ipv4_dn2_moc = self.get_moc_from_path(object_with_ip['cplane.ipv4addressdn2[0]'])
        cplane_ipv4_dn2 = str(ta_emss().get_enb_parameter_value(cplane_ipv4_dn2_moc, 'localIpAddr', bts_id=1))
        cplane_ipv6_dn1_moc = self.get_moc_from_path(object_with_ip['cplane.ipv6addressdn1[0]'])
        cplane_ipv6_dn1 = str(ta_emss().get_enb_parameter_value(cplane_ipv6_dn1_moc, 'localIpAddr', bts_id=1))
        cplane_ipv6_dn2_moc = self.get_moc_from_path(object_with_ip['cplane.ipv6addressdn2[0]'])
        cplane_ipv6_dn2 = str(ta_emss().get_enb_parameter_value(cplane_ipv6_dn2_moc, 'localIpAddr', bts_id=1))

        uplane_ipv4_dn1_moc = self.get_moc_from_path(object_with_ip['uplane.ipv4addressdn1[0]'])
        uplane_ipv4_dn1 = str(ta_emss().get_enb_parameter_value(uplane_ipv4_dn1_moc, 'localIpAddr', bts_id=1))
        uplane_ipv6_dn1_moc = self.get_moc_from_path(object_with_ip['uplane.ipv6addressdn1[0]'])
        uplane_ipv6_dn1 = str(ta_emss().get_enb_parameter_value(uplane_ipv6_dn1_moc, 'localIpAddr', bts_id=1))

        ipv4_ipv6_details = {'id': enb_id,
                             'cplane_ipv4_dn1': cplane_ipv4_dn1,
                             'cplane_ipv4_dn2': cplane_ipv4_dn2,
                             'cplane_ipv6_dn1': cplane_ipv6_dn1,
                             'cplane_ipv6_dn2': cplane_ipv6_dn2,
                             'uplane_ipv4_dn1': uplane_ipv4_dn1,
                             'uplane_ipv6_dn1': uplane_ipv6_dn1
                             }
        print(ipv4_ipv6_details)
        return ipv4_ipv6_details
