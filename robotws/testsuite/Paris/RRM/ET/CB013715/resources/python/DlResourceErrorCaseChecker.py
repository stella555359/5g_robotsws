import logging
import BitsetAlgorithms
# from testsuite.Paris.RRM.ET.resources.TRF.python.tools import calculate_ratio_bits_1
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html, \
    display_df_as_table
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
pd = None


def sharing_ratio(allocated_normal_subframes, fixed_mbsfn_pattern):
    nbr_of_bits = BitsetAlgorithms.calculate_nbr_of_bits_set_for_union(allocated_normal_subframes,
                                                                       fixed_mbsfn_pattern)
    print(f"len allocated_normal_subframes is {len(allocated_normal_subframes)}")
    print(f"nbr_of_bits is {nbr_of_bits} and len fixed_mbsfn_pattern is {len(fixed_mbsfn_pattern)}")
    return BitsetAlgorithms.calculate_ratio_from_nbr_of_bits_set(float(nbr_of_bits), len(fixed_mbsfn_pattern))


def is_slot_based_ratio_in_range(slot_based_ratio, min_nr_dss_ratio, max_nr_dss_ratio):
    min_ratio = int(min_nr_dss_ratio)
    max_ratio = int(max_nr_dss_ratio)
    in_range = (int(slot_based_ratio) >= min_ratio) and (int(slot_based_ratio) <= max_ratio)
    if not in_range:
        print(f"slotBasedRatio: {slot_based_ratio}, lteNrDssDlRatio(min: {min_ratio}, max: {max_ratio})")
    return in_range


def check_allocation_in_range_when_needed(allocated_normal_subframes,
                                          dss_fixed_mbsfn_pattern,
                                          min_nr_dss_ratio,
                                          max_nr_dss_ratio):
    ratio = sharing_ratio(allocated_normal_subframes, dss_fixed_mbsfn_pattern)
    return is_slot_based_ratio_in_range(ratio, min_nr_dss_ratio, max_nr_dss_ratio), ratio


def reverse_bits(binary_str):
    allocated_normal_subframes = binary_str.replace('-', '')
    return allocated_normal_subframes[::-1]


def reverse_bits_pattern_from_crmsim_and_calculate_ratio(allocated_normal_subframes_str, dss_fixed_mbsfn_pattern):
    allocated_normal_subframes = allocated_normal_subframes_str.replace('-', '')
    print(f"{allocated_normal_subframes}")
    allocated_normal_subframes_reverse = reverse_bits(allocated_normal_subframes)
    print(f"{allocated_normal_subframes_reverse}")
    print(f"{dss_fixed_mbsfn_pattern}")
    ratio = sharing_ratio(allocated_normal_subframes_reverse, dss_fixed_mbsfn_pattern)
    print(f"ratio is {ratio}")
    return ratio


def convert_dl_allocation_to_df_with_row(allocated_normal_subframes, dss_fixed_mbsfn_pattern,
                                         min_nr_dss_ratio=0, max_nr_dss_ratio=0, dl_ratio=0,
                                         write_to_pickle=False, target_path=None):
    """ This function converts the DL allocation info output from JSON file into
        a data frame
    """
    # for evaluation dont cut df prints
    pd.set_option('display.max_columns', None)

    # Initialize an empty list to store the row data
    data_rows = []

    # Initialize an empty set to store the unique column names
    column_names = set()

    allocated_normal_subframes_1 = allocated_normal_subframes.replace('-', '')
    print(f"{allocated_normal_subframes_1}")
    allocated_normal_subframes_reverse = reverse_bits(allocated_normal_subframes_1)

    # Create a dictionary for the row data
    row_data = {
        'allocated_normal_subframes': allocated_normal_subframes_reverse,
        'dss_fixed_mbsfn_pattern': dss_fixed_mbsfn_pattern,
        'min_nr_dss_ratio': min_nr_dss_ratio,
        'max_nr_dss_ratio': max_nr_dss_ratio,
        'ratio': dl_ratio
    }
    data_rows.append(row_data)

    # Create a new DataFrame with the desired structure
    column_names.update(set(row_data.keys()))
    df = pd.DataFrame(data_rows, columns=list(column_names))

    if write_to_pickle and target_path:
        df.to_pickle(target_path)

    display_df_as_html(df)
    display_df_as_table(df)

    return df


