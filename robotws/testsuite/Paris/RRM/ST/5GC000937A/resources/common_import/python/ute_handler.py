"""
:author: ULM
"""

from qualcomm import create_qualcomm_ue_configuration
from viavi import create_viavi_ue_configuration


def create_ue_configuration(config, tl, ue_id, ue_type):
    """Author: Jing Liang
    :param: config : must be ${ABSTRACT_LIB_CONFIG}
    :param: tl : must be ${tl}
    :param  ue_id : the ID of UE, Integer or String
    :param  ue_type : string, qualcomm / viavi / etc """
    if ue_type == 'qualcomm':
        return create_qualcomm_ue_configuration(config, tl, ue_id)
    if ue_type == 'viavi':
        return create_viavi_ue_configuration(config, tl, ue_id)
    return config
