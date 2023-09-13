# Calver Releaser for Github Actions

Create calver release (YYYY.VV)

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


## Output

### `release`

The new release name.

## Example usage

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
