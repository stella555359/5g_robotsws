import csv
import logging


class CsvVerification:
    def __init__(self):
        self.csv_list = []

    def create_list_of_lists_from_csv(self, csv_path):
        with open(csv_path, newline='') as csv_file:
            csv_list = list(csv.reader(csv_file))
        if len(csv_list) <= 1:
            raise Exception(f"CSV file {csv_path} is empty")
        self.csv_list = csv_list
        return csv_list

    def extract_filtered_prb(self, prb_column="ulFdSchedData.numOfPrb",
                             slots_filter=(4, 8, 9, 18, 19)):
        headers, rows = self.csv_list[0], self.csv_list[1:]
        sfn_idx = headers.index("sfn")
        slot_idx = headers.index("slot")
        prb_idx = headers.index(prb_column)

        result = {}
        for row in rows:
            try:
                sfn = int(float(row[sfn_idx])) % 32
                if sfn % 2 == 0:
                    continue
                slot = int(float(row[slot_idx]))
                if slot not in slots_filter:
                    continue
                prb = float(row[prb_idx])
            except (ValueError, IndexError):
                continue

            if sfn not in result:
                result[sfn] = {}
            result[sfn][slot] = prb
        return result

    def save_filtered_prb_to_csv(self, result_dict, output_path="filtered_prb.csv",
                                 slots=None):
        if slots is None:
            slots = [4, 8, 9, 18, 19]

        with open(output_path, mode='w', newline='') as file:
            writer = csv.writer(file)
            header = ["SFN % 32"] + [f"Slot {slot}" for slot in slots]
            writer.writerow(header)

            for sfn in sorted(result_dict.keys()):
                row = result_dict[sfn]
                values = [row.get(slot, "") for slot in slots]
                writer.writerow([sfn] + values)

        logging.info(f"Filtered PRB saved to {output_path}")

    def compare_prb_csv_files(self, feature_off_path, feature_on_path, slots_filter):

        if slots_filter is None or slots_filter == "":
            slots_to_check = None
        elif isinstance(slots_filter, int):
            slots_to_check = {f"Slot {slots_filter}"}
        elif isinstance(slots_filter, str):
            parts = [p.strip() for p in slots_filter.split(",") if p.strip()]
            slots_to_check = {f"Slot {int(p)}" for p in parts}
        else:
            raise TypeError(f"slots_filter must be int or comma-separated string, got {type(slots_filter)}")

        def load_csv(filepath):
            with open(filepath, newline='') as f:
                reader = csv.reader(f)
                header = next(reader)
                slots = header[1:]
                data = {}
                for row in reader:
                    if not row:
                        continue
                    sfn = row[0]
                    data[sfn] = {
                        slot: (float(val) if val else None)
                        for slot, val in zip(slots, row[1:])
                    }
                return slots, data

        off_slots, off_data = load_csv(feature_off_path)
        on_slots, on_data = load_csv(feature_on_path)

        if slots_to_check is None:
            slots_to_check = set(off_slots).intersection(on_slots)
        else:
            slots_to_check = slots_to_check.intersection(off_slots, on_slots)

        differences = []
        missing = []

        for sfn, off_slots_vals in off_data.items():
            on_slots_vals = on_data.get(sfn, {})
            for slot in slots_to_check:
                off_val = off_slots_vals.get(slot)
                on_val = on_slots_vals.get(slot)

                if off_val is None:
                    continue
                if on_val is None:
                    missing.append(f"SFN {sfn} {slot} missing in feature_on")
                    continue
                if on_val < off_val:
                    differences.append(
                        f"SFN {sfn} {slot}: feature_on={on_val} feature_off={off_val}"
                    )

        for msg in differences + missing:
            logging.warning(msg)

        if differences or missing:
            raise AssertionError("Some PRB values in feature_on are lower than feature_off or missing.")
        logging.info("All selected PRB values in feature_on are greater than in feature_off")
