from os import walk
from os.path import join
from os.path import exists
try:
    import xml.etree.cElementTree as et
except ImportError:
    import xml.etree.ElementTree as et
import pandas as pd
import argparse


def parse_arguments():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter)
    required_named = parser.add_argument_group('Arguments')
    required_named.add_argument(
        '-ox',
        '--output_xml',
        dest='output_xml',
        help='robot output.xml file with path if not in same folder',
        default='output.xml',
        required=False)
    required_named.add_argument(
        '-rp',
        '--resource_path',
        dest='resource_path',
        help='complete path where resources are located',
        required=True)
    args = parser.parse_args()
    return args.output_xml, args.resource_path


def get_all_files_under(mypath):
    for (dirpath, dirnames, filenames) in walk(mypath):
        return filenames


def get_keywords_in_resource(filename):
    kw_dict = {}
    kw_section = False
    exclusions = (' ', '#', '\t')
    for line in open(filename, 'r'):
        if (kw_section and not line.startswith(exclusions) and line != '\n'):
            kw_dict[line.strip('\n')] = 0
        if '*** Keywords ***' in line:
            kw_section = True
    return kw_dict


def create_dict_of_keywords_in_folder(resource_path):
    keyword_dict = {}
    resource_file_list = get_all_files_under(resource_path)
    for filename in resource_file_list:
        if filename.endswith('.robot'):
            keyword_dict[filename.split('.')[0]] = get_keywords_in_resource(
                join(resource_path, filename))
    return keyword_dict


def update_keyword_counter_dict(kw_library, kw_name, kw_counter_dict):
    if kw_library in kw_counter_dict.keys():
        if kw_name in kw_counter_dict[kw_library].keys():
            kw_counter_dict[kw_library][kw_name] += 1
        else:
            return f'keyword {kw_name} not found in library {kw_library}'
    else:
        # avoid verbose prints related with keywords from known
        # external libraries
        libraries_not_relevant = ['BuiltIn', 'ssh', 'Collections',
                                  'OperatingSystem', 'scf', 'ute_wtssim',
                                  'admin', 'String', 'DateTime', 'gnb_lib',
                                  'gnb_internal', 'pm_internal',
                                  'collect_pm', 'XML', 'pdu',
                                  'pmtocsv', 'testline_info', '']
        if kw_library not in libraries_not_relevant:
            return f'library {kw_library} not found in given resource path'
    return ''


def update_counter_dict_according_to_robot_test(output_xml, kw_counter_dict):
    warning_message_list = []
    if not exists(output_xml):
        print(f'No such file or directory: {output_xml}')
        exit(-1)
    with open(output_xml) as xml_file:
        for event, elem in et.iterparse(xml_file):
            if elem.tag == "kw":
                keyword_name = elem.attrib['name']
                keyword_library = elem.get('library', '')
                warning_message_list.append(update_keyword_counter_dict(
                                                keyword_library,
                                                keyword_name,
                                                kw_counter_dict))
            elem.clear()
    for message in set(warning_message_list):
        print(message)


def prepare_dict_for_pandas(keywords_counter_dict):
    keyword_data = []
    for lib, keywords in keywords_counter_dict.items():
        for keyword_name, number_calls in keywords.items():
            keyword_data.append([keyword_name, lib, number_calls])
    return keyword_data


def main():
    separator = '-----------------------------------------' \
                '-----------------------------------------'
    output_xml, resource_path = parse_arguments()
    print('Robot test output.xml:', output_xml)
    print('Path to Resources:', resource_path)
    print(separator)

    kw_counter_dict = create_dict_of_keywords_in_folder(resource_path)
    update_counter_dict_according_to_robot_test(output_xml, kw_counter_dict)
    keyword_data = prepare_dict_for_pandas(kw_counter_dict)

    # load keyword data to pandas data frame
    kw_df = pd.DataFrame(keyword_data, columns=['keyword', 'library', 'calls'])

    # calculate overall test coverage
    # number of keywords with at least 1 call
    number_of_kw_called = kw_df[kw_df.calls != 0]['calls'].count()
    total_number_kw = len(kw_df)
    test_keyword_coverage_pct = 100 * number_of_kw_called / total_number_kw

    library_complete_overview_report = ''

    # generate individual report per library
    libraries = kw_df['library'].unique()
    pd.set_option('display.max_rows', None)
    pd.set_option('display.max_columns', None)
    for lib in libraries:
        print('Library:', lib)
        lib_df = kw_df[kw_df.library == lib]
        pct_called_kw_in_lib = 100 * \
            lib_df[lib_df.calls != 0]['calls'].count() / len(lib_df)
        library_usage_report = f'{lib} : {round(pct_called_kw_in_lib, 2)} % \n'
        print('coverage:', library_usage_report)
        library_complete_overview_report += '  ' + library_usage_report
        print(lib_df)
        print(separator)

    print(separator)
    print('% of keywords covered in test:',
          round(test_keyword_coverage_pct, 2))
    print('Library coverage overview:')
    print(library_complete_overview_report)
    print(separator)

    # 0 for 100% coverage,1 for less than 10% missing, 2 less than 20% ...
    return (10 - int(test_keyword_coverage_pct / 10))


if __name__ == "__main__":
    exit(main())
