#!/usr/bin/python3

import socket
import requests
import socks
from sys import argv
import urllib
import json

# get string of sense family
def senseFamilyStr(entry: dict):
    result = ''
    for index, senseFamily in enumerate(entry['senseFamilies'], start=1):
        partsOfSpeechs = senseFamily['partsOfSpeechs'][0]['value']
        sensesStr = f'[{partsOfSpeechs}]\r\n'
        for index, sense in enumerate(senseFamily['senses'], start=1):
            definition = sense['definition']['text']
            senseStr = f'   {definition}\r\n'
            if 'exampleGroups' in sense.keys():
                for exampleGroup in sense['exampleGroups']:
                    example = exampleGroup['examples'][0]
                    senseStr += f'     • {example}\r\n'
            sensesStr += senseStr
        result += sensesStr
    return result


# change your proxy's ip
ip = '127.0.0.1'
# change your proxy's port
port = 1086
socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, ip, port)
socket.socket = socks.socksocket


# url
PATH = 'https://content.googleapis.com/dictionaryextension/v1/knowledge/search'
term = ' '.join(argv[1:])
query = {
    'language': 'en',
    'key': 'AIzaSyC9PDwo2wgENKuI8DSFOfqFqKP2cKAxxso',
    'term': term
}
url = PATH + '?' + urllib.parse.urlencode(query)
# headers
headers = {
    'x-origin': 'chrome-extension://mgijmajocgfcbeboacabfgobmjgjcoja'
}
# make the request, and decode the response to dict
response = json.loads(requests.get(url, headers=headers).text)

#if response not has key 'dictionaryData', exit
if 'dictionaryData' not in response.keys():
    print(f'Sorry, entry [{term}] not found.')
    exit(-1)

# get entry
entry = response['dictionaryData'][0]['entries'][0]

# construct output string
headword = entry['headword']
phonetics = ''
if 'phonetics' in entry.keys():
    phonetics = '|' + entry['phonetics'][0]['text'] + '|'

senseFamily = senseFamilyStr(entry)

# output
print(f'{headword} {phonetics}\r\n\r\n{senseFamily}')
exit(0)
