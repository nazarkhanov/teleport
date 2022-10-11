# Teleport command

`te` command allows you to go to a directory with various abbreviations

```shell
te --help
```

```
Usage: te [<command>] <arg> [<arg> ...] [-h | --help]

Description:

te command allows you to teleport to a directory with various abbreviations

Commands:

add             Add path to index
                Add tags to paths
rm              Remove path from index
                Remove tags from paths
ls              View indexed paths
                and their tags

Options:

-h, --help      Print this help

Examples:

te <path | tag | path abbr>             # teleport to path
te add <path> [<tag> ...]               # add path to index
te rm <path | tag> [<path | tag> ...]   # remove path or tags
te ls                                   # view index
```

## Setup

1. Copy `teleport.sh` to `/usr/bin/`
2. Allow to execute script `chmod +x /usr/bin/teleport.sh`
3. Add this line to your `~/.bashrc` file to make the script work

```
alias te=". teleport.sh"
```
