Kommissar - Lisp Browser Automation
===========
![sample](https://github.com/olewhalehunter/kommissar/blob/master/screenshot.png?raw=true)
Kommissar is a

1. browser automation development environment using Emacs and an interactive browser addon
2. Common Lisp library for generating and maintaining web user simulation applications

You can use kommissar to:
* make bots
* create web verification tests
* control browsers from a shell/console/scripts
* interactively develop browser applications
* use Emacs as an internet browser
* combine web and local applications into a single runtime

It is currently under without an installer, to try to run it:
* install and start MozRepl
* install kommissar-utils.js in the js folder as a Scriptish userscript
* load kommissar.el in emacs
* eval commands in kommissar.lisp with SLIME

The end product will include an option for a monolithic GUI intended for non-emacs users with the ability for laypersons to create their own browser scripts, bots, and workflows, and to have a repository for users to share, collaborate, and work on a collection of scripts.

