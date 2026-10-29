import json
import argparse
import re


# Function to load error strings from JSON for a specific test case
def load_errors_for_test_case(json_file_path, test_case_name):
    with open(json_file_path, 'r') as json_file:
        json_content = json.load(json_file)
        test_cases = json_content.get('test_cases', {})
        return test_cases.get(test_case_name, {}).get('errors', [])


# Function to check for error strings in input text
def check_errors_in_input(errors, input_text):
    match_found = True
    for error in errors:
        error_string = json.dumps(error) if isinstance(error, dict) else error
        if error_string in input_text:
            print(f"Match found for: {error_string}")
        else:
            print(f"No match found for: {error_string}")
            match_found = False
    return match_found


# Function to count occurrences of 'feedback' in input text
def count_feedback_in_input(input_text):
    return input_text.count("'feedback':")


# Function to convert JSON to text format
def json_to_text(json_data):
    lines = []

    def recurse(value, prefix=''):
        if isinstance(value, dict):
            for key, val in value.items():
                recurse(val, prefix + key + '.')
        elif isinstance(value, list):
            for i, item in enumerate(value):
                recurse(item, prefix + f'[{i}].')
        else:
            lines.append(f"{prefix}: {value}")
    recurse(json_data)
    return '\n'.join(lines)


# Function to find and write non-matching content from the JSON and input text to a new file
def write_non_matching_content(json_file_path, input_text_file_path, test_case_name, new_file_path):
    with open(json_file_path, 'r') as json_file:
        json_content = json.load(json_file)
        test_case_content = json_content.get('test_cases', {}).get(test_case_name, {})
        json_text = json_to_text(test_case_content)
    with open(input_text_file_path, 'r') as input_file:
        input_text = input_file.read()
    feedback_pattern = re.compile(r"'feedback': '[^']*'")
    json_feedbacks = feedback_pattern.findall(json_text)
    non_matching_feedbacks = []
    relational_errors = False
    hardware_errors = False

    for feedback in feedback_pattern.findall(input_text):
        context = None
        start_pos = input_text.rfind(feedback)
        if start_pos > 0:
            left_text = input_text[:start_pos]
            if "'hardwareErrors':" in left_text:
                context = 'hardwareError'
                hardware_errors = True
            elif "'relationErrors':" in left_text:
                context = 'relationError'
                relational_errors = True
        if feedback not in json_feedbacks:
            non_matching_feedbacks.append((context, feedback))

    with open(new_file_path, 'w') as new_file:
        for i, (context, feedback) in enumerate(non_matching_feedbacks, start=1):
            if context:
                new_file.write(f"{context} error{i}: {feedback}\n\n")
            else:
                new_file.write(f"error{i}: {feedback}\n\n")

    return relational_errors, hardware_errors


# Main script
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process error strings for a test case.')
    parser.add_argument('json_file_path', type=str)
    parser.add_argument('input_text_file_path', type=str)
    parser.add_argument('test_case_name', type=str)
    parser.add_argument('new_file_path', type=str)
    args = parser.parse_args()

    error_strings = load_errors_for_test_case(args.json_file_path, args.test_case_name)

    with open(args.input_text_file_path, 'r') as input_file:
        input_text = input_file.read()

    match_found = check_errors_in_input(error_strings, input_text)
    total_feedback_count = count_feedback_in_input(input_text)
    json_feedback_count = count_feedback_in_input(" ".join(json.dumps(error) for error in error_strings))

    relational_errors, hardware_errors = write_non_matching_content(
        args.json_file_path,
        args.input_text_file_path,
        args.test_case_name,
        args.new_file_path
    )

    print(f"Total Error feedback on SCF Commissioning: {total_feedback_count}")
    print(f"Total Admissible Error Feedback for {args.test_case_name}: {json_feedback_count}")

    if match_found and json_feedback_count == total_feedback_count:
        print("SCF_VALIDATION_STATUS: Pass")
    else:
        error_types = []
        if relational_errors:
            error_types.append("RELATIONAL_ERRORS")
        if hardware_errors:
            error_types.append("HARDWARE_ERRORS")
        print(f"SCF_VALIDATION_STATUS: {', '.join(error_types)}")
