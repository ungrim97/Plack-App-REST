package Plack::App::REST::DBIC::Serialise;

use Moo::Role;
use URI;

sub serialise_results {
    my ($self, $results, $params, $offset, $rows) = @_;

    my @results;
    while (my $result = $results->next){
        push @results, $self->serialise_row($result);
    }
    return unless @results;

    my $href = URI->new($self->request->base.$results->result_source->source_name);
    $href->query_form(%$params) if keys %$params;
    $href->query_form(offset => $offset, rows => $rows, $href->query_form);

    return {
        total_result    => $results->pager->total_entries,
        offset          => $offset,
        results         => $results->pager->entries_on_this_page,
        href            => $href->as_string,
        data            => \@results,
    }
}

sub serialise_row {
    my ($self, $result) = @_;

    my $href = URI->new($self->request->base.$result->result_source->source_name);
    $href->query_form(map {$_ => $result->$_ } $result->primary_columns);

    return {
        type => $result->result_source->source_name,
        href => $href->as_string,
        data => {$result->get_columns},
    };
}

1;
