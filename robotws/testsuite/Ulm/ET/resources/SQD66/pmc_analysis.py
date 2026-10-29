# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd66
# Team: 'SqdGp66'
# Email: 'I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging

import pandas as pd

# ET or Feature Specific Libraries:
from testsuite.Ulm.resources.Common.python.pmcounters import compare_values
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html


@log_begin_end_func_name
def analyze_pmc(actual_values, expected_values, rel_tol=0, abs_tol=0, description=None):
    """

    The analyze_pmc function is designed to compare actual values against expected values, taking into account
    relative and absolute tolerances. It generates a summary of the comparison results, optionally including
    descriptions for each value, and displays the results in a formatted HTML table.

    :param actual_values: A dictionary containing the actual values to be compared. Keys correspond to identifiers
                          for each value.
    :param expected_values: A dictionary containing the expected values for comparison. Keys should
                            match those in actual_values.
    :param rel_tol: (Optional) A float representing the relative tolerance for the comparison. Default is 0.
    :param abs_tol: (Optional) A float representing the absolute tolerance for the comparison. Default is 0.
    :param description: (Optional) A dictionary containing descriptions for each value. Keys should match those in
                        actual_values and expected_values.


    Output: The function does not return any value but displays the comparison results in HTML format using
    display_df_as_html. If any comparisons fail (i.e., the result is 'Failed'), the function logs the failing
    counters and raises an exception.

    """

    summary = {}
    for x in expected_values:
        result = compare_values(
            actual_values[x], expected_values[x], rel_tol, abs_tol)
        # Include description if provided
        if description:
            summary.update({x: [expected_values[x], actual_values[x], rel_tol, abs_tol, result, description[x]]})
        else:
            summary.update({x: [expected_values[x], actual_values[x], rel_tol, abs_tol, result]})

    summary = sorted(summary.items())
    sorted_summary = {}
    for key, value in summary:
        sorted_summary[key] = value

    # Adjust columns based on whether description is included
    columns = ['Expected', 'Actual', 'Rel. Tol.', 'Abs. Tol.', 'Result']
    if description:
        columns.append('Description')

    result_df = pd.DataFrame.from_dict(sorted_summary, orient='index', columns=columns)
    logging.info('Show all counter which are being verified')
    display_df_as_html(result_df)

    failing_rows = result_df[(result_df['Result'] == 'Failed')]
    if len(failing_rows) != 0:
        logging.info('Following counters did not meet tolerance')
        display_df_as_html(failing_rows)
        raise Exception('Some counters did not meet tolerance')
