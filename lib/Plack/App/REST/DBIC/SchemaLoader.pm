package Plack::App::REST::DBIC::SchemaLoader;

use strict;
use warnings;

use parent 'DBIx::Class::Schema::Loader';

__PACKAGE__->naming('current');
__PACKAGE__->use_namespaces(1);

1;
