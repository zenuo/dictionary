# Google Dictionary python script
------------------

## Basic
``` sh
curl 'https://content.googleapis.com/dictionaryextension/v1/knowledge/search?term=query&language=en&key=AIzaSyC9PDwo2wgENKuI8DSFOfqFqKP2cKAxxso' -H 'x-origin: chrome-extension://mgijmajocgfcbeboacabfgobmjgjcoja'
```

## Requirements
Because of (Great Firewall)[https://en.wikipedia.org/wiki/Great_Firewall], we have to request Google API over a proxy. 

This script use (socks5)[https://en.wikipedia.org/wiki/SOCKS#SOCKS5] as the proxy, Install (PySocks)[https://github.com/Anorov/PySocks] :

```sh
pip3 install -U pysocks
```

and, edit script to your proxy setting:

```python
# change your proxy's ip
ip = '127.0.0.1'
# change your proxy's port
port = 1086
```

## Using
> You can add this script to your `PATH`
```sh
$ ./google-dictionary.py dictionary
dictionary |ˈdɪkʃ(ə)n(ə)ri|

[noun]
   a book or electronic resource that lists the words of a language (typically in alphabetical order) and gives their meaning, or gives the equivalent words in a different language, often also providing information about pronunciation, origin, and usage.
     • I'll look up 'love' in the dictionary
     • the website gives access to an online dictionary
     • the dictionary definition of ‘smile’
```

Thanks for your intrest :)