import requests
from bs4 import BeautifulSoup
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def download_html(url, output_file):
    """
    Downloads an HTML file from the given URL and saves it to the specified output file.

    Args:
        url (str): The URL of the HTML file to download.
        output_file (str): The path to save the downloaded HTML file.
    """
    try:
        response = requests.get(url, timeout=30, verify=False)
        response.raise_for_status()
        with open(output_file, 'w', encoding='utf-8') as file:
            file.write(response.text)
        print(f"HTML file downloaded and saved to {output_file}")
    except requests.exceptions.RequestException as e:
        print(f"Error downloading the HTML file: {e}")


def read_html(file_path):
    """
    Reads the HTML content from a local file.

    Args:
        file_path (str): The path to the HTML file.

    Returns:
        BeautifulSoup: Parsed HTML content.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            html_content = file.read()
        soup = BeautifulSoup(html_content, 'html.parser')
    except Exception as e:
        print(f"Error reading the HTML file: {e}")
        soup = None
    if soup:
        table_id = "dumb_table"
        print(get_table_by_id(soup, table_id))
        # Extract "CPU Analysis:" text
        print(get_table_by_id(soup, "summary_table"))
        cpu_analysis_results = extract_cpu_analysis(soup)
        for result in cpu_analysis_results:
            print(result)

        # Extract "FAILED reason:" text
        failed_reasons = extract_text_matching(soup, "FAILED reason:", tag_name='font',
                                               class_name='bold_txt summary_title cursor')
        for reason in failed_reasons:
            print(reason)


def get_table_by_id(soup, table_id):
    """
    Fetches an HTML table with a specific ID.

    Args:
        soup (BeautifulSoup): Parsed HTML content.
        table_id (str): The ID of the table to extract.

    Returns:
        str: The HTML content of the table, or a message if not found.
    """
    table = soup.find('table', id=table_id)
    return str(table) if table else f"Table with id='{table_id}' not found."


def extract_text_matching(soup, keyword, tag_name=None, class_name=None):
    """
    Extracts text matching a specific keyword from the HTML content.

    Args:
        soup (BeautifulSoup): Parsed HTML content.
        keyword (str): The keyword to search for.
        tag_name (str, optional): The tag name to filter by.
        class_name (str, optional): The class name to filter by.

    Returns:
        list: A list of matching text.
    """
    results = []
    tags = soup.find_all(tag_name, class_=class_name) if tag_name else (soup.find_all
                                                                        (string=lambda text: keyword in text))
    for tag in tags:
        if keyword in tag.get_text() if hasattr(tag, 'get_text') else tag:
            results.append(tag.get_text(strip=True) if hasattr(tag, 'get_text') else tag.strip())
    return results


def extract_cpu_analysis(soup):
    """
    Extracts text containing "CPU Analysis:" and associated details.

    Args:
        soup (BeautifulSoup): Parsed HTML content.

    Returns:
        list: A list of extracted details.
    """
    results = []
    for line in soup.find_all(string=lambda text: "CPU Analysis:" in text):
        parent = line.parent
        if parent.find('a') and parent.find('font'):
            href = parent.find('a')['href']
            font_text = parent.find('font').get_text(strip=True)
            results.append(f"{line.strip()} {href} | {font_text}")
    return results
