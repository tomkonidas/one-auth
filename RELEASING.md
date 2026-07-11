# Releasing

This is a maintainer-facing guide for cutting a new version of OneAuth and
publishing it to Hex. It isn't included in the published documentation —
it's for whoever is running the release, not for consumers of the package.

## 1. Decide the version

OneAuth follows [Semantic Versioning](https://semver.org/). While the project
is pre-1.0 (see the warning in the README), breaking changes are shipped as a
**minor** version bump (`0.x.0`) rather than a major one, per the SemVer
convention for `0.y.z` releases. Bug fixes and non-breaking additions are
patch (`0.1.x`) or minor (`0.x.0`) releases as appropriate.

## 2. Make sure `main` is releasable

- Confirm CI is green on `main`.
- Run the full local check locally as a final sanity check:

  ```bash
  mix lint
  mix test
  ```

## 3. Bump the version

Update `@version` in `mix.exs`:

```elixir
@version "0.2.0"
```

This single attribute drives the package version, the `source_ref` used for
"View Source" links on Hexdocs, and (via `{:one_auth, "~> 0.1"}`-style
guidance in the README) what consumers pin against.

Commit it:

```bash
git commit -am "Release v0.2.0"
git push
```

Wait for CI to pass on that commit before continuing.

## 4. Tag the release

The tag **must** match the `source_ref: "v#{@version}"` format configured in
`mix.exs`, or ExDoc's "View Source" links will point at a tag that doesn't
exist:

```bash
git tag v0.2.0
git push origin v0.2.0
```

## 5. Create the GitHub Release

This is OneAuth's changelog — see the README's "Changelog" link and the
`Changelog` entry in `mix.exs`'s `package()` links, both of which point at
the [Releases page](https://github.com/tomkonidas/one-auth/releases).

Publishing to Hex happens automatically as soon as the release is published
(see step 6 below), so double-check the release notes and the tag before
clicking publish — there's no "draft" stage after this point.

1. Go to **Releases → Draft a new release** and select the `v0.2.0` tag.
2. Click **Generate release notes** to group merged PRs automatically.
3. Clean up the generated notes so they read as user-facing changes, not raw
   PR titles — e.g. collapse routine dependency bumps into a single line
   rather than listing each Dependabot PR individually.
4. Publish the release.

## 6. Hex publishing (automatic)

Publishing to Hex is handled by
[`.github/workflows/publish.yml`](.github/workflows/publish.yml), which
triggers the moment a release is published in the step above. It:

1. Checks out the exact commit the release tag points at.
2. Verifies the tag matches `@version` in `mix.exs`, failing loudly if they've
   drifted.
3. Runs the test suite.
4. Runs `mix hex.publish --yes`, which publishes both the package and its
   docs.

### One-time setup

Before the first automated release, generate a Hex API key for CI:

```bash
mix hex.user key generate --key-name publish-ci --permission api:write
```

Note this generates a personal key scoped to `api:write` — Hex doesn't offer
a narrower, package-only scope for personal keys (only organization-owned
keys support that). Treat it accordingly: don't reuse it elsewhere, and
revoke and regenerate it (`mix hex.user key remove publish-ci`, then
`generate` again) if it's ever exposed.

Add the generated key as a secret named `HEX_API_KEY`, scoped to a GitHub
Environment named `hex` (Settings → Environments → New environment → `hex` →
add secret). Using an environment rather than a repo-wide secret lets you
optionally require a manual approval before the publish job runs, even after
the release itself is published — a second checkpoint for an action that's
otherwise hard to undo (see the note on revert windows below).

If you generated the key via the Hex.pm dashboard rather than the CLI, set
an expiration (roughly a year is reasonable) rather than "never" — an
expiring key fails loudly in the `Publish` workflow when it lapses, which is
a safer failure mode than a permanently-valid credential sitting in a GitHub
secret indefinitely. When it expires, generate a new one and update the
`HEX_API_KEY` secret; the workflow doesn't need any other changes.

### If something goes wrong

Hex allows reverting: a brand new package within 24 hours of its first
publish, or a new version of an existing package within 1 hour. After that,
the version is permanent. If a bad version slips out, revert if you're still
in the window:

```bash
mix hex.publish --revert 0.2.0
```

Otherwise, retire the version instead (it stays resolvable but shows a
warning to anyone using it):

```bash
mix hex.retire one_auth 0.2.0 --message "Reason for retiring this version"
```

## 7. Verify

Once the `Publish` workflow finishes on the release:

- `https://hex.pm/packages/one_auth` shows the new version.
- `https://hexdocs.pm/one_auth` shows the new version's docs, and the
  "View Source" links resolve to the `v0.2.0` tag.
- The Hex.pm and Hexdocs badges in the README now resolve (they 404 until the
  first version is published).
