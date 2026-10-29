_counters_to_verify = [
    # "M40004C2", # not visible - need to enable some feature?
    "M40003C2",
    "M40002C1",
    "M40003C4"
]
counters_to_verify = {counter: {} for counter in _counters_to_verify}

test_model_params_load10 = [
    {
        'dist_name': 'NRCELL-1',
        'test_model': 'E-TM1.1.ETSI',  # sprawdzic czy jest supportowany prze report EE
        # 'p_max': 39,
        # 'load_type': 'slotWiseLoad',
        'load_level': 'load_10'
    }
]

test_model_params_load30 = [
    {
        'dist_name': 'NRCELL-1',
        'test_model': 'NR-FR1-TM1.1.ETSI',
        'p_max': 39,
        'load_type': 'slotWiseLoad',
        'load_level': 'load_30_medium'
    }
]

test_model_params_load50 = [
    {
        'dist_name': 'NRCELL-1',
        'test_model': 'NR-FR2-TM1.1.ETSI',  # sprawdzic czy jest supportowany prze report EE
        'p_max': 18,
        'load_type': 'slotWiseLoad',
        'load_level': 'load_50_busy_hour'
    }
]

test_model_params_load70 = [
    {
        'dist_name': 'NRCELL-0',
        'test_model': 'NR-FR1-TM1.1.ETSI',
        'p_max': 17,
        'load_type': 'slotWiseLoad',
        'load_level': 'load_70'
    }
]

test_model_params_idle = [
    {
        'dist_name': 'NRCELL-0',
        'test_model': 'NR-FR1-IdleActive',  # sprawdzic czy jest supportowany prze report EE
        'p_max': 17,
        # 'load_type': 'slotWiseLoad',
        # 'load_level': 'load_70'
    }
]
