# GameBrief Heroku EU Migration Checklist

## Goal

Move GameBrief from a Heroku app created in the US region to a new Heroku app created in the EU region.

Because Heroku does not allow the region of an existing app to be changed in place, the correct approach is:

1. Create a new Heroku app in the `eu` region
2. Copy config, add-ons, code, and database
3. Move the custom domain from the old app to the new app
4. Verify production works
5. Delete the old app only after cutover is complete

This runbook assumes:

- the app is a Rails app
- the production database is Heroku Postgres
- the public site uses a custom domain managed in Namecheap
- Google OAuth is used in production

## Important Notes For This App

Before migration, review these app-specific items:

- Production uses `DATABASE_URL` from Heroku Postgres
- Required config vars include:
  - `RAILS_MASTER_KEY`
  - `GOOGLE_OAUTH_CLIENT_ID`
  - `GOOGLE_OAUTH_CLIENT_SECRET`
  - `TWITCH_CLIENT_ID`
  - `TWITCH_CLIENT_SECRET`
  - `OPENAI_API_KEY`
- Google OAuth callback URLs must match the final production hostname
- [production.rb](/Users/edhoblyn/GameBrief/config/environments/production.rb) still contains placeholder host values and should be corrected for the real production domain

## Suggested Migration Strategy

Do not delete the current Heroku app first.

The safer sequence is:

1. Audit the current app
2. Create the new EU app
3. Recreate add-ons
4. Copy config vars
5. Deploy the code
6. Restore the database
7. Test on the temporary Heroku URL
8. Move the custom domain
9. Verify live traffic
10. Delete the old app

## Variables To Replace

Replace these placeholders before running commands:

- `OLD_APP` = current live US Heroku app name
- `NEW_APP` = new EU Heroku app name
- `YOUR_DOMAIN` = apex domain, for example `gamebrief.com`
- `WWW_DOMAIN` = subdomain, for example `www.gamebrief.com`

## 1. Prepare For Cutover

- Pick a low-traffic maintenance window
- Log in to Heroku CLI
- Confirm you can access Namecheap DNS
- If possible, lower the DNS TTL in Namecheap a few hours before cutover
- Confirm the current production app is healthy before making changes

Useful login commands:

```bash
heroku login
```

## 2. Audit The Current US App

Capture the current app state before changing anything:

```bash
heroku info -a OLD_APP
heroku config -a OLD_APP
heroku addons -a OLD_APP
heroku domains -a OLD_APP
heroku ps -a OLD_APP
```

Confirm the current config includes:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `GOOGLE_OAUTH_CLIENT_ID`
- `GOOGLE_OAUTH_CLIENT_SECRET`
- `TWITCH_CLIENT_ID`
- `TWITCH_CLIENT_SECRET`
- `OPENAI_API_KEY`

## 3. Create The New EU App

Create a new app in Europe:

```bash
heroku create NEW_APP --region eu
heroku info -a NEW_APP
```

Verify that the app reports:

```text
Region: eu
```

## 4. Recreate Add-ons On The New App

At minimum, create Heroku Postgres on the new app:

```bash
heroku addons:create heroku-postgresql:essential-0 -a NEW_APP
```

If the old app has other add-ons, recreate them on the new app and verify they support the `eu` region.

Check add-ons again:

```bash
heroku addons -a NEW_APP
```

## 5. Copy Config Vars

Set the same production secrets on the new app.

Example:

```bash
heroku config:set RAILS_MASTER_KEY=... -a NEW_APP
heroku config:set GOOGLE_OAUTH_CLIENT_ID=... GOOGLE_OAUTH_CLIENT_SECRET=... -a NEW_APP
heroku config:set TWITCH_CLIENT_ID=... TWITCH_CLIENT_SECRET=... -a NEW_APP
heroku config:set OPENAI_API_KEY=... -a NEW_APP
```

If the current app has any other secrets, copy them as well.

Verify:

```bash
heroku config -a NEW_APP
```

## 6. Deploy The Current Code To The New App

Option 1: point the default Heroku remote at the new app

```bash
heroku git:remote -a NEW_APP
git push heroku main
```

Option 2: keep a separate remote for the EU app

```bash
git remote add heroku-eu https://git.heroku.com/NEW_APP.git
git push heroku-eu main
```

After deploy:

```bash
heroku open -a NEW_APP
heroku logs --tail -a NEW_APP
```

## 7. Copy The Production Database

For this app, copying the database is the critical step.

Capture a backup from the old app:

```bash
heroku pg:backups:capture -a OLD_APP
heroku pg:backups:url -a OLD_APP
```

Then restore that backup into the new app:

```bash
heroku pg:backups:restore "BACKUP_URL" DATABASE_URL -a NEW_APP
```

