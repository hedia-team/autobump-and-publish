# GitHub Action for version auto-bumping & auto-publishing

This GitHub Action intends to manage the versioning of npm packages via auto-bumping, auto-alpha-publishing & auto-releasing.

Using this GA allows to easily test npm packages as they’ll be automatically published to npm as an alpha release at the moment of creating a Pull Request on GitHub.
All consecutive commits pushed will be published too, handling automatically the versioning of each.

## Usage

1. **On open/synchronize PR** (poiting to `/master`), the GA will make sure to bump the alpha release accordingly to the label set & publish a new version to NPM.\*

2. **On post-merge** (poiting to `/master`), the GA will publish the package as the @latest release.

\* Steps require to setup `actions/checkout@v2` using own [PAT](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) in order to re-trigger workflows. **If using the default `${{secrets.GITHUB_TOKEN}`, workflows will be omitted.**

The `package.json` version is always bumped accordingly to the latest published version on NPM, and for instance, it will auto-bump in the case of multiple PR's opened at the same time with the same version release type.

## Considerations

In order to keep the version properly updated, make sure to enable the "Require branches to be up to date before merging" rule on your GitHub `mater` branch.

### Example Workflow file

#### On open/synchronize

```bash
#!/bin/bash
on:
  pull_request:
    branches:
      - master
    types: [opened, reopened, synchronize]
...
...
...
- uses: mstachniuk/ci-skip@v1
    with:
    commit-filter: "autobump"

- name: Autobump & Publish
    if: ${{ env.CI_SKIP == 'false' }}
    uses: hedia-team/autobump-and-publish@master
    with:
        label: ${{ toJson(github.event.pull_request.labels.*.name) }}
        npm-token: ${{ env.NPM_TOKEN }}
        issue-number: ${{ github.event.number }}
        github-token: ${{ secrets.GITHUB_TOKEN }}
```

#### On post merge

```bash
#!/bin/bash
on:
  pull_request:
    branches:
      - master
    types: [closed]
...
...
...
- name: Autobump & Publish
    uses: hedia-team/autobump-and-publish@master
    with:
        npm-token: ${{ env.NPM_TOKEN }}
        issue-number: ${{ github.event.number }}
        github-token: ${{ secrets.GITHUB_TOKEN }}
        is-post-merge: true
```

### Inputs

| Name          | Type                     | Required? | Default                                | Description                                                                  |
| ------------- | ------------------------ | --------- | -------------------------------------- | ---------------------------------------------------------------------------- |
| github-token  | string                   | true      |                                        | GitHub token required by delete-comment workflow to remove comment from PR   |
| npm-token     | string                   | true      |                                        | NPM token required to publish package to npm                                 |
| issue-number  | number/string            | true      |                                        | Issue number required by create-or-update-comment & delete-comment workflows |
| label         | GitHub PR label (string) | -         |                                        | Type of version bump [major, minor, patch] (required on Open PR / On Push)   |
| git-email     | string                   | false     | github-action@users.noreply.github.com | Value for git config user.email                                              |
| git-name      | string                   | false     | github-actions[bot]                    | Value for git config user.name                                               |
| is-post-merge | boolean                  | false     | false                                  | Boolean used to publish package as release on NPM                            |
| run-scripts   | string                   | false     | -                                      | Scripts to be executed prior to publishing package                           |

## License

The associated scripts and documentation in this project are released under the [MIT License](LICENSE).

## No affiliation with GitHub Inc.

GitHub are registered trademarks of GitHub, Inc. GitHub name used in this project are for identification purposes only. The project is not associated in any way with GitHub Inc. and is not an official solution of GitHub Inc. It was made available in order to facilitate the use of the site GitHub.

### Using

- [izhangzhihao/delete-comment](https://github.com/marketplace/actions/delete-comment), published by [MIT License](https://github.com/izhangzhihao/delete-comment/blob/master/LICENSE)

- [peter-evans/create-or-update-comment](https://github.com/marketplace/actions/create-or-update-comment), published by [MIT License](https://github.com/peter-evans/create-or-update-comment/blob/main/LICENSE)

- [mstachniuk/ci-ski](https://github.com/marketplace/actions/ci-skip-action), published by [MIT License](https://github.com/mstachniuk/ci-skip/blob/master/LICENSE)
