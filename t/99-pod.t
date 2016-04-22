use strict;
use warnings;

use Test::More 'no_plan';

SKIP: {
    eval 'use Test::Pod 1.26';
    skip('Test::Pod 1.26 required for testing POD', 1) if $@;

    pod_file_ok('lib/Object/InsideOut.pod');
    pod_file_ok('lib/Object/InsideOut/Metadata.pm');
    pod_file_ok('lib/Bundle/Object/InsideOut.pm');
    pod_file_ok('examples/YAPI.pm');
}

SKIP: {
    eval 'use Test::Pod::Coverage 1.08';
    skip('Test::Pod::Coverage 1.08 required for testing POD coverage', 1) if $@;

    pod_coverage_ok('Object::InsideOut',
                    {
                        'trustme' => [
                            qr/^new$/,
                            qr/^clone$/,
                            qr/^set$/,
                            qr/^meta$/,
                            qr/^create_field$/,
                            qr/^add_class$/,
                            qr/^normalize$/,
                        ],
                        'private' => [
                            qr/^STORABLE_freeze$/,
                            qr/^STORABLE_thaw$/,
                            qr/^create_CHAINED$/,
                            qr/^create_CUMULATIVE$/,
                            qr/^create_accessors$/,
                            qr/^create_heritage$/,
                            qr/^create_lvalue_accessor$/,
                            qr/^generate_CHAINED$/,
                            qr/^generate_CUMULATIVE$/,
                            qr/^generate_OVERLOAD$/,
                            qr/^wrap_HIDDEN$/,
                            qr/^wrap_MERGE_ARGS$/,
                            qr/^wrap_PRIVATE$/,
                            qr/^wrap_RESTRICTED$/,
                            qr/^initialize$/,
                            qr/^install_ATTRIBUTES$/,
                            qr/^install_UNIVERSAL$/,
                            qr/^is_sharing$/,
                            qr/^load$/,
                            qr/^preamble_code$/,
                            qr/^type_code$/,
                            qr/^process_fields$/,
                            qr/^set_sharing$/,
                            qr/^sub_name$/,
                            qr/^AUTOLOAD$/,
                            qr/^CLONE$/,
                            qr/^CLONE_SKIP$/,
                            qr/^DESTROY$/,
                            qr/^MODIFY_ARRAY_ATTRIBUTES$/,
                            qr/^MODIFY_CODE_ATTRIBUTES$/,
                            qr/^MODIFY_HASH_ATTRIBUTES$/,
                            qr/^_ID$/,
                            qr/^_args$/,
                            qr/^_obj$/,
                            qr/^import$/,
                        ]
                    }
    );

    pod_coverage_ok('Object::InsideOut::Metadata', {
                        'trustme' => [ qr/^add_meta$/ ],
                    }
    );
}

SKIP: {
    skip('Spelling tested by module maintainer', 1) if (! -d '.svn');
    eval "use Test::Spelling";
    skip("Test::Spelling required for testing POD spelling", 1) if $@;
    if (system('aspell help >/dev/null 2>&1')) {
        skip("'aspell' required for testing POD spelling", 1);
    }
    set_spell_cmd('aspell list --lang=en');
    add_stopwords(<DATA>);
    pod_file_spelling_ok('lib/Object/InsideOut.pod', 'OIO.pod spelling');
    pod_file_spelling_ok('lib/Object/InsideOut/Metadata.pm', 'Metadata.pm POD spelling');
    pod_file_spelling_ok('lib/Bundle/Object/InsideOut.pm', 'Bundle POD spelling');
    pod_file_spelling_ok('examples/YAPI.pm', 'Term::YAPI POD spelling');
    unlink("/home/$ENV{'USER'}/en.prepl", "/home/$ENV{'USER'}/en.pws");
}

__DATA__

API
Hedden
Kubb
Naofumi
OO
OO-compatible
Storable
TSUJII
abigail
accessor's
attribute's
automethods
autopilotmarketing
cpan
de-serialize
gmail
metadata
namespace
non-lvalue
nt
param
parm
Pre
preproc
preprocess
pre-initialization
reloadable
renormalize
uncallable
unhandled

OO-callable
automethod
se

XP

MSDOS
YAPI.pm
async
anim

__END__
