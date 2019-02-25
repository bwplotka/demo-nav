# demo-nav

The main goal of this small lib is to enable clear, reproducible, scripted and structured live demo presentations, without sacrificing the *flexibility*. 

Why flexibility matters? It is almost *always* the case that you need to adjust the presentation on the fly, e.g:
* You did some sequence of commands too fast and you need to retry.
* In the Q&A someone asks you to explain certain commands in sequence.
* You are short on time and you want to skip few less important parts of demo.
* Something unexpected happen. You want to pause the flow and continue after quick fix.

You can find a video of the live demo I performed using this handy tool at FOSDEM 2019 [here](https://fosdem.org/2019/schedule/event/thanos_transforming_prometheus_to_a_global_scale_in_a_seven_simple_steps/) 

## Features:

* Script whole demo as ordered set of commands.
* Hide irrelevant details: execute one command, but show different (e.g simplified) command. Must have when you are short of time. 
* Executed command stays on the screen (if chosen) to guide the audience on what was invoked.
* Once demo started, NO typing is required! Navigate through commands using single keyboard keys:
    * Execute written command by pressing `enter`.
    * Skip current command and get to the previous one by pressing `p`.
    * Skip current command and get to the next one by pressing `n`.
    * Skip current command and get to the beginning of demo by pressing `b`.
    * Skip current command and get to the end of demo by pressing `e`.
    * Quit by pressing `q` or `Ctrl+C`.
* Once exitted, script will remember the last position, which allows easy continuation.
* Optionally mimick the typing if really need to ;> 

## Tested on:

* Ubuntu 18.04, zsh 5.4.2-3ubuntu3.1 (CI tests in progress)

## Oh My.. Why shell?

I am asking this question myself everyday as well (: It's ugly, and it does not work on every platform. But it is quick 
to adjust and iterate. Also, natively you run the commands in terminal anyway so that's why - no need for yet another DSL. Python might be a better fit?

*Note* that I am not a bash magician, so happy to take contributions to improve this lib - as long as functionality stays the same.

## How to use it?

* Import `demo-example.sh` in your bash script: `. demo-example.sh`
* Use `r` or `rc` to register commands.
* Invoke `navigate` at the very end.
* Run your script. 

See [full example demo script with docs](./example/demo-example.sh)

## Credits

This was initially inspired by https://github.com/paxtonhare/demo-magic, so kudos to @paxtonhare