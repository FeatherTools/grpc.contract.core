# Changelog

<!-- There is always Unreleased section on the top. Subsections (Add, Changed, Fix, Removed) should be Add as needed. -->
## Unreleased
### Fixed
- Pinned the PHP `php_metadata_namespace` to the standard protoc convention `GPBMetadata\Feather\Contracts\Core\V1` (instead of managed mode's `Feather\Contracts\Core\V1\GPBMetadata` default), so downstream contracts generated without managed mode can load the metadata class.

### Changed
- Added a `GPBMetadata\` PSR-4 autoload entry in `composer.json` for the relocated PHP metadata class.

## 1.2.0 - 2026-07-31
### Changed
- Renamed the package to `feather.contracts.core.v1` (module `buf.build/feathertools/contracts`, path `proto/feather/contracts/core/v1/core.proto`).
- Generated namespaces are now .NET `Feather.Contracts.Core.V1` and PHP `Feather\Contracts\Core\V1`.

## 1.1.0 - 2026-07-31
### Changed
- Distribute the schema via the Buf Schema Registry (`buf.build/feathertools/core`); added `buf.yaml` and `buf.gen.yaml` (managed mode).
- Moved `proto/core.proto` to `proto/feather/core/v1/core.proto` and bumped the package to `feather.core.v1`.
- Generated namespaces changed: .NET `Feather.Contracts` → `Feather.Core.V1`, PHP `Feather\Contracts` → `Feather\Core\V1`.

### Removed
- Removed the `csharp_namespace` / `php_namespace` proto options; Buf managed mode now derives them.

## 1.0.0 - 2026-07-30
- Initial implementation
