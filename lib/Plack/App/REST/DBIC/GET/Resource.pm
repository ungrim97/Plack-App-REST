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
    my $page        = delete $params->{page} // 1;
    my $rows        = delete $params->{page_size} // 10;
    my $resultset   = $self->db_schema->resultset($self->db_table);

    for my $param (keys %$params){
        return \400 unless $resultset->result_source->has_column($param);
    }

    my $results = $resultset->search($params, {page => $page, rows => $rows});

    return $self->serialise_results($results, $params, $results->pager, $rows);
}

sub to_json {
    my $self = shift;

    my $response = $self->get_data;

    return \404 unless $response;
    return $response if ref $response eq 'SCALAR';

    return JSON::to_json($response),
}

sub finish_request {
    my ($self, $meta) = @_;
    warn $meta->{exception} if $meta->{exception};
}

1;

