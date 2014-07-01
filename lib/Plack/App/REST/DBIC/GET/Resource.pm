package Plack::App::REST::DBIC::GET::Resource;

use parent 'Web::Machine::Resource';

use Moo;
use Data::Dumper;
use JSON ();

with 'Plack::App::REST::DBIC::Serialise';

has db_schema => (
    is => 'ro',
    isa => sub {
        return $_[0]->isa('DBIx::Class::Schema');
    },
);

has db_table => (
    is => 'ro',
    isa => sub {
        return eval {shift->db_schema->sources($_[0])};
    },
);

has db_params => (
    is  => 'ro',
    isa => sub {return ref $_[0] eq 'HASH'},
);

sub content_types_provided {
    [
        {'application/json' => 'to_json'},
    ];
}

sub get_data {
    my ($self) = @_;

    my $params      = $self->db_params;
    my $offset      = delete $params->{offset} // 0;
    my $rows        = delete $params->{results} // 10;
    my $resultset   = $self->db_schema->resultset($self->db_table);

    my $results     = $resultset->search($params, {page => 1, offset => $offset, rows => $rows});

    return $self->serialise_results($results, $params, $offset, $rows);
}

sub to_json {
    my $self = shift;

    my $response = $self->get_data;

    return \404 unless $response;
    return JSON::to_json($response),
}

sub finish_request {
    my ($self, $meta) = @_;
    warn $meta->{exception} if $meta->{exception};
}

1;

