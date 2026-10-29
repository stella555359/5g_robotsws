# TODO get cell ids automatically from BTS configuration(cell type param)

_pcell_id = ['NRCELL-411']
_ul_scell_ids = ['NRCELL-412', 'NRCELL-413', 'NRCELL-414']
_dl_scell_ids = ['NRCELL-412', 'NRCELL-413', 'NRCELL-414', 'NRCELL-415', 'NRCELL-416', 'NRCELL-417', 'NRCELL-418']

ul_counters_verification_rules = {
    'step_4a': {
        'counters': ['M55118C02005', 'M55118C03005'],
        'cells': _pcell_id,
        'tolerance': 0
    },
    'step_4b1': {
        'counters': ['M55118C04005'],
        'cells': _pcell_id,
        'tolerance': 1
    },
    'step_4b2': {
        'counters': ['M55118C05005'],
        'cells': _ul_scell_ids,
        'tolerance': 1
    },
    'step_4c': {
        'counters': ['M55316C02001'],
        'cells': _pcell_id,
        'tolerance': 1
    },
    'step_4d': {
        'counters': ['M55316C04003'],
        'cells': _pcell_id,
        'tolerance': 1
    },
    'step_4e': {
        'counters': ['M55316C06003'],
        'cells': _pcell_id,
        'tolerance': 0
    }
}


dl_counters_verification_rules = {
    'step_4a': {
        'counters': ['M55118C02012', 'M55118C03012'],
        'cells': _pcell_id,
        'tolerance': 0
    },
    'step_4b1': {
        'counters': ['M55118C04012'],
        'cells': _pcell_id,
        'tolerance': 1
    },
    'step_4b2': {
        'counters': ['M55118C05012'],
        'cells': _dl_scell_ids,
        'tolerance': 1
    },
    'step_4c': {
        'counters': ['M55316C02000'],
        'cells': _pcell_id,
        'tolerance': 1
    },
    'step_4d': {
        'counters': ['M55316C03007'],
        'cells': _pcell_id,
        'tolerance': 1
    },
    'step_4e': {
        'counters': ['M55316C05007'],
        'cells': _pcell_id,
        'tolerance': 0
    }
}


def get_counters_based_on_verification_rules(verification_rules):
    counters = []
    for rule in verification_rules.values():
        counters.extend(rule['counters'])
    return counters


ul_counters = get_counters_based_on_verification_rules(ul_counters_verification_rules)
dl_counters = get_counters_based_on_verification_rules(dl_counters_verification_rules)
