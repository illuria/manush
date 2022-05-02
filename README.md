
![](logo.png)
![](menu.png)

manush is a simple, configurable, secure menu shell.

It presents the list of configurable options to the user.  
Each option represents a command to run.  

## Installation

There are two ways to build manush.

First is by using vipack package manager. Therefore, the prerequisites are voc (vishap oberon compiler) and vipack (vishap package manager).

Issue the following command in manush's directory:

```console
vipack -t $(pwd)/deptree -p manush -P $(pwd)
```

vipack should download all the necessary dependencies and build manush. You will find the resulting binary in the `build` directory.

The second way to build manush is by using the supplied Makefile. The Makefile is POSIX compatible.

## Configuration

manush needs to be started with exactly one command-line argument: The path of the configuration file.

In case no argument is provided, the default, `/usr/local/etc/manush.json` will be used. If the default configuration is not found either then manush will issue an error and exit.

manush will attempt to validate the configuration file with `jq`, which is the only runtime dependency it currently has.

For a sample configuration have a look at [`manush.json`](template/manush.json)

It looks like this:

```json
{
  "Top":
  {
    "name": "Top",
    "exec": "top",
    "cmnt": "top utility"
  },
  "Ls":
  {
    "name": "List",
    "exec": "ls -al",
    "cmnt": "list files and directories"
  },
  "sh":
  {
    "name": "shell",
    "exec": "/bin/sh",
    "cmnt": "posix shell"
  }
}
```

// manush will add one (the first) option to the menu described in the configuration: `exit`.

manush will always insert an `exit` command (internal) at the top of the menu.

Pro tip: you can have `manush /path/to/other_configuration_file.json` as one of the options, thus you may create menus with unlimited depth! (:
