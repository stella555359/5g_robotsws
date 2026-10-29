import os


def validate_bip_values(csv1_path, csv2_path):
    MIN_UL_ECID = 0
    MAX_UL_ECID = 3150848
    MIN_TA = 0
    MAX_TA = 1024

    def read_value(file_path, label):
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"{label} file not found: {file_path}")
        with open(file_path, "r") as f:
            lines = [line.strip() for line in f if line.strip()]
            if not lines:
                raise ValueError(f"{label} - File is empty.")
            try:
                value = int(lines[0])
                print(f"{label} value read from file: {value}")
                return value
            except ValueError:
                raise ValueError(f"{label} - First line is not a valid integer: '{lines[0]}'")

    try:
        ul_ecid_value = read_value(csv1_path, "initialUlEcidTAdv")
        ta_value = read_value(csv2_path, "initialTa")
    except Exception as e:
        raise Exception(f"Failed to read or parse CSV files:\n{e}")

    # Validate both values
    ul_ecid_valid = MIN_UL_ECID <= ul_ecid_value <= MAX_UL_ECID
    ta_valid = MIN_TA <= ta_value <= MAX_TA

    if ul_ecid_valid and ta_valid:
        msg = f"CB013507 BIP values initialUlEcidTAdv:{ul_ecid_value}  initialTa:{ta_value} passed."
        print(msg)
        return msg
    else:
        # Detailed failure message
        msg = (
            f"Expected range is missing for CB013507 BIP validation.\n"
            f"initialUlEcidTAdv: {ul_ecid_value} (expected 128–3150848)\n"
            f"initialTa: {ta_value} (expected 0–1024)\n"
            f"Validation failed."
        )
        print(msg)
        raise AssertionError(msg)
