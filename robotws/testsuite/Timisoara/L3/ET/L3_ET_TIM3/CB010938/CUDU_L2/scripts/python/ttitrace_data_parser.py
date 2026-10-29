import logging
from format_ttitrace_table import *
logging.basicConfig(level=logging.INFO)


def create_rnti_table_file(dir, infile="head_resReqClassPrio.csv"):
    """
    From ttitrace with ue info column index, combine the same ue info to one column.
    :param dir: traffic direction
    :param infile: ttitrace csv type file with ue info column index.
    :return out_file: output file.
    """
    path, file_name = os.path.split(infile)
    out_file = path + "/" + "rnti_" + file_name
    fh_w = open(out_file, "w")
    head = [dir+"TdSchedSubcellData: sfn", "rnti",
            "resReqClassPrio", "resReqClassSubPrio"]
    data_w_list = []
    data_w_list.append(",".join(head)+"\n")
    fh = open(infile)
    data = csv.DictReader(fh)
    for line in data:
        for int_i in range(10):
            i = str(int_i)
            if line["rnti_" + i] not in ["", 6666, "6666", "0", None]:
                line_w = [line[dir+"TdSchedSubcellData: sfn"], line["rnti_"+i], line["resReqClassPrio_"+i],
                          line["resReqClassSubPrio_"+i]]
                data_w_list.append(",".join(line_w)+"\n")
    fh_w.writelines(data_w_list)
    fh.close()
    fh_w.close()
    return out_file


def get_resReqClassPrio(rnti, infile="out_head_resReqClassPrio.csv"):
    """

    :param rnti:
    :param infile:
    :return:
    """
    fh = open(infile)
    data = csv.DictReader(fh)
    resReqClassPrio_list = []
    for line in data:
        tmp_rnti = int(line["rnti"])
        resReqClassPrio = int(line["resReqClassPrio"])
        if tmp_rnti == rnti:
            resReqClassPrio_list.append(resReqClassPrio)
    resReqClassPrio_set = set(resReqClassPrio_list)
    int_resReqClassPrio_list = [int(i) for i in resReqClassPrio_set]
    return int_resReqClassPrio_list


def get_sfn_interval(sfn_list):
    """

    :param sfn_list:
    :return:
    """
    sfn_listen = len(sfn_list)
    sfn_interval_list = []
    if sfn_listen > 1:
        sfn_interval_list1 = list(range(sfn_listen))
        sfn_len = list(range(1, sfn_listen))
        for i in sfn_len:
            sfn_interval_list1[i] = sfn_list[i] - sfn_list[i-1]
        sfn_interval_list = sfn_interval_list1
        logging.info(" sfn_interval_list {}...".format(sfn_interval_list))
    else:
        sfn_interval_list = sfn_list
    return sfn_interval_list


def test_check_log_for_CB006112(dir, in_file="L2TtiTrace_EventsSnapshot.bin.727.dl.csv", out_dir="./"):
    """
    Test example for CB006112, get rnti from paTimerData_sfn.csv or numOf5qi1Prb.csv table,
    scheduling data interval, PA timer expired interval
    and query ue scheduling class from resReqClassPrio.csv
    :param dir: traffic direction
    :param in_file: ttitrace file.
    :param out_dir: output file directory.
    :return rnti: ue rnti
    :return resReqClassPrio_list: scheduling class of special ue rnti
    :return data_schedule_interval_list: scheduling data interval
    :return pa_timer_interval_list: PA timer expired interval
    :return numOf5qi1Prb_list: number of 5qi1 prb
    """
    filter_list = ["paTimerData: sfn", "numOf5qi1Prb", "resReqClassPrio"]
    for filter_str in filter_list:
        logging.info("start to deal {}...".format(filter_str))
        format_ttitrace_table_for_easy_read(in_file, filter_str, out_dir)
    rnti_1_list, sfn1_list = get_rnti_from_paTimerData_table(
        in_file=out_dir+"paTimerData_sfn.csv")
    rnti_2_list, sfn2_list, numOf5qi1Prb_list = get_rnti_from_numOf5qi1Prb_table(
        dir, in_file=out_dir+"numOf5qi1Prb.csv")
    rnti = rnti_2_list[0]
    print("in paTimerData_sfn.csv: rnti={}".format(rnti_1_list))
    print("in paTimerData_sfn.csv: sfn={}".format(sfn1_list))
    print("in numOf5qi1Prb.csv: rnti={}".format(rnti_2_list))
    print("in numOf5qi1Prb.csv: sfn_list={}".format(sfn2_list))
    print("in numOf5qi1Prb.csv: numOf5qi1Prb_list={}".format(numOf5qi1Prb_list))
    out_file_head_index = add_head_column_index_if_head_column_has_same_content(
        in_file=out_dir+"resReqClassPrio.csv")
    out_file_head_rnti = create_rnti_table_file(dir, infile=out_file_head_index)
    resReqClassPrio_list = get_resReqClassPrio(
        rnti, infile=out_file_head_rnti)
    print("rnti={}, resReqClassPrio_list={}".format(rnti, resReqClassPrio_list))
    data_schedule_interval_list = get_sfn_interval(sfn2_list)
    pa_timer_interval_list = get_sfn_interval(sfn1_list)
    return rnti, resReqClassPrio_list, data_schedule_interval_list, pa_timer_interval_list, numOf5qi1Prb_list


