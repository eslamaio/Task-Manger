# Task-Manger
Task Manager with Rofi and Dmenu

./task_manager.sh


nots:
The expression 2>/dev/null is used in Bash to suppress error messages by redirecting standard error (stderr) to /dev/null, a special null device that discards all input.


1. Breakdown of Redirection Operators
Symbol	Description
>	Redirect stdout (standard output, descriptor 1)
2>	Redirect stderr (standard error, descriptor 2)
&>	Redirect both stdout and stderr
/dev/null	A special device file that discards anything written to it
Thus, 2>/dev/null means:

Redirect stderr (file descriptor 2) to /dev/null, effectively hiding all error messages.

Redirect stderr to a file
find ~ -name "*.pdf" 2> errors.log
Redirect stdout and stderr to separate files
find ~ -name "*.pdf" > results.txt 2> errors.log
Saves valid results in results.txt.
Saves error messages in errors.log.
Redirect both stdout and stderr
find ~ -name "*.pdf" &>/dev/null
