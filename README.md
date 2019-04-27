# NAME

Test::Spelling - check for spelling errors in POD files

# SYNOPSIS

```perl
use Test::More;
BEGIN {
    plan skip_all => "Spelling tests only for authors"
        unless -d 'inc/.author';
}

use Test::Spelling;
all_pod_files_spelling_ok();
```

# DESCRIPTION

`Test::Spelling` lets you check the spelling of a POD file, and report
its results in standard `Test::More` fashion. This module requires a
spellcheck program such as `spell`, `aspell`, `ispell`, or `hunspell`.

```perl
use Test::Spelling;
pod_file_spelling_ok('lib/Foo/Bar.pm', 'POD file spelling OK');
```

Note that it is a bad idea to run spelling tests during an ordinary CPAN
distribution install, or in a package that will run in an uncontrolled
environment. There is no way of predicting whether the word list or spellcheck
program used will give the same results. You **can** include the test in your
distribution, but be sure to run it only for authors of the module by guarding
it in a `skip_all unless -d 'inc/.author'` clause, or by putting the test in
your distribution's `xt/` directory. Anyway, people installing your module
really do not need to run such tests, as it is unlikely that the documentation
will acquire typos while in transit. :-)

You can add your own stop words, which are words that should be ignored by the
spell check, like so:

```
add_stopwords(qw(asdf thiswordiscorrect));
```

Adding stop words in this fashion affects all files checked for the remainder of
the test script. See [Pod::Spell](https://metacpan.org/pod/Pod::Spell) (which this module is built upon) for a
variety of ways to add per-file stop words to each .pm file.

If you have a lot of stop words, it's useful to put them in your test file's
`DATA` section like so:

```perl
use Test::Spelling;
add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__END__
folksonomy
Jifty
Zakirov
```

To maintain backwards compatibility, comment markers and some whitespace are
ignored. In the near future, the preprocessing we do on the arguments to
[add\_stopwords](https://metacpan.org/pod/add_stopwords) will be changed and documented properly.

# FUNCTIONS

## all\_pod\_files\_spelling\_ok( \[@files/@directories\] )

Checks all the files for POD spelling. It gathers ["all\_pod\_files"](#all_pod_files) on each
file/directory, and declares a ["plan" in Test::More](https://metacpan.org/pod/Test::More#plan) for you (one test for each
file), so you must not call `plan` yourself.

If `@files` is empty, the function finds all POD files in the `blib`
directory if it exists, or the `lib` directory if it does not. A POD file is
one that ends with `.pod`, `.pl`, `.plx`, or `.pm`; or any file where the
first line looks like a perl shebang line.

If there is no working spellchecker (determined by
["has\_working\_spellchecker"](#has_working_spellchecker)), this test will issue a "skip all" directive.

If you're testing a distribution, just create a `t/pod-spell.t` with the code
in the ["SYNOPSIS"](#synopsis).

Returns true if every POD file has correct spelling, or false if any of them fail.
This function will show any spelling errors as diagnostics.

## pod\_file\_spelling\_ok( $filename\[, $testname \] )

`pod_file_spelling_ok` will test that the given POD file has no spelling
errors.

When it fails, `pod_file_spelling_ok` will show any spelling errors as
diagnostics.

The optional second argument is the name of the test.  If it is
omitted, `pod_file_spelling_ok` chooses a default test name "POD
spelling for `$filename`".

## all\_pod\_files( \[@dirs\] )

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

## add\_stopwords(@words)

Add words that should be skipped by the spellcheck. Note that [Pod::Spell](https://metacpan.org/pod/Pod::Spell)
already skips words believed to be code, such as everything in verbatim
(indented) blocks and code marked up with `` `...` ``, as well as some common
Perl jargon.

## has\_working\_spellchecker

`has_working_spellchecker` will return `undef` if there is no working
spellchecker, or a true value (the spellchecker command itself) if there is.
The module performs a dry-run to determine whether any of the spellcheckers it
can will use work on the current system. You can use this to skip tests if
there is no spellchecker. Note that ["all\_pod\_files\_spelling\_ok"](#all_pod_files_spelling_ok) will do this
for you.

A full list of spellcheckers which this method might test can be found in the
source of the `spellchecker_candidates` method.

## set\_spell\_cmd($command)

If you want to force this module to use a particular spellchecker, then you can
specify which one with `set_spell_cmd`. This is useful to ensure a more
consistent lexicon between developers, or if you have an unusual environment.
Any command that takes text from standard input and prints a list of misspelled
words, one per line, to standard output will do.

## set\_pod\_file\_filter($code)

If your project has POD documents written in languages other than English, then
obviously you don't want to be running a spellchecker on every Perl file.
`set_pod_file_filter` lets you filter out files returned from
["all\_pod\_files"](#all_pod_files) (and hence, the documents tested by
["all\_pod\_files\_spelling\_ok"](#all_pod_files_spelling_ok)).

```perl
set_pod_file_filter(sub {
    my $filename = shift;
    return 0 if $filename =~ /_ja.pod$/; # skip Japanese translations
    return 1;
});
```

## set\_pod\_parser($object)

By default [Pod::Spell](https://metacpan.org/pod/Pod::Spell) is used to generate text suitable for spellchecking
from the input POD.  If you want to use a different parser, perhaps a
customized subclass of [Pod::Spell](https://metacpan.org/pod/Pod::Spell), call `set_pod_parser` with an object
that is-a [Pod::Parser](https://metacpan.org/pod/Pod::Parser).  Be sure to create a fresh parser object for
each file (don't use this with `all_pod_files_spelling_ok`).

# SEE ALSO

[Pod::Spell](https://metacpan.org/pod/Pod::Spell)

# ORIGINAL AUTHOR

Ivan Tubert-Brohman `<itub@cpan.org>`

Heavily based on [Test::Pod](https://metacpan.org/pod/Test::Pod) by Andy Lester and brian d foy.

# MAINTAINER

Shawn M Moore `<code@sartak.org>`

# COPYRIGHT

Copyright 2005, Ivan Tubert-Brohman, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
