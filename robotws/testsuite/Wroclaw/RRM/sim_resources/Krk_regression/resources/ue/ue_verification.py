import logging
from taf.rfrl.utilities.robot.general import get_builtin_instance


def verify_ue_is_attached_to_proper_bts_and_cell(bts_id, cell_id, ue_alias='UE', cell_version='E-UTRAN'):
    ue = get_builtin_instance('ue')
    ue.validate_ue_info(ue_alias, info='CELL_ID', expected_value=cell_id)
    attached_cell_id = ue.get_ue_info(ue_alias, 'CELL_ID')

    if cell_version == 'E-UTRAN':
        bts_cell_based = (int(attached_cell_id) - 1) / 256
    elif cell_version == 'NR':
        bts_cell_based = (int(attached_cell_id) - 1) / 16
    else:
        raise Exception('Cell version: "{}" not supported'.format(cell_version))
    if int(bts_cell_based) == int(bts_id):
        logging.info('UE is in correct cell ID: {} and eNB: {}'.format(attached_cell_id, bts_cell_based))
    else:
        ue_info = ue.get_ue_info(ue_alias, info_name='CELL_INFO')
        raise Exception('UE attached to wrong BTS: {}, DETAILS: {}'.format(bts_cell_based, ue_info))
