use strict;
use warnings;

use inc::Module::Install;

all_from 'lib/Plack/Middleware/Debug/W3cValidate.pm';

requires 'parent';
requires 'Plack';
requires 'Plack::Middleware::Debug';

build_requires 'Test::More' => '0.96';

auto_install;
WriteAll;
