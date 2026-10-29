"""
:copyright: Nokia Networks
:authors:

    Patryk Wojcik   <patryk.wojcik@nokia.com>
    Maciej Majewski <maciej.majewski@nokia.com>

:maintainers:

    Patryk Wojcik   <patryk.wojcik@nokia.com>
    Maciej Majewski <maciej.majewski@nokia.com>

"""

from robot.api import logger
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers

csv_bip = csv_verifiers()


def verify_tadv_in_bip_logs(csv_path, expected_value, diff=1, tc_res=128):
    """
    Function that verifies initialTa and initialUlEcidTAdv from BIP logs to expected value
    +------------------+---------+------------+------------+------------+
    |     Example                                                       |
    +==================+=========+============+============+============+
    | Verify tadv in BIP logs    csv_path=${csv_path}  expected_value=25|
    +------------------+---------+------------+------------+------------+
    :param csv_path:        path to csv file
    :param expected_value:  expected values from BIP logs to which initialTa and initialUlEcidTAdv will be compared
    :param diff:            accepted error in results
    :param tc_res:          Tc resolution for timing advance. 128 Tc resolution for timing advance less than 262144 Tc
                            and 512 Tc for timing advance greater than or equal to 262144 Tc
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    initialTa = csv_bip.filter_csv_by_column_value(
        csv_list=csv_list,
        column_name='UlData_detectedPrachPreambles_t.initialTa',
        condition='==',
        value=expected_value)
    logger.info(f"Number of occurences with UlData_detectedPrachPreambles_t.initialTa=={expected_value} is equal to"
                f" {len(initialTa[1:])}")
    assert len(initialTa[1:]) == 1, f'Only One occurance of UlData_detectedPrachPreambles_t.initialTa' \
                                    f'=={expected_value} should be found'

    initialUlEcidTAdv = csv_bip.filter_csv_by_column_value(
        csv_list=csv_list,
        column_name='UlData_detectedPrachPreambles_t.initialUlEcidTAdv',
        condition='>=',
        value=0)

    logger.info(f'Filtered list={initialUlEcidTAdv}')
    assert len(initialUlEcidTAdv[1:]) == 1, f'Only one occurance of UlData_detectedPrachPreambles_t.' \
                                            f'initialUlEcidTAdv should be found'
    assert tc_res*int(expected_value)*(1+diff/100) >= float(initialUlEcidTAdv[1][-1]) >=\
           tc_res*int(expected_value)*(1-diff/100), f'initialUlEcidTAdv={initialUlEcidTAdv[1][-1]} should be ' \
                                                    f'in range ({tc_res*int(expected_value)*(1+diff/100)}, ' \
                                                    f'{tc_res*int(expected_value)*(1+diff/100)})'
