"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import os


def add_test_execution_errors_to_file(warning_error_list, test_folder):
    """Add test execution errors to file"""
    # Create the HTML content
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test Execution Errors</title>
    </head>
    <body>
        <h1>Test Execution Errors</h1>
        <ul>
    """
    # Add formatted entries to the HTML content
    for entry in warning_error_list:
        html_content += format_entry(entry) + "\n"
    # Close the HTML tags
    html_content += """
        </ul>
    </body>
    </html>
    """
    # Write the HTML content to a file
    path_for_the_file = os.path.join(test_folder, "test_execution_errors.html")
    with open(path_for_the_file, "w") as file:
        file.write(html_content)
    print(f"HTML file 'test_execution_errors.html' has been created to {path_for_the_file}.")
    return path_for_the_file


# Function to format entries with appropriate highlighting
def format_entry(entry):
    # Replace newline characters with <br> for HTML display
    entry = entry.replace('\n', '<br>')
    if "WARNING" in entry:
        # Highlight WARNING with orange
        parts = entry.split(" WARNING: ")
        date = parts[0]
        message = parts[1]
        return f'<li>{date} <span style="background-color: orange;">WARNING</span>: {message}</li>'
    elif "ERROR" in entry:
        # Highlight ERROR with red
        parts = entry.split(" ERROR: ")
        date = parts[0]
        message = parts[1]
        return f'<li>{date} <span style="background-color: red;">ERROR</span>: {message}</li>'
    else:
        # Default case (shouldn't happen with this list)
        return f'<li>{entry}</li>'
