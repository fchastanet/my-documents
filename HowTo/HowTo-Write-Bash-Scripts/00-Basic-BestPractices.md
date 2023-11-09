# Best practices and recipes

- [1. General best practices](#1-general-best-practices)
- [2. escape quotes](#2-escape-quotes)
- [3. Bash environment options](#3-bash-environment-options)
  - [3.1. errexit (set -e | set -o errexit)](#31-errexit-set--e--set--o-errexit)
    - [3.1.1. Caveats with command substitution](#311-caveats-with-command-substitution)
    - [3.1.2. Caveats with process substitution](#312-caveats-with-process-substitution)
    - [3.1.3. Process substitution is asynchronous](#313-process-substitution-is-asynchronous)
  - [3.2. pipefail (set -o pipefail)](#32-pipefail-set--o-pipefail)
  - [3.3. errtrace (set -E | set -o errtrace)](#33-errtrace-set--e--set--o-errtrace)
  - [3.4. nounset (set -u | set -o nounset)](#34-nounset-set--u--set--o-nounset)
  - [3.5. inherit error exit code in sub shells](#35-inherit-error-exit-code-in-sub-shells)
  - [3.6. posix (set -o posix)](#36-posix-set--o-posix)
- [4. Main function](#4-main-function)
- [5. Arguments](#5-arguments)
- [6. some commands default options to use](#6-some-commands-default-options-to-use)
- [7. Bash and grep regular expressions](#7-bash-and-grep-regular-expressions)
- [9. Variables](#9-variables)
  - [9.1. Variable declaration](#91-variable-declaration)
  - [9.2. variable naming convention](#92-variable-naming-convention)
  - [9.3. Variable expansion](#93-variable-expansion)
  - [9.4. Check if a variable is defined](#94-check-if-a-variable-is-defined)
  - [9.5. Variable default value](#95-variable-default-value)
- [10. Capture output](#10-capture-output)
  - [10.1. Capture output and test result](#101-capture-output-and-test-result)
  - [10.2. Capture output and retrieve status code](#102-capture-output-and-retrieve-status-code)
- [11. Array](#11-array)
- [12. Temporary directory](#12-temporary-directory)

## 1. General best practices

- `cat << 'EOF'` avoid to interpolate variables

- use `builtin cd` instead of `cd`, `builtin pwd` instead of `pwd`, ... to avoid
  using customized aliased commands by the user In this framework, I added the
  command `unalias -a || true` to remove all eventual aliases and also ensure to
  disable aliases expansion by using `shopt -u expand_aliases`. Because aliases
  have a very special way to load. In a script file changing an alias doesn't
  occur immediately, it depends if script evaluated has been parsed yet or not.
  And alias changed in a function, will be applied outside of the function. But
  I experienced some trouble with this last rule, so I give up using aliases.

- use the right shebang, avoid `#!/bin/bash` as bash binary could be in another
  folder (especially on alpine), use this instead `#!/usr/bin/env bash`

- prefer to use printf vs echo

- check that every lowercase variable is used as local in functions
  - <https://github.com/bats-core/bats-core/issues/726>
  - <https://github.com/koalaman/shellcheck/issues/1395>
  - <https://github.com/koalaman/shellcheck/issues/468>

## 2. escape quotes

```bash
help='quiet mode, doesn'\''t display any output'

# alternative
help="quiet mode, doesn't display any output"
```

## 3. Bash environment options

See
[Set bash builtin documentation](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)

This framework uses these mode by default:

- errexit
- pipefail
- errtrace

### 3.1. errexit (set -e | set -o errexit)

Check official doc but it can be summarized like this:

> Exit immediately command returns a non-zero status.

This mode is a best practice because every non controlled command failure will
stop your program. But sometimes you need or expect a command to fail

**Eg1**: delete a folder that actually doesn't exists. Use `|| true` to ignore
the error.

```bash
rm -Rf folder || true
```

**Eg2**: a command that expects to fail if conditions are not met. Using `if`
will not stop the program on non-zero exit code.

```bash
if git diff-index --quiet HEAD --; then
  Log::displayInfo "Pull git repository '${dir}' as no changes detected"
  git pull --progress
  return 0
else
  Log::displayWarning "Pulling git repository '${dir}' avoided as changes detected"
fi
```

#### 3.1.1. Caveats with command substitution

```bash
#!/bin/bash
set -o errexit
echo `exit 1`
echo $?
```

Output:

```bash

0
```

it is because echo has succeeded. the same result occurs even with
`shopt -s inherit_errexit` (see below).

The **best practice** is to always assign command substitution to variable:

```bash
#!/bin/bash
set -o errexit
declare cmdOut
cmdOut=`exit 1`
echo "${cmdOut}"
echo $?
```

Outputs nothing because the script stopped before variable affectation, return
code is 1.

#### 3.1.2. Caveats with process substitution

Consider this example that reads each line of the output of the command passed
using process substitution in `<(...)`

```bash
parse() {
  local scriptFile="$1"
  local implementDirective
  while IFS='' read -r implementDirective; do
    echo "${implementDirective}"
  done < <(grep -E -e "^# IMPLEMENT .*$" "${scriptFile}")
}
```

If we execute this command with a non existent file, even if errexit, pipefail
and inherit_errexit are set, the command will actually succeed.

It is because process substitution launch the command as as separated process. I
didn't find any clean way to manage this using process substitution (only
workaround I found was to pass by file to pass the exit code to parent process).

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

But interfacesFunctions was empty because readarray is run in another process,
to avoid this issue, I could have used `shopt -s lastpipe`

But I finally transformed it to (the array in the same subshell so no issue):

```bash
Compiler::Implement::mergeInterfacesFunctions "${COMPILED_FILE2}" | {
  declare -a interfacesFunctions
  readarray -t interfacesFunctions
  Compiler::Implement::validateInterfaceFunctions \
    "${COMPILED_FILE2}" "${INPUT_FILE}" "${interfacesFunctions[@]}"
}
```

The issue with this previous solution is that commands runs in a subshell but
using `shopt -s lastpipe` could solve this issue.

Another solution would be to simply read the array from stdin:

```bash
declare -a interfacesFunctions
readarray -t interfacesFunctions <<<"$(
  Compiler::Implement::mergeInterfacesFunctions "${COMPILED_FILE2}"
)"
Compiler::Implement::validateInterfaceFunctions \
    "${COMPILED_FILE2}" "${INPUT_FILE}" "${interfacesFunctions[@]}"
```

#### 3.1.3. Process substitution is asynchronous

it is why you cannot retrieve the status code, a way to do that is to wait the
process to finish

```bash
while read -r line; do
  echo "$line" &
done < <(echo 1; sleep 1; echo 2; sleep 1; exit 77)
```

could be rewritten in

```bash
mapfile -t lines < <(echo 1; sleep 1; echo 2; sleep 1; exit 77)
wait $!

for line in "${lines[@]}"; do
  echo "$line" &
done
sleep 1
wait $!
echo done
```

### 3.2. pipefail (set -o pipefail)

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

> If set, the return value of a pipeline is the value of the last (rightmost)
> command to exit with a non-zero status, or zero if all commands in the
> pipeline exit successfully. This option is disabled by default.

It is complementary with errexit, as if it not activated, the failure of command
in pipe could hide the error.

**Eg**: without `pipefail` this command succeed

```bash
#!/bin/bash
set -o errexit
set +o pipefail # deactivate pipefail mode
foo | echo "a" # 'foo' is a non-existing command
# Output:
# a
# bash: foo: command not found
# echo $? # exit code is 0
# 0
```

### 3.3. errtrace (set -E | set -o errtrace)

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

> If set, any trap on ERR is inherited by shell functions, command
> substitutions, and commands executed in a subShell environment. The ERR trap
> is normally not inherited in such cases.

### 3.4. nounset (set -u | set -o nounset)

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

> Treat unset variables and parameters other than the special parameters ‘@’ or
> ‘_’, or array variables subscripted with ‘@’ or ‘_’, as an error when
> performing parameter expansion. An error message will be written to the
> standard error, and a non-interactive shell will exit.

### 3.5. inherit error exit code in sub shells

<https://dougrichardson.us/notes/fail-fast-bash-scripting.html>

let's see why using `shopt -s inherit_errexit` ?

set -e does not affect subShells created by Command Substitution. This rule is
stated in Command Execution Environment:

> subShells spawned to execute command substitutions inherit the value of the -e
> option from the parent shell. When not in POSIX mode, Bash clears the -e
> option in such subShells.

This rule means that the following script will run to completion, in spite of
INVALID_COMMAND.

```bash
#!/bin/bash
# command-substitution.sh
set -e
MY_VAR=$(echo -n Start; INVALID_COMMAND; echo -n End)
echo "MY_VAR is $MY_VAR"
```

Output:

```bash
./command-substitution.sh: line 4: INVALID_COMMAND: command not found
MY_VAR is StartEnd
```

`shopt -s inherit_errexit`, added in Bash 4.4 allows you to have command
substitution parameters inherit your set -e from the parent script.

From the Shopt Builtin documentation:

> If set, command substitution inherits the value of the errexit option, instead
> of unsetting it in the subShell environment. This option is enabled when POSIX
> mode is enabled.

So, modifying command-substitution.sh above, we get:

```bash
#!/bin/bash
# command-substitution-inherit_errexit.sh
set -e
shopt -s inherit_errexit
MY_VAR=$(echo -n Start; INVALID_COMMAND; echo -n End)
echo "MY_VAR is $MY_VAR"
```

Output:

```bash
./command-substitution-inherit_errexit.sh: line 5: INVALID_COMMAND: command not found
```

### 3.6. posix (set -o posix)

> Change the behavior of Bash where the default operation differs from the POSIX
> standard to match the standard (see
> [Bash POSIX Mode](https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html)).
> This is intended to make Bash behave as a strict superset of that standard.

## 4. Main function

An important best practice is to always encapsulate all your script inside a
main function. One reason for this technique is to make sure the script does not
accidentally do anything nasty in the case where the script is truncated. I
often had this issue because when I change some of my bash framework functions,
the pre-commit runs buildBinFiles command that can be recompiled itself. In this
case the script fails.

[another reason for doing this](https://unix.stackexchange.com/a/537397) is to
not execute the file at all if there is a syntax error.

Additionally you can add a snippet in order to avoid your function to be
executed in the case where it is being source. The following code will execute
main function if called as a script passing arguments, or will just import the
main function if the script is sourced. See
[this stack overflow for more details](https://stackoverflow.com/a/47613477)

```bash
#!/usr/bin/env bash

main() {
  # main script
  set -eo pipefail
}

BASH_SOURCE=".$0"
[[ ".$0" != ".$BASH_SOURCE" ]] || main "$@"
```

## 5. Arguments

- to construct complex command line, prefer to use an array
  - `declare -a cmd=(git push origin :${branch})`
  - then you can display the result using echo `"${cmd[*]}"`
  - you can execute the command using `"${cmd[@]}"`
- boolean arguments, to avoid seeing some calls like this `myFunction 0 1 0`
  with 3 boolean values. prefer to provide constants(using readonly) to make the
  call more clear like `myFunction arg1False arg2True arg3False` of course
  replacing argX with the real argument name. Eg:
  `Filters::directive "${FILTER_DIRECTIVE_REMOVE_HEADERS}"` You have to prefix
  all your constants to avoid conflicts.

## 6. some commands default options to use

- <https://dougrichardson.us/notes/fail-fast-bash-scripting.html> but set -o
  nounset is not usable because empty array are considered unset
- always use `sed -E`
- avoid using grep -P as it is not supported on alpine, prefer using -E

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD033 -->

## 7. <a name="regularExpressions"></a>Bash and grep regular expressions

<!-- markdownlint-restore -->

- grep regular expression [A-Za-z] matches by default accentuated character, it
  you don't want to match them, use the environment variable `LC_ALL=POSIX`,
  - Eg: `LC_ALL=POSIX grep -E -q '^[A-Za-z_0-9:]+$'`
  - I added `export LC_ALL=POSIX` in all my headers, it can be overridden using
    a subShell

## 9. Variables

### 9.1. Variable declaration

- ensure we don't have any globals, all variables should be passed to the
  functions
- declare all variables as local in functions to avoid making them global
- local or declare multiple local a z
- `export readonly` does not work, first `readonly` then `export`
- avoid using export most of the times, export is needed only when variables has
  to be passed to child process.

### 9.2. variable naming convention

- env variable that aims to be exported should be capitalized with underscore
- local variables should conform to camelCase

### 9.3. Variable expansion

`${PARAMETER:-WORD}` vs `${PARAMETER-WORD}`:

If the parameter PARAMETER is unset (was never defined) or null (empty),
`${PARAMETER:-WORD}` expands to WORD, otherwise it expands to the value of
PARAMETER, as if it just was ${PARAMETER}.

If you omit the `:`(colon) like in `${PARAMETER-WORD}`, the default value is
only used when the parameter is unset, not when it was empty.

> :warning: use this latter syntax when using function arguments in order to be
> able to reset a value to empty string, otherwise default value would be
> applied.

### 9.4. Check if a variable is defined

```bash
if [[ -z ${varName+xxx} ]]; then
  # varName is not set
fi
```

Alternatively you can use this framework function `Assert::varExistsAndNotEmpty`

### 9.5. Variable default value

Always consider to set a default value to the variable that you are using.

**Eg.**: Let's see this dangerous example

```bash
# Don't Do that !!!!
rm -Rf "${TMPDIR}/etc" || true
```

This could end very badly if your script runs as root and if `${TMPDIR}` is not
set, this script will result to do a `rm -Rf /etc`

Instead you can do that

```bash
rm -Rf "${TMPDIR:-/tmp}/etc" || true
```

## 10. Capture output

You can use
[command substitution](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Substitution).

Eg:

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"
```

### 10.1. Capture output and test result

```bash
local output
output="$(functionThatOutputSomething "${arg1}")" || {
  echo "error"
  exit 1
}
```

### 10.2. Capture output and retrieve status code

It's advised to put it on the same line using `;`. If it was on 2 lines, other
commands could be put between the command and the status code retrieval, the
status would not be the same command status.

```bash
local output
output="$(functionThatOutputSomething "${arg1}")"; status=$?
```

## 11. Array

- read each line of a file to an array `readarray -t var < /path/to/filename`

## 12. Temporary directory

use `${TMPDIR:-/tmp}`, TMPDIR variable does not always exist. or when mktemp is
available, use `dirname $(mktemp -u --tmpdir)`

The variable TMPDIR is initialized in `src/_includes/_commonHeader.sh` used by
all the binaries used in this framework.
