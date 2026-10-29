import logging
import csv
import os
logging.basicConfig(level=logging.INFO)


def filter_file_by_str(in_file, filter_str, out_file):
    """
    Filter lines contains str from one file.
    :param in_file: ttitrace file with csv type
    :param filter_str: filter str
    :param out_file: output file with csv type
    :return out_file:
    """
    filter_data = []
    fh = open(in_file)
    data = fh.readlines()
    for line in data:
        if line.count(filter_str):
            filter_data.append(line)
    fh.close()
    fh = open(out_file, "w")
    fh.writelines(filter_data)
    fh.close()
    return out_file


def remove_blank_data_in_list_at_end(list1):
    """
    Remove blank data "" at the end of a list.
    :param list1: list need to deal
    :return list after dealed
    """
    length_list1 = len(list1)
    last_non_blank_data_index = 0
    list1.reverse()
    for i in list1:
        if i == "":
            last_non_blank_data_index = last_non_blank_data_index+1
        else:
            break
    length_non_blank_data = length_list1 - last_non_blank_data_index
    logging.info("There are {} data in list.".format(length_list1))
    logging.info("There are {} blank data in list.".format(
        last_non_blank_data_index))
    logging.info("There are {} non blank data in list.".format(
        length_non_blank_data))
    list1.reverse()
    target_list = list1[0:length_non_blank_data]
    return target_list


def add_title_for_ttitrace(in_file, output_file):
    """
    From filterred ttitrace file, get the 1st line,convert it to list,delete blank data at the end,
    set the first half as head list, set the second half as 1st data list,select data from other lines too.
    Write data in to output file.
    :param in_file: list need to deal
    :param output_file: list need to deal
    :return output_file
    """
    fh = open(in_file)
    data = fh.readlines()
    fh.close()
    logging.debug("data[0][0:3]={}".format(data[0][0:3]))
    if data[0][0:3] == ",,,":
        logging.error("the first line start with ',,,', it is a head line,this line will be ommitted.")
        data.pop(0)
    logging.debug("data[0]={}".format(data[0]))
    data_start_column, data_end_column = get_data_start_end_column_number_check_sfn_number_method(
        data[0])
    line_list = data[0].strip().split(",")
    head_list = line_list[0:data_start_column]
    logging.debug("head_list={}".format(head_list))
    logging.info("There are {} columns in table, data is from column {} to column {}".format(
        len(head_list), data_start_column, data_end_column))
    line1_data_list = line_list[data_start_column:data_end_column]
    fh = open(output_file, "w")
    head_string = ",".join(head_list)
    line1_data_string = ",".join(line1_data_list)
    fh.write(head_string + "\n")
    fh.write(line1_data_string + "\n")
    for line in data[1:]:
        line = line.strip()
        line_list = line.split(',')
        line_data_list = line_list[data_start_column:data_end_column]
        line_data_string = ",".join(line_data_list)
        fh.write(line_data_string+"\n")
    fh.close()
    return output_file


def get_data_start_end_column_number_check_sfn_number_method(head_line):
    """
    split head line strings by comma, check data from index 0 to n,return until data can be changed to int method,
    because the first data is fsn number.
    :param head_line: the first line of log file.
    :return data_start_column : sfn data index
    :return data_end_column : sfn data index*2
    """
    line1 = head_line
    line1 = line1.strip()
    line_list = line1.split(',')
    logging.debug("line1_list={}".format(line_list))
    line_list = remove_blank_data_in_list_at_end(line_list)
    logging.debug("line_list={}".format(line_list))
    data_start_column = 0
    for i in line_list:
        try:
            int(i)
            break
        except ValueError:
            data_start_column = data_start_column + 1
    data_end_column = data_start_column*2
    print("data_start_column={},data_end_column={}".format(
        data_start_column, data_end_column))
    return data_start_column, data_end_column


def format_ttitrace_table_for_easy_read(ttitrace_file, filter_str, output_dir="./"):
    """
    Filter string from ttitrace table, and create a new table for easy to read
    :param ttitrace_file: ttitrace file with csv type
    :param filter_str: filter str
    :return out_file
    """
    deal_filter_str_for_file_name = filter_str.replace(":", "_")
    deal_filter_str_for_file_name = deal_filter_str_for_file_name.replace(
        " ", "")
    tmp_file = "tmp_"+deal_filter_str_for_file_name+".csv"
    out_file = deal_filter_str_for_file_name+".csv"
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)
    out_file_path = os.path.join(output_dir, out_file)
    filter_file_by_str(ttitrace_file, filter_str, tmp_file)
    add_title_for_ttitrace(tmp_file, out_file_path)
    return out_file_path


def get_column_title_index_in_csv_table(in_file, column_title):
    with open(in_file) as fh:
        head = fh.readline()
        data = head.split(",")
        column_title_index = 0
        for value in data:
            if value == column_title:
                break
            else:
                column_title_index = column_title_index+1
            print("column_title_index={}".format(column_title_index))
    return column_title_index


def get_rnti_from_paTimerData_table(in_file="paTimerData_sfn.csv"):
    """
    from a csv table, get data of rnti column.
    :param in_file: ttitrace file with csv type
    :return rnti number
    """
    rnti_index = get_column_title_index_in_csv_table(in_file, "rnti")
    sfn_index = get_column_title_index_in_csv_table(
        in_file, "paTimerData: sfn")
    with open(in_file) as fh:
        fh.readline()
        rnti_list = []
        sfn_list = []
        data = csv.reader(fh)
        for value in data:
            rnti_list.append(value[rnti_index])
            int_sfn = int(value[sfn_index])
            sfn_list.append(int_sfn)
    return rnti_list, sfn_list


