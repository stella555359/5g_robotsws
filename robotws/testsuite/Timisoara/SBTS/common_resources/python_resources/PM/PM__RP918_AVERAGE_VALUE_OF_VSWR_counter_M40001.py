import re


pattern_1_pm_counter = r'<DN>PLMN-PLMN/'
pattern_3_pm_counter = r'</DN></MO><NE-WBTS_1.0 measurementType="SBTS_Antenna_Line"><M40001C0>[0-9]+</M40001C0>'
pattern_for_scf = "<p name=\"direction\">TX</p>"
pattern_for_antennas = r'\>.*\<'
list_of_antennas = []
counter_file_content = None


def _read_scf_file_content(file_path):
    f = open(file_path, "r")
    global scf_file_content
    scf_file_content = f.readlines()
    f.close()


def _read_pm_counter_file_content(file_path):
    f = open(file_path, "r")
    global counter_file_content
    counter_file_content = f.readlines()[0]
    f.close()


def _get_antennas_list_from_scf():
    for i in range(1, len(scf_file_content)):
        x = scf_file_content[i].find(pattern_for_scf)
        if x >= 0:
            match_record = re.search(pattern_for_antennas, scf_file_content[i-1])
            if match_record:
                antenna_name = match_record.group()
                antenna_name = antenna_name[1:len(antenna_name)-1]
                list_of_antennas.append(antenna_name)


def _clean_antenna_list():
    global list_of_antennas
    list_of_antennas = list(dict.fromkeys(list_of_antennas))
    list_of_antennas.sort()


def _check_pm_counter_M40001C0_for_antennas_from_the_list():
    list_of_antennas_with_not_detected_counter = []
    for i in range(len(list_of_antennas)):
        pattern_2_pm_counter = r'%s' % list_of_antennas[i]
        match_record = re.search(pattern_1_pm_counter+pattern_2_pm_counter+pattern_3_pm_counter, counter_file_content)
        if not match_record:
            list_of_antennas_with_not_detected_counter.append(list_of_antennas[i])
        else:
            print("Counter M40001C0 incremented for", list_of_antennas[i])
    if list_of_antennas_with_not_detected_counter:
        raise NameError("Following antennas not have incremented counter M40001C0: ",
                        list_of_antennas_with_not_detected_counter)


def check_value_of_counter_M40001C0_for_each_tx_antenna(scf_file_path, pm_counter_file_path):
    _read_scf_file_content(scf_file_path)
    _read_pm_counter_file_content(pm_counter_file_path)
    _get_antennas_list_from_scf()
    _clean_antenna_list()
    _check_pm_counter_M40001C0_for_antennas_from_the_list()
