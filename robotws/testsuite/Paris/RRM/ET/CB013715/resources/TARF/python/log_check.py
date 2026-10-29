import re
import logging

from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html, \
    display_df_as_table

pd = None


def verify_sequence_in_log(ueid, contents, *patternList):
    # Initialize an empty list to store the unique column names
    column_names = []

    def add_column_name(name):
        if name not in column_names:
            column_names.append(name)

    if len(patternList) == 0:
        raise AssertionError("Empty patternlist")
    pd.set_option('display.max_columns', None)
    # Initialize an empty list to store the row data
    data_rows = []
    row_data = {}
    notFoundList = list(patternList)
    contents = contents.split('\n')
    row_data['UeId'] = ueid
    add_column_name('UeId')
    for line in contents:
        if len(notFoundList) != 0:
            pattern = notFoundList[0]
            add_column_name(pattern)
            row_data[pattern] = 'SEQUENCE NOT PRESENT'
            result = find_match(line, pattern)
            if result:
                logging.info("Pattern '{}' found in line {}".format(
                    pattern, str(contents.index(line) + 1)))
                notFoundList.pop(0)
                row_data[pattern] = 'SEQUENCE PRESENT'
        else:
            break
    data_rows.append(row_data)
    # Create a new DataFrame with the desired structure
    new_df = pd.DataFrame(data_rows, columns=list(column_names))
    display_df_as_table(new_df)
    display_df_as_html(new_df)
    if len(notFoundList) != 0:
        raise AssertionError("Following pattern was not found '{}', Number {}".
                             format(notFoundList[0], len(patternList)-len(notFoundList)+1))


def find_match(line, pattern):
    p = re.search(pattern, line, re.IGNORECASE)
    if p:
        return p.group()
    return None


def test_find_match():
    file_path = '/home/ute/csamson/7-20-UTE5GCLASSTL116/tools_for-vm-ute/TLConfig/CrtResults_20250608_150628/' \
                'CB013715_X_template_test_SA_CA/Rrc_after_A1_based_scell_addition_UE_1.log'
    patternlist = ['sCellToAddModList', 'sCellIndex 1', 'physCellId 50', 'downlinkConfigCommon', 'uplinkConfigCommon']
    global pd
    pd = pandas_gate.install_and_import_pandas()
    # Open the file in read mode
    with open(file_path, 'r') as file:
        contents = file.read()
    verify_sequence_in_log(1, contents, *patternlist)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    test_find_match()
