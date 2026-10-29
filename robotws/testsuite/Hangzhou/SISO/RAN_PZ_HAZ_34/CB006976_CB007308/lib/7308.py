def check_special_condition(version_flag, measure_type):
    condition = 0
    if version_flag == 1:
        if measure_type == 'SBTS_SFP_RMOD':
            condition = 1
    return condition
