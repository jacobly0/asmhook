# ASMHOOK

This tiny program installs a hook that restores assembly functionality on OS versions above 5.5.0.

## Compatibility

- TI-83 Premium CE
- TI-84 Plus CE
- TI-84 Plus CE-T

If it doesn't have exactly `CE` in the name then it is not supported!

- Any OS version

## Compile

    git clone https://github.com/jacobly0/asmhook.git
    cd asmhook
    make # or make unprot to make an unprotected program

## FAQ

### Why?

This simply restores functionality that already existed on previous OS versions.

### Can't I just use Cesium instead?

Yes.

### Can I run at the same time as Cesium?

Probably, but whichever program you installed last will overwrite functionality of the other one.

### How long does it last?

Until the next ram clear, but it persists through Garbage Collects.

### Which one should I install.

Just use ASMHOOK.8xp if you are able to transfer it.  If you are using TI-Connect CE for Chrome OS then you may have to use ASMHOOK_unprot.8xp instead.

### How do I install?

Assembly programs were removed from recent OS versions, which are also the only versions for which this program is actually useful.  This means that you have to be able to run assembly programs in order to run this program that allows you to be able to run assembly programs.  Therefore, you'll need some sort of jailbreak-like program first, in order to bootstrap running this program.

### What does ERR:INVALID mean?

You have recent OS that disables assembly programs, see the previous answer.

### It didn't do anything when I ran it!

It's not supposed to.  An easy way to test if it worked is to try running itself from the homescreen afterwards.
