import logging


values_per_test = {
    "CB008246_G_TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE": (5, 10),
    "CB008246_G_TC02_HrDrbPdsch_SA_multiDRB_nonGBR_FDD": (7, 9),
    "CB008246_G_TC03_HrDrbPdsch_SA_multiDRB_nonGBR_OnlineModify_multiUE": (7, 7),
    "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance1": (1, 9),
    "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance2": (1, 9),
    "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance3": (1, 9),
    "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance4": (1, 9),
    "CB008246_G_TC12_HrDrbPdsch_SA_multiDRB_GBR_FDD": (9, 7),
    "CB008246_G_TC13_HrDrbPdsch_SA_multiDRB_GBR_PDCCH_AL_Dynamic_multiUE": (10, 5)
}


def get_parameters_for_activate_CB008246_dllaBlerTargetHR(called_tests):
    intersection = list(set(called_tests) & set(values_per_test.keys()))
    print(intersection)
    if len(intersection) == 1:
        logging.info("For Testcase %s values %s were selected for dllaBlerTargetHR_1 and 2",
                     intersection[0], values_per_test[intersection[0]])
        return values_per_test[intersection[0]]
    else:
        logging.error("conflicting tests were run together, please check execution.")
        return 5, 10


def get_parameters_for_activate_CB008246_NRPDSCHHRLA(called_tests):
    values_per_test = {
        "CB008246_G_TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1", "NRPDSCHHRLA-2",
                                                                  "NRPDSCHHRLA-2", "NRPDSCHHRLA-2", "NRPDSCHHRLA-2"),
        "CB008246_G_TC02_HrDrbPdsch_SA_multiDRB_nonGBR_FDD": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1", "NRPDSCHHRLA-2",
                                                              "NRPDSCHHRLA-2", "NRPDSCHHRLA-2", "NRPDSCHHRLA-2"),
        "CB008246_G_TC03_HrDrbPdsch_SA_multiDRB_nonGBR_OnlineModify_multiUE": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-2",
                                                                               "NRPDSCHHRLA-2", "NRPDSCHHRLA-2",
                                                                               "NRPDSCHHRLA-2", "NRPDSCHHRLA-2"),
        "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance1": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1"),
        "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance2": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1"),
        "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance3": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1"),
        "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance4": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                     "NRPDSCHHRLA-1", "NRPDSCHHRLA-1"),
        "CB008246_G_TC12_HrDrbPdsch_SA_multiDRB_GBR_FDD": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1", "NRPDSCHHRLA-2",
                                                           "NRPDSCHHRLA-2", "NRPDSCHHRLA-2", "NRPDSCHHRLA-2"),
        "CB008246_G_TC13_HrDrbPdsch_SA_multiDRB_GBR_PDCCH_AL_Dynamic_multiUE": ("NRPDSCHHRLA-1", "NRPDSCHHRLA-1",
                                                                                "NRPDSCHHRLA-2", "NRPDSCHHRLA-2",
                                                                                "NRPDSCHHRLA-2", "NRPDSCHHRLA-2")
    }
    intersection = list(set(called_tests) & set(values_per_test.keys()))
    print(intersection)
    if len(intersection) == 1:
        logging.info("For Testcase %s values %s were selected for NRDRB-11/17/14/12/18/19 that correspond to "
                     "5QI-6/3/9/7/171/80", intersection[0], values_per_test[intersection[0]])
        return values_per_test[intersection[0]]
    else:
        logging.error("conflicting tests were run together, please check execution.")
        return "NRPDSCHHRLA-1", "NRPDSCHHRLA-1", "NRPDSCHHRLA-2", "NRPDSCHHRLA-2", "NRPDSCHHRLA-2", "NRPDSCHHRLA-2"


if __name__ == "__main__":
    print(get_parameters_for_activate_CB008246_dllaBlerTargetHR())
    print(get_parameters_for_activate_CB008246__NRPDSCHHRLA())
