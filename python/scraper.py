#!/usr/bin/env python3
"""
Web scraper module using BeautifulSoup and requests
"""
import sys
import json
import requests
import certifi
from bs4 import BeautifulSoup


def scrape():
    """
    Scrape a webpage and extract the title.
    
    Returns:
        dict: Contains 'url', 'title', and optionally 'warning' or 'error'
    """
    url = 'https://en.wikipedia.org/wiki/Plain_text'
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    try:
        r = requests.get(url, timeout=10, headers=headers, verify=certifi.where())
        soup = BeautifulSoup(r.text, 'html.parser')
        # Try to extract title from <title> tag, then fallback to og:title, then h1
        title = ''
        if soup.title and soup.title.string:
            title = soup.title.string
        else:
            og_title = soup.find('meta', property='og:title')
            if og_title:
                title = og_title.get('content', '')
            else:
                h1 = soup.find('h1')
                if h1:
                    title = h1.get_text().strip()
        return {'url': url, 'title': title}

    except requests.exceptions.SSLError:
        # Fallback: try without verification and return a warning
        try:
            r = requests.get(url, timeout=10, headers=headers, verify=False)
            soup = BeautifulSoup(r.text, 'html.parser')
            title = ''
            if soup.title and soup.title.string:
                title = soup.title.string
            else:
                og_title = soup.find('meta', property='og:title')
                if og_title:
                    title = og_title.get('content', '')
                else:
                    h1 = soup.find('h1')
                    if h1:
                        title = h1.get_text().strip()
            return {'url': url, 'title': title, 'warning': 'SSL verification disabled (fallback)'}
        except Exception as e:
            return {'error': str(e)}
    except Exception as e:
        return {'error': str(e)}


if __name__ == '__main__':
    print(json.dumps(scrape()))
    sys.exit(0)
