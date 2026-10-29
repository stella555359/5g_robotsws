from pprint import pformat
from robot.libraries.BuiltIn import logger
from ute_common_abstract_core.message import KeyFindingDict, NotFoundKey


def check_pci_from_get_ue_info(get_ue_info: dict, desired_pci: str):
    """Check if UE has been attached to proper cell (filtered by PCI).

    :param dict get_ue_info: dict returned from ute_ue.get_ue_info KW
    :param str desired_pci:
    :raises ValueError: if UE has not being attached to any CELL
    :raises ValueError: if UE has been attached to different than desired CELL
    """
    logger.debug(pformat(get_ue_info))
    already_attached_pci = get_ue_info.get('cell_info').get('PCID')
    if not already_attached_pci:
        raise ValueError('UE do not attached to any cell, there is no PCI that can be checked!')
    if not str(desired_pci) == already_attached_pci:
        raise ValueError(f'UE should attached to PCI {desired_pci}, '
                         f'but it has been attached to {already_attached_pci} instead!')


def log_ue_info(ue_info: dict, key_list: list[str]):
    info = ''
    logger.debug(pformat(ue_info))
    for key in key_list:
        try:
            info += f"{key}:{str(KeyFindingDict.get_all_values_by_key(ue_info, key)).strip('[]')} "
        except NotFoundKey:
            logger.trace(f"NotFoundKey: {key}")
    logger.info(f"UE connected to {info}", also_console=True)