def get_rnti_from_numOf5qi1Prb_table(dir, in_file="numOf5qi1Prb.csv"):
    """
    from a csv table, get data of rnti column, fsn column and numOf5qi1Prb column.
    :param in_file: ttitrace file with csv type
    :return :rnti number
    :return :sfn_list
    :return :numOf5qi1Prb_list
    """
    with open(in_file) as fh:
        data = csv.DictReader(fh)
        rnti_list = []
        sfn_list = []
        numOf5qi1Prb_list = []
        for line in data:
            try:
                int_numOf5qi1Prb = int(line["numOf5qi1Prb"])
                int_rnti = int(line["rnti"])
                int_sfn = int(line[dir+"FdSchedData: sfn"])
            except ValueError:
                print("{},{},{} changed to int type error".format(
                    line["numOf5qi1Prb"], line["rnti"], line[dir+"FdSchedData: sfn"]))
            if int_numOf5qi1Prb > 0:
                rnti_list.append(int_rnti)
                sfn_list.append(int_sfn)
                numOf5qi1Prb_list.append(int_numOf5qi1Prb)
        return rnti_list, sfn_list, numOf5qi1Prb_list


def add_head_column_index_if_head_column_has_same_content(in_file="resReqClassPrio.csv"):
    """
    For dlTdSchedSubcellData, there are many UE info in one message.This funcion is used to add index for
    rnti,resReqClassPrio,resReqClassSubPrio.
    :param in_file: ttitrace file with csv type
    :return : out_file
    """
    path, file_name = os.path.split(in_file)
    out_file = path+"/head_index_"+file_name
    with open(in_file) as fh:
        head = fh.readline()
        pure_data_without_head = fh.readlines()
    count_rnti = head.count("rnti,resReqClassPrio,resReqClassSubPrio")
    logging.debug("count_rnti={}".format(count_rnti))
    for i in range(count_rnti):
        head = head.replace("rnti,resReqClassPrio,resReqClassSubPrio",
                            "rnti_{},resReqClassPrio_{},resReqClassSubPrio_{}".format(i, i, i), 1)
    with open(out_file, "w") as fh:
        fh.write(head)
        fh.writelines(pure_data_without_head)
    return out_file


def remove_blank_lines_from_one_file(in_file):
    """
    When we catch ttitrace, we use "cat $(ls -v *dl.csv) > full_dl.csv", there are many blank lines in file.
    They need to be removed.
    :param in_file: ttitrace file with csv type.
    :return out_file : file name with blank lines.
    """
    with open(in_file) as fh:
        with open("without_blank_line_file.csv", "w") as fh_w:
            fh_w.write("message,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10\n")
            for i in fh:
                if i != "\n":
                    fh_w.writelines(i)
    return "without_blank_line_file.csv"


def get_message_type(in_file):
    """
    Get the first column of ttitrace csv table, removed deplicated ones.
    :param in_file: ttitrace file with csv type.
    :return data_type_list : message list.
    """
    sfn_list = []
    with open(in_file) as fh:
        line1 = fh.readline()
        logging.info("omit the first line {}".format(line1))
        for i in fh:
            data = i.split(",")
            sfn_list.append(data[0])
    data_type_list = set(sfn_list)
    logging.info("data_type_list={}".format(data_type_list))
    return data_type_list


def split_table_by_different_message_type(in_file, output_dir):
    """
    Split table by different message type
    :param in_file: ttitrace file with csv type.
    :param output_dir : output file directory.
    """
    data_type_list = get_message_type(in_file)
    for message in data_type_list:
        format_ttitrace_table_for_easy_read(in_file, message, output_dir)


def delete_useless_files():
    """
    Delete useless temp files, if you debug script, remove this step.
    """
    useless_file_prefix = ["tmp_", "with"]
    file_name_list = os.listdir("./")
    for i in file_name_list:
        if i[0:4] in useless_file_prefix:
            tmp_file = os.path.join("./", i)
            logging.info("remove tmp file {}".format(tmp_file))
            os.remove(tmp_file)


def ttitrace_filter_table_with_all_different_message(in_file, output_dir):
    """
    Deal ttitrace table, filter all type of messages, and delete temp files.
    :param in_file: ttitrace file with csv type.
    :param output_dir: output file directory.
    :return:
    """
    file_without_blank_line = remove_blank_lines_from_one_file(in_file)
    split_table_by_different_message_type(file_without_blank_line, output_dir)
    delete_useless_files()


def test_filter_table_with_one_para():
    """
    Example test for filtering table with one parameter.
    :return:
    """
    in_file = "./ttitrace_log/L2TtiTrace_EventsSnapshot.bin.727.dl.csv"
    filter_para = "numOf5qi1Prb"
    format_ttitrace_table_for_easy_read(in_file, filter_para)


def test_ttitrace_filter_table_with_all_different_message():
    """
    Example test for filtering dl and ul table with all different messages.
    :return:
    """
    in_file = "./ttitrace_log/full_dl.csv"
    output_dir = "./dl/"
    ttitrace_filter_table_with_all_different_message(in_file, output_dir)
    in_file = "./ttitrace_log/full_ul.csv"
    output_dir = "./ul/"
    ttitrace_filter_table_with_all_different_message(in_file, output_dir)


if __name__ == "__main__":
    test_ttitrace_filter_table_with_all_different_message()
