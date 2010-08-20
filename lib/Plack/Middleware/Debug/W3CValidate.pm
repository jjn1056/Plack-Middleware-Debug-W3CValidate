package Plack::Middleware::Debug::W3CValidate;

our $VERSION = '0.01';
use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Base);

use WebService::Validator::HTML::W3C;
use Plack::Util::Accessor qw(validator_uri);

my $table_template = __PACKAGE__->build_template(<<'EOTMPL');
<table>
    <thead>
        <tr>
            <th>Line</th>
            <th>Column</th>
            <th>Message</th>
            <th>Details</th>
        </tr>
    </thead>
    <tbody>
% my $i = 0;
% for my $info (@{$_[0]}) {
            <tr class="<%= ++$i % 2 ? 'plDebugOdd' : 'plDebugEven' %>">
                <td><%= $info->line %></td>
                <td><%= $info->col %></td>
                <td><%= $info->msg %></td>
                <td><%= Text::MicroTemplate::encoded_string($info->explanation) %></td>
            </tr>
% }
    </tbody>
</table>
EOTMPL

sub get_validator {
    my $self = shift @_;
    my %opts = ($self->validator_uri ? (validator_uri=>$self->validator_uri) : ());
    return WebService::Validator::HTML::W3C->new(detailed=>1, %opts);
}

sub flatten_body {
    my ($self, $res) = @_;
    my $body = $res->[2];
    if(ref $body eq 'ARRAY') {
        return join "", @$body;
    } elsif(defined $body) {
        my $slurped;
        while (defined(my $line = $body->getline)) {
            $slurped .= $line if length $line;
        }
        return $slurped;
    }
}

sub run {
    my($self, $env, $panel) = @_;
    $panel->title("W3C Validation");
    $panel->nav_title("W3C Validation");
    return sub {
        my $res = shift @_;
        my $v = $self->get_validator;
        my $slurped_body = $self->flatten_body($res);
        if($v->validate_markup($slurped_body)) {
            if ( $v->is_valid ) {
                $panel->nav_subtitle("Page validated.");
            } else {
                $panel->nav_subtitle('Not valid. Error Count: '.$v->num_errors);
                $panel->content(sub {
                    $self->render($table_template, $v->errors)
                });
            }
        } else {
            $panel->content("Failed to validate the website: ". $v->validator_error);
        }
    }
}

1;

=head1 NAME

Plack::Middleware::Debug::W3CValidate - Validate your Response Content

=head2 SYNOPSIS

    use Plack::Builder;

    my $app = ...; ## Build your Plack App

    builder {
        enable 'Debug', panels =>['W3CValidate'];
        $app;
    };

=head1 DESCRIPTION

Adds a debug panel that runs your response body through the W3C validator and
returns a list of errors.

=head1 OPTIONS

This debug panel defines the following options.

=head2 validator_uri

Takes the url of the W3C validator.  Defaults to the common validator, but if
you plan to pound this it would be polite to setup your own and point to that
instead.  Please see L<WebService::Validator::HTML::W3C> for more.

=head1 SEE ALSO

L<Plack::Middleware::Debug>

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

