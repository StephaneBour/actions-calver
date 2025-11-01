# Calver Releaser for Github Actions

Create calver release (YYYY.VV)

## Race Condition Protection

This action includes protection against race conditions. If a commit is no longer at the HEAD of the branch at the time of execution, the release creation will be skipped. This ensures that only the most recent commit creates a release, thus preventing out-of-order versions.

**Example of a protected scenario:**
- Commit 1 merged → CI takes 10 minutes
- Commit 2 merged → CI takes 2 minutes
- Commit 2 finishes and creates the release (because it is HEAD)
- Commit 1 finishes but does not create a release (because it is no longer HEAD)

## Inputs

### `release_branch`

Branch to tag. Default `master`.

### `name`

The title of the release. Default `release: version ${NEXT_RELEASE}`.

### `message`

The message of the release. Default generate conventional changelog.

### `draft`

Is a draft ?. Default `false`.

### `pre`

Is a pre-release ?. Default `false`.

### `release`

Create a new release ?. Default `true`.

### `date_format`

Set the date format in posix shell. Default `%Y.%V` (Year.Week - 2020.45).

### `version_regexp`

Extended regexp for grep to match existing versions. It has to be consistent with `date_format`. Default `^20[^\-]*$` (catches everything without `-` starting `20`).

### `patch_separator`

Separator to use between version and patch level. Default: `.`

## Output

### `release`

The new release version.

### `title`

Release title

### `changelog`

Changelog generated for the release body

### `draft`

Is the release a draft

### `pre`

Is the release a pre-release

### `created`

Was a release created

## Example usage

### Configuration de base

```yaml
steps:
  - uses: actions/checkout@v2
    
  - name: Calver Release
    uses: StephaneBour/actions-calver@master
    id: calver
    with:
      date_format: "%Y-%m-%d"
      release: ${{ github.event_name == 'push' && github.ref == 'refs/heads/master' }}
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  - name: Deploy
    env:
      VERSION: ${{ steps.calver.outputs.release }}
    run: ./deploy ${VERSION}
```

### Configuration recommandée avec concurrency group

Pour une protection maximale contre les race conditions, utilisez un concurrency group :

```yaml
name: Release

on:
  push:
    branches:
      - master

# Prevent concurrent releases
concurrency:
  group: release-${{ github.ref }}
  cancel-in-progress: false

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
        
      - name: Run tests
        run: npm test
        
      - name: Calver Release
        uses: StephaneBour/actions-calver@master
        id: calver
        with:
          date_format: "%Y.%V"
          release: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Deploy
        if: steps.calver.outputs.created == 'true'
        env:
          VERSION: ${{ steps.calver.outputs.release }}
        run: ./deploy ${VERSION}
```
