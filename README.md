# picture4name
Crawl the web to get a picture for each name on a list

## Usage

Run `sh picture4name.sh`.

```
Crawl the web to get a picture for each name on a list.

Usage: picture4name.sh NAMES_FILE [DOWNLOAD_DIR] [SITE]

Arguments :
    NAMES_FILE      The path to a file containing names (one on each line, no special chars, no quote)
    DOWNLOAD_DIR    (Optional) The path to a directory (if it doesn't exist it will be created, default is the current directory)
    SITE            (Optional) Download pictures only from this site (example: linkedin.com), but always through google
```

## Example

Consider the names file `names.txt` containing :

```
Mahatma Gandhi
Noam Chomsky
Paul Watson
Vandana Shiva
```

To get a picture for each names using google into the directory `pictures`, run :

```
sh picture4name.sh names.txt pictures
```

To get pictures from only linkedin (through google) run :

```
sh picture4name.sh names.txt pictures linkedin.com
```

