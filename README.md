# mshex

This is a repository for my personal shell scripts.
The name `mshex` comes from the abbreviation of "my shell extensions".
The license is [MIT License](LICENSE).

## Install

`make` (GNU make) and `gawk` (GNU awk) is required.
`mshex` can be installed by the following commands.
The scripts and settings will be copied to the install path specified by the make variable `PREFIX`.
The default path for `PREFIX` is `~/.mwg`.

```bash
$ git clone git@github.com:akinomyoga/mshex.git
$ cd mshex
$ make install PREFIX=~/.mwg
```

The common bashrc settings can be loaded by sourcing `~/.mwg/share/mshex/shrc/bashrc_common.sh`.
To use the external commands of this package, add `PREFIX/bin` (where `PREFIX` is the install path) to the environment variable `PATH`.

```bash
# bashrc

# Initialize mshex install prefix
MWGPATH=~/.mwg

# Load common bashrc settings
source "$MWGPATH/share/mshex/shrc/bashrc_common.sh"

# Use mshex external commansds
export PATH=$MWGPATH/bin:$PATH
```

## The list of external commands

The scripts installed in `PREFIX/bin` is listed here.
Please check the output of `--help` for details of each command.

### Source file manipulation

```bash
# Find source file names
findsrc [options]
src find [options]

# Grep patterns from the source files
grc [options] pattern [files...]
src grep [options]

# Count LoC
src wc [options]

# Replace tokens in the source files
refact [options] before after [files...]

# Update Makefile from Makefile.pp
makepp
```

### General file manipulation

```bash
# Create backup to file.20150101.ext
mwgbk [options] files...

# Rename files with regex (ERE)
ren before after [files...]

# Safe file removes backed up into ~/.recycle
remove [options] files...

# Safe file moves
move [options] file1 file2
move [options] files... dir

# Modify cygwin permissions
modmod [files...]

# Backupped synchronization
msync [options] srcdir dstdir
```

### Copy & run executable files

```bash
# Copy and run the executable.
crun executable

# Compile and run program.cxx.
crun program.cxx
```

### Passwords and encryption

```bash
# Generate random password
passgen

# Edit ~/.ssh/passwd.cz2
pass --edit

# View ~/.ssh/passwd.cz2
pass

# Encrypt the file
cz file

# Decrypt the file
cz file.cz2

# View contents of the encrypted file
czless file.cz2
```

### Others

```bash
# Remove duplicates in ~/.bash_history
hist-uniq [file]

# Filter for text justification (extended fold)
ifold [options]

# Create archive
tarc archive files...

# Show IO activities of the system
iostat.sh
```

## The list of aliases and functions by shrc/bashrc_common.sh

### Job control

- Alias `j`: `jobs`
- Alias `f`: `fg`
- Alias `F`: `fg %-`
- Alias NUM: `fg %NUM`
- Key-binding <kbd>M-z</kbd>: `fg`
- Key-binding <kbd>C-z</kbd>: `fg`
- Key-binding <kbd>C-NUM</kbd>: `fg %NUM`

### Change directory

- Alias `c`: `cd -` (goto previous directory)
- Alias `C`: `cd ..` (goto parent directory)
- Key-binding <kbd>next</kbd>: show menu for cd history
- Key-binding <kbd>M-up</kbd>: goto the previous entry in cd history
- Key-binding <kbd>M-down</kbd>: goto the next entry in cd history

### Devel

- Alias `m`: `make` in the appropriate directory
- Function `g`: git manipulations
  - Function `g`: `git status`
  - Function `g d`: diff "working tree" vs "index" (`git diff`)
  - Function `g d0`: diff "index" vs "HEAD" (`git diff --cached`)
  - Function `g d[NUM]`: diff "NUM-th last commit" vs "its previous commit" (`git diff @~((NUM-1)) @~NUM`)
  - Function `g d COMMIT`: diff "the specified commit" vs "its previous commit" (`git diff COMMIT~1 COMMIT`)
  - Function `g t`: show commit graph (`git log --graph ...`)
  - Function `g set-mtime`: set timestamp of each tracked file to that of the last commit that changed the file
  - Function `g ...`: other git commands (`git "$@"`)

### Others

- Function `rmgomi`: `rm -rf gomi`
- Alias `o`: open file with an appropriate program (`cygstart`, `xdg-open`, `open`, etc.)
- Alias `p`: show processes (`ps uaxf`)
- Alias `h`: show recent command history
- Alias `d`: show date and calendar
- Alias `a`: simple calculation command (using gawk)
- Alias `s`: `stty sane`
- Alias `v`: view file
- Alias `l`: `ls -lB`
- Alias `ll`: `ls -l`
- Alias `la`: `ls -la`
- Alias `ls`, `diff`, `grep`: color options
- Alias `cp`, `rm`, `mv`, `scp`: clobber options
- Alias `yes`: check stdout
- Function `mshex/display`: reset the environment variable `DISPLAY` for the latest SSH session.
- Function `mshex/set-prompt`: set prompt
- Function `mshex/set-window-title`: set window title in prompt

Also, `bash_common.sh` changes the settings for history, tty, `checkwinsize`, `TRAPERR`, `LANG`, etc.

## PATH manipulation

These functions are defined in `PREFIX/share/mshex/shrc/path.sh`.

```bash
SYNOPSIS

  PATH.canonicalize [-v VARNAME] [-F SEP]
  PATH.prepend      [-v VARNAME] [-F SEP] [-n] PATHS...
  PATH.append       [-v VARNAME] [-F SEP] [-n] PATHS...
  PATH.remove       [-v VARNAME] [-F SEP] PATHS...
  PATH.show         [VARNAME]

OPTIONS

  -v VARNAME  Change the target variable name. The default is PATH.
  -F SEP      Change the path separater. The default is colon (:).
  -n          Do not add non-existent path.
```
