use Test::Tester;
use Test::More;
use Test::Spelling;
use utf8;

BEGIN {
    if (!Test::Spelling::HAVE_UTF8) {
        plan skip_all => "skipping utf8 test for perls before 5.8.1";
    }
}

sub test_encoding {
  my ($name, $stopword) = @_;
  my $file = "t/corpus/$name.pm";

  ok utf8::is_utf8($stopword), 'stopword is a utf8 character string';

  test_spell_check($file, "$name pod file before stopword", $stopword);

  # only add this stopword for the next test (so that we can run it again)
  local %Pod::Wordlist::Wordlist = %Pod::Wordlist::Wordlist;
  add_stopwords($stopword);

  test_spell_check($file, "$name pod file after stopword");
}

sub test_spell_check {
  my ($file, $desc, $errors) = @_;
  check_test(sub { pod_file_spelling_ok($file, $desc) }, {
      ok   => $errors ? 0 : 1,
      name => $desc,
      diag => $errors ? "Errors:\n    $errors" : '',
  });
}

if( has_working_spellchecker() ){
  test_encoding(utf8 => "Simões");
}

set_spell_cmd( $^X . qq< -alne "\@words = grep { /[^[:ascii:]]/ } \@F; print join q[], \@words if \@words"> );

test_encoding(utf8 => "Simões");

# aspell won't find this one, but our fake checker will
test_encoding('koi8-r' => "Код");

done_testing;
