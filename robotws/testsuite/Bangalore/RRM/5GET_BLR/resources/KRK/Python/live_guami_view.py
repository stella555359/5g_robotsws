import copy
import logging
import os
import pprint
import re
import threading
import time
import traceback
from ute_common_abstract_core.aliases_registry import aliases_registry as _aliases_registry
from utilities import val_to_bool as _val_to_bool
from emss_param_disp import get_parameters_for_object_type as _get_parameters_for_object_type
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from ta_messaging.message_verifiers import message_verifier as _message_verifier

FORMAT = '%(asctime)s-[%(levelname)s] (%(threadName)-10s) %(message)s'

logging.basicConfig(level=logging.INFO,
                    format=FORMAT)
try:
    out_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
except RobotNotRunningError:
    out_dir = os.getcwd()
log_filepath = os.path.sep.join([out_dir,  'guami_view.log'])
if os.path.exists(log_filepath):
    os.remove(log_filepath)
file_handler = logging.FileHandler(log_filepath)
file_handler.setFormatter(logging.Formatter(FORMAT))
logging.getLogger('guami_view').addHandler(file_handler)


GUAMI_DATABASE = {}
"""
Has structure like:
{'AMF1' :
    [{'region': reg_dec, 'pointer': pointer_dec,
     'set': set_dec, 'guami_type': guami_type,
     'status': 'available'},
     ...
     ]
}
"""
GUAMI_DATABASE_UPDATES = 0
message_lock = threading.Semaphore(1)


@_message_verifier
def save_guamis_and_types(owner_alias, message):
    global GUAMI_DATABASE
    global GUAMI_DATABASE_UPDATES
    logger = logging.getLogger('guami_view')
    logger.info('Got message for alias: {}'.format(owner_alias))
    message_lock.acquire()
    try:
        message_payload = message.parse()
        logger.info(pprint.pformat(message_payload))
        if 'ServedGUAMIList' in message_payload:  # from NGSetupResponse/AmfConfigurationUpdate
            guami_result = []
            guami_list = message_payload.get_value_by_unique_key('ServedGUAMIList')
            for guami in guami_list:
                pointer_bin = str(guami.get_value_by_unique_key('aMFPointer')[2:])
                set_bin = str(guami.get_value_by_unique_key('aMFSetID')[2:])
                region_bin = str(guami.get_value_by_unique_key('aMFRegionID')[2:])
                pointer_dec = str(int(pointer_bin, 2))
                set_dec = str(int(set_bin, 2))
                reg_dec = str(int(region_bin, 2))
                if 'GUAMIType' in guami:
                    guami_type = guami.get_value_by_unique_key('GUAMIType')
                    if 'unknown' in guami_type:
                        guami_type = 'other'
                else:
                    guami_type = 'not_set'
                guami_result.append({'region': reg_dec, 'pointer': pointer_dec, 'set': set_dec,
                                     'guami_type': guami_type, 'status': 'available'})
            GUAMI_DATABASE[owner_alias] = guami_result
            logger.info('[{}] Updated Guami View:\n{}'.format(owner_alias, pprint.pformat(GUAMI_DATABASE[owner_alias])))
        if 'UnavailableGUAMIList' in message_payload:  # from AMFStatusIndication
            unavailable_guami_list = message_payload.get_value_by_unique_key('UnavailableGUAMIList')
            for guami in unavailable_guami_list:
                pointer_bin = str(guami.get_value_by_unique_key('aMFPointer')[2:])
                set_bin = str(guami.get_value_by_unique_key('aMFSetID')[2:])
                region_bin = str(guami.get_value_by_unique_key('aMFRegionID')[2:])
                pointer_dec = str(int(pointer_bin, 2))
                set_dec = str(int(set_bin, 2))
                reg_dec = str(int(region_bin, 2))
                temp_guami = {'region': reg_dec, 'pointer': pointer_dec, 'set': set_dec}
                logger.info('[{}] Received unavailable guami: {}'.format(owner_alias, pprint.pformat(temp_guami)))
                for database_guami_item in GUAMI_DATABASE[owner_alias]:
                    if (database_guami_item['region'] == temp_guami['region'] and
                            database_guami_item['set'] == temp_guami['set'] and
                            database_guami_item['pointer'] == temp_guami['pointer']):
                        logger.info('[{}] Found guami in database'.format(owner_alias))
                        if database_guami_item['status'] == 'unavailable':
                            logger.info('[{}] Guami is already set to unavailable!')
                        else:
                            database_guami_item['status'] = 'unavailable'
                            logger.info('[{}] Setting guami status to: unavailable')
                            break
        GUAMI_DATABASE_UPDATES += 1
    except Exception as e:
        traceback.print_exc()
        print('Caught exception:\n{}'.format(e))
    message_lock.release()


