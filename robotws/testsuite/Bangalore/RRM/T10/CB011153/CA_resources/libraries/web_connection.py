from requests import Session
from requests.packages.urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter


def website_should_be_reachable(url):
    """Fails if the given URL is unreachable."""
    session = Session()
    retries = Retry(total=2,
                    backoff_factor=0.1,
                    status_forcelist=[500, 502, 503, 504])
    session.mount('https://', HTTPAdapter(max_retries=retries))
    session.mount('http://', HTTPAdapter(max_retries=retries))

    resp = session.head(url, timeout=3.02)
    resp.raise_for_status()
