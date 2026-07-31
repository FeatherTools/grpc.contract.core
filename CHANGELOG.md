# Changelog

<!-- There is always Unreleased section on the top. Subsections (Add, Changed, Fix, Removed) should be Add as needed. -->
## Unreleased
### Changed
- Distribute the schema via the Buf Schema Registry (`buf.build/feathertools/core`); added `buf.yaml` and `buf.gen.yaml` (managed mode).
- Moved `proto/core.proto` to `proto/feather/core/v1/core.proto` and bumped the package to `feather.core.v1`.
- Generated namespaces changed: .NET `Feather.Contracts` → `Feather.Core.V1`, PHP `Feather\Contracts` → `Feather\Core\V1`.

### Removed
- Removed the `csharp_namespace` / `php_namespace` proto options; Buf managed mode now derives them.

## 1.0.0 - 2026-07-30
- Initial implementation