def get_view_for_amf(amf_alias, expected_param_list=None):
    message_lock.acquire()
    if amf_alias not in GUAMI_DATABASE:
        raise Exception('AMF: {} not in database, current state:\n{}'
                        .format(amf_alias, pprint.pformat(GUAMI_DATABASE)))
    full_database = copy.deepcopy(GUAMI_DATABASE[amf_alias])
    message_lock.release()
    print('Full guami database (based on NG-C messages) for AMF: {}:\n{}'
          .format(amf_alias, pprint.pformat(full_database)))
    if expected_param_list is not None:
        filtered_result = []
        for record in full_database:
            filtered_result.append({})
            for param in expected_param_list:
                filtered_result[-1][param] = record[param]

        return filtered_result
    else:
        return full_database


def get_ip_address_for_created_aliases(amf_alias):
    amf_instances = {elem.network_elem_identifier.alias: elem.network_elem_identifier['ip'] for elem in
                     list(_aliases_registry().values())
                     if ((hasattr(elem, 'network_elem_identifier')) and
                         (elem.network_elem_identifier.network_elem_type == 'AMF'))
                     }
    if amf_alias in amf_instances:
        return list(amf_instances[amf_alias])[0]  # ip is object of Endpoints class, derived from set
    else:
        raise Exception('Found {} instances: {} but not matching given alias: {}'
                        .format(len(amf_instances), pprint.pformat(amf_instances), amf_alias))


def get_view_from_gnb(amf_ip, expected_param_list=None, refresh=False, gnb=1,
                      retrieved_emss_params='amfipaddress,guami'):
    """
    {1: {'SERVEDAMF-1': {'guami': [
                                {'amfpointer': '1',
                                'amfregionid': '1',
                                'amfsetid': '2',
                                'backupamfname': 'amf3',
                                'guamistatus': 'available',
                                'mcc': '311',
                                'mnc': '489',
                                'mnclength': '3'},
                               {'amfpointer': '2',
                                'amfregionid': '1',
                                'amfsetid': '2',
                                'backupamfname': 'amf2',
                                'guamitype': 'mapped',
                                'guamistatus': 'available',
                                'mcc': '311',
                                'mnc': '489',
                                'mnclength': '3'}]},
    'SERVEDAMF-2': {'guami': [{'amfpointer': '2',
                                ....
    """
    if refresh is True:
        print('Running additional discover')
        ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
        ta_emss_inst.discover_bts(bts_id=gnb)
    ret_value = _get_parameters_for_object_type('SERVEDAMF', param_names=retrieved_emss_params)
    gnb_view = {}
    assert gnb in ret_value, 'gNB id: {} not present in returned data:\n{}'.format(gnb, pprint.pformat(ret_value))
    for servedamf in ret_value[gnb]:
        amf_ip_addr = ret_value[gnb][servedamf]['amfipaddress']
        gnb_view[amf_ip_addr] = []
        for guami in ret_value[gnb][servedamf]['guami']:
            gnb_view[amf_ip_addr].append({})
            gnb_view[amf_ip_addr][-1]['region'] = str(guami['amfregionid'])
            gnb_view[amf_ip_addr][-1]['set'] = str(guami['amfsetid'])
            gnb_view[amf_ip_addr][-1]['pointer'] = str(guami['amfpointer'])
            gnb_view[amf_ip_addr][-1]['status'] = str(guami['guamistatus'])
            if 'guamitype' in guami:
                gnb_view[amf_ip_addr][-1]['guami_type'] = str(guami['guamitype'])
            else:
                gnb_view[amf_ip_addr][-1]['guami_type'] = str("not_set")

    print('Got following gnb view across all AMF:\n{}'.format(pprint.pformat(gnb_view)))
    assert amf_ip in gnb_view, 'AMF with name: {} not found in gNB view'.format(amf_ip)
    single_amf_view = copy.deepcopy(gnb_view[amf_ip])
    if expected_param_list is not None:
        filtered_result = []
        for record in single_amf_view:
            filtered_result.append({})
            for param in expected_param_list:
                filtered_result[-1][param] = record[param]
        return filtered_result
    else:
        return single_amf_view


