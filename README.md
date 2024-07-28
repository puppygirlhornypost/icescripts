# icescripts
scripts for iceshrimp.NET

# installation
you probably need perl at the very minimum. the dependencies are LWP (w/ https support), JSON::MaybeXS, HTTP::Request. if you are running fedora, run

```
sudo dnf install perl-libwww-perl perl-JSON-XS perl-JSON-MaybeXS
```

and you should be good to go.

# why
the version of iceshrimp.NET running on https://ice.puppygirl.sale is 2024.1-beta2.security2+72c0db55e3, which does not have these endpoints exposed in the experimental blazor front end. these are a collection of tools to help me create invite tokens, http bearer tokens (generating an invite requires one) and some user tools for changing password and registering an account.

# why perl
someone said it was hideous that i was rawdogging curl for my instance, so i wrote these perl scripts to be more professional. :)

