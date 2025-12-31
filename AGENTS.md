# Agent guidelines

This repository contains [Helm charts](https://helm.sh/) for [Hoppscotch](https://github.com/hoppscotch/hoppscotch), a
lightweight, web-based API development suite. Follow the guidelines below when working in this repository with an agent.

## Development environment

- Use `make install-deps` to install dependencies

## Build and test commands

- Use `make fmt` and `make fmt-fix` to check and fix file formatting issues
- Use `make fmt-<file-type>` and `make fmt-<file-type>-fix` to check and fix file formatting issues for a specific file
  type
- Use `make lint` to check for linting issues
- Use `make lint-<file-type>` to check for linting issues for a specific file type
- Use `make test` to run unit, integration, and end-to-end tests
- Use `make test-<test-type>` to run specific test types
- Use `TEST_UNIT_FILES=<test-file-glob-paths> make test-unit` to run specific unit tests

## Code style and conventions

- Use [Helm Chart Best Practices Guide](https://helm.sh/docs/chart_best_practices/) for chart design best practices
- Use popular Helm charts such as [Bitnami charts](https://github.com/bitnami/charts) and
  [Grafana charts](https://github.com/grafana/helm-charts) for common design patterns

## Testing guidelines

### Unit testing

- Use [helm unittest](https://github.com/helm-unittest/helm-unittest) for unit tests
- Add unit tests to `/charts/<chart-name>/tests` for major, minor, and patch changes
- Do not write unit tests that just check the existence of a value. Instead, assert the correctness of the value using
  helm unittest [assertions](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md#assertion) such as
  `equal` for static values or `matchRegex` for dynamic values.
- Use helm unittest [Kubernetes provider](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md) to unit
  test existing resource lookup logic

### Integration testing

- Use [helm chart tests](https://helm.sh/docs/topics/chart_tests/) for integration tests
- Add integration tests to `/charts/<chart-name>/templates/tests` to check readiness probes for each container

### End-to-end testing

- Use [chart-testing](https://github.com/helm/chart-testing) for end-to-end tests
- Add end-to-end tests to `/charts/<chart-name>/ci` for major changes

## Security considerations

- Use [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) to restrict access to resources
- Store sensitive information in [secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and reference them
  using environment variables

## Commit guidelines

- Use `make pre-commit` to run pre-commit checks and resolve all issues before committing
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages
- Type should be one of the following:
  - **build**: Changes that affect the build system or external dependencies
  - **chore**: Other changes that don't modify src or test files
  - **ci**: Changes to CI configuration files and scripts
  - **docs**: Documentation only changes
  - **feat**: A new feature
  - **fix**: A bug fix
  - **perf**: A code change that improves performance
  - **refactor**: A code change that neither fixes a bug nor adds a feature
  - **style**: Changes that don't affect the meaning of the code
  - **test**: Adding missing tests or correcting existing tests
- Scope should be the name of the chart affected. The following is the list of supported scopes:
  - **hoppscotch**: Hoppscotch chart
  - **shc**: Hoppscotch community chart
  - **she**: Hoppscotch enterprise chart`