After restore, run migrations:

```bash
heroku run bin/rails db:migrate -a NEW_APP
```

Only run seeds if they are known to be safe for production:

```bash
heroku run bin/rails db:seed -a NEW_APP
```

## 8. Smoke Test The New EU App Before DNS Changes

Test the temporary Heroku app URL first.

Recommended checks:

- home page loads
- login page loads
- Google sign-in flow works
- games list loads
- patch pages load
- events pages load
- no production exceptions appear in logs

Tail logs while testing:

```bash
heroku logs --tail -a NEW_APP
```

## 9. Confirm Google OAuth Settings

GameBrief uses Google OAuth, so callback URLs must match the final production hostname.

Check whether Google Cloud currently allows:

```text
https://WWW_DOMAIN/users/auth/google_oauth2/callback
```

If Google is still using an old `herokuapp.com` callback URL, add the correct production callback URL before cutover.

If you intend to use both apex and `www`, make sure the exact domain used by users is configured consistently in Google Cloud.

## 10. Review Production Host Configuration

Review [production.rb](/Users/edhoblyn/GameBrief/config/environments/production.rb) before or during the migration.

It currently contains placeholder values such as:

- `http://TODO_PUT_YOUR_DOMAIN_HERE`
- `example.com`

These should be updated to the real production hostname so generated URLs and mailer links are correct.

## 11. Move The Custom Domain From The Old App To The New App

The public domain can stay the same even though the Heroku app changes.

List existing custom domains on the old app:

```bash
heroku domains -a OLD_APP
```

During cutover:

1. Remove each custom domain from `OLD_APP`
2. Add the same custom domain to `NEW_APP`
3. Wait for Heroku to confirm the domain

Examples:

```bash
heroku domains:remove WWW_DOMAIN -a OLD_APP
heroku domains:add WWW_DOMAIN -a NEW_APP
heroku domains:wait 'WWW_DOMAIN' -a NEW_APP
```

If the apex domain is also attached:

```bash
heroku domains:remove YOUR_DOMAIN -a OLD_APP
heroku domains:add YOUR_DOMAIN -a NEW_APP
heroku domains:wait 'YOUR_DOMAIN' -a NEW_APP
```

## 12. Update Namecheap DNS If Heroku Gives A New Target

After adding the domain to the new app, inspect the DNS target Heroku expects:

```bash
heroku domains -a NEW_APP
```

Then update Namecheap if needed:

- `www` should usually be a `CNAME` pointing to the Heroku DNS target
- the apex domain should use the appropriate Namecheap-supported record type for root-domain forwarding to Heroku

Important:

- use the exact DNS target shown by Heroku for `NEW_APP`
- do not assume the old target remains valid

## 13. Verify The Live Site On The Real Domain

Once the domain is attached and DNS is updated, verify:

- the site loads on the production domain
- HTTPS works correctly
- Google OAuth works on the real domain
- games and patch pages load
- no errors appear in logs

Useful command:

```bash
heroku logs --tail -a NEW_APP
```

## 14. Delete The Old US App

Only after the new EU app is fully serving live traffic:

```bash
heroku apps:destroy -a OLD_APP --confirm OLD_APP
```

## 15. Optional: Reuse The Old Heroku App Name

This is usually not necessary if users access the site through the custom domain.

In most cases, the public domain matters more than the Heroku app name.

Only bother reusing the old Heroku app name if:

- you depend on the `*.herokuapp.com` URL somewhere
- a third-party service still points at the old Heroku hostname
- you want naming consistency for operational reasons

## Final Cutover Checklist

- [ ] Current US app audited
- [ ] New EU app created
- [ ] New EU app confirmed in `eu` region
- [ ] Heroku Postgres attached to new app
- [ ] Config vars copied
- [ ] Code deployed to new app
- [ ] Database backup captured from old app
- [ ] Database restored to new app
- [ ] `bin/rails db:migrate` run on new app
- [ ] New app tested on temporary Heroku URL
- [ ] Google OAuth callback URLs confirmed
- [ ] Production host settings reviewed
- [ ] Custom domain removed from old app
- [ ] Custom domain added to new app
- [ ] Namecheap DNS checked and updated if required
- [ ] HTTPS verified on live domain
- [ ] Live smoke test passed
- [ ] Old US app deleted

## References

- Heroku Regions: https://devcenter.heroku.com/articles/regions
- Heroku Custom Domains: https://devcenter.heroku.com/articles/custom-domains
- Heroku Renaming Apps: https://devcenter.heroku.com/articles/renaming-apps
- Heroku App Names And Subdomains: https://devcenter.heroku.com/articles/app-names-and-subdomains
- Heroku Postgres Backups: https://devcenter.heroku.com/articles/heroku-postgres-backups
