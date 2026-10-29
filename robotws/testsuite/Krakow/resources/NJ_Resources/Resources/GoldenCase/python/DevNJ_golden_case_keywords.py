import taf.ul.sc.tl_config as tl_config
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SCF_Parser_Keywords import DevNJ_SCF_Parser_Keywords
from pprint import pprint


def rmod_index_and_rmod_id_mapping(scf_file, rmod='HUBMOD_R', rat='5g'):
    """
    Main Function:
        This function is get asirmod id/hubmod id -> hub device index(__init__.py)

    Arguments:
        :param scf_file
        :param rmod: HUBMOD_R or asir scf_file and ASIRMOD_R for sbts scf_file
        :param rat: used for distinguish 5g or 4g, since in __init__.py hubmod device index
                    have different path for 4g and 5g

    Return Value:
        :return rmod_id_index_mapping_dict, example:{rmod_id: rmod_index}

     Version:
            | Author | Version | Delivery Date | Comments |
            | cuicuiw | 0.0.1 | 2022/06/13 | First draft version |
    """

    new_obj = DevNJ_SCF_Parser_Keywords()
    new_obj.load(scf_file)
    hub_info_list = new_obj.scf_filter.filter({'class': ':{}$'.format(rmod)}).project(
        display_keys=['configDN', 'serialNumber']).mo_list()

    rmod_id_sn_mapping = {}
    for hub in hub_info_list:
        rmod_id_sn_mapping[hub.get('configDN').split('-')[-1]] = hub.get('serialNumber')
    pprint(rmod_id_sn_mapping)

    rmod_index_sn_mapping = {}
    if rat.lower() == '5g':
        for ru in tl_config.tl.gnbs[0].dus[0].rus:
            rmod_index_sn_mapping[tl_config.tl.gnbs[0].dus[0].rus.index(ru)] = ru.serial_number
    else:
        for ru in tl_config.tl.enbs[0].rms:
            rmod_index_sn_mapping[tl_config.tl.enbs[0].rms.index(ru)] = ru.serial_number

    pprint(rmod_index_sn_mapping)

    rmod_id_index_mapping_dict = {}
    for k_id, v_id in rmod_id_sn_mapping.items():
        for k_index, v_index in rmod_index_sn_mapping.items():
            if v_id == v_index:
                rmod_id_index_mapping_dict[k_id] = k_index

    return rmod_id_index_mapping_dict


def get_bts_mode():
    """
    Main Function:
        This function is to get the BTS mode, according to the tl_config in __init__.py.
    """
    bts_mode = None
    if tl_config.tl.gnbs is None and tl_config.tl.enbs is not None:
        bts_mode = 'LTE'
    elif tl_config.tl.gnbs is not None and tl_config.tl.enbs is None:
        bts_mode = '5GSA'
    else:
        bts_mode = '5GNSA'
    return bts_mode