def wait_for_number_of_updates(updates_num, timeout=10):
    updates_num = int(updates_num)
    timeouted = True
    if GUAMI_DATABASE_UPDATES >= updates_num:
        print('Already have: {} updates, not waiting'.format(GUAMI_DATABASE_UPDATES))
        return
    else:
        def _on_timeout():
            print('Timeouted')
        start = time.time()
        timer = threading.Timer(int(timeout), _on_timeout)
        timer.start()
        while timer.is_alive():
            if GUAMI_DATABASE_UPDATES < updates_num:
                time.sleep(0.1)
            else:
                print('Updates arrived')
                timer.cancel()
                timeouted = False
                break
        stop = time.time()
        print('Waited for: {:.4f} s'.format(float(stop - start)))
        if timeouted is True:
            raise Exception('Timeout: Expected updates num: {} did not occur, got only: {}'
                            .format(updates_num, GUAMI_DATABASE_UPDATES))


def clear_updates_counter():
    global GUAMI_DATABASE_UPDATES
    message_lock.acquire()
    GUAMI_DATABASE_UPDATES = 0
    message_lock.release()


def get_wts_guami_parameter_from_input(input_str_or_list_of_str, old_separator="-", new_separator=":", join_sep=","):
    """
    Input line like
    ...   guami:1-1-1,guami_type:native
    return:
        1-1-1 depending on new sep

    Input line like
    ...   guami:1-1-1,guami_type:native
    ...   guami:1-1-2,guami_type:native
    ...   guami:1-1-3,guami_type:native
    return:
        1-1-1,1-1-2,1-2-3 depending on new sep and join sep

    """
    guamis = []
    regexp_string = r'(\d+{}\d+{}\d+)'.format(old_separator, old_separator)
    if not isinstance(input_str_or_list_of_str, list):
        input_str_or_list_of_str = [input_str_or_list_of_str]
    for single_input in input_str_or_list_of_str:
        res = re.findall(regexp_string, single_input)
        assert len(res) == 1, 'Parsed > 1 guamis from single input'
        guamis.append(re.sub(old_separator, new_separator, res[0]))
    ret_val = join_sep.join(guamis)
    print('Returning: {}'.format(ret_val))
    return ret_val


def if_any_guami_guami_type_required_as_not_set(input_str_or_list_of_str):
    """
    Input line like
    ...   guami:1-1-1,guami_type:native
    return:
        guami_index=1 guami_type=native

    Input line like
    ...   guami:1-1-1,guami_type:native
    ...   guami:1-1-2,guami_type:not_set
    ...   guami:1-1-3,guami_type:mapped
    return:
        True or False

    """
    regexp_string = r'guami_type:(\S+)'
    if not isinstance(input_str_or_list_of_str, list):
        input_str_or_list_of_str = [input_str_or_list_of_str]
    for index, single_input in enumerate(input_str_or_list_of_str):
        res = re.findall(regexp_string, single_input)
        assert len(res) == 1, 'Parsed > 1 guami types from single input'
        if res[0] == 'not_set':
            return True
    return False


def get_wts_guami_index_guami_type_from_input(input_str_or_list_of_str):
    """
    Input line like
    ...   guami:1-1-1,guami_type:native
    return:
        guami_index=1 guami_type=native

    Input line like
    ...   guami:1-1-1,guami_type:native
    ...   guami:1-1-2,guami_type:native
    ...   guami:1-1-3,guami_type:mapped
    return:
        guami_index=1 guami_type=native guami_index=2 guami_type=native guami_index=3 guami_type=mapped

    """
    guami_index_param_name = 'guami_index'
    guami_type_param_name = 'guami_type'
    guamis = []
    regexp_string = r'guami_type:(\S+)'
    if not isinstance(input_str_or_list_of_str, list):
        input_str_or_list_of_str = [input_str_or_list_of_str]
    for index, single_input in enumerate(input_str_or_list_of_str):
        res = re.findall(regexp_string, single_input)
        assert len(res) == 1, 'Parsed > 1 guami types from single input'
        guami_index = index + 1
        if res[0] != 'not_set':
            guamis.append("{}={} {}={}".format(guami_index_param_name, guami_index, guami_type_param_name, res[0]))
        else:
            print('Guami_type not set for {}, not adding guami_index in option'.format(single_input))
            print('This will only work when guami type has not been set in first place')
    ret_val = " ".join(guamis)
    print('Returning: {}'.format(ret_val))
    return ret_val


