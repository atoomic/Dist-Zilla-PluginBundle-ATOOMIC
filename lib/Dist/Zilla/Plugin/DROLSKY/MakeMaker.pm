package Dist::Zilla::Plugin::DROLSKY::MakeMaker;

use v5.10;

use strict;
use warnings;
use autodie;
use namespace::autoclean;

our $VERSION = '0.91';

use File::Which qw( which );

use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

has has_xs => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

with 'Dist::Zilla::Plugin::DROLSKY::Role::CoreCounter';

# Dist::Zilla provides no way to pass a `-j` option when running dzil release
# but I really would like faster releases.
sub default_jobs {
    return shift->_core_count;
}

override _build_WriteMakefile_dump => sub {
    my $self = shift;

    my $dump = super();
    return $dump unless $self->has_xs;

    $dump .= <<'EOF';
my $gcc_warnings = $ENV{AUTHOR_TESTING} ? q{ -Wall -Werror} : q{};
$WriteMakefileArgs{DEFINE}
    = ( $WriteMakefileArgs{DEFINE} || q{} ) . $gcc_warnings;

EOF

    return $dump;
};

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Subclasses MakeMaker::Awesome to always run tests in parallel and add -W flags for XS code

__END__

=for Pod::Coverage .*