def convert_dl_allocation_to_df(allocated_normal_subframes, dss_fixed_mbsfn_pattern,
                                min_nr_dss_ratio=0, max_nr_dss_ratio=0, dl_ratio=0,
                                write_to_pickle=False, target_path=None):
    """ This function converts the DL allocation info output into
        a data frame
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()

    # for evaluation dont cut df prints
    pd.set_option('display.max_columns', None)
    pd.set_option('display.float_format', lambda x: '%.0f' % x)  # Disable scientific notation

    # Initialize an empty list to store the row data
    data_rows = []

    # Initialize an empty set to store the unique column names
    column_names = set()

    allocated_normal_subframes_1 = allocated_normal_subframes.replace('-', '')
    print(f"{allocated_normal_subframes_1}")
    allocated_normal_subframes_reverse = reverse_bits(allocated_normal_subframes_1)

    # Create a dictionary for the row data
    row_data = {
        'allocated_normal_subframes': allocated_normal_subframes_reverse,
        'dss_fixed_mbsfn_pattern': dss_fixed_mbsfn_pattern,
        'min_nr_dss_ratio': min_nr_dss_ratio,
        'max_nr_dss_ratio': max_nr_dss_ratio,
        'ratio': dl_ratio
    }
    # Append each parameter as a separate row
    data_rows.append({'Parameter': 'allocated_normal_subframes(CRM)', 'Value': allocated_normal_subframes})
    data_rows.append({'Parameter': 'allocated_normal_subframes(80Bits)', 'Value': allocated_normal_subframes_reverse})
    data_rows.append({'Parameter': 'dss_fixed_mbsfn_pattern(80Bits)', 'Value': dss_fixed_mbsfn_pattern})
    data_rows.append({'Parameter': 'min_nr_dl_dss_ratio(%)', 'Value': min_nr_dss_ratio})
    data_rows.append({'Parameter': 'max_nr_dl_dss_ratio(%)', 'Value': max_nr_dss_ratio})
    data_rows.append({'Parameter': 'dl_ratio(%)', 'Value': dl_ratio})

    # Create a new DataFrame with the desired structure
    # Convert the dictionary to a DataFrame and transpose it
    df = pd.DataFrame(data_rows)

    if write_to_pickle and target_path:
        df.to_pickle(target_path)

    df = df.astype(str)
    display_df_as_html(df)
    # print(f"df={df}")
    display_df_as_table(df)

    return df


def main_test_for_robot():
    global pd
    pd = pandas_gate.install_and_import_pandas()
    allocated_normal_subframes_95 = '10111110111111111111101111101111111111111011111011111111111110111110111111111111'
    allocated_normal_subframes = '10111100111111111111101111001111111111111011110011111111111110111100111111111111'
    dss_fixed_mbsfn_pattern = '00000000000000000010000000000000000000100000000000000000001000000000000000000010'
    min_nr_dss_ratio = 30
    max_nr_dss_ratio = 90
    is_slot_based_ratio_in_range, ratio = check_allocation_in_range_when_needed(allocated_normal_subframes,
                                                                                dss_fixed_mbsfn_pattern,
                                                                                min_nr_dss_ratio, max_nr_dss_ratio)
    print(f"is_slot_based_ratio_in_range is {is_slot_based_ratio_in_range}")
    print(f"ratio is {ratio}")

    allocated_normal_subframes = '1011111011-1111101111-1011111011-1110111111-' \
                                 '1011111011-1101111111-1011111011-1111011111'
    allocated_normal_subframes_2 = '10111110111111101111101111101111101111111011111011110111111110111110111111011111'
    ratio = reverse_bits_pattern_from_crmsim_and_calculate_ratio(allocated_normal_subframes, dss_fixed_mbsfn_pattern)
    df = convert_dl_allocation_to_df(allocated_normal_subframes=allocated_normal_subframes,
                                     dss_fixed_mbsfn_pattern=dss_fixed_mbsfn_pattern,
                                     min_nr_dss_ratio=min_nr_dss_ratio,
                                     max_nr_dss_ratio=max_nr_dss_ratio,
                                     dl_ratio=ratio)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    main_test_for_robot()
