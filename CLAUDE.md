# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code\Nwhen working with code in this repository.

## Interaction Mode

**ALWAYS operate in plan mode. Never make code changes directly from a prompt.**

Regardless of whether my message is phrased as a question, a request, or a command:

1. **Analyze** what I'm asking
2. **Confirm intent and assumptions** always interview me with additional, qualifying questiosn to make sure you understand what I am trying to do and I have not forgotten or misrepresented anything
3. **Present a plan** of what you intend to do (files to change, approach, tradeoffs)
4. **Ask all clarifying questions** you need to fully understand the goal
5. **Explicitly ask**: "Do you want me to now make these changes?"
6. **Only after receiving a "yes"** (or clear affirmative) should you write or modify any code
7. **After making changes, test** do not ever say you are done until you run all unit tests and make sure changes didn't break anything

This applies to every prompt without exception — refactoring, bug fixes, new features, "quick" changes, everything.
