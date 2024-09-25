## Stains

This is the repostiory for *Stains*, my project for module 1 of the CPSC 334 curriculum. 

In order to run this program, you should have:

- A Raspberry Pi. I believe mine has 4 GB of RAM so anything of or above should work fine.
- Processing v.4. The Raspberry Pi has `aarch64`, so you should make sure to install the correct version for the correct platform. There is a separate download link for the Pi vs. some other Linux download. Unpack this `.tar.gz` file you receive. This folder should contain the compiler for the included `.pde` file.

In `~/.config/wayfire.ini`, you should add the following code (or append to `autostart` if the header already exists).
```
[autostart]
prcss = /path/to/shellscript/prcs.sh
```

The `prcs.sh` should be executable and contain the following:

```sh
/path/to/processing/processing-java --sketch=/path/to/sketch/folder --run
```

It should run on start up now, or if you just want to run it immediately, you could run the Processing IDE and run it from there or just run the bash script from the terminal.

As for the picking colors from the filename, you should try changing the filename to the directory where you have stored the photos. I have them here for convenience, but right now, they don't run out of the box. Give it a try. Use your own photos, too!
