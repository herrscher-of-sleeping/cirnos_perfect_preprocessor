# Cirno's perfect preprocessor
A simple preprocessor with the following rules:
* It processes files line-by-line
If it finds an instruction in a line, the whole line is treated as an instruction
and its contents outside of it is being discarded. This is to prevent going as deep
as creating/using real parsers for real languages. So if it's a real programming language,
you'll have to use single-line comment for that to prevent syntax checkers going crazy.
But that was the intention anyway.
* It has 4 available instructions:
  * #ifeq key value — accept contents in ifeq block only if passed value matches such in ifeq arguments
  * #ifneq key value — accept contents in ifeq block only if passed value doesn't match such in ifeq arguments
  * #else — inverts ifeq/ifneq block from the next line until the end of it
  * #endif — closes the block
* For ifeq/ifneq it uses values passed in command-line arguments like this:
```
$ cirpp key1=value1 key2=value2
```
* All keys and values are strings consisting only of latin alphabet characters, numbers and underscore

# Example usage
```
// #ifeq GNOME_VERSION 45
... do Gnome 45 things
// #else
... do pre-45 Gnome things
// #endif
```

```sh
# preprocess source for Gnome 45
$ cat extension.js | cirpp GNOME_VERSION=45 > build/extension.js
# preprocess source for Gnome 44
$ cat extension.js | cirpp > build/extension.js
```

# License
MIT
