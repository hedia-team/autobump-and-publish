# GitHub Action for version auto-bumping & auto-publishing

This GitHub Action intends to manage the versioning of npm packages via auto-bumping, auto-alpha-publishing & auto-releasing.

This GA allows to easily install and test npm packages as they’ll be automatically published to npm as an alpha release at the moment of creating a Pull Request on GitHub.

All consecutive commits pushed will be published aswell, handling automatically the versioning of each.

## Usage

### Example Workflow file

#### On open PR

```bash
#!/bin/bash
on:
  pull_request:
    branches:
      - master
    types: [opened]
...
...
...
- name: Autobump & Publish
    uses: hedia-team/autobump-and-publish@master
    with:
        label: ${{ toJson(github.event.pull_request.labels.*.name) }}
        npm-token: ${{ env.NPM_TOKEN }}
```

#### On push commit to PR

```bash
#!/bin/bash
on:
  pull_request:
    branches:
      - master
    types: [synchronize]
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
        is-post-merge: true
```

### Inputs

:warning: Under construction :warning:

| Name              | Type                     | Required? | Default | Description                                                                                           |
| ----------------- | ------------------------ | --------- | ------- | ----------------------------------------------------------------------------------------------------- |
| npm-token         | string                   | true      |         | The NPM auth token to use for publishing package to NPM                                               |
| label             | GitHub PR label (string) |           |         | Type of version bump [major, minor, patch] (required on Open PR / On Push)                            |
| is-post-merge     | boolean                  | false     | false   | Boolean used to publish package as release on NPM if action is being triggered by post-merging the PR |
| run-ci            | boolean                  | false     | false   | Value used to determine if npm run ci shall run                                                       |
| run-lint          | boolean                  | false     | false   | Value used to determine if npm run lint shall run                                                     |
| run-lint-pkg      | boolean                  | false     | false   | Value used to determine if npm run lint-pkg shall run                                                 |
| run-test          | boolean                  | false     | false   | Value used to determine if npm run test shall run                                                     |
| run-test-coverage | boolean                  | false     | false   | Value used to determine if npm run test-coverage shall run                                            |
| run-tsc           | boolean                  | false     | false   | Value used to determine if npm run tsc shall run                                                      |

## License

The associated scripts and documentation in this project are released under the [MIT License](LICENSE).

## No affiliation with GitHub Inc.

GitHub are registered trademarks of GitHub, Inc. GitHub name used in this project are for identification purposes only. The project is not associated in any way with GitHub Inc. and is not an official solution of GitHub Inc. It was made available in order to facilitate the use of the site GitHub.

### Using

- [izhangzhihao/delete-comment](https://github.com/marketplace/actions/delete-comment), published by [MIT License](https://github.com/izhangzhihao/delete-comment/blob/master/LICENSE)

- [peter-evans/create-or-update-comment](https://github.com/marketplace/actions/create-or-update-comment), published by [MIT License](https://github.com/peter-evans/create-or-update-comment/blob/main/LICENSE)
