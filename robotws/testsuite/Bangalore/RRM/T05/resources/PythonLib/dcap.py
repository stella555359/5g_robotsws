import zipfile
import os
import json


def find_pattern_in_json(json_file_path, pattern):
    # Load JSON data from the file
    with open(json_file_path, 'r') as file:
        data = json.load(file)
    # Function to recursively search for the pattern and extract "time" field

    def search_pattern(data, pattern, matched_rows):
        if isinstance(data, dict):
            for key, value in data.items():
                if isinstance(value, str) and pattern.lower() in value.lower():
                    time = find_timestamp(data)
                    if time:
                        matched_rows.append((time, data))  # Append the time and matched row
                search_pattern(value, pattern, matched_rows)
        elif isinstance(data, list):
            for item in data:
                search_pattern(item, pattern, matched_rows)
    # Function to retrieve timestamp from JSON

    def find_timestamp(data):
        if isinstance(data, dict):
            for key, value in data.items():
                if key.lower() == 'time':
                    return value
                elif isinstance(value, (dict, list)):
                    result = find_timestamp(value)
                    if result:
                        return result
        elif isinstance(data, list):
            for item in data:
                result = find_timestamp(item)
                if result:
                    return result
        return None
    # Initialize list to store matched rows
    matched_rows = []
    # Search for the pattern in the JSON data and extract "time" field
    search_pattern(data, pattern, matched_rows)
    # If pattern found, return the matched rows
    if matched_rows:
        return matched_rows
    else:
        return None