def verify_guamis_in_database(*guami_params, **kwargs):
    """

    """
    supported_options = ['guami', 'status', 'guami_type']
    supported_kwargs = ['skip_check_ngc_view', 'skip_check_gnb_view', 'amf_alias', 'dont_match_guami_type']
    for key in kwargs:
        assert key in supported_kwargs, 'Kwarg: {} not supported, only allowed:\n{}'.format(key, supported_kwargs)
    assert 'amf_alias' in kwargs, 'amf_alias must be supplied as kwarg'
    dont_match_guami_type = True if 'dont_match_guami_type' in kwargs else False
    skip_check_ngc_view = True if 'skip_check_ngc_view' in kwargs and \
                                  _val_to_bool(kwargs['skip_check_ngc_view']) is True else False
    skip_check_gnb_view = True if 'skip_check_gnb_view' in kwargs and \
                                  _val_to_bool(kwargs['skip_check_gnb_view']) is True else False
    guamis_to_verify = []
    guami_to_compare = []
    supplied_options = set()
    for guami_param in guami_params:
        guamis_to_verify.append(dict([guami_options.strip().split(':')
                                for guami_options in guami_param.strip().split(',')]))
        if dont_match_guami_type is True and 'guami_type' in guamis_to_verify[-1]:
            del guamis_to_verify[-1]['guami_type']
            print('Removed guami_type param from comparision')
    for guami_to_verify in guamis_to_verify:
        assert set(list(guami_to_verify.keys())).issubset(set(supported_options)), \
            'Options: {} not supported, only allowed: {}'.format(pprint.pformat(guami_to_verify), supported_options)
        guami_to_compare.append({})
        for option in guami_to_verify:
            if option == 'guami':
                supplied_options.add('region')
                supplied_options.add('set')
                supplied_options.add('pointer')
                guami_to_compare[-1].update(dict(zip(['region', 'set', 'pointer'],
                                                     guami_to_verify['guami'].split('-'))))
            else:
                supplied_options.add(option)
                guami_to_compare[-1][option] = guami_to_verify[option]
    """
    Guami to compare should have the same structure as single view item:
    [ {'region': region_dc, 'set': set_dec, 'pointer': pointer_dec, 'status': 'available', 'guami_type': xxx},
        ...
    ]
    """
    if skip_check_ngc_view is False:
        data_view = get_view_for_amf(amf_alias=kwargs['amf_alias'], expected_param_list=list(supplied_options))
        assert guami_to_compare == data_view, \
            '[{}]: Expected structure:\n{}\ndoes not match database:\n{}'.format(kwargs['amf_alias'],
                                                                                 pprint.pformat(guami_to_compare),
                                                                                 pprint.pformat(data_view))
        print('\n{}\n[{}]: Expected structure:\n{}\nmatched NG link database:\n{}\n{}\n'
              .format('#' * 80,
                      kwargs['amf_alias'],
                      pprint.pformat(guami_to_compare),
                      pprint.pformat(data_view),
                      '#' * 80))
    else:
        print('\nSkip checking NG-C link related messages !!!\n')
    #  gNB comparision part
    if skip_check_gnb_view is False:
        gnb_guami_to_compare = copy.deepcopy(guami_to_compare)
        # TO DO: some mapping actions in case of guami not set or value other
        amf_ip = get_ip_address_for_created_aliases(kwargs['amf_alias'])
        print('Got ip: {} for alias: {}'.format(amf_ip, kwargs['amf_alias']))
        retry_run_with_discover = 3
        sleep_between_discover = 5
        while retry_run_with_discover > 0:
            retry_run_with_discover -= 1
            gnb_view = get_view_from_gnb(amf_ip=amf_ip, expected_param_list=list(supplied_options),
                                         refresh=True)
            try:
                assert gnb_guami_to_compare == gnb_view, \
                    '[{}/{}]: Expected structure:\n{}\ndoes not match database:\n{}'\
                    .format(kwargs['amf_alias'], amf_ip, pprint.pformat(guami_to_compare), pprint.pformat(gnb_view))
                print('\n{}\n[{}/{}]: Expected structure:\n{}\nmatched SERVEDAMF database:\n{}\n{}\n'
                      .format('#' * 80,
                              kwargs['amf_alias'],
                              amf_ip,
                              pprint.pformat(guami_to_compare),
                              pprint.pformat(gnb_view),
                              '#' * 80))
                break
            except Exception as e:
                if retry_run_with_discover > 0:
                    time.sleep(sleep_between_discover)
                else:
                    traceback.print_exc()
                    raise e
    else:
        print('\nSkip checking gNB SERVEDAMF database !!!\n')
