Simple command line logging script to log a one-off note.

Basically used for simple things like:

* Project-based notes
    * Quick links to resources, references
    * Small local project TODO's
    * Reminders and gotchas
    * Logging progress, short micro-journaling to record check points in
      progress.
* Simple quick references (in the home directory)
    * Reminders on system configuration todo's
    * Refreshers on simple tasks that you only do a few times a year

I recommend using a short alias like `l` or `n` ("note").

Usage
-----

~~~sh
log.sh -c                     # creates the empty file .log.log in the
                              #   current directory

log.sh hey, this is a note!   # logs the line "hey, this is a note!"

cat .log.log
# [Sun Sep 29 16:07:21 PDT 2013]  hey, this is a note!

mkdir test; cd test

log.sh logging from ./test!   # logs the line to the original .log.log, one
                              #   directory up.  traverses up directory tree
                              #   until it finds a valid .log file

log.sh -l                     # outputs the contents of the active .log file
# Log file: ../.log.log
# [Sun Sep 29 16:07:21 PDT 2013]  hey, this is a note!
# [Sun Sep 29 16:10:38 PDT 2013]  (./test) logging from ./test!

cd ../

log.sh -t "buy milk"

log.sh -l
# Log file: ./.log.log
# [Sun Sep 29 16:07:21 PDT 2013]  hey, this is a note!
# [Sun Sep 29 16:10:38 PDT 2013]  (./test) logging from ./test!
# [Sun Sep 29 16:14:03 PDT 2013]  [ ] buy milk

log.sh -e                     # opens active log file in your favorite text
                              #   editor
~~~

Full usage can be found by typing

~~~sh
log.sh -t
~~~

