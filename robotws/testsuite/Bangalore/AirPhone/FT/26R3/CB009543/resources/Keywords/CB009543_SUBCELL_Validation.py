def validate_subcells(csv_file_path):
    required_values = {"0", "1", "2", "3"}
    detected_values = set()

    with open(csv_file_path, "r", encoding="utf-8") as file:
        for line in file:
            value = line.strip()

            if value in required_values:
                detected_values.add(value)

            if detected_values == required_values:
                print("4 SUBCELL IDS are DETECTED AND PASSED")
                return "4 SUBCELL IDS are DETECTED AND PASSED"

    print("@ID SUBCELL is not detected and its FAILED")
    return "@ID SUBCELL is not detected and its FAILED"
