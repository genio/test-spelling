use Test::Tester;
use Test::More;
use Test::Spelling;
use utf8;

BEGIN {
    if ($] < 5.008001) {
        plan skip_all => "skipping utf8 test for perls before 5.8.1";
    }
    if (!has_working_spellchecker()) {
        plan skip_all => "no working spellchecker found";
    }
}

my $author = "Simões";
ok utf8::is_utf8($author), 'author is a utf8 character string';

my $spell_check = sub { pod_file_spelling_ok('t/corpus/utf8.pm', 'utf8 pod file') };

check_test($spell_check, {
    ok   => 0,
    name => 'utf8 pod file',
    # diag is a byte string
    diag => do { my $diag = "Errors:\n    $author"; utf8::encode($diag); $diag },
});

add_stopwords($author);

check_test($spell_check, {
    ok   => 1,
    name => 'utf8 pod file',
    diag => '',
});

done_testing;
