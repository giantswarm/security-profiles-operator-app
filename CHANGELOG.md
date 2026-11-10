# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-11-10

### Added

- Add `security-profiles-operator` chart.
- Add `refpolicy` container policies.
- Add kyverno PolicyExceptions.

### Changed

- Change `app.giantswarm.io` label group to `application.giantswarm.io`.
- Update `refpolicy` to upstream version `RELEASE_2_20260922`.
- Update `security-profiles-operator` to upstream version `v1.1.2`.

### Fixed

- Install policy exceptions into the `policy-exceptions` namespace instead of the `giantswarm` namespace for ATS 1.x.
- Drop `smoke-tests-cluster-type` and `upgrade-tests-cluster-type` keys that are not supported by ATS 1.x.
- Trim trailing `-`, `.` and `_` in `helm.sh/chart` label.

[Unreleased]: https://github.com/giantswarm/security-profiles-operator-app/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/giantswarm/security-profiles-operator-app/releases/tag/v0.1.0
