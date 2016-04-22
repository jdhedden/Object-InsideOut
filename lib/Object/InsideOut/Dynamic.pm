package Object::InsideOut; {

use strict;
use warnings;
no warnings 'redefine';

sub create_field
{
    my ($u_isa, $TREE_TOP_DOWN, $TREE_BOTTOM_UP, $HERITAGE, $call, @args) = @_;

    # Dynamically create a new object field
    *Object::InsideOut::create_field = sub
    {
        # Handle being called as a method or subroutine
        if ($_[0] eq __PACKAGE__) {
            shift;
        }

        my ($class, $field, @attrs) = @_;
        # Verify valid class
        if (! $class->$u_isa(__PACKAGE__)) {
            OIO::Args->die(
                'message' => 'Not an Object::InsideOut class',
                'Arg'     => $class);
        }

        # Check for valid field
        if ($field !~ /^\s*[@%]\s*[a-zA-Z_]\w*\s*$/) {
            OIO::Args->die(
                'message' => 'Not an array or hash declaration',
                'Arg'     => $field);
        }

        # Convert attributes to single string
        my $attr;
        if (@attrs) {
            s/^\s*(.*?)\s*$/$1/ foreach @attrs;
            $attr = join(',', @attrs);
            $attr =~ s/[\r\n]/ /sg;
            $attr =~ s/,\s*,/,/g;
            $attr =~ s/\s*,\s*:/ :/g;
            if ($attr !~ /^\s*:/) {
                $attr = ":Field($attr)";
            }
        } else {
            $attr = ':Field';
        }

        # Create the declaration
        my @errs;
        local $SIG{'__WARN__'} = sub { push(@errs, @_); };

        my $code = "package $class; my $field $attr;";

        # Inspect generated code
        print("\n", $code, "\n\n") if $Object::InsideOut::DEBUG;

        eval $code;
        if (my $e = Exception::Class::Base->caught()) {
            die($e);
        }
        if ($@ || @errs) {
            my ($err) = split(/ at /, $@ || join(" | ", @errs));
            OIO::Code->die(
                'message' => 'Failure creating field',
                'Error'   => $err,
                'Code'    => $code);
        }

        # Process the declaration
        process_fields();
    };


    # Runtime hierarchy building
    *Object::InsideOut::add_class = sub
    {
        my $class = shift;
        if (ref($class)) {
            OIO::Method->die('message' => q/'add_class' called as an object method/);
        }
        if ($class eq __PACKAGE__) {
            OIO::Method->die('message' => q/'add_class' called on non-class 'Object::InsideOut'/);
        }
        if (! $class->isa(__PACKAGE__)) {
            OIO::Method->die('message' => "'add_class' called on non-Object::InsideOut class '$class'");
        }

        my $pkg = shift;
        if (! $pkg) {
            OIO::Args->die(
                        'message' => 'Missing argument',
                        'Usage'   => "$class\->add_class(\$class)");
        }

        # Already in the hierarchy - ignore
        return if ($class->isa($pkg));

        no strict 'refs';

        # If no package symbols, then load it
        if (! grep { $_ !~ /::$/ } keys(%{$pkg.'::'})) {
            eval "require $pkg";
            if ($@) {
                OIO::Code->die(
                    'message' => "Failure loading package '$pkg'",
                    'Error'   => $@);
            }
            # Empty packages make no sense
            if (! grep { $_ !~ /::$/ } keys(%{$pkg.'::'})) {
                OIO::Code->die('message' => "Package '$pkg' is empty");
            }
        }

        # Import the package, if needed
        if (@_) {
            eval { $pkg->import(@_); };
            if ($@) {
                OIO::Code->die(
                    'message' => "Failure running 'import' on package '$pkg'",
                    'Error'   => $@);
            }
        }

        # Foreign class added
        if (! exists($$TREE_BOTTOM_UP{$pkg})) {
            # Get inheritance 'classes' hash
            if (! exists($$HERITAGE{$class})) {
                create_heritage($class);
            }
            # Add package to inherited classes
            $$HERITAGE{$class}[1]{$pkg} = undef;
            return;
        }

        # Add to class trees
        foreach my $cl (keys(%{$TREE_BOTTOM_UP})) {
            next if (! grep { $_ eq $class } @{$$TREE_BOTTOM_UP{$cl}});

            # Splice in the added class's tree
            my @tree;
            foreach (@{$$TREE_BOTTOM_UP{$cl}}) {
                push(@tree, $_);
                if ($_ eq $class) {
                    my %seen;
                    @seen{@{$$TREE_BOTTOM_UP{$cl}}} = undef;
                    foreach (@{$$TREE_BOTTOM_UP{$pkg}}) {
                        push(@tree, $_) if (! exists($seen{$_}));
                    }
                }
            }

            # Add to @ISA array
            push(@{$cl.'::ISA'}, $pkg);

            # Save revised trees
            $$TREE_BOTTOM_UP{$cl} = \@tree;
            @{$$TREE_TOP_DOWN{$cl}} = reverse(@tree);
        }
    };

    # Do the original call
    @_ = @args;
    goto &$call;
}

}  # End of package's lexical scope


# Ensure correct versioning
my $VERSION = 2.16;
($Object::InsideOut::VERSION == 2.16) or die("Version mismatch\n");
