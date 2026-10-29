import requests
import json
import sys


WFT_ACCESS_KEY = '5wUS7J3ooFesM2hbWcFyv6gagJER6w00uZBZ4rb4'
WFT_BASE_URL = 'https://wft.int.net.nokia.com:8091/TOOLS/api/v1/build.json'


def get_airphone_builds(states=None, items=10):
    """Query WFT for airphone builds filtered by state.

    Args:
        states: list of states to filter, e.g. ['RELEASED', 'RELEASED_WITH_RESTRICTIONS']
        items: number of results to return
    Returns:
        list of build items or empty list on failure
    """
    if states is None:
        states = ['RELEASED', 'RELEASED_WITH_RESTRICTIONS']

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
    params = [
        ('access_key', WFT_ACCESS_KEY),
        ('view[items]', items),
        ('view[sorting_field]', 'created_at'),
        ('view[sorting_direction]', 'DESC'),
        ('view[columns][][id]', 'version'),
        ('view[columns][][id]', 'state'),
        ('view[view_filters_attributes][1][column]', 'state'),
        ('view[view_filters_attributes][1][operation]', 'eq_any'),
        ('view[view_filters_attributes][2][column]', 'component'),
        ('view[view_filters_attributes][2][operation]', 'eq'),
        ('view[view_filters_attributes][2][value][]', 'airphone'),
    ]
    for state in states:
        params.append(('view[view_filters_attributes][1][value][]', state))

    try:
        r = requests.get(WFT_BASE_URL, timeout=60, headers=headers, params=params)
        r.raise_for_status()
    except requests.exceptions.ConnectTimeout:
        print(f'Connection to {WFT_BASE_URL} timed out')
        return []
    except requests.exceptions.HTTPError as err:
        print(f'HTTP Error: {err}')
        return []
    except requests.exceptions.RequestException as e:
        print(f'Request Error: {e}')
        return []

    data = r.json()
    return data.get('items', [])


def get_latest_airphone_version(states=None):
    """Return the version string of the latest airphone build matching the given states.
    Strips the 'airphone_' prefix so the result can be used directly as packagename.
    """
    items = get_airphone_builds(states=states)
    if not items:
        print('No matching airphone builds found')
        return None
    version = items[0].get('version', '')
    if version.startswith('airphone_'):
        version = version[len('airphone_'):]
    return version


if __name__ == '__main__':
    states = ['released', 'RELEASED_WITH_RESTRICTIONS']
    if len(sys.argv) > 1:
        states = sys.argv[1:]

    items = get_airphone_builds(states=states, items=20)
    if not items:
        print('No matching airphone builds found')
        sys.exit(1)

    print(f'Found {len(items)} airphone builds:')
    print('-' * 90)
    for item in items:
        version = item.get('version', 'N/A')
        state = item.get('state', 'N/A')
        print(f'  {version:60s} {state}')
    print('-' * 90)
    print(f'\nLatest: {items[0].get("version")} ({items[0].get("state")})')
