from moler.util.moler_test import MolerTest


def verify_transfer_was_not_interrupted(data_transfer_statistics):
    transfer_list = data_transfer_statistics.split(";")[1].strip('[]').split(', ')
    transfer_list = [eval(i) for i in transfer_list]
    if 0 in transfer_list:
        MolerTest.error("Transfer was interrupted. Statistics:", dump=transfer_list, raise_exception=True)
