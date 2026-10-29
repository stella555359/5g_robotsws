from datetime import datetime


def msg_notexist(func):
    def inner(err):
        error_msg = func(err)
        if not error_msg:
            return "invalid params"
        else:
            return error_msg
    return inner


@msg_notexist
def get_msg(filepath):
    date_format_str = "%Y-%m-%d %H:%M:%S.%f"
    with open(filepath) as readfile:
        for cnt, line in enumerate(readfile):
            if '"rrcSetupRequest";gNB' in line:
                t1 = (line.split(";")[0])
                dt1 = datetime.strptime(t1, date_format_str)
            if '"InitialContextSetupResponse";AMF' in line:
                t2 = (line.split(";")[0])
                dt2 = datetime.strptime(t2, date_format_str)
                diff_in_micro_secs = (dt2-dt1).total_seconds() * 1000000
        readfile.close
    return diff_in_micro_secs
