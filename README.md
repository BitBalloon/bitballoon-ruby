BitBalloon Ruby Client
======================

BitBalloon is a hosting service for the programmable web. It understands your documents, processes forms and lets you do deploys, manage forms submissions, inject javascript snippets into sites and do intelligent updates of HTML documents through it's API.

Installation
============

Install the gem by running

    gem install bitballoon

or put it in a Gemfile and run `bundle install`

    gem bitballoon


Authenticating
==============

You'll need an application client id and a client secret before you can access the BitBalloon API. Please contact us at team@bitballoon.com for your credentials.

Once you have your credentials you can instantiate a BitBalloon client.

```ruby
bitballoon = BitBalloon::Client.new(:client_id => "YOUR_API_KEY", :client_secret => "YOUR_API_SECRET")
```

Before you can make any requests to the API, you'll need to authenticate with OAuth2. The BitBalloon client supports two OAuth2 flows.

If you're authenticating on behalf of a user, you'll need to get a valid access token for that user. Use the BitBalloon client to request an authentication URL:

```ruby
url = bitballoon.authorize_url(:redirect_urai => "http://www.example.com/callback")
```

The user then visits that URL and will be prompted to authorize your application to access his BitBalloon sites. If she grants permission, she'll be redirected back to the `redirect_uri` provided in the `authorize_url` call. This URL must match the redirect url configured for your BitBalloon application. Once the user comes back to your app, you'll be able to access a `code` query parameter that gives you an authorization code. Use this to finish the OAuth2 flow:

```ruby
bitballoon.authorize!(token, :redirect_uri => "http://www.example.com/callback")
```

If you're not authenticating on behalf of a user you can authorize directly with the API credentials. Just call:

```ruby
bitballoon.authorize_from_credentials!
```

If you already have an OAuth2 `access_token` you can instantiate the client like this:

```ruby
bitballoon = BitBalloon::Client.new(:access_token => access_token)
```

And the client will be ready to do requests. This means that once you've gotten a token via `authorize!` or `authorize_from_credentials!` you can store it and reuse it for later sessions.


Command Line Utility
====================

The BitBalloon gem comes with a handy command line utility for deploying and redeploying sites.

To deploy the site in the current working directory:

```ruby
bitballoon deploy
```

The first time you deploy, you will be asked for your `client id` and `client secret`. After the deploy the tool will store an `access_token` and the `site_id` in `.bitballoon`. Next time you run the command the tool will redeploy the site using the stored `access_token`.

You can also deploy a specific path:

```ruby
bitballoon deploy /path/to/my/site
```

Or a zip file:

```ruby
bitballoon deploy /path/to/my/site.zip
```

Sites
=====

Getting a list of all sites you have access to:

```ruby
bitballoon.sites.each do |site|
  puts site.url
end
```

Getting a specific site by id:

```ruby
site = bitballoon.sites.get(id)
```

Creating a site from a directory:

```ruby
site = bitballoon.sites.create(:dir => "/tmp/my-site")
```

Creating a site from a zip file:

```ruby
site = bitballoon.sites.create(:zip => "/tmp/my-site.zip")
```

Both methods will create the site and upload the files. The site will then be processing.

```ruby
site.state == "processing"
site.processing? == true
```

Refresh a site to update the state:

```ruby
    site.refresh
```

Use `wait_until_ready` to wait until a site has finished processing.

```ruby
site = bitballoon.sites.create(:dir => "/tmp/my-site")
site.wait_for_ready
site.state == "ready"
```

Redeploy a site from a dir:

```ruby
site = bitballoon.sites.get(site_id)
site.update(:dir => "/tmp/my-site")
site.wait_for_ready
```

Redeploy a site from a zip file:

```ruby
site = bitballoon.sites.get(site_id)
site.update(:zip => "/tmp/my-site.zip")
site.wait_for_ready
```

Update the name of the site (its subdomain), the custom domain and the notification email for form submissions:

```ruby
    site.update(:name => "my-site", :custom_domain => "www.example.com", :notification_email => "me@example.com")
```

Deleting a site:

```ruby
    site.destroy!
```

Deploys
=======

Access all deploys for a site

```ruby
site = bitballoon.sites.get(site_id)
site.deploys.all
```

Access a specific deploy

```ruby
site = bitballoon.sites.get(site_id)
site.deploys.get(id)
```

Restore a deploy (makes it the current live version of the site)

```ruby
site.deploys.get(id).restore
```

Users
=====

Access all users you have access to

```ruby
bitballoon.users.all
```

Access a specific user

```ruby
bitballoon.users.get(id)
```

Create a user. **Reseller only**. A unique email is required. You can optionally include a unique uid, typically the database ID you use for the user on your end.

```ruby
bitballoon.users.create(:email => "some@email.com", :uid => "12345")
```

Update a user. **Reseller only**.

```ruby
bitballoon.users.get(id).update(:email => "new@email.com", :uid => "12345")
```

Delete a user. **Reseller only**

```ruby
bitballoon.users.get(id).destroy
```

Get all sites for a user

```ruby
bitballoon.users.get(id).sites
```

Get all form submissions for a user

```ruby
bitballoon.users.get(id).submissions
```

Forms
=====

Access all forms you have access to:

```ruby
    bitballoon.forms.all
```

Access forms for a specific site:

```ruby
    site = bitballoon.sites.get(id)
    site.forms.all
```

Access a specific form:

```ruby
    form = bitballoon.forms.get(id)
```

Access a list of all form submissions you have access to:

```ruby
    bitballoon.submissions.all
```

Access submissions from a specific site

```ruby
    site = bitballoon.sites.get(id)
    site.submissions.all
```

Access submissions from a specific form

```ruby
    form = bitballoon.forms.get(id)
    form.submissions.all
```

Get a specific submission

```ruby
    bitballoon.submissions.get(id)
```

Files
=====

Access all files in a site:

```ruby
    site = bitballoon.sites.get(id)
    site.files.all
```

Get a specific file:

```ruby
    file = site.files.get(path) # Example paths: "/css/main.css", "/index.html"
```

Reading a file:

```ruby
    file.read
```

Snippets
========

Snippets are small code snippets injected into all HTML pages of a site right before the closing head or body tag. To get all snippets for a site:

```ruby
site = bitballoon.sites.get(id)
site.snippets.all
```

Get a specific snippet

```ruby
site.snippets.get(0)
```

Add a snippet to a site.

You can specify a `general` snippet that will be inserted into all pages, and a `goal` snippet that will be injected into a page following a successful form submission. Each snippet must have a title. You can optionally set the position of both the general and the goal snippet to `head` or `footer` to determine if it gets injected into the head tag or at the end of the page.

```ruby
site.snippets.create(
  :general => general_snippet,
  :general_position => "footer",
  :goal => goal_snippet,
  :goal_position => "head",
  :title => "My Snippet"
)
```

Update a snippet

```ruby
site.snippets.get(id).update(
  :general => general_snippet,
  :general_position => "footer",
  :goal => goal_snippet,
  :goal_position => "head",
  :title => "My Snippet"
)
```

Remove a snippet

```ruby
site.snippet.get(id).destroy
end