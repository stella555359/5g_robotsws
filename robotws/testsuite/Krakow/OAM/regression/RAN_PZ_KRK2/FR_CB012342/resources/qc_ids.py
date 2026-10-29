qc_ids = {"7_7_UTE5GCLOUDT9SK034": {("SBTS24R2", "SBTS25R2"): "185943",
                                    ("SBTS25R2", "SBTS25R3"): "220460",
                                    ("SBTS25R3", "SBTS26R1"): "255017",
                                    ("SBTS26R1", "SBTS26R2"): "298131",
                                    ("SBTS26R2", "SBTS26R3"): "243167"}
          }


def get_qc_id(tl, source, target):
    return qc_ids.get(tl, {}).get((source, target), None)
