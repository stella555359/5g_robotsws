"""
        Keywords Purpose:
            Keywords to do the hardxware invetory of RAP

        AUTHOR:
            Pascal Lecuyer      pascal.lecuyer@nokia.com
"""

import re
from robot.api import logger

__version__ = '1.1.1'
__date__ = '12/12/2018'


class hwDetectionZoomFormat(object):

    def define_hw_list_in_zoom_format(self, gnb_type, hw_config):
        RRH_list = []
        FSM_list = []
        FBB_list = []
        RAP_list = []
        NB_FBB_List = {}
        elt_list = []
        # Read HW configuration
        for elt in hw_config.values():
            card_type = elt['unitType']
            if (card_type == 'gnsse') or (card_type == 'fan') or (card_type == 'bp'):
                continue
            unit_type = elt['inventoryUnitType']
            version = elt['versionNumber']
            m = re.search(r"/mz/p/v1/pbts/(?P<rapId>\d+)/bpf/(?P<positionId>\d+)", elt['bpfRef'])
            if m is not None:
                RAP_Id = m.group('rapId')
            else:
                RAP_Id = '0'
            if RAP_Id not in RAP_list:
                RAP_list.append(RAP_Id)
            id = ''
            if card_type == 'fsm':
                id = elt['fsmId']
                if unit_type not in FSM_list:
                    FSM_list.append(unit_type)
            elif card_type == 'fbb':
                id = elt['fbbId']
                if unit_type not in FBB_list:
                    FBB_list.append(unit_type)
                # if not NB_FBB_List.has_key(RAP_Id): # Pyhon 3.7
                if RAP_Id not in NB_FBB_List:
                    NB_FBB_List[RAP_Id] = 1
                else:
                    NB_FBB_List[RAP_Id] += 1
            elif card_type == 'fr':
                id = elt['frId']
                if unit_type not in RRH_list:
                    RRH_list.append(unit_type)
            elt_list.append("z_RAP_Definition %s %s %s %s %s" % (RAP_Id, card_type, unit_type, version, id))
        max = 0
        for nb in NB_FBB_List.values():
            if nb > max:
                max = nb
        # Type of HW configuration
        type_hw = "z_gNB_Type %s_%dRAP%sFBB" % (gnb_type, len(RAP_list), max)
        for fsm in FSM_list:
            type_hw += "_%s" % (fsm)
        for fbb in FBB_list:
            type_hw += "_%s" % (fbb)
        for rrh in RRH_list:
            type_hw += "_%s" % (rrh)
        logger.info(type_hw, html=True, also_console=True)
        # HW Configuraiton detail
        for elt in elt_list:
            logger.info(elt, html=True, also_console=True)
