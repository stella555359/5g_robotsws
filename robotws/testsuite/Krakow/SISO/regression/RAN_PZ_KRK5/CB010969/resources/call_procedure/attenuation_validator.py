import common_operations
import attenuator_operations
os.environ["ATTENUATOR_VALUES"] = json.dumps(ATTENUATOR_VALUES)


def validate_attenuator_matrix_result():
    data = attenuator_matrix
    for key, value in data.items():
        if isinstance(value, list):
            print(f"Key: {key}, Type: list")
            for item in value:
                if not isinstance(item, dict):
                    print(f"Type mismatch! Key: {key}, Value: {item}, Expected Type: dict")
                else:
                    validate_attenuator_matrix_result(item)
        elif isinstance(value, dict):
            print(f"Key: {key}, Type: dict")
            validate_attenuator_matrix_result(value)
        elif isinstance(value, (int, float, str, bool, type(None))):
            print(f"Key: {key}, Value: {value}, Type: {type(value)}")
        else:
            print(f"Unsupported type for value of key: {key}")
