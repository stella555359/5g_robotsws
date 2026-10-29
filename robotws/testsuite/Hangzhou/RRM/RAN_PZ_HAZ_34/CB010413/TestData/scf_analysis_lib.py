from robot.libraries.BuiltIn import BuiltIn
from xml.etree import ElementTree as ET

tl = BuiltIn().get_variable_value('${tl}')
vDU_DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
vDU_DN_NRBTS = vDU_DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
VDU_DN_NRDU1 = vDU_DN_NRBTS + '/NRDU-1'


def get_all_channel_groups_under_specific_cell_from_scf(lcr_id, scf_file_path):
    """
    Author: Lingxue Cui
    Get the channel group dist names of specified cell.
    :param lcr_id: lcr id of NRCELL
    :param scf_file_path: file path of vDU scf
    :return: list of the distname of channel groups
       E.G:['MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1',
            'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2',
            'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3',
            'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4',
            'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5',
            'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6']
    """
    tree = ET.parse(scf_file_path)
    root = tree.getroot()

    lcr_id = str(lcr_id)
    dn_lcelnr = vDU_DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + lcr_id

    channel_group_list = []
    for element in root.findall('.//{raml21.xsd}managedObject[@class="com.nokia.srbts.mnl:CHANNELGROUP"]'):
        dn_channel_group = element.attrib['distName']
        if dn_lcelnr in dn_channel_group:
            channel_group_list.append(dn_channel_group)
    return channel_group_list


def get_mapping_relations_between_subcellId_and_rmodIdx(lcr_id, scf_file_path):
    """
    Author: Lingxue Cui
    Get the mapping relations between subcell id and rmod id, antl DN, channel group.
    :param lcr_id: lcr id of NRCELL
    :param scf_file_path: file path of vDU scf
    :return: a dict of mapping relations
        EG:{'0': {'antlDN': ['MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-1',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-2',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-3',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-4',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-1',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-2',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-3',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-4'],
                   'channel_group': 'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1',
                   'rmod_index': '1'},
             '1': {'antlDN': ['MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-1',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-2',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-3',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-4',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-1',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-2',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-3',
                              'MRBTS-37241/EQM-1/APEQM-1/RMOD-2/ANTL-4'],
                   'channel_group': 'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2',
                   'rmod_index': '2'}}
    """
    tree = ET.parse(scf_file_path)
    root = tree.getroot()

    lcr_id = str(lcr_id)
    # dn_lcelnr = vDU_DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + lcr_id
    mapping_relation = {}

    # channel_group_list = []
    # for element in root.findall('.//{raml21.xsd}managedObject[@class="com.nokia.srbts.mnl:CHANNELGROUP"]'):
    #     dn_channel_group = element.attrib['distName']
    #     if dn_lcelnr in dn_channel_group:
    #         channel_group_list.append(dn_channel_group)
    channel_group_list = get_all_channel_groups_under_specific_cell_from_scf(lcr_id=lcr_id, scf_file_path=scf_file_path)

    for subcell_id, channel_group_id in enumerate(channel_group_list):
        ant_list = []
        for element in root.findall('.//{raml21.xsd}managedObject[@class="com.nokia.srbts.mnl:CHANNEL"]'):
            if channel_group_id in element.attrib['distName']:
                antlDN = element.find('.//{raml21.xsd}p[@name="antlDN"]').text
                ant_list.append(antlDN)
        dn_rmod = ant_list[0].rsplit('/', 1)[0]
        rmod_index = dn_rmod.rsplit('-', 1)[-1]
        dict_subcell = dict(rmod_index=rmod_index, antlDN=ant_list, channel_group=channel_group_id)
        subcell_id = str(subcell_id)
        mapping_relation[subcell_id] = dict_subcell

    print("the relation between subcell id and rmod is {}".format(mapping_relation))
    return mapping_relation
