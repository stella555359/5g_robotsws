import re
import datetime


def check_if_there_is_counter_without_value(counter_file_content):
    counter_tag_start_pattern = r'<M\w{6,8}>'
    counter_tag_end_pattern = r'</M\w{6,8}>'
    records = re.findall(
        counter_tag_start_pattern + counter_tag_end_pattern,
        counter_file_content)
    if records:
        raise NameError('There are empty PM counters without value')


def check_dn_tag(counter_file_content, mrbts_id):
    id = mrbts_id.split("-")[1]
    lnbts_pattern = "LNBTS-"
    lnbts_id = lnbts_pattern + id
    lnbts_id_name = "/"+lnbts_id.split("-")[0]
    number_of_lnbts_id_name = re.findall(lnbts_id_name, counter_file_content)
    number_of_lnbts_id = re.findall(lnbts_id, counter_file_content)
    if len(number_of_lnbts_id) != len(number_of_lnbts_id_name):
        raise NameError('There is an issue in LNBTS field in <DN> tag')

    dn_close_tag_pattern = r'</DN>'
    dn_pattern = r'<DN>[-/\w]+</DN>'
    mcc_pattern = "/MCC-"
    number_of_dn = re.findall(dn_close_tag_pattern, counter_file_content)
    dn_list = re.findall(dn_pattern, counter_file_content)
    if len(number_of_dn) != len(dn_list):
        raise NameError('There is an issue in <DN> tag')

    mrbts_list = []
    lnbts_list = []
    mcc_list = []
    for i in dn_list:
        mrbts_item = re.search(mrbts_id, i)
        lnbts_item = re.search(lnbts_id, i)
        if mrbts_item:
            mrbts_list.append(mrbts_item)
        if lnbts_item:
            lnbts_list.append(lnbts_item)
        mcc_item = re.search(mcc_pattern, i)
        if mcc_item:
            mcc_list.append(mcc_item)
    if len(mrbts_list) + len(mcc_list) != len(dn_list):
        raise NameError('There is an issue in <DN> tag related to BTS name (usually set to MRBTS-...)')


def check_ne_tag(counter_file_content):
    measurement_type_pattern = r' measurementType=\"\"'
    measurement_type = re.search(measurement_type_pattern, counter_file_content)
    if measurement_type is not None:
        raise NameError('There is an empty measurement type in PM counter file')


def check_startime_info(counter_file_content, f_date, f_time, f_timeinterval):
    s_p = r'<PMSetup startTime=\"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}\+\d{2}:\d{2}:\d{2}\" interval=\"\d{1,2}\">'
    interval_pattern = r'interval=\"\d{1,2}\"'
    f_timeinterval = f_timeinterval.replace("min", "")
    start_time_data = re.findall(s_p, counter_file_content)
    if len(start_time_data) == 0:
        raise NameError('There is no startTime value in PM counter file. Found data:' + str(start_time_data))
    elif len(start_time_data) > 1:
        raise NameError('There are more than 1 values of startTime in PM counter file. Found data:'
                        + str(start_time_data))
        start_time_data = [start_time_data[0]]
    interval_value = re.search(interval_pattern, start_time_data[0]).group()
    if not interval_value:
        raise NameError('There is no interval time value in PM counter file. Found data:'+interval_value)
    interval_value = interval_value.replace("interval=\"", "")
    interval_value = interval_value.replace("\"", "")
    if f_timeinterval != interval_value:
        raise NameError('Time interval in PM counter file is different than set at BTS. ' +
                        f_timeinterval +
                        ' is not equal ' +
                        interval_value)
    s_date = start_time_data[0][20:30].replace("-", "")
    s_time = start_time_data[0][31:39].replace(":", "")
    time_shift_hours = start_time_data[0][44:46]
    td1 = datetime.datetime(
        int(f_date[0:4]),
        int(f_date[4:6]),
        int(f_date[6:8]),
        int(f_time[0:2]),
        int(f_time[2:4]),
        int(f_time[4:6]))
    td2 = datetime.datetime(
        int(s_date[0:4]),
        int(s_date[4:6]),
        int(s_date[6:8]),
        int(s_time[0:2]),
        int(s_time[2:4]),
        int(s_time[4:6]))
    d1 = datetime.timedelta(hours=int(time_shift_hours))
    d2 = datetime.timedelta(minutes=int(interval_value))
    sum_td2 = td2-d1+d2
    if td1 != sum_td2:
        raise NameError('Date and time in PM counter file name is different than value inside file. ' +
                        str(td1) +
                        ' is not equal ' +
                        str(sum_td2))


def get_data_from_filename(file_name):
    date_time = file_name.split(".")
    if date_time:
        return date_time[2], date_time[3]
    else:
        return None, None
