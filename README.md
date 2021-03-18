[![Actions Status](https://github.com/genio/test-spelling/workflows/linux/badge.svg)](https://github.com/genio/test-spelling/actions)
[![Actions Status](https://github.com/genio/test-spelling/workflows/macos/badge.svg)](https://github.com/genio/test-spelling/actions)
[![Actions Status](https://github.com/genio/test-spelling/workflows/windows/badge.svg)](https://github.com/genio/test-spelling/actions)

# NAME

Test::Spelling - Check for spelling errors in POD files

# SYNOPSIS

Place a file, `pod-spell.t` in your distribution's `xt/author` directory:

```perl
use strict;
use warnings;
use Test::More;

use Test::Spelling;
use Pod::Wordlist;

add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( bin lib ) );

__DATA__
SomeBizarreWord
YetAnotherBIzarreWord
```

Or, you can gate the spelling test with the environment variable `AUTHOR_TESTING`:

```perl
use strict;
use warnings;
use Test::More;

BEGIN {
    plan skip_all => "Spelling tests only for authors"
        unless $ENV{AUTHOR_TESTING};
}

use Test::Spelling;
use Pod::Wordlist;

all_pod_files_spelling_ok();
```

# DESCRIPTION

[Test::Spelling](https://metacpan.org/pod/Test%3A%3ASpelling) lets you check the spelling of a `POD` file, and report
its results in standard [Test::More](https://metacpan.org/pod/Test%3A%3AMore) fashion. This module requires a
spellcheck program such as [Hunspell](http://hunspell.github.io/),
`aspell`, `spell`, or, `ispell`. We suggest using Hunspell.

```perl
use Test::Spelling;
pod_file_spelling_ok('lib/Foo/Bar.pm', 'POD file spelling OK');
```

Note that it is a bad idea to run spelling tests during an ordinary CPAN
distribution install, or in a package that will run in an uncontrolled
environment. There is no way of predicting whether the word list or spellcheck
program used will give the same results. You **can** include the test in your
distribution, but be sure to run it only for authors of the module by guarding
it in a `skip_all unless $ENV{AUTHOR_TESTING}` clause, or by putting the test in
your distribution's `xt/author` directory. Anyway, people installing your module
really do not need to run such tests, as it is unlikely that the documentation
will acquire typos while in transit.

You can add your own stop words, which are words that should be ignored by the
spell check, like so:

```
add_stopwords(qw(asdf thiswordiscorrect));
```

Adding stop words in this fashion affects all files checked for the remainder of
the test script. See [Pod::Spell](https://metacpan.org/pod/Pod%3A%3ASpell) (which this module is built upon) for a
variety of ways to add per-file stop words to each .pm file.

If you have a lot of stop words, it's useful to put them in your test file's
`DATA` section like so:

```perl
use strict;
use warnings;
use Test::More;

use Test::Spelling;
use Pod::Wordlist;

add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__DATA__
folksonomy
Jifty
Zakirov
```

To maintain backwards compatibility, comment markers and some whitespace are
ignored. In the near future, the preprocessing we do on the arguments to
["add\_stopwords" in Test::Spelling](https://metacpan.org/pod/Test%3A%3ASpelling#add_stopwords) will be changed and documented properly.

# FUNCTIONS

[Test::Spelling](https://metacpan.org/pod/Test%3A%3ASpelling) makes the following methods available.

## add\_stopwords

```
add_stopwords(@words);
add_stopwords(<DATA>); # pull in stop words from the DATA section
```

Add words that should be skipped by the spell checker. Note that [Pod::Spell](https://metacpan.org/pod/Pod%3A%3ASpell)
already skips words believed to be code, such as everything in verbatim
(indented) blocks and code marked up with `` `...` ``, as well as some common
Perl jargon.

## all\_pod\_files

```
all_pod_files();
all_pod_files(@list_of_directories);
```

Returns a list of all the Perl files in each directory and its subdirectories,
recursively. If no directories are passed, it defaults to `blib` if `blib`
exists, or else `lib` if not. Skips any files in `CVS` or `.svn` directories.

A Perl file is:

- Any file that ends in `.PL`, `.pl`, `.plx`, `.pm`, `.pod` or `.t`.
- Any file that has a first line with a shebang and "perl" on it.

Furthermore, files for which the filter set by ["set\_pod\_file\_filter"](#set_pod_file_filter) return
false are skipped. By default, this filter passes everything through.

The order of the files returned is machine-dependent.  If you want them
sorted, you'll have to sort them yourself.

## all\_pod\_files\_spelling\_ok

```
all_pod_files_spelling_ok(@list_of_files);
all_pod_files_spelling_ok(@list_of_directories);
```

Checks all the files for `POD` spelling. It gathers
["all\_pod\_files" in Test::Spelling](https://metacpan.org/pod/Test%3A%3ASpelling#all_pod_files) on each file/directory, and
declares a ["plan" in Test::More](https://metacpan.org/pod/Test%3A%3AMore#plan) for you (one test for each file), so you
must not call `plan` yourself.

If `@files` is empty, the function finds all `POD` files in the `blib`
directory if it exists, or the `lib` directory if it does not. A `POD` file is
one that ends with `.pod`, `.pl`, `.plx`, or `.pm`; or any file where the
first line looks like a perl shebang line.

If there is no working spellchecker (determined by
[Test:Spelling/"has\_working\_spellchecker"](Test:Spelling/&#x22;has_working_spellchecker&#x22;)), this test will issue a
`skip all` directive.

If you're testing a distribution, just create an `xt/author/pod-spell.t` with the code
in the ["SYNOPSIS"](#synopsis).

Returns true if every `POD` file has correct spelling, or false if any of them fail.
This function will show any spelling errors as diagnostics.

\* **NOTE:** This only tests using bytes. This is not decoded content, etc. Do
not expect this to work with Unicode content, for example. This uses an open
with no layers and no decoding.

## get\_pod\_parser

```perl
# a Pod::Spell -like object
my $object = get_pod_parser();
```

Get the object we're using to parse the `POD`. A new [Pod::Spell](https://metacpan.org/pod/Pod%3A%3ASpell) object
should be used for every file. People providing custom parsers will have
to do this themselves.

## has\_working\_spellchecker

```perl
my $cmd = has_working_spellchecker;
```

`has_working_spellchecker` will return `undef` if there is no working
spellchecker, or a true value (the spellchecker command itself) if there is.
The module performs a dry-run to determine whether any of the spellcheckers it
can will use work on the current system. You can use this to skip tests if
there is no spellchecker. Note that ["all\_pod\_files\_spelling\_ok"](#all_pod_files_spelling_ok) will do this
for you.

A full list of spellcheckers which this method might test can be found in the
source of the `spellchecker_candidates` method.

## pod\_file\_spelling\_ok

```
pod_file_spelling_ok('/path/to/Foo.pm');
pod_file_spelling_ok('/path/to/Foo.pm', 'Foo is well spelled!');
```

`pod_file_spelling_ok` will test that the given `POD` file has no spelling
errors.

When it fails, `pod_file_spelling_ok` will show any spelling errors as
diagnostics.

The optional second argument is the name of the test.  If it is
omitted, `pod_file_spelling_ok` chooses a default test name
`POD spelling for $filename`.

\* **NOTE:** This only tests using bytes. This is not decoded content, etc. Do
not expect this to work with Unicode content, for example. This uses an open
with no layers and no decoding.

## set\_pod\_file\_filter

```perl
# code ref
set_pod_file_filter(sub {
    my $filename = shift;
    return 0 if $filename =~ /_ja.pod$/; # skip Japanese translations
    return 1;
});
```

If your project has `POD` documents written in languages other than English, then
obviously you don't want to be running a spellchecker on every Perl file.
`set_pod_file_filter` lets you filter out files returned from
["all\_pod\_files"](#all_pod_files) (and hence, the documents tested by
["all\_pod\_files\_spelling\_ok"](#all_pod_files_spelling_ok)).

## set\_pod\_parser

```perl
my $object = Pod::Spell->new();
set_pod_parser($object);
```

By default [Pod::Spell](https://metacpan.org/pod/Pod%3A%3ASpell) is used to generate text suitable for spellchecking
from the input POD.  If you want to use a different parser, perhaps a
customized subclass of [Pod::Spell](https://metacpan.org/pod/Pod%3A%3ASpell), call `set_pod_parser` with an object
that is-a [Pod::Parser](https://metacpan.org/pod/Pod%3A%3AParser).  Be sure to create a fresh parser object for
each file (don't use this with ["all\_pod\_files\_spelling\_ok"](#all_pod_files_spelling_ok)).

## set\_spell\_cmd

```
set_spell_cmd('hunspell -l'); # current preferred
set_spell_cmd('aspell list');
set_spell_cmd('spell');
set_spell_cmd('ispell -l');
```

If you want to force this module to use a particular spellchecker, then you can
specify which one with `set_spell_cmd`. This is useful to ensure a more
consistent lexicon between developers, or if you have an unusual environment.
Any command that takes text from standard input and prints a list of misspelled
words, one per line, to standard output will do.

# SEE ALSO

[Pod::Spell](https://metacpan.org/pod/Pod%3A%3ASpell)

# AUTHOR

Ivan Tubert-Brohman `<itub@cpan.org>`

Heavily based on [Test::Pod](https://metacpan.org/pod/Test%3A%3APod) by Andy Lester and brian d foy.

# COPYRIGHT & LICENSE

Copyright 2005, Ivan Tubert-Brohman, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
