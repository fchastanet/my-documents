---
title: Basic Best Practices
description: Foundational best practices for writing Bash scripts
weight: 10
categories: [Bash]
tags: [bash, scripts, best-practices]
---

- [1. External references](#1-external-references)
- [2. General best practices](#2-general-best-practices)
- [3. escape quotes](#3-escape-quotes)
- [4. Bash environment options](#4-bash-environment-options)
  - [4.1. errexit (set -e | set -o errexit)](#41-errexit-set--e--set--o-errexit)
    - [4.1.1. Caveats with command substitution](#411-caveats-with-command-substitution)
    - [4.1.2. Caveats with process substitution](#412-caveats-with-process-substitution)
    - [4.1.3. Process substitution is asynchronous](#413-process-substitution-is-asynchronous)
  - [4.2. pipefail (set -o pipefail)](#42-pipefail-set--o-pipefail)
  - [4.3. errtrace (set -E | set -o errtrace)](#43-errtrace-set--e--set--o-errtrace)
  - [4.4. nounset (set -u | set -o nounset)](#44-nounset-set--u--set--o-nounset)
  - [4.5. inherit error exit code in sub shells](#45-inherit-error-exit-code-in-sub-shells)
  - [4.6. posix (set -o posix)](#46-posix-set--o-posix)
- [5. Main function](#5-main-function)
- [6. Arguments](#6-arguments)
- [7. some commands default options to use](#7-some-commands-default-options-to-use)
- [8. Variables](#8-variables)
  - [8.1. Variable declaration](#81-variable-declaration)
  - [8.2. variable naming convention](#82-variable-naming-convention)
  - [8.3. Variable expansion](#83-variable-expansion)
    - [8.3.1. Examples](#831-examples)
  - [8.4. Check if a variable is defined](#84-check-if-a-variable-is-defined)
  - [8.5. Variable default value](#85-variable-default-value)
  - [8.6. Passing variable by reference to function](#86-passing-variable-by-reference-to-function)
    - [8.6.1. Example 1](#861-example-1)
    - [8.6.2. Example 2](#862-example-2)
- [9. Capture output](#9-capture-output)
  - [9.1. Capture output and test result](#91-capture-output-and-test-result)
  - [9.2. Capture output and retrieve status code](#92-capture-output-and-retrieve-status-code)
- [10. Array](#10-array)
- [11. Temporary directory](#11-temporary-directory)
- [12. Traps](#12-traps)
- [13. Deal with SIGPIPE - exit code 141](#13-deal-with-sigpipe---exit-code-141)
- [14. Performances analysis](#14-performances-analysis)
- [15. Bash Performance tips](#15-bash-performance-tips)
  - [15.1. Array::wrap2 performance improvement](#151-arraywrap2-performance-improvement)

## 1. External references

- [pure bash bible](https://github.com/dylanaraps/pure-bash-bible?tab=readme-ov-file)
- [pure sh(posix) bible](https://github.com/dylanaraps/pure-sh-bible?tab=readme-ov-file)

## 2. General best practices

- `cat << 'EOF'` avoid to interpolate variables

- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid using customized aliased commands by
  the user In this framework, I added the command `unalias -a || true` to remove all eventual aliases and also ensure to
  disable aliases expansion by using `shopt -u expand_aliases`. Because aliases have a very special way to load. In a
  script file changing an alias doesn't occur immediately, it depends if script evaluated has been parsed yet or not.
  And alias changed in a function, will be applied outside of the function. But I experienced some trouble with this
  last rule, so I give up using aliases.

- use the right shebang, avoid `#!/bin/bash` as bash binary could be in another folder (especially on alpine), use this
  instead `#!/usr/bin/env bash`

- prefer to use printf vs echo

- avoid global variables whenever possible, prefer using local

  - check that every lowercase variable is used as local in functions
    - <https://github.com/bats-core/bats-core/issues/726>
    - <https://github.com/koalaman/shellcheck/issues/1395>
    - <https://github.com/koalaman/shellcheck/issues/468>

- avoid to export variables whenever possible

## 3. escape quotes

```bash
help='quiet mode, doesn'\''t display any output'

# alternative
help="quiet mode, doesn't display any output"
```

## 4. Bash environment options

See [Set bash builtin documentation](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

This framework uses these mode by default:

- errexit
- pipefail
- errtrace

### 4.1. errexit (set -e | set -o errexit)

Check official doc but it can be summarized like this:

> Exit immediately command returns a non-zero status.

I was considering this as a best practice because every non controlled command failure will stop your program. But
actually

- sometimes you need or expect a command to fail

**Eg1**: delete a folder that actually doesn't exists. Use `|| true` to ignore the error.

```bash
rm -Rf folder || true
```

**Eg2**: a command that expects to fail if conditions are not met. Using `if` will not stop the program on non-zero exit
code.

```bash
if git diff-index --quiet HEAD --; then
  Log::displayInfo "Pull git repository '${dir}' as no changes detected"
  git pull --progress
  return 0
else
  Log::displayWarning "Pulling git repository '${dir}' avoided as changes detected"
fi
```

- actually this feature is not well implemented everywhere

  - sometimes some commands that should fail doesn't fail
  - the feature is not homogeneous across implementations
  - some commands expects to have non zero exit code
  - some commands exits with non zero error code but does not necessarily needs the program to exit

- Finally it is preferable to check every command status code manually instead of relying to an automatic management.

#### 4.1.1. Caveats with command substitution

```bash
#!/bin/bash
set -o errexit
echo $(exit 1)
echo $?
```

Output:

```bash
0
```

it is because echo has succeeded. the same result occurs even with `shopt -s inherit_errexit` (see below).

The **best practice** is to always assign command substitution to variable:

```bash
#!/bin/bash
set -o errexit
declare cmdOut
cmdOut=$(exit 1)
echo "${cmdOut}"
echo $?
```

Outputs nothing because the script stopped before variable affectation, return code is 1.

#### 4.1.2. Caveats with process substitution

Consider this example that reads each line of the output of the command passed using process substitution in `<(...)`

```bash
parse() {
  local scriptFile="$1"
  local implementDirective
  while IFS='' read -r implementDirective; do
    echo "${implementDirective}"
  done < <(grep -E -e "^# IMPLEMENT .*$" "${scriptFile}")
}
```

If we execute this command with a non existent file, even if errexit, pipefail and inherit_errexit are set, the command
will actually succeed.

It is because process substitution launch the command as as separated process. I didn't find any clean way to manage
this using process substitution (only workaround I found was to pass by file to pass the exit code to parent process).

So here the solution removing process substitution

```bash
parse() {
  local scriptFile="$1"
  local implementDirective
  grep -E -e "^# IMPLEMENT .*$" "${scriptFile}" | while IFS='' read -r implementDirective; do
    echo "${implementDirective}"
  done
}
```

But how to use readarray without using process substitution. Old code was:

```bash
declare -a interfacesFunctions
readarray -t interfacesFunctions < <(Compiler::Implement::mergeInterfacesFunctions "${COMPILED_FILE2}")
Compiler::Implement::validateInterfaceFunctions \
  "${COMPILED_FILE2}" "${INPUT_FILE}" "${interfacesFunctions[@]}"
```

I first think about doing this

```bash
declare -a interfacesFunctions
Compiler::Implement::mergeInterfacesFunctions "${COMPILED_FILE2}" | readarray -t interfacesFunctions
```

But interfacesFunctions was empty because readarray is run in another process, to avoid this issue, I could have used
`shopt -s lastpipe`

But I finally transformed it to (the array in the same sub-shell so no issue):

```bash
Compiler::Implement::mergeInterfacesFunctions "${COMPILED_FILE2}" | {
  declare -a interfacesFunctions
  readarray -t interfacesFunctions
  Compiler::Implement::validateInterfaceFunctions \
    "${COMPILED_FILE2}" "${INPUT_FILE}" "${interfacesFunctions[@]}"
}
```

The issue with this previous solution is that commands runs in a sub-shell but using `shopt -s lastpipe` could solve this
issue.

Another solution would be to simply read the array from stdin:

```bash
declare -a interfacesFunctions
readarray -t interfacesFunctions <<<"$(
  Compiler::Implement::mergeInterfacesFunctions "${COMPILED_FILE2}"
)"
Compiler::Implement::validateInterfaceFunctions \
  "${COMPILED_FILE2}" "${INPUT_FILE}" "${interfacesFunctions[@]}"
```

#### 4.1.3. Process substitution is asynchronous

it is why you cannot retrieve the status code, a way to do that is to wait the process to finish

```bash
while read -r line; do
  echo "$line" &
done < <(
  echo 1
  sleep 1
  echo 2
  sleep 1
  exit 77
)
```

could be rewritten in

```bash
mapfile -t lines < <(
  echo 1
  sleep 1
  echo 2
  sleep 1
  exit 77
)
wait $!

for line in "${lines[@]}"; do
  echo "$line" &
done
sleep 1
wait $!
echo done
```

### 4.2. pipefail (set -o pipefail)

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

> If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or
> zero if all commands in the pipeline exit successfully. This option is disabled by default.

It is complementary with errexit, as if it not activated, the failure of command in pipe could hide the error.

**Eg**: without `pipefail` this command succeed

```bash
#!/bin/bash
set -o errexit
set +o pipefail # deactivate pipefail mode
foo | echo "a"  # 'foo' is a non-existing command
# Output:
# a
# bash: foo: command not found
# echo $? # exit code is 0
# 0
```

### 4.3. errtrace (set -E | set -o errtrace)

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

> If set, any trap on ERR is inherited by shell functions, command substitutions, and commands executed in a subShell
> environment. The ERR trap is normally not inherited in such cases.

### 4.4. nounset (set -u | set -o nounset)

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

> Treat unset variables and parameters other than the special parameters ‘@’ or ‘_’, or array variables subscripted with
> ‘@’ or ‘_’, as an error when performing parameter expansion. An error message will be written to the standard error,
> and a non-interactive shell will exit.

### 4.5. inherit error exit code in sub shells

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

let's see why using `shopt -s inherit_errexit` ?

set -e does not affect subShells created by Command Substitution. This rule is stated in Command Execution Environment:

> subShells spawned to execute command substitutions inherit the value of the -e option from the parent shell. When not
> in POSIX mode, Bash clears the -e option in such subShells.

This rule means that the following script will run to completion, in spite of INVALID_COMMAND.

```bash
#!/bin/bash
# command-substitution.sh
set -e
MY_VAR=$(
  echo -n Start
  INVALID_COMMAND
  echo -n End
)
echo "MY_VAR is $MY_VAR"
```

Output:

```bash
./command-substitution.sh: line 4: INVALID_COMMAND: command not found
MY_VAR is StartEnd
```

`shopt -s inherit_errexit`, added in Bash 4.4 allows you to have command substitution parameters inherit your set -e
from the parent script.

From the Shopt Builtin documentation:

> If set, command substitution inherits the value of the errexit option, instead of unsetting it in the subShell
> environment. This option is enabled when POSIX mode is enabled.

So, modifying command-substitution.sh above, we get:

```bash
#!/bin/bash
# command-substitution-inherit_errexit.sh
set -e
shopt -s inherit_errexit
MY_VAR=$(
  echo -n Start
  INVALID_COMMAND
  echo -n End
)
echo "MY_VAR is $MY_VAR"
```

Output:

```bash
./command-substitution-inherit_errexit.sh: line 5: INVALID_COMMAND: command not found
```

### 4.6. posix (set -o posix)

> Change the behavior of Bash where the default operation differs from the POSIX standard to match the standard (see
> [Bash POSIX Mode](https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html)). This is intended to make
> Bash behave as a strict superset of that standard.

## 5. Main function

An important best practice is to always encapsulate all your script inside a main function. One reason for this
technique is to make sure the script does not accidentally do anything nasty in the case where the script is truncated.
I often had this issue because when I change some of my bash framework functions, the pre-commit runs buildBinFiles
command that can be recompiled itself. In this case the script fails.

[another reason for doing this](https://unix.stackexchange.com/a/537397) is to not execute the file at all if there is a
syntax error.

Additionally you can add a snippet in order to avoid your function to be executed in the case where it is being source.
The following code will execute main function if called as a script passing arguments, or will just import the main
function if the script is sourced. See [this stack overflow for more details](https://stackoverflow.com/a/47613477)

```bash
#!/usr/bin/env bash

main() {
  # main script
  set -eo pipefail
}

BASH_SOURCE=".$0"
[[ ".$0" != ".$BASH_SOURCE" ]] || main "$@"
```

## 6. Arguments

- to construct complex command line, prefer to use an array
  - `declare -a cmd=(git push origin :${branch})`
  - then you can display the result using echo `"${cmd[*]}"`
  - you can execute the command using `"${cmd[@]}"`
- boolean arguments, to avoid seeing some calls like this `myFunction 0 1 0` with 3 boolean values. prefer to provide
  constants(using readonly) to make the call more clear like `myFunction arg1False arg2True arg3False` of course
  replacing argX with the real argument name. Eg: `Filters::directive "${FILTER_DIRECTIVE_REMOVE_HEADERS}"` You have to
  prefix all your constants to avoid conflicts.
- instead of adding a new arg to the function with a default value, consider using an env variable that can be easily
  overridden before calling the function. Eg: `SUDO=sudo Github::upgradeRelease ...` It avoids to have to pass previous
  arguments that were potentially defaulted.

## 7. some commands default options to use

[Check out 10-LinuxCommands-BestPractices.md](/HowTo/HowTo-Write-Bash-Scripts/10-LinuxCommands-BestPractices.md)

## 8. Variables

### 8.1. Variable declaration

- ensure we don't have any globals, all variables should be passed to the functions
- declare all variables as local in functions to avoid making them global
- local or declare multiple local a z
- `export readonly` does not work, first `readonly` then `export`
- avoid using export most of the times, export is needed only when variables has to be passed to child process.

### 8.2. variable naming convention

- env variable that aims to be exported should be capitalized with underscore
- local variables should conform to camelCase

### 8.3. Variable expansion

[Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)

`${PARAMETER:-WORD}` vs `${PARAMETER-WORD}`:

If the parameter PARAMETER is unset (was never defined) or null (empty), `${PARAMETER:-WORD}` expands to WORD, otherwise
it expands to the value of PARAMETER, as if it just was ${PARAMETER}.

If you omit the `:`(colon) like in `${PARAMETER-WORD}`, the default value is only used when the parameter is unset, not
when it was empty.

> :warning: use this latter syntax when using function arguments in order to be able to reset a value to empty string,
> otherwise default value would be applied.

#### 8.3.1. Examples

Extract directory from full file path: `directory="${REAL_SCRIPT_FILE%/*}"`

Extract file name from full file path: `fileName="${REAL_SCRIPT_FILE##*/}"`

### 8.4. Check if a variable is defined

```bash
if [[ -z ${varName+xxx} ]]; then
  # varName is not set
fi
```

Alternatively you can use this framework function `Assert::varExistsAndNotEmpty`

### 8.5. Variable default value

Always consider to set a default value to the variable that you are using.

**Eg.**: Let's see this dangerous example

```bash
# Don't Do that !!!!
rm -Rf "${TMPDIR}/etc" || true
```

This could end very badly if your script runs as root and if `${TMPDIR}` is not set, this script will result to do a
`rm -Rf /etc`

Instead you can do that

```bash
rm -Rf "${TMPDIR:-/tmp}/etc" || true
```

### 8.6. Passing variable by reference to function

Always "scope" variables passed by reference. Scoping in bash means to find a name that is a low probability that the
caller of the method names the parameter with the same name as in the function.

#### 8.6.1. Example 1

```bash
Array::setArray() {
  local -n arr=$1
  local IFS=$2 -
  # set no glob feature
  set -f
  # shellcheck disable=SC2206,SC2034
  arr=($3)
}

Array::setArray arr , "1,2,3,"
```

this example results to the following error messages

```text
bash: local: warning: arr: circular name reference
bash: warning: arr: circular name reference
bash: warning: arr: circular name reference
```

Tis example should be fixed by renaming local arr to a more "scoped" name.

```bash
Array::setArray() {
  local -n setArray_array=$1
  local IFS=$2 -
  # set no glob feature
  set -f
  # shellcheck disable=SC2206,SC2034
  setArray_array=($3)
}

Array::setArray arr , "1,2,3,"
# declare -p arr
# # output: declare -a arr=([0]="1" [1]="2" [2]="3")
```

#### 8.6.2. Example 2

A more tricky example, here the references array is affected to local array, this local array has a conflicting name.
This example does not produce any error messages.

```bash
Postman::Model::getValidCollectionRefs() {
  local configFile="$1"
  local -n getValidCollectionRefs=$2
  shift 2 || true
  local -a refs=("$@")
  # ...
  getValidCollectionRefs=("${refs[@]}")
}

local -a refs
Postman::Model::getValidCollectionRefs "file" refs a b c
declare -p refs # => declare -a refs
```

In Previous example, getValidCollectionRefs is well "scoped" but there is a conflict with the local refs array inside
the function resulting in affectation not working. The correct way to do it is to scope also the variables affected to
referenced variables

```bash
Postman::Model::getValidCollectionRefs() {
  local configFile="$1"
  local -n getValidCollectionRefsResult=$2
  shift 2 || true
  local -a getValidCollectionRefsSelection=("$@")
  # ...
  getValidCollectionRefsResult=("${getValidCollectionRefsSelection[@]}")
}

local -a refs
Postman::Model::getValidCollectionRefs "file" refs a b c
declare -p refs # => declare -a refs=([0]="a" [1]="b" [2]="c")
```

## 9. Capture output

You can use
[command substitution](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Substitution).

Eg:

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"
```

### 9.1. Capture output and test result

```bash
local output
output="$(functionThatOutputSomething "${arg1}")" || {
  echo "error"
  exit 1
}
```

### 9.2. Capture output and retrieve status code

It's advised to put it on the same line using `;`. If it was on 2 lines, other commands could be put between the command
and the status code retrieval, the status would not be the same command status.

![Capture output and retrieve status code example](example1.sh)

## 10. Array

- read each line of a file to an array `readarray -t var < /path/to/filename`

## 11. Temporary directory

use `${TMPDIR:-/tmp}`, TMPDIR variable does not always exist. or when mktemp is available, use
`dirname $(mktemp -u --tmpdir)`

The variable TMPDIR is initialized in `src/_includes/_commonHeader.sh` used by all the binaries used in this framework.

## 12. Traps

when trapping EXIT do not forget to throw back same exit code otherwise exit code of last command executed in the trap
is thrown

In this example rc variable contains the original exit code

```bash
cleanOnExit() {
  local rc=$?
  if [[ "${KEEP_TEMP_FILES:-0}" = "1" ]]; then
    Log::displayInfo "KEEP_TEMP_FILES=1 temp files kept here '${TMPDIR}'"
  elif [[ -n "${TMPDIR+xxx}" ]]; then
    Log::displayDebug "KEEP_TEMP_FILES=0 removing temp files '${TMPDIR}'"
    rm -Rf "${TMPDIR:-/tmp/fake}" >/dev/null 2>&1
  fi
  exit "${rc}"
}
trap cleanOnExit EXIT HUP QUIT ABRT TERM
```

## 13. Deal with SIGPIPE - exit code 141

[related stackoverflow post](https://stackoverflow.com/questions/19120263/why-exit-code-141-with-grep-q)

`set -o pipefail` makes exit code 141 being sent in some cases

Eg: with grep

```bash
bin/postmanCli --help | grep -q DESCRIPTION
echo "$? ${PIPESTATUS[@]}"
```

This is because grep -q exits immediately with a zero status as soon as a match is found. The zfs command is still
writing to the pipe, but there is no reader (because grep has exited), so it is sent a SIGPIPE signal from the kernel
and it exits with a status of 141.

Eg: or with head

```bash
echo "${longMultilineString}" | head -n 1
```

Finally I found this elegant [stackoverflow solution](https://unix.stackexchange.com/a/709880/582856):

```bash
handle_pipefail() {
  # ignore exit code 141 from simple command pipes
  # - use with: cmd1 | cmd2 || handle_pipefail $?
  (($1 == 141)) && return 0
  return $1
}

# then use it or test it as:
yes | head -n 1 || handle_pipefail $?
echo "ec=$?"
```

I added `handle_pipefail` as `Bash::handlePipelineFailure` in bash-tools-framework.

## 14. Performances analysis

generate a csv file with milliseconds measures

```bash
codeToMeasureStart=$(date +%s%3N)
# ... the code to measure
echo >&2 "printCurrentLine;$(($(date +%s%3N) - codeToMeasureStart))"
```

## 15. Bash Performance tips

### 15.1. Array::wrap2 performance improvement

[Commit with performance improvement](https://github.com/fchastanet/bash-tools-framework/commit/2f52d3af27170b7fff5284b5ad2793ae58af21e1)

manualTests/Array::wrap2Perf.sh:

- displaying 12 lines (558 characters) 100 times
- passed from ~10s to \<1s (improved by 90%)

performance improvement using:

- echo instead of string concatenation
- string substitution instead of calling sed on each element
- echo -e removed the need to do a loop on each character to parse ansi code and the need of Filters::removeAnsiCodes
