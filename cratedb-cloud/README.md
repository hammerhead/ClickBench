CrateDB Cloud Setup
===================

This describes the process of setting up a CrateDB Cloud instance.

Setup
-----

1. Sign up at [https://console.cratedb.cloud/].
2. Install the [Croud CLI](https://cratedb.com/docs/cloud/cli/en/latest/index.html): `pip3 install -U croud`
3. Install the `psql` client, e.g. using `apt-get install postgresql-client` or `brew install postgresql`.
4. Log in by running `croud login --idp <IDP>`. The IDP (Identity Provider) is the login method you used. Currently, it can be one of `cognito, azuread, github, google`.
5. You will need a payment method (subscription). New users receive $200 of credits. Set up a new subscription through the Cloud Console and obtain its ID. You can also view all available subscriptions on the command line using `croud subscriptions list`.

Benchmark
---------

To execute the benchmark, run the following commands:

1. Create a new CrateDB cluster by running: `./setup.sh <SUBSCRIPTION_ID> <ORGANIZATION_ID> <CRATEDB_PASSWORD>`
2. Once the cluster is provisioned, you can run the actual benchmark: `./benchmark.sh `