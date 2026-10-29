import os


def extract_nidd_version(scf_file_path, class_name='com.nokia.srbts.nrbts:NRBTS'):
    """
    Extracts the NIDD version from an SCF file.

    Args:
        scf_file_path: The path to the SCF file.

    Returns:
        The NIDD version as a string, or None if not found or an error occurs.
    """
    try:
        with open(scf_file_path, 'r') as scf_file:
            for line in scf_file:
                if class_name in line:
                    nrbts_nidd_list = line.split()
                    if len(nrbts_nidd_list) > 5:  # Check if enough elements exist
                        nidd_version = nrbts_nidd_list[5].replace("'", "")
                        return nidd_version
                    else:
                        print("Warning: Insufficient elements after splitting the line.")
                        return None
            print(f"Warning: Line containing class_name '{class_name}' not found.")
            return None
    except FileNotFoundError:
        print(f"Error: File not found at {scf_file_path}")
        return None
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return None
