# Google Dictionary python script
------------------

## Powered by
* Google Dictionary API
* [ntkme/dictionary](https://github.com/ntkme/dictionary)

## Based on
``` sh
$ curl --socks5 127.0.0.1:1086\
    -H 'x-origin: chrome-extension://mgijmajocgfcbeboacabfgobmjgjcoja'\
    'https://content.googleapis.com/dictionaryextension/v1/knowledge/search?term=query&language=en&key=AIzaSyC9PDwo2wgENKuI8DSFOfqFqKP2cKAxxso'
```

## Requirements
Because of [Great Firewall](https://en.wikipedia.org/wiki/Great_Firewall), we have to request Google API over a proxy. 

This script use [socks5](https://en.wikipedia.org/wiki/SOCKS#SOCKS5) as the proxy, Install [PySocks](https://github.com/Anorov/PySocks) :

```sh
$ sudo pip3 install -U pysocks
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

Open your terminal, and execute:

```sh
$ ./google-dictionary.py love
```

will output like this:
```
love |lʌv|

[noun]
   a strong feeling of affection.
     • babies fill parents with intense feelings of love
     • their <b>love for</b> their country
   a great interest and pleasure in something.
     • his <b>love for</b> football
     • we share a <b>love of</b> music
   a person or thing that one loves.
     • she was <b>the love of his life</b>
     • their two great loves are tobacco and whisky
   (in tennis, squash, and some other sports) a score of zero; nil.
     • love fifteen
[verb]
   feel deep affection or sexual love for (someone).
     • do you love me?

```

the response of Google API of this query is in [google-dictionary-love.json](./google-dictionary-love.json), you can get more information from it.

*Thanks for your interest :)*
