from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
MODIFY_TL_NAME = [dict(value='1937_ta',
                             dist_name='MRBTS-' + str(tl.gnbs[0].instance_id),
                             p_name='btsName')]

dict_tput_info = dict(ul_tput_peak_all_cells_avg=None, ul_tput_peak_all_cells_max=None,
                      ul_tput_peak_all_cells_min=None, dl_tput_peak_all_cells_avg=None,
                      dl_tput_peak_all_cells_max=None, dl_tput_peak_all_cells_min=None,
                      ul_tput_peak_all_cells_details=None, dl_tput_peak_all_cells_details=None)

UL_TPUT_INI = [{'count': 0, 'average': 0, 'min_time_interval': 1.024, 'minimum': 0, 'peak': 0, 'cellid': 0}]

DL_TPUT_INI = [{'count': 0, 'average': 0, 'min_time_interval': 1.024, 'minimum': 0, 'peak': 0, 'cellid': 0}]
