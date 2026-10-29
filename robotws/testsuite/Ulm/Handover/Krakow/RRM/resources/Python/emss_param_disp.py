import pprint
import time
from robot.libraries.BuiltIn import BuiltIn
ACTIVE_EMSS_INSTANCES = []


def get_all_active_emss_instances_with_node_ids(refresh=False):
    global ACTIVE_EMSS_INSTANCES
    if refresh is False and len(ACTIVE_EMSS_INSTANCES):
        print('Getting emss instances from history, found {} instances'.format(
            len(ACTIVE_EMSS_INSTANCES)))
        return ACTIVE_EMSS_INSTANCES
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    a = time.time()
    enb_id_list = ta_emss_inst.get_enb_ids_with_created_emss_instances()
    print('Elapsed after getting enb ids for active emssims: {:.2f} s'.format(
        time.time() - a))
    assert len(
        enb_id_list) > 0, 'EMSS has not active instances. Before running keyword \n' \
                          'setup ALL needed ta_emss instances by setup_emss keyword\n' \
                          'Setup emss       node_id=x'
    ACTIVE_EMSS_INSTANCES = enb_id_list
    print('Getting emss instances from ta_emss database, found {} instances'.format(
        len(ACTIVE_EMSS_INSTANCES)))
    return ACTIVE_EMSS_INSTANCES


def get_parameters_for_object_type(object_type, param_names, node_id=None):
    """

    :param object_type:  NRCELL (without IDs) or NRCELL-1
    :param param_names: lcrId,earfcnDL
    :param node_id: currently only 1 or 2 are supported
    :return:    { 1: {'NRCEL-1': 30}}
    """
    value = {}
    param_names = [p.strip() for p in param_names.strip().split(',')]
    if len(param_names) > 1 and any(['.' in p for p in param_names]):
        raise Exception(
            'You can request only single param if any param contains "."')
    ta_emss_inst = BuiltIn().get_library_instance('ta_emss')
    for active_node_id in get_all_active_emss_instances_with_node_ids(refresh=False):
        try:
            ret = ta_emss_inst.run_emssim_command("disp",
                                                  ["{}".format(str(object_type).upper()),
                                                   "{}".format(" ".join(param_names))],
                                                  bts_id=active_node_id)
            value[int(active_node_id)] = {}
            # e.g. {u'NRCEL_FDD-8-0': {'lcrId': '20200', 'earfcndl': '2200'}}
            for (obj, val) in list(ret['attributes'].items()):
                obj_dict = value[int(active_node_id)].setdefault(str(obj), {})
                obj_dict.update(val)
        except Exception as e:
            print('Got exception: {}, ignoring...'.format(e))
            continue
    print('Found params:\n{}'.format(pprint.pformat(value)))
    if node_id is not None:
        assert int(node_id) in value, 'No data found for node_id: {}'.format(
            node_id)
        print('Returning only data for node_id: {}\n{}'.format(
            node_id, pprint.pformat(value[int(node_id)])))
        return value[int(node_id)]
    return value
