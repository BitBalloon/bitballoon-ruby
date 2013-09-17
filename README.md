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

You'll need an application client key and a client secret before you can access the BitBalloon API. Please contact us at team@bitballoon.com for your credentials.

Once you have your credentials, connecting to BitBalloon is straight forward:

   bitballoon = BitBalloon::Client.new(:client_id => "YOUR_API_KEY", :client_secret => "YOUR_API_SECRET")

Sites
=====

Getting a list of all sites you have access to:

    bitballoon.sites.each do |site|
      puts site.url
    end

Getting a specific site by id:

    site = bitballoon.sites.get(id)

Creating a site from a directory:

    site = bitballoon.sites.create(:dir => "/tmp/my-site")

Creating a site from a zip file:

    site = bitballoon.sites.create(:zip => "/tmp/my-site.zip")

Both methods will create the site and upload the files. The site will then be processing.

    site.state == "processing"
    site.processing? == true

Refresh a site to update the state:

    site.refresh

Use `wait_until_ready` to wait until a site has finished processing.

    site = bitballoon.sites.create(:dir => "/tmp/my-site")
    site.wait_for_ready
    site.state == "ready"

Update the name of the site (its subdomain), the custom domain and the notification email for form submissions:

    site.update(:subdomain => "my-site", :custom_domain => "www.example.com", :notification_email => "me@example.com")

Deleting a site:

    site.destroy!

Forms
=====

Access all forms you have access to:

    bitballoon.forms

Access forms for a specific site:

    site = bitballoon.sites.get(id)
    site.forms
    
Access a specific form:

    form = bitballoon.forms.get(id)

Access a list of all form submissions you have access to:

    bitballoon.submissions

Access submissions from a specific site

    site = bitballoon.sites.get(id)
    site.submissions

Access submissions from a specific form

    form = bitballoon.forms.get(id)
    form.submissions

Get a specific submission

    bitballoon.submissions.get(id)

Files
=====

Access all files in a site:

    site = bitballoon.sites.get(id)
    site.files

Get a specific file:

    file = site.files.get(path) # Example paths: "/css/main.css", "/index.html"

Reading a file:

    file.read