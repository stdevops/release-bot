ReleaseBot
===========

# Overview

ReleaseBot is web service which performs automated artifact publication.

It's purpose is to safely perform code releases. Often, people let Jenkins push to Github and 
modify their code base and public artifacts. [Bad things can happen](http://www.infoq.com/news/2013/11/use-the-force).
ReleaseBot isolates `write` operations into a specific code repository, so that automated push behavior
is safer, better defined, and more controlled.

ReleaseBot consists of various coded commands which perform tasks such as `rake release`, `gem yank`,
and publishing to other destinations such as Maven and `apt` repositories. Each command is exposed through
a web service function which is specifically access-controlled and audited.

All secrets which are needed for ReleaseBot commands are obtained by Conjur on an as-needed basis. The ReleaseBot
runs as a specific host identity, with layer membership granting it the access it needs.

# Permissions

Like all our access-controlled web services, ReleaseBot is protected by a 
[Conjur policy](https://github.com/conjurinc/release-bot/blob/master/policy.rb).

Access to ReleaseBot is given by granting specific roles:

* **[policy]/gem-managers** publish and yank gems
* **[policy]/gem-publishers** publish gems

Jenkins is a `gem-publisher` and may get additional permissions in the future.

# Audit

All operations are recorded as Conjur audit events.

For example:

```
$ conjur audit resource -s webservice:production/release-bot-1.0/rubygems
[2014-10-07 15:27:15 UTC] conjurops:user:kgilpin checked that they can create conjurops:webservice:production/release-bot-1.0/rubygems (true)
[2014-10-07 15:27:25 UTC] conjurops:host:heroku/releasebot-conjur reported releasebot:release
```

# Running the service

```
$ CONJURRC=~/accounts/conjurops/.conjurrc conjur env run -c app.secrets -- env CONJUR_POLICY_ID=kgilpin@spudling.local/release-bot-1.1 rackup
$ CONJURRC=~/accounts/conjurops/.conjurrc conjur env run -c app.secrets -- env CONJUR_POLICY_ID=kgilpin@spudling.local/release-bot-1.1 rake work
```

# Client Usage

## Publish a gem release

```
$ curl -H "`conjur authn authenticate -H`" -X POST \
  "https://releasebot-conjur.herokuapp.com/rubygems/releases" \
  --data "name=conjur-api"
```

## Yank a gem release

```
$ curl -H "`conjur authn authenticate -H`" -X DELETE \
  "https://releasebot-conjur.herokuapp.com/rubygems/releases/conjur-api?version=10.0.0"
```

