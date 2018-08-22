# bank-ruby ![](https://travis-ci.org/boardfish/bank-ruby.svg?branch=master)

A finance planner that's (mostly) automated. All you need to do is categorise your transactions manually!

This and its predecessor `bank` are very much inspired by our family's way of doing finances - setting budgets for a bunch of different categories and using that to forecast how much we're likely to spend or save in future.

## Capabilities

- Retrieve your transactions from Monzo as and when they happen with the webhook endpoint.
- Categorise your transactions completely manually.
- See how much you've spent in each category each month.

### Upcoming capabilities

- Set budgets/average income for each category.
- Forecast how much you're likely to have in future based on your budgets and average income.
- More flexibility on the above.
- Cleaner mobile UI
- In-feed reminders to do your finances

## Deployment

Make sure that all environment variables are set.

- MONDO_TOKEN: A Monzo API token. OAuth will be supported...when `mondo-ruby` supports it. *I'll actively try to contribute to that gem in order to further `bank-ruby`'s development.*
- ROOT_URL: The external URL that you're hosting your instance of `bank-ruby` on. **You should secure all endpoints if possible**, but leave `/monzo_webhook_add` exposed if you don't wish to seed the system manually every time you want to update your transactions.
- ACCOUNT_ID: Especially for beta users, Monzo considers your default account as your first account - that being your now-dead prepaid card. If necessary, supply your account ID manually here.
- STARTING_BALANCE: The balance of your account, in pounds, at the seed start date. I might get this from the first transaction in future.
- SEED_START_DATE: An ISO8601 date indicating the point from which you'd like to start seeding the system.

You may also want to modify the category list to your liking. I'll make this more flexible within the system in future.

`docker-compose build; docker-compose up -d`

I'm using `nginx` on my personal server, and I've provided an example config that you might want to use. Build `nginx` with digest authentication support, use `certbot` to get a cert for your subdomain (or a wildcard!), then update the `example-nginx-config` to use your hostname, cert and `.passwd.digest`. If all goes to plan, you'll be asked for the username and password you defined when using `htdigest` to create your `passwd.digest`, and your instance will be using HTTPS. If I can track down the tutorials I used, I'll attach them here too.

## FAQs

### How can I contribute?

Make a pull request! Fork the project, create a branch detailing what you're going to do (e.g. `improve-user-interface`), and once all your changes are done, submit a pull request.

### Why aren't you running this thing as a service?

Security. I don't need to say much more than that. It's really on you to secure your instance of `bank-ruby` as best you can, because after all, it's got your financial data. If you really want to be safe, don't use the webhook, but that takes much of the convenience out of it, really.

I'll be providing guidance on nginx configs in this README in the near future.

### What drove you to do this?

Again, one word answer - utility. I'm gonna make use of it, and I hope you are too.
