# Feather Core gRPC Contracts — AI agent instructions

This is the **primary** instruction file for AI coding agents. `AGENTS.md` and `CLAUDE.md` reference this file.

## What this repository is

The single source of truth for generic, domain-agnostic Protobuf contracts shared across Feather gRPC services. The schema in `proto/feather/core/v1/core.proto` is compiled by `buf generate` into committed output under `gen/`, published as:

- **.NET**: `Feather.Contracts` NuGet package (`Contracts.csproj` compiles `gen/csharp`).
- **PHP**: `feather/contracts` composer package (autoloads `gen/php`).
- **Protobuf module**: `buf.build/feathertools/core` on the Buf Schema Registry.

It is consumed as a .NET dependency in `Feather.Grpc`, as a PHP dependency in the PHP contracts library, and by depending on the BSR module in other `.proto` files.

## Golden rules

- **`proto/core.proto` is the source of truth.** All message types are defined there. Never hand-edit generated output.
- **Keep contracts generic and domain-agnostic.** This library holds only reusable primitives. Do not add domain-specific types.
- **NO abbreviations** in names. Use full, readable words (`Instance` not `Inst`, `Message` not `Msg`). Exception: an adopted standard's proper name is written fully uppercase.
- Change **only what is asked**. No unsolicited refactors, extra files, or "improvements".
- Do not add `.gitignore` entries or new tooling unless explicitly requested.

## Editing the schema

After changing `proto/feather/core/v1/core.proto`:

1. Lint: `buf lint` (config in `buf.yaml`, STANDARD rule set).
2. .NET classes regenerate automatically at build time via `Grpc.Tools` — run `./build.sh`.
3. Regenerate committed classes: `buf generate` (remote plugins in `buf.gen.yaml`, managed mode) emits C# to `gen/csharp` and PHP to `gen/php`. Commit the updated `gen/` output. `buf build` only compiles the schema; use `buf generate` to emit code.

**Before opening a PR**, always run `buf generate` and commit the regenerated `gen/` files so they stay in sync with the schema in git.

### Proto naming conventions

- File names: `lower_snake_case`
- Messages / enums: `UpperCamelCase`
- Fields: `lower_snake_case`
- Enum values: `UPPER_SNAKE_CASE`
- Package is `feather.core.v1`; do NOT set `csharp_namespace` / `php_namespace` — Buf managed mode derives them (`Feather.Core.V1`, `Feather\Core\V1`).

## Build & tooling

- Build system: [FAKE](https://fake.build/) (F#) via `./build.sh`. Targets: default, `-t tests`, `-t publish`. Flags: `no-lint`, `no-clean`.
- Dependencies: [Paket](https://fsprojects.github.io/Paket/) (`paket.dependencies`, `paket.references`) and dotnet tools (`.config/dotnet-tools.json`).
- PHP: `composer install`; `composer lint` runs parallel-lint + validate + normalize.
- Local setup: `dotnet tool restore && dotnet tool run paket install && ./build.sh && composer install`.

## CI (`.github/workflows/`)

- `net-tests.yaml` — .NET build & tests.
- `php-tests.yaml` — PHP lint / static analysis.
- `proto-lint.yaml` — `buf lint` on the schema.
- `net-publish.yaml` — publishes NuGet on a `MAJOR.MINOR.PATCH` tag push.
- `pr-check.yaml` — blocks fixup commits; shellcheck.

## Releasing

1. Update `CHANGELOG.md` (keep the `## Unreleased` section on top).
2. Bump `<Version>` in `Contracts.csproj`.
3. Push a semver tag (`MAJOR.MINOR.PATCH`) to trigger the publish workflow.
