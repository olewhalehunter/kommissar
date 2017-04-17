Kommissar - Lisp Browser Automation
===========
![sample](https://github.com/olewhalehunter/kommissar/blob/master/screenshot.png?raw=true)
Kommissar is a

* browser automation development environment using Emacs and an interactive browser addon
* Common Lisp/ParenScript library for generating and maintaining web user simulation applications

Kommissar's primary function is to compile lisp userscripts from manually recorded actions in the browser that you can then use to build web-oriented programs or bots.

# Uses
* web botting
* test automation
* Emacs as an internet browser
* controlling browsers from CLI
* interactive development of browser applications with ParenScript
* pull web and local applications into a single runtime

# Setup
* install and start MozRepl
* install kommissar-utils.js in the js folder as a Scriptish userscript
* load kommissar.el in emacs
* eval commands in kommissar.lisp with SLIME
* to record a script, use the record tool with F2 in the browser, then save it as a common lisp program by evaluating (store-workflow "workflow-name.lisp")

The end product will include an option for a monolithic GUI intended for non-emacs users with the ability for laypersons to create their own browser scripts, bots, and workflows, and to have a repository for users to share, collaborate, and work on a collection of scripts and constructed site interaction APIs.


# To Do

* better ParenScript support
* record tab changes
* action-by-action runthrough of recording
* sequences of elements by interactive xpath regex highlight
* re-edit/re-order? actions in gui
