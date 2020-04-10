# Calver Releaser for Github Actions

Create calver release

## Inputs

### `release_branch`

Branch to tag. Default `master`.

### `message`

The message of the release. Default `release: version ${NEXT_RELEASE}`.

### `draft`

Is a draft ?. Default `false`.

### `pre`

Is a pre-release ?. Default `false`.

## Example usage

```yaml
- name: Calver Release
  uses: StephaneBour/actions-calver@master
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
