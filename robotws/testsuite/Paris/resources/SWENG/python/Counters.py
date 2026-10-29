"""
PM Counter management utilities for Robot Framework tests.

This module consolidates PM counter analysis functionality previously
split across SWENG/Pm/Python/getpmc.py and tools.py.
"""
from taf.analyzer.pmcounter import PMCounterLogReader
from taf.analyzer.pmcounter import interface
import logging
import os
import re
import glob
import datetime
from robot.libraries.BuiltIn import BuiltIn


# ============================================================================
# PM Counter Value Extraction Functions (from getpmc.py)
# ============================================================================

def get_counter_values_from_dir(pi_dir, object_name, counter_name, object_id=1):
    pi_file_pattern = "*PM*.xml"
    logging.debug("reading counter {} values from {}-{} in {}/{}".format(counter_name,
                                                                         object_name,
                                                                         object_id,
                                                                         pi_dir,
                                                                         pi_file_pattern))
    values_list = []
    for log_entry in PMCounterLogReader.from_dir(pi_dir, file_pattern=pi_file_pattern):
        values_list.extend(log_entry.pm_setup.xpath("//{object_name}[@id='{object_id}']//@{pi_name}"
                                                    .format(object_name=object_name,
                                                            object_id=object_id,
                                                            pi_name=counter_name)))
    return values_list


def get_latest_single_counter_value(pm_file, counter_name):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))

        # Flatten all values with their dates using generator expression
        all_values = (
            (str(pi_date), pi_value)
            for pi_dict in pi_dict_values_list
            for pi_date, pi_dict_value in pi_dict.items()
            for pi_xpath_value in pi_dict_value.values()
            for pi_value in pi_xpath_value.values()
        )

        # Get max by date in single pass
        latest_pi_date, latest_counter = max(all_values, key=lambda x: x[0], default=("", ""))

        if latest_counter:
            print("Counter {} extracted from date {} : {}".format(counter_name, latest_pi_date, latest_counter))
        return str(latest_counter)
    except Exception as e:
        print(e)
    return ""


def get_earliest_single_counter_value(pm_file, counter_name):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))

        # Flatten all values with their dates using generator expression
        all_values = (
            (str(pi_date), pi_value)
            for pi_dict in pi_dict_values_list
            for pi_date, pi_dict_value in pi_dict.items()
            for pi_xpath_value in pi_dict_value.values()
            for pi_value in pi_xpath_value.values()
        )

        # Get min by date in single pass
        earliest_pi_date, earliest_counter = min(all_values, key=lambda x: x[0], default=("", ""))

        if earliest_counter:
            print("Counter {} extracted from date {} : {}".format(counter_name, earliest_pi_date, earliest_counter))
        return str(earliest_counter)
    except Exception as e:
        print(e)
    return ""


def get_latest_single_counter_value_with_CellID(pm_file, counter_name, cell_id):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))

        cell_id_int = int(cell_id)

        # Flatten and filter by cell_id in single pass
        matching_values = (
            (str(pi_date), pi_value)
            for pi_dict in pi_dict_values_list
            for pi_date, pi_dict_value in pi_dict.items()
            for pi_xpath_value in pi_dict_value.values()
            for pi_key_xpath, pi_value in pi_xpath_value.items()
            if extractId(pi_key_xpath) and int(extractId(pi_key_xpath)) == cell_id_int
        )

        # Get max by date
        latest_pi_date, latest_counter = max(matching_values, key=lambda x: x[0], default=("", ""))

        if latest_counter:
            print("Counter {} extracted from date {} : {}".format(counter_name, latest_pi_date, latest_counter))
        return str(latest_counter)
    except Exception as e:
        print(e)
    return ""


def get_sum_of_counter_values_with_cellid(pm_file, counter_name, cell_id):
    try:
        file_path = os.path.split(pm_file)
        pi_dict_values_list = interface.pmcounter.get_pi_value(pi_list=[counter_name],
                                                               pi_dir=file_path[0],
                                                               pi_file_pattern=file_path[1])
        print("matching counters: {}".format(pi_dict_values_list))

        # Flatten, filter, and sum in single pass using generator expression
        sum_retrieved = sum(
            int(pi_value)
            for pi_dict in pi_dict_values_list
            for pi_dict_value in pi_dict.values()
            for pi_xpath_value in pi_dict_value.values()
            for pi_key_xpath, pi_value in pi_xpath_value.items()
            if pi_value and pi_key_xpath.split("/")[-1].split("-")[1] == cell_id
        )

        print("6_xxx_final_sum_retrieved: {}".format(sum_retrieved))
        return str(sum_retrieved)
    except Exception as e:
        print(e)
    return ""


