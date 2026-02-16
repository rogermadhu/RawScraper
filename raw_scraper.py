#!/usr/bin/env python3
import sys
import json
import requests
import certifi
from bs4 import BeautifulSoup

def scrape():
    url = 'https://en.wikipedia.org/wiki/Plain_text'
    try:
        r = requests.get(url, timeout=10, verify=certifi.where())
        soup = BeautifulSoup(r.text, 'html.parser')
        title = soup.title.string if soup.title else ''
        return {'url': url, 'title': title}
    except requests.exceptions.SSLError:
        # Fallback: try without verification and return a warning
        try:
            r = requests.get(url, timeout=10, verify=False)
            soup = BeautifulSoup(r.text, 'html.parser')
            title = soup.title.string if soup.title else ''
            return {'url': url, 'title': title, 'warning': 'SSL verification disabled (fallback)'}
        except Exception as e:
            return {'error': str(e)}
    except Exception as e:
        return {'error': str(e)}

if __name__ == '__main__':
    print(json.dumps(scrape()))
    sys.exit(0)
