# Calver Releaser for Github Actions

Create calver release (YYYY.VV)

## Inputs

### `release_branch`

Branch to tag. Default `master`.

### `name`

The title of the release. Default `release: version ${NEXT_RELEASE}`.

### `message`

The message of the release. Default `${NEXT_RELEASE}`.

### `draft`

Is a draft ?. Default `false`.

### `pre`

Is a pre-release ?. Default `false`.

### `release`

Create a new release ?. Default `true`.

## Output

### `release`

The new release name.

## Example usage

```yaml

    steps:
      - uses: actions/checkout@v2
      - run: git fetch --depth=1 origin +refs/tags/*:refs/tags/*
        
      - name: Calver Release
        uses: StephaneBour/actions-calver@master
        id: calver
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Deploy
        env:
          VERSION: ${{ steps.calver.outputs.release }}
        run: ./deploy ${VERSION}
```
