use inc::Module::Install;
use Module::Install::GithubMeta;
use Module::Install::ManifestSkip;
use Module::Install::AutoManifest;

name       'Test-Spelling';
all_from   'lib/Test/Spelling.pm';
githubmeta;

requires 'Pod::Spell' => '1.01';

manifest_skip;
auto_manifest;
WriteAll;