def fetch_from_file_cell_counter_value(pm_file, counter_name, cell_id=1, index=0):
    return fetch_from_file_counter_value_by_object(pm_file, "NRCELL", counter_name, cell_id, index)


def fetch_from_file_all_cell_counters(pm_file, cell_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = fetch_from_file_cell_counter_value(pm_file,
                                                                          counter_name,
                                                                          cell_id,
                                                                          index)
    return counter_values


def fetch_from_file_counter_value_by_object(pm_file,
                                            object_name,
                                            counter_name,
                                            object_id=1,
                                            index=0):
    logging.debug("pm_file : {} object_name : {} counter_name : {} object_id : {} index : {}".format(
        pm_file, object_name, counter_name, object_id, index))
    pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".format(object_name=object_name,
                                                                            object_id=object_id,
                                                                            counter_name=counter_name)
    with open(pm_file, "rb") as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            try:
                return log_entry.pm_setup.xpath(pm_xpath)[index]
            except IndexError as e:
                return ""
        raise AssertionError('Counter Value {} is not present for {} in {}'.format(counter_name,
                                                                                   object_name,
                                                                                   pm_file))


def fetch_from_file_counter_values_by_object(pm_file, object_name, counter_name, object_id=1):
    logging.debug("pm_file : {} object_name : {} counter_name : {} object_id : {}".format(pm_file,
                                                                                          object_name,
                                                                                          counter_name,
                                                                                          object_id))
    pm_xpath = "//{}[@id='{}']//@{}".format(object_name, object_id, counter_name)
    with open(pm_file, "rb") as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            return log_entry.pm_setup.xpath(pm_xpath)


def fetch_from_file_counter_latest_values_by_object(pm_file,
                                                    object_name,
                                                    counter_name,
                                                    object_id=1):
    logging.debug("pm_file : {} object_name : {} counter_name : {} object_id : {}".format(pm_file,
                                                                                          object_name,
                                                                                          counter_name,
                                                                                          object_id))
    pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".format(object_name=object_name,
                                                                            object_id=object_id,
                                                                            counter_name=counter_name)
    with open(pm_file, "rb") as pm_file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[pm_file_obj]):
            val_lis = log_entry.pm_setup.xpath(pm_xpath)
            logging.debug("val_lis : {}".format(val_lis))
            val_lis.reverse()
            logging.debug(" val_lis_reverse : {} ".format(val_lis))
            try:
                logging.debug(" val_lis_reverse0 : {}".format(val_lis[0]))
                return val_lis[0]
            except IndexError as e:
                return ""
        raise AssertionError('Counter Value {} is not present for {} in {}'.format(counter_name,
                                                                                   object_name,
                                                                                   pm_file))


