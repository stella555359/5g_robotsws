ecpri_parameters_list = [
    {"dist_name": "NRBTS-ID/NRPMRNL-1", "parameter": "miNrEcpriUpFCp", "value": "5min"},
    {"dist_name": "MNL-1/MNLENT-1/PMMNL-1", "parameter": "miRxWindowStats", "value": "5min"},
    {"dist_name": "MNL-1/MNLENT-1/PMMNL-1", "parameter": "miOranRuTxStats", "value": "5min"},
    {"dist_name": "MNL-1/MNLENT-1/FMCADM-1", "parameter": "actECpriOutOfTimingWindowAlarm", "value": "true"},
    {"dist_name": "EQM-1/APEQM-1", "parameter": "eCpriOutOfTimingWindowMinorThreshold", "value": "-3"},
    ]

recent_counter_values_dict = {"without_call": {}, "with_call": {}}

counter_ids_for_13355_b = (
    "M55318C00003,M55318C00005,M55318C00007,M55318C00009,"
    "M55318C00020,M55318C00021,M55318C00026,M55318C00027"
)
zero_counters_for_13355_b_08 = ["M55318C00005", "M55318C00007", "M55318C00009"]
positive_counters_for_13355_b_08 = ["M55318C00003", "M55318C00020", "M55318C00021", "M55318C00026"]
# TODO: "M55318C00027" will be added into positive_counters_for_13355_b_08 and positive_counters_for_13355_b_09
zero_counters_for_13355_b_09 = ["M55318C00009"]
positive_counters_for_13355_b_09 = ["M55318C00003", "M55318C00005", "M55318C00007",
                                    "M55318C00020", "M55318C00021", "M55318C00026"]

counter_ids_for_13355 = (
    "M55318C00003,M55318C00004,M55318C00005,M55318C00006,M55318C00007,M55318C00008,M55318C00009,M55318C00010,"
    "M55318C00020,M55318C00021,M55318C00022,M55318C00023,M55318C00024,M55318C00025,M55318C00026,M55318C00027,"
    "M55604C00001,M55604C00002,M55604C00003,M55604C00004,M55604C00006,M55604C00007,M55604C00008,M55604C00009,"
    "M40022C0"
)

# M55318C Zero counters (should be 0)
m55318c_zero_counters = ["M55318C00005", "M55318C00006", "M55318C00007", "M55318C00008", "M55318C00009",
                         "M55318C00010", "M55318C00024", "M55318C00025"]
# M55318C Positive counters (should be > 0)
m55318c_positive_counters = ["M55318C00003", "M55318C00004", "M55318C00020", "M55318C00021",
                             "M55318C00022", "M55318C00023", "M55318C00026", "M55318C00027"]
# M55604C Zero counters (should be 0)
m55604c_zero_counters = ["M55604C00002", "M55604C00003", "M55604C00004", "M55604C00008", "M55604C00009"]
# M55604C Positive counters (should be > 0)
m55604c_positive_counters = ["M55604C00001", "M55604C00006", "M55604C00007"]
# M40022C Zero counters (should be 0)
m40022c_zero_counters = []
# M40022C Positive counters (should be > 0)
m40022c_positive_counters = ["M40022C0"]

# Test flags for CB013355-SR-B_09 case
# IDT "eCPRI LL Split U-Plane Application Layer Specification"update due to PR842094
# PUSCH window changed from "1280-1551" to "1100-1351"
test_flags = [
    "0x420094=1115000",
    "0x4200B3=390000"
]
