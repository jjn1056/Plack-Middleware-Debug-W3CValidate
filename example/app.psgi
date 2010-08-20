use strict;
use warnings;
use Plack::Builder;

builder {
    enable 'Debug', panels =>['W3CValidate'];
    sub {
        return [ 200, [ 'Content-Type' => 'text/html' ], [ '<body>Hello World</body>' ] ];
    };
};

