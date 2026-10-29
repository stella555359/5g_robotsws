"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""


def map_single_counter_value_to_any_counter_value(ta5g_pm_counters_comparator_and_value):
    try:
        int(ta5g_pm_counters_comparator_and_value)
        print('Substituting: {} ->  +{}'.format(ta5g_pm_counters_comparator_and_value,
                                                ta5g_pm_counters_comparator_and_value))
        return "+{}".format(ta5g_pm_counters_comparator_and_value)
    except Exception:
        print('Special (non-int) value used, leaving as is')
        return ta5g_pm_counters_comparator_and_value
