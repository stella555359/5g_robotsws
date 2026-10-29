import sys


def extract_tput(input_file_name, job_name):
    result_cb8661 = {
        "Traffic_2CC_1UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_5UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_10UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_20UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_30UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_40UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_50UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_50UE_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_100UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_2CC_100UE_DlHighTputBler9_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_10UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_20UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_40UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_60UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_80UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_100UE_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_4CC_100UE_DlHighTputBler9_UlBler0":
            {"NR_417": {"NRCELL[@id='3']": "", "NRCELL[@id='1']": "", "NRCELL[@id='6']": "", "NRCELL[@id='5']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_1CC_5UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_1CC_10UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": ""}},
        "Traffic_1CC_20UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": ""}},
        "Traffic_1CC_40UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": ""}},
        "Traffic_1CC_80UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": ""}},
        "Traffic_1CC_80UE_FR2_DlHighTputBler9_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": ""}},
        "Traffic_1CC_96UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": ""}},
        "Traffic_1CC_96UE_FR2_DlMedTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
        "DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""}},
        "Traffic_2CC_10UE_FR2_DlHighTputBler0_UlBler0":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": ""},
             "cs1_average": {},
             "skipped_fd_average": {},
             "slot_delay_max": {}},
    }

    result_other_fr2 = {
        "Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "DualConnEndur_1CC_96UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "DualConnEndur_1CC_70UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Spare7":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Spare8":
            {"NR_417": {"NRCELL[@id='1']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
    }

    result_other_fr2ca = {
        "Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_3CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_4CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "DualConnEndur_2CC_25UE_FR2_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='2']": "", "NRCELL[@id='3']": "", "NRCELL[@id='4']": ""},
             "cs1_average": {"ASP-2730-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": ""},
             "slot_delay_max": {"ALL": ""},
             "slot_delay_p95": {"4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
    }

    result_other_fr1 = {
        "Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='3']": ""},
             "cs1_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_p95": {"4": "", "ASP-2830-Disp_4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0_FifoON":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='3']": ""},
             "cs1_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_p95": {"4": "", "ASP-2830-Disp_4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Spare3":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='3']": ""},
             "cs1_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_p95": {"4": "", "ASP-2830-Disp_4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
        "Spare4":
            {"NR_417": {"NRCELL[@id='1']": "", "NRCELL[@id='3']": ""},
             "cs1_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "skipped_fd_average": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_max": {"ASP-2730-Disp_4": "", "ASP-2830-Disp_4": ""},
             "slot_delay_p95": {"4": "", "ASP-2830-Disp_4": ""},
             "queue_not_empty": {"1": "", "2": "", "3": ""},
             "queue_overload": {"1": "", "2": "", "3": ""},
             "tti_too_long": {"ALL": ""},
             "avg_skipped_ues": {"4": ""},
             "l1_dl_errors": {"ALL": ""}},
    }

    if "cb8661" in job_name:
        load_measurements = (
            "cs1_average", "skipped_fd_average", "slot_delay_max")
        result = result_cb8661
    else:
        load_measurements = (
            "cs1_average", "skipped_fd_average", "slot_delay_max", "slot_delay_p95", "queue_not_empty",
            "queue_overload", "tti_too_long", "avg_skipped_ues", "l1_dl_errors")
        if "FR2CA" in job_name:
            result = result_other_fr2ca
        elif "FR2" in job_name:
            result = result_other_fr2
        else:
            result = result_other_fr1
    input_file = open(input_file_name, "r")
    log_name = job_name.split("/")[0]
    current_test = None
    gnb_sw = None
    ap_sw = None
    for line in input_file.readlines():
        if "SW[0]=" in line:
            gnb_sw_full = line.split("SW[0]=")[1].strip()
            split_gnb_sw = gnb_sw_full.split("_")
            gnb_sw = f"{split_gnb_sw[0]}_{split_gnb_sw[2]}_{split_gnb_sw[3]}_{int(split_gnb_sw[4])}"
        if "AP Version" in line:
            ap_sw = line.split("=")[1].strip()
        if line.startswith("Checking "):
            current_test = line.split(" ")[1]
        if current_test in result:
            if "ROOT:NR_417" in line:
                current_oam_id = line.split("OAM:")[1].split(" ")[0]
                current_value = line.split("VAL:")[1].strip().split(" ")[0]
                if current_oam_id in result[current_test]["NR_417"]:
                    result[current_test]["NR_417"][current_oam_id] = current_value
            for load_measurement in load_measurements:
                if load_measurement in line:
                    current_oam_id = line.split("[")[1].split("]")[0]
                    current_value = line.split(":")[1].strip()
                    print(current_oam_id, current_value)
                    if current_oam_id in result[current_test][load_measurement]:
                        result[current_test][load_measurement][current_oam_id] = current_value
                        print(f"found result[{current_test}][{load_measurement}][{current_oam_id}] = {current_value}")
    if "cb8661" in job_name:
        for test in result:
            if test in ("Traffic_4CC_10UE_DlHighTputBler0_UlBler0",
                        "Traffic_2CC_1UE_DlHighTputBler0_UlBler0",
                        "Traffic_1CC_1UE_FR2_DlHighTputBler0_UlBler0"):
                print(f"{log_name}\n{ap_sw}\n{gnb_sw}")
            for oam_id in result[test]["NR_417"]:
                print(f"{result[test]['NR_417'][oam_id]}")
        for test in result:
            for load_measurement in load_measurements:
                for oam_id in result[test][load_measurement]:
                    print(f"{result[test][load_measurement][oam_id]}")
    else:
        for test in result:
            if test in ("Traffic_1CC_80UE_FR2_DlHighTputBler0_UlMedTputBler0",
                        "Traffic_2CC_160UE_DlHighTputBler0_UlMedTputBler0",
                        "Traffic_2CC_20UE_FR2_DlHighTputBler0_UlMedTputBler0"):
                print(f"{log_name}\n{ap_sw}\n{gnb_sw}")
            for oam_id in result[test]["NR_417"]:
                print(f"{result[test]['NR_417'][oam_id]}")
        for load_measurement in load_measurements:
            print(f"{log_name}\n{ap_sw}\n{gnb_sw}")
            for test in result:
                for oam_id in result[test][load_measurement]:
                    print(f"{result[test][load_measurement][oam_id]}")
    print(f"End of data")
    input_file.close()


if __name__ == '__main__':
    extract_tput(sys.argv[1], sys.argv[-1])
