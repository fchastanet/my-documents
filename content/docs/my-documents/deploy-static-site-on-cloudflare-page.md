---
title: Deploy Static Site on Cloudflare Pages
linkTitle: Deploy Static Site on Cloudflare Pages
type: docs
tags: [hugo, cloudflare, deployment, cloudflare-pages, github-pages, ci-cd]
date: '2026-04-12T08:00:00+01:00'
lastmod: '2026-04-12T08:00:00+01:00'
version: '1.0'
---

## 1. Introduction

I struggled a bit to deploy my web site. I wanted to have less cost as possible, I will explain here the difficulties I
encountered and how I solved them.

## 2. Hugo

Originally my web site was using [docsify](https://docsify.js.org/) which was giving a great website without a lot of
configuration. But as it's generating a single page application, it was not very good for SEO.

So I switched to [Hugo](https://gohugo.io/) which is a static site generator. It generates a static website that can be
easily deployed on any hosting service.

You can check my other articles about Hugo:

- [My-documents technical architecture](/docs/my-documents/01-technical-architecture.md)
- [Static Site Generation Using Hugo](/docs/my-documents/05-static-site-generation-using-hugo.md)
- [Multi-Site Generation Using Hugo](/docs/my-documents/10-multi-site-generation-using-hugo.md)
- [Trigger My-Documents Workflow](/docs/my-documents/11-trigger-my-documents-workflow.md)

## 3. Github Pages

With this new static site, I wanted to deploy it on Github Pages which is a free hosting service for static websites.
But I encountered issues when I tried to reference the website through Google Search Console. Google Search Console was
triggering "Page with redirect" error. After investigation, I understood that Github Pages is not redirecting http to
https using 301 redirect but in an other way. This is an error for Google Search Console and it was not able to index my
website. I didn't find any solution to this problem, so I decided to switch to another hosting service.

## 4. Cloudflare Pages

I decided to switch to [Cloudflare Pages](https://pages.cloudflare.com/) which proposes a free hosting service for
static websites.

I struggled a bit to understand how to deploy my website on Cloudflare Pages, but I finally succeeded.

There is a way to create cloudflare pages project from the Cloudflare dashboard. It proposes many worker configurations.
You can for example choose to deploy React router, worker for static assets, React + postgresql, etc... But I wanted to
deploy a static website without any worker configuration. There is also a way to make cloudflare to build your website
from a github repository, but I have already a working github workflow to build my website and I just want to deploy the
generated static files on cloudflare pages.

At one moment, I succeed via the Cloudflare dashboard to create a very simple project but I wasn't able to do it again
using the UI (maybe an upgrade of the dashboard or something else).

Anyway, I found a way using wrangler CLI.

### 4.1. Using wrangler CLI

Prerequisite, you need a cloudflare account.

Then you need to create a cloudflare API token with the permission to create and manage pages projects.

Save these credentials in your favorite password manager, you will need them later.

Then you need to login to cloudflare using wrangler CLI:

Here I had some issues with the authentication, as I'm using wsl, when authenticating through the windows browser, the
authentication was not communicated to wsl.

So I installed google-chrome on wsl and authenticated through it, using this command line:

```bash
npx wrangler login --callback-host 0.0.0.0 --callback-port 8976 --browser=false
```

Open google-chrome on wsl, copy-paste the url provided by the command line and authenticate to cloudflare.

Then you need to create a cloudflare pages project using wrangler CLI:

```bash
npx wrangler pages project create bash-tools-framework --production-branch master --cwd build/bash-tools-framework/public
```

This command will create a cloudflare pages project named "bash-tools-framework" with the production branch "master" and
the build output directory "build/bash-tools-framework/public".

Already I could see my website deployed on cloudflare preview pages.

### 4.2. Connect to custom domain

Then I wanted to connect my custom domain to cloudflare pages.

I added a custom domain to my cloudflare pages project, using the cloudflare dashboard, and I added "devlab.top" as
custom domain.

I simply replaced the default dns servers of my OVH custom domain by the cloudflare dns servers.

- braelyn.ns.cloudflare.com
- rudy.ns.cloudflare.com

Then I added a CNAME record to point my custom domain to the cloudflare pages project:

- Type: CNAME
- Name: www
- Target: my-documents-dz6.pages.dev.

After a while, my custom domain was pointing to my cloudflare pages project and I could access my website through
"www.devlab.top". The web site you are reading right now.

## 5. Last step: automate deployment with Github Actions

Finally, I wanted to automate the deployment of my website using Github Actions.

You can check how I did it in
[my-documents build-site-action.yml](https://github.com/fchastanet/my-documents/blob/master/.github/workflows/build-site-action.yml).

There is one trick I had to figure out. This workflow is a sub action of my main workflow. So you need to ensure the
secrets are passed from the main workflow to the sub workflow using `secrets: inherit` in the job triggering the sub
workflow. See
[my-documents main workflow](https://github.com/fchastanet/my-documents/blob/master/.github/workflows/main.yml#L132).

## 6. Conclusion

I finally succeeded and I hope this article will help you to deploy your static website on cloudflare pages and to
automate the deployment using Github Actions.
