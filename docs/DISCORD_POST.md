# Discord post — `#omarchy-security`

Five messages, posted in order, **one Discord message each**.

## How to post them

Each message lives in its own file under [`docs/discord/`](discord/). The file
*is* the message: nothing in it is an instruction, a marker, or a note to you.
Copy the whole file, paste it, send. Then the next one.

The safest way is to never select text by hand at all:

```bash
wl-copy < docs/discord/1-hook.txt        # then Ctrl+V in Discord, send
wl-copy < docs/discord/2-proposals.txt   # send
wl-copy < docs/discord/3-flow.txt        # send
wl-copy < docs/discord/4-audit.txt       # send
wl-copy < docs/discord/5-ask.txt         # send
```

| # | File | Chars | What it does |
| :-- | :--- | --: | :--- |
| 1 | [`1-hook.txt`](discord/1-hook.txt) | 884 | The problem, and the list of what is *not* being proposed |
| 2 | [`2-proposals.txt`](discord/2-proposals.txt) | 1152 | A, B and C, each with its own counter-argument |
| 3 | [`3-flow.txt`](discord/3-flow.txt) | 1385 | The architecture diagram and the three states |
| 4 | [`4-audit.txt`](discord/4-audit.txt) | 1498 | What the self-audit found — the message that earns the rest |
| 5 | [`5-ask.txt`](discord/5-ask.txt) | 631 | Links and the three open questions |

## Why they are separate files

An earlier version of this page put the messages in fenced code blocks with
instructions in between. Both got pasted into the channel — the meta-text about
how to paste ended up in the public post, and the five messages merged into one.
A file containing nothing but the payload cannot fail that way.

## Constraints these respect

**2000 characters per message.** Discord's hard cap. The largest here is 1498.

**No Markdown tables.** Discord does not render them. It does render `#`/`##`
headings, `**bold**`, `*italics*`, lists, inline `code`, and fenced code blocks.

**Message 3 carries its own fence.** Pasted text containing triple-backtick
lines is parsed by Discord as a code block, so the diagram arrives formatted
without you typing anything. That is why it is one paste, not two.

**No emoji inside the code block.** Emoji are not monospaced — one inside the
diagram shifts every line after it, which is what broke the first attempt. The
diagram is plain ASCII, 74 columns at its widest so it does not wrap. The line
that does use emoji sits outside the block.

## If you already posted a broken version

Delete those messages rather than editing them. Editing leaves an "(edited)"
marker on a wall of text people have already scrolled past; a clean repost of
five short messages reads the way it was meant to.