def test_check_log_for_CB006112_BC_01(dir, in_file="L2TtiTrace_EventsSnapshot.bin.727.dl.csv", out_dir="./"):
    filter_list = ["dlFdSchedData: sfn", "numOf5qi1Prb", "resReqClassPrio"]
    for filter_str in filter_list:
        logging.info("start to deal {}...".format(filter_str))
        format_ttitrace_table_for_easy_read(in_file, filter_str, out_dir)
    rnti_2_list, sfn2_list, numOf5qi1Prb_list = get_rnti_from_numOf5qi1Prb_table(
        dir, in_file=out_dir+"numOf5qi1Prb.csv")
    rnti = rnti_2_list[0]
    print("in numOf5qi1Prb.csv: rnti={}".format(rnti_2_list))
    print("in numOf5qi1Prb.csv: sfn_list={}".format(sfn2_list))
    print("in numOf5qi1Prb.csv: numOf5qi1Prb_list={}".format(numOf5qi1Prb_list))
    out_file_head_index = add_head_column_index_if_head_column_has_same_content(
        in_file=out_dir+"resReqClassPrio.csv")
    out_file_head_rnti = create_rnti_table_file(dir, infile=out_file_head_index)
    resReqClassPrio_list = get_resReqClassPrio(
        rnti, infile=out_file_head_rnti)
    print("rnti={}, resReqClassPrio_list={}".format(rnti, resReqClassPrio_list))
    data_schedule_interval_list = get_sfn_interval(sfn2_list)
    return rnti, resReqClassPrio_list, data_schedule_interval_list, numOf5qi1Prb_list


def test_check_log_for_CB006112_A_02_01(dir, in_file="L2TtiTrace_EventsSnapshot.bin.727.dl.csv", out_dir="./"):
    filter_list = ["ulFdSchedData: sfn", "numOf5qi1Prb", "resReqClassPrio"]
    for filter_str in filter_list:
        logging.info("start to deal {}...".format(filter_str))
        format_ttitrace_table_for_easy_read(in_file, filter_str, out_dir)
    rnti_2_list, sfn2_list, numOf5qi1Prb_list = get_rnti_from_numOf5qi1Prb_table(
        dir, in_file=out_dir+"numOf5qi1Prb.csv")
    rnti = rnti_2_list[0]
    print("in numOf5qi1Prb.csv: rnti={}".format(rnti_2_list))
    print("in numOf5qi1Prb.csv: sfn_list={}".format(sfn2_list))
    print("in numOf5qi1Prb.csv: numOf5qi1Prb_list={}".format(numOf5qi1Prb_list))
    out_file_head_index = add_head_column_index_if_head_column_has_same_content(
        in_file=out_dir+"resReqClassPrio.csv")
    out_file_head_rnti = create_rnti_table_file(dir, infile=out_file_head_index)
    resReqClassPrio_list = get_resReqClassPrio(
        rnti, infile=out_file_head_rnti)
    print("rnti={}, resReqClassPrio_list={}".format(rnti, resReqClassPrio_list))
    data_schedule_interval_list = get_sfn_interval(sfn2_list)
    return rnti, resReqClassPrio_list, data_schedule_interval_list, numOf5qi1Prb_list


def check_for_schedule_interval_dl(dir, in_file="L2TtiTrace_EventsSnapshot.bin.727.dl.csv", out_dir="./"):
    filter_list = ["dlFdSchedData: sfn", "numOf5qi1Prb"]
    for filter_str in filter_list:
        logging.info("start to deal {}...".format(filter_str))
        format_ttitrace_table_for_easy_read(in_file, filter_str, out_dir)
    rnti_2_list, sfn2_list, numOf5qi1Prb_list = get_rnti_from_numOf5qi1Prb_table(
        dir, in_file=out_dir+"numOf5qi1Prb.csv")
    rnti = rnti_2_list[0]
    print("in numOf5qi1Prb.csv: rnti={}".format(rnti_2_list))
    print("in numOf5qi1Prb.csv: sfn_list={}".format(sfn2_list))
    print("in numOf5qi1Prb.csv: numOf5qi1Prb_list={}".format(numOf5qi1Prb_list))
    data_schedule_interval_list = get_sfn_interval(sfn2_list)
    return rnti, data_schedule_interval_list, numOf5qi1Prb_list


def check_for_schedule_interval_ul(dir, in_file="L2TtiTrace_EventsSnapshot.bin.727.ul.csv", out_dir="./"):
    filter_list = ["ulFdSchedData: sfn", "numOf5qi1Prb"]
    for filter_str in filter_list:
        logging.info("start to deal {}...".format(filter_str))
        format_ttitrace_table_for_easy_read(in_file, filter_str, out_dir)
    rnti_2_list, sfn2_list, numOf5qi1Prb_list = get_rnti_from_numOf5qi1Prb_table(
        dir, in_file=out_dir+"numOf5qi1Prb.csv")
    rnti = rnti_2_list[0]
    print("in numOf5qi1Prb.csv: rnti={}".format(rnti_2_list))
    print("in numOf5qi1Prb.csv: sfn_list={}".format(sfn2_list))
    print("in numOf5qi1Prb.csv: numOf5qi1Prb_list={}".format(numOf5qi1Prb_list))
    data_schedule_interval_list = get_sfn_interval(sfn2_list)
    return rnti, data_schedule_interval_list, numOf5qi1Prb_list


if __name__ == "__main__":
    test_check_log_for_CB006112(
        in_file="./ttitrace_log/L2TtiTrace_EventsSnapshot.bin.727.dl.csv", out_dir="./CB006112/")
