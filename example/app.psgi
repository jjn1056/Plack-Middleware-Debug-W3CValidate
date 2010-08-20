use Plack::Builder;

my $app = sub {
    return [ 200, [ 'Content-Type' => 'text/html' ], [ '<body>Hello World</body>' ] ];
};

builder {
    enable 'Debug', panels =>['W3CValidate'];
    $app;
};