def fetch_from_file_all_counters_by_object(pm_file, object_name, object_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = fetch_from_file_counter_value_by_object(pm_file,
                                                                               object_name,
                                                                               counter_name,
                                                                               object_id,
                                                                               index)
    return counter_values


def extractId(pname):
    idExtract = None
    m1 = re.match(r".*NRCELL-(\d\d?)", pname)
    if m1:
        idExtract = m1.group(1)
    return idExtract


# ============================================================================
# PM File Utilities (from tools.py)
# ============================================================================

def get_latest_pm_file(pm_files_path):
    """ This function takes the PM_Files Path and returns the latest PM XML file.
    """
    pm_files_path_actual = os.path.join(pm_files_path,
                                        "pm_files/")
    assert os.path.isdir(pm_files_path_actual), "PM Folder not present in directory"
    pm_files = [file for pattern in ('{pm_path}*.xml', '{pm_path}*.xml.gz')
                for file in glob.iglob(pattern.format(pm_path=pm_files_path_actual))]
    try:
        return os.path.join(pm_files_path_actual, sorted(pm_files, key=sort_by_date_time)[-1])
    except IndexError as e:
        return ""
    raise AssertionError('No PM xml found in {} '.format(pm_files_path))


def sort_by_date_time(pm_file_name):
    """ The PM file name is in the format /PM.BTS-72.20191017.120000.ANY.xml
    We are splitting by "." and returning the date and time fields which are index
    This will be used by the key function to sort the
    input file list.
    """
    pm_file_fields = pm_file_name.split(".")
    return pm_file_fields[-4], pm_file_fields[-3]


def get_log_path():
    log_path = get_builtin_value('LOG_PATH')
    if log_path is None:
        log_path = os.path.join(get_builtin_value('OUTPUT_DIR'), 'Logs/{}'.format(datetime.datetime.now().
                                                                                  strftime("%Y%m%d%H%M%S%f")))
    if not os.path.exists(log_path):
        os.makedirs(log_path)
    temp_log_path = os.path.join(log_path, 'tmp')
    if not os.path.exists(temp_log_path):
        os.makedirs(temp_log_path)
    return log_path


def get_temp_log_path():
    temp_log_path = get_builtin_value('TEMP_PATH')
    if temp_log_path is None:
        temp_log_path = '/tmp'
        if not os.path.exists(temp_log_path):
            os.makedirs(temp_log_path)
    return temp_log_path


def get_difference_between_lists(first_list, second_list):
    """
    Returns the list of items that are not present in first_list
    :param first_list: The list with which the comparison is going to be made against
    :param second_list: The new items in this list which are not present in first_list needs to be found
    :return: List of items that are not present in first_list
    """
    return list(set(second_list).difference(set(first_list)))


def get_builtin_value(variable_name):
    """Helper function to get Robot Framework built-in variable value"""
    try:
        return BuiltIn().get_variable_value('${%s}' % variable_name)
    except Exception:
        return None


# ============================================================================
# PM Post-Processing Functions (Python replacement for shell scripts)
# ============================================================================

def remove_old_pm_files(pm_dir):
    """
    Remove old PM files, keeping only the latest ones based on timestamp.
    Python replacement for fic_rm.sh.

    Args:
        pm_dir: Directory containing PM files (A*.gz or A*.xml files)

    Returns:
        str: Latest date found in format used for filtering
    """
    import gzip
    import shutil

    if not os.path.isdir(pm_dir):
        raise ValueError(f"Directory {pm_dir} does not exist")

    # Get all A* files
    all_files = glob.glob(os.path.join(pm_dir, "A*"))
    if not all_files:
        logging.info("No PM files starting with 'A' found in {}".format(pm_dir))
        return ""

    # Extract dates from filenames (format: A<date1>-<date2>+...)
    # Date format in filename: YYYYMMDD.HHMM+XXXX-YYYYMMDD.HHMM+XXXX
    file_dates = {}
    for filepath in all_files:
        filename = os.path.basename(filepath)
        try:
            # Extract date pattern like "20220509.0445+0000" from filename
            match = re.search(r'A(\d{8}\.\d{4}\+\d{4})', filename)
            if match:
                date_str = match.group(1)
                file_dates[filepath] = date_str
        except Exception as e:
            logging.warning(f"Could not parse date from {filename}: {e}")

    if not file_dates:
        logging.warning("No valid date patterns found in PM files")
        return ""

    # Find latest date
    latest_date = max(file_dates.values())
    logging.info(f"Latest PM date found: {latest_date}")

    # Remove files that don't match the latest date
    removed_count = 0
    for filepath, file_date in file_dates.items():
        if file_date != latest_date:
            try:
                os.remove(filepath)
                removed_count += 1
                logging.debug(f"Removed old PM file: {os.path.basename(filepath)}")
            except Exception as e:
                logging.error(f"Failed to remove {filepath}: {e}")

    logging.info(f"Removed {removed_count} old PM files, kept files with date {latest_date}")
    return latest_date


def post_process_pm_files(pm_dir, vpm_path_local):
    """
    Post-process PM files: decompress, merge XML files, add headers.
    Python replacement for pos_process.sh.

    Args:
        pm_dir: Directory containing compressed PM files (*.gz)
        vpm_path_local: Local PM path variable (e.g., 'vDU_PM_20241205-120000')
                       Used to extract prefix and timestamp for marker file

    Returns:
        str: Path to the consolidated PM.xml file
    """
    import gzip
    import shutil

    if not os.path.isdir(pm_dir):
        raise ValueError(f"Directory {pm_dir} does not exist")

    logging.info(f"Post-processing PM files in {pm_dir}")

    # Step 1: Decompress all .gz files
    gz_files = glob.glob(os.path.join(pm_dir, "*.gz"))
    for gz_file in gz_files:
        try:
            xml_file = gz_file[:-3]  # Remove .gz extension
            with gzip.open(gz_file, 'rb') as f_in:
                with open(xml_file, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            logging.debug(f"Decompressed: {os.path.basename(gz_file)}")
        except Exception as e:
            logging.error(f"Failed to decompress {gz_file}: {e}")

    # Step 2: Process A*.xml files - remove headers/footers
    a_xml_files = sorted(glob.glob(os.path.join(pm_dir, "A*.xml")))
    if not a_xml_files:
        logging.warning("No A*.xml files found to process")
        return ""

    processed_contents = []
    for xml_file in a_xml_files:
        try:
            with open(xml_file, 'r', encoding='utf-8') as f:
                content = f.read()

            # Remove XML declaration and OMeS wrapper from each file
            # Pattern: ^<?xml version="1.0"?><OMeS version="2.3"> at start
            # Pattern: </OMeS>$ at end
            content = re.sub(r'^<\?xml version="1\.0"\?><OMeS version="2\.3">', '', content)
            content = re.sub(r'</OMeS>$', '', content)

            processed_contents.append(content)
            logging.debug(f"Processed: {os.path.basename(xml_file)}")
        except Exception as e:
            logging.error(f"Failed to process {xml_file}: {e}")

    # Step 3: Concatenate all processed XML content into PM.xml
    pm_xml_path = os.path.join(pm_dir, "PM.xml")
    try:
        with open(pm_xml_path, 'w', encoding='utf-8') as pm_file:
            # Add XML header and opening OMeS tag
            pm_file.write('<?xml version="1.0"?>\n<OMeS>\n')

            # Write all processed content
            for content in processed_contents:
                pm_file.write(content)

            # Add closing OMeS tag
            pm_file.write('\n</OMeS>\n')

        logging.info(f"Created consolidated PM.xml from {len(a_xml_files)} files")
    except Exception as e:
        logging.error(f"Failed to create PM.xml: {e}")
        return ""

    # Step 4: Extract period information and create marker file
    try:
        # Get beginning timestamp from first file
        first_file = os.path.basename(a_xml_files[0])
        beg_match = re.search(r'A(\d{8}\.\d{4}\+\d{4})', first_file)
        beg_name = beg_match.group(1) if beg_match else "unknown"

        # Get ending timestamp from filename pattern (second date)
        end_match = re.search(r'-(\d{8}\.\d{4}\+\d{4})', first_file)
        end_name = end_match.group(1) if end_match else "unknown"

        # Extract prefix and timestamp from vpm_path_local
        # Format: vDU_PM_20241205-120000 or vCU_PM_20241205-120000
        match = re.match(r'(.+)_PM_(.+)', vpm_path_local)
        if match:
            prefix = match.group(1)
            old_name = match.group(2)
        else:
            prefix = "unknown"
            old_name = "unknown"

        # Create marker file in parent directory
        parent_dir = os.path.dirname(pm_dir)
        marker_name = f"DIR___{prefix}_PM_{old_name}__PERIOD__{beg_name}_to_{end_name}"
        marker_path = os.path.join(parent_dir, marker_name)

        with open(marker_path, 'w') as marker_file:
            marker_file.write('')  # Create empty marker file

        logging.info(f"Created marker file: {marker_name}")
    except Exception as e:
        logging.warning(f"Failed to create marker file: {e}")

    # Step 5: Clean up A*.xml files
    for xml_file in a_xml_files:
        try:
            os.remove(xml_file)
            logging.debug(f"Removed: {os.path.basename(xml_file)}")
        except Exception as e:
            logging.error(f"Failed to remove {xml_file}: {e}")

    # Step 6: Clean up .gz files
    for gz_file in gz_files:
        try:
            os.remove(gz_file)
            logging.debug(f"Removed: {os.path.basename(gz_file)}")
        except Exception as e:
            logging.error(f"Failed to remove {gz_file}: {e}")

    return pm_xml_path
