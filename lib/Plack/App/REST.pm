package Plack::App::REST;
use 5.008005;

use Moo;
use Plack::Util;

our $VERSION = "0.01";

has persistence_mapper => (
    is => 'ro',
    isa => sub {
        return unless $_[0];
        return Plack::Util::load_class($_[0], 'Plack::App::REST');
    },
);

has persistence_args => (
    is => 'ro',
);

sub init {
    my $class = shift;

    my $self = $class->new(@_);

    return $self->init_rest_resource;
}

sub init_rest_resource {
    my ($self) = @_;

    my $resource_initialiser = Plack::Util::load_class($self->persistence_mapper, 'Plack::App::REST');

    $resource_initialiser->new(
        @{$self->persistence_args},
    )->to_psgi_app;

}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::App::REST - It's new $module

=head1 SYNOPSIS

    use Plack::App::REST;

=head1 DESCRIPTION

Plack::App::REST is ...

=head1 LICENSE

Copyright (C) Mike Francis.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Mike Francis E<lt>ungrim97@gmail.comE<gt>

=cut

