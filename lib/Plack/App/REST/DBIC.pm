package Plack::App::REST::DBIC;

use Web::Simple 'Plack::App::REST::DBIC';
use Web::Machine;
use Data::Dumper;

use Plack::App::REST::DBIC::GET::Resource;
use Plack::App::REST::DBIC::SchemaLoader;

has db_schema => (
    is => 'lazy',
    isa => sub {$_[0]->isa('DBIx::Class::Schema')},
    default => sub {Plack::App::REST::DBIC::SchemaLoader->connect(shift->db_connection_args)},
);

has db_connection_args => (
    is => 'ro',
);

=head1 METHODS

=head2 dispatch_request

Introspects the list of available Domain sources via $schema->sources. Then provides GET, PUT, POST, DELETE endpoints
for each resource in the format:
    VERB /$resource/ ?optional_params

=cut 

sub dispatch_request {
    my ($self) = @_;

    map {
        my $resource = $_;
        warn "Creating path for $resource";
        (
            "GET + /".$resource."/ + ?*" => sub {
                my ($self, $params) = @_;

                Web::Machine->new(
                    resource        => 'Plack::App::REST::DBIC::GET::Resource',
                    resource_args   => [
                        db_schema   => $self->db_schema,
                        db_table    => $resource,
                        db_params   => $params,
                    ],
                );
            },
            "POST + /".$resource."/ + ?*" => sub {
                [ 200, [ 'Content-type', 'text/plain' ], [ 'Hello world!' ] ];
            },
        );
    } $self->db_schema->sources;
}

1;
