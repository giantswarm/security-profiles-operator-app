# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add a `policies.kyverno.io/v1` PolicyException next to the `kyverno.io/v2` one, so the exception also applies to the CEL (ValidatingPolicy) versions of the policies. `kyvernoPolicyExceptions.legacy.enabled` and `kyvernoPolicyExceptions.cel.enabled` turn each one on or off.
- Label the `kyverno.io/v2` PolicyExceptions with `policy.giantswarm.io/migrated-to-cel: "true"`, to mark them as migrated to CEL.

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
